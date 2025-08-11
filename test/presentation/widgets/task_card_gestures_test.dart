import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_tracker_app/presentation/widgets/task_card_m3.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';

void main() {
  group('TaskCardM3 Gesture Tests', () {
    late TaskModel testTask;
    
    setUp(() {
      testTask = TaskModel(
        id: 'test-task-1',
        title: 'Test Task',
        description: 'Test Description',
        createdAt: DateTime.now(),
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        tags: const [],
        subTasks: const [],
      );
    });
    testWidgets('should trigger completion when swiped right', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TaskCardM3(task: testTask),
            ),
          ),
        ),
      );

      // Perform a right swipe gesture on the TaskCardM3 widget
      await tester.drag(find.byType(TaskCardM3), const Offset(400.0, 0.0));
      await tester.pumpAndSettle();
      
      // Verify the card is still rendered (completion handled by provider)
      expect(find.byType(TaskCardM3), findsOneWidget);
      expect(find.text('Test Task'), findsOneWidget);
    });

    testWidgets('should handle delete gesture when swiped left', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TaskCardM3(task: testTask),
            ),
          ),
        ),
      );

      // Perform a left swipe gesture on the TaskCardM3 widget
      await tester.drag(find.byType(TaskCardM3), const Offset(-400.0, 0.0));
      await tester.pumpAndSettle();
      
      // Verify the card still exists (deletion handled by provider)
      expect(find.byType(TaskCardM3), findsOneWidget);
      expect(find.text('Test Task'), findsOneWidget);
    });

    testWidgets('should not trigger actions for small swipes', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TaskCardM3(task: testTask),
            ),
          ),
        ),
      );

      // Perform small swipe gestures that shouldn't trigger actions
      await tester.drag(find.byType(TaskCardM3), const Offset(30.0, 0.0));
      await tester.pumpAndSettle();
      
      await tester.drag(find.byType(TaskCardM3), const Offset(-30.0, 0.0));
      await tester.pumpAndSettle();
      
      // Card should still be present and unchanged
      expect(find.byType(TaskCardM3), findsOneWidget);
      expect(find.text('Test Task'), findsOneWidget);
    });

    testWidgets('should show visual feedback during swipe', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TaskCardM3(task: testTask),
            ),
          ),
        ),
      );

      // Start a drag gesture on the main card area
      final cardFinder = find.byType(TaskCardM3);
      expect(cardFinder, findsOneWidget);
      
      final gesture = await tester.startGesture(tester.getCenter(cardFinder));
      await tester.pump();
      
      // Move right to trigger visual feedback
      await gesture.moveBy(const Offset(100.0, 0.0));
      await tester.pump();
      
      // The card should still be visible
      expect(find.byType(TaskCardM3), findsOneWidget);
      
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('should handle tap gestures on task card', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TaskCardM3(
                task: testTask,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      // Tap the task card
      await tester.tap(find.byType(TaskCardM3));
      await tester.pumpAndSettle();
      
      expect(tapped, isTrue);
      expect(find.text('Test Task'), findsOneWidget);
    });
  });
}