import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/services/speech/voice_command_service.dart';
import 'package:task_tracker_app/services/speech/speech_service.dart';
import 'package:task_tracker_app/domain/repositories/task_repository.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';


import '../services/speech/voice_command_service_test.mocks.dart';

@GenerateMocks([SpeechService, TaskRepository])
void main() {
  group('Voice Command Integration Tests', () {
    late VoiceCommandService service;
    late MockSpeechService mockSpeechService;
    late MockTaskRepository mockTaskRepository;

    setUp(() async {
      mockSpeechService = const MockSpeechService();
      mockTaskRepository = const MockTaskRepository();
      
      service = VoiceCommandService(
        speechService: mockSpeechService,
        taskRepository: mockTaskRepository,
      );

      // Setup basic mocks
      when(mockSpeechService.initialize()).thenAnswer((_) async => true);
      when(mockSpeechService.isAvailable).thenReturn(true);
      
      await service.initialize();
    });

    tearDown(() async {
      await service.dispose();
    });

    group('Complete Task Management Workflow', () {
      test('should handle complete task lifecycle through voice commands', () async {
        // Mock repository responses
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async {});
        when(mockTaskRepository.searchTasks(any)).thenAnswer((_) async => []);
        when(mockTaskRepository.updateTask(any)).thenAnswer((_) async {});
        when(mockTaskRepository.deleteTask(any)).thenAnswer((_) async {});

        // Step 1: Create a task
        var result = await service.processTextCommand('create high priority task finish project report tomorrow');
        expect(result.success, true);
        expect(result.message, contains('Created task: finish project report'));

        // Capture the created task
        final createdTaskCapture = verify(mockTaskRepository.createTask(captureAny)).captured.first as TaskModel;
        expect(createdTaskCapture.title, 'finish project report');
        expect(createdTaskCapture.priority, TaskPriority.high);
        expect(createdTaskCapture.dueDate, isNotNull);

        // Step 2: Search for the task
        when(mockTaskRepository.searchTasks('project')).thenAnswer((_) async => [createdTaskCapture]);
        
        result = await service.processTextCommand('search for project');
        expect(result.success, true);
        expect(result.message, contains('Found 1 task matching "project"'));

        // Step 3: Add a subtask
        when(mockTaskRepository.searchTasks('finish project report')).thenAnswer((_) async => [createdTaskCapture]);
        
        result = await service.processTextCommand('add subtask review draft to finish project report');
        expect(result.success, true);
        expect(result.message, contains('Added subtask "review draft"'));

        // Step 4: Mark task in progress
        result = await service.processTextCommand('start working on finish project report');
        expect(result.success, true);
        expect(result.message, contains('Marked task in progress'));

        // Step 5: Change priority
        result = await service.processTextCommand('set finish project report priority to urgent');
        expect(result.success, true);
        expect(result.message, contains('Set finish project report priority to Urgent'));

        // Step 6: Complete the task
        result = await service.processTextCommand('complete task finish project report');
        expect(result.success, true);
        expect(result.message, contains('Completed task: finish project report'));

        // Verify all operations were called
        verify(mockTaskRepository.createTask(any)).called(1);
        verify(mockTaskRepository.updateTask(any)).called(4); // subtask, in progress, priority, complete
        verify(mockTaskRepository.searchTasks(any)).called(4);
      });

      test('should handle task management with natural language variations', () async {
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async {});

        // Test various ways to create tasks
        final createCommands = [
          'create task buy groceries',
          'add task call dentist',
          'new task prepare presentation',
          'remind me to water plants',
          'i need to finish homework',
        ];

        for (final command in createCommands) {
          final result = await service.processTextCommand(command);
          expect(result.success, true, reason: 'Failed for command: $command');
          expect(result.message, contains('Created task'), reason: 'Wrong message for: $command');
        }

        verify(mockTaskRepository.createTask(any)).called(createCommands.length);
      });

      test('should handle complex task creation with multiple attributes', () async {
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async {});

        final result = await service.processTextCommand(
          'create urgent priority task team meeting tomorrow at 2pm tagged with work'
        );

        expect(result.success, true);
        expect(result.message, contains('Created task: team meeting'));

        final capturedTask = verify(mockTaskRepository.createTask(captureAny)).captured.first as TaskModel;
        expect(capturedTask.title, 'team meeting');
        expect(capturedTask.priority, TaskPriority.urgent);
        expect(capturedTask.dueDate, isNotNull);
        expect(capturedTask.dueDate!.hour, 14); // 2 PM
        expect(capturedTask.tags, contains('work'));
      });
    });

    group('Error Handling and Recovery', () {
      test('should provide helpful suggestions for unrecognized commands', () async {
        final result = await service.processTextCommand('xyz random gibberish');
        
        expect(result.success, false);
        
        final suggestions = service.getCommandSuggestions('xyz random gibberish');
        expect(suggestions, isNotEmpty);
      });

      test('should handle database errors gracefully', () async {
        when(mockTaskRepository.createTask(any)).thenThrow(Exception('Database connection failed'));

        final result = await service.processTextCommand('create task test');
        
        expect(result.success, false);
        expect(result.message, contains('Failed to execute command'));
      });

      test('should handle missing task scenarios', () async {
        when(mockTaskRepository.searchTasks(any)).thenAnswer((_) async => []);

        final result = await service.processTextCommand('complete task nonexistent task');
        
        expect(result.success, false);
        expect(result.errorCode, 'task_not_found');
        expect(result.message, contains('Could not find task'));
      });
    });

    group('Voice Command Customization Integration', () {
      test('should support custom command aliases', () async {
        // Add a custom alias
        await service.customization.addCommandAlias('make task', 'create task');
        
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async {});

        // Use the alias
        final result = await service.processTextCommand('make task custom test');
        
        expect(result.success, true);
        expect(result.message, contains('Created task'));
      });

      test('should export and import customizations', () async {
        // Add some customizations
        await service.customization.addCommandAlias('do', 'create task');
        
        // Export customizations
        final exported = service.exportCustomizations();
        expect(exported, isA<String>());
        expect(exported.isNotEmpty, true);

        // Reset and import
        await service.resetCustomizations();
        await service.importCustomizations(exported);

        // Verify customizations were restored
        expect(service.customization.commandAliases, containsPair('do', 'create task'));
      });
    });

    group('Multi-Language and Locale Support', () {
      test('should handle different locales', () async {
        when(mockSpeechService.getAvailableLocales()).thenAnswer((_) async => ['en-US', 'es-ES', 'fr-FR']);

        final locales = await service.getAvailableLocales();
        
        expect(locales, contains('en-US'));
        expect(locales, contains('es-ES'));
        expect(locales, contains('fr-FR'));
      });
    });

    group('Performance and Concurrency', () {
      test('should handle rapid command sequences', () async {
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 10));
        });

        final commands = [
          'create task task 1',
          'create task task 2',
          'create task task 3',
        ];

        final results = <dynamic>[];
        for (final command in commands) {
          final result = await service.processTextCommand(command);
          results.add(result);
        }

        expect(results.length, 3);
        expect(results.every((r) => r.success), true);
        verify(mockTaskRepository.createTask(any)).called(3);
      });

      test('should prevent concurrent processing', () async {
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
        });

        // Start first command
        final future1 = service.processTextCommand('create task test 1');
        
        // Try to start second command immediately
        expect(
          () => service.processTextCommand('create task test 2'),
          throwsStateError,
        );

        await future1;
      });
    });

    group('State Management Integration', () {
      test('should track service state throughout operations', () async {
        final states = <VoiceCommandServiceState>[];
        service.stateChanges.listen(states.add);

        when(mockTaskRepository.createTask(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
        });

        expect(service.currentState, VoiceCommandServiceState.idle);

        final future = service.processTextCommand('create task test');
        
        // Should transition to processing
        expect(service.currentState, VoiceCommandServiceState.processing);

        await future;

        // Should return to idle
        expect(service.currentState, VoiceCommandServiceState.idle);

        // Allow time for state changes to propagate
        await Future.delayed(const Duration(milliseconds: 10));

        expect(states, contains(VoiceCommandServiceState.processing));
        expect(states, contains(VoiceCommandServiceState.idle));
      });
    });

    group('Real-world Scenarios', () {
      test('should handle shopping list creation scenario', () async {
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async {});

        final shoppingCommands = [
          'create task buy milk',
          'create task buy bread',
          'create task buy eggs',
          'create high priority task buy birthday cake tomorrow',
        ];

        for (final command in shoppingCommands) {
          final result = await service.processTextCommand(command);
          expect(result.success, true);
        }

        verify(mockTaskRepository.createTask(any)).called(4);
      });

      test('should handle work project management scenario', () async {
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async {});
        when(mockTaskRepository.searchTasks(any)).thenAnswer((_) async => []);
        when(mockTaskRepository.updateTask(any)).thenAnswer((_) async {});

        // Create project tasks
        await service.processTextCommand('create urgent task prepare quarterly report due next week');
        await service.processTextCommand('create task schedule team meeting');
        await service.processTextCommand('create high priority task review budget proposals');

        // Simulate finding and updating tasks
        final mockTask = TaskModel.create(title: 'prepare quarterly report', priority: TaskPriority.urgent);
        when(mockTaskRepository.searchTasks('quarterly report')).thenAnswer((_) async => [mockTask]);

        await service.processTextCommand('add subtask gather financial data to quarterly report');
        await service.processTextCommand('start working on quarterly report');

        verify(mockTaskRepository.createTask(any)).called(3);
        verify(mockTaskRepository.updateTask(any)).called(2);
      });

      test('should handle personal task management scenario', () async {
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async {});
        when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => [
          TaskModel.create(title: 'exercise', priority: TaskPriority.medium),
          TaskModel.create(title: 'read book', priority: TaskPriority.low),
          TaskModel.create(title: 'call family', priority: TaskPriority.high),
        ]);

        // Create personal tasks
        await service.processTextCommand('remind me to exercise today');
        await service.processTextCommand('create task read book for 30 minutes');
        await service.processTextCommand('create high priority task call family');

        // List all tasks
        final result = await service.processTextCommand('what are my tasks');
        expect(result.success, true);
        expect(result.message, contains('You have 3 active tasks'));

        verify(mockTaskRepository.createTask(any)).called(3);
        verify(mockTaskRepository.getAllTasks()).called(1);
      });
    });
  });
}