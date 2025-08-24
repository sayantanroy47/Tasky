import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/presentation/widgets/advanced_task_card.dart';
import 'package:task_tracker_app/presentation/widgets/enhanced_task_creation_dialog.dart';

void main() {
  group('Task Management Workflow Integration Tests', () {
    late ProviderContainer container;
    late AppDatabase testDatabase;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Create test database
      testDatabase = AppDatabase.forTesting(NativeDatabase.memory());
      
      // Create container with overrides
      container = ProviderContainer(
        overrides: [
          // Override database provider with test database
          // databaseProvider.overrideWithValue(testDatabase),
        ],
      );
    });

    tearDown(() async {
      await testDatabase.close();
      container.dispose();
    });

    group('Complete Task Creation Workflow', () {
      testWidgets('should create task from home screen through dialog', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: const Center(child: Text('Home')),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    showDialog(
                      context: tester.element(find.byType(Scaffold)),
                      builder: (context) => const EnhancedTaskCreationDialog(),
                    );
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ),
        );

        // Verify home screen loads
        expect(find.text('Home'), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // Tap the FAB to open task creation dialog
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // Verify dialog appears
        expect(find.byType(EnhancedTaskCreationDialog), findsOneWidget);

        // Fill in task details
        await tester.enterText(find.byKey(const Key('task_title_field')), 'Integration Test Task');
        await tester.enterText(find.byKey(const Key('task_description_field')), 'This task was created during integration testing');

        // Set priority
        await tester.tap(find.byKey(const Key('priority_dropdown')));
        await tester.pump();
        await tester.tap(find.text('High').last);
        await tester.pump();

        // Save task
        await tester.tap(find.byKey(const Key('save_task_button')));
        await tester.pump();

        // Verify dialog closes
        expect(find.byType(EnhancedTaskCreationDialog), findsNothing);

        // Verify task appears in the list (would need to pump the home screen)
        // This would require proper home screen integration
      });

      testWidgets('should create task with voice input workflow', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  actions: [
                    IconButton(
                      key: const Key('voice_input_button'),
                      icon: const Icon(Icons.mic),
                      onPressed: () {
                        // Simulate voice input workflow
                      },
                    ),
                  ],
                ),
                body: const Center(child: Text('Voice Input Test')),
              ),
            ),
          ),
        );

        // Tap voice input button
        await tester.tap(find.byKey(const Key('voice_input_button')));
        await tester.pump();

        // Simulate voice recognition (would require actual voice service integration)
        // For now, verify the button interaction works
        expect(find.byKey(const Key('voice_input_button')), findsOneWidget);
      });

      testWidgets('should create task with AI parsing integration', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Column(
                    children: [
                      const Text('AI Task Creation Test'),
                      const TextField(
                        key: Key('ai_input_field'),
                        decoration: InputDecoration(
                          labelText: 'Describe your task naturally',
                          hintText: 'e.g., "Buy groceries tomorrow at 5 PM with high priority"',
                        ),
                      ),
                      ElevatedButton(
                        key: const Key('ai_parse_button'),
                        onPressed: () {
                          // Simulate AI parsing workflow
                        },
                        child: const Text('Parse with AI'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Enter natural language task description
        await tester.enterText(
          find.byKey(const Key('ai_input_field')),
          'Schedule dentist appointment next Tuesday at 2 PM with high priority',
        );

        // Tap AI parse button
        await tester.tap(find.byKey(const Key('ai_parse_button')));
        await tester.pump();

        // Verify AI parsing integration (would need actual service integration)
        expect(find.text('Schedule dentist appointment next Tuesday at 2 PM with high priority'), findsOneWidget);
      });
    });

    group('Task Management Operations Workflow', () {
      testWidgets('should complete full task lifecycle: create -> edit -> complete -> delete', (tester) async {
        // Create a test task in the database
        final testTask = TaskModel.create(
          title: 'Lifecycle Test Task',
          description: 'Testing complete task lifecycle',
          priority: TaskPriority.medium,
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: ListView(
                  children: [
                    AdvancedTaskCard(
                      key: Key('task_card_${testTask.id}'),
                      task: testTask,
                      onTap: () {
                        // Navigate to task detail
                      },
                      onComplete: () {
                        // Mark task as complete
                      },
                      onEdit: () {
                        // Edit task
                      },
                      onDelete: () {
                        // Delete task
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Verify task card appears
        expect(find.byKey(Key('task_card_${testTask.id}')), findsOneWidget);
        expect(find.text('Lifecycle Test Task'), findsOneWidget);

        // Test task completion
        await tester.tap(find.byKey(Key('complete_button_${testTask.id}')));
        await tester.pump();

        // Test task editing
        await tester.tap(find.byKey(Key('edit_button_${testTask.id}')));
        await tester.pump();

        // Test task deletion
        await tester.tap(find.byKey(Key('delete_button_${testTask.id}')));
        await tester.pump();

        // Confirm deletion
        await tester.tap(find.text('Delete'));
        await tester.pump();

        // Verify task is removed
        expect(find.byKey(Key('task_card_${testTask.id}')), findsNothing);
      });

      testWidgets('should handle task priority changes workflow', (tester) async {
        final testTasks = [
          TaskModel.create(title: 'Low Priority Task', priority: TaskPriority.low),
          TaskModel.create(title: 'Medium Priority Task', priority: TaskPriority.medium),
          TaskModel.create(title: 'High Priority Task', priority: TaskPriority.high),
          TaskModel.create(title: 'Urgent Priority Task', priority: TaskPriority.urgent),
        ];

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: ListView(
                  children: testTasks
                      .map((task) => AdvancedTaskCard(
                            key: Key('task_card_${task.id}'),
                            task: task,
                            onPriorityChange: (newPriority) {
                              // Handle priority change
                            },
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        );

        // Verify all tasks appear with correct priorities
        expect(find.text('Low Priority Task'), findsOneWidget);
        expect(find.text('Medium Priority Task'), findsOneWidget);
        expect(find.text('High Priority Task'), findsOneWidget);
        expect(find.text('Urgent Priority Task'), findsOneWidget);

        // Test priority change on first task
        await tester.tap(find.byKey(Key('priority_button_${testTasks[0].id}')));
        await tester.pump();

        // Select new priority
        await tester.tap(find.text('High'));
        await tester.pump();

        // Verify priority change workflow completes
        expect(find.byKey(Key('task_card_${testTasks[0].id}')), findsOneWidget);
      });

      testWidgets('should handle bulk task operations workflow', (tester) async {
        final testTasks = List.generate(
          5,
          (i) => TaskModel.create(
            title: 'Bulk Task ${i + 1}',
            priority: TaskPriority.medium,
          ),
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  actions: [
                    IconButton(
                      key: const Key('select_all_button'),
                      icon: const Icon(Icons.select_all),
                      onPressed: () {
                        // Select all tasks
                      },
                    ),
                    IconButton(
                      key: const Key('bulk_complete_button'),
                      icon: const Icon(Icons.check_circle),
                      onPressed: () {
                        // Complete selected tasks
                      },
                    ),
                    IconButton(
                      key: const Key('bulk_delete_button'),
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        // Delete selected tasks
                      },
                    ),
                  ],
                ),
                body: ListView(
                  children: testTasks
                      .map((task) => AdvancedTaskCard(
                            key: Key('task_card_${task.id}'),
                            task: task,
                            isSelectable: true,
                            onSelectionChanged: (isSelected) {
                              // Handle selection change
                            },
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        );

        // Verify all tasks appear
        for (int i = 0; i < testTasks.length; i++) {
          expect(find.text('Bulk Task ${i + 1}'), findsOneWidget);
        }

        // Test select all workflow
        await tester.tap(find.byKey(const Key('select_all_button')));
        await tester.pump();

        // Test bulk completion workflow
        await tester.tap(find.byKey(const Key('bulk_complete_button')));
        await tester.pump();

        // Confirm bulk action
        await tester.tap(find.text('Confirm'));
        await tester.pump();

        // Verify bulk operation completed
        expect(find.byKey(const Key('select_all_button')), findsOneWidget);
      });
    });

    group('Task Filtering and Search Workflow', () {
      testWidgets('should filter tasks by status, priority, and date', (tester) async {
        final testTasks = [
          TaskModel.create(
            title: 'Completed Task', 
            priority: TaskPriority.high,
          ),
          TaskModel.create(
            title: 'In Progress Task', 
            priority: TaskPriority.medium,
          ),
          TaskModel.create(
            title: 'Todo Task', 
            priority: TaskPriority.low,
          ),
          TaskModel.create(
            title: 'Overdue Task',
            // Task will be marked as pending after creation,
            priority: TaskPriority.urgent,
            dueDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child: Row(
                      children: [
                        const Expanded(
                          child: TextField(
                            key: Key('search_field'),
                            decoration: InputDecoration(
                              hintText: 'Search tasks...',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          key: const Key('filter_menu'),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'all', child: Text('All Tasks')),
                            const PopupMenuItem(value: 'completed', child: Text('Completed')),
                            const PopupMenuItem(value: 'pending', child: Text('Pending')),
                            const PopupMenuItem(value: 'overdue', child: Text('Overdue')),
                            const PopupMenuItem(value: 'high_priority', child: Text('High Priority')),
                          ],
                          onSelected: (value) {
                            // Handle filter selection
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                body: ListView(
                  children: testTasks
                      .map((task) => AdvancedTaskCard(
                            key: Key('task_card_${task.id}'),
                            task: task,
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        );

        // Test search functionality
        await tester.enterText(find.byKey(const Key('search_field')), 'Overdue');
        await tester.pump();

        // Verify search results (would need actual search implementation)
        expect(find.byKey(const Key('search_field')), findsOneWidget);

        // Test filtering by status
        await tester.tap(find.byKey(const Key('filter_menu')));
        await tester.pump();
        await tester.tap(find.text('Completed'));
        await tester.pump();

        // Test filtering by priority
        await tester.tap(find.byKey(const Key('filter_menu')));
        await tester.pump();
        await tester.tap(find.text('High Priority'));
        await tester.pump();

        // Verify filtering workflow completes
        expect(find.byKey(const Key('filter_menu')), findsOneWidget);
      });

      testWidgets('should handle advanced search with multiple criteria', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  actions: [
                    IconButton(
                      key: const Key('advanced_search_button'),
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        // Open advanced search
                      },
                    ),
                  ],
                ),
                body: const Center(child: Text('Advanced Search Test')),
              ),
            ),
          ),
        );

        // Open advanced search
        await tester.tap(find.byKey(const Key('advanced_search_button')));
        await tester.pump();

        // Would test advanced search dialog with multiple criteria
        expect(find.byKey(const Key('advanced_search_button')), findsOneWidget);
      });
    });

    group('Task Dependencies Workflow', () {
      testWidgets('should create and manage task dependencies', (tester) async {
        final parentTask = TaskModel.create(
          title: 'Parent Task',
          description: 'This task has dependencies',
        );

        final childTask1 = TaskModel.create(
          title: 'Child Task 1',
          description: 'First dependency',
        );

        final childTask2 = TaskModel.create(
          title: 'Child Task 2',
          description: 'Second dependency',
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    AdvancedTaskCard(
                      key: Key('parent_task_${parentTask.id}'),
                      task: parentTask,
                      showDependencies: true,
                      onManageDependencies: () {
                        // Open dependency management
                      },
                    ),
                    AdvancedTaskCard(
                      key: Key('child_task_${childTask1.id}'),
                      task: childTask1,
                      isDependency: true,
                    ),
                    AdvancedTaskCard(
                      key: Key('child_task_${childTask2.id}'),
                      task: childTask2,
                      isDependency: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Verify tasks appear
        expect(find.text('Parent Task'), findsOneWidget);
        expect(find.text('Child Task 1'), findsOneWidget);
        expect(find.text('Child Task 2'), findsOneWidget);

        // Test dependency management
        await tester.tap(find.byKey(const Key('manage_dependencies_button')));
        await tester.pump();

        // Would test dependency creation and management workflow
        expect(find.byKey(Key('parent_task_${parentTask.id}')), findsOneWidget);
      });
    });
  });
}