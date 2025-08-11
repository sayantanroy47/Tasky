import '../../domain/entities/task_model.dart';
import '../../domain/entities/recurrence_pattern.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/models/enums.dart';
import '../../services/database/database.dart';

/// Service for managing recurring tasks
/// 
/// This service handles:
/// - Generating next instances of recurring tasks
/// - Managing recurring task completion
/// - Cleaning up old recurring task instances
/// - Handling recurrence pattern modifications
class RecurringTaskService {
  final TaskRepository _taskRepository;
  final AppDatabase _database;
  
  const RecurringTaskService(this._taskRepository, this._database);
  
  /// Processes all completed recurring tasks and generates their next instances
  Future<List<TaskModel>> processCompletedRecurringTasks() async {
    final completedTasks = await _taskRepository.getTasksByStatus(TaskStatus.completed);
    final newTasks = <TaskModel>[];
    
    // Use transaction for creating multiple recurring task instances
    await _database.transaction(() async {
      for (final task in completedTasks) {
        if (task.isRecurring && task.completedAt != null) {
          final nextTask = await generateNextRecurringTask(task);
          if (nextTask != null) {
            await _taskRepository.createTask(nextTask);
            newTasks.add(nextTask);
          }
        }
      }
    });
    
    return newTasks;
  }
  
  /// Generates the next recurring instance of a completed task
  Future<TaskModel?> generateNextRecurringTask(TaskModel completedTask) async {
    if (!completedTask.isRecurring || completedTask.recurrence == null) {
      return null;
    }
    
    final recurrence = completedTask.recurrence!;
    final baseDate = completedTask.dueDate ?? completedTask.completedAt ?? DateTime.now();
    
    // Check if recurrence has reached its limit
    if (await _hasReachedRecurrenceLimit(completedTask)) {
      return null;
    }
    
    final nextDueDate = _calculateNextDueDate(baseDate, recurrence);
    if (nextDueDate == null) {
      return null;
    }
    
    // Create the next task instance
    final nextTask = TaskModel.create(
      title: completedTask.title,
      description: completedTask.description,
      dueDate: nextDueDate,
      priority: completedTask.priority,
      tags: completedTask.tags,
      locationTrigger: completedTask.locationTrigger,
      recurrence: recurrence,
      projectId: completedTask.projectId,
      metadata: {
        ...completedTask.metadata,
        'original_task_id': completedTask.id,
        'recurrence_instance': DateTime.now().millisecondsSinceEpoch,
      },
      isPinned: false, // Don't pin recurring instances by default
      estimatedDuration: completedTask.estimatedDuration,
    );
    
    return nextTask;
  }
  
  /// Calculates the next due date based on recurrence pattern
  DateTime? _calculateNextDueDate(DateTime baseDate, RecurrencePattern recurrence) {
    switch (recurrence.type) {
      case RecurrenceType.none:
        return null;
        
      case RecurrenceType.daily:
        return baseDate.add(Duration(days: recurrence.interval));
        
      case RecurrenceType.weekly:
        if (recurrence.daysOfWeek != null && recurrence.daysOfWeek!.isNotEmpty) {
          return _getNextWeeklyDate(baseDate, recurrence);
        } else {
          return baseDate.add(Duration(days: 7 * recurrence.interval));
        }
        
      case RecurrenceType.monthly:
        return DateTime(
          baseDate.year,
          baseDate.month + recurrence.interval,
          baseDate.day,
          baseDate.hour,
          baseDate.minute,
        );
        
      case RecurrenceType.yearly:
        return DateTime(
          baseDate.year + recurrence.interval,
          baseDate.month,
          baseDate.day,
          baseDate.hour,
          baseDate.minute,
        );
        
      case RecurrenceType.custom:
        // For custom recurrence, use weekly as fallback
        return baseDate.add(Duration(days: 7 * recurrence.interval));
    }
  }
  
  /// Calculates next weekly recurrence date based on specified days of week
  DateTime _getNextWeeklyDate(DateTime baseDate, RecurrencePattern recurrence) {
    final daysOfWeek = recurrence.daysOfWeek!;
    final currentWeekday = baseDate.weekday; // Monday = 1, Sunday = 7
    
    // Find the next occurrence in the current week
    for (int day in daysOfWeek) {
      if (day > currentWeekday) {
        final daysToAdd = day - currentWeekday;
        return baseDate.add(Duration(days: daysToAdd));
      }
    }
    
    // No more occurrences this week, find first occurrence in next interval
    final firstDayOfWeek = daysOfWeek.first;
    final daysUntilNextWeek = (7 - currentWeekday) + firstDayOfWeek;
    final weeksToAdd = (recurrence.interval - 1) * 7;
    
    return baseDate.add(Duration(days: daysUntilNextWeek + weeksToAdd));
  }
  
  /// Checks if a recurring task has reached its limit
  Future<bool> _hasReachedRecurrenceLimit(TaskModel task) async {
    final recurrence = task.recurrence!;
    
    // Check end date
    if (recurrence.endDate != null && 
        DateTime.now().isAfter(recurrence.endDate!)) {
      return true;
    }
    
    // Check max occurrences
    if (recurrence.maxOccurrences != null) {
      final instances = await _countRecurringTaskInstances(task);
      return instances >= recurrence.maxOccurrences!;
    }
    
    return false;
  }
  
  /// Counts how many instances of a recurring task have been created
  Future<int> _countRecurringTaskInstances(TaskModel originalTask) async {
    // Use optimized search to find instances instead of loading all tasks
    final instances = await _taskRepository.searchTasks(originalTask.title);
    
    int count = 0;
    for (final task in instances) {
      // Count tasks with same title and recurrence pattern
      if (task.title == originalTask.title && 
          task.recurrence?.type == originalTask.recurrence?.type) {
        count++;
      }
      
      // Also count tasks that reference this as original
      if (task.metadata['original_task_id'] == originalTask.id) {
        count++;
      }
    }
    
    return count;
  }
  
  /// Updates the recurrence pattern of a task and all future instances
  Future<void> updateRecurringTaskPattern(
    TaskModel task, 
    RecurrencePattern newPattern,
    {bool updateFutureInstances = true}
  ) async {
    await _database.transaction(() async {
      // Update the current task
      final updatedTask = task.copyWith(recurrence: newPattern);
      await _taskRepository.updateTask(updatedTask);
      
      if (updateFutureInstances) {
        // Find and update future instances more efficiently
        final futureInstances = await getFutureRecurringInstances(task);
        
        for (final instance in futureInstances) {
          final updatedInstance = instance.copyWith(recurrence: newPattern);
          await _taskRepository.updateTask(updatedInstance);
        }
      }
    });
  }
  
  /// Stops a recurring task series (marks the pattern as none)
  Future<void> stopRecurringTaskSeries(TaskModel task) async {
    final stoppedPattern = RecurrencePattern(
      type: RecurrenceType.none,
      interval: 1,
    );
    
    await updateRecurringTaskPattern(task, stoppedPattern);
  }
  
  /// Gets all future instances of a recurring task
  Future<List<TaskModel>> getFutureRecurringInstances(TaskModel task) async {
    // Use filtering instead of loading all tasks
    final filter = TaskFilter(
      status: null, // Don't filter by status here, we'll filter out completed below
      dueDateFrom: DateTime.now(), // Only get tasks due from now onwards
      searchQuery: null,
      sortBy: TaskSortBy.dueDate,
      sortAscending: true,
    );
    
    final futureTasks = await _taskRepository.getTasksWithFilter(filter);
    
    // Filter for instances of this specific recurring task
    return futureTasks.where((t) => 
      t.metadata['original_task_id'] == task.id &&
      t.status != TaskStatus.completed
    ).toList();
  }
  
  /// Deletes all future instances of a recurring task
  Future<void> deleteFutureRecurringInstances(TaskModel task) async {
    final futureInstances = await getFutureRecurringInstances(task);
    
    if (futureInstances.isNotEmpty) {
      await _database.transaction(() async {
        for (final instance in futureInstances) {
          await _taskRepository.deleteTask(instance.id);
        }
      });
    }
  }
  
  /// Generates multiple future instances of a recurring task
  Future<List<TaskModel>> generateFutureInstances(
    TaskModel task, 
    int count,
  ) async {
    if (!task.isRecurring || task.recurrence == null) {
      return [];
    }
    
    final instances = <TaskModel>[];
    var currentDate = task.dueDate ?? DateTime.now();
    
    for (int i = 0; i < count; i++) {
      final nextDate = _calculateNextDueDate(currentDate, task.recurrence!);
      if (nextDate == null) break;
      
      final nextTask = TaskModel.create(
        title: task.title,
        description: task.description,
        dueDate: nextDate,
        priority: task.priority,
        tags: task.tags,
        locationTrigger: task.locationTrigger,
        recurrence: task.recurrence,
        projectId: task.projectId,
        metadata: {
          ...task.metadata,
          'original_task_id': task.id,
          'recurrence_instance': DateTime.now().millisecondsSinceEpoch + i,
        },
        isPinned: false,
        estimatedDuration: task.estimatedDuration,
      );
      
      instances.add(nextTask);
      currentDate = nextDate;
    }
    
    return instances;
  }
  
  /// Creates multiple future instances in a single transaction
  Future<List<TaskModel>> createFutureInstances(
    TaskModel task, 
    int count,
  ) async {
    final instances = await generateFutureInstances(task, count);
    
    if (instances.isNotEmpty) {
      await _database.transaction(() async {
        for (final instance in instances) {
          await _taskRepository.createTask(instance);
        }
      });
    }
    
    return instances;
  }
}

/// Extension to provide recurring task utilities
extension RecurringTaskExtensions on TaskModel {
  /// Checks if this task is part of a recurring series
  bool get isPartOfRecurringSeries => 
    metadata.containsKey('original_task_id') || isRecurring;
  
  /// Gets the original task ID if this is a recurring instance
  String? get originalRecurringTaskId => 
    metadata['original_task_id'] as String?;
  
  /// Checks if this is the original recurring task (not an instance)
  bool get isOriginalRecurringTask => 
    isRecurring && !metadata.containsKey('original_task_id');
}