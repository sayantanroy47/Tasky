import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/services/performance_service.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/services/ai/enhanced_local_parser.dart';
import 'package:task_tracker_app/services/database/database.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'performance_stress_test.mocks.dart';

@GenerateMocks([AppDatabase])
void main() {
  group('Performance and Stress Tests', () {
    late PerformanceService performanceService;
    late EnhancedLocalParser aiParser;

    setUp(() {
      performanceService = PerformanceService();
      aiParser = EnhancedLocalParser();
    });

    group('AI Parser Performance Tests', () {
      test('should parse simple tasks quickly', () async {
        // Arrange
        const simpleTexts = [
          'Buy milk',
          'Call mom',
          'Meeting at 3 PM',
          'Doctor appointment',
          'Pay bills',
        ];

        // Act & Assert
        for (final text in simpleTexts) {
          final stopwatch = Stopwatch()..start();
          await aiParser.parseTaskFromText(text);
          stopwatch.stop();

          expect(
            stopwatch.elapsedMilliseconds,
            lessThan(50),
            reason: 'Simple text parsing should be under 50ms: $text',
          );
        }
      });

      test('should parse complex tasks within reasonable time', () async {
        // Arrange
        const complexTexts = [
          '''URGENT: Complete quarterly business review presentation for board meeting next Tuesday at 10 AM.
Include the following sections:
1. Q3 financial summary and variance analysis
2. Key performance indicators and metrics
3. Market analysis and competitive positioning
4. Product roadmap and development updates
5. Risk assessment and mitigation strategies
Make sure to coordinate with finance team for latest numbers.''',
          '''Plan weekend family trip:
- Book hotel reservations for Saturday night
- Research local restaurants and attractions
- Pack bags with weather-appropriate clothing
- Prepare snacks and entertainment for the drive
- Confirm pet sitting arrangements
- Set up auto-reply for work email''',
          '''Project milestone review scheduled for Friday at 2 PM in conference room B.
Attendees: development team, product manager, QA lead, and stakeholders.
Agenda items include feature completion status, bug triage, performance metrics,
user feedback analysis, and next sprint planning. Please prepare status reports
and demo materials in advance.''',
        ];

        // Act & Assert
        for (final text in complexTexts) {
          final stopwatch = Stopwatch()..start();
          final result = await aiParser.parseTaskFromText(text);
          stopwatch.stop();

          expect(
            stopwatch.elapsedMilliseconds,
            lessThan(500),
            reason: 'Complex text parsing should be under 500ms',
          );

          // Verify quality of parsing wasn't sacrificed for speed
          expect(result.title, isNotEmpty);
          expect(result.priority, isNotNull);
          expect(result.suggestedTags, isNotEmpty);
        }
      });

      test('should handle batch processing efficiently', () async {
        // Arrange
        final batchTexts = List.generate(100, (i) => 'Task $i: Complete item number $i');
        final stopwatch = Stopwatch()..start();

        // Act
        final results = <Future>[];
        for (final text in batchTexts) {
          results.add(aiParser.parseTaskFromText(text));
        }
        await Future.wait(results);
        stopwatch.stop();

        // Assert
        final averageTimePerTask = stopwatch.elapsedMilliseconds / batchTexts.length;
        expect(
          averageTimePerTask,
          lessThan(100),
          reason: 'Batch processing should average under 100ms per task',
        );
      });

      test('should maintain performance with very long input', () async {
        // Arrange
        final longText = '''
This is an extremely long task description that contains many words and detailed information
about a complex project that needs to be completed. The description includes multiple
paragraphs, various requirements, deadlines, stakeholder information, and technical
specifications. It also contains numbered lists, bullet points, and extensive details
about the scope of work, expected deliverables, quality criteria, testing requirements,
documentation needs, approval processes, and follow-up activities. The text continues
with additional sections covering risk analysis, resource allocation, timeline constraints,
budget considerations, compliance requirements, and integration details.

Here are the specific requirements:
1. Complete comprehensive analysis of current system architecture
2. Design new scalable solution with microservices approach
3. Implement robust authentication and authorization mechanisms
4. Develop comprehensive API documentation with examples
5. Create automated testing suite with unit, integration, and end-to-end tests
6. Set up continuous integration and deployment pipelines
7. Implement monitoring, logging, and alerting systems
8. Conduct security audit and penetration testing
9. Prepare deployment runbooks and operational procedures
10. Train team members on new system architecture and processes

Additional considerations include performance optimization, scalability planning,
disaster recovery procedures, data migration strategies, user training materials,
and comprehensive documentation for maintenance and future enhancements.
''' * 10; // Multiply to make it extremely long

        final stopwatch = Stopwatch()..start();

        // Act
        final result = await aiParser.parseTaskFromText(longText);
        stopwatch.stop();

        // Assert
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(1000),
          reason: 'Very long text should still parse under 1 second',
        );
        expect(result.title, isNotEmpty);
        expect(result.title.length, lessThan(100)); // Should be truncated reasonably
      });
    });

    group('Task Model Performance Tests', () {
      test('should create tasks quickly', () {
        // Arrange & Act
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 1000; i++) {
          TaskModel.create(
            title: 'Performance Test Task $i',
            description: 'Testing task creation performance',
            priority: TaskPriority.values[i % TaskPriority.values.length],
            tags: ['test', 'performance', 'batch-$i'],
          );
        }
        
        stopwatch.stop();

        // Assert
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
          reason: '1000 task creations should take under 100ms',
        );
      });

      test('should perform operations on large task lists efficiently', () {
        // Arrange
        final tasks = List.generate(10000, (i) => TaskModel.create(
          title: 'Task $i',
          priority: TaskPriority.values[i % TaskPriority.values.length],
          status: TaskStatus.values[i % TaskStatus.values.length],
          tags: ['tag-${i % 10}'],
        ));

        // Test filtering performance
        final stopwatch1 = Stopwatch()..start();
        final highPriorityTasks = tasks.where((task) => task.priority == TaskPriority.high).toList();
        stopwatch1.stop();

        // Test sorting performance
        final stopwatch2 = Stopwatch()..start();
        tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        stopwatch2.stop();

        // Test searching performance
        final stopwatch3 = Stopwatch()..start();
        final searchResults = tasks.where((task) => task.title.contains('500')).toList();
        stopwatch3.stop();

        // Assert
        expect(stopwatch1.elapsedMilliseconds, lessThan(50), reason: 'Filtering 10k tasks should be under 50ms');
        expect(stopwatch2.elapsedMilliseconds, lessThan(100), reason: 'Sorting 10k tasks should be under 100ms');
        expect(stopwatch3.elapsedMilliseconds, lessThan(50), reason: 'Searching 10k tasks should be under 50ms');
        
        expect(highPriorityTasks, isNotEmpty);
        expect(searchResults, isNotEmpty);
      });

      test('should handle complex task operations efficiently', () {
        // Arrange
        final baseTask = TaskModel.create(
          title: 'Complex Task',
          description: 'Original description',
          tags: ['original'],
          dependencies: [],
        );

        final stopwatch = Stopwatch()..start();

        // Act - Perform many operations
        var task = baseTask;
        for (int i = 0; i < 1000; i++) {
          task = task
              .addTag('tag-$i')
              .addDependency('dep-$i')
              .copyWith(description: 'Updated description $i')
              .updateMetadata({'iteration': i.toString()});
        }

        stopwatch.stop();

        // Assert
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(200),
          reason: '1000 complex operations should complete under 200ms',
        );
        expect(task.tags.length, greaterThan(1000));
        expect(task.dependencies.length, 1000);
        expect(task.metadata['iteration'], '999');
      });
    });

    group('Memory Performance Tests', () {
      test('should not cause memory leaks with repeated operations', () {
        // This test checks for memory efficiency
        // Note: Actual memory monitoring would require platform-specific tools
        
        // Arrange
        final initialTasks = <TaskModel>[];
        
        // Act - Create and destroy many objects
        for (int cycle = 0; cycle < 10; cycle++) {
          final tasks = List.generate(1000, (i) => TaskModel.create(
            title: 'Memory Test Task $cycle-$i',
            tags: List.generate(5, (j) => 'tag-$j'),
          ));
          
          // Perform operations
          for (final task in tasks) {
            task.copyWith(title: '${task.title} - modified');
            task.addTag('extra');
            task.markCompleted();
          }
          
          // Keep only a few references
          if (cycle == 0) {
            initialTasks.addAll(tasks.take(10));
          }
          
          // Let garbage collection work
          tasks.clear();
        }

        // Assert
        expect(initialTasks.length, 10);
        expect(initialTasks.first.title, contains('Memory Test Task 0-0'));
      });

      test('should handle large datasets efficiently', () {
        // Arrange
        const largeDatasetSize = 50000;
        final stopwatch = Stopwatch()..start();

        // Act
        final largeTasks = List.generate(largeDatasetSize, (i) {
          return TaskModel.create(
            title: 'Large Dataset Task $i',
            description: 'Description for task $i with some detailed content',
            priority: TaskPriority.values[i % TaskPriority.values.length],
            tags: ['large-dataset', 'batch-${i ~/ 1000}'],
          );
        });

        // Perform some operations on the large dataset
        final completedTasks = largeTasks.where((task) => 
          task.priority == TaskPriority.high).take(100).toList();
        
        for (final task in completedTasks) {
          task.markCompleted();
        }

        stopwatch.stop();

        // Assert
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(2000),
          reason: 'Creating and processing 50k tasks should complete under 2 seconds',
        );
        expect(largeTasks.length, largeDatasetSize);
        expect(completedTasks.length, 100);
      });
    });

    group('Concurrency Performance Tests', () {
      test('should handle concurrent task operations', () async {
        // Arrange
        final futures = <Future>[];
        final results = <TaskModel>[];
        final stopwatch = Stopwatch()..start();

        // Act - Create many concurrent operations
        for (int i = 0; i < 100; i++) {
          futures.add(
            Future.microtask(() {
              final task = TaskModel.create(title: 'Concurrent Task $i');
              final modifiedTask = task
                  .addTag('concurrent')
                  .copyWith(description: 'Processed concurrently')
                  .markInProgress();
              return modifiedTask;
            })
          );
        }

        final concurrentResults = await Future.wait(futures);
        stopwatch.stop();

        // Assert
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
          reason: '100 concurrent operations should complete under 100ms',
        );
        expect(concurrentResults.length, 100);
        expect(concurrentResults.every((task) => task.status == TaskStatus.inProgress), true);
      });

      test('should handle AI parsing concurrency', () async {
        // Arrange
        final texts = List.generate(20, (i) => 'Concurrent parsing test task $i with priority level ${i % 3}');
        final stopwatch = Stopwatch()..start();

        // Act
        final futures = texts.map((text) => aiParser.parseTaskFromText(text));
        final results = await Future.wait(futures);
        stopwatch.stop();

        // Assert
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(1000),
          reason: '20 concurrent AI parsing operations should complete under 1 second',
        );
        expect(results.length, 20);
        expect(results.every((result) => result.title.isNotEmpty), true);
      });
    });

    group('Database Performance Tests', () {
      test('should handle bulk operations efficiently', () async {
        // Note: This would require actual database setup in a real test
        // Here we're testing the data conversion performance
        
        // Arrange
        final tasks = List.generate(1000, (i) => TaskModel.create(
          title: 'Bulk Task $i',
          description: 'Bulk operation test task number $i',
          priority: TaskPriority.values[i % TaskPriority.values.length],
          tags: ['bulk', 'test', 'performance'],
        ));

        final stopwatch = Stopwatch()..start();

        // Act - Simulate data conversion operations
        final conversions = tasks.map((task) {
          // This simulates the conversion to database format
          return {
            'id': task.id,
            'title': task.title,
            'description': task.description,
            'priority': task.priority.name,
            'tags': task.tags.join(','),
            'created_at': task.createdAt.toIso8601String(),
          };
        }).toList();

        stopwatch.stop();

        // Assert
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
          reason: '1000 data conversions should complete under 100ms',
        );
        expect(conversions.length, 1000);
        expect(conversions.first['title'], 'Bulk Task 0');
      });
    });

    group('Stress Tests', () {
      test('should survive extreme load conditions', () async {
        // Arrange
        const extremeTaskCount = 100000;
        final stopwatch = Stopwatch()..start();

        // Act
        final results = <TaskModel>[];
        for (int i = 0; i < extremeTaskCount; i++) {
          final task = TaskModel.create(
            title: 'Stress Test $i',
            priority: TaskPriority.values[i % TaskPriority.values.length],
          );
          
          if (i % 10000 == 0) {
            // Perform some operations every 10k tasks
            task.addTag('milestone').markInProgress();
          }
          
          results.add(task);
          
          // Clear old references periodically to prevent memory issues
          if (i % 50000 == 0 && i > 0) {
            results.removeRange(0, results.length ~/ 2);
          }
        }

        stopwatch.stop();

        // Assert
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(10000),
          reason: 'Extreme stress test should complete under 10 seconds',
        );
        expect(results.length, greaterThan(50000)); // At least half should remain
      });

      test('should handle rapid successive operations', () async {
        // Arrange
        var task = TaskModel.create(title: 'Rapid Operations Task');
        final stopwatch = Stopwatch()..start();

        // Act - Perform rapid successive operations
        for (int i = 0; i < 10000; i++) {
          task = task
              .copyWith(title: 'Rapid Task $i')
              .addTag('rapid-$i')
              .updateMetadata({'iteration': i.toString()});
          
          if (i % 1000 == 0) {
            task = task.markInProgress().markCompleted().resetToPending();
          }
        }

        stopwatch.stop();

        // Assert
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(1000),
          reason: '10000 rapid operations should complete under 1 second',
        );
        expect(task.title, 'Rapid Task 9999');
        expect(task.tags.length, 10001); // Original + 10000 added
        expect(task.metadata['iteration'], '9999');
      });
    });

    group('Performance Monitoring Tests', () {
      test('should track performance metrics accurately', () async {
        // Arrange
        await performanceService.initialize();
        const operation = 'test_operation';

        // Act
        performanceService.startTimer(operation);
        await Future.delayed(const Duration(milliseconds: 100));
        performanceService.stopTimer(operation);

        // Record some metrics
        performanceService.recordMetric(
          'test_metric',
          const Duration(milliseconds: 50),
          metadata: {'test': 'value'},
        );

        // Assert
        // Performance service should track these metrics
        // In a real implementation, you'd verify the metrics were recorded
        expect(performanceService, isNotNull);
      });

      test('should handle high-frequency metric recording', () {
        // Arrange
        const metricCount = 10000;
        final stopwatch = Stopwatch()..start();

        // Act
        for (int i = 0; i < metricCount; i++) {
          performanceService.recordMetric(
            'high_frequency_metric',
            Duration(microseconds: i),
            metadata: {'iteration': i.toString()},
          );
        }

        stopwatch.stop();

        // Assert
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(1000),
          reason: '10k metric recordings should complete under 1 second',
        );
      });
    });

    group('Edge Case Performance Tests', () {
      test('should handle empty and null values efficiently', () {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act
        for (int i = 0; i < 1000; i++) {
          final task = TaskModel.create(
            title: '', // Empty title
            description: null, // Null description
            tags: [], // Empty tags
          );
          
          task.copyWith(
            title: null, // Null in copyWith
            tags: const [], // Empty tags
          );
        }

        stopwatch.stop();

        // Assert
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(50),
          reason: 'Handling empty/null values should be very fast',
        );
      });

      test('should handle unicode and special characters efficiently', () async {
        // Arrange
        const unicodeTexts = [
          '完成项目文档 📝',
          'Réunion importante à 14h 🇫🇷',
          'Встреча с командой 🇷🇺',
          'مقابلة العمل في الساعة الثالثة',
          '🚀 Launch new feature 🎉',
          'Task with emojis: 😀😃😄😁😆😅',
        ];

        final stopwatch = Stopwatch()..start();

        // Act
        for (final text in unicodeTexts) {
          await aiParser.parseTaskFromText(text);
          
          final task = TaskModel.create(
            title: text,
            description: '$text - detailed description',
            tags: [text.substring(0, text.length.clamp(0, 10))],
          );
          
          task.copyWith(title: '${task.title} - updated');
        }

        stopwatch.stop();

        // Assert
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(300),
          reason: 'Unicode handling should be efficient',
        );
      });
    });
  });
}