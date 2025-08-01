import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/task_enums.dart';
import '../../domain/entities/recurrence_pattern.dart';
import '../../services/recurring_task_service.dart';
import 'task_providers.dart';

/// Provider for RecurringTaskService
final recurringTaskServiceProvider = Provider<RecurringTaskService>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return RecurringTaskService(taskRepository);
});

/// State notifier for managing recurring tasks
class RecurringTaskNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final RecurringTaskService _service;

  RecurringTaskNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadRecurringTasks();
  }

  Future<void> _loadRecurringTasks() async {
    try {
      final recurringTasks = await _service.getRecurringTasks();
      state = AsyncValue.data(recurringTasks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createRecurringTask({
    required String title,
    String? description,
    DateTime? dueDate,
    required RecurrencePattern recurrence,
    TaskPriority priority = TaskPriority.medium,
    List<String> tags = const [],
    String? locationTrigger,
    String? projectId,
    List<String> dependencies = const [],
    Map<String, dynamic> metadata = const {},
    bool isPinned = false,
    int? estimatedDuration,
  }) async {
    try {
      await _service.createRecurringTask(
        title: title,
        description: description,
        dueDate: dueDate,
        recurrence: recurrence,
        priority: priority,
        tags: tags,
        locationTrigger: locationTrigger,
        projectId: projectId,
        dependencies: dependencies,
        metadata: metadata,
        isPinned: isPinned,
        estimatedDuration: estimatedDuration,
      );
      await _loadRecurringTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateRecurrencePattern(
    String taskId,
    RecurrencePattern? newRecurrence,
  ) async {
    try {
      await _service.updateRecurrencePattern(taskId, newRecurrence);
      await _loadRecurringTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> stopRecurringTask(String taskId) async {
    try {
      await _service.stopRecurringTask(taskId);
      await _loadRecurringTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<TaskModel?> completeRecurringTask(String taskId) async {
    try {
      final nextTask = await _service.completeRecurringTask(taskId);
      await _loadRecurringTasks();
      return nextTask;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  Future<List<TaskModel>> processRecurringTasks() async {
    try {
      final newTasks = await _service.processRecurringTasks();
      await _loadRecurringTasks();
      return newTasks;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return [];
    }
  }

  Future<List<TaskModel>> getRecurringTaskInstances(String parentTaskId) async {
    try {
      return await _service.getRecurringTaskInstances(parentTaskId);
    } catch (error) {
      return [];
    }
  }

  Future<List<RecurrencePattern>> getSuggestedRecurrencePatterns(
    String taskTitle,
  ) async {
    try {
      return await _service.getSuggestedRecurrencePatterns(taskTitle);
    } catch (error) {
      return [];
    }
  }
}

/// Provider for RecurringTaskNotifier
final recurringTaskNotifierProvider = 
    StateNotifierProvider<RecurringTaskNotifier, AsyncValue<List<TaskModel>>>((ref) {
  final service = ref.watch(recurringTaskServiceProvider);
  return RecurringTaskNotifier(service);
});

/// Provider for all recurring tasks
final recurringTasksProvider = Provider<AsyncValue<List<TaskModel>>>((ref) {
  return ref.watch(recurringTaskNotifierProvider);
});

/// Provider for active recurring tasks (not completed)
final activeRecurringTasksProvider = Provider<AsyncValue<List<TaskModel>>>((ref) {
  final recurringTasksAsync = ref.watch(recurringTasksProvider);
  return recurringTasksAsync.when(
    data: (tasks) {
      final activeTasks = tasks.where((task) => task.status.isActive).toList();
      return AsyncValue.data(activeTasks);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider for completed recurring tasks
final completedRecurringTasksProvider = Provider<AsyncValue<List<TaskModel>>>((ref) {
  final recurringTasksAsync = ref.watch(recurringTasksProvider);
  return recurringTasksAsync.when(
    data: (tasks) {
      final completedTasks = tasks.where((task) => task.status.isCompleted).toList();
      return AsyncValue.data(completedTasks);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider for recurring task instances by parent ID
final recurringTaskInstancesProvider = 
    FutureProvider.family<List<TaskModel>, String>((ref, parentTaskId) async {
  return await ref.read(recurringTaskNotifierProvider.notifier)
      .getRecurringTaskInstances(parentTaskId);
});

/// Provider for suggested recurrence patterns
final suggestedRecurrencePatternsProvider = 
    FutureProvider.family<List<RecurrencePattern>, String>((ref, taskTitle) async {
  return await ref.read(recurringTaskNotifierProvider.notifier)
      .getSuggestedRecurrencePatterns(taskTitle);
});
