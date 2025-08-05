import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/presentation/widgets/task_card.dart';

void main() {
  group('TaskCard Gesture Tests', () {
    testWidgets('should trigger onToggleComplete when swiped right', (WidgetTester tester) async {
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

      // Perform a right swipe gesture on the Dismissible widget
      await tester.drag(find.byType(Dismissible), const Offset(400.0, 0.0));
      await tester.pumpAndSettle();
      
      expect(toggled, isTrue);
    });

    testWidgets('should show delete confirmation when swiped left', (WidgetTester tester) async {
      bool deleted = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      // Perform a left swipe gesture on the Dismissible widget
      await tester.drag(find.byType(Dismissible), const Offset(-400.0, 0.0));
      await tester.pumpAndSettle();
      
      // Should show delete confirmation dialog
      expect(find.text('Delete Task'), findsOneWidget);
      expect(find.text('Are you sure you want to delete "Test Task"?'), findsOneWidget);
      
      // Tap confirm to trigger onDelete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      
      expect(deleted, isTrue);
    });

    testWidgets('should not trigger actions for small swipes', (WidgetTester tester) async {
      bool toggled = false;
      bool deleted = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              onToggleComplete: () => toggled = true,
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      // Perform small swipe gestures that shouldn't trigger actions
      await tester.drag(find.byType(TaskCard), const Offset(30.0, 0.0));
      await tester.pumpAndSettle();
      
      await tester.drag(find.byType(TaskCard), const Offset(-30.0, 0.0));
      await tester.pumpAndSettle();
      
      expect(toggled, isFalse);
      expect(deleted, isFalse);
    });

    testWidgets('should show visual feedback during swipe', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              onToggleComplete: () {},
            ),
          ),
        ),
      );

      // Start a drag gesture on the main card area
      final cardFinder = find.byType(TaskCard);
      expect(cardFinder, findsOneWidget);
      
      final gesture = await tester.startGesture(tester.getCenter(cardFinder));
      await tester.pump();
      
      // Move right to trigger visual feedback
      await gesture.moveBy(const Offset(50.0, 0.0));
      await tester.pump();
      
      // The card should show visual feedback (check icon for incomplete task)
      expect(find.byIcon(Icons.check), findsOneWidget);
      
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('should animate completion state changes', (WidgetTester tester) async {
      bool isCompleted = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    TaskCard(
                      title: 'Test Task',
                      isCompleted: isCompleted,
                      onToggleComplete: () {
                        setState(() {
                          isCompleted = !isCompleted;
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isCompleted = !isCompleted;
                        });
                      },
                      child: const Text('Toggle'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Initially not completed - checkbox should be unchecked
      final initialCheckbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(initialCheckbox.value, isFalse);
      
      // Toggle completion
      await tester.tap(find.text('Toggle'));
      await tester.pump(); // Start animation
      
      // Should find the checkbox checked after animation completes
      await tester.pumpAndSettle(); // Complete animation
      final completedCheckbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(completedCheckbox.value, isTrue);
    });
  });
}