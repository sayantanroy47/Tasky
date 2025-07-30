import 'dart:convert';

import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';
import '../../../domain/entities/task_model.dart';
import '../../../domain/entities/task_enums.dart';
import '../../../domain/entities/subtask.dart' as domain;
import '../../../domain/entities/recurrence_pattern.dart';

part 'task_dao.g.dart';

/// Data Access Object for Task operations
/// 
/// Provides CRUD operations and queries for tasks in the database.
@DriftAccessor(tables: [Tasks, SubTasks, TaskTags, TaskDependencies])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(AppDatabase db) : super(db);

  /// Gets all tasks from the database
  Future<List<TaskModel>> getAllTasks() async {
    final taskRows = await select(tasks).get();
    final taskModels = <TaskModel>[];

    for (final taskRow in taskRows) {
      final taskModel = await _taskRowToModel(taskRow);
      taskModels.add(taskModel);
    }

    return taskModels;
  }

  /// Gets a task by its ID
  Future<TaskModel?> getTaskById(String id) async {
    final taskRow = await (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (taskRow == null) return null;

    return await _taskRowToModel(taskRow);
  }

  /// Creates a new task in the database
  Future<void> createTask(TaskModel task) async {
    await db.transaction(() async {
      // Insert the main task
      await into(tasks).insert(_taskModelToRow(task));

      // Insert subtasks
      for (final subTask in task.subTasks) {
        await into(subTasks).insert(_subTaskToRow(subTask));
      }

      // Insert task-tag relationships
      for (final tag in task.tags) {
        await into(taskTags).insert(TaskTagsCompanion.insert(
          taskId: task.id,
          tagId: tag,
        ));
      }

      // Insert task dependencies
      for (final dependencyId in task.dependencies) {
        await into(taskDependencies).insert(TaskDependenciesCompanion.insert(
          dependentTaskId: task.id,
          prerequisiteTaskId: dependencyId,
        ));
      }
    });
  }

  /// Updates an existing task in the database
  Future<void> updateTask(TaskModel task) async {
    await db.transaction(() async {
      // Update the main task
      await (update(tasks)..where((t) => t.id.equals(task.id)))
          .write(_taskModelToRow(task));

      // Delete and recreate subtasks (simpler than complex update logic)
      await (delete(subTasks)..where((st) => st.taskId.equals(task.id))).go();
      for (final subTask in task.subTasks) {
        await into(subTasks).insert(_subTaskToRow(subTask));
      }

      // Delete and recreate task-tag relationships
      await (delete(taskTags)..where((tt) => tt.taskId.equals(task.id))).go();
      for (final tag in task.tags) {
        await into(taskTags).insert(TaskTagsCompanion.insert(
          taskId: task.id,
          tagId: tag,
        ));
      }

      // Delete and recreate task dependencies
      await (delete(taskDependencies)..where((td) => td.dependentTaskId.equals(task.id))).go();
      for (final dependencyId in task.dependencies) {
        await into(taskDependencies).insert(TaskDependenciesCompanion.insert(
          dependentTaskId: task.id,
          prerequisiteTaskId: dependencyId,
        ));
      }
    });
  }

  /// Deletes a task from the database
  Future<void> deleteTask(String id) async {
    await (delete(tasks)..where((t) => t.id.equals(id))).go();
    // Subtasks, tags, and dependencies will be deleted automatically due to CASCADE
  }

  /// Gets tasks by status
  Future<List<TaskModel>> getTasksByStatus(TaskStatus status) async {
    final statusValue = _taskStatusToInt(status);
    final taskRows = await (select(tasks)..where((t) => t.status.equals(statusValue))).get();
    
    final taskModels = <TaskModel>[];
    for (final taskRow in taskRows) {
      final taskModel = await _taskRowToModel(taskRow);
      taskModels.add(taskModel);
    }

    return taskModels;
  }

  /// Gets tasks by priority
  Future<List<TaskModel>> getTasksByPriority(TaskPriority priority) async {
    final priorityValue = _taskPriorityToInt(priority);
    final taskRows = await (select(tasks)..where((t) => t.priority.equals(priorityValue))).get();
    
    final taskModels = <TaskModel>[];
    for (final taskRow in taskRows) {
      final taskModel = await _taskRowToModel(taskRow);
      taskModels.add(taskModel);
    }

    return taskModels;
  }

  /// Gets tasks due today
  Future<List<TaskModel>> getTasksDueToday() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final taskRows = await (select(tasks)
      ..where((t) => t.dueDate.isBetweenValues(startOfDay, endOfDay))
    ).get();
    
    final taskModels = <TaskModel>[];
    for (final taskRow in taskRows) {
      final taskModel = await _taskRowToModel(taskRow);
      taskModels.add(taskModel);
    }

    return taskModels;
  }

  /// Gets overdue tasks
  Future<List<TaskModel>> getOverdueTasks() async {
    final now = DateTime.now();
    final taskRows = await (select(tasks)
      ..where((t) => t.dueDate.isSmallerThanValue(now) & t.status.isNotValue(_taskStatusToInt(TaskStatus.completed)))
    ).get();
    
    final taskModels = <TaskModel>[];
    for (final taskRow in taskRows) {
      final taskModel = await _taskRowToModel(taskRow);
      taskModels.add(taskModel);
    }

    return taskModels;
  }

  /// Gets tasks by project ID
  Future<List<TaskModel>> getTasksByProject(String projectId) async {
    final taskRows = await (select(tasks)..where((t) => t.projectId.equals(projectId))).get();
    
    final taskModels = <TaskModel>[];
    for (final taskRow in taskRows) {
      final taskModel = await _taskRowToModel(taskRow);
      taskModels.add(taskModel);
    }

    return taskModels;
  }

  /// Searches tasks by title or description
  Future<List<TaskModel>> searchTasks(String query) async {
    final taskRows = await (select(tasks)
      ..where((t) => t.title.contains(query) | t.description.contains(query))
    ).get();
    
    final taskModels = <TaskModel>[];
    for (final taskRow in taskRows) {
      final taskModel = await _taskRowToModel(taskRow);
      taskModels.add(taskModel);
    }

    return taskModels;
  }

  /// Watches all tasks (returns a stream)
  Stream<List<TaskModel>> watchAllTasks() {
    return select(tasks).watch().asyncMap((taskRows) async {
      final taskModels = <TaskModel>[];
      for (final taskRow in taskRows) {
        final taskModel = await _taskRowToModel(taskRow);
        taskModels.add(taskModel);
      }
      return taskModels;
    });
  }

  /// Watches tasks by status (returns a stream)
  Stream<List<TaskModel>> watchTasksByStatus(TaskStatus status) {
    final statusValue = _taskStatusToInt(status);
    return (select(tasks)..where((t) => t.status.equals(statusValue))).watch().asyncMap((taskRows) async {
      final taskModels = <TaskModel>[];
      for (final taskRow in taskRows) {
        final taskModel = await _taskRowToModel(taskRow);
        taskModels.add(taskModel);
      }
      return taskModels;
    });
  }

  /// Converts a task database row to a TaskModel
  Future<TaskModel> _taskRowToModel(Task taskRow) async {
    // Get subtasks
    final subTaskRows = await (select(subTasks)..where((st) => st.taskId.equals(taskRow.id))).get();
    final subTaskModels = subTaskRows.map(_subTaskRowToModel).toList().cast<domain.SubTask>();

    // Get tags
    final tagRows = await (select(taskTags).join([
      innerJoin(tags, tags.id.equalsExp(taskTags.tagId))
    ])..where(taskTags.taskId.equals(taskRow.id))).get();
    final tagIds = tagRows.map((row) => row.readTable(tags).id).toList();

    // Get dependencies
    final dependencyRows = await (select(taskDependencies)
      ..where((td) => td.dependentTaskId.equals(taskRow.id))
    ).get();
    final dependencyIds = dependencyRows.map((row) => row.prerequisiteTaskId).toList();

    // Parse metadata
    final metadata = taskRow.metadata.isNotEmpty 
        ? Map<String, dynamic>.from(jsonDecode(taskRow.metadata))
        : <String, dynamic>{};

    // Parse recurrence pattern
    RecurrencePattern? recurrence;
    if (taskRow.recurrenceType != null) {
      final daysOfWeek = taskRow.recurrenceDaysOfWeek != null
          ? List<int>.from(jsonDecode(taskRow.recurrenceDaysOfWeek!))
          : null;

      recurrence = RecurrencePattern(
        type: _intToRecurrenceType(taskRow.recurrenceType!),
        interval: taskRow.recurrenceInterval ?? 1,
        daysOfWeek: daysOfWeek,
        endDate: taskRow.recurrenceEndDate,
        maxOccurrences: taskRow.recurrenceMaxOccurrences,
      );
    }

    return TaskModel(
      id: taskRow.id,
      title: taskRow.title,
      description: taskRow.description,
      createdAt: taskRow.createdAt,
      updatedAt: taskRow.updatedAt,
      dueDate: taskRow.dueDate,
      completedAt: taskRow.completedAt,
      priority: _intToTaskPriority(taskRow.priority),
      status: _intToTaskStatus(taskRow.status),
      tags: tagIds,
      subTasks: subTaskModels,
      locationTrigger: taskRow.locationTrigger,
      recurrence: recurrence,
      projectId: taskRow.projectId,
      dependencies: dependencyIds,
      metadata: metadata,
      isPinned: taskRow.isPinned,
      estimatedDuration: taskRow.estimatedDuration,
      actualDuration: taskRow.actualDuration,
    );
  }

  /// Converts a TaskModel to a database row
  TasksCompanion _taskModelToRow(TaskModel task) {
    final metadataJson = task.metadata.isNotEmpty ? jsonEncode(task.metadata) : '{}';
    
    int? recurrenceType;
    int? recurrenceInterval;
    String? recurrenceDaysOfWeek;
    DateTime? recurrenceEndDate;
    int? recurrenceMaxOccurrences;

    if (task.recurrence != null) {
      recurrenceType = _recurrenceTypeToInt(task.recurrence!.type);
      recurrenceInterval = task.recurrence!.interval;
      recurrenceDaysOfWeek = task.recurrence!.daysOfWeek != null
          ? jsonEncode(task.recurrence!.daysOfWeek)
          : null;
      recurrenceEndDate = task.recurrence!.endDate;
      recurrenceMaxOccurrences = task.recurrence!.maxOccurrences;
    }

    return TasksCompanion.insert(
      id: task.id,
      title: task.title,
      description: Value(task.description),
      createdAt: task.createdAt,
      updatedAt: Value(task.updatedAt),
      dueDate: Value(task.dueDate),
      completedAt: Value(task.completedAt),
      priority: _taskPriorityToInt(task.priority),
      status: _taskStatusToInt(task.status),
      locationTrigger: Value(task.locationTrigger),
      projectId: Value(task.projectId),
      metadata: metadataJson,
      isPinned: Value(task.isPinned),
      estimatedDuration: Value(task.estimatedDuration),
      actualDuration: Value(task.actualDuration),
      recurrenceType: Value(recurrenceType),
      recurrenceInterval: Value(recurrenceInterval),
      recurrenceDaysOfWeek: Value(recurrenceDaysOfWeek),
      recurrenceEndDate: Value(recurrenceEndDate),
      recurrenceMaxOccurrences: Value(recurrenceMaxOccurrences),
    );
  }

  /// Converts a SubTask to a database row
  SubTasksCompanion _subTaskToRow(domain.SubTask subTask) {
    return SubTasksCompanion.insert(
      id: subTask.id,
      taskId: subTask.taskId,
      title: subTask.title,
      isCompleted: Value(subTask.isCompleted),
      completedAt: Value(subTask.completedAt),
      sortOrder: Value(subTask.sortOrder),
      createdAt: subTask.createdAt,
    );
  }

  /// Converts a subtask database row to a SubTask model
  domain.SubTask _subTaskRowToModel(SubTask subTaskRow) {
    return domain.SubTask(
      id: subTaskRow.id,
      taskId: subTaskRow.taskId,
      title: subTaskRow.title,
      isCompleted: subTaskRow.isCompleted,
      completedAt: subTaskRow.completedAt,
      sortOrder: subTaskRow.sortOrder,
      createdAt: subTaskRow.createdAt,
    );
  }

  // Helper methods for enum conversions
  int _taskStatusToInt(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 0;
      case TaskStatus.inProgress:
        return 1;
      case TaskStatus.completed:
        return 2;
      case TaskStatus.cancelled:
        return 3;
    }
  }

  TaskStatus _intToTaskStatus(int value) {
    switch (value) {
      case 0:
        return TaskStatus.pending;
      case 1:
        return TaskStatus.inProgress;
      case 2:
        return TaskStatus.completed;
      case 3:
        return TaskStatus.cancelled;
      default:
        return TaskStatus.pending;
    }
  }

  int _taskPriorityToInt(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 0;
      case TaskPriority.medium:
        return 1;
      case TaskPriority.high:
        return 2;
      case TaskPriority.urgent:
        return 3;
    }
  }

  TaskPriority _intToTaskPriority(int value) {
    switch (value) {
      case 0:
        return TaskPriority.low;
      case 1:
        return TaskPriority.medium;
      case 2:
        return TaskPriority.high;
      case 3:
        return TaskPriority.urgent;
      default:
        return TaskPriority.medium;
    }
  }

  int _recurrenceTypeToInt(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.none:
        return 0;
      case RecurrenceType.daily:
        return 1;
      case RecurrenceType.weekly:
        return 2;
      case RecurrenceType.monthly:
        return 3;
      case RecurrenceType.yearly:
        return 4;
      case RecurrenceType.custom:
        return 5;
    }
  }

  RecurrenceType _intToRecurrenceType(int value) {
    switch (value) {
      case 0:
        return RecurrenceType.none;
      case 1:
        return RecurrenceType.daily;
      case 2:
        return RecurrenceType.weekly;
      case 3:
        return RecurrenceType.monthly;
      case 4:
        return RecurrenceType.yearly;
      case 5:
        return RecurrenceType.custom;
      default:
        return RecurrenceType.none;
    }
  }
}