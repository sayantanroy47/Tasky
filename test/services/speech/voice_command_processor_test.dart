import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/services/speech/voice_command_processor.dart';
import 'package:task_tracker_app/services/speech/voice_command_models.dart';
import 'package:task_tracker_app/domain/repositories/task_repository.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';


import 'voice_command_processor_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  group('VoiceCommandProcessor', () {
    late VoiceCommandProcessor processor;
    late MockTaskRepository mockRepository;

    setUp(() {
      mockRepository = const MockTaskRepository();
      processor = VoiceCommandProcessor(taskRepository: mockRepository);
    });

    tearDown(() {
      processor.dispose();
    });

    group('Create Task Commands', () {
      test('should create task successfully', () async {
        final command = VoiceCommand.createTask(
          originalText: 'create task buy groceries',
          taskTitle: 'buy groceries',
        );

        when(mockRepository.createTask(any)).thenAnswer((_) async {});

        final result = await processor.executeCommand(command);

        expect(result.success, true);
        expect(result.message, contains('Created task: buy groceries'));
        verify(mockRepository.createTask(any)).called(1);
      });

      test('should fail to create task without title', () async {
        final command = VoiceCommand.createTask(
          originalText: 'create task',
          taskTitle: '',
        );

        final result = await processor.executeCommand(command);

        expect(result.success, false);
        expect(result.errorCode, 'missing_title');
        verifyNever(mockRepository.createTask(any));
      });

      test('should create task with priority and due date', () async {
        final dueDate = DateTime.now().add(const Duration(days: 1));
        final command = VoiceCommand.createTask(
          originalText: 'create high priority task meeting tomorrow',
          taskTitle: 'meeting',
          priority: TaskPriority.high,
          dueDate: dueDate,
        );

        when(mockRepository.createTask(any)).thenAnswer((_) async {});

        final result = await processor.executeCommand(command);

        expect(result.success, true);
        
        final capturedTask = verify(mockRepository.createTask(captureAny)).captured.first as TaskModel;
        expect(capturedTask.title, 'meeting');
        expect(capturedTask.priority, TaskPriority.high);
        expect(capturedTask.dueDate?.day, dueDate.day);
      });
    });

    group('Complete Task Commands', () {
      test('should complete task successfully', () async {
        final existingTask = TaskModel.create(
          title: 'buy groceries',
          priority: TaskPriority.medium,
        );

        final command = VoiceCommand.completeTask(
          originalText: 'complete task buy groceries',
          taskTitle: 'buy groceries',
        );

        when(mockRepository.searchTasks('buy groceries'))
            .thenAnswer((_) async => [existingTask]);
        when(mockRepository.updateTask(any)).thenAnswer((_) async {});

        final result = await processor.executeCommand(command);

        expect(result.success, true);
        expect(result.message, contains('Completed task: buy groceries'));
        
        final capturedTask = verify(mockRepository.updateTask(captureAny)).captured.first as TaskModel;
        expect(capturedTask.status, TaskStatus.completed);
        expect(capturedTask.completedAt, isNotNull);
      });

      test('should fail to complete non-existent task', () async {
        final command = VoiceCommand.completeTask(
          originalText: 'complete task non-existent',
          taskTitle: 'non-existent',
        );

        when(mockRepository.searchTasks('non-existent'))
            .thenAnswer((_) async => []);

        final result = await processor.executeCommand(command);

        expect(result.success, false);
        expect(result.errorCode, 'task_not_found');
        verifyNever(mockRepository.updateTask(any));
      });
    });

    group('Delete Task Commands', () {
      test('should delete task successfully', () async {
        final existingTask = TaskModel.create(
          title: 'old meeting',
          priority: TaskPriority.medium,
        );

        final command = VoiceCommand.deleteTask(
          originalText: 'delete task old meeting',
          taskTitle: 'old meeting',
        );

        when(mockRepository.searchTasks('old meeting'))
            .thenAnswer((_) async => [existingTask]);
        when(mockRepository.deleteTask(existingTask.id)).thenAnswer((_) async {});

        final result = await processor.executeCommand(command);

        expect(result.success, true);
        expect(result.message, contains('Deleted task: old meeting'));
        verify(mockRepository.deleteTask(existingTask.id)).called(1);
      });
    });

    group('Reschedule Task Commands', () {
      test('should reschedule task successfully', () async {
        final existingTask = TaskModel.create(
          title: 'meeting',
          priority: TaskPriority.medium,
        );

        final newDueDate = DateTime.now().add(const Duration(days: 2));
        final command = VoiceCommand.rescheduleTask(
          originalText: 'reschedule meeting to day after tomorrow',
          taskTitle: 'meeting',
          newDueDate: newDueDate,
        );

        when(mockRepository.searchTasks('meeting'))
            .thenAnswer((_) async => [existingTask]);
        when(mockRepository.updateTask(any)).thenAnswer((_) async {});

        final result = await processor.executeCommand(command);

        expect(result.success, true);
        expect(result.message, contains('Rescheduled task: meeting'));
        
        final capturedTask = verify(mockRepository.updateTask(captureAny)).captured.first as TaskModel;
        expect(capturedTask.dueDate?.day, newDueDate.day);
      });

      test('should fail to reschedule without due date', () async {
        final existingTask = TaskModel.create(
          title: 'meeting',
          priority: TaskPriority.medium,
        );

        final command = VoiceCommand.rescheduleTask(
          originalText: 'reschedule meeting',
          taskTitle: 'meeting',
        );

        when(mockRepository.searchTasks('meeting'))
            .thenAnswer((_) async => [existingTask]);

        final result = await processor.executeCommand(command);

        expect(result.success, false);
        expect(result.errorCode, 'missing_due_date');
      });
    });

    group('Set Priority Commands', () {
      test('should set task priority successfully', () async {
        final existingTask = TaskModel.create(
          title: 'report',
          priority: TaskPriority.medium,
        );

        final command = VoiceCommand.setPriority(
          originalText: 'set report priority to high',
          taskTitle: 'report',
          priority: TaskPriority.high,
        );

        when(mockRepository.searchTasks('report'))
            .thenAnswer((_) async => [existingTask]);
        when(mockRepository.updateTask(any)).thenAnswer((_) async {});

        final result = await processor.executeCommand(command);

        expect(result.success, true);
        expect(result.message, contains('Set report priority to High'));
        
        final capturedTask = verify(mockRepository.updateTask(captureAny)).captured.first as TaskModel;
        expect(capturedTask.priority, TaskPriority.high);
      });
    });

    group('Search Tasks Commands', () {
      test('should search tasks successfully', () async {
        final tasks = [
          TaskModel.create(title: 'grocery shopping', priority: TaskPriority.medium),
          TaskModel.create(title: 'buy groceries', priority: TaskPriority.low),
        ];

        final command = VoiceCommand.searchTasks(
          originalText: 'search for grocery',
          searchQuery: 'grocery',
        );

        when(mockRepository.searchTasks('grocery'))
            .thenAnswer((_) async => tasks);

        final result = await processor.executeCommand(command);

        expect(result.success, true);
        expect(result.message, contains('Found 2 tasks matching "grocery"'));
        expect(result.data['count'], 2);
      });

      test('should handle empty search results', () async {
        final command = VoiceCommand.searchTasks(
          originalText: 'search for nonexistent',
          searchQuery: 'nonexistent',
        );

        when(mockRepository.searchTasks('nonexistent'))
            .thenAnswer((_) async => []);

        final result = await processor.executeCommand(command);

        expect(result.success, true);
        expect(result.message, contains('Found 0 tasks matching "nonexistent"'));
        expect(result.data['count'], 0);
      });
    });

    group('List Tasks Commands', () {
      test('should list active tasks successfully', () async {
        final tasks = [
          TaskModel.create(title: 'active task 1', priority: TaskPriority.medium),
          TaskModel.create(title: 'active task 2', priority: TaskPriority.high),
          TaskModel.create(title: 'completed task', priority: TaskPriority.low)
              .markCompleted(),
        ];

        final command = VoiceCommand(
          type: VoiceCommandType.listTasks,
          confidence: CommandConfidence.high,
          originalText: 'list tasks',
          timestamp: DateTime.now(),
        );

        when(mockRepository.getAllTasks()).thenAnswer((_) async => tasks);

        final result = await processor.executeCommand(command);

        expect(result.success, true);
        expect(result.message, contains('You have 2 active tasks'));
        expect(result.data['count'], 2);
      });
    });

    group('Add Subtask Commands', () {
      test('should add subtask successfully', () async {
        final existingTask = TaskModel.create(
          title: 'project report',
          priority: TaskPriority.medium,
        );

        final command = VoiceCommand(
          type: VoiceCommandType.addSubtask,
          confidence: CommandConfidence.high,
          originalText: 'add subtask review draft to project report',
          timestamp: DateTime.now(),
          taskTitle: 'project report',
          subtaskTitle: 'review draft',
          parameters: const {
            'taskTitle': 'project report',
            'subtaskTitle': 'review draft',
          },
        );

        when(mockRepository.searchTasks('project report'))
            .thenAnswer((_) async => [existingTask]);
        when(mockRepository.updateTask(any)).thenAnswer((_) async {});

        final result = await processor.executeCommand(command);

        expect(result.success, true);
        expect(result.message, contains('Added subtask "review draft" to project report'));
        
        final capturedTask = verify(mockRepository.updateTask(captureAny)).captured.first as TaskModel;
        expect(capturedTask.subTasks.length, 1);
        expect(capturedTask.subTasks.first.title, 'review draft');
      });
    });

    group('Mark In Progress Commands', () {
      test('should mark task in progress successfully', () async {
        final existingTask = TaskModel.create(
          title: 'presentation',
          priority: TaskPriority.medium,
        );

        final command = VoiceCommand(
          type: VoiceCommandType.markInProgress,
          confidence: CommandConfidence.high,
          originalText: 'start working on presentation',
          timestamp: DateTime.now(),
          taskTitle: 'presentation',
          status: TaskStatus.inProgress,
          parameters: {
            'taskTitle': 'presentation',
            'status': TaskStatus.inProgress.name,
          },
        );

        when(mockRepository.searchTasks('presentation'))
            .thenAnswer((_) async => [existingTask]);
        when(mockRepository.updateTask(any)).thenAnswer((_) async {});

        final result = await processor.executeCommand(command);

        expect(result.success, true);
        expect(result.message, contains('Marked task in progress: presentation'));
        
        final capturedTask = verify(mockRepository.updateTask(captureAny)).captured.first as TaskModel;
        expect(capturedTask.status, TaskStatus.inProgress);
      });
    });

    group('Pin/Unpin Task Commands', () {
      test('should pin task successfully', () async {
        final existingTask = TaskModel.create(
          title: 'important task',
          priority: TaskPriority.medium,
        );

        final command = VoiceCommand(
          type: VoiceCommandType.pinTask,
          confidence: CommandConfidence.high,
          originalText: 'pin important task',
          timestamp: DateTime.now(),
          taskTitle: 'important task',
          parameters: const {'taskTitle': 'important task'},
        );

        when(mockRepository.searchTasks('important task'))
            .thenAnswer((_) async => [existingTask]);
        when(mockRepository.updateTask(any)).thenAnswer((_) async {});

        final result = await processor.executeCommand(command);

        expect(result.success, true);
        expect(result.message, contains('Pinned task: important task'));
        
        final capturedTask = verify(mockRepository.updateTask(captureAny)).captured.first as TaskModel;
        expect(capturedTask.isPinned, true);
      });
    });

    group('Process Voice Input', () {
      test('should process voice input end-to-end', () async {
        when(mockRepository.createTask(any)).thenAnswer((_) async {});

        final result = await processor.processVoiceInput('create task test task');

        expect(result.success, true);
        expect(result.message, contains('Created task: test task'));
        verify(mockRepository.createTask(any)).called(1);
      });

      test('should handle processing errors gracefully', () async {
        when(mockRepository.createTask(any)).thenThrow(Exception('Database error'));

        final result = await processor.processVoiceInput('create task test task');

        expect(result.success, false);
        expect(result.message, contains('Failed to execute command'));
      });
    });

    group('Unknown Commands', () {
      test('should handle unknown commands', () async {
        final command = VoiceCommand.unknown(
          originalText: 'random gibberish',
          errorMessage: 'Could not parse command',
        );

        final result = await processor.executeCommand(command);

        expect(result.success, false);
        expect(result.errorCode, 'unknown_command');
      });
    });

    group('Task Finding', () {
      test('should find task by exact title match', () async {
        final tasks = [
          TaskModel.create(title: 'buy groceries', priority: TaskPriority.medium),
          TaskModel.create(title: 'grocery shopping', priority: TaskPriority.low),
        ];

        final command = VoiceCommand.completeTask(
          originalText: 'complete task buy groceries',
          taskTitle: 'buy groceries',
        );

        when(mockRepository.searchTasks('buy groceries'))
            .thenAnswer((_) async => tasks);
        when(mockRepository.updateTask(any)).thenAnswer((_) async {});

        final result = await processor.executeCommand(command);

        expect(result.success, true);
        
        // Should find the exact match
        final capturedTask = verify(mockRepository.updateTask(captureAny)).captured.first as TaskModel;
        expect(capturedTask.title, 'buy groceries');
      });

      test('should find task by partial match when no exact match', () async {
        final tasks = [
          TaskModel.create(title: 'grocery shopping list', priority: TaskPriority.medium),
        ];

        final command = VoiceCommand.completeTask(
          originalText: 'complete task grocery',
          taskTitle: 'grocery',
        );

        when(mockRepository.searchTasks('grocery'))
            .thenAnswer((_) async => tasks);
        when(mockRepository.updateTask(any)).thenAnswer((_) async {});

        final result = await processor.executeCommand(command);

        expect(result.success, true);
        
        final capturedTask = verify(mockRepository.updateTask(captureAny)).captured.first as TaskModel;
        expect(capturedTask.title, 'grocery shopping list');
      });
    });
  });
}