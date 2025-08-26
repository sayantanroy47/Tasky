import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:mockito/mockito.dart';

import 'package:task_tracker_app/services/database/database.dart' as db;
import 'package:task_tracker_app/domain/entities/project.dart' as entities;
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/presentation/widgets/kanban_board_view.dart';
import 'package:task_tracker_app/presentation/widgets/kanban_column.dart';
import 'package:task_tracker_app/presentation/widgets/advanced_task_card.dart';
import 'package:task_tracker_app/presentation/providers/kanban_providers.dart';
import 'package:task_tracker_app/presentation/providers/task_providers.dart';
import 'package:task_tracker_app/core/providers/core_providers.dart';

void main() {
  group('Kanban Board Workflow Integration Tests', () {
    late ProviderContainer container;
    late db.AppDatabase testDatabase;
    late entities.Project testProject;
    late List<TaskModel> testTasks;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Create test database
      testDatabase = db.AppDatabase.forTesting(NativeDatabase.memory());
      
      // Create test project
      testProject = entities.Project(
        id: 'kanban-test-project',
        name: 'Kanban Test Project',
        description: 'Project for testing Kanban board functionality',
        color: '#2196F3',
        createdAt: DateTime.now(),
      );

      // Create test tasks across different statuses
      testTasks = [
        TaskModel.create(
          title: 'Design Landing Page',
          description: 'Create wireframes and mockups for landing page',
          priority: TaskPriority.high,
          projectId: testProject.id,
        ),
        TaskModel.create(
          title: 'Implement Authentication',
          description: 'Set up user login and registration',
          priority: TaskPriority.urgent,
          projectId: testProject.id,
        ),
        TaskModel.create(
          title: 'Setup Database Schema',
          description: 'Design and implement database tables',
          priority: TaskPriority.medium,
          projectId: testProject.id,
        ),
        TaskModel.create(
          title: 'Write Unit Tests',
          description: 'Create comprehensive test coverage',
          priority: TaskPriority.medium,
          projectId: testProject.id,
        ),
        TaskModel.create(
          title: 'Deploy to Production',
          description: 'Setup CI/CD pipeline and deploy',
          priority: TaskPriority.low,
          projectId: testProject.id,
        ),
        TaskModel.create(
          title: 'Blocked Backend Task',
          description: 'Task waiting for external dependency',
          priority: TaskPriority.high,
          projectId: testProject.id,
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

    group('Complete Kanban Workflow', () {
      testWidgets('should display kanban board with all columns and tasks', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: Text(testProject.name),
                  actions: [
                    IconButton(
                      key: const Key('kanban_settings'),
                      icon: const Icon(Icons.settings),
                      onPressed: () {},
                    ),
                    IconButton(
                      key: const Key('kanban_filter'),
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: KanbanBoardView(
                  key: const Key('kanban_board'),
                  projectId: testProject.id,
                  showTaskCounts: true,
                  enableDragAndDrop: true,
                  showControls: true,
                  onTaskMoved: (task, newStatus) {
                    // Handle task movement
                  },
                  onTaskTapped: (task) {
                    // Handle task tap
                  },
                  onCreateTask: (status) {
                    // Handle create task
                  },
                ),
              ),
            ),
          ),
        );

        // Verify kanban board loads
        expect(find.byKey(const Key('kanban_board')), findsOneWidget);
        expect(find.text(testProject.name), findsOneWidget);

        // Verify all column headers appear
        expect(find.text('To Do (1)'), findsOneWidget);
        expect(find.text('In Progress (2)'), findsOneWidget);
        expect(find.text('In Review (1)'), findsOneWidget);
        expect(find.text('Done (1)'), findsOneWidget);
        expect(find.text('Blocked (1)'), findsOneWidget);

        // Verify tasks appear in correct columns
        expect(find.text('Design Landing Page'), findsOneWidget);
        expect(find.text('Implement Authentication'), findsOneWidget);
        expect(find.text('Setup Database Schema'), findsOneWidget);
        expect(find.text('Write Unit Tests'), findsOneWidget);
        expect(find.text('Deploy to Production'), findsOneWidget);
        expect(find.text('Blocked Backend Task'), findsOneWidget);

        // Verify task priorities are displayed
        expect(find.byIcon(Icons.priority_high), findsAtLeastNWidgets(2)); // High priority tasks
        expect(find.byIcon(Icons.error), findsOneWidget); // Urgent priority
        
        // Test horizontal scrolling for columns
        await tester.drag(find.byKey(const Key('kanban_board')), const Offset(-300, 0));
        await tester.pumpAndSettle();

        // Verify columns still visible after scroll
        expect(find.text('Blocked (1)'), findsOneWidget);
      });

      testWidgets('should handle drag and drop task movement between columns', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: KanbanBoardView(
                  key: const Key('kanban_board'),
                  projectId: testProject.id,
                  enableDragAndDrop: true,
                  onTaskMoved: (task, newStatus) {
                    // Track task movement
                    print('Task ${task.title} moved to $newStatus');
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find the task card in To Do column
        final todoTask = find.byKey(Key('task_card_${testTasks[0].id}'));
        expect(todoTask, findsOneWidget);

        // Find the In Progress column drop target
        final inProgressColumn = find.byKey(const Key('kanban_column_in_progress'));
        expect(inProgressColumn, findsOneWidget);

        // Perform drag and drop
        await tester.drag(todoTask, const Offset(200, 0));
        await tester.pumpAndSettle();

        // Verify task moved to In Progress column
        expect(find.text('To Do (0)'), findsOneWidget);
        expect(find.text('In Progress (3)'), findsOneWidget);

        // Test dragging task to Done column
        final taskInProgress = find.byKey(Key('task_card_${testTasks[0].id}'));
        final doneColumn = find.byKey(const Key('kanban_column_done'));

        await tester.drag(taskInProgress, const Offset(400, 0));
        await tester.pumpAndSettle();

        // Verify final position
        expect(find.text('In Progress (2)'), findsOneWidget);
        expect(find.text('Done (2)'), findsOneWidget);
      });

      testWidgets('should handle task creation directly in kanban columns', (tester) async {
        bool taskCreated = false;
        TaskStatus? createdInStatus;

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: KanbanBoardView(
                  key: const Key('kanban_board'),
                  projectId: testProject.id,
                  onCreateTask: (status) {
                    taskCreated = true;
                    createdInStatus = status;
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test quick task creation in To Do column
        await tester.tap(find.byKey(const Key('add_task_todo')));
        await tester.pumpAndSettle();

        // Verify quick creation dialog appears
        expect(find.text('Quick Add Task'), findsOneWidget);
        expect(find.byKey(const Key('quick_task_title_field')), findsOneWidget);

        // Fill in quick task
        await tester.enterText(
          find.byKey(const Key('quick_task_title_field')),
          'Quick Todo Task'
        );

        await tester.tap(find.byKey(const Key('save_quick_task')));
        await tester.pumpAndSettle();

        // Verify task creation callback was called
        expect(taskCreated, true);
        expect(createdInStatus, TaskStatus.pending);

        // Test detailed task creation in In Progress column
        await tester.longPress(find.byKey(const Key('add_task_in_progress')));
        await tester.pumpAndSettle();

        // Verify detailed creation dialog
        expect(find.text('Create Detailed Task'), findsOneWidget);
        expect(find.byKey(const Key('detailed_task_form')), findsOneWidget);

        await tester.enterText(
          find.byKey(const Key('task_title_field')),
          'Detailed In Progress Task'
        );
        await tester.enterText(
          find.byKey(const Key('task_description_field')),
          'Comprehensive task with full details'
        );

        // Set priority
        await tester.tap(find.byKey(const Key('priority_dropdown')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('High').last);
        await tester.pumpAndSettle();

        // Set due date
        await tester.tap(find.byKey(const Key('due_date_picker')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('15')); // Select 15th
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('save_detailed_task')));
        await tester.pumpAndSettle();

        expect(find.text('Task created successfully'), findsOneWidget);
      });

      testWidgets('should handle bulk task operations across kanban columns', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  actions: [
                    IconButton(
                      key: const Key('bulk_select_mode'),
                      icon: const Icon(Icons.checklist),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: KanbanBoardView(
                  key: const Key('kanban_board'),
                  projectId: testProject.id,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Enable bulk selection mode
        await tester.tap(find.byKey(const Key('bulk_select_mode')));
        await tester.pumpAndSettle();

        // Verify selection checkboxes appear on tasks
        expect(find.byIcon(Icons.check_box_outline_blank), findsAtLeastNWidgets(6));

        // Select multiple tasks across columns
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[0].id}')));
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[2].id}')));
        await tester.tap(find.byKey(Key('task_checkbox_${testTasks[3].id}')));
        await tester.pumpAndSettle();

        // Verify selection count
        expect(find.text('3 tasks selected'), findsOneWidget);

        // Verify bulk action toolbar appears
        expect(find.byKey(const Key('bulk_actions_toolbar')), findsOneWidget);
        expect(find.byKey(const Key('bulk_move_to')), findsOneWidget);
        expect(find.byKey(const Key('bulk_change_priority')), findsOneWidget);
        expect(find.byKey(const Key('bulk_assign')), findsOneWidget);
        expect(find.byKey(const Key('bulk_delete')), findsOneWidget);

        // Test bulk move operation
        await tester.tap(find.byKey(const Key('bulk_move_to')));
        await tester.pumpAndSettle();

        expect(find.text('Move 3 tasks to:'), findsOneWidget);
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();

        // Confirm bulk operation
        await tester.tap(find.byKey(const Key('confirm_bulk_move')));
        await tester.pumpAndSettle();

        // Verify tasks moved
        expect(find.text('Done (4)'), findsOneWidget);
        expect(find.text('3 tasks moved successfully'), findsOneWidget);

        // Exit bulk mode
        await tester.tap(find.byKey(const Key('exit_bulk_mode')));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check_box_outline_blank), findsNothing);
      });
    });

    group('Advanced Kanban Features', () {
      testWidgets('should handle custom column configuration and management', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: KanbanBoardView(
                  key: const Key('kanban_board'),
                  projectId: testProject.id,
                  initialColumns: [
                    KanbanColumnConfig(
                      title: 'Backlog',
                      color: Colors.grey[300]!,
                      maxTasks: 10,
                    ),
                    KanbanColumnConfig(
                      title: 'Active Sprint',
                      color: Colors.blue[300]!,
                      maxTasks: 3, // WIP limit
                    ),
                    KanbanColumnConfig(
                      title: 'Code Review',
                      color: Colors.orange[300]!,
                      maxTasks: 5,
                    ),
                    KanbanColumnConfig(
                      title: 'Completed',
                      color: Colors.green[300]!,
                      maxTasks: null, // No limit
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  key: const Key('customize_columns'),
                  onPressed: () {},
                  child: const Icon(Icons.view_column),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify custom column titles
        expect(find.text('Backlog'), findsOneWidget);
        expect(find.text('Active Sprint'), findsOneWidget);
        expect(find.text('Code Review'), findsOneWidget);
        expect(find.text('Completed'), findsOneWidget);

        // Test WIP limit enforcement
        final activeSprintColumn = find.byKey(const Key('kanban_column_in_progress'));
        
        // Try to add task to column at WIP limit
        await tester.tap(find.byKey(const Key('add_task_in_progress')));
        await tester.pumpAndSettle();

        // Should show WIP limit warning if at limit
        if (find.text('WIP Limit Reached (3/3)').evaluate().isNotEmpty) {
          expect(find.text('This column has reached its work-in-progress limit'), findsOneWidget);
          expect(find.byKey(const Key('override_wip_limit')), findsOneWidget);
          expect(find.byKey(const Key('move_task_first')), findsOneWidget);
        }

        // Test column customization
        await tester.tap(find.byKey(const Key('customize_columns')));
        await tester.pumpAndSettle();

        expect(find.text('Customize Kanban Columns'), findsOneWidget);

        // Add new custom column
        await tester.tap(find.byKey(const Key('add_custom_column')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('column_title_field')),
          'Testing'
        );
        
        await tester.tap(find.byKey(const Key('column_color_picker')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('color_purple')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('save_custom_column')));
        await tester.pumpAndSettle();

        // Verify new column appears
        expect(find.text('Testing'), findsOneWidget);
      });

      testWidgets('should handle real-time updates and collaborative features', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Kanban - Live Collaboration'),
                  actions: [
                    IconButton(
                      key: const Key('collaboration_status'),
                      icon: const Icon(Icons.people),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: KanbanBoardView(
                  key: const Key('kanban_board'),
                  projectId: testProject.id,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Simulate real-time task update from another user
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'task_update_channel',
          null,
          (data) {},
        );
        await tester.pumpAndSettle();

        // Verify real-time update notification
        expect(find.byIcon(Icons.sync), findsOneWidget);
        expect(find.text('Live updates enabled'), findsOneWidget);

        // Test collaborative cursor/selection indicators
        expect(find.byKey(const Key('user_cursor_john')), findsOneWidget);
        expect(find.text('John is editing'), findsOneWidget);

        // Test conflict resolution
        // Simulate concurrent edit conflict
        await tester.tap(find.byKey(Key('task_card_${testTasks[0].id}')));
        await tester.pumpAndSettle();

        // Should show conflict resolution dialog
        expect(find.text('Task Being Edited'), findsOneWidget);
        expect(find.text('Another user is currently editing this task'), findsOneWidget);
        expect(find.byKey(const Key('view_only_mode')), findsOneWidget);
        expect(find.byKey(const Key('request_edit_access')), findsOneWidget);

        // Request edit access
        await tester.tap(find.byKey(const Key('request_edit_access')));
        await tester.pumpAndSettle();

        expect(find.text('Edit request sent to John'), findsOneWidget);

        // Simulate permission granted
        await Future.delayed(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        expect(find.text('You now have edit access'), findsOneWidget);
      });

      testWidgets('should handle advanced filtering and search in kanban view', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const TextField(
                    key: Key('kanban_search_field'),
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                  ),
                  actions: [
                    IconButton(
                      key: const Key('advanced_filters'),
                      icon: const Icon(Icons.tune),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: KanbanBoardView(
                  key: const Key('kanban_board'),
                  projectId: testProject.id,
                  showControls: true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test basic search functionality
        await tester.enterText(
          find.byKey(const Key('kanban_search_field')),
          'authentication'
        );
        await tester.pumpAndSettle();

        // Verify filtered results
        expect(find.text('Implement Authentication'), findsOneWidget);
        expect(find.text('Design Landing Page'), findsNothing);

        // Clear search
        await tester.enterText(
          find.byKey(const Key('kanban_search_field')),
          ''
        );
        await tester.pumpAndSettle();

        // Test advanced filtering
        await tester.tap(find.byKey(const Key('advanced_filters')));
        await tester.pumpAndSettle();

        expect(find.text('Advanced Filters'), findsOneWidget);

        // Filter by priority
        await tester.tap(find.byKey(const Key('filter_priority')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('High'));
        await tester.pumpAndSettle();

        // Filter by assignee
        await tester.tap(find.byKey(const Key('filter_assignee')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('John Doe'));
        await tester.pumpAndSettle();

        // Filter by due date
        await tester.tap(find.byKey(const Key('filter_due_date')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('This Week'));
        await tester.pumpAndSettle();

        // Apply filters
        await tester.tap(find.byKey(const Key('apply_filters')));
        await tester.pumpAndSettle();

        // Verify filtered view
        expect(find.text('Filtered View (2 tasks)'), findsOneWidget);
        expect(find.byIcon(Icons.filter_list), findsOneWidget);

        // Test saved filter presets
        await tester.tap(find.byKey(const Key('filter_presets')));
        await tester.pumpAndSettle();

        expect(find.text('My Tasks'), findsOneWidget);
        expect(find.text('Urgent Items'), findsOneWidget);
        expect(find.text('This Week'), findsOneWidget);

        await tester.tap(find.text('Urgent Items'));
        await tester.pumpAndSettle();

        expect(find.text('Implement Authentication'), findsOneWidget); // Urgent task
      });

      testWidgets('should handle performance optimization with large task sets', (tester) async {
        // Create large set of tasks for performance testing
        final largeTasks = List.generate(
          1000,
          (index) => TaskModel.create(
            title: 'Performance Test Task ${index + 1}',
            description: 'Task for performance testing',
            priority: TaskPriority.values[index % TaskPriority.values.length],
            projectId: testProject.id,
          ),
        );

        final stopwatch = Stopwatch();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: KanbanBoardView(
                  key: const Key('kanban_board'),
                  projectId: testProject.id,
                  showTaskCounts: true,
                ),
              ),
            ),
          ),
        );

        // Measure initial load time
        stopwatch.start();
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Verify performance benchmark (<100ms for 1000 tasks)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));

        // Verify virtual scrolling is working (not all 1000 tasks rendered)
        final taskCards = find.byType(AdvancedTaskCard);
        expect(taskCards.evaluate().length, lessThan(50)); // Only visible tasks

        // Test scroll performance
        stopwatch.reset();
        stopwatch.start();
        
        await tester.drag(find.byKey(const Key('kanban_board')), const Offset(-500, 0));
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(50)); // Smooth scrolling

        // Test column switching performance
        stopwatch.reset();
        stopwatch.start();
        
        await tester.tap(find.byKey(const Key('switch_to_list_view')));
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Fast view switching
      });
    });

    group('Kanban Accessibility and Error Handling', () {
      testWidgets('should provide full accessibility support for kanban board', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: KanbanBoardView(
                  key: const Key('kanban_board'),
                  projectId: testProject.id,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify semantic labels for screen readers
        expect(find.bySemanticsLabel('Kanban board for ${testProject.name}'), findsOneWidget);
        expect(find.bySemanticsLabel('To Do column with 1 task'), findsOneWidget);
        expect(find.bySemanticsLabel('In Progress column with 2 tasks'), findsOneWidget);

        // Test keyboard navigation
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        // Verify focus moves between tasks
        expect(tester.binding.focusManager.primaryFocus?.debugLabel, contains('task'));

        // Test drag and drop accessibility
        await tester.sendKeyEvent(LogicalKeyboardKey.space); // Select task
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight); // Move to next column
        await tester.sendKeyEvent(LogicalKeyboardKey.space); // Drop task
        await tester.pumpAndSettle();

        // Verify task moved with keyboard
        expect(find.text('To Do (0)'), findsOneWidget);
        expect(find.text('In Progress (3)'), findsOneWidget);

        // Test high contrast mode support
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/accessibility',
          null,
          (data) {},
        );
        await tester.pumpAndSettle();

        // Verify high contrast colors applied
        expect(find.byKey(const Key('high_contrast_mode')), findsOneWidget);
      });

      testWidgets('should handle error conditions gracefully', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: KanbanBoardView(
                  key: const Key('kanban_board'),
                  projectId: 'non-existent-project', // Invalid project ID
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify error state handling
        expect(find.text('Project not found'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.byKey(const Key('retry_load_project')), findsOneWidget);

        // Test retry functionality
        await tester.tap(find.byKey(const Key('retry_load_project')));
        await tester.pumpAndSettle();

        // Test network error handling
        container.read(connectivityProvider.notifier).state = false;
        await tester.pumpAndSettle();

        expect(find.text('Working offline'), findsOneWidget);
        expect(find.byIcon(Icons.cloud_off), findsOneWidget);

        // Test task operation failure handling
        await tester.drag(
          find.byKey(Key('task_card_${testTasks[0].id}')),
          const Offset(200, 0),
        );
        await tester.pumpAndSettle();

        // Should show offline operation queued
        expect(find.text('Operation queued for sync'), findsOneWidget);

        // Test data corruption recovery
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'data_corruption_detected',
          null,
          (data) {},
        );
        await tester.pumpAndSettle();

        expect(find.text('Data sync required'), findsOneWidget);
        expect(find.byKey(const Key('force_sync_button')), findsOneWidget);

        await tester.tap(find.byKey(const Key('force_sync_button')));
        await tester.pumpAndSettle();

        expect(find.text('Data synchronized successfully'), findsOneWidget);
      });
    });
  });
}

// Mock classes and extensions for testing
class KanbanColumnConfig {
  final TaskStatus status;
  final String title;
  final Color color;
  final int? maxTasks;

  const KanbanColumnConfig({
    required this.status,
    required this.title,
    required this.color,
    this.maxTasks,
  });
}

// Mock providers
final connectivityProvider = StateProvider<bool>((ref) => true);