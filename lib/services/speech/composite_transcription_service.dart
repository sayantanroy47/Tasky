import 'dart:io';
import 'package:flutter/foundation.dart';
import 'transcription_service.dart';
import 'local_transcription_service.dart';
import 'openai_transcription_service.dart';

/// Composite transcription service that manages local and cloud transcription
/// with intelligent fallback and error handling
class CompositeTranscriptionService implements TranscriptionService {
  final LocalTranscriptionService _localService;
  final OpenAITranscriptionService? _cloudService;
  final TranscriptionPreference _preference;
  final TranscriptionConfig _config;
  
  bool _isInitialized = false;
  bool _isAvailable = false;
  
  CompositeTranscriptionService({
    required LocalTranscriptionService localService,
    OpenAITranscriptionService? cloudService,
    TranscriptionPreference preference = TranscriptionPreference.localFirst,
    TranscriptionConfig? config,
  }) : _localService = localService,
       _cloudService = cloudService,
       _preference = preference,
       _config = config ?? const TranscriptionConfig();

  @override
  bool get isAvailable => _isAvailable;

  @override
  bool get isInitialized => _isInitialized;

  @override
  List<String> get supportedFormats {
    final localFormats = _localService.supportedFormats;
    final cloudFormats = _cloudService?.supportedFormats ?? <String>[];
    
    // Return union of supported formats
    return {...localFormats, ...cloudFormats}.toList();
  }

  @override
  Future<bool> initialize() async {
    try {
      bool localAvailable = false;
      bool cloudAvailable = false;
      
      // Initialize local service
      try {
        localAvailable = await _localService.initialize();
      } catch (e) {
        // Local service initialization failed, continue with cloud only
        debugPrint('Local transcription service initialization failed: $e');
      }
      
      // Initialize cloud service if available
      if (_cloudService != null) {
        try {
          cloudAvailable = await _cloudService.initialize();
        } catch (e) {
          // Cloud service initialization failed, continue with local only
          debugPrint('Cloud transcription service initialization failed: $e');
        }
      }
      
      _isAvailable = localAvailable || cloudAvailable;
      _isInitialized = true;
      
      return _isAvailable;
    } catch (e) {
      _isInitialized = false;
      _isAvailable = false;
      throw TranscriptionException(
        'Failed to initialize transcription services: ${e.toString()}',
        type: TranscriptionErrorType.serviceUnavailable,
        originalError: e,
      );
    }
  }

  @override
  Future<TranscriptionResult> transcribeAudioFile(String audioFilePath) async {
    if (!_isInitialized || !_isAvailable) {
      throw const TranscriptionException(
        'Transcription service not initialized or available',
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

    return _transcribeWithFallback(() async {
      final audioData = await file.readAsBytes();
      return transcribeAudioData(audioData);
    });
  }

  @override
  Future<TranscriptionResult> transcribeAudioData(List<int> audioData) async {
    if (!_isInitialized || !_isAvailable) {
      throw const TranscriptionException(
        'Transcription service not initialized or available',
        type: TranscriptionErrorType.serviceUnavailable,
      );
    }

    return _transcribeWithFallback(() async {
      return _transcribeAudioDataInternal(audioData);
    });
  }

  @override
  Future<void> dispose() async {
    await _localService.dispose();
    await _cloudService?.dispose();
    _isInitialized = false;
    _isAvailable = false;
  }

  // Private helper methods

  Future<TranscriptionResult> _transcribeWithFallback(
    Future<TranscriptionResult> Function() transcribeFunction,
  ) async {
    TranscriptionResult? lastResult;
    
    for (int attempt = 0; attempt <= _config.maxRetries; attempt++) {
      try {
        final result = await transcribeFunction();
        
        if (result.isSuccess) {
          return result;
        } else {
          lastResult = result;
          
          // If this was the last attempt, return the failed result
          if (attempt == _config.maxRetries) {
            return result;
          }
          
          // Wait before retry
          await Future.delayed(Duration(milliseconds: 1000 * (attempt + 1)));
        }
      } catch (e) {
        if (attempt == _config.maxRetries) {
          return TranscriptionResult.failure(
            error: TranscriptionError(
              message: 'All transcription attempts failed: ${e.toString()}',
              type: TranscriptionErrorType.processingError,
              originalError: e,
            ),
          );
        }
        
        // Wait before retry
        await Future.delayed(Duration(milliseconds: 1000 * (attempt + 1)));
      }
    }
    
    return lastResult ?? TranscriptionResult.failure(
      error: const TranscriptionError(
        message: 'Transcription failed after all retries',
        type: TranscriptionErrorType.processingError,
      ),
    );
  }

  Future<TranscriptionResult> _transcribeAudioDataInternal(List<int> audioData) async {
    switch (_preference) {
      case TranscriptionPreference.localOnly:
        return _transcribeLocal(audioData);
        
      case TranscriptionPreference.cloudOnly:
        return _transcribeCloud(audioData);
        
      case TranscriptionPreference.localFirst:
        return _transcribeLocalFirst(audioData);
        
      case TranscriptionPreference.cloudFirst:
        return _transcribeCloudFirst(audioData);
        
      case TranscriptionPreference.fastest:
        return _transcribeFastest(audioData);
        
      case TranscriptionPreference.mostAccurate:
        return _transcribeMostAccurate(audioData);
    }
  }

  Future<TranscriptionResult> _transcribeLocal(List<int> audioData) async {
    if (!_localService.isAvailable) {
      throw const TranscriptionException(
        'Local transcription service not available',
        type: TranscriptionErrorType.serviceUnavailable,
      );
    }
    
    return _localService.transcribeAudioData(audioData);
  }

  Future<TranscriptionResult> _transcribeCloud(List<int> audioData) async {
    if (_cloudService == null || !_cloudService.isAvailable) {
      throw const TranscriptionException(
        'Cloud transcription service not available',
        type: TranscriptionErrorType.serviceUnavailable,
      );
    }
    
    return _cloudService.transcribeAudioData(audioData);
  }

  Future<TranscriptionResult> _transcribeLocalFirst(List<int> audioData) async {
    // Try local first
    if (_localService.isAvailable) {
      try {
        final result = await _localService.transcribeAudioData(audioData);
        if (result.isSuccess && _isResultAcceptable(result)) {
          return result;
        }
      } catch (e) {
        // Local failed, continue to cloud fallback
        debugPrint('Local transcription failed, falling back to cloud: $e');
      }
    }
    
    // Fallback to cloud
    if (_cloudService != null && _cloudService.isAvailable) {
      return _cloudService.transcribeAudioData(audioData);
    }
    
    throw const TranscriptionException(
      'No transcription service available',
      type: TranscriptionErrorType.serviceUnavailable,
    );
  }

  Future<TranscriptionResult> _transcribeCloudFirst(List<int> audioData) async {
    // Try cloud first
    if (_cloudService != null && _cloudService.isAvailable) {
      try {
        final result = await _cloudService.transcribeAudioData(audioData);
        if (result.isSuccess && _isResultAcceptable(result)) {
          return result;
        }
      } catch (e) {
        // Cloud failed, continue to local fallback
        debugPrint('Cloud transcription failed, falling back to local: $e');
      }
    }
    
    // Fallback to local
    if (_localService.isAvailable) {
      return _localService.transcribeAudioData(audioData);
    }
    
    throw const TranscriptionException(
      'No transcription service available',
      type: TranscriptionErrorType.serviceUnavailable,
    );
  }

  Future<TranscriptionResult> _transcribeFastest(List<int> audioData) async {
    final futures = <Future<TranscriptionResult>>[];
    
    if (_localService.isAvailable) {
      futures.add(_localService.transcribeAudioData(audioData));
    }
    
    if (_cloudService != null && _cloudService.isAvailable) {
      futures.add(_cloudService.transcribeAudioData(audioData));
    }
    
    if (futures.isEmpty) {
      throw const TranscriptionException(
        'No transcription service available',
        type: TranscriptionErrorType.serviceUnavailable,
      );
    }
    
    // Return the first successful result
    final results = await Future.wait(futures, eagerError: false);
    
    for (final result in results) {
      if (result.isSuccess && _isResultAcceptable(result)) {
        return result;
      }
    }
    
    // If no successful results, return the best available result
    return results.firstWhere(
      (result) => result.isSuccess,
      orElse: () => results.first,
    );
  }

  Future<TranscriptionResult> _transcribeMostAccurate(List<int> audioData) async {
    final results = <TranscriptionResult>[];
    
    // Try both services if available
    if (_localService.isAvailable) {
      try {
        final result = await _localService.transcribeAudioData(audioData);
        results.add(result);
      } catch (e) {
        // Continue with other services
      }
    }
    
    if (_cloudService != null && _cloudService.isAvailable) {
      try {
        final result = await _cloudService.transcribeAudioData(audioData);
        results.add(result);
      } catch (e) {
        // Continue with other services
      }
    }
    
    if (results.isEmpty) {
      throw const TranscriptionException(
        'No transcription service available',
        type: TranscriptionErrorType.serviceUnavailable,
      );
    }
    
    // Return the result with highest confidence
    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    return results.first;
  }

  bool _isResultAcceptable(TranscriptionResult result) {
    // Define minimum acceptable confidence threshold
    const minConfidence = 0.6;
    
    return result.isSuccess && 
           result.confidence >= minConfidence &&
           result.text.trim().isNotEmpty;
  }
}

/// Preference for transcription service selection
enum TranscriptionPreference {
  /// Use only local transcription
  localOnly,
  
  /// Use only cloud transcription
  cloudOnly,
  
  /// Try local first, fallback to cloud
  localFirst,
  
  /// Try cloud first, fallback to local
  cloudFirst,
  
  /// Use whichever service responds fastest
  fastest,
  
  /// Use whichever service provides most accurate results
  mostAccurate,
}
