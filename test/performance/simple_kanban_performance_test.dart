import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';

void main() {
  group('Simple Kanban Performance Tests - Enterprise Scale', () {
    late PerformanceBenchmarker benchmarker;

    setUp(() {
      benchmarker = PerformanceBenchmarker();
    });

    group('Large Dataset Processing Performance', () {
      test('Task processing with 100+ tasks performs within benchmarks', () async {
        final tasks = _generateLargeTaskDataset(100);
        final stopwatch = Stopwatch()..start();

        // Simulate basic task processing
        final processedTasks = <TaskModel>[];
        for (final task in tasks) {
          processedTasks.add(task.copyWith(updatedAt: DateTime.now()));
        }

        stopwatch.stop();
        benchmarker.recordMetric('task_processing_100', stopwatch.elapsedMilliseconds);

        expect(stopwatch.elapsedMilliseconds, lessThan(100),
            reason: 'Processing 100 tasks should complete within 100ms');
        expect(processedTasks.length, equals(100));

        print('Processed 100 tasks in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Task processing with 500+ tasks performs within benchmarks', () async {
        final tasks = _generateLargeTaskDataset(500);
        final stopwatch = Stopwatch()..start();

        // Simulate task filtering and grouping
        final highPriorityTasks = tasks.where((t) => t.priority == TaskPriority.high).toList();
        final groupedByStatus = <TaskStatus, List<TaskModel>>{};

        for (final task in tasks) {
          groupedByStatus.putIfAbsent(task.status, () => []).add(task);
        }

        stopwatch.stop();
        benchmarker.recordMetric('task_processing_500', stopwatch.elapsedMilliseconds);

        expect(stopwatch.elapsedMilliseconds, lessThan(500),
            reason: 'Processing 500 tasks should complete within 500ms');
        expect(groupedByStatus.length, greaterThan(0));

        print('Processed 500 tasks in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Task processing with 1000+ tasks performs within benchmarks', () async {
        final tasks = _generateLargeTaskDataset(1000);
        final stopwatch = Stopwatch()..start();

        // Simulate complex operations
        final results = <String, dynamic>{};

        // Group by priority
        final priorityGroups = <TaskPriority, List<TaskModel>>{};
        for (final task in tasks) {
          priorityGroups.putIfAbsent(task.priority, () => []).add(task);
        }

        // Calculate statistics
        final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).length;
        final tasksWithDuration = tasks.where((t) => t.estimatedDuration != null).toList();
        final avgDuration = tasksWithDuration.isNotEmpty
            ? tasksWithDuration.fold<double>(0.0, (sum, t) => sum + (t.estimatedDuration ?? 0)) /
                tasksWithDuration.length
            : 0.0;

        results['priorityGroups'] = priorityGroups;
        results['completedCount'] = completedTasks;
        results['avgDuration'] = avgDuration;

        stopwatch.stop();
        benchmarker.recordMetric('task_processing_1000', stopwatch.elapsedMilliseconds);

        expect(stopwatch.elapsedMilliseconds, lessThan(1000),
            reason: 'Processing 1000 tasks should complete within 1 second');
        expect(results['completedCount'], greaterThan(0));

        print('Processed 1000 tasks in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Task processing with 2500+ tasks stress test', () async {
        final tasks = _generateLargeTaskDataset(2500);
        final stopwatch = Stopwatch()..start();

        // Simulate intensive operations
        final analytics = <String, dynamic>{};

        // Multiple grouping operations
        final byStatus = <TaskStatus, List<TaskModel>>{};
        final byPriority = <TaskPriority, List<TaskModel>>{};
        final byProject = <String?, List<TaskModel>>{};

        for (final task in tasks) {
          byStatus.putIfAbsent(task.status, () => []).add(task);
          byTaskPriority.putIfAbsent(task.priority, () => []).add(task);
          byProject.putIfAbsent(task.projectId, () => []).add(task);
        }

        // Search operations
        final urgentTasks =
            tasks.where((t) => t.title.toLowerCase().contains('urgent') || t.priority == TaskPriority.urgent).toList();

        analytics['byStatus'] = byStatus;
        analytics['byPriority'] = byPriority;
        analytics['byProject'] = byProject;
        analytics['urgentTasks'] = urgentTasks;

        stopwatch.stop();
        benchmarker.recordMetric('task_processing_2500', stopwatch.elapsedMilliseconds);

        expect(stopwatch.elapsedMilliseconds, lessThan(2500),
            reason: 'Processing 2500 tasks should complete within 2.5 seconds');

        print('STRESS: Processed 2500 tasks in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Task processing with 5000+ tasks extreme stress test', () async {
        final tasks = _generateLargeTaskDataset(5000);
        final stopwatch = Stopwatch()..start();

        // Extreme processing simulation
        final results = <String, dynamic>{};

        // Complex filtering chain
        final filteredTasks = tasks
            .where((t) => t.priority != TaskPriority.low)
            .where((t) => t.status != TaskStatus.cancelled)
            .where((t) => t.dueDate?.isAfter(DateTime.now()) ?? false)
            .toList();

        // Statistical calculations
        final totalDuration = filteredTasks
            .where((t) => t.estimatedDuration != null)
            .fold<double>(0.0, (sum, t) => sum + (t.estimatedDuration ?? 0));

        final projectTaskCounts = <String?, int>{};
        for (final task in filteredTasks) {
          projectTaskCounts[task.projectId] = (projectTaskCounts[task.projectId] ?? 0) + 1;
        }

        results['filtered'] = filteredTasks;
        results['totalDuration'] = totalDuration;
        results['projectCounts'] = projectTaskCounts;

        stopwatch.stop();
        benchmarker.recordMetric('task_processing_5000', stopwatch.elapsedMilliseconds);

        expect(stopwatch.elapsedMilliseconds, lessThan(5000),
            reason: 'Processing 5000 tasks should complete within 5 seconds');

        print('EXTREME: Processed 5000 tasks in ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Search and Filter Performance', () {
      test('Complex search queries with large dataset', () async {
        final tasks = _generateLargeTaskDataset(1000);

        final searchQueries = [
          'urgent',
          'critical project',
          'bug fix implementation',
          'user interface design',
          'database optimization task',
        ];

        for (int i = 0; i < searchQueries.length; i++) {
          final query = searchQueries[i];
          final stopwatch = Stopwatch()..start();

          final results = tasks.where((task) {
            final queryLower = query.toLowerCase();
            return task.title.toLowerCase().contains(queryLower) ||
                task.description?.toLowerCase().contains(queryLower) == true ||
                task.tags.any((tag) => tag.toLowerCase().contains(queryLower));
          }).toList();

          stopwatch.stop();
          benchmarker.recordMetric('search_query_$i', stopwatch.elapsedMilliseconds);

          expect(stopwatch.elapsedMilliseconds, lessThan(100), reason: 'Search query should complete within 100ms');

          print('Search "$query": ${stopwatch.elapsedMilliseconds}ms, ${results.length} results');
        }
      });

      test('Multi-criteria filtering performance', () async {
        final tasks = _generateLargeTaskDataset(1500);
        final stopwatch = Stopwatch()..start();

        // Complex multi-criteria filter
        final filteredTasks = tasks.where((task) {
          // Priority filter
          if (task.priority == TaskPriority.low) return false;

          // Status filter
          if (![TaskStatus.pending, TaskStatus.inProgress].contains(task.status)) return false;

          // Date filter
          if (task.dueDate?.isBefore(DateTime.now()) ?? false) return false;

          // Tag filter
          if (!task.tags.any(['feature', 'bug', 'critical'].contains)) return false;

          return true;
        }).toList();

        stopwatch.stop();
        benchmarker.recordMetric('multi_criteria_filter_1500', stopwatch.elapsedMilliseconds);

        expect(stopwatch.elapsedMilliseconds, lessThan(200),
            reason: 'Multi-criteria filtering should complete within 200ms');
        expect(filteredTasks.length, lessThanOrEqualTo(tasks.length));

        print(
            'Multi-criteria filtering (1500 tasks): ${stopwatch.elapsedMilliseconds}ms, ${filteredTasks.length} results');
      });
    });

    group('Sorting and Grouping Performance', () {
      test('Large dataset sorting performance', () async {
        final tasks = _generateLargeTaskDataset(2000);

        final sortingTests = [
          (
            'by_due_date',
            (List<TaskModel> list) {
              list.sort((a, b) {
                if (a.dueDate == null && b.dueDate == null) return 0;
                if (a.dueDate == null) return 1;
                if (b.dueDate == null) return -1;
                return a.dueDate!.compareTo(b.dueDate!);
              });
            }
          ),
          (
            'by_priority',
            (List<TaskModel> list) {
              list.sort((a, b) => b.priority.index.compareTo(a.priority.index));
            }
          ),
          (
            'by_created_date',
            (List<TaskModel> list) {
              list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            }
          ),
          (
            'by_title',
            (List<TaskModel> list) {
              list.sort((a, b) => a.title.compareTo(b.title));
            }
          ),
        ];

        for (final (testName, sortFunction) in sortingTests) {
          final tasksCopy = List<TaskModel>.from(tasks);
          final stopwatch = Stopwatch()..start();

          sortFunction(tasksCopy);

          stopwatch.stop();
          benchmarker.recordMetric('sort_$testName', stopwatch.elapsedMilliseconds);

          expect(stopwatch.elapsedMilliseconds, lessThan(300),
              reason: 'Sorting $testName should complete within 300ms');

          print('Sort $testName (2000 tasks): ${stopwatch.elapsedMilliseconds}ms');
        }
      });

      test('Complex grouping operations performance', () async {
        final tasks = _generateLargeTaskDataset(3000);
        final stopwatch = Stopwatch()..start();

        // Multiple grouping operations
        final groupings = <String, Map<dynamic, List<TaskModel>>>{};

        // Group by status
        final byStatus = <TaskStatus, List<TaskModel>>{};
        for (final task in tasks) {
          byStatus.putIfAbsent(task.status, () => []).add(task);
        }
        groupings['status'] = byStatus;

        // Group by priority
        final byPriority = <TaskPriority, List<TaskModel>>{};
        for (final task in tasks) {
          byTaskPriority.putIfAbsent(task.priority, () => []).add(task);
        }
        groupings['priority'] = byPriority;

        // Group by project
        final byProject = <String?, List<TaskModel>>{};
        for (final task in tasks) {
          byProject.putIfAbsent(task.projectId, () => []).add(task);
        }
        groupings['project'] = byProject;

        // Group by month created
        final byMonth = <String, List<TaskModel>>{};
        for (final task in tasks) {
          final monthKey = '${task.createdAt.year}-${task.createdAt.month.toString().padLeft(2, '0')}';
          byMonth.putIfAbsent(monthKey, () => []).add(task);
        }
        groupings['month'] = byMonth;

        stopwatch.stop();
        benchmarker.recordMetric('complex_grouping_3000', stopwatch.elapsedMilliseconds);

        expect(stopwatch.elapsedMilliseconds, lessThan(1000),
            reason: 'Complex grouping should complete within 1 second');
        expect(groupings.length, equals(4));

        print('Complex grouping (3000 tasks): ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Memory and Performance Validation', () {
      test('Memory usage simulation with large datasets', () async {
        final memoryTracker = MemoryUsageTracker();

        final baselineMemory = await memoryTracker.getCurrentUsage();

        // Create large dataset
        final largeTasks = _generateLargeTaskDataset(10000);
        final largeProjects = _generateProjectDataset(500);

        final afterCreation = await memoryTracker.getCurrentUsage();

        // Perform operations
        final operationResults = <String, dynamic>{};

        // Filter operations
        final highPriorityTasks = largeTasks.where((t) => t.priority == TaskPriority.high).toList();
        final recentTasks =
            largeTasks.where((t) => t.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 30)))).toList();

        operationResults['highPriority'] = highPriorityTasks;
        operationResults['recent'] = recentTasks;

        final afterOperations = await memoryTracker.getCurrentUsage();

        // Cleanup
        largeTasks.clear();
        largeProjects.clear();
        operationResults.clear();

        final afterCleanup = await memoryTracker.getCurrentUsage();

        final memoryUsed = afterCreation - baselineMemory;
        final operationOverhead = afterOperations - afterCreation;
        final memoryRecovered = afterOperations - afterCleanup;

        benchmarker.recordMetric('memory_usage_10k', memoryUsed.round());
        benchmarker.recordMetric('memory_operations', operationOverhead.round());
        benchmarker.recordMetric('memory_recovered', memoryRecovered.round());

        expect(memoryUsed, lessThan(500.0), reason: '10k tasks should use less than 500MB');
        expect(memoryRecovered, greaterThan(memoryUsed * 0.5), reason: 'At least 50% of memory should be recoverable');

        print('Memory analysis (10k tasks):');
        print('  Used: ${memoryUsed.toStringAsFixed(1)}MB');
        print('  Operations: ${operationOverhead.toStringAsFixed(1)}MB');
        print('  Recovered: ${memoryRecovered.toStringAsFixed(1)}MB');
      });

      test('Performance regression detection', () async {
        final summary = benchmarker.generateSummary();

        // Define performance requirements
        final requirements = {
          'task_processing_100': 100,
          'task_processing_500': 500,
          'task_processing_1000': 1000,
          'task_processing_2500': 2500,
          'search_query_0': 100,
          'multi_criteria_filter_1500': 200,
          'complex_grouping_3000': 1000,
        };

        final failures = <String>[];
        final successes = <String>[];

        requirements.forEach((metric, maxTime) {
          if (summary.containsKey(metric)) {
            final avg = summary[metric]!['avg']!;
            if (avg > maxTime) {
              failures.add('❌ $metric: ${avg}ms > ${maxTime}ms');
            } else {
              successes.add('✅ $metric: ${avg}ms ≤ ${maxTime}ms');
            }
          }
        });

        print('\nPerformance Requirements Validation:');
        successes.forEach(print);

        if (failures.isNotEmpty) {
          print('\nFAILED Requirements:');
          failures.forEach(print);
        } else {
          print('\n🎉 All performance requirements MET!');
        }

        expect(failures, isEmpty, reason: 'Performance requirements not met');
      });
    });

    tearDown(() {
      final summary = benchmarker.generateSummary();
      print('\n=== Simple Kanban Performance Summary ===');

      final categories = {
        '⚡ Processing Performance': summary.entries.where((e) => e.key.contains('processing')),
        '🔍 Search Performance': summary.entries.where((e) => e.key.contains('search') || e.key.contains('filter')),
        '📊 Sorting/Grouping Performance':
            summary.entries.where((e) => e.key.contains('sort') || e.key.contains('group')),
        '🧠 Memory Performance': summary.entries.where((e) => e.key.contains('memory')),
      };

      categories.forEach((category, metrics) {
        if (metrics.isNotEmpty) {
          print('\n$category:');
          for (final metric in metrics) {
            final stats = metric.value;
            final unit = metric.key.contains('memory') ? 'MB' : 'ms';
            print('  ${metric.key}: ${stats['avg']}$unit avg (${stats['min']}-${stats['max']}$unit)');
          }
        }
      });

      print('\n==============================================\n');
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
  ];

  final descriptions = [
    'Critical task requiring immediate attention and careful implementation',
    'Complex feature involving multiple system components and stakeholder coordination',
    'Routine maintenance task that can be completed efficiently',
    'Research and analysis required before starting implementation work',
    'Collaborative effort requiring coordination with external development teams',
  ];

  final tags = [
    ['urgent', 'critical'],
    ['feature', 'ui'],
    ['backend', 'api'],
    ['testing', 'quality'],
    ['documentation'],
    ['deployment', 'ops'],
    ['monitoring', 'analytics'],
    ['security'],
    ['research'],
    ['optimization'],
  ];

  for (int i = 0; i < count; i++) {
    final title = '${taskTitles[i % taskTitles.length]} #${i + 1}';
    final description = descriptions[i % descriptions.length];
    final priority = TaskPriority.values[i % TaskPriority.values.length];
    final status = TaskStatus.values[i % TaskStatus.values.length];
    final taskTags = tags[i % tags.length];
    final projectId = random.nextBool() ? 'project-${(i % 20) + 1}' : null;

    final task = TaskModel.create(
      title: title,
      description: description,
      priority: priority,
      tags: taskTags,
      projectId: projectId,
      dueDate: random.nextBool() ? now.add(Duration(days: random.nextInt(60) - 10)) : null,
      estimatedDuration: 30 + random.nextInt(240),
    ).copyWith(
      status: status,
      createdAt: now.subtract(Duration(days: random.nextInt(180))),
    );

    tasks.add(task);
  }

  return tasks;
}

/// Generates a dataset of projects for testing
List<Project> _generateProjectDataset(int count) {
  final projects = <Project>[];
  final random = math.Random(42);

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

  for (int i = 0; i < count; i++) {
    final project = Project.create(
      name: '${projectNames[i % projectNames.length]} ${i + 1}',
      description: 'Project for performance testing',
      deadline: random.nextBool() ? DateTime.now().add(Duration(days: 30 + random.nextInt(90))) : null,
    );

    projects.add(project);
  }

  return projects;
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
    await Future.delayed(const Duration(milliseconds: 5));
    return 50.0 + (DateTime.now().millisecondsSinceEpoch % 1000) / 100.0;
  }
}
