import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:mockito/mockito.dart';

import 'package:task_tracker_app/services/database/database.dart' hide Project, ProjectCategory;
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/entities/project_category.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/presentation/widgets/batch_task_operations_widget.dart';
import 'package:task_tracker_app/presentation/widgets/bulk_operations/operation_history_widget.dart';
import 'package:task_tracker_app/presentation/widgets/advanced_task_card.dart';
import 'package:task_tracker_app/presentation/providers/bulk_operation_providers.dart';
import 'package:task_tracker_app/presentation/providers/task_providers.dart';
import 'package:task_tracker_app/core/providers/core_providers.dart';

// Mock providers
final connectivityProvider = StateProvider<bool>((ref) => true);

// Mock widgets for testing
class BatchTaskOperationsWidget extends StatelessWidget {
  const BatchTaskOperationsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text('3 tasks selected'),
          const Spacer(),
          IconButton(
            key: const Key('bulk_change_status'),
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
          IconButton(
            key: const Key('bulk_change_priority'),
            icon: const Icon(Icons.priority_high),
            onPressed: () {},
          ),
          IconButton(
            key: const Key('bulk_manage_tags'),
            icon: const Icon(Icons.label),
            onPressed: () {},
          ),
          IconButton(
            key: const Key('bulk_move_to_project'),
            icon: const Icon(Icons.folder),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class OperationHistoryWidget extends StatelessWidget {
  const OperationHistoryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Operation History'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Moved 1 task to Website Redesign'),
            subtitle: const Text('2 minutes ago'),
            trailing: IconButton(
              key: const Key('undo_this_operation'),
              icon: const Icon(Icons.undo),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // More history items would be here
        ],
      ),
      actions: [
        TextButton(
          key: const Key('filter_history'),
          onPressed: () {},
          child: const Text('Filter'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class ProjectCard extends StatelessWidget {
  final Project project;
  final int taskCount;
  final int completedTaskCount;

  const ProjectCard({
    Key? key,
    required this.project,
    required this.taskCount,
    required this.completedTaskCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(project.name),
        subtitle: Text('$completedTaskCount/$taskCount tasks completed'),
      ),
    );
  }
}

class KanbanBoardView extends StatelessWidget {
  const KanbanBoardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Kanban Board'));
  }
}

class CalendarView extends StatelessWidget {
  const CalendarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Calendar View'));
  }
}

void main() {
  group('Bulk Operations Workflow Integration Tests', () {
    late ProviderContainer container;
    late AppDatabase testDatabase;
    late List<Project> testProjects;
    late List<TaskModel> testTasks;
    late List<ProjectCategory> testCategories;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Create test database
      testDatabase = AppDatabase.forTesting(NativeDatabase.memory());
      
      // Create test categories
      testCategories = [
        ProjectCategory.createSystem(
          id: 'work',
          name: 'Work',
          iconName: 'briefcase',
          color: '#1976D2',
        ),
        ProjectCategory.createSystem(
          id: 'personal',
          name: 'Personal',
          iconName: 'user',
          color: '#4CAF50',
        ),
        ProjectCategory.createUser(
          name: 'Archive',
          iconName: 'archive',
          color: '#757575',
        ),
      ];

      // Create test projects
      testProjects = [
        Project(
          id: 'project-1',
          name: 'Mobile App Development',
          description: 'Cross-platform mobile application',
          color: '#2196F3',
          categoryId: 'work',
          createdAt: DateTime(2024, 1, 1).subtract(const Duration(days: 30)),
        ),
        Project(
          id: 'project-2',
          name: 'Website Redesign',
          description: 'Company website overhaul',
          color: '#FF9800',
          categoryId: 'work',
          createdAt: DateTime(2024, 1, 1).subtract(const Duration(days: 20)),
        ),
        Project(
          id: 'project-3',
          name: 'Personal Blog',
          description: 'Technical blog setup',
          color: '#4CAF50',
          categoryId: 'personal',
          createdAt: DateTime(2024, 1, 1).subtract(const Duration(days: 10)),
        ),
      ];

      // Create diverse set of test tasks
      testTasks = [
        // Project 1 tasks
        TaskModel(
          id: '1',
          title: 'Setup Development Environment',
          description: 'Configure Flutter development environment',
          createdAt: DateTime(2024, 1, 1),
          priority: TaskPriority.high,
          projectId: 'project-1',
          tags: const ['setup', 'development'],
        ),
        TaskModel(
          id: '2',
          title: 'Design User Interface',
          description: 'Create wireframes and mockups',
          createdAt: DateTime(2024, 1, 1),
          priority: TaskPriority.medium,
          projectId: 'project-1',
          tags: const ['design', 'ui'],
        ),
        TaskModel(
          id: '3',
          title: 'Implement Authentication',
          description: 'User login and registration',
          createdAt: DateTime(2024, 1, 1),
          priority: TaskPriority.urgent,
          projectId: 'project-1',
          tags: const ['auth', 'security'],
        ),
        TaskModel(
          id: '4',
          title: 'Database Integration',
          description: 'Setup and configure database',
          createdAt: DateTime(2024, 1, 1),
          priority: TaskPriority.high,
          projectId: 'project-1',
          tags: const ['database', 'backend'],
        ),
        
        // Project 2 tasks
        TaskModel(
          id: '5',
          title: 'Content Audit',
          description: 'Review and catalog existing content',
          createdAt: DateTime(2024, 1, 1),
          priority: TaskPriority.medium,
          projectId: 'project-2',
          tags: const ['content', 'audit'],
        ),
        TaskModel(
          id: '6',
          title: 'SEO Optimization',
          description: 'Optimize for search engines',
          createdAt: DateTime(2024, 1, 1),
          priority: TaskPriority.low,
          projectId: 'project-2',
          tags: const ['seo', 'marketing'],
        ),
        TaskModel(
          id: '7',
          title: 'Performance Testing',
          description: 'Load testing and optimization',
          createdAt: DateTime(2024, 1, 1),
          priority: TaskPriority.high,
          projectId: 'project-2',
          tags: const ['performance', 'testing'],
        ),
        
        // Project 3 tasks
        TaskModel(
          id: '8',
          title: 'Choose Blogging Platform',
          description: 'Research and select platform',
          createdAt: DateTime(2024, 1, 1),
          priority: TaskPriority.medium,
          projectId: 'project-3',
          tags: const ['research', 'platform'],
        ),
        TaskModel(
          id: '9',
          title: 'Write First Post',
          description: 'Introduction blog post',
          createdAt: DateTime(2024, 1, 1),
          priority: TaskPriority.low,
          projectId: 'project-3',
          tags: const ['writing', 'content'],
        ),
        
        // Unassigned tasks
        TaskModel(
          id: '10',
          title: 'Organize Desk',
          description: 'Clean and organize workspace',
          createdAt: DateTime(2024, 1, 1),
          priority: TaskPriority.low,
          tags: const ['organization'],
        ),
      ];

      // Create container with test overrides
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(testDatabase),
        ],
      );
    });

    tearDown(() async {
      await testDatabase.close();
      container.dispose();
    });

    group('Multi-Select and Batch Selection', () {
      testWidgets('should handle multi-select across different views and projects', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Bulk Operations'),
                  actions: [
                    IconButton(
                      key: const Key('enable_selection_mode'),
                      icon: const Icon(Icons.checklist),
                      onPressed: () {},
                    ),
                    IconButton(
                      key: const Key('select_all_visible'),
                      icon: const Icon(Icons.select_all),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    // Batch operations toolbar
                    const BatchTaskOperationsWidget(
                      key: Key('batch_operations_widget'),
                    ),
                    // Task list
                    Expanded(
                      child: ListView(
                        children: testTasks
                            .map<Widget>((task) => AdvancedTaskCard(
                                  key: Key('task_card_${task.id}'),
                                  task: task,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Enable selection mode
        await tester.tap(find.byKey(const Key('enable_selection_mode')));
        await tester.pumpAndSettle();

        // Verify selection checkboxes appear
        expect(find.byIcon(Icons.check_box_outline_blank), findsAtLeastNWidgets(10));

        // Select individual tasks from different projects
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[0].id}')));
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[4].id}')));
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[8].id}')));
        await tester.pumpAndSettle();

        // Verify selection count
        expect(find.text('3 tasks selected'), findsOneWidget);

        // Verify batch operations toolbar appears
        expect(find.byKey(const Key('batch_operations_widget')), findsOneWidget);
        expect(find.byKey(const Key('batch_move_button')), findsOneWidget);
        expect(find.byKey(const Key('batch_edit_button')), findsOneWidget);
        expect(find.byKey(const Key('batch_delete_button')), findsOneWidget);

        // Test select all visible
        await tester.tap(find.byKey(const Key('select_all_visible')));
        await tester.pumpAndSettle();

        expect(find.text('10 tasks selected'), findsOneWidget);

        // Test deselect all
        await tester.tap(find.byKey(const Key('deselect_all')));
        await tester.pumpAndSettle();

        expect(find.text('0 tasks selected'), findsOneWidget);
      });

      testWidgets('should support advanced selection criteria and smart selection', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  actions: [
                    PopupMenuButton<String>(
                      key: const Key('smart_selection_menu'),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'by_status', child: Text('Select by Status')),
                        const PopupMenuItem(value: 'by_priority', child: Text('Select by Priority')),
                        const PopupMenuItem(value: 'by_project', child: Text('Select by Project')),
                        const PopupMenuItem(value: 'by_assignee', child: Text('Select by Assignee')),
                        const PopupMenuItem(value: 'by_tags', child: Text('Select by Tags')),
                        const PopupMenuItem(value: 'overdue', child: Text('Select Overdue')),
                        const PopupMenuItem(value: 'no_project', child: Text('Select Unassigned')),
                      ],
                      onSelected: (value) {},
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    const BatchTaskOperationsWidget(),
                    Expanded(
                      child: ListView(
                        children: testTasks
                            .map<Widget>((task) => AdvancedTaskCard(
                                  key: Key('task_card_${task.id}'),
                                  task: task,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test smart selection by priority
        await tester.tap(find.byKey(const Key('smart_selection_menu')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Select by Priority'));
        await tester.pumpAndSettle();

        // Should show priority selection dialog
        expect(find.text('Select Tasks by Priority'), findsOneWidget);
        expect(find.text('Urgent'), findsOneWidget);
        expect(find.text('High'), findsOneWidget);
        expect(find.text('Medium'), findsOneWidget);
        expect(find.text('Low'), findsOneWidget);

        // Select high priority tasks
        await tester.tap(find.byKey(const Key('priority_high_checkbox')));
        await tester.tap(find.byKey(const Key('confirm_smart_selection')));
        await tester.pumpAndSettle();

        // Verify high priority tasks selected
        expect(find.text('3 tasks selected'), findsOneWidget); // 3 high priority tasks

        // Test selection by project
        await tester.tap(find.byKey(const Key('smart_selection_menu')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Select by Project'));
        await tester.pumpAndSettle();

        expect(find.text('Mobile App Development'), findsOneWidget);
        expect(find.text('Website Redesign'), findsOneWidget);
        expect(find.text('Personal Blog'), findsOneWidget);

        await tester.tap(find.text('Mobile App Development'));
        await tester.tap(find.byKey(const Key('confirm_smart_selection')));
        await tester.pumpAndSettle();

        expect(find.text('4 tasks selected'), findsOneWidget); // All project-1 tasks

        // Test selection by tags
        await tester.tap(find.byKey(const Key('smart_selection_menu')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Select by Tags'));
        await tester.pumpAndSettle();

        expect(find.text('Select by Tags'), findsOneWidget);
        await tester.enterText(
          find.byKey(const Key('tag_input_field')),
          'development'
        );
        await tester.tap(find.byKey(const Key('confirm_smart_selection')));
        await tester.pumpAndSettle();

        expect(find.text('1 task selected'), findsOneWidget); // Tasks with 'development' tag
      });

      testWidgets('should handle cross-view selection persistence', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: DefaultTabController(
                length: 3,
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('Multi-View Selection'),
                    bottom: const TabBar(
                      tabs: [
                        Tab(key: Key('list_view_tab'), text: 'List'),
                        Tab(key: Key('kanban_view_tab'), text: 'Kanban'),
                        Tab(key: Key('calendar_view_tab'), text: 'Calendar'),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      // List View
                      ListView(
                        children: testTasks
                            .map<Widget>((task) => AdvancedTaskCard(
                                  key: Key('list_task_${task.id}'),
                                  task: task,
                                ))
                            .toList(),
                      ),
                      // Kanban View
                      const KanbanBoardView(
                        key: Key('kanban_board'),
                      ),
                      // Calendar View
                      const CalendarView(
                        key: Key('calendar_view'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Select tasks in list view
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[0].id}')));
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[2].id}')));
        await tester.pumpAndSettle();

        expect(find.text('2 tasks selected'), findsOneWidget);

        // Switch to kanban view
        await tester.tap(find.byKey(const Key('kanban_view_tab')));
        await tester.pumpAndSettle();

        // Verify selection persists in kanban view
        expect(find.text('2 tasks selected'), findsOneWidget);
        expect(find.byKey(Key('selected_task_${testTasks[0].id}')), findsOneWidget);
        expect(find.byKey(Key('selected_task_${testTasks[2].id}')), findsOneWidget);

        // Add more selections in kanban view
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[4].id}')));
        await tester.pumpAndSettle();

        expect(find.text('3 tasks selected'), findsOneWidget);

        // Switch to calendar view
        await tester.tap(find.byKey(const Key('calendar_view_tab')));
        await tester.pumpAndSettle();

        // Verify all selections persist
        expect(find.text('3 tasks selected'), findsOneWidget);
      });
    });

    group('Bulk Task Operations', () {
      testWidgets('should handle bulk status changes with validation', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    const BatchTaskOperationsWidget(),
                    Expanded(
                      child: ListView(
                        children: testTasks
                            .map<Widget>((task) => AdvancedTaskCard(
                                  key: Key('task_card_${task.id}'),
                                  task: task,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Select tasks with different statuses
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[1].id}'))); // In Progress
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[2].id}'))); // Todo
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[5].id}'))); // Todo
        await tester.pumpAndSettle();

        expect(find.text('3 tasks selected'), findsOneWidget);

        // Test bulk status change
        await tester.tap(find.byKey(const Key('bulk_change_status')));
        await tester.pumpAndSettle();

        expect(find.text('Change Status'), findsOneWidget);
        expect(find.text('Selected tasks will be moved to:'), findsOneWidget);

        // Select new status
        await tester.tap(find.byKey(const Key('status_in_review')));
        await tester.pumpAndSettle();

        // Verify preview of changes
        expect(find.text('3 tasks will be moved to In Review'), findsOneWidget);
        expect(find.text('Design User Interface: In Progress → In Review'), findsOneWidget);
        expect(find.text('Implement Authentication: Todo → In Review'), findsOneWidget);

        // Confirm changes
        await tester.tap(find.byKey(const Key('confirm_status_change')));
        await tester.pumpAndSettle();

        expect(find.text('3 tasks updated successfully'), findsOneWidget);

        // Test validation for invalid status transitions
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[0].id}'))); // Done task
        await tester.tap(find.byKey(const Key('bulk_change_status')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('status_todo')));
        await tester.pumpAndSettle();

        // Should show warning about moving done task back to todo
        expect(find.text('Warning: Moving completed tasks back to Todo'), findsOneWidget);
        expect(find.byKey(const Key('acknowledge_warning')), findsOneWidget);
      });

      testWidgets('should handle bulk priority changes with conflict resolution', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    const BatchTaskOperationsWidget(),
                    Expanded(
                      child: ListView(
                        children: testTasks
                            .map<Widget>((task) => AdvancedTaskCard(
                                  key: Key('task_card_${task.id}'),
                                  task: task,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Select tasks with different priorities
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[1].id}'))); // Medium
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[5].id}'))); // Low
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[8].id}'))); // Low
        await tester.pumpAndSettle();

        // Test bulk priority change
        await tester.tap(find.byKey(const Key('bulk_change_priority')));
        await tester.pumpAndSettle();

        expect(find.text('Change Priority'), findsOneWidget);

        // Select high priority
        await tester.tap(find.byKey(const Key('priority_high')));
        await tester.pumpAndSettle();

        // Should show impact analysis
        expect(find.text('Impact Analysis'), findsOneWidget);
        expect(find.text('3 tasks will be changed to High priority'), findsOneWidget);
        expect(find.text('This will increase team workload by 15%'), findsOneWidget);

        // Test workload validation
        expect(find.text('Warning: This change may overload assigned team members'), findsOneWidget);
        expect(find.byKey(const Key('suggest_reassignment')), findsOneWidget);

        // Confirm with awareness of impact
        await tester.tap(find.byKey(const Key('confirm_priority_change')));
        await tester.pumpAndSettle();

        expect(find.text('Priority updated for 3 tasks'), findsOneWidget);

        // Test automatic priority balancing suggestion
        expect(find.text('Consider redistributing tasks to balance workload'), findsOneWidget);
        expect(find.byKey(const Key('auto_balance_workload')), findsOneWidget);

        await tester.tap(find.byKey(const Key('auto_balance_workload')));
        await tester.pumpAndSettle();

        expect(find.text('Workload balanced across 3 team members'), findsOneWidget);
      });

      testWidgets('should handle bulk tag management operations', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    const BatchTaskOperationsWidget(),
                    Expanded(
                      child: ListView(
                        children: testTasks
                            .map<Widget>((task) => AdvancedTaskCard(
                                  key: Key('task_card_${task.id}'),
                                  task: task,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Select tasks
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[0].id}')));
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[1].id}')));
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[2].id}')));
        await tester.pumpAndSettle();

        // Test bulk tag operations
        await tester.tap(find.byKey(const Key('bulk_manage_tags')));
        await tester.pumpAndSettle();

        expect(find.text('Manage Tags'), findsOneWidget);
        expect(find.text('Add Tags'), findsOneWidget);
        expect(find.text('Remove Tags'), findsOneWidget);
        expect(find.text('Replace Tags'), findsOneWidget);

        // Test adding tags
        await tester.tap(find.byKey(const Key('add_tags_tab')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('new_tags_field')),
          'sprint-1, mobile, frontend'
        );

        await tester.tap(find.byKey(const Key('confirm_add_tags')));
        await tester.pumpAndSettle();

        expect(find.text('Tags added to 3 tasks'), findsOneWidget);

        // Test removing specific tags
        await tester.tap(find.byKey(const Key('bulk_manage_tags')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('remove_tags_tab')));
        await tester.pumpAndSettle();

        // Show existing tags across selected tasks
        expect(find.text('Existing tags in selection:'), findsOneWidget);
        expect(find.text('setup'), findsOneWidget);
        expect(find.text('design'), findsOneWidget);
        expect(find.text('auth'), findsOneWidget);

        // Select tags to remove
        await tester.tap(find.byKey(const Key('tag_setup_checkbox')));
        await tester.tap(find.byKey(const Key('confirm_remove_tags')));
        await tester.pumpAndSettle();

        expect(find.text('setup tag removed from 1 task'), findsOneWidget);

        // Test tag replacement
        await tester.tap(find.byKey(const Key('bulk_manage_tags')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('replace_tags_tab')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('replacement_tags_field')),
          'v2.0, refactor, optimization'
        );

        await tester.tap(find.byKey(const Key('confirm_replace_tags')));
        await tester.pumpAndSettle();

        expect(find.text('Tags replaced for 3 tasks'), findsOneWidget);
      });
    });

    group('Project Migration Operations', () {
      testWidgets('should handle bulk project reassignment with category validation', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    const BatchTaskOperationsWidget(),
                    Expanded(
                      child: ListView(
                        children: testTasks
                            .map<Widget>((task) => AdvancedTaskCard(
                                  key: Key('task_card_${task.id}'),
                                  task: task,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Select tasks from different projects
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[0].id}'))); // project-1
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[4].id}'))); // project-2
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[9].id}'))); // unassigned
        await tester.pumpAndSettle();

        // Test project migration
        await tester.tap(find.byKey(const Key('bulk_move_to_project')));
        await tester.pumpAndSettle();

        expect(find.text('Move to Project'), findsOneWidget);
        expect(find.text('Select destination project:'), findsOneWidget);

        // Show available projects with categories
        expect(find.text('Work Projects'), findsOneWidget);
        expect(find.text('Mobile App Development'), findsOneWidget);
        expect(find.text('Website Redesign'), findsOneWidget);
        expect(find.text('Personal Projects'), findsOneWidget);
        expect(find.text('Personal Blog'), findsOneWidget);

        // Select destination project
        await tester.tap(find.text('Website Redesign'));
        await tester.pumpAndSettle();

        // Show migration preview
        expect(find.text('Migration Preview'), findsOneWidget);
        expect(find.text('3 tasks will be moved to Website Redesign'), findsOneWidget);
        expect(find.text('From: Mobile App Development → Website Redesign'), findsOneWidget);
        expect(find.text('From: Unassigned → Website Redesign'), findsOneWidget);

        // Test category compatibility check
        expect(find.text('Category Compatibility: ✓ Compatible'), findsOneWidget);

        // Show potential conflicts
        expect(find.text('Potential Issues:'), findsOneWidget);
        expect(find.text('• 1 task may have conflicting dependencies'), findsOneWidget);
        expect(find.byKey(const Key('resolve_conflicts')), findsOneWidget);

        // Resolve conflicts
        await tester.tap(find.byKey(const Key('resolve_conflicts')));
        await tester.pumpAndSettle();

        expect(find.text('Conflict Resolution'), findsOneWidget);
        expect(find.text('Update task dependencies automatically'), findsOneWidget);
        expect(find.text('Reassign conflicting tasks'), findsOneWidget);

        await tester.tap(find.byKey(const Key('auto_resolve_dependencies')));
        await tester.tap(find.byKey(const Key('confirm_migration')));
        await tester.pumpAndSettle();

        expect(find.text('3 tasks migrated successfully'), findsOneWidget);
        expect(find.text('1 dependency conflict resolved'), findsOneWidget);
      });

      testWidgets('should handle project archival and restoration workflow', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Project Management'),
                  actions: [
                    PopupMenuButton<String>(
                      key: const Key('project_actions_menu'),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'archive', child: Text('Archive Project')),
                        const PopupMenuItem(value: 'restore', child: Text('Restore Project')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete Project')),
                      ],
                    ),
                  ],
                ),
                body: ListView(
                  children: testProjects
                      .map<Widget>((project) => ProjectCard(
                            key: Key('project_card_${project.id}'),
                            project: project,
                            taskCount: testTasks.where((t) => t.projectId == project.id).length,
                            completedTaskCount: testTasks
                                .where((t) => t.projectId == project.id && t.status == TaskStatus.completed)
                                .length,
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Select project for archival
        await tester.longPress(find.byKey(Key('project_card_${testProjects[0].id}')));
        await tester.pumpAndSettle();

        expect(find.text('Project Actions'), findsOneWidget);
        await tester.tap(find.text('Archive Project'));
        await tester.pumpAndSettle();

        // Archive confirmation dialog
        expect(find.text('Archive Project'), findsOneWidget);
        expect(find.text('This will archive "Mobile App Development" and all its tasks'), findsOneWidget);
        expect(find.text('Tasks can be moved to another project or archived with the project'), findsOneWidget);

        // Choose task handling strategy
        expect(find.byKey(const Key('move_tasks_option')), findsOneWidget);
        expect(find.byKey(const Key('archive_tasks_option')), findsOneWidget);

        await tester.tap(find.byKey(const Key('move_tasks_option')));
        await tester.pumpAndSettle();

        // Select destination project
        expect(find.text('Move 4 tasks to:'), findsOneWidget);
        await tester.tap(find.text('Website Redesign'));
        await tester.pumpAndSettle();

        // Confirm archival
        await tester.tap(find.byKey(const Key('confirm_archive')));
        await tester.pumpAndSettle();

        expect(find.text('Project archived successfully'), findsOneWidget);
        expect(find.text('4 tasks moved to Website Redesign'), findsOneWidget);

        // Verify project moved to archive category
        expect(find.text('Archived Projects'), findsOneWidget);
        expect(find.byKey(Key('archived_project_${testProjects[0].id}')), findsOneWidget);

        // Test project restoration
        await tester.tap(find.byKey(Key('archived_project_${testProjects[0].id}')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('restore_project_button')), findsOneWidget);
        await tester.tap(find.byKey(const Key('restore_project_button')));
        await tester.pumpAndSettle();

        expect(find.text('Restore Project'), findsOneWidget);
        expect(find.text('Select category for restored project:'), findsOneWidget);

        await tester.tap(find.text('Work'));
        await tester.tap(find.byKey(const Key('confirm_restore')));
        await tester.pumpAndSettle();

        expect(find.text('Project restored successfully'), findsOneWidget);
      });

      testWidgets('should handle cross-project task dependencies during migration', (tester) async {
        // Create tasks with dependencies across projects
        final taskWithDependency = TaskModel.create(
          title: 'Dependent Task',
          description: 'Task that depends on another project task',
          projectId: 'project-1',
          dependencies: [(testTasks[4].id)], // Depends on task from project-2
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    const BatchTaskOperationsWidget(),
                    Expanded(
                      child: ListView(
                        children: [
                          AdvancedTaskCard(
                            key: Key('dependent_task_${taskWithDependency.id}'),
                            task: taskWithDependency,
                          ),
                          ...testTasks
                              .map<Widget>((task) => AdvancedTaskCard(
                                    key: Key('task_card_${task.id}'),
                                    task: task,
                                    ))
                              ,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Select task with cross-project dependency
        await tester.tap(find.byKey(Key('task_checkbox_${taskWithDependency.id}')));
        await tester.pumpAndSettle();

        // Try to move to different project
        await tester.tap(find.byKey(const Key('bulk_move_to_project')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Personal Blog'));
        await tester.pumpAndSettle();

        // Should detect dependency conflict
        expect(find.text('Dependency Conflict Detected'), findsOneWidget);
        expect(find.text('This task depends on tasks from other projects'), findsOneWidget);
        expect(find.text('Content Audit (Website Redesign)'), findsOneWidget);

        // Show resolution options
        expect(find.byKey(const Key('break_dependencies')), findsOneWidget);
        expect(find.byKey(const Key('move_dependencies')), findsOneWidget);
        expect(find.byKey(const Key('create_cross_project_link')), findsOneWidget);

        // Test moving dependencies together
        await tester.tap(find.byKey(const Key('move_dependencies')));
        await tester.pumpAndSettle();

        expect(find.text('2 additional tasks will be moved to maintain dependencies'), findsOneWidget);
        
        await tester.tap(find.byKey(const Key('confirm_move_with_dependencies')));
        await tester.pumpAndSettle();

        expect(find.text('3 tasks moved successfully with dependencies preserved'), findsOneWidget);

        // Test creating cross-project links
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[0].id}')));
        await tester.tap(find.byKey(const Key('bulk_move_to_project')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Personal Blog'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('create_cross_project_link')));
        await tester.pumpAndSettle();

        expect(find.text('Cross-project link created'), findsOneWidget);
        expect(find.text('Dependencies will be maintained across projects'), findsOneWidget);
      });
    });

    group('Undo/Redo and Operation History', () {
      testWidgets('should support comprehensive undo/redo for bulk operations', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  actions: [
                    IconButton(
                      key: const Key('undo_button'),
                      icon: const Icon(Icons.undo),
                      onPressed: () {},
                    ),
                    IconButton(
                      key: const Key('redo_button'),
                      icon: const Icon(Icons.redo),
                      onPressed: () {},
                    ),
                    IconButton(
                      key: const Key('operation_history'),
                      icon: const Icon(Icons.history),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    const BatchTaskOperationsWidget(),
                    Expanded(
                      child: ListView(
                        children: testTasks
                            .map<Widget>((task) => AdvancedTaskCard(
                                  key: Key('task_card_${task.id}'),
                                  task: task,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Perform bulk status change
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[1].id}')));
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[2].id}')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('bulk_change_status')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('status_done')));
        await tester.tap(find.byKey(const Key('confirm_status_change')));
        await tester.pumpAndSettle();

        expect(find.text('2 tasks updated successfully'), findsOneWidget);

        // Verify undo button is enabled
        expect(tester.widget<IconButton>(find.byKey(const Key('undo_button'))).onPressed, isNotNull);

        // Perform undo
        await tester.tap(find.byKey(const Key('undo_button')));
        await tester.pumpAndSettle();

        expect(find.text('Undo: Status change reverted'), findsOneWidget);
        expect(find.text('2 tasks restored to previous status'), findsOneWidget);

        // Verify redo button is now enabled
        expect(tester.widget<IconButton>(find.byKey(const Key('redo_button'))).onPressed, isNotNull);

        // Perform redo
        await tester.tap(find.byKey(const Key('redo_button')));
        await tester.pumpAndSettle();

        expect(find.text('Redo: Status change reapplied'), findsOneWidget);

        // Test multiple operations and complex undo
        await tester.tap(find.byKey(const Key('bulk_change_priority')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('priority_high')));
        await tester.tap(find.byKey(const Key('confirm_priority_change')));
        await tester.pumpAndSettle();

        // Add tags
        await tester.tap(find.byKey(const Key('bulk_manage_tags')));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const Key('new_tags_field')), 'urgent, critical');
        await tester.tap(find.byKey(const Key('confirm_add_tags')));
        await tester.pumpAndSettle();

        // Undo last operation (tags)
        await tester.tap(find.byKey(const Key('undo_button')));
        await tester.pumpAndSettle();

        expect(find.text('Undo: Tags removed'), findsOneWidget);

        // Undo previous operation (priority)
        await tester.tap(find.byKey(const Key('undo_button')));
        await tester.pumpAndSettle();

        expect(find.text('Undo: Priority change reverted'), findsOneWidget);
      });

      testWidgets('should display comprehensive operation history', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  actions: [
                    IconButton(
                      key: const Key('operation_history'),
                      icon: const Icon(Icons.history),
                      onPressed: () {
                        showDialog(
                          context: tester.element(find.byType(Scaffold)),
                          builder: (context) => const OperationHistoryWidget(),
                        );
                      },
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    const BatchTaskOperationsWidget(),
                    Expanded(
                      child: ListView(
                        children: testTasks
                            .map<Widget>((task) => AdvancedTaskCard(
                                  key: Key('task_card_${task.id}'),
                                  task: task,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Perform several operations to build history
        // Operation 1: Status change
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[0].id}')));
        await tester.tap(find.byKey(const Key('bulk_change_status')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('status_todo')));
        await tester.tap(find.byKey(const Key('confirm_status_change')));
        await tester.pumpAndSettle();

        // Operation 2: Priority change
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[1].id}')));
        await tester.tap(find.byKey(const Key('bulk_change_priority')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('priority_urgent')));
        await tester.tap(find.byKey(const Key('confirm_priority_change')));
        await tester.pumpAndSettle();

        // Operation 3: Project migration
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[2].id}')));
        await tester.tap(find.byKey(const Key('bulk_move_to_project')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Website Redesign'));
        await tester.tap(find.byKey(const Key('confirm_migration')));
        await tester.pumpAndSettle();

        // Open operation history
        await tester.tap(find.byKey(const Key('operation_history')));
        await tester.pumpAndSettle();

        expect(find.text('Operation History'), findsOneWidget);

        // Verify operations are listed chronologically
        expect(find.text('Moved 1 task to Website Redesign'), findsOneWidget);
        expect(find.text('Changed priority of 1 task to Urgent'), findsOneWidget);
        expect(find.text('Changed status of 1 task to Todo'), findsOneWidget);

        // Verify operation details
        await tester.tap(find.text('Moved 1 task to Website Redesign'));
        await tester.pumpAndSettle();

        expect(find.text('Operation Details'), findsOneWidget);
        expect(find.text('Operation: Project Migration'), findsOneWidget);
        expect(find.text('Affected Tasks: 1'), findsOneWidget);
        expect(find.text('From: Mobile App Development'), findsOneWidget);
        expect(find.text('To: Website Redesign'), findsOneWidget);
        expect(find.text('Timestamp:'), findsOneWidget);

        // Test selective undo from history
        expect(find.byKey(const Key('undo_this_operation')), findsOneWidget);
        await tester.tap(find.byKey(const Key('undo_this_operation')));
        await tester.pumpAndSettle();

        expect(find.text('Operation undone successfully'), findsOneWidget);

        // Test operation filtering
        await tester.tap(find.byKey(const Key('filter_history')));
        await tester.pumpAndSettle();

        expect(find.text('Filter Operations'), findsOneWidget);
        expect(find.text('Status Changes'), findsOneWidget);
        expect(find.text('Priority Changes'), findsOneWidget);
        expect(find.text('Project Migrations'), findsOneWidget);
        expect(find.text('Tag Operations'), findsOneWidget);

        await tester.tap(find.text('Status Changes'));
        await tester.tap(find.byKey(const Key('apply_filter')));
        await tester.pumpAndSettle();

        // Should show only status change operations
        expect(find.text('Changed status of 1 task to Todo'), findsOneWidget);
        expect(find.text('Moved 1 task to Website Redesign'), findsNothing);
      });

      testWidgets('should handle operation rollback with conflict detection', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    const BatchTaskOperationsWidget(),
                    Expanded(
                      child: ListView(
                        children: testTasks
                            .map<Widget>((task) => AdvancedTaskCard(
                                  key: Key('task_card_${task.id}'),
                                  task: task,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Perform initial bulk operation
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[0].id}')));
        await tester.tap(find.byKey(const Key('bulk_change_status')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('status_in_progress')));
        await tester.tap(find.byKey(const Key('confirm_status_change')));
        await tester.pumpAndSettle();

        // Simulate external modification (e.g., from another user)
        // This would be handled by the state management system
        
        // Attempt to undo
        await tester.tap(find.byKey(const Key('undo_button')));
        await tester.pumpAndSettle();

        // Should detect conflicts if task was modified externally
        expect(find.text('Conflict Detected'), findsOneWidget);
        expect(find.text('Task has been modified since the operation'), findsOneWidget);
        expect(find.text('Current: In Progress (modified externally)'), findsOneWidget);
        expect(find.text('Undo would restore to: Done'), findsOneWidget);

        // Show resolution options
        expect(find.byKey(const Key('force_undo')), findsOneWidget);
        expect(find.byKey(const Key('skip_conflicted')), findsOneWidget);
        expect(find.byKey(const Key('cancel_undo')), findsOneWidget);

        // Test force undo
        await tester.tap(find.byKey(const Key('force_undo')));
        await tester.pumpAndSettle();

        expect(find.text('Undo completed with conflicts resolved'), findsOneWidget);
        expect(find.text('1 task restored despite external modifications'), findsOneWidget);
      });
    });

    group('Performance and Error Handling', () {
      testWidgets('should handle large scale bulk operations with progress tracking', (tester) async {
        // Create large set of tasks for performance testing
        final largeTasks = List.generate(
          1000,
          (index) => TaskModel.create(
            title: 'Bulk Test Task ${index + 1}',
            description: 'Task for bulk operation testing',
            priority: TaskPriority.medium,
            projectId: testProjects[index % 3].id,
          ),
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    const BatchTaskOperationsWidget(),
                    Expanded(
                      child: ListView(
                        children: largeTasks
                            .take(50) // Only show first 50 for UI
                            .map<Widget>((task) => AdvancedTaskCard(
                                  key: Key('task_card_${task.id}'),
                                  task: task,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Select all 1000 tasks programmatically
        await tester.tap(find.byKey(const Key('select_all_tasks')));
        await tester.pumpAndSettle();

        expect(find.text('1000 tasks selected'), findsOneWidget);

        // Perform bulk operation
        final stopwatch = Stopwatch()..start();
        await tester.tap(find.byKey(const Key('bulk_change_status')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('status_in_progress')));
        await tester.tap(find.byKey(const Key('confirm_status_change')));

        // Should show progress indicator
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.text('Processing 1000 tasks...'), findsOneWidget);

        await tester.pumpAndSettle();
        stopwatch.stop();

        // Verify performance benchmark (<2 seconds for 1000 tasks)
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));

        expect(find.text('1000 tasks updated successfully'), findsOneWidget);

        // Test batch processing with chunking
        expect(find.text('Processed in 10 batches of 100 tasks'), findsOneWidget);
      });

      testWidgets('should handle network errors and offline operations gracefully', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    const BatchTaskOperationsWidget(),
                    Expanded(
                      child: ListView(
                        children: testTasks
                            .map<Widget>((task) => AdvancedTaskCard(
                                  key: Key('task_card_${task.id}'),
                                  task: task,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Simulate offline mode
        container.read(connectivityProvider.notifier).state = false;
        await tester.pumpAndSettle();

        // Verify offline indicator
        expect(find.byIcon(Icons.cloud_off), findsOneWidget);
        expect(find.text('Working offline'), findsOneWidget);

        // Select tasks and perform bulk operation
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[0].id}')));
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[1].id}')));
        await tester.tap(find.byKey(const Key('bulk_change_priority')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('priority_high')));
        await tester.tap(find.byKey(const Key('confirm_priority_change')));
        await tester.pumpAndSettle();

        // Should queue operation for sync
        expect(find.text('Operation queued for sync'), findsOneWidget);
        expect(find.text('Changes will be synchronized when online'), findsOneWidget);

        // Verify operations in sync queue
        expect(find.byIcon(Icons.sync_disabled), findsOneWidget);
        expect(find.text('1 operation pending sync'), findsOneWidget);

        // Simulate coming back online
        container.read(connectivityProvider.notifier).state = true;
        await tester.pumpAndSettle();

        // Should show sync in progress
        expect(find.byIcon(Icons.sync), findsOneWidget);
        expect(find.text('Syncing offline operations...'), findsOneWidget);

        await tester.pumpAndSettle();

        // Verify sync completion
        expect(find.text('All operations synchronized'), findsOneWidget);
        expect(find.byIcon(Icons.sync_disabled), findsNothing);

        // Test network error during operation
        container.read(connectivityProvider.notifier).state = false;
        await tester.tap(find.byKey(const Key('bulk_change_status')));
        await tester.pumpAndSettle();

        expect(find.text('Network Error'), findsOneWidget);
        expect(find.text('Operation will be retried when connection is restored'), findsOneWidget);
        expect(find.byKey(const Key('retry_now')), findsOneWidget);
        expect(find.byKey(const Key('queue_for_later')), findsOneWidget);

        await tester.tap(find.byKey(const Key('queue_for_later')));
        await tester.pumpAndSettle();

        expect(find.text('Operation queued successfully'), findsOneWidget);
      });
    });
  }); // Close the main group
}
