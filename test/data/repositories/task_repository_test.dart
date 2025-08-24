import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/services/database/daos/task_dao.dart';
import 'package:task_tracker_app/data/repositories/task_repository_impl.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';

import 'task_repository_test.mocks.dart';

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

    group('Basic CRUD Operations', () {
      test('should get all tasks', () async {
        // Arrange
        final expectedTasks = [
          TaskModel.create(title: 'Task 1'),
          TaskModel.create(title: 'Task 2'),
        ];
        when(mockTaskDao.getAllTasks()).thenAnswer((_) async => expectedTasks);

        // Act
        final result = await repository.getAllTasks();

        // Assert
        expect(result, equals(expectedTasks));
        verify(mockTaskDao.getAllTasks()).called(1);
      });

      test('should get task by id', () async {
        // Arrange
        const taskId = 'test-task-id';
        final expectedTask = TaskModel.create(title: 'Test Task');
        when(mockTaskDao.getTaskById(taskId)).thenAnswer((_) async => expectedTask);

        // Act
        final result = await repository.getTaskById(taskId);

        // Assert
        expect(result, equals(expectedTask));
        verify(mockTaskDao.getTaskById(taskId)).called(1);
      });

      test('should return null for non-existent task', () async {
        // Arrange
        const nonExistentId = 'non-existent-id';
        when(mockTaskDao.getTaskById(nonExistentId)).thenAnswer((_) async => null);

        // Act
        final result = await repository.getTaskById(nonExistentId);

        // Assert
        expect(result, isNull);
        verify(mockTaskDao.getTaskById(nonExistentId)).called(1);
      });

      test('should create task', () async {
        // Arrange
        final task = TaskModel.create(title: 'New Task');
        when(mockTaskDao.createTask(task)).thenAnswer((_) async => {});

        // Act
        await repository.createTask(task);

        // Assert
        verify(mockTaskDao.createTask(task)).called(1);
      });

      test('should update task', () async {
        // Arrange
        final task = TaskModel.create(title: 'Updated Task');
        when(mockTaskDao.updateTask(task)).thenAnswer((_) async => {});

        // Act
        await repository.updateTask(task);

        // Assert
        verify(mockTaskDao.updateTask(task)).called(1);
      });

      test('should update task safely', () async {
        // Arrange
        final task = TaskModel.create(title: 'Safe Update Task');
        final updatedTask = task.copyWith(description: 'Updated description');
        when(mockTaskDao.updateTaskSafely(task)).thenAnswer((_) async => updatedTask);

        // Act
        final result = await repository.updateTaskSafely(task);

        // Assert
        expect(result, equals(updatedTask));
        verify(mockTaskDao.updateTaskSafely(task)).called(1);
      });

      test('should delete task', () async {
        // Arrange
        const taskId = 'task-to-delete';
        when(mockTaskDao.deleteTask(taskId)).thenAnswer((_) async => {});

        // Act
        await repository.deleteTask(taskId);

        // Assert
        verify(mockTaskDao.deleteTask(taskId)).called(1);
      });
    });

    group('Filtering Operations', () {
      test('should get tasks by status', () async {
        // Arrange
        const status = TaskStatus.inProgress;
        final expectedTasks = [
          TaskModel.create(title: 'In Progress Task 1'),
          TaskModel.create(title: 'In Progress Task 2'),
        ];
        when(mockTaskDao.getTasksByStatus(status)).thenAnswer((_) async => expectedTasks);

        // Act
        final result = await repository.getTasksByStatus(status);

        // Assert
        expect(result, equals(expectedTasks));
        verify(mockTaskDao.getTasksByStatus(status)).called(1);
      });

      test('should get tasks by priority', () async {
        // Arrange
        const priority = TaskPriority.high;
        final expectedTasks = [
          TaskModel.create(title: 'High Priority Task', priority: priority),
        ];
        when(mockTaskDao.getTasksByPriority(priority)).thenAnswer((_) async => expectedTasks);

        // Act
        final result = await repository.getTasksByPriority(priority);

        // Assert
        expect(result, equals(expectedTasks));
        verify(mockTaskDao.getTasksByPriority(priority)).called(1);
      });

      test('should get tasks due today', () async {
        // Arrange
        final expectedTasks = [
          TaskModel.create(title: 'Due Today Task', dueDate: DateTime.now()),
        ];
        when(mockTaskDao.getTasksDueToday()).thenAnswer((_) async => expectedTasks);

        // Act
        final result = await repository.getTasksDueToday();

        // Assert
        expect(result, equals(expectedTasks));
        verify(mockTaskDao.getTasksDueToday()).called(1);
      });

      test('should get overdue tasks', () async {
        // Arrange
        final expectedTasks = [
          TaskModel.create(
            title: 'Overdue Task',
            dueDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];
        when(mockTaskDao.getOverdueTasks()).thenAnswer((_) async => expectedTasks);

        // Act
        final result = await repository.getOverdueTasks();

        // Assert
        expect(result, equals(expectedTasks));
        verify(mockTaskDao.getOverdueTasks()).called(1);
      });

      test('should get tasks by date range', () async {
        // Arrange
        final startDate = DateTime.now();
        final endDate = DateTime.now().add(const Duration(days: 7));
        final expectedTasks = [
          TaskModel.create(title: 'Task in Range', dueDate: startDate.add(const Duration(days: 1))),
        ];
        when(mockTaskDao.getTasksByDateRange(startDate, endDate)).thenAnswer((_) async => expectedTasks);

        // Act
        final result = await repository.getTasksByDateRange(startDate, endDate);

        // Assert
        expect(result, equals(expectedTasks));
        verify(mockTaskDao.getTasksByDateRange(startDate, endDate)).called(1);
      });

      test('should get tasks by project', () async {
        // Arrange
        const projectId = 'test-project-id';
        final expectedTasks = [
          TaskModel.create(title: 'Project Task', projectId: projectId),
        ];
        when(mockTaskDao.getTasksByProject(projectId)).thenAnswer((_) async => expectedTasks);

        // Act
        final result = await repository.getTasksByProject(projectId);

        // Assert
        expect(result, equals(expectedTasks));
        verify(mockTaskDao.getTasksByProject(projectId)).called(1);
      });

      test('should search tasks', () async {
        // Arrange
        const query = 'search query';
        final expectedTasks = [
          TaskModel.create(title: 'Task matching search query'),
        ];
        when(mockTaskDao.searchTasks(query)).thenAnswer((_) async => expectedTasks);

        // Act
        final result = await repository.searchTasks(query);

        // Assert
        expect(result, equals(expectedTasks));
        verify(mockTaskDao.searchTasks(query)).called(1);
      });

      test('should get tasks with filter', () async {
        // Arrange
        const filter = TaskFilter(
          priority: TaskPriority.high,
          searchQuery: 'test',
        );
        final expectedTasks = [
          TaskModel.create(title: 'Filtered Task', priority: TaskPriority.high),
        ];
        when(mockTaskDao.getTasksWithFilter(filter)).thenAnswer((_) async => expectedTasks);

        // Act
        final result = await repository.getTasksWithFilter(filter);

        // Assert
        expect(result, equals(expectedTasks));
        verify(mockTaskDao.getTasksWithFilter(filter)).called(1);
      });
    });

    group('Streaming Operations', () {
      test('should watch all tasks', () async {
        // Arrange
        final expectedTasks = [
          TaskModel.create(title: 'Watched Task 1'),
          TaskModel.create(title: 'Watched Task 2'),
        ];
        when(mockTaskDao.watchAllTasks()).thenAnswer((_) => Stream.value(expectedTasks));

        // Act
        final stream = repository.watchAllTasks();

        // Assert
        expect(await stream.first, equals(expectedTasks));
        verify(mockTaskDao.watchAllTasks()).called(1);
      });

      test('should watch tasks by status', () async {
        // Arrange
        const status = TaskStatus.completed;
        final expectedTasks = [
          TaskModel.create(title: 'Completed Task'),
        ];
        when(mockTaskDao.watchTasksByStatus(status)).thenAnswer((_) => Stream.value(expectedTasks));

        // Act
        final stream = repository.watchTasksByStatus(status);

        // Assert
        expect(await stream.first, equals(expectedTasks));
        verify(mockTaskDao.watchTasksByStatus(status)).called(1);
      });

      test('should watch tasks by project', () async {
        // Arrange
        const projectId = 'watch-project-id';
        final expectedTasks = [
          TaskModel.create(title: 'Project Task', projectId: projectId),
        ];
        when(mockTaskDao.watchTasksByProject(projectId)).thenAnswer((_) => Stream.value(expectedTasks));

        // Act
        final stream = repository.watchTasksByProject(projectId);

        // Assert
        expect(await stream.first, equals(expectedTasks));
        verify(mockTaskDao.watchTasksByProject(projectId)).called(1);
      });
    });

    group('Bulk Operations', () {
      test('should get multiple tasks by IDs', () async {
        // Arrange
        final taskIds = ['id1', 'id2', 'id3'];
        final expectedTasks = [
          TaskModel.create(title: 'Task 1'),
          TaskModel.create(title: 'Task 2'),
          TaskModel.create(title: 'Task 3'),
        ];
        when(mockTaskDao.getTasksByIds(taskIds)).thenAnswer((_) async => expectedTasks);

        // Act
        final result = await repository.getTasksByIds(taskIds);

        // Assert
        expect(result, equals(expectedTasks));
        verify(mockTaskDao.getTasksByIds(taskIds)).called(1);
      });

      test('should get tasks with dependency', () async {
        // Arrange
        const dependencyId = 'dependency-task-id';
        final expectedTasks = [
          TaskModel.create(title: 'Dependent Task'),
        ];
        when(mockTaskDao.getTasksWithDependency(dependencyId)).thenAnswer((_) async => expectedTasks);

        // Act
        final result = await repository.getTasksWithDependency(dependencyId);

        // Assert
        expect(result, equals(expectedTasks));
        verify(mockTaskDao.getTasksWithDependency(dependencyId)).called(1);
      });

      test('should bulk delete tasks', () async {
        // Arrange
        final taskIds = ['id1', 'id2', 'id3'];
        when(mockTaskDao.deleteTasks(taskIds)).thenAnswer((_) async => {});

        // Act
        await repository.deleteTasks(taskIds);

        // Assert
        verify(mockTaskDao.deleteTasks(taskIds)).called(1);
      });

      test('should bulk update tasks status', () async {
        // Arrange
        final taskIds = ['id1', 'id2'];
        const newStatus = TaskStatus.completed;
        when(mockTaskDao.updateTasksStatus(taskIds, newStatus)).thenAnswer((_) async => {});

        // Act
        await repository.updateTasksStatus(taskIds, newStatus);

        // Assert
        verify(mockTaskDao.updateTasksStatus(taskIds, newStatus)).called(1);
      });

      test('should bulk update tasks priority', () async {
        // Arrange
        final taskIds = ['id1', 'id2'];
        const newPriority = TaskPriority.urgent;
        when(mockTaskDao.updateTasksPriority(taskIds, newPriority)).thenAnswer((_) async => {});

        // Act
        await repository.updateTasksPriority(taskIds, newPriority);

        // Assert
        verify(mockTaskDao.updateTasksPriority(taskIds, newPriority)).called(1);
      });

      test('should bulk assign tasks to project', () async {
        // Arrange
        final taskIds = ['id1', 'id2'];
        const projectId = 'new-project-id';
        when(mockTaskDao.assignTasksToProject(taskIds, projectId)).thenAnswer((_) async => {});

        // Act
        await repository.assignTasksToProject(taskIds, projectId);

        // Assert
        verify(mockTaskDao.assignTasksToProject(taskIds, projectId)).called(1);
      });

      test('should bulk unassign tasks from project', () async {
        // Arrange
        final taskIds = ['id1', 'id2'];
        when(mockTaskDao.assignTasksToProject(taskIds, null)).thenAnswer((_) async => {});

        // Act
        await repository.assignTasksToProject(taskIds, null);

        // Assert
        verify(mockTaskDao.assignTasksToProject(taskIds, null)).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle database exceptions during getAllTasks', () async {
        // Arrange
        when(mockTaskDao.getAllTasks()).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () async => await repository.getAllTasks(),
          throwsException,
        );
      });

      test('should handle database exceptions during createTask', () async {
        // Arrange
        final task = TaskModel.create(title: 'Error Task');
        when(mockTaskDao.createTask(task)).thenThrow(Exception('Create error'));

        // Act & Assert
        expect(
          () async => await repository.createTask(task),
          throwsException,
        );
      });

      test('should handle database exceptions during updateTask', () async {
        // Arrange
        final task = TaskModel.create(title: 'Error Task');
        when(mockTaskDao.updateTask(task)).thenThrow(Exception('Update error'));

        // Act & Assert
        expect(
          () async => await repository.updateTask(task),
          throwsException,
        );
      });

      test('should handle database exceptions during deleteTask', () async {
        // Arrange
        const taskId = 'error-task-id';
        when(mockTaskDao.deleteTask(taskId)).thenThrow(Exception('Delete error'));

        // Act & Assert
        expect(
          () async => await repository.deleteTask(taskId),
          throwsException,
        );
      });
    });

    group('Edge Cases', () {
      test('should handle empty task list', () async {
        // Arrange
        when(mockTaskDao.getAllTasks()).thenAnswer((_) async => []);

        // Act
        final result = await repository.getAllTasks();

        // Assert
        expect(result, isEmpty);
        verify(mockTaskDao.getAllTasks()).called(1);
      });

      test('should handle empty search results', () async {
        // Arrange
        const query = 'no-match-query';
        when(mockTaskDao.searchTasks(query)).thenAnswer((_) async => []);

        // Act
        final result = await repository.searchTasks(query);

        // Assert
        expect(result, isEmpty);
        verify(mockTaskDao.searchTasks(query)).called(1);
      });

      test('should handle empty bulk operations', () async {
        // Arrange
        final emptyIds = <String>[];
        when(mockTaskDao.getTasksByIds(emptyIds)).thenAnswer((_) async => []);

        // Act
        final result = await repository.getTasksByIds(emptyIds);

        // Assert
        expect(result, isEmpty);
        verify(mockTaskDao.getTasksByIds(emptyIds)).called(1);
      });
    });
  });

  group('TaskRepositoryImpl Integration Tests', () {
    late TaskRepositoryImpl repository;
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = TaskRepositoryImpl(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('should perform end-to-end task operations', () async {
      // Create tasks
      final task1 = TaskModel.create(
        title: 'Integration Test Task 1',
        description: 'Test description',
        priority: TaskPriority.high,
      );
      final task2 = TaskModel.create(
        title: 'Integration Test Task 2',
        priority: TaskPriority.medium,
      );

      await repository.createTask(task1);
      await repository.createTask(task2);

      // Retrieve all tasks
      final allTasks = await repository.getAllTasks();
      expect(allTasks.length, equals(2));

      // Get by ID
      final retrievedTask = await repository.getTaskById(task1.id);
      expect(retrievedTask, isNotNull);
      expect(retrievedTask!.title, equals('Integration Test Task 1'));

      // Update task
      final updatedTask = task1.copyWith(description: 'Updated description');
      await repository.updateTask(updatedTask);
      final retrieved = await repository.getTaskById(task1.id);
      expect(retrieved!.description, equals('Updated description'));

      // Filter by priority
      final highPriorityTasks = await repository.getTasksByPriority(TaskPriority.high);
      expect(highPriorityTasks.length, equals(1));
      expect(highPriorityTasks.first.priority, equals(TaskPriority.high));

      // Delete task
      await repository.deleteTask(task2.id);
      final remainingTasks = await repository.getAllTasks();
      expect(remainingTasks.length, equals(1));
      expect(remainingTasks.first.id, equals(task1.id));
    });

    test('should handle streaming operations', () async {
      // Create initial task
      final task = TaskModel.create(title: 'Stream Test Task');
      await repository.createTask(task);

      // Watch all tasks
      final stream = repository.watchAllTasks();
      final initialTasks = await stream.first;
      expect(initialTasks.length, equals(1));
      expect(initialTasks.first.title, equals('Stream Test Task'));

      // The stream should continue to emit as tasks change
      // This would require more complex setup for real streaming tests
    });
  });
}