import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

/// Service for handling audio recording functionality
class AudioRecordingService {
  FlutterSoundRecorder? _recorder;
  bool _isInitialized = false;
  bool _isRecording = false;
  String? _currentRecordingPath;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  
  static const Duration maxRecordingDuration = Duration(minutes: 3);

  /// Initialize the audio recording service
  Future<bool> initialize() async {
    try {
      _recorder = FlutterSoundRecorder();
      await _recorder!.openRecorder();
      _isInitialized = true;
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize audio recorder: $e');
      }
      return false;
    }
  }

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Check if currently recording
  bool get isRecording => _isRecording;

  /// Get current recording duration
  Duration get recordingDuration => _recordingDuration;

  /// Get current recording file path
  String? get currentRecordingPath => _currentRecordingPath;

  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    try {
      final status = await Permission.microphone.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      return false;
    }
  }

  /// Request microphone permission
  Future<bool> requestPermission() async {
    try {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      return false;
    }
  }

  /// Start recording audio
  Future<String?> startRecording({
    Function(Duration)? onDurationUpdate,
    VoidCallback? onMaxDurationReached,
  }) async {
    if (!_isInitialized || _recorder == null) {
      throw Exception('Audio recorder not initialized');
    }

    if (_isRecording) {
      throw Exception('Already recording');
    }

    if (!await hasPermission()) {
      final granted = await requestPermission();
      if (!granted) {
        throw Exception('Microphone permission not granted');
      }
    }

    try {
      // Create a unique filename
      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory(path.join(directory.path, 'audio'));
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }
      
      final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.aac';
      _currentRecordingPath = path.join(audioDir.path, fileName);

      // Start recording
      await _recorder!.startRecorder(
        toFile: _currentRecordingPath,
        codec: Codec.aacADTS,
        bitRate: 128000,
        sampleRate: 44100,
      );

      _isRecording = true;
      _recordingDuration = Duration.zero;

      // Start timer to track duration
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration = Duration(seconds: timer.tick);
        onDurationUpdate?.call(_recordingDuration);

        // Stop recording if max duration reached
        if (_recordingDuration >= maxRecordingDuration) {
          stopRecording();
          onMaxDurationReached?.call();
        }
      });

      return _currentRecordingPath;
    } catch (e) {
      _isRecording = false;
      _currentRecordingPath = null;
      if (kDebugMode) {
        print('Failed to start recording: $e');
      }
      rethrow;
    }
  }

  /// Stop recording and return the file path
  Future<String?> stopRecording() async {
    if (!_isRecording || _recorder == null) {
      return null;
    }

    try {
      await _recorder!.stopRecorder();
      _recordingTimer?.cancel();
      _recordingTimer = null;
      _isRecording = false;

      final recordingPath = _currentRecordingPath;
      _currentRecordingPath = null;
      _recordingDuration = Duration.zero;

      return recordingPath;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to stop recording: $e');
      }
      _isRecording = false;
      _currentRecordingPath = null;
      _recordingDuration = Duration.zero;
      return null;
    }
  }

  /// Cancel recording and delete the file
  Future<void> cancelRecording() async {
    final recordingPath = await stopRecording();
    
    if (recordingPath != null) {
      try {
        final file = File(recordingPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to delete cancelled recording: $e');
        }
      }
    }
  }

  /// Get the duration of an audio file
  Future<Duration?> getAudioDuration(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      // For now, return a placeholder - would need additional audio processing
      // to get exact duration without playing the file
      return Duration.zero;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get audio duration: $e');
      }
      return null;
    }
  }

  /// Delete an audio file
  Future<bool> deleteAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete audio file: $e');
      }
      return false;
    }
  }

  /// Get all audio files in the app directory
  Future<List<String>> getAudioFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory(path.join(directory.path, 'audio'));
      
      if (!await audioDir.exists()) {
        return [];
      }

      final files = await audioDir.list().toList();
      return files
          .where((file) => file is File && file.path.endsWith('.aac'))
          .map((file) => file.path)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get audio files: $e');
      }
      return [];
    }
  }

  /// Dispose of the audio recording service
  Future<void> dispose() async {
    if (_isRecording) {
      await cancelRecording();
    }
    
    _recordingTimer?.cancel();
    _recordingTimer = null;
    
    if (_recorder != null) {
      await _recorder!.closeRecorder();
      _recorder = null;
    }
    
    _isInitialized = false;
  }
}