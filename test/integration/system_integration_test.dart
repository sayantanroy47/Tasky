import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/core/integration/system_integration_service.dart';
import 'package:task_tracker_app/services/performance_service.dart';
import 'package:task_tracker_app/services/error_recovery_service.dart';
import 'package:task_tracker_app/services/privacy_service.dart';

@GenerateMocks([PerformanceService, ErrorRecoveryService, PrivacyService])
import 'system_integration_test.mocks.dart';

void main() {
  group('SystemIntegrationService', () {
    late SystemIntegrationService systemIntegrationService;
    late MockPerformanceService mockPerformanceService;
    late MockErrorRecoveryService mockErrorRecoveryService;
    late MockPrivacyService mockPrivacyService;

    setUp(() {
      mockPerformanceService = MockPerformanceService();
      mockErrorRecoveryService = MockErrorRecoveryService();
      mockPrivacyService = MockPrivacyService();
      
      systemIntegrationService = SystemIntegrationService(
        mockPerformanceService,
        mockErrorRecoveryService,
        mockPrivacyService,
      );
    });

    tearDown(() {
      systemIntegrationService.dispose();
    });

    group('Initialization', () {
      test('should initialize successfully with all services healthy', () async {
        // Arrange
        when(mockPerformanceService.initialize()).thenAnswer((_) async {});
        when(mockErrorRecoveryService.initialize()).thenAnswer((_) async {});
        when(mockPrivacyService.initializePrivacyDefaults()).thenAnswer((_) async {});
        when(mockPerformanceService.getPerformanceStats()).thenAnswer((_) async => 
          PerformanceStats(
            totalMetrics: 10,
            operationStats: {},
            generatedAt: DateTime.now(),
          )
        );
        when(mockErrorRecoveryService.performHealthCheck()).thenAnswer((_) async => 
          AppHealthStatus(
            level: HealthLevel.healthy,
            message: 'All good',
            crashCount: 0,
            errorCount: 0,
            lastChecked: DateTime.now(),
          )
        );
        when(mockPrivacyService.getPrivacySettings()).thenAnswer((_) async => 
          PrivacySettings.defaultSettings()
        );
        when(mockErrorRecoveryService.backupAppState(any)).thenAnswer((_) async {});
        when(mockErrorRecoveryService.restoreAppState()).thenAnswer((_) async => {'test': 'data'});

        // Act
        await systemIntegrationService.initialize();

        // Assert
        verify(mockPerformanceService.initialize()).called(1);
        verify(mockErrorRecoveryService.initialize()).called(1);
        verify(mockPrivacyService.initializePrivacyDefaults()).called(1);
      });

      test('should handle initialization failure gracefully', () async {
        // Arrange
        when(mockPerformanceService.initialize()).thenThrow(Exception('Init failed'));
        when(mockErrorRecoveryService.recordError(any, any, any)).thenAnswer((_) async {});

        // Act & Assert
        expect(() => systemIntegrationService.initialize(), throwsException);
        
        await untilCalled(mockErrorRecoveryService.recordError(any, any, any));
        verify(mockErrorRecoveryService.recordError(
          'system_integration_init',
          any,
          any,
        )).called(1);
      });
    });

    group('Health Checks', () {
      test('should run all health checks successfully', () async {
        // Arrange
        when(mockPerformanceService.getPerformanceStats()).thenAnswer((_) async => 
          PerformanceStats(
            totalMetrics: 10,
            operationStats: {},
            generatedAt: DateTime.now(),
          )
        );
        when(mockErrorRecoveryService.performHealthCheck()).thenAnswer((_) async => 
          AppHealthStatus(
            level: HealthLevel.healthy,
            message: 'All good',
            crashCount: 0,
            errorCount: 0,
            lastChecked: DateTime.now(),
          )
        );
        when(mockPrivacyService.getPrivacySettings()).thenAnswer((_) async => 
          PrivacySettings.defaultSettings()
        );

        // Act
        final status = await systemIntegrationService.runSystemHealthChecks();

        // Assert
        expect(status.isHealthy, isTrue);
        expect(status.failedChecks, isEmpty);
        expect(status.message, equals('All system health checks passed'));
      });

      test('should detect failed health checks', () async {
        // Arrange
        when(mockPerformanceService.getPerformanceStats()).thenThrow(Exception('Performance service failed'));
        when(mockErrorRecoveryService.performHealthCheck()).thenAnswer((_) async => 
          AppHealthStatus(
            level: HealthLevel.critical,
            message: 'Critical issues',
            crashCount: 5,
            errorCount: 20,
            lastChecked: DateTime.now(),
          )
        );
        when(mockPrivacyService.getPrivacySettings()).thenAnswer((_) async => 
          PrivacySettings.defaultSettings()
        );
        when(mockErrorRecoveryService.recordError(any, any, any)).thenAnswer((_) async {});

        // Act
        final status = await systemIntegrationService.runSystemHealthChecks();

        // Assert
        expect(status.isHealthy, isFalse);
        expect(status.failedChecks, isNotEmpty);
        expect(status.failedChecks, contains('performance_service'));
        expect(status.failedChecks, contains('error_recovery_service'));
      });

      test('should handle health check execution failure', () async {
        // Arrange
        when(mockPerformanceService.getPerformanceStats()).thenThrow(Exception('Critical failure'));
        when(mockErrorRecoveryService.recordError(any, any, any)).thenAnswer((_) async {});

        // Act
        final status = await systemIntegrationService.runSystemHealthChecks();

        // Assert
        expect(status.isHealthy, isFalse);
        expect(status.failedChecks, contains('performance_service'));
      });
    });

    group('Feature Integration Validation', () {
      test('should validate feature integrations successfully', () async {
        // Arrange
        when(mockErrorRecoveryService.backupAppState(any)).thenAnswer((_) async {});
        when(mockErrorRecoveryService.restoreAppState()).thenAnswer((_) async => {'test': 'data'});
        when(mockErrorRecoveryService.recordError(any, any, any)).thenAnswer((_) async {});
        when(mockPrivacyService.getPrivacySettings()).thenAnswer((_) async => 
          PrivacySettings.defaultSettings()
        );
        when(mockPerformanceService.getPerformanceStats()).thenAnswer((_) async => 
          PerformanceStats(
            totalMetrics: 10,
            operationStats: {},
            generatedAt: DateTime.now(),
          )
        );

        // Act
        expect(() => systemIntegrationService.validateFeatureIntegrations(), returnsNormally);
      });

      test('should handle feature integration validation failure', () async {
        // Arrange
        when(mockErrorRecoveryService.backupAppState(any)).thenThrow(Exception('Backup failed'));
        when(mockErrorRecoveryService.recordError(any, any, any)).thenAnswer((_) async {});

        // Act & Assert
        expect(() => systemIntegrationService.validateFeatureIntegrations(), throwsException);
        
        await untilCalled(mockErrorRecoveryService.recordError(any, any, any));
        verify(mockErrorRecoveryService.recordError(
          'feature_integration_validation',
          any,
          any,
        )).called(1);
      });
    });

    group('Critical User Flows', () {
      test('should test all critical user flows', () async {
        // Arrange
        when(mockPerformanceService.initialize()).thenAnswer((_) async {});
        when(mockErrorRecoveryService.initialize()).thenAnswer((_) async {});
        when(mockPrivacyService.initializePrivacyDefaults()).thenAnswer((_) async {});
        when(mockErrorRecoveryService.recordError(any, any, any)).thenAnswer((_) async {});
        when(mockErrorRecoveryService.backupAppState(any)).thenAnswer((_) async {});
        when(mockErrorRecoveryService.restoreAppState()).thenAnswer((_) async => {'recovered': true});
        when(mockPerformanceService.getPerformanceStats()).thenAnswer((_) async => 
          PerformanceStats(
            totalMetrics: 10,
            operationStats: {},
            generatedAt: DateTime.now(),
          )
        );
        when(mockPrivacyService.getPrivacySettings()).thenAnswer((_) async => 
          PrivacySettings.defaultSettings()
        );
        when(mockPrivacyService.recordConsent(any)).thenAnswer((_) async {});
        when(mockPrivacyService.hasConsent(any)).thenAnswer((_) async => false);
        when(mockPrivacyService.getComplianceStatus()).thenAnswer((_) async => 
          PrivacyComplianceStatus(
            isCompliant: true,
            issues: [],
            lastChecked: DateTime.now(),
          )
        );

        // Act
        final results = await systemIntegrationService.testCriticalUserFlows();

        // Assert
        expect(results, hasLength(4));
        expect(results.map((r) => r.flowName), containsAll([
          'app_startup',
          'error_recovery',
          'performance_optimization',
          'privacy_compliance',
        ]));
        
        // All flows should succeed with proper mocking
        for (final result in results) {
          expect(result.success, isTrue, reason: 'Flow ${result.flowName} failed: ${result.message}');
        }
      });

      test('should handle user flow test failures', () async {
        // Arrange
        when(mockPerformanceService.initialize()).thenThrow(Exception('Startup failed'));

        // Act
        final results = await systemIntegrationService.testCriticalUserFlows();

        // Assert
        final startupResult = results.firstWhere((r) => r.flowName == 'app_startup');
        expect(startupResult.success, isFalse);
        expect(startupResult.message, contains('App startup flow failed'));
      });
    });

    group('Service Interactions', () {
      test('should test service interactions correctly', () async {
        // Arrange
        when(mockPrivacyService.getPrivacySettings()).thenAnswer((_) async => 
          PrivacySettings.defaultSettings().copyWith(analyticsEnabled: true)
        );
        when(mockErrorRecoveryService.recordError(any, any, any)).thenAnswer((_) async {});

        // Act
        await systemIntegrationService.validateFeatureIntegrations();

        // Assert
        verify(mockPrivacyService.getPrivacySettings()).called(1);
        verify(mockErrorRecoveryService.recordError(any, any, any)).called(greaterThan(0));
      });
    });

    group('Data Flow Testing', () {
      test('should test data flow between components', () async {
        // Arrange
        final testData = {'test': 'data', 'timestamp': DateTime.now().toIso8601String()};
        when(mockErrorRecoveryService.backupAppState(any)).thenAnswer((_) async {});
        when(mockErrorRecoveryService.restoreAppState()).thenAnswer((_) async => testData);

        // Act
        await systemIntegrationService.validateFeatureIntegrations();

        // Assert
        verify(mockErrorRecoveryService.backupAppState(any)).called(1);
        verify(mockErrorRecoveryService.restoreAppState()).called(1);
      });

      test('should handle data flow failures', () async {
        // Arrange
        when(mockErrorRecoveryService.backupAppState(any)).thenAnswer((_) async {});
        when(mockErrorRecoveryService.restoreAppState()).thenAnswer((_) async => null);
        when(mockErrorRecoveryService.recordError(any, any, any)).thenAnswer((_) async {});

        // Act & Assert
        expect(() => systemIntegrationService.validateFeatureIntegrations(), throwsStateError);
      });
    });

    group('Performance Under Load', () {
      test('should handle performance under simulated load', () async {
        // Arrange
        when(mockPerformanceService.getPerformanceStats()).thenAnswer((_) async => 
          PerformanceStats(
            totalMetrics: 10,
            operationStats: {},
            generatedAt: DateTime.now(),
          )
        );
        when(mockErrorRecoveryService.backupAppState(any)).thenAnswer((_) async {});
        when(mockErrorRecoveryService.restoreAppState()).thenAnswer((_) async => {'test': 'data'});
        when(mockErrorRecoveryService.recordError(any, any, any)).thenAnswer((_) async {});
        when(mockPrivacyService.getPrivacySettings()).thenAnswer((_) async => 
          PrivacySettings.defaultSettings()
        );

        // Act
        expect(() => systemIntegrationService.validateFeatureIntegrations(), returnsNormally);

        // Assert
        verify(mockPerformanceService.getPerformanceStats()).called(1);
      });

      test('should handle performance failure under load', () async {
        // Arrange
        when(mockPerformanceService.getPerformanceStats()).thenAnswer((_) async => 
          PerformanceStats(
            totalMetrics: 0, // No metrics recorded
            operationStats: {},
            generatedAt: DateTime.now(),
          )
        );
        when(mockErrorRecoveryService.backupAppState(any)).thenAnswer((_) async {});
        when(mockErrorRecoveryService.restoreAppState()).thenAnswer((_) async => {'test': 'data'});
        when(mockErrorRecoveryService.recordError(any, any, any)).thenAnswer((_) async {});
        when(mockPrivacyService.getPrivacySettings()).thenAnswer((_) async => 
          PrivacySettings.defaultSettings()
        );

        // Act & Assert
        expect(() => systemIntegrationService.validateFeatureIntegrations(), throwsStateError);
      });
    });

    group('Status Stream', () {
      test('should emit status updates', () async {
        // Arrange
        when(mockPerformanceService.getPerformanceStats()).thenAnswer((_) async => 
          PerformanceStats(
            totalMetrics: 10,
            operationStats: {},
            generatedAt: DateTime.now(),
          )
        );
        when(mockErrorRecoveryService.performHealthCheck()).thenAnswer((_) async => 
          AppHealthStatus(
            level: HealthLevel.healthy,
            message: 'All good',
            crashCount: 0,
            errorCount: 0,
            lastChecked: DateTime.now(),
          )
        );
        when(mockPrivacyService.getPrivacySettings()).thenAnswer((_) async => 
          PrivacySettings.defaultSettings()
        );

        // Act
        final statusFuture = systemIntegrationService.statusStream.first;
        await systemIntegrationService.runSystemHealthChecks();
        final status = await statusFuture;

        // Assert
        expect(status.isHealthy, isTrue);
        expect(status.message, equals('All system health checks passed'));
      });
    });
  });

  group('SystemHealthCheck', () {
    test('should execute health check correctly', () async {
      // Arrange
      bool executed = false;
      final healthCheck = SystemHealthCheck(
        name: 'test_check',
        description: 'Test health check',
        execute: () async {
          executed = true;
          return true;
        },
      );

      // Act
      final result = await healthCheck.execute();

      // Assert
      expect(result, isTrue);
      expect(executed, isTrue);
    });
  });

  group('SystemIntegrationStatus', () {
    test('should create status correctly', () {
      // Arrange & Act
      final status = SystemIntegrationStatus(
        isHealthy: true,
        message: 'All good',
        timestamp: DateTime.now(),
        failedChecks: [],
        checkResults: {'test': true},
      );

      // Assert
      expect(status.isHealthy, isTrue);
      expect(status.message, equals('All good'));
      expect(status.failedChecks, isEmpty);
      expect(status.checkResults, equals({'test': true}));
    });
  });

  group('UserFlowTestResult', () {
    test('should create result correctly', () {
      // Arrange & Act
      const result = UserFlowTestResult(
        flowName: 'test_flow',
        success: true,
        duration: Duration(milliseconds: 100),
        message: 'Flow completed',
      );

      // Assert
      expect(result.flowName, equals('test_flow'));
      expect(result.success, isTrue);
      expect(result.duration, equals(const Duration(milliseconds: 100)));
      expect(result.message, equals('Flow completed'));
    });
  });
}
