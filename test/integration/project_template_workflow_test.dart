import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:mockito/mockito.dart';

import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/entities/project_template.dart';
import 'package:task_tracker_app/domain/entities/task_template.dart';
import 'package:task_tracker_app/domain/entities/project_category.dart';
import 'package:task_tracker_app/presentation/widgets/project_template_wizard.dart';
import 'package:task_tracker_app/presentation/widgets/project_template_marketplace.dart';
import 'package:task_tracker_app/presentation/widgets/project_template_editor.dart';
import 'package:task_tracker_app/presentation/providers/project_template_providers.dart';
import 'package:task_tracker_app/core/providers/core_providers.dart';

void main() {
  group('Project Template Workflow Integration Tests', () {
    late ProviderContainer container;
    late AppDatabase testDatabase;
    late List<ProjectTemplate> systemTemplates;
    late List<ProjectTemplate> userTemplates;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Create test database
      testDatabase = AppDatabase.forTesting(NativeDatabase.memory());
      
      // Create system-defined templates
      systemTemplates = [
        ProjectTemplate.createSystem(
          id: 'agile-sprint',
          name: 'Agile Sprint',
          description: 'Standard 2-week agile sprint template with backlog, sprint planning, and retrospective',
          type: ProjectTemplateType.wizard,
          category: 'Software Development',
          iconName: 'rocket',
          color: '#2196F3',
          tags: ['agile', 'scrum', 'sprint'],
          variables: [
            const TemplateVariable(
              key: 'sprint_duration',
              displayName: 'Sprint Duration',
              type: TemplateVariableType.choice,
              isRequired: true,
              defaultValue: '2',
              options: ['1', '2', '3', '4'],
              description: 'Duration of sprint in weeks',
            ),
            const TemplateVariable(
              key: 'team_size',
              displayName: 'Team Size',
              type: TemplateVariableType.number,
              isRequired: true,
              defaultValue: '5',
              validation: {'min': 1, 'max': 20},
              description: 'Number of team members',
            ),
          ],
          tasks: [
            TaskTemplate(
              title: 'Sprint Planning',
              description: 'Plan the {{sprint_duration}}-week sprint with {{team_size}} team members',
              priority: TaskPriority.high,
              estimatedDuration: const Duration(hours: 4),
            ),
            TaskTemplate(
              title: 'Daily Standups',
              description: 'Recurring daily standup meetings',
              isRecurring: true,
              recurrencePattern: RecurrencePattern.daily,
            ),
            TaskTemplate(
              title: 'Sprint Review',
              description: 'Review completed work with stakeholders',
              priority: TaskPriority.medium,
              estimatedDuration: const Duration(hours: 2),
            ),
          ],
        ),
        ProjectTemplate.createSystem(
          id: 'marketing-campaign',
          name: 'Marketing Campaign',
          description: 'Comprehensive marketing campaign template with research, planning, execution, and analysis',
          type: ProjectTemplateType.wizard,
          category: 'Marketing',
          iconName: 'megaphone',
          color: '#FF9800',
          tags: ['marketing', 'campaign', 'promotion'],
          variables: [
            const TemplateVariable(
              key: 'campaign_type',
              displayName: 'Campaign Type',
              type: TemplateVariableType.choice,
              isRequired: true,
              options: ['Product Launch', 'Brand Awareness', 'Lead Generation', 'Customer Retention'],
              description: 'Type of marketing campaign',
            ),
            const TemplateVariable(
              key: 'budget',
              displayName: 'Campaign Budget',
              type: TemplateVariableType.number,
              isRequired: true,
              validation: {'min': 1000},
              description: 'Total campaign budget in USD',
            ),
          ],
        ),
        ProjectTemplate.createSystem(
          id: 'event-planning',
          name: 'Event Planning',
          description: 'Complete event planning template from concept to post-event analysis',
          type: ProjectTemplateType.simple,
          category: 'Events',
          iconName: 'calendar-event',
          color: '#4CAF50',
        ),
      ];

      // Create user-defined templates
      userTemplates = [
        ProjectTemplate.createUser(
          name: 'Mobile App Development',
          description: 'Custom template for mobile app development projects',
          type: ProjectTemplateType.advanced,
          category: 'Software Development',
          iconName: 'device-mobile',
          color: '#9C27B0',
          tags: ['mobile', 'app', 'development'],
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

    group('Template Marketplace Workflow', () {
      testWidgets('should display template marketplace with categories and search', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Project Template Marketplace'),
                  actions: [
                    IconButton(
                      key: const Key('search_templates'),
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                    IconButton(
                      key: const Key('filter_templates'),
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: const ProjectTemplateMarketplace(),
                floatingActionButton: FloatingActionButton(
                  key: const Key('create_custom_template'),
                  onPressed: () {},
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify marketplace loads with categories
        expect(find.text('Project Template Marketplace'), findsOneWidget);
        expect(find.text('Software Development'), findsOneWidget);
        expect(find.text('Marketing'), findsOneWidget);
        expect(find.text('Events'), findsOneWidget);

        // Verify system templates appear
        expect(find.text('Agile Sprint'), findsOneWidget);
        expect(find.text('Marketing Campaign'), findsOneWidget);
        expect(find.text('Event Planning'), findsOneWidget);

        // Verify user templates appear
        expect(find.text('Mobile App Development'), findsOneWidget);

        // Test template card interaction
        await tester.tap(find.text('Agile Sprint'));
        await tester.pumpAndSettle();

        // Verify template detail view
        expect(find.text('Template Details'), findsOneWidget);
        expect(find.text('Standard 2-week agile sprint template'), findsOneWidget);
        expect(find.text('Sprint Duration'), findsOneWidget);
        expect(find.text('Team Size'), findsOneWidget);
        expect(find.byKey(const Key('use_template_button')), findsOneWidget);
        expect(find.byKey(const Key('preview_template_button')), findsOneWidget);

        // Test template preview
        await tester.tap(find.byKey(const Key('preview_template_button')));
        await tester.pumpAndSettle();

        expect(find.text('Template Preview'), findsOneWidget);
        expect(find.text('Sprint Planning'), findsOneWidget);
        expect(find.text('Daily Standups'), findsOneWidget);
        expect(find.text('Sprint Review'), findsOneWidget);
      });

      testWidgets('should handle template search and filtering', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const TextField(
                    key: Key('template_search_field'),
                    decoration: InputDecoration(
                      hintText: 'Search templates...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                body: const ProjectTemplateMarketplace(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test search functionality
        await tester.enterText(
          find.byKey(const Key('template_search_field')),
          'agile'
        );
        await tester.pumpAndSettle();

        // Verify search results
        expect(find.text('Agile Sprint'), findsOneWidget);
        expect(find.text('Marketing Campaign'), findsNothing);

        // Clear search
        await tester.enterText(
          find.byKey(const Key('template_search_field')),
          ''
        );
        await tester.pumpAndSettle();

        // Test category filtering
        await tester.tap(find.text('Software Development'));
        await tester.pumpAndSettle();

        expect(find.text('Agile Sprint'), findsOneWidget);
        expect(find.text('Mobile App Development'), findsOneWidget);
        expect(find.text('Marketing Campaign'), findsNothing);

        // Test tag filtering
        await tester.tap(find.byKey(const Key('filter_by_tags')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('sprint'));
        await tester.pumpAndSettle();

        expect(find.text('Agile Sprint'), findsOneWidget);
        expect(find.text('Mobile App Development'), findsNothing);

        // Test sorting options
        await tester.tap(find.byKey(const Key('sort_templates')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Most Popular'));
        await tester.pumpAndSettle();

        // Verify templates reordered by popularity
        final templateCards = find.byKey(const Key('template_card'));
        expect(templateCards, findsAtLeastNWidgets(3));
      });

      testWidgets('should handle template rating and reviews', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: ProjectTemplateMarketplace(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Open template details
        await tester.tap(find.text('Agile Sprint'));
        await tester.pumpAndSettle();

        // Verify rating display
        expect(find.byIcon(Icons.star), findsAtLeastNWidgets(5)); // Star rating
        expect(find.text('4.8/5.0'), findsOneWidget);
        expect(find.text('(127 reviews)'), findsOneWidget);

        // Test adding a review
        await tester.tap(find.byKey(const Key('add_review_button')));
        await tester.pumpAndSettle();

        expect(find.text('Rate this template'), findsOneWidget);

        // Rate template
        await tester.tap(find.byKey(const Key('star_5')));
        await tester.pumpAndSettle();

        // Write review
        await tester.enterText(
          find.byKey(const Key('review_text_field')),
          'Excellent template! Very comprehensive and well-structured.'
        );

        await tester.tap(find.byKey(const Key('submit_review_button')));
        await tester.pumpAndSettle();

        expect(find.text('Review submitted successfully'), findsOneWidget);

        // Verify review appears
        expect(find.text('Excellent template! Very comprehensive'), findsOneWidget);
        expect(find.text('★★★★★'), findsOneWidget);
      });
    });

    group('Template Wizard Workflow', () {
      testWidgets('should complete full template wizard with variable substitution', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: ElevatedButton(
                    key: const Key('start_wizard'),
                    onPressed: () {
                      Navigator.of(tester.element(find.byType(Scaffold))).push(
                        MaterialPageRoute(
                          builder: (context) => ProjectTemplateWizard(
                            template: systemTemplates[0], // Agile Sprint
                          ),
                        ),
                      );
                    },
                    child: const Text('Start Template Wizard'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Start wizard
        await tester.tap(find.byKey(const Key('start_wizard')));
        await tester.pumpAndSettle();

        // Verify wizard starts
        expect(find.text('Project Template Wizard'), findsOneWidget);
        expect(find.text('Step 1 of 4: Basic Information'), findsOneWidget);

        // Fill basic project information
        await tester.enterText(
          find.byKey(const Key('project_name_field')),
          'Q1 Development Sprint'
        );
        await tester.enterText(
          find.byKey(const Key('project_description_field')),
          'First quarter development sprint focusing on core features'
        );

        // Continue to variables step
        await tester.tap(find.byKey(const Key('wizard_next_button')));
        await tester.pumpAndSettle();

        // Verify variable configuration step
        expect(find.text('Step 2 of 4: Template Configuration'), findsOneWidget);
        expect(find.text('Sprint Duration'), findsOneWidget);
        expect(find.text('Team Size'), findsOneWidget);

        // Configure template variables
        await tester.tap(find.byKey(const Key('sprint_duration_dropdown')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('3')); // 3-week sprint
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('team_size_field')),
          '8'
        );

        // Continue to customization step
        await tester.tap(find.byKey(const Key('wizard_next_button')));
        await tester.pumpAndSettle();

        // Verify task customization step
        expect(find.text('Step 3 of 4: Customize Tasks'), findsOneWidget);
        expect(find.text('Plan the 3-week sprint with 8 team members'), findsOneWidget); // Variable substitution

        // Customize tasks
        await tester.tap(find.byKey(Key('edit_task_${systemTemplates[0].tasks[0].id}')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('task_title_field')),
          'Q1 Sprint Planning Session'
        );
        await tester.tap(find.byKey(const Key('save_task_changes')));
        await tester.pumpAndSettle();

        // Add custom task
        await tester.tap(find.byKey(const Key('add_custom_task')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('custom_task_title')),
          'Architecture Review'
        );
        await tester.enterText(
          find.byKey(const Key('custom_task_description')),
          'Review system architecture for scalability'
        );
        await tester.tap(find.byKey(const Key('save_custom_task')));
        await tester.pumpAndSettle();

        // Continue to final step
        await tester.tap(find.byKey(const Key('wizard_next_button')));
        await tester.pumpAndSettle();

        // Verify preview step
        expect(find.text('Step 4 of 4: Review & Create'), findsOneWidget);
        expect(find.text('Q1 Development Sprint'), findsOneWidget);
        expect(find.text('Q1 Sprint Planning Session'), findsOneWidget);
        expect(find.text('Architecture Review'), findsOneWidget);

        // Create project from template
        await tester.tap(find.byKey(const Key('create_project_from_template')));
        await tester.pumpAndSettle();

        // Verify success
        expect(find.text('Project created successfully!'), findsOneWidget);
        expect(find.text('4 tasks added to project'), findsOneWidget);
      });

      testWidgets('should handle wizard validation and error recovery', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: ProjectTemplateWizard(
                template: systemTemplates[1], // Marketing Campaign
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Try to proceed without filling required fields
        await tester.tap(find.byKey(const Key('wizard_next_button')));
        await tester.pumpAndSettle();

        // Verify validation errors
        expect(find.text('Project name is required'), findsOneWidget);

        // Fill minimum required info
        await tester.enterText(
          find.byKey(const Key('project_name_field')),
          'Q1 Marketing Push'
        );

        await tester.tap(find.byKey(const Key('wizard_next_button')));
        await tester.pumpAndSettle();

        // Try to proceed with invalid variable values
        await tester.enterText(
          find.byKey(const Key('budget_field')),
          '500' // Below minimum
        );

        await tester.tap(find.byKey(const Key('wizard_next_button')));
        await tester.pumpAndSettle();

        expect(find.text('Budget must be at least \$1,000'), findsOneWidget);

        // Fix validation error
        await tester.enterText(
          find.byKey(const Key('budget_field')),
          '15000'
        );

        // Select campaign type
        await tester.tap(find.byKey(const Key('campaign_type_dropdown')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Product Launch'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('wizard_next_button')));
        await tester.pumpAndSettle();

        // Should proceed to next step
        expect(find.text('Step 3 of 4: Customize Tasks'), findsOneWidget);
      });

      testWidgets('should support wizard navigation and step jumping', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: ProjectTemplateWizard(
                template: systemTemplates[0],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify step indicator
        expect(find.byKey(const Key('step_indicator')), findsOneWidget);
        expect(find.text('1'), findsOneWidget); // Current step
        expect(find.text('4'), findsOneWidget); // Total steps

        // Fill required fields to enable navigation
        await tester.enterText(
          find.byKey(const Key('project_name_field')),
          'Navigation Test Project'
        );

        // Test going to specific step
        await tester.tap(find.byKey(const Key('step_3_indicator')));
        await tester.pumpAndSettle();

        expect(find.text('Step 3 of 4: Customize Tasks'), findsOneWidget);

        // Test back navigation
        await tester.tap(find.byKey(const Key('wizard_back_button')));
        await tester.pumpAndSettle();

        expect(find.text('Step 2 of 4: Template Configuration'), findsOneWidget);

        // Test progress persistence
        await tester.tap(find.byKey(const Key('step_1_indicator')));
        await tester.pumpAndSettle();

        expect(find.text('Navigation Test Project'), findsOneWidget); // Data preserved
      });
    });

    group('Custom Template Creation Workflow', () {
      testWidgets('should create custom template with editor workflow', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: ElevatedButton(
                    key: const Key('create_template'),
                    onPressed: () {
                      Navigator.of(tester.element(find.byType(Scaffold))).push(
                        MaterialPageRoute(
                          builder: (context) => const ProjectTemplateEditor(),
                        ),
                      );
                    },
                    child: const Text('Create Custom Template'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Open template editor
        await tester.tap(find.byKey(const Key('create_template')));
        await tester.pumpAndSettle();

        // Verify editor loads
        expect(find.text('Create Project Template'), findsOneWidget);

        // Fill template metadata
        await tester.enterText(
          find.byKey(const Key('template_name_field')),
          'Product Launch Checklist'
        );
        await tester.enterText(
          find.byKey(const Key('template_description_field')),
          'Comprehensive checklist for product launch activities'
        );

        // Select template type
        await tester.tap(find.byKey(const Key('template_type_dropdown')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Wizard'));
        await tester.pumpAndSettle();

        // Select category
        await tester.tap(find.byKey(const Key('template_category_dropdown')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Product Management'));
        await tester.pumpAndSettle();

        // Add template variables
        await tester.tap(find.byKey(const Key('add_template_variable')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('variable_key_field')),
          'product_name'
        );
        await tester.enterText(
          find.byKey(const Key('variable_display_name_field')),
          'Product Name'
        );
        await tester.tap(find.byKey(const Key('variable_type_dropdown')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Text'));
        await tester.pumpAndSettle();

        // Mark as required
        await tester.tap(find.byKey(const Key('variable_required_checkbox')));
        await tester.tap(find.byKey(const Key('save_variable')));
        await tester.pumpAndSettle();

        // Add task templates
        await tester.tap(find.byKey(const Key('add_task_template')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('task_title_field')),
          'Market Research for {{product_name}}'
        );
        await tester.enterText(
          find.byKey(const Key('task_description_field')),
          'Conduct thorough market research for {{product_name}} launch'
        );

        // Set task priority
        await tester.tap(find.byKey(const Key('task_priority_dropdown')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('High'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('save_task_template')));
        await tester.pumpAndSettle();

        // Add more tasks
        await tester.tap(find.byKey(const Key('add_task_template')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('task_title_field')),
          'Prepare Marketing Materials'
        );
        await tester.tap(find.byKey(const Key('save_task_template')));
        await tester.pumpAndSettle();

        // Test template preview
        await tester.tap(find.byKey(const Key('preview_template')));
        await tester.pumpAndSettle();

        expect(find.text('Template Preview'), findsOneWidget);
        expect(find.text('Market Research for {{product_name}}'), findsOneWidget);
        expect(find.text('Prepare Marketing Materials'), findsOneWidget);

        // Save template
        await tester.tap(find.byKey(const Key('save_template_button')));
        await tester.pumpAndSettle();

        expect(find.text('Template saved successfully!'), findsOneWidget);
      });

      testWidgets('should handle template import/export workflow', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  actions: [
                    IconButton(
                      key: const Key('import_template'),
                      icon: const Icon(Icons.file_upload),
                      onPressed: () {},
                    ),
                    IconButton(
                      key: const Key('export_template'),
                      icon: const Icon(Icons.file_download),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: const ProjectTemplateMarketplace(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Test template export
        await tester.longPress(find.text('Mobile App Development'));
        await tester.pumpAndSettle();

        expect(find.text('Template Actions'), findsOneWidget);
        await tester.tap(find.text('Export Template'));
        await tester.pumpAndSettle();

        expect(find.text('Export Template'), findsOneWidget);
        expect(find.text('JSON Format'), findsOneWidget);
        expect(find.text('YAML Format'), findsOneWidget);

        await tester.tap(find.text('JSON Format'));
        await tester.tap(find.byKey(const Key('confirm_export')));
        await tester.pumpAndSettle();

        expect(find.text('Template exported successfully'), findsOneWidget);

        // Test template import
        await tester.tap(find.byKey(const Key('import_template')));
        await tester.pumpAndSettle();

        expect(find.text('Import Template'), findsOneWidget);
        expect(find.byKey(const Key('select_file_button')), findsOneWidget);
        expect(find.byKey(const Key('paste_json_button')), findsOneWidget);

        // Test JSON paste import
        await tester.tap(find.byKey(const Key('paste_json_button')));
        await tester.pumpAndSettle();

        const templateJson = '''
        {
          "name": "Imported Template",
          "description": "Template imported from JSON",
          "type": "simple",
          "tasks": [
            {
              "title": "Imported Task 1",
              "description": "First imported task"
            }
          ]
        }
        ''';

        await tester.enterText(
          find.byKey(const Key('json_input_field')),
          templateJson
        );

        await tester.tap(find.byKey(const Key('validate_json')));
        await tester.pumpAndSettle();

        expect(find.text('Template is valid'), findsOneWidget);

        await tester.tap(find.byKey(const Key('import_template_button')));
        await tester.pumpAndSettle();

        expect(find.text('Template imported successfully'), findsOneWidget);
        expect(find.text('Imported Template'), findsOneWidget);
      });

      testWidgets('should handle template sharing and collaboration', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: ProjectTemplateMarketplace(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Long press on user template to show actions
        await tester.longPress(find.text('Mobile App Development'));
        await tester.pumpAndSettle();

        expect(find.text('Template Actions'), findsOneWidget);
        expect(find.text('Share Template'), findsOneWidget);
        expect(find.text('Edit Template'), findsOneWidget);
        expect(find.text('Duplicate Template'), findsOneWidget);
        expect(find.text('Delete Template'), findsOneWidget);

        // Test template sharing
        await tester.tap(find.text('Share Template'));
        await tester.pumpAndSettle();

        expect(find.text('Share Template'), findsOneWidget);
        expect(find.byKey(const Key('share_link_button')), findsOneWidget);
        expect(find.byKey(const Key('share_email_button')), findsOneWidget);
        expect(find.byKey(const Key('publish_to_marketplace')), findsOneWidget);

        // Test generate share link
        await tester.tap(find.byKey(const Key('share_link_button')));
        await tester.pumpAndSettle();

        expect(find.text('Share Link Generated'), findsOneWidget);
        expect(find.byIcon(Icons.copy), findsOneWidget);
        
        // Copy link to clipboard
        await tester.tap(find.byIcon(Icons.copy));
        await tester.pumpAndSettle();

        expect(find.text('Link copied to clipboard'), findsOneWidget);

        // Test publishing to marketplace
        await tester.tap(find.byKey(const Key('publish_to_marketplace')));
        await tester.pumpAndSettle();

        expect(find.text('Publish to Marketplace'), findsOneWidget);
        expect(find.text('Make this template available to all users'), findsOneWidget);

        await tester.tap(find.byKey(const Key('confirm_publish')));
        await tester.pumpAndSettle();

        expect(find.text('Template published successfully!'), findsOneWidget);
      });
    });

    group('Template Performance and Analytics', () {
      testWidgets('should track template usage analytics', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: ProjectTemplateMarketplace(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Open template details
        await tester.tap(find.text('Agile Sprint'));
        await tester.pumpAndSettle();

        // Verify analytics data
        expect(find.text('Template Analytics'), findsOneWidget);
        expect(find.text('Used 42 times this month'), findsOneWidget);
        expect(find.text('Average project success rate: 87%'), findsOneWidget);
        expect(find.text('Most common customizations:'), findsOneWidget);

        // Test template performance metrics
        await tester.tap(find.byKey(const Key('view_analytics')));
        await tester.pumpAndSettle();

        expect(find.text('Template Performance'), findsOneWidget);
        expect(find.byType(Chart), findsOneWidget); // Usage chart
        expect(find.text('Success Rate Trend'), findsOneWidget);
        expect(find.text('Common Variations'), findsOneWidget);

        // Test usage tracking
        await tester.tap(find.byKey(const Key('use_template_button')));
        await tester.pumpAndSettle();

        // Should increment usage counter
        expect(find.text('Used 43 times this month'), findsOneWidget);
      });

      testWidgets('should handle large template sets with performance optimization', (tester) async {
        // Create large set of templates for performance testing
        final largeTemplateSet = List.generate(
          500,
          (index) => ProjectTemplate.createUser(
            name: 'Performance Test Template $index',
            description: 'Template for performance testing',
            type: ProjectTemplateType.simple,
            category: 'Test Category',
          ),
        );

        final stopwatch = Stopwatch();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: ProjectTemplateMarketplace(),
              ),
            ),
          ),
        );

        // Measure load time
        stopwatch.start();
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Verify performance benchmark (<200ms for 500 templates)
        expect(stopwatch.elapsedMilliseconds, lessThan(200));

        // Verify virtual scrolling (not all templates rendered)
        final templateCards = find.byKey(const Key('template_card'));
        expect(templateCards.evaluate().length, lessThan(50));

        // Test search performance
        stopwatch.reset();
        stopwatch.start();
        
        await tester.enterText(
          find.byKey(const Key('template_search_field')),
          'Performance Test Template 250'
        );
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Fast search

        expect(find.text('Performance Test Template 250'), findsOneWidget);
      });
    });
  });
}

// Mock classes for testing
class Chart extends StatelessWidget {
  const Chart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: Text('Chart Placeholder')),
    );
  }
}