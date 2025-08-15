import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/speech/speech_service.dart';
import '../../services/speech/speech_service_impl.dart';
import '../../core/providers/error_state_manager.dart';

// Provider for the speech service
final speechServiceProvider = Provider<SpeechService>((ref) {
  return SpeechServiceImpl();
});

// State class for speech recognition
class SpeechRecognitionState {
  final SpeechRecognitionStatus status;
  final String? transcriptionText;
  final String? errorMessage;
  final double soundLevel;
  final bool hasPermission;
  final List<String> availableLocales;
  final String? selectedLocale;

  const SpeechRecognitionState({
    this.status = SpeechRecognitionStatus.notInitialized,
    this.transcriptionText,
    this.errorMessage,
    this.soundLevel = 0.0,
    this.hasPermission = false,
    this.availableLocales = const [],
    this.selectedLocale,
  });

  SpeechRecognitionState copyWith({
    SpeechRecognitionStatus? status,
    String? transcriptionText,
    String? errorMessage,
    double? soundLevel,
    bool? hasPermission,
    List<String>? availableLocales,
    String? selectedLocale,
  }) {
    return SpeechRecognitionState(
      status: status ?? this.status,
      transcriptionText: transcriptionText ?? this.transcriptionText,
      errorMessage: errorMessage,
      soundLevel: soundLevel ?? this.soundLevel,
      hasPermission: hasPermission ?? this.hasPermission,
      availableLocales: availableLocales ?? this.availableLocales,
      selectedLocale: selectedLocale ?? this.selectedLocale,
    );
  }

  bool get isRecording => status == SpeechRecognitionStatus.listening;
  bool get isProcessing => status == SpeechRecognitionStatus.notInitialized;
  bool get isAvailable => status == SpeechRecognitionStatus.available || 
                         status == SpeechRecognitionStatus.notListening;
  bool get hasError => status == SpeechRecognitionStatus.error;
}

// Notifier for managing speech recognition state
class SpeechRecognitionNotifier extends StateNotifier<SpeechRecognitionState> {
  final SpeechService _speechService;
  final Ref _ref;
  Timer? _soundLevelTimer;

  SpeechRecognitionNotifier(this._speechService, this._ref) : super(const SpeechRecognitionState());

  /// Get access to the underlying speech service for advanced operations
  SpeechService? get speechService => _speechService;

  /// Initialize speech recognition service
  Future<void> initialize() async {
    try {
      state = state.copyWith(status: SpeechRecognitionStatus.notInitialized);

      // Check and request permissions
      final hasPermission = await _speechService.hasPermission();
      if (!hasPermission) {
        final granted = await _speechService.requestPermission();
        if (!granted) {
          state = state.copyWith(
            status: SpeechRecognitionStatus.error,
            errorMessage: 'Microphone permission is required for voice input',
            hasPermission: false,
          );
          return;
        }
      }

      // Initialize the service
      final isAvailable = await _speechService.initialize();
      if (!isAvailable) {
        state = state.copyWith(
          status: SpeechRecognitionStatus.unavailable,
          errorMessage: 'Speech recognition is not available on this device',
          hasPermission: true,
        );
        return;
      }

      // Get available locales
      final locales = await _speechService.getAvailableLocales();
      
      state = state.copyWith(
        status: SpeechRecognitionStatus.available,
        hasPermission: true,
        availableLocales: locales,
        selectedLocale: locales.isNotEmpty ? locales.first : null,
        errorMessage: null,
      );
    } catch (e, stackTrace) {
      final errorMessage = e.toString();
      state = state.copyWith(
        status: SpeechRecognitionStatus.error,
        errorMessage: errorMessage,
      );
      
      // Report to global error state
      _ref.reportError(
        e,
        code: 'speech_initialization_failed',
        severity: ErrorSeverity.error,
        context: {'operation': 'initialize'},
        stackTrace: stackTrace,
      );
    }
  }

  /// Start listening for speech input
  Future<void> startListening({
    String? localeId,
    Duration? listenFor,
    Duration? pauseFor,
  }) async {
    if (!state.isAvailable) {
      await initialize();
      if (!state.isAvailable) {
        return;
      }
    }

    try {
      state = state.copyWith(
        status: SpeechRecognitionStatus.listening,
        transcriptionText: null,
        errorMessage: null,
      );

      await _speechService.startListening(
        onResult: _handleTranscriptionResult,
        onError: _handleError,
        localeId: localeId ?? state.selectedLocale,
        listenFor: listenFor,
        pauseFor: pauseFor,
      );

      // Start sound level monitoring (simulated)
      _startSoundLevelMonitoring();
    } catch (e, stackTrace) {
      final errorMessage = e.toString();
      state = state.copyWith(
        status: SpeechRecognitionStatus.error,
        errorMessage: errorMessage,
      );
      
      // Report to global error state
      _ref.reportError(
        e,
        code: 'speech_listening_failed',
        severity: ErrorSeverity.error,
        context: {'operation': 'startListening'},
        stackTrace: stackTrace,
      );
    }
  }

  /// Stop listening for speech input
  Future<void> stopListening() async {
    try {
      await _speechService.stopListening();
      _stopSoundLevelMonitoring();
      
      state = state.copyWith(
        status: SpeechRecognitionStatus.notListening,
        soundLevel: 0.0,
      );
    } catch (e) {
      state = state.copyWith(
        status: SpeechRecognitionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Cancel current listening session
  Future<void> cancelListening() async {
    try {
      await _speechService.cancel();
      _stopSoundLevelMonitoring();
      
      state = state.copyWith(
        status: SpeechRecognitionStatus.notListening,
        transcriptionText: null,
        soundLevel: 0.0,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: SpeechRecognitionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Set the selected locale for speech recognition
  void setSelectedLocale(String localeId) {
    if (state.availableLocales.contains(localeId)) {
      state = state.copyWith(selectedLocale: localeId);
    }
  }

  /// Clear any error messages
  void clearError() {
    state = state.copyWith(
      errorMessage: null,
      status: state.hasError ? SpeechRecognitionStatus.notListening : state.status,
    );
  }

  /// Clear transcription text
  void clearTranscription() {
    state = state.copyWith(transcriptionText: '');
  }

  // Private helper methods

  void _handleTranscriptionResult(String result) {
    state = state.copyWith(
      transcriptionText: result,
      errorMessage: null,
    );
  }

  void _handleError(String error) {
    _stopSoundLevelMonitoring();
    state = state.copyWith(
      status: SpeechRecognitionStatus.error,
      errorMessage: error,
      soundLevel: 0.0,
    );
  }

  void _startSoundLevelMonitoring() {
    _soundLevelTimer?.cancel();
    _soundLevelTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        // Simulate sound level changes for visual feedback
        // In a real implementation, this would come from the speech service
        if (state.isRecording) {
          final newLevel = (DateTime.now().millisecondsSinceEpoch % 1000) / 1000.0;
          state = state.copyWith(soundLevel: newLevel);
        }
      },
    );
  }

  void _stopSoundLevelMonitoring() {
    _soundLevelTimer?.cancel();
    _soundLevelTimer = null;
  }
  @override
  void dispose() {
    _stopSoundLevelMonitoring();
    _speechService.dispose();
    super.dispose();
  }
}

// Provider for speech recognition state
final speechRecognitionProvider = StateNotifierProvider.autoDispose<SpeechRecognitionNotifier, SpeechRecognitionState>((ref) {
  final speechService = ref.read(speechServiceProvider);
  final notifier = SpeechRecognitionNotifier(speechService, ref);
  
  // Ensure proper disposal of resources
  ref.onDispose(() {
    notifier.dispose();
  });
  
  return notifier;
});

// Computed providers for specific state aspects
final isRecordingProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(speechRecognitionProvider).isRecording;
});

final transcriptionTextProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(speechRecognitionProvider).transcriptionText;
});

final speechErrorProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(speechRecognitionProvider).errorMessage;
});

final speechAvailableLocalesProvider = Provider.autoDispose<List<String>>((ref) {
  return ref.watch(speechRecognitionProvider).availableLocales;
});

final selectedSpeechLocaleProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(speechRecognitionProvider).selectedLocale;
});
