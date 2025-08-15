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
    final processedSeries = <String>{};
    
    // Use transaction for creating multiple recurring task instances
    await _database.transaction(() async {
      for (final task in completedTasks) {
        if (task.isRecurring && task.completedAt != null) {
          // Avoid processing the same series multiple times
          final seriesId = task.originalRecurringTaskId ?? task.id;
          if (processedSeries.contains(seriesId)) {
            continue;
          }
          processedSeries.add(seriesId);
          
          // Only generate next instance if this was completed recently
          final completedRecently = task.completedAt != null && 
            DateTime.now().difference(task.completedAt!).inHours < 24;
            
          if (completedRecently) {
            try {
              final nextTask = await generateNextRecurringTask(task);
              if (nextTask != null) {
                await _taskRepository.createTask(nextTask);
                newTasks.add(nextTask);
              }
            } catch (e) {
              // Log error but continue processing other tasks
              print('Error generating next recurring task for ${task.id}: $e');
            }
          }
        }
      }
    });
    
    return newTasks;
  }
  
  /// Generates the next recurring instance of a completed task with proper occurrence tracking
  Future<TaskModel?> generateNextRecurringTask(TaskModel completedTask) async {
    if (!completedTask.isRecurring || completedTask.recurrence == null) {
      return null;
    }
    
    final recurrence = completedTask.recurrence!;
    final baseDate = completedTask.dueDate ?? completedTask.completedAt ?? DateTime.now();
    
    // Get accurate occurrence count for this recurring task series
    final occurrenceCount = await _getAccurateOccurrenceCount(completedTask);
    
    // Check if recurrence has reached its limit
    if (await _hasReachedRecurrenceLimit(completedTask, occurrenceCount)) {
      return null;
    }
    
    final nextDueDate = recurrence.getNextOccurrence(baseDate, occurrenceCount: occurrenceCount);
    if (nextDueDate == null) {
      return null;
    }
    
    // Validate the next due date is reasonable
    if (!_isValidNextDueDate(nextDueDate)) {
      return null;
    }
    
    // Create the next task instance with proper metadata
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
        'original_task_id': completedTask.originalRecurringTaskId ?? completedTask.id,
        'recurrence_instance': DateTime.now().millisecondsSinceEpoch,
        'occurrence_number': occurrenceCount + 1,
        'parent_completed_at': completedTask.completedAt?.toIso8601String(),
      },
      isPinned: false, // Don't pin recurring instances by default
      estimatedDuration: completedTask.estimatedDuration,
    );
    
    return nextTask;
  }
  
  /// Validates that the next due date is reasonable
  bool _isValidNextDueDate(DateTime nextDueDate) {
    final now = DateTime.now();
    final maxFutureDate = now.add(const Duration(days: 365 * 10)); // 10 years max
    
    return nextDueDate.isAfter(now) && nextDueDate.isBefore(maxFutureDate);
  }
  
  /// Gets accurate occurrence count by counting all instances in the series
  Future<int> _getAccurateOccurrenceCount(TaskModel task) async {
    final originalTaskId = task.originalRecurringTaskId ?? task.id;
    
    // Use more efficient query to count occurrences
    final allTasks = await _taskRepository.getAllTasks();
    
    int count = 0;
    for (final t in allTasks) {
      // Count the original task if it's the same
      if (t.id == originalTaskId) {
        count++;
      }
      // Count all instances that reference this original task
      else if (t.metadata['original_task_id'] == originalTaskId) {
        count++;
      }
    }
    
    return count;
  }
  
  /// Calculates the next due date using the recurrence pattern's built-in logic
  DateTime? _calculateNextDueDate(DateTime baseDate, RecurrencePattern recurrence, {int occurrenceCount = 0}) {
    // Use the improved recurrence pattern logic
    return recurrence.getNextOccurrence(baseDate, occurrenceCount: occurrenceCount);
  }
  
  /// Legacy method - now delegates to RecurrencePattern's improved logic
  DateTime _getNextWeeklyDate(DateTime baseDate, RecurrencePattern recurrence) {
    return recurrence.getNextOccurrence(baseDate) ?? baseDate.add(Duration(days: 7));
  }
  
  /// Checks if a recurring task has reached its limit with proper occurrence tracking
  Future<bool> _hasReachedRecurrenceLimit(TaskModel task, [int? knownOccurrenceCount]) async {
    final recurrence = task.recurrence!;
    
    // Check end date
    if (recurrence.endDate != null) {
      final now = DateTime.now();
      if (now.isAfter(recurrence.endDate!)) {
        return true;
      }
      
      // Also check if the next occurrence would be after end date
      final nextDate = recurrence.getNextOccurrence(
        task.dueDate ?? now, 
        occurrenceCount: knownOccurrenceCount ?? 0,
      );
      if (nextDate != null && nextDate.isAfter(recurrence.endDate!)) {
        return true;
      }
    }
    
    // Check max occurrences
    if (recurrence.maxOccurrences != null) {
      final instances = knownOccurrenceCount ?? await _getAccurateOccurrenceCount(task);
      return instances >= recurrence.maxOccurrences!;
    }
    
    return false;
  }
  
  /// Gets comprehensive statistics about a recurring task series
  Future<RecurringTaskStats> getRecurringTaskStats(TaskModel task) async {
    final originalTaskId = task.originalRecurringTaskId ?? task.id;
    final allTasks = await _taskRepository.getAllTasks();
    
    int totalInstances = 0;
    int completedInstances = 0;
    int pendingInstances = 0;
    DateTime? firstCreated;
    DateTime? lastCompleted;
    final List<TaskModel> allInstances = [];
    
    for (final t in allTasks) {
      bool isInstance = false;
      
      // Check if this is the original task or an instance
      if (t.id == originalTaskId || t.metadata['original_task_id'] == originalTaskId) {
        isInstance = true;
      }
      
      if (isInstance) {
        totalInstances++;
        allInstances.add(t);
        
        if (t.isCompleted) {
          completedInstances++;
          if (t.completedAt != null) {
            if (lastCompleted == null || t.completedAt!.isAfter(lastCompleted)) {
              lastCompleted = t.completedAt;
            }
          }
        } else {
          pendingInstances++;
        }
        
        if (firstCreated == null || t.createdAt.isBefore(firstCreated)) {
          firstCreated = t.createdAt;
        }
      }
    }
    
    return RecurringTaskStats(
      totalInstances: totalInstances,
      completedInstances: completedInstances,
      pendingInstances: pendingInstances,
      firstCreated: firstCreated,
      lastCompleted: lastCompleted,
      allInstances: allInstances,
    );
  }
  
  /// Updates the recurrence pattern of a task and handles future instances
  Future<void> updateRecurringTaskPattern(
    TaskModel task, 
    RecurrencePattern newPattern,
    {
      bool updateFutureInstances = true,
      bool regenerateFutureInstances = false,
    }
  ) async {
    if (!newPattern.isValid()) {
      throw ArgumentError('Invalid recurrence pattern provided');
    }
    
    await _database.transaction(() async {
      // Update the current task
      final updatedTask = task.copyWith(recurrence: newPattern);
      await _taskRepository.updateTask(updatedTask);
      
      if (updateFutureInstances) {
        final futureInstances = await getFutureRecurringInstances(task);
        
        if (regenerateFutureInstances) {
          // Delete old instances and generate new ones with the new pattern
          for (final instance in futureInstances) {
            await _taskRepository.deleteTask(instance.id);
          }
          
          // Generate new instances with the updated pattern
          final newInstances = await generateFutureInstances(updatedTask, futureInstances.length);
          for (final newInstance in newInstances) {
            await _taskRepository.createTask(newInstance);
          }
        } else {
          // Just update the pattern on existing instances
          for (final instance in futureInstances) {
            final updatedInstance = instance.copyWith(recurrence: newPattern);
            await _taskRepository.updateTask(updatedInstance);
          }
        }
      }
    });
  }
  
  /// Stops a recurring task series (marks the pattern as none)
  Future<void> stopRecurringTaskSeries(TaskModel task, {bool deleteFutureInstances = true}) async {
    final stoppedPattern = RecurrencePattern(
      type: RecurrenceType.none,
      interval: 1,
    );
    
    await updateRecurringTaskPattern(task, stoppedPattern);
    
    if (deleteFutureInstances) {
      await this.deleteFutureRecurringInstances(task, confirmed: true);
    }
  }
  
  /// Gets all future instances of a recurring task with proper series tracking
  Future<List<TaskModel>> getFutureRecurringInstances(TaskModel task) async {
    final originalTaskId = task.originalRecurringTaskId ?? task.id;
    
    // Use filtering instead of loading all tasks
    final filter = TaskFilter(
      status: null, // Don't filter by status here, we'll filter out completed below
      dueDateFrom: DateTime.now(), // Only get tasks due from now onwards
      searchQuery: null,
      sortBy: TaskSortBy.dueDate,
      sortAscending: true,
    );
    
    final futureTasks = await _taskRepository.getTasksWithFilter(filter);
    
    // Filter for instances of this specific recurring task series
    return futureTasks.where((t) => 
      t.metadata['original_task_id'] == originalTaskId &&
      t.status != TaskStatus.completed &&
      (t.dueDate?.isAfter(DateTime.now()) ?? false)
    ).toList();
  }
  
  /// Deletes all future instances of a recurring task with confirmation
  Future<int> deleteFutureRecurringInstances(TaskModel task, {bool confirmed = false}) async {
    if (!confirmed) {
      throw ArgumentError('Deletion of future instances must be explicitly confirmed');
    }
    
    final futureInstances = await getFutureRecurringInstances(task);
    
    if (futureInstances.isNotEmpty) {
      await _database.transaction(() async {
        for (final instance in futureInstances) {
          await _taskRepository.deleteTask(instance.id);
        }
      });
    }
    
    return futureInstances.length;
  }
  
  /// Generates multiple future instances of a recurring task with proper occurrence tracking
  Future<List<TaskModel>> generateFutureInstances(
    TaskModel task, 
    int count,
  ) async {
    if (!task.isRecurring || task.recurrence == null) {
      return [];
    }
    
    final instances = <TaskModel>[];
    var currentDate = task.dueDate ?? DateTime.now();
    final currentOccurrenceCount = await _getAccurateOccurrenceCount(task);
    
    for (int i = 0; i < count; i++) {
      final nextDate = task.recurrence!.getNextOccurrence(
        currentDate, 
        occurrenceCount: currentOccurrenceCount + i,
      );
      
      if (nextDate == null) break;
      
      // Check if we would exceed recurrence limits
      if (await _hasReachedRecurrenceLimit(task, currentOccurrenceCount + i + 1)) {
        break;
      }
      
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
          'original_task_id': task.originalRecurringTaskId ?? task.id,
          'recurrence_instance': DateTime.now().millisecondsSinceEpoch + i,
          'occurrence_number': currentOccurrenceCount + i + 1,
          'generated_at': DateTime.now().toIso8601String(),
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

/// Statistics for a recurring task series
class RecurringTaskStats {
  final int totalInstances;
  final int completedInstances;
  final int pendingInstances;
  final DateTime? firstCreated;
  final DateTime? lastCompleted;
  final List<TaskModel> allInstances;
  
  const RecurringTaskStats({
    required this.totalInstances,
    required this.completedInstances,
    required this.pendingInstances,
    required this.firstCreated,
    required this.lastCompleted,
    required this.allInstances,
  });
  
  double get completionRate {
    if (totalInstances == 0) return 0.0;
    return completedInstances / totalInstances;
  }
  
  Duration? get averageCompletionTime {
    if (completedInstances == 0 || firstCreated == null || lastCompleted == null) {
      return null;
    }
    
    final totalTime = lastCompleted!.difference(firstCreated!);
    return Duration(milliseconds: totalTime.inMilliseconds ~/ completedInstances);
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
  
  /// Gets the occurrence number of this task in the series
  int get occurrenceNumber => 
    metadata['occurrence_number'] as int? ?? 1;
  
  /// Checks if this task was auto-generated from a recurring pattern
  bool get isAutoGenerated => 
    metadata.containsKey('recurrence_instance');
  
  /// Gets the parent completion timestamp if available
  DateTime? get parentCompletedAt {
    final timestamp = metadata['parent_completed_at'] as String?;
    return timestamp != null ? DateTime.tryParse(timestamp) : null;
  }
}