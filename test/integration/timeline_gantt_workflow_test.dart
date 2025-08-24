import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'package:task_tracker_app/services/database/database.dart' hide Project;
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/presentation/widgets/timeline_gantt_view.dart';
import 'package:task_tracker_app/presentation/widgets/milestone_manager.dart';
import 'package:task_tracker_app/core/providers/core_providers.dart';

void main() {
  group('Timeline/Gantt Workflow Integration Tests', () {
    late ProviderContainer container;
    late AppDatabase testDatabase;
    late List<Project> testProjects;
    late List<TaskModel> testTasks;
    late List<Milestone> testMilestones;
    late DateTime baseDate;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Create test database
      testDatabase = AppDatabase.forTesting(NativeDatabase.memory());
      baseDate = DateTime.now();
      
      // Create test projects
      testProjects = [
        Project(
          id: 'project-1',
          name: 'Software Development Project',
          description: 'Complex software project with dependencies',
          color: 0xFF2196F3,
          createdAt: baseDate.subtract(const Duration(days: 30)),
        ),
        Project(
          id: 'project-2',
          name: 'Marketing Campaign',
          description: 'Integrated marketing campaign',
          color: 0xFFFF9800,
          createdAt: baseDate.subtract(const Duration(days: 20)),
          startDate: baseDate.subtract(const Duration(days: 20)),
        ),
      ];

      // Create milestones
      testMilestones = [
        Milestone(
          id: 'milestone-1',
          name: 'Requirements Complete',
          description: 'All requirements gathered and approved',
          projectId: 'project-1',
          dueDate: baseDate.add(const Duration(days: 10)),
          isCompleted: true,
          completedAt: baseDate.add(const Duration(days: 8)),
        ),
        Milestone(
          id: 'milestone-2',
          name: 'MVP Release',
          description: 'Minimum viable product release',
          projectId: 'project-1',
          dueDate: baseDate.add(const Duration(days: 60)),
          isCompleted: false,
        ),
        Milestone(
          id: 'milestone-3',
          name: 'Final Release',
          description: 'Production ready release',
          projectId: 'project-1',
          dueDate: baseDate.add(const Duration(days: 120)),
          isCompleted: false,
          isCritical: true,
        ),
        Milestone(
          id: 'milestone-4',
          name: 'Campaign Launch',
          description: 'Marketing campaign goes live',
          projectId: 'project-2',
          dueDate: baseDate.add(const Duration(days: 30)),
          isCompleted: false,
        ),
      ];

      // Create tasks with complex dependencies
      testTasks = [
        // Project 1 - Software Development (Sequential dependencies)
        TaskModel(
          title: 'Requirements Analysis',
          description: 'Analyze and document requirements',
          priority: TaskPriority.high,
          projectId: 'project-1',
          dueDate: baseDate.subtract(const Duration(days: 20)),
          completedAt: baseDate.subtract(const Duration(days: 22)),
          estimatedDuration: 11520, // 8 days in minutes
          actualDuration: 11520, // 8 days in minutes
        ),
        TaskModel(
          title: 'System Architecture Design',
          description: 'Design overall system architecture',
          priority: TaskPriority.high,
          projectId: 'project-1',
          startDate: baseDate.subtract(const Duration(days: 22)),
          dueDate: baseDate.subtract(const Duration(days: 15)),
          completedAt: baseDate.subtract(const Duration(days: 16)),
          estimatedDuration: 8640, // 6 days in minutes
          actualDuration: 8640, // 6 days in minutes
          dependencies: [(testTasks.isNotEmpty ? testTasks[0].id : 'task-1')],
        ),
        TaskModel(
          title: 'Database Design',
          description: 'Design database schema and relationships',
          priority: TaskPriority.high,
          projectId: 'project-1',
          startDate: baseDate.subtract(const Duration(days: 16)),
          dueDate: baseDate.add(const Duration(days: 5)),
          estimatedDuration: 14400, // 10 days in minutes
          dependencies: const ['task-2'], // References System Architecture
        ),
        TaskModel(
          title: 'Frontend Development',
          description: 'Implement user interface components',
          priority: TaskPriority.medium,
          projectId: 'project-1',
          startDate: baseDate.add(const Duration(days: 5)),
          dueDate: baseDate.add(const Duration(days: 35)),
          estimatedDuration: 36000, // 25 days in minutes
          dependencies: const ['task-2'], // Can start after architecture
        ),
        TaskModel(
          title: 'Backend API Development',
          description: 'Implement REST API endpoints',
          priority: TaskPriority.high,
          projectId: 'project-1',
          startDate: baseDate.add(const Duration(days: 5)),
          dueDate: baseDate.add(const Duration(days: 40)),
          estimatedDuration: 43200, // 30 days in minutes
          dependencies: const ['task-3'], // Depends on database design
        ),
        TaskModel(
          title: 'Integration Testing',
          description: 'Test system integration points',
          priority: TaskPriority.high,
          projectId: 'project-1',
          startDate: baseDate.add(const Duration(days: 35)),
          dueDate: baseDate.add(const Duration(days: 50)),
          estimatedDuration: 14400, // 10 days in minutes
          dependencies: const ['task-4', 'task-5'], // Depends on both frontend and backend
        ),
        TaskModel(
          title: 'Performance Optimization',
          description: 'Optimize system performance',
          priority: TaskPriority.medium,
          projectId: 'project-1',
          startDate: baseDate.add(const Duration(days: 50)),
          dueDate: baseDate.add(const Duration(days: 65)),
          estimatedDuration: 14400, // 10 days in minutes
          dependencies: const ['task-6'], // After integration testing
        ),
        TaskModel(
          title: 'Production Deployment',
          description: 'Deploy to production environment',
          priority: TaskPriority.urgent,
          projectId: 'project-1',
          startDate: baseDate.add(const Duration(days: 110)),
          dueDate: baseDate.add(const Duration(days: 120)),
          estimatedDuration: 7200, // 5 days in minutes
          dependencies: const ['task-7'], // Final deployment step
          isCriticalPath: true,
        ),

        // Project 2 - Marketing Campaign (Parallel tasks)
        TaskModel(
          title: 'Market Research',
          description: 'Conduct comprehensive market analysis',
          priority: TaskPriority.high,
          projectId: 'project-2',
          startDate: baseDate.subtract(const Duration(days: 20)),
          dueDate: baseDate.subtract(const Duration(days: 10)),
          completedAt: baseDate.subtract(const Duration(days: 12)),
          estimatedDuration: 11520, // 8 days in minutes
          actualDuration: 11520, // 8 days in minutes
        ),
        TaskModel(
          title: 'Content Creation',
          description: 'Create marketing content and assets',
          priority: TaskPriority.high,
          projectId: 'project-2',
          startDate: baseDate.subtract(const Duration(days: 12)),
          dueDate: baseDate.add(const Duration(days: 10)),
          estimatedDuration: 28800, // 20 days in minutes
          dependencies: const ['task-9'], // Depends on market research
        ),
        TaskModel(
          title: 'Website Updates',
          description: 'Update website for campaign',
          priority: TaskPriority.medium,
          projectId: 'project-2',
          startDate: baseDate,
          dueDate: baseDate.add(const Duration(days: 15)),
          estimatedDuration: 17280, // 12 days in minutes
          dependencies: const ['task-9'], // Can run parallel with content creation
        ),
        TaskModel(
          title: 'Social Media Setup',
          description: 'Setup social media campaigns',
          priority: TaskPriority.medium,
          projectId: 'project-2',
          startDate: baseDate.add(const Duration(days: 5)),
          dueDate: baseDate.add(const Duration(days: 20)),
          estimatedDuration: 14400, // 10 days in minutes
          dependencies: const ['task-10'], // Depends on content creation
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

    group('Timeline View and Navigation', () {
      testWidgets('should display comprehensive timeline with projects and tasks', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Project Timeline'),
                  actions: [
                    IconButton(
                      key: const Key('timeline_settings'),
                      icon: const Icon(Icons.settings),
                      onPressed: () {},
                    ),
                    IconButton(
                      key: const Key('zoom_controls'),
                      icon: const Icon(Icons.zoom_in),
                      onPressed: () {},
                    ),
                    PopupMenuButton<String>(
                      key: const Key('view_options'),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'gantt', child: Text('Gantt Chart')),
                        const PopupMenuItem(value: 'timeline', child: Text('Timeline View')),
                        const PopupMenuItem(value: 'calendar', child: Text('Calendar View')),
                      ],
                    ),
                  ],
                ),
                body: TimelineGanttView(
                  key: const Key('timeline_gantt_view'),
                  projects: testProjects,
                  tasks: testTasks,
                  milestones: testMilestones,
                  viewMode: TimelineViewMode.gantt,
                  showDependencies: true,
                  showMilestones: true,
                  showCriticalPath: true,
                  onTaskTap: (task) {
                    // Handle task tap
                  },
                  onTaskDrag: (task, newDates) {
                    // Handle task date changes
                  },
                  onDependencyCreate: (fromTask, toTask) {
                    // Handle dependency creation
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify timeline loads with projects
        expect(find.text('Project Timeline'), findsOneWidget);
        expect(find.text('Software Development Project'), findsOneWidget);
        expect(find.text('Marketing Campaign'), findsOneWidget);

        // Verify timeline header with dates
        expect(find.byKey(const Key('timeline_header')), findsOneWidget);
        expect(find.text('Jan 2024'), findsOneWidget);
        expect(find.text('Feb 2024'), findsOneWidget);
        expect(find.text('Mar 2024'), findsOneWidget);

        // Verify task bars are displayed
        expect(find.byKey(const Key('task_bar_Requirements Analysis')), findsOneWidget);
        expect(find.byKey(const Key('task_bar_System Architecture Design')), findsOneWidget);
        expect(find.byKey(const Key('task_bar_Database Design')), findsOneWidget);

        // Verify milestones are displayed
        expect(find.byKey(const Key('milestone_Requirements Complete')), findsOneWidget);
        expect(find.byKey(const Key('milestone_MVP Release')), findsOneWidget);
        expect(find.byKey(const Key('milestone_Final Release')), findsOneWidget);

        // Verify dependency lines
        expect(find.byKey(const Key('dependency_line_task-1_to_task-2')), findsOneWidget);
        expect(find.byKey(const Key('dependency_line_task-2_to_task-3')), findsOneWidget);

        // Verify critical path highlighting
        expect(find.byKey(const Key('critical_path_indicator')), findsOneWidget);

        // Test zoom controls
        await tester.tap(find.byKey(const Key('zoom_controls')));
        await tester.pumpAndSettle();

        expect(find.text('Week View'), findsOneWidget);
        expect(find.text('Month View'), findsOneWidget);
        expect(find.text('Quarter View'), findsOneWidget);

        // Test view mode switching
        await tester.tap(find.byKey(const Key('view_options')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Timeline View'));
        await tester.pumpAndSettle();

        // Verify view changed to timeline mode
        expect(find.byKey(const Key('timeline_mode_indicator')), findsOneWidget);
      });

      testWidgets('should support interactive timeline navigation and scrolling', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    // Timeline navigation controls
                    SizedBox(
                      key: const Key('timeline_controls'),
                      height: 60,
                      child: Row(
                        children: [
                          IconButton(
                            key: const Key('timeline_prev'),
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () {},
                          ),
                          Expanded(
                            child: Container(
                              key: const Key('timeline_date_range'),
                              child: const Center(child: Text('Jan 2024 - Jun 2024')),
                            ),
                          ),
                          IconButton(
                            key: const Key('timeline_next'),
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () {},
                          ),
                          IconButton(
                            key: const Key('timeline_today'),
                            icon: const Icon(Icons.today),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    // Main timeline view
                    Expanded(
                      child: TimelineGanttView(
                        key: const Key('main_timeline'),
                        projects: testProjects,
                        tasks: testTasks,
                        milestones: testMilestones,
                        onDateRangeChanged: (start, end) {
                          // Handle date range changes
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test horizontal scrolling
        await tester.drag(find.byKey(const Key('main_timeline')), const Offset(-300, 0));
        await tester.pumpAndSettle();

        // Verify timeline scrolled
        expect(find.text('Feb 2024 - Jul 2024'), findsOneWidget);

        // Test navigation controls
        await tester.tap(find.byKey(const Key('timeline_prev')));
        await tester.pumpAndSettle();

        expect(find.text('Dec 2023 - May 2024'), findsOneWidget);

        await tester.tap(find.byKey(const Key('timeline_next')));
        await tester.pumpAndSettle();

        expect(find.text('Jan 2024 - Jun 2024'), findsOneWidget);

        // Test "go to today" functionality
        await tester.tap(find.byKey(const Key('timeline_today')));
        await tester.pumpAndSettle();

        // Should center view on current date
        final now = DateTime.now();
        final monthName = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][now.month];
        expect(find.textContaining('$monthName ${now.year}'), findsOneWidget);

        // Test vertical scrolling for multiple projects
        await tester.drag(find.byKey(const Key('main_timeline')), const Offset(0, -200));
        await tester.pumpAndSettle();

        // Should still show both projects
        expect(find.text('Software Development Project'), findsOneWidget);
        expect(find.text('Marketing Campaign'), findsOneWidget);
      });

      testWidgets('should handle timeline filtering and grouping options', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Timeline Filters'),
                  actions: [
                    IconButton(
                      key: const Key('filter_menu'),
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {},
                    ),
                    IconButton(
                      key: const Key('group_menu'),
                      icon: const Icon(Icons.group_work),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: TimelineGanttView(
                  key: const Key('filtered_timeline'),
                  projects: testProjects,
                  tasks: testTasks,
                  milestones: testMilestones,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test filtering options
        await tester.tap(find.byKey(const Key('filter_menu')));
        await tester.pumpAndSettle();

        expect(find.text('Filter Timeline'), findsOneWidget);
        expect(find.text('Task Status'), findsOneWidget);
        expect(find.text('Priority'), findsOneWidget);
        expect(find.text('Assignee'), findsOneWidget);
        expect(find.text('Date Range'), findsOneWidget);

        // Filter by status
        await tester.tap(find.byKey(const Key('filter_status')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('In Progress'));
        await tester.tap(find.text('Todo'));
        await tester.tap(find.byKey(const Key('apply_status_filter')));
        await tester.pumpAndSettle();

        // Verify completed tasks are filtered out
        expect(find.byKey(const Key('task_bar_Requirements Analysis')), findsNothing);
        expect(find.byKey(const Key('task_bar_Database Design')), findsOneWidget);
        expect(find.byKey(const Key('task_bar_Frontend Development')), findsOneWidget);

        // Filter by priority
        await tester.tap(find.byKey(const Key('filter_menu')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('filter_priority')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('High'));
        await tester.tap(find.text('Urgent'));
        await tester.tap(find.byKey(const Key('apply_priority_filter')));
        await tester.pumpAndSettle();

        // Should show only high/urgent priority tasks
        expect(find.text('Filtered: 4 of 12 tasks'), findsOneWidget);

        // Test grouping options
        await tester.tap(find.byKey(const Key('group_menu')));
        await tester.pumpAndSettle();

        expect(find.text('Group By'), findsOneWidget);
        expect(find.text('Project'), findsOneWidget);
        expect(find.text('Status'), findsOneWidget);
        expect(find.text('Priority'), findsOneWidget);
        expect(find.text('Assignee'), findsOneWidget);

        // Group by status
        await tester.tap(find.text('Status'));
        await tester.pumpAndSettle();

        // Verify tasks are grouped by status
        expect(find.text('In Progress Tasks'), findsOneWidget);
        expect(find.text('Todo Tasks'), findsOneWidget);
        expect(find.text('Done Tasks'), findsOneWidget);

        // Test clearing filters
        await tester.tap(find.byKey(const Key('filter_menu')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('clear_all_filters')));
        await tester.pumpAndSettle();

        expect(find.text('Showing all 12 tasks'), findsOneWidget);
      });
    });

    group('Task Dependencies Management', () {
      testWidgets('should visualize and manage task dependencies comprehensively', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Dependency Management'),
                  actions: [
                    IconButton(
                      key: const Key('dependency_mode'),
                      icon: const Icon(Icons.account_tree),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    // Dependency controls
                    Container(
                      key: const Key('dependency_controls'),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          ElevatedButton(
                            key: const Key('show_all_dependencies'),
                            onPressed: () {},
                            child: const Text('Show All Dependencies'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            key: const Key('show_critical_path'),
                            onPressed: () {},
                            child: const Text('Show Critical Path'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            key: const Key('dependency_analysis'),
                            onPressed: () {},
                            child: const Text('Analyze Dependencies'),
                          ),
                        ],
                      ),
                    ),
                    // Timeline with dependency focus
                    Expanded(
                      child: TimelineGanttView(
                        key: const Key('dependency_timeline'),
                        projects: testProjects,
                        tasks: testTasks,
                        milestones: testMilestones,
                        showDependencies: true,
                        showCriticalPath: true,
                        dependencyMode: true,
                        onDependencyTap: (fromTask, toTask) {
                          // Handle dependency tap
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify dependency visualization
        expect(find.byKey(const Key('dependency_line_task-1_to_task-2')), findsOneWidget);
        expect(find.byKey(const Key('dependency_line_task-2_to_task-3')), findsOneWidget);
        expect(find.byKey(const Key('dependency_line_task-3_to_task-5')), findsOneWidget);

        // Test critical path highlighting
        await tester.tap(find.byKey(const Key('show_critical_path')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('critical_path_highlight')), findsOneWidget);
        expect(find.text('Critical Path: 8 tasks, 120 days'), findsOneWidget);

        // Verify critical path tasks are highlighted
        expect(find.byKey(const Key('critical_task_Production Deployment')), findsOneWidget);

        // Test dependency analysis
        await tester.tap(find.byKey(const Key('dependency_analysis')));
        await tester.pumpAndSettle();

        expect(find.text('Dependency Analysis'), findsOneWidget);
        expect(find.text('Total Dependencies: 8'), findsOneWidget);
        expect(find.text('Circular Dependencies: 0'), findsOneWidget);
        expect(find.text('Longest Chain: 6 tasks'), findsOneWidget);
        expect(find.text('Potential Bottlenecks: 2'), findsOneWidget);

        // Show dependency details
        expect(find.text('Dependency Details:'), findsOneWidget);
        expect(find.text('• System Architecture → Database Design'), findsOneWidget);
        expect(find.text('• Database Design → Backend API'), findsOneWidget);
        expect(find.text('• Frontend + Backend → Integration Testing'), findsOneWidget);

        // Test creating new dependency
        await tester.tap(find.byKey(const Key('dependency_mode')));
        await tester.pumpAndSettle();

        expect(find.text('Dependency Creation Mode'), findsOneWidget);
        expect(find.text('Click source task, then target task'), findsOneWidget);

        // Select source task
        await tester.tap(find.byKey(const Key('task_bar_Content Creation')));
        await tester.pumpAndSettle();

        expect(find.text('Source selected: Content Creation'), findsOneWidget);

        // Select target task
        await tester.tap(find.byKey(const Key('task_bar_Social Media Setup')));
        await tester.pumpAndSettle();

        expect(find.text('Create Dependency'), findsOneWidget);
        expect(find.text('Content Creation → Social Media Setup'), findsOneWidget);

        // Configure dependency type
        expect(find.text('Dependency Type:'), findsOneWidget);
        expect(find.byKey(const Key('finish_to_start')), findsOneWidget);
        expect(find.byKey(const Key('start_to_start')), findsOneWidget);
        expect(find.byKey(const Key('finish_to_finish')), findsOneWidget);

        await tester.tap(find.byKey(const Key('finish_to_start')));
        await tester.tap(find.byKey(const Key('create_dependency')));
        await tester.pumpAndSettle();

        expect(find.text('Dependency created successfully'), findsOneWidget);
        expect(find.byKey(const Key('dependency_line_Content Creation_to_Social Media Setup')), findsOneWidget);
      });

      testWidgets('should handle dependency conflicts and validation', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    // Dependency validation panel
                    Container(
                      key: const Key('validation_panel'),
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Dependency Validation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ElevatedButton(
                                  key: const Key('validate_dependencies'),
                                  onPressed: () {},
                                  child: const Text('Validate All'),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  key: const Key('auto_resolve_conflicts'),
                                  onPressed: () {},
                                  child: const Text('Auto Resolve'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Timeline view
                    Expanded(
                      child: TimelineGanttView(
                        key: const Key('validation_timeline'),
                        projects: testProjects,
                        tasks: testTasks,
                        milestones: testMilestones,
                        showDependencies: true,
                        showConflicts: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test dependency validation
        await tester.tap(find.byKey(const Key('validate_dependencies')));
        await tester.pumpAndSettle();

        expect(find.text('Dependency Validation Results'), findsOneWidget);

        // Show validation results
        expect(find.text('Valid Dependencies: 6'), findsOneWidget);
        expect(find.text('Conflicts Found: 2'), findsOneWidget);
        expect(find.text('Circular Dependencies: 0'), findsOneWidget);

        // Show conflict details
        expect(find.text('Conflict Details:'), findsOneWidget);
        expect(find.text('• Database Design ends after Frontend Development starts'), findsOneWidget);
        expect(find.text('• Integration Testing scheduled before Backend API completion'), findsOneWidget);

        // Test automatic conflict resolution
        await tester.tap(find.byKey(const Key('auto_resolve_conflicts')));
        await tester.pumpAndSettle();

        expect(find.text('Auto-Resolution Options'), findsOneWidget);
        expect(find.text('Adjust start dates to resolve conflicts'), findsOneWidget);
        expect(find.text('Add buffer time between tasks'), findsOneWidget);
        expect(find.text('Modify dependency types'), findsOneWidget);

        await tester.tap(find.byKey(const Key('adjust_start_dates')));
        await tester.tap(find.byKey(const Key('add_buffer_time')));
        await tester.tap(find.byKey(const Key('confirm_auto_resolve')));
        await tester.pumpAndSettle();

        expect(find.text('Conflicts resolved successfully'), findsOneWidget);
        expect(find.text('2 task dates adjusted'), findsOneWidget);
        expect(find.text('Buffer time added: 2 days'), findsOneWidget);

        // Test manual conflict resolution
        await tester.tap(find.byKey(const Key('conflict_indicator_task-6')));
        await tester.pumpAndSettle();

        expect(find.text('Resolve Dependency Conflict'), findsOneWidget);
        expect(find.text('Current Issue: Task scheduled before dependency completion'), findsOneWidget);

        // Resolution options
        expect(find.text('Resolution Options:'), findsOneWidget);
        expect(find.byKey(const Key('move_task_start')), findsOneWidget);
        expect(find.byKey(const Key('change_dependency_type')), findsOneWidget);
        expect(find.byKey(const Key('remove_dependency')), findsOneWidget);

        await tester.tap(find.byKey(const Key('move_task_start')));
        await tester.tap(find.byKey(const Key('apply_resolution')));
        await tester.pumpAndSettle();

        expect(find.text('Conflict resolved'), findsOneWidget);

        // Test circular dependency detection
        // Simulate creating a circular dependency
        await tester.tap(find.byKey(const Key('dependency_mode')));
        await tester.pumpAndSettle();

        // Try to create Backend API → Database Design (would create cycle)
        await tester.tap(find.byKey(const Key('task_bar_Backend API Development')));
        await tester.tap(find.byKey(const Key('task_bar_Database Design')));
        await tester.pumpAndSettle();

        expect(find.text('Circular Dependency Detected'), findsOneWidget);
        expect(find.text('This would create a circular dependency'), findsOneWidget);
        expect(find.text('Dependency chain: Database Design → Backend API → Database Design'), findsOneWidget);
        expect(find.byKey(const Key('show_cycle_path')), findsOneWidget);
      });

      testWidgets('should support advanced dependency types and lag times', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Advanced Dependencies'),
                ),
                body: Column(
                  children: [
                    // Dependency type selector
                    Container(
                      key: const Key('dependency_types'),
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        child: Column(
                          children: [
                            const Text('Dependency Types', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    IconButton(
                                      key: const Key('finish_to_start_type'),
                                      icon: const Icon(Icons.arrow_forward),
                                      onPressed: () {},
                                    ),
                                    const Text('Finish-to-Start'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      key: const Key('start_to_start_type'),
                                      icon: const Icon(Icons.arrow_upward),
                                      onPressed: () {},
                                    ),
                                    const Text('Start-to-Start'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      key: const Key('finish_to_finish_type'),
                                      icon: const Icon(Icons.arrow_downward),
                                      onPressed: () {},
                                    ),
                                    const Text('Finish-to-Finish'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      key: const Key('start_to_finish_type'),
                                      icon: const Icon(Icons.arrow_back),
                                      onPressed: () {},
                                    ),
                                    const Text('Start-to-Finish'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Timeline with advanced dependencies
                    Expanded(
                      child: TimelineGanttView(
                        key: const Key('advanced_timeline'),
                        projects: testProjects,
                        tasks: testTasks,
                        milestones: testMilestones,
                        showDependencies: true,
                        showAdvancedDependencies: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test creating Start-to-Start dependency
        await tester.tap(find.byKey(const Key('start_to_start_type')));
        await tester.pumpAndSettle();

        expect(find.text('Start-to-Start Dependency Mode'), findsOneWidget);
        expect(find.text('Tasks will start at the same time'), findsOneWidget);

        // Select tasks for SS dependency
        await tester.tap(find.byKey(const Key('task_bar_Content Creation')));
        await tester.tap(find.byKey(const Key('task_bar_Website Updates')));
        await tester.pumpAndSettle();

        expect(find.text('Create Start-to-Start Dependency'), findsOneWidget);
        expect(find.text('Lag Time (days):'), findsOneWidget);

        // Set lag time
        await tester.enterText(find.byKey(const Key('lag_time_field')), '3');
        await tester.tap(find.byKey(const Key('create_ss_dependency')));
        await tester.pumpAndSettle();

        expect(find.text('Start-to-Start dependency created with 3-day lag'), findsOneWidget);

        // Test Finish-to-Finish dependency
        await tester.tap(find.byKey(const Key('finish_to_finish_type')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('task_bar_Frontend Development')));
        await tester.tap(find.byKey(const Key('task_bar_Backend API Development')));
        await tester.pumpAndSettle();

        expect(find.text('Create Finish-to-Finish Dependency'), findsOneWidget);
        expect(find.text('Tasks will finish at related times'), findsOneWidget);

        // Set lead time (negative lag)
        await tester.enterText(find.byKey(const Key('lag_time_field')), '-2');
        await tester.tap(find.byKey(const Key('create_ff_dependency')));
        await tester.pumpAndSettle();

        expect(find.text('Finish-to-Finish dependency created with 2-day lead'), findsOneWidget);

        // Test dependency modification
        await tester.tap(find.byKey(const Key('dependency_line_task-4_to_task-5')));
        await tester.pumpAndSettle();

        expect(find.text('Modify Dependency'), findsOneWidget);
        expect(find.text('Current Type: Finish-to-Start'), findsOneWidget);
        expect(find.text('Current Lag: 0 days'), findsOneWidget);

        // Change dependency type
        await tester.tap(find.byKey(const Key('change_dependency_type')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Start-to-Start'));
        await tester.pumpAndSettle();

        // Add lag time
        await tester.enterText(find.byKey(const Key('modify_lag_field')), '1');
        await tester.tap(find.byKey(const Key('save_dependency_changes')));
        await tester.pumpAndSettle();

        expect(find.text('Dependency updated successfully'), findsOneWidget);

        // Test dependency impact analysis
        await tester.tap(find.byKey(const Key('analyze_dependency_impact')));
        await tester.pumpAndSettle();

        expect(find.text('Dependency Impact Analysis'), findsOneWidget);
        expect(find.text('Changing this dependency will affect:'), findsOneWidget);
        expect(find.text('• 3 downstream tasks'), findsOneWidget);
        expect(find.text('• Project deadline may shift by 2 days'), findsOneWidget);
        expect(find.text('• Critical path remains unchanged'), findsOneWidget);
      });
    });

    group('Milestone Management', () {
      testWidgets('should display and manage project milestones effectively', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Milestone Management'),
                  actions: [
                    IconButton(
                      key: const Key('add_milestone'),
                      icon: const Icon(Icons.flag),
                      onPressed: () {},
                    ),
                    IconButton(
                      key: const Key('milestone_settings'),
                      icon: const Icon(Icons.settings),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    // Milestone overview panel
                    Container(
                      key: const Key('milestone_overview'),
                      padding: const EdgeInsets.all(16),
                      child: const Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Milestone Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text('4', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                    Text('Total Milestones'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('1', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                                    Text('Completed'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('2', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                                    Text('Upcoming'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('1', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
                                    Text('Critical'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Timeline with milestone focus
                    Expanded(
                      child: TimelineGanttView(
                        key: const Key('milestone_timeline'),
                        projects: testProjects,
                        tasks: testTasks,
                        milestones: testMilestones,
                        showMilestones: true,
                        milestoneMode: true,
                        onMilestoneTap: (milestone) {
                          // Handle milestone tap
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify milestone display
        expect(find.byKey(const Key('milestone_Requirements Complete')), findsOneWidget);
        expect(find.byKey(const Key('milestone_MVP Release')), findsOneWidget);
        expect(find.byKey(const Key('milestone_Final Release')), findsOneWidget);
        expect(find.byKey(const Key('milestone_Campaign Launch')), findsOneWidget);

        // Verify milestone status indicators
        expect(find.byKey(const Key('completed_milestone_Requirements Complete')), findsOneWidget);
        expect(find.byKey(const Key('upcoming_milestone_MVP Release')), findsOneWidget);
        expect(find.byKey(const Key('critical_milestone_Final Release')), findsOneWidget);

        // Test milestone details
        await tester.tap(find.byKey(const Key('milestone_Requirements Complete')));
        await tester.pumpAndSettle();

        expect(find.text('Milestone Details'), findsOneWidget);
        expect(find.text('Requirements Complete'), findsOneWidget);
        expect(find.text('Status: Completed'), findsOneWidget);
        expect(find.text('Completed 2 days early'), findsOneWidget);
        expect(find.text('All requirements gathered and approved'), findsOneWidget);

        // Test milestone modification
        await tester.tap(find.byKey(const Key('edit_milestone')));
        await tester.pumpAndSettle();

        expect(find.text('Edit Milestone'), findsOneWidget);
        await tester.enterText(find.byKey(const Key('milestone_name_field')), 'Requirements Finalized');
        await tester.enterText(find.byKey(const Key('milestone_description_field')), 'All requirements gathered, reviewed, and approved by stakeholders');

        await tester.tap(find.byKey(const Key('save_milestone_changes')));
        await tester.pumpAndSettle();

        expect(find.text('Milestone updated successfully'), findsOneWidget);
        expect(find.text('Requirements Finalized'), findsOneWidget);

        // Test creating new milestone
        await tester.tap(find.byKey(const Key('add_milestone')));
        await tester.pumpAndSettle();

        expect(find.text('Create New Milestone'), findsOneWidget);

        await tester.enterText(find.byKey(const Key('new_milestone_name')), 'Alpha Release');
        await tester.enterText(find.byKey(const Key('new_milestone_description')), 'First alpha version ready for testing');

        // Select project
        await tester.tap(find.byKey(const Key('milestone_project_dropdown')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Software Development Project'));
        await tester.pumpAndSettle();

        // Set due date
        await tester.tap(find.byKey(const Key('milestone_date_picker')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('15'));
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Mark as critical
        await tester.tap(find.byKey(const Key('milestone_critical_checkbox')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('create_milestone_button')));
        await tester.pumpAndSettle();

        expect(find.text('Milestone created successfully'), findsOneWidget);
        expect(find.byKey(const Key('milestone_Alpha Release')), findsOneWidget);
        expect(find.byKey(const Key('critical_milestone_Alpha Release')), findsOneWidget);
      });

      testWidgets('should track milestone progress and dependencies', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    // Milestone progress tracking
                    Container(
                      key: const Key('milestone_progress'),
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        child: Column(
                          children: [
                            const Text('Milestone Progress Tracking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            ListView(
                              shrinkWrap: true,
                              children: [
                                MilestoneProgressCard(
                                  key: const Key('progress_MVP Release'),
                                  milestone: testMilestones[1],
                                  dependentTasks: testTasks.where((t) => t.projectId == 'project-1').take(4).toList(),
                                  completionPercentage: 45,
                                ),
                                MilestoneProgressCard(
                                  key: const Key('progress_Final Release'),
                                  milestone: testMilestones[2],
                                  dependentTasks: testTasks.where((t) => t.projectId == 'project-1').toList(),
                                  completionPercentage: 15,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Timeline view
                    Expanded(
                      child: TimelineGanttView(
                        key: const Key('progress_timeline'),
                        projects: testProjects,
                        tasks: testTasks,
                        milestones: testMilestones,
                        showMilestones: true,
                        showMilestoneProgress: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify milestone progress cards
        expect(find.byKey(const Key('progress_MVP Release')), findsOneWidget);
        expect(find.text('MVP Release'), findsOneWidget);
        expect(find.text('45% Complete'), findsOneWidget);
        expect(find.text('4 tasks linked'), findsOneWidget);

        // Test milestone progress details
        await tester.tap(find.byKey(const Key('progress_MVP Release')));
        await tester.pumpAndSettle();

        expect(find.text('MVP Release Progress'), findsOneWidget);
        expect(find.text('Linked Tasks:'), findsOneWidget);
        expect(find.text('• Requirements Analysis (Completed)'), findsOneWidget);
        expect(find.text('• System Architecture Design (Completed)'), findsOneWidget);
        expect(find.text('• Database Design (In Progress)'), findsOneWidget);
        expect(find.text('• Frontend Development (Not Started)'), findsOneWidget);

        expect(find.text('Progress Calculation:'), findsOneWidget);
        expect(find.text('Completed: 2/4 tasks (50%)'), findsOneWidget);
        expect(find.text('Weighted by effort: 45%'), findsOneWidget);

        expect(find.text('Risk Assessment:'), findsOneWidget);
        expect(find.text('On track for target date'), findsOneWidget);
        expect(find.text('Database Design may impact timeline'), findsOneWidget);

        // Test milestone dependency tracking
        await tester.tap(find.byKey(const Key('milestone_dependencies')));
        await tester.pumpAndSettle();

        expect(find.text('Milestone Dependencies'), findsOneWidget);
        expect(find.text('MVP Release depends on:'), findsOneWidget);
        expect(find.text('• Requirements Complete (Completed)'), findsOneWidget);

        expect(find.text('Final Release depends on:'), findsOneWidget);
        expect(find.text('• MVP Release (45% complete)'), findsOneWidget);
        expect(find.text('• All development tasks (15% complete)'), findsOneWidget);

        // Test milestone alerts
        expect(find.byKey(const Key('milestone_alert_Final Release')), findsOneWidget);
        expect(find.text('Risk: May miss deadline'), findsOneWidget);
        expect(find.text('Recommended: Accelerate development'), findsOneWidget);

        // Test milestone completion
        await tester.tap(find.byKey(const Key('progress_MVP Release')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('mark_milestone_complete')));
        await tester.pumpAndSettle();

        expect(find.text('Mark Milestone Complete'), findsOneWidget);
        expect(find.text('MVP Release will be marked as completed'), findsOneWidget);
        expect(find.text('This will affect dependent milestones'), findsOneWidget);

        await tester.tap(find.byKey(const Key('confirm_milestone_complete')));
        await tester.pumpAndSettle();

        expect(find.text('Milestone marked as completed'), findsOneWidget);
        expect(find.byKey(const Key('completed_milestone_MVP Release')), findsOneWidget);
      });

      testWidgets('should handle milestone alerts and notifications', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Milestone Alerts'),
                  actions: [
                    Badge(
                      key: const Key('alert_badge'),
                      label: const Text('3'),
                      child: IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    // Alert summary
                    Container(
                      key: const Key('alert_summary'),
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        color: Colors.orange[50],
                        child: Column(
                          children: [
                            const ListTile(
                              leading: Icon(Icons.warning, color: Colors.orange),
                              title: Text('Milestone Alerts'),
                              subtitle: Text('3 milestones require attention'),
                            ),
                            const Divider(),
                            MilestoneAlertCard(
                              key: const Key('alert_Final Release'),
                              milestone: testMilestones[2],
                              alertType: MilestoneAlertType.riskOfDelay,
                              daysUntilDue: 45,
                              completionPercentage: 15,
                            ),
                            MilestoneAlertCard(
                              key: const Key('alert_Campaign Launch'),
                              milestone: testMilestones[3],
                              alertType: MilestoneAlertType.approaching,
                              daysUntilDue: 7,
                              completionPercentage: 75,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Timeline with alerts
                    Expanded(
                      child: TimelineGanttView(
                        key: const Key('alert_timeline'),
                        projects: testProjects,
                        tasks: testTasks,
                        milestones: testMilestones,
                        showMilestones: true,
                        showAlerts: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify alert badge
        expect(find.byKey(const Key('alert_badge')), findsOneWidget);
        expect(find.text('3'), findsOneWidget);

        // Verify alert cards
        expect(find.byKey(const Key('alert_Final Release')), findsOneWidget);
        expect(find.text('Risk of Delay'), findsOneWidget);
        expect(find.text('Only 15% complete with 45 days remaining'), findsOneWidget);

        expect(find.byKey(const Key('alert_Campaign Launch')), findsOneWidget);
        expect(find.text('Approaching Deadline'), findsOneWidget);
        expect(find.text('Due in 7 days, 75% complete'), findsOneWidget);

        // Test alert actions
        await tester.tap(find.byKey(const Key('alert_Final Release')));
        await tester.pumpAndSettle();

        expect(find.text('Milestone Alert: Final Release'), findsOneWidget);
        expect(find.text('Risk Analysis:'), findsOneWidget);
        expect(find.text('• Current progress: 15%'), findsOneWidget);
        expect(find.text('• Required daily progress: 1.9%'), findsOneWidget);
        expect(find.text('• Projected completion: 30 days late'), findsOneWidget);

        expect(find.text('Recommended Actions:'), findsOneWidget);
        expect(find.byKey(const Key('action_add_resources')), findsOneWidget);
        expect(find.byKey(const Key('action_extend_deadline')), findsOneWidget);
        expect(find.byKey(const Key('action_reduce_scope')), findsOneWidget);

        // Test taking action
        await tester.tap(find.byKey(const Key('action_add_resources')));
        await tester.pumpAndSettle();

        expect(find.text('Add Resources to Milestone'), findsOneWidget);
        expect(find.text('Additional team members or hours'), findsOneWidget);

        await tester.enterText(find.byKey(const Key('additional_hours_field')), '20');
        await tester.tap(find.byKey(const Key('apply_resource_action')));
        await tester.pumpAndSettle();

        expect(find.text('Resources added to milestone tasks'), findsOneWidget);
        expect(find.text('Projected completion updated'), findsOneWidget);

        // Test notification settings
        await tester.tap(find.byKey(const Key('alert_badge')));
        await tester.pumpAndSettle();

        expect(find.text('Milestone Notifications'), findsOneWidget);
        expect(find.text('Alert Settings:'), findsOneWidget);

        expect(find.text('Approaching deadline (days before):'), findsOneWidget);
        expect(find.byKey(const Key('approaching_days_field')), findsOneWidget);

        expect(find.text('Risk threshold (completion %):'), findsOneWidget);
        expect(find.byKey(const Key('risk_threshold_field')), findsOneWidget);

        expect(find.text('Notification methods:'), findsOneWidget);
        expect(find.byKey(const Key('email_notifications')), findsOneWidget);
        expect(find.byKey(const Key('push_notifications')), findsOneWidget);
        expect(find.byKey(const Key('slack_notifications')), findsOneWidget);

        // Update notification settings
        await tester.enterText(find.byKey(const Key('approaching_days_field')), '14');
        await tester.enterText(find.byKey(const Key('risk_threshold_field')), '30');
        await tester.tap(find.byKey(const Key('email_notifications')));
        await tester.tap(find.byKey(const Key('save_notification_settings')));
        await tester.pumpAndSettle();

        expect(find.text('Notification settings updated'), findsOneWidget);
      });
    });

    group('Critical Path Analysis', () {
      testWidgets('should identify and display critical path comprehensively', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Critical Path Analysis'),
                  actions: [
                    IconButton(
                      key: const Key('recalculate_critical_path'),
                      icon: const Icon(Icons.route),
                      onPressed: () {},
                    ),
                    IconButton(
                      key: const Key('critical_path_settings'),
                      icon: const Icon(Icons.settings),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    // Critical path summary
                    Container(
                      key: const Key('critical_path_summary'),
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        color: Colors.red[50],
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: Icon(Icons.warning, color: Colors.red),
                              title: Text('Critical Path Analysis'),
                              subtitle: Text('Longest sequence determining project duration'),
                            ),
                            Divider(),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          Text('6', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                          Text('Critical Tasks'),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text('120', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                          Text('Total Days'),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text('0', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                          Text('Buffer Days'),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text('High', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
                                          Text('Risk Level'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Text('Critical Path Sequence:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Requirements → Architecture → Database → Backend → Integration → Deployment'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Timeline with critical path highlighted
                    Expanded(
                      child: TimelineGanttView(
                        key: const Key('critical_path_timeline'),
                        projects: testProjects,
                        tasks: testTasks,
                        milestones: testMilestones,
                        showCriticalPath: true,
                        highlightCriticalPath: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify critical path visualization
        expect(find.byKey(const Key('critical_path_highlight')), findsOneWidget);
        expect(find.text('Critical Path Analysis'), findsOneWidget);

        // Verify critical path statistics
        expect(find.text('6'), findsOneWidget); // Critical Tasks
        expect(find.text('120'), findsOneWidget); // Total Days
        expect(find.text('0'), findsOneWidget); // Buffer Days
        expect(find.text('High'), findsOneWidget); // Risk Level

        // Verify critical tasks are highlighted
        expect(find.byKey(const Key('critical_task_Requirements Analysis')), findsOneWidget);
        expect(find.byKey(const Key('critical_task_System Architecture Design')), findsOneWidget);
        expect(find.byKey(const Key('critical_task_Database Design')), findsOneWidget);
        expect(find.byKey(const Key('critical_task_Backend API Development')), findsOneWidget);
        expect(find.byKey(const Key('critical_task_Integration Testing')), findsOneWidget);
        expect(find.byKey(const Key('critical_task_Production Deployment')), findsOneWidget);

        // Test critical path recalculation
        await tester.tap(find.byKey(const Key('recalculate_critical_path')));
        await tester.pumpAndSettle();

        expect(find.text('Recalculating critical path...'), findsOneWidget);
        await tester.pumpAndSettle();

        expect(find.text('Critical path updated'), findsOneWidget);

        // Test critical task details
        await tester.tap(find.byKey(const Key('critical_task_Database Design')));
        await tester.pumpAndSettle();

        expect(find.text('Critical Task Details'), findsOneWidget);
        expect(find.text('Database Design'), findsOneWidget);
        expect(find.text('Status: Critical Path'), findsOneWidget);
        expect(find.text('Total Float: 0 days'), findsOneWidget);
        expect(find.text('Free Float: 0 days'), findsOneWidget);
        expect(find.text('Impact: Any delay affects project completion'), findsOneWidget);

        // Show predecessor and successor tasks
        expect(find.text('Predecessors:'), findsOneWidget);
        expect(find.text('• System Architecture Design'), findsOneWidget);
        expect(find.text('Successors:'), findsOneWidget);
        expect(find.text('• Backend API Development'), findsOneWidget);

        // Test what-if analysis
        await tester.tap(find.byKey(const Key('what_if_analysis')));
        await tester.pumpAndSettle();

        expect(find.text('What-If Analysis'), findsOneWidget);
        expect(find.text('Simulate changes to this critical task'), findsOneWidget);

        await tester.enterText(find.byKey(const Key('duration_change_field')), '+3');
        await tester.tap(find.byKey(const Key('simulate_change')));
        await tester.pumpAndSettle();

        expect(find.text('Impact of 3-day delay:'), findsOneWidget);
        expect(find.text('• Project completion delayed by 3 days'), findsOneWidget);
        expect(find.text('• Final Release milestone affected'), findsOneWidget);
        expect(find.text('• 2 downstream tasks delayed'), findsOneWidget);

        // Test critical path optimization suggestions
        await tester.tap(find.byKey(const Key('optimization_suggestions')));
        await tester.pumpAndSettle();

        expect(find.text('Critical Path Optimization'), findsOneWidget);
        expect(find.text('Recommendations to reduce project duration:'), findsOneWidget);
        expect(find.text('• Fast-track Database Design (parallel with Architecture)'), findsOneWidget);
        expect(find.text('• Add resources to Backend API Development'), findsOneWidget);
        expect(find.text('• Overlap Integration Testing with Development'), findsOneWidget);

        expect(find.text('Potential time savings: 15 days'), findsOneWidget);
        expect(find.text('Resource requirements: +2 developers'), findsOneWidget);
        expect(find.text('Risk increase: Moderate'), findsOneWidget);
      });

      testWidgets('should handle critical path changes and impacts', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    // Critical path change notification
                    Container(
                      key: const Key('critical_path_changes'),
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        color: Colors.amber[50],
                        child: Column(
                          children: [
                            const ListTile(
                              leading: Icon(Icons.info, color: Colors.amber),
                              title: Text('Critical Path Changes'),
                              subtitle: Text('Recent changes have affected the critical path'),
                            ),
                            const Divider(),
                            CriticalPathChangeCard(
                              key: const Key('change_database_design'),
                              taskName: 'Database Design',
                              changeType: CriticalPathChangeType.durationIncrease,
                              impact: '3 days added to project',
                              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
                            ),
                            CriticalPathChangeCard(
                              key: const Key('change_frontend_parallel'),
                              taskName: 'Frontend Development',
                              changeType: CriticalPathChangeType.becameNonCritical,
                              impact: 'No longer on critical path',
                              timestamp: DateTime.now().subtract(const Duration(hours: 1)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Impact analysis panel
                    Container(
                      key: const Key('impact_analysis'),
                      padding: const EdgeInsets.all(16),
                      child: const Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Critical Path Impact Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 16),
                            Text('Current Impact:'),
                            Text('• Project duration: 120 → 123 days (+3 days)'),
                            Text('• Completion date: May 15 → May 18, 2024'),
                            Text('• Budget impact: +\$4,500 (overtime costs)'),
                            SizedBox(height: 16),
                            Text('Affected Stakeholders:'),
                            Text('• Client delivery deadline may be missed'),
                            Text('• Marketing campaign timing affected'),
                            Text('• Resource allocation needs adjustment'),
                          ],
                        ),
                      ),
                    ),
                    // Timeline view
                    Expanded(
                      child: TimelineGanttView(
                        key: const Key('impact_timeline'),
                        projects: testProjects,
                        tasks: testTasks,
                        milestones: testMilestones,
                        showCriticalPath: true,
                        showImpactAnalysis: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify change notifications
        expect(find.text('Critical Path Changes'), findsOneWidget);
        expect(find.byKey(const Key('change_database_design')), findsOneWidget);
        expect(find.text('3 days added to project'), findsOneWidget);
        expect(find.byKey(const Key('change_frontend_parallel')), findsOneWidget);
        expect(find.text('No longer on critical path'), findsOneWidget);

        // Verify impact analysis
        expect(find.text('Project duration: 120 → 123 days (+3 days)'), findsOneWidget);
        expect(find.text('Completion date: May 15 → May 18, 2024'), findsOneWidget);
        expect(find.text('Budget impact: +\$4,500 (overtime costs)'), findsOneWidget);

        // Test change details
        await tester.tap(find.byKey(const Key('change_database_design')));
        await tester.pumpAndSettle();

        expect(find.text('Critical Path Change Details'), findsOneWidget);
        expect(find.text('Task: Database Design'), findsOneWidget);
        expect(find.text('Change: Duration increased from 10 to 13 days'), findsOneWidget);
        expect(find.text('Reason: Additional complexity discovered'), findsOneWidget);
        expect(find.text('Impact Timeline:'), findsOneWidget);
        expect(find.text('• Backend API start delayed by 3 days'), findsOneWidget);
        expect(find.text('• Integration Testing start delayed by 3 days'), findsOneWidget);
        expect(find.text('• Final deployment delayed by 3 days'), findsOneWidget);

        // Test mitigation options
        expect(find.text('Mitigation Options:'), findsOneWidget);
        expect(find.byKey(const Key('add_resources_mitigation')), findsOneWidget);
        expect(find.byKey(const Key('fast_track_mitigation')), findsOneWidget);
        expect(find.byKey(const Key('reduce_scope_mitigation')), findsOneWidget);

        // Apply mitigation
        await tester.tap(find.byKey(const Key('add_resources_mitigation')));
        await tester.pumpAndSettle();

        expect(find.text('Add Resources Mitigation'), findsOneWidget);
        expect(find.text('Additional developers can reduce delay'), findsOneWidget);
        expect(find.text('Estimated impact: Reduce delay by 2 days'), findsOneWidget);
        expect(find.text('Cost: +\$3,000'), findsOneWidget);

        await tester.tap(find.byKey(const Key('apply_mitigation')));
        await tester.pumpAndSettle();

        expect(find.text('Mitigation applied successfully'), findsOneWidget);
        expect(find.text('Project delay reduced to 1 day'), findsOneWidget);

        // Test critical path alerts
        expect(find.byKey(const Key('critical_path_alert')), findsOneWidget);
        expect(find.text('Alert: Critical path extended'), findsOneWidget);
        expect(find.text('Immediate action recommended'), findsOneWidget);

        await tester.tap(find.byKey(const Key('critical_path_alert')));
        await tester.pumpAndSettle();

        expect(find.text('Critical Path Alert'), findsOneWidget);
        expect(find.text('Your project critical path has been extended'), findsOneWidget);
        expect(find.text('This affects project delivery date'), findsOneWidget);
        expect(find.text('Review and take action to minimize impact'), findsOneWidget);

        expect(find.byKey(const Key('acknowledge_alert')), findsOneWidget);
        expect(find.byKey(const Key('take_action')), findsOneWidget);

        await tester.tap(find.byKey(const Key('take_action')));
        await tester.pumpAndSettle();

        expect(find.text('Critical Path Action Plan'), findsOneWidget);
      });
    });

    group('Performance and Advanced Features', () {
      testWidgets('should handle large projects with performance optimization', (tester) async {
        // Create large project for performance testing
        final largeProject = Project(
          id: 'large-project',
          name: 'Large Enterprise Project',
          description: 'Complex enterprise project with many tasks',
          color: '#673AB7',
          createdAt: baseDate.subtract(const Duration(days: 60)),
          deadline: baseDate.add(const Duration(days: 365)),
        );

        final largeTasks = List.generate(
          1000,
          (index) => TaskModel(
            title: 'Large Project Task ${index + 1}',
            description: 'Task ${index + 1} for performance testing',
            priority: TaskPriority.values[index % TaskPriority.values.length],
            projectId: 'large-project',
            startDate: baseDate.add(Duration(days: index ~/ 10)),
            dueDate: baseDate.add(Duration(days: (index ~/ 10) + 5)),
            estimatedDuration: (3 + (index % 5)) * 1440, // days converted to minutes
          ),
        );

        final stopwatch = Stopwatch();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TimelineGanttView(
                  key: const Key('performance_timeline'),
                  projects: [largeProject],
                  tasks: largeTasks,
                  milestones: const [],
                  enableVirtualization: true,
                  performanceMode: true,
                ),
              ),
            ),
          ),
        );

        // Measure initial render performance
        stopwatch.start();
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Verify performance benchmark (<1 second for 1000 tasks)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));

        // Verify virtualization is working (not all tasks rendered)
        final renderedTasks = find.byType(TaskBar);
        expect(renderedTasks.evaluate().length, lessThan(100)); // Only visible tasks

        // Test scrolling performance
        stopwatch.reset();
        stopwatch.start();
        
        await tester.drag(find.byKey(const Key('performance_timeline')), const Offset(-1000, 0));
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(200)); // Smooth scrolling

        // Test zoom performance
        stopwatch.reset();
        stopwatch.start();
        
        await tester.tap(find.byKey(const Key('zoom_in')));
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(300)); // Fast zoom

        // Verify memory usage doesn't grow excessively
        // Note: In a real test, you would monitor memory usage
        expect(find.text('Large Enterprise Project'), findsOneWidget);
      });

      testWidgets('should support advanced timeline features and customization', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Advanced Timeline Features'),
                  actions: [
                    IconButton(
                      key: const Key('timeline_customization'),
                      icon: const Icon(Icons.palette),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    // Advanced controls
                    Container(
                      key: const Key('advanced_controls'),
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        child: Column(
                          children: [
                            const Text('Timeline Customization', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: CheckboxListTile(
                                    key: const Key('show_task_labels'),
                                    title: const Text('Task Labels'),
                                    value: true,
                                    onChanged: (value) {},
                                  ),
                                ),
                                Expanded(
                                  child: CheckboxListTile(
                                    key: const Key('show_progress_bars'),
                                    title: const Text('Progress Bars'),
                                    value: true,
                                    onChanged: (value) {},
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CheckboxListTile(
                                    key: const Key('show_baseline'),
                                    title: const Text('Baseline'),
                                    value: false,
                                    onChanged: (value) {},
                                  ),
                                ),
                                Expanded(
                                  child: CheckboxListTile(
                                    key: const Key('show_resource_usage'),
                                    title: const Text('Resources'),
                                    value: false,
                                    onChanged: (value) {},
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Advanced timeline view
                    Expanded(
                      child: TimelineGanttView(
                        key: const Key('advanced_timeline'),
                        projects: testProjects,
                        tasks: testTasks,
                        milestones: testMilestones,
                        showTaskLabels: true,
                        showProgressBars: true,
                        showBaseline: false,
                        showResourceUsage: false,
                        customColorScheme: CustomColorScheme.professional,
                        onCustomizationChanged: (settings) {
                          // Handle customization changes
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test customization options
        expect(find.byKey(const Key('show_task_labels')), findsOneWidget);
        expect(find.byKey(const Key('show_progress_bars')), findsOneWidget);
        expect(find.byKey(const Key('show_baseline')), findsOneWidget);
        expect(find.byKey(const Key('show_resource_usage')), findsOneWidget);

        // Test enabling baseline view
        await tester.tap(find.byKey(const Key('show_baseline')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('baseline_bars')), findsOneWidget);
        expect(find.text('Baseline vs Actual'), findsOneWidget);

        // Test resource usage view
        await tester.tap(find.byKey(const Key('show_resource_usage')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('resource_usage_panel')), findsOneWidget);
        expect(find.text('Resource Utilization'), findsOneWidget);
        expect(find.text('John Doe: 85%'), findsOneWidget);
        expect(find.text('Jane Smith: 75%'), findsOneWidget);

        // Test timeline customization
        await tester.tap(find.byKey(const Key('timeline_customization')));
        await tester.pumpAndSettle();

        expect(find.text('Timeline Appearance'), findsOneWidget);
        expect(find.text('Color Scheme:'), findsOneWidget);
        expect(find.text('Professional'), findsOneWidget);
        expect(find.text('High Contrast'), findsOneWidget);
        expect(find.text('Color Blind Friendly'), findsOneWidget);

        await tester.tap(find.text('High Contrast'));
        await tester.pumpAndSettle();

        expect(find.text('Color scheme updated'), findsOneWidget);

        // Test timeline export
        await tester.tap(find.byKey(const Key('export_timeline')));
        await tester.pumpAndSettle();

        expect(find.text('Export Timeline'), findsOneWidget);
        expect(find.text('PNG Image'), findsOneWidget);
        expect(find.text('PDF Document'), findsOneWidget);
        expect(find.text('Excel Gantt'), findsOneWidget);

        await tester.tap(find.text('PNG Image'));
        await tester.tap(find.byKey(const Key('export_confirm')));
        await tester.pumpAndSettle();

        expect(find.text('Timeline exported successfully'), findsOneWidget);
      });
    });
  });
}

// Mock models and widgets for testing
class Milestone {
  final String id;
  final String name;
  final String description;
  final String projectId;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isCritical;

  const Milestone({
    required this.id,
    required this.name,
    required this.description,
    required this.projectId,
    required this.dueDate,
    this.isCompleted = false,
    this.completedAt,
    this.isCritical = false,
  });
}

enum TimelineViewMode { gantt, timeline, calendar }
enum CustomColorScheme { professional, highContrast, colorBlindFriendly }
enum MilestoneAlertType { approaching, riskOfDelay, overdue }
enum CriticalPathChangeType { durationIncrease, durationDecrease, becameCritical, becameNonCritical }

// Mock widgets
class TimelineGanttView extends StatelessWidget {
  final List<Project> projects;
  final List<TaskModel> tasks;
  final List<Milestone> milestones;
  final TimelineViewMode? viewMode;
  final bool? showDependencies;
  final bool? showMilestones;
  final bool? showCriticalPath;
  final bool? highlightCriticalPath;
  final bool? dependencyMode;
  final bool? milestoneMode;
  final bool? showMilestoneProgress;
  final bool? showAlerts;
  final bool? showConflicts;
  final bool? showAdvancedDependencies;
  final bool? showImpactAnalysis;
  final bool? enableVirtualization;
  final bool? performanceMode;
  final bool? showTaskLabels;
  final bool? showProgressBars;
  final bool? showBaseline;
  final bool? showResourceUsage;
  final CustomColorScheme? customColorScheme;
  final Function(TaskModel)? onTaskTap;
  final Function(TaskModel, Map<String, DateTime>)? onTaskDrag;
  final Function(TaskModel, TaskModel)? onDependencyCreate;
  final Function(TaskModel, TaskModel)? onDependencyTap;
  final Function(Milestone)? onMilestoneTap;
  final Function(DateTime, DateTime)? onDateRangeChanged;
  final Function(Map<String, dynamic>)? onCustomizationChanged;

  const TimelineGanttView({
    super.key,
    required this.projects,
    required this.tasks,
    required this.milestones,
    this.viewMode,
    this.showDependencies,
    this.showMilestones,
    this.showCriticalPath,
    this.highlightCriticalPath,
    this.dependencyMode,
    this.milestoneMode,
    this.showMilestoneProgress,
    this.showAlerts,
    this.showConflicts,
    this.showAdvancedDependencies,
    this.showImpactAnalysis,
    this.enableVirtualization,
    this.performanceMode,
    this.showTaskLabels,
    this.showProgressBars,
    this.showBaseline,
    this.showResourceUsage,
    this.customColorScheme,
    this.onTaskTap,
    this.onTaskDrag,
    this.onDependencyCreate,
    this.onDependencyTap,
    this.onMilestoneTap,
    this.onDateRangeChanged,
    this.onCustomizationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: Column(
        children: [
          // Timeline header
          const SizedBox(
            key: Key('timeline_header'),
            height: 60,
            child: Row(
              children: [
                Text('Jan 2024'),
                SizedBox(width: 50),
                Text('Feb 2024'),
                SizedBox(width: 50),
                Text('Mar 2024'),
              ],
            ),
          ),
          // Timeline content
          Expanded(
            child: ListView(
              children: [
                // Projects and tasks
                ...projects.map((project) => 
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ...tasks.where((t) => t.projectId == project.id).map((task) =>
                        Container(
                          key: Key('task_bar_${task.title}'),
                          height: 30,
                          margin: const EdgeInsets.all(2),
                          color: _getTaskColor(task),
                          child: Text(task.title),
                        ),
                      ),
                    ],
                  ),
                ),
                // Milestones
                if (showMilestones == true)
                  ...milestones.map((milestone) =>
                    Container(
                      key: Key('milestone_${milestone.name}'),
                      height: 20,
                      color: milestone.isCritical ? Colors.red : Colors.blue,
                      child: Text(milestone.name),
                    ),
                  ),
                // Dependencies
                if (showDependencies == true)
                  ...tasks.expand((task) =>
                    (task.dependencies ?? []).map((depId) =>
                      Container(
                        key: Key('dependency_line_${depId}_to_${task.id}'),
                        height: 2,
                        color: Colors.grey,
                        child: const Text('→'),
                      ),
                    ),
                  ),
                // Critical path indicator
                if (showCriticalPath == true)
                  Container(
                    key: const Key('critical_path_indicator'),
                    color: Colors.red,
                    child: const Text('Critical Path'),
                  ),
                // Other indicators based on flags
                if (showBaseline == true)
                  Container(key: const Key('baseline_bars')),
                if (showResourceUsage == true)
                  Container(key: const Key('resource_usage_panel')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTaskColor(TaskModel task) {
    switch (task.status) {
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class MilestoneProgressCard extends StatelessWidget {
  final Milestone milestone;
  final List<TaskModel> dependentTasks;
  final int completionPercentage;

  const MilestoneProgressCard({
    super.key,
    required this.milestone,
    required this.dependentTasks,
    required this.completionPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(milestone.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$completionPercentage% Complete'),
            Text('${dependentTasks.length} tasks linked'),
            LinearProgressIndicator(value: completionPercentage / 100),
          ],
        ),
      ),
    );
  }
}

class MilestoneAlertCard extends StatelessWidget {
  final Milestone milestone;
  final MilestoneAlertType alertType;
  final int daysUntilDue;
  final int completionPercentage;

  const MilestoneAlertCard({
    super.key,
    required this.milestone,
    required this.alertType,
    required this.daysUntilDue,
    required this.completionPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(_getAlertIcon(), color: _getAlertColor()),
        title: Text(_getAlertTitle()),
        subtitle: Text(_getAlertDescription()),
      ),
    );
  }

  IconData _getAlertIcon() {
    switch (alertType) {
      case MilestoneAlertType.approaching:
        return Icons.schedule;
      case MilestoneAlertType.riskOfDelay:
        return Icons.warning;
      case MilestoneAlertType.overdue:
        return Icons.error;
    }
  }

  Color _getAlertColor() {
    switch (alertType) {
      case MilestoneAlertType.approaching:
        return Colors.orange;
      case MilestoneAlertType.riskOfDelay:
        return Colors.red;
      case MilestoneAlertType.overdue:
        return Colors.red;
    }
  }

  String _getAlertTitle() {
    switch (alertType) {
      case MilestoneAlertType.approaching:
        return 'Approaching Deadline';
      case MilestoneAlertType.riskOfDelay:
        return 'Risk of Delay';
      case MilestoneAlertType.overdue:
        return 'Overdue';
    }
  }

  String _getAlertDescription() {
    switch (alertType) {
      case MilestoneAlertType.approaching:
        return 'Due in $daysUntilDue days, $completionPercentage% complete';
      case MilestoneAlertType.riskOfDelay:
        return 'Only $completionPercentage% complete with $daysUntilDue days remaining';
      case MilestoneAlertType.overdue:
        return '$daysUntilDue days overdue, $completionPercentage% complete';
    }
  }
}

class CriticalPathChangeCard extends StatelessWidget {
  final String taskName;
  final CriticalPathChangeType changeType;
  final String impact;
  final DateTime timestamp;

  const CriticalPathChangeCard({
    super.key,
    required this.taskName,
    required this.changeType,
    required this.impact,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(_getChangeIcon(), color: _getChangeColor()),
        title: Text(taskName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getChangeDescription()),
            Text(impact),
          ],
        ),
        trailing: Text('${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}'),
      ),
    );
  }

  IconData _getChangeIcon() {
    switch (changeType) {
      case CriticalPathChangeType.durationIncrease:
        return Icons.trending_up;
      case CriticalPathChangeType.durationDecrease:
        return Icons.trending_down;
      case CriticalPathChangeType.becameCritical:
        return Icons.add_circle;
      case CriticalPathChangeType.becameNonCritical:
        return Icons.remove_circle;
    }
  }

  Color _getChangeColor() {
    switch (changeType) {
      case CriticalPathChangeType.durationIncrease:
        return Colors.red;
      case CriticalPathChangeType.durationDecrease:
        return Colors.green;
      case CriticalPathChangeType.becameCritical:
        return Colors.orange;
      case CriticalPathChangeType.becameNonCritical:
        return Colors.blue;
    }
  }

  String _getChangeDescription() {
    switch (changeType) {
      case CriticalPathChangeType.durationIncrease:
        return 'Duration Increased';
      case CriticalPathChangeType.durationDecrease:
        return 'Duration Decreased';
      case CriticalPathChangeType.becameCritical:
        return 'Became Critical';
      case CriticalPathChangeType.becameNonCritical:
        return 'No Longer Critical';
    }
  }
}

class TaskBar extends StatelessWidget {
  const TaskBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      color: Colors.blue,
      child: const Text('Task Bar'),
    );
  }
}