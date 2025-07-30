

/// Abstract interface for speech transcription services
abstract class TranscriptionService {
  /// Initialize the transcription service
  Future<bool> initialize();

  /// Check if the service is available
  bool get isAvailable;

  /// Check if the service has been initialized
  bool get isInitialized;

  /// Transcribe audio file to text
  Future<TranscriptionResult> transcribeAudioFile(String audioFilePath);

  /// Transcribe audio data to text
  Future<TranscriptionResult> transcribeAudioData(List<int> audioData);

  /// Get supported audio formats
  List<String> get supportedFormats;

  /// Dispose of resources
  Future<void> dispose();
}

/// Result of transcription operation
class TranscriptionResult {
  final String text;
  final double confidence;
  final Duration processingTime;
  final String? language;
  final List<TranscriptionSegment>? segments;
  final TranscriptionError? error;
  final bool isSuccess;

  const TranscriptionResult({
    required this.text,
    required this.confidence,
    required this.processingTime,
    this.language,
    this.segments,
    this.error,
    required this.isSuccess,
  });

  factory TranscriptionResult.success({
    required String text,
    required double confidence,
    required Duration processingTime,
    String? language,
    List<TranscriptionSegment>? segments,
  }) {
    return TranscriptionResult(
      text: text,
      confidence: confidence,
      processingTime: processingTime,
      language: language,
      segments: segments,
      isSuccess: true,
    );
  }

  factory TranscriptionResult.failure({
    required TranscriptionError error,
    Duration? processingTime,
  }) {
    return TranscriptionResult(
      text: '',
      confidence: 0.0,
      processingTime: processingTime ?? Duration.zero,
      error: error,
      isSuccess: false,
    );
  }

  @override
  String toString() {
    return 'TranscriptionResult(text: $text, confidence: $confidence, success: $isSuccess)';
  }
}

/// Segment of transcribed text with timing information
class TranscriptionSegment {
  final String text;
  final Duration startTime;
  final Duration endTime;
  final double confidence;

  const TranscriptionSegment({
    required this.text,
    required this.startTime,
    required this.endTime,
    required this.confidence,
  });

  @override
  String toString() {
    return 'TranscriptionSegment(text: $text, start: ${startTime.inMilliseconds}ms, end: ${endTime.inMilliseconds}ms)';
  }
}

/// Error information for transcription failures
class TranscriptionError {
  final String message;
  final TranscriptionErrorType type;
  final dynamic originalError;
  final int? statusCode;

  const TranscriptionError({
    required this.message,
    required this.type,
    this.originalError,
    this.statusCode,
  });

  @override
  String toString() {
    return 'TranscriptionError(type: $type, message: $message)';
  }
}

/// Types of transcription errors
enum TranscriptionErrorType {
  networkError,
  authenticationError,
  fileNotFound,
  unsupportedFormat,
  processingError,
  quotaExceeded,
  serviceUnavailable,
  timeout,
  unknown,
}

/// Exception thrown when transcription fails
class TranscriptionException implements Exception {
  final String message;
  final TranscriptionErrorType type;
  final dynamic originalError;

  const TranscriptionException(
    this.message, {
    required this.type,
    this.originalError,
  });

  @override
  String toString() {
    return 'TranscriptionException: $message (Type: $type)';
  }
}

/// Configuration for transcription services
class TranscriptionConfig {
  final String? language;
  final double? temperature;
  final String? prompt;
  final bool enableTimestamps;
  final int maxRetries;
  final Duration timeout;

  const TranscriptionConfig({
    this.language,
    this.temperature,
    this.prompt,
    this.enableTimestamps = false,
    this.maxRetries = 3,
    this.timeout = const Duration(seconds: 30),
  });
}