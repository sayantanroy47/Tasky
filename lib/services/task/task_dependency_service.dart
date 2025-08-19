import 'package:flutter/foundation.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/models/enums.dart';

/// Service for managing task dependencies
/// 
/// This service handles:
/// - Validating task dependencies before completion
/// - Detecting circular dependencies
/// - Managing dependency chains
/// - Providing dependency-aware task ordering
class TaskDependencyService {
  final TaskRepository _taskRepository;
  
  const TaskDependencyService(this._taskRepository);
  
  /// Validates if a task can be completed based on its dependencies
  Future<DependencyValidationResult> validateTaskCompletion(TaskModel task) async {
    if (task.dependencies.isEmpty) {
      return DependencyValidationResult.success();
    }
    
    final dependencyTasks = await _taskRepository.getTasksByIds(task.dependencies);
    final incompleteDependencies = dependencyTasks
        .where((dep) => dep.status != TaskStatus.completed)
        .toList();
    
    if (incompleteDependencies.isNotEmpty) {
      return DependencyValidationResult.failure(
        'Cannot complete task: ${incompleteDependencies.length} dependencies are not completed',
        incompleteDependencies,
      );
    }
    
    return DependencyValidationResult.success();
  }
  
  /// Adds a dependency relationship between two tasks
  Future<DependencyResult> addDependency(String dependentTaskId, String prerequisiteTaskId) async {
    if (dependentTaskId == prerequisiteTaskId) {
      return DependencyResult.failure('A task cannot depend on itself');
    }
    
    final dependentTask = await _taskRepository.getTaskById(dependentTaskId);
    final prerequisiteTask = await _taskRepository.getTaskById(prerequisiteTaskId);
    
    if (dependentTask == null) {
      return DependencyResult.failure('Dependent task not found');
    }
    
    if (prerequisiteTask == null) {
      return DependencyResult.failure('Prerequisite task not found');
    }
    
    // Check for circular dependency
    final circularCheck = await _wouldCreateCircularDependency(dependentTaskId, prerequisiteTaskId);
    if (circularCheck) {
      return DependencyResult.failure('Adding this dependency would create a circular dependency');
    }
    
    // Add the dependency
    final updatedTask = dependentTask.addDependency(prerequisiteTaskId);
    await _taskRepository.updateTask(updatedTask);
    
    return DependencyResult.success();
  }
  
  /// Removes a dependency relationship
  Future<DependencyResult> removeDependency(String dependentTaskId, String prerequisiteTaskId) async {
    final dependentTask = await _taskRepository.getTaskById(dependentTaskId);
    
    if (dependentTask == null) {
      return DependencyResult.failure('Task not found');
    }
    
    final updatedTask = dependentTask.removeDependency(prerequisiteTaskId);
    await _taskRepository.updateTask(updatedTask);
    
    return DependencyResult.success();
  }
  
  /// Checks if adding a dependency would create a circular dependency
  Future<bool> _wouldCreateCircularDependency(String dependentTaskId, String prerequisiteTaskId) async {
    // If prerequisiteTask depends on dependentTask (directly or indirectly), 
    // then adding dependentTask -> prerequisiteTask would create a cycle
    return await _hasPath(prerequisiteTaskId, dependentTaskId);
  }
  
  /// Checks if there's a dependency path from startTaskId to targetTaskId
  Future<bool> _hasPath(String startTaskId, String targetTaskId) async {
    if (startTaskId == targetTaskId) {
      return true;
    }
    
    final visited = <String>{};
    final toVisit = <String>[startTaskId];
    
    while (toVisit.isNotEmpty) {
      final currentTaskId = toVisit.removeLast();
      
      if (visited.contains(currentTaskId)) {
        continue;
      }
      
      visited.add(currentTaskId);
      
      final currentTask = await _taskRepository.getTaskById(currentTaskId);
      if (currentTask == null) continue;
      
      for (final dependencyId in currentTask.dependencies) {
        if (dependencyId == targetTaskId) {
          return true;
        }
        
        if (!visited.contains(dependencyId)) {
          toVisit.add(dependencyId);
        }
      }
    }
    
    return false;
  }
  
  /// Gets all tasks that depend on the given task
  Future<List<TaskModel>> getDependentTasks(String taskId) async {
    return await _taskRepository.getTasksWithDependency(taskId);
  }
  
  /// Gets the dependency chain for a task (all prerequisites recursively)
  Future<List<TaskModel>> getDependencyChain(TaskModel task) async {
    final chain = <TaskModel>[];
    final visited = <String>{};
    
    await _buildDependencyChain(task, chain, visited);
    
    return chain;
  }
  
  /// Recursively builds the dependency chain
  Future<void> _buildDependencyChain(
    TaskModel task, 
    List<TaskModel> chain, 
    Set<String> visited,
  ) async {
    if (visited.contains(task.id)) {
      return; // Avoid infinite loops
    }
    
    visited.add(task.id);
    
    if (task.dependencies.isNotEmpty) {
      final dependencyTasks = await _taskRepository.getTasksByIds(task.dependencies);
      
      for (final dependency in dependencyTasks) {
        await _buildDependencyChain(dependency, chain, visited);
        if (!chain.any((t) => t.id == dependency.id)) {
          chain.add(dependency);
        }
      }
    }
  }
  
  /// Gets tasks ordered by their dependencies (topological sort)
  Future<List<TaskModel>> getTasksInDependencyOrder(List<TaskModel> tasks) async {
    final result = <TaskModel>[];
    final visited = <String>{};
    final visiting = <String>{};
    
    for (final task in tasks) {
      await _topologicalSort(task, tasks, result, visited, visiting);
    }
    
    return result;
  }
  
  /// Performs topological sort for dependency ordering
  Future<void> _topologicalSort(
    TaskModel task,
    List<TaskModel> allTasks,
    List<TaskModel> result,
    Set<String> visited,
    Set<String> visiting,
  ) async {
    if (visited.contains(task.id)) {
      return;
    }
    
    if (visiting.contains(task.id)) {
      // Circular dependency detected
      return;
    }
    
    visiting.add(task.id);
    
    // Visit all dependencies first
    for (final depId in task.dependencies) {
      final depTask = allTasks.firstWhere(
        (t) => t.id == depId,
        orElse: () => throw Exception('Dependency not found: $depId'),
      );
      await _topologicalSort(depTask, allTasks, result, visited, visiting);
    }
    
    visiting.remove(task.id);
    visited.add(task.id);
    result.add(task);
  }
  
  /// Gets tasks that are ready to be worked on (all dependencies completed)
  Future<List<TaskModel>> getReadyTasks() async {
    final pendingTasks = await _taskRepository.getTasksByStatus(TaskStatus.pending);
    final readyTasks = <TaskModel>[];
    
    for (final task in pendingTasks) {
      final validation = await validateTaskCompletion(task);
      if (validation.isValid) {
        readyTasks.add(task);
      }
    }
    
    return readyTasks;
  }
  
  /// Gets tasks that are blocked by dependencies
  Future<List<TaskModel>> getBlockedTasks() async {
    final pendingTasks = await _taskRepository.getTasksByStatus(TaskStatus.pending);
    final blockedTasks = <TaskModel>[];
    
    for (final task in pendingTasks) {
      final validation = await validateTaskCompletion(task);
      if (!validation.isValid) {
        blockedTasks.add(task);
      }
    }
    
    return blockedTasks;
  }
  
  /// Updates all dependent tasks when a task is completed
  Future<void> onTaskCompleted(TaskModel completedTask) async {
    final dependentTasks = await getDependentTasks(completedTask.id);
    
    // Check if any dependent tasks are now ready to start
    for (final dependent in dependentTasks) {
      final validation = await validateTaskCompletion(dependent);
      if (validation.isValid && dependent.status == TaskStatus.pending) {
        // Optionally, you could automatically move to in-progress
        // For now, just log that the task is ready
        debugPrint('Task "${dependent.title}" is now ready to start');
      }
    }
  }
}

/// Result of dependency validation
class DependencyValidationResult {
  final bool isValid;
  final String? errorMessage;
  final List<TaskModel> incompleteDependencies;
  
  const DependencyValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.incompleteDependencies = const [],
  });
  
  factory DependencyValidationResult.success() {
    return const DependencyValidationResult._(isValid: true);
  }
  
  factory DependencyValidationResult.failure(
    String message,
    List<TaskModel> incompleteDependencies,
  ) {
    return DependencyValidationResult._(
      isValid: false,
      errorMessage: message,
      incompleteDependencies: incompleteDependencies,
    );
  }
}

/// Result of dependency operations
class DependencyResult {
  final bool isSuccess;
  final String? errorMessage;
  
  const DependencyResult._({
    required this.isSuccess,
    this.errorMessage,
  });
  
  factory DependencyResult.success() {
    return const DependencyResult._(isSuccess: true);
  }
  
  factory DependencyResult.failure(String message) {
    return DependencyResult._(isSuccess: false, errorMessage: message);
  }
}