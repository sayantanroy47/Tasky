import 'dart:convert';

import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';
import '../../../domain/entities/task_model.dart';
import '../../../domain/entities/task_enums.dart';
import '../../../domain/entities/subtask.dart' as domain;
import '../../../domain/entities/recurrence_pattern.dart';
import '../../../domain/models/enums.dart';

part 'task_dao.g.dart';

/// Data Access Object for Task operations
/// 
/// Provides CRUD operations and queries for tasks in the database.
@DriftAccessor(tables: [Tasks, SubTasks, TaskTags, TaskDependencies])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

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
    await db.transaction(() async {
      // Delete the task and related data
      await (delete(tasks)..where((t) => t.id.equals(id))).go();
      // Subtasks, tags, and dependencies will be deleted automatically due to CASCADE
    });
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

  /// Gets tasks within a date range
  Future<List<TaskModel>> getTasksByDateRange(DateTime startDate, DateTime endDate) async {
    final taskRows = await (select(tasks)
      ..where((t) => t.dueDate.isBiggerOrEqualValue(startDate) & t.dueDate.isSmallerOrEqualValue(endDate))
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

  /// Searches tasks by title, description, or tags
  Future<List<TaskModel>> searchTasks(String query) async {
    // Search in title and description
    final titleDescriptionTasks = await (select(tasks)
      ..where((t) => t.title.contains(query) | t.description.contains(query))
    ).get();
    
    // Search in tags
    final tagTasks = await (select(tasks).join([
      innerJoin(taskTags, taskTags.taskId.equalsExp(tasks.id)),
      innerJoin(tags, tags.id.equalsExp(taskTags.tagId))
    ])..where(tags.name.contains(query))).get();
    
    // Combine results and remove duplicates
    final allTaskRows = <Task>[];
    final seenIds = <String>{};
    
    for (final taskRow in titleDescriptionTasks) {
      if (!seenIds.contains(taskRow.id)) {
        allTaskRows.add(taskRow);
        seenIds.add(taskRow.id);
      }
    }
    
    for (final row in tagTasks) {
      final taskRow = row.readTable(tasks);
      if (!seenIds.contains(taskRow.id)) {
        allTaskRows.add(taskRow);
        seenIds.add(taskRow.id);
      }
    }
    
    final taskModels = <TaskModel>[];
    for (final taskRow in allTaskRows) {
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

  /// Bulk delete tasks by IDs
  Future<void> deleteTasks(List<String> taskIds) async {
    if (taskIds.isEmpty) return;
    
    await db.transaction(() async {
      for (final id in taskIds) {
        await (delete(tasks)..where((t) => t.id.equals(id))).go();
      }
    });
  }
  
  /// Bulk update task status
  Future<void> updateTasksStatus(List<String> taskIds, TaskStatus status) async {
    if (taskIds.isEmpty) return;
    
    final statusValue = _taskStatusToInt(status);
    final now = DateTime.now();
    
    await db.transaction(() async {
      for (final id in taskIds) {
        final updates = TasksCompanion(
          status: Value(statusValue),
          updatedAt: Value(now),
        );
        
        // If marking as completed, set completedAt
        if (status == TaskStatus.completed) {
          await (update(tasks)..where((t) => t.id.equals(id)))
              .write(updates.copyWith(completedAt: Value(now)));
        } else {
          await (update(tasks)..where((t) => t.id.equals(id)))
              .write(updates);
        }
      }
    });
  }
  
  /// Bulk update task priority
  Future<void> updateTasksPriority(List<String> taskIds, TaskPriority priority) async {
    if (taskIds.isEmpty) return;
    
    final priorityValue = _taskPriorityToInt(priority);
    final now = DateTime.now();
    
    await db.transaction(() async {
      for (final id in taskIds) {
        await (update(tasks)..where((t) => t.id.equals(id)))
            .write(TasksCompanion(
              priority: Value(priorityValue),
              updatedAt: Value(now),
            ));
      }
    });
  }
  
  /// Bulk assign tasks to a project
  Future<void> assignTasksToProject(List<String> taskIds, String? projectId) async {
    if (taskIds.isEmpty) return;
    
    final now = DateTime.now();
    
    await db.transaction(() async {
      for (final id in taskIds) {
        await (update(tasks)..where((t) => t.id.equals(id)))
            .write(TasksCompanion(
              projectId: Value(projectId),
              updatedAt: Value(now),
            ));
      }
    });
  }

  /// Optimized method to get tasks by multiple IDs
  Future<List<TaskModel>> getTasksByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    
    final taskRows = await (select(tasks)..where((t) => t.id.isIn(ids))).get();
    final taskModels = <TaskModel>[];

    for (final taskRow in taskRows) {
      final taskModel = await _taskRowToModel(taskRow);
      taskModels.add(taskModel);
    }

    return taskModels;
  }

  /// Optimized method to get tasks with a specific dependency
  Future<List<TaskModel>> getTasksWithDependency(String dependencyId) async {
    // Use JOIN to efficiently find tasks with the specific dependency
    final taskRows = await (select(tasks).join([
      innerJoin(taskDependencies, taskDependencies.dependentTaskId.equalsExp(tasks.id))
    ])..where(taskDependencies.prerequisiteTaskId.equals(dependencyId))).get();
    
    final taskModels = <TaskModel>[];
    for (final row in taskRows) {
      final taskRow = row.readTable(tasks);
      final taskModel = await _taskRowToModel(taskRow);
      taskModels.add(taskModel);
    }

    return taskModels;
  }

  /// Optimized database-level filtering with proper query building
  Future<List<TaskModel>> getTasksWithFilter(TaskFilter filter) async {
    var query = select(tasks);

    // Apply database-level filters
    if (filter.status != null) {
      query = query..where((t) => t.status.equals(_taskStatusToInt(filter.status!)));
    }

    if (filter.priority != null) {
      query = query..where((t) => t.priority.equals(_taskPriorityToInt(filter.priority!)));
    }

    if (filter.projectId != null) {
      query = query..where((t) => t.projectId.equals(filter.projectId!));
    }

    if (filter.dueDateFrom != null) {
      query = query..where((t) => t.dueDate.isBiggerOrEqualValue(filter.dueDateFrom!));
    }

    if (filter.dueDateTo != null) {
      query = query..where((t) => t.dueDate.isSmallerOrEqualValue(filter.dueDateTo!));
    }

    if (filter.isOverdue == true) {
      final now = DateTime.now();
      query = query..where((t) => 
        t.dueDate.isSmallerThanValue(now) & 
        t.status.isNotValue(_taskStatusToInt(TaskStatus.completed))
      );
    } else if (filter.isOverdue == false) {
      final now = DateTime.now();
      query = query..where((t) => 
        t.dueDate.isBiggerOrEqualValue(now) |
        t.dueDate.isNull() |
        t.status.equals(_taskStatusToInt(TaskStatus.completed))
      );
    }

    if (filter.isPinned != null) {
      query = query..where((t) => t.isPinned.equals(filter.isPinned!));
    }

    // Apply database-level search if provided
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      query = query..where((t) => 
        t.title.contains(filter.searchQuery!) |
        t.description.contains(filter.searchQuery!)
      );
    }

    // Apply sorting at database level
    switch (filter.sortBy) {
      case TaskSortBy.createdAt:
        query = filter.sortAscending 
          ? (query..orderBy([((t) => OrderingTerm.asc(t.createdAt))]))
          : (query..orderBy([((t) => OrderingTerm.desc(t.createdAt))]));
        break;
      case TaskSortBy.updatedAt:
        query = filter.sortAscending 
          ? (query..orderBy([((t) => OrderingTerm.asc(t.updatedAt))]))
          : (query..orderBy([((t) => OrderingTerm.desc(t.updatedAt))]));
        break;
      case TaskSortBy.dueDate:
        query = filter.sortAscending 
          ? (query..orderBy([((t) => OrderingTerm.asc(t.dueDate))]))
          : (query..orderBy([((t) => OrderingTerm.desc(t.dueDate))]));
        break;
      case TaskSortBy.priority:
        query = filter.sortAscending 
          ? (query..orderBy([((t) => OrderingTerm.asc(t.priority))]))
          : (query..orderBy([((t) => OrderingTerm.desc(t.priority))]));
        break;
      case TaskSortBy.title:
        query = filter.sortAscending 
          ? (query..orderBy([((t) => OrderingTerm.asc(t.title))]))
          : (query..orderBy([((t) => OrderingTerm.desc(t.title))]));
        break;
      case TaskSortBy.status:
        query = filter.sortAscending 
          ? (query..orderBy([((t) => OrderingTerm.asc(t.status))]))
          : (query..orderBy([((t) => OrderingTerm.desc(t.status))]));
        break;
    }

    final taskRows = await query.get();
    final taskModels = <TaskModel>[];

    for (final taskRow in taskRows) {
      final taskModel = await _taskRowToModel(taskRow);
      taskModels.add(taskModel);
    }

    // Apply tag filtering in memory only if needed (since it requires JOIN logic)
    var filteredTasks = taskModels;
    if (filter.tags != null && filter.tags!.isNotEmpty) {
      filteredTasks = taskModels.where((task) {
        return filter.tags!.any((tagId) => task.tags.contains(tagId));
      }).toList();
    }

    return filteredTasks;
  }

  /// Database-level pagination for better performance
  Future<List<TaskModel>> getTasksWithFilterAndPagination(
    TaskFilter filter, {
    int page = 0,
    int pageSize = 20,
  }) async {
    var query = select(tasks);

    // Apply the same filters as getTasksWithFilter
    if (filter.status != null) {
      query = query..where((t) => t.status.equals(_taskStatusToInt(filter.status!)));
    }

    if (filter.priority != null) {
      query = query..where((t) => t.priority.equals(_taskPriorityToInt(filter.priority!)));
    }

    if (filter.projectId != null) {
      query = query..where((t) => t.projectId.equals(filter.projectId!));
    }

    if (filter.dueDateFrom != null) {
      query = query..where((t) => t.dueDate.isBiggerOrEqualValue(filter.dueDateFrom!));
    }

    if (filter.dueDateTo != null) {
      query = query..where((t) => t.dueDate.isSmallerOrEqualValue(filter.dueDateTo!));
    }

    if (filter.isOverdue == true) {
      final now = DateTime.now();
      query = query..where((t) => 
        t.dueDate.isSmallerThanValue(now) & 
        t.status.isNotValue(_taskStatusToInt(TaskStatus.completed))
      );
    } else if (filter.isOverdue == false) {
      final now = DateTime.now();
      query = query..where((t) => 
        t.dueDate.isBiggerOrEqualValue(now) |
        t.dueDate.isNull() |
        t.status.equals(_taskStatusToInt(TaskStatus.completed))
      );
    }

    if (filter.isPinned != null) {
      query = query..where((t) => t.isPinned.equals(filter.isPinned!));
    }

    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      query = query..where((t) => 
        t.title.contains(filter.searchQuery!) |
        t.description.contains(filter.searchQuery!)
      );
    }

    // Apply sorting at database level
    switch (filter.sortBy) {
      case TaskSortBy.createdAt:
        query = filter.sortAscending 
          ? (query..orderBy([((t) => OrderingTerm.asc(t.createdAt))]))
          : (query..orderBy([((t) => OrderingTerm.desc(t.createdAt))]));
        break;
      case TaskSortBy.updatedAt:
        query = filter.sortAscending 
          ? (query..orderBy([((t) => OrderingTerm.asc(t.updatedAt))]))
          : (query..orderBy([((t) => OrderingTerm.desc(t.updatedAt))]));
        break;
      case TaskSortBy.dueDate:
        query = filter.sortAscending 
          ? (query..orderBy([((t) => OrderingTerm.asc(t.dueDate))]))
          : (query..orderBy([((t) => OrderingTerm.desc(t.dueDate))]));
        break;
      case TaskSortBy.priority:
        query = filter.sortAscending 
          ? (query..orderBy([((t) => OrderingTerm.asc(t.priority))]))
          : (query..orderBy([((t) => OrderingTerm.desc(t.priority))]));
        break;
      case TaskSortBy.title:
        query = filter.sortAscending 
          ? (query..orderBy([((t) => OrderingTerm.asc(t.title))]))
          : (query..orderBy([((t) => OrderingTerm.desc(t.title))]));
        break;
      case TaskSortBy.status:
        query = filter.sortAscending 
          ? (query..orderBy([((t) => OrderingTerm.asc(t.status))]))
          : (query..orderBy([((t) => OrderingTerm.desc(t.status))]));
        break;
    }

    // Apply pagination at database level for maximum efficiency
    query = query..limit(pageSize, offset: page * pageSize);

    final taskRows = await query.get();
    final taskModels = <TaskModel>[];

    for (final taskRow in taskRows) {
      final taskModel = await _taskRowToModel(taskRow);
      taskModels.add(taskModel);
    }

    // Apply tag filtering in memory only if needed
    var filteredTasks = taskModels;
    if (filter.tags != null && filter.tags!.isNotEmpty) {
      filteredTasks = taskModels.where((task) {
        return filter.tags!.any((tagId) => task.tags.contains(tagId));
      }).toList();
    }

    return filteredTasks;
  }

  /// Get count of filtered tasks for pagination info
  Future<int> getTasksWithFilterCount(TaskFilter filter) async {
    var query = selectOnly(tasks)..addColumns([tasks.id.count()]);

    // Apply the same filters as getTasksWithFilter
    if (filter.status != null) {
      query = query..where(tasks.status.equals(_taskStatusToInt(filter.status!)));
    }

    if (filter.priority != null) {
      query = query..where(tasks.priority.equals(_taskPriorityToInt(filter.priority!)));
    }

    if (filter.projectId != null) {
      query = query..where(tasks.projectId.equals(filter.projectId!));
    }

    if (filter.dueDateFrom != null) {
      query = query..where(tasks.dueDate.isBiggerOrEqualValue(filter.dueDateFrom!));
    }

    if (filter.dueDateTo != null) {
      query = query..where(tasks.dueDate.isSmallerOrEqualValue(filter.dueDateTo!));
    }

    if (filter.isOverdue == true) {
      final now = DateTime.now();
      query = query..where(
        tasks.dueDate.isSmallerThanValue(now) & 
        tasks.status.isNotValue(_taskStatusToInt(TaskStatus.completed))
      );
    } else if (filter.isOverdue == false) {
      final now = DateTime.now();
      query = query..where(
        tasks.dueDate.isBiggerOrEqualValue(now) |
        tasks.dueDate.isNull() |
        tasks.status.equals(_taskStatusToInt(TaskStatus.completed))
      );
    }

    if (filter.isPinned != null) {
      query = query..where(tasks.isPinned.equals(filter.isPinned!));
    }

    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      query = query..where(
        tasks.title.contains(filter.searchQuery!) |
        tasks.description.contains(filter.searchQuery!)
      );
    }

    final result = await query.getSingle();
    return result.read(tasks.id.count()) ?? 0;
  }
}
