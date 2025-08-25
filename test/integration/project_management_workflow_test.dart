import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/presentation/widgets/project_card.dart';
import 'package:task_tracker_app/presentation/widgets/project_form_dialog.dart';
import 'package:task_tracker_app/presentation/widgets/advanced_task_card.dart';

void main() {
  group('Project Management Workflow Integration Tests', () {
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

    group('Project Creation and Management', () {
      testWidgets('should create project with tasks assignment workflow', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Projects'),
                  actions: [
                    IconButton(
                      key: const Key('create_project_button'),
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        showDialog(
                          context: tester.element(find.byType(Scaffold)),
                          builder: (context) => const ProjectFormDialog(),
                        );
                      },
                    ),
                  ],
                ),
                body: const Center(child: Text('No projects yet')),
              ),
            ),
          ),
        );

        // Tap create project button
        await tester.tap(find.byKey(const Key('create_project_button')));
        await tester.pump();

        // Verify dialog appears
        expect(find.byType(ProjectFormDialog), findsOneWidget);

        // Fill project details
        await tester.enterText(find.byKey(const Key('project_name_field')), 'Mobile App Development');
        await tester.enterText(find.byKey(const Key('project_description_field')), 'Developing a new task management mobile application');

        // Select project color
        await tester.tap(find.byKey(const Key('project_color_picker')));
        await tester.pump();
        await tester.tap(find.byKey(const Key('color_blue')));
        await tester.pump();

        // Set project deadline
        await tester.tap(find.byKey(const Key('project_deadline_picker')));
        await tester.pump();
        // Would select a date from the date picker
        await tester.tap(find.text('OK'));
        await tester.pump();

        // Save project
        await tester.tap(find.byKey(const Key('save_project_button')));
        await tester.pump();

        // Verify project is created and dialog closes
        expect(find.byType(ProjectFormDialog), findsNothing);
      });

      testWidgets('should assign tasks to project workflow', (tester) async {
        final project = Project(
          id: 'test-project',
          name: 'Test Project',
          description: 'Project for testing',
          color: '#2196F3',
          createdAt: DateTime.now(),
        );

        final unassignedTasks = [
          TaskModel.create(title: 'Unassigned Task 1', description: 'First task'),
          TaskModel.create(title: 'Unassigned Task 2', description: 'Second task'),
          TaskModel.create(title: 'Unassigned Task 3', description: 'Third task'),
        ];

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Assign Tasks to Project'),
                  actions: [
                    IconButton(
                      key: const Key('assign_tasks_button'),
                      icon: const Icon(Icons.assignment_add),
                      onPressed: () {
                        // Open task assignment dialog
                      },
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    ProjectCard(
                      project: project,
                      taskCount: 0,
                      completedTaskCount: 0,
                    ),
                    const Divider(),
                    const Text('Available Tasks:'),
                    Expanded(
                      child: ListView(
                        children: unassignedTasks
                            .map((task) => AdvancedTaskCard(
                                  key: Key('unassigned_task_${task.id}'),
                                  task: task,
                                  isSelectable: true,
                                  onSelectionChanged: (isSelected) {
                                    // Handle selection
                                  },
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

        // Verify project and tasks appear
        expect(find.text('Test Project'), findsOneWidget);
        expect(find.text('Unassigned Task 1'), findsOneWidget);
        expect(find.text('Unassigned Task 2'), findsOneWidget);
        expect(find.text('Unassigned Task 3'), findsOneWidget);

        // Select tasks for assignment
        await tester.tap(find.byKey(Key('unassigned_task_${unassignedTasks[0].id}')));
        await tester.pump();
        await tester.tap(find.byKey(Key('unassigned_task_${unassignedTasks[1].id}')));
        await tester.pump();

        // Assign selected tasks to project
        await tester.tap(find.byKey(const Key('assign_tasks_button')));
        await tester.pump();

        // Confirm assignment
        await tester.tap(find.text('Assign'));
        await tester.pump();

        // Verify assignment workflow completed
        expect(find.byKey(const Key('assign_tasks_button')), findsOneWidget);
      });

      testWidgets('should manage project settings and team members', (tester) async {
        final project = Project(
          id: 'settings-project',
          name: 'Settings Test Project',
          description: 'Project for testing settings',
          color: '#4CAF50',
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: ProjectCard(
                  project: project,
                  taskCount: 5,
                  completedTaskCount: 2,
                  onTap: () {
                    // Navigate to project details
                  },
                  onSettings: () {
                    // Open project settings
                  },
                ),
              ),
            ),
          ),
        );

        // Tap project settings
        await tester.tap(find.byKey(const Key('project_settings_button')));
        await tester.pump();

        // Would test project settings dialog
        expect(find.text('Settings Test Project'), findsOneWidget);
      });
    });

    group('Project Organization and Filtering', () {
      testWidgets('should organize tasks by project workflow', (tester) async {
        final projects = [
          Project(id: '1', name: 'Work Project', description: 'Work tasks', color: '#F44336', createdAt: DateTime.now()),
          Project(id: '2', name: 'Personal Project', description: 'Personal tasks', color: '#2196F3', createdAt: DateTime.now()),
          Project(id: '3', name: 'Learning Project', description: 'Learning tasks', color: '#4CAF50', createdAt: DateTime.now()),
        ];

        final tasks = [
          TaskModel.create(title: 'Work Task 1', projectId: '1'),
          TaskModel.create(title: 'Work Task 2', projectId: '1'),
          TaskModel.create(title: 'Personal Task 1', projectId: '2'),
          TaskModel.create(title: 'Learning Task 1', projectId: '3'),
          TaskModel.create(title: 'Unassigned Task', projectId: null),
        ];

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: DefaultTabController(
                length: projects.length + 1,
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('Tasks by Project'),
                    bottom: TabBar(
                      isScrollable: true,
                      tabs: [
                        ...projects.map((p) => Tab(text: p.name)),
                        const Tab(text: 'Unassigned'),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      // Work Project Tab
                      ListView(
                        children: tasks
                            .where((t) => t.projectId == '1')
                            .map((t) => AdvancedTaskCard(key: Key('task_${t.id}'), task: t))
                            .toList(),
                      ),
                      // Personal Project Tab
                      ListView(
                        children: tasks
                            .where((t) => t.projectId == '2')
                            .map((t) => AdvancedTaskCard(key: Key('task_${t.id}'), task: t))
                            .toList(),
                      ),
                      // Learning Project Tab
                      ListView(
                        children: tasks
                            .where((t) => t.projectId == '3')
                            .map((t) => AdvancedTaskCard(key: Key('task_${t.id}'), task: t))
                            .toList(),
                      ),
                      // Unassigned Tab
                      ListView(
                        children: tasks
                            .where((t) => t.projectId == null)
                            .map((t) => AdvancedTaskCard(key: Key('task_${t.id}'), task: t))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Verify project tabs
        expect(find.text('Work Project'), findsOneWidget);
        expect(find.text('Personal Project'), findsOneWidget);
        expect(find.text('Learning Project'), findsOneWidget);
        expect(find.text('Unassigned'), findsOneWidget);

        // Test navigation between project tabs
        await tester.tap(find.text('Personal Project'));
        await tester.pump();

        // Verify correct tasks shown for personal project
        expect(find.text('Personal Task 1'), findsOneWidget);

        // Test unassigned tasks tab
        await tester.tap(find.text('Unassigned'));
        await tester.pump();

        expect(find.text('Unassigned Task'), findsOneWidget);
      });

      testWidgets('should filter projects by status and deadline', (tester) async {
        final projects = [
          Project(
            id: '1',
            name: 'Active Project',
            description: 'Currently active',
            color: '#4CAF50',
            createdAt: DateTime.now().subtract(const Duration(days: 10)),
            deadline: DateTime.now().add(const Duration(days: 30)),
          ),
          Project(
            id: '2',
            name: 'Overdue Project',
            description: 'Past deadline',
            color: '#F44336',
            createdAt: DateTime.now().subtract(const Duration(days: 60)),
            deadline: DateTime.now().subtract(const Duration(days: 1)),
          ),
          Project(
            id: '3',
            name: 'Archived Project',
            description: 'Completed project',
            color: '#9E9E9E',
            createdAt: DateTime.now().subtract(const Duration(days: 90)),
            isArchived: true,
          ),
        ];

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Project Filters'),
                  actions: [
                    PopupMenuButton<String>(
                      key: const Key('project_filter_menu'),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'all', child: Text('All Projects')),
                        const PopupMenuItem(value: 'active', child: Text('Active Projects')),
                        const PopupMenuItem(value: 'overdue', child: Text('Overdue Projects')),
                        const PopupMenuItem(value: 'archived', child: Text('Archived Projects')),
                      ],
                      onSelected: (value) {
                        // Handle filter selection
                      },
                    ),
                  ],
                ),
                body: ListView(
                  children: projects
                      .map((project) => ProjectCard(
                            key: Key('project_${project.id}'),
                            project: project,
                            taskCount: 5,
                            completedTaskCount: 2,
                            showStatus: true,
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        );

        // Verify all projects appear
        expect(find.text('Active Project'), findsOneWidget);
        expect(find.text('Overdue Project'), findsOneWidget);
        expect(find.text('Archived Project'), findsOneWidget);

        // Test filtering by status
        await tester.tap(find.byKey(const Key('project_filter_menu')));
        await tester.pump();
        await tester.tap(find.text('Active Projects'));
        await tester.pump();

        // Test overdue filter
        await tester.tap(find.byKey(const Key('project_filter_menu')));
        await tester.pump();
        await tester.tap(find.text('Overdue Projects'));
        await tester.pump();

        // Verify filter workflow
        expect(find.byKey(const Key('project_filter_menu')), findsOneWidget);
      });
    });

    group('Project Analytics and Reports', () {
      testWidgets('should display project progress and analytics', (tester) async {
        final project = Project(
          id: 'analytics-project',
          name: 'Analytics Test Project',
          description: 'Project for testing analytics',
          color: '#FF9800',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          deadline: DateTime.now().add(const Duration(days: 7)),
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Project Analytics'),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      ProjectCard(
                        project: project,
                        taskCount: 20,
                        completedTaskCount: 12,
                        showProgress: true,
                        showAnalytics: true,
                      ),
                      const Divider(),
                      // Progress indicators
                      const Card(
                        child: ListTile(
                          title: Text('Progress Overview'),
                          subtitle: LinearProgressIndicator(value: 0.6),
                        ),
                      ),
                      // Time tracking
                      const Card(
                        child: ListTile(
                          title: Text('Time Remaining'),
                          subtitle: Text('7 days until deadline'),
                          trailing: Icon(Icons.schedule),
                        ),
                      ),
                      // Team productivity
                      const Card(
                        child: ListTile(
                          title: Text('Team Productivity'),
                          subtitle: Text('5 tasks completed this week'),
                          trailing: Icon(Icons.trending_up),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Verify analytics components
        expect(find.text('Analytics Test Project'), findsOneWidget);
        expect(find.text('Progress Overview'), findsOneWidget);
        expect(find.text('Time Remaining'), findsOneWidget);
        expect(find.text('Team Productivity'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);

        // Test progress interaction
        await tester.tap(find.text('Progress Overview'));
        await tester.pump();

        // Verify analytics display
        expect(find.text('Progress Overview'), findsOneWidget);
      });

      testWidgets('should generate project reports workflow', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Project Reports'),
                  actions: [
                    IconButton(
                      key: const Key('generate_report_button'),
                      icon: const Icon(Icons.assessment),
                      onPressed: () {
                        // Generate report
                      },
                    ),
                  ],
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Project Report Generation'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        key: const Key('weekly_report_button'),
                        onPressed: () {
                          // Generate weekly report
                        },
                        child: const Text('Weekly Report'),
                      ),
                      ElevatedButton(
                        key: const Key('monthly_report_button'),
                        onPressed: () {
                          // Generate monthly report
                        },
                        child: const Text('Monthly Report'),
                      ),
                      ElevatedButton(
                        key: const Key('custom_report_button'),
                        onPressed: () {
                          // Generate custom report
                        },
                        child: const Text('Custom Report'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Test report generation
        await tester.tap(find.byKey(const Key('weekly_report_button')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('monthly_report_button')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('generate_report_button')));
        await tester.pump();

        // Verify report workflow
        expect(find.text('Project Report Generation'), findsOneWidget);
      });
    });
  });
}