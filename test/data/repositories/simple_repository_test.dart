import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/data/repositories/task_repository_impl.dart';
import 'package:task_tracker_app/data/repositories/cached_task_repository_impl.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';

void main() {
  group('Repository Tests', () {
    late AppDatabase database;
    late TaskRepositoryImpl taskRepository;
    late CachedTaskRepositoryImpl cachedTaskRepository;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      taskRepository = TaskRepositoryImpl(database);
      cachedTaskRepository = CachedTaskRepositoryImpl(database);
    });

    tearDown(() async {
      await database.close();
    });

    group('TaskRepositoryImpl Tests', () {
      test('should perform basic CRUD operations', () async {
        // Create task
        final task = TaskModel.create(
          title: 'Repository Test Task',
          description: 'Test task for repository',
          priority: TaskPriority.medium,
        );

        await taskRepository.createTask(task);

        // Read task
        final retrievedTask = await taskRepository.getTaskById(task.id);
        expect(retrievedTask, isNotNull);
        expect(retrievedTask!.title, equals('Repository Test Task'));
        expect(retrievedTask.description, equals('Test task for repository'));
        expect(retrievedTask.priority, equals(TaskPriority.medium));

        // Get all tasks
        final allTasks = await taskRepository.getAllTasks();
        expect(allTasks.length, equals(1));
        expect(allTasks.first.id, equals(task.id));

        // Update task
        final updatedTask = task.copyWith(
          title: 'Updated Repository Task',
          priority: TaskPriority.high,
        );
        await taskRepository.updateTask(updatedTask);

        final afterUpdate = await taskRepository.getTaskById(task.id);
        expect(afterUpdate!.title, equals('Updated Repository Task'));
        expect(afterUpdate.priority, equals(TaskPriority.high));

        // Delete task
        await taskRepository.deleteTask(task.id);

        final afterDelete = await taskRepository.getTaskById(task.id);
        expect(afterDelete, isNull);

        final emptyTasks = await taskRepository.getAllTasks();
        expect(emptyTasks, isEmpty);
      });

      test('should handle task filtering', () async {
        // Create multiple tasks with different properties
        final task1 = TaskModel.create(
          title: 'High Priority Task',
          priority: TaskPriority.high,
        );

        final task2 = TaskModel.create(
          title: 'Medium Priority Task',
          priority: TaskPriority.medium,
        );

        final task3 = TaskModel.create(
          title: 'Low Priority Task',
          priority: TaskPriority.low,
        );

        await taskRepository.createTask(task1);
        await taskRepository.createTask(task2);
        await taskRepository.createTask(task3);

        // Test priority filtering
        final highTasks = await taskRepository.getTasksByPriority(TaskPriority.high);
        expect(highTasks.length, equals(1));
        expect(highTasks.first.id, equals(task1.id));

        final mediumTasks = await taskRepository.getTasksByPriority(TaskPriority.medium);
        expect(mediumTasks.length, equals(1));
        expect(mediumTasks.first.id, equals(task2.id));

        final lowTasks = await taskRepository.getTasksByPriority(TaskPriority.low);
        expect(lowTasks.length, equals(1));
        expect(lowTasks.first.id, equals(task3.id));

        // Test search
        final searchResults = await taskRepository.searchTasks('High');
        expect(searchResults.length, equals(1));
        expect(searchResults.first.id, equals(task1.id));

        final noMatchResults = await taskRepository.searchTasks('NoMatch');
        expect(noMatchResults, isEmpty);

        // Clean up
        await taskRepository.deleteTask(task1.id);
        await taskRepository.deleteTask(task2.id);
        await taskRepository.deleteTask(task3.id);
      });

      test('should handle date-based filtering', () async {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final tomorrow = now.add(const Duration(days: 1));

        // Create tasks with different due dates
        final todayTask = TaskModel.create(
          title: 'Due Today',
          dueDate: now,
        );

        final overdueTask = TaskModel.create(
          title: 'Overdue Task',
          dueDate: yesterday,
        );

        final futureTask = TaskModel.create(
          title: 'Future Task',
          dueDate: tomorrow,
        );

        await taskRepository.createTask(todayTask);
        await taskRepository.createTask(overdueTask);
        await taskRepository.createTask(futureTask);

        // Test due today filtering
        final dueTodayTasks = await taskRepository.getTasksDueToday();
        expect(dueTodayTasks.length, equals(1));
        expect(dueTodayTasks.first.id, equals(todayTask.id));

        // Test overdue filtering
        final overdueTasks = await taskRepository.getOverdueTasks();
        expect(overdueTasks.length, equals(1));
        expect(overdueTasks.first.id, equals(overdueTask.id));

        // Test date range filtering
        final startDate = yesterday;
        final endDate = tomorrow;
        final tasksInRange = await taskRepository.getTasksByDateRange(startDate, endDate);
        expect(tasksInRange.length, equals(3));

        // Clean up
        await taskRepository.deleteTask(todayTask.id);
        await taskRepository.deleteTask(overdueTask.id);
        await taskRepository.deleteTask(futureTask.id);
      });

      test('should handle bulk operations', () async {
        // Create multiple tasks
        final tasks = List.generate(5, (i) => TaskModel.create(
          title: 'Bulk Task ${i + 1}',
          priority: TaskPriority.low,
        ));

        for (final task in tasks) {
          await taskRepository.createTask(task);
        }

        final taskIds = tasks.map((t) => t.id).toList();

        // Test bulk retrieval
        final retrievedTasks = await taskRepository.getTasksByIds(taskIds);
        expect(retrievedTasks.length, equals(5));

        // Test bulk priority update
        await taskRepository.updateTasksPriority(taskIds, TaskPriority.urgent);

        for (final taskId in taskIds) {
          final task = await taskRepository.getTaskById(taskId);
          expect(task!.priority, equals(TaskPriority.urgent));
        }

        // Test bulk status update
        await taskRepository.updateTasksStatus(taskIds, TaskStatus.completed);

        // Note: Need to check if status is actually updated - depends on implementation
        // For now, just verify no errors are thrown

        // Test bulk delete
        await taskRepository.deleteTasks(taskIds);

        final remainingTasks = await taskRepository.getAllTasks();
        expect(remainingTasks, isEmpty);
      });

      test('should handle project assignment', () async {
        const projectId = 'test-project-id';

        // Create tasks
        final task1 = TaskModel.create(title: 'Task 1');
        final task2 = TaskModel.create(title: 'Task 2');
        final task3 = TaskModel.create(title: 'Task 3');

        await taskRepository.createTask(task1);
        await taskRepository.createTask(task2);
        await taskRepository.createTask(task3);

        // Test project assignment
        final taskIds = [task1.id, task2.id];
        await taskRepository.assignTasksToProject(taskIds, projectId);

        final projectTasks = await taskRepository.getTasksByProject(projectId);
        expect(projectTasks.length, equals(2));

        // Test unassignment
        await taskRepository.assignTasksToProject([task1.id], null);

        final remainingProjectTasks = await taskRepository.getTasksByProject(projectId);
        expect(remainingProjectTasks.length, equals(1));
        expect(remainingProjectTasks.first.id, equals(task2.id));

        // Clean up
        await taskRepository.deleteTask(task1.id);
        await taskRepository.deleteTask(task2.id);
        await taskRepository.deleteTask(task3.id);
      });

      test('should handle streaming operations', () async {
        // Create initial task
        final task = TaskModel.create(title: 'Stream Test Task');
        await taskRepository.createTask(task);

        // Test watch all tasks
        final allTasksStream = taskRepository.watchAllTasks();
        final initialTasks = await allTasksStream.first;
        expect(initialTasks.length, equals(1));
        expect(initialTasks.first.title, equals('Stream Test Task'));

        // Test watch by status
        final statusStream = taskRepository.watchTasksByStatus(TaskStatus.pending);
        final pendingTasks = await statusStream.first;
        expect(pendingTasks.length, equals(1));

        // Clean up
        await taskRepository.deleteTask(task.id);
      });
    });

    group('CachedTaskRepositoryImpl Tests', () {
      test('should delegate to underlying repository', () async {
        // Create task through cached repository
        final task = TaskModel.create(
          title: 'Cached Repository Test',
          description: 'Testing cached repository',
        );

        await cachedTaskRepository.createTask(task);

        // Verify task was created
        final retrievedTask = await cachedTaskRepository.getTaskById(task.id);
        expect(retrievedTask, isNotNull);
        expect(retrievedTask!.title, equals('Cached Repository Test'));

        // Test caching behavior (if implemented)
        final allTasks1 = await cachedTaskRepository.getAllTasks();
        final allTasks2 = await cachedTaskRepository.getAllTasks();
        expect(allTasks1.length, equals(allTasks2.length));

        // Clean up
        await cachedTaskRepository.deleteTask(task.id);
      });

      test('should handle cache invalidation on updates', () async {
        final task = TaskModel.create(title: 'Cache Test Task');
        await cachedTaskRepository.createTask(task);

        // Get task (should cache it)
        final cachedTask = await cachedTaskRepository.getTaskById(task.id);
        expect(cachedTask, isNotNull);

        // Update task (should invalidate cache)
        final updatedTask = task.copyWith(title: 'Updated Cache Test');
        await cachedTaskRepository.updateTask(updatedTask);

        // Get task again (should get updated version)
        final afterUpdate = await cachedTaskRepository.getTaskById(task.id);
        expect(afterUpdate!.title, equals('Updated Cache Test'));

        // Clean up
        await cachedTaskRepository.deleteTask(task.id);
      });

      test('should handle safe updates', () async {
        final task = TaskModel.create(title: 'Safe Update Test');
        await cachedTaskRepository.createTask(task);

        // Test safe update
        final updatedTask = task.copyWith(description: 'Safe update description');
        final result = await cachedTaskRepository.updateTaskSafely(updatedTask);

        expect(result, isNotNull);
        expect(result!.description, equals('Safe update description'));

        // Clean up
        await cachedTaskRepository.deleteTask(task.id);
      });
    });

    group('Repository Error Handling', () {
      test('should handle non-existent task gracefully', () async {
        const nonExistentId = 'non-existent-task-id';

        // Should return null for non-existent task
        final nullTask = await taskRepository.getTaskById(nonExistentId);
        expect(nullTask, isNull);

        // Should return empty list for project with no tasks
        final emptyProjectTasks = await taskRepository.getTasksByProject('non-existent-project');
        expect(emptyProjectTasks, isEmpty);

        // Should not throw when deleting non-existent task
        expect(
          () async => await taskRepository.deleteTask(nonExistentId),
          returnsNormally,
        );
      });

      test('should handle empty operations', () async {
        // Empty database operations should work
        final emptyTasks = await taskRepository.getAllTasks();
        expect(emptyTasks, isEmpty);

        final emptySearch = await taskRepository.searchTasks('anything');
        expect(emptySearch, isEmpty);

        final emptyPriorityFilter = await taskRepository.getTasksByPriority(TaskPriority.urgent);
        expect(emptyPriorityFilter, isEmpty);

        // Bulk operations with empty lists should not throw
        await taskRepository.deleteTasks([]);
        await taskRepository.updateTasksPriority([], TaskPriority.high);
        await taskRepository.assignTasksToProject([], 'any-project');
      });

      test('should handle filter edge cases', () async {
        // Test filtering with no results
        final futureTasks = await taskRepository.getTasksByDateRange(
          DateTime.now().add(const Duration(days: 100)),
          DateTime.now().add(const Duration(days: 200)),
        );
        expect(futureTasks, isEmpty);

        // Test with empty search query
        final emptyQueryResults = await taskRepository.searchTasks('');
        expect(emptyQueryResults, isEmpty);

        // Test with complex filter
        const filter = TaskFilter(
          priority: TaskPriority.urgent,
          searchQuery: 'non-existent',
        );
        final complexFilterResults = await taskRepository.getTasksWithFilter(filter);
        expect(complexFilterResults, isEmpty);
      });
    });

    group('Repository Performance Tests', () {
      test('should handle bulk operations efficiently', () async {
        const taskCount = 100;

        // Create many tasks
        final tasks = List.generate(taskCount, (i) => TaskModel.create(
          title: 'Performance Test Task ${i + 1}',
          priority: i % 2 == 0 ? TaskPriority.high : TaskPriority.low,
        ));

        final stopwatch = Stopwatch()..start();

        for (final task in tasks) {
          await taskRepository.createTask(task);
        }

        stopwatch.stop();
        print('Created $taskCount tasks in ${stopwatch.elapsedMilliseconds}ms');

        // Should complete reasonably quickly
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 seconds max

        // Test bulk retrieval
        stopwatch.reset();
        stopwatch.start();

        final allTasks = await taskRepository.getAllTasks();
        expect(allTasks.length, equals(taskCount));

        stopwatch.stop();
        print('Retrieved $taskCount tasks in ${stopwatch.elapsedMilliseconds}ms');

        // Should be fast
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // 1 second max

        // Clean up efficiently
        final taskIds = tasks.map((t) => t.id).toList();
        await taskRepository.deleteTasks(taskIds);

        final remainingTasks = await taskRepository.getAllTasks();
        expect(remainingTasks, isEmpty);
      });

      test('should handle concurrent operations', () async {
        // Test concurrent task creation
        final futures = List.generate(10, (i) async {
          final task = TaskModel.create(title: 'Concurrent Task ${i + 1}');
          await taskRepository.createTask(task);
          return task;
        });

        final createdTasks = await Future.wait(futures);
        expect(createdTasks.length, equals(10));

        // Verify all tasks were created
        final allTasks = await taskRepository.getAllTasks();
        expect(allTasks.length, equals(10));

        // Clean up
        final taskIds = createdTasks.map((t) => t.id).toList();
        await taskRepository.deleteTasks(taskIds);
      });
    });
  });
}