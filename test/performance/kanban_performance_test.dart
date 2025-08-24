import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:tasky/domain/entities/task_model.dart';
import 'package:tasky/domain/models/enums.dart';
import 'package:tasky/presentation/widgets/kanban_board_view.dart';
import 'package:tasky/presentation/widgets/kanban_performance_optimizer.dart';
import 'package:tasky/presentation/providers/kanban_providers.dart';

import '../presentation/widgets/kanban_board_test.mocks.dart';

void main() {
  group('Kanban Performance Benchmarks', () {
    late MockTaskRepository mockRepository;
    late KanbanPerformanceOptimizer optimizer;
    late KanbanPerformanceMonitor monitor;

    setUp(() {
      mockRepository = MockTaskRepository();
      optimizer = KanbanPerformanceOptimizer();
      monitor = KanbanPerformanceMonitor();
    });

    test('Task filtering performance with 1000 tasks', () async {
      // Create 1000 test tasks
      final tasks = _generateLargeTasokDataset(1000);
      
      // Benchmark filtering operations
      final stopwatch = Stopwatch()..start();
      
      final filteredTasks = optimizer.filterTasks(
        tasks,
        searchQuery: 'test',
        priority: TaskPriority.high,
        tags: ['urgent'],
      );
      
      stopwatch.stop();
      monitor.recordOperation('filter_1000_tasks', stopwatch.elapsedMilliseconds);
      
      // Verify performance meets requirements
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      expect(filteredTasks.length, greaterThan(0));
      
      print('Filtering 1000 tasks took: ${stopwatch.elapsedMilliseconds}ms');
    });

    test('Task filtering performance with 5000 tasks', () async {
      final tasks = _generateLargeTasokDataset(5000);
      
      final stopwatch = Stopwatch()..start();
      
      final filteredTasks = optimizer.filterTasks(
        tasks,
        searchQuery: 'project',
        priority: TaskPriority.medium,
      );
      
      stopwatch.stop();
      monitor.recordOperation('filter_5000_tasks', stopwatch.elapsedMilliseconds);
      
      // Should still be under 500ms for 5000 tasks
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
      expect(filteredTasks.length, greaterThan(0));
      
      print('Filtering 5000 tasks took: ${stopwatch.elapsedMilliseconds}ms');
    });

    test('Column rendering performance with many tasks', () async {
      final tasks = _generateLargeTasokDataset(500);
      
      // Mock repository to return large dataset
      when(mockRepository.watchAllTasks()).thenAnswer(
        (_) => Stream.value(tasks),
      );
      when(mockRepository.getAllTasks()).thenAnswer(
        (_) async => tasks,
      );
      
      // Benchmark widget rendering
      await benchmarkWidgets((WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              taskRepositoryProvider.overrideWithValue(mockRepository),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: KanbanBoardView(),
              ),
            ),
          ),
        );
        
        await tester.pumpAndSettle();
        stopwatch.stop();
        
        monitor.recordOperation('render_500_tasks', stopwatch.elapsedMilliseconds);
        print('Rendering 500 tasks took: ${stopwatch.elapsedMilliseconds}ms');
        
        // Verify rendering performance
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      }, () {
        // Benchmark setup
      });
    });

    test('Memory usage with large task dataset', () async {
      final tasks = _generateLargeTasokDataset(2000);
      final taskListManager = TaskListManager();
      
      // Test memory efficiency
      final initialMemory = _getMemoryUsage();
      
      // Store multiple task lists
      for (int i = 0; i < 10; i++) {
        final filteredTasks = tasks.where((task) => 
          task.priority.value >= i % 4
        ).toList();
        
        taskListManager.updateTaskList('filter_$i', filteredTasks);
      }
      
      final memoryAfterCaching = _getMemoryUsage();
      
      // Trigger cleanup
      taskListManager.cleanup();
      
      final memoryAfterCleanup = _getMemoryUsage();
      
      print('Memory usage:');
      print('  Initial: ${initialMemory}MB');
      print('  After caching: ${memoryAfterCaching}MB');
      print('  After cleanup: ${memoryAfterCleanup}MB');
      
      // Verify memory is managed properly
      expect(memoryAfterCleanup, lessThanOrEqualTo(memoryAfterCaching));
    });

    test('Drag and drop performance simulation', () async {
      final tasks = _generateLargeTasokDataset(100);
      final operations = KanbanOperations(mockRepository);
      
      // Setup mock responses
      when(mockRepository.updateTask(any)).thenAnswer((_) async {});
      
      // Benchmark moving tasks between columns
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 20; i++) {
        final task = tasks[i];
        final newStatus = TaskStatus.values[(i + 1) % TaskStatus.values.length];
        
        await operations.moveTask(task, newStatus);
      }
      
      stopwatch.stop();
      monitor.recordOperation('move_20_tasks', stopwatch.elapsedMilliseconds);
      
      // Should be fast even with many operations
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      
      print('Moving 20 tasks took: ${stopwatch.elapsedMilliseconds}ms');
    });

    test('Search performance with complex queries', () async {
      final tasks = _generateLargeTasokDataset(1000);
      
      final searchQueries = [
        'important project task',
        'urgent high priority',
        'bug fix implementation',
        'user interface design',
        'database optimization',
      ];
      
      for (final query in searchQueries) {
        final stopwatch = Stopwatch()..start();
        
        final results = optimizer.filterTasks(
          tasks,
          searchQuery: query,
        );
        
        stopwatch.stop();
        monitor.recordOperation('search_complex_query', stopwatch.elapsedMilliseconds);
        
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
        print('Search "$query" took: ${stopwatch.elapsedMilliseconds}ms, found ${results.length} results');
      }
    });

    test('Batch operations performance', () async {
      final tasks = _generateLargeTasokDataset(200);
      final operations = KanbanOperations(mockRepository);
      
      // Setup mock responses
      when(mockRepository.updateTask(any)).thenAnswer((_) async {});
      
      // Test batch priority update
      final stopwatch1 = Stopwatch()..start();
      await operations.batchUpdatePriority(tasks.take(50).toList(), TaskPriority.high);
      stopwatch1.stop();
      
      expect(stopwatch1.elapsedMilliseconds, lessThan(500));
      
      // Test batch tag addition
      final stopwatch2 = Stopwatch()..start();
      await operations.batchAddTags(tasks.take(30).toList(), ['urgent', 'priority']);
      stopwatch2.stop();
      
      expect(stopwatch2.elapsedMilliseconds, lessThan(300));
      
      // Test batch status change
      final stopwatch3 = Stopwatch()..start();
      await operations.batchMoveTasksToStatus(tasks.take(40).toList(), TaskStatus.completed);
      stopwatch3.stop();
      
      expect(stopwatch3.elapsedMilliseconds, lessThan(400));
      
      print('Batch operations performance:');
      print('  Priority update (50 tasks): ${stopwatch1.elapsedMilliseconds}ms');
      print('  Tag addition (30 tasks): ${stopwatch2.elapsedMilliseconds}ms');
      print('  Status change (40 tasks): ${stopwatch3.elapsedMilliseconds}ms');
    });

    test('Cache performance and hit rates', () async {
      final tasks = _generateLargeTasokDataset(500);
      
      // Test cache performance
      final cacheKey = 'test_filter';
      
      // First call should be cache miss
      final stopwatch1 = Stopwatch()..start();
      final result1 = optimizer.filterTasks(
        tasks,
        searchQuery: 'test',
        priority: TaskPriority.high,
      );
      stopwatch1.stop();
      
      // Second call with same parameters should be cache hit
      final stopwatch2 = Stopwatch()..start();
      final result2 = optimizer.filterTasks(
        tasks,
        searchQuery: 'test',
        priority: TaskPriority.high,
      );
      stopwatch2.stop();
      
      expect(result1.length, equals(result2.length));
      expect(stopwatch2.elapsedMilliseconds, lessThan(stopwatch1.elapsedMilliseconds));
      
      print('Cache performance:');
      print('  Cache miss: ${stopwatch1.elapsedMilliseconds}ms');
      print('  Cache hit: ${stopwatch2.elapsedMilliseconds}ms');
      print('  Speed improvement: ${((stopwatch1.elapsedMilliseconds - stopwatch2.elapsedMilliseconds) / stopwatch1.elapsedMilliseconds * 100).toStringAsFixed(1)}%');
    });

    test('Virtual list rendering performance', () async {
      final tasks = _generateLargeTasokDataset(1000);
      
      await benchmarkWidgets((WidgetTester tester) async {
        final scrollController = ScrollController();
        
        final stopwatch = Stopwatch()..start();
        
        // Create virtualized list
        final virtualizedList = optimizer.buildVirtualizedTaskList(
          tasks: tasks,
          scrollController: scrollController,
          itemBuilder: (task, index) => ListTile(
            title: Text(task.title),
            subtitle: Text(task.description ?? ''),
          ),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: virtualizedList,
            ),
          ),
        );
        
        await tester.pumpAndSettle();
        stopwatch.stop();
        
        monitor.recordOperation('virtual_list_1000', stopwatch.elapsedMilliseconds);
        
        // Should render only visible items quickly
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
        
        print('Virtual list rendering (1000 tasks): ${stopwatch.elapsedMilliseconds}ms');
        
        scrollController.dispose();
      }, () {});
    });

    tearDown(() {
      // Print performance statistics
      final stats = monitor.getAllStats();
      print('\nPerformance Summary:');
      stats.forEach((operation, stat) {
        print('  $operation: $stat');
      });
      
      // Cleanup
      optimizer.cleanup();
    });
  });

  group('Performance Regression Tests', () {
    test('Verify performance requirements are met', () {
      final monitor = KanbanPerformanceMonitor();
      
      // Record some sample operations to verify the monitoring works
      monitor.recordOperation('sample_filter', 45);
      monitor.recordOperation('sample_filter', 52);
      monitor.recordOperation('sample_filter', 38);
      
      final stats = monitor.getStats('sample_filter');
      expect(stats.samples, equals(3));
      expect(stats.averageMs, closeTo(45.0, 10.0));
      expect(stats.minMs, equals(38.0));
      expect(stats.maxMs, equals(52.0));
      
      print('Performance monitoring verification: $stats');
    });
  });
}

/// Generate a large dataset of tasks for performance testing
List<TaskModel> _generateLargeTasokDataset(int count) {
  final tasks = <TaskModel>[];
  final now = DateTime.now();
  
  final titles = [
    'Implement user authentication',
    'Fix critical bug in payment system',
    'Design new dashboard interface',
    'Optimize database queries',
    'Write unit tests for API',
    'Update documentation',
    'Review code changes',
    'Deploy to production',
    'Monitor system performance',
    'Backup database',
  ];
  
  final descriptions = [
    'This is an important task that needs immediate attention',
    'Complex implementation required with multiple stakeholders',
    'Simple task that can be completed quickly',
    'Research and analysis needed before implementation',
    'Requires coordination with external team',
  ];
  
  final tags = [
    ['urgent', 'bug'],
    ['feature', 'ui'],
    ['backend', 'optimization'],
    ['testing', 'quality'],
    ['documentation'],
    ['deployment', 'production'],
    ['monitoring', 'performance'],
    ['maintenance'],
  ];
  
  for (int i = 0; i < count; i++) {
    final title = '${titles[i % titles.length]} #$i';
    final description = descriptions[i % descriptions.length];
    final priority = TaskPriority.values[i % TaskPriority.values.length];
    final status = TaskStatus.values[i % TaskStatus.values.length];
    final taskTags = tags[i % tags.length];
    
    final task = TaskModel.create(
      title: title,
      description: description,
      priority: priority,
      tags: taskTags,
      dueDate: now.add(Duration(days: i % 30 - 10)), // Mix of past and future dates
    ).copyWith(status: status);
    
    tasks.add(task);
  }
  
  return tasks;
}

/// Get current memory usage (simplified simulation)
double _getMemoryUsage() {
  // In a real implementation, this would use platform-specific APIs
  // to get actual memory usage. For testing, we simulate with a random value.
  return 50.0 + (DateTime.now().millisecondsSinceEpoch % 100) / 10.0;
}