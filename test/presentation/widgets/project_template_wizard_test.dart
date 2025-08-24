import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/entities/project_template.dart';
import 'package:task_tracker_app/presentation/widgets/project_template_wizard.dart';

void main() {
  group('ProjectTemplateWizard', () {
    late ProjectTemplate simpleTemplate;
    late ProjectTemplate wizardTemplate;
    late Function(Project) mockOnProjectCreated;
    late VoidCallback mockOnCancel;

    setUp(() {
      simpleTemplate = ProjectTemplate.create(
        name: 'Simple Template',
        projectNameTemplate: '{{project_name}} Project',
        type: ProjectTemplateType.simple,
        variables: const [
          TemplateVariable(
            key: 'project_name',
            displayName: 'Project Name',
            type: TemplateVariableType.text,
            isRequired: true,
          ),
          TemplateVariable(
            key: 'description',
            displayName: 'Project Description',
            type: TemplateVariableType.text,
            isRequired: false,
          ),
        ],
      );

      wizardTemplate = ProjectTemplate.create(
        name: 'Wizard Template',
        projectNameTemplate: '{{project_name}} Sprint',
        type: ProjectTemplateType.wizard,
        variables: const [
          TemplateVariable(
            key: 'project_name',
            displayName: 'Sprint Name',
            type: TemplateVariableType.text,
            isRequired: true,
          ),
          TemplateVariable(
            key: 'team_size',
            displayName: 'Team Size',
            type: TemplateVariableType.number,
            isRequired: true,
            defaultValue: 5,
          ),
          TemplateVariable(
            key: 'duration',
            displayName: 'Sprint Duration',
            type: TemplateVariableType.choice,
            isRequired: true,
            options: ['1 week', '2 weeks', '3 weeks', '4 weeks'],
          ),
        ],
        wizardSteps: const [
          TemplateWizardStep(
            id: 'basic_info',
            title: 'Basic Information',
            description: 'Configure your sprint basics',
            variableKeys: ['project_name'],
            order: 0,
            iconName: 'info',
          ),
          TemplateWizardStep(
            id: 'team_setup',
            title: 'Team Setup',
            description: 'Configure your team',
            variableKeys: ['team_size', 'duration'],
            order: 1,
            iconName: 'users',
          ),
        ],
      );

      mockOnProjectCreated = (Project project) {};
      mockOnCancel = () {};
    });

    testWidgets('should render simple template wizard', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProjectTemplateWizard(
            template: simpleTemplate,
            onProjectCreated: mockOnProjectCreated,
            onCancel: mockOnCancel,
          ),
        ),
      );

      // Should show dialog
      expect(find.byType(Dialog), findsOneWidget);
      
      // Should show template name
      expect(find.text('Simple Template'), findsOneWidget);
      
      // Should show form fields for all variables
      expect(find.byType(TextFormField), findsWidgets);
      
      // Should show action buttons
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Create Project'), findsOneWidget);
    });

    testWidgets('should render wizard template with steps', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProjectTemplateWizard(
            template: wizardTemplate,
            onProjectCreated: mockOnProjectCreated,
            onCancel: mockOnCancel,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show dialog
      expect(find.byType(Dialog), findsOneWidget);
      
      // Should show template name
      expect(find.text('Wizard Template'), findsOneWidget);
      
      // Should show progress indicator
      expect(find.text('Step 1 of 2'), findsOneWidget);
      
      // Should show first step content
      expect(find.text('Basic Information'), findsOneWidget);
      expect(find.text('Configure your sprint basics'), findsOneWidget);
      
      // Should show Sprint Name field (from first step)
      expect(find.text('Sprint Name'), findsOneWidget);
      
      // Should not show team size yet (second step)
      expect(find.text('Team Size'), findsNothing);
      
      // Should show navigation buttons
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should navigate between wizard steps', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProjectTemplateWizard(
            template: wizardTemplate,
            onProjectCreated: mockOnProjectCreated,
            onCancel: mockOnCancel,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Fill in required field on first step
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Sprint Name').first,
        'My Sprint',
      );

      // Click Next
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Should be on second step
      expect(find.text('Step 2 of 2'), findsOneWidget);
      expect(find.text('Team Setup'), findsOneWidget);
      expect(find.text('Configure your team'), findsOneWidget);
      
      // Should show second step fields
      expect(find.text('Team Size'), findsOneWidget);
      expect(find.text('Sprint Duration'), findsOneWidget);
      
      // Should show Previous button
      expect(find.text('Previous'), findsOneWidget);
      expect(find.text('Create Project'), findsOneWidget);

      // Go back to previous step
      await tester.tap(find.text('Previous'));
      await tester.pumpAndSettle();

      // Should be back on first step
      expect(find.text('Step 1 of 2'), findsOneWidget);
      expect(find.text('Basic Information'), findsOneWidget);
    });

    testWidgets('should validate required fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProjectTemplateWizard(
            template: wizardTemplate,
            onProjectCreated: mockOnProjectCreated,
            onCancel: mockOnCancel,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to go to next step without filling required field
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Should still be on first step (validation failed)
      expect(find.text('Step 1 of 2'), findsOneWidget);
      
      // Should show validation error
      expect(find.text('Sprint Name is required'), findsOneWidget);
    });

    testWidgets('should handle different input types', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProjectTemplateWizard(
            template: wizardTemplate,
            onProjectCreated: mockOnProjectCreated,
            onCancel: mockOnCancel,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Fill first step
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Sprint Name').first,
        'My Sprint',
      );

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Should show number input for team size
      final teamSizeField = find.widgetWithText(TextFormField, 'Team Size').first;
      expect(teamSizeField, findsOneWidget);
      
      // Should show dropdown for sprint duration
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.text('Sprint Duration'), findsOneWidget);
    });

    testWidgets('should show progress bar animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProjectTemplateWizard(
            template: wizardTemplate,
            onProjectCreated: mockOnProjectCreated,
            onCancel: mockOnCancel,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show 50% progress on first step
      expect(find.text('50%'), findsOneWidget);

      // Fill required field and go to next step
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Sprint Name').first,
        'My Sprint',
      );

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Should show 100% progress on second step
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('should handle boolean variables with checkboxes', (tester) async {
      final templateWithBoolean = wizardTemplate.copyWith(
        variables: [
          ...wizardTemplate.variables,
          const TemplateVariable(
            key: 'include_testing',
            displayName: 'Include Testing Phase',
            type: TemplateVariableType.boolean,
            isRequired: false,
            defaultValue: false,
          ),
        ],
        wizardSteps: [
          wizardTemplate.wizardSteps[0],
          wizardTemplate.wizardSteps[1].copyWith(
            variableKeys: [...wizardTemplate.wizardSteps[1].variableKeys, 'include_testing'],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ProjectTemplateWizard(
            template: templateWithBoolean,
            onProjectCreated: mockOnProjectCreated,
            onCancel: mockOnCancel,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to second step
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Sprint Name').first,
        'My Sprint',
      );

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Should show checkbox for boolean variable
      expect(find.byType(CheckboxListTile), findsOneWidget);
      expect(find.text('Include Testing Phase'), findsOneWidget);
    });

    testWidgets('should handle date variables with date picker', (tester) async {
      final templateWithDate = wizardTemplate.copyWith(
        variables: [
          ...wizardTemplate.variables,
          const TemplateVariable(
            key: 'start_date',
            displayName: 'Start Date',
            type: TemplateVariableType.date,
            isRequired: true,
          ),
        ],
        wizardSteps: [
          wizardTemplate.wizardSteps[0].copyWith(
            variableKeys: [...wizardTemplate.wizardSteps[0].variableKeys, 'start_date'],
          ),
          wizardTemplate.wizardSteps[1],
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ProjectTemplateWizard(
            template: templateWithDate,
            onProjectCreated: mockOnProjectCreated,
            onCancel: mockOnCancel,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show date picker field
      expect(find.text('Start Date'), findsOneWidget);
      expect(find.text('Select date'), findsOneWidget);
      
      // Tap on date field should trigger date picker
      await tester.tap(find.text('Select date'));
      await tester.pumpAndSettle();

      // Should show date picker dialog
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('should call onCancel when cancel is pressed', (tester) async {
      bool cancelCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ProjectTemplateWizard(
            template: simpleTemplate,
            onProjectCreated: mockOnProjectCreated,
            onCancel: () {
              cancelCalled = true;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(cancelCalled, isTrue);
    });

    testWidgets('should show loading state during project creation', (tester) async {
      bool projectCreated = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ProjectTemplateWizard(
            template: simpleTemplate,
            onProjectCreated: (project) async {
              // Simulate async operation
              await Future.delayed(const Duration(milliseconds: 100));
              projectCreated = true;
            },
            onCancel: mockOnCancel,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Fill required fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Project Name').first,
        'Test Project',
      );

      // Tap create project
      await tester.tap(find.text('Create Project'));
      await tester.pump(); // Don't settle to catch loading state

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Button should be disabled
      final createButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Create Project'),
      );
      expect(createButton.onPressed, isNull);

      await tester.pumpAndSettle();
      expect(projectCreated, isTrue);
    });

    testWidgets('should handle variable substitution correctly', (tester) async {
      Project? createdProject;
      
      await tester.pumpWidget(
        MaterialApp(
          home: ProjectTemplateWizard(
            template: simpleTemplate,
            onProjectCreated: (project) {
              createdProject = project;
            },
            onCancel: mockOnCancel,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Fill variables
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Project Name').first,
        'My Test Project',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Project Description').first,
        'This is a test project',
      );

      // Create project
      await tester.tap(find.text('Create Project'));
      await tester.pumpAndSettle();

      expect(createdProject, isNotNull);
      expect(createdProject!.name, equals('My Test Project Project'));
      expect(createdProject!.description, equals('This is a test project'));
    });

    testWidgets('should apply default values to variables', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProjectTemplateWizard(
            template: wizardTemplate, // Has default value for team_size
            onProjectCreated: mockOnProjectCreated,
            onCancel: mockOnCancel,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to second step
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Sprint Name').first,
        'My Sprint',
      );

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Team size field should have default value
      final teamSizeField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Team Size').first,
      );
      expect(teamSizeField.initialValue, equals('5'));
    });
  });
}