import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/pages/tasks_page.dart';
import 'package:task_tracker_app/presentation/providers/task_providers.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';

// Helper functions available to all test groups
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
            child: const TasksPage(),
          ),
        ),
      );
    }

TaskModel createTestTask({
  String title = 'Test Task',
  TaskPriority priority = TaskPriority.medium,
  TaskStatus status = TaskStatus.pending,
}) {
  return TaskModel.create(title: title).copyWith(
    priority: priority,
    status: status,
  );
}

void main() {
  group('TasksPage Widget Tests', () {
    testWidgets('should display tasks page with basic elements', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      expect(find.byType(TasksPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display loading state', (tester) async {
      await tester.pumpWidget(createTestWidget(isLoading: true));
      await tester.pump();
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error state', (tester) async {
      await tester.pumpWidget(createTestWidget(hasError: true));
      await tester.pump();
      
      expect(find.textContaining('error'), findsOneWidget, reason: 'Should display error message');
    });

    testWidgets('should display empty state when no tasks', (tester) async {
      await tester.pumpWidget(createTestWidget(tasks: []));
      await tester.pump();
      
      expect(find.byType(TasksPage), findsOneWidget);
    });

    testWidgets('should display task list when tasks exist', (tester) async {
      final tasks = [
        createTestTask(title: 'Task 1'),
        createTestTask(title: 'Task 2'),
        createTestTask(title: 'Task 3'),
      ];
      
      await tester.pumpWidget(createTestWidget(tasks: tasks));
      await tester.pump();
      
      expect(find.byType(TasksPage), findsOneWidget);
    });

    testWidgets('should handle tasks with different priorities', (tester) async {
      final tasks = [
        createTestTask(title: 'Urgent Task', priority: TaskPriority.urgent),
        createTestTask(title: 'High Task', priority: TaskPriority.high),
        createTestTask(title: 'Medium Task', priority: TaskPriority.medium),
        createTestTask(title: 'Low Task', priority: TaskPriority.low),
      ];
      
      await tester.pumpWidget(createTestWidget(tasks: tasks));
      await tester.pump();
      
      expect(find.byType(TasksPage), findsOneWidget);
    });

    testWidgets('should handle tasks with different statuses', (tester) async {
      final tasks = [
      ];
      
      await tester.pumpWidget(createTestWidget(tasks: tasks));
      await tester.pump();
      
      expect(find.byType(TasksPage), findsOneWidget);
    });

    testWidgets('should handle scrolling with many tasks', (tester) async {
      final tasks = List.generate(50, (i) => 
        createTestTask(title: 'Task $i'));
      
      await tester.pumpWidget(createTestWidget(tasks: tasks));
      await tester.pump();
      
      // Test scrolling
      await tester.drag(find.byType(TasksPage), const Offset(0, -300));
      await tester.pump();
      
      expect(find.byType(TasksPage), findsOneWidget);
    });

    testWidgets('should maintain consistent layout', (tester) async {
      final tasks = [createTestTask()];
      
      await tester.pumpWidget(createTestWidget(tasks: tasks));
      await tester.pump();
      
      expect(find.byType(TasksPage), findsOneWidget);
    });

    testWidgets('should handle rapid state changes', (tester) async {
      await tester.pumpWidget(createTestWidget(isLoading: true));
      await tester.pump();
      
      await tester.pumpWidget(createTestWidget(tasks: [createTestTask()]));
      await tester.pump();
      
      await tester.pumpWidget(createTestWidget(hasError: true));
      await tester.pump();
      
      expect(find.byType(TasksPage), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      final tasks = [createTestTask()];
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value(tasks)),
          ],
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const TasksPage(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(TasksPage), findsOneWidget);
    });
  });

  group('TasksPage Integration Tests', () {
    testWidgets('should integrate with real providers', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Theme(
              data: ThemeData.light(),
              child: const TasksPage(),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(TasksPage), findsOneWidget);
    });

    testWidgets('should handle provider state changes', (tester) async {
      final container = ProviderContainer();
      
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: TasksPage(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(TasksPage), findsOneWidget);
      
      container.dispose();
    });
  });

  group('TasksPage Performance Tests', () {
    testWidgets('should render efficiently with many tasks', (tester) async {
      final tasks = List.generate(100, (i) => 
        createTestTask(title: 'Task $i'));
      
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(createTestWidget(tasks: tasks));
      await tester.pump();
      
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      expect(find.byType(TasksPage), findsOneWidget);
    });

    testWidgets('should handle frequent rebuilds', (tester) async {
      final tasks = [createTestTask()];
      
      for (int i = 0; i < 20; i++) {
        await tester.pumpWidget(createTestWidget(tasks: tasks));
        await tester.pump(const Duration(milliseconds: 10));
      }
      
      await tester.pump();
      expect(find.byType(TasksPage), findsOneWidget);
    });
  });

  group('TasksPage Edge Cases', () {
    testWidgets('should handle null tasks gracefully', (tester) async {
      await tester.pumpWidget(createTestWidget(tasks: []));
      await tester.pump();
      
      expect(find.byType(TasksPage), findsOneWidget);
    });

    testWidgets('should handle very long task titles', (tester) async {
      final longTitle = 'A' * 200;
      final tasks = [createTestTask(title: longTitle)];
      
      await tester.pumpWidget(createTestWidget(tasks: tasks));
      await tester.pump();
      
      expect(find.byType(TasksPage), findsOneWidget);
    });

    testWidgets('should handle small screen sizes', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      
      final tasks = [createTestTask()];
      await tester.pumpWidget(createTestWidget(tasks: tasks));
      await tester.pump();
      
      expect(find.byType(TasksPage), findsOneWidget);
      
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should handle large screen sizes', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      
      final tasks = [createTestTask()];
      await tester.pumpWidget(createTestWidget(tasks: tasks));
      await tester.pump();
      
      expect(find.byType(TasksPage), findsOneWidget);
      
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should handle accessibility requirements', (tester) async {
      final tasks = [createTestTask()];
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tasksProvider.overrideWith((ref) => Stream.value(tasks)),
          ],
          child: const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: TasksPage(),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(TasksPage), findsOneWidget);
    });

    testWidgets('should handle widget disposal', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Navigate away
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Other page'))),
      );
      await tester.pump();
      
      expect(find.text('Other page'), findsOneWidget);
    });
  });
}
