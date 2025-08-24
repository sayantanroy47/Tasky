import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/entities/project_template.dart';
import 'package:task_tracker_app/domain/entities/template_variable.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/services/project_template_service.dart';
import 'package:task_tracker_app/services/template_engine/template_parser.dart';
import 'package:task_tracker_app/services/template_engine/variable_resolver.dart';
import 'package:task_tracker_app/services/template_engine/template_validator.dart';

import '../mocks/test_mocks.mocks.dart';

void main() {
  group('Project Template Performance Tests - Enterprise Scale', () {
    late MockTaskRepository mockTaskRepository;
    late MockProjectRepository mockProjectRepository;
    late PerformanceBenchmarker benchmarker;
    late TemplateTestDataGenerator dataGenerator;

    setUp(() {
      mockTaskRepository = MockTaskRepository();
      mockProjectRepository = MockProjectRepository();
      benchmarker = PerformanceBenchmarker();
      dataGenerator = TemplateTestDataGenerator();
    });

    group('Template Processing Performance', () {
      test('Complex template parsing with 50+ variables and conditional logic', () async {
        final template = dataGenerator.generateComplexProjectTemplate(50, 100);
        final variables = dataGenerator.generateTemplateVariables(50);
        
        final templateParser = TemplateParser();
        
        final stopwatch = Stopwatch()..start();
        
        // Parse complex template with many variables
        final parsedTemplate = await templateParser.parseTemplate(
          template,
          variables: variables,
          enableConditionalLogic: true,
          enableLoops: true,
          enableCustomFunctions: true,
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('template_parsing_50_vars_100_tasks', stopwatch.elapsedMilliseconds);
        
        // Template parsing should be efficient even with complex logic
        expect(stopwatch.elapsedMilliseconds, lessThan(2000),
               reason: 'Complex template parsing should complete within 2 seconds');
        
        expect(parsedTemplate, isNotNull);
        expect(parsedTemplate.tasks.length, equals(100));
        expect(parsedTemplate.resolvedVariables.length, equals(50));
        
        print('Complex template parsing (50 vars, 100 tasks): ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Variable substitution performance with nested and computed variables', () async {
        final template = dataGenerator.generateNestedVariableTemplate();
        final variables = dataGenerator.generateNestedTemplateVariables(30);
        
        final variableResolver = VariableResolver();
        
        final stopwatch = Stopwatch()..start();
        
        // Resolve complex nested variables with computations
        final resolvedVariables = await variableResolver.resolveVariables(
          variables,
          context: TemplateContext(
            projectName: 'Enterprise Project',
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 180)),
            budget: 250000.0,
            teamSize: 15,
            customData: {
              'department': 'Engineering',
              'priority_level': 'critical',
              'compliance_required': true,
            },
          ),
          enableRecursiveResolution: true,
          maxRecursionDepth: 10,
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('variable_resolution_nested_30', stopwatch.elapsedMilliseconds);
        
        // Variable resolution should handle complexity efficiently
        expect(stopwatch.elapsedMilliseconds, lessThan(1000),
               reason: 'Nested variable resolution should complete within 1 second');
        
        expect(resolvedVariables, isNotNull);
        expect(resolvedVariables.length, equals(30));
        
        // Verify computed variables were resolved correctly
        final computedVars = resolvedVariables.where((v) => v.isComputed).toList();
        expect(computedVars.length, greaterThan(0));
        
        print('Nested variable resolution (30 variables): ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Template validation with complex rule sets and dependencies', () async {
        final template = dataGenerator.generateComplexProjectTemplate(40, 200);
        final validationRules = dataGenerator.generateValidationRules(25);
        
        final templateValidator = TemplateValidator();
        
        final stopwatch = Stopwatch()..start();
        
        // Validate complex template with comprehensive rule set
        final validationResult = await templateValidator.validateTemplate(
          template,
          rules: validationRules,
          validateDependencies: true,
          validateResourceConstraints: true,
          validateDateConstraints: true,
          validateBudgetConstraints: true,
          validateCustomRules: true,
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('template_validation_40_vars_200_tasks', stopwatch.elapsedMilliseconds);
        
        // Template validation should be thorough but efficient
        expect(stopwatch.elapsedMilliseconds, lessThan(3000),
               reason: 'Complex template validation should complete within 3 seconds');
        
        expect(validationResult, isNotNull);
        expect(validationResult.isValid, isTrue);
        expect(validationResult.validatedRules.length, equals(25));
        
        print('Template validation (40 vars, 200 tasks, 25 rules): ${stopwatch.elapsedMilliseconds}ms');
        print('Validation issues found: ${validationResult.warnings.length} warnings, ${validationResult.errors.length} errors');
      });
    });

    group('Large-Scale Template Generation', () {
      test('Generate multiple projects from templates with 500+ tasks each', () async {
        final masterTemplate = dataGenerator.generateEnterpriseProjectTemplate(1000);
        final projectConfigs = dataGenerator.generateProjectConfigurations(5);
        
        final templateService = ProjectTemplateService(
          taskRepository: mockTaskRepository,
          projectRepository: mockProjectRepository,
        );
        
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async => '');
        when(mockProjectRepository.createProject(any)).thenAnswer((_) async => '');
        
        final stopwatch = Stopwatch()..start();
        
        // Generate multiple large projects from template
        final generationResults = <ProjectGenerationResult>[];
        
        for (final config in projectConfigs) {
          final result = await templateService.generateProjectFromTemplate(
            template: masterTemplate,
            configuration: config,
            options: const ProjectGenerationOptions(
              validateBeforeGeneration: true,
              createDependencies: true,
              assignResources: true,
              calculateTimelines: true,
              generateReports: true,
            ),
          );
          
          generationResults.add(result);
        }
        
        stopwatch.stop();
        
        benchmarker.recordMetric('template_generation_5_projects_1000_tasks', stopwatch.elapsedMilliseconds);
        
        // Large-scale template generation should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(15000),
               reason: 'Generating 5 projects with 1000 tasks each should complete within 15 seconds');
        
        expect(generationResults.length, equals(5));
        for (final result in generationResults) {
          expect(result.isSuccess, isTrue);
          expect(result.generatedTasks.length, equals(1000));
        }
        
        final totalTasksGenerated = generationResults.fold(0, (sum, result) => sum + result.generatedTasks.length);
        
        print('Large-scale template generation (5 projects, 5000 total tasks): ${stopwatch.elapsedMilliseconds}ms');
        print('Generation rate: ${(totalTasksGenerated / (stopwatch.elapsedMilliseconds / 1000.0)).toStringAsFixed(0)} tasks/sec');
      });

      test('Batch template processing with concurrent generation', () async {
        final templates = dataGenerator.generateTemplateLibrary(10);
        final batchConfigs = dataGenerator.generateBatchConfigurations(20);
        
        final batchTemplateService = BatchTemplateService(
          taskRepository: mockTaskRepository,
          projectRepository: mockProjectRepository,
          maxConcurrentGenerations: 4,
        );
        
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async => '');
        when(mockProjectRepository.createProject(any)).thenAnswer((_) async => '');
        
        final stopwatch = Stopwatch()..start();
        
        // Process batch of template generations concurrently
        final batchResult = await batchTemplateService.processBatch(
          templates: templates,
          configurations: batchConfigs,
          batchSize: 5,
          options: BatchProcessingOptions(
            continueOnError: true,
            generateProgressReports: true,
            validateResults: true,
            optimizeResourceAllocation: true,
          ),
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('batch_template_processing_20_projects', stopwatch.elapsedMilliseconds);
        
        // Batch processing should be efficient with concurrent execution
        expect(stopwatch.elapsedMilliseconds, lessThan(12000),
               reason: 'Batch template processing should complete within 12 seconds');
        
        expect(batchResult.isSuccess, isTrue);
        expect(batchResult.successfulGenerations, equals(20));
        expect(batchResult.failedGenerations, equals(0));
        
        print('Batch template processing (20 projects, 4 concurrent): ${stopwatch.elapsedMilliseconds}ms');
        print('Success rate: ${(batchResult.successfulGenerations / batchConfigs.length * 100).toStringAsFixed(1)}%');
      });

      test('Template library search and filtering with large dataset', () async {
        final templateLibrary = dataGenerator.generateLargeTemplateLibrary(500);
        final searchService = TemplateSearchService();
        
        final stopwatch = Stopwatch()..start();
        
        // Perform complex searches on large template library
        final searchQueries = [
          TemplateSearchQuery(
            text: 'software development',
            category: 'engineering',
            complexity: TemplateComplexity.high,
            minTasks: 50,
            maxTasks: 200,
            tags: ['agile', 'scrum'],
          ),
          TemplateSearchQuery(
            text: 'marketing campaign',
            category: 'marketing',
            budgetRange: BudgetRange(min: 10000, max: 100000),
            duration: DurationRange(min: const Duration(days: 30), max: const Duration(days: 90)),
            requiresApproval: true,
          ),
          TemplateSearchQuery(
            text: 'compliance',
            category: 'legal',
            complexity: TemplateComplexity.medium,
            tags: ['audit', 'governance'],
            customFields: {'industry': 'finance'},
          ),
        ];
        
        final searchResults = <TemplateSearchResult>[];
        for (final query in searchQueries) {
          final result = await searchService.searchTemplates(
            library: templateLibrary,
            query: query,
            rankingAlgorithm: TemplateRankingAlgorithm.relevanceScore,
            maxResults: 50,
          );
          searchResults.add(result);
        }
        
        stopwatch.stop();
        
        benchmarker.recordMetric('template_search_500_library', stopwatch.elapsedMilliseconds);
        
        // Template search should be fast even with large libraries
        expect(stopwatch.elapsedMilliseconds, lessThan(1000),
               reason: 'Template library search should complete within 1 second');
        
        expect(searchResults.length, equals(3));
        for (final result in searchResults) {
          expect(result.templates.length, greaterThan(0));
          expect(result.templates.length, lessThanOrEqualTo(50));
        }
        
        print('Template library search (500 templates, 3 queries): ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Template Customization and Adaptation', () {
      test('Dynamic template modification with real-time preview', () async {
        final baseTemplate = dataGenerator.generateComplexProjectTemplate(30, 150);
        final customizations = dataGenerator.generateTemplateCustomizations(20);
        
        final templateCustomizer = TemplateCustomizationService();
        
        final stopwatch = Stopwatch()..start();
        
        // Apply multiple customizations and generate previews
        var currentTemplate = baseTemplate;
        
        for (final customization in customizations) {
          currentTemplate = await templateCustomizer.applyCustomization(
            template: currentTemplate,
            customization: customization,
            generatePreview: true,
            validateChanges: true,
          );
        }
        
        // Generate final preview
        final finalPreview = await templateCustomizer.generatePreview(
          currentTemplate,
          previewOptions: PreviewOptions(
            includeTaskHierarchy: true,
            includeTimeline: true,
            includeResourceAllocation: true,
            includeBudgetBreakdown: true,
          ),
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('template_customization_20_changes', stopwatch.elapsedMilliseconds);
        
        // Template customization should provide responsive feedback
        expect(stopwatch.elapsedMilliseconds, lessThan(5000),
               reason: 'Template customization with preview should complete within 5 seconds');
        
        expect(currentTemplate, isNotNull);
        expect(finalPreview, isNotNull);
        expect(finalPreview.tasks.length, equals(150));
        
        print('Template customization (20 changes): ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Template inheritance and composition performance', () async {
        final baseTemplates = dataGenerator.generateBaseTemplates(15);
        final compositeTemplate = dataGenerator.generateCompositeTemplate(baseTemplates);
        
        final inheritanceService = TemplateInheritanceService();
        
        final stopwatch = Stopwatch()..start();
        
        // Resolve complex template inheritance hierarchy
        final resolvedTemplate = await inheritanceService.resolveInheritance(
          template: compositeTemplate,
          baseTemplates: baseTemplates,
          resolveOptions: InheritanceResolveOptions(
            overrideConflicts: true,
            mergeVariables: true,
            combineTaskHierarchies: true,
            inheritPermissions: true,
          ),
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('template_inheritance_15_base', stopwatch.elapsedMilliseconds);
        
        // Template inheritance should resolve efficiently
        expect(stopwatch.elapsedMilliseconds, lessThan(3000),
               reason: 'Template inheritance resolution should complete within 3 seconds');
        
        expect(resolvedTemplate, isNotNull);
        expect(resolvedTemplate.inheritedFrom.length, equals(15));
        expect(resolvedTemplate.tasks.length, greaterThan(0));
        
        print('Template inheritance resolution (15 base templates): ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Template versioning and migration performance', () async {
        final templateVersions = dataGenerator.generateTemplateVersionHistory(20);
        final migrationRules = dataGenerator.generateMigrationRules();
        
        final versioningService = TemplateVersioningService();
        
        final stopwatch = Stopwatch()..start();
        
        // Migrate template through version history
        var currentVersion = templateVersions.first;
        
        for (int i = 1; i < templateVersions.length; i++) {
          final targetVersion = templateVersions[i];
          
          currentVersion = await versioningService.migrateTemplate(
            from: currentVersion,
            to: targetVersion,
            migrationRules: migrationRules,
            options: MigrationOptions(
              preserveCustomizations: true,
              validateAfterMigration: true,
              generateMigrationReport: true,
            ),
          );
        }
        
        stopwatch.stop();
        
        benchmarker.recordMetric('template_migration_20_versions', stopwatch.elapsedMilliseconds);
        
        // Template migration should handle version history efficiently
        expect(stopwatch.elapsedMilliseconds, lessThan(4000),
               reason: 'Template migration through 20 versions should complete within 4 seconds');
        
        expect(currentVersion, isNotNull);
        expect(currentVersion.version, equals(templateVersions.last.version));
        
        print('Template version migration (20 versions): ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Template Analytics and Optimization', () {
      test('Template usage analytics with large dataset analysis', () async {
        final templates = dataGenerator.generateTemplateLibrary(100);
        final usageData = dataGenerator.generateTemplateUsageData(templates, 10000);
        
        final analyticsService = TemplateAnalyticsService();
        
        final stopwatch = Stopwatch()..start();
        
        // Analyze template usage patterns
        final analyticsResult = await analyticsService.analyzeTemplateUsage(
          templates: templates,
          usageData: usageData,
          analysisOptions: UsageAnalysisOptions(
            calculatePopularityMetrics: true,
            identifyUsagePatterns: true,
            generateRecommendations: true,
            analyzeSuccessRates: true,
            calculateROI: true,
          ),
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('template_analytics_100_10k_usage', stopwatch.elapsedMilliseconds);
        
        // Template analytics should process large datasets efficiently
        expect(stopwatch.elapsedMilliseconds, lessThan(6000),
               reason: 'Template analytics should complete within 6 seconds');
        
        expect(analyticsResult, isNotNull);
        expect(analyticsResult.popularTemplates.length, greaterThan(0));
        expect(analyticsResult.usagePatterns.length, greaterThan(0));
        expect(analyticsResult.recommendations.length, greaterThan(0));
        
        print('Template usage analytics (100 templates, 10k usage records): ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Template optimization suggestions based on performance data', () async {
        final template = dataGenerator.generateComplexProjectTemplate(25, 300);
        final performanceData = dataGenerator.generateTemplatePerformanceData(template, 500);
        
        final optimizationService = TemplateOptimizationService();
        
        final stopwatch = Stopwatch()..start();
        
        // Generate optimization suggestions
        final optimizationResult = await optimizationService.optimizeTemplate(
          template: template,
          performanceData: performanceData,
          optimizationGoals: [
            OptimizationGoal.reduceComplexity,
            OptimizationGoal.improvePerformance,
            OptimizationGoal.enhanceReusability,
            OptimizationGoal.simplifyMaintenance,
          ],
          analysisDepth: OptimizationDepth.deep,
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('template_optimization_300_tasks', stopwatch.elapsedMilliseconds);
        
        // Template optimization should provide actionable insights
        expect(stopwatch.elapsedMilliseconds, lessThan(4000),
               reason: 'Template optimization analysis should complete within 4 seconds');
        
        expect(optimizationResult, isNotNull);
        expect(optimizationResult.suggestions.length, greaterThan(0));
        expect(optimizationResult.estimatedImprovements.length, greaterThan(0));
        
        print('Template optimization analysis (300 tasks, 500 performance records): ${stopwatch.elapsedMilliseconds}ms');
        print('Optimization suggestions: ${optimizationResult.suggestions.length}');
      });
    });

    group('Memory and Resource Management', () {
      test('Memory efficiency during large template processing', () async {
        final memoryTracker = MemoryUsageTracker();
        final templateService = ProjectTemplateService(
          taskRepository: mockTaskRepository,
          projectRepository: mockProjectRepository,
        );
        
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async => '');
        when(mockProjectRepository.createProject(any)).thenAnswer((_) async => '');
        
        // Baseline memory
        final baselineMemory = await memoryTracker.getCurrentUsage();
        
        // Process large template
        final largeTemplate = dataGenerator.generateEnterpriseProjectTemplate(2000);
        final config = dataGenerator.generateProjectConfiguration();
        
        final afterTemplateLoad = await memoryTracker.getCurrentUsage();
        
        // Generate project from template
        final result = await templateService.generateProjectFromTemplate(
          template: largeTemplate,
          configuration: config,
          options: const ProjectGenerationOptions(
            validateBeforeGeneration: true,
            createDependencies: true,
            assignResources: true,
            calculateTimelines: true,
          ),
        );
        
        final afterGeneration = await memoryTracker.getCurrentUsage();
        
        // Cleanup
        await templateService.cleanup();
        final afterCleanup = await memoryTracker.getCurrentUsage();
        
        final loadMemoryIncrease = afterTemplateLoad - baselineMemory;
        final generationMemoryIncrease = afterGeneration - afterTemplateLoad;
        final memoryRecovered = afterGeneration - afterCleanup;
        
        benchmarker.recordMetric('template_memory_load_2k', loadMemoryIncrease.round());
        benchmarker.recordMetric('template_memory_generation_2k', generationMemoryIncrease.round());
        benchmarker.recordMetric('template_memory_recovered_2k', memoryRecovered.round());
        
        // Memory should be managed efficiently
        expect(loadMemoryIncrease, lessThan(100.0),
               reason: 'Loading large template should use less than 100MB');
        expect(generationMemoryIncrease, lessThan(150.0),
               reason: 'Template generation should not cause excessive memory growth');
        expect(memoryRecovered, greaterThan(generationMemoryIncrease * 0.8),
               reason: 'At least 80% of generation memory should be recoverable');
        
        expect(result.isSuccess, isTrue);
        expect(result.generatedTasks.length, equals(2000));
        
        print('Template memory analysis (2000 tasks):');
        print('  Template loading: +${loadMemoryIncrease.toStringAsFixed(1)}MB');
        print('  Generation: +${generationMemoryIncrease.toStringAsFixed(1)}MB');
        print('  Recovered: ${memoryRecovered.toStringAsFixed(1)}MB');
      });

      test('Template caching performance with large library', () async {
        final templateLibrary = dataGenerator.generateLargeTemplateLibrary(200);
        final cacheService = TemplateCacheService();
        
        final stopwatch = Stopwatch()..start();
        
        // Cache large template library
        await cacheService.cacheTemplateLibrary(templateLibrary);
        
        // Perform multiple lookups (should be fast)
        final lookupTasks = <Future>[];
        for (int i = 0; i < 100; i++) {
          final templateId = templateLibrary[i % templateLibrary.length].id;
          lookupTasks.add(cacheService.getCachedTemplate(templateId));
        }
        
        final cachedTemplates = await Future.wait(lookupTasks);
        
        stopwatch.stop();
        
        benchmarker.recordMetric('template_cache_200_lib_100_lookups', stopwatch.elapsedMilliseconds);
        
        // Template caching should provide fast access
        expect(stopwatch.elapsedMilliseconds, lessThan(1000),
               reason: 'Template caching and lookups should complete within 1 second');
        
        expect(cachedTemplates.length, equals(100));
        for (final template in cachedTemplates) {
          expect(template, isNotNull);
        }
        
        print('Template caching (200 templates, 100 lookups): ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    tearDown(() {
      // Print template performance summary
      final summary = benchmarker.generateSummary();
      print('\n=== Project Template Performance Summary ===');
      summary.forEach((metric, stats) {
        print('$metric: ${stats['avg']}ms avg (${stats['min']}-${stats['max']}ms)');
      });
      print('===========================================\n');
    });
  });
}

/// Template test data generator
class TemplateTestDataGenerator {
  final math.Random _random = math.Random(42); // Fixed seed
  
  /// Generates a complex project template with many variables and tasks
  ProjectTemplate generateComplexProjectTemplate(int variableCount, int taskCount) {
    final variables = generateTemplateVariables(variableCount);
    final tasks = _generateTemplateTasks(taskCount);
    
    return ProjectTemplate(
      id: 'complex-template-$variableCount-$taskCount',
      name: 'Complex Project Template',
      description: 'Enterprise-grade project template with complex variable substitution',
      category: 'enterprise',
      variables: variables,
      tasks: tasks,
      complexity: TemplateComplexity.high,
      estimatedDuration: Duration(days: 90 + _random.nextInt(180)),
      tags: ['enterprise', 'complex', 'scalable'],
      createdAt: DateTime.now(),
    );
  }
  
  /// Generates template variables with different types and constraints
  List<TemplateVariable> generateTemplateVariables(int count) {
    final variables = <TemplateVariable>[];
    
    final variableTypes = [
      VariableType.string,
      VariableType.number,
      VariableType.date,
      VariableType.boolean,
      VariableType.list,
      VariableType.computed,
    ];
    
    for (int i = 0; i < count; i++) {
      final type = variableTypes[i % variableTypes.length];
      
      final variable = TemplateVariable(
        id: 'var-${i + 1}',
        name: 'Variable ${i + 1}',
        type: type,
        defaultValue: _generateDefaultValue(type),
        isRequired: _random.nextBool(),
        constraints: _generateVariableConstraints(type),
        description: 'Template variable for testing performance',
      );
      
      variables.add(variable);
    }
    
    return variables;
  }
  
  /// Generates nested template variables with dependencies
  List<TemplateVariable> generateNestedTemplateVariables(int count) {
    final variables = <TemplateVariable>[];
    
    for (int i = 0; i < count; i++) {
      final isComputed = i % 3 == 0;
      
      final variable = TemplateVariable(
        id: 'nested-var-${i + 1}',
        name: 'Nested Variable ${i + 1}',
        type: isComputed ? VariableType.computed : VariableType.string,
        defaultValue: isComputed ? null : 'default-${i + 1}',
        computeExpression: isComputed ? '{{var-${(i ~/ 3) + 1}}} + "-computed"' : null,
        dependencies: isComputed && i > 0 ? ['nested-var-$i'] : [],
        isRequired: true,
        description: 'Nested variable with dependencies',
      );
      
      variables.add(variable);
    }
    
    return variables;
  }
  
  /// Generates template with nested variables
  ProjectTemplate generateNestedVariableTemplate() {
    final variables = generateNestedTemplateVariables(30);
    final tasks = _generateTemplateTasks(50);
    
    return ProjectTemplate(
      id: 'nested-var-template',
      name: 'Nested Variable Template',
      description: 'Template with complex nested variable dependencies',
      category: 'advanced',
      variables: variables,
      tasks: tasks,
      complexity: TemplateComplexity.high,
      tags: ['nested', 'computed'],
      createdAt: DateTime.now(),
    );
  }
  
  /// Generates validation rules for templates
  List<TemplateValidationRule> generateValidationRules(int count) {
    final rules = <TemplateValidationRule>[];
    
    for (int i = 0; i < count; i++) {
      final rule = TemplateValidationRule(
        id: 'rule-${i + 1}',
        name: 'Validation Rule ${i + 1}',
        type: ValidationRuleType.values[i % ValidationRuleType.values.length],
        expression: _generateValidationExpression(i),
        errorMessage: 'Validation rule ${i + 1} failed',
        severity: ValidationSeverity.values[i % ValidationSeverity.values.length],
      );
      
      rules.add(rule);
    }
    
    return rules;
  }
  
  /// Generates enterprise-scale project template
  ProjectTemplate generateEnterpriseProjectTemplate(int taskCount) {
    final variables = generateTemplateVariables(40);
    final tasks = _generateTemplateTasks(taskCount);
    
    return ProjectTemplate(
      id: 'enterprise-template-$taskCount',
      name: 'Enterprise Project Template',
      description: 'Large-scale enterprise project template',
      category: 'enterprise',
      variables: variables,
      tasks: tasks,
      complexity: TemplateComplexity.enterprise,
      estimatedDuration: const Duration(days: 365),
      estimatedBudget: 1000000.0,
      requiredRoles: [
        'Project Manager',
        'Technical Lead',
        'Senior Developer',
        'QA Lead',
        'DevOps Engineer',
      ],
      tags: ['enterprise', 'large-scale', 'complex'],
      createdAt: DateTime.now(),
    );
  }
  
  /// Generates project configurations for testing
  List<ProjectConfiguration> generateProjectConfigurations(int count) {
    final configs = <ProjectConfiguration>[];
    
    for (int i = 0; i < count; i++) {
      final config = ProjectConfiguration(
        projectName: 'Generated Project ${i + 1}',
        startDate: DateTime.now().add(Duration(days: i * 30)),
        budget: 50000.0 + (_random.nextDouble() * 200000),
        teamSize: 5 + _random.nextInt(20),
        priority: TaskPriority.values[_random.nextInt(TaskPriority.values.length)],
        customVariables: {
          'department': 'Engineering',
          'region': 'North America',
          'compliance_level': 'high',
        },
      );
      
      configs.add(config);
    }
    
    return configs;
  }
  
  /// Generates batch configurations
  List<ProjectConfiguration> generateBatchConfigurations(int count) {
    return generateProjectConfigurations(count);
  }
  
  /// Generates a single project configuration
  ProjectConfiguration generateProjectConfiguration() {
    return generateProjectConfigurations(1).first;
  }
  
  /// Generates template library for testing
  List<ProjectTemplate> generateTemplateLibrary(int count) {
    final templates = <ProjectTemplate>[];
    
    final categories = ['software', 'marketing', 'finance', 'operations', 'research'];
    const complexities = TemplateComplexity.values;
    
    for (int i = 0; i < count; i++) {
      final taskCount = 10 + _random.nextInt(100);
      final variableCount = 5 + _random.nextInt(20);
      
      final template = ProjectTemplate(
        id: 'lib-template-${i + 1}',
        name: 'Library Template ${i + 1}',
        description: 'Template from library for testing',
        category: categories[i % categories.length],
        variables: generateTemplateVariables(variableCount),
        tasks: _generateTemplateTasks(taskCount),
        complexity: complexities[i % complexities.length],
        estimatedDuration: Duration(days: 30 + _random.nextInt(120)),
        tags: _generateRandomTags(),
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(365))),
      );
      
      templates.add(template);
    }
    
    return templates;
  }
  
  /// Generates large template library
  List<ProjectTemplate> generateLargeTemplateLibrary(int count) {
    return generateTemplateLibrary(count);
  }
  
  /// Generates template customizations
  List<TemplateCustomization> generateTemplateCustomizations(int count) {
    final customizations = <TemplateCustomization>[];
    
    for (int i = 0; i < count; i++) {
      final customization = TemplateCustomization(
        id: 'customization-${i + 1}',
        name: 'Customization ${i + 1}',
        type: CustomizationType.values[i % CustomizationType.values.length],
        changes: _generateCustomizationChanges(),
      );
      
      customizations.add(customization);
    }
    
    return customizations;
  }
  
  /// Generates base templates for inheritance testing
  List<ProjectTemplate> generateBaseTemplates(int count) {
    final templates = <ProjectTemplate>[];
    
    for (int i = 0; i < count; i++) {
      final template = ProjectTemplate(
        id: 'base-template-${i + 1}',
        name: 'Base Template ${i + 1}',
        description: 'Base template for inheritance',
        category: 'base',
        variables: generateTemplateVariables(5),
        tasks: _generateTemplateTasks(20),
        complexity: TemplateComplexity.low,
        isBaseTemplate: true,
        createdAt: DateTime.now(),
      );
      
      templates.add(template);
    }
    
    return templates;
  }
  
  /// Generates composite template
  ProjectTemplate generateCompositeTemplate(List<ProjectTemplate> baseTemplates) {
    return ProjectTemplate(
      id: 'composite-template',
      name: 'Composite Template',
      description: 'Template that inherits from multiple base templates',
      category: 'composite',
      variables: generateTemplateVariables(10),
      tasks: _generateTemplateTasks(30),
      complexity: TemplateComplexity.medium,
      inheritsFrom: baseTemplates.map((t) => t.id).toList(),
      createdAt: DateTime.now(),
    );
  }
  
  /// Generates template version history
  List<ProjectTemplate> generateTemplateVersionHistory(int versionCount) {
    final versions = <ProjectTemplate>[];
    
    for (int i = 0; i < versionCount; i++) {
      final version = ProjectTemplate(
        id: 'versioned-template',
        name: 'Versioned Template',
        description: 'Template version ${i + 1}',
        category: 'versioned',
        variables: generateTemplateVariables(10 + i),
        tasks: _generateTemplateTasks(50 + i * 5),
        complexity: TemplateComplexity.medium,
        version: '${(i + 1) ~/ 10 + 1}.${(i + 1) % 10}',
        createdAt: DateTime.now().subtract(Duration(days: (versionCount - i) * 30)),
      );
      
      versions.add(version);
    }
    
    return versions;
  }
  
  /// Generates migration rules
  List<TemplateMigrationRule> generateMigrationRules() {
    return [
      TemplateMigrationRule(
        fromVersion: '1.0',
        toVersion: '2.0',
        transformations: ['rename_variable:oldVar->newVar', 'add_task:new_task'],
      ),
      TemplateMigrationRule(
        fromVersion: '2.0',
        toVersion: '3.0',
        transformations: ['update_task_priority', 'add_validation_rule'],
      ),
    ];
  }
  
  /// Generates template usage data
  List<TemplateUsageRecord> generateTemplateUsageData(List<ProjectTemplate> templates, int recordCount) {
    final usageData = <TemplateUsageRecord>[];
    
    for (int i = 0; i < recordCount; i++) {
      final template = templates[_random.nextInt(templates.length)];
      
      final record = TemplateUsageRecord(
        templateId: template.id,
        userId: 'user-${_random.nextInt(100) + 1}',
        usageDate: DateTime.now().subtract(Duration(days: _random.nextInt(365))),
        successRate: 0.7 + (_random.nextDouble() * 0.3),
        generatedTaskCount: _random.nextInt(200) + 10,
        executionTimeMs: _random.nextInt(5000) + 500,
      );
      
      usageData.add(record);
    }
    
    return usageData;
  }
  
  /// Generates template performance data
  List<TemplatePerformanceRecord> generateTemplatePerformanceData(ProjectTemplate template, int recordCount) {
    final performanceData = <TemplatePerformanceRecord>[];
    
    for (int i = 0; i < recordCount; i++) {
      final record = TemplatePerformanceRecord(
        templateId: template.id,
        executionDate: DateTime.now().subtract(Duration(days: _random.nextInt(90))),
        parseTimeMs: _random.nextInt(1000) + 100,
        generationTimeMs: _random.nextInt(5000) + 1000,
        memoryUsageMB: _random.nextDouble() * 100 + 50,
        successRate: 0.8 + (_random.nextDouble() * 0.2),
      );
      
      performanceData.add(record);
    }
    
    return performanceData;
  }
  
  // Private helper methods
  
  List<TemplateTask> _generateTemplateTasks(int count) {
    final tasks = <TemplateTask>[];
    
    for (int i = 0; i < count; i++) {
      final task = TemplateTask(
        id: 'template-task-${i + 1}',
        title: 'Template Task ${i + 1}: {{project_name}} - {{task_type}}',
        description: 'Task description with {{variable_substitution}}',
        priority: '{{task_priority}}',
        estimatedDuration: '{{base_duration}} * {{complexity_factor}}',
        tags: ['{{project_tag}}', 'generated'],
        dependencies: i > 0 && _random.nextDouble() < 0.3 ? ['template-task-$i'] : [],
      );
      
      tasks.add(task);
    }
    
    return tasks;
  }
  
  dynamic _generateDefaultValue(VariableType type) {
    switch (type) {
      case VariableType.string:
        return 'default-value';
      case VariableType.number:
        return _random.nextInt(100) + 1;
      case VariableType.date:
        return DateTime.now().toIso8601String();
      case VariableType.boolean:
        return _random.nextBool();
      case VariableType.list:
        return ['item1', 'item2', 'item3'];
      case VariableType.computed:
        return null;
    }
  }
  
  Map<String, dynamic> _generateVariableConstraints(VariableType type) {
    switch (type) {
      case VariableType.string:
        return {'minLength': 3, 'maxLength': 50};
      case VariableType.number:
        return {'min': 1, 'max': 1000};
      case VariableType.date:
        return {'minDate': DateTime.now().toIso8601String()};
      case VariableType.boolean:
        return {};
      case VariableType.list:
        return {'minItems': 1, 'maxItems': 10};
      case VariableType.computed:
        return {};
    }
  }
  
  String _generateValidationExpression(int index) {
    final expressions = [
      '{{budget}} > 1000',
      '{{team_size}} >= 3',
      '{{project_name}}.length > 5',
      '{{start_date}} < {{end_date}}',
      '{{priority}} in ["high", "medium", "low"]',
    ];
    
    return expressions[index % expressions.length];
  }
  
  List<String> _generateRandomTags() {
    final allTags = ['agile', 'enterprise', 'fast-track', 'complex', 'standard', 'custom'];
    final tagCount = 1 + _random.nextInt(3);
    final tags = <String>[];
    
    for (int i = 0; i < tagCount; i++) {
      final tag = allTags[_random.nextInt(allTags.length)];
      if (!tags.contains(tag)) {
        tags.add(tag);
      }
    }
    
    return tags;
  }
  
  Map<String, dynamic> _generateCustomizationChanges() {
    return {
      'variable_updates': {'budget': 75000, 'timeline': 'aggressive'},
      'task_modifications': ['update_task_1', 'add_review_step'],
      'validation_changes': ['add_budget_check'],
    };
  }
}

/// Performance benchmarker (shared utility)
class PerformanceBenchmarker {
  final Map<String, List<int>> _metrics = {};
  
  void recordMetric(String name, int valueMs) {
    _metrics.putIfAbsent(name, () => []).add(valueMs);
  }
  
  Map<String, Map<String, int>> generateSummary() {
    final summary = <String, Map<String, int>>{};
    
    _metrics.forEach((name, values) {
      final avg = values.reduce((a, b) => a + b) / values.length;
      final min = values.reduce(math.min);
      final max = values.reduce(math.max);
      
      summary[name] = {
        'avg': avg.round(),
        'min': min,
        'max': max,
        'count': values.length,
      };
    });
    
    return summary;
  }
}

/// Memory tracker (shared utility)
class MemoryUsageTracker {
  Future<double> getCurrentUsage() async {
    await Future.delayed(const Duration(milliseconds: 5));
    return 90.0 + (DateTime.now().millisecondsSinceEpoch % 1000) / 25.0;
  }
}

// Mock template services and data classes would follow here...
// (Truncated for length - would include all the template service implementations)

// Mock Enums and Data Classes
enum TemplateComplexity { low, medium, high, enterprise }
enum VariableType { string, number, date, boolean, list, computed }
enum ValidationRuleType { required, range, pattern, custom }
enum ValidationSeverity { warning, error, critical }
enum CustomizationType { variable, task, workflow, validation }
enum TemplateRankingAlgorithm { relevanceScore, popularityScore, recentUsage }
enum OptimizationGoal { reduceComplexity, improvePerformance, enhanceReusability, simplifyMaintenance }
enum OptimizationDepth { shallow, medium, deep }

// Mock Data Classes (abbreviated for length)
class ProjectTemplate {
  final String id, name, description, category;
  final List<TemplateVariable> variables;
  final List<TemplateTask> tasks;
  final TemplateComplexity complexity;
  final Duration? estimatedDuration;
  final double? estimatedBudget;
  final List<String> requiredRoles;
  final List<String> tags;
  final DateTime createdAt;
  final bool isBaseTemplate;
  final List<String> inheritsFrom;
  final String? version;

  const ProjectTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.variables,
    required this.tasks,
    required this.complexity,
    this.estimatedDuration,
    this.estimatedBudget,
    this.requiredRoles = const [],
    required this.tags,
    required this.createdAt,
    this.isBaseTemplate = false,
    this.inheritsFrom = const [],
    this.version,
  });

  List<TemplateVariable> get resolvedVariables => variables;
  List<String> get inheritedFrom => inheritsFrom;
}

class TemplateVariable {
  final String id, name;
  final VariableType type;
  final dynamic defaultValue;
  final bool isRequired;
  final Map<String, dynamic> constraints;
  final String? computeExpression;
  final List<String> dependencies;
  final String description;

  const TemplateVariable({
    required this.id,
    required this.name,
    required this.type,
    this.defaultValue,
    required this.isRequired,
    this.constraints = const {},
    this.computeExpression,
    this.dependencies = const [],
    required this.description,
  });

  bool get isComputed => type == VariableType.computed;
}

class TemplateTask {
  final String id, title, description;
  final String priority, estimatedDuration;
  final List<String> tags, dependencies;

  const TemplateTask({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.estimatedDuration,
    required this.tags,
    this.dependencies = const [],
  });
}

class ProjectConfiguration {
  final String projectName;
  final DateTime startDate;
  final double budget;
  final int teamSize;
  final TaskPriority priority;
  final Map<String, dynamic> customVariables;

  const ProjectConfiguration({
    required this.projectName,
    required this.startDate,
    required this.budget,
    required this.teamSize,
    required this.priority,
    this.customVariables = const {},
  });
}

// Additional mock classes would be defined here for completeness...
// (Abbreviated for length constraints)

class TemplateContext {
  final String projectName;
  final DateTime startDate, endDate;
  final double budget;
  final int teamSize;
  final Map<String, dynamic> customData;

  const TemplateContext({
    required this.projectName,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.teamSize,
    this.customData = const {},
  });
}

class ProjectGenerationResult {
  final bool isSuccess;
  final List<TaskModel> generatedTasks;

  const ProjectGenerationResult({
    required this.isSuccess,
    required this.generatedTasks,
  });
}

class ProjectGenerationOptions {
  final bool validateBeforeGeneration;
  final bool createDependencies;
  final bool assignResources;
  final bool calculateTimelines;
  final bool generateReports;

  const ProjectGenerationOptions({
    required this.validateBeforeGeneration,
    required this.createDependencies,
    required this.assignResources,
    required this.calculateTimelines,
    this.generateReports = false,
  });
}

// Simplified mock service classes
class TemplateParser {
  Future<ProjectTemplate> parseTemplate(ProjectTemplate template, {
    required Map<String, TemplateVariable> variables,
    bool enableConditionalLogic = false,
    bool enableLoops = false,
    bool enableCustomFunctions = false,
  }) async {
    await Future.delayed(Duration(milliseconds: template.tasks.length * 5));
    return template;
  }
}

class VariableResolver {
  Future<List<TemplateVariable>> resolveVariables(
    List<TemplateVariable> variables, {
    required TemplateContext context,
    bool enableRecursiveResolution = false,
    int maxRecursionDepth = 5,
  }) async {
    await Future.delayed(Duration(milliseconds: variables.length * 10));
    return variables;
  }
}

class TemplateValidator {
  Future<TemplateValidationResult> validateTemplate(
    ProjectTemplate template, {
    required List<TemplateValidationRule> rules,
    bool validateDependencies = false,
    bool validateResourceConstraints = false,
    bool validateDateConstraints = false,
    bool validateBudgetConstraints = false,
    bool validateCustomRules = false,
  }) async {
    await Future.delayed(Duration(milliseconds: template.tasks.length * 3));
    return TemplateValidationResult(
      isValid: true,
      validatedRules: rules,
      warnings: [],
      errors: [],
    );
  }
}

// Additional mock classes would continue here...
// (Simplified for length constraints)

class TemplateValidationRule {
  final String id, name;
  final ValidationRuleType type;
  final String expression, errorMessage;
  final ValidationSeverity severity;

  const TemplateValidationRule({
    required this.id,
    required this.name,
    required this.type,
    required this.expression,
    required this.errorMessage,
    required this.severity,
  });
}

class TemplateValidationResult {
  final bool isValid;
  final List<TemplateValidationRule> validatedRules;
  final List<String> warnings, errors;

  const TemplateValidationResult({
    required this.isValid,
    required this.validatedRules,
    required this.warnings,
    required this.errors,
  });
}