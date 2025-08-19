import '../../domain/entities/subtask.dart' as domain;
import '../../services/database/database.dart';

/// Local data source for subtasks using Drift database
class SubtaskLocalDataSource {
  final AppDatabase _database;

  SubtaskLocalDataSource({required AppDatabase database}) : _database = database;

  /// Get all subtasks for a specific task
  Future<List<domain.SubTask>> getSubtasksForTask(String taskId) async {
    return await _database.subtaskDao.getSubtasksForTask(taskId);
  }

  /// Get a subtask by ID
  Future<domain.SubTask?> getSubtaskById(String subtaskId) async {
    return await _database.subtaskDao.getSubtaskById(subtaskId);
  }

  /// Get all subtasks
  Future<List<domain.SubTask>> getAllSubtasks() async {
    return await _database.subtaskDao.getAllSubtasks();
  }

  /// Insert a new subtask
  Future<void> insertSubtask(domain.SubTask subtask) async {
    await _database.subtaskDao.insertSubtask(subtask);
  }

  /// Update an existing subtask
  Future<void> updateSubtask(domain.SubTask subtask) async {
    await _database.subtaskDao.updateSubtask(subtask);
  }

  /// Delete a subtask
  Future<void> deleteSubtask(String subtaskId) async {
    await _database.subtaskDao.deleteSubtask(subtaskId);
  }

  /// Delete all subtasks for a task
  Future<void> deleteSubtasksForTask(String taskId) async {
    await _database.subtaskDao.deleteSubtasksForTask(taskId);
  }

  /// Reorder subtasks for a task
  Future<void> reorderSubtasks(String taskId, List<String> subtaskIds) async {
    await _database.subtaskDao.reorderSubtasks(taskId, subtaskIds);
  }

  /// Get subtask count for a task
  Future<int> getSubtaskCount(String taskId) async {
    return await _database.subtaskDao.getSubtaskCount(taskId);
  }

  /// Get completed subtask count for a task
  Future<int> getCompletedSubtaskCount(String taskId) async {
    return await _database.subtaskDao.getCompletedSubtaskCount(taskId);
  }

  /// Get subtask completion percentage for a task
  Future<double> getSubtaskCompletionPercentage(String taskId) async {
    return await _database.subtaskDao.getSubtaskCompletionPercentage(taskId);
  }

  /// Mark all subtasks as completed for a task
  Future<void> markAllSubtasksCompleted(String taskId) async {
    await _database.subtaskDao.markAllSubtasksCompleted(taskId);
  }

  /// Mark all subtasks as incomplete for a task
  Future<void> markAllSubtasksIncomplete(String taskId) async {
    await _database.subtaskDao.markAllSubtasksIncomplete(taskId);
  }

  /// Get the next sort order for a new subtask
  Future<int> getNextSortOrder(String taskId) async {
    return await _database.subtaskDao.getNextSortOrder(taskId);
  }

  /// Watch subtasks for a task (real-time updates)
  Stream<List<domain.SubTask>> watchSubtasksForTask(String taskId) {
    return _database.subtaskDao.watchSubtasksForTask(taskId);
  }

  /// Watch subtask completion percentage for a task
  Stream<double> watchSubtaskCompletionPercentage(String taskId) {
    return _database.subtaskDao.watchSubtaskCompletionPercentage(taskId);
  }
}