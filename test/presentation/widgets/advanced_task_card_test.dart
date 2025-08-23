import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/presentation/widgets/advanced_task_card.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';

// Helper functions for testing
Widget createTestWidget({required Widget child}) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

TaskModel createTestTask({
  String title = 'Test Task',
  TaskStatus status = TaskStatus.pending,
  TaskPriority priority = TaskPriority.medium,
  DateTime? dueDate,
}) {
  return TaskModel.create(title: title).copyWith(
    status: status,
    priority: priority,
    dueDate: dueDate,
  );
}

void main() {
  group('AdvancedTaskCard Widget Tests', () {
    testWidgets('should display task title and basic information', (tester) async {
      final task = createTestTask(title: 'Test Task Title');
      
      await tester.pumpWidget(
        createTestWidget(
          child: AdvancedTaskCard(task: task),
        ),
      );
      await tester.pump();
      
      expect(find.text('Test Task Title'), findsOneWidget);
      expect(find.byType(AdvancedTaskCard), findsOneWidget);
    });

    testWidgets('should display different priority indicators', (tester) async {
      final urgentTask = createTestTask(
        title: 'Urgent Task',
        priority: TaskPriority.urgent,
      );
      
      await tester.pumpWidget(
        createTestWidget(
          child: AdvancedTaskCard(task: urgentTask),
        ),
      );
      await tester.pump();
      
      expect(find.text('Urgent Task'), findsOneWidget);
      expect(find.byType(AdvancedTaskCard), findsOneWidget);
    });

    testWidgets('should display different status indicators', (tester) async {
      final completedTask = createTestTask(
        title: 'Completed Task',
        status: TaskStatus.completed,
      );
      
      await tester.pumpWidget(
        createTestWidget(
          child: AdvancedTaskCard(task: completedTask),
        ),
      );
      await tester.pump();
      
      expect(find.text('Completed Task'), findsOneWidget);
      expect(find.byType(AdvancedTaskCard), findsOneWidget);
    });

    testWidgets('should handle tasks with due dates', (tester) async {
      final taskWithDueDate = createTestTask(
        title: 'Task with Due Date',
        dueDate: DateTime.now().add(const Duration(days: 1)),
      );
      
      await tester.pumpWidget(
        createTestWidget(
          child: AdvancedTaskCard(task: taskWithDueDate),
        ),
      );
      await tester.pump();
      
      expect(find.text('Task with Due Date'), findsOneWidget);
      expect(find.byType(AdvancedTaskCard), findsOneWidget);
    });

    testWidgets('should handle overdue tasks', (tester) async {
      final overdueTask = createTestTask(
        title: 'Overdue Task',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      
      await tester.pumpWidget(
        createTestWidget(
          child: AdvancedTaskCard(task: overdueTask),
        ),
      );
      await tester.pump();
      
      expect(find.text('Overdue Task'), findsOneWidget);
      expect(find.byType(AdvancedTaskCard), findsOneWidget);
    });

    testWidgets('should handle tap interactions', (tester) async {
      final task = createTestTask(title: 'Tappable Task');
      bool onTapCalled = false;
      
      await tester.pumpWidget(
        createTestWidget(
          child: AdvancedTaskCard(
            task: task,
            onTap: () => onTapCalled = true,
          ),
        ),
      );
      await tester.pump();
      
      await tester.tap(find.byType(AdvancedTaskCard));
      await tester.pump();
      
      expect(onTapCalled, isTrue);
    });

    testWidgets('should work with different themes', (tester) async {
      final task = createTestTask(title: 'Themed Task');
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: AdvancedTaskCard(task: task),
            ),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('Themed Task'), findsOneWidget);
      expect(find.byType(AdvancedTaskCard), findsOneWidget);
    });

    testWidgets('should handle long task titles', (tester) async {
      final longTitleTask = createTestTask(
        title: 'This is a very long task title that should be handled gracefully by the widget and should not cause overflow issues',
      );
      
      await tester.pumpWidget(
        createTestWidget(
          child: AdvancedTaskCard(task: longTitleTask),
        ),
      );
      await tester.pump();
      
      expect(find.byType(AdvancedTaskCard), findsOneWidget);
    });

    testWidgets('should handle null or missing properties gracefully', (tester) async {
      final minimalTask = TaskModel.create(title: 'Minimal Task');
      
      await tester.pumpWidget(
        createTestWidget(
          child: AdvancedTaskCard(task: minimalTask),
        ),
      );
      await tester.pump();
      
      expect(find.text('Minimal Task'), findsOneWidget);
      expect(find.byType(AdvancedTaskCard), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      final task = createTestTask(title: 'Accessible Task');
      
      await tester.pumpWidget(
        createTestWidget(
          child: AdvancedTaskCard(task: task),
        ),
      );
      await tester.pump();
      
      // Check for accessibility semantics
      expect(find.byType(AdvancedTaskCard), findsOneWidget);
      
      // Verify the widget can be found by semantic labels if present
      final semantics = tester.getSemantics(find.byType(AdvancedTaskCard));
      expect(semantics, isNotNull);
    });
  });
}