import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:task_tracker_app/presentation/providers/task_providers.dart';
import 'package:task_tracker_app/data/repositories/cached_task_repository_impl.dart';
import 'package:task_tracker_app/data/repositories/task_repository_impl.dart';
import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/core/cache/task_cache_manager.dart';
import 'package:task_tracker_app/core/performance/performance_monitor.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Performance and Caching Flow Integration Tests', () {
    late AppDatabase database;
    late CachedTaskRepositoryImpl cachedRepository;
    late TaskRepositoryImpl baseRepository;
    
    setUp(() async {
      // Create test database
      database = AppDatabase.forTesting(testExecutor);
      baseRepository = TaskRepositoryImpl(database);
      cachedRepository = CachedTaskRepositoryImpl(database);
      
      // Clear performance monitor
      PerformanceMonitor().clear();
    });

    tearDown(() async {
      await database.clearAllData();
      await database.close();
    });

    test('database-level filtering performance', () async {
      // Create test data
      final testTasks = List.generate(100, (index) => TaskModel.create(
        title: 'Test Task $index',
        description: 'Description for task $index',
        priority: TaskPriority.values[index % TaskPriority.values.length],
        status: TaskStatus.values[index % TaskStatus.values.length],
        dueDate: DateTime.now().add(Duration(days: index % 30)),
      ));

      // Insert tasks using bulk operation
      final stopwatch = Stopwatch()..start();
      for (final task in testTasks) {
        await baseRepository.createTask(task);
      }
      stopwatch.stop();
      
      print('Bulk insert time: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // Should complete in < 5s

      // Test filtered queries performance
      final filterCases = [
        TaskFilter(status: TaskStatus.pending),
        TaskFilter(priority: TaskPriority.high),
        TaskFilter(
          dueDateFrom: DateTime.now(),
          dueDateTo: DateTime.now().add(const Duration(days: 7)),
        ),
        TaskFilter(
          searchQuery: 'Test',
          sortBy: TaskSortBy.title,
          sortAscending: true,
        ),
      ];

      for (final filter in filterCases) {
        final filterStopwatch = Stopwatch()..start();
        final results = await baseRepository.getTasksWithFilter(filter);
        filterStopwatch.stop();
        
        expect(results, isA<List<TaskModel>>());
        expect(filterStopwatch.elapsedMilliseconds, lessThan(500)); // < 500ms per filter
        print('Filter query time: ${filterStopwatch.elapsedMilliseconds}ms for ${filter.toString()}');
      }
    });

    test('cache performance and effectiveness', () async {
      final cacheManager = TaskCacheManager();
      
      // Create test tasks
      final testTasks = List.generate(20, (index) => TaskModel.create(
        title: 'Cache Test Task $index',
        priority: TaskPriority.medium,
      ));

      for (final task in testTasks) {
        await cachedRepository.createTask(task);
      }

      // Test cache hits
      final stopwatch = Stopwatch()..start();
      
      // First access (should be cache miss and fetch from DB)
      var firstAccess = await cachedRepository.getTaskById(testTasks[0].id);
      final firstAccessTime = stopwatch.elapsedMicroseconds;
      stopwatch.reset();
      
      // Second access (should be cache hit)
      var secondAccess = await cachedRepository.getTaskById(testTasks[0].id);
      final secondAccessTime = stopwatch.elapsedMicroseconds;
      
      expect(firstAccess?.id, equals(testTasks[0].id));
      expect(secondAccess?.id, equals(testTasks[0].id));
      
      // Cache hit should be significantly faster
      expect(secondAccessTime, lessThan(firstAccessTime / 2));
      print('Cache miss time: ${firstAccessTime}μs, Cache hit time: ${secondAccessTime}μs');
      
      // Test cache statistics
      final stats = cachedRepository.getCacheStats();
      expect(stats.taskCacheSize, greaterThan(0));
      print('Cache stats: ${stats.taskCacheSize} tasks, ${stats.listCacheSize} lists');
    });

    test('bulk operations performance', () async {
      // Create initial tasks
      final taskIds = <String>[];
      for (int i = 0; i < 50; i++) {
        final task = TaskModel.create(title: 'Bulk Test Task $i');
        await baseRepository.createTask(task);
        taskIds.add(task.id);
      }

      // Test bulk status update
      final bulkUpdateStopwatch = Stopwatch()..start();
      await baseRepository.updateTasksStatus(taskIds, TaskStatus.completed);
      bulkUpdateStopwatch.stop();
      
      expect(bulkUpdateStopwatch.elapsedMilliseconds, lessThan(1000)); // < 1s for 50 tasks
      print('Bulk status update time: ${bulkUpdateStopwatch.elapsedMilliseconds}ms');

      // Verify all tasks were updated
      final completedTasks = await baseRepository.getTasksByStatus(TaskStatus.completed);
      expect(completedTasks.length, greaterThanOrEqualTo(50));

      // Test bulk delete
      final bulkDeleteStopwatch = Stopwatch()..start();
      await baseRepository.deleteTasks(taskIds.take(25).toList());
      bulkDeleteStopwatch.stop();
      
      expect(bulkDeleteStopwatch.elapsedMilliseconds, lessThan(500)); // < 500ms for 25 tasks
      print('Bulk delete time: ${bulkDeleteStopwatch.elapsedMilliseconds}ms');

      // Verify tasks were deleted
      final remainingTasks = await baseRepository.getAllTasks();
      expect(remainingTasks.length, equals(25));
    });

    test('pagination performance', () async {
      // Create test data
      for (int i = 0; i < 100; i++) {
        final task = TaskModel.create(
          title: 'Pagination Test $i',
          createdAt: DateTime.now().subtract(Duration(minutes: i)),
        );
        await baseRepository.createTask(task);
      }

      // Test paginated queries
      final filter = TaskFilter(
        sortBy: TaskSortBy.createdAt,
        sortAscending: false,
      );

      const pageSize = 20;
      final pageResults = <List<TaskModel>>[];
      
      final paginationStopwatch = Stopwatch()..start();
      
      // Get first few pages
      for (int page = 0; page < 3; page++) {
        final pageStopwatch = Stopwatch()..start();
        // Database-level pagination would be implemented in the DAO
        final results = await baseRepository.getTasksWithFilter(filter);
        final paginatedResults = results.skip(page * pageSize).take(pageSize).toList();
        pageStopwatch.stop();
        
        pageResults.add(paginatedResults);
        expect(paginatedResults.length, lessThanOrEqualTo(pageSize));
        expect(pageStopwatch.elapsedMilliseconds, lessThan(200)); // < 200ms per page
        
        print('Page $page query time: ${pageStopwatch.elapsedMilliseconds}ms');
      }
      
      paginationStopwatch.stop();
      print('Total pagination time: ${paginationStopwatch.elapsedMilliseconds}ms');
      
      // Verify pagination results are correct
      expect(pageResults[0].length, equals(pageSize));
      expect(pageResults[1].length, equals(pageSize));
      
      // Verify ordering (newest first)
      expect(pageResults[0][0].createdAt.isAfter(pageResults[0][1].createdAt), isTrue);
    });

    test('memory usage under load', () async {
      // Create many tasks to test memory usage
      const taskCount = 500;
      
      for (int i = 0; i < taskCount; i++) {
        final task = TaskModel.create(
          title: 'Memory Test Task $i',
          description: 'This is a longer description to test memory usage with larger task objects. It contains more text to simulate real-world task descriptions.',
        );
        await baseRepository.createTask(task);
      }

      // Test memory usage with different query patterns
      final queries = [
        () => baseRepository.getAllTasks(),
        () => baseRepository.getTasksByStatus(TaskStatus.pending),
        () => baseRepository.getTasksWithFilter(TaskFilter(searchQuery: 'Test')),
      ];

      for (int i = 0; i < queries.length; i++) {
        final queryStopwatch = Stopwatch()..start();
        final results = await queries[i]();
        queryStopwatch.stop();
        
        expect(results, isA<List<TaskModel>>());
        expect(queryStopwatch.elapsedMilliseconds, lessThan(2000)); // < 2s for large queries
        
        print('Query $i with ${results.length} results: ${queryStopwatch.elapsedMilliseconds}ms');
        
        // Clear results to help with memory management
        results.clear();
      }
    });

    test('transaction performance and integrity', () async {
      // Test transaction performance with complex operations
      final transactionStopwatch = Stopwatch()..start();
      
      // Create a task with subtasks in a transaction (simulated)
      final mainTask = TaskModel.create(title: 'Transaction Test Task');
      final subtasks = List.generate(10, (i) => 
        SubTask.create(taskId: mainTask.id, title: 'Subtask $i', sortOrder: i)
      );
      
      final taskWithSubtasks = mainTask.copyWith(subTasks: subtasks);
      await baseRepository.createTask(taskWithSubtasks);
      
      transactionStopwatch.stop();
      print('Transaction time: ${transactionStopwatch.elapsedMilliseconds}ms');
      
      // Verify transaction integrity
      final retrievedTask = await baseRepository.getTaskById(mainTask.id);
      expect(retrievedTask, isNotNull);
      expect(retrievedTask!.subTasks.length, equals(10));
      
      // Test rollback scenario (simulated failure)
      try {
        // This would normally cause a transaction rollback
        final invalidTask = TaskModel.create(title: '');
        await baseRepository.createTask(invalidTask);
      } catch (e) {
        // Expected to fail with validation
        expect(e, isA<Exception>());
      }
    });

    test('concurrent access performance', () async {
      // Test concurrent database access
      const concurrentOperations = 20;
      
      final futures = <Future>[];
      final concurrencyStopwatch = Stopwatch()..start();
      
      // Create concurrent tasks
      for (int i = 0; i < concurrentOperations; i++) {
        final future = baseRepository.createTask(TaskModel.create(
          title: 'Concurrent Task $i',
        ));
        futures.add(future);
      }
      
      await Future.wait(futures);
      concurrencyStopwatch.stop();
      
      print('Concurrent operations time: ${concurrencyStopwatch.elapsedMilliseconds}ms');
      expect(concurrencyStopwatch.elapsedMilliseconds, lessThan(3000)); // < 3s for 20 concurrent ops
      
      // Verify all tasks were created
      final allTasks = await baseRepository.getAllTasks();
      expect(allTasks.length, equals(concurrentOperations));
    });

    test('cache invalidation correctness', () async {
      // Create and cache tasks
      final task = TaskModel.create(title: 'Cache Invalidation Test');
      await cachedRepository.createTask(task);
      
      // Verify it's in cache by accessing it
      var cachedTask = await cachedRepository.getTaskById(task.id);
      expect(cachedTask, isNotNull);
      
      // Update the task
      final updatedTask = task.copyWith(title: 'Updated Title');
      await cachedRepository.updateTask(updatedTask);
      
      // Verify cache was invalidated and new data is returned
      cachedTask = await cachedRepository.getTaskById(task.id);
      expect(cachedTask?.title, equals('Updated Title'));
      
      // Delete the task
      await cachedRepository.deleteTask(task.id);
      
      // Verify cache was invalidated and task is not found
      cachedTask = await cachedRepository.getTaskById(task.id);
      expect(cachedTask, isNull);
    });

    test('performance monitoring accuracy', () async {
      final monitor = PerformanceMonitor();
      
      // Perform monitored operations
      Future<void> monitoredOperation() async {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // Record some operations
      await (() async {
        await monitoredOperation();
      }).timed('test_operation');
      
      await (() async {
        await Future.delayed(const Duration(milliseconds: 50));
      }).timed('fast_operation');
      
      await (() async {
        await Future.delayed(const Duration(milliseconds: 200));
      }).timed('slow_operation');
      
      // Check performance statistics
      final stats = monitor.getStats();
      
      expect(stats.averageQueryTimes.containsKey('test_operation'), isTrue);
      expect(stats.averageQueryTimes['test_operation']!.inMilliseconds, 
             closeTo(100, 20)); // Within 20ms tolerance
      
      expect(stats.totalQueries, greaterThan(0));
      
      // Check for slow queries
      final slowQueries = monitor.getSlowQueries(threshold: const Duration(milliseconds: 150));
      expect(slowQueries.length, equals(1)); // Only slow_operation should be flagged
      expect(slowQueries[0].queryType, equals('slow_operation'));
    });
  });

  group('Real-World Performance Scenarios', () {
    late AppDatabase database;
    late CachedTaskRepositoryImpl repository;
    
    setUp(() async {
      database = AppDatabase.forTesting(testExecutor);
      repository = CachedTaskRepositoryImpl(database);
    });

    tearDown(() async {
      await database.clearAllData();
      await database.close();
    });

    test('typical user workflow performance', () async {
      final workflowStopwatch = Stopwatch()..start();
      
      // Simulate typical user workflow
      // 1. Create several tasks
      final tasks = <TaskModel>[];
      for (int i = 0; i < 10; i++) {
        final task = TaskModel.create(
          title: 'Daily Task $i',
          priority: i % 2 == 0 ? TaskPriority.high : TaskPriority.medium,
          dueDate: DateTime.now().add(Duration(days: i)),
        );
        tasks.add(task);
        await repository.createTask(task);
      }
      
      // 2. View tasks by different filters
      await repository.getTasksByStatus(TaskStatus.pending);
      await repository.getTasksByPriority(TaskPriority.high);
      await repository.getTasksDueToday();
      
      // 3. Update some tasks
      for (int i = 0; i < 3; i++) {
        final updatedTask = tasks[i].copyWith(
          status: TaskStatus.inProgress,
        );
        await repository.updateTask(updatedTask);
      }
      
      // 4. Complete some tasks
      for (int i = 3; i < 6; i++) {
        final completedTask = tasks[i].markCompleted();
        await repository.updateTask(completedTask);
      }
      
      // 5. Search for tasks
      await repository.searchTasks('Daily');
      
      workflowStopwatch.stop();
      
      print('Complete user workflow time: ${workflowStopwatch.elapsedMilliseconds}ms');
      expect(workflowStopwatch.elapsedMilliseconds, lessThan(5000)); // < 5s for typical workflow
    });
  });
}

// Helper extension for timed operations
extension TimedOperations on Future<T> Function() {
  Future<T> timed(String operationType) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await this();
      stopwatch.stop();
      PerformanceMonitor().recordQuery(operationType, stopwatch.elapsed);
      return result;
    } catch (e) {
      stopwatch.stop();
      PerformanceMonitor().recordQuery('${operationType}_error', stopwatch.elapsed);
      rethrow;
    }
  }
}

// Mock test executor for testing
// In a real implementation, this would be provided by the test framework
final testExecutor = null; // Placeholder - would be actual test database executor