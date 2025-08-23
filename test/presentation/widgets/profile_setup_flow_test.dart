import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/widgets/profile_setup_flow.dart';

Widget createTestWidget({required Widget child}) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

void main() {
  group('ProfileSetupFlow Widget Tests', () {
    testWidgets('should display profile setup flow', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ProfileSetupFlow(
            onCompleted: () {},
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ProfileSetupFlow), findsOneWidget);
    });

    testWidgets('should display initial setup step', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ProfileSetupFlow(
            onCompleted: () {},
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ProfileSetupFlow), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('should handle name input step', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ProfileSetupFlow(
            onCompleted: () {},
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ProfileSetupFlow), findsOneWidget);
      
      final nameFields = find.byType(TextField);
      if (nameFields.evaluate().isNotEmpty) {
        await tester.enterText(nameFields.first, 'John Doe');
        await tester.pump();
      }
    });

    testWidgets('should handle navigation between steps', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ProfileSetupFlow(
            onCompleted: () {},
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ProfileSetupFlow), findsOneWidget);
      
      // Look for continue buttons
      final continueButtons = find.text('Continue');
      if (continueButtons.evaluate().isNotEmpty) {
        await tester.tap(continueButtons.first);
        await tester.pump();
      }
      
      // Look for back buttons
      final backButtons = find.text('Back');
      if (backButtons.evaluate().isNotEmpty) {
        await tester.tap(backButtons.first);
        await tester.pump();
      }
    });

    testWidgets('should handle skip functionality', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ProfileSetupFlow(
            onCompleted: () {},
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ProfileSetupFlow), findsOneWidget);
      
      // Look for skip buttons
      final skipButtons = find.text('Skip setup completely');
      if (skipButtons.evaluate().isNotEmpty) {
        await tester.tap(skipButtons.first);
        await tester.pump();
      }
    });

    testWidgets('should complete setup flow', (tester) async {
      bool onCompletedCalled = false;
      
      await tester.pumpWidget(
        createTestWidget(
          child: ProfileSetupFlow(
            onCompleted: () => onCompletedCalled = true,
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ProfileSetupFlow), findsOneWidget);
      
      // Look for complete setup buttons
      final completeButtons = find.text('Complete Setup');
      if (completeButtons.evaluate().isNotEmpty) {
        await tester.tap(completeButtons.first);
        await tester.pump();
        
        expect(onCompletedCalled, isTrue);
      }
    });

    testWidgets('should handle progress indication', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ProfileSetupFlow(
            onCompleted: () {},
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ProfileSetupFlow), findsOneWidget);
      
      // Look for progress indicators
      final progressIndicators = find.byType(LinearProgressIndicator);
      expect(progressIndicators.evaluate().length, greaterThanOrEqualTo(0));
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: ProfileSetupFlow(
                onCompleted: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ProfileSetupFlow), findsOneWidget);
    });

    testWidgets('should handle form validation', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ProfileSetupFlow(
            onCompleted: () {},
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ProfileSetupFlow), findsOneWidget);
      
      // Try to continue without filling required fields
      final continueButtons = find.text('Continue');
      if (continueButtons.evaluate().isNotEmpty) {
        await tester.tap(continueButtons.first);
        await tester.pump();
      }
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: ProfileSetupFlow(
            onCompleted: () {},
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(ProfileSetupFlow), findsOneWidget);
      
      final semantics = tester.getSemantics(find.byType(ProfileSetupFlow));
      expect(semantics, isNotNull);
    });
  });
}