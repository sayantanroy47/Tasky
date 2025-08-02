import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/core/services/app_initialization_service.dart';
import 'package:task_tracker_app/services/error_recovery_service.dart';
import 'package:task_tracker_app/services/performance_service.dart';
import 'package:task_tracker_app/services/privacy_service.dart';

@GenerateMocks([ErrorRecoveryService, PerformanceService, PrivacyService])
import 'app_initialization_service_test.mocks.dart';

void main() {
  group('AppInitializationService', () {
    late AppInitializationService initService;
    late MockErrorRecoveryService mockErrorRecoveryService;
    late MockPerformanceService mockPerformanceService;
    late MockPrivacyService mockPrivacyService;

    setUp(() {
      mockErrorRecoveryService = const MockErrorRecoveryService();
      mockPerformanceService = const MockPerformanceService();
      mockPrivacyService = const MockPrivacyService();
      
      initService = AppInitializationService(
        mockErrorRecoveryService,
        mockPerformanceService,
        mockPrivacyService,
      );
    });

    group('Initialization', () {
      test('should initialize all services successfully', () async {
        // Arrange
        when(mockErrorRecoveryService.initialize()).thenAnswer((_) async {});
        when(mockPerformanceService.initialize()).thenAnswer((_) async {});
        when(mockPrivacyService.initializePrivacyDefaults()).thenAnswer((_) async {});
        when(mockErrorRecoveryService.restoreAppState()).thenAnswer((_) async => null);
        when(mockErrorRecoveryService.performHealthCheck()).thenAnswer((_) async => 
          const AppHealthStatus(
            level: HealthLevel.healthy,
            message: 'All good',
            crashCount: 0,
            errorCount: 0,
            lastChecked: null,
          )
        );

        // Act
        await initService.initialize();

        // Assert
        verify(mockErrorRecoveryService.initialize()).called(1);
        verify(mockPerformanceService.initialize()).called(1);
        verify(mockPrivacyService.initializePrivacyDefaults()).called(1);
        verify(mockErrorRecoveryService.performHealthCheck()).called(1);
      });

      test('should start and stop performance timer', () async {
        // Arrange
        when(mockErrorRecoveryService.initialize()).thenAnswer((_) async {});
        when(mockPerformanceService.initialize()).thenAnswer((_) async {});
        when(mockPrivacyService.initializePrivacyDefaults()).thenAnswer((_) async {});
        when(mockErrorRecoveryService.restoreAppState()).thenAnswer((_) async => null);
        when(mockErrorRecoveryService.performHealthCheck()).thenAnswer((_) async => 
          const AppHealthStatus(
            level: HealthLevel.healthy,
            message: 'All good',
            crashCount: 0,
            errorCount: 0,
            lastChecked: null,
          )
        );

        // Act
        await initService.initialize();

        // Assert
        verify(mockPerformanceService.startTimer('app_initialization_service')).called(1);
        verify(mockPerformanceService.stopTimer('app_initialization_service')).called(1);
      });

      test('should attempt state recovery', () async {
        // Arrange
        final restoredState = {'key': 'value'};
        when(mockErrorRecoveryService.initialize()).thenAnswer((_) async {});
        when(mockPerformanceService.initialize()).thenAnswer((_) async {});
        when(mockPrivacyService.initializePrivacyDefaults()).thenAnswer((_) async {});
        when(mockErrorRecoveryService.restoreAppState()).thenAnswer((_) async => restoredState);
        when(mockErrorRecoveryService.performHealthCheck()).thenAnswer((_) async => 
          const AppHealthStatus(
            level: HealthLevel.healthy,
            message: 'All good',
            crashCount: 0,
            errorCount: 0,
            lastChecked: null,
          )
        );

        // Act
        await initService.initialize();

        // Assert
        verify(mockErrorRecoveryService.restoreAppState()).called(1);
      });

      test('should handle critical health status', () async {
        // Arrange
        when(mockErrorRecoveryService.initialize()).thenAnswer((_) async {});
        when(mockPerformanceService.initialize()).thenAnswer((_) async {});
        when(mockPrivacyService.initializePrivacyDefaults()).thenAnswer((_) async {});
        when(mockErrorRecoveryService.restoreAppState()).thenAnswer((_) async => null);
        when(mockErrorRecoveryService.performHealthCheck()).thenAnswer((_) async => 
          const AppHealthStatus(
            level: HealthLevel.critical,
            message: 'Critical issues detected',
            crashCount: 5,
            errorCount: 20,
            lastChecked: null,
          )
        );
        when(mockErrorRecoveryService.clearOldReports()).thenAnswer((_) async {});

        // Act
        await initService.initialize();

        // Assert
        verify(mockErrorRecoveryService.clearOldReports()).called(1);
        verify(mockPrivacyService.initializePrivacyDefaults()).called(2); // Once normally, once for recovery
      });

      test('should record error on initialization failure', () async {
        // Arrange
        final error = Exception('Initialization failed');
        when(mockErrorRecoveryService.initialize()).thenThrow(error);
        when(mockPerformanceService.stopTimer('app_initialization_service')).thenReturn(null);
        when(mockErrorRecoveryService.recordError(any, any, any)).thenAnswer((_) async {});

        // Act & Assert
        expect(() => initService.initialize(), throwsException);
        
        // Verify error was recorded
        await untilCalled(mockErrorRecoveryService.recordError(any, any, any));
        verify(mockErrorRecoveryService.recordError(
          'app_initialization',
          error,
          any,
        )).called(1);
      });

      test('should handle state recovery failure gracefully', () async {
        // Arrange
        when(mockErrorRecoveryService.initialize()).thenAnswer((_) async {});
        when(mockPerformanceService.initialize()).thenAnswer((_) async {});
        when(mockPrivacyService.initializePrivacyDefaults()).thenAnswer((_) async {});
        when(mockErrorRecoveryService.restoreAppState()).thenThrow(Exception('Recovery failed'));
        when(mockErrorRecoveryService.recordError(any, any, any)).thenAnswer((_) async {});
        when(mockErrorRecoveryService.performHealthCheck()).thenAnswer((_) async => 
          const AppHealthStatus(
            level: HealthLevel.healthy,
            message: 'All good',
            crashCount: 0,
            errorCount: 0,
            lastChecked: null,
          )
        );

        // Act
        await initService.initialize();

        // Assert - should continue initialization despite recovery failure
        verify(mockErrorRecoveryService.recordError(
          'state_recovery',
          any,
          any,
        )).called(1);
        verify(mockErrorRecoveryService.performHealthCheck()).called(1);
      });

      test('should handle critical health recovery failure', () async {
        // Arrange
        when(mockErrorRecoveryService.initialize()).thenAnswer((_) async {});
        when(mockPerformanceService.initialize()).thenAnswer((_) async {});
        when(mockPrivacyService.initializePrivacyDefaults()).thenAnswer((_) async {});
        when(mockErrorRecoveryService.restoreAppState()).thenAnswer((_) async => null);
        when(mockErrorRecoveryService.performHealthCheck()).thenAnswer((_) async => 
          const AppHealthStatus(
            level: HealthLevel.critical,
            message: 'Critical issues detected',
            crashCount: 5,
            errorCount: 20,
            lastChecked: null,
          )
        );
        when(mockErrorRecoveryService.clearOldReports()).thenThrow(Exception('Cleanup failed'));
        when(mockErrorRecoveryService.recordError(any, any, any)).thenAnswer((_) async {});

        // Act
        await initService.initialize();

        // Assert
        verify(mockErrorRecoveryService.recordError(
          'critical_health_recovery',
          any,
          any,
        )).called(1);
      });
    });

    group('Service Dependencies', () {
      test('should initialize services in correct order', () async {
        // Arrange
        final callOrder = <String>[];
        
        when(mockErrorRecoveryService.initialize()).thenAnswer((_) async {
          callOrder.add('error_recovery');
        });
        when(mockPerformanceService.initialize()).thenAnswer((_) async {
          callOrder.add('performance');
        });
        when(mockPrivacyService.initializePrivacyDefaults()).thenAnswer((_) async {
          callOrder.add('privacy');
        });
        when(mockErrorRecoveryService.restoreAppState()).thenAnswer((_) async {
          callOrder.add('state_recovery');
          return null;
        });
        when(mockErrorRecoveryService.performHealthCheck()).thenAnswer((_) async {
          callOrder.add('health_check');
          return const AppHealthStatus(
            level: HealthLevel.healthy,
            message: 'All good',
            crashCount: 0,
            errorCount: 0,
            lastChecked: null,
          );
        });

        // Act
        await initService.initialize();

        // Assert
        expect(callOrder, equals([
          'error_recovery',
          'performance',
          'privacy',
          'state_recovery',
          'health_check',
        ]));
      });
    });
  });
}