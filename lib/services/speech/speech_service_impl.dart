import 'dart:async';
import 'package:flutter/foundation.dart';
import 'speech_service.dart';
import 'transcription_service.dart';

/// Stub implementation of SpeechService when speech_to_text is not available
class SpeechServiceImpl implements SpeechService {
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isAvailable = false;

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
  Future<bool> hasPermission() async {
    return false; // Always false for stub
  }

  @override
  Future<bool> requestPermission() async {
    return false; // Always false for stub
  }

  @override
  Future<void> dispose() async {
    // No-op for stub
  }

  @override
  noSuchMethod(Invocation invocation) {
    if (kDebugMode) {
      print('Stub: SpeechService method ${invocation.memberName} called');
    }
    
    // Return appropriate default values based on return type
    final returnType = invocation.memberName.toString();
    if (returnType.contains('Future<bool>')) {
      return Future.value(false);
    } else if (returnType.contains('Future<List<String>>')) {
      return Future.value(['en_US']);
    } else if (returnType.contains('Future<TranscriptionResult>')) {
      return Future.value(TranscriptionResult(
        text: '',
        confidence: 0.0,
        processingTime: Duration.zero,
        isSuccess: false,
      ));
    } else if (returnType.contains('TranscriptionConfig')) {
      return TranscriptionConfig();
    } else if (returnType.contains('Future<void>')) {
      return Future.value();
    }
    
    return super.noSuchMethod(invocation);
  }
}