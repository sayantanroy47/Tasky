import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/entities/project_template.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_template.dart';
import 'package:task_tracker_app/domain/repositories/project_repository.dart';
import 'package:task_tracker_app/domain/repositories/project_template_repository.dart';
import 'package:task_tracker_app/domain/repositories/task_repository.dart';
import 'package:task_tracker_app/domain/repositories/task_template_repository.dart';
import 'package:task_tracker_app/services/project_template_service.dart';

@GenerateNiceMocks([
  MockSpec<ProjectTemplateRepository>(),
  MockSpec<ProjectRepository>(),
  MockSpec<TaskRepository>(),
  MockSpec<TaskTemplateRepository>(),
])
import 'project_template_service_test.mocks.dart';

void main() {
  group('ProjectTemplateService', () {
    late ProjectTemplateService service;
    late MockProjectTemplateRepository mockTemplateRepo;
    late MockProjectRepository mockProjectRepo;
    late MockTaskRepository mockTaskRepo;
    late MockTaskTemplateRepository mockTaskTemplateRepo;

    setUp(() {
      mockTemplateRepo = MockProjectTemplateRepository();
      mockProjectRepo = MockProjectRepository();
      mockTaskRepo = MockTaskRepository();
      mockTaskTemplateRepo = MockTaskTemplateRepository();
      
      service = ProjectTemplateService(
        templateRepository: mockTemplateRepo,
        projectRepository: mockProjectRepo,
        taskRepository: mockTaskRepo,
        taskTemplateRepository: mockTaskTemplateRepo,
      );
    });

    group('createTemplate', () {
      test('should create valid template', () async {
        final template = ProjectTemplate.create(
          name: 'Test Template',
          projectNameTemplate: '{{project_name}} Project',
        );

        when(mockTemplateRepo.create(any)).thenAnswer((_) async => template);

        final result = await service.createTemplate(template);

        expect(result, equals(template));
        verify(mockTemplateRepo.create(template)).called(1);
      });

      test('should throw error for invalid template', () async {
        final template = ProjectTemplate.create(
          name: '', // Invalid empty name
          projectNameTemplate: '{{project_name}} Project',
        );

        expect(
          () => service.createTemplate(template),
          throwsA(isA<ArgumentError>()),
        );
        
        verifyNever(mockTemplateRepo.create(any));
      });
    });

    group('updateTemplate', () {
      test('should update user template', () async {
        final template = ProjectTemplate.create(
          name: 'Updated Template',
          projectNameTemplate: '{{project_name}} Project',
        );

        when(mockTemplateRepo.update(any)).thenAnswer((_) async => template);

        final result = await service.updateTemplate(template);

        expect(result, equals(template));
        verify(mockTemplateRepo.update(template)).called(1);
      });

      test('should throw error for system template', () async {
        final template = ProjectTemplate.create(
          name: 'System Template',
          projectNameTemplate: '{{project_name}} Project',
        ).copyWith(isSystemTemplate: true);

        expect(
          () => service.updateTemplate(template),
          throwsA(isA<StateError>()),
        );
        
        verifyNever(mockTemplateRepo.update(any));
      });

      test('should throw error for invalid template', () async {
        final template = ProjectTemplate.create(
          name: 'Test Template',
          projectNameTemplate: '', // Invalid empty project name template
        );

        expect(
          () => service.updateTemplate(template),
          throwsA(isA<ArgumentError>()),
        );
        
        verifyNever(mockTemplateRepo.update(any));
      });
    });

    group('deleteTemplate', () {
      test('should delete user template', () async {
        const templateId = 'test-template-id';
        final template = ProjectTemplate.create(
          name: 'Test Template',
          projectNameTemplate: '{{project_name}} Project',
        ).copyWith(id: templateId);

        when(mockTemplateRepo.findById(templateId))
            .thenAnswer((_) async => template);
        when(mockTemplateRepo.delete(templateId)).thenAnswer((_) async {});

        await service.deleteTemplate(templateId);

        verify(mockTemplateRepo.findById(templateId)).called(1);
        verify(mockTemplateRepo.delete(templateId)).called(1);
      });

      test('should throw error for non-existent template', () async {
        const templateId = 'non-existent-id';

        when(mockTemplateRepo.findById(templateId))
            .thenAnswer((_) async => null);

        expect(
          () => service.deleteTemplate(templateId),
          throwsA(isA<ArgumentError>()),
        );
        
        verify(mockTemplateRepo.findById(templateId)).called(1);
        verifyNever(mockTemplateRepo.delete(any));
      });

      test('should throw error for system template', () async {
        const templateId = 'system-template-id';
        final template = ProjectTemplate.create(
          name: 'System Template',
          projectNameTemplate: '{{project_name}} Project',
        ).copyWith(id: templateId, isSystemTemplate: true);

        when(mockTemplateRepo.findById(templateId))
            .thenAnswer((_) async => template);

        expect(
          () => service.deleteTemplate(templateId),
          throwsA(isA<StateError>()),
        );
        
        verify(mockTemplateRepo.findById(templateId)).called(1);
        verifyNever(mockTemplateRepo.delete(any));
      });
    });

    group('getTemplates', () {
      test('should return filtered templates', () async {
        final templates = [
          ProjectTemplate.create(
            name: 'Template 1',
            projectNameTemplate: 'Project 1',
          ),
          ProjectTemplate.create(
            name: 'Template 2',
            projectNameTemplate: 'Project 2',
          ),
        ];

        when(mockTemplateRepo.findAll(
          categoryId: 'category1',
          type: ProjectTemplateType.simple,
          isPublished: true,
        )).thenAnswer((_) async => templates);

        final result = await service.getTemplates(
          categoryId: 'category1',
          type: ProjectTemplateType.simple,
          isPublished: true,
        );

        expect(result, equals(templates));
        verify(mockTemplateRepo.findAll(
          categoryId: 'category1',
          type: ProjectTemplateType.simple,
          isPublished: true,
        )).called(1);
      });
    });

    group('getPopularTemplates', () {
      test('should return sorted popular templates', () async {
        final templates = [
          ProjectTemplate.create(
            name: 'Popular Template',
            projectNameTemplate: 'Popular Project',
          ).copyWith(
            usageStats: TemplateUsageStats.initial().incrementUsage(),
          ),
          ProjectTemplate.create(
            name: 'Less Popular Template',
            projectNameTemplate: 'Less Popular Project',
          ),
        ];

        when(mockTemplateRepo.findAll(isPublished: true))
            .thenAnswer((_) async => templates);

        final result = await service.getPopularTemplates(limit: 5);

        expect(result.length, lessThanOrEqualTo(5));
        verify(mockTemplateRepo.findAll(isPublished: true)).called(1);
      });
    });

    group('createProjectFromTemplate', () {
      test('should create project with variable substitution', () async {
        final taskTemplate = TaskTemplate.create(
          name: 'Test Task',
          titleTemplate: '{{task_name}} for {{project_name}}',
        );

        final template = ProjectTemplate.create(
          name: 'Test Template',
          projectNameTemplate: '{{project_name}} Project',
          projectDescriptionTemplate: 'A project for {{client_name}}',
          taskTemplates: [taskTemplate],
          variables: const [
            TemplateVariable(
              key: 'project_name',
              displayName: 'Project Name',
              type: TemplateVariableType.text,
              isRequired: true,
            ),
            TemplateVariable(
              key: 'client_name',
              displayName: 'Client Name',
              type: TemplateVariableType.text,
              isRequired: true,
            ),
            TemplateVariable(
              key: 'task_name',
              displayName: 'Task Name',
              type: TemplateVariableType.text,
              isRequired: true,
            ),
          ],
        );

        final variables = {
          'project_name': 'My Project',
          'client_name': 'Client ABC',
          'task_name': 'Setup Task',
        };

        when(mockProjectRepo.createProject(any)).thenAnswer((_) async {});

        when(mockTaskRepo.createTask(any)).thenAnswer((_) async {});

        when(mockProjectRepo.updateProject(any)).thenAnswer((_) async {});

        when(mockTemplateRepo.update(any))
            .thenAnswer((invocation) async => 
                invocation.positionalArguments[0] as ProjectTemplate);

        final result = await service.createProjectFromTemplate(
          template,
          variables,
        );

        expect(result.name, equals('My Project Project'));
        expect(result.description, equals('A project for Client ABC'));
        expect(result.color, equals(template.defaultColor));

        verify(mockProjectRepo.createProject(any)).called(1);
        verify(mockTaskRepo.createTask(any)).called(1);
        verify(mockProjectRepo.updateProject(any)).called(1);
        verify(mockTemplateRepo.update(any)).called(1); // Usage increment
      });

      test('should throw error for missing required variables', () async {
        final variables = [
          const TemplateVariable(
            key: 'project_name',
            displayName: 'Project Name',
            type: TemplateVariableType.text,
            isRequired: true,
          ),
        ];

        final template = ProjectTemplate.create(
          name: 'Test Template',
          projectNameTemplate: '{{project_name}} Project',
          variables: variables,
        );

        // Missing required project_name variable
        final incompleteVariables = <String, dynamic>{};

        expect(
          () => service.createProjectFromTemplate(template, incompleteVariables),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('wizard validation', () {
      test('validateWizardStep should validate required variables', () async {
        final variables = [
          const TemplateVariable(
            key: 'required_var',
            displayName: 'Required Variable',
            type: TemplateVariableType.text,
            isRequired: true,
          ),
          const TemplateVariable(
            key: 'optional_var',
            displayName: 'Optional Variable',
            type: TemplateVariableType.text,
            isRequired: false,
          ),
        ];

        const step = TemplateWizardStep(
          id: 'step1',
          title: 'Step 1',
          variableKeys: ['required_var', 'optional_var'],
          order: 0,
        );

        final template = ProjectTemplate.create(
          name: 'Wizard Template',
          projectNameTemplate: 'Wizard Project',
          type: ProjectTemplateType.wizard,
          variables: variables,
          wizardSteps: const [step],
        );

        // Valid step values
        final validValues = {
          'required_var': 'Some Value',
          'optional_var': 'Optional Value',
        };

        final isValid = await service.validateWizardStep(
          template,
          'step1',
          validValues,
        );

        expect(isValid, isTrue);

        // Invalid step values (missing required)
        final invalidValues = {
          'optional_var': 'Optional Value',
        };

        final isInvalid = await service.validateWizardStep(
          template,
          'step1',
          invalidValues,
        );

        expect(isInvalid, isFalse);
      });

      test('getNextWizardStep should return correct next step', () async {
        final steps = [
          const TemplateWizardStep(
            id: 'step1',
            title: 'Step 1',
            variableKeys: [],
            order: 0,
          ),
          const TemplateWizardStep(
            id: 'step2',
            title: 'Step 2',
            variableKeys: [],
            order: 1,
          ),
          const TemplateWizardStep(
            id: 'step3',
            title: 'Step 3',
            variableKeys: [],
            order: 2,
          ),
        ];

        final template = ProjectTemplate.create(
          name: 'Wizard Template',
          projectNameTemplate: 'Wizard Project',
          type: ProjectTemplateType.wizard,
          wizardSteps: steps,
        );

        final nextStep = service.getNextWizardStep(template, 'step1', {});
        expect(nextStep, equals('step2'));

        final lastStep = service.getNextWizardStep(template, 'step3', {});
        expect(lastStep, isNull);
      });

      test('getWizardProgress should calculate correct progress', () async {
        final steps = [
          const TemplateWizardStep(
            id: 'step1',
            title: 'Step 1',
            variableKeys: [],
            order: 0,
          ),
          const TemplateWizardStep(
            id: 'step2',
            title: 'Step 2',
            variableKeys: [],
            order: 1,
          ),
          const TemplateWizardStep(
            id: 'step3',
            title: 'Step 3',
            variableKeys: [],
            order: 2,
          ),
        ];

        final template = ProjectTemplate.create(
          name: 'Wizard Template',
          projectNameTemplate: 'Wizard Project',
          type: ProjectTemplateType.wizard,
          wizardSteps: steps,
        );

        final progress1 = service.getWizardProgress(template, 'step1', {});
        expect(progress1, closeTo(0.33, 0.01));

        final progress2 = service.getWizardProgress(template, 'step2', {});
        expect(progress2, closeTo(0.67, 0.01));

        final progress3 = service.getWizardProgress(template, 'step3', {});
        expect(progress3, equals(1.0));
      });
    });

    group('createTemplateFromProject', () {
      test('should create template from existing project', () async {
        final project = Project.create(
          name: 'Existing Project',
          description: 'An existing project',
          color: '#FF5722',
        );

        final tasks = [
          TaskModel.create(
            title: 'Task 1',
            description: 'First task',
            projectId: project.id,
          ),
          TaskModel.create(
            title: 'Task 2',
            description: 'Second task',
            projectId: project.id,
          ),
        ];

        when(mockTaskRepo.getTasksByProject(project.id))
            .thenAnswer((_) async => tasks);

        when(mockTemplateRepo.create(any))
            .thenAnswer((invocation) async => 
                invocation.positionalArguments[0] as ProjectTemplate);

        final result = await service.createTemplateFromProject(
          project,
          'Project Template',
          description: 'Template from existing project',
        );

        expect(result.name, equals('Project Template'));
        expect(result.description, equals('Template from existing project'));
        expect(result.projectNameTemplate, equals('Existing Project'));
        expect(result.defaultColor, equals('#FF5722'));
        expect(result.taskTemplates.length, equals(2));

        verify(mockTaskRepo.getTasksByProject(project.id)).called(1);
        verify(mockTemplateRepo.create(any)).called(1);
      });
    });

    group('seedSystemTemplates', () {
      test('should seed system templates', () async {
        when(mockTemplateRepo.findById(any))
            .thenAnswer((_) async => null); // No existing templates
        when(mockTemplateRepo.create(any))
            .thenAnswer((invocation) async => 
                invocation.positionalArguments[0] as ProjectTemplate);

        await service.seedSystemTemplates();

        // Should create multiple system templates
        verify(mockTemplateRepo.create(any)).called(greaterThan(1));
      });

      test('should not recreate existing system templates', () async {
        final existingTemplate = ProjectTemplate.create(
          name: 'Existing System Template',
          projectNameTemplate: 'Existing Project',
        );

        when(mockTemplateRepo.findById(any))
            .thenAnswer((_) async => existingTemplate);

        await service.seedSystemTemplates();

        // Should not create templates that already exist
        verifyNever(mockTemplateRepo.create(any));
      });
    });
  });
}