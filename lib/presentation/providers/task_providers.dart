import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../domain/repositories/task_repository.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../services/database/database.dart';

/// Provider for the database instance
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Provider for the task repository
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

/// Task operations provider
final taskOperationsProvider = Provider<TaskOperations>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskOperations(repository);
});

/// Task operations class for CRUD operations
class TaskOperations {
  final TaskRepository _repository;
  
  TaskOperations(this._repository);
  
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
    final updatedTask = task.status == TaskStatus.completed
        ? task.resetToPending()
        : task.markCompleted();
    await _repository.updateTask(updatedTask);
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
}
