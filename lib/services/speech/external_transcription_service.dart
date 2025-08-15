import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'transcription_service.dart';
import '../../services/security/api_key_manager.dart';

/// External API-based transcription service
/// 
/// This service integrates with external APIs like OpenAI Whisper
/// for high-quality audio transcription when API keys are available.
class ExternalTranscriptionService implements TranscriptionService {
  static const Duration _defaultTimeout = Duration(seconds: 30);
  late http.Client _httpClient;
  TranscriptionConfig _config = const TranscriptionConfig();
  bool _isInitialized = false;

  @override
  Future<bool> initialize() async {
    _httpClient = http.Client();
    _isInitialized = true;
    return true;
  }

  @override
  bool get isAvailable => _isInitialized;

  @override
  bool get isInitialized => _isInitialized;

  TranscriptionConfig get transcriptionConfig => _config;

  Future<void> updateTranscriptionConfig(TranscriptionConfig config) async {
    _config = config;
  }

  @override
  Future<TranscriptionResult> transcribeAudioFile(String audioFilePath) async {
    if (!_isInitialized) {
      return TranscriptionResult.failure(
        error: const TranscriptionError(
          message: 'Service not initialized',
          type: TranscriptionErrorType.serviceUnavailable,
        ),
      );
    }

    try {
      // Read the audio file
      final file = File(audioFilePath);
      if (!await file.exists()) {
        return TranscriptionResult.failure(
          error: const TranscriptionError(
            message: 'Audio file not found',
            type: TranscriptionErrorType.fileNotFound,
          ),
        );
      }

      final audioData = await file.readAsBytes();
      final fileName = path.basename(audioFilePath);
      
      return await _transcribeWithAPI(audioData, fileName);
    } catch (e) {
      return TranscriptionResult.failure(
        error: TranscriptionError(
          message: 'Failed to read audio file: ${e.toString()}',
          type: TranscriptionErrorType.processingError,
          originalError: e,
        ),
      );
    }
  }

  @override
  Future<TranscriptionResult> transcribeAudioData(List<int> audioData) async {
    if (!_isInitialized) {
      return TranscriptionResult.failure(
        error: const TranscriptionError(
          message: 'Service not initialized',
          type: TranscriptionErrorType.serviceUnavailable,
        ),
      );
    }

    return await _transcribeWithAPI(audioData, 'audio.wav');
  }

  /// Transcribe audio using external API (OpenAI Whisper)
  Future<TranscriptionResult> _transcribeWithAPI(List<int> audioData, String fileName) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Check if OpenAI API key is available
      final apiKey = await APIKeyManager.getOpenAIApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        return TranscriptionResult.failure(
          error: const TranscriptionError(
            message: 'OpenAI API key not configured. Please set up your API key in settings.',
            type: TranscriptionErrorType.authenticationError,
          ),
        );
      }

      // Get base URL (use custom if configured, otherwise default)
      final baseUrl = await APIKeyManager.getOpenAIBaseUrl() ?? 'https://api.openai.com/v1';

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/audio/transcriptions'),
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $apiKey',
        'User-Agent': 'TaskTracker/1.0',
      });

      // Add audio file
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        audioData,
        filename: fileName,
      ));

      // Add parameters
      request.fields.addAll({
        'model': 'whisper-1',
        'language': _config.language ?? 'en',
        'response_format': 'verbose_json',
        'timestamp_granularities[]': 'segment',
      });

      // Send request with timeout
      final streamedResponse = await request.send().timeout(_defaultTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      stopwatch.stop();

      if (response.statusCode == 200) {
        return _parseOpenAIResponse(response.body, stopwatch.elapsed);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown API error';
        
        return TranscriptionResult.failure(
          error: TranscriptionError(
            message: 'API Error: $errorMessage',
            type: _mapHttpStatusToErrorType(response.statusCode),
            originalError: errorData,
          ),
        );
      }
    } catch (e) {
      stopwatch.stop();
      
      if (e.toString().contains('TimeoutException')) {
        return TranscriptionResult.failure(
          error: const TranscriptionError(
            message: 'Transcription request timed out. Please try again.',
            type: TranscriptionErrorType.timeout,
          ),
        );
      }
      
      return TranscriptionResult.failure(
        error: TranscriptionError(
          message: 'Network error: ${e.toString()}',
          type: TranscriptionErrorType.networkError,
          originalError: e,
        ),
      );
    }
  }

  /// Parse OpenAI API response
  TranscriptionResult _parseOpenAIResponse(String responseBody, Duration processingTime) {
    try {
      final data = jsonDecode(responseBody);
      
      final text = data['text'] as String? ?? '';
      final language = data['language'] as String? ?? _config.language;
      
      // Parse segments if available
      final segments = <TranscriptionSegment>[];
      if (data['segments'] != null) {
        for (final segment in data['segments']) {
          segments.add(TranscriptionSegment(
            text: segment['text'] ?? '',
            startTime: Duration(milliseconds: ((segment['start'] ?? 0.0) * 1000).round()),
            endTime: Duration(milliseconds: ((segment['end'] ?? 0.0) * 1000).round()),
            confidence: segment['confidence'] ?? 1.0,
          ));
        }
      }

      return TranscriptionResult.success(
        text: text,
        confidence: 1.0, // OpenAI doesn't provide overall confidence
        processingTime: processingTime,
        language: language,
        segments: segments,
      );
    } catch (e) {
      return TranscriptionResult.failure(
        error: TranscriptionError(
          message: 'Failed to parse API response: ${e.toString()}',
          type: TranscriptionErrorType.processingError,
          originalError: e,
        ),
      );
    }
  }

  /// Map HTTP status codes to error types
  TranscriptionErrorType _mapHttpStatusToErrorType(int statusCode) {
    switch (statusCode) {
      case 400:
        return TranscriptionErrorType.processingError;
      case 401:
        return TranscriptionErrorType.authenticationError;
      case 403:
        return TranscriptionErrorType.authenticationError;
      case 429:
        return TranscriptionErrorType.quotaExceeded;
      case 500:
      case 502:
      case 503:
      case 504:
        return TranscriptionErrorType.serviceUnavailable;
      default:
        return TranscriptionErrorType.processingError;
    }
  }

  @override
  List<String> get supportedFormats => [
    'mp3', 'mp4', 'mpeg', 'mpga', 'm4a', 'wav', 'webm',
    'flac', 'ogg', 'opus' // Additional formats supported by Whisper
  ];

  /// Test API connectivity and authentication
  Future<bool> testConnection() async {
    try {
      final apiKey = await APIKeyManager.getOpenAIApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        return false;
      }

      final baseUrl = await APIKeyManager.getOpenAIBaseUrl() ?? 'https://api.openai.com/v1';
      
      // Test with a minimal API call
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'User-Agent': 'TaskTracker/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    _httpClient.close();
    _isInitialized = false;
  }
}

