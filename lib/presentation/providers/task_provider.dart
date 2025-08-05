import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../domain/repositories/task_repository.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../services/database/database.dart';
import '../../services/task/recurring_task_service.dart';
import '../../services/task/task_dependency_service.dart';
import '../../services/notification/notification_service.dart';
import '../../services/notification/local_notification_service.dart';

/// Singleton database provider to prevent multiple instances
final databaseProvider = Provider<AppDatabase>((ref) {
  // Keep alive to ensure singleton behavior
  ref.keepAlive();
  
  final database = AppDatabase();
  
  // Proper cleanup on disposal
  ref.onDispose(() async {
    await database.close();
  });
  
  return database;
});

/// Provider for task repository
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return TaskRepositoryImpl(database);
});

/// Provider for all tasks
final tasksProvider = StreamProvider<List<TaskModel>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchAllTasks();
});

/// Provider for pending tasks
final pendingTasksProvider = StreamProvider<List<TaskModel>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchTasksByStatus(TaskStatus.pending);
});

/// Provider for completed tasks
final completedTasksProvider = StreamProvider<List<TaskModel>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchTasksByStatus(TaskStatus.completed);
});

/// Provider for today's tasks
final todayTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTasksDueToday();
});

/// Provider for overdue tasks
final overdueTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getOverdueTasks();
});

/// Provider for task filter state
final taskFilterProvider = StateProvider<TaskFilter>((ref) {
  return const TaskFilter();
});

/// Provider for filtered tasks
final filteredTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  final filter = ref.watch(taskFilterProvider);
  
  if (!filter.hasFilters) {
    return repository.getAllTasks();
  }
  
  return repository.getTasksWithFilter(filter);
});

/// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for searched tasks
final searchedTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  final query = ref.watch(searchQueryProvider);
  
  if (query.isEmpty) {
    return repository.getAllTasks();
  }
  
  return repository.searchTasks(query);
});

/// Recurring task service provider
final recurringTaskServiceProvider = Provider<RecurringTaskService>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return RecurringTaskService(repository);
});

/// Task dependency service provider
final taskDependencyServiceProvider = Provider<TaskDependencyService>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskDependencyService(repository);
});

/// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return LocalNotificationService(repository);
});

/// Task operations provider
final taskOperationsProvider = Provider<TaskOperations>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  final recurringService = ref.watch(recurringTaskServiceProvider);
  final dependencyService = ref.watch(taskDependencyServiceProvider);
  return TaskOperations(repository, recurringService, dependencyService);
});

/// Task operations class for CRUD operations
class TaskOperations {
  final TaskRepository _repository;
  final RecurringTaskService _recurringService;
  final TaskDependencyService _dependencyService;
  
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