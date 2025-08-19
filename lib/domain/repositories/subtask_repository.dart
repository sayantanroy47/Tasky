import '../entities/subtask.dart';

/// Repository interface for managing subtasks
abstract class SubtaskRepository {
  /// Get all subtasks for a specific task
  Future<List<SubTask>> getSubtasksForTask(String taskId);

  /// Add a new subtask
  Future<void> addSubtask(SubTask subtask);

  /// Update an existing subtask
  Future<void> updateSubtask(SubTask subtask);

  /// Delete a subtask
  Future<void> deleteSubtask(String subtaskId);

  /// Get a specific subtask by ID
  Future<SubTask?> getSubtaskById(String subtaskId);

  /// Get all subtasks
  Future<List<SubTask>> getAllSubtasks();

  /// Delete all subtasks for a task
  Future<void> deleteSubtasksForTask(String taskId);

  /// Reorder subtasks for a task
  Future<void> reorderSubtasks(String taskId, List<String> subtaskIds);

  /// Get subtask count for a task
  Future<int> getSubtaskCount(String taskId);

  /// Get completed subtask count for a task
  Future<int> getCompletedSubtaskCount(String taskId);

  /// Get subtask completion percentage for a task
  Future<double> getSubtaskCompletionPercentage(String taskId);

  /// Mark all subtasks as completed for a task
  Future<void> markAllSubtasksCompleted(String taskId);

  /// Mark all subtasks as incomplete for a task
  Future<void> markAllSubtasksIncomplete(String taskId);
}