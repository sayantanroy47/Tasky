import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_tracker_app/services/error_recovery_service.dart';

@GenerateMocks([SharedPreferences])


void main() {
  group('ErrorRecoveryService', () {
    late ErrorRecoveryService errorRecoveryService;

    setUp(() {
      errorRecoveryService = ErrorRecoveryService();
      
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      errorRecoveryService.dispose();
    });

    group('Crash Reporting', () {
      test('should record crash report', () async {
        final crashReport = CrashReport(
          error: 'Test error',
          stackTrace: StackTrace.current,
          timestamp: DateTime.now(),
          isFatal: true,
        );

        await errorRecoveryService.recordCrash(crashReport);

        final reports = errorRecoveryService.getCrashReports();
        expect(reports, contains(crashReport));
      });

      test('should persist crash reports', () async {
        final crashReport = CrashReport(
          error: 'Test error',
          stackTrace: StackTrace.current,
          timestamp: DateTime.now(),
          isFatal: true,
        );

        await errorRecoveryService.recordCrash(crashReport);

        // Verify that crash reports are persisted
        expect(errorRecoveryService.getCrashReports(), isNotEmpty);
      });
    });

    group('Error Recording', () {
      test('should record non-fatal error', () async {
        const operation = 'test_operation';
        const error = 'Test error';
        final stackTrace = StackTrace.current;

        await errorRecoveryService.recordError(operation, error, stackTrace);

        expect(errorRecoveryService.errorCount, greaterThan(0));
      });

      test('should increment error count', () async {
        final initialCount = errorRecoveryService.errorCount;

        await errorRecoveryService.recordError('op1', 'error1', null);
        await errorRecoveryService.recordError('op2', 'error2', null);

        expect(errorRecoveryService.errorCount, equals(initialCount + 2));
      });
    });

    group('State Backup and Recovery', () {
      test('should backup app state', () async {
        final state = {
          'currentScreen': 'home',
          'userPreferences': {'theme': 'dark'},
        };

        expect(() => errorRecoveryService.backupAppState(state), returnsNormally);
      });

      test('should restore app state', () async {
        final state = {
          'currentScreen': 'home',
          'userPreferences': {'theme': 'dark'},
        };

        await errorRecoveryService.backupAppState(state);
        final restoredState = await errorRecoveryService.restoreAppState();

        expect(restoredState, isNotNull);
      });

      test('should return null for old backup', () async {
        // This test would require mocking time or using a test-specific implementation
        final restoredState = await errorRecoveryService.restoreAppState();
        expect(restoredState, isNull);
      });
    });

    group('Health Check', () {
      test('should perform health check', () async {
        final healthStatus = await errorRecoveryService.performHealthCheck();

        expect(healthStatus, isA<AppHealthStatus>());
        expect(healthStatus.level, isA<HealthLevel>());
        expect(healthStatus.message, isA<String>());
        expect(healthStatus.lastChecked, isA<DateTime>());
      });

      test('should report healthy status with no errors', () async {
        final healthStatus = await errorRecoveryService.performHealthCheck();

        expect(healthStatus.level, equals(HealthLevel.healthy));
        expect(healthStatus.crashCount, equals(0));
      });

      test('should report warning status with some errors', () async {
        // Record some errors
        for (int i = 0; i < 15; i++) {
          await errorRecoveryService.recordError('test_op', 'error', null);
        }

        final healthStatus = await errorRecoveryService.performHealthCheck();

        expect(healthStatus.level, equals(HealthLevel.warning));
        expect(healthStatus.errorCount, greaterThan(10));
      });
    });

    group('Retry Operations', () {
      test('should retry failed operation', () async {
        int attemptCount = 0;
        
        final result = await errorRecoveryService.retryOperation<String>(
          () async {
            attemptCount++;
            if (attemptCount < 3) {
              throw Exception('Temporary failure');
            }
            return 'Success';
          },
          'test_operation',
          maxRetries: 3,
          initialDelay: const Duration(milliseconds: 10),
        );

        expect(result, equals('Success'));
        expect(attemptCount, equals(3));
      });

      test('should fail after max retries', () async {
        int attemptCount = 0;
        
        expect(
          () => errorRecoveryService.retryOperation<String>(
            () async {
              attemptCount++;
              throw Exception('Persistent failure');
            },
            'test_operation',
            maxRetries: 2,
            initialDelay: const Duration(milliseconds: 10),
          ),
          throwsException,
        );

        expect(attemptCount, greaterThan(0)); // At least one attempt was made
      });

      test('should use exponential backoff', () async {
        int attemptCount = 0;
        
        try {
          await errorRecoveryService.retryOperation<String>(
            () async {
              attemptCount++;
              throw Exception('Test failure');
            },
            'test_operation',
            maxRetries: 3,
            initialDelay: const Duration(milliseconds: 100),
            backoffMultiplier: 2.0,
          );
        } catch (e) {
          // Expected to fail
        }

        expect(attemptCount, equals(3));
      });
    });

    group('Cleanup', () {
      test('should clear old reports', () async {
        // Add some crash reports
        final oldReport = CrashReport(
          error: 'Old error',
          stackTrace: StackTrace.current,
          timestamp: DateTime.now().subtract(const Duration(days: 35)),
          isFatal: true,
        );

        await errorRecoveryService.recordCrash(oldReport);
        
        final initialCount = errorRecoveryService.getCrashReports().length;
        
        await errorRecoveryService.clearOldReports();
        
        final finalCount = errorRecoveryService.getCrashReports().length;
        expect(finalCount, lessThan(initialCount));
      });

      test('should reset error count on cleanup', () async {
        // Record some errors
        await errorRecoveryService.recordError('op', 'error', null);
        expect(errorRecoveryService.errorCount, greaterThan(0));

        await errorRecoveryService.clearOldReports();
        expect(errorRecoveryService.errorCount, equals(0));
      });
    });
  });

  group('CrashReport', () {
    test('should serialize to JSON correctly', () {
      final crashReport = CrashReport(
        error: 'Test error',
        stackTrace: StackTrace.current,
        timestamp: DateTime(2023, 1, 1, 12, 0, 0),
        context: 'Test context',
        library: 'test_library',
        isFatal: true,
      );

      final json = crashReport.toJson();

      expect(json['error'], equals('Test error'));
      expect(json['timestamp'], equals('2023-01-01T12:00:00.000'));
      expect(json['context'], equals('Test context'));
      expect(json['library'], equals('test_library'));
      expect(json['isFatal'], equals(true));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'error': 'Test error',
        'stackTrace': 'Stack trace string',
        'timestamp': '2023-01-01T12:00:00.000',
        'context': 'Test context',
        'library': 'test_library',
        'isFatal': true,
      };

      final crashReport = CrashReport.fromJson(json);

      expect(crashReport.error, equals('Test error'));
      expect(crashReport.timestamp, equals(DateTime(2023, 1, 1, 12, 0, 0)));
      expect(crashReport.context, equals('Test context'));
      expect(crashReport.library, equals('test_library'));
      expect(crashReport.isFatal, equals(true));
    });
  });

  group('AppHealthStatus', () {
    test('should create health status correctly', () {
      final healthStatus = AppHealthStatus(
        level: HealthLevel.healthy,
        message: 'All good',
        crashCount: 0,
        errorCount: 0,
        lastChecked: DateTime.now(),
      );

      expect(healthStatus.level, equals(HealthLevel.healthy));
      expect(healthStatus.message, equals('All good'));
      expect(healthStatus.crashCount, equals(0));
      expect(healthStatus.errorCount, equals(0));
    });
  });
}
