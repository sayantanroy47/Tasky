import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/entities/project_template.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_template.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/services/data_export/data_export_models.dart';
import 'package:task_tracker_app/services/data_export/template_export_service.dart';

void main() {
  late TemplateExportService templateService;
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('template_test_');
    templateService = TemplateExportService();
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  group('TemplateExportService', () {
    group('Project Template Export', () {
      test('should export project as template successfully', () async {
        // Arrange
        final project = Project(
          id: 'project_1',
          name: 'Test Project',
          description: 'A test project for template creation',
          color: '#FF0000',
          createdAt: DateTime(2024, 1, 1),
          deadline: DateTime(2024, 2, 1),
          taskIds: const ['task_1', 'task_2'],
        );

        final projectTasks = [
          TaskModel(
            id: 'task_1',
            title: 'Setup Task',
            description: 'Initial setup task',
            priority: TaskPriority.high,
            createdAt: DateTime(2024, 1, 1),
            estimatedDuration: 120,
            tags: const ['setup', 'important'],
            isPinned: false,
          ),
          TaskModel(
            id: 'task_2',
            title: 'Implementation Task',
            description: 'Main implementation work',
            priority: TaskPriority.medium,
            createdAt: DateTime(2024, 1, 2),
            estimatedDuration: 480,
            tags: const ['development'],
            isPinned: false,
          ),
        ];

        final filePath = path.join(tempDir.path, 'project_template.json');
        final templateMetadata = {
          'name': 'Development Project Template',
          'description': 'Template for development projects',
          'category': 'Software Development',
          'tags': ['development', 'template'],
          'difficulty': 3,
        };

        // Act
        final result = await templateService.exportProjectAsTemplate(
          project: project,
          projectTasks: projectTasks,
          filePath: filePath,
          templateMetadata: templateMetadata,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.filePath, equals(filePath));
        expect(result.fileSize, greaterThan(0));
        expect(result.message, contains('template exported successfully'));
        expect(result.metadata['templateName'], equals('Development Project Template'));
        expect(result.metadata['taskCount'], equals(2));

        // Verify file exists and has correct content
        final file = File(filePath);
        expect(file.existsSync(), isTrue);

        final content = await file.readAsString();
        expect(content, contains('Development Project Template'));
        expect(content, contains('Setup Task'));
        expect(content, contains('Implementation Task'));
        expect(content, contains('template_variables'));
        expect(content, contains('wizardSteps'));
      });

      test('should generate template variables correctly', () async {
        // Arrange
        final project = Project(
          id: 'project_var',
          name: 'Variable Test Project',
          description: 'Project for testing variable extraction',
          color: '#00FF00',
          createdAt: DateTime(2024, 1, 1),
          deadline: DateTime(2024, 3, 1),
          taskIds: const [],
        );

        final filePath = path.join(tempDir.path, 'variable_template.json');

        // Act
        final result = await templateService.exportProjectAsTemplate(
          project: project,
          projectTasks: [],
          filePath: filePath,
        );

        // Assert
        expect(result.success, isTrue);

        final file = File(filePath);
        final content = await file.readAsString();
        
        // Check for essential template variables
        expect(content, contains('projectName'));
        expect(content, contains('projectDescription'));
        expect(content, contains('startDate'));
        expect(content, contains('deadline'));
      });

      test('should create milestones from project data', () async {
        // Arrange
        final project = Project(
          id: 'project_milestone',
          name: 'Milestone Project',
          description: 'Project with milestones',
          color: '#0000FF',
          createdAt: DateTime(2024, 1, 1),
          deadline: DateTime(2024, 6, 1),
          taskIds: const ['urgent_task'],
        );

        final urgentTask = TaskModel(
          id: 'urgent_task',
          title: 'Critical Milestone Task',
          description: 'This is an urgent task that becomes a milestone',
          priority: TaskPriority.urgent,
          createdAt: DateTime(2024, 1, 1),
          dueDate: DateTime(2024, 2, 1),
          tags: const [],
          isPinned: false,
        );

        final filePath = path.join(tempDir.path, 'milestone_template.json');

        // Act
        final result = await templateService.exportProjectAsTemplate(
          project: project,
          projectTasks: [urgentTask],
          filePath: filePath,
        );

        // Assert
        expect(result.success, isTrue);

        final content = await File(filePath).readAsString();
        expect(content, contains('milestones'));
        expect(content, contains('Critical Milestone Task'));
        expect(content, contains('project_deadline'));
      });
    });

    group('Template Package Export', () {
      test('should export template package successfully', () async {
        // Arrange
        final templates = [
          ProjectTemplate(
            id: 'template_1',
            name: 'Web Development Template',
            description: 'Template for web development projects',
            type: ProjectTemplateType.simple,
            projectNameTemplate: '{{projectName}} Web App',
            createdAt: DateTime(2024, 1, 1),
            taskTemplates: [
              TaskTemplate(
                id: 'task_template_1',
                title: 'Setup Environment',
                description: 'Setup development environment',
                priority: TaskPriority.high,
                estimatedDuration: 60,
                tags: const ['setup'],
                category: 'development',
                createdAt: DateTime(2024, 1, 1),
              ),
            ],
            variables: const [
              TemplateVariable(
                key: 'projectName',
                displayName: 'Project Name',
                type: TemplateVariableType.text,
                isRequired: true,
              ),
            ],
            wizardSteps: const [
              TemplateWizardStep(
                id: 'basic_info',
                title: 'Basic Information',
                variableKeys: ['projectName'],
                order: 1,
              ),
            ],
            usageStats: const TemplateUsageStats(),
            sizeEstimate: const TemplateSizeEstimate(
              taskCount: 5,
              estimatedMemoryKb: 100,
              complexityCategory: 'simple',
              isLargeTemplate: false,
            ),
          ),
          ProjectTemplate(
            id: 'template_2',
            name: 'Mobile App Template',
            description: 'Template for mobile app development',
            type: ProjectTemplateType.wizard,
            projectNameTemplate: '{{projectName}} Mobile App',
            createdAt: DateTime(2024, 1, 2),
            taskTemplates: [
              TaskTemplate(
                id: 'task_template_2',
                title: 'Design UI/UX',
                description: 'Create app design',
                priority: TaskPriority.medium,
                estimatedDuration: 240,
                tags: const ['design'],
                category: 'design',
                createdAt: DateTime(2024, 1, 2),
              ),
            ],
            variables: const [
              TemplateVariable(
                key: 'platform',
                displayName: 'Platform',
                type: TemplateVariableType.choice,
                options: ['iOS', 'Android', 'Cross-platform'],
                isRequired: true,
              ),
            ],
            wizardSteps: const [
              TemplateWizardStep(
                id: 'platform_selection',
                title: 'Platform Selection',
                variableKeys: ['platform'],
                order: 1,
              ),
            ],
            usageStats: const TemplateUsageStats(),
            sizeEstimate: const TemplateSizeEstimate(
              taskCount: 10,
              estimatedMemoryKb: 200,
              complexityCategory: 'medium',
              isLargeTemplate: false,
            ),
          ),
        ];

        final packageInfo = TemplatePackage(
          id: 'package_dev',
          name: 'Development Templates Package',
          description: 'Collection of development project templates',
          version: '1.2.0',
          projectTemplateIds: templates.map((t) => t.id).toList(),
          taskTemplateIds: [],
          metadata: {
            'category': 'development',
            'license': 'MIT',
          },
          createdAt: DateTime(2024, 1, 1),
          authorId: 'dev_team',
          tags: ['development', 'templates', 'productivity'],
        );

        final filePath = path.join(tempDir.path, 'dev_package.json');

        // Act
        final result = await templateService.exportTemplatePackage(
          templates: templates,
          filePath: filePath,
          packageInfo: packageInfo,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.filePath, equals(filePath));
        expect(result.message, contains('package exported successfully'));
        expect(result.metadata['packageName'], equals('Development Templates Package'));
        expect(result.metadata['templateCount'], equals(2));

        // Verify file content
        final content = await File(filePath).readAsString();
        expect(content, contains('Development Templates Package'));
        expect(content, contains('Web Development Template'));
        expect(content, contains('Mobile App Template'));
        expect(content, contains('requiredFeatures'));
        expect(content, contains('checksum'));
      });

      test('should create compressed template package', () async {
        // Arrange
        final templates = [
          ProjectTemplate(
            id: 'compressed_template',
            name: 'Compressed Template',
            description: 'Template for compression testing',
            type: ProjectTemplateType.simple,
            projectNameTemplate: '{{projectName}}',
            createdAt: DateTime(2024, 1, 1),
            taskTemplates: const [],
            variables: const [],
            wizardSteps: const [],
            usageStats: const TemplateUsageStats(),
            sizeEstimate: const TemplateSizeEstimate(
              taskCount: 1,
              estimatedMemoryKb: 50,
              complexityCategory: 'simple',
              isLargeTemplate: false,
            ),
          ),
        ];

        final filePath = path.join(tempDir.path, 'compressed_package.taskytpl');

        // Act
        final result = await templateService.exportTemplatePackage(
          templates: templates,
          filePath: filePath,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.filePath, equals(filePath));
        expect(result.metadata['compressed'], isTrue);
        expect(result.metadata['format'], equals('taskytpl'));

        // Verify compressed file exists and has content
        final file = File(filePath);
        expect(file.existsSync(), isTrue);
        expect(file.lengthSync(), greaterThan(0));
      });

      test('should analyze required features correctly', () async {
        // Arrange - Create templates with various features
        final templates = [
          ProjectTemplate(
            id: 'feature_template',
            name: 'Feature Rich Template',
            description: 'Template with multiple features',
            type: ProjectTemplateType.advanced,
            projectNameTemplate: '{{projectName}}',
            createdAt: DateTime(2024, 1, 1),
            taskTemplates: [
              TaskTemplate(
                id: 'recurring_task',
                title: 'Recurring Task',
                priority: TaskPriority.medium,
                estimatedDuration: 60,
                tags: const [],
                category: 'maintenance',
                createdAt: DateTime(2024, 1, 1),
                isRecurring: true,
              ),
            ],
            variables: const [
              TemplateVariable(
                key: 'testVar',
                displayName: 'Test Variable',
                type: TemplateVariableType.text,
              ),
            ],
            wizardSteps: const [],
            milestones: const [
              ProjectMilestone(
                id: 'milestone_1',
                name: 'First Milestone',
                dayOffset: 30,
                requiredTaskIds: [],
              ),
            ],
            usageStats: const TemplateUsageStats(),
            sizeEstimate: const TemplateSizeEstimate(
              taskCount: 5,
              estimatedMemoryKb: 150,
              complexityCategory: 'advanced',
              isLargeTemplate: false,
            ),
          ),
        ];

        final filePath = path.join(tempDir.path, 'feature_analysis.json');

        // Act
        final result = await templateService.exportTemplatePackage(
          templates: templates,
          filePath: filePath,
        );

        // Assert
        expect(result.success, isTrue);

        final content = await File(filePath).readAsString();
        expect(content, contains('requiredFeatures'));
        expect(content, contains('recurring_tasks'));
        expect(content, contains('milestones'));
        expect(content, contains('template_variables'));
      });
    });

    group('Task Templates Export', () {
      test('should export task templates collection', () async {
        // Arrange
        final taskTemplates = [
          TaskTemplate(
            id: 'task_template_1',
            title: 'Code Review Task',
            description: 'Perform code review for {{pullRequestNumber}}',
            priority: TaskPriority.high,
            estimatedDuration: 30,
            tags: const ['review', 'quality'],
            category: 'development',
            createdAt: DateTime(2024, 1, 1),
          ),
          TaskTemplate(
            id: 'task_template_2',
            title: 'Testing Task',
            description: 'Write tests for {{featureName}}',
            priority: TaskPriority.medium,
            estimatedDuration: 120,
            tags: const ['testing', 'quality'],
            category: 'development',
            createdAt: DateTime(2024, 1, 2),
          ),
        ];

        final filePath = path.join(tempDir.path, 'task_templates.json');
        final metadata = {
          'name': 'Development Task Templates',
          'description': 'Common development tasks',
          'category': 'Software Development',
        };

        // Act
        final result = await templateService.exportTaskTemplates(
          templates: taskTemplates,
          filePath: filePath,
          metadata: metadata,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.filePath, equals(filePath));
        expect(result.metadata['templateCount'], equals(2));

        final content = await File(filePath).readAsString();
        expect(content, contains('Development Task Templates'));
        expect(content, contains('Code Review Task'));
        expect(content, contains('Testing Task'));
        expect(content, contains('{{pullRequestNumber}}'));
        expect(content, contains('{{featureName}}'));
      });
    });

    group('Marketplace Integration', () {
      test('should create marketplace-ready package', () async {
        // Arrange
        final templates = [
          ProjectTemplate(
            id: 'marketplace_template',
            name: 'E-commerce Project Template',
            description: 'Complete e-commerce project setup',
            type: ProjectTemplateType.wizard,
            projectNameTemplate: '{{storeName}} E-commerce',
            createdAt: DateTime(2024, 1, 1),
            taskTemplates: [
              TaskTemplate(
                id: 'ecommerce_task',
                title: 'Setup Payment Gateway',
                description: 'Configure payment processing',
                priority: TaskPriority.high,
                estimatedDuration: 180,
                tags: const ['payment', 'integration'],
                category: 'backend',
                createdAt: DateTime(2024, 1, 1),
              ),
            ],
            variables: const [
              TemplateVariable(
                key: 'storeName',
                displayName: 'Store Name',
                type: TemplateVariableType.text,
                isRequired: true,
              ),
            ],
            wizardSteps: const [],
            usageStats: const TemplateUsageStats(),
            sizeEstimate: const TemplateSizeEstimate(
              taskCount: 15,
              estimatedMemoryKb: 300,
              complexityCategory: 'complex',
              isLargeTemplate: false,
            ),
          ),
        ];

        final marketplaceMetadata = {
          'id': 'ecommerce_template_v1',
          'name': 'E-commerce Starter Pack',
          'description': 'Everything needed to start an e-commerce project',
          'version': '1.0.0',
          'authorId': 'template_store',
          'tags': ['ecommerce', 'business', 'web'],
          'pricing': 'premium',
          'license': 'Commercial',
          'supportContact': 'support@templatestore.com',
          'screenshots': ['screen1.png', 'screen2.png'],
          'documentation': 'https://docs.templatestore.com/ecommerce',
        };

        final filePath = path.join(tempDir.path, 'marketplace_package.taskytpl');

        // Act
        final result = await templateService.createMarketplacePackage(
          templates: templates,
          filePath: filePath,
          marketplaceMetadata: marketplaceMetadata,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.filePath, equals(filePath));

        // Verify the package contains marketplace metadata
        // Note: Since it's compressed, we can't easily read the content in tests
        // but we can verify the file was created successfully
        final file = File(filePath);
        expect(file.existsSync(), isTrue);
        expect(file.lengthSync(), greaterThan(500));
      });
    });

    group('Template Import', () {
      test('should validate template structure during import', () async {
        // Arrange
        final invalidTemplateFile = File(path.join(tempDir.path, 'invalid_template.json'));
        await invalidTemplateFile.writeAsString('''
        {
          "version": "1.0",
          "type": "invalid_template",
          "template": {}
        }
        ''');

        // Act
        final result = await templateService.importProjectTemplate(
          filePath: invalidTemplateFile.path,
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.message, contains('Invalid template file format'));
        expect(result.importedCount, equals(0));
      });

      test('should handle missing template file', () async {
        // Arrange
        final nonExistentPath = path.join(tempDir.path, 'missing_template.json');

        // Act
        final result = await templateService.importProjectTemplate(
          filePath: nonExistentPath,
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.message, contains('Template file not found'));
        expect(result.errors, contains('File does not exist'));
      });

      test('should import valid template package', () async {
        // Arrange - First export a package, then import it
        final templates = [
          ProjectTemplate(
            id: 'import_test_template',
            name: 'Import Test Template',
            description: 'Template for import testing',
            type: ProjectTemplateType.simple,
            projectNameTemplate: '{{projectName}}',
            createdAt: DateTime(2024, 1, 1),
            taskTemplates: const [],
            variables: const [],
            wizardSteps: const [],
            usageStats: const TemplateUsageStats(),
            sizeEstimate: const TemplateSizeEstimate(
              taskCount: 1,
              estimatedMemoryKb: 50,
              complexityCategory: 'simple',
              isLargeTemplate: false,
            ),
          ),
        ];

        final exportPath = path.join(tempDir.path, 'export_for_import.json');
        await templateService.exportTemplatePackage(
          templates: templates,
          filePath: exportPath,
        );

        // Act
        final result = await templateService.importTemplatePackage(
          filePath: exportPath,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.importedCount, equals(1));
        expect(result.message, contains('Template package imported'));
      });
    });

    group('Error Handling', () {
      test('should handle export errors gracefully', () async {
        // Arrange - Try to export to an invalid path
        final project = Project(
          id: 'error_test',
          name: 'Error Test Project',
          color: '#FF0000',
          createdAt: DateTime(2024, 1, 1),
          taskIds: const [],
        );

        final invalidPath = path.join('/invalid_directory', 'template.json');

        // Act
        final result = await templateService.exportProjectAsTemplate(
          project: project,
          projectTasks: [],
          filePath: invalidPath,
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.message, contains('Template export failed'));
        expect(result.filePath, isNull);
        expect(result.fileSize, equals(0));
      });

      test('should handle template package export errors', () async {
        // Arrange
        final templates = [
          ProjectTemplate(
            id: 'error_template',
            name: 'Error Template',
            type: ProjectTemplateType.simple,
            projectNameTemplate: '{{projectName}}',
            createdAt: DateTime(2024, 1, 1),
            taskTemplates: const [],
            variables: const [],
            wizardSteps: const [],
            usageStats: const TemplateUsageStats(),
            sizeEstimate: const TemplateSizeEstimate(
              taskCount: 1,
              estimatedMemoryKb: 50,
              complexityCategory: 'simple',
              isLargeTemplate: false,
            ),
          ),
        ];

        final invalidPath = path.join('/invalid_directory', 'package.json');

        // Act
        final result = await templateService.exportTemplatePackage(
          templates: templates,
          filePath: invalidPath,
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.message, contains('export failed'));
      });
    });
  });

  group('Template Conversion', () {
    test('should convert project to template format correctly', () async {
      // Arrange
      final project = Project(
        id: 'conversion_test',
        name: 'Conversion Test Project',
        description: 'Project for conversion testing',
        color: '#123456',
        categoryId: 'work_category',
        createdAt: DateTime(2024, 1, 1),
        deadline: DateTime(2024, 3, 1),
        taskIds: const ['task_1'],
      );

      final task = TaskModel(
        id: 'task_1',
        title: 'Sample Task - 2024-01-15',
        description: 'Complete 5 items by deadline',
        priority: TaskPriority.high,
        createdAt: DateTime(2024, 1, 1),
        estimatedDuration: 120,
        tags: const ['conversion', 'test'],
        isPinned: false,
      );

      final filePath = path.join(tempDir.path, 'conversion_template.json');

      // Act
      final result = await templateService.exportProjectAsTemplate(
        project: project,
        projectTasks: [task],
        filePath: filePath,
        templateMetadata: {
          'templateName': 'Conversion Template',
          'templateDescription': 'Template from conversion test',
        },
      );

      // Assert
      expect(result.success, isTrue);

      final content = await File(filePath).readAsString();
      
      // Check that dynamic content is converted to template variables
      expect(content, contains('{{date}}'));  // Date should be templated
      expect(content, contains('{{number}}')); // Numbers should be templated
      expect(content, contains('projectName'));
      expect(content, contains('projectDescription'));
      expect(content, contains('startDate'));
      expect(content, contains('deadline'));
      
      // Check that original project data is preserved in source
      expect(content, contains('Conversion Test Project'));
      expect(content, contains('#123456'));
      expect(content, contains('work_category'));
    });
  });
}