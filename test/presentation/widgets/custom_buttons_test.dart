import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_tracker_app/presentation/widgets/custom_buttons.dart';

Widget createTestWidget({required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  group('PrimaryButton Widget Tests', () {
    testWidgets('should display button with text', (tester) async {
      bool onPressedCalled = false;
      
      await tester.pumpWidget(
        createTestWidget(
          child: PrimaryButton(
            text: 'Test Button',
            onPressed: () => onPressedCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
      
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();
      
      expect(onPressedCalled, isTrue);
    });

    testWidgets('should handle disabled state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const PrimaryButton(
            text: 'Disabled Button',
            onPressed: null,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Disabled Button'), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
    });

    testWidgets('should handle loading state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PrimaryButton(
            text: 'Loading Button',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PrimaryButton(
            text: 'Icon Button',
            onPressed: () {},
            icon: Icons.add,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Icon Button'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
    });

    testWidgets('should handle expanded state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: PrimaryButton(
            text: 'Expanded Button',
            onPressed: () {},
            isExpanded: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Expanded Button'), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
    });
  });

  group('SecondaryButton Widget Tests', () {
    testWidgets('should display secondary button', (tester) async {
      bool onPressedCalled = false;
      
      await tester.pumpWidget(
        createTestWidget(
          child: SecondaryButton(
            text: 'Secondary Button',
            onPressed: () => onPressedCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Secondary Button'), findsOneWidget);
      expect(find.byType(SecondaryButton), findsOneWidget);
      
      await tester.tap(find.byType(SecondaryButton));
      await tester.pumpAndSettle();
      
      expect(onPressedCalled, isTrue);
    });

    testWidgets('should handle disabled state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const SecondaryButton(
            text: 'Disabled Secondary',
            onPressed: null,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Disabled Secondary'), findsOneWidget);
      expect(find.byType(SecondaryButton), findsOneWidget);
    });

    testWidgets('should handle loading state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: SecondaryButton(
            text: 'Loading Secondary',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(SecondaryButton), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('CustomTextButton Widget Tests', () {
    testWidgets('should display text button', (tester) async {
      bool onPressedCalled = false;
      
      await tester.pumpWidget(
        createTestWidget(
          child: CustomTextButton(
            text: 'Text Button',
            onPressed: () => onPressedCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Text Button'), findsOneWidget);
      expect(find.byType(CustomTextButton), findsOneWidget);
      
      await tester.tap(find.byType(CustomTextButton));
      await tester.pumpAndSettle();
      
      expect(onPressedCalled, isTrue);
    });

    testWidgets('should handle disabled state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const CustomTextButton(
            text: 'Disabled Text Button',
            onPressed: null,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Disabled Text Button'), findsOneWidget);
      expect(find.byType(CustomTextButton), findsOneWidget);
    });

    testWidgets('should handle loading state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: CustomTextButton(
            text: 'Loading Text Button',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(CustomTextButton), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('VoiceActionButton Widget Tests', () {
    testWidgets('should display voice action button', (tester) async {
      bool onPressedCalled = false;
      
      await tester.pumpWidget(
        createTestWidget(
          child: VoiceActionButton(
            onPressed: () => onPressedCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(VoiceActionButton), findsOneWidget);
      
      await tester.tap(find.byType(VoiceActionButton));
      await tester.pumpAndSettle();
      
      expect(onPressedCalled, isTrue);
    });

    testWidgets('should handle listening state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: VoiceActionButton(
            onPressed: () {},
            isListening: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(VoiceActionButton), findsOneWidget);
    });

    testWidgets('should handle processing state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: VoiceActionButton(
            onPressed: () {},
            isProcessing: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(VoiceActionButton), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle tooltip', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: VoiceActionButton(
            onPressed: () {},
            tooltip: 'Voice Input',
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(VoiceActionButton), findsOneWidget);
    });
  });

  group('DestructiveButton Widget Tests', () {
    testWidgets('should display destructive button', (tester) async {
      bool onPressedCalled = false;
      
      await tester.pumpWidget(
        createTestWidget(
          child: DestructiveButton(
            text: 'Delete',
            onPressed: () => onPressedCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Delete'), findsOneWidget);
      expect(find.byType(DestructiveButton), findsOneWidget);
      
      await tester.tap(find.byType(DestructiveButton));
      await tester.pumpAndSettle();
      
      expect(onPressedCalled, isTrue);
    });

    testWidgets('should handle disabled state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const DestructiveButton(
            text: 'Disabled Delete',
            onPressed: null,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Disabled Delete'), findsOneWidget);
      expect(find.byType(DestructiveButton), findsOneWidget);
    });

    testWidgets('should handle loading state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: DestructiveButton(
            text: 'Deleting...',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(DestructiveButton), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle expanded state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: DestructiveButton(
            text: 'Expanded Delete',
            onPressed: () {},
            isExpanded: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.text('Expanded Delete'), findsOneWidget);
      expect(find.byType(DestructiveButton), findsOneWidget);
    });
  });

  group('Button Accessibility Tests', () {
    testWidgets('all buttons should be accessible', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: Column(
            children: [
              PrimaryButton(
                text: 'Primary',
                onPressed: () {},
              ),
              SecondaryButton(
                text: 'Secondary',
                onPressed: () {},
              ),
              CustomTextButton(
                text: 'Text',
                onPressed: () {},
              ),
              VoiceActionButton(
                onPressed: () {},
              ),
              DestructiveButton(
                text: 'Delete',
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.byType(SecondaryButton), findsOneWidget);
      expect(find.byType(CustomTextButton), findsOneWidget);
      expect(find.byType(VoiceActionButton), findsOneWidget);
      expect(find.byType(DestructiveButton), findsOneWidget);
    });
  });

  group('Button Theme Tests', () {
    testWidgets('should work with dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Column(
              children: [
                PrimaryButton(
                  text: 'Primary Dark',
                  onPressed: () {},
                ),
                SecondaryButton(
                  text: 'Secondary Dark',
                  onPressed: () {},
                ),
                CustomTextButton(
                  text: 'Text Dark',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(PrimaryButton), findsOneWidget);
      expect(find.byType(SecondaryButton), findsOneWidget);
      expect(find.byType(CustomTextButton), findsOneWidget);
    });
  });
}