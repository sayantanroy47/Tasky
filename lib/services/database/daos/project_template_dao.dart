import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database.dart';
import '../tables.dart';
import '../../../domain/entities/project_template.dart' as domain;
import '../../../domain/entities/task_template.dart' as task_domain;

part 'project_template_dao.g.dart';

/// Data Access Object for ProjectTemplate operations
@DriftAccessor(tables: [
  ProjectTemplates,
  ProjectTemplateVariables,
  ProjectTemplateWizardSteps,
  ProjectTemplateMilestones,
  ProjectTemplateTaskTemplates,
])
class ProjectTemplateDao extends DatabaseAccessor<AppDatabase> with _$ProjectTemplateDaoMixin {
  ProjectTemplateDao(super.db);

  // ============================================================================
  // BASIC CRUD OPERATIONS
  // ============================================================================

  /// Gets all project templates
  Future<List<domain.ProjectTemplate>> getAllTemplates() async {
    final rows = await select(projectTemplates).get();
    final templates = <domain.ProjectTemplate>[];
    
    for (final row in rows) {
      templates.add(await _mapRowToProjectTemplate(row));
    }
    
    return templates;
  }

  /// Gets a project template by ID
  Future<domain.ProjectTemplate?> getTemplateById(String id) async {
    final query = select(projectTemplates)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? await _mapRowToProjectTemplate(row) : null;
  }

  /// Creates a new project template
  Future<void> createTemplate(domain.ProjectTemplate template) async {
    await transaction(() async {
      // Insert main template record
      await into(projectTemplates).insert(_mapProjectTemplateToRow(template));
      
      // Insert variables
      for (final variable in template.variables) {
        await into(projectTemplateVariables).insert(
          _mapVariableToRow(variable, template.id),
        );
      }
      
      // Insert wizard steps
      for (final step in template.wizardSteps) {
        await into(projectTemplateWizardSteps).insert(
          _mapWizardStepToRow(step, template.id),
        );
      }
      
      // Insert milestones
      for (final milestone in template.milestones) {
        await into(projectTemplateMilestones).insert(
          _mapMilestoneToRow(milestone, template.id),
        );
      }
      
      // Insert task template associations
      for (int i = 0; i < template.taskTemplates.length; i++) {
        final taskTemplate = template.taskTemplates[i];
        await into(projectTemplateTaskTemplates).insert(
          ProjectTemplateTaskTemplatesCompanion(
            projectTemplateId: Value(template.id),
            taskTemplateId: Value(taskTemplate.id),
            sortOrder: Value(i),
            taskDependencies: Value(jsonEncode(
              template.taskDependencies[taskTemplate.id] ?? [],
            )),
          ),
        );
      }
    });
  }

  /// Updates an existing project template
  Future<void> updateTemplate(domain.ProjectTemplate template) async {
    await transaction(() async {
      // Update main template record
      await (update(projectTemplates)..where((t) => t.id.equals(template.id)))
          .write(_mapProjectTemplateToRow(template));
      
      // Delete existing related records
      await (delete(projectTemplateVariables)
            ..where((v) => v.templateId.equals(template.id))).go();
      await (delete(projectTemplateWizardSteps)
            ..where((s) => s.templateId.equals(template.id))).go();
      await (delete(projectTemplateMilestones)
            ..where((m) => m.templateId.equals(template.id))).go();
      await (delete(projectTemplateTaskTemplates)
            ..where((tt) => tt.projectTemplateId.equals(template.id))).go();
      
      // Re-insert variables
      for (final variable in template.variables) {
        await into(projectTemplateVariables).insert(
          _mapVariableToRow(variable, template.id),
        );
      }
      
      // Re-insert wizard steps
      for (final step in template.wizardSteps) {
        await into(projectTemplateWizardSteps).insert(
          _mapWizardStepToRow(step, template.id),
        );
      }
      
      // Re-insert milestones
      for (final milestone in template.milestones) {
        await into(projectTemplateMilestones).insert(
          _mapMilestoneToRow(milestone, template.id),
        );
      }
      
      // Re-insert task template associations
      for (int i = 0; i < template.taskTemplates.length; i++) {
        final taskTemplate = template.taskTemplates[i];
        await into(projectTemplateTaskTemplates).insert(
          ProjectTemplateTaskTemplatesCompanion(
            projectTemplateId: Value(template.id),
            taskTemplateId: Value(taskTemplate.id),
            sortOrder: Value(i),
            taskDependencies: Value(jsonEncode(
              template.taskDependencies[taskTemplate.id] ?? [],
            )),
          ),
        );
      }
    });
  }

  /// Deletes a project template
  Future<void> deleteTemplate(String id) async {
    await transaction(() async {
      // Delete related records first (cascade will handle some, but explicit is safer)
      await (delete(projectTemplateVariables)
            ..where((v) => v.templateId.equals(id))).go();
      await (delete(projectTemplateWizardSteps)
            ..where((s) => s.templateId.equals(id))).go();
      await (delete(projectTemplateMilestones)
            ..where((m) => m.templateId.equals(id))).go();
      await (delete(projectTemplateTaskTemplates)
            ..where((tt) => tt.projectTemplateId.equals(id))).go();
      
      // Delete main template
      await (delete(projectTemplates)..where((t) => t.id.equals(id))).go();
    });
  }

  /// Checks if a template exists
  Future<bool> exists(String id) async {
    final query = select(projectTemplates)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null;
  }

  // ============================================================================
  // FILTERING AND SEARCH OPERATIONS
  // ============================================================================

  /// Gets templates with filtering options
  Future<List<domain.ProjectTemplate>> findAll({
    String? categoryId,
    List<String>? tags,
    domain.ProjectTemplateType? type,
    int? maxDifficultyLevel,
    bool? isPublished,
    bool? isPremium,
    String? searchQuery,
  }) async {
    var query = select(projectTemplates);
    
    // Apply filters
    if (categoryId != null) {
      query = query..where((t) => t.categoryId.equals(categoryId));
    }
    
    if (type != null) {
      query = query..where((t) => t.type.equals(type.index));
    }
    
    if (maxDifficultyLevel != null) {
      query = query..where((t) => t.difficultyLevel.isSmallerOrEqualValue(maxDifficultyLevel));
    }
    
    if (isPublished != null) {
      query = query..where((t) => t.isPublished.equals(isPublished));
    }
    
    if (isPremium != null) {
      query = query..where((t) => t.isPremium.equals(isPremium));
    }
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final searchTerm = '%$searchQuery%';
      query = query..where((t) => 
          t.name.like(searchTerm) |
          t.description.like(searchTerm) |
          t.shortDescription.like(searchTerm) |
          t.tags.like(searchTerm));
    }
    
    final rows = await query.get();
    final templates = <domain.ProjectTemplate>[];
    
    for (final row in rows) {
      final template = await _mapRowToProjectTemplate(row);
      
      // Additional tag filtering (since tags are stored as JSON)
      if (tags != null && tags.isNotEmpty) {
        final hasMatchingTags = tags.any((tag) => template.tags.contains(tag));
        if (!hasMatchingTags) continue;
      }
      
      templates.add(template);
    }
    
    return templates;
  }

  /// Searches templates by query
  Future<List<domain.ProjectTemplate>> search(String query) async {
    if (query.trim().isEmpty) {
      return await getAllTemplates();
    }
    
    return await findAll(searchQuery: query);
  }

  /// Gets popular templates (by usage statistics)
  Future<List<domain.ProjectTemplate>> getPopularTemplates({int limit = 10}) async {
    final rows = await (select(projectTemplates)
          ..where((t) => t.isPublished.equals(true))
          ..limit(limit))
        .get();
    
    final templates = <domain.ProjectTemplate>[];
    for (final row in rows) {
      templates.add(await _mapRowToProjectTemplate(row));
    }
    
    // Sort by trending score and usage count
    templates.sort((a, b) {
      final scoreA = a.usageStats.trendingScore + (a.usageStats.usageCount * 0.1);
      final scoreB = b.usageStats.trendingScore + (b.usageStats.usageCount * 0.1);
      return scoreB.compareTo(scoreA);
    });
    
    return templates.take(limit).toList();
  }

  /// Gets system templates
  Future<List<domain.ProjectTemplate>> getSystemTemplates() async {
    final query = select(projectTemplates)
      ..where((t) => t.isSystemTemplate.equals(true))
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
    
    final rows = await query.get();
    final templates = <domain.ProjectTemplate>[];
    
    for (final row in rows) {
      templates.add(await _mapRowToProjectTemplate(row));
    }
    
    return templates;
  }

  /// Gets user templates (non-system)
  Future<List<domain.ProjectTemplate>> getUserTemplates() async {
    final query = select(projectTemplates)
      ..where((t) => t.isSystemTemplate.equals(false))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);
    
    final rows = await query.get();
    final templates = <domain.ProjectTemplate>[];
    
    for (final row in rows) {
      templates.add(await _mapRowToProjectTemplate(row));
    }
    
    return templates;
  }

  /// Gets templates by category
  Future<List<domain.ProjectTemplate>> getTemplatesByCategory(String categoryId) async {
    return await findAll(categoryId: categoryId, isPublished: true);
  }

  /// Gets templates by type
  Future<List<domain.ProjectTemplate>> getTemplatesByType(domain.ProjectTemplateType type) async {
    return await findAll(type: type, isPublished: true);
  }

  // ============================================================================
  // STREAMING OPERATIONS
  // ============================================================================

  /// Watches all templates (returns a stream)
  Stream<List<domain.ProjectTemplate>> watchAllTemplates() {
    return select(projectTemplates).watch().asyncMap((rows) async {
      final templates = <domain.ProjectTemplate>[];
      for (final row in rows) {
        templates.add(await _mapRowToProjectTemplate(row));
      }
      return templates;
    });
  }

  /// Watches published templates
  Stream<List<domain.ProjectTemplate>> watchPublishedTemplates() {
    final query = select(projectTemplates)
      ..where((t) => t.isPublished.equals(true))
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
    
    return query.watch().asyncMap((rows) async {
      final templates = <domain.ProjectTemplate>[];
      for (final row in rows) {
        templates.add(await _mapRowToProjectTemplate(row));
      }
      return templates;
    });
  }

  /// Watches system templates
  Stream<List<domain.ProjectTemplate>> watchSystemTemplates() {
    final query = select(projectTemplates)
      ..where((t) => t.isSystemTemplate.equals(true))
      ..orderBy([(t) => OrderingTerm(expression: t.name)]);
    
    return query.watch().asyncMap((rows) async {
      final templates = <domain.ProjectTemplate>[];
      for (final row in rows) {
        templates.add(await _mapRowToProjectTemplate(row));
      }
      return templates;
    });
  }

  /// Watches user templates
  Stream<List<domain.ProjectTemplate>> watchUserTemplates() {
    final query = select(projectTemplates)
      ..where((t) => t.isSystemTemplate.equals(false))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);
    
    return query.watch().asyncMap((rows) async {
      final templates = <domain.ProjectTemplate>[];
      for (final row in rows) {
        templates.add(await _mapRowToProjectTemplate(row));
      }
      return templates;
    });
  }

  // ============================================================================
  // PRIVATE MAPPING METHODS
  // ============================================================================

  /// Maps a database row to a ProjectTemplate
  Future<domain.ProjectTemplate> _mapRowToProjectTemplate(ProjectTemplate row) async {
    // Get variables
    final variableRows = await (select(projectTemplateVariables)
          ..where((v) => v.templateId.equals(row.id))
          ..orderBy([(v) => OrderingTerm(expression: v.sortOrder)]))
        .get();
    
    final variables = variableRows.map(_mapRowToVariable).toList();

    // Get wizard steps
    final stepRows = await (select(projectTemplateWizardSteps)
          ..where((s) => s.templateId.equals(row.id))
          ..orderBy([(s) => OrderingTerm(expression: s.stepOrder)]))
        .get();
    
    final wizardSteps = stepRows.map(_mapRowToWizardStep).toList();

    // Get milestones
    final milestoneRows = await (select(projectTemplateMilestones)
          ..where((m) => m.templateId.equals(row.id))
          ..orderBy([(m) => OrderingTerm(expression: m.sortOrder)]))
        .get();
    
    final milestones = milestoneRows.map(_mapRowToMilestone).toList();

    // Get task template associations
    final taskTemplateRows = await (select(projectTemplateTaskTemplates)
          ..where((tt) => tt.projectTemplateId.equals(row.id))
          ..orderBy([(tt) => OrderingTerm(expression: tt.sortOrder)]))
        .get();
    
    // For now, create empty task templates - in a full implementation,
    // you would fetch the actual task templates from the TaskTemplateDao
    final taskTemplates = <task_domain.TaskTemplate>[];
    final taskDependencies = <String, List<String>>{};
    
    for (final taskTemplateRow in taskTemplateRows) {
      // This would fetch actual task template from TaskTemplateDao
      // taskTemplates.add(await _getTaskTemplateById(taskTemplateRow.taskTemplateId));
      
      final dependencies = List<String>.from(jsonDecode(taskTemplateRow.taskDependencies));
      if (dependencies.isNotEmpty) {
        taskDependencies[taskTemplateRow.taskTemplateId] = dependencies;
      }
    }

    return domain.ProjectTemplate(
      id: row.id,
      name: row.name,
      description: row.description?.isEmpty == true ? null : row.description,
      shortDescription: row.shortDescription?.isEmpty == true ? null : row.shortDescription,
      type: domain.ProjectTemplateType.values[row.type],
      categoryId: row.categoryId?.isEmpty == true ? null : row.categoryId,
      industryTags: List<String>.from(jsonDecode(row.industryTags)),
      difficultyLevel: row.difficultyLevel,
      estimatedHours: row.estimatedHours,
      projectNameTemplate: row.projectNameTemplate,
      projectDescriptionTemplate: row.projectDescriptionTemplate?.isEmpty == true 
          ? null 
          : row.projectDescriptionTemplate,
      defaultColor: row.defaultColor,
      projectCategoryId: row.projectCategoryId?.isEmpty == true ? null : row.projectCategoryId,
      deadlineOffsetDays: row.deadlineOffsetDays,
      taskTemplates: taskTemplates,
      variables: variables,
      wizardSteps: wizardSteps,
      taskDependencies: taskDependencies,
      milestones: milestones,
      resourceTemplates: Map<String, dynamic>.from(jsonDecode(row.resourceTemplates)),
      metadata: Map<String, dynamic>.from(jsonDecode(row.metadata)),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      createdBy: row.createdBy?.isEmpty == true ? null : row.createdBy,
      isSystemTemplate: row.isSystemTemplate,
      isPublished: row.isPublished,
      version: row.version,
      usageStats: domain.TemplateUsageStats.fromJson(
        Map<String, dynamic>.from(jsonDecode(row.usageStats)),
      ),
      rating: row.rating != null 
          ? domain.TemplateRating.fromJson(Map<String, dynamic>.from(jsonDecode(row.rating!)))
          : null,
      previewImages: List<String>.from(jsonDecode(row.previewImages)),
      tags: List<String>.from(jsonDecode(row.tags)),
      supportedLocales: List<String>.from(jsonDecode(row.supportedLocales)),
      isPremium: row.isPremium,
      sizeEstimate: domain.TemplateSizeEstimate.fromJson(
        Map<String, dynamic>.from(jsonDecode(row.sizeEstimate)),
      ),
    );
  }

  /// Maps a ProjectTemplate to a database row
  ProjectTemplatesCompanion _mapProjectTemplateToRow(domain.ProjectTemplate template) {
    return ProjectTemplatesCompanion(
      id: Value(template.id),
      name: Value(template.name),
      description: Value(template.description ?? ''),
      shortDescription: Value(template.shortDescription ?? ''),
      type: Value(template.type.index),
      categoryId: Value(template.categoryId ?? ''),
      industryTags: Value(jsonEncode(template.industryTags)),
      difficultyLevel: Value(template.difficultyLevel),
      estimatedHours: Value(template.estimatedHours),
      projectNameTemplate: Value(template.projectNameTemplate),
      projectDescriptionTemplate: Value(template.projectDescriptionTemplate ?? ''),
      defaultColor: Value(template.defaultColor),
      projectCategoryId: Value(template.projectCategoryId ?? ''),
      deadlineOffsetDays: Value(template.deadlineOffsetDays),
      taskTemplates: Value(jsonEncode(template.taskTemplates.map((t) => t.id).toList())),
      variables: Value(jsonEncode(template.variables.map((v) => v.toJson()).toList())),
      wizardSteps: Value(jsonEncode(template.wizardSteps.map((s) => s.toJson()).toList())),
      taskDependencies: Value(jsonEncode(template.taskDependencies)),
      milestones: Value(jsonEncode(template.milestones.map((m) => m.toJson()).toList())),
      resourceTemplates: Value(jsonEncode(template.resourceTemplates)),
      metadata: Value(jsonEncode(template.metadata)),
      createdAt: Value(template.createdAt),
      updatedAt: Value(template.updatedAt),
      createdBy: Value(template.createdBy ?? ''),
      isSystemTemplate: Value(template.isSystemTemplate),
      isPublished: Value(template.isPublished),
      version: Value(template.version),
      usageStats: Value(jsonEncode(template.usageStats.toJson())),
      rating: Value(template.rating?.toJson() != null ? jsonEncode(template.rating!.toJson()) : null),
      previewImages: Value(jsonEncode(template.previewImages)),
      tags: Value(jsonEncode(template.tags)),
      supportedLocales: Value(jsonEncode(template.supportedLocales)),
      isPremium: Value(template.isPremium),
      sizeEstimate: Value(jsonEncode(template.sizeEstimate.toJson())),
    );
  }

  /// Maps a database row to a TemplateVariable
  domain.TemplateVariable _mapRowToVariable(ProjectTemplateVariable row) {
    return domain.TemplateVariable(
      key: row.variableKey,
      displayName: row.displayName,
      type: domain.TemplateVariableType.values[row.type],
      description: row.description?.isEmpty == true ? null : row.description,
      isRequired: row.isRequired,
      defaultValue: row.defaultValue != null ? jsonDecode(row.defaultValue!) : null,
      options: List<String>.from(jsonDecode(row.options)),
      validationPattern: row.validationPattern?.isEmpty == true ? null : row.validationPattern,
      validationError: row.validationError?.isEmpty == true ? null : row.validationError,
      minValue: row.minValue != null ? jsonDecode(row.minValue!) : null,
      maxValue: row.maxValue != null ? jsonDecode(row.maxValue!) : null,
      isConditional: row.isConditional,
      dependentVariables: List<String>.from(jsonDecode(row.dependentVariables)),
    );
  }

  /// Maps a TemplateVariable to a database row
  ProjectTemplateVariablesCompanion _mapVariableToRow(domain.TemplateVariable variable, String templateId) {
    return ProjectTemplateVariablesCompanion(
      id: Value(const Uuid().v4()),
      templateId: Value(templateId),
      variableKey: Value(variable.key),
      displayName: Value(variable.displayName),
      type: Value(variable.type.index),
      description: Value(variable.description ?? ''),
      isRequired: Value(variable.isRequired),
      defaultValue: Value(variable.defaultValue != null ? jsonEncode(variable.defaultValue) : null),
      options: Value(jsonEncode(variable.options)),
      validationPattern: Value(variable.validationPattern ?? ''),
      validationError: Value(variable.validationError ?? ''),
      minValue: Value(variable.minValue != null ? jsonEncode(variable.minValue) : null),
      maxValue: Value(variable.maxValue != null ? jsonEncode(variable.maxValue) : null),
      isConditional: Value(variable.isConditional),
      dependentVariables: Value(jsonEncode(variable.dependentVariables)),
      sortOrder: const Value(0),
    );
  }

  /// Maps a database row to a TemplateWizardStep
  domain.TemplateWizardStep _mapRowToWizardStep(ProjectTemplateWizardStep row) {
    return domain.TemplateWizardStep(
      id: row.id,
      title: row.title,
      description: row.description?.isEmpty == true ? null : row.description,
      variableKeys: List<String>.from(jsonDecode(row.variableKeys)),
      showCondition: row.showCondition?.isEmpty == true ? null : row.showCondition,
      order: row.stepOrder,
      isOptional: row.isOptional,
      iconName: row.iconName?.isEmpty == true ? null : row.iconName,
    );
  }

  /// Maps a TemplateWizardStep to a database row
  ProjectTemplateWizardStepsCompanion _mapWizardStepToRow(domain.TemplateWizardStep step, String templateId) {
    return ProjectTemplateWizardStepsCompanion(
      id: Value(step.id),
      templateId: Value(templateId),
      title: Value(step.title),
      description: Value(step.description ?? ''),
      variableKeys: Value(jsonEncode(step.variableKeys)),
      showCondition: Value(step.showCondition ?? ''),
      stepOrder: Value(step.order),
      isOptional: Value(step.isOptional),
      iconName: Value(step.iconName ?? ''),
    );
  }

  /// Maps a database row to a ProjectMilestone
  domain.ProjectMilestone _mapRowToMilestone(ProjectTemplateMilestone row) {
    return domain.ProjectMilestone(
      id: row.id,
      name: row.name,
      description: row.description?.isEmpty == true ? null : row.description,
      dayOffset: row.dayOffset,
      requiredTaskIds: List<String>.from(jsonDecode(row.requiredTaskIds)),
      iconName: row.iconName?.isEmpty == true ? null : row.iconName,
    );
  }

  /// Maps a ProjectMilestone to a database row
  ProjectTemplateMilestonesCompanion _mapMilestoneToRow(domain.ProjectMilestone milestone, String templateId) {
    return ProjectTemplateMilestonesCompanion(
      id: Value(milestone.id),
      templateId: Value(templateId),
      name: Value(milestone.name),
      description: Value(milestone.description ?? ''),
      dayOffset: Value(milestone.dayOffset),
      requiredTaskIds: Value(jsonEncode(milestone.requiredTaskIds)),
      iconName: Value(milestone.iconName ?? ''),
      sortOrder: const Value(0),
    );
  }
}