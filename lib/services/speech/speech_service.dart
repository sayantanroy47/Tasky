import 'transcription_service.dart';

/// Abstract interface for speech recognition services
abstract class SpeechService {
  /// Initialize the speech service
  Future<bool> initialize();

  /// Check if speech recognition is available on the device
  bool get isAvailable;

  /// Check if currently listening for speech
  bool get isListening;

  /// Check if speech recognition has been initialized
  bool get isInitialized;

  /// Start listening for speech input
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    String? localeId,
    Duration? listenFor,
    Duration? pauseFor,
  });

  /// Stop listening for speech input
  Future<void> stopListening();

  /// Cancel current listening session
  Future<void> cancel();

  /// Get available locales for speech recognition
  Future<List<String>> getAvailableLocales();

  /// Check microphone permission status
  Future<bool> hasPermission();

  /// Request microphone permission
  Future<bool> requestPermission();

  /// Transcribe audio file to text
  Future<TranscriptionResult> transcribeAudioFile(String audioFilePath);

  /// Transcribe audio data to text
  Future<TranscriptionResult> transcribeAudioData(List<int> audioData);

  /// Get transcription service configuration
  TranscriptionConfig get transcriptionConfig;

  /// Update transcription service configuration
  Future<void> updateTranscriptionConfig(TranscriptionConfig config);

  /// Dispose of resources
  Future<void> dispose();
}

/// Enum for speech recognition status
enum SpeechRecognitionStatus {
  notInitialized,
  available,
  listening,
  notListening,
  unavailable,
  error,
}

/// Class to represent speech recognition result
class SpeechRecognitionResult {
  final String recognizedWords;
  final bool finalResult;
  final double confidence;
  final String? alternativeText;

  const SpeechRecognitionResult({
    required this.recognizedWords,
    required this.finalResult,
    required this.confidence,
    this.alternativeText,
  });  @override
  String toString() {
    return 'SpeechRecognitionResult(words: $recognizedWords, final: $finalResult, confidence: $confidence)';
  }
}

/// Exception thrown when speech recognition fails
class SpeechRecognitionException implements Exception {
  final String message;
  final String? errorType;
  final dynamic originalError;

  const SpeechRecognitionException(
    this.message, {
    this.errorType,
    this.originalError,
  });  @override
  String toString() {
    return 'SpeechRecognitionException: $message${errorType != null ? ' (Type: $errorType)' : ''}';
  }
}
