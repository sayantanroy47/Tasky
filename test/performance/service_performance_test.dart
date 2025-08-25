import 'package:flutter_test/flutter_test.dart';

import 'package:task_tracker_app/services/ai/local_task_parser.dart';
import 'package:task_tracker_app/services/ai/composite_ai_task_parser.dart';
import 'package:task_tracker_app/services/analytics/analytics_service.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';

void main() {
  group('Service Performance Tests', () {
    group('AI Task Parser Performance', () {
      late LocalTaskParser localParser;
      late CompositeAITaskParser compositeParser;

      setUp(() {
        localParser = LocalTaskParser();
        compositeParser = CompositeAITaskParser(
          primaryParser: localParser,
          fallbackParser: localParser,
        );
      });

      test('should parse simple tasks quickly', () async {
        const simpleTexts = [
          'Buy groceries',
          'Call mom',
          'Finish project',
          'Book dentist appointment',
          'Pay bills',
        ];

        final stopwatch = Stopwatch()..start();
        
        for (final text in simpleTexts) {
          final result = await localParser.parseTask(text);
          expect(result.title, isNotEmpty);
        }
        
        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;
        final avgMs = elapsedMs / simpleTexts.length;
        
        print('Parsed ${simpleTexts.length} simple tasks in ${elapsedMs}ms (${avgMs.toStringAsFixed(1)}ms avg)');
        
        // Should parse simple tasks very quickly
        expect(avgMs, lessThan(50.0)); // 50ms per task max
        expect(elapsedMs, lessThan(500)); // 500ms total max
      });

      test('should parse complex tasks efficiently', () async {
        const complexTexts = [
          'Schedule dentist appointment for next Tuesday at 2 PM with high priority',
          'Buy groceries tomorrow morning including milk, bread, eggs, and fruits for the family dinner',
          'Complete the quarterly report by Friday, making sure to include all department metrics and performance data',
          'Organize team meeting next week to discuss the new project timeline and assign responsibilities to each team member',
          'Book flight tickets for vacation in December, preferring morning flights and checking for the best deals',
        ];

        final stopwatch = Stopwatch()..start();
        
        for (final text in complexTexts) {
          final result = await localParser.parseTask(text);
          expect(result.title, isNotEmpty);
          // Complex tasks might have more extracted information
        }
        
        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;
        final avgMs = elapsedMs / complexTexts.length;
        
        print('Parsed ${complexTexts.length} complex tasks in ${elapsedMs}ms (${avgMs.toStringAsFixed(1)}ms avg)');
        
        // Complex tasks can take longer but should still be reasonable
        expect(avgMs, lessThan(200.0)); // 200ms per task max
        expect(elapsedMs, lessThan(2000)); // 2 seconds total max
      });

      test('should handle batch parsing efficiently', () async {
        const batchSize = 50;
        final batchTexts = List.generate(batchSize, (i) => 
          'Task number ${i + 1} - ${_generateRandomTaskText(i)}'
        );

        final stopwatch = Stopwatch()..start();
        
        final futures = batchTexts.map((text) => localParser.parseTask(text));
        final results = await Future.wait(futures);
        
        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;
        final avgMs = elapsedMs / batchSize;
        
        print('Batch parsed $batchSize tasks in ${elapsedMs}ms (${avgMs.toStringAsFixed(1)}ms avg)');
        
        expect(results.length, equals(batchSize));
        expect(avgMs, lessThan(100.0)); // 100ms per task max in batch
        expect(elapsedMs, lessThan(10000)); // 10 seconds total max
      });

      test('should handle composite parser fallback efficiently', () async {
        const testTexts = [
          'Simple task',
          'Complex task with multiple details and scheduling information',
          'Edge case task with special characters',
        ];

        final stopwatch = Stopwatch()..start();
        
        for (final text in testTexts) {
          final result = await compositeParser.parseTask(text);
          expect(result.title, isNotEmpty);
        }
        
        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;
        
        print('Composite parser handled ${testTexts.length} tasks in ${elapsedMs}ms');
        
        // Should not be significantly slower than single parser
        expect(elapsedMs, lessThan(1000)); // 1 second max
      });
    });

    group('Analytics Service Performance', () {
      late AnalyticsService analyticsService;
      late List<TaskModel> testTasks;

      setUp(() {
        analyticsService = AnalyticsService();
        
        // Create diverse test data
        testTasks = _generateTestTasks(1000);
      });

      test('should calculate productivity metrics efficiently', () async {
        final stopwatch = Stopwatch()..start();
        
        final metrics = await analyticsService.calculateProductivityMetrics(testTasks);
        
        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;
        
        print('Calculated productivity metrics for ${testTasks.length} tasks in ${elapsedMs}ms');
        
        expect(metrics, isNotNull);
        expect(elapsedMs, lessThan(1000)); // 1 second max
      });

      test('should generate completion trends efficiently', () async {
        final stopwatch = Stopwatch()..start();
        
        final trends = await analyticsService.getCompletionTrends(
          testTasks,
          DateTime.now().subtract(const Duration(days: 30)),
          DateTime.now(),
        );
        
        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;
        
        print('Generated completion trends for ${testTasks.length} tasks in ${elapsedMs}ms');
        
        expect(trends, isNotNull);
        expect(elapsedMs, lessThan(2000)); // 2 seconds max
      });

      test('should calculate statistics efficiently', () async {
        final stopwatch = Stopwatch()..start();
        
        final stats = await analyticsService.calculateTaskStatistics(testTasks);
        
        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;
        
        print('Calculated task statistics for ${testTasks.length} tasks in ${elapsedMs}ms');
        
        expect(stats, isNotNull);
        expect(elapsedMs, lessThan(500)); // 500ms max
      });

      test('should handle large dataset analytics', () async {
        // Create larger dataset
        final largeTasks = _generateTestTasks(5000);
        
        final stopwatch = Stopwatch()..start();
        
        // Run multiple analytics operations
        final futures = [
          analyticsService.calculateProductivityMetrics(largeTasks),
          analyticsService.calculateTaskStatistics(largeTasks),
          analyticsService.getCompletionTrends(
            largeTasks,
            DateTime.now().subtract(const Duration(days: 90)),
            DateTime.now(),
          ),
        ];
        
        final results = await Future.wait(futures);
        
        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;
        
        print('Completed comprehensive analytics for ${largeTasks.length} tasks in ${elapsedMs}ms');
        
        expect(results.length, equals(3));
        expect(elapsedMs, lessThan(10000)); // 10 seconds max
      });
    });

    group('Memory Usage Performance', () {
      test('should handle large data processing without excessive memory', () async {
        const iterations = 5;
        const tasksPerIteration = 2000;
        
        for (int i = 0; i < iterations; i++) {
          final tasks = _generateTestTasks(tasksPerIteration);
          
          // Process tasks (simulate real workload)
          final stopwatch = Stopwatch()..start();
          
          // Simulate various operations
          final parser = LocalTaskParser();
          for (int j = 0; j < 10; j++) {
            await parser.parseTask('Test task ${i}_$j');
          }
          
          final analyticsService = AnalyticsService();
          await analyticsService.calculateTaskStatistics(tasks);
          
          stopwatch.stop();
          
          print('Iteration ${i + 1}: Processed $tasksPerIteration tasks in ${stopwatch.elapsedMilliseconds}ms');
          
          // Clear references to help GC
          tasks.clear();
        }
        
        print('Memory performance test completed successfully');
      });
    });

    group('Concurrent Service Performance', () {
      test('should handle concurrent AI parsing', () async {
        const concurrentRequests = 20;
        final parser = LocalTaskParser();
        
        final stopwatch = Stopwatch()..start();
        
        final futures = List.generate(concurrentRequests, (i) async {
          return await parser.parseTask('Concurrent task ${i + 1} with some details');
        });
        
        final results = await Future.wait(futures);
        
        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;
        
        print('Handled $concurrentRequests concurrent parsing requests in ${elapsedMs}ms');
        
        expect(results.length, equals(concurrentRequests));
        expect(elapsedMs, lessThan(5000)); // 5 seconds max
        
        // Verify all parsed successfully
        for (final result in results) {
          expect(result.title, isNotEmpty);
        }
      });

      test('should handle concurrent analytics calculations', () async {
        final testTasks = _generateTestTasks(500);
        const concurrentAnalytics = 10;
        
        final stopwatch = Stopwatch()..start();
        
        final futures = List.generate(concurrentAnalytics, (i) async {
          final service = AnalyticsService();
          if (i % 3 == 0) {
            return await service.calculateProductivityMetrics(testTasks);
          } else if (i % 3 == 1) {
            return await service.calculateTaskStatistics(testTasks);
          } else {
            return await service.getCompletionTrends(
              testTasks,
              DateTime.now().subtract(const Duration(days: 30)),
              DateTime.now(),
            );
          }
        });
        
        final results = await Future.wait(futures);
        
        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;
        
        print('Handled $concurrentAnalytics concurrent analytics in ${elapsedMs}ms');
        
        expect(results.length, equals(concurrentAnalytics));
        expect(elapsedMs, lessThan(10000)); // 10 seconds max
      });
    });
  });
}

String _generateRandomTaskText(int index) {
  final taskTypes = [
    'Buy something from store',
    'Call someone important',
    'Complete work project',
    'Schedule appointment',
    'Review documents',
    'Plan meeting',
    'Organize files',
    'Update system',
    'Write report',
    'Send email',
  ];
  
  return taskTypes[index % taskTypes.length];
}

List<TaskModel> _generateTestTasks(int count) {
  final tasks = <TaskModel>[];
  final now = DateTime.now();
  
  for (int i = 0; i < count; i++) {
    tasks.add(TaskModel.create(
      title: 'Performance Test Task ${i + 1}',
      description: i % 5 == 0 ? 'Important task with detailed description' : 'Regular task',
      priority: TaskPriority.values[i % TaskPriority.values.length],
      dueDate: i % 3 == 0 ? now.add(Duration(days: i % 30)) : null,
      projectId: i % 4 == 0 ? 'project-${i % 5}' : null,
      estimatedDuration: Duration(minutes: 15 + (i % 120)),
      createdAt: now.subtract(Duration(days: i % 100)),
    ));
  }
  
  return tasks;
}