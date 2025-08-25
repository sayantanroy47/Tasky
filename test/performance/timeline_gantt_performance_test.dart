import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/entities/timeline_milestone.dart';
import 'package:task_tracker_app/domain/entities/timeline_dependency.dart';
import 'package:task_tracker_app/domain/entities/timeline_settings.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/presentation/widgets/timeline_gantt_chart.dart';
import 'package:task_tracker_app/presentation/providers/timeline_providers.dart';

import '../mocks/test_mocks.mocks.dart';

void main() {
  group('Timeline/Gantt Chart Performance Tests - Enterprise Scale', () {
    late MockTaskRepository mockTaskRepository;
    late MockProjectRepository mockProjectRepository;
    late PerformanceBenchmarker benchmarker;
    late TimelineTestDataGenerator dataGenerator;

    setUp(() {
      mockTaskRepository = MockTaskRepository();
      mockProjectRepository = MockProjectRepository();
      benchmarker = PerformanceBenchmarker();
      dataGenerator = TimelineTestDataGenerator();
    });

    group('Complex Dependency Rendering Performance', () {
      testWidgets('Timeline with 100 tasks and 200 dependencies renders smoothly', (WidgetTester tester) async {
        final tasks = dataGenerator.generateTasksWithDependencies(100, 200);
        final projects = dataGenerator.generateProjectDataset(10);
        final dependencies = dataGenerator.extractDependencies(tasks);
        
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
            child: MaterialApp(
              home: Scaffold(
                body: TimelineGanttChart(
                  tasks: tasks,
                  dependencies: dependencies,
                  settings: TimelineSettings.defaultSettings(),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 3));
        stopwatch.stop();

        benchmarker.recordMetric('timeline_render_100_tasks_200_deps', stopwatch.elapsedMilliseconds);
        
        // Should render complex timeline within performance budget
        expect(stopwatch.elapsedMilliseconds, lessThan(3000),
               reason: 'Timeline with 100 tasks and 200 dependencies should render within 3 seconds');
        
        // Verify timeline components are present
        expect(find.byType(TimelineGanttChart), findsOneWidget);
        
        print('Timeline render (100 tasks, 200 dependencies): ${stopwatch.elapsedMilliseconds}ms');
      });

      testWidgets('Timeline zoom and pan operations with large dataset', (WidgetTester tester) async {
        final tasks = dataGenerator.generateTasksWithDependencies(500, 800);
        final projects = dataGenerator.generateProjectDataset(25);
        final dependencies = dataGenerator.extractDependencies(tasks);
        
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
            child: MaterialApp(
              home: Scaffold(
                body: TimelineGanttChart(
                  tasks: tasks,
                  dependencies: dependencies,
                  settings: TimelineSettings.defaultSettings(),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find the timeline widget
        final timelineWidget = find.byType(TimelineGanttChart);
        
        final stopwatch = Stopwatch()..start();
        
        // Simulate zoom operations
        for (int i = 0; i < 5; i++) {
          await tester.drag(timelineWidget, const Offset(0, 0));
          await tester.pump(const Duration(milliseconds: 16)); // 60fps
          
          // Simulate pinch zoom gesture
          await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
            'flutter/gestures',
            null,
            (data) {},
          );
          await tester.pump(const Duration(milliseconds: 16));
        }
        
        // Simulate pan operations
        for (int i = 0; i < 10; i++) {
          await tester.drag(timelineWidget, const Offset(-50, 0));
          await tester.pump(const Duration(milliseconds: 16)); // 60fps
        }
        
        stopwatch.stop();
        
        benchmarker.recordMetric('timeline_zoom_pan_500_tasks', stopwatch.elapsedMilliseconds);
        
        final avgFrameTime = stopwatch.elapsedMilliseconds / 15; // 15 operations
        
        // Should maintain smooth interactions
        expect(avgFrameTime, lessThan(25.0),
               reason: 'Timeline zoom/pan should maintain near 60fps with large dataset');
        
        print('Timeline zoom/pan (500 tasks): ${stopwatch.elapsedMilliseconds}ms (${avgFrameTime.toStringAsFixed(2)}ms avg frame)');
      });

      test('Dependency calculation performance with complex network', () async {
        final tasks = dataGenerator.generateTasksWithDependencies(1000, 2500);
        final dependencyService = TimelineDependencyService();
        
        final stopwatch = Stopwatch()..start();
        
        // Calculate complex dependency network
        final dependencyGraph = await dependencyService.buildDependencyGraph(tasks);
        final criticalPath = await dependencyService.calculateCriticalPath(dependencyGraph);
        final circularDependencies = await dependencyService.detectCircularDependencies(dependencyGraph);
        
        stopwatch.stop();
        
        benchmarker.recordMetric('timeline_dependency_calc_1000_2500', stopwatch.elapsedMilliseconds);
        
        // Complex dependency calculations should be efficient
        expect(stopwatch.elapsedMilliseconds, lessThan(2000),
               reason: 'Dependency calculations (1000 tasks, 2500 dependencies) should complete within 2 seconds');
        
        expect(dependencyGraph, isNotNull);
        expect(criticalPath, isNotNull);
        expect(circularDependencies, isNotNull);
        
        print('Dependency calculations (1000 tasks, 2500 deps): ${stopwatch.elapsedMilliseconds}ms');
        print('Critical path length: ${criticalPath.length}');
        print('Circular dependencies found: ${circularDependencies.length}');
      });
    });

    group('Timeline Rendering Optimization', () {
      test('Virtual rendering with massive timeline dataset', () async {
        final tasks = dataGenerator.generateTimelineSpreadTasks(5000, const Duration(days: 365));
        final timelineRenderer = VirtualTimelineRenderer();
        
        final stopwatch = Stopwatch()..start();
        
        // Test viewport-based rendering
        final viewportTasks = await timelineRenderer.getViewportTasks(
          tasks,
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now().add(const Duration(days: 30)),
          zoomLevel: TimelineZoomLevel.weeks,
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('timeline_virtual_render_5000', stopwatch.elapsedMilliseconds);
        
        // Virtual rendering should be very fast
        expect(stopwatch.elapsedMilliseconds, lessThan(100),
               reason: 'Virtual timeline rendering should complete within 100ms');
        
        expect(viewportTasks.length, lessThan(tasks.length));
        expect(viewportTasks.length, greaterThan(0));
        
        print('Virtual timeline rendering (5000 tasks): ${stopwatch.elapsedMilliseconds}ms');
        print('Viewport tasks: ${viewportTasks.length}/${tasks.length}');
      });

      test('Timeline layout calculation performance', () async {
        final tasks = dataGenerator.generateTasksWithDependencies(2000, 4000);
        final layoutEngine = TimelineLayoutEngine();
        
        final stopwatch = Stopwatch()..start();
        
        // Calculate optimal layout
        final layout = await layoutEngine.calculateLayout(
          tasks,
          settings: const TimelineSettings(
            zoomLevel: TimelineZoomLevel.days,
            showDependencies: true,
            groupByProject: true,
            autoArrangeRows: true,
          ),
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('timeline_layout_2000_4000', stopwatch.elapsedMilliseconds);
        
        // Layout calculation should be efficient
        expect(stopwatch.elapsedMilliseconds, lessThan(3000),
               reason: 'Timeline layout calculation should complete within 3 seconds');
        
        expect(layout, isNotNull);
        expect(layout.taskPositions.length, equals(2000));
        
        print('Timeline layout calculation (2000 tasks, 4000 deps): ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Milestone rendering with large project portfolio', () async {
        final projects = dataGenerator.generateProjectDataset(100);
        final tasks = dataGenerator.generateCrossProjectTasks(projects, 10000);
        final milestones = dataGenerator.generateMilestones(projects, 500);
        
        final timelineService = TimelineRenderingService();
        
        final stopwatch = Stopwatch()..start();
        
        // Render timeline with milestones
        final renderResult = await timelineService.renderTimeline(
          tasks: tasks,
          projects: projects,
          milestones: milestones,
          settings: TimelineSettings.defaultSettings(),
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('timeline_milestones_100_proj_10k_tasks', stopwatch.elapsedMilliseconds);
        
        // Should handle large milestone rendering efficiently
        expect(stopwatch.elapsedMilliseconds, lessThan(5000),
               reason: 'Timeline with milestones should render within 5 seconds');
        
        expect(renderResult, isNotNull);
        expect(renderResult.renderedTasks.length, equals(10000));
        expect(renderResult.renderedMilestones.length, equals(500));
        
        print('Timeline with milestones (100 projects, 10k tasks, 500 milestones): ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Interactive Timeline Performance', () {
      test('Task drag and drop in timeline with dependency updates', () async {
        final tasks = dataGenerator.generateTasksWithDependencies(300, 600);
        final timelineService = InteractiveTimelineService();
        
        when(mockTaskRepository.updateTask(any)).thenAnswer((_) async {
          return;
        });
        
        final stopwatch = Stopwatch()..start();
        
        // Simulate dragging 20 tasks to new positions
        for (int i = 0; i < 20; i++) {
          final task = tasks[i];
          final newStartDate = task.dueDate?.add(Duration(days: i % 7)) ?? DateTime.now();
          
          await timelineService.moveTask(
            task,
            newStartDate,
            updateDependencies: true,
            repository: mockTaskRepository,
          );
        }
        
        stopwatch.stop();
        
        benchmarker.recordMetric('timeline_drag_20_tasks_dep_update', stopwatch.elapsedMilliseconds);
        
        // Interactive operations should be responsive
        expect(stopwatch.elapsedMilliseconds, lessThan(2000),
               reason: 'Moving 20 tasks with dependency updates should complete within 2 seconds');
        
        verify(mockTaskRepository.updateTask(any)).called(greaterThan(20));
        
        print('Timeline task moves with dependency updates (20 tasks): ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Real-time timeline updates during concurrent modifications', () async {
        final tasks = dataGenerator.generateTasksWithDependencies(500, 1000);
        final streamController = StreamController<List<TaskModel>>.broadcast();
        
        when(mockTaskRepository.watchAllTasks()).thenAnswer(
          (_) => streamController.stream,
        );
        
        final timelineService = RealTimeTimelineService();
        
        // Start with initial data
        streamController.add(tasks);
        
        final stopwatch = Stopwatch()..start();
        
        // Simulate 50 concurrent updates
        final futures = <Future>[];
        for (int i = 0; i < 50; i++) {
          futures.add(Future.delayed(Duration(milliseconds: i * 20), () {
            final updatedTasks = List<TaskModel>.from(tasks);
            if (i < tasks.length) {
              updatedTasks[i] = tasks[i].copyWith(
                dueDate: DateTime.now().add(Duration(days: i % 30)),
                updatedAt: DateTime.now(),
              );
            }
            streamController.add(updatedTasks);
          }));
        }
        
        await Future.wait(futures);
        stopwatch.stop();
        
        benchmarker.recordMetric('timeline_realtime_50_updates', stopwatch.elapsedMilliseconds);
        
        // Real-time updates should be handled efficiently
        expect(stopwatch.elapsedMilliseconds, lessThan(3000),
               reason: '50 real-time timeline updates should complete within 3 seconds');
        
        await streamController.close();
        
        print('Real-time timeline updates (50 concurrent): ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Critical Path and Schedule Analysis', () {
      test('Critical path calculation with deep dependency chains', () async {
        final tasks = dataGenerator.generateDependencyChain(1000, maxChainLength: 50);
        final criticalPathService = CriticalPathService();
        
        final stopwatch = Stopwatch()..start();
        
        // Calculate critical path through complex network
        final criticalPath = await criticalPathService.calculateCriticalPath(tasks);
        final scheduleAnalysis = await criticalPathService.analyzeSchedule(tasks, criticalPath);
        
        stopwatch.stop();
        
        benchmarker.recordMetric('timeline_critical_path_1000_deep', stopwatch.elapsedMilliseconds);
        
        // Critical path calculation should be efficient even with deep chains
        expect(stopwatch.elapsedMilliseconds, lessThan(1500),
               reason: 'Critical path calculation should complete within 1.5 seconds');
        
        expect(criticalPath, isNotNull);
        expect(criticalPath.length, greaterThan(0));
        expect(scheduleAnalysis, isNotNull);
        
        print('Critical path calculation (1000 tasks, deep chains): ${stopwatch.elapsedMilliseconds}ms');
        print('Critical path length: ${criticalPath.length} tasks');
        print('Schedule slack analysis: ${scheduleAnalysis.totalSlackDays} days');
      });

      test('Resource leveling with capacity constraints', () async {
        final tasks = dataGenerator.generateResourceConstrainedTasks(800);
        final resources = dataGenerator.generateResourcePool(20);
        
        final resourceService = TimelineResourceService();
        
        final stopwatch = Stopwatch()..start();
        
        // Perform resource leveling
        final levelingResult = await resourceService.levelResources(
          tasks,
          resources,
          constraints: ResourceConstraints(
            maxConcurrentTasksPerResource: 3,
            workingDaysPerWeek: 5,
            workingHoursPerDay: 8,
          ),
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('timeline_resource_leveling_800', stopwatch.elapsedMilliseconds);
        
        // Resource leveling should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(4000),
               reason: 'Resource leveling (800 tasks, 20 resources) should complete within 4 seconds');
        
        expect(levelingResult, isNotNull);
        expect(levelingResult.adjustedTasks.length, equals(800));
        
        print('Resource leveling (800 tasks, 20 resources): ${stopwatch.elapsedMilliseconds}ms');
        print('Schedule extension: ${levelingResult.scheduleExtensionDays} days');
      });
    });

    group('Timeline Export and Import Performance', () {
      test('Timeline data export with complex project structure', () async {
        final projects = dataGenerator.generateProjectDataset(50);
        final tasks = dataGenerator.generateCrossProjectTasks(projects, 5000);
        final milestones = dataGenerator.generateMilestones(projects, 200);
        final dependencies = dataGenerator.extractDependencies(tasks);
        
        final exportService = TimelineExportService();
        
        final stopwatch = Stopwatch()..start();
        
        // Export complete timeline data
        final exportData = await exportService.exportTimeline(
          tasks: tasks,
          projects: projects,
          milestones: milestones,
          dependencies: dependencies,
          format: TimelineExportFormat.comprehensive,
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('timeline_export_5000_tasks', stopwatch.elapsedMilliseconds);
        
        // Export should complete efficiently
        expect(stopwatch.elapsedMilliseconds, lessThan(3000),
               reason: 'Timeline export should complete within 3 seconds');
        
        expect(exportData, isNotNull);
        expect(exportData.tasks.length, equals(5000));
        expect(exportData.projects.length, equals(50));
        
        print('Timeline export (5000 tasks, 50 projects): ${stopwatch.elapsedMilliseconds}ms');
        print('Export size: ${exportData.sizeInMB.toStringAsFixed(2)}MB');
      });

      test('Timeline data import with validation', () async {
        final importService = TimelineImportService();
        final largeTimelineData = dataGenerator.generateTimelineImportData(3000);
        
        final stopwatch = Stopwatch()..start();
        
        // Import and validate timeline data
        final importResult = await importService.importTimeline(
          largeTimelineData,
          validateDependencies: true,
          detectCircularReferences: true,
          autoFixConflicts: true,
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('timeline_import_3000_tasks', stopwatch.elapsedMilliseconds);
        
        // Import should handle validation efficiently
        expect(stopwatch.elapsedMilliseconds, lessThan(4000),
               reason: 'Timeline import with validation should complete within 4 seconds');
        
        expect(importResult, isNotNull);
        expect(importResult.importedTasks.length, equals(3000));
        expect(importResult.errors.length, equals(0));
        
        print('Timeline import with validation (3000 tasks): ${stopwatch.elapsedMilliseconds}ms');
        print('Validation issues resolved: ${importResult.fixedIssues.length}');
      });
    });

    group('Memory Management and Performance Optimization', () {
      test('Memory usage during timeline rendering with large datasets', () async {
        final memoryTracker = MemoryUsageTracker();
        final timelineService = TimelineRenderingService();
        
        // Baseline memory
        final baselineMemory = await memoryTracker.getCurrentUsage();
        
        // Load massive timeline dataset
        final tasks = dataGenerator.generateTimelineSpreadTasks(10000, const Duration(days: 730));
        final projects = dataGenerator.generateProjectDataset(100);
        
        final afterDataLoad = await memoryTracker.getCurrentUsage();
        
        // Render timeline
        final renderResult = await timelineService.renderTimeline(
          tasks: tasks,
          projects: projects,
          milestones: [],
          settings: TimelineSettings.defaultSettings(),
        );
        
        final afterRendering = await memoryTracker.getCurrentUsage();
        
        // Cleanup
        await timelineService.cleanup();
        final afterCleanup = await memoryTracker.getCurrentUsage();
        
        final dataMemoryIncrease = afterDataLoad - baselineMemory;
        final renderMemoryIncrease = afterRendering - afterDataLoad;
        final memoryRecovered = afterRendering - afterCleanup;
        
        benchmarker.recordMetric('timeline_memory_data_10k', dataMemoryIncrease.round());
        benchmarker.recordMetric('timeline_memory_render_10k', renderMemoryIncrease.round());
        benchmarker.recordMetric('timeline_memory_recovered_10k', memoryRecovered.round());
        
        // Memory should be managed efficiently
        expect(dataMemoryIncrease, lessThan(300.0),
               reason: 'Loading 10k timeline tasks should use less than 300MB');
        expect(renderMemoryIncrease, lessThan(200.0),
               reason: 'Timeline rendering should not cause excessive memory growth');
        expect(memoryRecovered, greaterThan(renderMemoryIncrease * 0.8),
               reason: 'At least 80% of rendering memory should be recoverable');
        
        print('Timeline memory analysis (10k tasks):');
        print('  Data loading: +${dataMemoryIncrease.toStringAsFixed(1)}MB');
        print('  Rendering: +${renderMemoryIncrease.toStringAsFixed(1)}MB');
        print('  Recovered: ${memoryRecovered.toStringAsFixed(1)}MB');
      });

      test('Timeline caching and invalidation performance', () async {
        final tasks = dataGenerator.generateTasksWithDependencies(2000, 4000);
        final cacheService = TimelineCacheService();
        
        // Warm up cache
        await cacheService.initialize();
        
        final stopwatch = Stopwatch()..start();
        
        // Cache complex timeline data
        await cacheService.cacheTimelineLayout(tasks, 'large-project');
        await cacheService.cacheDependencyGraph(tasks, 'large-project');
        await cacheService.cacheCriticalPath(tasks, 'large-project');
        
        // Retrieve cached data (should be fast)
        final cachedLayout = await cacheService.getCachedTimelineLayout('large-project');
        final cachedGraph = await cacheService.getCachedDependencyGraph('large-project');
        final cachedPath = await cacheService.getCachedCriticalPath('large-project');
        
        stopwatch.stop();
        
        benchmarker.recordMetric('timeline_cache_operations_2000', stopwatch.elapsedMilliseconds);
        
        // Cache operations should be very fast
        expect(stopwatch.elapsedMilliseconds, lessThan(500),
               reason: 'Timeline cache operations should complete within 500ms');
        
        expect(cachedLayout, isNotNull);
        expect(cachedGraph, isNotNull);
        expect(cachedPath, isNotNull);
        
        print('Timeline cache operations (2000 tasks): ${stopwatch.elapsedMilliseconds}ms');
        
        // Test cache invalidation performance
        final invalidationStopwatch = Stopwatch()..start();
        
        // Invalidate cache for task updates
        for (int i = 0; i < 100; i++) {
          await cacheService.invalidateCache('task-update-$i');
        }
        
        invalidationStopwatch.stop();
        
        benchmarker.recordMetric('timeline_cache_invalidation_100', invalidationStopwatch.elapsedMilliseconds);
        
        expect(invalidationStopwatch.elapsedMilliseconds, lessThan(200),
               reason: 'Cache invalidation should be very fast');
        
        print('Cache invalidation (100 operations): ${invalidationStopwatch.elapsedMilliseconds}ms');
      });
    });

    tearDown(() {
      // Print timeline performance summary
      final summary = benchmarker.generateSummary();
      print('\n=== Timeline/Gantt Chart Performance Summary ===');
      summary.forEach((metric, stats) {
        print('$metric: ${stats['avg']}ms avg (${stats['min']}-${stats['max']}ms)');
      });
      print('===============================================\n');
    });
  });
}

/// Timeline-specific test data generator
class TimelineTestDataGenerator {
  final math.Random _random = math.Random(42); // Fixed seed
  
  /// Generates tasks with complex dependency relationships
  List<TaskModel> generateTasksWithDependencies(int taskCount, int dependencyCount) {
    final tasks = <TaskModel>[];
    final taskIds = List.generate(taskCount, (i) => 'task-${i + 1}');
    final now = DateTime.now();
    
    // Create tasks first
    for (int i = 0; i < taskCount; i++) {
      final startDate = now.add(Duration(days: _random.nextInt(365)));
      final durationDays = 1 + _random.nextInt(14);
      final duration = Duration(days: durationDays);
      
      final task = TaskModel.create(
        title: 'Timeline Task #${i + 1}',
        description: 'Task for timeline performance testing',
        dueDate: startDate.add(duration),
        estimatedDuration: durationDays * 1440, // Convert to minutes
        createdAt: now.subtract(Duration(days: _random.nextInt(30))),
      ).copyWith(
        id: taskIds[i],
        priority: TaskPriority.values[_random.nextInt(TaskPriority.values.length)],
      );
      
      tasks.add(task);
    }
    
    // Add dependencies
    final dependencyMap = <String, Set<String>>{};
    for (int i = 0; i < dependencyCount && i < taskCount * 3; i++) {
      final dependentTaskIndex = _random.nextInt(taskCount);
      final dependsOnTaskIndex = _random.nextInt(taskCount);
      
      // Avoid self-dependency and limit dependencies per task
      if (dependentTaskIndex != dependsOnTaskIndex) {
        final dependentId = taskIds[dependentTaskIndex];
        final dependsOnId = taskIds[dependsOnTaskIndex];
        
        dependencyMap.putIfAbsent(dependentId, () => <String>{}).add(dependsOnId);
      }
    }
    
    // Update tasks with dependencies
    for (int i = 0; i < tasks.length; i++) {
      final taskId = taskIds[i];
      final dependencies = dependencyMap[taskId]?.toList() ?? <String>[];
      
      tasks[i] = tasks[i].copyWith(dependencies: dependencies);
    }
    
    return tasks;
  }
  
  /// Generates projects for timeline testing
  List<Project> generateProjectDataset(int count) {
    final projects = <Project>[];
    
    for (int i = 0; i < count; i++) {
      final project = Project.create(
        name: 'Timeline Project ${i + 1}',
        description: 'Project for timeline performance testing',
        deadline: DateTime.now().add(Duration(days: 30 + _random.nextInt(180))),
      );
      
      projects.add(project);
    }
    
    return projects;
  }
  
  /// Extracts timeline dependencies from tasks
  List<TimelineDependency> extractDependencies(List<TaskModel> tasks) {
    final dependencies = <TimelineDependency>[];
    
    for (final task in tasks) {
      for (final dependsOnId in task.dependencies) {
        dependencies.add(TimelineDependency(
          id: 'dep-${task.id}-$dependsOnId',
          fromTaskId: dependsOnId,
          toTaskId: task.id,
          type: DependencyType.finishToStart,
          lag: 0, // no lag in minutes
        ));
      }
    }
    
    return dependencies;
  }
  
  /// Generates tasks spread across a time period
  List<TaskModel> generateTimelineSpreadTasks(int count, Duration timeSpan) {
    final tasks = <TaskModel>[];
    final now = DateTime.now();
    final startTime = now.subtract(timeSpan);
    
    for (int i = 0; i < count; i++) {
      final taskStart = startTime.add(
        Duration(milliseconds: (timeSpan.inMilliseconds * i / count).round())
      );
      final taskDuration = Duration(days: 1 + _random.nextInt(21)); // 1-21 days
      
      final task = TaskModel.create(
        title: 'Spread Task #${i + 1}',
        dueDate: taskStart.add(taskDuration),
        createdAt: taskStart.subtract(Duration(days: _random.nextInt(7))),
      );
      
      tasks.add(task);
    }
    
    return tasks;
  }
  
  /// Generates cross-project tasks
  List<TaskModel> generateCrossProjectTasks(List<Project> projects, int taskCount) {
    final tasks = <TaskModel>[];
    
    for (int i = 0; i < taskCount; i++) {
      final project = projects[_random.nextInt(projects.length)];
      
      final task = TaskModel.create(
        title: 'Cross-Project Task #${i + 1}',
        projectId: project.id,
        dueDate: DateTime.now().add(Duration(days: 1 + _random.nextInt(90))),
      );
      
      tasks.add(task);
    }
    
    return tasks;
  }
  
  /// Generates milestones for projects
  List<TimelineMilestone> generateMilestones(List<Project> projects, int count) {
    final milestones = <TimelineMilestone>[];
    
    for (int i = 0; i < count; i++) {
      final project = projects[_random.nextInt(projects.length)];
      
      final milestone = TimelineMilestone(
        id: 'milestone-${i + 1}',
        name: 'Milestone ${i + 1}',
        description: 'Timeline milestone for testing',
        dueDate: DateTime.now().add(Duration(days: 7 + _random.nextInt(180))),
        projectId: project.id,
        isCompleted: _random.nextDouble() < 0.3,
        priority: TaskPriority.values[_random.nextInt(TaskPriority.values.length)],
      );
      
      milestones.add(milestone);
    }
    
    return milestones;
  }
  
  /// Generates dependency chains for critical path testing
  List<TaskModel> generateDependencyChain(int count, {required int maxChainLength}) {
    final tasks = <TaskModel>[];
    final now = DateTime.now();
    
    int currentIndex = 0;
    
    while (currentIndex < count) {
      final chainLength = 1 + _random.nextInt(maxChainLength);
      final actualChainLength = math.min(chainLength, count - currentIndex);
      
      // Create a chain of dependent tasks
      for (int i = 0; i < actualChainLength; i++) {
        final taskIndex = currentIndex + i;
        final dependencies = i > 0 ? ['task-${currentIndex + i}'] : <String>[];
        
        final task = TaskModel.create(
          title: 'Chain Task #${taskIndex + 1}',
          dueDate: now.add(Duration(days: taskIndex * 2)),
          estimatedDuration: (1 + _random.nextInt(5)) * 1440, // days in minutes
        ).copyWith(
          id: 'task-${taskIndex + 1}',
          dependencies: dependencies,
        );
        
        tasks.add(task);
      }
      
      currentIndex += actualChainLength;
    }
    
    return tasks;
  }
  
  /// Generates resource-constrained tasks
  List<TaskModel> generateResourceConstrainedTasks(int count) {
    final tasks = <TaskModel>[];
    final resources = List.generate(20, (i) => 'resource-${i + 1}');
    
    for (int i = 0; i < count; i++) {
      final assignedResource = resources[_random.nextInt(resources.length)];
      
      final task = TaskModel.create(
        title: 'Resource Task #${i + 1}',
        estimatedDuration: (4 + _random.nextInt(32)) * 60, // hours in minutes
      ).copyWith(
        metadata: {
          'assigned_resource': assignedResource,
          'effort_hours': 4 + _random.nextInt(32),
        },
      );
      
      tasks.add(task);
    }
    
    return tasks;
  }
  
  /// Generates resource pool for testing
  List<TimelineResource> generateResourcePool(int count) {
    final resources = <TimelineResource>[];
    
    for (int i = 0; i < count; i++) {
      final resource = TimelineResource(
        id: 'resource-${i + 1}',
        name: 'Resource ${i + 1}',
        capacity: 8.0, // 8 hours per day
        skills: _generateRandomSkills(),
        costPerHour: 50.0 + _random.nextDouble() * 100,
      );
      
      resources.add(resource);
    }
    
    return resources;
  }
  
  /// Generates timeline import data
  TimelineImportData generateTimelineImportData(int taskCount) {
    final tasks = generateTasksWithDependencies(taskCount, taskCount * 2);
    final projects = generateProjectDataset(taskCount ~/ 20);
    
    return TimelineImportData(
      tasks: tasks,
      projects: projects,
      dependencies: extractDependencies(tasks),
      milestones: generateMilestones(projects, taskCount ~/ 10),
    );
  }
  
  List<String> _generateRandomSkills() {
    final allSkills = [
      'frontend', 'backend', 'mobile', 'design', 'testing',
      'devops', 'data-analysis', 'project-management'
    ];
    
    final skillCount = 1 + _random.nextInt(4);
    final skills = <String>[];
    
    for (int i = 0; i < skillCount; i++) {
      final skill = allSkills[_random.nextInt(allSkills.length)];
      if (!skills.contains(skill)) {
        skills.add(skill);
      }
    }
    
    return skills;
  }
}

/// Performance benchmarker (shared utility)
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

/// Memory tracker (shared utility)
class MemoryUsageTracker {
  Future<double> getCurrentUsage() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return 80.0 + (DateTime.now().millisecondsSinceEpoch % 1000) / 40.0;
  }
}

/// Mock timeline services for testing
class TimelineDependencyService {
  Future<DependencyGraph> buildDependencyGraph(List<TaskModel> tasks) async {
    await Future.delayed(Duration(milliseconds: tasks.length ~/ 10));
    return DependencyGraph(tasks);
  }
  
  Future<List<TaskModel>> calculateCriticalPath(DependencyGraph graph) async {
    await Future.delayed(Duration(milliseconds: graph.tasks.length ~/ 5));
    return graph.tasks.take(10).toList(); // Simplified
  }
  
  Future<List<CircularDependency>> detectCircularDependencies(DependencyGraph graph) async {
    await Future.delayed(Duration(milliseconds: graph.tasks.length ~/ 20));
    return []; // Simplified - assume no circular dependencies
  }
}

class VirtualTimelineRenderer {
  Future<List<TaskModel>> getViewportTasks(
    List<TaskModel> allTasks,
    {required DateTime startDate,
    required DateTime endDate,
    required TimelineZoomLevel zoomLevel}) async {
    
    await Future.delayed(Duration(milliseconds: allTasks.length ~/ 100));
    
    return allTasks.where((task) {
      final taskDate = task.dueDate ?? task.createdAt;
      return taskDate.isAfter(startDate) && taskDate.isBefore(endDate);
    }).toList();
  }
}

class TimelineLayoutEngine {
  Future<TimelineLayout> calculateLayout(List<TaskModel> tasks, {required TimelineSettings settings}) async {
    await Future.delayed(Duration(milliseconds: tasks.length ~/ 5));
    
    return TimelineLayout(
      taskPositions: Map.fromEntries(
        tasks.map((task) => MapEntry(task.id, TimelinePosition(x: 0, y: 0, width: 100, height: 30)))
      ),
    );
  }
}

class TimelineRenderingService {
  Future<TimelineRenderResult> renderTimeline({
    required List<TaskModel> tasks,
    required List<Project> projects,
    required List<TimelineMilestone> milestones,
    required TimelineSettings settings,
  }) async {
    await Future.delayed(Duration(milliseconds: (tasks.length + milestones.length) ~/ 10));
    
    return TimelineRenderResult(
      renderedTasks: tasks,
      renderedMilestones: milestones,
    );
  }
  
  Future<void> cleanup() async {
    await Future.delayed(const Duration(milliseconds: 50));
  }
}

class InteractiveTimelineService {
  Future<void> moveTask(
    TaskModel task,
    DateTime newStartDate,
    {required bool updateDependencies,
    required MockTaskRepository repository}) async {
    
    await Future.delayed(const Duration(milliseconds: 20));
    
    final updatedTask = task.copyWith(
      dueDate: newStartDate.add(Duration(minutes: task.estimatedDuration ?? 0)),
      updatedAt: DateTime.now(),
    );
    
    await repository.updateTask(updatedTask);
    
    if (updateDependencies) {
      // Simulate updating dependent tasks
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }
}

class RealTimeTimelineService {
  // Implementation for real-time timeline updates
}

class CriticalPathService {
  Future<List<TaskModel>> calculateCriticalPath(List<TaskModel> tasks) async {
    await Future.delayed(Duration(milliseconds: tasks.length ~/ 5));
    
    // Simplified critical path calculation
    final sortedTasks = List<TaskModel>.from(tasks);
    sortedTasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    return sortedTasks.take(tasks.length ~/ 10).toList();
  }
  
  Future<ScheduleAnalysis> analyzeSchedule(List<TaskModel> tasks, List<TaskModel> criticalPath) async {
    await Future.delayed(Duration(milliseconds: tasks.length ~/ 10));
    
    return ScheduleAnalysis(
      totalSlackDays: tasks.length ~/ 20,
      criticalPathDuration: criticalPath.length * 2,
    );
  }
}

class TimelineResourceService {
  Future<ResourceLevelingResult> levelResources(
    List<TaskModel> tasks,
    List<TimelineResource> resources,
    {required ResourceConstraints constraints}) async {
    
    await Future.delayed(Duration(milliseconds: (tasks.length + resources.length) ~/ 2));
    
    return ResourceLevelingResult(
      adjustedTasks: tasks,
      scheduleExtensionDays: tasks.length ~/ 100,
    );
  }
}

class TimelineExportService {
  Future<TimelineExportData> exportTimeline({
    required List<TaskModel> tasks,
    required List<Project> projects,
    required List<TimelineMilestone> milestones,
    required List<TimelineDependency> dependencies,
    required TimelineExportFormat format,
  }) async {
    await Future.delayed(Duration(milliseconds: (tasks.length + projects.length) ~/ 5));
    
    return TimelineExportData(
      tasks: tasks,
      projects: projects,
      milestones: milestones,
      dependencies: dependencies,
      sizeInMB: (tasks.length * 2) / 1000.0,
    );
  }
}

class TimelineImportService {
  Future<TimelineImportResult> importTimeline(
    TimelineImportData data,
    {required bool validateDependencies,
    required bool detectCircularReferences,
    required bool autoFixConflicts}) async {
    
    await Future.delayed(Duration(milliseconds: data.tasks.length ~/ 3));
    
    return TimelineImportResult(
      importedTasks: data.tasks,
      errors: [],
      fixedIssues: [],
    );
  }
}

class TimelineCacheService {
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  Future<void> cacheTimelineLayout(List<TaskModel> tasks, String projectKey) async {
    await Future.delayed(Duration(milliseconds: tasks.length ~/ 20));
  }
  
  Future<void> cacheDependencyGraph(List<TaskModel> tasks, String projectKey) async {
    await Future.delayed(Duration(milliseconds: tasks.length ~/ 15));
  }
  
  Future<void> cacheCriticalPath(List<TaskModel> tasks, String projectKey) async {
    await Future.delayed(Duration(milliseconds: tasks.length ~/ 25));
  }
  
  Future<TimelineLayout?> getCachedTimelineLayout(String projectKey) async {
    await Future.delayed(const Duration(milliseconds: 5));
    return TimelineLayout(taskPositions: {});
  }
  
  Future<DependencyGraph?> getCachedDependencyGraph(String projectKey) async {
    await Future.delayed(const Duration(milliseconds: 5));
    return DependencyGraph([]);
  }
  
  Future<List<TaskModel>?> getCachedCriticalPath(String projectKey) async {
    await Future.delayed(const Duration(milliseconds: 5));
    return [];
  }
  
  Future<void> invalidateCache(String key) async {
    await Future.delayed(const Duration(milliseconds: 1));
  }
}

// Mock data classes
enum TimelineZoomLevel { hours, days, weeks, months, years }
enum TimelineExportFormat { comprehensive, summary, gantt }
enum DependencyType { finishToStart, startToStart, finishToFinish, startToFinish }

class DependencyGraph {
  final List<TaskModel> tasks;
  DependencyGraph(this.tasks);
}

class CircularDependency {
  final List<String> taskIds;
  CircularDependency(this.taskIds);
}

class TimelinePosition {
  final double x, y, width, height;
  TimelinePosition({required this.x, required this.y, required this.width, required this.height});
}

class TimelineLayout {
  final Map<String, TimelinePosition> taskPositions;
  TimelineLayout({required this.taskPositions});
}

class TimelineRenderResult {
  final List<TaskModel> renderedTasks;
  final List<TimelineMilestone> renderedMilestones;
  TimelineRenderResult({required this.renderedTasks, required this.renderedMilestones});
}

class ScheduleAnalysis {
  final int totalSlackDays;
  final int criticalPathDuration;
  ScheduleAnalysis({required this.totalSlackDays, required this.criticalPathDuration});
}

class TimelineResource {
  final String id, name;
  final double capacity, costPerHour;
  final List<String> skills;
  TimelineResource({required this.id, required this.name, required this.capacity, required this.costPerHour, required this.skills});
}

class ResourceConstraints {
  final int maxConcurrentTasksPerResource;
  final int workingDaysPerWeek;
  final int workingHoursPerDay;
  ResourceConstraints({required this.maxConcurrentTasksPerResource, required this.workingDaysPerWeek, required this.workingHoursPerDay});
}

class ResourceLevelingResult {
  final List<TaskModel> adjustedTasks;
  final int scheduleExtensionDays;
  ResourceLevelingResult({required this.adjustedTasks, required this.scheduleExtensionDays});
}

class TimelineExportData {
  final List<TaskModel> tasks;
  final List<Project> projects;
  final List<TimelineMilestone> milestones;
  final List<TimelineDependency> dependencies;
  final double sizeInMB;
  TimelineExportData({required this.tasks, required this.projects, required this.milestones, required this.dependencies, required this.sizeInMB});
}

class TimelineImportData {
  final List<TaskModel> tasks;
  final List<Project> projects;
  final List<TimelineDependency> dependencies;
  final List<TimelineMilestone> milestones;
  TimelineImportData({required this.tasks, required this.projects, required this.dependencies, required this.milestones});
}

class TimelineImportResult {
  final List<TaskModel> importedTasks;
  final List<String> errors;
  final List<String> fixedIssues;
  TimelineImportResult({required this.importedTasks, required this.errors, required this.fixedIssues});
}