import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'audio_playback_service.dart';

/// Audio playback states
enum AudioPlayerState {
  idle,
  loading,
  ready,
  playing,
  paused,
  stopped,
  error,
}

/// Audio playback speed options
enum PlaybackSpeed {
  slow(0.75),
  normal(1.0),
  fast(1.25),
  faster(1.5),
  fastest(2.0);

  const PlaybackSpeed(this.value);
  final double value;

  String get label => switch (this) {
    PlaybackSpeed.slow => '0.75x',
    PlaybackSpeed.normal => '1x',
    PlaybackSpeed.fast => '1.25x',
    PlaybackSpeed.faster => '1.5x',
    PlaybackSpeed.fastest => '2x',
  };
}

/// Audio playback information
class AudioPlaybackInfo {
  final String filePath;
  final Duration duration;
  final Duration position;
  final AudioPlayerState state;
  final PlaybackSpeed speed;
  final double volume;
  final String? error;

  const AudioPlaybackInfo({
    required this.filePath,
    required this.duration,
    required this.position,
    required this.state,
    this.speed = PlaybackSpeed.normal,
    this.volume = 1.0,
    this.error,
  });

  AudioPlaybackInfo copyWith({
    String? filePath,
    Duration? duration,
    Duration? position,
    AudioPlayerState? state,
    PlaybackSpeed? speed,
    double? volume,
    String? error,
  }) {
    return AudioPlaybackInfo(
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      state: state ?? this.state,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
      error: error ?? this.error,
    );
  }

  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  Duration get remaining => duration - position;

  bool get isPlaying => state == AudioPlayerState.playing;
  bool get isPaused => state == AudioPlayerState.paused;
  bool get isLoading => state == AudioPlayerState.loading;
  bool get hasError => state == AudioPlayerState.error;
}

/// Service for managing audio playback across the app
class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final StreamController<AudioPlaybackInfo> _stateController = StreamController<AudioPlaybackInfo>.broadcast();
  
  AudioPlaybackInfo _currentInfo = const AudioPlaybackInfo(
    filePath: '',
    duration: Duration.zero,
    position: Duration.zero,
    state: AudioPlayerState.idle,
  );

  // Real audio playback service
  final AudioPlaybackService _realPlayer = AudioPlaybackService();
  bool _isPlayerInitialized = false;
  String? _currentTaskId;

  // Stream of audio player state changes
  Stream<AudioPlaybackInfo> get audioStateStream => _stateController.stream;
  AudioPlaybackInfo get currentState => _currentInfo;
  String? get currentTaskId => _currentTaskId;

  /// Load and prepare audio file for playback
  Future<void> loadAudio(String filePath, String taskId) async {
    try {
      // Stop any currently playing audio
      await stop();

      _currentTaskId = taskId;
      _updateState(_currentInfo.copyWith(
        filePath: filePath,
        state: AudioPlayerState.loading,
        error: null,
      ));

      // Initialize real player if needed
      if (!_isPlayerInitialized) {
        _isPlayerInitialized = await _realPlayer.initialize();
        if (!_isPlayerInitialized) {
          throw Exception('Failed to initialize audio player');
        }
      }

      // Check if file exists
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Audio file not found: $filePath');
      }

      // Get real duration from audio file using the real player
      Duration actualDuration;
      try {
        final duration = await _realPlayer.getAudioDuration(filePath);
        actualDuration = duration ?? const Duration(seconds: 5); // fallback to 5 seconds if unable to get duration
      } catch (e) {
        debugPrint('Could not get real audio duration: $e');
        actualDuration = const Duration(seconds: 5); // fallback
      }

      _updateState(_currentInfo.copyWith(
        duration: actualDuration,
        state: AudioPlayerState.ready,
        position: Duration.zero,
      ));

      debugPrint('Audio loaded for real playback: $filePath (${_formatDuration(actualDuration)})');

    } catch (e) {
      _updateState(_currentInfo.copyWith(
        state: AudioPlayerState.error,
        error: e.toString(),
      ));
      debugPrint('Error loading audio: $e');
    }
  }

  /// Start or resume playback
  Future<void> play() async {
    if (_currentInfo.state != AudioPlayerState.ready && 
        _currentInfo.state != AudioPlayerState.paused) {
      return;
    }

    try {
      _updateState(_currentInfo.copyWith(state: AudioPlayerState.playing));
      
      // Start real audio playback
      await _realPlayer.playAudioFile(
        _currentInfo.filePath,
        onProgress: (position, duration) {
          // Update position from real audio player
          _updateState(_currentInfo.copyWith(
            position: position,
            duration: duration, // Update with real duration if available
          ));
        },
        onComplete: () {
          // Playback completed
          _onPlaybackCompleted();
        },
      );

      // Haptic feedback for play action
      HapticFeedback.lightImpact();
      debugPrint('Real audio playback started: ${_currentInfo.filePath}');

    } catch (e) {
      _updateState(_currentInfo.copyWith(
        state: AudioPlayerState.error,
        error: e.toString(),
      ));
      debugPrint('Error starting real playback: $e');
    }
  }

  /// Pause playback
  Future<void> pause() async {
    if (_currentInfo.state != AudioPlayerState.playing) return;

    try {
      await _realPlayer.pausePlayback();
      _updateState(_currentInfo.copyWith(state: AudioPlayerState.paused));
      
      HapticFeedback.selectionClick();
      debugPrint('Real audio playback paused');
    } catch (e) {
      debugPrint('Error pausing real playback: $e');
    }
  }

  /// Stop playback and reset position
  Future<void> stop() async {
    try {
      await _realPlayer.stopPlayback();
      
      if (_currentInfo.state != AudioPlayerState.idle) {
        _updateState(_currentInfo.copyWith(
          state: AudioPlayerState.stopped,
          position: Duration.zero,
        ));
      }
      
      _currentTaskId = null;
      debugPrint('Real audio playback stopped');
    } catch (e) {
      debugPrint('Error stopping real playback: $e');
    }
  }

  /// Seek to specific position
  Future<void> seekTo(Duration position) async {
    if (_currentInfo.state == AudioPlayerState.idle || 
        _currentInfo.state == AudioPlayerState.loading) {
      return;
    }

    try {
      final clampedPosition = Duration(
        milliseconds: position.inMilliseconds.clamp(0, _currentInfo.duration.inMilliseconds),
      );

      await _realPlayer.seekTo(clampedPosition);
      _updateState(_currentInfo.copyWith(position: clampedPosition));
      
      HapticFeedback.selectionClick();
      debugPrint('Real audio seeked to: ${_formatDuration(clampedPosition)}');
    } catch (e) {
      debugPrint('Error seeking real playback: $e');
    }
  }

  /// Change playback speed
  Future<void> setPlaybackSpeed(PlaybackSpeed speed) async {
    if (_currentInfo.state == AudioPlayerState.idle) return;

    _updateState(_currentInfo.copyWith(speed: speed));
    debugPrint('Playback speed changed to: ${speed.label}');
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0);
    _updateState(_currentInfo.copyWith(volume: clampedVolume));
    debugPrint('Volume set to: ${(clampedVolume * 100).round()}%');
  }

  /// Skip forward by specified duration
  Future<void> skipForward(Duration duration) async {
    final newPosition = _currentInfo.position + duration;
    await seekTo(newPosition);
  }

  /// Skip backward by specified duration
  Future<void> skipBackward(Duration duration) async {
    final newPosition = _currentInfo.position - duration;
    await seekTo(newPosition);
  }

  /// Toggle between play and pause
  Future<void> togglePlayPause() async {
    if (_currentInfo.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Check if the given task is currently playing
  bool isTaskPlaying(String taskId) {
    return _currentTaskId == taskId && _currentInfo.isPlaying;
  }

  /// Check if the given task is currently loaded (but not necessarily playing)
  bool isTaskLoaded(String taskId) {
    return _currentTaskId == taskId && _currentInfo.state != AudioPlayerState.idle;
  }

  void _onPlaybackCompleted() {
    _updateState(_currentInfo.copyWith(
      state: AudioPlayerState.stopped,
      position: _currentInfo.duration,
    ));
    
    HapticFeedback.lightImpact();
    debugPrint('Audio playback completed');
  }

  void _updateState(AudioPlaybackInfo newInfo) {
    _currentInfo = newInfo;
    _stateController.add(_currentInfo);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  /// Dispose and clean up resources
  void dispose() {
    _realPlayer.dispose();
    _stateController.close();
  }
}