import 'dart:async';
import 'package:flutter/foundation.dart';
import 'speech_service.dart';

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

  @override
  Stream<SpeechRecognitionResult> get onResult {
    _resultController ??= StreamController<SpeechRecognitionResult>.broadcast();
    return _resultController!.stream;
  }

  @override
  Stream<String> get onError {
    _errorController ??= StreamController<String>.broadcast();
    return _errorController!.stream;
  }

  @override
  Future<bool> startListening({
    String? localeId,
    Duration? listenFor,
    Duration? pauseFor,
    bool partialResults = true,
    bool onDevice = false,
    bool cancelOnError = false,
    bool listenMode = false,
  }) async {
    if (!_isInitialized || !_isAvailable) {
      _errorController?.add('Speech recognition not available');
      return false;
    }
    
    _isListening = true;
    return true;
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
  Future<List<String>> getLocales() async {
    return ['en_US']; // Return default locale
  }

  @override
  Future<String?> getSystemLocale() async {
    return 'en_US';
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
  void dispose() {
    _resultController?.close();
    _errorController?.close();
    _resultController = null;
    _errorController = null;
  }
}
