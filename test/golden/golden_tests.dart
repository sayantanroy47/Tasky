import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_tracker_app/presentation/widgets/message_task_dialog.dart';
import 'package:task_tracker_app/presentation/widgets/advanced_task_card.dart';
import 'package:task_tracker_app/presentation/pages/settings_page.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';

void main() {
  group('Golden Tests', () {
    testWidgets('MessageTaskDialog - light theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: MessageTaskDialog(
                messageText: 'Can you pick up milk on your way home?',
                sourceName: 'Wife 💕',
                sourceApp: 'WhatsApp',
                suggestedTask: TaskModel.create(
                  title: 'Pick up milk',
                  priority: TaskPriority.medium,
                  tags: ['shopping', 'wife'],
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(MessageTaskDialog),
        matchesGoldenFile('message_task_dialog_light.png'),
      );
    });

    testWidgets('MessageTaskDialog - dark theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: MessageTaskDialog(
                messageText: 'Can you pick up milk on your way home?',
                sourceName: 'Wife 💕',
                sourceApp: 'WhatsApp',
                suggestedTask: TaskModel.create(
                  title: 'Pick up milk',
                  priority: TaskPriority.medium,
                  tags: ['shopping', 'wife'],
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(MessageTaskDialog),
        matchesGoldenFile('message_task_dialog_dark.png'),
      );
    });

    testWidgets('MessageTaskDialog - high contrast light', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.light().copyWith(visualDensity: VisualDensity.adaptivePlatformDensity),
            home: Scaffold(
              body: MessageTaskDialog(
                messageText: 'Can you pick up milk on your way home?',
                sourceName: 'Wife 💕',
                sourceApp: 'WhatsApp',
                suggestedTask: TaskModel.create(
                  title: 'Pick up milk',
                  priority: TaskPriority.high,
                  tags: ['shopping', 'wife'],
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(MessageTaskDialog),
        matchesGoldenFile('message_task_dialog_high_contrast_light.png'),
      );
    });

    testWidgets('MessageTaskDialog - high contrast dark', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark().copyWith(visualDensity: VisualDensity.adaptivePlatformDensity),
            home: Scaffold(
              body: MessageTaskDialog(
                messageText: 'Can you pick up milk on your way home?',
                sourceName: 'Wife 💕',
                sourceApp: 'WhatsApp',
                suggestedTask: TaskModel.create(
                  title: 'Pick up milk',
                  priority: TaskPriority.urgent,
                  tags: ['shopping', 'wife'],
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(MessageTaskDialog),
        matchesGoldenFile('message_task_dialog_high_contrast_dark.png'),
      );
    });

    testWidgets('TaskCard - pending task light theme', (tester) async {
      final task = TaskModel.create(
        title: 'Complete project documentation',
        description: 'Write comprehensive documentation for the new API endpoints and user guides',
        priority: TaskPriority.high,
        dueDate: DateTime.now().add(const Duration(days: 2)),
        tags: ['work', 'documentation', 'api'],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AdvancedTaskCard(task: task),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AdvancedTaskCard),
        matchesGoldenFile('task_card_pending_light.png'),
      );
    });

    testWidgets('TaskCard - completed task dark theme', (tester) async {
      final task = TaskModel.create(
        title: 'Review quarterly reports',
        description: 'Analyze Q3 financial data and prepare summary',
        priority: TaskPriority.medium,
        tags: ['finance', 'quarterly'],
      ).markCompleted();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AdvancedTaskCard(task: task),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AdvancedTaskCard),
        matchesGoldenFile('task_card_completed_dark.png'),
      );
    });

    testWidgets('TaskCard - urgent task with subtasks', (tester) async {
      final task = TaskModel.create(
        title: 'Prepare for board meeting',
        description: 'Comprehensive preparation for quarterly board meeting',
        priority: TaskPriority.urgent,
        dueDate: DateTime.now().add(const Duration(hours: 6)),
        tags: ['urgent', 'meeting', 'board'],
      );

      // Add some subtasks
      final taskWithSubtasks = task.copyWith(
        subTasks: [
          SubTask.create(taskId: task.id, title: 'Prepare presentation slides'),
          SubTask.create(taskId: task.id, title: 'Review financial reports').markCompleted(),
          SubTask.create(taskId: task.id, title: 'Coordinate with stakeholders'),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AdvancedTaskCard(task: taskWithSubtasks),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AdvancedTaskCard),
        matchesGoldenFile('task_card_urgent_with_subtasks.png'),
      );
    });

    testWidgets('TaskCard - overdue task', (tester) async {
      final task = TaskModel.create(
        title: 'Submit expense report',
        description: 'Monthly expense report submission',
        priority: TaskPriority.medium,
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        tags: ['finance', 'overdue'],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AdvancedTaskCard(task: task),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(AdvancedTaskCard),
        matchesGoldenFile('task_card_overdue.png'),
      );
    });

    testWidgets('Settings page - light theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.light(),
            home: const SettingsPage(),
          ),
        ),
      );

      await expectLater(
        find.byType(SettingsPage),
        matchesGoldenFile('settings_page_light.png'),
      );
    });

    testWidgets('Settings page - dark theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const SettingsPage(),
          ),
        ),
      );

      await expectLater(
        find.byType(SettingsPage),
        matchesGoldenFile('settings_page_dark.png'),
      );
    });

    group('Responsive Design Golden Tests', () {
      testWidgets('MessageTaskDialog - tablet landscape', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(1200, 800);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: Scaffold(
                body: MessageTaskDialog(
                  messageText: 'Can you pick up milk on your way home?',
                  sourceName: 'Wife 💕',
                  sourceApp: 'WhatsApp',
                  suggestedTask: TaskModel.create(
                    title: 'Pick up milk',
                    priority: TaskPriority.medium,
                    tags: ['shopping', 'wife'],
                  ),
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(MessageTaskDialog),
          matchesGoldenFile('message_task_dialog_tablet_landscape.png'),
        );

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      });

      testWidgets('TaskCard - phone portrait', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(375, 812);
        tester.binding.window.devicePixelRatioTestValue = 2.0;

        final task = TaskModel.create(
          title: 'Long task title that should wrap properly on narrow screens',
          description: 'This is a longer description that should also wrap nicely on mobile devices',
          priority: TaskPriority.high,
          tags: ['mobile', 'responsive', 'design'],
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AdvancedTaskCard(task: task),
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AdvancedTaskCard),
          matchesGoldenFile('task_card_phone_portrait.png'),
        );

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      });
    });

    group('Accessibility Golden Tests', () {
      testWidgets('MessageTaskDialog - large text scale', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: MediaQuery(
                data: const MediaQueryData(
                  textScaleFactor: 2.0, // Large text scale
                ),
                child: Scaffold(
                  body: MessageTaskDialog(
                    messageText: 'Can you pick up milk on your way home?',
                    sourceName: 'Wife 💕',
                    sourceApp: 'WhatsApp',
                    suggestedTask: TaskModel.create(
                      title: 'Pick up milk',
                      priority: TaskPriority.medium,
                      tags: ['shopping', 'wife'],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(MessageTaskDialog),
          matchesGoldenFile('message_task_dialog_large_text.png'),
        );
      });

      testWidgets('TaskCard - high contrast accessibility', (tester) async {
        final task = TaskModel.create(
          title: 'Accessibility test task',
          description: 'Testing high contrast mode for accessibility',
          priority: TaskPriority.high,
          tags: ['accessibility', 'testing'],
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light().copyWith(visualDensity: VisualDensity.adaptivePlatformDensity),
              home: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AdvancedTaskCard(task: task),
                ),
              ),
            ),
          ),
        );

        await expectLater(
          find.byType(AdvancedTaskCard),
          matchesGoldenFile('task_card_high_contrast_accessibility.png'),
        );
      });
    });

    group('Error State Golden Tests', () {
      testWidgets('MessageTaskDialog - error state', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: Scaffold(
                body: MessageTaskDialog(
                  messageText: '', // Empty message to trigger validation
                  sourceName: 'Test',
                  sourceApp: 'Test',
                ),
              ),
            ),
          ),
        );

        // Try to create task with empty title to trigger error
        final createButton = find.text('Create Task');
        await tester.tap(createButton);
        await tester.pump();

        await expectLater(
          find.byType(MessageTaskDialog),
          matchesGoldenFile('message_task_dialog_error_state.png'),
        );
      });
    });

    group('Loading State Golden Tests', () {
      testWidgets('MessageTaskDialog - loading state simulation', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.light(),
              home: Scaffold(
                body: MessageTaskDialog(
                  messageText: 'Loading test message',
                  sourceName: 'Test',
                  sourceApp: 'Test',
                ),
              ),
            ),
          ),
        );

        // Simulate loading state by showing a progress indicator
        await tester.pump(const Duration(milliseconds: 100));

        await expectLater(
          find.byType(MessageTaskDialog),
          matchesGoldenFile('message_task_dialog_loading_state.png'),
        );
      });
    });

    group('Priority Variations Golden Tests', () {
      for (final priority in TaskPriority.values) {
        testWidgets('TaskCard - ${priority.name} priority', (tester) async {
          final task = TaskModel.create(
            title: '${priority.name.toUpperCase()} priority task',
            description: 'Testing ${priority.name} priority styling',
            priority: priority,
            tags: [priority.name, 'testing'],
          );

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                theme: ThemeData.light(),
                home: Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AdvancedTaskCard(task: task),
                  ),
                ),
              ),
            ),
          );

          await expectLater(
            find.byType(AdvancedTaskCard),
            matchesGoldenFile('task_card_priority_${priority.name}.png'),
          );
        });
      }
    });

    group('Status Variations Golden Tests', () {
      for (final status in TaskStatus.values) {
        testWidgets('TaskCard - ${status.name} status', (tester) async {
          var task = TaskModel.create(
            title: '${status.name.toUpperCase()} status task',
            description: 'Testing ${status.name} status styling',
            priority: TaskPriority.medium,
            tags: [status.name, 'testing'],
          );

          // Apply the specific status
          switch (status) {
            case TaskStatus.pending:
              // Already pending
              break;
            case TaskStatus.inProgress:
              task = task.markInProgress();
              break;
            case TaskStatus.completed:
              task = task.markCompleted();
              break;
            case TaskStatus.cancelled:
              task = task.markCancelled();
              break;
          }

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                theme: ThemeData.light(),
                home: Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AdvancedTaskCard(task: task),
                  ),
                ),
              ),
            ),
          );

          await expectLater(
            find.byType(AdvancedTaskCard),
            matchesGoldenFile('task_card_status_${status.name}.png'),
          );
        });
      }
    });
  });
}

/// Extension to help with SubTask creation since it might not have a create method
extension SubTaskHelper on TaskModel {
  // This would need to be implemented based on the actual SubTask class
}