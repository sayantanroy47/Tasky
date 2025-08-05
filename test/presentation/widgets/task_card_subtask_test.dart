import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/presentation/widgets/task_card.dart';

void main() {
  group('TaskCard Subtask Tests', () {
    testWidgets('should display subtask progress when task has subtasks', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              subTasksTotal: 3,
              subTasksCompleted: 2,
            ),
          ),
        ),
      );

      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('2/3'), findsOneWidget);
      expect(find.byIcon(Icons.checklist), findsOneWidget);
    });

    testWidgets('should not display subtask progress when task has no subtasks', (WidgetTester tester) async {
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
      expect(find.byIcon(Icons.checklist), findsNothing);
    });

    testWidgets('should show correct progress text value', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              subTasksTotal: 4,
              subTasksCompleted: 3,
            ),
          ),
        ),
      );

      // Should show 3 out of 4 subtasks completed
      expect(find.text('3/4'), findsOneWidget);
      expect(find.byIcon(Icons.checklist), findsOneWidget);
    });

    testWidgets('should show all subtasks completed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              subTasksTotal: 2,
              subTasksCompleted: 2,
            ),
          ),
        ),
      );

      // Should show all subtasks completed
      expect(find.text('2/2'), findsOneWidget);
      expect(find.byIcon(Icons.checklist), findsOneWidget);
    });

    testWidgets('should show zero progress when no subtasks completed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              subTasksTotal: 3,
              subTasksCompleted: 0,
            ),
          ),
        ),
      );

      // Should show 0 out of 3 subtasks completed
      expect(find.text('0/3'), findsOneWidget);
      expect(find.byIcon(Icons.checklist), findsOneWidget);
    });

    testWidgets('should handle null subtask completed count', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              subTasksTotal: 3,
              subTasksCompleted: null,
            ),
          ),
        ),
      );

      // Should show 0 when completed count is null
      expect(find.text('0/3'), findsOneWidget);
      expect(find.byIcon(Icons.checklist), findsOneWidget);
    });

    testWidgets('should show subtask progress for completed tasks', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              isCompleted: true,
              subTasksTotal: 2,
              subTasksCompleted: 2,
            ),
          ),
        ),
      );

      // Should still show subtask progress even when task is completed
      expect(find.text('2/2'), findsOneWidget);
      expect(find.byIcon(Icons.checklist), findsOneWidget);
    });
  });
}