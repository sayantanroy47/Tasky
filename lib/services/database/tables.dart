import 'package:drift/drift.dart';

/// Tasks table definition
/// 
/// Stores the main task data including title, description, dates, priority, etc.
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get priority => integer()(); // 0=low, 1=medium, 2=high, 3=urgent
  IntColumn get status => integer()(); // 0=pending, 1=inProgress, 2=completed, 3=cancelled
  TextColumn get locationTrigger => text().nullable()();
  TextColumn get projectId => text().nullable()();
  TextColumn get metadata => text()(); // JSON blob
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  IntColumn get estimatedDuration => integer().nullable()(); // in minutes
  IntColumn get actualDuration => integer().nullable()(); // in minutes
  
  // Recurrence pattern fields
  IntColumn get recurrenceType => integer().nullable()(); // 0=none, 1=daily, 2=weekly, etc.
  IntColumn get recurrenceInterval => integer().nullable()();
  TextColumn get recurrenceDaysOfWeek => text().nullable()(); // JSON array of integers
  DateTimeColumn get recurrenceEndDate => dateTime().nullable()();
  IntColumn get recurrenceMaxOccurrences => integer().nullable()();  @override
  Set<Column> get primaryKey => {id};  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE SET NULL',
  ];
}

/// SubTasks table definition
/// 
/// Stores subtasks/checklist items that belong to a main task
class SubTasks extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text()();
  TextColumn get title => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();  @override
  Set<Column> get primaryKey => {id};  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE',
  ];
}

/// Tags table definition
/// 
/// Stores reusable tags that can be applied to tasks
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  TextColumn get color => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();  @override
  Set<Column> get primaryKey => {id};
}

/// TaskTags table definition
/// 
/// Junction table for many-to-many relationship between tasks and tags
class TaskTags extends Table {
  TextColumn get taskId => text()();
  TextColumn get tagId => text()();  @override
  Set<Column> get primaryKey => {taskId, tagId};  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE',
    'FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE',
  ];
}

/// Projects table definition
/// 
/// Stores project information for organizing tasks
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get color => text()();
  TextColumn get categoryId => text().nullable()(); // Reference to ProjectCategories
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deadline => dateTime().nullable()();  @override
  Set<Column> get primaryKey => {id};
}

/// ProjectCategories table definition
/// 
/// Stores both system-defined and user-defined project categories
/// with Phosphor icons and design system colors
class ProjectCategories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get iconName => text()(); // Phosphor icon name as string
  TextColumn get color => text()(); // Hex color code from design system
  TextColumn get parentId => text().nullable()(); // For hierarchical categories
  BoolColumn get isSystemDefined => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get metadata => text().withDefault(const Constant('{}'))(); // JSON blob for extensibility

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (parent_id) REFERENCES project_categories (id) ON DELETE SET NULL',
    'UNIQUE (name) WHERE is_active = 1', // Unique active category names
  ];
}

/// TaskDependencies table definition
/// 
/// Stores task dependency relationships (which tasks depend on which other tasks)
class TaskDependencies extends Table {
  TextColumn get dependentTaskId => text()();
  TextColumn get prerequisiteTaskId => text()();  @override
  Set<Column> get primaryKey => {dependentTaskId, prerequisiteTaskId};  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (dependent_task_id) REFERENCES tasks (id) ON DELETE CASCADE',
    'FOREIGN KEY (prerequisite_task_id) REFERENCES tasks (id) ON DELETE CASCADE',
  ];
}

/// TaskTemplates table definition
/// 
/// Stores task templates for quick task creation
class TaskTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get titleTemplate => text()();
  TextColumn get descriptionTemplate => text().nullable()();
  IntColumn get priority => integer()(); // 0=low, 1=medium, 2=high, 3=urgent
  TextColumn get tags => text()(); // JSON array of strings
  TextColumn get subTaskTemplates => text()(); // JSON array of subtask objects
  TextColumn get locationTrigger => text().nullable()();
  TextColumn get projectId => text().nullable()();
  IntColumn get estimatedDuration => integer().nullable()(); // in minutes
  TextColumn get metadata => text()(); // JSON blob
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get category => text().nullable()();
  
  // Recurrence pattern fields
  IntColumn get recurrenceType => integer().nullable()(); // 0=none, 1=daily, 2=weekly, etc.
  IntColumn get recurrenceInterval => integer().nullable()();
  TextColumn get recurrenceDaysOfWeek => text().nullable()(); // JSON array of integers
  DateTimeColumn get recurrenceEndDate => dateTime().nullable()();
  IntColumn get recurrenceMaxOccurrences => integer().nullable()();  @override
  Set<Column> get primaryKey => {id};  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE SET NULL',
  ];
}

/// UserProfiles table definition
/// 
/// Stores user profile information including name, profile picture, and location
class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text().nullable()();
  TextColumn get profilePicturePath => text().nullable()(); // Local file path to profile picture
  TextColumn get location => text().nullable()(); // User-entered location
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// ProjectTemplates table definition
/// 
/// Stores comprehensive project templates for wizard-based project creation
class ProjectTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get shortDescription => text().nullable()();
  IntColumn get type => integer()(); // 0=simple, 1=wizard, 2=advanced
  TextColumn get categoryId => text().nullable()();
  TextColumn get industryTags => text()(); // JSON array
  IntColumn get difficultyLevel => integer().withDefault(const Constant(1))();
  IntColumn get estimatedHours => integer().nullable()();
  TextColumn get projectNameTemplate => text()();
  TextColumn get projectDescriptionTemplate => text().nullable()();
  TextColumn get defaultColor => text().withDefault(const Constant('#2196F3'))();
  TextColumn get projectCategoryId => text().nullable()();
  IntColumn get deadlineOffsetDays => integer().nullable()();
  TextColumn get taskTemplates => text()(); // JSON array of task template IDs
  TextColumn get variables => text()(); // JSON array of template variables
  TextColumn get wizardSteps => text()(); // JSON array of wizard steps
  TextColumn get taskDependencies => text()(); // JSON map of dependencies
  TextColumn get milestones => text()(); // JSON array of milestones
  TextColumn get resourceTemplates => text()(); // JSON map of resource templates
  TextColumn get metadata => text()(); // JSON blob
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get createdBy => text().nullable()();
  BoolColumn get isSystemTemplate => boolean().withDefault(const Constant(false))();
  BoolColumn get isPublished => boolean().withDefault(const Constant(false))();
  TextColumn get version => text().withDefault(const Constant('1.0.0'))();
  TextColumn get usageStats => text()(); // JSON blob for usage statistics
  TextColumn get rating => text().nullable()(); // JSON blob for rating info
  TextColumn get previewImages => text()(); // JSON array of image URLs
  TextColumn get tags => text()(); // JSON array of tag strings
  TextColumn get supportedLocales => text()(); // JSON array of locale strings
  BoolColumn get isPremium => boolean().withDefault(const Constant(false))();
  TextColumn get sizeEstimate => text()(); // JSON blob for size estimate

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (category_id) REFERENCES project_categories (id) ON DELETE SET NULL',
    'FOREIGN KEY (project_category_id) REFERENCES project_categories (id) ON DELETE SET NULL',
  ];
}

/// ProjectTemplateVariables table definition
/// 
/// Stores template variables for dynamic project creation
class ProjectTemplateVariables extends Table {
  TextColumn get id => text()();
  TextColumn get templateId => text()();
  TextColumn get variableKey => text()();
  TextColumn get displayName => text()();
  IntColumn get type => integer()(); // Variable type enum
  TextColumn get description => text().nullable()();
  BoolColumn get isRequired => boolean().withDefault(const Constant(false))();
  TextColumn get defaultValue => text().nullable()(); // JSON serialized value
  TextColumn get options => text()(); // JSON array for choice types
  TextColumn get validationPattern => text().nullable()();
  TextColumn get validationError => text().nullable()();
  TextColumn get minValue => text().nullable()(); // JSON serialized value
  TextColumn get maxValue => text().nullable()(); // JSON serialized value
  BoolColumn get isConditional => boolean().withDefault(const Constant(false))();
  TextColumn get dependentVariables => text()(); // JSON array
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (template_id) REFERENCES project_templates (id) ON DELETE CASCADE',
    'UNIQUE (template_id, variable_key)',
  ];
}

/// ProjectTemplateWizardSteps table definition
/// 
/// Stores wizard steps for guided project template creation
class ProjectTemplateWizardSteps extends Table {
  TextColumn get id => text()();
  TextColumn get templateId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get variableKeys => text()(); // JSON array
  TextColumn get showCondition => text().nullable()();
  IntColumn get stepOrder => integer()();
  BoolColumn get isOptional => boolean().withDefault(const Constant(false))();
  TextColumn get iconName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (template_id) REFERENCES project_templates (id) ON DELETE CASCADE',
    'UNIQUE (template_id, step_order)',
  ];
}

/// ProjectTemplateMilestones table definition
/// 
/// Stores milestone definitions for project templates
class ProjectTemplateMilestones extends Table {
  TextColumn get id => text()();
  TextColumn get templateId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get dayOffset => integer()();
  TextColumn get requiredTaskIds => text()(); // JSON array
  TextColumn get iconName => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (template_id) REFERENCES project_templates (id) ON DELETE CASCADE',
  ];
}

/// ProjectTemplateTaskTemplates table definition
/// 
/// Junction table linking project templates to their task templates
class ProjectTemplateTaskTemplates extends Table {
  TextColumn get projectTemplateId => text()();
  TextColumn get taskTemplateId => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get taskDependencies => text()(); // JSON array of dependent task template IDs

  @override
  Set<Column> get primaryKey => {projectTemplateId, taskTemplateId};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (project_template_id) REFERENCES project_templates (id) ON DELETE CASCADE',
    'FOREIGN KEY (task_template_id) REFERENCES task_templates (id) ON DELETE CASCADE',
  ];
}
