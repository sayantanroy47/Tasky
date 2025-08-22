import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';

/// Lazy-loading audio playback service that initializes only when first used
class LazyAudioPlaybackService {
  static LazyAudioPlaybackService? _instance;
  static LazyAudioPlaybackService get instance => _instance ??= LazyAudioPlaybackService._internal();
  
  LazyAudioPlaybackService._internal();

  FlutterSoundPlayer? _player;
  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _isPlaying = false;
  String? _currentFilePath;
  StreamSubscription<PlaybackDisposition>? _playbackSubscription;
  Completer<bool>? _initCompleter;

  /// Lazy initialization - only called when service is first used
  Future<bool> _ensureInitialized() async {
    if (_isInitialized) return true;
    
    if (_isInitializing) {
      return await _initCompleter!.future;
    }

    _isInitializing = true;
    _initCompleter = Completer<bool>();

    try {
      if (kDebugMode) {
        print('LazyAudioPlaybackService: Initializing on demand...');
      }
      
      _player = FlutterSoundPlayer();
      await _player!.openPlayer();
      _isInitialized = true;
      
      if (kDebugMode) {
        print('LazyAudioPlaybackService: Successfully initialized');
      }
      
      _initCompleter!.complete(true);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('LazyAudioPlaybackService: Failed to initialize: $e');
      }
      
      _player = null;
      _isInitialized = false;
      _initCompleter!.complete(false);
      return false;
    } finally {
      _isInitializing = false;
    }
  }

  /// Check if the service is ready (doesn't trigger initialization)
  bool get isReady => _isInitialized;

  /// Check if currently playing
  bool get isPlaying => _isPlaying;

  /// Get currently playing file path
  String? get currentFilePath => _currentFilePath;

  /// Play an audio file - initializes service if needed
  Future<void> playAudioFile(
    String filePath, {
    Function(Duration, Duration)? onProgress,
    VoidCallback? onComplete,
  }) async {
    if (!await _ensureInitialized()) {
      throw Exception('Audio service failed to initialize');
    }

    if (_player == null) return;

    try {
      // Stop current playback if any
      if (_isPlaying) {
        await stopAudio();
      }

      if (!File(filePath).existsSync()) {
        throw Exception('Audio file not found: $filePath');
      }

      _currentFilePath = filePath;
      _isPlaying = true;

      // Set up progress monitoring if callback provided
      if (onProgress != null) {
        _playbackSubscription = _player!.onProgress!.listen(
          (disposition) {
            onProgress(disposition.position, disposition.duration);
                    },
        );
      }

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
        print('LazyAudioPlaybackService: Error playing audio: $e');
      }
      rethrow;
    }
  }

  /// Stop audio playback
  Future<void> stopAudio() async {
    if (!_isInitialized || _player == null) return;

    try {
      if (_isPlaying) {
        await _player!.stopPlayer();
      }
    } catch (e) {
      if (kDebugMode) {
        print('LazyAudioPlaybackService: Error stopping audio: $e');
      }
    } finally {
      _isPlaying = false;
      _currentFilePath = null;
      _playbackSubscription?.cancel();
      _playbackSubscription = null;
    }
  }

  /// Pause audio playback
  Future<void> pauseAudio() async {
    if (!_isInitialized || _player == null || !_isPlaying) return;

    try {
      await _player!.pausePlayer();
      _isPlaying = false;
    } catch (e) {
      if (kDebugMode) {
        print('LazyAudioPlaybackService: Error pausing audio: $e');
      }
    }
  }

  /// Resume audio playback
  Future<void> resumeAudio() async {
    if (!_isInitialized || _player == null) return;

    try {
      await _player!.resumePlayer();
      _isPlaying = true;
    } catch (e) {
      if (kDebugMode) {
        print('LazyAudioPlaybackService: Error resuming audio: $e');
      }
    }
  }

  /// Set playback volume
  Future<void> setVolume(double volume) async {
    if (!_isInitialized || _player == null) return;

    try {
      await _player!.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      if (kDebugMode) {
        print('LazyAudioPlaybackService: Error setting volume: $e');
      }
    }
  }

  /// Get current playback position  
  Future<Duration?> getCurrentPosition() async {
    if (!_isInitialized || _player == null || !_isPlaying) return null;

    try {
      // Simple position tracking - can be enhanced later
      return Duration.zero;
    } catch (e) {
      if (kDebugMode) {
        print('LazyAudioPlaybackService: Error getting position: $e');
      }
      return null;
    }
  }

  /// Seek to specific position
  Future<void> seekTo(Duration position) async {
    if (!_isInitialized || _player == null || !_isPlaying) return;

    try {
      await _player!.seekToPlayer(position);
    } catch (e) {
      if (kDebugMode) {
        print('LazyAudioPlaybackService: Error seeking: $e');
      }
    }
  }

  /// Dispose the service
  Future<void> dispose() async {
    try {
      await stopAudio();
      if (_player != null) {
        await _player!.closePlayer();
      }
    } catch (e) {
      if (kDebugMode) {
        print('LazyAudioPlaybackService: Error disposing: $e');
      }
    } finally {
      _player = null;
      _isInitialized = false;
      _isInitializing = false;
      _isPlaying = false;
      _currentFilePath = null;
      _initCompleter = null;
    }
  }

  /// Preload the service without playing anything
  /// Useful for warming up the service when you know it will be needed soon
  Future<bool> warmup() async {
    return await _ensureInitialized();
  }

  /// Get the duration of an audio file without playing it
  Future<Duration?> getAudioDuration(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      if (kDebugMode) {
        print('Audio file does not exist: $filePath');
      }
      return null;
    }

    // Ensure the service is initialized
    final initialized = await _ensureInitialized();
    if (!initialized) {
      if (kDebugMode) {
        print('Failed to initialize LazyAudioPlaybackService for duration check');
      }
      return null;
    }

    try {
      // For now, return null as flutter_sound doesn't provide duration without playback
      // Real implementation would require additional audio processing libraries
      if (kDebugMode) {
        print('LazyAudioPlaybackService: Duration check requested for $filePath');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting audio duration in LazyAudioPlaybackService: $e');
      }
      return null;
    }
  }

  /// Get service status for debugging
  Map<String, dynamic> getStatus() {
    return {
      'isInitialized': _isInitialized,
      'isInitializing': _isInitializing,
      'isPlaying': _isPlaying,
      'currentFile': _currentFilePath,
      'playerExists': _player != null,
    };
  }
}