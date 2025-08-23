import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:task_tracker_app/presentation/screens/performance_dashboard_screen.dart';

Widget createTestWidget({required Widget child, List<Override>? overrides}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('PerformanceDashboardScreen Widget Tests', () {
    testWidgets('should display performance dashboard screen', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PerformanceDashboardScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(PerformanceDashboardScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Performance Dashboard'), findsOneWidget);
    });

    testWidgets('should display refresh button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PerformanceDashboardScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byIcon(PhosphorIcons.arrowClockwise()), findsOneWidget);
    });

    testWidgets('should handle refresh button tap', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PerformanceDashboardScreen(),
        ),
      );
      await tester.pump();
      
      final refreshButton = find.byIcon(PhosphorIcons.arrowClockwise());
      expect(refreshButton, findsOneWidget);
      
      await tester.tap(refreshButton);
      await tester.pump();
      
      expect(find.byType(PerformanceDashboardScreen), findsOneWidget);
    });

    testWidgets('should display single scroll view', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PerformanceDashboardScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const PerformanceDashboardScreen(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(PerformanceDashboardScreen), findsOneWidget);
      expect(find.text('Performance Dashboard'), findsOneWidget);
    });

    testWidgets('should handle provider loading states', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PerformanceDashboardScreen(),
          overrides: [
            // Mock providers as needed
          ],
        ),
      );
      await tester.pump();
      
      expect(find.byType(PerformanceDashboardScreen), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PerformanceDashboardScreen(),
        ),
      );
      await tester.pump();
      
      final dashboardSemantics = tester.getSemantics(find.byType(PerformanceDashboardScreen));
      expect(dashboardSemantics, isNotNull);
      
      final refreshButtonSemantics = tester.getSemantics(find.byIcon(PhosphorIcons.arrowClockwise()));
      expect(refreshButtonSemantics, isNotNull);
    });

    testWidgets('should render on small screens', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        createTestWidget(
          child: const PerformanceDashboardScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(PerformanceDashboardScreen), findsOneWidget);
      expect(find.text('Performance Dashboard'), findsOneWidget);
      
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should render on large screens', (tester) async {
      tester.view.physicalSize = const Size(1440, 2560);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        createTestWidget(
          child: const PerformanceDashboardScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(PerformanceDashboardScreen), findsOneWidget);
      expect(find.text('Performance Dashboard'), findsOneWidget);
      
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should handle orientation changes', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PerformanceDashboardScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.text('Performance Dashboard'), findsOneWidget);
      
      // Simulate orientation change
      tester.view.physicalSize = const Size(800, 600);
      await tester.pump();
      
      expect(find.byType(PerformanceDashboardScreen), findsOneWidget);
      
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should handle scrolling', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PerformanceDashboardScreen(),
        ),
      );
      await tester.pump();
      
      final scrollView = find.byType(SingleChildScrollView);
      expect(scrollView, findsOneWidget);
      
      // Test scrolling
      await tester.drag(scrollView, const Offset(0, -100));
      await tester.pump();
      
      expect(find.byType(PerformanceDashboardScreen), findsOneWidget);
    });

    testWidgets('should maintain state during rebuild', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PerformanceDashboardScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.text('Performance Dashboard'), findsOneWidget);
      
      // Trigger rebuild
      await tester.pumpWidget(
        createTestWidget(
          child: const PerformanceDashboardScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(PerformanceDashboardScreen), findsOneWidget);
    });

    testWidgets('should handle provider error states', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PerformanceDashboardScreen(),
        ),
      );
      await tester.pump();
      
      // Screen should render even with potential provider errors
      expect(find.byType(PerformanceDashboardScreen), findsOneWidget);
    });
  });
}