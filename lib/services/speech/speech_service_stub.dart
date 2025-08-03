import 'dart:async';
import 'speech_service.dart';
import 'transcription_service.dart';

/// Stub implementation of SpeechService when speech_to_text is not available
class SpeechServiceStub implements SpeechService {
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isAvailable = false;
  
  StreamController<SpeechRecognitionResult>? _resultController;
  StreamController<String>? _errorController;
  @override
  Future<bool> initialize() async {
    _isInitialized = true;
    _isAvailable = false; // Always false for stub
    return _isAvailable;
  }
  @override
  bool get isInitialized => _isInitialized;
  @override
  bool get isListening => _isListening;
  @override
  bool get isAvailable => _isAvailable;
  Stream<SpeechRecognitionResult> get onResult {
    _resultController ??= StreamController<SpeechRecognitionResult>.broadcast();
    return _resultController!.stream;
  }
  Stream<String> get onError {
    _errorController ??= StreamController<String>.broadcast();
    return _errorController!.stream;
  }
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
    
    _isListening = true;
  }
  @override
  Future<void> stopListening() async {
    _isListening = false;
  }
  @override
  Future<void> cancel() async {
    _isListening = false;
  }
  @override
  Future<List<String>> getAvailableLocales() async {
    return ['en_US']; // Return default locale
  }

  @override
  Future<TranscriptionResult> transcribeAudioFile(String audioFilePath) async {
    return const TranscriptionResult(
      text: '',
      confidence: 0.0,
      processingTime: Duration.zero,
      isSuccess: false,
    );
  }

  @override
  Future<TranscriptionResult> transcribeAudioData(List<int> audioData) async {
    return const TranscriptionResult(
      text: '',
      confidence: 0.0,
      processingTime: Duration.zero,
      isSuccess: false,
    );
  }

  @override
  TranscriptionConfig get transcriptionConfig => const TranscriptionConfig();

  @override
  Future<void> updateTranscriptionConfig(TranscriptionConfig config) async {
    // No-op for stub
  }
  @override
  Future<bool> hasPermission() async {
    return false; // Always false for stub
  }
  @override
  Future<bool> requestPermission() async {
    return false; // Always false for stub
  }
  @override
  Future<void> dispose() async {
    _resultController?.close();
    _errorController?.close();
    _resultController = null;
    _errorController = null;
  }
}
