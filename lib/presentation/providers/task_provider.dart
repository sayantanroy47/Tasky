import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../domain/repositories/task_repository.dart';

/// Provider for task repository
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  throw UnimplementedError('TaskRepository provider not implemented');
});

/// Provider for all tasks
final tasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getAllTasks();
});

/// Provider for tasks by status
final tasksByStatusProvider = FutureProvider.family<List<TaskModel>, TaskStatus>((ref, status) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getTasksByStatus(status);
});

/// Provider for tasks by priority
final tasksByPriorityProvider = FutureProvider.family<List<TaskModel>, TaskPriority>((ref, priority) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getTasksByPriority(priority);
});

/// Provider for pending tasks
final pendingTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getTasksByStatus(TaskStatus.pending);
});

/// Provider for completed tasks
final completedTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getTasksByStatus(TaskStatus.completed);
});

/// Provider for overdue tasks
final overdueTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getOverdueTasks();
});

/// Provider for today's tasks
final todayTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  return repository.getTasksByDateRange(today, tomorrow);
});

/// Provider for task search
final taskSearchProvider = FutureProvider.family<List<TaskModel>, String>((ref, query) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.searchTasks(query);
});

/// State notifier for managing task operations
class TaskNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  TaskNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadTasks();
  }

  final TaskRepository _repository;

  Future<void> _loadTasks() async {
    try {
      final tasks = await _repository.getAllTasks();
      state = AsyncValue.data(tasks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addTask(TaskModel task) async {
    try {
      await _repository.createTask(task);
      await _loadTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _repository.updateTask(task);
      await _loadTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _repository.deleteTask(taskId);
      await _loadTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleTaskStatus(String taskId) async {
    try {
      final task = await _repository.getTaskById(taskId);
      if (task != null) {
        final newStatus = task.status == TaskStatus.completed 
            ? TaskStatus.pending 
            : TaskStatus.completed;
        final updatedTask = task.copyWith(status: newStatus);
        await _repository.updateTask(updatedTask);
        await _loadTasks();
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void refresh() {
    _loadTasks();
  }
}

/// Provider for task notifier
final taskNotifierProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<TaskModel>>>((ref) {
  final repository = ref.read(taskRepositoryProvider);
  return TaskNotifier(repository);
});