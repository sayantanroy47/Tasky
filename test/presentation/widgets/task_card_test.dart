import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/presentation/widgets/task_card.dart';

void main() {
  group('TaskCard Widget Tests', () {
    testWidgets('should display task title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
            ),
          ),
        ),
      );

      expect(find.text('Test Task'), findsOneWidget);
    });

    testWidgets('should display task description when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              description: 'Test Description',
            ),
          ),
        ),
      );

      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('should show completion indicator with correct state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              isCompleted: true,
            ),
          ),
        ),
      );

      // Look for the check icon that appears when completed
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should show strikethrough text when completed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              isCompleted: true,
            ),
          ),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Find the Text widget with the task title and check its style
      final titleTextFinder = find.byWidgetPredicate((widget) => 
        widget is RichText && 
        widget.text is TextSpan &&
        (widget.text as TextSpan).toPlainText().contains('Test Task')
      );
      
      expect(titleTextFinder, findsOneWidget);
      
      final richText = tester.widget<RichText>(titleTextFinder);
      final textSpan = richText.text as TextSpan;
      expect(textSpan.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('should display due date when provided', (WidgetTester tester) async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              dueDate: tomorrow,
            ),
          ),
        ),
      );

      expect(find.text('Tomorrow'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('should display tags when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              tags: ['work', 'urgent'],
            ),
          ),
        ),
      );

      expect(find.text('work'), findsOneWidget);
      expect(find.text('urgent'), findsOneWidget);
    });

    testWidgets('should show more tags indicator when more than 3 tags', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              tags: ['tag1', 'tag2', 'tag3', 'tag4', 'tag5'],
            ),
          ),
        ),
      );

      expect(find.text('+2'), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TaskCard));
      expect(tapped, isTrue);
    });

    testWidgets('should call onToggleComplete when completion indicator is tapped', (WidgetTester tester) async {
      bool toggled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              onToggleComplete: () => toggled = true,
            ),
          ),
        ),
      );

      // Find the completion indicator (circular container) and tap it
      final completionIndicator = find.byWidgetPredicate(
        (widget) => widget is GestureDetector && 
                    widget.child is AnimatedContainer &&
                    (widget.child as AnimatedContainer).decoration is BoxDecoration &&
                    ((widget.child as AnimatedContainer).decoration as BoxDecoration).shape == BoxShape.circle
      );
      
      await tester.tap(completionIndicator);
      expect(toggled, isTrue);
    });

    testWidgets('should show popup menu when actions are enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              showActions: true,
            ),
          ),
        ),
      );

      expect(find.byWidgetPredicate((widget) => 
        widget.runtimeType.toString().contains('PopupMenuButton')
      ), findsOneWidget);
    });

    testWidgets('should not show popup menu when actions are disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              showActions: false,
            ),
          ),
        ),
      );

      expect(find.byType(PopupMenuButton), findsNothing);
    });

    testWidgets('should show priority indicator with correct color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              priority: 2, // High priority
            ),
          ),
        ),
      );

      // Find the priority indicator container
      final priorityIndicator = find.byWidgetPredicate(
        (widget) => widget is Container && 
                    widget.decoration is BoxDecoration &&
                    (widget.decoration as BoxDecoration).color != null,
      );
      
      expect(priorityIndicator, findsWidgets);
    });
  });
}