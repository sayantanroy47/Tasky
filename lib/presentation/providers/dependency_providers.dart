import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task_model.dart';
import '../../services/dependency_service.dart';
import '../../core/providers/core_providers.dart';

// Service provider
final dependencyServiceProvider = Provider<DependencyService>((ref) {
  final taskRepository = ref.read(taskRepositoryProvider);
  return DependencyService(taskRepository);
});

// State providers
final blockedTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final dependencyService = ref.read(dependencyServiceProvider);
  return await dependencyService.getBlockedTasks();
});

final readyTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final dependencyService = ref.read(dependencyServiceProvider);
  return await dependencyService.getReadyTasks();
});

final suggestedNextTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final dependencyService = ref.read(dependencyServiceProvider);
  return await dependencyService.getSuggestedNextTasks();
});

final taskPrerequisitesProvider = FutureProvider.family<List<TaskModel>, String>((ref, taskId) async {
  final dependencyService = ref.read(dependencyServiceProvider);
  return await dependencyService.getPrerequisites(taskId);
});

final taskDependentsProvider = FutureProvider.family<List<TaskModel>, String>((ref, taskId) async {
  final dependencyService = ref.read(dependencyServiceProvider);
  return await dependencyService.getDependents(taskId);
});

final taskDependencyChainProvider = FutureProvider.family<List<TaskModel>, String>((ref, taskId) async {
  final dependencyService = ref.read(dependencyServiceProvider);
  return await dependencyService.getDependencyChain(taskId);
});

final canCompleteTaskProvider = FutureProvider.family<bool, String>((ref, taskId) async {
  final dependencyService = ref.read(dependencyServiceProvider);
  return await dependencyService.canCompleteTask(taskId);
});

// Dependency management state
final dependencyManagerProvider = StateNotifierProvider<DependencyManagerNotifier, DependencyManagerState>(
  (ref) => DependencyManagerNotifier(ref.read(dependencyServiceProvider)),
);

/// State for dependency management
class DependencyManagerState {
  final String? selectedTaskId;
  final List<TaskModel> availableTasks;
  final List<TaskModel> prerequisites;
  final List<TaskModel> dependents;
  final bool isLoading;
  final String? error;

  const DependencyManagerState({
    this.selectedTaskId,
    this.availableTasks = const [],
    this.prerequisites = const [],
    this.dependents = const [],
    this.isLoading = false,
    this.error,
  });

  DependencyManagerState copyWith({
    String? selectedTaskId,
    List<TaskModel>? availableTasks,
    List<TaskModel>? prerequisites,
    List<TaskModel>? dependents,
    bool? isLoading,
    String? error,
  }) {
    return DependencyManagerState(
      selectedTaskId: selectedTaskId ?? this.selectedTaskId,
      availableTasks: availableTasks ?? this.availableTasks,
      prerequisites: prerequisites ?? this.prerequisites,
      dependents: dependents ?? this.dependents,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier for dependency management
class DependencyManagerNotifier extends StateNotifier<DependencyManagerState> {
  final DependencyService _dependencyService;

  DependencyManagerNotifier(this._dependencyService) : super(const DependencyManagerState());

  Future<void> selectTask(String taskId) async {
    try {
      state = state.copyWith(selectedTaskId: taskId, isLoading: true, error: null);
      
      final prerequisites = await _dependencyService.getPrerequisites(taskId);
      final dependents = await _dependencyService.getDependents(taskId);
      
      state = state.copyWith(
        prerequisites: prerequisites,
        dependents: dependents,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> loadAvailableTasks() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Get all tasks from repository (you'd need to add this to the service)
      // For now, we'll use an empty list
      final tasks = <TaskModel>[];
      
      state = state.copyWith(
        availableTasks: tasks,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
      );
    }
  }

  Future<String?> validateDependency(String dependentTaskId, String prerequisiteTaskId) async {
    try {
      return await _dependencyService.validateDependency(dependentTaskId, prerequisiteTaskId);
    } catch (error) {
      return error.toString();
    }
  }

  Future<bool> addDependency(String dependentTaskId, String prerequisiteTaskId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _dependencyService.addDependency(dependentTaskId, prerequisiteTaskId);
      
      // Refresh the current task's dependencies
      if (state.selectedTaskId == dependentTaskId) {
        await selectTask(dependentTaskId);
      }
      
      return true;
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> removeDependency(String dependentTaskId, String prerequisiteTaskId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _dependencyService.removeDependency(dependentTaskId, prerequisiteTaskId);
      
      // Refresh the current task's dependencies
      if (state.selectedTaskId == dependentTaskId) {
        await selectTask(dependentTaskId);
      }
      
      return true;
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  void clearSelection() {
    state = const DependencyManagerState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
