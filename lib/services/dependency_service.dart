import '../domain/entities/task_model.dart';
import '../domain/entities/task_enums.dart';
import '../domain/repositories/task_repository.dart';

/// Service for managing task dependencies and validation
/// 
/// This service provides functionality to validate task dependencies,
/// check for circular dependencies, and enforce dependency rules.
class DependencyService {
  final TaskRepository _taskRepository;

  const DependencyService(this._taskRepository);

  /// Validates if a dependency can be added between two tasks
  /// 
  /// Returns null if valid, or an error message if invalid
  Future<String?> validateDependency(String dependentTaskId, String prerequisiteTaskId) async {
    // Can't depend on itself
    if (dependentTaskId == prerequisiteTaskId) {
      return 'A task cannot depend on itself';
    }

    // Check if both tasks exist
    final dependentTask = await _taskRepository.getTaskById(dependentTaskId);
    final prerequisiteTask = await _taskRepository.getTaskById(prerequisiteTaskId);

    if (dependentTask == null) {
      return 'Dependent task not found';
    }

    if (prerequisiteTask == null) {
      return 'Prerequisite task not found';
    }

    // Check if dependency already exists
    if (dependentTask.dependencies.contains(prerequisiteTaskId)) {
      return 'Dependency already exists';
    }

    // Check for circular dependencies
    final wouldCreateCircle = await _wouldCreateCircularDependency(
      dependentTaskId, 
      prerequisiteTaskId,
    );

    if (wouldCreateCircle) {
      return 'This would create a circular dependency';
    }

    return null; // Valid dependency
  }

  /// Checks if adding a dependency would create a circular dependency
  Future<bool> _wouldCreateCircularDependency(String dependentTaskId, String prerequisiteTaskId) async {
    // If the prerequisite task depends on the dependent task (directly or indirectly),
    // then adding this dependency would create a circle
    return await _taskDependsOn(prerequisiteTaskId, dependentTaskId);
  }

  /// Recursively checks if taskA depends on taskB (directly or indirectly)
  Future<bool> _taskDependsOn(String taskAId, String taskBId, [Set<String>? visited]) async {
    visited ??= <String>{};

    // Prevent infinite loops
    if (visited.contains(taskAId)) {
      return false;
    }
    visited.add(taskAId);

    final taskA = await _taskRepository.getTaskById(taskAId);
    if (taskA == null) return false;

    // Direct dependency
    if (taskA.dependencies.contains(taskBId)) {
      return true;
    }

    // Check indirect dependencies
    for (final dependencyId in taskA.dependencies) {
      if (await _taskDependsOn(dependencyId, taskBId, visited)) {
        return true;
      }
    }

    return false;
  }

  /// Gets all tasks that the given task depends on (prerequisites)
  Future<List<TaskModel>> getPrerequisites(String taskId) async {
    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) return [];

    final prerequisites = <TaskModel>[];
    for (final dependencyId in task.dependencies) {
      final prerequisite = await _taskRepository.getTaskById(dependencyId);
      if (prerequisite != null) {
        prerequisites.add(prerequisite);
      }
    }

    return prerequisites;
  }

  /// Gets all tasks that depend on the given task (dependents)
  Future<List<TaskModel>> getDependents(String taskId) async {
    final allTasks = await _taskRepository.getAllTasks();
    return allTasks.where((task) => task.dependencies.contains(taskId)).toList();
  }

  /// Checks if a task can be completed based on its dependencies
  Future<bool> canCompleteTask(String taskId) async {
    final prerequisites = await getPrerequisites(taskId);
    return prerequisites.every((task) => task.status == TaskStatus.completed);
  }

  /// Gets tasks that are blocked by incomplete dependencies
  Future<List<TaskModel>> getBlockedTasks() async {
    final allTasks = await _taskRepository.getAllTasks();
    final blockedTasks = <TaskModel>[];

    for (final task in allTasks) {
      if (task.status.isActive && task.hasDependencies) {
        final canComplete = await canCompleteTask(task.id);
        if (!canComplete) {
          blockedTasks.add(task);
        }
      }
    }

    return blockedTasks;
  }

  /// Gets tasks that are ready to be worked on (no blocking dependencies)
  Future<List<TaskModel>> getReadyTasks() async {
    final allTasks = await _taskRepository.getAllTasks();
    final readyTasks = <TaskModel>[];

    for (final task in allTasks) {
      if (task.status.isActive) {
        if (!task.hasDependencies) {
          readyTasks.add(task);
        } else {
          final canComplete = await canCompleteTask(task.id);
          if (canComplete) {
            readyTasks.add(task);
          }
        }
      }
    }

    return readyTasks;
  }

  /// Adds a dependency between two tasks
  Future<void> addDependency(String dependentTaskId, String prerequisiteTaskId) async {
    final validationError = await validateDependency(dependentTaskId, prerequisiteTaskId);
    if (validationError != null) {
      throw DependencyValidationException(validationError);
    }

    final task = await _taskRepository.getTaskById(dependentTaskId);
    if (task == null) {
      throw TaskNotFoundException('Task not found: $dependentTaskId');
    }

    final updatedTask = task.addDependency(prerequisiteTaskId);
    await _taskRepository.updateTask(updatedTask);
  }

  /// Removes a dependency between two tasks
  Future<void> removeDependency(String dependentTaskId, String prerequisiteTaskId) async {
    final task = await _taskRepository.getTaskById(dependentTaskId);
    if (task == null) {
      throw TaskNotFoundException('Task not found: $dependentTaskId');
    }

    final updatedTask = task.removeDependency(prerequisiteTaskId);
    await _taskRepository.updateTask(updatedTask);
  }

  /// Gets the dependency chain for a task (all tasks it depends on, recursively)
  Future<List<TaskModel>> getDependencyChain(String taskId, [Set<String>? visited]) async {
    visited ??= <String>{};
    
    if (visited.contains(taskId)) {
      return []; // Prevent infinite loops
    }
    visited.add(taskId);

    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) return [];

    final chain = <TaskModel>[];
    
    for (final dependencyId in task.dependencies) {
      final dependency = await _taskRepository.getTaskById(dependencyId);
      if (dependency != null) {
        chain.add(dependency);
        // Add dependencies of this dependency
        final subChain = await getDependencyChain(dependencyId, visited);
        chain.addAll(subChain);
      }
    }

    return chain;
  }

  /// Gets suggested tasks to work on next based on dependencies and priorities
  Future<List<TaskModel>> getSuggestedNextTasks({int limit = 10}) async {
    final readyTasks = await getReadyTasks();
    
    // Sort by priority and due date
    readyTasks.sort((a, b) {
      // First by priority (higher priority first)
      final priorityComparison = b.priority.sortValue.compareTo(a.priority.sortValue);
      if (priorityComparison != 0) return priorityComparison;
      
      // Then by due date (earlier due date first)
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

    return readyTasks.take(limit).toList();
  }
}

/// Exception thrown when dependency validation fails
class DependencyValidationException implements Exception {
  final String message;
  const DependencyValidationException(this.message);  @override
  String toString() => 'DependencyValidationException: $message';
}

/// Exception thrown when a task is not found
class TaskNotFoundException implements Exception {
  final String message;
  const TaskNotFoundException(this.message);  @override
  String toString() => 'TaskNotFoundException: $message';
}
