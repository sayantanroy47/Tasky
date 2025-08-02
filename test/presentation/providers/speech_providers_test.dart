import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/services/speech/speech_service.dart';
import 'package:task_tracker_app/presentation/providers/speech_providers.dart';

// Generate mocks
@GenerateMocks([SpeechService])
import 'speech_providers_test.mocks.dart';

void main() {
  group('SpeechRecognitionState', () {
    test('should create state with default values', () {
      const state = SpeechRecognitionState();
      
      expect(state.status, SpeechRecognitionStatus.notInitialized);
      expect(state.transcriptionText, null);
      expect(state.errorMessage, null);
      expect(state.soundLevel, 0.0);
      expect(state.hasPermission, false);
      expect(state.availableLocales, isEmpty);
      expect(state.selectedLocale, null);
    });

    test('should create state with custom values', () {
      const state = SpeechRecognitionState(
        status: SpeechRecognitionStatus.listening,
        transcriptionText: 'test transcription',
        errorMessage: 'test error',
        soundLevel: 0.5,
        hasPermission: true,
        availableLocales: ['en-US', 'es-ES'],
        selectedLocale: 'en-US',
      );

      expect(state.status, SpeechRecognitionStatus.listening);
      expect(state.transcriptionText, 'test transcription');
      expect(state.errorMessage, 'test error');
      expect(state.soundLevel, 0.5);
      expect(state.hasPermission, true);
      expect(state.availableLocales, ['en-US', 'es-ES']);
      expect(state.selectedLocale, 'en-US');
    });

    test('should copy state with new values', () {
      const originalState = SpeechRecognitionState(
        status: SpeechRecognitionStatus.notInitialized,
        transcriptionText: 'original',
      );

      final newState = originalState.copyWith(
        status: SpeechRecognitionStatus.listening,
        transcriptionText: 'updated',
      );

      expect(newState.status, SpeechRecognitionStatus.listening);
      expect(newState.transcriptionText, 'updated');
      expect(newState.soundLevel, originalState.soundLevel); // Unchanged
    });

    test('should clear error message when copying with null', () {
      const originalState = SpeechRecognitionState(
        errorMessage: 'some error',
      );

      final newState = originalState.copyWith(errorMessage: null);
      expect(newState.errorMessage, null);
    });

    group('computed properties', () {
      test('isRecording should return true when listening', () {
        const state = SpeechRecognitionState(
          status: SpeechRecognitionStatus.listening,
        );
        expect(state.isRecording, true);
      });

      test('isRecording should return false when not listening', () {
        const state = SpeechRecognitionState(
          status: SpeechRecognitionStatus.available,
        );
        expect(state.isRecording, false);
      });

      test('isProcessing should return true when not initialized', () {
        const state = SpeechRecognitionState(
          status: SpeechRecognitionStatus.notInitialized,
        );
        expect(state.isProcessing, true);
      });

      test('isAvailable should return true for available states', () {
        const availableState = SpeechRecognitionState(
          status: SpeechRecognitionStatus.available,
        );
        const notListeningState = SpeechRecognitionState(
          status: SpeechRecognitionStatus.notListening,
        );

        expect(availableState.isAvailable, true);
        expect(notListeningState.isAvailable, true);
      });

      test('isAvailable should return false for unavailable states', () {
        const state = SpeechRecognitionState(
          status: SpeechRecognitionStatus.unavailable,
        );
        expect(state.isAvailable, false);
      });

      test('hasError should return true when status is error', () {
        const state = SpeechRecognitionState(
          status: SpeechRecognitionStatus.error,
        );
        expect(state.hasError, true);
      });

      test('hasError should return false when status is not error', () {
        const state = SpeechRecognitionState(
          status: SpeechRecognitionStatus.available,
        );
        expect(state.hasError, false);
      });
    });
  });

  group('SpeechRecognitionNotifier', () {
    late MockSpeechService mockSpeechService;
    late ProviderContainer container;

    setUp(() {
      mockSpeechService = const MockSpeechService();
      container = ProviderContainer(
        overrides: [
          speechServiceProvider.overrideWithValue(mockSpeechService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with default state', () {
      // final notifier = container.read(speechRecognitionProvider.notifier);
      final state = container.read(speechRecognitionProvider);

      expect(state.status, SpeechRecognitionStatus.notInitialized);
      expect(state.hasPermission, false);
      expect(state.isRecording, false);
    });

    test('should handle successful initialization', () async {
      when(mockSpeechService.hasPermission()).thenAnswer((_) async => true);
      when(mockSpeechService.initialize()).thenAnswer((_) async => true);
      when(mockSpeechService.getAvailableLocales())
          .thenAnswer((_) async => ['en-US', 'es-ES']);

      final notifier = container.read(speechRecognitionProvider.notifier);
      await notifier.initialize();

      final state = container.read(speechRecognitionProvider);
      expect(state.status, SpeechRecognitionStatus.available);
      expect(state.hasPermission, true);
      expect(state.availableLocales, ['en-US', 'es-ES']);
      expect(state.selectedLocale, 'en-US');
    });

    test('should handle permission denied during initialization', () async {
      when(mockSpeechService.hasPermission()).thenAnswer((_) async => false);
      when(mockSpeechService.requestPermission()).thenAnswer((_) async => false);

      final notifier = container.read(speechRecognitionProvider.notifier);
      await notifier.initialize();

      final state = container.read(speechRecognitionProvider);
      expect(state.status, SpeechRecognitionStatus.error);
      expect(state.hasPermission, false);
      expect(state.errorMessage, contains('permission'));
    });

    test('should handle speech recognition unavailable', () async {
      when(mockSpeechService.hasPermission()).thenAnswer((_) async => true);
      when(mockSpeechService.initialize()).thenAnswer((_) async => false);

      final notifier = container.read(speechRecognitionProvider.notifier);
      await notifier.initialize();

      final state = container.read(speechRecognitionProvider);
      expect(state.status, SpeechRecognitionStatus.unavailable);
      expect(state.errorMessage, contains('not available'));
    });

    test('should handle initialization errors', () async {
      when(mockSpeechService.hasPermission()).thenThrow(Exception('Test error'));

      final notifier = container.read(speechRecognitionProvider.notifier);
      await notifier.initialize();

      final state = container.read(speechRecognitionProvider);
      expect(state.status, SpeechRecognitionStatus.error);
      expect(state.errorMessage, contains('Test error'));
    });

    test('should clear error message', () {
      final notifier = container.read(speechRecognitionProvider.notifier);
      
      // Set an error state first
      notifier.state = notifier.state.copyWith(
        status: SpeechRecognitionStatus.error,
        errorMessage: 'Test error',
      );

      notifier.clearError();

      final state = container.read(speechRecognitionProvider);
      expect(state.errorMessage, null);
      expect(state.status, SpeechRecognitionStatus.notListening);
    });

    test('should clear transcription text', () {
      final notifier = container.read(speechRecognitionProvider.notifier);
      
      // Set transcription text first
      notifier.state = notifier.state.copyWith(
        transcriptionText: 'Test transcription',
      );

      notifier.clearTranscription();

      final state = container.read(speechRecognitionProvider);
      expect(state.transcriptionText, '');
    });

    test('should set selected locale', () {
      final notifier = container.read(speechRecognitionProvider.notifier);
      
      // Set available locales first
      notifier.state = notifier.state.copyWith(
        availableLocales: ['en-US', 'es-ES', 'fr-FR'],
      );

      notifier.setSelectedLocale('es-ES');

      final state = container.read(speechRecognitionProvider);
      expect(state.selectedLocale, 'es-ES');
    });

    test('should not set invalid locale', () {
      final notifier = container.read(speechRecognitionProvider.notifier);
      
      // Set available locales first
      notifier.state = notifier.state.copyWith(
        availableLocales: ['en-US', 'es-ES'],
        selectedLocale: 'en-US',
      );

      notifier.setSelectedLocale('invalid-locale');

      final state = container.read(speechRecognitionProvider);
      expect(state.selectedLocale, 'en-US'); // Should remain unchanged
    });
  });

  group('Computed Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = const ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('isRecordingProvider should return recording state', () {
      final notifier = container.read(speechRecognitionProvider.notifier);
      
      // Set listening state
      notifier.state = notifier.state.copyWith(
        status: SpeechRecognitionStatus.listening,
      );

      final isRecording = container.read(isRecordingProvider);
      expect(isRecording, true);
    });

    test('transcriptionTextProvider should return transcription text', () {
      final notifier = container.read(speechRecognitionProvider.notifier);
      
      notifier.state = notifier.state.copyWith(
        transcriptionText: 'Test transcription',
      );

      final transcriptionText = container.read(transcriptionTextProvider);
      expect(transcriptionText, 'Test transcription');
    });

    test('speechErrorProvider should return error message', () {
      final notifier = container.read(speechRecognitionProvider.notifier);
      
      notifier.state = notifier.state.copyWith(
        errorMessage: 'Test error',
      );

      final errorMessage = container.read(speechErrorProvider);
      expect(errorMessage, 'Test error');
    });

    test('speechAvailableLocalesProvider should return available locales', () {
      final notifier = container.read(speechRecognitionProvider.notifier);
      
      notifier.state = notifier.state.copyWith(
        availableLocales: ['en-US', 'es-ES'],
      );

      final availableLocales = container.read(speechAvailableLocalesProvider);
      expect(availableLocales, ['en-US', 'es-ES']);
    });

    test('selectedSpeechLocaleProvider should return selected locale', () {
      final notifier = container.read(speechRecognitionProvider.notifier);
      
      notifier.state = notifier.state.copyWith(
        selectedLocale: 'en-US',
      );

      final selectedLocale = container.read(selectedSpeechLocaleProvider);
      expect(selectedLocale, 'en-US');
    });
  });
}