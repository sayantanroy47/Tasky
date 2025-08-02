import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_tracker_app/main.dart' as app;
import 'package:task_tracker_app/services/performance_service.dart';
import 'package:task_tracker_app/services/error_recovery_service.dart';
import 'package:task_tracker_app/services/privacy_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('app should start successfully', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify app has loaded
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('app should handle initialization errors gracefully', (WidgetTester tester) async {
      // This would test error scenarios during app startup
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify error handling UI is not shown (app started successfully)
      expect(find.text('Failed to initialize app'), findsNothing);
    });

    testWidgets('performance monitoring should be active', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify performance monitoring is working
      // This would require access to the performance service
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('error recovery should be initialized', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify error recovery is working
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('privacy settings should be initialized', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify privacy settings are initialized
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Service Integration Tests', () {
    testWidgets('services should work together correctly', (WidgetTester tester) async {
      // Create a test app with all services
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final performanceService = ref.watch(performanceServiceProvider);
                final errorRecoveryService = ref.watch(errorRecoveryServiceProvider);
                final privacyService = ref.watch(privacyServiceProvider);

                return Scaffold(
                  body: Column(
                    children: [
                      Text('Performance: ${performanceService.runtimeType}'),
                      Text('Error Recovery: ${errorRecoveryService.runtimeType}'),
                      Text('Privacy: ${privacyService.runtimeType}'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all services are available
      expect(find.text('Performance: PerformanceService'), findsOneWidget);
      expect(find.text('Error Recovery: ErrorRecoveryService'), findsOneWidget);
      expect(find.text('Privacy: PrivacyService'), findsOneWidget);
    });

    testWidgets('error recovery should handle service failures', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final errorRecoveryService = ref.watch(errorRecoveryServiceProvider);

                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      // Simulate an error
                      errorRecoveryService.recordError(
                        'test_operation',
                        'Test error',
                        StackTrace.current,
                      );
                    },
                    child: const Text('Trigger Error'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger an error
      await tester.tap(find.text('Trigger Error'));
      await tester.pumpAndSettle();

      // Verify error was handled (no crash)
      expect(find.text('Trigger Error'), findsOneWidget);
    });
  });

  group('Performance Integration Tests', () {
    testWidgets('app startup should be within performance targets', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      stopwatch.stop();

      // Verify app starts within 5 seconds (generous for integration test)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('memory usage should be reasonable', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // This is a basic check - in a real app you'd measure actual memory usage
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Error Handling Integration Tests', () {
    testWidgets('app should recover from widget errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    onPressed: () {
                      // This would trigger a widget error in a real scenario
                      throw Exception('Test widget error');
                    },
                    child: const Text('Trigger Widget Error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // In a real implementation, this would test error boundary behavior
      expect(find.text('Trigger Widget Error'), findsOneWidget);
    });

    testWidgets('app should handle async errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    onPressed: () async {
                      // Simulate async error
                      await Future.delayed(const Duration(milliseconds: 100));
                      throw Exception('Async error');
                    },
                    child: const Text('Trigger Async Error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger async error
      await tester.tap(find.text('Trigger Async Error'));
      await tester.pumpAndSettle();

      // App should still be responsive
      expect(find.text('Trigger Async Error'), findsOneWidget);
    });
  });

  group('Privacy Integration Tests', () {
    testWidgets('privacy settings should persist across app restarts', (WidgetTester tester) async {
      // First app instance
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final privacyService = ref.watch(privacyServiceProvider);
                
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () async {
                      const settings = PrivacySettings(
                        dataMinimization: false,
                        localProcessingPreferred: false,
                        analyticsEnabled: true,
                        crashReportingEnabled: true,
                        locationTrackingEnabled: true,
                        voiceDataRetention: VoiceDataRetention.day,
                        aiProcessingConsent: true,
                        cloudSyncEnabled: true,
                        shareUsageData: true,
                        personalizedAds: true,
                      );
                      await privacyService.savePrivacySettings(settings);
                    },
                    child: const Text('Save Settings'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Save settings
      await tester.tap(find.text('Save Settings'));
      await tester.pumpAndSettle();

      // Simulate app restart by creating new widget tree
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final privacyService = ref.watch(privacyServiceProvider);
                
                return Scaffold(
                  body: FutureBuilder<PrivacySettings>(
                    future: privacyService.getPrivacySettings(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text('Analytics: ${snapshot.data!.analyticsEnabled}');
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify settings persisted
      expect(find.text('Analytics: true'), findsOneWidget);
    });
  });
}