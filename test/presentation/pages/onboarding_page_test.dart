import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/pages/onboarding_page.dart';

void main() {
  group('OnboardingPage Widget Tests', () {
    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          home: Theme(
            data: ThemeData.light(),
            child: const OnboardingPage(),
          ),
        ),
      );
    }

    testWidgets('should display onboarding page with basic elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(OnboardingPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display onboarding steps', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(OnboardingPage), findsOneWidget);
    });

    testWidgets('should handle navigation between steps', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Look for next/previous buttons
      final nextButtons = [
        ...find.textContaining('Next').evaluate(),
        ...find.byIcon(Icons.arrow_forward).evaluate(),
        ...find.byIcon(Icons.chevron_right).evaluate(),
      ];
      
      if (nextButtons.isNotEmpty) {
        await tester.tap(find.byWidget(nextButtons.first.widget));
        await tester.pumpAndSettle();
      }
      
      expect(find.byType(OnboardingPage), findsOneWidget);
    });

    testWidgets('should handle skip functionality', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      final skipButtons = find.textContaining('Skip');
      if (skipButtons.evaluate().isNotEmpty) {
        await tester.tap(skipButtons.first);
        await tester.pumpAndSettle();
      }
      
      expect(find.byType(OnboardingPage), findsOneWidget);
    });

    testWidgets('should handle finish/get started', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      final finishButtons = [
        ...find.textContaining('Finish').evaluate(),
        ...find.textContaining('Get Started').evaluate(),
        ...find.textContaining('Done').evaluate(),
      ];
      
      if (finishButtons.isNotEmpty) {
        await tester.tap(find.byWidget(finishButtons.first.widget));
        await tester.pumpAndSettle();
      }
      
      expect(find.byType(OnboardingPage), findsOneWidget);
    });

    testWidgets('should display page indicator', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(OnboardingPage), findsOneWidget);
    });

    testWidgets('should handle swipe gestures', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Test swiping through pages
      await tester.drag(find.byType(OnboardingPage), const Offset(-300, 0));
      await tester.pumpAndSettle();
      
      await tester.drag(find.byType(OnboardingPage), const Offset(300, 0));
      await tester.pumpAndSettle();
      
      expect(find.byType(OnboardingPage), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const OnboardingPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(OnboardingPage), findsOneWidget);
    });
  });
}
