
import '../domain/entities/project.dart';
import '../domain/entities/project_template.dart';
import '../domain/entities/task_model.dart';
import '../domain/entities/task_template.dart';
import '../domain/models/enums.dart';
import '../domain/repositories/project_repository.dart';
import '../domain/repositories/project_template_repository.dart';
import '../domain/repositories/task_repository.dart';
import '../domain/repositories/task_template_repository.dart';

/// Service for comprehensive project template management
/// 
/// Handles template creation, variable substitution, project generation,
/// wizard flows, and template marketplace functionality.
class ProjectTemplateService {
  final ProjectTemplateRepository _templateRepository;
  final ProjectRepository _projectRepository;
  final TaskRepository _taskRepository;
  final TaskTemplateRepository _taskTemplateRepository;

  ProjectTemplateService({
    required ProjectTemplateRepository templateRepository,
    required ProjectRepository projectRepository,
    required TaskRepository taskRepository,
    required TaskTemplateRepository taskTemplateRepository,
  })  : _templateRepository = templateRepository,
        _projectRepository = projectRepository,
        _taskRepository = taskRepository,
        _taskTemplateRepository = taskTemplateRepository;

  // ============================================================================
  // TEMPLATE MANAGEMENT
  // ============================================================================

  /// Creates a new project template
  Future<ProjectTemplate> createTemplate(ProjectTemplate template) async {
    if (!template.isValid()) {
      throw ArgumentError('Invalid template data');
    }

    final savedTemplate = await _templateRepository.create(template);
    
    // Save associated task templates if they don't exist
    for (final taskTemplate in template.taskTemplates) {
      final existing = await _taskTemplateRepository.getTemplateById(taskTemplate.id);
      if (existing == null) {
        await _taskTemplateRepository.createTemplate(taskTemplate);
      }
    }

    return savedTemplate;
  }

  /// Updates an existing template
  Future<ProjectTemplate> updateTemplate(ProjectTemplate template) async {
    if (!template.canModify) {
      throw StateError('Cannot modify system template');
    }

    if (!template.isValid()) {
      throw ArgumentError('Invalid template data');
    }

    return await _templateRepository.update(template);
  }

  /// Deletes a template
  Future<void> deleteTemplate(String templateId) async {
    final template = await _templateRepository.findById(templateId);
    if (template == null) {
      throw ArgumentError('Template not found: $templateId');
    }

    if (!template.canModify) {
      throw StateError('Cannot delete system template');
    }

    await _templateRepository.delete(templateId);
  }

  /// Gets all templates with optional filtering
  Future<List<ProjectTemplate>> getTemplates({
    String? categoryId,
    List<String>? tags,
    ProjectTemplateType? type,
    int? maxDifficultyLevel,
    bool? isPublished,
    bool? isPremium,
    String? searchQuery,
  }) async {
    return await _templateRepository.findAll(
      categoryId: categoryId,
      tags: tags,
      type: type,
      maxDifficultyLevel: maxDifficultyLevel,
      isPublished: isPublished,
      isPremium: isPremium,
      searchQuery: searchQuery,
    );
  }

  /// Gets popular templates based on usage statistics
  Future<List<ProjectTemplate>> getPopularTemplates({int limit = 10}) async {
    final templates = await _templateRepository.findAll(isPublished: true);
    
    // Sort by trending score and usage count
    templates.sort((a, b) {
      final scoreA = a.usageStats.trendingScore + (a.usageStats.usageCount * 0.1);
      final scoreB = b.usageStats.trendingScore + (b.usageStats.usageCount * 0.1);
      return scoreB.compareTo(scoreA);
    });

    return templates.take(limit).toList();
  }

  /// Gets recommended templates for a user based on their project history
  Future<List<ProjectTemplate>> getRecommendedTemplates({int limit = 5}) async {
    // This would typically analyze user's project patterns
    // For now, return popular templates
    return await getPopularTemplates(limit: limit);
  }

  /// Searches templates by name, description, and tags
  Future<List<ProjectTemplate>> searchTemplates(String query) async {
    if (query.trim().isEmpty) {
      return await getTemplates(isPublished: true);
    }

    return await _templateRepository.search(query);
  }

  // ============================================================================
  // PROJECT GENERATION FROM TEMPLATES
  // ============================================================================

  /// Creates a project from a template with variable substitution
  Future<Project> createProjectFromTemplate(
    ProjectTemplate template,
    Map<String, dynamic> variableValues, {
    String? customProjectName,
    String? customDescription,
    DateTime? customDeadline,
  }) async {
    // Validate required variables
    await _validateRequiredVariables(template, variableValues);

    // Replace variables in project name and description
    final projectName = customProjectName ?? 
        template.replaceVariables(template.projectNameTemplate, variableValues);
    final projectDescription = customDescription ??
        (template.projectDescriptionTemplate != null
            ? template.replaceVariables(template.projectDescriptionTemplate!, variableValues)
            : null);

    // Calculate deadline
    DateTime? deadline = customDeadline;
    if (deadline == null && template.deadlineOffsetDays != null) {
      deadline = DateTime.now().add(Duration(days: template.deadlineOffsetDays!));
    }

    // Create the project
    final project = Project.create(
      name: projectName,
      description: projectDescription,
      color: template.defaultColor,
      categoryId: template.projectCategoryId,
      deadline: deadline,
    );

    await _projectRepository.createProject(project);
    final savedProject = project;

    // Create tasks from templates
    final createdTasks = <TaskModel>[];
    final taskIdMapping = <String, String>{}; // Template task ID -> Actual task ID

    for (final taskTemplate in template.taskTemplates) {
      final task = await _createTaskFromTemplate(
        taskTemplate,
        variableValues,
        savedProject.id,
      );
      
      await _taskRepository.createTask(task);
      createdTasks.add(task);
      taskIdMapping[taskTemplate.id] = task.id;
    }

    // Apply task dependencies
    await _applyTaskDependencies(template, taskIdMapping);

    // Create milestones if any
    await _createProjectMilestones(template, savedProject.id, taskIdMapping);

    // Update template usage statistics
    await _templateRepository.update(template.incrementUsage());

    // Update project with task IDs
    final updatedProject = savedProject.copyWith(
      taskIds: createdTasks.map((t) => t.id).toList(),
    );

    await _projectRepository.updateProject(updatedProject);
    return updatedProject;
  }

  /// Creates multiple projects from a template (bulk creation)
  Future<List<Project>> createMultipleProjectsFromTemplate(
    ProjectTemplate template,
    List<Map<String, dynamic>> projectConfigurations,
  ) async {
    final projects = <Project>[];

    for (final config in projectConfigurations) {
      final project = await createProjectFromTemplate(
        template,
        config['variables'] as Map<String, dynamic>,
        customProjectName: config['name'] as String?,
        customDescription: config['description'] as String?,
        customDeadline: config['deadline'] as DateTime?,
      );
      projects.add(project);
    }

    return projects;
  }

  // ============================================================================
  // TEMPLATE CREATION FROM EXISTING PROJECTS
  // ============================================================================

  /// Creates a template from an existing project
  Future<ProjectTemplate> createTemplateFromProject(
    Project project,
    String templateName, {
    String? description,
    ProjectTemplateType type = ProjectTemplateType.simple,
    List<TemplateVariable>? variables,
    Map<String, String>? variableMappings,
  }) async {
    // Get all tasks for the project
    final tasks = await _taskRepository.getTasksByProject(project.id);
    
    // Convert tasks to task templates
    final taskTemplates = <TaskTemplate>[];
    for (final task in tasks) {
      final taskTemplate = TaskTemplate.fromTask(
        task: task,
        name: '${task.title} Template',
        description: 'Generated from existing task',
      );
      taskTemplates.add(taskTemplate);
    }

    // Create project name template with variables
    String projectNameTemplate = project.name;
    if (variableMappings != null) {
      for (final entry in variableMappings.entries) {
        projectNameTemplate = projectNameTemplate.replaceAll(
          entry.value,
          '{{${entry.key}}}',
        );
      }
    }

    final template = ProjectTemplate.create(
      name: templateName,
      description: description,
      type: type,
      projectNameTemplate: projectNameTemplate,
      projectDescriptionTemplate: project.description != null
          ? _addVariablesToText(project.description!, variableMappings)
          : null,
      defaultColor: project.color,
      projectCategoryId: project.categoryId,
      taskTemplates: taskTemplates,
      variables: variables ?? [],
      deadlineOffsetDays: project.deadline?.difference(project.createdAt).inDays,
    );

    return await createTemplate(template);
  }

  // ============================================================================
  // WIZARD FLOW MANAGEMENT
  // ============================================================================

  /// Validates wizard step completion
  Future<bool> validateWizardStep(
    ProjectTemplate template,
    String stepId,
    Map<String, dynamic> stepValues,
  ) async {
    final stepVariables = template.getVariablesForStep(stepId);

    for (final variable in stepVariables) {
      if (variable.isRequired && !stepValues.containsKey(variable.key)) {
        return false;
      }

      final value = stepValues[variable.key];
      if (!_validateVariableValue(variable, value)) {
        return false;
      }
    }

    return true;
  }

  /// Gets the next wizard step based on current values
  String? getNextWizardStep(
    ProjectTemplate template,
    String currentStepId,
    Map<String, dynamic> allValues,
  ) {
    final sortedSteps = template.wizardSteps.toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    // Find next step after current
    for (int i = 0; i < sortedSteps.length; i++) {
      if (sortedSteps[i].id == currentStepId && i < sortedSteps.length - 1) {
        final nextStep = sortedSteps[i + 1];
        
        // Check if next step should be shown based on conditions
        if (_shouldShowStep(nextStep, allValues)) {
          return nextStep.id;
        }
        
        // Skip conditional steps that shouldn't be shown
        for (int j = i + 2; j < sortedSteps.length; j++) {
          if (_shouldShowStep(sortedSteps[j], allValues)) {
            return sortedSteps[j].id;
          }
        }
      }
    }

    return null; // No more steps
  }

  /// Gets wizard progress percentage
  double getWizardProgress(
    ProjectTemplate template,
    String currentStepId,
    Map<String, dynamic> allValues,
  ) {
    final sortedSteps = template.wizardSteps.toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    // Count applicable steps (not skipped by conditions)
    final applicableSteps = sortedSteps
        .where((step) => _shouldShowStep(step, allValues))
        .toList();

    if (applicableSteps.isEmpty) return 1.0;

    final currentIndex = applicableSteps.indexWhere((s) => s.id == currentStepId);
    if (currentIndex == -1) return 0.0;

    return (currentIndex + 1) / applicableSteps.length;
  }

  // ============================================================================
  // SYSTEM TEMPLATES MANAGEMENT
  // ============================================================================

  /// Seeds system templates into the database
  Future<void> seedSystemTemplates() async {
    final systemTemplates = _createSystemTemplates();

    for (final template in systemTemplates) {
      final existing = await _templateRepository.findById(template.id);
      if (existing == null) {
        await _templateRepository.create(template);
      }
    }
  }

  /// Creates predefined system templates
  List<ProjectTemplate> _createSystemTemplates() {
    return [
      _createWorkSprintTemplate(),
      _createEventPlanningTemplate(),
      _createCourseManagementTemplate(),
      _createHomeRenovationTemplate(),
      _createProductLaunchTemplate(),
      _createWeddingPlanningTemplate(),
    ];
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Validates required variables are provided
  Future<void> _validateRequiredVariables(
    ProjectTemplate template,
    Map<String, dynamic> values,
  ) async {
    for (final variable in template.variables) {
      if (variable.isRequired && !values.containsKey(variable.key)) {
        throw ArgumentError('Required variable missing: ${variable.key}');
      }

      if (values.containsKey(variable.key)) {
        final value = values[variable.key];
        if (!_validateVariableValue(variable, value)) {
          throw ArgumentError('Invalid value for variable: ${variable.key}');
        }
      }
    }
  }

  /// Validates a single variable value
  bool _validateVariableValue(TemplateVariable variable, dynamic value) {
    if (value == null) return !variable.isRequired;

    switch (variable.type) {
      case TemplateVariableType.text:
        if (value is! String) return false;
        if (variable.validationPattern != null) {
          return RegExp(variable.validationPattern!).hasMatch(value);
        }
        return true;

      case TemplateVariableType.number:
        if (value is! num) return false;
        if (variable.minValue != null && value < variable.minValue) return false;
        if (variable.maxValue != null && value > variable.maxValue) return false;
        return true;

      case TemplateVariableType.date:
        if (value is! DateTime) return false;
        if (variable.minValue != null && value.isBefore(variable.minValue)) return false;
        if (variable.maxValue != null && value.isAfter(variable.maxValue)) return false;
        return true;

      case TemplateVariableType.choice:
        if (value is! String) return false;
        return variable.options.contains(value);

      case TemplateVariableType.multiChoice:
        if (value is! List) return false;
        return (value).every((item) => variable.options.contains(item));

      case TemplateVariableType.boolean:
        return value is bool;
    }
  }

  /// Creates a task from a task template with variable substitution
  Future<TaskModel> _createTaskFromTemplate(
    TaskTemplate taskTemplate,
    Map<String, dynamic> variableValues,
    String projectId,
  ) async {
    final placeholders = Map<String, String>.from(
      variableValues.map((key, value) => MapEntry(key, value.toString())),
    );

    return taskTemplate.createTask(
      placeholders: placeholders,
    ).copyWith(projectId: projectId);
  }

  /// Applies task dependencies after creation
  Future<void> _applyTaskDependencies(
    ProjectTemplate template,
    Map<String, String> taskIdMapping,
  ) async {
    for (final entry in template.taskDependencies.entries) {
      final taskId = taskIdMapping[entry.key];
      if (taskId == null) continue;

      final task = await _taskRepository.getTaskById(taskId);
      if (task == null) continue;

      final dependencies = entry.value
          .map((depId) => taskIdMapping[depId])
          .where((id) => id != null)
          .cast<String>()
          .toList();

      final updatedTask = task.copyWith(dependencies: dependencies);
      await _taskRepository.updateTask(updatedTask);
    }
  }

  /// Creates project milestones
  Future<void> _createProjectMilestones(
    ProjectTemplate template,
    String projectId,
    Map<String, String> taskIdMapping,
  ) async {
    // Implementation would create milestone entities if they exist
    // For now, this is a placeholder for milestone creation logic
  }

  /// Checks if a wizard step should be shown based on conditions
  bool _shouldShowStep(TemplateWizardStep step, Map<String, dynamic> values) {
    if (step.showCondition == null) return true;

    // Simple condition evaluation - in production this would be more robust
    final condition = step.showCondition!;
    for (final entry in values.entries) {
      final placeholder = '{{${entry.key}}}';
      if (condition.contains(placeholder)) {
        final conditionWithValue = condition.replaceAll(placeholder, entry.value.toString());
        // This is a simplified evaluation - would need a proper expression parser
        return conditionWithValue.contains('true') || !conditionWithValue.contains('false');
      }
    }

    return true;
  }

  /// Adds variables to text for template creation
  String _addVariablesToText(String text, Map<String, String>? variableMappings) {
    if (variableMappings == null) return text;

    String result = text;
    for (final entry in variableMappings.entries) {
      result = result.replaceAll(entry.value, '{{${entry.key}}}');
    }
    return result;
  }

  // ============================================================================
  // SYSTEM TEMPLATE CREATION METHODS
  // ============================================================================

  ProjectTemplate _createWorkSprintTemplate() {
    const templateId = 'system-work-sprint';
    
    final variables = [
      const TemplateVariable(
        key: 'sprint_name',
        displayName: 'Sprint Name',
        type: TemplateVariableType.text,
        isRequired: true,
        defaultValue: 'Sprint 1',
      ),
      const TemplateVariable(
        key: 'sprint_duration',
        displayName: 'Sprint Duration (weeks)',
        type: TemplateVariableType.number,
        isRequired: true,
        defaultValue: 2,
        minValue: 1,
        maxValue: 4,
      ),
      const TemplateVariable(
        key: 'team_size',
        displayName: 'Team Size',
        type: TemplateVariableType.number,
        isRequired: true,
        defaultValue: 5,
        minValue: 1,
        maxValue: 20,
      ),
    ];

    final wizardSteps = [
      const TemplateWizardStep(
        id: 'basic_info',
        title: 'Basic Information',
        description: 'Configure your sprint basics',
        variableKeys: ['sprint_name', 'sprint_duration'],
        order: 0,
        iconName: 'info',
      ),
      const TemplateWizardStep(
        id: 'team_setup',
        title: 'Team Setup',
        description: 'Configure your team',
        variableKeys: ['team_size'],
        order: 1,
        iconName: 'users',
      ),
    ];

    final taskTemplates = [
      TaskTemplate.create(
        name: 'Sprint Planning',
        titleTemplate: '{{sprint_name}} - Sprint Planning',
        descriptionTemplate: 'Plan the {{sprint_name}} sprint with {{team_size}} team members',
        priority: TaskPriority.high,
        estimatedDuration: 120,
        tags: const ['planning', 'sprint'],
      ),
      TaskTemplate.create(
        name: 'Daily Standups',
        titleTemplate: '{{sprint_name}} - Daily Standups',
        descriptionTemplate: 'Daily standup meetings for {{sprint_name}}',
        priority: TaskPriority.medium,
        estimatedDuration: 15,
        tags: const ['standup', 'daily'],
      ),
      TaskTemplate.create(
        name: 'Sprint Review',
        titleTemplate: '{{sprint_name}} - Sprint Review',
        descriptionTemplate: 'Review completed work for {{sprint_name}}',
        priority: TaskPriority.high,
        estimatedDuration: 60,
        tags: const ['review', 'demo'],
      ),
      TaskTemplate.create(
        name: 'Sprint Retrospective',
        titleTemplate: '{{sprint_name}} - Retrospective',
        descriptionTemplate: 'Retrospective meeting for {{sprint_name}}',
        priority: TaskPriority.medium,
        estimatedDuration: 45,
        tags: const ['retrospective', 'improvement'],
      ),
    ];

    return ProjectTemplate(
      id: templateId,
      name: 'Work Sprint',
      description: 'Complete sprint template for agile development teams',
      shortDescription: 'Agile sprint with planning, standups, and reviews',
      type: ProjectTemplateType.wizard,
      industryTags: const ['software', 'agile', 'development'],
      difficultyLevel: 2,
      estimatedHours: 80,
      projectNameTemplate: '{{sprint_name}} Sprint',
      projectDescriptionTemplate: 'Sprint project for {{team_size}} team members over {{sprint_duration}} weeks',
      defaultColor: '#1976D2',
      deadlineOffsetDays: 14, // 2 weeks default
      taskTemplates: taskTemplates,
      variables: variables,
      wizardSteps: wizardSteps,
      createdAt: DateTime.now(),
      isSystemTemplate: true,
      isPublished: true,
      version: '1.0.0',
      usageStats: TemplateUsageStats.initial(),
      tags: const ['work', 'agile', 'sprint', 'development'],
      sizeEstimate: TemplateSizeEstimate.calculate(taskTemplates),
    );
  }

  ProjectTemplate _createEventPlanningTemplate() {
    const templateId = 'system-event-planning';
    
    final variables = [
      const TemplateVariable(
        key: 'event_name',
        displayName: 'Event Name',
        type: TemplateVariableType.text,
        isRequired: true,
      ),
      const TemplateVariable(
        key: 'event_date',
        displayName: 'Event Date',
        type: TemplateVariableType.date,
        isRequired: true,
      ),
      const TemplateVariable(
        key: 'guest_count',
        displayName: 'Expected Guests',
        type: TemplateVariableType.number,
        isRequired: true,
        defaultValue: 50,
        minValue: 1,
      ),
      const TemplateVariable(
        key: 'event_type',
        displayName: 'Event Type',
        type: TemplateVariableType.choice,
        isRequired: true,
        options: ['Wedding', 'Conference', 'Birthday Party', 'Corporate Event', 'Other'],
      ),
    ];

    final taskTemplates = [
      TaskTemplate.create(
        name: 'Venue Booking',
        titleTemplate: 'Book venue for {{event_name}}',
        descriptionTemplate: 'Find and book venue for {{guest_count}} guests',
        priority: TaskPriority.high,
        estimatedDuration: 180,
        tags: const ['venue', 'booking'],
      ),
      TaskTemplate.create(
        name: 'Send Invitations',
        titleTemplate: 'Send invitations for {{event_name}}',
        descriptionTemplate: 'Create and send invitations to {{guest_count}} guests',
        priority: TaskPriority.medium,
        estimatedDuration: 120,
        tags: const ['invitations', 'guests'],
      ),
      // Add more event planning tasks...
    ];

    return ProjectTemplate(
      id: templateId,
      name: 'Event Planning',
      description: 'comprehensive template for planning any type of event',
      shortDescription: 'Complete event planning with venue, catering, and coordination',
      type: ProjectTemplateType.wizard,
      industryTags: const ['events', 'planning', 'hospitality'],
      difficultyLevel: 3,
      estimatedHours: 40,
      projectNameTemplate: '{{event_name}} Planning',
      projectDescriptionTemplate: 'Planning {{event_type}} for {{guest_count}} guests',
      defaultColor: '#E91E63',
      taskTemplates: taskTemplates,
      variables: variables,
      createdAt: DateTime.now(),
      isSystemTemplate: true,
      isPublished: true,
      version: '1.0.0',
      usageStats: TemplateUsageStats.initial(),
      tags: const ['event', 'planning', 'coordination'],
      sizeEstimate: TemplateSizeEstimate.calculate(taskTemplates),
    );
  }

  ProjectTemplate _createCourseManagementTemplate() {
    const templateId = 'system-course-management';
    
    return ProjectTemplate(
      id: templateId,
      name: 'Course Management',
      description: 'Template for creating and managing educational courses',
      shortDescription: 'Educational course with lessons, assignments, and assessments',
      type: ProjectTemplateType.simple,
      industryTags: const ['education', 'learning', 'teaching'],
      difficultyLevel: 2,
      projectNameTemplate: 'Course: {{course_name}}',
      defaultColor: '#4CAF50',
      taskTemplates: const [], // Would include lesson planning, assignment creation, etc.
      createdAt: DateTime.now(),
      isSystemTemplate: true,
      isPublished: true,
      version: '1.0.0',
      usageStats: TemplateUsageStats.initial(),
      tags: const ['education', 'course', 'teaching'],
      sizeEstimate: TemplateSizeEstimate.calculate(const []),
    );
  }

  ProjectTemplate _createHomeRenovationTemplate() {
    const templateId = 'system-home-renovation';
    
    return ProjectTemplate(
      id: templateId,
      name: 'Home Renovation',
      description: 'Complete template for home renovation projects',
      shortDescription: 'Home renovation with planning, contractors, and execution',
      type: ProjectTemplateType.advanced,
      industryTags: const ['home', 'renovation', 'construction'],
      difficultyLevel: 4,
      projectNameTemplate: 'Renovate {{room_name}}',
      defaultColor: '#FF9800',
      taskTemplates: const [], // Would include planning, permits, contractor coordination, etc.
      createdAt: DateTime.now(),
      isSystemTemplate: true,
      isPublished: true,
      version: '1.0.0',
      usageStats: TemplateUsageStats.initial(),
      tags: const ['home', 'renovation', 'diy'],
      sizeEstimate: TemplateSizeEstimate.calculate(const []),
    );
  }

  ProjectTemplate _createProductLaunchTemplate() {
    const templateId = 'system-product-launch';
    
    return ProjectTemplate(
      id: templateId,
      name: 'Product Launch',
      description: 'Comprehensive product launch template with marketing and operations',
      shortDescription: 'Product launch with marketing, PR, and operations coordination',
      type: ProjectTemplateType.wizard,
      industryTags: const ['marketing', 'product', 'launch'],
      difficultyLevel: 4,
      projectNameTemplate: '{{product_name}} Launch',
      defaultColor: '#9C27B0',
      taskTemplates: const [], // Would include marketing, PR, operations tasks
      createdAt: DateTime.now(),
      isSystemTemplate: true,
      isPublished: true,
      version: '1.0.0',
      usageStats: TemplateUsageStats.initial(),
      tags: const ['product', 'launch', 'marketing'],
      sizeEstimate: TemplateSizeEstimate.calculate(const []),
    );
  }

  ProjectTemplate _createWeddingPlanningTemplate() {
    const templateId = 'system-wedding-planning';
    
    return ProjectTemplate(
      id: templateId,
      name: 'Wedding Planning',
      description: 'Complete wedding planning template with timeline and checklist',
      shortDescription: 'Wedding planning with venue, vendors, and timeline management',
      type: ProjectTemplateType.wizard,
      industryTags: const ['wedding', 'planning', 'events'],
      difficultyLevel: 5,
      projectNameTemplate: '{{bride_name}} & {{groom_name}} Wedding',
      defaultColor: '#FF69B4',
      taskTemplates: const [], // Would include venue, catering, photography, etc.
      createdAt: DateTime.now(),
      isSystemTemplate: true,
      isPublished: true,
      version: '1.0.0',
      usageStats: TemplateUsageStats.initial(),
      tags: const ['wedding', 'planning', 'celebration'],
      sizeEstimate: TemplateSizeEstimate.calculate(const []),
    );
  }
}