import '../entities/task_model.dart';
import '../entities/subtask.dart';
import '../repositories/task_repository.dart';
import '../../core/errors/app_exceptions.dart';

/// Custom exceptions for use cases
class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
  @override
  String toString() => 'ValidationException: $message';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);
  @override
  String toString() => 'NotFoundException: $message';
}

/// Use cases for task management operations
/// 
/// This class encapsulates the business logic for task operations,
/// ensuring that all business rules are enforced consistently.
class TaskUseCases {
  final TaskRepository _taskRepository;

  const TaskUseCases(this._taskRepository);

  /// Creates a new task with validation
  Future<TaskModel> createTask({
    required String title,
    String? description,
    DateTime? dueDate,
    String? projectId,
    List<String> tags = const [],
  }) async {
    // Validate input
    if (title.trim().isEmpty) {
      throw ValidationException('Task title cannot be empty');
    }

    // Create task
    final task = TaskModel.create(
      title: title.trim(),
      description: description?.trim(),
      dueDate: dueDate,
      projectId: projectId,
      tags: tags,
    );

    // Validate task
    if (!task.isValid()) {
      throw ValidationException('Invalid task data');
    }

    // Save to repository
    await _taskRepository.createTask(task);
    return task;
  }

  /// Updates an existing task
  Future<TaskModel> updateTask(TaskModel task) async {
    // Validate task
    if (!task.isValid()) {
      throw ValidationException('Invalid task data');
    }

    // Check if task exists
    final existingTask = await _taskRepository.getTaskById(task.id);
    if (existingTask == null) {
      throw NotFoundException('Task not found');
    }

    // Update with current timestamp
    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    
    await _taskRepository.updateTask(updatedTask);
    return updatedTask;
  }

  /// Completes a task and handles recurring tasks
  Future<TaskModel> completeTask(String taskId) async {
    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      throw NotFoundException('Task not found');
    }

    if (task.isCompleted) {
      throw ValidationException('Task is already completed');
    }

    // Check if all dependencies are completed
    if (task.hasDependencies) {
      final dependencies = await _taskRepository.getTasksByIds(task.dependencies);
      final incompleteDependencies = dependencies.where((t) => !t.isCompleted).toList();
      
      if (incompleteDependencies.isNotEmpty) {
        throw ValidationException(
          'Cannot complete task: ${incompleteDependencies.length} dependencies are not completed'
        );
      }
    }

    // Mark task as completed
    final completedTask = task.markCompleted();
    await _taskRepository.updateTask(completedTask);

    // Handle recurring tasks
    if (task.isRecurring) {
      final nextTask = task.generateNextRecurrence();
      if (nextTask != null) {
        await _taskRepository.createTask(nextTask);
      }
    }

    return completedTask;
  }

  /// Deletes a task and handles dependencies
  Future<void> deleteTask(String taskId) async {
    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      throw NotFoundException('Task not found');
    }

    // Check if other tasks depend on this task
    final dependentTasks = await _taskRepository.getTasksWithDependency(taskId);
    if (dependentTasks.isNotEmpty) {
      throw ValidationException(
        'Cannot delete task: ${dependentTasks.length} tasks depend on it'
      );
    }

    await _taskRepository.deleteTask(taskId);
  }

  /// Gets tasks with smart filtering
  Future<List<TaskModel>> getTasks({
    String? projectId,
    List<String>? tags,
    DateTime? dueBefore,
    DateTime? dueAfter,
    bool? isCompleted,
    bool? isOverdue,
    String? searchQuery,
  }) async {
    List<TaskModel> tasks = await _taskRepository.getAllTasks();

    // Apply filters
    if (projectId != null) {
      tasks = tasks.where((t) => t.projectId == projectId).toList();
    }

    if (tags != null && tags.isNotEmpty) {
      tasks = tasks.where((t) => tags.any((tag) => t.tags.contains(tag))).toList();
    }

    if (dueBefore != null) {
      tasks = tasks.where((t) => t.dueDate != null && t.dueDate!.isBefore(dueBefore)).toList();
    }

    if (dueAfter != null) {
      tasks = tasks.where((t) => t.dueDate != null && t.dueDate!.isAfter(dueAfter)).toList();
    }

    if (isCompleted != null) {
      tasks = tasks.where((t) => t.isCompleted == isCompleted).toList();
    }

    if (isOverdue == true) {
      tasks = tasks.where((t) => t.isOverdue).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      tasks = tasks.where((t) => 
        t.title.toLowerCase().contains(query) ||
        (t.description?.toLowerCase().contains(query) ?? false) ||
        t.tags.any((tag) => tag.toLowerCase().contains(query))
      ).toList();
    }

    return tasks;
  }

  /// Gets today's tasks
  Future<List<TaskModel>> getTodayTasks() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return getTasks(
      dueAfter: today.subtract(const Duration(microseconds: 1)),
      dueBefore: tomorrow,
      isCompleted: false,
    );
  }

  /// Gets overdue tasks
  Future<List<TaskModel>> getOverdueTasks() async {
    return getTasks(isOverdue: true);
  }

  /// Gets upcoming tasks (due within next 7 days)
  Future<List<TaskModel>> getUpcomingTasks() async {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return getTasks(
      dueAfter: now,
      dueBefore: nextWeek,
      isCompleted: false,
    );
  }

  /// Adds a subtask to a task
  Future<TaskModel> addSubTask(String taskId, String subTaskTitle) async {
    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      throw NotFoundException('Task not found');
    }

    if (subTaskTitle.trim().isEmpty) {
      throw ValidationException('Subtask title cannot be empty');
    }

    final subTask = SubTask.create(
      taskId: taskId,
      title: subTaskTitle.trim(),
      sortOrder: task.subTasks.length,
    );

    final updatedTask = task.addSubTask(subTask);
    await _taskRepository.updateTask(updatedTask);
    
    return updatedTask;
  }

  /// Toggles subtask completion
  Future<TaskModel> toggleSubTask(String taskId, String subTaskId) async {
    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      throw NotFoundException('Task not found');
    }

    final subTaskIndex = task.subTasks.indexWhere((st) => st.id == subTaskId);
    if (subTaskIndex == -1) {
      throw NotFoundException('Subtask not found');
    }

    final subTask = task.subTasks[subTaskIndex];
    final updatedSubTask = subTask.isCompleted 
        ? subTask.markIncomplete() 
        : subTask.markCompleted();

    final updatedTask = task.updateSubTask(updatedSubTask);
    await _taskRepository.updateTask(updatedTask);
    
    return updatedTask;
  }

  /// Validates task dependencies to prevent circular dependencies
  Future<bool> validateDependencies(String taskId, List<String> dependencyIds) async {
    // Check for self-dependency
    if (dependencyIds.contains(taskId)) {
      return false;
    }

    // Check for circular dependencies using DFS
    final visited = <String>{};
    final recursionStack = <String>{};

    bool hasCycle(String currentTaskId) {
      if (recursionStack.contains(currentTaskId)) {
        return true; // Cycle detected
      }
      
      if (visited.contains(currentTaskId)) {
        return false; // Already processed
      }

      visited.add(currentTaskId);
      recursionStack.add(currentTaskId);

      // Get dependencies for current task
      final taskDependencies = dependencyIds.contains(currentTaskId) 
          ? dependencyIds 
          : [];

      for (final depId in taskDependencies) {
        if (hasCycle(depId)) {
          return true;
        }
      }

      recursionStack.remove(currentTaskId);
      return false;
    }

    return !hasCycle(taskId);
  }
}