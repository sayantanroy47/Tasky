import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../domain/entities/recurrence_pattern.dart';
import '../../services/task/recurring_task_service.dart';
import '../../core/providers/core_providers.dart';

/// Provider for RecurringTaskService
final recurringTaskServiceProvider = Provider<RecurringTaskService>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  final database = ref.watch(databaseProvider);
  return RecurringTaskService(taskRepository, database);
});

/// State notifier for managing recurring tasks
class RecurringTaskNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final RecurringTaskService _service;
  final Ref _ref;

  RecurringTaskNotifier(this._service, this._ref) : super(const AsyncValue.loading()) {
    _loadRecurringTasks();
  }

  Future<void> _loadRecurringTasks() async {
    try {
      final taskRepository = _ref.read(taskRepositoryProvider);
      final allTasks = await taskRepository.getAllTasks();
      
      // Filter tasks that have recurring patterns
      final recurringTasks = allTasks.where((task) => task.isRecurring).toList();
      
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
      final taskRepository = _ref.read(taskRepositoryProvider);
      
      // Create the recurring task using TaskModel.create
      final recurringTask = TaskModel.create(
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        tags: tags,
        locationTrigger: locationTrigger,
        recurrence: recurrence,
        projectId: projectId,
        metadata: metadata,
        isPinned: isPinned,
        estimatedDuration: estimatedDuration,
      );
      
      await taskRepository.createTask(recurringTask);
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
      final taskRepository = _ref.read(taskRepositoryProvider);
      final task = await taskRepository.getTaskById(taskId);
      
      if (task != null) {
        if (newRecurrence != null) {
          // Update the recurrence pattern using the service
          await _service.updateRecurringTaskPattern(task, newRecurrence);
        } else {
          // Remove recurrence pattern
          final updatedTask = task.copyWith(recurrence: null);
          await taskRepository.updateTask(updatedTask);
        }
        await _loadRecurringTasks();
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> stopRecurringTask(String taskId) async {
    try {
      final taskRepository = _ref.read(taskRepositoryProvider);
      final task = await taskRepository.getTaskById(taskId);
      
      if (task != null && task.isRecurring) {
        // Stop the recurring task series
        await _service.stopRecurringTaskSeries(task, deleteFutureInstances: true);
        await _loadRecurringTasks();
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<TaskModel?> completeRecurringTask(String taskId) async {
    try {
      final taskRepository = _ref.read(taskRepositoryProvider);
      final task = await taskRepository.getTaskById(taskId);
      
      if (task != null) {
        // Mark the task as completed
        final completedTask = task.copyWith(
          status: TaskStatus.completed,
          completedAt: DateTime.now(),
        );
        await taskRepository.updateTask(completedTask);
        
        // If it's a recurring task, generate the next instance
        if (task.isRecurring) {
          final nextTask = await _service.generateNextRecurringTask(completedTask);
          if (nextTask != null) {
            await taskRepository.createTask(nextTask);
          }
        }
        
        await _loadRecurringTasks();
        return completedTask;
      }
      return null;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  Future<List<TaskModel>> processRecurringTasks() async {
    try {
      final newTasks = await _service.processCompletedRecurringTasks();
      await _loadRecurringTasks();
      return newTasks;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return [];
    }
  }

  Future<List<TaskModel>> getRecurringTaskInstances(String parentTaskId) async {
    try {
      final taskRepository = _ref.read(taskRepositoryProvider);
      final parentTask = await taskRepository.getTaskById(parentTaskId);
      
      if (parentTask != null && parentTask.isRecurring) {
        // Get all instances of this recurring task
        final allTasks = await taskRepository.getAllTasks();
        final instances = allTasks.where((task) {
          // Check if this task is an instance of the parent recurring task
          final originalTaskId = task.metadata['original_task_id'] as String?;
          return originalTaskId == parentTaskId || task.id == parentTaskId;
        }).toList();
        
        // Sort by creation date
        instances.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        return instances;
      }
      return [];
    } catch (error) {
      return [];
    }
  }

  Future<List<RecurrencePattern>> getSuggestedRecurrencePatterns(
    String taskTitle,
  ) async {
    try {
      // Provide common recurrence patterns based on task title keywords
      final suggestions = <RecurrencePattern>[];
      final titleLower = taskTitle.toLowerCase();
      
      // Daily patterns
      if (titleLower.contains('daily') || titleLower.contains('every day')) {
        suggestions.add(const RecurrencePattern(
          type: RecurrenceType.daily,
          interval: 1,
        ));
      }
      
      // Weekly patterns
      if (titleLower.contains('weekly') || titleLower.contains('every week')) {
        suggestions.add(const RecurrencePattern(
          type: RecurrenceType.weekly,
          interval: 1,
          daysOfWeek: [1], // Default to Monday
        ));
      }
      
      // Monthly patterns
      if (titleLower.contains('monthly') || titleLower.contains('every month')) {
        suggestions.add(const RecurrencePattern(
          type: RecurrenceType.monthly,
          interval: 1,
        ));
      }
      
      // Work-related patterns (weekdays only)
      if (titleLower.contains('work') || titleLower.contains('meeting') || titleLower.contains('standup')) {
        suggestions.add(const RecurrencePattern(
          type: RecurrenceType.weekly,
          interval: 1,
          daysOfWeek: [1, 2, 3, 4, 5], // Monday to Friday
        ));
      }
      
      // Default suggestions if no specific patterns found
      if (suggestions.isEmpty) {
        suggestions.addAll([
          const RecurrencePattern(type: RecurrenceType.daily, interval: 1),
          const RecurrencePattern(type: RecurrenceType.weekly, interval: 1, daysOfWeek: [1]),
          const RecurrencePattern(type: RecurrenceType.monthly, interval: 1),
        ]);
      }
      
      return suggestions;
    } catch (error) {
      return [];
    }
  }
}

/// Provider for RecurringTaskNotifier
final recurringTaskNotifierProvider = 
    StateNotifierProvider<RecurringTaskNotifier, AsyncValue<List<TaskModel>>>((ref) {
  final service = ref.watch(recurringTaskServiceProvider);
  return RecurringTaskNotifier(service, ref);
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
