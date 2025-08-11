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
            print('🎤 Speech recognition initialization error: ${error.errorMsg}');
            print('🎤 Error message: ${error.errorMsg}');
          }
        },
        onStatus: (status) {
          if (kDebugMode) {
            print('🎤 Speech recognition initialization status: $status');
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
    
    // Check microphone permission before starting
    final hasPermission = await this.hasPermission();
    if (!hasPermission) {
      if (kDebugMode) {
        print('🎤 No microphone permission - requesting...');
      }
      final granted = await requestPermission();
      if (!granted) {
        onError('Microphone permission denied');
        return;
      }
      if (kDebugMode) {
        print('🎤 Microphone permission granted');
      }
    }
    
    try {
      if (kDebugMode) {
        print('🎤 Starting speech recognition with 5-minute timeout...');
        print('🎤 Using locale: ${localeId ?? 'default'}');
        print('🎤 Listen duration: ${listenFor ?? const Duration(minutes: 5)}');
        print('🎤 Pause duration: ${pauseFor ?? const Duration(seconds: 5)}');
      }
      
      await _speechToText.listen(
        onResult: (stt.SpeechRecognitionResult result) {
          if (kDebugMode) {
            print('🎤 Speech result: ${result.recognizedWords} (confidence: ${result.confidence}, final: ${result.finalResult})');
          }
          onResult(result.recognizedWords);
          if (result.finalResult) {
            _isListening = false;
            if (kDebugMode) {
              print('🎤 Final result received - stopping listening');
            }
          }
        },
        localeId: localeId,
        listenFor: listenFor ?? const Duration(minutes: 5), // Increase to 5 minutes
        pauseFor: pauseFor ?? const Duration(seconds: 5), // Increase pause timeout
        partialResults: true,
        onSoundLevelChange: null, // Could be used for visual feedback
        cancelOnError: false, // Don't cancel on error - let user handle it
        listenMode: ListenMode.dictation, // Change to dictation mode for longer listening
      );
      _isListening = true;
      if (kDebugMode) {
        print('🎤 Successfully started listening');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🎤 Failed to start listening: $e');
        print('🎤 Error type: ${e.runtimeType}');
      }
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