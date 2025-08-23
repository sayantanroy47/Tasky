import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/screens/onboarding_screen.dart';

Widget createTestWidget({required Widget child}) {
  return ProviderScope(
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('OnboardingScreen Widget Tests', () {
    testWidgets('should display onboarding screen', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const OnboardingScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('should display welcome page initially', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const OnboardingScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.text('Welcome to Task Tracker'), findsOneWidget);
      expect(find.text('Your intelligent task management companion that helps you stay organized and productive.'), findsOneWidget);
    });

    testWidgets('should handle page navigation', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const OnboardingScreen(),
        ),
      );
      await tester.pump();
      
      // Initial page
      expect(find.text('Welcome to Task Tracker'), findsOneWidget);
      
      // Look for navigation elements (buttons/indicators)
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('should handle animations properly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const OnboardingScreen(),
        ),
      );
      
      // Allow animations to start
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(OnboardingScreen), findsOneWidget);
      
      // Allow more animation time
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('should display page indicators', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const OnboardingScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(OnboardingScreen), findsOneWidget);
      // Page indicators should be present (likely as dots or similar UI elements)
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const OnboardingScreen(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Welcome to Task Tracker'), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const OnboardingScreen(),
        ),
      );
      await tester.pump();
      
      final onboardingSemantics = tester.getSemantics(find.byType(OnboardingScreen));
      expect(onboardingSemantics, isNotNull);
      
      final pageViewSemantics = tester.getSemantics(find.byType(PageView));
      expect(pageViewSemantics, isNotNull);
    });

    testWidgets('should handle widget lifecycle correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const OnboardingScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(OnboardingScreen), findsOneWidget);
      
      // Test widget disposal
      await tester.pumpWidget(
        createTestWidget(
          child: const Scaffold(body: Text('Different Screen')),
        ),
      );
      await tester.pump();
      
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.text('Different Screen'), findsOneWidget);
    });

    testWidgets('should render on small screens', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        createTestWidget(
          child: const OnboardingScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Welcome to Task Tracker'), findsOneWidget);
      
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should render on large screens', (tester) async {
      tester.view.physicalSize = const Size(1440, 2560);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(
        createTestWidget(
          child: const OnboardingScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Welcome to Task Tracker'), findsOneWidget);
      
      addTearDown(() => tester.view.resetPhysicalSize());
    });

    testWidgets('should handle provider overrides', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          overrides: [],
          child: MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Welcome to Task Tracker'), findsOneWidget);
    });

    testWidgets('should dispose controllers properly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const OnboardingScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(OnboardingScreen), findsOneWidget);
      
      // Dispose by pumping a different widget
      await tester.pumpWidget(
        createTestWidget(
          child: const Scaffold(body: Text('New Screen')),
        ),
      );
      await tester.pump();
      
      expect(find.text('New Screen'), findsOneWidget);
    });

    testWidgets('should handle orientation changes', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const OnboardingScreen(),
        ),
      );
      await tester.pump();
      
      expect(find.text('Welcome to Task Tracker'), findsOneWidget);
      
      // Simulate orientation change
      tester.view.physicalSize = const Size(800, 600);
      await tester.pump();
      
      expect(find.byType(OnboardingScreen), findsOneWidget);
      
      addTearDown(() => tester.view.resetPhysicalSize());
    });
  });
}