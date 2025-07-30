import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/presentation/widgets/custom_buttons.dart';

void main() {
  group('Custom Buttons Tests', () {
    group('PrimaryButton', () {
      testWidgets('should display text correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PrimaryButton(
                text: 'Test Button',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Test Button'), findsOneWidget);
        expect(find.byType(FilledButton), findsOneWidget);
      });

      testWidgets('should display icon when provided', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PrimaryButton(
                text: 'Test Button',
                icon: Icons.add,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.text('Test Button'), findsOneWidget);
      });

      testWidgets('should show loading indicator when loading', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PrimaryButton(
                text: 'Test Button',
                isLoading: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Test Button'), findsNothing);
      });

      testWidgets('should be disabled when loading', (WidgetTester tester) async {
        // bool pressed = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PrimaryButton(
                text: 'Test Button',
                isLoading: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        // Button should be disabled when loading, so onPressed should be null
        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.onPressed, isNull);
      });

      testWidgets('should expand when isExpanded is true', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PrimaryButton(
                text: 'Test Button',
                isExpanded: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        final sizedBox = find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.width == double.infinity,
        );
        expect(sizedBox, findsOneWidget);
      });
    });

    group('SecondaryButton', () {
      testWidgets('should display as outlined button', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SecondaryButton(
                text: 'Test Button',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Test Button'), findsOneWidget);
        expect(find.byType(OutlinedButton), findsOneWidget);
      });
    });

    group('CustomTextButton', () {
      testWidgets('should display as text button', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomTextButton(
                text: 'Test Button',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Test Button'), findsOneWidget);
        expect(find.byType(TextButton), findsOneWidget);
      });
    });

    group('VoiceActionButton', () {
      testWidgets('should display mic icon by default', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VoiceActionButton(
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.mic_none), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('should show listening state', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VoiceActionButton(
                isListening: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.mic), findsOneWidget);
      });

      testWidgets('should show processing state', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VoiceActionButton(
                isProcessing: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should be disabled when processing or listening', (WidgetTester tester) async {
        bool pressed = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VoiceActionButton(
                isProcessing: true,
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(FloatingActionButton));
        expect(pressed, isFalse);
      });
    });

    group('DestructiveButton', () {
      testWidgets('should display with error colors', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DestructiveButton(
                text: 'Delete',
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Delete'), findsOneWidget);
        expect(find.byType(FilledButton), findsOneWidget);
        
        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.style?.backgroundColor?.resolve({}), isNotNull);
      });
    });
  });
}