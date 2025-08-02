import 'dart:async';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/task_enums.dart';
import '../../domain/entities/subtask.dart';
import '../../domain/repositories/task_repository.dart';
import 'voice_command_models.dart';
import 'voice_command_parser.dart';

/// Service for processing and executing voice commands
class VoiceCommandProcessor {
  final TaskRepository _taskRepository;
  final VoiceCommandParser _parser;
  // final VoiceCommandConfig _config;
  
  // Stream controllers for command results and feedback
  final StreamController<VoiceCommandResult> _resultController = 
      StreamController<VoiceCommandResult>.broadcast();
  final StreamController<String> _feedbackController = 
      StreamController<String>.broadcast();

  VoiceCommandProcessor({
    required TaskRepository taskRepository,
    VoiceCommandParser? parser,
    VoiceCommandConfig config = const VoiceCommandConfig(),
  }) : _taskRepository = taskRepository,
       _parser = parser ?? VoiceCommandParser(config: config);

  /// Stream of command execution results
  Stream<VoiceCommandResult> get results => _resultController.stream;

  /// Stream of user feedback messages
  Stream<String> get feedback => _feedbackController.stream;

  /// Processes a voice transcription and executes the resulting command
  Future<VoiceCommandResult> processVoiceInput(String transcription) async {
    try {
      // Parse the transcription into a command
      final command = await _parser.parseCommand(transcription);
      
      // Check if command is executable
      if (!command.isExecutable) {
        final result = VoiceCommandResult.failure(
          command: command,
          message: _getCommandNotExecutableMessage(command),
          errorCode: 'not_executable',
        );
        _resultController.add(result);
        return result;
      }

      // Execute the command
      final result = await executeCommand(command);
      _resultController.add(result);
      
      // Send feedback to user
      _feedbackController.add(result.message);
      
      return result;
    } catch (e) {
      final unknownCommand = VoiceCommand.unknown(
        originalText: transcription,
        errorMessage: e.toString(),
      );
      
      final result = VoiceCommandResult.failure(
        command: unknownCommand,
        message: 'Failed to process voice command: ${e.toString()}',
        errorCode: 'processing_error',
      );
      
      _resultController.add(result);
      return result;
    }
  }

  /// Executes a parsed voice command
  Future<VoiceCommandResult> executeCommand(VoiceCommand command) async {
    try {
      switch (command.type) {
        case VoiceCommandType.createTask:
          return await _executeCreateTask(command);
        
        case VoiceCommandType.completeTask:
          return await _executeCompleteTask(command);
        
        case VoiceCommandType.deleteTask:
          return await _executeDeleteTask(command);
        
        case VoiceCommandType.rescheduleTask:
          return await _executeRescheduleTask(command);
        
        case VoiceCommandType.setPriority:
          return await _executeSetPriority(command);
        
        case VoiceCommandType.addTag:
          return await _executeAddTag(command);
        
        case VoiceCommandType.removeTag:
          return await _executeRemoveTag(command);
        
        case VoiceCommandType.markInProgress:
          return await _executeMarkInProgress(command);
        
        case VoiceCommandType.cancelTask:
          return await _executeCancelTask(command);
        
        case VoiceCommandType.searchTasks:
          return await _executeSearchTasks(command);
        
        case VoiceCommandType.listTasks:
          return await _executeListTasks(command);
        
        case VoiceCommandType.showTaskDetails:
          return await _executeShowTaskDetails(command);
        
        case VoiceCommandType.addSubtask:
          return await _executeAddSubtask(command);
        
        case VoiceCommandType.completeSubtask:
          return await _executeCompleteSubtask(command);
        
        case VoiceCommandType.pinTask:
          return await _executePinTask(command);
        
        case VoiceCommandType.unpinTask:
          return await _executeUnpinTask(command);
        
        case VoiceCommandType.setReminder:
          return await _executeSetReminder(command);
        
        case VoiceCommandType.unknown:
          return VoiceCommandResult.failure(
            command: command,
            message: 'Unknown command: ${command.originalText}',
            errorCode: 'unknown_command',
          );
        
        default:
          return VoiceCommandResult.failure(
            command: command,
            message: 'Command type not implemented: ${command.type}',
            errorCode: 'not_implemented',
          );
      }
    } catch (e) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'Failed to execute command: ${e.toString()}',
        errorCode: 'execution_error',
      );
    }
  }

  /// Creates a new task from voice command
  Future<VoiceCommandResult> _executeCreateTask(VoiceCommand command) async {
    if (command.taskTitle == null || command.taskTitle!.isEmpty) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'Cannot create task without a title',
        errorCode: 'missing_title',
      );
    }

    final task = TaskModel.create(
      title: command.taskTitle!,
      description: command.description,
      priority: command.priority ?? TaskPriority.medium,
      dueDate: command.dueDate,
      tags: command.tags,
    );

    await _taskRepository.createTask(task);

    return VoiceCommandResult.success(
      command: command,
      message: 'Created task: ${task.title}',
      data: {'taskId': task.id, 'task': task.toJson()},
    );
  }

  /// Completes a task based on voice command
  Future<VoiceCommandResult> _executeCompleteTask(VoiceCommand command) async {
    final task = await _findTaskByCommand(command);
    if (task == null) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'Could not find task to complete',
        errorCode: 'task_not_found',
      );
    }

    final completedTask = task.markCompleted();
    await _taskRepository.updateTask(completedTask);

    return VoiceCommandResult.success(
      command: command,
      message: 'Completed task: ${task.title}',
      data: {'taskId': task.id, 'task': completedTask.toJson()},
    );
  }

  /// Deletes a task based on voice command
  Future<VoiceCommandResult> _executeDeleteTask(VoiceCommand command) async {
    final task = await _findTaskByCommand(command);
    if (task == null) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'Could not find task to delete',
        errorCode: 'task_not_found',
      );
    }

    await _taskRepository.deleteTask(task.id);

    return VoiceCommandResult.success(
      command: command,
      message: 'Deleted task: ${task.title}',
      data: {'taskId': task.id},
    );
  }

  /// Reschedules a task based on voice command
  Future<VoiceCommandResult> _executeRescheduleTask(VoiceCommand command) async {
    final task = await _findTaskByCommand(command);
    if (task == null) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'Could not find task to reschedule',
        errorCode: 'task_not_found',
      );
    }

    if (command.dueDate == null) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'No new due date specified',
        errorCode: 'missing_due_date',
      );
    }

    final rescheduledTask = task.copyWith(dueDate: command.dueDate);
    await _taskRepository.updateTask(rescheduledTask);

    return VoiceCommandResult.success(
      command: command,
      message: 'Rescheduled task: ${task.title} to ${_formatDate(command.dueDate!)}',
      data: {'taskId': task.id, 'task': rescheduledTask.toJson()},
    );
  }

  /// Sets task priority based on voice command
  Future<VoiceCommandResult> _executeSetPriority(VoiceCommand command) async {
    final task = await _findTaskByCommand(command);
    if (task == null) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'Could not find task to set priority',
        errorCode: 'task_not_found',
      );
    }

    if (command.priority == null) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'No priority level specified',
        errorCode: 'missing_priority',
      );
    }

    final updatedTask = task.copyWith(priority: command.priority);
    await _taskRepository.updateTask(updatedTask);

    return VoiceCommandResult.success(
      command: command,
      message: 'Set ${task.title} priority to ${command.priority!.displayName}',
      data: {'taskId': task.id, 'task': updatedTask.toJson()},
    );
  }

  /// Adds a tag to a task based on voice command
  Future<VoiceCommandResult> _executeAddTag(VoiceCommand command) async {
    final task = await _findTaskByCommand(command);
    if (task == null) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'Could not find task to add tag',
        errorCode: 'task_not_found',
      );
    }

    if (command.tags.isEmpty) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'No tag specified',
        errorCode: 'missing_tag',
      );
    }

    var updatedTask = task;
    for (final tag in command.tags) {
      updatedTask = updatedTask.addTag(tag);
    }
    
    await _taskRepository.updateTask(updatedTask);

    return VoiceCommandResult.success(
      command: command,
      message: 'Added tag${command.tags.length > 1 ? 's' : ''} ${command.tags.join(', ')} to ${task.title}',
      data: {'taskId': task.id, 'task': updatedTask.toJson()},
    );
  }

  /// Removes a tag from a task based on voice command
  Future<VoiceCommandResult> _executeRemoveTag(VoiceCommand command) async {
    final task = await _findTaskByCommand(command);
    if (task == null) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'Could not find task to remove tag',
        errorCode: 'task_not_found',
      );
    }

    if (command.tags.isEmpty) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'No tag specified',
        errorCode: 'missing_tag',
      );
    }

    var updatedTask = task;
    for (final tag in command.tags) {
      updatedTask = updatedTask.removeTag(tag);
    }
    
    await _taskRepository.updateTask(updatedTask);

    return VoiceCommandResult.success(
      command: command,
      message: 'Removed tag${command.tags.length > 1 ? 's' : ''} ${command.tags.join(', ')} from ${task.title}',
      data: {'taskId': task.id, 'task': updatedTask.toJson()},
    );
  }

  /// Marks a task as in progress based on voice command
  Future<VoiceCommandResult> _executeMarkInProgress(VoiceCommand command) async {
    final task = await _findTaskByCommand(command);
    if (task == null) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'Could not find task to mark in progress',
        errorCode: 'task_not_found',
      );
    }

    final updatedTask = task.markInProgress();
    await _taskRepository.updateTask(updatedTask);

    return VoiceCommandResult.success(
      command: command,
      message: 'Marked task in progress: ${task.title}',
      data: {'taskId': task.id, 'task': updatedTask.toJson()},
    );
  }

  /// Cancels a task based on voice command
  Future<VoiceCommandResult> _executeCancelTask(VoiceCommand command) async {
    final task = await _findTaskByCommand(command);
    if (task == null) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'Could not find task to cancel',
        errorCode: 'task_not_found',
      );
    }

    final cancelledTask = task.markCancelled();
    await _taskRepository.updateTask(cancelledTask);

    return VoiceCommandResult.success(
      command: command,
      message: 'Cancelled task: ${task.title}',
      data: {'taskId': task.id, 'task': cancelledTask.toJson()},
    );
  }

  /// Searches for tasks based on voice command
  Future<VoiceCommandResult> _executeSearchTasks(VoiceCommand command) async {
    if (command.searchQuery == null || command.searchQuery!.isEmpty) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'No search query specified',
        errorCode: 'missing_search_query',
      );
    }

    final tasks = await _taskRepository.searchTasks(command.searchQuery!);

    return VoiceCommandResult.success(
      command: command,
      message: 'Found ${tasks.length} task${tasks.length != 1 ? 's' : ''} matching "${command.searchQuery}"',
      data: {
        'tasks': tasks.map((t) => t.toJson()).toList(),
        'count': tasks.length,
      },
    );
  }

  /// Lists all tasks based on voice command
  Future<VoiceCommandResult> _executeListTasks(VoiceCommand command) async {
    final tasks = await _taskRepository.getAllTasks();
    final activeTasks = tasks.where((t) => t.status.isActive).toList();

    return VoiceCommandResult.success(
      command: command,
      message: 'You have ${activeTasks.length} active task${activeTasks.length != 1 ? 's' : ''}',
      data: {
        'tasks': activeTasks.map((t) => t.toJson()).toList(),
        'count': activeTasks.length,
      },
    );
  }

  /// Shows task details based on voice command
  Future<VoiceCommandResult> _executeShowTaskDetails(VoiceCommand command) async {
    final task = await _findTaskByCommand(command);
    if (task == null) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'Could not find task to show details',
        errorCode: 'task_not_found',
      );
    }

    final details = _formatTaskDetails(task);

    return VoiceCommandResult.success(
      command: command,
      message: details,
      data: {'task': task.toJson()},
    );
  }

  /// Adds a subtask based on voice command
  Future<VoiceCommandResult> _executeAddSubtask(VoiceCommand command) async {
    final task = await _findTaskByCommand(command);
    if (task == null) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'Could not find task to add subtask',
        errorCode: 'task_not_found',
      );
    }

    if (command.subtaskTitle == null || command.subtaskTitle!.isEmpty) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'No subtask title specified',
        errorCode: 'missing_subtask_title',
      );
    }

    final subtask = SubTask.create(
      taskId: task.id,
      title: command.subtaskTitle!,
    );

    final updatedTask = task.addSubTask(subtask);
    await _taskRepository.updateTask(updatedTask);

    return VoiceCommandResult.success(
      command: command,
      message: 'Added subtask "${command.subtaskTitle}" to ${task.title}',
      data: {'taskId': task.id, 'subtaskId': subtask.id, 'task': updatedTask.toJson()},
    );
  }

  /// Completes a subtask based on voice command
  Future<VoiceCommandResult> _executeCompleteSubtask(VoiceCommand command) async {
    final task = await _findTaskByCommand(command);
    if (task == null) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'Could not find task with subtask',
        errorCode: 'task_not_found',
      );
    }

    if (command.subtaskTitle == null || command.subtaskTitle!.isEmpty) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'No subtask specified',
        errorCode: 'missing_subtask_title',
      );
    }

    // Find the subtask by title
    final subtask = task.subTasks.firstWhere(
      (st) => st.title.toLowerCase().contains(command.subtaskTitle!.toLowerCase()),
      orElse: () => throw StateError('Subtask not found'),
    );

    final completedSubtask = subtask.markCompleted();
    final updatedTask = task.updateSubTask(completedSubtask);
    await _taskRepository.updateTask(updatedTask);

    return VoiceCommandResult.success(
      command: command,
      message: 'Completed subtask "${subtask.title}" in ${task.title}',
      data: {'taskId': task.id, 'subtaskId': subtask.id, 'task': updatedTask.toJson()},
    );
  }

  /// Pins a task based on voice command
  Future<VoiceCommandResult> _executePinTask(VoiceCommand command) async {
    final task = await _findTaskByCommand(command);
    if (task == null) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'Could not find task to pin',
        errorCode: 'task_not_found',
      );
    }

    if (task.isPinned) {
      return VoiceCommandResult.success(
        command: command,
        message: 'Task "${task.title}" is already pinned',
        data: {'taskId': task.id},
      );
    }

    final pinnedTask = task.togglePin();
    await _taskRepository.updateTask(pinnedTask);

    return VoiceCommandResult.success(
      command: command,
      message: 'Pinned task: ${task.title}',
      data: {'taskId': task.id, 'task': pinnedTask.toJson()},
    );
  }

  /// Unpins a task based on voice command
  Future<VoiceCommandResult> _executeUnpinTask(VoiceCommand command) async {
    final task = await _findTaskByCommand(command);
    if (task == null) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'Could not find task to unpin',
        errorCode: 'task_not_found',
      );
    }

    if (!task.isPinned) {
      return VoiceCommandResult.success(
        command: command,
        message: 'Task "${task.title}" is not pinned',
        data: {'taskId': task.id},
      );
    }

    final unpinnedTask = task.togglePin();
    await _taskRepository.updateTask(unpinnedTask);

    return VoiceCommandResult.success(
      command: command,
      message: 'Unpinned task: ${task.title}',
      data: {'taskId': task.id, 'task': unpinnedTask.toJson()},
    );
  }

  /// Sets a reminder for a task based on voice command
  Future<VoiceCommandResult> _executeSetReminder(VoiceCommand command) async {
    final task = await _findTaskByCommand(command);
    if (task == null) {
      return VoiceCommandResult.failure(
        command: command,
        message: 'Could not find task to set reminder',
        errorCode: 'task_not_found',
      );
    }

    // For now, we'll just set the due date as the reminder time
    // In a full implementation, this would integrate with the notification system
    final reminderTime = command.dueDate ?? DateTime.now().add(const Duration(hours: 1));
    final updatedTask = task.copyWith(dueDate: reminderTime);
    await _taskRepository.updateTask(updatedTask);

    return VoiceCommandResult.success(
      command: command,
      message: 'Set reminder for "${task.title}" at ${_formatDate(reminderTime)}',
      data: {'taskId': task.id, 'reminderTime': reminderTime.toIso8601String()},
    );
  }

  /// Finds a task based on the command parameters
  Future<TaskModel?> _findTaskByCommand(VoiceCommand command) async {
    // If we have a task ID, use it directly
    if (command.taskId != null) {
      return await _taskRepository.getTaskById(command.taskId!);
    }

    // If we have a task title, search for it
    if (command.taskTitle != null && command.taskTitle!.isNotEmpty) {
      final tasks = await _taskRepository.searchTasks(command.taskTitle!);
      
      // Return exact match if found
      for (final task in tasks) {
        if (task.title.toLowerCase() == command.taskTitle!.toLowerCase()) {
          return task;
        }
      }
      
      // Return partial match if no exact match
      if (tasks.isNotEmpty) {
        return tasks.first;
      }
    }

    return null;
  }

  /// Formats a date for user-friendly display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    
    if (taskDate.isAtSameMomentAs(today)) {
      return 'today at ${_formatTime(date)}';
    } else if (taskDate.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'tomorrow at ${_formatTime(date)}';
    } else {
      return '${date.month}/${date.day}/${date.year} at ${_formatTime(date)}';
    }
  }

  /// Formats time for user-friendly display
  String _formatTime(DateTime date) {
    final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  /// Formats task details for display
  String _formatTaskDetails(TaskModel task) {
    const buffer = StringBuffer();
    buffer.writeln('Task: ${task.title}');
    
    if (task.description != null && task.description!.isNotEmpty) {
      buffer.writeln('Description: ${task.description}');
    }
    
    buffer.writeln('Status: ${task.status.displayName}');
    buffer.writeln('Priority: ${task.priority.displayName}');
    
    if (task.dueDate != null) {
      buffer.writeln('Due: ${_formatDate(task.dueDate!)}');
    }
    
    if (task.tags.isNotEmpty) {
      buffer.writeln('Tags: ${task.tags.join(', ')}');
    }
    
    if (task.subTasks.isNotEmpty) {
      buffer.writeln('Subtasks: ${task.subTasks.length} (${task.subTasks.where((st) => st.isCompleted).length} completed)');
    }
    
    return buffer.toString().trim();
  }

  /// Gets a user-friendly message for non-executable commands
  String _getCommandNotExecutableMessage(VoiceCommand command) {
    switch (command.type) {
      case VoiceCommandType.unknown:
        return 'I didn\'t understand that command. Try saying something like "create task buy groceries" or "complete task meeting notes".';
      
      case VoiceCommandType.createTask:
        return 'I couldn\'t create a task because no title was provided.';
      
      case VoiceCommandType.searchTasks:
        return 'I couldn\'t search because no search terms were provided.';
      
      default:
        if (command.requiresTaskIdentification) {
          return 'I couldn\'t find which task you\'re referring to. Try being more specific with the task name.';
        }
        return 'I couldn\'t execute that command. Please try again with more details.';
    }
  }

  /// Disposes of resources
  void dispose() {
    _resultController.close();
    _feedbackController.close();
  }
}
