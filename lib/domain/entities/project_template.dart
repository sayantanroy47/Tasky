import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'task_template.dart';

part 'project_template.g.dart';

/// Type of project template
enum ProjectTemplateType {
  /// Simple template with basic configuration
  simple,
  
  /// Wizard template with guided step-by-step creation
  wizard,
  
  /// Advanced template with complex configuration
  advanced,
}

/// Variable type for template variable substitution
enum TemplateVariableType {
  /// Text input variable
  text,
  
  /// Date picker variable
  date,
  
  /// Number input variable
  number,
  
  /// Single choice from options
  choice,
  
  /// Multiple choices from options
  multiChoice,
  
  /// Boolean checkbox variable
  boolean,
}

/// Template variable definition for dynamic form generation
@JsonSerializable()
class TemplateVariable extends Equatable {
  /// Unique key for the variable (used in substitution)
  final String key;
  
  /// Display name for the variable in forms
  final String displayName;
  
  /// Type of input for this variable
  final TemplateVariableType type;
  
  /// Optional description/help text
  final String? description;
  
  /// Whether this variable is required
  final bool isRequired;
  
  /// Default value for the variable
  final dynamic defaultValue;
  
  /// Options for choice/multiChoice types
  final List<String> options;
  
  /// Validation pattern (regex) for text inputs
  final String? validationPattern;
  
  /// Error message for validation failures
  final String? validationError;
  
  /// Minimum value for number/date types
  final dynamic minValue;
  
  /// Maximum value for number/date types
  final dynamic maxValue;
  
  /// Whether this variable affects other variables (conditional display)
  final bool isConditional;
  
  /// Variables that depend on this one
  final List<String> dependentVariables;

  const TemplateVariable({
    required this.key,
    required this.displayName,
    required this.type,
    this.description,
    this.isRequired = false,
    this.defaultValue,
    this.options = const [],
    this.validationPattern,
    this.validationError,
    this.minValue,
    this.maxValue,
    this.isConditional = false,
    this.dependentVariables = const [],
  });

  factory TemplateVariable.fromJson(Map<String, dynamic> json) => 
      _$TemplateVariableFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateVariableToJson(this);

  @override
  List<Object?> get props => [
        key,
        displayName,
        type,
        description,
        isRequired,
        defaultValue,
        options,
        validationPattern,
        validationError,
        minValue,
        maxValue,
        isConditional,
        dependentVariables,
      ];
}

/// Template step for wizard-based templates
@JsonSerializable()
class TemplateWizardStep extends Equatable {
  /// Unique identifier for the step
  final String id;
  
  /// Display title for the step
  final String title;
  
  /// Optional description for the step
  final String? description;
  
  /// Variables to collect in this step
  final List<String> variableKeys;
  
  /// Condition to show this step (based on previous variables)
  final String? showCondition;
  
  /// Order of this step in the wizard
  final int order;
  
  /// Whether this step can be skipped
  final bool isOptional;
  
  /// Icon name for the step
  final String? iconName;

  const TemplateWizardStep({
    required this.id,
    required this.title,
    this.description,
    required this.variableKeys,
    this.showCondition,
    required this.order,
    this.isOptional = false,
    this.iconName,
  });

  factory TemplateWizardStep.fromJson(Map<String, dynamic> json) => 
      _$TemplateWizardStepFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateWizardStepToJson(this);

  /// Create a copy of this step with optional parameter overrides
  TemplateWizardStep copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? variableKeys,
    String? showCondition,
    int? order,
    bool? isOptional,
    String? iconName,
  }) {
    return TemplateWizardStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      variableKeys: variableKeys ?? this.variableKeys,
      showCondition: showCondition ?? this.showCondition,
      order: order ?? this.order,
      isOptional: isOptional ?? this.isOptional,
      iconName: iconName ?? this.iconName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        variableKeys,
        showCondition,
        order,
        isOptional,
        iconName,
      ];
}

/// Comprehensive project template with wizard creation capabilities
/// 
/// ProjectTemplate allows users to create entire projects with predefined
/// tasks, configuration, and guided wizard flows for complex project setup.
@JsonSerializable()
class ProjectTemplate extends Equatable {
  /// Unique identifier for the template
  final String id;
  
  /// Name of the template
  final String name;
  
  /// Detailed description of the template
  final String? description;
  
  /// Short description for preview/cards
  final String? shortDescription;
  
  /// Type of template (simple, wizard, advanced)
  final ProjectTemplateType type;
  
  /// Category ID for template organization
  final String? categoryId;
  
  /// Industry/domain tags for filtering
  final List<String> industryTags;
  
  /// Difficulty level (1-5, where 1 is beginner, 5 is expert)
  final int difficultyLevel;
  
  /// Estimated time to complete project (in hours)
  final int? estimatedHours;
  
  /// Template for project name with variables
  final String projectNameTemplate;
  
  /// Template for project description with variables
  final String? projectDescriptionTemplate;
  
  /// Default project color (hex code)
  final String defaultColor;
  
  /// Project category ID template
  final String? projectCategoryId;
  
  /// Default project deadline offset (days from creation)
  final int? deadlineOffsetDays;
  
  /// List of task templates for this project
  final List<TaskTemplate> taskTemplates;
  
  /// Template variables for customization
  final List<TemplateVariable> variables;
  
  /// Wizard steps for guided creation
  final List<TemplateWizardStep> wizardSteps;
  
  /// Dependencies between tasks in template
  final Map<String, List<String>> taskDependencies;
  
  /// Milestone definitions
  final List<ProjectMilestone> milestones;
  
  /// Resource allocation templates
  final Map<String, dynamic> resourceTemplates;
  
  /// Template metadata
  final Map<String, dynamic> metadata;
  
  /// When this template was created
  final DateTime createdAt;
  
  /// When this template was last updated
  final DateTime? updatedAt;
  
  /// Creator information
  final String? createdBy;
  
  /// Whether this is a system template
  final bool isSystemTemplate;
  
  /// Whether this template is published/shareable
  final bool isPublished;
  
  /// Template version for updates
  final String version;
  
  /// Usage statistics
  final TemplateUsageStats usageStats;
  
  /// Rating and review information
  final TemplateRating? rating;
  
  /// Preview images/screenshots
  final List<String> previewImages;
  
  /// Template tags for search/filtering
  final List<String> tags;
  
  /// Supported languages/locales
  final List<String> supportedLocales;
  
  /// Whether template requires premium subscription
  final bool isPremium;
  
  /// Template size estimate (number of tasks/complexity)
  final TemplateSizeEstimate sizeEstimate;

  const ProjectTemplate({
    required this.id,
    required this.name,
    this.description,
    this.shortDescription,
    required this.type,
    this.categoryId,
    this.industryTags = const [],
    this.difficultyLevel = 1,
    this.estimatedHours,
    required this.projectNameTemplate,
    this.projectDescriptionTemplate,
    this.defaultColor = '#2196F3',
    this.projectCategoryId,
    this.deadlineOffsetDays,
    this.taskTemplates = const [],
    this.variables = const [],
    this.wizardSteps = const [],
    this.taskDependencies = const {},
    this.milestones = const [],
    this.resourceTemplates = const {},
    this.metadata = const {},
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.isSystemTemplate = false,
    this.isPublished = false,
    this.version = '1.0.0',
    required this.usageStats,
    this.rating,
    this.previewImages = const [],
    this.tags = const [],
    this.supportedLocales = const ['en'],
    this.isPremium = false,
    required this.sizeEstimate,
  });

  /// Creates a new template with generated ID and current timestamp
  factory ProjectTemplate.create({
    required String name,
    String? description,
    String? shortDescription,
    ProjectTemplateType type = ProjectTemplateType.simple,
    String? categoryId,
    List<String> industryTags = const [],
    int difficultyLevel = 1,
    int? estimatedHours,
    required String projectNameTemplate,
    String? projectDescriptionTemplate,
    String defaultColor = '#2196F3',
    String? projectCategoryId,
    int? deadlineOffsetDays,
    List<TaskTemplate> taskTemplates = const [],
    List<TemplateVariable> variables = const [],
    List<TemplateWizardStep> wizardSteps = const [],
    Map<String, List<String>> taskDependencies = const {},
    List<ProjectMilestone> milestones = const [],
    Map<String, dynamic> resourceTemplates = const {},
    Map<String, dynamic> metadata = const {},
    String? createdBy,
    bool isSystemTemplate = false,
    bool isPublished = false,
    String version = '1.0.0',
    List<String> previewImages = const [],
    List<String> tags = const [],
    List<String> supportedLocales = const ['en'],
    bool isPremium = false,
  }) {
    final now = DateTime.now();
    return ProjectTemplate(
      id: const Uuid().v4(),
      name: name,
      description: description,
      shortDescription: shortDescription,
      type: type,
      categoryId: categoryId,
      industryTags: industryTags,
      difficultyLevel: difficultyLevel,
      estimatedHours: estimatedHours,
      projectNameTemplate: projectNameTemplate,
      projectDescriptionTemplate: projectDescriptionTemplate,
      defaultColor: defaultColor,
      projectCategoryId: projectCategoryId,
      deadlineOffsetDays: deadlineOffsetDays,
      taskTemplates: taskTemplates,
      variables: variables,
      wizardSteps: wizardSteps,
      taskDependencies: taskDependencies,
      milestones: milestones,
      resourceTemplates: resourceTemplates,
      metadata: metadata,
      createdAt: now,
      createdBy: createdBy,
      isSystemTemplate: isSystemTemplate,
      isPublished: isPublished,
      version: version,
      usageStats: TemplateUsageStats.initial(),
      previewImages: previewImages,
      tags: tags,
      supportedLocales: supportedLocales,
      isPremium: isPremium,
      sizeEstimate: TemplateSizeEstimate.calculate(taskTemplates),
    );
  }

  /// Creates a ProjectTemplate from JSON
  factory ProjectTemplate.fromJson(Map<String, dynamic> json) => 
      _$ProjectTemplateFromJson(json);

  /// Converts this ProjectTemplate to JSON
  Map<String, dynamic> toJson() => _$ProjectTemplateToJson(this);

  /// Creates a copy of this template with updated fields
  ProjectTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? shortDescription,
    ProjectTemplateType? type,
    String? categoryId,
    List<String>? industryTags,
    int? difficultyLevel,
    int? estimatedHours,
    String? projectNameTemplate,
    String? projectDescriptionTemplate,
    String? defaultColor,
    String? projectCategoryId,
    int? deadlineOffsetDays,
    List<TaskTemplate>? taskTemplates,
    List<TemplateVariable>? variables,
    List<TemplateWizardStep>? wizardSteps,
    Map<String, List<String>>? taskDependencies,
    List<ProjectMilestone>? milestones,
    Map<String, dynamic>? resourceTemplates,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool? isSystemTemplate,
    bool? isPublished,
    String? version,
    TemplateUsageStats? usageStats,
    TemplateRating? rating,
    List<String>? previewImages,
    List<String>? tags,
    List<String>? supportedLocales,
    bool? isPremium,
    TemplateSizeEstimate? sizeEstimate,
  }) {
    return ProjectTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      industryTags: industryTags ?? this.industryTags,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      projectNameTemplate: projectNameTemplate ?? this.projectNameTemplate,
      projectDescriptionTemplate: projectDescriptionTemplate ?? this.projectDescriptionTemplate,
      defaultColor: defaultColor ?? this.defaultColor,
      projectCategoryId: projectCategoryId ?? this.projectCategoryId,
      deadlineOffsetDays: deadlineOffsetDays ?? this.deadlineOffsetDays,
      taskTemplates: taskTemplates ?? this.taskTemplates,
      variables: variables ?? this.variables,
      wizardSteps: wizardSteps ?? this.wizardSteps,
      taskDependencies: taskDependencies ?? this.taskDependencies,
      milestones: milestones ?? this.milestones,
      resourceTemplates: resourceTemplates ?? this.resourceTemplates,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      createdBy: createdBy ?? this.createdBy,
      isSystemTemplate: isSystemTemplate ?? this.isSystemTemplate,
      isPublished: isPublished ?? this.isPublished,
      version: version ?? this.version,
      usageStats: usageStats ?? this.usageStats,
      rating: rating ?? this.rating,
      previewImages: previewImages ?? this.previewImages,
      tags: tags ?? this.tags,
      supportedLocales: supportedLocales ?? this.supportedLocales,
      isPremium: isPremium ?? this.isPremium,
      sizeEstimate: sizeEstimate ?? this.sizeEstimate,
    );
  }

  /// Increments the usage count
  ProjectTemplate incrementUsage() {
    return copyWith(
      usageStats: usageStats.incrementUsage(),
      updatedAt: DateTime.now(),
    );
  }

  /// Updates the rating
  ProjectTemplate updateRating(double newRating, int newReviewCount) {
    final currentRating = rating ?? TemplateRating.initial();
    return copyWith(
      rating: currentRating.update(newRating, newReviewCount),
      updatedAt: DateTime.now(),
    );
  }

  /// Publishes the template
  ProjectTemplate publish() {
    return copyWith(
      isPublished: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Unpublishes the template
  ProjectTemplate unpublish() {
    return copyWith(
      isPublished: false,
      updatedAt: DateTime.now(),
    );
  }

  /// Validates the template data
  bool isValid() {
    if (id.isEmpty || name.trim().isEmpty || projectNameTemplate.trim().isEmpty) {
      return false;
    }
    
    // Validate color format
    if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(defaultColor)) {
      return false;
    }
    
    // Validate difficulty level
    if (difficultyLevel < 1 || difficultyLevel > 5) {
      return false;
    }
    
    // Validate task templates
    for (final taskTemplate in taskTemplates) {
      if (!taskTemplate.isValid()) {
        return false;
      }
    }
    
    // Validate variables
    for (final variable in variables) {
      if (variable.key.isEmpty || variable.displayName.isEmpty) {
        return false;
      }
    }
    
    // Validate wizard steps for wizard templates
    if (type == ProjectTemplateType.wizard) {
      if (wizardSteps.isEmpty) return false;
      
      // Check step ordering
      final orders = wizardSteps.map((s) => s.order).toList()..sort();
      for (int i = 0; i < orders.length; i++) {
        if (orders[i] != i) return false;
      }
    }
    
    return true;
  }

  /// Returns true if this template has tasks
  bool get hasTasks => taskTemplates.isNotEmpty;

  /// Returns true if this template has variables
  bool get hasVariables => variables.isNotEmpty;

  /// Returns true if this template is a wizard
  bool get isWizard => type == ProjectTemplateType.wizard;

  /// Returns true if this template has dependencies
  bool get hasDependencies => taskDependencies.isNotEmpty;

  /// Returns true if this template has milestones
  bool get hasMilestones => milestones.isNotEmpty;

  /// Returns true if this template can be modified
  bool get canModify => !isSystemTemplate;

  /// Returns the template complexity score
  int get complexityScore {
    int score = 0;
    score += taskTemplates.length * 2;
    score += variables.length;
    score += wizardSteps.length * 3;
    score += taskDependencies.length;
    score += milestones.length * 2;
    return score;
  }

  /// Gets variables for a specific wizard step
  List<TemplateVariable> getVariablesForStep(String stepId) {
    final step = wizardSteps.firstWhere(
      (s) => s.id == stepId,
      orElse: () => throw ArgumentError('Step not found: $stepId'),
    );
    
    return variables.where((v) => step.variableKeys.contains(v.key)).toList();
  }

  /// Replaces template variables in text
  String replaceVariables(String text, Map<String, dynamic> values) {
    String result = text;
    
    for (final variable in variables) {
      final value = values[variable.key];
      if (value != null) {
        result = result.replaceAll('{{${variable.key}}}', value.toString());
      }
    }
    
    // Replace common date placeholders
    final now = DateTime.now();
    result = result.replaceAll('{{today}}', _formatDate(now));
    result = result.replaceAll('{{tomorrow}}', _formatDate(now.add(const Duration(days: 1))));
    result = result.replaceAll('{{next_week}}', _formatDate(now.add(const Duration(days: 7))));
    result = result.replaceAll('{{next_month}}', _formatDate(DateTime(now.year, now.month + 1, now.day)));
    
    return result;
  }

  /// Formats a date for template replacement
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        shortDescription,
        type,
        categoryId,
        industryTags,
        difficultyLevel,
        estimatedHours,
        projectNameTemplate,
        projectDescriptionTemplate,
        defaultColor,
        projectCategoryId,
        deadlineOffsetDays,
        taskTemplates,
        variables,
        wizardSteps,
        taskDependencies,
        milestones,
        resourceTemplates,
        metadata,
        createdAt,
        updatedAt,
        createdBy,
        isSystemTemplate,
        isPublished,
        version,
        usageStats,
        rating,
        previewImages,
        tags,
        supportedLocales,
        isPremium,
        sizeEstimate,
      ];

  @override
  String toString() {
    return 'ProjectTemplate(id: $id, name: $name, type: $type, '
           'tasks: ${taskTemplates.length}, variables: ${variables.length}, '
           'complexity: $complexityScore, published: $isPublished)';
  }
}

/// Project milestone definition
@JsonSerializable()
class ProjectMilestone extends Equatable {
  /// Unique identifier for the milestone
  final String id;
  
  /// Name of the milestone
  final String name;
  
  /// Description of the milestone
  final String? description;
  
  /// Offset in days from project start
  final int dayOffset;
  
  /// Task IDs that must be completed for this milestone
  final List<String> requiredTaskIds;
  
  /// Icon name for the milestone
  final String? iconName;

  const ProjectMilestone({
    required this.id,
    required this.name,
    this.description,
    required this.dayOffset,
    this.requiredTaskIds = const [],
    this.iconName,
  });

  factory ProjectMilestone.fromJson(Map<String, dynamic> json) => 
      _$ProjectMilestoneFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectMilestoneToJson(this);

  @override
  List<Object?> get props => [id, name, description, dayOffset, requiredTaskIds, iconName];
}

/// Template usage statistics
@JsonSerializable()
class TemplateUsageStats extends Equatable {
  /// Number of times this template has been used
  final int usageCount;
  
  /// Number of times this template has been favorited
  final int favoriteCount;
  
  /// Number of successful project completions from this template
  final int successfulCompletions;
  
  /// Average project completion rate (0.0 to 1.0)
  final double averageCompletionRate;
  
  /// Last time this template was used
  final DateTime? lastUsed;
  
  /// Trending score (calculated based on recent usage)
  final double trendingScore;

  const TemplateUsageStats({
    this.usageCount = 0,
    this.favoriteCount = 0,
    this.successfulCompletions = 0,
    this.averageCompletionRate = 0.0,
    this.lastUsed,
    this.trendingScore = 0.0,
  });

  factory TemplateUsageStats.initial() {
    return const TemplateUsageStats();
  }

  factory TemplateUsageStats.fromJson(Map<String, dynamic> json) => 
      _$TemplateUsageStatsFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateUsageStatsToJson(this);

  TemplateUsageStats incrementUsage() {
    return TemplateUsageStats(
      usageCount: usageCount + 1,
      favoriteCount: favoriteCount,
      successfulCompletions: successfulCompletions,
      averageCompletionRate: averageCompletionRate,
      lastUsed: DateTime.now(),
      trendingScore: _calculateTrendingScore(usageCount + 1),
    );
  }

  TemplateUsageStats incrementFavorites() {
    return TemplateUsageStats(
      usageCount: usageCount,
      favoriteCount: favoriteCount + 1,
      successfulCompletions: successfulCompletions,
      averageCompletionRate: averageCompletionRate,
      lastUsed: lastUsed,
      trendingScore: trendingScore,
    );
  }

  double _calculateTrendingScore(int usage) {
    final now = DateTime.now();
    final daysSinceLastUse = lastUsed != null ? now.difference(lastUsed!).inDays : 30;
    
    // Trending score decreases over time and increases with usage
    return (usage * 10) / (1 + daysSinceLastUse);
  }

  @override
  List<Object?> get props => [
        usageCount,
        favoriteCount,
        successfulCompletions,
        averageCompletionRate,
        lastUsed,
        trendingScore,
      ];
}

/// Template rating and review information
@JsonSerializable()
class TemplateRating extends Equatable {
  /// Average rating (1.0 to 5.0)
  final double averageRating;
  
  /// Total number of reviews
  final int totalReviews;
  
  /// Rating distribution (1-star to 5-star counts)
  final Map<int, int> ratingDistribution;
  
  /// Featured review comments
  final List<String> featuredReviews;

  const TemplateRating({
    required this.averageRating,
    required this.totalReviews,
    this.ratingDistribution = const {},
    this.featuredReviews = const [],
  });

  factory TemplateRating.initial() {
    return const TemplateRating(
      averageRating: 0.0,
      totalReviews: 0,
    );
  }

  factory TemplateRating.fromJson(Map<String, dynamic> json) => 
      _$TemplateRatingFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateRatingToJson(this);

  TemplateRating update(double newRating, int newReviewCount) {
    return TemplateRating(
      averageRating: newRating,
      totalReviews: newReviewCount,
      ratingDistribution: ratingDistribution,
      featuredReviews: featuredReviews,
    );
  }

  @override
  List<Object?> get props => [averageRating, totalReviews, ratingDistribution, featuredReviews];
}

/// Template size estimate for performance optimization
@JsonSerializable()
class TemplateSizeEstimate extends Equatable {
  /// Number of tasks in the template
  final int taskCount;
  
  /// Estimated memory usage in KB
  final int estimatedMemoryKb;
  
  /// Complexity category (small, medium, large, xlarge)
  final String complexityCategory;
  
  /// Whether this template might cause performance issues
  final bool isLargeTemplate;

  const TemplateSizeEstimate({
    required this.taskCount,
    required this.estimatedMemoryKb,
    required this.complexityCategory,
    required this.isLargeTemplate,
  });

  factory TemplateSizeEstimate.calculate(List<TaskTemplate> tasks) {
    final taskCount = tasks.length;
    final estimatedMemoryKb = (taskCount * 2) + 10; // Rough estimate
    
    String category;
    bool isLarge;
    
    if (taskCount <= 10) {
      category = 'small';
      isLarge = false;
    } else if (taskCount <= 50) {
      category = 'medium';
      isLarge = false;
    } else if (taskCount <= 100) {
      category = 'large';
      isLarge = true;
    } else {
      category = 'xlarge';
      isLarge = true;
    }
    
    return TemplateSizeEstimate(
      taskCount: taskCount,
      estimatedMemoryKb: estimatedMemoryKb,
      complexityCategory: category,
      isLargeTemplate: isLarge,
    );
  }

  factory TemplateSizeEstimate.fromJson(Map<String, dynamic> json) => 
      _$TemplateSizeEstimateFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateSizeEstimateToJson(this);

  @override
  List<Object?> get props => [taskCount, estimatedMemoryKb, complexityCategory, isLargeTemplate];
}