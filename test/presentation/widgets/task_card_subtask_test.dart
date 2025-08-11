import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_tracker_app/presentation/widgets/task_card_m3.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/domain/entities/subtask.dart';

void main() {
  group('TaskCardM3 Subtask Tests', () {
    late DateTime testDate;
    
    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
    });
    testWidgets('should display task with subtasks', (WidgetTester tester) async {
      final completedSubTask1 = SubTask(
        id: 'sub-1',
        taskId: 'task-1',
        title: 'Subtask 1',
        createdAt: testDate,
        isCompleted: true,
        completedAt: testDate,
      );
      final completedSubTask2 = SubTask(
        id: 'sub-2', 
        taskId: 'task-1',
        title: 'Subtask 2',
        createdAt: testDate,
        isCompleted: true,
        completedAt: testDate,
      );
      final pendingSubTask = SubTask(
        id: 'sub-3',
        taskId: 'task-1', 
        title: 'Subtask 3',
        createdAt: testDate,
        isCompleted: false,
      );
      
      final taskWithSubTasks = TaskModel(
        id: 'task-1',
        title: 'Test Task',
        createdAt: testDate,
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        tags: const [],
        subTasks: [completedSubTask1, completedSubTask2, pendingSubTask],
      );
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TaskCardM3(task: taskWithSubTasks),
            ),
          ),
        ),
      );

      expect(find.text('Test Task'), findsOneWidget);
      expect(find.byType(TaskCardM3), findsOneWidget);
    });

    testWidgets('should display task without subtasks', (WidgetTester tester) async {
      final taskWithoutSubTasks = TaskModel(
        id: 'task-2',
        title: 'Test Task',
        createdAt: testDate,
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        tags: const [],
        subTasks: const [],
      );
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TaskCardM3(task: taskWithoutSubTasks),
            ),
          ),
        ),
      );

      expect(find.text('Test Task'), findsOneWidget);
      expect(find.byType(TaskCardM3), findsOneWidget);
    });

    testWidgets('should display task with partial subtask completion', (WidgetTester tester) async {
      final completedSubTasks = List<SubTask>.generate(3, (index) => SubTask(
        id: 'sub-${index + 1}',
        taskId: 'task-3',
        title: 'Subtask ${index + 1}',
        createdAt: testDate,
        isCompleted: true,
        completedAt: testDate,
      ));
      
      final pendingSubTask = SubTask(
        id: 'sub-4',
        taskId: 'task-3',
        title: 'Subtask 4',
        createdAt: testDate,
        isCompleted: false,
      );
      
      final taskWithMixedSubTasks = TaskModel(
        id: 'task-3',
        title: 'Test Task',
        createdAt: testDate,
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        tags: const [],
        subTasks: [...completedSubTasks, pendingSubTask],
      );
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TaskCardM3(task: taskWithMixedSubTasks),
            ),
          ),
        ),
      );

      expect(find.text('Test Task'), findsOneWidget);
      expect(find.byType(TaskCardM3), findsOneWidget);
      // Check that task has mixed subtask completion (3 out of 4)
      expect(taskWithMixedSubTasks.subTaskCompletionPercentage, 0.75);
    });

    testWidgets('should show all subtasks completed', (WidgetTester tester) async {
      final allCompletedSubTasks = List<SubTask>.generate(2, (index) => SubTask(
        id: 'sub-${index + 1}',
        taskId: 'task-4',
        title: 'Subtask ${index + 1}',
        createdAt: testDate,
        isCompleted: true,
        completedAt: testDate,
      ));
      
      final taskWithAllCompletedSubTasks = TaskModel(
        id: 'task-4',
        title: 'Test Task',
        createdAt: testDate,
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        tags: const [],
        subTasks: allCompletedSubTasks,
      );
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TaskCardM3(task: taskWithAllCompletedSubTasks),
            ),
          ),
        ),
      );

      expect(find.text('Test Task'), findsOneWidget);
      expect(find.byType(TaskCardM3), findsOneWidget);
      // Check that all subtasks are completed
      expect(taskWithAllCompletedSubTasks.allSubTasksCompleted, true);
    });

    testWidgets('should show zero progress when no subtasks completed', (WidgetTester tester) async {
      final allPendingSubTasks = List<SubTask>.generate(3, (index) => SubTask(
        id: 'sub-${index + 1}',
        taskId: 'task-5',
        title: 'Subtask ${index + 1}',
        createdAt: testDate,
        isCompleted: false,
      ));
      
      final taskWithNoneCompleted = TaskModel(
        id: 'task-5',
        title: 'Test Task',
        createdAt: testDate,
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        tags: const [],
        subTasks: allPendingSubTasks,
      );
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TaskCardM3(task: taskWithNoneCompleted),
            ),
          ),
        ),
      );

      expect(find.text('Test Task'), findsOneWidget);
      expect(find.byType(TaskCardM3), findsOneWidget);
      // Check that no subtasks are completed
      expect(taskWithNoneCompleted.subTaskCompletionPercentage, 0.0);
    });

    testWidgets('should handle empty subtasks list', (WidgetTester tester) async {
      final taskWithEmptySubTasks = TaskModel(
        id: 'task-6',
        title: 'Test Task',
        createdAt: testDate,
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        tags: const [],
        subTasks: const [],
      );
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TaskCardM3(task: taskWithEmptySubTasks),
            ),
          ),
        ),
      );

      expect(find.text('Test Task'), findsOneWidget);
      expect(find.byType(TaskCardM3), findsOneWidget);
      // Check that completion percentage is 0 for no subtasks
      expect(taskWithEmptySubTasks.subTaskCompletionPercentage, 0.0);
      expect(taskWithEmptySubTasks.hasSubTasks, false);
    });

    testWidgets('should show subtasks for completed tasks', (WidgetTester tester) async {
      final completedSubTasks = List<SubTask>.generate(2, (index) => SubTask(
        id: 'sub-${index + 1}',
        taskId: 'task-7',
        title: 'Subtask ${index + 1}',
        createdAt: testDate,
        isCompleted: true,
        completedAt: testDate,
      ));
      
      final completedTaskWithSubTasks = TaskModel(
        id: 'task-7',
        title: 'Test Task',
        createdAt: testDate,
        priority: TaskPriority.medium,
        status: TaskStatus.completed,
        completedAt: testDate.add(const Duration(hours: 1)),
        tags: const [],
        subTasks: completedSubTasks,
      );
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TaskCardM3(task: completedTaskWithSubTasks),
            ),
          ),
        ),
      );

      expect(find.text('Test Task'), findsOneWidget);
      expect(find.byType(TaskCardM3), findsOneWidget);
      // Check that task and all subtasks are completed
      expect(completedTaskWithSubTasks.status, TaskStatus.completed);
      expect(completedTaskWithSubTasks.allSubTasksCompleted, true);
    });
  });
}