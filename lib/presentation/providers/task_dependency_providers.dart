import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../services/task/task_dependency_service.dart';
import '../../core/providers/core_providers.dart';

/// Provider for TaskDependencyService
final taskDependencyServiceProvider = Provider<TaskDependencyService>((ref) {
  final taskRepository = ref.read(taskRepositoryProvider);
  return TaskDependencyService(taskRepository);
});

/// Provider for ready tasks (tasks that can be started now)
final readyTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final dependencyService = ref.read(taskDependencyServiceProvider);
  return await dependencyService.getReadyTasks();
});

/// Provider for blocked tasks (tasks waiting for dependencies)
final blockedTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final dependencyService = ref.read(taskDependencyServiceProvider);
  return await dependencyService.getBlockedTasks();
});

/// Provider for getting dependency chain of a specific task
final taskDependencyChainProvider = 
    FutureProvider.family<List<TaskModel>, TaskModel>((ref, task) async {
  final dependencyService = ref.read(taskDependencyServiceProvider);
  return await dependencyService.getDependencyChain(task);
});

/// Provider for getting dependent tasks (tasks that depend on this one)
final dependentTasksProvider = 
    FutureProvider.family<List<TaskModel>, String>((ref, taskId) async {
  final dependencyService = ref.read(taskDependencyServiceProvider);
  return await dependencyService.getDependentTasks(taskId);
});

/// Provider for task dependency validation
final taskDependencyValidationProvider = 
    FutureProvider.family<DependencyValidationResult, TaskModel>((ref, task) async {
  final dependencyService = ref.read(taskDependencyServiceProvider);
  return await dependencyService.validateTaskCompletion(task);
});

/// State notifier for managing task dependencies
class TaskDependencyNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final TaskDependencyService _service;
  final Ref _ref;

  TaskDependencyNotifier(this._service, this._ref) : super(const AsyncValue.loading()) {
    _loadAllDependencyData();
  }

  Future<void> _loadAllDependencyData() async {
    try {
      // Load ready tasks by default
      final readyTasks = await _service.getReadyTasks();
      state = AsyncValue.data(readyTasks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<DependencyResult> addDependency(String dependentTaskId, String prerequisiteTaskId) async {
    final result = await _service.addDependency(dependentTaskId, prerequisiteTaskId);
    
    if (result.isSuccess) {
      // Refresh the state
      await _loadAllDependencyData();
      // Invalidate related providers
      _ref.invalidate(readyTasksProvider);
      _ref.invalidate(blockedTasksProvider);
      _ref.invalidate(taskDependencyChainProvider);
      _ref.invalidate(dependentTasksProvider);
    }
    
    return result;
  }

  Future<DependencyResult> removeDependency(String dependentTaskId, String prerequisiteTaskId) async {
    final result = await _service.removeDependency(dependentTaskId, prerequisiteTaskId);
    
    if (result.isSuccess) {
      // Refresh the state
      await _loadAllDependencyData();
      // Invalidate related providers
      _ref.invalidate(readyTasksProvider);
      _ref.invalidate(blockedTasksProvider);
      _ref.invalidate(taskDependencyChainProvider);
      _ref.invalidate(dependentTasksProvider);
    }
    
    return result;
  }

  Future<void> onTaskCompleted(TaskModel completedTask) async {
    await _service.onTaskCompleted(completedTask);
    // Refresh the state to update ready/blocked tasks
    await _loadAllDependencyData();
    // Invalidate related providers
    _ref.invalidate(readyTasksProvider);
    _ref.invalidate(blockedTasksProvider);
  }

  Future<List<TaskModel>> getTasksInDependencyOrder(List<TaskModel> tasks) async {
    return await _service.getTasksInDependencyOrder(tasks);
  }

  void refresh() {
    _loadAllDependencyData();
  }
}

/// Provider for TaskDependencyNotifier
final taskDependencyNotifierProvider = 
    StateNotifierProvider<TaskDependencyNotifier, AsyncValue<List<TaskModel>>>((ref) {
  final service = ref.read(taskDependencyServiceProvider);
  return TaskDependencyNotifier(service, ref);
});

/// Provider for dependency graph data
final dependencyGraphProvider = FutureProvider<DependencyGraphData>((ref) async {
  final taskRepository = ref.read(taskRepositoryProvider);
  final dependencyService = ref.read(taskDependencyServiceProvider);
  
  final allTasks = await taskRepository.getAllTasks();
  final activeTasks = allTasks.where((task) => 
    task.status == TaskStatus.pending || 
    task.status == TaskStatus.inProgress
  ).toList();
  
  final readyTasks = await dependencyService.getReadyTasks();
  final blockedTasks = await dependencyService.getBlockedTasks();
  
  // Build dependency relationships
  final dependencies = <DependencyRelationship>[];
  for (final task in activeTasks) {
    for (final depId in task.dependencies) {
      final prerequisite = allTasks.firstWhere(
        (t) => t.id == depId,
        orElse: () => throw Exception('Dependency not found: $depId'),
      );
      dependencies.add(DependencyRelationship(
        dependent: task,
        prerequisite: prerequisite,
      ));
    }
  }
  
  return DependencyGraphData(
    allTasks: activeTasks,
    readyTasks: readyTasks,
    blockedTasks: blockedTasks,
    dependencies: dependencies,
  );
});

/// Data class for dependency graph
class DependencyGraphData {
  final List<TaskModel> allTasks;
  final List<TaskModel> readyTasks;
  final List<TaskModel> blockedTasks;
  final List<DependencyRelationship> dependencies;

  const DependencyGraphData({
    required this.allTasks,
    required this.readyTasks,
    required this.blockedTasks,
    required this.dependencies,
  });
}

/// Data class for dependency relationship
class DependencyRelationship {
  final TaskModel dependent;
  final TaskModel prerequisite;

  const DependencyRelationship({
    required this.dependent,
    required this.prerequisite,
  });
}

/// Provider for dependency statistics
final dependencyStatsProvider = FutureProvider<DependencyStats>((ref) async {
  final graphData = await ref.read(dependencyGraphProvider.future);
  
  final totalTasks = graphData.allTasks.length;
  final readyCount = graphData.readyTasks.length;
  final blockedCount = graphData.blockedTasks.length;
  final dependencyCount = graphData.dependencies.length;
  
  // Calculate average dependencies per task
  final totalDependencies = graphData.allTasks
      .map((task) => task.dependencies.length)
      .fold(0, (sum, count) => sum + count);
  final avgDependencies = totalTasks > 0 ? totalDependencies / totalTasks : 0.0;
  
  // Find tasks with most dependencies
  final tasksByDepCount = Map.fromEntries(
    graphData.allTasks.map((task) => MapEntry(task, task.dependencies.length))
  );
  final maxDependencies = tasksByDepCount.values.isEmpty ? 0 : tasksByDepCount.values.reduce((a, b) => a > b ? a : b);
  final mostDependentTasks = tasksByDepCount.entries
      .where((entry) => entry.value == maxDependencies && maxDependencies > 0)
      .map((entry) => entry.key)
      .toList();
  
  return DependencyStats(
    totalTasks: totalTasks,
    readyTasks: readyCount,
    blockedTasks: blockedCount,
    totalDependencies: dependencyCount,
    averageDependencies: avgDependencies,
    maxDependencies: maxDependencies,
    mostDependentTasks: mostDependentTasks,
  );
});

/// Statistics for task dependencies
class DependencyStats {
  final int totalTasks;
  final int readyTasks;
  final int blockedTasks;
  final int totalDependencies;
  final double averageDependencies;
  final int maxDependencies;
  final List<TaskModel> mostDependentTasks;

  const DependencyStats({
    required this.totalTasks,
    required this.readyTasks,
    required this.blockedTasks,
    required this.totalDependencies,
    required this.averageDependencies,
    required this.maxDependencies,
    required this.mostDependentTasks,
  });
}