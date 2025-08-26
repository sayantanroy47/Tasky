import '../entities/task_model.dart';
import '../models/enums.dart';

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

  /// Updates a task safely with concurrent modification handling
  Future<TaskModel?> updateTaskSafely(TaskModel task);

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

  /// Gets tasks within a date range
  Future<List<TaskModel>> getTasksByDateRange(DateTime startDate, DateTime endDate);

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

  /// Gets multiple tasks by their IDs
  Future<List<TaskModel>> getTasksByIds(List<String> ids);

  /// Gets tasks that have a specific task as a dependency
  Future<List<TaskModel>> getTasksWithDependency(String dependencyId);

  // Bulk Operations
  
  /// Bulk delete multiple tasks by their IDs
  Future<void> deleteTasks(List<String> taskIds);
  
  /// Bulk update task status for multiple tasks
  Future<void> updateTasksStatus(List<String> taskIds, TaskStatus status);
  
  /// Bulk update task priority for multiple tasks
  Future<void> updateTasksPriority(List<String> taskIds, TaskPriority priority);
  
  /// Bulk assign tasks to a project
  Future<void> assignTasksToProject(List<String> taskIds, String? projectId);

  // Additional methods required by services
  
  /// Gets tasks for a specific project (alias for getTasksByProject)
  Future<List<TaskModel>> getTasksForProject(String projectId) => getTasksByProject(projectId);
  
  /// Gets tasks by project ID (alias for getTasksByProject)
  Future<List<TaskModel>> getTasksByProjectId(String projectId) => getTasksByProject(projectId);
  
  /// Gets tasks that don't belong to any project
  Future<List<TaskModel>> getTasksWithoutProject();
}


