import 'dart:async';
import '../../domain/repositories/task_repository.dart';
import 'speech_service.dart';
import 'voice_command_models.dart';
import 'voice_command_processor.dart';
import 'voice_command_customization.dart';

/// Main service for handling voice commands in the task tracker app
class VoiceCommandService {
  final SpeechService _speechService;
  // final TaskRepository _taskRepository;
  final VoiceCommandProcessor _processor;
  final VoiceCommandCustomization _customization;
  
  bool _isListening = false;
  bool _isProcessing = false;
  
  // Stream controllers for various events
  final StreamController<VoiceCommandResult> _resultController = 
      StreamController<VoiceCommandResult>.broadcast();
  final StreamController<String> _transcriptionController = 
      StreamController<String>.broadcast();
  final StreamController<VoiceCommandServiceState> _stateController = 
      StreamController<VoiceCommandServiceState>.broadcast();
  final StreamController<String> _errorController = 
      StreamController<String>.broadcast();

  VoiceCommandService({
    required SpeechService speechService,
    required TaskRepository taskRepository,
    VoiceCommandConfig? config,
    VoiceCommandCustomization? customization,
  }) : _speechService = speechService,
       _customization = customization ?? VoiceCommandCustomization(),
       _processor = VoiceCommandProcessor(
         taskRepository: taskRepository,
         config: config ?? const VoiceCommandConfig(),
       );

  /// Stream of command execution results
  Stream<VoiceCommandResult> get results => _resultController.stream;

  /// Stream of speech transcriptions
  Stream<String> get transcriptions => _transcriptionController.stream;

  /// Stream of service state changes
  Stream<VoiceCommandServiceState> get stateChanges => _stateController.stream;

  /// Stream of error messages
  Stream<String> get errors => _errorController.stream;

  /// Current state of the service
  VoiceCommandServiceState get currentState {
    if (_isProcessing) return VoiceCommandServiceState.processing;
    if (_isListening) return VoiceCommandServiceState.listening;
    return VoiceCommandServiceState.idle;
  }

  /// Whether the service is currently listening for voice input
  bool get isListening => _isListening;

  /// Whether the service is currently processing a command
  bool get isProcessing => _isProcessing;

  /// Whether voice commands are available on this device
  bool get isAvailable => _speechService.isAvailable;

  /// Initializes the voice command service
  Future<bool> initialize() async {
    try {
      // Initialize speech service
      final speechInitialized = await _speechService.initialize();
      if (!speechInitialized) {
        _emitError('Speech recognition not available on this device');
        return false;
      }

      // Initialize customization service
      await _customization.initialize();

      _emitState(VoiceCommandServiceState.idle);
      return true;
    } catch (e) {
      _emitError('Failed to initialize voice command service: $e');
      return false;
    }
  }

  /// Starts listening for voice commands
  Future<void> startListening({
    Duration? timeout,
    String? localeId,
  }) async {
    if (_isListening || _isProcessing) {
      return;
    }

    try {
      _isListening = true;
      _emitState(VoiceCommandServiceState.listening);

      await _speechService.startListening(
        onResult: _handleTranscriptionResult,
        onError: _handleTranscriptionError,
        localeId: localeId,
        listenFor: timeout ?? const Duration(seconds: 30),
      );
    } catch (e) {
      _isListening = false;
      _emitState(VoiceCommandServiceState.idle);
      _emitError('Failed to start listening: $e');
    }
  }

  /// Stops listening for voice commands
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speechService.stopListening();
      _isListening = false;
      _emitState(VoiceCommandServiceState.idle);
    } catch (e) {
      _emitError('Failed to stop listening: $e');
    }
  }

  /// Cancels current listening session
  Future<void> cancelListening() async {
    if (!_isListening) return;

    try {
      await _speechService.cancel();
      _isListening = false;
      _emitState(VoiceCommandServiceState.idle);
    } catch (e) {
      _emitError('Failed to cancel listening: $e');
    }
  }

  /// Processes a text command directly (useful for testing or text input)
  Future<VoiceCommandResult> processTextCommand(String text) async {
    if (_isProcessing) {
      throw StateError('Already processing a command');
    }

    try {
      _isProcessing = true;
      _emitState(VoiceCommandServiceState.processing);

      final result = await _processor.processVoiceInput(text);
      _resultController.add(result);

      return result;
    } finally {
      _isProcessing = false;
      _emitState(VoiceCommandServiceState.idle);
    }
  }

  /// Gets the customization service for managing user preferences
  VoiceCommandCustomization get customization => _customization;

  /// Updates the voice command configuration
  Future<void> updateConfiguration(VoiceCommandConfig config) async {
    await _customization.updateConfig(config);
    
    // Update processor with new config
    // Note: In a real implementation, you might need to recreate the processor
    // or provide a method to update its configuration
  }

  /// Gets available locales for speech recognition
  Future<List<String>> getAvailableLocales() async {
    return await _speechService.getAvailableLocales();
  }

  /// Checks if microphone permission is granted
  Future<bool> hasPermission() async {
    return await _speechService.hasPermission();
  }

  /// Requests microphone permission
  Future<bool> requestPermission() async {
    return await _speechService.requestPermission();
  }

  /// Gets command suggestions based on recent failed attempts
  List<String> getCommandSuggestions(String failedTranscription) {
    return _customization.getCommandSuggestions(failedTranscription);
  }

  /// Exports user customizations
  String exportCustomizations() {
    return _customization.exportCustomizations();
  }

  /// Imports user customizations
  Future<void> importCustomizations(String jsonData) async {
    await _customization.importCustomizations(jsonData);
  }

  /// Resets all customizations to defaults
  Future<void> resetCustomizations() async {
    await _customization.resetToDefaults();
  }

  /// Gets usage statistics for voice commands
  Map<String, int> getUsageStatistics() {
    return _customization.getCommandUsageStats();
  }

  /// Disposes of the service and releases resources
  Future<void> dispose() async {
    await stopListening();
    await _speechService.dispose();
    _processor.dispose();
    
    await _resultController.close();
    await _transcriptionController.close();
    await _stateController.close();
    await _errorController.close();
  }

  // Private methods

  void _handleTranscriptionResult(String transcription) {
    _transcriptionController.add(transcription);
    
    // Process the transcription as a voice command
    _processTranscription(transcription);
  }

  void _handleTranscriptionError(String error) {
    _isListening = false;
    _emitState(VoiceCommandServiceState.idle);
    _emitError('Speech recognition error: $error');
  }

  Future<void> _processTranscription(String transcription) async {
    if (transcription.trim().isEmpty) return;

    try {
      _isProcessing = true;
      _isListening = false;
      _emitState(VoiceCommandServiceState.processing);

      final result = await _processor.processVoiceInput(transcription);
      _resultController.add(result);

      // If the command failed, provide suggestions
      if (!result.success) {
        final suggestions = getCommandSuggestions(transcription);
        if (suggestions.isNotEmpty) {
          _emitError('${result.message}\n\nSuggestions:\n${suggestions.join('\n')}');
        } else {
          _emitError(result.message);
        }
      }
    } catch (e) {
      _emitError('Failed to process voice command: $e');
    } finally {
      _isProcessing = false;
      _emitState(VoiceCommandServiceState.idle);
    }
  }

  void _emitState(VoiceCommandServiceState state) {
    _stateController.add(state);
  }

  void _emitError(String error) {
    _errorController.add(error);
  }
}

/// Represents the current state of the voice command service
enum VoiceCommandServiceState {
  /// Service is idle and ready to accept commands
  idle,
  
  /// Service is listening for voice input
  listening,
  
  /// Service is processing a voice command
  processing,
  
  /// Service encountered an error
  error,
}

/// Extension to get display names for service states
extension VoiceCommandServiceStateExtension on VoiceCommandServiceState {
  String get displayName {
    switch (this) {
      case VoiceCommandServiceState.idle:
        return 'Ready';
      case VoiceCommandServiceState.listening:
        return 'Listening...';
      case VoiceCommandServiceState.processing:
        return 'Processing...';
      case VoiceCommandServiceState.error:
        return 'Error';
    }
  }

  /// Returns true if the service is actively working
  bool get isActive {
    return this == VoiceCommandServiceState.listening || 
           this == VoiceCommandServiceState.processing;
  }

  /// Returns true if the service can accept new commands
  bool get canAcceptCommands {
    return this == VoiceCommandServiceState.idle;
  }
}

/// Configuration for voice command service behavior
class VoiceCommandServiceConfig {
  final Duration defaultListenTimeout;
  final bool autoStopOnResult;
  final bool provideSuggestions;
  final bool enableHapticFeedback;
  final double confidenceThreshold;
  final bool enableContinuousListening;
  final Duration continuousListeningPause;

  const VoiceCommandServiceConfig({
    this.defaultListenTimeout = const Duration(seconds: 30),
    this.autoStopOnResult = true,
    this.provideSuggestions = true,
    this.enableHapticFeedback = true,
    this.confidenceThreshold = 0.7,
    this.enableContinuousListening = false,
    this.continuousListeningPause = const Duration(seconds: 2),
  });

  /// Creates a copy of this config with updated fields
  VoiceCommandServiceConfig copyWith({
    Duration? defaultListenTimeout,
    bool? autoStopOnResult,
    bool? provideSuggestions,
    bool? enableHapticFeedback,
    double? confidenceThreshold,
    bool? enableContinuousListening,
    Duration? continuousListeningPause,
  }) {
    return VoiceCommandServiceConfig(
      defaultListenTimeout: defaultListenTimeout ?? this.defaultListenTimeout,
      autoStopOnResult: autoStopOnResult ?? this.autoStopOnResult,
      provideSuggestions: provideSuggestions ?? this.provideSuggestions,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      enableContinuousListening: enableContinuousListening ?? this.enableContinuousListening,
      continuousListeningPause: continuousListeningPause ?? this.continuousListeningPause,
    );
  }
}