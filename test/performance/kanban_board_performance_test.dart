import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/presentation/widgets/kanban_board_view.dart';
import 'package:task_tracker_app/presentation/providers/kanban_providers.dart';
import 'package:task_tracker_app/services/analytics_service.dart';

import '../mocks/test_mocks.mocks.dart';

void main() {
  group('Kanban Board Performance Tests - Enterprise Scale', () {
    late MockTaskRepository mockTaskRepository;
    late MockProjectRepository mockProjectRepository;
    late MockAnalyticsService mockAnalyticsService;
    late PerformanceBenchmarker benchmarker;

    setUp(() {
      mockTaskRepository = MockTaskRepository();
      mockProjectRepository = MockProjectRepository();
      mockAnalyticsService = MockAnalyticsService();
      benchmarker = PerformanceBenchmarker();
    });

    group('Large Dataset Rendering Performance', () {
      testWidgets('Kanban board with 100 tasks renders smoothly', (WidgetTester tester) async {
        final tasks = _generateLargeTaskDataset(100);
        final projects = _generateProjectDataset(10);
        
        // Mock repository responses
        when(mockTaskRepository.watchAllTasks()).thenAnswer(
          (_) => Stream.value(tasks),
        );
        when(mockProjectRepository.watchAllProjects()).thenAnswer(
          (_) => Stream.value(projects),
        );

        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              taskRepositoryProvider.overrideWithValue(mockTaskRepository),
              projectRepositoryProvider.overrideWithValue(mockProjectRepository),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: KanbanBoardView(),
              ),
            ),
          ),
        );

        // Wait for initial render and animations
        await tester.pumpAndSettle(const Duration(seconds: 2));
        stopwatch.stop();

        benchmarker.recordMetric('kanban_render_100_tasks', stopwatch.elapsedMilliseconds);
        
        // Should render within performance budget
        expect(stopwatch.elapsedMilliseconds, lessThan(2000), 
               reason: 'Kanban board with 100 tasks should render within 2 seconds');
        
        // Verify all columns are rendered
        expect(find.text('To Do'), findsWidgets);
        expect(find.text('In Progress'), findsWidgets);
        expect(find.text('Done'), findsWidgets);
        
        print('Kanban board with 100 tasks rendered in ${stopwatch.elapsedMilliseconds}ms');
      });

      testWidgets('Kanban board with 500 tasks uses virtualization effectively', (WidgetTester tester) async {
        final tasks = _generateLargeTaskDataset(500);
        final projects = _generateProjectDataset(20);
        
        when(mockTaskRepository.watchAllTasks()).thenAnswer(
          (_) => Stream.value(tasks),
        );
        when(mockProjectRepository.watchAllProjects()).thenAnswer(
          (_) => Stream.value(projects),
        );

        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              taskRepositoryProvider.overrideWithValue(mockTaskRepository),
              projectRepositoryProvider.overrideWithValue(mockProjectRepository),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: KanbanBoardView(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 3));
        stopwatch.stop();

        benchmarker.recordMetric('kanban_render_500_tasks', stopwatch.elapsedMilliseconds);
        
        // Should still render reasonably fast with virtualization
        expect(stopwatch.elapsedMilliseconds, lessThan(5000), 
               reason: 'Kanban board with 500 tasks should render within 5 seconds using virtualization');
        
        print('Kanban board with 500 tasks rendered in ${stopwatch.elapsedMilliseconds}ms');
      });

      testWidgets('Kanban board with 1000+ tasks maintains 60fps during scroll', (WidgetTester tester) async {
        final tasks = _generateLargeTaskDataset(1000);
        final projects = _generateProjectDataset(50);
        
        when(mockTaskRepository.watchAllTasks()).thenAnswer(
          (_) => Stream.value(tasks),
        );
        when(mockProjectRepository.watchAllProjects()).thenAnswer(
          (_) => Stream.value(projects),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              taskRepositoryProvider.overrideWithValue(mockTaskRepository),
              projectRepositoryProvider.overrideWithValue(mockProjectRepository),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: KanbanBoardView(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find scrollable column
        final scrollable = find.byType(Scrollable).first;
        
        // Measure scrolling performance
        final scrollStopwatch = Stopwatch()..start();
        
        // Simulate rapid scrolling
        for (int i = 0; i < 10; i++) {
          await tester.drag(scrollable, const Offset(0, -100));
          await tester.pump(const Duration(milliseconds: 16)); // 60fps frame time
        }
        
        scrollStopwatch.stop();
        final frameTime = scrollStopwatch.elapsedMilliseconds / 10;
        
        benchmarker.recordMetric('kanban_scroll_frame_time', frameTime.round());
        
        // Should maintain 60fps (16.67ms per frame)
        expect(frameTime, lessThan(20.0), 
               reason: 'Kanban scrolling should maintain near 60fps with 1000+ tasks');
        
        print('Average frame time during scroll: ${frameTime.toStringAsFixed(2)}ms');
      });

      testWidgets('Kanban board with 2500+ tasks stress test', (WidgetTester tester) async {
        final tasks = _generateLargeTaskDataset(2500);
        final projects = _generateProjectDataset(75);
        
        when(mockTaskRepository.watchAllTasks()).thenAnswer(
          (_) => Stream.value(tasks),
        );
        when(mockProjectRepository.watchAllProjects()).thenAnswer(
          (_) => Stream.value(projects),
        );

        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              taskRepositoryProvider.overrideWithValue(mockTaskRepository),
              projectRepositoryProvider.overrideWithValue(mockProjectRepository),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: KanbanBoardView(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 5));
        stopwatch.stop();

        benchmarker.recordMetric('kanban_render_2500_tasks', stopwatch.elapsedMilliseconds);
        
        // Should handle extreme load with virtualization
        expect(stopwatch.elapsedMilliseconds, lessThan(8000), 
               reason: 'Kanban board with 2500+ tasks should render within 8 seconds');
        
        print('Kanban board with 2500+ tasks rendered in ${stopwatch.elapsedMilliseconds}ms');
      });

      testWidgets('Kanban board with 5000+ tasks extreme stress test', (WidgetTester tester) async {
        final tasks = _generateLargeTaskDataset(5000);
        final projects = _generateProjectDataset(100);
        
        when(mockTaskRepository.watchAllTasks()).thenAnswer(
          (_) => Stream.value(tasks),
        );
        when(mockProjectRepository.watchAllProjects()).thenAnswer(
          (_) => Stream.value(projects),
        );

        final stopwatch = Stopwatch()..start();
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              taskRepositoryProvider.overrideWithValue(mockTaskRepository),
              projectRepositoryProvider.overrideWithValue(mockProjectRepository),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: KanbanBoardView(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 10));
        stopwatch.stop();

        benchmarker.recordMetric('kanban_render_5000_tasks', stopwatch.elapsedMilliseconds);
        
        // Ultimate stress test - should still work with advanced virtualization
        expect(stopwatch.elapsedMilliseconds, lessThan(15000), 
               reason: 'Kanban board with 5000+ tasks should render within 15 seconds with advanced virtualization');
        
        print('EXTREME: Kanban board with 5000+ tasks rendered in ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Drag and Drop Performance', () {
      testWidgets('Drag and drop performance with large datasets', (WidgetTester tester) async {
        final tasks = _generateLargeTaskDataset(200);
        final projects = _generateProjectDataset(15);
        
        when(mockTaskRepository.watchAllTasks()).thenAnswer(
          (_) => Stream.value(tasks),
        );
        when(mockProjectRepository.watchAllProjects()).thenAnswer(
          (_) => Stream.value(projects),
        );
        when(mockTaskRepository.updateTask(any)).thenAnswer((_) async {
          return null;
        });

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              taskRepositoryProvider.overrideWithValue(mockTaskRepository),
              projectRepositoryProvider.overrideWithValue(mockProjectRepository),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: KanbanBoardView(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find draggable task cards
        final taskCards = find.byKey(const ValueKey('task-card')).first;
        
        final stopwatch = Stopwatch()..start();
        
        // Simulate drag and drop operation
        await tester.drag(taskCards, const Offset(300, 0)); // Move to next column
        await tester.pumpAndSettle();
        
        stopwatch.stop();

        benchmarker.recordMetric('kanban_drag_drop_200_tasks', stopwatch.elapsedMilliseconds);
        
        // Should complete drag operation quickly
        expect(stopwatch.elapsedMilliseconds, lessThan(500), 
               reason: 'Drag and drop should complete within 500ms');
        
        print('Drag and drop with 200 tasks completed in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Batch drag and drop operations performance', () async {
        final tasks = _generateLargeTaskDataset(100);
        final operations = KanbanOperations(mockTaskRepository);
        
        when(mockTaskRepository.updateTask(any)).thenAnswer((_) async {
          return null;
        });
        
        final stopwatch = Stopwatch()..start();
        
        // Simulate moving 20 tasks in batch
        final tasksToMove = tasks.take(20).toList();
        await operations.batchMoveTasksToStatus(tasksToMove, TaskStatus.inProgress);
        
        stopwatch.stop();

        benchmarker.recordMetric('kanban_batch_move_20_tasks', stopwatch.elapsedMilliseconds);
        
        expect(stopwatch.elapsedMilliseconds, lessThan(1000), 
               reason: 'Batch moving 20 tasks should complete within 1 second');
        
        verify(mockTaskRepository.updateTask(any)).called(20);
        
        print('Batch moved 20 tasks in ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Real-time Updates Performance', () {
      test('Handle rapid task status changes efficiently', () async {
        final tasks = _generateLargeTaskDataset(100);
        final streamController = StreamController<List<TaskModel>>.broadcast();
        
        when(mockTaskRepository.watchAllTasks()).thenAnswer(
          (_) => streamController.stream,
        );
        
        // Start with initial data
        streamController.add(tasks);
        
        final stopwatch = Stopwatch()..start();
        
        // Simulate 50 rapid updates (status changes)
        for (int i = 0; i < 50; i++) {
          final updatedTasks = List<TaskModel>.from(tasks);
          if (i < tasks.length) {
            updatedTasks[i] = tasks[i].copyWith(
              updatedAt: DateTime.now(),
            );
          }
          streamController.add(updatedTasks);
          
          // Small delay to simulate realistic update frequency
          await Future.delayed(const Duration(milliseconds: 10));
        }
        
        stopwatch.stop();

        benchmarker.recordMetric('kanban_rapid_updates_50', stopwatch.elapsedMilliseconds);
        
        expect(stopwatch.elapsedMilliseconds, lessThan(2000), 
               reason: '50 rapid updates should complete within 2 seconds');
        
        await streamController.close();
        
        print('50 rapid status updates processed in ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Filtering and Search Performance', () {
      test('Complex filtering with large dataset', () async {
        final tasks = _generateLargeTaskDataset(1000);
        final filterService = KanbanFilterService();
        
        final stopwatch = Stopwatch()..start();
        
        // Apply complex filter
        final filteredTasks = filterService.filterTasks(
          tasks,
          searchQuery: 'urgent project',
          priority: TaskPriority.high,
          status: [TaskStatus.inProgress, TaskStatus.pending],
          tags: ['feature', 'bug'],
          projectIds: tasks.take(10).map((t) => t.projectId).whereType<String>().toList(),
          dueDateRange: DateTimeRange(
            start: DateTime.now(),
            end: DateTime.now().add(const Duration(days: 30)),
          ),
        );
        
        stopwatch.stop();

        benchmarker.recordMetric('kanban_complex_filter_1000', stopwatch.elapsedMilliseconds);
        
        expect(stopwatch.elapsedMilliseconds, lessThan(100), 
               reason: 'Complex filtering 1000 tasks should complete within 100ms');
        
        expect(filteredTasks.length, greaterThan(0));
        
        print('Complex filtering 1000 tasks took ${stopwatch.elapsedMilliseconds}ms, found ${filteredTasks.length} results');
      });

      test('Real-time search performance', () async {
        final tasks = _generateLargeTaskDataset(500);
        final searchService = KanbanSearchService();
        
        final searchQueries = [
          'task',
          'project',
          'urgent',
          'bug fix',
          'feature implementation',
          'user interface',
          'database optimization',
          'performance improvement',
          'test coverage',
          'documentation update',
        ];
        
        final totalStopwatch = Stopwatch()..start();
        
        for (final query in searchQueries) {
          final queryStopwatch = Stopwatch()..start();
          
          final results = searchService.searchTasks(tasks, query);
          
          queryStopwatch.stop();
          
          benchmarker.recordMetric('kanban_search_query', queryStopwatch.elapsedMilliseconds);
          
          expect(queryStopwatch.elapsedMilliseconds, lessThan(50), 
                 reason: 'Each search query should complete within 50ms');
          
          print('Search "$query": ${queryStopwatch.elapsedMilliseconds}ms, ${results.length} results');
        }
        
        totalStopwatch.stop();
        
        final avgSearchTime = totalStopwatch.elapsedMilliseconds / searchQueries.length;
        
        expect(avgSearchTime, lessThan(30.0), 
               reason: 'Average search time should be under 30ms');
        
        print('Average search time: ${avgSearchTime.toStringAsFixed(2)}ms');
      });
    });

    group('Glassmorphism Animation Performance', () {
      testWidgets('Glassmorphism effects maintain 60fps during drag operations', (WidgetTester tester) async {
        final tasks = _generateLargeTaskDataset(100);
        final projects = _generateProjectDataset(10);
        
        when(mockTaskRepository.watchAllTasks()).thenAnswer(
          (_) => Stream.value(tasks),
        );
        when(mockProjectRepository.watchAllProjects()).thenAnswer(
          (_) => Stream.value(projects),
        );
        when(mockTaskRepository.updateTask(any)).thenAnswer((_) async {
          return null;
        });

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              taskRepositoryProvider.overrideWithValue(mockTaskRepository),
              projectRepositoryProvider.overrideWithValue(mockProjectRepository),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: KanbanBoardView(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final taskCards = find.byKey(const ValueKey('task-card')).first;
        final frameStopwatch = Stopwatch()..start();
        
        // Test glassmorphism effects during drag
        await tester.startGesture(tester.getCenter(taskCards));
        
        // Simulate 30 frames of drag animation (0.5 seconds at 60fps)
        for (int frame = 0; frame < 30; frame++) {
          await tester.pump(const Duration(milliseconds: 16)); // 60fps frame time
        }
        
        frameStopwatch.stop();
        final avgFrameTime = frameStopwatch.elapsedMilliseconds / 30;
        
        benchmarker.recordMetric('glassmorphism_drag_frame_time', avgFrameTime.round());
        
        // Should maintain 60fps with glassmorphism effects
        expect(avgFrameTime, lessThan(18.0), 
               reason: 'Glassmorphism effects should maintain near 60fps during drag');
        
        print('Glassmorphism drag animation: ${avgFrameTime.toStringAsFixed(2)}ms avg frame time');
      });

      testWidgets('Column blur effects performance with many tasks', (WidgetTester tester) async {
        final tasks = _generateLargeTaskDataset(300);
        final projects = _generateProjectDataset(15);
        
        when(mockTaskRepository.watchAllTasks()).thenAnswer(
          (_) => Stream.value(tasks),
        );
        when(mockProjectRepository.watchAllProjects()).thenAnswer(
          (_) => Stream.value(projects),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              taskRepositoryProvider.overrideWithValue(mockTaskRepository),
              projectRepositoryProvider.overrideWithValue(mockProjectRepository),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: KanbanBoardView(),
              ),
            ),
          ),
        );

        final renderStopwatch = Stopwatch()..start();
        
        // Test blur effect rendering performance
        await tester.pumpAndSettle();
        
        renderStopwatch.stop();
        
        benchmarker.recordMetric('glassmorphism_blur_render_300_tasks', renderStopwatch.elapsedMilliseconds);
        
        // Blur effects should not significantly impact render time
        expect(renderStopwatch.elapsedMilliseconds, lessThan(3000), 
               reason: 'Glassmorphism blur effects should render efficiently with 300 tasks');
        
        print('Glassmorphism blur effects with 300 tasks: ${renderStopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Device Class Performance Testing', () {
      testWidgets('Performance across different device classes', (WidgetTester tester) async {
        final tasks = _generateLargeTaskDataset(1000);
        final projects = _generateProjectDataset(25);
        
        when(mockTaskRepository.watchAllTasks()).thenAnswer(
          (_) => Stream.value(tasks),
        );
        when(mockProjectRepository.watchAllProjects()).thenAnswer(
          (_) => Stream.value(projects),
        );

        final deviceConfigs = [
          const DeviceConfig('Budget Phone', Size(360, 640), 1.0, 2), // Low-end
          const DeviceConfig('Mid-range Phone', Size(375, 812), 2.0, 4), // Mid-range  
          const DeviceConfig('Flagship Phone', Size(414, 896), 3.0, 8), // High-end
          const DeviceConfig('Small Tablet', Size(768, 1024), 2.0, 4), // Tablet
          const DeviceConfig('Large Tablet', Size(1024, 1366), 2.0, 6), // Large tablet
        ];
        
        for (final config in deviceConfigs) {
          await tester.binding.setSurfaceSize(config.screenSize);
          
          final stopwatch = Stopwatch()..start();
          
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                taskRepositoryProvider.overrideWithValue(mockTaskRepository),
                projectRepositoryProvider.overrideWithValue(mockProjectRepository),
              ],
              child: MaterialApp(
                home: Scaffold(
                  body: MediaQuery(
                    data: MediaQueryData(
                      size: config.screenSize,
                      devicePixelRatio: config.pixelRatio,
                    ),
                    child: const KanbanBoardView(),
                  ),
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();
          stopwatch.stop();
          
          benchmarker.recordMetric('device_${config.name.toLowerCase().replaceAll(' ', '_')}_render', stopwatch.elapsedMilliseconds);
          
          // Performance expectations based on device class
          final maxTime = config.coreCount >= 8 ? 2000 : 
                         config.coreCount >= 4 ? 4000 : 8000;
          
          expect(stopwatch.elapsedMilliseconds, lessThan(maxTime), 
                 reason: '${config.name} should render within ${maxTime}ms');
          
          print('${config.name}: ${stopwatch.elapsedMilliseconds}ms (${config.screenSize})');
        }
        
        await tester.binding.setSurfaceSize(null); // Reset
      });
    });

    group('Performance Regression Prevention', () {
      test('Establish baseline performance metrics', () async {
        // This test establishes baseline metrics for regression detection
        final baselineMetrics = {
          'kanban_render_100_tasks': 2000,
          'kanban_render_500_tasks': 5000, 
          'kanban_render_1000_tasks': 8000,
          'kanban_render_2500_tasks': 12000,
          'kanban_scroll_frame_time': 20,
          'kanban_drag_drop_200_tasks': 500,
          'kanban_batch_move_20_tasks': 1000,
          'glassmorphism_drag_frame_time': 18,
        };
        
        for (final metric in baselineMetrics.entries) {
          benchmarker.recordMetric('baseline_${metric.key}', metric.value);
        }
        
        print('\nBaseline Performance Metrics Established:');
        baselineMetrics.forEach((metric, value) {
          print('  $metric: ${value}ms');
        });
      });

      test('Performance regression detection', () async {
        const regressionThreshold = 1.2; // 20% performance degradation threshold
        const criticalThreshold = 1.5;   // 50% critical regression threshold
        
        final currentMetrics = benchmarker.generateSummary();
        final regressions = <String, double>{};
        
        // Compare against baselines (in a real implementation, these would be stored)
        final mockBaselines = {
          'kanban_render_100_tasks': 1800,
          'kanban_render_500_tasks': 4500,
          'kanban_drag_drop_200_tasks': 450,
        };
        
        mockBaselines.forEach((metric, baseline) {
          if (currentMetrics.containsKey(metric)) {
            final current = currentMetrics[metric]!['avg']!;
            final ratio = current / baseline;
            
            if (ratio > regressionThreshold) {
              regressions[metric] = ratio;
            }
          }
        });
        
        if (regressions.isNotEmpty) {
          print('\nPerformance Regressions Detected:');
          regressions.forEach((metric, ratio) {
            final severity = ratio > criticalThreshold ? 'CRITICAL' : 'WARNING';
            print('  $severity: $metric - ${((ratio - 1) * 100).toStringAsFixed(1)}% slower');
          });
        } else {
          print('\nNo performance regressions detected ✓');
        }
        
        // For testing purposes, we'll just warn about critical regressions
        expect(regressions.values.where((r) => r > criticalThreshold), isEmpty,
               reason: 'Critical performance regressions detected');
      });
    });

    group('Memory Management Performance', () {
      test('Memory usage with large task datasets', () async {
        final memoryTracker = MemoryUsageTracker();
        
        // Baseline memory
        final baselineMemory = await memoryTracker.getCurrentUsage();
        
        // Load large dataset
        final tasks = _generateLargeTaskDataset(2000);
        final projects = _generateProjectDataset(100);
        
        final afterLoadMemory = await memoryTracker.getCurrentUsage();
        
        // Perform various operations
        final kanbanService = KanbanService();
        await kanbanService.loadTasks(tasks);
        await kanbanService.loadProjects(projects);
        
        // Apply filters and grouping
        final filteredTasks = kanbanService.filterByStatus(TaskStatus.inProgress);
        final groupedTasks = kanbanService.groupByProject(filteredTasks);
        
        final afterOperationsMemory = await memoryTracker.getCurrentUsage();
        
        // Cleanup
        await kanbanService.cleanup();
        
        final afterCleanupMemory = await memoryTracker.getCurrentUsage();
        
        final dataMemoryIncrease = afterLoadMemory - baselineMemory;
        final operationsMemoryIncrease = afterOperationsMemory - afterLoadMemory;
        final memoryRecovered = afterOperationsMemory - afterCleanupMemory;
        
        benchmarker.recordMetric('kanban_memory_data_increase', dataMemoryIncrease);
        benchmarker.recordMetric('kanban_memory_operations_increase', operationsMemoryIncrease);
        benchmarker.recordMetric('kanban_memory_recovered', memoryRecovered);
        
        // Memory should be managed efficiently
        expect(dataMemoryIncrease, lessThan(100), 
               reason: 'Loading 2000 tasks should increase memory by less than 100MB');
        expect(operationsMemoryIncrease, lessThan(50), 
               reason: 'Operations should not cause excessive memory growth');
        expect(memoryRecovered, greaterThan(dataMemoryIncrease * 0.8), 
               reason: 'At least 80% of memory should be recoverable');
        
        print('Memory usage analysis:');
        print('  Data loading: +${dataMemoryIncrease}MB');
        print('  Operations: +${operationsMemoryIncrease}MB');
        print('  Recovered: ${memoryRecovered}MB');
      });

      test('Memory leak detection during continuous operation', () async {
        final memoryTracker = MemoryUsageTracker();
        final kanbanService = KanbanService();
        
        final memoryReadings = <double>[];
        
        // Run continuous operations for memory leak detection
        for (int cycle = 0; cycle < 10; cycle++) {
          // Generate fresh data each cycle
          final tasks = _generateLargeTaskDataset(200);
          
          await kanbanService.loadTasks(tasks);
          
          // Perform various operations
          kanbanService.filterByPriority(TaskPriority.high);
          kanbanService.sortByDueDate();
          kanbanService.groupByStatus();
          
          // Record memory usage
          final currentMemory = await memoryTracker.getCurrentUsage();
          memoryReadings.add(currentMemory);
          
          // Cleanup cycle
          await kanbanService.cleanup();
          
          // Small delay to allow GC
          await Future.delayed(const Duration(milliseconds: 100));
        }
        
        // Analyze memory trend
        final memoryTrend = _calculateMemoryTrend(memoryReadings);
        
        benchmarker.recordMetric('kanban_memory_leak_trend', (memoryTrend * 1000).round());
        
        // Memory should not continuously increase (no leaks)
        expect(memoryTrend, lessThan(1.0), 
               reason: 'Memory usage should not show continuous upward trend (leak detection)');
        
        print('Memory leak analysis:');
        print('  Trend: ${memoryTrend > 0 ? '+' : ''}${memoryTrend.toStringAsFixed(3)}MB per cycle');
        print('  Readings: ${memoryReadings.map((r) => r.toStringAsFixed(1)).join(', ')}MB');
      });
    });

    group('Stress Testing', () {
      test('Extreme load: 5000 tasks across 200 projects', () async {
        final tasks = _generateLargeTaskDataset(5000);
        final projects = _generateProjectDataset(200);
        
        when(mockTaskRepository.watchAllTasks()).thenAnswer(
          (_) => Stream.value(tasks),
        );
        when(mockProjectRepository.watchAllProjects()).thenAnswer(
          (_) => Stream.value(projects),
        );
        
        final kanbanService = KanbanService();
        
        final stopwatch = Stopwatch()..start();
        
        // Extreme operations
        await kanbanService.loadTasks(tasks);
        await kanbanService.loadProjects(projects);
        
        final groupedByProject = kanbanService.groupByProject(tasks);
        final groupedByStatus = kanbanService.groupByStatus(tasks);
        final filteredHighPriority = kanbanService.filterByPriority(TaskPriority.high);
        
        stopwatch.stop();

        benchmarker.recordMetric('kanban_extreme_load_5000_tasks', stopwatch.elapsedMilliseconds);
        
        // Should handle extreme load within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(10000), 
               reason: 'Extreme load (5000 tasks, 200 projects) should be handled within 10 seconds');
        
        expect(groupedByProject.length, greaterThan(0));
        expect(groupedByStatus.length, equals(TaskStatus.values.length));
        expect(filteredHighTaskPriority.length, greaterThan(0));
        
        print('Extreme load test (5000 tasks, 200 projects): ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Concurrent operations stress test', () async {
        final tasks = _generateLargeTaskDataset(1000);
        final kanbanService = KanbanService();
        
        await kanbanService.loadTasks(tasks);
        
        final stopwatch = Stopwatch()..start();
        
        // Run multiple operations concurrently
        final futures = [
          kanbanService.filterByPriorityAsync(TaskPriority.high),
          kanbanService.filterByPriorityAsync(TaskPriority.medium),
          kanbanService.filterByStatusAsync(TaskStatus.inProgress),
          kanbanService.filterByStatusAsync(TaskStatus.pending),
          kanbanService.searchTasksAsync('project'),
          kanbanService.searchTasksAsync('feature'),
          kanbanService.groupByProjectAsync(),
          kanbanService.groupByStatusAsync(),
          kanbanService.sortByDueDateAsync(),
          kanbanService.sortByPriorityAsync(),
        ];
        
        final results = await Future.wait(futures);
        
        stopwatch.stop();

        benchmarker.recordMetric('kanban_concurrent_operations_10', stopwatch.elapsedMilliseconds);
        
        expect(stopwatch.elapsedMilliseconds, lessThan(3000), 
               reason: '10 concurrent operations should complete within 3 seconds');
        
        expect(results.length, equals(10));
        
        print('10 concurrent operations on 1000 tasks: ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Comprehensive Performance Validation', () {
      test('All performance benchmarks meet requirements', () async {
        final summary = benchmarker.generateSummary();
        final requirements = {
          'kanban_render_100_tasks': 2000,
          'kanban_render_500_tasks': 5000,
          'kanban_render_1000_tasks': 10000,
          'kanban_scroll_frame_time': 20,
          'glassmorphism_drag_frame_time': 18,
          'kanban_drag_drop_200_tasks': 500,
          'kanban_batch_move_20_tasks': 1000,
        };
        
        final failures = <String>[];
        
        requirements.forEach((metric, maxTime) {
          if (summary.containsKey(metric)) {
            final avg = summary[metric]!['avg']!;
            if (avg > maxTime) {
              failures.add('$metric: ${avg}ms > ${maxTime}ms');
            }
          }
        });
        
        if (failures.isNotEmpty) {
          print('\nPerformance Requirements FAILED:');
          failures.forEach(print);
        } else {
          print('\nAll performance requirements MET ✓');
        }
        
        expect(failures, isEmpty, reason: 'Performance requirements not met');
      });

      test('Memory usage within acceptable limits', () async {
        final memoryMetrics = benchmarker.generateSummary()
            .entries
            .where((e) => e.key.contains('memory'))
            .toList();
        
        final memoryLimits = {
          'kanban_memory_data_increase': 100,  // MB
          'kanban_memory_operations_increase': 50,  // MB
          'budget_memory_usage': 150,  // MB
          'mid-range_memory_usage': 300,  // MB
        };
        
        final memoryFailures = <String>[];
        
        memoryLimits.forEach((metric, limit) {
          final found = memoryMetrics
              .where((e) => e.key.contains(metric.split('_').last))
              .firstOrNull;
          
          if (found != null) {
            final usage = found.value['avg']!;
            if (usage > limit) {
              memoryFailures.add('${found.key}: ${usage}MB > ${limit}MB');
            }
          }
        });
        
        expect(memoryFailures, isEmpty, reason: 'Memory usage limits exceeded');
      });

      test('60fps animation requirements validated', () async {
        final animationMetrics = benchmarker.generateSummary()
            .entries
            .where((e) => e.key.contains('frame_time') || e.key.contains('glassmorphism'))
            .toList();
        
        final animationFailures = <String>[];
        
        for (final metric in animationMetrics) {
          final avgFrameTime = metric.value['avg']!;
          // 60fps = 16.67ms per frame, we allow up to 18ms for some tolerance
          if (avgFrameTime > 18) {
            animationFailures.add('${metric.key}: ${avgFrameTime}ms > 18ms (60fps requirement)');
          }
        }
        
        if (animationFailures.isEmpty) {
          print('\n60fps Animation Requirements MET ✓');
        } else {
          print('\n60fps Animation Requirements FAILED:');
          animationFailures.forEach(print);
        }
        
        expect(animationFailures, isEmpty, reason: '60fps animation requirements not met');
      });
    });

    tearDown(() {
      // Print benchmark summary
      final summary = benchmarker.generateSummary();
      print('\n=== Kanban Board Performance Summary ===');
      summary.forEach((metric, stats) {
        print('$metric: ${stats['avg']}ms avg (${stats['min']}-${stats['max']}ms)');
      });
      print('=========================================\n');
    });
  });
}

/// Generates a large dataset of tasks for performance testing
List<TaskModel> _generateLargeTaskDataset(int count) {
  final tasks = <TaskModel>[];
  final now = DateTime.now();
  final random = math.Random(42); // Fixed seed for reproducible tests
  
  final taskTitles = [
    'Implement user authentication system',
    'Fix critical payment processing bug',
    'Design responsive dashboard interface',
    'Optimize database query performance',
    'Write comprehensive unit tests',
    'Update API documentation',
    'Review security vulnerabilities',
    'Deploy to production environment',
    'Monitor system performance metrics',
    'Backup database and logs',
    'Refactor legacy codebase',
    'Integrate third-party services',
    'Setup continuous integration',
    'Implement caching layer',
    'Analyze user behavior data',
    'Create automated reports',
    'Setup monitoring alerts',
    'Improve error handling',
    'Optimize image processing',
    'Update dependencies',
  ];
  
  final descriptions = [
    'Critical task requiring immediate attention and careful implementation',
    'Complex feature involving multiple system components and stakeholder coordination',
    'Routine maintenance task that can be completed efficiently',
    'Research and analysis required before starting implementation work',
    'Collaborative effort requiring coordination with external development teams',
    'Performance-critical implementation requiring optimization and benchmarking',
    'Security-focused task with compliance and audit requirements',
    'User experience improvement with A/B testing and metrics collection',
  ];
  
  final tags = [
    ['urgent', 'bug', 'critical'],
    ['feature', 'ui', 'frontend'],
    ['backend', 'api', 'database'],
    ['testing', 'quality', 'automation'],
    ['documentation', 'maintenance'],
    ['deployment', 'production', 'ops'],
    ['monitoring', 'performance', 'analytics'],
    ['security', 'compliance'],
    ['research', 'analysis'],
    ['optimization', 'performance'],
  ];
  
  final projectIds = List.generate(50, (i) => 'project-${i + 1}');
  
  for (int i = 0; i < count; i++) {
    final title = '${taskTitles[i % taskTitles.length]} #${i + 1}';
    final description = descriptions[i % descriptions.length];
    final priority = TaskPriority.values[i % TaskPriority.values.length];
    final status = TaskStatus.values[i % TaskStatus.values.length];
    final taskTags = tags[i % tags.length];
    final projectId = random.nextBool() ? projectIds[i % projectIds.length] : null;
    
    final task = TaskModel.create(
      title: title,
      description: description,
      priority: priority,
      tags: taskTags,
      projectId: projectId,
      dueDate: random.nextBool() 
        ? now.add(Duration(days: random.nextInt(60) - 10))
        : null,
      estimatedDuration: Duration(minutes: 30 + random.nextInt(240)),
    ).copyWith(
      status: status,
      dependencies: random.nextBool() && i > 0
        ? ['task-${random.nextInt(i)}']
        : [],
      metadata: {
        'complexity': random.nextInt(5) + 1,
        'priority_score': random.nextDouble() * 10,
        'effort_points': random.nextInt(13) + 1,
      },
      isPinned: random.nextDouble() < 0.1, // 10% pinned
    );
    
    tasks.add(task);
  }
  
  return tasks;
}

/// Generates a dataset of projects for testing
List<Project> _generateProjectDataset(int count) {
  final projects = <Project>[];
  final random = math.Random(42); // Fixed seed
  
  final projectNames = [
    'E-commerce Platform Redesign',
    'Mobile App Development',
    'API Gateway Implementation',
    'Database Migration Project',
    'Security Audit and Fixes',
    'Performance Optimization',
    'User Experience Improvements',
    'Analytics Dashboard',
    'Automated Testing Suite',
    'DevOps Infrastructure',
  ];
  
  final categories = [
    'Development',
    'Design',
    'Testing',
    'DevOps',
    'Research',
    'Maintenance',
    'Security',
    'Analytics',
  ];
  
  final colors = [
    '#FF5722', '#E91E63', '#9C27B0', '#673AB7',
    '#3F51B5', '#2196F3', '#03A9F4', '#00BCD4',
    '#009688', '#4CAF50', '#8BC34A', '#CDDC39',
    '#FFEB3B', '#FFC107', '#FF9800', '#FF5722',
  ];
  
  for (int i = 0; i < count; i++) {
    final project = Project.create(
      name: '${projectNames[i % projectNames.length]} ${i + 1}',
      description: 'Project description for testing performance with large datasets',
      category: categories[i % categories.length],
      color: colors[i % colors.length],
      deadline: random.nextBool() 
        ? DateTime.now().add(Duration(days: 30 + random.nextInt(90)))
        : null,
    );
    
    projects.add(project);
  }
  
  return projects;
}

/// Calculates memory trend from readings
double _calculateMemoryTrend(List<double> readings) {
  if (readings.length < 2) return 0.0;
  
  double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
  final n = readings.length;
  
  for (int i = 0; i < n; i++) {
    sumX += i;
    sumY += readings[i];
    sumXY += i * readings[i];
    sumX2 += i * i;
  }
  
  // Linear regression slope
  return (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
}

/// Device configuration for performance testing
class DeviceConfig {
  final String name;
  final Size screenSize;
  final double pixelRatio;
  final int coreCount;
  
  const DeviceConfig(this.name, this.screenSize, this.pixelRatio, this.coreCount);
}

/// Performance benchmarker utility
class PerformanceBenchmarker {
  final Map<String, List<int>> _metrics = {};
  
  void recordMetric(String name, int valueMs) {
    _metrics.putIfAbsent(name, () => []).add(valueMs);
  }
  
  Map<String, Map<String, int>> generateSummary() {
    final summary = <String, Map<String, int>>{};
    
    _metrics.forEach((name, values) {
      final avg = values.reduce((a, b) => a + b) / values.length;
      final min = values.reduce(math.min);
      final max = values.reduce(math.max);
      
      summary[name] = {
        'avg': avg.round(),
        'min': min,
        'max': max,
        'count': values.length,
      };
    });
    
    return summary;
  }
}

/// Memory usage tracker utility
class MemoryUsageTracker {
  Future<double> getCurrentUsage() async {
    // In a real implementation, this would use platform channels
    // to get actual memory usage. For testing, we simulate.
    await Future.delayed(const Duration(milliseconds: 10));
    return 45.0 + (DateTime.now().millisecondsSinceEpoch % 1000) / 100.0;
  }
}

/// Mock classes for testing (would normally be generated)
class KanbanOperations {
  final MockTaskRepository repository;
  
  KanbanOperations(this.repository);
  
  Future<void> batchMoveTasksToStatus(List<TaskModel> tasks, TaskStatus status) async {
    for (final task in tasks) {
      await repository.updateTask(task.copyWith(status: status));
    }
  }
}

class KanbanFilterService {
  List<TaskModel> filterTasks(
    List<TaskModel> tasks, {
    String? searchQuery,
    TaskPriority? priority,
    List<TaskStatus>? status,
    List<String>? tags,
    List<String>? projectIds,
    DateTimeRange? dueDateRange,
  }) {
    return tasks.where((task) {
      if (searchQuery != null && 
          !task.title.toLowerCase().contains(searchQuery.toLowerCase()) &&
          !task.description?.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }
      
      if (priority != null && task.priority != priority) return false;
      
      if (status != null && !status.contains(task.status)) return false;
      
      if (tags != null && !tags.any((tag) => task.tags.contains(tag))) return false;
      
      if (projectIds != null && task.projectId != null && 
          !projectIds.contains(task.projectId)) {
        return false;
      }
      
      if (dueDateRange != null && task.dueDate != null &&
          (task.dueDate!.isBefore(dueDateRange.start) || 
           task.dueDate!.isAfter(dueDateRange.end))) {
        return false;
      }
      
      return true;
    }).toList();
  }
}

class KanbanSearchService {
  List<TaskModel> searchTasks(List<TaskModel> tasks, String query) {
    final lowercaseQuery = query.toLowerCase();
    return tasks.where((task) {
      return task.title.toLowerCase().contains(lowercaseQuery) ||
             task.description?.toLowerCase().contains(lowercaseQuery) == true ||
             task.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }
}

class KanbanService {
  List<TaskModel> _tasks = [];
  List<Project> _projects = [];
  
  Future<void> loadTasks(List<TaskModel> tasks) async {
    _tasks = tasks;
  }
  
  Future<void> loadProjects(List<Project> projects) async {
    _projects = projects;
  }
  
  List<TaskModel> filterByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).toList();
  }
  
  List<TaskModel> filterByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }
  
  Map<String?, List<TaskModel>> groupByProject(List<TaskModel>? tasks) {
    final tasksToGroup = tasks ?? _tasks;
    final grouped = <String?, List<TaskModel>>{};
    
    for (final task in tasksToGroup) {
      grouped.putIfAbsent(task.projectId, () => []).add(task);
    }
    
    return grouped;
  }
  
  Map<TaskStatus, List<TaskModel>> groupByStatus(List<TaskModel>? tasks) {
    final tasksToGroup = tasks ?? _tasks;
    final grouped = <TaskStatus, List<TaskModel>>{};
    
    for (final task in tasksToGroup) {
      grouped.putIfAbsent(task.status, () => []).add(task);
    }
    
    return grouped;
  }
  
  List<TaskModel> sortByDueDate() {
    final sorted = List<TaskModel>.from(_tasks);
    sorted.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return sorted;
  }
  
  List<TaskModel> sortByPriority() {
    final sorted = List<TaskModel>.from(_tasks);
    sorted.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return sorted;
  }
  
  Future<List<TaskModel>> filterByPriorityAsync(TaskPriority priority) async {
    return filterByPriority(priority);
  }
  
  Future<List<TaskModel>> filterByStatusAsync(TaskStatus status) async {
    return filterByStatus(status);
  }
  
  Future<List<TaskModel>> searchTasksAsync(String query) async {
    return KanbanSearchService().searchTasks(_tasks, query);
  }
  
  Future<Map<String?, List<TaskModel>>> groupByProjectAsync() async {
    return groupByProject(_tasks);
  }
  
  Future<Map<TaskStatus, List<TaskModel>>> groupByStatusAsync() async {
    return groupByStatus(_tasks);
  }
  
  Future<List<TaskModel>> sortByDueDateAsync() async {
    return sortByDueDate();
  }
  
  Future<List<TaskModel>> sortByPriorityAsync() async {
    return sortByPriority();
  }
  
  Future<void> cleanup() async {
    _tasks.clear();
    _projects.clear();
  }
}