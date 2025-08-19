import 'dart:math' as math;
import 'package:uuid/uuid.dart';
import '../entities/task_model.dart';
import '../entities/subtask.dart';
import '../entities/task_enums.dart';
import '../repositories/task_repository.dart';


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

/// Result of dependency validation
class DependencyValidationResult {
  final bool isValid;
  final String? message;
  final bool isWarning;
  
  const DependencyValidationResult._(
    this.isValid, 
    this.message, 
    this.isWarning,
  );
  
  factory DependencyValidationResult.valid() => 
    const DependencyValidationResult._(true, null, false);
  
  factory DependencyValidationResult.invalid(String message) => 
    DependencyValidationResult._(false, message, false);
  
  factory DependencyValidationResult.warning(String message) => 
    DependencyValidationResult._(true, message, true);
}

/// Result of circular dependency detection
class CircularDependencyResult {
  final bool hasCycle;
  final List<String> cyclePath;
  
  const CircularDependencyResult._(this.hasCycle, this.cyclePath);
  
  factory CircularDependencyResult.noCycle() => 
    const CircularDependencyResult._(false, []);
  
  factory CircularDependencyResult.withCycle(List<String> path) => 
    CircularDependencyResult._(true, List.from(path));
}

/// Result of task completion
class TaskCompletionResult {
  final TaskModel completedTask;
  final TaskModel? nextRecurringTask;
  final List<TaskModel> dependentTasksEnabled;
  final int autoCompletedSubtasks;
  
  const TaskCompletionResult({
    required this.completedTask,
    this.nextRecurringTask,
    required this.dependentTasksEnabled,
    required this.autoCompletedSubtasks,
  });
}

/// Result of subtask toggle operation
class SubtaskToggleResult {
  final TaskModel task;
  final SubTask toggledSubtask;
  final bool parentTaskCompleted;
  final bool parentTaskReopened;
  final bool wasSubtaskCompleted;
  
  const SubtaskToggleResult({
    required this.task,
    required this.toggledSubtask,
    required this.parentTaskCompleted,
    required this.parentTaskReopened,
    required this.wasSubtaskCompleted,
  });
  
  bool get statusChanged => parentTaskCompleted || parentTaskReopened;
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
      throw const ValidationException('Task title cannot be empty');
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
      throw const ValidationException('Invalid task data');
    }

    // Save to repository
    await _taskRepository.createTask(task);
    return task;
  }

  /// Updates an existing task
  Future<TaskModel> updateTask(TaskModel task) async {
    // Validate task
    if (!task.isValid()) {
      throw const ValidationException('Invalid task data');
    }

    // Check if task exists
    final existingTask = await _taskRepository.getTaskById(task.id);
    if (existingTask == null) {
      throw const NotFoundException('Task not found');
    }

    // Update with current timestamp
    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    
    await _taskRepository.updateTask(updatedTask);
    return updatedTask;
  }

  /// Completes a task and handles subtasks, dependencies, and recurring tasks
  Future<TaskCompletionResult> completeTask(String taskId, {bool autoCompleteSubtasks = true}) async {
    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      throw const NotFoundException('Task not found');
    }

    if (task.isCompleted) {
      throw const ValidationException('Task is already completed');
    }

    // Check if all subtasks are completed (if auto-completion is disabled)
    if (!autoCompleteSubtasks && task.subTasks.isNotEmpty) {
      final incompleteSubtasks = task.subTasks.where((st) => !st.isCompleted).toList();
      if (incompleteSubtasks.isNotEmpty) {
        throw ValidationException(
          'Cannot complete task: ${incompleteSubtasks.length} subtasks are not completed'
        );
      }
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

    // Auto-complete remaining subtasks if enabled
    TaskModel taskToComplete = task;
    if (autoCompleteSubtasks && task.subTasks.isNotEmpty) {
      final updatedSubtasks = task.subTasks.map((subtask) => 
        subtask.isCompleted ? subtask : subtask.markCompleted()
      ).toList();
      
      taskToComplete = task.copyWith(subTasks: updatedSubtasks);
    }

    // Mark task as completed
    final completedTask = taskToComplete.markCompleted();
    await _taskRepository.updateTask(completedTask);

    // Handle recurring tasks using RecurringTaskService
    TaskModel? nextRecurringTask;
    if (task.isRecurring && task.recurrence != null) {
      try {
        // Note: RecurringTaskService requires database instance which isn't available here
        // For now, use manual generation until proper dependency injection is set up
        final nextOccurrence = task.recurrence!.getNextOccurrence(DateTime.now());
        if (nextOccurrence != null) {
          nextRecurringTask = task.copyWith(
            id: const Uuid().v4(), // Generate new ID
            dueDate: nextOccurrence,
            status: TaskStatus.pending,
            completedAt: null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _taskRepository.createTask(nextRecurringTask);
        }
      } catch (e) {
        // Log error but don't fail the completion
        // In a production app, this would be logged to a proper logging service
      }
    }
    
    // Check if completing this task enables completion of dependent tasks
    final dependentTasksEnabled = await _checkDependentTasksEnabled(taskId);

    return TaskCompletionResult(
      completedTask: completedTask,
      nextRecurringTask: nextRecurringTask,
      dependentTasksEnabled: dependentTasksEnabled,
      autoCompletedSubtasks: autoCompleteSubtasks ? 
        taskToComplete.subTasks.where((st) => !task.subTasks.any((original) => original.id == st.id && original.isCompleted)).length : 0,
    );
  }
  
  /// Checks which dependent tasks can now be completed
  Future<List<TaskModel>> _checkDependentTasksEnabled(String completedTaskId) async {
    final allTasks = await _taskRepository.getAllTasks();
    final enabledTasks = <TaskModel>[];
    
    for (final task in allTasks) {
      if (task.dependencies.contains(completedTaskId) && !task.isCompleted) {
        // Check if all other dependencies are also completed
        final otherDependencies = task.dependencies.where((id) => id != completedTaskId).toList();
        if (otherDependencies.isNotEmpty) {
          final otherDepTasks = await _taskRepository.getTasksByIds(otherDependencies);
          final allOthersCompleted = otherDepTasks.every((t) => t.isCompleted);
          if (allOthersCompleted) {
            enabledTasks.add(task);
          }
        } else {
          // This was the only dependency
          enabledTasks.add(task);
        }
      }
    }
    
    return enabledTasks;
  }

  /// Deletes a task and handles dependencies
  Future<void> deleteTask(String taskId) async {
    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      throw const NotFoundException('Task not found');
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
      throw const NotFoundException('Task not found');
    }

    if (subTaskTitle.trim().isEmpty) {
      throw const ValidationException('Subtask title cannot be empty');
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

  /// Toggles subtask completion and updates parent task status accordingly
  Future<SubtaskToggleResult> toggleSubTask(
    String taskId, 
    String subTaskId, 
    {bool autoCompleteParent = false}
  ) async {
    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      throw const NotFoundException('Task not found');
    }

    final subTaskIndex = task.subTasks.indexWhere((st) => st.id == subTaskId);
    if (subTaskIndex == -1) {
      throw const NotFoundException('Subtask not found');
    }

    final subTask = task.subTasks[subTaskIndex];
    final wasCompleted = subTask.isCompleted;
    final updatedSubTask = wasCompleted 
        ? subTask.markIncomplete() 
        : subTask.markCompleted();

    final updatedTask = task.updateSubTask(updatedSubTask);
    
    // Check if parent task status should be updated
    TaskModel finalTask = updatedTask;
    bool parentTaskCompleted = false;
    bool parentTaskReopened = false;
    
    // If we just completed a subtask and all subtasks are now complete
    if (!wasCompleted && autoCompleteParent) {
      final allSubtasksCompleted = updatedTask.subTasks.every((st) => st.isCompleted);
      if (allSubtasksCompleted && !updatedTask.isCompleted) {
        // Check dependencies before auto-completing
        bool canComplete = true;
        if (updatedTask.hasDependencies) {
          final dependencies = await _taskRepository.getTasksByIds(updatedTask.dependencies);
          canComplete = dependencies.every((dep) => dep.isCompleted);
        }
        
        if (canComplete) {
          finalTask = updatedTask.markCompleted();
          parentTaskCompleted = true;
        }
      }
    }
    // If we just uncompleted a subtask and the parent was completed
    else if (wasCompleted && updatedTask.isCompleted) {
      // Reopen the parent task since not all subtasks are complete
      finalTask = updatedTask.copyWith(
        status: TaskStatus.inProgress,
        completedAt: null,
      );
      parentTaskReopened = true;
    }
    
    await _taskRepository.updateTask(finalTask);
    
    return SubtaskToggleResult(
      task: finalTask,
      toggledSubtask: updatedSubTask,
      parentTaskCompleted: parentTaskCompleted,
      parentTaskReopened: parentTaskReopened,
      wasSubtaskCompleted: wasCompleted,
    );
  }

  /// Validates task dependencies to prevent circular dependencies using improved algorithm
  Future<DependencyValidationResult> validateDependencies(String taskId, List<String> dependencyIds) async {
    // Check for self-dependency
    if (dependencyIds.contains(taskId)) {
      return DependencyValidationResult.invalid('Task cannot depend on itself');
    }

    // Check if all dependency tasks exist
    final existingTasks = await _taskRepository.getTasksByIds([taskId, ...dependencyIds]);
    final existingTaskIds = existingTasks.map((t) => t.id).toSet();
    
    final missingDependencies = dependencyIds.where((id) => !existingTaskIds.contains(id)).toList();
    if (missingDependencies.isNotEmpty) {
      return DependencyValidationResult.invalid(
        'Dependencies not found: ${missingDependencies.join(', ')}'
      );
    }
    
    if (!existingTaskIds.contains(taskId)) {
      return DependencyValidationResult.invalid('Task $taskId not found');
    }

    // Build dependency graph for all tasks
    final dependencyGraph = await _buildDependencyGraph();
    
    // Create a temporary graph with the new dependencies
    final tempGraph = Map<String, List<String>>.from(dependencyGraph);
    tempGraph[taskId] = List.from(dependencyIds);

    // Check for circular dependencies using topological sort
    final cycleDetection = _detectCircularDependencies(tempGraph, taskId);
    
    if (cycleDetection.hasCycle) {
      return DependencyValidationResult.invalid(
        'Circular dependency detected: ${cycleDetection.cyclePath.join(' -> ')}'
      );
    }
    
    // Check dependency depth (prevent overly complex chains)
    final maxDepth = _calculateDependencyDepth(tempGraph, taskId);
    if (maxDepth > 10) {
      return DependencyValidationResult.invalid(
        'Dependency chain too deep (maximum 10 levels allowed)'
      );
    }
    
    // Validate that dependencies don't create impossible completion scenarios
    final completionValidation = await _validateCompletionScenarios(taskId, dependencyIds);
    if (!completionValidation.isValid) {
      return completionValidation;
    }

    return DependencyValidationResult.valid();
  }
  
  /// Builds a complete dependency graph for all tasks
  Future<Map<String, List<String>>> _buildDependencyGraph() async {
    final allTasks = await _taskRepository.getAllTasks();
    final graph = <String, List<String>>{};
    
    for (final task in allTasks) {
      graph[task.id] = List.from(task.dependencies);
    }
    
    return graph;
  }
  
  /// Detects circular dependencies using DFS with proper cycle detection
  CircularDependencyResult _detectCircularDependencies(Map<String, List<String>> graph, String startNode) {
    final visited = <String>{};
    final recursionStack = <String>{};
    final path = <String>[];
    
    bool dfs(String node) {
      if (recursionStack.contains(node)) {
        // Cycle detected - build cycle path
        final cycleStart = path.indexOf(node);
        final cyclePath = path.sublist(cycleStart);
        cyclePath.add(node); // Cycle path built but not stored
        return true;
      }
      
      if (visited.contains(node)) {
        return false; // Already processed, no cycle through this path
      }
      
      visited.add(node);
      recursionStack.add(node);
      path.add(node);
      
      final dependencies = graph[node] ?? [];
      for (final dep in dependencies) {
        if (dfs(dep)) {
          return true;
        }
      }
      
      recursionStack.remove(node);
      path.removeLast();
      return false;
    }
    
    // Check for cycles starting from any unvisited node in the graph
    for (final node in graph.keys) {
      if (!visited.contains(node)) {
        path.clear();
        if (dfs(node)) {
          return CircularDependencyResult.withCycle(path);
        }
      }
    }
    
    return CircularDependencyResult.noCycle();
  }
  
  /// Calculates the maximum dependency depth for a task
  int _calculateDependencyDepth(Map<String, List<String>> graph, String taskId) {
    final visited = <String>{};
    
    int dfs(String node) {
      if (visited.contains(node)) {
        return 0; // Prevent infinite recursion on cycles
      }
      
      visited.add(node);
      
      final dependencies = graph[node] ?? [];
      if (dependencies.isEmpty) {
        visited.remove(node);
        return 1;
      }
      
      int maxDepth = 0;
      for (final dep in dependencies) {
        maxDepth = math.max(maxDepth, dfs(dep));
      }
      
      visited.remove(node);
      return maxDepth + 1;
    }
    
    return dfs(taskId);
  }
  
  /// Validates that the dependency setup allows for task completion
  Future<DependencyValidationResult> _validateCompletionScenarios(
    String taskId, 
    List<String> dependencyIds,
  ) async {
    final dependencies = await _taskRepository.getTasksByIds(dependencyIds);
    
    // Check if any dependencies are already completed and this would create issues
    final incompleteDependencies = dependencies.where((t) => !t.isCompleted).toList();
    
    // Warn if adding dependencies to a task that's already completed
    final task = await _taskRepository.getTaskById(taskId);
    if (task != null && task.isCompleted && incompleteDependencies.isNotEmpty) {
      return DependencyValidationResult.warning(
        'Adding incomplete dependencies to a completed task'
      );
    }
    
    // Check for dependencies on cancelled tasks
    final cancelledDependencies = dependencies.where((t) => t.status == TaskStatus.cancelled).toList();
    if (cancelledDependencies.isNotEmpty) {
      return DependencyValidationResult.invalid(
        'Cannot depend on cancelled tasks: ${cancelledDependencies.map((t) => t.title).join(', ')}'
      );
    }
    
    return DependencyValidationResult.valid();
  }
}