import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/audio/audio_player_service.dart';
import '../../services/audio/audio_file_manager.dart';
import '../../services/audio/audio_recording_service.dart';

/// Provider for the singleton audio player service
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  return AudioPlayerService();
});

/// Provider for the singleton audio file manager
final audioFileManagerProvider = Provider<AudioFileManager>((ref) {
  return AudioFileManager();
});

/// Provider for the singleton audio recording service
final audioRecordingServiceProvider = Provider<AudioRecordingService>((ref) {
  return AudioRecordingService();
});

/// Provider for the current audio playback state
final audioPlaybackStateProvider = StreamProvider<AudioPlaybackInfo>((ref) {
  final audioService = ref.read(audioPlayerServiceProvider);
  return audioService.audioStateStream;
});

/// Provider to check if a specific task is currently playing
final isTaskPlayingProvider = Provider.family<bool, String>((ref, taskId) {
  final audioService = ref.read(audioPlayerServiceProvider);
  return audioService.isTaskPlaying(taskId);
});

/// Provider to check if a specific task has audio loaded
final isTaskLoadedProvider = Provider.family<bool, String>((ref, taskId) {
  final audioService = ref.read(audioPlayerServiceProvider);
  return audioService.isTaskLoaded(taskId);
});

/// Provider to get the currently playing task ID
final currentPlayingTaskProvider = Provider<String?>((ref) {
  final audioService = ref.read(audioPlayerServiceProvider);
  return audioService.currentTaskId;
});

/// Provider for audio file metadata
final audioFileMetadataProvider = FutureProvider.family<AudioFileMetadata?, String>((ref, filePath) async {
  final fileManager = ref.read(audioFileManagerProvider);
  return await fileManager.getFileMetadata(filePath);
});

/// Provider to check if an audio file exists
final audioFileExistsProvider = FutureProvider.family<bool, String>((ref, filePath) async {
  final fileManager = ref.read(audioFileManagerProvider);
  return await fileManager.audioFileExists(filePath);
});

/// Provider for all audio files in the system
final allAudioFilesProvider = FutureProvider<List<AudioFileMetadata>>((ref) async {
  final fileManager = ref.read(audioFileManagerProvider);
  return await fileManager.getAllAudioFiles();
});

/// Provider for total storage used by audio files
final audioStorageUsageProvider = FutureProvider<int>((ref) async {
  final fileManager = ref.read(audioFileManagerProvider);
  return await fileManager.getTotalStorageUsed();
});

/// Notifier for audio player controls
class AudioPlayerNotifier extends StateNotifier<AudioPlaybackInfo> {
  final AudioPlayerService _audioService;

  AudioPlayerNotifier(this._audioService) 
      : super(const AudioPlaybackInfo(
          filePath: '',
          duration: Duration.zero,
          position: Duration.zero,
          state: AudioPlayerState.idle,
        )) {
    // Listen to audio service state changes
    _audioService.audioStateStream.listen((info) {
      state = info;
    });
  }

  /// Load and prepare audio for a task
  Future<void> loadAudioForTask(String taskId, String audioFilePath) async {
    await _audioService.loadAudio(audioFilePath, taskId);
  }

  /// Play the currently loaded audio
  Future<void> play() async {
    await _audioService.play();
  }

  /// Pause the currently playing audio
  Future<void> pause() async {
    await _audioService.pause();
  }

  /// Stop playback and reset
  Future<void> stop() async {
    await _audioService.stop();
  }

  /// Toggle between play and pause
  Future<void> togglePlayPause() async {
    await _audioService.togglePlayPause();
  }

  /// Seek to a specific position
  Future<void> seekTo(Duration position) async {
    await _audioService.seekTo(position);
  }

  /// Skip forward by 10 seconds
  Future<void> skipForward() async {
    await _audioService.skipForward(const Duration(seconds: 10));
  }

  /// Skip backward by 10 seconds
  Future<void> skipBackward() async {
    await _audioService.skipBackward(const Duration(seconds: 10));
  }

  /// Set playback speed
  Future<void> setSpeed(PlaybackSpeed speed) async {
    await _audioService.setPlaybackSpeed(speed);
  }

  /// Set volume
  Future<void> setVolume(double volume) async {
    await _audioService.setVolume(volume);
  }
}

/// Provider for the audio player notifier
final audioPlayerProvider = StateNotifierProvider<AudioPlayerNotifier, AudioPlaybackInfo>((ref) {
  final audioService = ref.read(audioPlayerServiceProvider);
  return AudioPlayerNotifier(audioService);
});

/// Provider for audio player controls (simplified interface)
final audioControlsProvider = Provider<AudioControls>((ref) {
  return AudioControls(ref);
});

/// Simplified audio controls interface
class AudioControls {
  final Ref _ref;

  AudioControls(this._ref);

  /// Play audio for a specific task
  Future<void> playTask(String taskId, String audioFilePath) async {
    final notifier = _ref.read(audioPlayerProvider.notifier);
    
    // If a different task is playing, stop it first
    final currentTaskId = _ref.read(currentPlayingTaskProvider);
    if (currentTaskId != null && currentTaskId != taskId) {
      await notifier.stop();
    }
    
    // Load and play the requested task
    await notifier.loadAudioForTask(taskId, audioFilePath);
    await notifier.play();
  }

  /// Toggle play/pause for a specific task
  Future<void> togglePlayPauseForTask(String taskId, String audioFilePath) async {
    try {
      final notifier = _ref.read(audioPlayerProvider.notifier);
      final currentTaskId = _ref.read(currentPlayingTaskProvider);
      
      debugPrint('AudioControls: Toggle play/pause for task $taskId with audio file: $audioFilePath');
      debugPrint('AudioControls: Current playing task: $currentTaskId');
      
      if (currentTaskId == taskId) {
        // Same task - toggle play/pause
        debugPrint('AudioControls: Toggling play/pause for same task');
        await notifier.togglePlayPause();
      } else {
        // Different task - stop current and play new
        debugPrint('AudioControls: Playing new task');
        await playTask(taskId, audioFilePath);
      }
    } catch (e) {
      debugPrint('AudioControls: Error in togglePlayPauseForTask: $e');
    }
  }

  /// Stop any currently playing audio
  Future<void> stopAll() async {
    final notifier = _ref.read(audioPlayerProvider.notifier);
    await notifier.stop();
  }

  /// Check if a specific task is currently playing
  bool isTaskPlaying(String taskId) {
    return _ref.read(isTaskPlayingProvider(taskId));
  }

  /// Get the current playback state
  AudioPlaybackInfo getCurrentState() {
    return _ref.read(audioPlayerProvider);
  }
}

/// Provider for formatted audio duration
final formattedAudioDurationProvider = Provider.family<String, Duration>((ref, duration) {
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
});

/// Provider for formatted audio position
final formattedAudioPositionProvider = Provider.family<String, AudioPlaybackInfo>((ref, info) {
  final minutes = info.position.inMinutes.remainder(60);
  final seconds = info.position.inSeconds.remainder(60);
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
});

/// Provider for audio progress percentage (0.0 to 1.0)
final audioProgressProvider = Provider.family<double, AudioPlaybackInfo>((ref, info) {
  return info.progress;
});