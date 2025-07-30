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
  IntColumn get recurrenceMaxOccurrences => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
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
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
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
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// TaskTags table definition
/// 
/// Junction table for many-to-many relationship between tasks and tags
class TaskTags extends Table {
  TextColumn get taskId => text()();
  TextColumn get tagId => text()();

  @override
  Set<Column> get primaryKey => {taskId, tagId};

  @override
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
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deadline => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// TaskDependencies table definition
/// 
/// Stores task dependency relationships (which tasks depend on which other tasks)
class TaskDependencies extends Table {
  TextColumn get dependentTaskId => text()();
  TextColumn get prerequisiteTaskId => text()();

  @override
  Set<Column> get primaryKey => {dependentTaskId, prerequisiteTaskId};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (dependent_task_id) REFERENCES tasks (id) ON DELETE CASCADE',
    'FOREIGN KEY (prerequisite_task_id) REFERENCES tasks (id) ON DELETE CASCADE',
  ];
}