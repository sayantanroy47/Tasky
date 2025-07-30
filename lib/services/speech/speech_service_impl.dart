import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'speech_service.dart';
import 'transcription_service.dart';
import 'composite_transcription_service.dart';
import 'local_transcription_service.dart';
import 'openai_transcription_service.dart';

/// Implementation of SpeechService using speech_to_text package
class SpeechServiceImpl implements SpeechService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  late final CompositeTranscriptionService _transcriptionService;
  
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isAvailable = false;
  
  StreamController<SpeechRecognitionResult>? _resultController;
  StreamController<String>? _errorController;
  
  TranscriptionConfig _transcriptionConfig = const TranscriptionConfig();

  SpeechServiceImpl({
    String? openAIApiKey,
    TranscriptionPreference transcriptionPreference = TranscriptionPreference.localFirst,
    TranscriptionConfig? transcriptionConfig,
  }) {
    _transcriptionConfig = transcriptionConfig ?? const TranscriptionConfig();
    
    // Initialize transcription services
    final localService = LocalTranscriptionService(config: _transcriptionConfig);
    
    OpenAITranscriptionService? cloudService;
    if (openAIApiKey != null && openAIApiKey.isNotEmpty) {
      cloudService = OpenAITranscriptionService(
        apiKey: openAIApiKey,
        config: _transcriptionConfig,
      );
    }
    
    _transcriptionService = CompositeTranscriptionService(
      localService: localService,
      cloudService: cloudService,
      preference: transcriptionPreference,
      config: _transcriptionConfig,
    );
  }
  
  @override
  bool get isAvailable => _isAvailable;
  
  @override
  bool get isListening => _isListening;
  
  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<bool> initialize() async {
    try {
      // Check if already initialized
      if (_isInitialized) {
        return _isAvailable;
      }

      // Request microphone permission first
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        throw const SpeechRecognitionException(
          'Microphone permission denied',
          errorType: 'permission_denied',
        );
      }

      // Initialize speech recognition
      _isAvailable = await _speechToText.initialize(
        onError: _handleError,
        onStatus: _handleStatus,
        debugLogging: false,
      );

      // Initialize transcription service
      await _transcriptionService.initialize();

      _isInitialized = true;
      return _isAvailable;
    } catch (e) {
      _isInitialized = false;
      _isAvailable = false;
      throw SpeechRecognitionException(
        'Failed to initialize speech recognition: ${e.toString()}',
        originalError: e,
      );
    }
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
      throw const SpeechRecognitionException(
        'Speech recognition not initialized or available',
        errorType: 'not_initialized',
      );
    }

    if (_isListening) {
      await stopListening();
    }

    try {
      // Set up result and error handling
      _setupResultHandling(onResult, onError);

      await _speechToText.listen(
        onResult: (result) => _handleResult(result),
        listenFor: listenFor ?? const Duration(seconds: 30),
        pauseFor: pauseFor ?? const Duration(seconds: 3),
        // partialResults: // Use SpeechListenOptions.partialResults instead true,
        localeId: localeId,
        onSoundLevelChange: (level) => _handleSoundLevel(level),
        // cancelOnError: // Use SpeechListenOptions.cancelOnError instead true,
        // listenMode: // Use SpeechListenOptions.listenMode instead stt.ListenMode.confirmation,
      );

      _isListening = true;
    } catch (e) {
      _isListening = false;
      throw SpeechRecognitionException(
        'Failed to start listening: ${e.toString()}',
        originalError: e,
      );
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
  Future<List<String>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final locales = await _speechToText.locales();
      return locales.map((locale) => locale.localeId).toList();
    } catch (e) {
      throw SpeechRecognitionException(
        'Failed to get available locales: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  @override
  Future<TranscriptionResult> transcribeAudioFile(String audioFilePath) async {
    if (!_isInitialized) {
      throw const SpeechRecognitionException(
        'Speech service not initialized',
        errorType: 'not_initialized',
      );
    }

    try {
      return await _transcriptionService.transcribeAudioFile(audioFilePath);
    } catch (e) {
      if (e is TranscriptionException) {
        throw SpeechRecognitionException(
          'Transcription failed: ${e.message}',
          errorType: e.type.toString(),
          originalError: e,
        );
      }
      throw SpeechRecognitionException(
        'Transcription failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<TranscriptionResult> transcribeAudioData(List<int> audioData) async {
    if (!_isInitialized) {
      throw const SpeechRecognitionException(
        'Speech service not initialized',
        errorType: 'not_initialized',
      );
    }

    try {
      return await _transcriptionService.transcribeAudioData(audioData);
    } catch (e) {
      if (e is TranscriptionException) {
        throw SpeechRecognitionException(
          'Transcription failed: ${e.message}',
          errorType: e.type.toString(),
          originalError: e,
        );
      }
      throw SpeechRecognitionException(
        'Transcription failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  TranscriptionConfig get transcriptionConfig => _transcriptionConfig;

  @override
  Future<void> updateTranscriptionConfig(TranscriptionConfig config) async {
    _transcriptionConfig = config;
    
    // Reinitialize transcription service with new config if needed
    if (_isInitialized) {
      await _transcriptionService.dispose();
      
      // Create new transcription service with updated config
      // final localService = LocalTranscriptionService(config: _transcriptionConfig);
      
      // OpenAITranscriptionService? cloudService;
      // Note: We can't change API key at runtime, so we keep the existing cloud service
      // In a real implementation, you might want to store the API key and recreate the service
      
      await _transcriptionService.initialize();
    }
  }

  @override
  Future<void> dispose() async {
    await cancel();
    await _transcriptionService.dispose();
    await _resultController?.close();
    await _errorController?.close();
    _resultController = null;
    _errorController = null;
    _isInitialized = false;
    _isAvailable = false;
  }

  // Private helper methods

  void _setupResultHandling(
    Function(String) onResult,
    Function(String) onError,
  ) {
    _resultController?.close();
    _errorController?.close();

    _resultController = StreamController<SpeechRecognitionResult>.broadcast();
    _errorController = StreamController<String>.broadcast();

    _resultController!.stream.listen((result) {
      onResult(result.recognizedWords);
    });

    _errorController!.stream.listen((error) {
      onError(error);
    });
  }

  void _handleResult(result) {
    final speechResult = SpeechRecognitionResult(
      recognizedWords: result.recognizedWords,
      finalResult: result.finalResult,
      confidence: result.confidence,
      alternativeText: result.alternates.isNotEmpty 
          ? result.alternates.first.recognizedWords 
          : null,
    );

    _resultController?.add(speechResult);
  }

  void _handleError(error) {
    _isListening = false;
    final errorMessage = 'Speech recognition error: ${error.errorMsg}';
    _errorController?.add(errorMessage);
  }

  void _handleStatus(String status) {
    switch (status) {
      case 'listening':
        _isListening = true;
        break;
      case 'notListening':
        _isListening = false;
        break;
      case 'done':
        _isListening = false;
        break;
    }
  }

  void _handleSoundLevel(double level) {
    // Sound level can be used for visual feedback
    // This could be exposed through a stream if needed
  }
}