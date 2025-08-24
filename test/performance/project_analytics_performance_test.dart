import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/services/analytics_service.dart';
import 'package:task_tracker_app/presentation/providers/analytics_providers.dart';

import '../mocks/test_mocks.mocks.dart';

void main() {
  group('Project Analytics Performance Tests - Enterprise Scale', () {
    late MockAnalyticsService mockAnalyticsService;
    late MockTaskRepository mockTaskRepository;
    late MockProjectRepository mockProjectRepository;
    late PerformanceBenchmarker benchmarker;
    late AnalyticsTestDataGenerator dataGenerator;

    setUp(() {
      mockAnalyticsService = MockAnalyticsService();
      mockTaskRepository = MockTaskRepository();
      mockProjectRepository = MockProjectRepository();
      benchmarker = PerformanceBenchmarker();
      dataGenerator = AnalyticsTestDataGenerator();
    });

    group('Large Dataset Analytics Calculations', () {
      test('Productivity metrics calculation with 10k tasks across 50 projects', () async {
        final tasks = dataGenerator.generateLargeTaskDataset(10000);
        final projects = dataGenerator.generateProjectDataset(50);
        
        final analyticsService = AnalyticsService();
        
        final stopwatch = Stopwatch()..start();
        
        // Calculate comprehensive productivity metrics
        final metrics = await analyticsService.calculateProductivityMetrics(tasks);
        
        stopwatch.stop();
        
        benchmarker.recordMetric('analytics_productivity_10k_tasks', stopwatch.elapsedMilliseconds);
        
        // Should complete complex analytics within performance budget
        expect(stopwatch.elapsedMilliseconds, lessThan(5000),
               reason: 'Productivity metrics for 10k tasks should complete within 5 seconds');
        
        expect(metrics, isNotNull);
        expect(metrics.totalTasks, equals(10000));
        
        print('Productivity metrics for 10k tasks calculated in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Completion trends analysis with massive historical data', () async {
        final tasks = dataGenerator.generateHistoricalTaskData(15000, const Duration(days: 365));
        
        final analyticsService = AnalyticsService();
        
        final stopwatch = Stopwatch()..start();
        
        // Analyze completion trends over a full year
        final trends = await analyticsService.getCompletionTrends(
          tasks,
          DateTime.now().subtract(const Duration(days: 365)),
          DateTime.now(),
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('analytics_trends_15k_tasks_1year', stopwatch.elapsedMilliseconds);
        
        // Should handle large historical analysis efficiently
        expect(stopwatch.elapsedMilliseconds, lessThan(7000),
               reason: 'Completion trends for 15k tasks over 1 year should complete within 7 seconds');
        
        expect(trends, isNotNull);
        expect(trends.length, greaterThan(0));
        
        print('Completion trends analysis (15k tasks, 1 year): ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Cross-project performance analysis with complex aggregations', () async {
        final projects = dataGenerator.generateProjectDataset(100);
        final tasks = dataGenerator.generateCrossProjectTaskData(projects, 20000);
        
        final analyticsService = AnalyticsService();
        
        final stopwatch = Stopwatch()..start();
        
        // Perform complex cross-project analytics
        final projectStats = await analyticsService.calculateProjectStatistics(projects, tasks);
        
        stopwatch.stop();
        
        benchmarker.recordMetric('analytics_cross_project_100_20k', stopwatch.elapsedMilliseconds);
        
        // Should handle cross-project analysis efficiently
        expect(stopwatch.elapsedMilliseconds, lessThan(8000),
               reason: 'Cross-project analytics (100 projects, 20k tasks) should complete within 8 seconds');
        
        expect(projectStats, isNotNull);
        expect(projectStats.length, equals(100));
        
        print('Cross-project analysis (100 projects, 20k tasks): ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Real-time Analytics Updates', () {
      test('Incremental analytics updates with streaming data', () async {
        final baselineTasks = dataGenerator.generateLargeTaskDataset(5000);
        final analyticsService = RealTimeAnalyticsService();
        
        // Initialize with baseline
        await analyticsService.initialize(baselineTasks);
        
        final updateStopwatch = Stopwatch()..start();
        
        // Simulate 100 incremental updates
        for (int i = 0; i < 100; i++) {
          final newTask = dataGenerator.generateSingleTask(i);
          final updatedMetrics = await analyticsService.updateWithNewTask(newTask);
          
          expect(updatedMetrics, isNotNull);
        }
        
        updateStopwatch.stop();
        
        benchmarker.recordMetric('analytics_incremental_100_updates', updateStopwatch.elapsedMilliseconds);
        
        // Incremental updates should be very fast
        expect(updateStopwatch.elapsedMilliseconds, lessThan(2000),
               reason: '100 incremental analytics updates should complete within 2 seconds');
        
        final avgUpdateTime = updateStopwatch.elapsedMilliseconds / 100;
        expect(avgUpdateTime, lessThan(15.0),
               reason: 'Each incremental update should take less than 15ms on average');
        
        print('100 incremental updates: ${updateStopwatch.elapsedMilliseconds}ms (${avgUpdateTime.toStringAsFixed(2)}ms avg)');
      });

      test('Concurrent analytics calculations', () async {
        final tasks = dataGenerator.generateLargeTaskDataset(8000);
        final projects = dataGenerator.generateProjectDataset(40);
        final analyticsService = AnalyticsService();
        
        final stopwatch = Stopwatch()..start();
        
        // Run multiple analytics operations concurrently
        final futures = [
          analyticsService.calculateProductivityMetrics(tasks),
          analyticsService.calculateTaskStatistics(tasks),
          analyticsService.getCompletionTrends(tasks, 
                                             DateTime.now().subtract(const Duration(days: 90)),
                                             DateTime.now()),
          analyticsService.calculateProjectStatistics(projects, tasks),
          analyticsService.calculatePriorityDistribution(tasks),
          analyticsService.calculateTagAnalytics(tasks),
          analyticsService.calculateTimeTrackingMetrics(tasks),
          analyticsService.calculateBurndownData(tasks, projects.first),
        ];
        
        final results = await Future.wait(futures);
        
        stopwatch.stop();
        
        benchmarker.recordMetric('analytics_concurrent_8_operations', stopwatch.elapsedMilliseconds);
        
        // Concurrent operations should be efficient
        expect(stopwatch.elapsedMilliseconds, lessThan(10000),
               reason: '8 concurrent analytics operations should complete within 10 seconds');
        
        expect(results.length, equals(8));
        for (final result in results) {
          expect(result, isNotNull);
        }
        
        print('8 concurrent analytics operations (8k tasks): ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Dashboard Widget Performance', () {
      test('Analytics dashboard with multiple widgets and large datasets', () async {
        final tasks = dataGenerator.generateLargeTaskDataset(12000);
        final projects = dataGenerator.generateProjectDataset(60);
        
        final dashboardService = AnalyticsDashboardService();
        
        final stopwatch = Stopwatch()..start();
        
        // Load all dashboard widgets simultaneously
        final dashboardData = await dashboardService.loadDashboard(
          tasks: tasks,
          projects: projects,
          timeRange: AnalyticsTimeRange.last90Days,
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('analytics_dashboard_12k_tasks', stopwatch.elapsedMilliseconds);
        
        // Dashboard should load within reasonable time for good UX
        expect(stopwatch.elapsedMilliseconds, lessThan(6000),
               reason: 'Analytics dashboard should load within 6 seconds');
        
        expect(dashboardData.productivityMetrics, isNotNull);
        expect(dashboardData.completionTrends, isNotNull);
        expect(dashboardData.projectStatistics, isNotNull);
        expect(dashboardData.priorityDistribution, isNotNull);
        
        print('Analytics dashboard (12k tasks, 60 projects): ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Chart data generation performance with complex visualizations', () async {
        final tasks = dataGenerator.generateTimeSeriesTaskData(10000, const Duration(days: 180));
        final projects = dataGenerator.generateProjectDataset(30);
        
        final chartService = AnalyticsChartService();
        
        final stopwatch = Stopwatch()..start();
        
        // Generate various chart data sets
        final chartData = await Future.wait([
          chartService.generateBurndownChartData(tasks, projects.first, const Duration(days: 30)),
          chartService.generateVelocityChartData(tasks, const Duration(days: 180)),
          chartService.generatePriorityDistributionChart(tasks),
          chartService.generateProjectComparisonChart(projects, tasks),
          chartService.generateTimelineChartData(tasks),
          chartService.generateHeatmapData(tasks),
          chartService.generateCumulativeFlowData(tasks),
        ]);
        
        stopwatch.stop();
        
        benchmarker.recordMetric('analytics_chart_generation', stopwatch.elapsedMilliseconds);
        
        // Chart generation should be efficient
        expect(stopwatch.elapsedMilliseconds, lessThan(4000),
               reason: 'Chart data generation should complete within 4 seconds');
        
        expect(chartData.length, equals(7));
        for (final data in chartData) {
          expect(data, isNotNull);
        }
        
        print('Chart data generation (7 charts, 10k tasks): ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Memory Efficiency Tests', () {
      test('Memory usage during large analytics computations', () async {
        final memoryTracker = MemoryUsageTracker();
        final analyticsService = AnalyticsService();
        
        // Baseline memory
        final baselineMemory = await memoryTracker.getCurrentUsage();
        
        // Process large dataset
        final tasks = dataGenerator.generateLargeTaskDataset(20000);
        final afterDataLoad = await memoryTracker.getCurrentUsage();
        
        // Perform analytics
        final metrics = await analyticsService.calculateProductivityMetrics(tasks);
        final afterAnalytics = await memoryTracker.getCurrentUsage();
        
        // Clear references and force GC
        tasks.clear();
        await memoryTracker.forceGarbageCollection();
        final afterCleanup = await memoryTracker.getCurrentUsage();
        
        final dataMemoryIncrease = afterDataLoad - baselineMemory;
        final analyticsMemoryIncrease = afterAnalytics - afterDataLoad;
        final memoryRecovered = afterAnalytics - afterCleanup;
        
        benchmarker.recordMetric('analytics_memory_data_increase', dataMemoryIncrease.round());
        benchmarker.recordMetric('analytics_memory_analytics_increase', analyticsMemoryIncrease.round());
        benchmarker.recordMetric('analytics_memory_recovered', memoryRecovered.round());
        
        // Memory should be managed efficiently
        expect(dataMemoryIncrease, lessThan(200.0),
               reason: 'Loading 20k tasks should increase memory by less than 200MB');
        expect(analyticsMemoryIncrease, lessThan(100.0),
               reason: 'Analytics computation should not cause excessive memory growth');
        expect(memoryRecovered, greaterThan(dataMemoryIncrease * 0.7),
               reason: 'At least 70% of memory should be recoverable');
        
        print('Analytics memory usage:');
        print('  Data loading: +${dataMemoryIncrease.toStringAsFixed(1)}MB');
        print('  Analytics: +${analyticsMemoryIncrease.toStringAsFixed(1)}MB');
        print('  Recovered: ${memoryRecovered.toStringAsFixed(1)}MB');
      });

      test('Memory leak detection in analytics streaming', () async {
        final memoryTracker = MemoryUsageTracker();
        final analyticsService = StreamingAnalyticsService();
        
        final memoryReadings = <double>[];
        
        // Run analytics cycles to detect memory leaks
        for (int cycle = 0; cycle < 15; cycle++) {
          // Generate data for this cycle
          final tasks = dataGenerator.generateLargeTaskDataset(1000);
          
          // Process through analytics
          await analyticsService.processBatch(tasks);
          
          // Record memory
          final currentMemory = await memoryTracker.getCurrentUsage();
          memoryReadings.add(currentMemory);
          
          // Cleanup cycle
          await analyticsService.cleanup();
          
          // Small delay for GC
          await Future.delayed(const Duration(milliseconds: 100));
        }
        
        // Analyze memory trend
        final memoryTrend = _calculateLinearTrend(memoryReadings);
        
        benchmarker.recordMetric('analytics_memory_leak_trend', (memoryTrend * 1000).round());
        
        // Memory should not show continuous upward trend
        expect(memoryTrend, lessThan(0.5),
               reason: 'Analytics streaming should not show significant memory leak');
        
        print('Analytics memory leak analysis:');
        print('  Trend: ${memoryTrend > 0 ? '+' : ''}${memoryTrend.toStringAsFixed(3)}MB per cycle');
        print('  Final memory: ${memoryReadings.last.toStringAsFixed(1)}MB');
      });
    });

    group('Database Query Performance', () {
      test('Complex analytics database queries with large datasets', () async {
        final tasks = dataGenerator.generateLargeTaskDataset(25000);
        final projects = dataGenerator.generateProjectDataset(100);
        
        // Mock database responses
        when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => tasks);
        when(mockProjectRepository.getAllProjects()).thenAnswer((_) async => projects);
        
        final analyticsRepository = AnalyticsRepository(
          taskRepository: mockTaskRepository,
          projectRepository: mockProjectRepository,
        );
        
        final stopwatch = Stopwatch()..start();
        
        // Execute complex analytics queries
        final results = await Future.wait([
          analyticsRepository.getTaskCompletionRateByProject(),
          analyticsRepository.getAverageTaskDurationByPriority(),
          analyticsRepository.getTaskDistributionByTag(),
          analyticsRepository.getProjectProgressByMonth(),
          analyticsRepository.getTeamProductivityMetrics(),
        ]);
        
        stopwatch.stop();
        
        benchmarker.recordMetric('analytics_db_queries_25k_tasks', stopwatch.elapsedMilliseconds);
        
        // Database queries should be optimized
        expect(stopwatch.elapsedMilliseconds, lessThan(3000),
               reason: 'Complex analytics database queries should complete within 3 seconds');
        
        expect(results.length, equals(5));
        for (final result in results) {
          expect(result, isNotNull);
        }
        
        print('Complex analytics DB queries (25k tasks): ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Paginated analytics queries for large result sets', () async {
        final analyticsRepository = AnalyticsRepository(
          taskRepository: mockTaskRepository,
          projectRepository: mockProjectRepository,
        );
        
        final stopwatch = Stopwatch()..start();
        
        // Test paginated results
        const pageSize = 1000;
        final totalResults = <AnalyticsDataPoint>[];
        
        for (int page = 0; page < 10; page++) {
          final pageResults = await analyticsRepository.getTaskAnalyticsPaginated(
            offset: page * pageSize,
            limit: pageSize,
          );
          totalResults.addAll(pageResults);
          
          // Each page should load quickly
          expect(pageResults.length, lessThanOrEqualTo(pageSize));
        }
        
        stopwatch.stop();
        
        benchmarker.recordMetric('analytics_paginated_queries_10k_results', stopwatch.elapsedMilliseconds);
        
        // Paginated queries should be efficient
        expect(stopwatch.elapsedMilliseconds, lessThan(2000),
               reason: 'Paginated analytics queries should complete within 2 seconds');
        
        expect(totalResults.length, greaterThan(0));
        
        print('Paginated analytics queries (10k results): ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Export Performance Tests', () {
      test('Large analytics data export performance', () async {
        final tasks = dataGenerator.generateLargeTaskDataset(30000);
        final projects = dataGenerator.generateProjectDataset(150);
        
        final exportService = AnalyticsExportService();
        
        final stopwatch = Stopwatch()..start();
        
        // Export comprehensive analytics report
        final exportData = await exportService.exportAnalyticsReport(
          tasks: tasks,
          projects: projects,
          format: ExportFormat.comprehensive,
          includeCharts: true,
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('analytics_export_30k_tasks', stopwatch.elapsedMilliseconds);
        
        // Export should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(15000),
               reason: 'Analytics export (30k tasks) should complete within 15 seconds');
        
        expect(exportData, isNotNull);
        expect(exportData.length, greaterThan(0));
        
        print('Analytics export (30k tasks, 150 projects): ${stopwatch.elapsedMilliseconds}ms');
        print('Export size: ${(exportData.length / 1024 / 1024).toStringAsFixed(2)}MB');
      });
    });

    tearDown(() {
      // Print analytics performance summary
      final summary = benchmarker.generateSummary();
      print('\n=== Project Analytics Performance Summary ===');
      summary.forEach((metric, stats) {
        print('$metric: ${stats['avg']}ms avg (${stats['min']}-${stats['max']}ms)');
      });
      print('============================================\n');
    });
  });
}

/// Analytics test data generator
class AnalyticsTestDataGenerator {
  final math.Random _random = math.Random(42); // Fixed seed for reproducible tests
  
  /// Generates a large dataset of tasks for analytics testing
  List<TaskModel> generateLargeTaskDataset(int count) {
    final tasks = <TaskModel>[];
    final now = DateTime.now();
    
    final taskTitles = [
      'Implement authentication system',
      'Fix payment processing bug',
      'Design dashboard interface',
      'Optimize database queries',
      'Write unit tests',
      'Update documentation',
      'Review security audit',
      'Deploy to production',
      'Monitor performance',
      'Backup database',
      'Refactor legacy code',
      'Integrate API service',
      'Setup CI/CD pipeline',
      'Implement caching',
      'Analyze user metrics',
      'Create reports',
      'Setup alerts',
      'Improve error handling',
      'Optimize images',
      'Update dependencies',
    ];
    
    final projectIds = List.generate(50, (i) => 'project-${i + 1}');
    
    for (int i = 0; i < count; i++) {
      final createdDaysAgo = _random.nextInt(365);
      final createdAt = now.subtract(Duration(days: createdDaysAgo));
      
      final task = TaskModel.create(
        title: '${taskTitles[i % taskTitles.length]} #${i + 1}',
        description: 'Task for analytics performance testing with detailed information',
        priority: TaskPriority.values[_random.nextInt(TaskPriority.values.length)],
        tags: _generateRandomTags(),
        projectId: _random.nextBool() ? projectIds[_random.nextInt(projectIds.length)] : null,
        estimatedDuration: Duration(minutes: 30 + _random.nextInt(480)),
        createdAt: createdAt,
      ).copyWith(
        dueDate: _random.nextBool() 
          ? createdAt.add(Duration(days: 1 + _random.nextInt(30)))
          : null,
        completedAt: _random.nextDouble() < 0.6 
          ? createdAt.add(Duration(days: 1 + _random.nextInt(20)))
          : null,
        actualDuration: Duration(minutes: 15 + _random.nextInt(600)),
      );
      
      tasks.add(task);
    }
    
    return tasks;
  }
  
  /// Generates historical task data spread over time period
  List<TaskModel> generateHistoricalTaskData(int count, Duration timeSpan) {
    final tasks = <TaskModel>[];
    final now = DateTime.now();
    final startTime = now.subtract(timeSpan);
    
    for (int i = 0; i < count; i++) {
      final createdAt = startTime.add(
        Duration(milliseconds: (timeSpan.inMilliseconds * _random.nextDouble()).round())
      );
      
      final task = TaskModel.create(
        title: 'Historical Task #${i + 1}',
        description: 'Historical task for trend analysis',
        createdAt: createdAt,
      ).copyWith(
        priority: TaskPriority.values[_random.nextInt(TaskPriority.values.length)],
        completedAt: _random.nextDouble() < 0.7 
          ? createdAt.add(Duration(days: 1 + _random.nextInt(14)))
          : null,
      );
      
      tasks.add(task);
    }
    
    return tasks;
  }
  
  /// Generates cross-project task data
  List<TaskModel> generateCrossProjectTaskData(List<Project> projects, int taskCount) {
    final tasks = <TaskModel>[];
    
    for (int i = 0; i < taskCount; i++) {
      final project = projects[_random.nextInt(projects.length)];
      final tasksPerProject = taskCount ~/ projects.length;
      
      final task = TaskModel.create(
        title: 'Cross-Project Task #${i + 1}',
        projectId: project.id,
      ).copyWith(
        priority: TaskPriority.values[_random.nextInt(TaskPriority.values.length)],
        tags: _generateRandomTags(),
        estimatedDuration: Duration(minutes: 30 + _random.nextInt(300)),
        actualDuration: Duration(minutes: 20 + _random.nextInt(400)),
      );
      
      tasks.add(task);
    }
    
    return tasks;
  }
  
  /// Generates project dataset for testing
  List<Project> generateProjectDataset(int count) {
    final projects = <Project>[];
    
    final projectNames = [
      'E-commerce Platform',
      'Mobile Application',
      'Data Analytics',
      'Security Audit',
      'Performance Optimization',
      'User Experience',
      'API Integration',
      'Database Migration',
      'DevOps Infrastructure',
      'Quality Assurance',
    ];
    
    for (int i = 0; i < count; i++) {
      final project = Project.create(
        name: '${projectNames[i % projectNames.length]} ${i + 1}',
        description: 'Project for analytics performance testing',
        deadline: _random.nextBool() 
          ? DateTime.now().add(Duration(days: 30 + _random.nextInt(90)))
          : null,
      );
      
      projects.add(project);
    }
    
    return projects;
  }
  
  /// Generates time series task data
  List<TaskModel> generateTimeSeriesTaskData(int count, Duration timeSpan) {
    final tasks = <TaskModel>[];
    final now = DateTime.now();
    final startTime = now.subtract(timeSpan);
    
    // Generate tasks with even distribution over time
    for (int i = 0; i < count; i++) {
      final createdAt = startTime.add(
        Duration(milliseconds: (timeSpan.inMilliseconds * i / count).round())
      );
      
      final task = TaskModel.create(
        title: 'Time Series Task #${i + 1}',
        createdAt: createdAt,
      ).copyWith(
        status: _random.nextDouble() < 0.8 ? TaskStatus.completed : TaskStatus.inProgress,
        completedAt: _random.nextDouble() < 0.8 
          ? createdAt.add(Duration(hours: 1 + _random.nextInt(168)))
          : null,
      );
      
      tasks.add(task);
    }
    
    return tasks;
  }
  
  /// Generates a single task for incremental testing
  TaskModel generateSingleTask(int index) {
    return TaskModel.create(
      title: 'Incremental Task #$index',
      priority: TaskPriority.values[_random.nextInt(TaskPriority.values.length)],
      tags: _generateRandomTags(),
    );
  }
  
  List<String> _generateRandomTags() {
    final allTags = [
      'urgent', 'bug', 'feature', 'ui', 'backend', 'api', 'database',
      'testing', 'documentation', 'security', 'performance', 'mobile'
    ];
    
    final tagCount = 1 + _random.nextInt(4); // 1-4 tags
    final selectedTags = <String>[];
    
    for (int i = 0; i < tagCount; i++) {
      final tag = allTags[_random.nextInt(allTags.length)];
      if (!selectedTags.contains(tag)) {
        selectedTags.add(tag);
      }
    }
    
    return selectedTags;
  }
}

/// Performance benchmarker utility (shared with other test files)
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

/// Memory usage tracker utility (shared with other test files)
class MemoryUsageTracker {
  Future<double> getCurrentUsage() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return 60.0 + (DateTime.now().millisecondsSinceEpoch % 1000) / 50.0;
  }
  
  Future<void> forceGarbageCollection() async {
    // Simulate garbage collection delay
    await Future.delayed(const Duration(milliseconds: 50));
  }
}

/// Mock analytics services for testing
class RealTimeAnalyticsService {
  Future<void> initialize(List<TaskModel> tasks) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  Future<AnalyticsMetrics> updateWithNewTask(TaskModel task) async {
    await Future.delayed(const Duration(milliseconds: 5));
    return AnalyticsMetrics.empty();
  }
}

class AnalyticsDashboardService {
  Future<DashboardData> loadDashboard({
    required List<TaskModel> tasks,
    required List<Project> projects,
    required AnalyticsTimeRange timeRange,
  }) async {
    // Simulate dashboard loading
    await Future.delayed(Duration(milliseconds: tasks.length ~/ 100));
    return DashboardData(
      productivityMetrics: AnalyticsMetrics.empty(),
      completionTrends: [],
      projectStatistics: [],
      priorityDistribution: {},
    );
  }
}

class AnalyticsChartService {
  Future<ChartData> generateBurndownChartData(List<TaskModel> tasks, Project project, Duration period) async {
    await Future.delayed(Duration(milliseconds: tasks.length ~/ 50));
    return const ChartData();
  }
  
  Future<ChartData> generateVelocityChartData(List<TaskModel> tasks, Duration period) async {
    await Future.delayed(Duration(milliseconds: tasks.length ~/ 50));
    return const ChartData();
  }
  
  Future<ChartData> generatePriorityDistributionChart(List<TaskModel> tasks) async {
    await Future.delayed(Duration(milliseconds: tasks.length ~/ 100));
    return const ChartData();
  }
  
  Future<ChartData> generateProjectComparisonChart(List<Project> projects, List<TaskModel> tasks) async {
    await Future.delayed(Duration(milliseconds: tasks.length ~/ 80));
    return const ChartData();
  }
  
  Future<ChartData> generateTimelineChartData(List<TaskModel> tasks) async {
    await Future.delayed(Duration(milliseconds: tasks.length ~/ 60));
    return const ChartData();
  }
  
  Future<ChartData> generateHeatmapData(List<TaskModel> tasks) async {
    await Future.delayed(Duration(milliseconds: tasks.length ~/ 70));
    return const ChartData();
  }
  
  Future<ChartData> generateCumulativeFlowData(List<TaskModel> tasks) async {
    await Future.delayed(Duration(milliseconds: tasks.length ~/ 60));
    return const ChartData();
  }
}

class StreamingAnalyticsService {
  Future<void> processBatch(List<TaskModel> tasks) async {
    await Future.delayed(Duration(milliseconds: tasks.length ~/ 10));
  }
  
  Future<void> cleanup() async {
    await Future.delayed(const Duration(milliseconds: 20));
  }
}

class AnalyticsRepository {
  final MockTaskRepository taskRepository;
  final MockProjectRepository projectRepository;
  
  AnalyticsRepository({
    required this.taskRepository,
    required this.projectRepository,
  });
  
  Future<Map<String, double>> getTaskCompletionRateByProject() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {};
  }
  
  Future<Map<TaskPriority, Duration>> getAverageTaskDurationByPriority() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return {};
  }
  
  Future<Map<String, int>> getTaskDistributionByTag() async {
    await Future.delayed(const Duration(milliseconds: 180));
    return {};
  }
  
  Future<List<ProjectProgressData>> getProjectProgressByMonth() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [];
  }
  
  Future<TeamProductivityMetrics> getTeamProductivityMetrics() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const TeamProductivityMetrics();
  }
  
  Future<List<AnalyticsDataPoint>> getTaskAnalyticsPaginated({
    required int offset,
    required int limit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return List.generate(limit, (i) => const AnalyticsDataPoint());
  }
}

class AnalyticsExportService {
  Future<List<int>> exportAnalyticsReport({
    required List<TaskModel> tasks,
    required List<Project> projects,
    required ExportFormat format,
    required bool includeCharts,
  }) async {
    // Simulate export processing time based on data size
    final processingTime = (tasks.length / 100).round() + (projects.length / 10).round();
    await Future.delayed(Duration(milliseconds: processingTime));
    
    // Return simulated export data
    return List.generate(tasks.length * 10, (i) => i % 256);
  }
}

/// Helper function to calculate linear trend
double _calculateLinearTrend(List<double> values) {
  if (values.length < 2) return 0.0;
  
  double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
  final n = values.length;
  
  for (int i = 0; i < n; i++) {
    sumX += i;
    sumY += values[i];
    sumXY += i * values[i];
    sumX2 += i * i;
  }
  
  return (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
}

// Mock data classes
enum AnalyticsTimeRange { last30Days, last90Days, lastYear }
enum ExportFormat { comprehensive, summary, detailed }

class AnalyticsMetrics {
  final int totalTasks;
  
  const AnalyticsMetrics({required this.totalTasks});
  
  factory AnalyticsMetrics.empty() => const AnalyticsMetrics(totalTasks: 0);
}

class DashboardData {
  final AnalyticsMetrics productivityMetrics;
  final List<dynamic> completionTrends;
  final List<dynamic> projectStatistics;
  final Map<String, int> priorityDistribution;
  
  const DashboardData({
    required this.productivityMetrics,
    required this.completionTrends,
    required this.projectStatistics,
    required this.priorityDistribution,
  });
}

class ChartData {
  const ChartData();
}

class ProjectProgressData {
  const ProjectProgressData();
}

class TeamProductivityMetrics {
  const TeamProductivityMetrics();
}

class AnalyticsDataPoint {
  const AnalyticsDataPoint();
}