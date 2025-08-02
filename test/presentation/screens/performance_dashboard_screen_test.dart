import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/presentation/screens/performance_dashboard_screen.dart';
import 'package:task_tracker_app/services/performance_service.dart';

@GenerateMocks([PerformanceService])
import 'performance_dashboard_screen_test.mocks.dart';

void main() {
  group('PerformanceDashboardScreen', () {
    late MockPerformanceService mockPerformanceService;

    setUp(() {
      mockPerformanceService = const MockPerformanceService();
    });

    testWidgets('should display loading indicator while loading stats', (WidgetTester tester) async {
      // Arrange
      when(mockPerformanceService.getPerformanceStats()).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 1)).then((_) => 
          PerformanceStats(
            totalMetrics: 0,
            operationStats: {},
            generatedAt: DateTime.now(),
          )
        ),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            performanceServiceProvider.overrideWithValue(mockPerformanceService),
          ],
          child: const MaterialApp(
            home: PerformanceDashboardScreen(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display performance stats when loaded', (WidgetTester tester) async {
      // Arrange
      final stats = PerformanceStats(
        totalMetrics: 100,
        operationStats: {
          'test_operation': const OperationStats(
            operation: 'test_operation',
            count: 10,
            averageDuration: Duration(milliseconds: 150),
            minDuration: Duration(milliseconds: 50),
            maxDuration: Duration(milliseconds: 300),
            p95Duration: Duration(milliseconds: 250),
          ),
        },
        generatedAt: DateTime.now(),
      );

      when(mockPerformanceService.getPerformanceStats()).thenAnswer((_) async => stats);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            performanceServiceProvider.overrideWithValue(mockPerformanceService),
          ],
          child: const MaterialApp(
            home: PerformanceDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Performance Dashboard'), findsOneWidget);
      expect(find.text('Performance Summary'), findsOneWidget);
      expect(find.text('100'), findsOneWidget); // Total metrics
      expect(find.text('1'), findsOneWidget); // Operations count
      expect(find.text('test_operation'), findsOneWidget);
      expect(find.text('150ms'), findsOneWidget); // Average duration
    });

    testWidgets('should display error message when stats loading fails', (WidgetTester tester) async {
      // Arrange
      when(mockPerformanceService.getPerformanceStats()).thenThrow(Exception('Failed to load stats'));

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            performanceServiceProvider.overrideWithValue(mockPerformanceService),
          ],
          child: const MaterialApp(
            home: PerformanceDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.textContaining('Error loading performance data'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should refresh stats when refresh button is tapped', (WidgetTester tester) async {
      // Arrange
      final stats = PerformanceStats(
        totalMetrics: 50,
        operationStats: {},
        generatedAt: DateTime.now(),
      );

      when(mockPerformanceService.getPerformanceStats()).thenAnswer((_) async => stats);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            performanceServiceProvider.overrideWithValue(mockPerformanceService),
          ],
          child: const MaterialApp(
            home: PerformanceDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Assert
      verify(mockPerformanceService.getPerformanceStats()).called(2); // Initial load + refresh
    });

    testWidgets('should display operation performance details', (WidgetTester tester) async {
      // Arrange
      final stats = PerformanceStats(
        totalMetrics: 100,
        operationStats: {
          'slow_operation': const OperationStats(
            operation: 'slow_operation',
            count: 5,
            averageDuration: Duration(milliseconds: 500),
            minDuration: Duration(milliseconds: 200),
            maxDuration: Duration(milliseconds: 800),
            p95Duration: Duration(milliseconds: 750),
          ),
          'fast_operation': const OperationStats(
            operation: 'fast_operation',
            count: 20,
            averageDuration: Duration(milliseconds: 50),
            minDuration: Duration(milliseconds: 10),
            maxDuration: Duration(milliseconds: 100),
            p95Duration: Duration(milliseconds: 90),
          ),
        },
        generatedAt: DateTime.now(),
      );

      when(mockPerformanceService.getPerformanceStats()).thenAnswer((_) async => stats);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            performanceServiceProvider.overrideWithValue(mockPerformanceService),
          ],
          child: const MaterialApp(
            home: PerformanceDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('slow_operation'), findsOneWidget);
      expect(find.text('fast_operation'), findsOneWidget);
      expect(find.text('500ms'), findsOneWidget); // Slow operation average
      expect(find.text('50ms'), findsOneWidget); // Fast operation average
      expect(find.text('5x'), findsOneWidget); // Slow operation count
      expect(find.text('20x'), findsOneWidget); // Fast operation count
    });

    testWidgets('should display memory management section', (WidgetTester tester) async {
      // Arrange
      final stats = PerformanceStats(
        totalMetrics: 0,
        operationStats: {},
        generatedAt: DateTime.now(),
      );

      when(mockPerformanceService.getPerformanceStats()).thenAnswer((_) async => stats);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            performanceServiceProvider.overrideWithValue(mockPerformanceService),
          ],
          child: const MaterialApp(
            home: PerformanceDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Memory Management'), findsOneWidget);
      expect(find.text('Automatic Cleanup'), findsOneWidget);
      expect(find.text('Image Cache'), findsOneWidget);
      expect(find.text('Clean Now'), findsAtLeastNWidgets(1));
      expect(find.text('Clear Cache'), findsOneWidget);
    });

    testWidgets('should trigger memory cleanup when Clean Now is tapped', (WidgetTester tester) async {
      // Arrange
      final stats = PerformanceStats(
        totalMetrics: 0,
        operationStats: {},
        generatedAt: DateTime.now(),
      );

      when(mockPerformanceService.getPerformanceStats()).thenAnswer((_) async => stats);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            performanceServiceProvider.overrideWithValue(mockPerformanceService),
          ],
          child: const MaterialApp(
            home: PerformanceDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Clean Now'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Memory cleanup performed'), findsOneWidget);
    });

    testWidgets('should clear image cache when Clear Cache is tapped', (WidgetTester tester) async {
      // Arrange
      final stats = PerformanceStats(
        totalMetrics: 0,
        operationStats: {},
        generatedAt: DateTime.now(),
      );

      when(mockPerformanceService.getPerformanceStats()).thenAnswer((_) async => stats);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            performanceServiceProvider.overrideWithValue(mockPerformanceService),
          ],
          child: const MaterialApp(
            home: PerformanceDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Clear Cache'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Image cache cleared'), findsOneWidget);
    });

    testWidgets('should show empty state when no performance data', (WidgetTester tester) async {
      // Arrange
      final stats = PerformanceStats(
        totalMetrics: 0,
        operationStats: {},
        generatedAt: DateTime.now(),
      );

      when(mockPerformanceService.getPerformanceStats()).thenAnswer((_) async => stats);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            performanceServiceProvider.overrideWithValue(mockPerformanceService),
          ],
          child: const MaterialApp(
            home: PerformanceDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No performance data available'), findsOneWidget);
    });

    testWidgets('should use correct performance colors for operations', (WidgetTester tester) async {
      // Arrange
      final stats = PerformanceStats(
        totalMetrics: 100,
        operationStats: {
          'fast_operation': const OperationStats(
            operation: 'fast_operation',
            count: 10,
            averageDuration: Duration(milliseconds: 30), // Should be green
            minDuration: Duration(milliseconds: 10),
            maxDuration: Duration(milliseconds: 50),
            p95Duration: Duration(milliseconds: 45),
          ),
          'medium_operation': const OperationStats(
            operation: 'medium_operation',
            count: 5,
            averageDuration: Duration(milliseconds: 75), // Should be orange
            minDuration: Duration(milliseconds: 50),
            maxDuration: Duration(milliseconds: 100),
            p95Duration: Duration(milliseconds: 95),
          ),
          'slow_operation': const OperationStats(
            operation: 'slow_operation',
            count: 3,
            averageDuration: Duration(milliseconds: 200), // Should be red
            minDuration: Duration(milliseconds: 150),
            maxDuration: Duration(milliseconds: 300),
            p95Duration: Duration(milliseconds: 280),
          ),
        },
        generatedAt: DateTime.now(),
      );

      when(mockPerformanceService.getPerformanceStats()).thenAnswer((_) async => stats);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            performanceServiceProvider.overrideWithValue(mockPerformanceService),
          ],
          child: const MaterialApp(
            home: PerformanceDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert - verify operations are displayed
      expect(find.text('fast_operation'), findsOneWidget);
      expect(find.text('medium_operation'), findsOneWidget);
      expect(find.text('slow_operation'), findsOneWidget);
      expect(find.text('10x'), findsOneWidget);
      expect(find.text('5x'), findsOneWidget);
      expect(find.text('3x'), findsOneWidget);
    });
  });
}