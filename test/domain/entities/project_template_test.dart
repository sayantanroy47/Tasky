import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/domain/entities/project_template.dart';
import 'package:task_tracker_app/domain/entities/task_template.dart';

void main() {
  group('ProjectTemplate', () {
    late ProjectTemplate template;
    late TemplateUsageStats usageStats;
    late TemplateSizeEstimate sizeEstimate;

    setUp(() {
      usageStats = TemplateUsageStats.initial();
      sizeEstimate = TemplateSizeEstimate.calculate(const []);
      
      template = ProjectTemplate(
        id: 'test-template-id',
        name: 'Test Template',
        description: 'A test project template',
        type: ProjectTemplateType.simple,
        projectNameTemplate: '{{project_name}} Project',
        createdAt: DateTime.now(),
        usageStats: usageStats,
        sizeEstimate: sizeEstimate,
      );
    });

    group('factory constructors', () {
      test('create() should create a valid template with defaults', () {
        final created = ProjectTemplate.create(
          name: 'New Template',
          projectNameTemplate: 'New {{name}} Project',
        );

        expect(created.name, equals('New Template'));
        expect(created.projectNameTemplate, equals('New {{name}} Project'));
        expect(created.type, equals(ProjectTemplateType.simple));
        expect(created.difficultyLevel, equals(1));
        expect(created.defaultColor, equals('#2196F3'));
        expect(created.isSystemTemplate, isFalse);
        expect(created.isPublished, isFalse);
        expect(created.version, equals('1.0.0'));
        expect(created.id, isNotEmpty);
        expect(created.usageStats.usageCount, equals(0));
      });
    });

    group('validation', () {
      test('isValid() should return true for valid template', () {
        expect(template.isValid(), isTrue);
      });

      test('isValid() should return false for empty name', () {
        final invalidTemplate = template.copyWith(name: '');
        expect(invalidTemplate.isValid(), isFalse);
      });

      test('isValid() should return false for empty project name template', () {
        final invalidTemplate = template.copyWith(projectNameTemplate: '');
        expect(invalidTemplate.isValid(), isFalse);
      });

      test('isValid() should return false for invalid color', () {
        final invalidTemplate = template.copyWith(defaultColor: 'invalid-color');
        expect(invalidTemplate.isValid(), isFalse);
      });

      test('isValid() should return false for invalid difficulty level', () {
        final invalidTemplate = template.copyWith(difficultyLevel: 0);
        expect(invalidTemplate.isValid(), isFalse);

        final invalidTemplate2 = template.copyWith(difficultyLevel: 6);
        expect(invalidTemplate2.isValid(), isFalse);
      });

      test('isValid() should return false for wizard without steps', () {
        final wizardTemplate = template.copyWith(
          type: ProjectTemplateType.wizard,
          wizardSteps: [],
        );
        expect(wizardTemplate.isValid(), isFalse);
      });

      test('isValid() should validate wizard step ordering', () {
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
            order: 2, // Should be 1
          ),
        ];

        final wizardTemplate = template.copyWith(
          type: ProjectTemplateType.wizard,
          wizardSteps: steps,
        );
        expect(wizardTemplate.isValid(), isFalse);
      });
    });

    group('properties', () {
      test('hasTasks should return correct values', () {
        expect(template.hasTasks, isFalse);

        final withTasks = template.copyWith(
          taskTemplates: [
            TaskTemplate.create(
              name: 'Test Task',
              titleTemplate: 'Test Task Title',
            ),
          ],
        );
        expect(withTasks.hasTasks, isTrue);
      });

      test('hasVariables should return correct values', () {
        expect(template.hasVariables, isFalse);

        final withVariables = template.copyWith(
          variables: [
            const TemplateVariable(
              key: 'test_var',
              displayName: 'Test Variable',
              type: TemplateVariableType.text,
            ),
          ],
        );
        expect(withVariables.hasVariables, isTrue);
      });

      test('isWizard should return correct values', () {
        expect(template.isWizard, isFalse);

        final wizardTemplate = template.copyWith(
          type: ProjectTemplateType.wizard,
        );
        expect(wizardTemplate.isWizard, isTrue);
      });

      test('canModify should return correct values', () {
        expect(template.canModify, isTrue);

        final systemTemplate = template.copyWith(isSystemTemplate: true);
        expect(systemTemplate.canModify, isFalse);
      });

      test('complexityScore should calculate correctly', () {
        final complexTemplate = template.copyWith(
          taskTemplates: [
            TaskTemplate.create(name: 'Task 1', titleTemplate: 'Task 1'),
            TaskTemplate.create(name: 'Task 2', titleTemplate: 'Task 2'),
          ],
          variables: [
            const TemplateVariable(
              key: 'var1',
              displayName: 'Variable 1',
              type: TemplateVariableType.text,
            ),
          ],
          wizardSteps: [
            const TemplateWizardStep(
              id: 'step1',
              title: 'Step 1',
              variableKeys: [],
              order: 0,
            ),
          ],
          taskDependencies: {'task1': ['task2']},
          milestones: [
            const ProjectMilestone(
              id: 'milestone1',
              name: 'Milestone 1',
              dayOffset: 7,
            ),
          ],
        );

        // 2 tasks * 2 + 1 variable + 1 step * 3 + 1 dependency + 1 milestone * 2 = 11
        expect(complexTemplate.complexityScore, equals(11));
      });
    });

    group('variable operations', () {
      test('getVariablesForStep should return correct variables', () {
        final variables = [
          const TemplateVariable(
            key: 'var1',
            displayName: 'Variable 1',
            type: TemplateVariableType.text,
          ),
          const TemplateVariable(
            key: 'var2',
            displayName: 'Variable 2',
            type: TemplateVariableType.text,
          ),
        ];

        const step = TemplateWizardStep(
          id: 'step1',
          title: 'Step 1',
          variableKeys: ['var1'],
          order: 0,
        );

        final wizardTemplate = template.copyWith(
          type: ProjectTemplateType.wizard,
          variables: variables,
          wizardSteps: [step],
        );

        final stepVariables = wizardTemplate.getVariablesForStep('step1');
        expect(stepVariables.length, equals(1));
        expect(stepVariables.first.key, equals('var1'));
      });

      test('replaceVariables should substitute variables correctly', () {
        final variables = [
          const TemplateVariable(
            key: 'project_name',
            displayName: 'Project Name',
            type: TemplateVariableType.text,
          ),
          const TemplateVariable(
            key: 'team_size',
            displayName: 'Team Size',
            type: TemplateVariableType.number,
          ),
        ];

        final templateWithVars = template.copyWith(variables: variables);
        
        final result = templateWithVars.replaceVariables(
          'Creating {{project_name}} for {{team_size}} members',
          {
            'project_name': 'My Project',
            'team_size': 5,
          },
        );

        expect(result, equals('Creating My Project for 5 members'));
      });

      test('replaceVariables should handle date placeholders', () {
        final today = DateTime.now();
        final tomorrow = today.add(const Duration(days: 1));
        
        final result = template.replaceVariables(
          'Starting {{today}} and ending {{tomorrow}}',
          {},
        );

        final expectedToday = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        final expectedTomorrow = '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
        
        expect(result, equals('Starting $expectedToday and ending $expectedTomorrow'));
      });
    });

    group('usage tracking', () {
      test('incrementUsage should update stats', () {
        final updated = template.incrementUsage();
        
        expect(updated.usageStats.usageCount, equals(1));
        expect(updated.usageStats.lastUsed, isNotNull);
        expect(updated.updatedAt, isNotNull);
      });

      test('updateRating should update rating info', () {
        final updated = template.updateRating(4.5, 10);
        
        expect(updated.rating, isNotNull);
        expect(updated.rating!.averageRating, equals(4.5));
        expect(updated.rating!.totalReviews, equals(10));
        expect(updated.updatedAt, isNotNull);
      });
    });

    group('publication', () {
      test('publish should mark as published', () {
        expect(template.isPublished, isFalse);
        
        final published = template.publish();
        
        expect(published.isPublished, isTrue);
        expect(published.updatedAt, isNotNull);
      });

      test('unpublish should mark as unpublished', () {
        final published = template.copyWith(isPublished: true);
        expect(published.isPublished, isTrue);
        
        final unpublished = published.unpublish();
        
        expect(unpublished.isPublished, isFalse);
        expect(unpublished.updatedAt, isNotNull);
      });
    });

    group('serialization', () {
      test('toJson and fromJson should work correctly', () {
        final json = template.toJson();
        final deserialized = ProjectTemplate.fromJson(json);
        
        expect(deserialized.id, equals(template.id));
        expect(deserialized.name, equals(template.name));
        expect(deserialized.description, equals(template.description));
        expect(deserialized.type, equals(template.type));
        expect(deserialized.projectNameTemplate, equals(template.projectNameTemplate));
        expect(deserialized.defaultColor, equals(template.defaultColor));
        expect(deserialized.isSystemTemplate, equals(template.isSystemTemplate));
        expect(deserialized.isPublished, equals(template.isPublished));
        expect(deserialized.version, equals(template.version));
      });

      test('copyWith should create modified copy', () {
        final modified = template.copyWith(
          name: 'Modified Template',
          description: 'Modified description',
          difficultyLevel: 3,
        );

        expect(modified.name, equals('Modified Template'));
        expect(modified.description, equals('Modified description'));
        expect(modified.difficultyLevel, equals(3));
        
        // Original unchanged
        expect(template.name, equals('Test Template'));
        expect(template.description, equals('A test project template'));
        expect(template.difficultyLevel, equals(1));
        
        // Other fields unchanged
        expect(modified.id, equals(template.id));
        expect(modified.type, equals(template.type));
      });
    });
  });

  group('TemplateVariable', () {
    test('should create valid variable', () {
      const variable = TemplateVariable(
        key: 'test_key',
        displayName: 'Test Variable',
        type: TemplateVariableType.text,
        isRequired: true,
        defaultValue: 'default',
      );

      expect(variable.key, equals('test_key'));
      expect(variable.displayName, equals('Test Variable'));
      expect(variable.type, equals(TemplateVariableType.text));
      expect(variable.isRequired, isTrue);
      expect(variable.defaultValue, equals('default'));
    });
  });

  group('TemplateWizardStep', () {
    test('should create valid wizard step', () {
      const step = TemplateWizardStep(
        id: 'step1',
        title: 'Test Step',
        description: 'Test step description',
        variableKeys: ['var1', 'var2'],
        order: 0,
        isOptional: false,
      );

      expect(step.id, equals('step1'));
      expect(step.title, equals('Test Step'));
      expect(step.description, equals('Test step description'));
      expect(step.variableKeys, equals(['var1', 'var2']));
      expect(step.order, equals(0));
      expect(step.isOptional, isFalse);
    });
  });

  group('ProjectMilestone', () {
    test('should create valid milestone', () {
      const milestone = ProjectMilestone(
        id: 'milestone1',
        name: 'Test Milestone',
        description: 'Test milestone description',
        dayOffset: 7,
        requiredTaskIds: ['task1', 'task2'],
      );

      expect(milestone.id, equals('milestone1'));
      expect(milestone.name, equals('Test Milestone'));
      expect(milestone.description, equals('Test milestone description'));
      expect(milestone.dayOffset, equals(7));
      expect(milestone.requiredTaskIds, equals(['task1', 'task2']));
    });
  });

  group('TemplateUsageStats', () {
    test('initial should create empty stats', () {
      final stats = TemplateUsageStats.initial();

      expect(stats.usageCount, equals(0));
      expect(stats.favoriteCount, equals(0));
      expect(stats.successfulCompletions, equals(0));
      expect(stats.averageCompletionRate, equals(0.0));
      expect(stats.lastUsed, isNull);
      expect(stats.trendingScore, equals(0.0));
    });

    test('incrementUsage should increase count and update trending', () {
      final stats = TemplateUsageStats.initial();
      final incremented = stats.incrementUsage();

      expect(incremented.usageCount, equals(1));
      expect(incremented.lastUsed, isNotNull);
      expect(incremented.trendingScore, greaterThan(0));
    });

    test('incrementFavorites should increase favorite count', () {
      final stats = TemplateUsageStats.initial();
      final incremented = stats.incrementFavorites();

      expect(incremented.favoriteCount, equals(1));
      expect(incremented.usageCount, equals(0)); // Unchanged
    });
  });

  group('TemplateRating', () {
    test('initial should create empty rating', () {
      final rating = TemplateRating.initial();

      expect(rating.averageRating, equals(0.0));
      expect(rating.totalReviews, equals(0));
      expect(rating.ratingDistribution, isEmpty);
      expect(rating.featuredReviews, isEmpty);
    });

    test('update should change rating values', () {
      final rating = TemplateRating.initial();
      final updated = rating.update(4.5, 10);

      expect(updated.averageRating, equals(4.5));
      expect(updated.totalReviews, equals(10));
    });
  });

  group('TemplateSizeEstimate', () {
    test('calculate should estimate size correctly', () {
      final tasks = [
        TaskTemplate.create(name: 'Task 1', titleTemplate: 'Task 1'),
        TaskTemplate.create(name: 'Task 2', titleTemplate: 'Task 2'),
      ];

      final estimate = TemplateSizeEstimate.calculate(tasks);

      expect(estimate.taskCount, equals(2));
      expect(estimate.estimatedMemoryKb, equals(14)); // (2 * 2) + 10
      expect(estimate.complexityCategory, equals('small'));
      expect(estimate.isLargeTemplate, isFalse);
    });

    test('calculate should handle large templates', () {
      final tasks = List.generate(60, (index) => 
        TaskTemplate.create(
          name: 'Task $index', 
          titleTemplate: 'Task $index',
        ),
      );

      final estimate = TemplateSizeEstimate.calculate(tasks);

      expect(estimate.taskCount, equals(60));
      expect(estimate.complexityCategory, equals('large'));
      expect(estimate.isLargeTemplate, isTrue);
    });
  });
}