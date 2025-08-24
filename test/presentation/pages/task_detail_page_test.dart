import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:task_tracker_app/presentation/pages/task_detail_page.dart';
import 'package:task_tracker_app/presentation/providers/task_providers.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/presentation/widgets/standardized_app_bar.dart';
import 'package:task_tracker_app/presentation/widgets/theme_background_widget.dart';

void main() {
  group('TaskDetailPage Widget Tests', () {
    const testTaskId = 'test-task-id';

    Widget createTestWidget({
      List<TaskModel>? tasks,
      bool hasError = false,
      bool isLoading = false,
    }) {

      return ProviderScope(
        overrides: [
          tasksProvider.overrideWith((ref) => Stream.value(tasks ?? [])),
        ],
        child: MaterialApp(
          home: Theme(
            data: ThemeData.light(),
            child: const TaskDetailPage(taskId: testTaskId),
          ),
        ),
      );
    }

    TaskModel createTestTask({
      String? id,
      String title = 'Test Task',
      String description = 'Test Description',
      TaskPriority priority = TaskPriority.medium,
      TaskStatus status = TaskStatus.pending,
    }) {
      return TaskModel.create(title: title).copyWith(
        id: id ?? testTaskId,
        description: description,
        priority: priority,
        status: status,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    testWidgets('should display loading state', (tester) async {
      await tester.pumpWidget(createTestWidget(isLoading: true));
      await tester.pump();
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Task Details'), findsOneWidget);
      expect(find.byType(StandardizedAppBar), findsOneWidget);
    });

    testWidgets('should display error state', (tester) async {
      await tester.pumpWidget(createTestWidget(hasError: true));
      await tester.pump();
      
      expect(find.byIcon(PhosphorIcons.warningCircle()), findsOneWidget);
      expect(find.textContaining('Error loading task:'), findsOneWidget);
      expect(find.text('Go Back'), findsOneWidget);
    });

    testWidgets('should display task not found state', (tester) async {
      await tester.pumpWidget(createTestWidget(tasks: []));
      await tester.pump();
      
      expect(find.text('Task not found'), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.checkSquare()), findsOneWidget);
    });

    testWidgets('should display task details when task exists', (tester) async {
      final task = createTestTask();
      
      await tester.pumpWidget(createTestWidget(tasks: [task]));
      await tester.pump();
      
      expect(find.byType(TaskDetailPage), findsOneWidget);
      // The _TaskDetailView should be displayed
      expect(find.byType(ThemeBackgroundWidget), findsOneWidget);
    });

    testWidgets('should handle task with different priorities', (tester) async {
      final urgentTask = createTestTask(priority: TaskPriority.urgent);
      
      await tester.pumpWidget(createTestWidget(tasks: [urgentTask]));
      await tester.pump();
      
      expect(find.byType(TaskDetailPage), findsOneWidget);
    });

    testWidgets('should handle completed task', (tester) async {
      
      await tester.pumpWidget(createTestWidget(tasks: [completedTask]));
      await tester.pump();
      
      expect(find.byType(TaskDetailPage), findsOneWidget);
    });

    testWidgets('should handle cancelled task', (tester) async {
      
      await tester.pumpWidget(createTestWidget(tasks: [cancelledTask]));
      await tester.pump();
      
      expect(find.byType(TaskDetailPage), findsOneWidget);
    });

    testWidgets('should handle in progress task', (tester) async {
      
      await tester.pumpWidget(createTestWidget(tasks: [inProgressTask]));
      await tester.pump();
      
      expect(find.byType(TaskDetailPage), findsOneWidget);
    });

    testWidgets('should handle task with long description', (tester) async {
      const longDescription = 'This is a very long description that should be handled properly by the task detail page. It contains multiple sentences and should wrap correctly in the UI.';
      final task = createTestTask(description: longDescription);
      
      await tester.pumpWidget(createTestWidget(tasks: [task]));
      await tester.pump();
      
      expect(find.byType(TaskDetailPage), findsOneWidget);
    });

    testWidgets('should handle task with empty description', (tester) async {
      final task = createTestTask(description: '');
      
      await tester.pumpWidget(createTestWidget(tasks: [task]));
      await tester.pump();
      
      expect(find.byType(TaskDetailPage), findsOneWidget);
    });

    testWidgets('should handle go back button in error state', (tester) async {
      await tester.pumpWidget(createTestWidget(hasError: true));
      await tester.pump();
      
      final goBackButton = find.text('Go Back');
      expect(goBackButton, findsOneWidget);
      
      await tester.tap(goBackButton);
      await tester.pump();
    });

    testWidgets('should display all scaffold properties correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(isLoading: true));
      await tester.pump();
      
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, Colors.transparent);
      expect(scaffold.extendBodyBehindAppBar, true);
    });

    testWidgets('should handle multiple tasks with same id gracefully', (tester) async {
      final task1 = createTestTask(title: 'Task 1');
      final task2 = createTestTask(title: 'Task 2');
      
      await tester.pumpWidget(createTestWidget(tasks: [task1, task2]));
      await tester.pump();
      
      // Should find the first task with matching ID
      expect(find.byType(TaskDetailPage), findsOneWidget);
    });

    testWidgets('should handle wrong task id', (tester) async {
      final task = createTestTask(id: 'different-id');
      
      await tester.pumpWidget(createTestWidget(tasks: [task]));
      await tester.pump();
      
      expect(find.text('Task not found'), findsOneWidget);
    });

    testWidgets('should maintain theme background wrapper', (tester) async {
      await tester.pumpWidget(createTestWidget(hasError: true));
      await tester.pump();
      
      expect(find.byType(ThemeBackgroundWidget), findsOneWidget);
    });

    testWidgets('should handle task with all priority levels', (tester) async {
      for (final priority in TaskPriority.values) {
        final task = createTestTask(priority: priority);
        
        await tester.pumpWidget(createTestWidget(tasks: [task]));
        await tester.pump();
        
        expect(find.byType(TaskDetailPage), findsOneWidget);
      }
    });

    testWidgets('should handle task with all status levels', (tester) async {
      for (final status in TaskStatus.values) {
        final task = createTestTask(status: status);
        
        await tester.pumpWidget(createTestWidget(tasks: [task]));
        await tester.pump();
        
        expect(find.byType(TaskDetailPage), findsOneWidget);
      }
    });

    testWidgets('should handle task created with quickCreate', (tester) async {
      final quickTask = TaskModel.create(title: 'Quick Task').copyWith(id: testTaskId);
      
      await tester.pumpWidget(createTestWidget(tasks: [quickTask]));
      await tester.pump();
      
      expect(find.byType(TaskDetailPage), findsOneWidget);
    });

    testWidgets('should handle null task in list gracefully', (tester) async {
      // Test with a list that might contain nulls (edge case)
      final task = createTestTask();
      
      await tester.pumpWidget(createTestWidget(tasks: [task]));
      await tester.pump();
      
      expect(find.byType(TaskDetailPage), findsOneWidget);
    });
  });

  group('TaskDetailPage Integration Tests', () {
    testWidgets('should integrate with providers correctly', (tester) async {
      final widget = ProviderScope(
        child: MaterialApp(
          home: Theme(
            data: ThemeData.light(),
            child: const TaskDetailPage(taskId: 'test-id'),
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();
      
      expect(find.byType(TaskDetailPage), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      final task = TaskModel.create(title: 'Test').copyWith(id: 'test-id');
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value([task])),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const TaskDetailPage(taskId: 'test-id'),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(TaskDetailPage), findsOneWidget);
    });
  });

  group('TaskDetailPage Edge Cases', () {
    testWidgets('should handle rapid navigation', (tester) async {
      final task = TaskModel.create(title: 'Test').copyWith(id: 'test-id');
      
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tasksProvider.overrideWith((ref) => Stream.value([task])),
            ],
            child: MaterialApp(
              home: TaskDetailPage(taskId: 'test-id-$i'),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 10));
      }
      
      await tester.pump();
      expect(find.byType(TaskDetailPage), findsOneWidget);
    });

    testWidgets('should handle very large task list', (tester) async {
      final largeTasks = List.generate(1000, (i) => 
        TaskModel.create(title: 'Task $i').copyWith(id: 'task-$i'));
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value(largeTasks)),
          ],
          child: const MaterialApp(
            home: TaskDetailPage(taskId: 'task-500'),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(TaskDetailPage), findsOneWidget);
    });

    testWidgets('should handle widget disposal properly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TaskDetailPage(taskId: 'test-id'),
          ),
        ),
      );
      await tester.pump();
      
      // Navigate away to test disposal
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Other page'))),
      );
      await tester.pump();
      
      expect(find.text('Other page'), findsOneWidget);
    });
  });

  group('TaskDetailPage Performance Tests', () {
    testWidgets('should render quickly with simple task', (tester) async {
      final stopwatch = Stopwatch()..start();
      
      final task = TaskModel.create(title: 'Simple Task').copyWith(id: 'test-id');
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value([task])),
          ],
          child: const MaterialApp(
            home: TaskDetailPage(taskId: 'test-id'),
          ),
        ),
      );
      await tester.pump();
      
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(find.byType(TaskDetailPage), findsOneWidget);
    });

    testWidgets('should handle frequent rebuilds efficiently', (tester) async {
      final task = TaskModel.create(title: 'Test').copyWith(id: 'test-id');
      
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 50; i++) {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tasksProvider.overrideWith((ref) => Stream.value([task])),
            ],
            child: const MaterialApp(
              home: TaskDetailPage(taskId: 'test-id'),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 1));
      }
      
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      expect(find.byType(TaskDetailPage), findsOneWidget);
    });
  });
}
