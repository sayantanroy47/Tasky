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
    if (!_isInitialized) {
      onError('Speech recognition not initialized');
      return;
    }
    
    _isListening = true;
    
    // In debug mode, provide mock speech recognition after a delay
    if (_isListening) {
      Future.delayed(const Duration(seconds: 2), () {
        if (_isListening) {
          // Emit mock result for testing
          final mockResults = [
            'Add task buy groceries',
            'Create urgent task finish presentation',
            'New task call mom this evening',
            'Schedule meeting with John tomorrow',
            'Task reminder pay electricity bill',
          ];
          
          final result = mockResults[DateTime.now().millisecond % mockResults.length];
          onResult(result);
          
          // Emit to stream as well
          if (_resultController != null) {
            _resultController!.add(SpeechRecognitionResult(
              recognizedWords: result,
              confidence: 0.85,
              finalResult: true,
            ));
          }
        }
      });
    }
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
    // Return mock transcription result for development/testing
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate processing time
    
    return TranscriptionResult.success(
      text: 'Add new task buy groceries and finish project',
      confidence: 0.9,
      processingTime: const Duration(milliseconds: 300),
      language: 'en-US',
      segments: [
        const TranscriptionSegment(
          text: 'Add new task buy groceries and finish project',
          startTime: Duration.zero,
          endTime: Duration(seconds: 3),
          confidence: 0.9,
        ),
      ],
    );
  }

  @override
  Future<TranscriptionResult> transcribeAudioData(List<int> audioData) async {
    // Return mock transcription result for development/testing
    await Future.delayed(const Duration(milliseconds: 400)); // Simulate processing time
    
    // Generate different mock responses based on audio data size for variety
    final mockTexts = [
      'Create task call dentist tomorrow',
      'Add urgent task complete presentation',
      'New task buy milk and bread',
      'Schedule meeting with team next week',
      'Task reminder submit report by Friday',
    ];
    
    final selectedText = mockTexts[audioData.length % mockTexts.length];
    
    return TranscriptionResult.success(
      text: selectedText,
      confidence: 0.87,
      processingTime: const Duration(milliseconds: 400),
      language: 'en-US',
      segments: [
        TranscriptionSegment(
          text: selectedText,
          startTime: Duration.zero,
          endTime: Duration(seconds: selectedText.length ~/ 5), // Approximate duration
          confidence: 0.87,
        ),
      ],
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
