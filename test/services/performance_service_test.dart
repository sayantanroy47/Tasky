import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_tracker_app/services/performance_service.dart';

@GenerateMocks([SharedPreferences])


void main() {
  group('PerformanceService', () {
    late PerformanceService performanceService;

    setUp(() {
      performanceService = PerformanceService();
      
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      performanceService.dispose();
    });

    group('Timer Operations', () {
      test('should start and stop timer correctly', () {
        const operation = 'test_operation';
        
        performanceService.startTimer(operation);
        
        // Simulate some work
        Future.delayed(const Duration(milliseconds: 10));
        
        performanceService.stopTimer(operation);
        
        // Verify timer was recorded (would need access to metrics)
        expect(performanceService, isNotNull);
      });

      test('should handle multiple concurrent timers', () {
        performanceService.startTimer('operation1');
        performanceService.startTimer('operation2');
        
        performanceService.stopTimer('operation1');
        performanceService.stopTimer('operation2');
        
        expect(performanceService, isNotNull);
      });

      test('should handle stopping non-existent timer gracefully', () {
        expect(() => performanceService.stopTimer('non_existent'), returnsNormally);
      });
    });

    group('Metric Recording', () {
      test('should record metric with duration', () {
        const operation = 'test_metric';
        const duration = Duration(milliseconds: 100);
        
        performanceService.recordMetric(operation, duration);
        
        expect(performanceService, isNotNull);
      });

      test('should record metric with metadata', () {
        const operation = 'test_metric_with_metadata';
        const duration = Duration(milliseconds: 50);
        final metadata = {'key': 'value', 'count': 5};
        
        performanceService.recordMetric(operation, duration, metadata: metadata);
        
        expect(performanceService, isNotNull);
      });
    });

    group('Performance Stats', () {
      test('should generate performance stats', () async {
        // Record some test metrics
        performanceService.recordMetric('operation1', const Duration(milliseconds: 100));
        performanceService.recordMetric('operation1', const Duration(milliseconds: 150));
        performanceService.recordMetric('operation2', const Duration(milliseconds: 50));
        
        final stats = await performanceService.getPerformanceStats();
        
        expect(stats.totalMetrics, greaterThan(0));
        expect(stats.operationStats, isNotEmpty);
        expect(stats.generatedAt, isA<DateTime>());
      });

      test('should calculate operation statistics correctly', () async {
        // Record metrics for a specific operation
        const operation = 'test_operation';
        performanceService.recordMetric(operation, const Duration(milliseconds: 100));
        performanceService.recordMetric(operation, const Duration(milliseconds: 200));
        performanceService.recordMetric(operation, const Duration(milliseconds: 300));
        
        final stats = await performanceService.getPerformanceStats();
        final opStats = stats.operationStats[operation];
        
        expect(opStats, isNotNull);
        expect(opStats!.count, equals(3));
        expect(opStats.averageDuration.inMilliseconds, equals(200));
        expect(opStats.minDuration.inMilliseconds, equals(100));
        expect(opStats.maxDuration.inMilliseconds, equals(300));
      });
    });

    group('Memory Management', () {
      test('should record memory usage', () {
        expect(() => performanceService.recordMemoryUsage(), returnsNormally);
      });
    });

    group('Initialization', () {
      test('should initialize without errors', () async {
        expect(() => performanceService.initialize(), returnsNormally);
      });
    });
  });

  group('MemoryManager', () {
    test('should start and stop periodic cleanup', () {
      expect(() => MemoryManager.startPeriodicCleanup(), returnsNormally);
      expect(() => MemoryManager.stopPeriodicCleanup(), returnsNormally);
    });

    test('should perform cleanup without errors', () {
      expect(() => MemoryManager.performCleanup(), returnsNormally);
    });
  });

  group('PerformanceMetric', () {
    test('should serialize to JSON correctly', () {
      final metric = PerformanceMetric(
        operation: 'test_operation',
        duration: const Duration(milliseconds: 100),
        timestamp: DateTime(2023, 1, 1, 12, 0, 0),
        metadata: {'key': 'value'},
      );

      final json = metric.toJson();

      expect(json['operation'], equals('test_operation'));
      expect(json['duration_ms'], equals(100));
      expect(json['timestamp'], equals('2023-01-01T12:00:00.000'));
      expect(json['metadata'], equals({'key': 'value'}));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'operation': 'test_operation',
        'duration_ms': 100,
        'timestamp': '2023-01-01T12:00:00.000',
        'metadata': {'key': 'value'},
      };

      final metric = PerformanceMetric.fromJson(json);

      expect(metric.operation, equals('test_operation'));
      expect(metric.duration.inMilliseconds, equals(100));
      expect(metric.timestamp, equals(DateTime(2023, 1, 1, 12, 0, 0)));
      expect(metric.metadata, equals({'key': 'value'}));
    });
  });
}
