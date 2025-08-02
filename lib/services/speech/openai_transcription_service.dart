import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'transcription_service.dart';

/// OpenAI Whisper API transcription service implementation
class OpenAITranscriptionService implements TranscriptionService {
  final String _apiKey;
  final String _baseUrl;
  final TranscriptionConfig _config;
  
  bool _isInitialized = false;
  bool _isAvailable = false;
  
  static const String _defaultBaseUrl = 'https://api.openai.com/v1';
  static const List<String> _supportedFormats = [
    'mp3', 'mp4', 'mpeg', 'mpga', 'm4a', 'wav', 'webm'
  ];

  OpenAITranscriptionService({
    required String apiKey,
    String? baseUrl,
    TranscriptionConfig? config,
  }) : _apiKey = apiKey,
       _baseUrl = baseUrl ?? _defaultBaseUrl,
       _config = config ?? const TranscriptionConfig();  @override
  bool get isAvailable => _isAvailable;  @override
  bool get isInitialized => _isInitialized;  @override
  List<String> get supportedFormats => _supportedFormats;  @override
  Future<bool> initialize() async {
    try {
      // Test API connectivity and authentication
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(_config.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Check if Whisper models are available
        final models = data['data'] as List;
        _isAvailable = models.any((model) => 
          model['id'].toString().contains('whisper'));
        _isInitialized = true;
        return _isAvailable;
      } else {
        _handleHttpError(response);
        return false;
      }
    } catch (e) {
      _isInitialized = false;
      _isAvailable = false;
      throw TranscriptionException(
        'Failed to initialize OpenAI transcription service: ${e.toString()}',
        type: TranscriptionErrorType.serviceUnavailable,
        originalError: e,
      );
    }
  }  @override
  Future<TranscriptionResult> transcribeAudioFile(String audioFilePath) async {
    if (!_isInitialized || !_isAvailable) {
      throw const TranscriptionException(
        'OpenAI transcription service not initialized or available',
        type: TranscriptionErrorType.serviceUnavailable,
      );
    }

    final file = File(audioFilePath);
    if (!await file.exists()) {
      throw const TranscriptionException(
        'Audio file not found',
        type: TranscriptionErrorType.fileNotFound,
      );
    }

    // Check file format
    final extension = audioFilePath.split('.').last.toLowerCase();
    if (!_supportedFormats.contains(extension)) {
      throw TranscriptionException(
        'Unsupported audio format: $extension',
        type: TranscriptionErrorType.unsupportedFormat,
      );
    }

    final audioData = await file.readAsBytes();
    return _transcribeAudioDataWithFileName(audioData, fileName: audioFilePath.split('/').last);
  }  @override
  Future<TranscriptionResult> transcribeAudioData(List<int> audioData) async {
    return _transcribeAudioDataWithFileName(audioData, fileName: 'audio.wav');
  }

  /// Transcribe audio data with optional filename
  Future<TranscriptionResult> _transcribeAudioDataWithFileName(
    List<int> audioData, {
    String fileName = 'audio.wav',
  }) async {
    if (!_isInitialized || !_isAvailable) {
      throw const TranscriptionException(
        'OpenAI transcription service not initialized or available',
        type: TranscriptionErrorType.serviceUnavailable,
      );
    }

    final stopwatch = Stopwatch()..start();
    
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/audio/transcriptions'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $_apiKey',
      });

      // Add audio file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          audioData,
          filename: fileName,
        ),
      );

      // Add parameters
      request.fields['model'] = 'whisper-1';
      request.fields['response_format'] = _config.enableTimestamps ? 'verbose_json' : 'json';
      
      if (_config.language != null) {
        request.fields['language'] = _config.language!;
      }
      
      if (_config.temperature != null) {
        request.fields['temperature'] = _config.temperature.toString();
      }
      
      if (_config.prompt != null) {
        request.fields['prompt'] = _config.prompt!;
      }

      // Send request with retry logic
      http.StreamedResponse? response;
      TranscriptionException? lastException;
      
      for (int attempt = 0; attempt <= _config.maxRetries; attempt++) {
        try {
          response = await request.send().timeout(_config.timeout);
          break;
        } catch (e) {
          lastException = TranscriptionException(
            'Request failed (attempt ${attempt + 1}): ${e.toString()}',
            type: _getErrorTypeFromException(e),
            originalError: e,
          );
          
          if (attempt == _config.maxRetries) {
            throw lastException;
          }
          
          // Wait before retry with exponential backoff
          await Future.delayed(Duration(milliseconds: 1000 * (attempt + 1)));
        }
      }

      if (response == null) {
        throw lastException ?? const TranscriptionException(
          'Failed to get response from OpenAI API',
          type: TranscriptionErrorType.networkError,
        );
      }

      stopwatch.stop();

      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return _parseSuccessResponse(responseBody, stopwatch.elapsed);
      } else {
        return _parseErrorResponse(responseBody, response.statusCode, stopwatch.elapsed);
      }
    } catch (e) {
      stopwatch.stop();
      if (e is TranscriptionException) {
        rethrow;
      }
      
      return TranscriptionResult.failure(
        error: TranscriptionError(
          message: 'Transcription failed: ${e.toString()}',
          type: _getErrorTypeFromException(e),
          originalError: e,
        ),
        processingTime: stopwatch.elapsed,
      );
    }
  }  @override
  Future<void> dispose() async {
    _isInitialized = false;
    _isAvailable = false;
  }

  // Private helper methods

  TranscriptionResult _parseSuccessResponse(String responseBody, Duration processingTime) {
    try {
      final data = json.decode(responseBody);
      
      if (_config.enableTimestamps && data['segments'] != null) {
        final segments = (data['segments'] as List).map((segment) {
          return TranscriptionSegment(
            text: segment['text'] ?? '',
            startTime: Duration(milliseconds: ((segment['start'] ?? 0.0) * 1000).round()),
            endTime: Duration(milliseconds: ((segment['end'] ?? 0.0) * 1000).round()),
            confidence: (segment['avg_logprob'] ?? 0.0).toDouble(),
          );
        }).toList();

        return TranscriptionResult.success(
          text: data['text'] ?? '',
          confidence: _calculateOverallConfidence(segments),
          processingTime: processingTime,
          language: data['language'],
          segments: segments,
        );
      } else {
        return TranscriptionResult.success(
          text: data['text'] ?? '',
          confidence: 0.9, // Default confidence for simple response
          processingTime: processingTime,
          language: data['language'],
        );
      }
    } catch (e) {
      return TranscriptionResult.failure(
        error: TranscriptionError(
          message: 'Failed to parse response: ${e.toString()}',
          type: TranscriptionErrorType.processingError,
          originalError: e,
        ),
        processingTime: processingTime,
      );
    }
  }

  TranscriptionResult _parseErrorResponse(String responseBody, int statusCode, Duration processingTime) {
    try {
      final data = json.decode(responseBody);
      final errorMessage = data['error']?['message'] ?? 'Unknown error';
      final errorType = _getErrorTypeFromStatusCode(statusCode);
      
      return TranscriptionResult.failure(
        error: TranscriptionError(
          message: errorMessage,
          type: errorType,
          statusCode: statusCode,
        ),
        processingTime: processingTime,
      );
    } catch (e) {
      return TranscriptionResult.failure(
        error: TranscriptionError(
          message: 'HTTP $statusCode: Failed to parse error response',
          type: _getErrorTypeFromStatusCode(statusCode),
          statusCode: statusCode,
          originalError: e,
        ),
        processingTime: processingTime,
      );
    }
  }

  double _calculateOverallConfidence(List<TranscriptionSegment> segments) {
    if (segments.isEmpty) return 0.0;
    
    final totalConfidence = segments.fold<double>(
      0.0, 
      (sum, segment) => sum + segment.confidence,
    );
    
    return totalConfidence / segments.length;
  }

  TranscriptionErrorType _getErrorTypeFromStatusCode(int statusCode) {
    switch (statusCode) {
      case 401:
        return TranscriptionErrorType.authenticationError;
      case 429:
        return TranscriptionErrorType.quotaExceeded;
      case 503:
        return TranscriptionErrorType.serviceUnavailable;
      default:
        return TranscriptionErrorType.networkError;
    }
  }

  TranscriptionErrorType _getErrorTypeFromException(dynamic exception) {
    if (exception is SocketException) {
      return TranscriptionErrorType.networkError;
    } else if (exception is HttpException) {
      return TranscriptionErrorType.networkError;
    } else if (exception.toString().contains('timeout')) {
      return TranscriptionErrorType.timeout;
    } else {
      return TranscriptionErrorType.unknown;
    }
  }

  void _handleHttpError(http.Response response) {
    final errorType = _getErrorTypeFromStatusCode(response.statusCode);
    String message = 'HTTP ${response.statusCode}';
    
    try {
      final data = json.decode(response.body);
      message = data['error']?['message'] ?? message;
    } catch (e) {
      // Ignore JSON parsing errors for error responses
    }
    
    throw TranscriptionException(
      message,
      type: errorType,
    );
  }
}
