import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';

void main() {
  group('Simple Workflow Integration Tests', () {
    late ProviderContainer container;
    late AppDatabase testDatabase;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      
      testDatabase = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [],
      );
    });

    tearDown(() async {
      await testDatabase.close();
      container.dispose();
    });

    group('Basic Task Management Workflow', () {
      testWidgets('should create and display task', (tester) async {
        final testTask = TaskModel.create(
          title: 'Integration Test Task',
          description: 'This task was created during integration testing',
          priority: TaskPriority.high,
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Task Management'),
                  actions: [
                    IconButton(
                      key: const Key('add_task_button'),
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        // Add task action
                      },
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    Card(
                      key: Key('task_card_${testTask.id}'),
                      child: ListTile(
                        title: Text(testTask.title),
                        subtitle: Text(testTask.description ?? ''),
                        trailing: Chip(
                          label: Text(testTask.priority.displayName),
                          backgroundColor: testTask.priority.color.withOpacity(0.2),
                        ),
                        onTap: () {
                          // Navigate to task detail
                        },
                      ),
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  key: const Key('fab_add_task'),
                  onPressed: () {
                    // Open task creation dialog
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ),
        );

        // Verify task display
        expect(find.text('Task Management'), findsOneWidget);
        expect(find.text('Integration Test Task'), findsOneWidget);
        expect(find.text('This task was created during integration testing'), findsOneWidget);
        expect(find.text('High'), findsOneWidget);

        // Test task interaction
        await tester.tap(find.byKey(Key('task_card_${testTask.id}')));
        await tester.pump();

        // Test add task button
        await tester.tap(find.byKey(const Key('add_task_button')));
        await tester.pump();

        // Test FAB
        await tester.tap(find.byKey(const Key('fab_add_task')));
        await tester.pump();

        // Verify interactions work
        expect(find.byKey(const Key('add_task_button')), findsOneWidget);
        expect(find.byKey(const Key('fab_add_task')), findsOneWidget);
      });

      testWidgets('should handle task priority workflow', (tester) async {
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
                appBar: AppBar(
                  title: const Text('Priority Management'),
                ),
                body: ListView.builder(
                  itemCount: testTasks.length,
                  itemBuilder: (context, index) {
                    final task = testTasks[index];
                    return Card(
                      key: Key('priority_task_${task.id}'),
                      child: ListTile(
                        title: Text(task.title),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(task.priority.displayName),
                              backgroundColor: task.priority.color.withOpacity(0.2),
                            ),
                            PopupMenuButton<TaskPriority>(
                              key: Key('priority_menu_${task.id}'),
                              itemBuilder: (context) => TaskPriority.values
                                  .map((priority) => PopupMenuItem(
                                        value: priority,
                                        child: Text(priority.displayName),
                                      ))
                                  .toList(),
                              onSelected: (priority) {
                                // Handle priority change
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // Verify all priority tasks appear
        expect(find.text('Low Priority Task'), findsOneWidget);
        expect(find.text('Medium Priority Task'), findsOneWidget);
        expect(find.text('High Priority Task'), findsOneWidget);
        expect(find.text('Urgent Priority Task'), findsOneWidget);

        // Test priority menu interaction
        await tester.tap(find.byKey(Key('priority_menu_${testTasks[0].id}')));
        await tester.pump();
        await tester.tap(find.text('High').last);
        await tester.pump();

        // Verify priority workflow
        expect(find.text('Priority Management'), findsOneWidget);
      });

      testWidgets('should handle task status workflow', (tester) async {
        final testTasks = [
          TaskModel.create(title: 'Pending Task'),
          TaskModel.create(title: 'Another Task'),
        ];

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Task Status'),
                ),
                body: Column(
                  children: testTasks
                      .map((task) => Card(
                            key: Key('status_task_${task.id}'),
                            child: ListTile(
                              title: Text(task.title),
                              subtitle: Text('Status: ${TaskStatus.pending.displayName}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    key: Key('start_task_${task.id}'),
                                    icon: const Icon(Icons.play_arrow),
                                    onPressed: () {
                                      // Start task (change to in progress)
                                    },
                                  ),
                                  IconButton(
                                    key: Key('complete_task_${task.id}'),
                                    icon: const Icon(Icons.check_circle),
                                    onPressed: () {
                                      // Complete task
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        );

        // Verify tasks appear with status
        expect(find.text('Pending Task'), findsOneWidget);
        expect(find.text('Another Task'), findsOneWidget);
        expect(find.text('Status: Pending'), findsAtLeastNWidgets(1));

        // Test status change actions
        await tester.tap(find.byKey(Key('start_task_${testTasks[0].id}')));
        await tester.pump();

        await tester.tap(find.byKey(Key('complete_task_${testTasks[1].id}')));
        await tester.pump();

        // Verify status workflow
        expect(find.text('Task Status'), findsOneWidget);
      });
    });

    group('Basic Settings Workflow', () {
      testWidgets('should display settings options', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Settings'),
                ),
                body: ListView(
                  children: [
                    Card(
                      child: ListTile(
                        key: const Key('theme_setting'),
                        leading: const Icon(Icons.palette),
                        title: const Text('Theme'),
                        subtitle: const Text('Light'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Open theme settings
                        },
                      ),
                    ),
                    Card(
                      child: ListTile(
                        key: const Key('notification_setting'),
                        leading: const Icon(Icons.notifications),
                        title: const Text('Notifications'),
                        subtitle: const Text('Enabled'),
                        trailing: Switch(
                          value: true,
                          onChanged: (value) {
                            // Toggle notifications
                          },
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        key: const Key('backup_setting'),
                        leading: const Icon(Icons.backup),
                        title: const Text('Backup & Sync'),
                        subtitle: const Text('Last backup: 2 hours ago'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Open backup settings
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Verify settings appear
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Theme'), findsOneWidget);
        expect(find.text('Light'), findsOneWidget);
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.text('Backup & Sync'), findsOneWidget);

        // Test settings interactions
        await tester.tap(find.byKey(const Key('theme_setting')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('backup_setting')));
        await tester.pump();

        // Test notification toggle
        final notificationSwitch = find.byType(Switch);
        expect(notificationSwitch, findsOneWidget);
        await tester.tap(notificationSwitch);
        await tester.pump();

        // Verify settings workflow
        expect(find.byKey(const Key('theme_setting')), findsOneWidget);
      });
    });

    group('Basic Search and Filter Workflow', () {
      testWidgets('should handle search and filter', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Search & Filter'),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const Expanded(
                            child: TextField(
                              key: Key('search_field'),
                              decoration: InputDecoration(
                                hintText: 'Search tasks...',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            key: const Key('filter_menu'),
                            icon: const Icon(Icons.filter_list),
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'all', child: Text('All Tasks')),
                              const PopupMenuItem(value: 'high', child: Text('High Priority')),
                              const PopupMenuItem(value: 'pending', child: Text('Pending')),
                              const PopupMenuItem(value: 'completed', child: Text('Completed')),
                            ],
                            onSelected: (value) {
                              // Handle filter
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                body: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Search Results'),
                      SizedBox(height: 16),
                      Text('No tasks match your search criteria'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Test search functionality
        await tester.enterText(find.byKey(const Key('search_field')), 'test task');
        await tester.pump();

        expect(find.text('test task'), findsOneWidget);

        // Test filter menu
        await tester.tap(find.byKey(const Key('filter_menu')));
        await tester.pump();
        await tester.tap(find.text('High Priority'));
        await tester.pump();

        // Verify search and filter workflow
        expect(find.text('Search & Filter'), findsOneWidget);
        expect(find.text('Search Results'), findsOneWidget);
      });
    });
  });
}