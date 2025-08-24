import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:mockito/mockito.dart';

import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/entities/project_category.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/presentation/widgets/project_form_dialog.dart';
import 'package:task_tracker_app/presentation/widgets/project_card.dart';
import 'package:task_tracker_app/presentation/providers/project_providers.dart';
import 'package:task_tracker_app/presentation/providers/project_category_providers.dart';
import 'package:task_tracker_app/core/providers/core_providers.dart';

void main() {
  group('Project Creation Workflow Integration Tests', () {
    late ProviderContainer container;
    late AppDatabase testDatabase;
    late List<ProjectCategory> testCategories;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Create test database
      testDatabase = AppDatabase.forTesting(NativeDatabase.memory());
      
      // Create test categories for project creation
      testCategories = [
        ProjectCategory.createSystem(
          id: 'work',
          name: 'Work',
          iconName: 'briefcase',
          color: '#1976D2',
          sortOrder: 0,
        ),
        ProjectCategory.createSystem(
          id: 'personal',
          name: 'Personal',
          iconName: 'user',
          color: '#4CAF50',
          sortOrder: 1,
        ),
        ProjectCategory.createUser(
          name: 'Side Projects',
          iconName: 'lightbulb',
          color: '#FF9800',
          sortOrder: 2,
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

    group('Complete Project Creation Flow', () {
      testWidgets('should create project from home screen with full category integration', (tester) async {
        // Setup the test widget tree with provider scope
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Projects Dashboard'),
                  actions: [
                    IconButton(
                      key: const Key('create_project_fab'),
                      icon: const Icon(Icons.add_circle),
                      onPressed: () {
                        showDialog(
                          context: tester.element(find.byType(Scaffold)),
                          builder: (context) => const ProjectFormDialog(),
                        );
                      },
                    ),
                  ],
                ),
                body: const Center(
                  child: Text('No projects yet. Create your first project!'),
                ),
                floatingActionButton: FloatingActionButton(
                  key: const Key('quick_create_project_fab'),
                  onPressed: () {
                    showDialog(
                      context: tester.element(find.byType(Scaffold)),
                      builder: (context) => const ProjectFormDialog(quickCreate: true),
                    );
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ),
        );

        // Verify initial state
        expect(find.text('Projects Dashboard'), findsOneWidget);
        expect(find.text('No projects yet. Create your first project!'), findsOneWidget);
        expect(find.byKey(const Key('create_project_fab')), findsOneWidget);
        expect(find.byKey(const Key('quick_create_project_fab')), findsOneWidget);

        // Test full project creation flow through main FAB
        await tester.tap(find.byKey(const Key('create_project_fab')));
        await tester.pumpAndSettle();

        // Verify project creation dialog appears
        expect(find.byType(ProjectFormDialog), findsOneWidget);
        expect(find.text('Create New Project'), findsOneWidget);

        // Fill in project details
        await tester.enterText(
          find.byKey(const Key('project_name_field')), 
          'Mobile App Development Project'
        );
        await tester.enterText(
          find.byKey(const Key('project_description_field')), 
          'Comprehensive mobile application for task management with advanced features including AI integration, voice commands, and real-time collaboration.'
        );

        // Test category selection integration
        await tester.tap(find.byKey(const Key('project_category_selector')));
        await tester.pumpAndSettle();

        // Verify category options appear
        expect(find.text('Work'), findsOneWidget);
        expect(find.text('Personal'), findsOneWidget);
        expect(find.text('Side Projects'), findsOneWidget);

        // Select work category
        await tester.tap(find.text('Work'));
        await tester.pumpAndSettle();

        // Test color selection with category-aware defaults
        await tester.tap(find.byKey(const Key('project_color_picker')));
        await tester.pumpAndSettle();

        // Select a custom color
        await tester.tap(find.byKey(const Key('color_#2196F3')));
        await tester.pumpAndSettle();

        // Set project deadline using date picker
        await tester.tap(find.byKey(const Key('project_deadline_picker')));
        await tester.pumpAndSettle();

        // Would interact with calendar widget (simplified for test)
        await tester.tap(find.text('15')); // Select 15th of current month
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Test priority setting
        await tester.tap(find.byKey(const Key('project_priority_dropdown')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('High').last);
        await tester.pumpAndSettle();

        // Add project tags
        await tester.enterText(
          find.byKey(const Key('project_tags_field')), 
          'mobile, development, flutter, ai'
        );

        // Configure advanced settings
        await tester.tap(find.byKey(const Key('show_advanced_settings')));
        await tester.pumpAndSettle();

        // Set estimated budget
        await tester.enterText(
          find.byKey(const Key('project_budget_field')), 
          '50000'
        );

        // Add team members
        await tester.tap(find.byKey(const Key('add_team_member_button')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('team_member_email_field')), 
          'developer@example.com'
        );
        await tester.tap(find.byKey(const Key('confirm_team_member')));
        await tester.pumpAndSettle();

        // Save project
        await tester.tap(find.byKey(const Key('save_project_button')));
        await tester.pumpAndSettle();

        // Verify project creation success
        expect(find.byType(ProjectFormDialog), findsNothing);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Project created successfully!'), findsOneWidget);
      });

      testWidgets('should handle project creation with validation errors and recovery', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: tester.element(find.byType(Scaffold)),
                        builder: (context) => const ProjectFormDialog(),
                      );
                    },
                    child: const Text('Create Project'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Open project creation dialog
        await tester.tap(find.text('Create Project'));
        await tester.pumpAndSettle();

        // Test validation: try to save empty project
        await tester.tap(find.byKey(const Key('save_project_button')));
        await tester.pumpAndSettle();

        // Verify validation errors appear
        expect(find.text('Project name is required'), findsOneWidget);
        expect(find.text('Please select a category'), findsOneWidget);

        // Test invalid name characters
        await tester.enterText(
          find.byKey(const Key('project_name_field')), 
          'Invalid<>Name|*?'
        );
        await tester.tap(find.byKey(const Key('save_project_button')));
        await tester.pumpAndSettle();

        expect(find.text('Project name contains invalid characters'), findsOneWidget);

        // Fix validation errors
        await tester.enterText(
          find.byKey(const Key('project_name_field')), 
          'Valid Project Name'
        );

        await tester.tap(find.byKey(const Key('project_category_selector')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Personal'));
        await tester.pumpAndSettle();

        // Test recovery: save valid project
        await tester.tap(find.byKey(const Key('save_project_button')));
        await tester.pumpAndSettle();

        // Verify successful creation after error recovery
        expect(find.byType(ProjectFormDialog), findsNothing);
        expect(find.text('Project created successfully!'), findsOneWidget);
      });

      testWidgets('should create project with existing tasks assignment workflow', (tester) async {
        // Pre-create some unassigned tasks
        final unassignedTasks = [
          TaskModel.create(title: 'Unassigned Design Task', description: 'UI/UX design work'),
          TaskModel.create(title: 'Unassigned Development Task', description: 'Backend API development'),
          TaskModel.create(title: 'Unassigned Testing Task', description: 'Quality assurance testing'),
        ];

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    ElevatedButton(
                      key: const Key('create_project_with_tasks'),
                      onPressed: () {
                        showDialog(
                          context: tester.element(find.byType(Scaffold)),
                          builder: (context) => const ProjectFormDialog(
                            showTaskAssignment: true,
                          ),
                        );
                      },
                      child: const Text('Create Project with Tasks'),
                    ),
                    Expanded(
                      child: ListView(
                        children: unassignedTasks
                            .map((task) => ListTile(
                                  key: Key('unassigned_task_${task.id}'),
                                  title: Text(task.title),
                                  subtitle: Text(task.description ?? ''),
                                  leading: const Icon(Icons.task_alt),
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

        // Verify unassigned tasks are visible
        expect(find.text('Unassigned Design Task'), findsOneWidget);
        expect(find.text('Unassigned Development Task'), findsOneWidget);
        expect(find.text('Unassigned Testing Task'), findsOneWidget);

        // Open project creation with task assignment
        await tester.tap(find.byKey(const Key('create_project_with_tasks')));
        await tester.pumpAndSettle();

        // Fill basic project info
        await tester.enterText(
          find.byKey(const Key('project_name_field')), 
          'Development Sprint Project'
        );
        await tester.tap(find.byKey(const Key('project_category_selector')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Work'));
        await tester.pumpAndSettle();

        // Navigate to task assignment step
        await tester.tap(find.byKey(const Key('next_step_button')));
        await tester.pumpAndSettle();

        // Verify task assignment interface appears
        expect(find.text('Assign Existing Tasks'), findsOneWidget);
        expect(find.text('Select tasks to include in this project'), findsOneWidget);

        // Select tasks for assignment
        await tester.tap(find.byKey(Key('task_checkbox_${unassignedTasks[0].id}')));
        await tester.tap(find.byKey(Key('task_checkbox_${unassignedTasks[2].id}')));
        await tester.pumpAndSettle();

        // Verify selection feedback
        expect(find.text('2 tasks selected'), findsOneWidget);

        // Complete project creation with task assignment
        await tester.tap(find.byKey(const Key('create_project_with_tasks_button')));
        await tester.pumpAndSettle();

        // Verify success with task assignment summary
        expect(find.text('Project created with 2 tasks assigned'), findsOneWidget);
      });
    });

    group('Category Integration Workflows', () {
      testWidgets('should create project with new category creation workflow', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: tester.element(find.byType(Scaffold)),
                        builder: (context) => const ProjectFormDialog(),
                      );
                    },
                    child: const Text('Create Project'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Open project creation
        await tester.tap(find.text('Create Project'));
        await tester.pumpAndSettle();

        // Fill project name
        await tester.enterText(
          find.byKey(const Key('project_name_field')), 
          'Research Project'
        );

        // Try to create new category
        await tester.tap(find.byKey(const Key('project_category_selector')));
        await tester.pumpAndSettle();

        // Select "Create New Category" option
        await tester.tap(find.byKey(const Key('create_new_category_option')));
        await tester.pumpAndSettle();

        // Fill new category details
        expect(find.text('Create New Category'), findsOneWidget);
        await tester.enterText(
          find.byKey(const Key('category_name_field')), 
          'Research & Development'
        );

        // Select category icon
        await tester.tap(find.byKey(const Key('category_icon_selector')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('icon_microscope')));
        await tester.pumpAndSettle();

        // Select category color
        await tester.tap(find.byKey(const Key('category_color_selector')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('color_#9C27B0')));
        await tester.pumpAndSettle();

        // Save new category
        await tester.tap(find.byKey(const Key('save_category_button')));
        await tester.pumpAndSettle();

        // Verify category was created and selected
        expect(find.text('Research & Development'), findsOneWidget);

        // Complete project creation
        await tester.tap(find.byKey(const Key('save_project_button')));
        await tester.pumpAndSettle();

        // Verify project created with new category
        expect(find.text('Project created successfully!'), findsOneWidget);
      });

      testWidgets('should handle category inheritance and hierarchy in project creation', (tester) async {
        // Create hierarchical categories
        final parentCategory = ProjectCategory.createUser(
          name: 'Client Work',
          iconName: 'buildings',
          color: '#1976D2',
          sortOrder: 0,
        );

        final childCategory = ProjectCategory.createUser(
          name: 'Web Development',
          iconName: 'globe',
          color: '#1976D2',
          parentId: parentCategory.id,
          sortOrder: 1,
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: tester.element(find.byType(Scaffold)),
                        builder: (context) => const ProjectFormDialog(),
                      );
                    },
                    child: const Text('Create Project'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Create Project'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('project_name_field')), 
          'Client Website Redesign'
        );

        // Test hierarchical category selection
        await tester.tap(find.byKey(const Key('project_category_selector')));
        await tester.pumpAndSettle();

        // Verify parent category appears
        expect(find.text('Client Work'), findsOneWidget);

        // Expand to show child categories
        await tester.tap(find.byKey(Key('expand_category_${parentCategory.id}')));
        await tester.pumpAndSettle();

        // Select child category
        expect(find.text('  Web Development'), findsOneWidget); // Indented
        await tester.tap(find.text('  Web Development'));
        await tester.pumpAndSettle();

        // Verify inheritance of parent category properties
        expect(find.text('Web Development (Client Work)'), findsOneWidget);

        await tester.tap(find.byKey(const Key('save_project_button')));
        await tester.pumpAndSettle();

        expect(find.text('Project created successfully!'), findsOneWidget);
      });
    });

    group('Performance and Data Validation Workflows', () {
      testWidgets('should handle bulk project creation with performance optimization', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(title: const Text('Bulk Project Creation')),
                body: Column(
                  children: [
                    ElevatedButton(
                      key: const Key('bulk_create_projects'),
                      onPressed: () {
                        showDialog(
                          context: tester.element(find.byType(Scaffold)),
                          builder: (context) => const BulkProjectCreationDialog(),
                        );
                      },
                      child: const Text('Bulk Create Projects'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Open bulk creation dialog
        await tester.tap(find.byKey(const Key('bulk_create_projects')));
        await tester.pumpAndSettle();

        // Test CSV import functionality
        await tester.tap(find.byKey(const Key('import_csv_button')));
        await tester.pumpAndSettle();

        // Simulate CSV data entry
        const csvData = '''
Name,Category,Priority,Deadline
Marketing Campaign Q1,Work,High,2024-03-31
Personal Blog Redesign,Personal,Medium,2024-04-15
Side Project App,Side Projects,Low,2024-06-01
''';

        await tester.enterText(
          find.byKey(const Key('csv_data_field')), 
          csvData
        );

        // Validate CSV data
        await tester.tap(find.byKey(const Key('validate_csv_button')));
        await tester.pumpAndSettle();

        // Verify validation results
        expect(find.text('3 valid projects found'), findsOneWidget);
        expect(find.text('0 errors detected'), findsOneWidget);

        // Create projects in batch
        final stopwatch = Stopwatch()..start();
        await tester.tap(find.byKey(const Key('create_all_projects_button')));
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Verify performance benchmark (<100ms for 3 projects)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));

        // Verify batch creation success
        expect(find.text('3 projects created successfully'), findsOneWidget);
      });

      testWidgets('should validate project data consistency across the workflow', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    // Project creation form
                    ElevatedButton(
                      key: const Key('create_project'),
                      onPressed: () {
                        showDialog(
                          context: tester.element(find.byType(Scaffold)),
                          builder: (context) => const ProjectFormDialog(),
                        );
                      },
                      child: const Text('Create Project'),
                    ),
                    // Project list display
                    const Expanded(
                      child: ProjectListView(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Create a project with specific data
        await tester.tap(find.byKey(const Key('create_project')));
        await tester.pumpAndSettle();

        const projectName = 'Data Consistency Test Project';
        const projectDescription = 'Testing data flow and consistency';

        await tester.enterText(
          find.byKey(const Key('project_name_field')), 
          projectName
        );
        await tester.enterText(
          find.byKey(const Key('project_description_field')), 
          projectDescription
        );

        await tester.tap(find.byKey(const Key('project_category_selector')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Work'));
        await tester.pumpAndSettle();

        // Add metadata for consistency checking
        await tester.tap(find.byKey(const Key('show_advanced_settings')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('project_budget_field')), 
          '15000.50'
        );

        await tester.enterText(
          find.byKey(const Key('project_tags_field')), 
          'testing, data-consistency, integration'
        );

        // Save project
        await tester.tap(find.byKey(const Key('save_project_button')));
        await tester.pumpAndSettle();

        // Verify project appears in list with consistent data
        expect(find.text(projectName), findsOneWidget);
        expect(find.text('Work'), findsOneWidget);
        expect(find.text('\$15,000.50'), findsOneWidget);

        // Test data persistence after app restart simulation
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: ProjectListView(),
              ),
            ),
          ),
        );

        // Verify data persisted correctly
        expect(find.text(projectName), findsOneWidget);
        expect(find.text(projectDescription), findsOneWidget);

        // Test project detail view consistency
        await tester.tap(find.text(projectName));
        await tester.pumpAndSettle();

        expect(find.text(projectName), findsOneWidget);
        expect(find.text(projectDescription), findsOneWidget);
        expect(find.text('Work'), findsOneWidget);
        expect(find.text('\$15,000.50'), findsOneWidget);
        expect(find.text('testing'), findsOneWidget);
        expect(find.text('data-consistency'), findsOneWidget);
        expect(find.text('integration'), findsOneWidget);
      });
    });

    group('Error Handling and Recovery Workflows', () {
      testWidgets('should handle network errors during project creation with offline support', (tester) async {
        // Simulate offline mode
        container.read(connectivityProvider.notifier).state = false;

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: tester.element(find.byType(Scaffold)),
                        builder: (context) => const ProjectFormDialog(),
                      );
                    },
                    child: const Text('Create Project'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Create Project'));
        await tester.pumpAndSettle();

        // Verify offline indicator
        expect(find.byIcon(Icons.cloud_off), findsOneWidget);
        expect(find.text('Working offline'), findsOneWidget);

        // Create project offline
        await tester.enterText(
          find.byKey(const Key('project_name_field')), 
          'Offline Created Project'
        );
        await tester.tap(find.byKey(const Key('project_category_selector')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Personal'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('save_project_button')));
        await tester.pumpAndSettle();

        // Verify offline creation success
        expect(find.text('Project created offline. Will sync when connected.'), findsOneWidget);

        // Simulate coming back online
        container.read(connectivityProvider.notifier).state = true;
        await tester.pumpAndSettle();

        // Verify sync indication
        expect(find.byIcon(Icons.sync), findsOneWidget);
        expect(find.text('Syncing offline changes...'), findsOneWidget);

        // Wait for sync completion
        await tester.pumpAndSettle();

        // Verify successful sync
        expect(find.text('All changes synced successfully'), findsOneWidget);
      });

      testWidgets('should handle concurrent project creation conflicts with resolution', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Row(
                  children: [
                    // User 1 interface
                    Expanded(
                      child: Column(
                        children: [
                          const Text('User 1'),
                          ElevatedButton(
                            key: const Key('user1_create_project'),
                            onPressed: () {
                              showDialog(
                                context: tester.element(find.byType(Scaffold)),
                                builder: (context) => const ProjectFormDialog(
                                  userContext: 'user1',
                                ),
                              );
                            },
                            child: const Text('Create Project'),
                          ),
                        ],
                      ),
                    ),
                    // User 2 interface
                    Expanded(
                      child: Column(
                        children: [
                          const Text('User 2'),
                          ElevatedButton(
                            key: const Key('user2_create_project'),
                            onPressed: () {
                              showDialog(
                                context: tester.element(find.byType(Scaffold)),
                                builder: (context) => const ProjectFormDialog(
                                  userContext: 'user2',
                                ),
                              );
                            },
                            child: const Text('Create Project'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Both users create projects with same name simultaneously
        const conflictingName = 'Shared Team Project';

        // User 1 starts creation
        await tester.tap(find.byKey(const Key('user1_create_project')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('project_name_field')).first, 
          conflictingName
        );

        // User 2 starts creation (simulating concurrent action)
        await tester.tap(find.byKey(const Key('user2_create_project')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('project_name_field')).last, 
          conflictingName
        );

        // User 1 saves first
        await tester.tap(find.byKey(const Key('save_project_button')).first);
        await tester.pumpAndSettle();

        // User 2 tries to save (should detect conflict)
        await tester.tap(find.byKey(const Key('save_project_button')).last);
        await tester.pumpAndSettle();

        // Verify conflict detection
        expect(find.text('Project name already exists'), findsOneWidget);
        expect(find.text('Choose a different name or merge with existing project'), findsOneWidget);

        // Test conflict resolution options
        expect(find.byKey(const Key('merge_with_existing')), findsOneWidget);
        expect(find.byKey(const Key('rename_project')), findsOneWidget);
        expect(find.byKey(const Key('cancel_creation')), findsOneWidget);

        // Choose rename option
        await tester.tap(find.byKey(const Key('rename_project')));
        await tester.pumpAndSettle();

        // Verify suggested name appears
        expect(find.text('$conflictingName (2)'), findsOneWidget);

        // Accept suggested name
        await tester.tap(find.byKey(const Key('accept_suggested_name')));
        await tester.pumpAndSettle();

        // Verify successful resolution
        expect(find.text('Project created with name: $conflictingName (2)'), findsOneWidget);
      });
    });
  });
}

// Mock dialog components for testing
class ProjectFormDialog extends StatelessWidget {
  final bool quickCreate;
  final bool showTaskAssignment;
  final String? userContext;

  const ProjectFormDialog({
    super.key,
    this.quickCreate = false,
    this.showTaskAssignment = false,
    this.userContext,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Project'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(key: Key('project_name_field')),
          TextField(key: Key('project_description_field')),
          // Additional form fields would be here
        ],
      ),
      actions: [
        TextButton(
          key: const Key('save_project_button'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class BulkProjectCreationDialog extends StatelessWidget {
  const BulkProjectCreationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bulk Create Projects'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            key: Key('import_csv_button'),
            onPressed: null,
            child: Text('Import CSV'),
          ),
          TextField(key: Key('csv_data_field')),
          ElevatedButton(
            key: Key('validate_csv_button'),
            onPressed: null,
            child: Text('Validate'),
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('create_all_projects_button'),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Create All'),
        ),
      ],
    );
  }
}

class ProjectListView extends StatelessWidget {
  const ProjectListView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Project List'));
  }
}

// Mock providers for testing
final connectivityProvider = StateProvider<bool>((ref) => true);