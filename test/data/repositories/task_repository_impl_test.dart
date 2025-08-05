import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/data/repositories/task_repository_impl.dart';
import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/services/database/daos/task_dao.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/data/models/api_models.dart';

import 'task_repository_impl_test.mocks.dart';

@GenerateMocks([AppDatabase, TaskDao])
void main() {
  group('TaskRepositoryImpl', () {
    late TaskRepositoryImpl repository;
    late MockAppDatabase mockDatabase;
    late MockTaskDao mockTaskDao;

    setUp(() {
      mockDatabase = MockAppDatabase();
      mockTaskDao = MockTaskDao();
      when(mockDatabase.taskDao).thenReturn(mockTaskDao);
      repository = TaskRepositoryImpl(mockDatabase);
    });

    group('createTask', () {
      test('should create task successfully', () async {
        // Arrange
        final task = TaskModel.create(
          title: 'Test Task',
          description: 'Test Description',
          priority: TaskPriority.high,
        );

        when(mockTaskDao.createTask(any)).thenAnswer((_) async {});

        // Act
        await repository.createTask(task);

        // Assert
        verify(mockTaskDao.createTask(any)).called(1);
      });

      test('should handle task creation error', () async {
        // Arrange
        final task = TaskModel.create(title: 'Test Task');
        when(mockTaskDao.createTask(any)).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.createTask(task),
          throwsA(isA<Exception>()),
        );
      });

      test('should create task with all properties', () async {
        // Arrange
        final now = DateTime.now();
        final task = TaskModel(
          id: 'test-id',
          title: 'Complex Task',
          description: 'Detailed description',
          createdAt: now,
          updatedAt: now,
          dueDate: now.add(const Duration(days: 1)),
          completedAt: null,
          priority: TaskPriority.urgent,
          status: TaskStatus.pending,
          tags: ['work', 'important'],
          subTasks: [],
          locationTrigger: 'Office',
          recurrence: null,
          projectId: 'project-1',
          dependencies: ['task-0'],
          metadata: {'key': 'value'},
          isPinned: true,
          estimatedDuration: 120,
          actualDuration: null,
        );

        TaskTableData? capturedTaskData;
        when(mockTaskDao.createTask(any)).thenAnswer((invocation) async {
          capturedTaskData = invocation.positionalArguments[0] as TaskTableData;
        });

        // Act
        await repository.createTask(task);

        // Assert
        expect(capturedTaskData, isNotNull);
        expect(capturedTaskData!.id, task.id);
        expect(capturedTaskData!.title, task.title);
        expect(capturedTaskData!.description, task.description);
        expect(capturedTaskData!.priority, task.priority.name);
        expect(capturedTaskData!.status, task.status.name);
        expect(capturedTaskData!.isPinned, task.isPinned);
      });
    });

    group('getAllTasks', () {
      test('should return all tasks', () async {
        // Arrange
        final taskData = [
          TaskTableData(
            id: 'task-1',
            title: 'Task 1',
            createdAt: DateTime.now(),
            priority: TaskPriority.medium.name,
            status: TaskStatus.pending.name,
            tags: '["work"]',
            isPinned: false,
          ),
          TaskTableData(
            id: 'task-2',
            title: 'Task 2',
            createdAt: DateTime.now(),
            priority: TaskPriority.high.name,
            status: TaskStatus.completed.name,
            tags: '["personal"]',
            isPinned: true,
          ),
        ];

        when(mockTaskDao.getAllTasks()).thenAnswer((_) async => taskData);

        // Act
        final result = await repository.getAllTasks();

        // Assert
        expect(result, hasLength(2));
        expect(result[0].id, 'task-1');
        expect(result[0].title, 'Task 1');
        expect(result[0].priority, TaskPriority.medium);
        expect(result[0].status, TaskStatus.pending);
        expect(result[1].id, 'task-2');
        expect(result[1].isPinned, true);
      });

      test('should return empty list when no tasks', () async {
        // Arrange
        when(mockTaskDao.getAllTasks()).thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllTasks();

        // Assert
        expect(result, isEmpty);
      });

      test('should handle database error', () async {
        // Arrange
        when(mockTaskDao.getAllTasks()).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.getAllTasks(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getTaskById', () {
      test('should return task when found', () async {
        // Arrange
        const taskId = 'task-1';
        final taskData = TaskTableData(
          id: taskId,
          title: 'Found Task',
          createdAt: DateTime.now(),
          priority: TaskPriority.high.name,
          status: TaskStatus.inProgress.name,
          tags: '["urgent"]',
          isPinned: false,
        );

        when(mockTaskDao.getTaskById(taskId)).thenAnswer((_) async => taskData);

        // Act
        final result = await repository.getTaskById(taskId);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, taskId);
        expect(result.title, 'Found Task');
        expect(result.priority, TaskPriority.high);
        expect(result.status, TaskStatus.inProgress);
      });

      test('should return null when task not found', () async {
        // Arrange
        const taskId = 'nonexistent';
        when(mockTaskDao.getTaskById(taskId)).thenAnswer((_) async => null);

        // Act
        final result = await repository.getTaskById(taskId);

        // Assert
        expect(result, isNull);
      });
    });

    group('updateTask', () {
      test('should update task successfully', () async {
        // Arrange
        final task = TaskModel.create(title: 'Updated Task');
        when(mockTaskDao.updateTask(any)).thenAnswer((_) async {});

        // Act
        await repository.updateTask(task);

        // Assert
        verify(mockTaskDao.updateTask(any)).called(1);
      });

      test('should update task with modified timestamp', () async {
        // Arrange
        final originalTime = DateTime.now().subtract(const Duration(hours: 1));
        final task = TaskModel(
          id: 'test-id',
          title: 'Updated Task',
          createdAt: originalTime,
          updatedAt: originalTime, // Old timestamp
        );

        TaskTableData? capturedTaskData;
        when(mockTaskDao.updateTask(any)).thenAnswer((invocation) async {
          capturedTaskData = invocation.positionalArguments[0] as TaskTableData;
        });

        // Act
        await repository.updateTask(task);

        // Assert
        expect(capturedTaskData, isNotNull);
        expect(capturedTaskData!.updatedAt, isNotNull);
        expect(capturedTaskData!.updatedAt!.isAfter(originalTime), true);
      });
    });

    group('deleteTask', () {
      test('should delete task successfully', () async {
        // Arrange
        const taskId = 'task-to-delete';
        when(mockTaskDao.deleteTask(taskId)).thenAnswer((_) async {});

        // Act
        await repository.deleteTask(taskId);

        // Assert
        verify(mockTaskDao.deleteTask(taskId)).called(1);
      });

      test('should handle deletion error', () async {
        // Arrange
        const taskId = 'task-to-delete';
        when(mockTaskDao.deleteTask(taskId)).thenThrow(Exception('Delete failed'));

        // Act & Assert
        expect(
          () => repository.deleteTask(taskId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getTasksByStatus', () {
      test('should return tasks with specific status', () async {
        // Arrange
        const status = TaskStatus.completed;
        final taskData = [
          TaskTableData(
            id: 'completed-1',
            title: 'Completed Task 1',
            createdAt: DateTime.now(),
            priority: TaskPriority.medium.name,
            status: status.name,
            tags: '[]',
            isPinned: false,
          ),
          TaskTableData(
            id: 'completed-2',
            title: 'Completed Task 2',
            createdAt: DateTime.now(),
            priority: TaskPriority.low.name,
            status: status.name,
            tags: '[]',
            isPinned: false,
          ),
        ];

        when(mockTaskDao.getTasksByStatus(status.name)).thenAnswer((_) async => taskData);

        // Act
        final result = await repository.getTasksByStatus(status);

        // Assert
        expect(result, hasLength(2));
        expect(result.every((task) => task.status == status), true);
      });
    });

    group('getTasksByPriority', () {
      test('should return tasks with specific priority', () async {
        // Arrange
        const priority = TaskPriority.urgent;
        final taskData = [
          TaskTableData(
            id: 'urgent-1',
            title: 'Urgent Task 1',
            createdAt: DateTime.now(),
            priority: priority.name,
            status: TaskStatus.pending.name,
            tags: '[]',
            isPinned: false,
          ),
        ];

        when(mockTaskDao.getTasksByPriority(priority.name)).thenAnswer((_) async => taskData);

        // Act
        final result = await repository.getTasksByPriority(priority);

        // Assert
        expect(result, hasLength(1));
        expect(result.first.priority, priority);
      });
    });

    group('getTasksDueToday', () {
      test('should return tasks due today', () async {
        // Arrange
        final today = DateTime.now();
        final taskData = [
          TaskTableData(
            id: 'due-today',
            title: 'Due Today Task',
            createdAt: today.subtract(const Duration(days: 1)),
            dueDate: today,
            priority: TaskPriority.medium.name,
            status: TaskStatus.pending.name,
            tags: '[]',
            isPinned: false,
          ),
        ];

        when(mockTaskDao.getTasksDueToday()).thenAnswer((_) async => taskData);

        // Act
        final result = await repository.getTasksDueToday();

        // Assert
        expect(result, hasLength(1));
        expect(result.first.isDueToday, true);
      });
    });

    group('getOverdueTasks', () {
      test('should return overdue tasks', () async {
        // Arrange
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final taskData = [
          TaskTableData(
            id: 'overdue',
            title: 'Overdue Task',
            createdAt: yesterday.subtract(const Duration(days: 1)),
            dueDate: yesterday,
            priority: TaskPriority.medium.name,
            status: TaskStatus.pending.name,
            tags: '[]',
            isPinned: false,
          ),
        ];

        when(mockTaskDao.getOverdueTasks()).thenAnswer((_) async => taskData);

        // Act
        final result = await repository.getOverdueTasks();

        // Assert
        expect(result, hasLength(1));
        expect(result.first.isOverdue, true);
      });
    });

    group('searchTasks', () {
      test('should return tasks matching search query', () async {
        // Arrange
        const query = 'important meeting';
        final taskData = [
          TaskTableData(
            id: 'search-result',
            title: 'Important meeting with client',
            description: 'Discuss quarterly results',
            createdAt: DateTime.now(),
            priority: TaskPriority.high.name,
            status: TaskStatus.pending.name,
            tags: '["work"]',
            isPinned: false,
          ),
        ];

        when(mockTaskDao.searchTasks(query)).thenAnswer((_) async => taskData);

        // Act
        final result = await repository.searchTasks(query);

        // Assert
        expect(result, hasLength(1));
        expect(result.first.title.toLowerCase(), contains('important'));
        expect(result.first.title.toLowerCase(), contains('meeting'));
      });

      test('should return empty list for no matches', () async {
        // Arrange
        const query = 'nonexistent task';
        when(mockTaskDao.searchTasks(query)).thenAnswer((_) async => []);

        // Act
        final result = await repository.searchTasks(query);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getTasksByDateRange', () {
      test('should return tasks within date range', () async {
        // Arrange
        final startDate = DateTime.now();
        final endDate = startDate.add(const Duration(days: 7));
        final taskData = [
          TaskTableData(
            id: 'in-range',
            title: 'Task in range',
            createdAt: DateTime.now(),
            dueDate: startDate.add(const Duration(days: 3)),
            priority: TaskPriority.medium.name,
            status: TaskStatus.pending.name,
            tags: '[]',
            isPinned: false,
          ),
        ];

        when(mockTaskDao.getTasksByDateRange(startDate, endDate)).thenAnswer((_) async => taskData);

        // Act
        final result = await repository.getTasksByDateRange(startDate, endDate);

        // Assert
        expect(result, hasLength(1));
        expect(result.first.dueDate, isNotNull);
        expect(result.first.dueDate!.isAfter(startDate.subtract(const Duration(days: 1))), true);
        expect(result.first.dueDate!.isBefore(endDate.add(const Duration(days: 1))), true);
      });
    });

    group('watchAllTasks', () {
      test('should return stream of tasks', () async {
        // Arrange
        final taskData = [
          TaskTableData(
            id: 'stream-task',
            title: 'Stream Task',
            createdAt: DateTime.now(),
            priority: TaskPriority.medium.name,
            status: TaskStatus.pending.name,
            tags: '[]',
            isPinned: false,
          ),
        ];

        when(mockTaskDao.watchAllTasks()).thenAnswer((_) => Stream.value(taskData));

        // Act
        final stream = repository.watchAllTasks();
        final result = await stream.first;

        // Assert
        expect(result, hasLength(1));
        expect(result.first.id, 'stream-task');
      });

      test('should handle stream errors', () async {
        // Arrange
        when(mockTaskDao.watchAllTasks()).thenAnswer((_) => Stream.error(Exception('Stream error')));

        // Act
        final stream = repository.watchAllTasks();

        // Assert
        expect(stream, emitsError(isA<Exception>()));
      });
    });

    group('data conversion', () {
      test('should convert TaskModel to TaskTableData correctly', () async {
        // Arrange
        final task = TaskModel(
          id: 'conversion-test',
          title: 'Conversion Task',
          description: 'Test conversion',
          createdAt: DateTime.now(),
          priority: TaskPriority.high,
          status: TaskStatus.inProgress,
          tags: ['test', 'conversion'],
          isPinned: true,
          estimatedDuration: 60,
        );

        TaskTableData? capturedData;
        when(mockTaskDao.createTask(any)).thenAnswer((invocation) async {
          capturedData = invocation.positionalArguments[0] as TaskTableData;
        });

        // Act
        await repository.createTask(task);

        // Assert
        expect(capturedData, isNotNull);
        expect(capturedData!.id, task.id);
        expect(capturedData!.title, task.title);
        expect(capturedData!.description, task.description);
        expect(capturedData!.priority, task.priority.name);
        expect(capturedData!.status, task.status.name);
        expect(capturedData!.isPinned, task.isPinned);
        expect(capturedData!.estimatedDuration, task.estimatedDuration);
        
        // Test tags conversion
        expect(capturedData!.tags, contains('test'));
        expect(capturedData!.tags, contains('conversion'));
      });

      test('should convert TaskTableData to TaskModel correctly', () async {
        // Arrange
        final now = DateTime.now();
        final taskData = TaskTableData(
          id: 'data-conversion',
          title: 'Data Task',
          description: 'Convert from data',
          createdAt: now,
          updatedAt: now.add(const Duration(minutes: 5)),
          dueDate: now.add(const Duration(days: 1)),
          priority: TaskPriority.urgent.name,
          status: TaskStatus.completed.name,
          tags: '["urgent", "important"]',
          locationTrigger: 'Office',
          projectId: 'project-1',
          dependencies: '["dep-1", "dep-2"]',
          metadata: '{"key": "value"}',
          isPinned: true,
          estimatedDuration: 120,
          actualDuration: 90,
        );

        when(mockTaskDao.getTaskById('data-conversion')).thenAnswer((_) async => taskData);

        // Act
        final result = await repository.getTaskById('data-conversion');

        // Assert
        expect(result, isNotNull);
        expect(result!.id, taskData.id);
        expect(result.title, taskData.title);
        expect(result.description, taskData.description);
        expect(result.createdAt, taskData.createdAt);
        expect(result.updatedAt, taskData.updatedAt);
        expect(result.dueDate, taskData.dueDate);
        expect(result.priority, TaskPriority.urgent);
        expect(result.status, TaskStatus.completed);
        expect(result.tags, contains('urgent'));
        expect(result.tags, contains('important'));
        expect(result.locationTrigger, taskData.locationTrigger);
        expect(result.projectId, taskData.projectId);
        expect(result.dependencies, contains('dep-1'));
        expect(result.dependencies, contains('dep-2'));
        expect(result.metadata['key'], 'value');
        expect(result.isPinned, taskData.isPinned);
        expect(result.estimatedDuration, taskData.estimatedDuration);
        expect(result.actualDuration, taskData.actualDuration);
      });

      test('should handle null and empty values in conversion', () async {
        // Arrange
        final taskData = TaskTableData(
          id: 'minimal-task',
          title: 'Minimal Task',
          createdAt: DateTime.now(),
          priority: TaskPriority.medium.name,
          status: TaskStatus.pending.name,
          tags: '[]',
          isPinned: false,
          // All other fields are null
        );

        when(mockTaskDao.getTaskById('minimal-task')).thenAnswer((_) async => taskData);

        // Act
        final result = await repository.getTaskById('minimal-task');

        // Assert
        expect(result, isNotNull);
        expect(result!.description, isNull);
        expect(result.dueDate, isNull);
        expect(result.tags, isEmpty);
        expect(result.dependencies, isEmpty);
        expect(result.metadata, isEmpty);
        expect(result.subTasks, isEmpty);
      });
    });
  });
}