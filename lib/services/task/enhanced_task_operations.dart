import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../domain/repositories/task_repository.dart';
import 'recurring_task_service.dart';
import '../dependency_service.dart';
import '../notification/notification_service.dart';
import '../../core/accessibility/accessibility_constants.dart';

/// Enhanced task operations with comprehensive error handling, undo functionality, and user feedback
class EnhancedTaskOperations {
  final TaskRepository _repository;
  final RecurringTaskService _recurringService;
  final DependencyService _dependencyService;
  final NotificationService? _notificationService;
  final List<TaskOperation> _operationHistory = [];
  static const int _maxHistorySize = 50;

  EnhancedTaskOperations(
    this._repository,
    this._recurringService,
    this._dependencyService, [
    this._notificationService,
  ]);

  /// Creates a new task with comprehensive validation and feedback
  Future<TaskOperationResult> createTask(
    TaskModel task, {
    BuildContext? context,
    bool showFeedback = true,
  }) async {
    try {
      // Validate task
      final validation = _validateTask(task);
      if (!validation.isValid) {
        return TaskOperationResult.failure(
          operation: TaskOperationType.create,
          error: validation.errorMessage ?? 'Task validation failed',
          originalTask: task,
        );
      }

      // Create task
      await _repository.createTask(task);

      // Add to history for undo
      _addToHistory(TaskOperation(
        type: TaskOperationType.create,
        task: task,
        timestamp: DateTime.now(),
      ));

      // Schedule notification if needed
      if (task.dueDate != null && _notificationService != null) {
        await _notificationService.scheduleTaskReminder(
          task: task,
          scheduledTime: task.dueDate ?? DateTime.now().add(const Duration(hours: 1)),
        );
      }

      // Show feedback
      if (context != null && context.mounted && showFeedback) {
        _showSuccessFeedback(
          context,
          AccessibilityConstants.taskCreatedAnnouncement,
          task,
          TaskOperationType.create,
        );
      }

      return TaskOperationResult.success(
        operation: TaskOperationType.create,
        task: task,
        message: 'Task "${task.title}" created successfully',
      );
    } catch (e) {
      return TaskOperationResult.failure(
        operation: TaskOperationType.create,
        error: 'Failed to create task: ${e.toString()}',
        originalTask: task,
      );
    }
  }

  /// Updates an existing task with validation and feedback
  Future<TaskOperationResult> updateTask(
    TaskModel updatedTask, {
    TaskModel? originalTask,
    BuildContext? context,
    bool showFeedback = true,
  }) async {
    try {
      // Get original task if not provided
      TaskModel? original = originalTask;
      if (original == null) {
        try {
          original = await _repository.getTaskById(updatedTask.id);
        } catch (e) {
          return TaskOperationResult.failure(
            operation: TaskOperationType.update,
            error: 'Original task not found: ${e.toString()}',
            originalTask: originalTask,
          );
        }
      }

      // Validate updated task
      final validation = _validateTask(updatedTask);
      if (!validation.isValid) {
        return TaskOperationResult.failure(
          operation: TaskOperationType.update,
          error: validation.errorMessage ?? 'Task validation failed',
          originalTask: original,
        );
      }

      // Update task
      await _repository.updateTask(updatedTask);

      // Add to history for undo
      if (original != null) {
        _addToHistory(TaskOperation(
          type: TaskOperationType.update,
          task: updatedTask,
          previousTask: original,
          timestamp: DateTime.now(),
        ));
      }

      // Update notifications if needed
      if (updatedTask.dueDate != original?.dueDate && _notificationService != null) {
        await _notificationService.cancelTaskNotifications(updatedTask.id);
        if (updatedTask.dueDate != null) {
          await _notificationService.scheduleTaskReminder(
            task: updatedTask,
            scheduledTime: updatedTask.dueDate!,
          );
        }
      }

      // Show feedback
      if (context != null && context.mounted && showFeedback) {
        _showSuccessFeedback(
          context,
          AccessibilityConstants.taskEditedAnnouncement,
          updatedTask,
          TaskOperationType.update,
        );
      }

      return TaskOperationResult.success(
        operation: TaskOperationType.update,
        task: updatedTask,
        previousTask: original,
        message: 'Task "${updatedTask.title}" updated successfully',
      );
    } catch (e) {
      return TaskOperationResult.failure(
        operation: TaskOperationType.update,
        error: 'Failed to update task: ${e.toString()}',
        originalTask: originalTask,
      );
    }
  }

  /// Toggles task completion with comprehensive validation and feedback
  Future<TaskOperationResult> toggleTaskCompletion(
    TaskModel task, {
    BuildContext? context,
    bool showFeedback = true,
  }) async {
    try {
      final wasCompleted = task.status == TaskStatus.completed;

      // If marking as complete, validate dependencies
      if (!wasCompleted) {
        final validation = await _dependencyService.validateTaskCompletion(task);
        if (!validation.isValid) {
          if (context != null && context.mounted) {
            _showErrorFeedback(
              context,
              validation.errorMessage ?? 'Task dependencies not completed',
            );
          }
          return TaskOperationResult.failure(
            operation: TaskOperationType.toggleComplete,
            error: validation.errorMessage ?? 'Task dependencies not completed',
            originalTask: task,
          );
        }
      }

      // Toggle completion
      final updatedTask = wasCompleted ? task.resetToPending() : task.markCompleted();
      await _repository.updateTask(updatedTask);

      // Add to history for undo
      _addToHistory(TaskOperation(
        type: TaskOperationType.toggleComplete,
        task: updatedTask,
        previousTask: task,
        timestamp: DateTime.now(),
      ));

      // Handle side effects if completed
      if (updatedTask.status == TaskStatus.completed) {
        // Handle dependent tasks
        await _dependencyService.onTaskCompleted(updatedTask);

        // Generate next recurring instance if needed
        if (task.isRecurring) {
          final nextTask = await _recurringService.generateNextRecurringTask(updatedTask);
          if (nextTask != null) {
            await _repository.createTask(nextTask);
          }
        }

        // Cancel notification
        if (_notificationService != null) {
          await _notificationService.cancelTaskNotifications(updatedTask.id);
        }
      } else {
        // Re-schedule notification if uncompleted
        if (updatedTask.dueDate != null && _notificationService != null) {
          await _notificationService.scheduleTaskReminder(
            task: updatedTask,
            scheduledTime: updatedTask.dueDate!,
          );
        }
      }

      // Provide haptic feedback
      if (updatedTask.status == TaskStatus.completed) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.selectionClick();
      }

      // Show feedback
      if (context != null && context.mounted && showFeedback) {
        final message = updatedTask.status == TaskStatus.completed
            ? AccessibilityConstants.taskCompletedAnnouncement
            : AccessibilityConstants.taskUncompletedAnnouncement;
        _showSuccessFeedback(
          context,
          message,
          updatedTask,
          TaskOperationType.toggleComplete,
        );
      }

      return TaskOperationResult.success(
        operation: TaskOperationType.toggleComplete,
        task: updatedTask,
        previousTask: task,
        message: updatedTask.status == TaskStatus.completed
            ? 'Task "${updatedTask.title}" completed'
            : 'Task "${updatedTask.title}" marked as incomplete',
      );
    } catch (e) {
      return TaskOperationResult.failure(
        operation: TaskOperationType.toggleComplete,
        error: 'Failed to toggle task completion: ${e.toString()}',
        originalTask: task,
      );
    }
  }

  /// Deletes a task with confirmation and feedback
  Future<TaskOperationResult> deleteTask(
    TaskModel task, {
    BuildContext? context,
    bool showFeedback = true,
    bool requireConfirmation = true,
  }) async {
    try {
      // Show confirmation dialog if required
      if (requireConfirmation && context != null) {
        final confirmed = await _showDeleteConfirmation(context, task);
        if (!confirmed) {
          return TaskOperationResult.cancelled(
            operation: TaskOperationType.delete,
            task: task,
          );
        }
      }

      // Check for dependencies
      final dependentTasks = await _dependencyService.getDependentTasks(task.id);
      if (dependentTasks.isNotEmpty) {
        if (context != null && context.mounted) {
          _showErrorFeedback(
            context,
            'Cannot delete task: ${dependentTasks.length} other tasks depend on it',
          );
        }
        return TaskOperationResult.failure(
          operation: TaskOperationType.delete,
          error: 'Cannot delete task: ${dependentTasks.length} other tasks depend on it',
          originalTask: task,
        );
      }

      // Delete task
      await _repository.deleteTask(task.id);

      // Add to history for undo
      _addToHistory(TaskOperation(
        type: TaskOperationType.delete,
        task: task,
        timestamp: DateTime.now(),
      ));

      // Cancel notifications
      if (_notificationService != null) {
        await _notificationService.cancelTaskNotifications(task.id);
      }

      // Show feedback
      if (context != null && context.mounted && showFeedback) {
        _showSuccessFeedback(
          context,
          AccessibilityConstants.taskDeletedAnnouncement,
          task,
          TaskOperationType.delete,
        );
      }

      return TaskOperationResult.success(
        operation: TaskOperationType.delete,
        task: task,
        message: 'Task "${task.title}" deleted successfully',
      );
    } catch (e) {
      return TaskOperationResult.failure(
        operation: TaskOperationType.delete,
        error: 'Failed to delete task: ${e.toString()}',
        originalTask: task,
      );
    }
  }

  /// Undoes the last operation
  Future<TaskOperationResult> undoLastOperation({
    BuildContext? context,
    bool showFeedback = true,
  }) async {
    if (_operationHistory.isEmpty) {
      return TaskOperationResult.failure(
        operation: TaskOperationType.undo,
        error: 'No operations to undo',
      );
    }

    final lastOperation = _operationHistory.removeLast();

    try {
      switch (lastOperation.type) {
        case TaskOperationType.create:
          // Undo create by deleting
          await _repository.deleteTask(lastOperation.task.id);
          break;

        case TaskOperationType.update:
          // Undo update by restoring previous state
          if (lastOperation.previousTask != null) {
            await _repository.updateTask(lastOperation.previousTask!);
          }
          break;

        case TaskOperationType.delete:
          // Undo delete by recreating
          await _repository.createTask(lastOperation.task);
          break;

        case TaskOperationType.toggleComplete:
          // Undo completion toggle
          if (lastOperation.previousTask != null) {
            await _repository.updateTask(lastOperation.previousTask!);
          }
          break;

        default:
          return TaskOperationResult.failure(
            operation: TaskOperationType.undo,
            error: 'Cannot undo operation of type: ${lastOperation.type}',
          );
      }

      // Show feedback
      if (context != null && context.mounted && showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Undid ${lastOperation.type.toString().split('.').last}'),
            duration: const Duration(seconds: 2),
          ),
        );
        AccessibilityUtils.announceToScreenReader(context, 'Operation undone');
      }

      return TaskOperationResult.success(
        operation: TaskOperationType.undo,
        task: lastOperation.task,
        message: 'Operation undone successfully',
      );
    } catch (e) {
      // Restore operation to history if undo failed
      _operationHistory.add(lastOperation);
      return TaskOperationResult.failure(
        operation: TaskOperationType.undo,
        error: 'Failed to undo operation: ${e.toString()}',
      );
    }
  }

  /// Validates a task before creation or update
  TaskValidationResult _validateTask(TaskModel task) {
    final errors = <String>[];

    // Title validation
    if (task.title.trim().isEmpty) {
      errors.add('Task title cannot be empty');
    }
    if (task.title.length > 200) {
      errors.add('Task title cannot exceed 200 characters');
    }

    // Description validation
    if (task.description?.length != null && task.description!.length > 1000) {
      errors.add('Task description cannot exceed 1000 characters');
    }

    // Due date validation
    if (task.dueDate != null && task.dueDate!.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      errors.add('Due date cannot be in the past');
    }

    // Priority validation
    // if (task.priority == null) {
    //   errors.add('Task priority must be specified');
    // }

    return TaskValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Adds operation to history for undo functionality
  void _addToHistory(TaskOperation operation) {
    _operationHistory.add(operation);
    if (_operationHistory.length > _maxHistorySize) {
      _operationHistory.removeAt(0);
    }
  }

  /// Shows success feedback to user
  void _showSuccessFeedback(
    BuildContext context,
    String message,
    TaskModel task,
    TaskOperationType operation,
  ) {
    // Show snackbar with undo option for certain operations
    final canUndo = operation == TaskOperationType.create ||
        operation == TaskOperationType.update ||
        operation == TaskOperationType.delete ||
        operation == TaskOperationType.toggleComplete;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        action: canUndo
            ? SnackBarAction(
                label: 'Undo',
                onPressed: () => undoLastOperation(context: context),
              )
            : null,
      ),
    );

    // Announce to screen reader
    AccessibilityUtils.announceToScreenReader(context, message);
  }

  /// Shows error feedback to user
  void _showErrorFeedback(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 5),
      ),
    );
    AccessibilityUtils.announceToScreenReader(context, 'Error: $error');
  }

  /// Shows delete confirmation dialog
  Future<bool> _showDeleteConfirmation(BuildContext context, TaskModel task) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Gets operation history for debugging or advanced undo
  List<TaskOperation> get operationHistory => List.unmodifiable(_operationHistory);

  /// Clears operation history
  void clearHistory() {
    _operationHistory.clear();
  }
}

/// Represents a task operation for undo functionality
class TaskOperation {
  final TaskOperationType type;
  final TaskModel task;
  final TaskModel? previousTask;
  final DateTime timestamp;

  TaskOperation({
    required this.type,
    required this.task,
    this.previousTask,
    required this.timestamp,
  });
}

/// Types of task operations
enum TaskOperationType {
  create,
  update,
  delete,
  toggleComplete,
  undo,
}

/// Result of a task operation
class TaskOperationResult {
  final bool isSuccess;
  final TaskOperationType operation;
  final TaskModel? task;
  final TaskModel? previousTask;
  final TaskModel? originalTask;
  final String? message;
  final String? error;
  final bool isCancelled;

  TaskOperationResult._({
    required this.isSuccess,
    required this.operation,
    this.task,
    this.previousTask,
    this.originalTask,
    this.message,
    this.error,
    this.isCancelled = false,
  });

  factory TaskOperationResult.success({
    required TaskOperationType operation,
    TaskModel? task,
    TaskModel? previousTask,
    String? message,
  }) {
    return TaskOperationResult._(
      isSuccess: true,
      operation: operation,
      task: task,
      previousTask: previousTask,
      message: message,
    );
  }

  factory TaskOperationResult.failure({
    required TaskOperationType operation,
    required String error,
    TaskModel? originalTask,
    TaskModel? task,
  }) {
    return TaskOperationResult._(
      isSuccess: false,
      operation: operation,
      task: task,
      originalTask: originalTask,
      error: error,
    );
  }

  factory TaskOperationResult.cancelled({
    required TaskOperationType operation,
    TaskModel? task,
  }) {
    return TaskOperationResult._(
      isSuccess: false,
      operation: operation,
      task: task,
      isCancelled: true,
    );
  }
}

/// Result of task validation
class TaskValidationResult {
  final bool isValid;
  final List<String> errors;

  TaskValidationResult({
    required this.isValid,
    required this.errors,
  });

  String? get errorMessage => errors.isEmpty ? null : errors.first;
}