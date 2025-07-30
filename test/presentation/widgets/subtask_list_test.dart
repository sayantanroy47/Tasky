import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/subtask.dart';

import 'package:task_tracker_app/presentation/widgets/subtask_list.dart';

void main() {
  group('SubTaskList Widget Tests', () {
    late TaskModel testTask;
    late TaskModel taskWithSubTasks;

    setUp(() {
      testTask = TaskModel.create(
        title: 'Test Task',
        description: 'Test Description',
      );

      final subTask1 = SubTask.create(
        taskId: testTask.id,
        title: 'Subtask 1',
        sortOrder: 0,
      );

      final subTask2 = SubTask.create(
        taskId: testTask.id,
        title: 'Subtask 2',
        sortOrder: 1,
      ).markCompleted();

      taskWithSubTasks = testTask.copyWith(
        subTasks: [subTask1, subTask2],
      );
    });

    testWidgets('should display empty state when task has no subtasks', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SubTaskList(task: testTask),
            ),
          ),
        ),
      );

      expect(find.text('Subtasks'), findsOneWidget);
      expect(find.text('No subtasks yet'), findsOneWidget);
      expect(find.text('Break down this task into smaller steps'), findsOneWidget);
    });

    testWidgets('should display subtasks when task has subtasks', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SubTaskList(task: taskWithSubTasks),
            ),
          ),
        ),
      );

      expect(find.text('Subtasks'), findsOneWidget);
      expect(find.text('Subtask 1'), findsOneWidget);
      expect(find.text('Subtask 2'), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget); // Progress indicator
    });

    testWidgets('should show progress indicator with correct completion percentage', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SubTaskList(task: taskWithSubTasks),
            ),
          ),
        ),
      );

      // Find the LinearProgressIndicator
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      // Should show 50% completion (1 out of 2 subtasks completed)
      expect(progressIndicator.value, equals(0.5));
    });

    testWidgets('should show add subtask button when editable', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SubTaskList(task: testTask, isEditable: true),
            ),
          ),
        ),
      );

      expect(find.text('Add subtask'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should not show add subtask button when not editable', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SubTaskList(task: testTask, isEditable: false),
            ),
          ),
        ),
      );

      expect(find.text('Add subtask'), findsNothing);
    });

    testWidgets('should show checkboxes for subtasks', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SubTaskList(task: taskWithSubTasks),
            ),
          ),
        ),
      );

      // Should find 2 checkboxes (one for each subtask)
      expect(find.byType(Checkbox), findsNWidgets(2));
    });

    testWidgets('should show completed subtask with strikethrough text', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SubTaskList(task: taskWithSubTasks),
            ),
          ),
        ),
      );

      // Find the text widgets for subtasks
      final subtask1Text = tester.widget<Text>(
        find.text('Subtask 1'),
      );
      final subtask2Text = tester.widget<Text>(
        find.text('Subtask 2'),
      );

      // Subtask 1 should not have strikethrough (not completed)
      expect(subtask1Text.style?.decoration, isNot(equals(TextDecoration.lineThrough)));

      // Subtask 2 should have strikethrough (completed)
      expect(subtask2Text.style?.decoration, equals(TextDecoration.lineThrough));
    });
  });
}