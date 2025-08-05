import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'speech_service.dart';
import 'transcription_service.dart';
import 'transcription_service_impl.dart';

/// Real implementation of SpeechService using speech_to_text package
class SpeechServiceImpl implements SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isAvailable = false;
  List<LocaleName> _availableLocales = [];

  @override
  Future<bool> initialize() async {
    try {
      _isAvailable = await _speechToText.initialize(
        onError: (error) {
          if (kDebugMode) {
            print('Speech recognition error: ${error.errorMsg}');
          }
        },
        onStatus: (status) {
          if (kDebugMode) {
            print('Speech recognition status: $status');
          }
        },
      );
      
      if (_isAvailable) {
        _availableLocales = await _speechToText.locales();
      }
      
      _isInitialized = true;
      return _isAvailable;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize speech recognition: $e');
      }
      _isInitialized = true;
      _isAvailable = false;
      return false;
    }
  }

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isListening => _isListening;

  @override
  bool get isAvailable => _isAvailable;

  @override
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    String? localeId,
    Duration? listenFor,
    Duration? pauseFor,
  }) async {
    if (!_isInitialized || !_isAvailable) {
      onError('Speech recognition not available');
      return;
    }
    
    if (_isListening) {
      onError('Already listening');
      return;
    }
    
    try {
      await _speechToText.listen(
        onResult: (stt.SpeechRecognitionResult result) {
          onResult(result.recognizedWords);
          if (result.finalResult) {
            _isListening = false;
          }
        },
        localeId: localeId,
        listenFor: listenFor ?? const Duration(minutes: 3), // 3 minute limit
        pauseFor: pauseFor ?? const Duration(seconds: 3),
        partialResults: true,
        onSoundLevelChange: null, // Could be used for visual feedback
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
      _isListening = true;
    } catch (e) {
      onError('Failed to start listening: $e');
    }
  }

  @override
  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  @override
  Future<void> cancel() async {
    if (_isListening) {
      await _speechToText.cancel();
      _isListening = false;
    }
  }

  @override
  Future<bool> hasPermission() async {
    try {
      final status = await Permission.microphone.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> getAvailableLocales() async {
    if (!_isInitialized || !_isAvailable) {
      return ['en_US'];
    }
    
    return _availableLocales.map((locale) => locale.localeId).toList();
  }

  @override
  Future<TranscriptionResult> transcribeAudioFile(String audioFilePath) async {
    // Use the transcription service for audio file processing
    final transcriptionService = TranscriptionServiceImpl();
    await transcriptionService.initialize();
    
    try {
      return await transcriptionService.transcribeAudioFile(audioFilePath);
    } finally {
      await transcriptionService.dispose();
    }
  }

  @override
  Future<TranscriptionResult> transcribeAudioData(List<int> audioData) async {
    // Use the transcription service for audio data processing
    final transcriptionService = TranscriptionServiceImpl();
    await transcriptionService.initialize();
    
    try {
      return await transcriptionService.transcribeAudioData(audioData);
    } finally {
      await transcriptionService.dispose();
    }
  }

  @override
  TranscriptionConfig get transcriptionConfig => const TranscriptionConfig();

  @override
  Future<void> updateTranscriptionConfig(TranscriptionConfig config) async {
    // Stub for now
  }

  @override
  Future<void> dispose() async {
    if (_isListening) {
      await cancel();
    }
  }
}