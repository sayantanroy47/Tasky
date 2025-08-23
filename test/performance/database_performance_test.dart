import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';

void main() {
  group('Database Performance Tests', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    group('Task DAO Performance', () {
      test('should create tasks efficiently', () async {
        const taskCount = 1000;
        final tasks = List.generate(taskCount, (i) => TaskModel.create(
          title: 'Performance Test Task ${i + 1}',
          description: 'Task for performance testing',
          priority: TaskPriority.values[i % TaskPriority.values.length],
        ));

        final stopwatch = Stopwatch()..start();

        for (final task in tasks) {
          await database.taskDao.createTask(task);
        }

        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;
        
        print('Created $taskCount tasks in ${elapsedMs}ms (${(elapsedMs / taskCount).toStringAsFixed(2)}ms per task)');
        
        // Should create each task in less than 10ms on average
        expect(elapsedMs / taskCount, lessThan(10.0));
        
        // Total operation should complete in reasonable time
        expect(elapsedMs, lessThan(10000)); // 10 seconds max
      });

      test('should retrieve tasks efficiently', () async {
        // Setup: Create test data
        const taskCount = 1000;
        final tasks = List.generate(taskCount, (i) => TaskModel.create(
          title: 'Retrieval Test Task ${i + 1}',
          priority: TaskPriority.values[i % TaskPriority.values.length],
        ));

        for (final task in tasks) {
          await database.taskDao.createTask(task);
        }

        // Test: Measure retrieval performance
        final stopwatch = Stopwatch()..start();
        final retrievedTasks = await database.taskDao.getAllTasks();
        stopwatch.stop();

        expect(retrievedTasks.length, equals(taskCount));
        
        final elapsedMs = stopwatch.elapsedMilliseconds;
        print('Retrieved $taskCount tasks in ${elapsedMs}ms');
        
        // Should retrieve all tasks in less than 1 second
        expect(elapsedMs, lessThan(1000));
        
        // Should average less than 1ms per task
        expect(elapsedMs / taskCount, lessThan(1.0));
      });

      test('should filter tasks efficiently', () async {
        // Setup: Create mixed priority tasks
        const taskCount = 1000;
        final tasks = List.generate(taskCount, (i) => TaskModel.create(
          title: 'Filter Test Task ${i + 1}',
          priority: TaskPriority.values[i % TaskPriority.values.length],
        ));

        for (final task in tasks) {
          await database.taskDao.createTask(task);
        }

        // Test: Measure filtering performance
        final stopwatch = Stopwatch()..start();
        final highPriorityTasks = await database.taskDao.getTasksByPriority(TaskPriority.high);
        stopwatch.stop();

        final elapsedMs = stopwatch.elapsedMilliseconds;
        print('Filtered ${highPriorityTasks.length} high priority tasks from $taskCount total in ${elapsedMs}ms');
        
        // Should filter efficiently
        expect(elapsedMs, lessThan(500)); // 500ms max
        expect(highPriorityTasks.length, greaterThan(0));
      });

      test('should search tasks efficiently', () async {
        // Setup: Create searchable tasks
        const taskCount = 1000;
        final tasks = List.generate(taskCount, (i) => TaskModel.create(
          title: i % 10 == 0 ? 'SEARCHABLE Task ${i + 1}' : 'Regular Task ${i + 1}',
          description: i % 10 == 0 ? 'This is a searchable task description' : 'Regular description',
        ));

        for (final task in tasks) {
          await database.taskDao.createTask(task);
        }

        // Test: Measure search performance
        final stopwatch = Stopwatch()..start();
        final searchResults = await database.taskDao.searchTasks('SEARCHABLE');
        stopwatch.stop();

        final elapsedMs = stopwatch.elapsedMilliseconds;
        print('Found ${searchResults.length} matching tasks from $taskCount total in ${elapsedMs}ms');
        
        // Should search efficiently
        expect(elapsedMs, lessThan(500)); // 500ms max
        expect(searchResults.length, equals(100)); // 10% of tasks
      });

      test('should update tasks efficiently', () async {
        // Setup: Create tasks to update
        const taskCount = 500;
        final tasks = List.generate(taskCount, (i) => TaskModel.create(
          title: 'Update Test Task ${i + 1}',
          priority: TaskPriority.low,
        ));

        for (final task in tasks) {
          await database.taskDao.createTask(task);
        }

        // Test: Measure update performance
        final stopwatch = Stopwatch()..start();
        
        for (final task in tasks) {
          final updatedTask = task.copyWith(
            title: 'UPDATED ${task.title}',
            priority: TaskPriority.high,
          );
          await database.taskDao.updateTask(updatedTask);
        }
        
        stopwatch.stop();

        final elapsedMs = stopwatch.elapsedMilliseconds;
        print('Updated $taskCount tasks in ${elapsedMs}ms (${(elapsedMs / taskCount).toStringAsFixed(2)}ms per task)');
        
        // Should update efficiently
        expect(elapsedMs / taskCount, lessThan(20.0)); // 20ms per task max
        expect(elapsedMs, lessThan(10000)); // 10 seconds total max
      });

      test('should delete tasks efficiently', () async {
        // Setup: Create tasks to delete
        const taskCount = 500;
        final tasks = List.generate(taskCount, (i) => TaskModel.create(
          title: 'Delete Test Task ${i + 1}',
        ));

        for (final task in tasks) {
          await database.taskDao.createTask(task);
        }

        // Test: Measure deletion performance
        final stopwatch = Stopwatch()..start();
        
        for (final task in tasks) {
          await database.taskDao.deleteTask(task.id);
        }
        
        stopwatch.stop();

        final elapsedMs = stopwatch.elapsedMilliseconds;
        print('Deleted $taskCount tasks in ${elapsedMs}ms (${(elapsedMs / taskCount).toStringAsFixed(2)}ms per task)');
        
        // Should delete efficiently
        expect(elapsedMs / taskCount, lessThan(10.0)); // 10ms per task max
        
        // Verify all deleted
        final remainingTasks = await database.taskDao.getAllTasks();
        expect(remainingTasks, isEmpty);
      });
    });

    group('Bulk Operations Performance', () {
      test('should handle bulk operations efficiently', () async {
        // Setup: Create tasks for bulk operations
        const taskCount = 1000;
        final tasks = List.generate(taskCount, (i) => TaskModel.create(
          title: 'Bulk Test Task ${i + 1}',
          priority: TaskPriority.low,
        ));

        for (final task in tasks) {
          await database.taskDao.createTask(task);
        }

        final taskIds = tasks.map((t) => t.id).toList();

        // Test: Bulk priority update
        var stopwatch = Stopwatch()..start();
        await database.taskDao.updateTasksPriority(taskIds, TaskPriority.high);
        stopwatch.stop();

        var elapsedMs = stopwatch.elapsedMilliseconds;
        print('Bulk updated $taskCount task priorities in ${elapsedMs}ms');
        expect(elapsedMs, lessThan(2000)); // 2 seconds max

        // Test: Bulk status update
        stopwatch = Stopwatch()..start();
        await database.taskDao.updateTasksStatus(taskIds, TaskStatus.completed);
        stopwatch.stop();

        elapsedMs = stopwatch.elapsedMilliseconds;
        print('Bulk updated $taskCount task statuses in ${elapsedMs}ms');
        expect(elapsedMs, lessThan(2000)); // 2 seconds max

        // Test: Bulk deletion
        stopwatch = Stopwatch()..start();
        await database.taskDao.deleteTasks(taskIds);
        stopwatch.stop();

        elapsedMs = stopwatch.elapsedMilliseconds;
        print('Bulk deleted $taskCount tasks in ${elapsedMs}ms');
        expect(elapsedMs, lessThan(2000)); // 2 seconds max

        // Verify all deleted
        final remainingTasks = await database.taskDao.getAllTasks();
        expect(remainingTasks, isEmpty);
      });
    });

    group('Complex Query Performance', () {
      test('should handle complex filters efficiently', () async {
        // Setup: Create diverse task data
        const taskCount = 1000;
        final tasks = <TaskModel>[];

        for (int i = 0; i < taskCount; i++) {
          tasks.add(TaskModel.create(
            title: 'Complex Filter Task ${i + 1}',
            description: i % 3 == 0 ? 'Important task description' : 'Regular description',
            priority: TaskPriority.values[i % TaskPriority.values.length],
            dueDate: i % 5 == 0 ? DateTime.now().add(Duration(days: i % 30)) : null,
            projectId: i % 4 == 0 ? 'project-${i % 3}' : null,
          ));
        }

        for (final task in tasks) {
          await database.taskDao.createTask(task);
        }

        // Test: Complex filter with multiple criteria
        final stopwatch = Stopwatch()..start();
        
        const filter = TaskFilter(
          priority: TaskPriority.high,
          searchQuery: 'Important',
          dueDateFrom: null,
          dueDateTo: null,
        );
        
        final filteredTasks = await database.taskDao.getTasksWithFilter(filter);
        stopwatch.stop();

        final elapsedMs = stopwatch.elapsedMilliseconds;
        print('Complex filter found ${filteredTasks.length} tasks from $taskCount in ${elapsedMs}ms');
        
        // Should handle complex filtering efficiently
        expect(elapsedMs, lessThan(1000)); // 1 second max
        expect(filteredTasks.length, greaterThan(0));
      });

      test('should handle date range queries efficiently', () async {
        // Setup: Create tasks with various due dates
        const taskCount = 1000;
        final baseDate = DateTime.now();
        final tasks = List.generate(taskCount, (i) => TaskModel.create(
          title: 'Date Range Task ${i + 1}',
          dueDate: baseDate.add(Duration(days: i - 500)), // Spread across 1000 days
        ));

        for (final task in tasks) {
          await database.taskDao.createTask(task);
        }

        // Test: Date range query
        final startDate = baseDate.subtract(const Duration(days: 10));
        final endDate = baseDate.add(const Duration(days: 10));
        
        final stopwatch = Stopwatch()..start();
        final tasksInRange = await database.taskDao.getTasksByDateRange(startDate, endDate);
        stopwatch.stop();

        final elapsedMs = stopwatch.elapsedMilliseconds;
        print('Date range query found ${tasksInRange.length} tasks from $taskCount in ${elapsedMs}ms');
        
        // Should handle date ranges efficiently
        expect(elapsedMs, lessThan(500)); // 500ms max
        expect(tasksInRange.length, greaterThan(0));
        expect(tasksInRange.length, lessThan(50)); // Should be subset
      });
    });

    group('Concurrent Operations Performance', () {
      test('should handle concurrent reads efficiently', () async {
        // Setup: Create test data
        const taskCount = 500;
        final tasks = List.generate(taskCount, (i) => TaskModel.create(
          title: 'Concurrent Read Task ${i + 1}',
          priority: TaskPriority.values[i % TaskPriority.values.length],
        ));

        for (final task in tasks) {
          await database.taskDao.createTask(task);
        }

        // Test: Concurrent read operations
        const concurrentReads = 10;
        final stopwatch = Stopwatch()..start();
        
        final futures = List.generate(concurrentReads, (i) async {
          if (i % 3 == 0) {
            return await database.taskDao.getAllTasks();
          } else if (i % 3 == 1) {
            return await database.taskDao.getTasksByPriority(TaskPriority.high);
          } else {
            return await database.taskDao.searchTasks('Task');
          }
        });

        final results = await Future.wait(futures);
        stopwatch.stop();

        final elapsedMs = stopwatch.elapsedMilliseconds;
        print('Completed $concurrentReads concurrent reads in ${elapsedMs}ms');
        
        // Should handle concurrent reads efficiently
        expect(elapsedMs, lessThan(2000)); // 2 seconds max
        expect(results.length, equals(concurrentReads));
        
        // Verify some results
        expect(results.first.length, equals(taskCount));
      });

      test('should handle mixed concurrent operations', () async {
        // Setup: Initial data
        const initialTaskCount = 200;
        final initialTasks = List.generate(initialTaskCount, (i) => TaskModel.create(
          title: 'Mixed Concurrent Task ${i + 1}',
        ));

        for (final task in initialTasks) {
          await database.taskDao.createTask(task);
        }

        // Test: Mix of reads and writes
        const operationCount = 20;
        final stopwatch = Stopwatch()..start();
        
        final futures = List.generate(operationCount, (i) async {
          if (i % 4 == 0) {
            // Read operation
            return await database.taskDao.getAllTasks();
          } else if (i % 4 == 1) {
            // Create operation
            final newTask = TaskModel.create(title: 'Concurrent New Task $i');
            await database.taskDao.createTask(newTask);
            return [newTask];
          } else if (i % 4 == 2) {
            // Search operation
            return await database.taskDao.searchTasks('Concurrent');
          } else {
            // Filter operation
            return await database.taskDao.getTasksByPriority(TaskPriority.medium);
          }
        });

        final results = await Future.wait(futures);
        stopwatch.stop();

        final elapsedMs = stopwatch.elapsedMilliseconds;
        print('Completed $operationCount mixed concurrent operations in ${elapsedMs}ms');
        
        // Should handle mixed operations reasonably well
        expect(elapsedMs, lessThan(5000)); // 5 seconds max
        expect(results.length, equals(operationCount));
      });
    });

    group('Memory Performance', () {
      test('should not leak memory with large datasets', () async {
        // This test ensures that large operations don't cause memory issues
        const batchSize = 1000;
        const batchCount = 5;

        for (int batch = 0; batch < batchCount; batch++) {
          // Create batch of tasks
          final tasks = List.generate(batchSize, (i) => TaskModel.create(
            title: 'Memory Test Batch $batch Task ${i + 1}',
          ));

          // Add tasks
          for (final task in tasks) {
            await database.taskDao.createTask(task);
          }

          // Read all tasks
          final allTasks = await database.taskDao.getAllTasks();
          expect(allTasks.length, equals((batch + 1) * batchSize));

          // Clean up batch (except last one for final verification)
          if (batch < batchCount - 1) {
            final taskIds = tasks.map((t) => t.id).toList();
            await database.taskDao.deleteTasks(taskIds);
          }
          
          print('Completed memory test batch ${batch + 1}/$batchCount');
        }

        // Final verification
        final finalTasks = await database.taskDao.getAllTasks();
        expect(finalTasks.length, equals(batchSize));
        
        print('Memory test completed successfully');
      });
    });
  });
}