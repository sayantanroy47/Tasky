import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subtask.dart' as entities;
import '../../domain/repositories/subtask_repository.dart';
import '../../data/repositories/subtask_repository_impl.dart';
import '../../data/datasources/subtask_local_datasource.dart';
import '../../services/subtask_service.dart';
import '../../core/providers/core_providers.dart';

/// Subtask local data source provider
final subtaskLocalDataSourceProvider = Provider<SubtaskLocalDataSource>((ref) {
  final database = ref.read(databaseProvider);
  return SubtaskLocalDataSource(database: database);
});

/// Subtask repository provider
final subtaskRepositoryProvider = Provider<SubtaskRepository>((ref) {
  final localDataSource = ref.read(subtaskLocalDataSourceProvider);
  return SubtaskRepositoryImpl(localDataSource: localDataSource);
});

/// Subtask service provider
final subtaskServiceProvider = Provider<SubtaskService>((ref) {
  final repository = ref.read(subtaskRepositoryProvider);
  return SubtaskService(repository: repository);
});

/// Provider for subtasks of a specific task
final subtasksForTaskProvider = StreamProvider.family<List<entities.SubTask>, String>((ref, taskId) {
  final dataSource = ref.read(subtaskLocalDataSourceProvider);
  return dataSource.watchSubtasksForTask(taskId).cast<List<entities.SubTask>>();
});

/// Provider for subtask completion percentage of a specific task
final subtaskCompletionPercentageProvider = StreamProvider.family<double, String>((ref, taskId) {
  final dataSource = ref.read(subtaskLocalDataSourceProvider);
  return dataSource.watchSubtaskCompletionPercentage(taskId);
});

/// Provider for subtask statistics of a specific task
final subtaskStatsProvider = FutureProvider.family<SubtaskStats, String>((ref, taskId) async {
  final service = ref.read(subtaskServiceProvider);
  return await service.getSubtaskStats(taskId);
});

/// State notifier for managing subtask operations
class SubtaskNotifier extends StateNotifier<AsyncValue<List<entities.SubTask>>> {
  final SubtaskService _service;
  final String _taskId;

  SubtaskNotifier(this._service, this._taskId) : super(const AsyncValue.loading()) {
    _loadSubtasks();
  }

  /// Load subtasks for the task
  Future<void> _loadSubtasks() async {
    try {
      final subtasks = await _service.getSubtasksForTask(_taskId);
      state = AsyncValue.data(subtasks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Add a new subtask
  Future<void> addSubtask(String title) async {
    try {
      await _service.addSubtask(_taskId, title);
      await _loadSubtasks();
    } catch (error) {
      // Keep current state and show error
      rethrow;
    }
  }

  /// Update subtask title
  Future<void> updateSubtaskTitle(String subtaskId, String newTitle) async {
    try {
      await _service.updateSubtaskTitle(subtaskId, newTitle);
      await _loadSubtasks();
    } catch (error) {
      rethrow;
    }
  }

  /// Toggle subtask completion
  Future<void> toggleSubtaskCompletion(String subtaskId) async {
    try {
      await _service.toggleSubtaskCompletion(subtaskId);
      await _loadSubtasks();
    } catch (error) {
      rethrow;
    }
  }

  /// Delete a subtask
  Future<void> deleteSubtask(String subtaskId) async {
    try {
      await _service.deleteSubtask(subtaskId);
      await _loadSubtasks();
    } catch (error) {
      rethrow;
    }
  }

  /// Reorder subtasks
  Future<void> reorderSubtasks(List<String> subtaskIds) async {
    try {
      await _service.reorderSubtasks(_taskId, subtaskIds);
      await _loadSubtasks();
    } catch (error) {
      rethrow;
    }
  }

  /// Move subtask up
  Future<void> moveSubtaskUp(String subtaskId) async {
    try {
      await _service.moveSubtaskUp(subtaskId);
      await _loadSubtasks();
    } catch (error) {
      rethrow;
    }
  }

  /// Move subtask down
  Future<void> moveSubtaskDown(String subtaskId) async {
    try {
      await _service.moveSubtaskDown(subtaskId);
      await _loadSubtasks();
    } catch (error) {
      rethrow;
    }
  }

  /// Complete all subtasks
  Future<void> completeAllSubtasks() async {
    try {
      await _service.completeAllSubtasks(_taskId);
      await _loadSubtasks();
    } catch (error) {
      rethrow;
    }
  }

  /// Uncomplete all subtasks
  Future<void> uncompleteAllSubtasks() async {
    try {
      await _service.uncompleteAllSubtasks(_taskId);
      await _loadSubtasks();
    } catch (error) {
      rethrow;
    }
  }

  /// Refresh subtasks
  Future<void> refresh() async {
    await _loadSubtasks();
  }
}

/// Provider for subtask notifier
final subtaskNotifierProvider = StateNotifierProvider.family<SubtaskNotifier, AsyncValue<List<entities.SubTask>>, String>((ref, taskId) {
  final service = ref.read(subtaskServiceProvider);
  return SubtaskNotifier(service, taskId);
});

/// Provider for checking if a task has subtasks
final hasSubtasksProvider = FutureProvider.family<bool, String>((ref, taskId) async {
  final subtasks = await ref.read(subtasksForTaskProvider(taskId).future);
  return subtasks.isNotEmpty;
});

/// Provider for subtask count
final subtaskCountProvider = FutureProvider.family<int, String>((ref, taskId) async {
  final subtasks = await ref.read(subtasksForTaskProvider(taskId).future);
  return subtasks.length;
});

/// Provider for completed subtask count
final completedSubtaskCountProvider = FutureProvider.family<int, String>((ref, taskId) async {
  final subtasks = await ref.read(subtasksForTaskProvider(taskId).future);
  return subtasks.where((s) => s.isCompleted).length;
});

/// Provider for checking if all subtasks are completed
final allSubtasksCompletedProvider = FutureProvider.family<bool, String>((ref, taskId) async {
  final subtasks = await ref.read(subtasksForTaskProvider(taskId).future);
  if (subtasks.isEmpty) return false;
  return subtasks.every((s) => s.isCompleted);
});