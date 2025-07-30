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

      // Perform a right swipe gesture
      await tester.drag(find.byType(TaskCard), const Offset(200.0, 0.0));
      await tester.pumpAndSettle();
      
      expect(toggled, isTrue);
    });

    testWidgets('should trigger onDelete when swiped left', (WidgetTester tester) async {
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

      // Perform a left swipe gesture
      await tester.drag(find.byType(TaskCard), const Offset(-200.0, 0.0));
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

      // Start a drag gesture
      final gesture = await tester.startGesture(tester.getCenter(find.byType(TaskCard)));
      await gesture.moveBy(const Offset(50.0, 0.0));
      await tester.pump();
      
      // The card should show visual feedback (background indicators)
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

      // Initially not completed
      expect(find.byIcon(Icons.check), findsNothing);
      
      // Toggle completion
      await tester.tap(find.text('Toggle'));
      await tester.pump(); // Start animation
      
      // Should find the check icon after animation starts
      await tester.pumpAndSettle(); // Complete animation
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}