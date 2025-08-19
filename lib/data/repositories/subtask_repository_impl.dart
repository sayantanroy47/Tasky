import '../../domain/entities/subtask.dart' as domain;
import '../../domain/repositories/subtask_repository.dart';
import '../datasources/subtask_local_datasource.dart';

/// Implementation of SubtaskRepository using local data source
class SubtaskRepositoryImpl implements SubtaskRepository {
  final SubtaskLocalDataSource _localDataSource;

  SubtaskRepositoryImpl({
    required SubtaskLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<List<domain.SubTask>> getSubtasksForTask(String taskId) async {
    try {
      return await _localDataSource.getSubtasksForTask(taskId);
    } catch (e) {
      throw Exception('Failed to get subtasks for task: $e');
    }
  }

  @override
  Future<void> addSubtask(domain.SubTask subtask) async {
    try {
      if (!subtask.isValid()) {
        throw Exception('Invalid subtask data');
      }
      await _localDataSource.insertSubtask(subtask);
    } catch (e) {
      throw Exception('Failed to add subtask: $e');
    }
  }

  @override
  Future<void> updateSubtask(domain.SubTask subtask) async {
    try {
      if (!subtask.isValid()) {
        throw Exception('Invalid subtask data');
      }
      await _localDataSource.updateSubtask(subtask);
    } catch (e) {
      throw Exception('Failed to update subtask: $e');
    }
  }

  @override
  Future<void> deleteSubtask(String subtaskId) async {
    try {
      await _localDataSource.deleteSubtask(subtaskId);
    } catch (e) {
      throw Exception('Failed to delete subtask: $e');
    }
  }

  @override
  Future<domain.SubTask?> getSubtaskById(String subtaskId) async {
    try {
      return await _localDataSource.getSubtaskById(subtaskId);
    } catch (e) {
      throw Exception('Failed to get subtask: $e');
    }
  }

  @override
  Future<List<domain.SubTask>> getAllSubtasks() async {
    try {
      return await _localDataSource.getAllSubtasks();
    } catch (e) {
      throw Exception('Failed to get all subtasks: $e');
    }
  }

  @override
  Future<void> deleteSubtasksForTask(String taskId) async {
    try {
      await _localDataSource.deleteSubtasksForTask(taskId);
    } catch (e) {
      throw Exception('Failed to delete subtasks for task: $e');
    }
  }

  @override
  Future<void> reorderSubtasks(String taskId, List<String> subtaskIds) async {
    try {
      await _localDataSource.reorderSubtasks(taskId, subtaskIds);
    } catch (e) {
      throw Exception('Failed to reorder subtasks: $e');
    }
  }

  @override
  Future<int> getSubtaskCount(String taskId) async {
    try {
      final subtasks = await _localDataSource.getSubtasksForTask(taskId);
      return subtasks.length;
    } catch (e) {
      throw Exception('Failed to get subtask count: $e');
    }
  }

  @override
  Future<int> getCompletedSubtaskCount(String taskId) async {
    try {
      final subtasks = await _localDataSource.getSubtasksForTask(taskId);
      return subtasks.where((subtask) => subtask.isCompleted).length;
    } catch (e) {
      throw Exception('Failed to get completed subtask count: $e');
    }
  }

  @override
  Future<double> getSubtaskCompletionPercentage(String taskId) async {
    try {
      final totalCount = await getSubtaskCount(taskId);
      if (totalCount == 0) return 0.0;
      
      final completedCount = await getCompletedSubtaskCount(taskId);
      return (completedCount / totalCount) * 100.0;
    } catch (e) {
      throw Exception('Failed to get subtask completion percentage: $e');
    }
  }

  @override
  Future<void> markAllSubtasksCompleted(String taskId) async {
    try {
      final subtasks = await _localDataSource.getSubtasksForTask(taskId);
      for (final subtask in subtasks) {
        if (!subtask.isCompleted) {
          await _localDataSource.updateSubtask(subtask.markCompleted());
        }
      }
    } catch (e) {
      throw Exception('Failed to mark all subtasks completed: $e');
    }
  }

  @override
  Future<void> markAllSubtasksIncomplete(String taskId) async {
    try {
      final subtasks = await _localDataSource.getSubtasksForTask(taskId);
      for (final subtask in subtasks) {
        if (subtask.isCompleted) {
          await _localDataSource.updateSubtask(subtask.markIncomplete());
        }
      }
    } catch (e) {
      throw Exception('Failed to mark all subtasks incomplete: $e');
    }
  }
}