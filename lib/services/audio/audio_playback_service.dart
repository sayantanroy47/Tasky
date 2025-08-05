import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';

/// Service for handling audio playback functionality
class AudioPlaybackService {
  FlutterSoundPlayer? _player;
  bool _isInitialized = false;
  bool _isPlaying = false;
  String? _currentFilePath;
  StreamSubscription<PlaybackDisposition>? _playbackSubscription;

  /// Initialize the audio playback service
  Future<bool> initialize() async {
    try {
      _player = FlutterSoundPlayer();
      await _player!.openPlayer();
      _isInitialized = true;
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize audio player: $e');
      }
      return false;
    }
  }

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Check if currently playing
  bool get isPlaying => _isPlaying;

  /// Get currently playing file path
  String? get currentFilePath => _currentFilePath;

  /// Play an audio file
  Future<void> playAudioFile(
    String filePath, {
    Function(Duration, Duration)? onProgress,
    VoidCallback? onComplete,
  }) async {
    if (!_isInitialized || _player == null) {
      throw Exception('Audio player not initialized');
    }

    if (_isPlaying) {
      await stopPlayback();
    }

    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Audio file does not exist: $filePath');
    }

    try {
      _currentFilePath = filePath;
      _isPlaying = true;

      // Set up progress tracking
      _playbackSubscription = _player!.onProgress!.listen((event) {
        onProgress?.call(event.position, event.duration);
      });

      await _player!.startPlayer(
        fromURI: filePath,
        whenFinished: () {
          _isPlaying = false;
          _currentFilePath = null;
          _playbackSubscription?.cancel();
          _playbackSubscription = null;
          onComplete?.call();
        },
      );
    } catch (e) {
      _isPlaying = false;
      _currentFilePath = null;
      _playbackSubscription?.cancel();
      _playbackSubscription = null;
      if (kDebugMode) {
        print('Failed to play audio file: $e');
      }
      rethrow;
    }
  }

  /// Pause playback
  Future<void> pausePlayback() async {
    if (_player != null && _isPlaying) {
      await _player!.pausePlayer();
    }
  }

  /// Resume playback
  Future<void> resumePlayback() async {
    if (_player != null && !_isPlaying && _currentFilePath != null) {
      await _player!.resumePlayer();
    }
  }

  /// Stop playback
  Future<void> stopPlayback() async {
    if (_player != null && _isPlaying) {
      await _player!.stopPlayer();
      _isPlaying = false;
      _currentFilePath = null;
      _playbackSubscription?.cancel();
      _playbackSubscription = null;
    }
  }

  /// Seek to a specific position
  Future<void> seekTo(Duration position) async {
    if (_player != null && _isPlaying) {
      await _player!.seekToPlayer(position);
    }
  }

  /// Get the duration of an audio file without playing it
  Future<Duration?> getAudioDuration(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return null;
    }

    // For now, return null - would need additional processing to get duration
    // without starting playback
    return null;
  }

  /// Dispose of the audio playback service
  Future<void> dispose() async {
    await stopPlayback();
    
    if (_player != null) {
      await _player!.closePlayer();
      _player = null;
    }
    
    _isInitialized = false;
  }
}