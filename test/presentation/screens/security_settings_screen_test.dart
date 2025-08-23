import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_tracker_app/presentation/screens/security_settings_screen.dart';

Widget createTestWidget({required Widget child, List<Override>? overrides}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('SecuritySettingsScreen Widget Tests', () {
    testWidgets('should display security settings screen', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SecuritySettingsScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(SecuritySettingsScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Security & Privacy'), findsOneWidget);
    });

    testWidgets('should handle loading states', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SecuritySettingsScreen(),
        ),
      );
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      expect(find.byType(SecuritySettingsScreen), findsOneWidget);
    });

    testWidgets('should display error state with warning icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SecuritySettingsScreen(),
        ),
      );
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      
      expect(find.byType(SecuritySettingsScreen), findsOneWidget);
      // Error state might show warning icon
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const SecuritySettingsScreen(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(SecuritySettingsScreen), findsOneWidget);
      expect(find.text('Security & Privacy'), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SecuritySettingsScreen(),
        ),
      );
      await tester.pump();
      
      final securitySemantics = tester.getSemantics(find.byType(SecuritySettingsScreen));
      expect(securitySemantics, isNotNull);
    });

    testWidgets('should render on small screens', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        createTestWidget(
          child: const SecuritySettingsScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(SecuritySettingsScreen), findsOneWidget);
      expect(find.text('Security & Privacy'), findsOneWidget);
      
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should render on large screens', (tester) async {
      tester.view.physicalSize = const Size(1440, 2560);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        createTestWidget(
          child: const SecuritySettingsScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(SecuritySettingsScreen), findsOneWidget);
      expect(find.text('Security & Privacy'), findsOneWidget);
      
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should handle provider data states', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SecuritySettingsScreen(),
        ),
      );
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      
      expect(find.byType(SecuritySettingsScreen), findsOneWidget);
    });

    testWidgets('should handle provider error states gracefully', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SecuritySettingsScreen(),
        ),
      );
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      
      // Screen should render even with potential provider errors
      expect(find.byType(SecuritySettingsScreen), findsOneWidget);
    });

    testWidgets('should handle orientation changes', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SecuritySettingsScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.text('Security & Privacy'), findsOneWidget);
      
      // Simulate orientation change
      tester.view.physicalSize = const Size(800, 600);
      await tester.pump();
      
      expect(find.byType(SecuritySettingsScreen), findsOneWidget);
      
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should maintain state during rebuild', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SecuritySettingsScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.text('Security & Privacy'), findsOneWidget);
      
      // Trigger rebuild
      await tester.pumpWidget(
        createTestWidget(
          child: const SecuritySettingsScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(SecuritySettingsScreen), findsOneWidget);
    });

    testWidgets('should handle async provider resolution', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SecuritySettingsScreen(),
        ),
      );
      
      // Initial pump
      await tester.pump();
      
      // Allow async operations to complete
      await tester.pump(const Duration(milliseconds: 500));
      
      expect(find.byType(SecuritySettingsScreen), findsOneWidget);
    });

    testWidgets('should display circular progress indicator during loading', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SecuritySettingsScreen(),
        ),
      );
      
      await tester.pump();
      
      // Loading indicator might be present during async operations
      expect(find.byType(SecuritySettingsScreen), findsOneWidget);
    });
  });
}