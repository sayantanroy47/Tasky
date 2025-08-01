import '../domain/entities/task_model.dart';
import '../domain/entities/recurrence_pattern.dart';
import '../domain/entities/task_enums.dart';
import '../domain/repositories/task_repository.dart';

/// Service for managing recurring tasks
/// 
/// This service handles the generation and management of recurring task instances
/// based on recurrence patterns defined in tasks.
class RecurringTaskService {
  final TaskRepository _taskRepository;

  RecurringTaskService(this._taskRepository);

  /// Processes all recurring tasks and generates new instances as needed
  Future<List<TaskModel>> processRecurringTasks() async {
    final allTasks = await _taskRepository.getAllTasks();
    final recurringTasks = allTasks.where((task) => task.isRecurring).toList();
    
    final List<TaskModel> newTasks = [];
    
    for (final task in recurringTasks) {
      final generatedTasks = await _processRecurringTask(task);
      newTasks.addAll(generatedTasks);
    }
    
    return newTasks;
  }

  /// Processes a single recurring task and generates new instances
  Future<List<TaskModel>> _processRecurringTask(TaskModel task) async {
    if (!task.isRecurring || task.recurrence == null) {
      return [];
    }

    final List<TaskModel> newTasks = [];
    
    // Only generate next instance if the current task is completed
    if (task.status == TaskStatus.completed) {
      final nextTask = await _generateNextRecurrence(task);
      if (nextTask != null) {
        newTasks.add(nextTask);
      }
    }
    
    return newTasks;
  }

  /// Generates the next recurring task instance
  Future<TaskModel?> _generateNextRecurrence(TaskModel completedTask) async {
    if (completedTask.recurrence == null) return null;
    
    // Get the occurrence count for this recurring task
    final occurrenceCount = await _getOccurrenceCount(completedTask);
    
    // Calculate next due date
    final baseDate = completedTask.dueDate ?? completedTask.createdAt;
    final nextDueDate = completedTask.recurrence!.getNextOccurrence(
      baseDate,
      occurrenceCount: occurrenceCount,
    );
    
    if (nextDueDate == null) {
      // No more occurrences (reached end date or max occurrences)
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
      recurrence: completedTask.recurrence,
      projectId: completedTask.projectId,
      dependencies: completedTask.dependencies,
      metadata: {
        ...completedTask.metadata,
        'parentRecurringTaskId': completedTask.id,
        'occurrenceNumber': occurrenceCount + 1,
      },
      isPinned: completedTask.isPinned,
      estimatedDuration: completedTask.estimatedDuration,
    );
    
    // Copy subtasks from the original task
    final nextTaskWithSubtasks = nextTask.copyWith(
      subTasks: completedTask.subTasks.map((subTask) => 
        subTask.copyWith(
          id: _generateSubTaskId(),
          taskId: nextTask.id,
          isCompleted: false,
          completedAt: null,
        )
      ).toList(),
    );
    
    return nextTaskWithSubtasks;
  }

  /// Gets the occurrence count for a recurring task
  Future<int> _getOccurrenceCount(TaskModel task) async {
    // Count how many tasks have been generated from this recurring pattern
    final allTasks = await _taskRepository.getAllTasks();
    
    final relatedTasks = allTasks.where((t) => 
      t.metadata['parentRecurringTaskId'] == task.id ||
      t.id == task.id
    ).toList();
    
    return relatedTasks.length;
  }

  /// Generates a unique ID for subtasks
  String _generateSubTaskId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Creates a recurring task with the specified pattern
  Future<TaskModel> createRecurringTask({
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
    final task = TaskModel.create(
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      tags: tags,
      locationTrigger: locationTrigger,
      recurrence: recurrence,
      projectId: projectId,
      dependencies: dependencies,
      metadata: {
        ...metadata,
        'isRecurringParent': true,
        'occurrenceNumber': 1,
      },
      isPinned: isPinned,
      estimatedDuration: estimatedDuration,
    );
    
    await _taskRepository.createTask(task);
    return task;
  }

  /// Updates the recurrence pattern of an existing task
  Future<void> updateRecurrencePattern(
    String taskId,
    RecurrencePattern? newRecurrence,
  ) async {
    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) return;
    
    final updatedTask = task.copyWith(recurrence: newRecurrence);
    await _taskRepository.updateTask(updatedTask);
  }

  /// Stops a recurring task (removes recurrence pattern)
  Future<void> stopRecurringTask(String taskId) async {
    await updateRecurrencePattern(taskId, null);
  }

  /// Gets all recurring tasks
  Future<List<TaskModel>> getRecurringTasks() async {
    final allTasks = await _taskRepository.getAllTasks();
    return allTasks.where((task) => task.isRecurring).toList();
  }

  /// Gets all instances of a recurring task
  Future<List<TaskModel>> getRecurringTaskInstances(String parentTaskId) async {
    final allTasks = await _taskRepository.getAllTasks();
    
    return allTasks.where((task) => 
      task.id == parentTaskId ||
      task.metadata['parentRecurringTaskId'] == parentTaskId
    ).toList();
  }

  /// Completes a recurring task and generates the next instance
  Future<TaskModel?> completeRecurringTask(String taskId) async {
    final task = await _taskRepository.getTaskById(taskId);
    if (task == null || !task.isRecurring) return null;
    
    // Mark the current task as completed
    final completedTask = task.markCompleted();
    await _taskRepository.updateTask(completedTask);
    
    // Generate the next instance
    final nextTask = await _generateNextRecurrence(completedTask);
    if (nextTask != null) {
      await _taskRepository.createTask(nextTask);
    }
    
    return nextTask;
  }

  /// Validates a recurrence pattern
  bool validateRecurrencePattern(RecurrencePattern pattern) {
    return pattern.isValid();
  }

  /// Gets suggested recurrence patterns based on task history
  Future<List<RecurrencePattern>> getSuggestedRecurrencePatterns(
    String taskTitle,
  ) async {
    // This could be enhanced with ML/AI to suggest patterns based on user behavior
    return [
      RecurrencePattern.daily(),
      RecurrencePattern.weekly(),
      RecurrencePattern.weekly(daysOfWeek: const [1, 3, 5]), // Mon, Wed, Fri
      RecurrencePattern.monthly(),
      RecurrencePattern.yearly(),
    ];
  }
}
