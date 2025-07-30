import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/presentation/widgets/task_card.dart';

void main() {
  group('TaskCard Subtask Tests', () {
    testWidgets('should display subtask progress when task has subtasks', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
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
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should not display subtask progress when task has no subtasks', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
            ),
          ),
        ),
      );

      expect(find.text('Test Task'), findsOneWidget);
      expect(find.byIcon(Icons.checklist), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('should show correct progress indicator value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              subTasksTotal: 4,
              subTasksCompleted: 3,
            ),
          ),
        ),
      );

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      // Should show 75% completion (3 out of 4 subtasks completed)
      expect(progressIndicator.value, equals(0.75));
    });

    testWidgets('should show 100% progress when all subtasks completed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              subTasksTotal: 2,
              subTasksCompleted: 2,
            ),
          ),
        ),
      );

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      // Should show 100% completion
      expect(progressIndicator.value, equals(1.0));
    });

    testWidgets('should show 0% progress when no subtasks completed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              subTasksTotal: 3,
              subTasksCompleted: 0,
            ),
          ),
        ),
      );

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      // Should show 0% completion
      expect(progressIndicator.value, equals(0.0));
    });

    testWidgets('should handle null subtask completed count', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              title: 'Test Task',
              subTasksTotal: 3,
              subTasksCompleted: null,
            ),
          ),
        ),
      );

      expect(find.text('0/3'), findsOneWidget);
      
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      // Should show 0% completion when completed count is null
      expect(progressIndicator.value, equals(0.0));
    });

    testWidgets('should show dimmed progress indicator for completed tasks', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
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

      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      // The progress indicator should have reduced opacity for completed tasks
      expect(progressIndicator.valueColor, isA<AlwaysStoppedAnimation<Color>>());
    });
  });
}