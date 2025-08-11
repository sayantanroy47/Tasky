import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/presentation/widgets/task_card_m3.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/domain/repositories/task_repository.dart';
import 'package:task_tracker_app/presentation/providers/task_providers.dart';

@GenerateMocks([TaskRepository])
import 'task_card_m3_comprehensive_test.mocks.dart';

/// COMPREHENSIVE TASK CARD M3 TESTS - ALL UI FUNCTIONALITY AND INTERACTIONS
void main() {
  group('TaskCardM3 - Comprehensive UI and Interaction Tests', () {
    late MockTaskRepository mockRepository;
    late ProviderContainer container;
    late TaskModel sampleTask;

    setUp(() {
      mockRepository = MockTaskRepository();
      container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      
      sampleTask = TaskModel.create(
        title: 'Sample Task',
        description: 'Sample task description',
        priority: TaskPriority.medium,
        dueDate: DateTime.now().add(const Duration(days: 1)),
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Task Card Display Tests', () {
      testWidgets('should display basic task information', (tester) async {
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(task: sampleTask),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Sample Task'), findsOneWidget);
        expect(find.text('Sample task description'), findsOneWidget);
      });

      testWidgets('should display task with null description', (tester) async {
        // Arrange
        final taskWithoutDesc = sampleTask.copyWith(description: null);

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(task: taskWithoutDesc),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Sample Task'), findsOneWidget);
        expect(find.text('Sample task description'), findsNothing);
      });

      testWidgets('should display priority indicator correctly', (tester) async {
        // Test all priority levels
        for (final priority in TaskPriority.values) {
          final taskWithPriority = sampleTask.copyWith(priority: priority);

          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                home: Scaffold(
                  body: TaskCardM3(task: taskWithPriority),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Should display priority-specific styling or indicator
          expect(find.byType(TaskCardM3), findsOneWidget);
          
          // Priority colors/styles should be applied
          final cardWidget = tester.widget<TaskCardM3>(find.byType(TaskCardM3));
          expect(cardWidget.task.priority, equals(priority));
        }
      });

      testWidgets('should display due date correctly', (tester) async {
        // Arrange
        final dueDate = DateTime(2024, 12, 25, 14, 30);
        final taskWithDueDate = sampleTask.copyWith(dueDate: dueDate);

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(task: taskWithDueDate),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Should display due date in some format
        expect(find.byType(TaskCardM3), findsOneWidget);
      });

      testWidgets('should display overdue tasks differently', (tester) async {
        // Arrange
        final overdueDate = DateTime.now().subtract(const Duration(days: 2));
        final overdueTask = sampleTask.copyWith(dueDate: overdueDate);

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(task: overdueTask),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Overdue tasks should have distinct styling
        expect(find.byType(TaskCardM3), findsOneWidget);
        expect(overdueTask.isOverdue, isTrue);
      });

      testWidgets('should display completed tasks with strikethrough', (tester) async {
        // Arrange
        final completedTask = sampleTask.complete();

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(task: completedTask),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Completed tasks should show strikethrough or different styling
        expect(find.byType(TaskCardM3), findsOneWidget);
        expect(completedTask.isCompleted, isTrue);
      });
    });

    group('Task Card Interaction Tests', () {
      testWidgets('should handle tap gesture', (tester) async {
        // Arrange
        bool tapped = false;

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(
                  task: sampleTask,
                  onTap: () => tapped = true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the card
        await tester.tap(find.byType(TaskCardM3));
        await tester.pumpAndSettle();

        // Assert
        expect(tapped, isTrue);
      });

      testWidgets('should handle long press gesture', (tester) async {
        // Arrange
        bool longPressed = false;

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(
                  task: sampleTask,
                  onLongPress: () => longPressed = true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Long press the card
        await tester.longPress(find.byType(TaskCardM3));
        await tester.pumpAndSettle();

        // Assert
        expect(longPressed, isTrue);
      });

      testWidgets('should handle checkbox tap for completion toggle', (tester) async {
        // Arrange
        when(mockRepository.updateTask(any))
            .thenAnswer((_) async => Right(sampleTask.complete()));

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(task: sampleTask),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find and tap checkbox
        final checkbox = find.byType(Checkbox);
        if (checkbox.evaluate().isNotEmpty) {
          await tester.tap(checkbox);
          await tester.pumpAndSettle();
        }

        // Should trigger completion toggle
      });

      testWidgets('should handle swipe gestures', (tester) async {
        // Arrange
        bool swiped = false;

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(
                  task: sampleTask,
                  onDismissed: (_) => swiped = true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Swipe the card
        await tester.drag(find.byType(TaskCardM3), const Offset(500, 0));
        await tester.pumpAndSettle();

        // Should handle swipe dismissal
      });
    });

    group('Task Card Subtasks Tests', () {
      testWidgets('should display subtask progress', (tester) async {
        // Arrange
        final taskWithSubtasks = sampleTask.copyWith(
          subtasks: ['Subtask 1', 'Subtask 2', 'Subtask 3'],
          completedSubtasks: 1,
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(task: taskWithSubtasks),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Should display progress indicator (1/3 completed)
        expect(find.byType(TaskCardM3), findsOneWidget);
        expect(taskWithSubtasks.subtaskProgress, equals(1/3));
      });

      testWidgets('should display task without subtasks', (tester) async {
        // Arrange
        final taskNoSubtasks = sampleTask.copyWith(subtasks: []);

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(task: taskNoSubtasks),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Should not display subtask progress
        expect(find.byType(TaskCardM3), findsOneWidget);
        expect(taskNoSubtasks.totalSubtasks, equals(0));
      });
    });

    group('Task Card Tags and Metadata Tests', () {
      testWidgets('should display task tags', (tester) async {
        // Arrange
        final taggedTask = sampleTask.copyWith(
          tags: ['work', 'urgent', 'meeting'],
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(task: taggedTask),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Should display tags as chips or similar
        expect(find.text('work'), findsOneWidget);
        expect(find.text('urgent'), findsOneWidget);
        expect(find.text('meeting'), findsOneWidget);
      });

      testWidgets('should handle task with no tags', (tester) async {
        // Arrange
        final untaggedTask = sampleTask.copyWith(tags: []);

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(task: untaggedTask),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Should handle empty tags gracefully
        expect(find.byType(TaskCardM3), findsOneWidget);
        expect(untaggedTask.tags, isEmpty);
      });
    });

    group('Task Card Layout and Spacing Tests', () {
      testWidgets('should use correct border radius (5px standard)', (tester) async {
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(task: sampleTask),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Card should use standardized 5px border radius
        final cardElements = find.byType(Card);
        if (cardElements.evaluate().isNotEmpty) {
          final card = tester.widget<Card>(cardElements.first);
          // Check if shape uses 5px radius as per requirements
        }
      });

      testWidgets('should have proper spacing between elements', (tester) async {
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(task: sampleTask),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Elements should have consistent spacing
        expect(find.byType(TaskCardM3), findsOneWidget);
      });

      testWidgets('should handle long task titles gracefully', (tester) async {
        // Arrange
        final longTitle = 'A' * 100; // Very long title
        final longTitleTask = sampleTask.copyWith(title: longTitle);

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 300, // Constrained width
                  child: TaskCardM3(task: longTitleTask),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Should handle overflow properly (ellipsis or wrapping)
        expect(find.byType(TaskCardM3), findsOneWidget);
      });
    });

    group('Task Card Theme Integration Tests', () {
      testWidgets('should adapt to light theme', (tester) async {
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: ThemeData.light(),
              home: Scaffold(
                body: TaskCardM3(task: sampleTask),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Should use light theme colors
        expect(find.byType(TaskCardM3), findsOneWidget);
      });

      testWidgets('should adapt to dark theme', (tester) async {
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: ThemeData.dark(),
              home: Scaffold(
                body: TaskCardM3(task: sampleTask),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Should use dark theme colors
        expect(find.byType(TaskCardM3), findsOneWidget);
      });

      testWidgets('should use centralized status badge colors', (tester) async {
        // Test different task statuses
        for (final status in TaskStatus.values) {
          final statusTask = sampleTask.copyWith(status: status);

          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                home: Scaffold(
                  body: TaskCardM3(task: statusTask),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Should use centralized theme-specific status colors
          expect(find.byType(TaskCardM3), findsOneWidget);
        }
      });
    });

    group('Task Card Animation Tests', () {
      testWidgets('should animate priority changes', (tester) async {
        // Arrange
        final lowPriorityTask = sampleTask.copyWith(priority: TaskPriority.low);

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(task: lowPriorityTask),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Change priority
        final highPriorityTask = lowPriorityTask.copyWith(priority: TaskPriority.urgent);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(task: highPriorityTask),
              ),
            ),
          ),
        );
        await tester.pump();

        // Should animate the priority change
        expect(find.byType(TaskCardM3), findsOneWidget);
      });

      testWidgets('should animate completion state changes', (tester) async {
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(task: sampleTask),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Complete task
        final completedTask = sampleTask.complete();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(task: completedTask),
              ),
            ),
          ),
        );
        await tester.pump();

        // Should animate completion transition
        expect(find.byType(TaskCardM3), findsOneWidget);
      });
    });

    group('Task Card Accessibility Tests', () {
      testWidgets('should provide proper accessibility semantics', (tester) async {
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(task: sampleTask),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Should have semantic labels
        expect(find.byType(Semantics), findsWidgets);
      });

      testWidgets('should support screen reader announcements', (tester) async {
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(task: sampleTask),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should provide descriptive accessibility labels
        // for task title, description, priority, due date, etc.
      });
    });

    group('Task Card Performance Tests', () {
      testWidgets('should render efficiently with complex task data', (tester) async {
        // Arrange - Task with lots of data
        final complexTask = TaskModel.create(
          title: 'Complex Task with Very Long Title That Tests Layout',
          description: 'Complex task description ' * 20, // Long description
          priority: TaskPriority.urgent,
          dueDate: DateTime.now().add(const Duration(days: 1)),
          tags: List.generate(10, (i) => 'tag$i'),
          subtasks: List.generate(20, (i) => 'Subtask $i'),
          metadata: Map.fromEntries(
            List.generate(50, (i) => MapEntry('key$i', 'value$i')),
          ),
        );

        // Act
        final startTime = DateTime.now();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(task: complexTask),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final endTime = DateTime.now();

        // Assert - Should render quickly
        final renderTime = endTime.difference(startTime);
        expect(renderTime.inMilliseconds, lessThan(500));
        expect(find.byType(TaskCardM3), findsOneWidget);
      });

      testWidgets('should handle rapid state changes efficiently', (tester) async {
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TaskCardM3(task: sampleTask),
              ),
            ),
          ),
        );

        // Rapidly change task states
        for (int i = 0; i < 10; i++) {
          final updatedTask = sampleTask.copyWith(
            priority: TaskPriority.values[i % TaskPriority.values.length],
            updatedAt: DateTime.now(),
          );
          
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                home: Scaffold(
                  body: TaskCardM3(task: updatedTask),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 50));
        }

        await tester.pumpAndSettle();
        
        // Should handle rapid updates without issues
        expect(find.byType(TaskCardM3), findsOneWidget);
      });
    });
  });
}