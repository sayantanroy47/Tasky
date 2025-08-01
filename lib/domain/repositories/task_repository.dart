import '../entities/task_model.dart';
import '../entities/task_enums.dart';

/// Abstract repository interface for task operations
/// 
/// This interface defines all the operations that can be performed on tasks.
/// It follows the repository pattern to abstract data access logic from
/// business logic.
abstract class TaskRepository {
  /// Gets all tasks from the repository
  Future<List<TaskModel>> getAllTasks();

  /// Gets a task by its unique identifier
  Future<TaskModel?> getTaskById(String id);

  /// Creates a new task in the repository
  Future<void> createTask(TaskModel task);

  /// Updates an existing task in the repository
  Future<void> updateTask(TaskModel task);

  /// Deletes a task from the repository
  Future<void> deleteTask(String id);

  /// Gets tasks filtered by status
  Future<List<TaskModel>> getTasksByStatus(TaskStatus status);

  /// Gets tasks filtered by priority
  Future<List<TaskModel>> getTasksByPriority(TaskPriority priority);

  /// Gets tasks that are due today
  Future<List<TaskModel>> getTasksDueToday();

  /// Gets tasks that are overdue
  Future<List<TaskModel>> getOverdueTasks();

  /// Gets tasks that belong to a specific project
  Future<List<TaskModel>> getTasksByProject(String projectId);

  /// Searches tasks by title or description
  Future<List<TaskModel>> searchTasks(String query);

  /// Gets tasks with advanced filtering options
  Future<List<TaskModel>> getTasksWithFilter(TaskFilter filter);

  /// Watches all tasks (returns a stream for real-time updates)
  Stream<List<TaskModel>> watchAllTasks();

  /// Watches tasks filtered by status (returns a stream)
  Stream<List<TaskModel>> watchTasksByStatus(TaskStatus status);

  /// Watches tasks for a specific project (returns a stream)
  Stream<List<TaskModel>> watchTasksByProject(String projectId);
}

/// Filter options for advanced task querying
class TaskFilter {
  final TaskStatus? status;
  final TaskPriority? priority;
  final List<String>? tags;
  final String? projectId;
  final DateTime? dueDateFrom;
  final DateTime? dueDateTo;
  final bool? isOverdue;
  final bool? isPinned;
  final String? searchQuery;
  final TaskSortBy sortBy;
  final bool sortAscending;

  const TaskFilter({
    this.status,
    this.priority,
    this.tags,
    this.projectId,
    this.dueDateFrom,
    this.dueDateTo,
    this.isOverdue,
    this.isPinned,
    this.searchQuery,
    this.sortBy = TaskSortBy.createdAt,
    this.sortAscending = false,
  });

  /// Creates a copy of this filter with updated fields
  TaskFilter copyWith({
    TaskStatus? status,
    TaskPriority? priority,
    List<String>? tags,
    String? projectId,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
    bool? isOverdue,
    bool? isPinned,
    String? searchQuery,
    TaskSortBy? sortBy,
    bool? sortAscending,
  }) {
    return TaskFilter(
      status: status ?? this.status,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      projectId: projectId ?? this.projectId,
      dueDateFrom: dueDateFrom ?? this.dueDateFrom,
      dueDateTo: dueDateTo ?? this.dueDateTo,
      isOverdue: isOverdue ?? this.isOverdue,
      isPinned: isPinned ?? this.isPinned,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  /// Returns true if any filter is applied
  bool get hasFilters {
    return status != null ||
        priority != null ||
        tags != null ||
        projectId != null ||
        dueDateFrom != null ||
        dueDateTo != null ||
        isOverdue != null ||
        isPinned != null ||
        (searchQuery != null && searchQuery!.isNotEmpty);
  }
}

/// Sorting options for tasks
enum TaskSortBy {
  createdAt,
  updatedAt,
  dueDate,
  priority,
  title,
  status,
}

/// Extension to get display names for sort options
extension TaskSortByExtension on TaskSortBy {
  String get displayName {
    switch (this) {
      case TaskSortBy.createdAt:
        return 'Created Date';
      case TaskSortBy.updatedAt:
        return 'Updated Date';
      case TaskSortBy.dueDate:
        return 'Due Date';
      case TaskSortBy.priority:
        return 'Priority';
      case TaskSortBy.title:
        return 'Title';
      case TaskSortBy.status:
        return 'Status';
    }
  }
}
