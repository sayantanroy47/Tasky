import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../domain/repositories/task_repository.dart';
import '../../services/task/recurring_task_service.dart';
import '../../services/dependency_service.dart';
import '../../services/task/enhanced_task_operations.dart';
import '../../core/providers/core_providers.dart';
import 'task_providers.dart';
import 'dependency_providers.dart';
import 'notification_providers.dart';

// All basic task providers moved to task_providers.dart to avoid duplicates
// This file now only contains specialized operations providers

/// Recurring task service provider (removed duplicate - using one from task_providers.dart)
// Duplicate removed to avoid conflicts

/// Task dependency service provider (using the one from dependency_providers.dart)
// Duplicate removed to avoid conflicts

/// Notification service provider (using the one from notification_providers.dart)
// Duplicate removed to avoid conflicts

/// Enhanced task operations provider with comprehensive error handling and undo
final taskOperationsProvider = Provider<EnhancedTaskOperations>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  // Import services from their respective provider files to avoid duplicates
  final recurringService = ref.watch(recurringTaskServiceProvider);
  final dependencyService = ref.watch(dependencyServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return EnhancedTaskOperations(repository, recurringService, dependencyService, notificationService);
});

/// Legacy task operations provider for backward compatibility
final legacyTaskOperationsProvider = Provider<TaskOperations>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  final recurringService = ref.watch(recurringTaskServiceProvider);
  final dependencyService = ref.watch(dependencyServiceProvider);
  return TaskOperations(repository, recurringService, dependencyService);
});

/// Task operations class for CRUD operations
class TaskOperations {
  final TaskRepository _repository;
  final RecurringTaskService _recurringService;
  final DependencyService _dependencyService;
  
  TaskOperations(this._repository, this._recurringService, this._dependencyService);
  
  Future<void> createTask(TaskModel task) async {
    await _repository.createTask(task);
  }
  
  Future<void> updateTask(TaskModel task) async {
    await _repository.updateTask(task);
  }
  
  Future<void> deleteTask(String id) async {
    await _repository.deleteTask(id);
  }
  
  Future<void> toggleTaskCompletion(TaskModel task) async {
    if (task.status != TaskStatus.completed) {
      // Validate dependencies before marking as completed
      final validation = await _dependencyService.validateTaskCompletion(task);
      if (!validation.isValid) {
        throw Exception(validation.errorMessage ?? 'Task dependencies not completed');
      }
    }
    
    final updatedTask = task.status == TaskStatus.completed
        ? task.resetToPending()
        : task.markCompleted();
    await _repository.updateTask(updatedTask);
    
    // If the task was completed
    if (updatedTask.status == TaskStatus.completed) {
      // Handle dependent tasks
      await _dependencyService.onTaskCompleted(updatedTask);
      
      // If recurring, generate next instance
      if (task.isRecurring) {
        final nextTask = await _recurringService.generateNextRecurringTask(updatedTask);
        if (nextTask != null) {
          await _repository.createTask(nextTask);
        }
      }
    }
  }
  
  Future<void> markTaskInProgress(TaskModel task) async {
    final updatedTask = task.markInProgress();
    await _repository.updateTask(updatedTask);
  }
  
  Future<void> cancelTask(TaskModel task) async {
    final updatedTask = task.markCancelled();
    await _repository.updateTask(updatedTask);
  }
  
  Future<void> pinTask(TaskModel task) async {
    final updatedTask = task.togglePin();
    await _repository.updateTask(updatedTask);
  }
  
  /// Processes all completed recurring tasks and generates next instances
  Future<List<TaskModel>> processRecurringTasks() async {
    return await _recurringService.processCompletedRecurringTasks();
  }
  
  /// Stops a recurring task series
  Future<void> stopRecurringTask(TaskModel task) async {
    await _recurringService.stopRecurringTaskSeries(task);
  }
  
  /// Gets future instances of a recurring task
  Future<List<TaskModel>> getFutureRecurringInstances(TaskModel task) async {
    return await _recurringService.getFutureRecurringInstances(task);
  }
  
  /// Deletes all future recurring instances
  Future<void> deleteFutureRecurringInstances(TaskModel task) async {
    await _recurringService.deleteFutureRecurringInstances(task);
  }
  
  /// Adds a dependency between two tasks
  Future<void> addTaskDependency(String dependentTaskId, String prerequisiteTaskId) async {
    final result = await _dependencyService.addDependency(dependentTaskId, prerequisiteTaskId);
    if (!result.isSuccess) {
      throw Exception(result.errorMessage ?? 'Failed to add dependency');
    }
  }
  
  /// Removes a dependency between two tasks
  Future<void> removeTaskDependency(String dependentTaskId, String prerequisiteTaskId) async {
    final result = await _dependencyService.removeDependency(dependentTaskId, prerequisiteTaskId);
    if (!result.isSuccess) {
      throw Exception(result.errorMessage ?? 'Failed to remove dependency');
    }
  }
  
  /// Gets tasks that are ready to be worked on
  Future<List<TaskModel>> getReadyTasks() async {
    return await _dependencyService.getReadyTasks();
  }
  
  /// Gets tasks that are blocked by dependencies
  Future<List<TaskModel>> getBlockedTasks() async {
    return await _dependencyService.getBlockedTasks();
  }
}