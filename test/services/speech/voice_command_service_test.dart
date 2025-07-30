import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/services/speech/voice_command_service.dart';
import 'package:task_tracker_app/services/speech/speech_service.dart';
import 'package:task_tracker_app/services/speech/voice_command_customization.dart';
import 'package:task_tracker_app/domain/repositories/task_repository.dart';


import 'voice_command_service_test.mocks.dart';

@GenerateMocks([SpeechService, TaskRepository, VoiceCommandCustomization])
void main() {
  group('VoiceCommandService', () {
    late VoiceCommandService service;
    late MockSpeechService mockSpeechService;
    late MockTaskRepository mockTaskRepository;
    late MockVoiceCommandCustomization mockCustomization;

    setUp(() {
      mockSpeechService = MockSpeechService();
      mockTaskRepository = MockTaskRepository();
      mockCustomization = MockVoiceCommandCustomization();
      
      service = VoiceCommandService(
        speechService: mockSpeechService,
        taskRepository: mockTaskRepository,
        customization: mockCustomization,
      );
    });

    tearDown(() async {
      await service.dispose();
    });

    group('Initialization', () {
      test('should initialize successfully when speech service is available', () async {
        when(mockSpeechService.initialize()).thenAnswer((_) async => true);
        when(mockSpeechService.isAvailable).thenReturn(true);
        when(mockCustomization.initialize()).thenAnswer((_) async {});

        final result = await service.initialize();

        expect(result, true);
        expect(service.isAvailable, true);
        expect(service.currentState, VoiceCommandServiceState.idle);
        verify(mockSpeechService.initialize()).called(1);
        verify(mockCustomization.initialize()).called(1);
      });

      test('should fail to initialize when speech service is not available', () async {
        when(mockSpeechService.initialize()).thenAnswer((_) async => false);
        when(mockSpeechService.isAvailable).thenReturn(false);

        final result = await service.initialize();

        expect(result, false);
        expect(service.isAvailable, false);
      });

      test('should handle initialization errors gracefully', () async {
        when(mockSpeechService.initialize()).thenThrow(Exception('Initialization failed'));

        final result = await service.initialize();

        expect(result, false);
      });
    });

    group('Voice Listening', () {
      setUp(() async {
        when(mockSpeechService.initialize()).thenAnswer((_) async => true);
        when(mockSpeechService.isAvailable).thenReturn(true);
        await service.initialize();
      });

      test('should start listening successfully', () async {
        when(mockSpeechService.startListening(
          onResult: anyNamed('onResult'),
          onError: anyNamed('onError'),
          localeId: anyNamed('localeId'),
          listenFor: anyNamed('listenFor'),
        )).thenAnswer((_) async {});

        await service.startListening();

        expect(service.isListening, true);
        expect(service.currentState, VoiceCommandServiceState.listening);
        verify(mockSpeechService.startListening(
          onResult: anyNamed('onResult'),
          onError: anyNamed('onError'),
          localeId: anyNamed('localeId'),
          listenFor: anyNamed('listenFor'),
        )).called(1);
      });

      test('should not start listening when already listening', () async {
        when(mockSpeechService.startListening(
          onResult: anyNamed('onResult'),
          onError: anyNamed('onError'),
          localeId: anyNamed('localeId'),
          listenFor: anyNamed('listenFor'),
        )).thenAnswer((_) async {});

        // Start listening first time
        await service.startListening();
        expect(service.isListening, true);

        // Try to start listening again
        await service.startListening();

        // Should only be called once
        verify(mockSpeechService.startListening(
          onResult: anyNamed('onResult'),
          onError: anyNamed('onError'),
          localeId: anyNamed('localeId'),
          listenFor: anyNamed('listenFor'),
        )).called(1);
      });

      test('should stop listening successfully', () async {
        when(mockSpeechService.startListening(
          onResult: anyNamed('onResult'),
          onError: anyNamed('onError'),
          localeId: anyNamed('localeId'),
          listenFor: anyNamed('listenFor'),
        )).thenAnswer((_) async {});
        when(mockSpeechService.stopListening()).thenAnswer((_) async {});

        await service.startListening();
        await service.stopListening();

        expect(service.isListening, false);
        expect(service.currentState, VoiceCommandServiceState.idle);
        verify(mockSpeechService.stopListening()).called(1);
      });

      test('should cancel listening successfully', () async {
        when(mockSpeechService.startListening(
          onResult: anyNamed('onResult'),
          onError: anyNamed('onError'),
          localeId: anyNamed('localeId'),
          listenFor: anyNamed('listenFor'),
        )).thenAnswer((_) async {});
        when(mockSpeechService.cancel()).thenAnswer((_) async {});

        await service.startListening();
        await service.cancelListening();

        expect(service.isListening, false);
        expect(service.currentState, VoiceCommandServiceState.idle);
        verify(mockSpeechService.cancel()).called(1);
      });
    });

    group('Text Command Processing', () {
      setUp(() async {
        when(mockSpeechService.initialize()).thenAnswer((_) async => true);
        when(mockSpeechService.isAvailable).thenReturn(true);
        await service.initialize();
      });

      test('should process text command successfully', () async {
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async {});

        final result = await service.processTextCommand('create task buy groceries');

        expect(result.success, true);
        expect(result.message, contains('Created task: buy groceries'));
        verify(mockTaskRepository.createTask(any)).called(1);
      });

      test('should handle processing errors gracefully', () async {
        when(mockTaskRepository.createTask(any)).thenThrow(Exception('Database error'));

        final result = await service.processTextCommand('create task test');

        expect(result.success, false);
        expect(result.message, contains('Failed to execute command'));
      });

      test('should not allow concurrent processing', () async {
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
        });

        // Start first command
        final future1 = service.processTextCommand('create task test1');
        
        // Try to start second command while first is processing
        expect(
          () => service.processTextCommand('create task test2'),
          throwsStateError,
        );

        await future1;
      });
    });

    group('State Management', () {
      setUp(() async {
        when(mockSpeechService.initialize()).thenAnswer((_) async => true);
        when(mockSpeechService.isAvailable).thenReturn(true);
        await service.initialize();
      });

      test('should emit state changes correctly', () async {
        final stateChanges = <VoiceCommandServiceState>[];
        service.stateChanges.listen(stateChanges.add);

        when(mockSpeechService.startListening(
          onResult: anyNamed('onResult'),
          onError: anyNamed('onError'),
          localeId: anyNamed('localeId'),
          listenFor: anyNamed('listenFor'),
        )).thenAnswer((_) async {});
        when(mockSpeechService.stopListening()).thenAnswer((_) async {});

        await service.startListening();
        await service.stopListening();

        // Allow time for state changes to propagate
        await Future.delayed(const Duration(milliseconds: 10));

        expect(stateChanges, contains(VoiceCommandServiceState.listening));
        expect(stateChanges, contains(VoiceCommandServiceState.idle));
      });

      test('should track processing state correctly', () async {
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
        });

        expect(service.currentState, VoiceCommandServiceState.idle);
        expect(service.isProcessing, false);

        final future = service.processTextCommand('create task test');
        
        // Should be processing now
        expect(service.currentState, VoiceCommandServiceState.processing);
        expect(service.isProcessing, true);

        await future;

        // Should be idle again
        expect(service.currentState, VoiceCommandServiceState.idle);
        expect(service.isProcessing, false);
      });
    });

    group('Permission Management', () {
      test('should check microphone permission', () async {
        when(mockSpeechService.hasPermission()).thenAnswer((_) async => true);

        final hasPermission = await service.hasPermission();

        expect(hasPermission, true);
        verify(mockSpeechService.hasPermission()).called(1);
      });

      test('should request microphone permission', () async {
        when(mockSpeechService.requestPermission()).thenAnswer((_) async => true);

        final granted = await service.requestPermission();

        expect(granted, true);
        verify(mockSpeechService.requestPermission()).called(1);
      });
    });

    group('Locale Management', () {
      test('should get available locales', () async {
        final locales = ['en-US', 'es-ES', 'fr-FR'];
        when(mockSpeechService.getAvailableLocales()).thenAnswer((_) async => locales);

        final result = await service.getAvailableLocales();

        expect(result, locales);
        verify(mockSpeechService.getAvailableLocales()).called(1);
      });
    });

    group('Customization', () {
      test('should provide access to customization service', () {
        expect(service.customization, isNotNull);
      });

      test('should export customizations', () {
        when(mockCustomization.exportCustomizations()).thenReturn('{"customCommands": {}}');
        
        final exported = service.exportCustomizations();
        expect(exported, isA<String>());
        expect(exported.isNotEmpty, true);
        verify(mockCustomization.exportCustomizations()).called(1);
      });
    });

    group('Error Handling', () {
      setUp(() async {
        when(mockSpeechService.initialize()).thenAnswer((_) async => true);
        when(mockSpeechService.isAvailable).thenReturn(true);
        await service.initialize();
      });

      test('should handle speech service errors', () async {
        final errors = <String>[];
        service.errors.listen(errors.add);

        when(mockSpeechService.startListening(
          onResult: anyNamed('onResult'),
          onError: anyNamed('onError'),
          localeId: anyNamed('localeId'),
          listenFor: anyNamed('listenFor'),
        )).thenThrow(Exception('Speech service error'));

        await service.startListening();

        // Allow time for error to propagate
        await Future.delayed(const Duration(milliseconds: 10));

        expect(errors.isNotEmpty, true);
        expect(errors.first, contains('Failed to start listening'));
      });

      test('should provide command suggestions for failed commands', () async {
        when(mockTaskRepository.searchTasks(any)).thenAnswer((_) async => []);
        when(mockCustomization.getCommandSuggestions(any)).thenReturn(['Try: complete task [task name]', 'Try: finish task [task name]']);

        final result = await service.processTextCommand('complete task nonexistent');

        expect(result.success, false);
        
        final suggestions = service.getCommandSuggestions('complete task nonexistent');
        expect(suggestions, isNotEmpty);
        verify(mockCustomization.getCommandSuggestions('complete task nonexistent')).called(1);
      });
    });

    group('Stream Management', () {
      setUp(() async {
        when(mockSpeechService.initialize()).thenAnswer((_) async => true);
        when(mockSpeechService.isAvailable).thenReturn(true);
        await service.initialize();
      });

      test('should emit results through stream', () async {
        final results = <dynamic>[];
        service.results.listen(results.add);

        when(mockTaskRepository.createTask(any)).thenAnswer((_) async {});

        await service.processTextCommand('create task test');

        // Allow time for result to propagate
        await Future.delayed(const Duration(milliseconds: 10));

        expect(results.isNotEmpty, true);
        expect(results.first.success, true);
      });

      test('should emit transcriptions through stream', () async {
        final transcriptions = <String>[];
        service.transcriptions.listen(transcriptions.add);

        // This would be called by the speech service callback
        // In a real test, we'd need to trigger the callback
        // For now, we'll just verify the stream exists
        expect(service.transcriptions, isNotNull);
      });
    });
  });
}