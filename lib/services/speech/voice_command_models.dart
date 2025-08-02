import 'package:equatable/equatable.dart';
import '../../domain/entities/task_enums.dart';

/// Types of voice commands that can be executed
enum VoiceCommandType {
  createTask,
  completeTask,
  deleteTask,
  editTask,
  rescheduleTask,
  setPriority,
  addTag,
  removeTag,
  markInProgress,
  cancelTask,
  searchTasks,
  listTasks,
  showTaskDetails,
  addSubtask,
  completeSubtask,
  pinTask,
  unpinTask,
  setReminder,
  unknown,
}

/// Confidence level for voice command recognition
enum CommandConfidence {
  high,
  medium,
  low,
}

/// Represents a parsed voice command with its parameters
class VoiceCommand extends Equatable {
  final VoiceCommandType type;
  final CommandConfidence confidence;
  final String originalText;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;
  final String? taskId;
  final String? taskTitle;
  final TaskPriority? priority;
  final TaskStatus? status;
  final DateTime? dueDate;
  final List<String> tags;
  final String? description;
  final String? subtaskTitle;
  final String? searchQuery;
  final String? errorMessage;

  const VoiceCommand({
    required this.type,
    required this.confidence,
    required this.originalText,
    this.parameters = const {},
    required this.timestamp,
    this.taskId,
    this.taskTitle,
    this.priority,
    this.status,
    this.dueDate,
    this.tags = const [],
    this.description,
    this.subtaskTitle,
    this.searchQuery,
    this.errorMessage,
  });

  /// Creates a voice command for task creation
  factory VoiceCommand.createTask({
    required String originalText,
    required String taskTitle,
    CommandConfidence confidence = CommandConfidence.medium,
    TaskPriority? priority,
    DateTime? dueDate,
    List<String> tags = const [],
    String? description,
    Map<String, dynamic> additionalParams = const {},
  }) {
    return VoiceCommand(
      type: VoiceCommandType.createTask,
      confidence: confidence,
      originalText: originalText,
      timestamp: DateTime.now(),
      taskTitle: taskTitle,
      priority: priority,
      dueDate: dueDate,
      tags: tags,
      description: description,
      parameters: {
        'title': taskTitle,
        if (priority != null) 'priority': priority.name,
        if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
        if (tags.isNotEmpty) 'tags': tags,
        if (description != null) 'description': description,
        ...additionalParams,
      },
    );
  }

  /// Creates a voice command for task completion
  factory VoiceCommand.completeTask({
    required String originalText,
    String? taskId,
    String? taskTitle,
    CommandConfidence confidence = CommandConfidence.medium,
  }) {
    return VoiceCommand(
      type: VoiceCommandType.completeTask,
      confidence: confidence,
      originalText: originalText,
      timestamp: DateTime.now(),
      taskId: taskId,
      taskTitle: taskTitle,
      status: TaskStatus.completed,
      parameters: {
        if (taskId != null) 'taskId': taskId,
        if (taskTitle != null) 'taskTitle': taskTitle,
        'status': TaskStatus.completed.name,
      },
    );
  }

  /// Creates a voice command for task deletion
  factory VoiceCommand.deleteTask({
    required String originalText,
    String? taskId,
    String? taskTitle,
    CommandConfidence confidence = CommandConfidence.medium,
  }) {
    return VoiceCommand(
      type: VoiceCommandType.deleteTask,
      confidence: confidence,
      originalText: originalText,
      timestamp: DateTime.now(),
      taskId: taskId,
      taskTitle: taskTitle,
      parameters: {
        if (taskId != null) 'taskId': taskId,
        if (taskTitle != null) 'taskTitle': taskTitle,
      },
    );
  }

  /// Creates a voice command for task rescheduling
  factory VoiceCommand.rescheduleTask({
    required String originalText,
    String? taskId,
    String? taskTitle,
    DateTime? newDueDate,
    CommandConfidence confidence = CommandConfidence.medium,
  }) {
    return VoiceCommand(
      type: VoiceCommandType.rescheduleTask,
      confidence: confidence,
      originalText: originalText,
      timestamp: DateTime.now(),
      taskId: taskId,
      taskTitle: taskTitle,
      dueDate: newDueDate,
      parameters: {
        if (taskId != null) 'taskId': taskId,
        if (taskTitle != null) 'taskTitle': taskTitle,
        if (newDueDate != null) 'newDueDate': newDueDate.toIso8601String(),
      },
    );
  }

  /// Creates a voice command for setting task priority
  factory VoiceCommand.setPriority({
    required String originalText,
    String? taskId,
    String? taskTitle,
    required TaskPriority priority,
    CommandConfidence confidence = CommandConfidence.medium,
  }) {
    return VoiceCommand(
      type: VoiceCommandType.setPriority,
      confidence: confidence,
      originalText: originalText,
      timestamp: DateTime.now(),
      taskId: taskId,
      taskTitle: taskTitle,
      priority: priority,
      parameters: {
        if (taskId != null) 'taskId': taskId,
        if (taskTitle != null) 'taskTitle': taskTitle,
        'priority': priority.name,
      },
    );
  }

  /// Creates a voice command for searching tasks
  factory VoiceCommand.searchTasks({
    required String originalText,
    required String searchQuery,
    CommandConfidence confidence = CommandConfidence.medium,
  }) {
    return VoiceCommand(
      type: VoiceCommandType.searchTasks,
      confidence: confidence,
      originalText: originalText,
      timestamp: DateTime.now(),
      searchQuery: searchQuery,
      parameters: {
        'searchQuery': searchQuery,
      },
    );
  }

  /// Creates an unknown/unrecognized voice command
  factory VoiceCommand.unknown({
    required String originalText,
    String? errorMessage,
  }) {
    return VoiceCommand(
      type: VoiceCommandType.unknown,
      confidence: CommandConfidence.low,
      originalText: originalText,
      timestamp: DateTime.now(),
      errorMessage: errorMessage,
      parameters: {
        if (errorMessage != null) 'error': errorMessage,
      },
    );
  }

  /// Creates a copy of this command with updated fields
  VoiceCommand copyWith({
    VoiceCommandType? type,
    CommandConfidence? confidence,
    String? originalText,
    Map<String, dynamic>? parameters,
    DateTime? timestamp,
    String? taskId,
    String? taskTitle,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    List<String>? tags,
    String? description,
    String? subtaskTitle,
    String? searchQuery,
    String? errorMessage,
  }) {
    return VoiceCommand(
      type: type ?? this.type,
      confidence: confidence ?? this.confidence,
      originalText: originalText ?? this.originalText,
      parameters: parameters ?? this.parameters,
      timestamp: timestamp ?? this.timestamp,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      subtaskTitle: subtaskTitle ?? this.subtaskTitle,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Returns true if this command requires a task to be identified
  bool get requiresTaskIdentification {
    return [
      VoiceCommandType.completeTask,
      VoiceCommandType.deleteTask,
      VoiceCommandType.editTask,
      VoiceCommandType.rescheduleTask,
      VoiceCommandType.setPriority,
      VoiceCommandType.addTag,
      VoiceCommandType.removeTag,
      VoiceCommandType.markInProgress,
      VoiceCommandType.cancelTask,
      VoiceCommandType.showTaskDetails,
      VoiceCommandType.addSubtask,
      VoiceCommandType.completeSubtask,
      VoiceCommandType.pinTask,
      VoiceCommandType.unpinTask,
      VoiceCommandType.setReminder,
    ].contains(type);
  }

  /// Returns true if this command can be executed
  bool get isExecutable {
    if (type == VoiceCommandType.unknown) return false;
    if (confidence == CommandConfidence.low) return false;
    
    // Check if required parameters are present
    switch (type) {
      case VoiceCommandType.createTask:
        return taskTitle != null && taskTitle!.isNotEmpty;
      case VoiceCommandType.searchTasks:
        return searchQuery != null && searchQuery!.isNotEmpty;
      case VoiceCommandType.completeTask:
      case VoiceCommandType.deleteTask:
      case VoiceCommandType.editTask:
      case VoiceCommandType.rescheduleTask:
      case VoiceCommandType.setPriority:
      case VoiceCommandType.addTag:
      case VoiceCommandType.removeTag:
      case VoiceCommandType.markInProgress:
      case VoiceCommandType.cancelTask:
      case VoiceCommandType.showTaskDetails:
      case VoiceCommandType.pinTask:
      case VoiceCommandType.unpinTask:
      case VoiceCommandType.setReminder:
        return taskId != null || taskTitle != null;
      case VoiceCommandType.addSubtask:
      case VoiceCommandType.completeSubtask:
        return (taskId != null || taskTitle != null) && subtaskTitle != null;
      case VoiceCommandType.listTasks:
        return true;
      case VoiceCommandType.unknown:
        return false;
    }
  }  @override
  List<Object?> get props => [
        type,
        confidence,
        originalText,
        parameters,
        timestamp,
        taskId,
        taskTitle,
        priority,
        status,
        dueDate,
        tags,
        description,
        subtaskTitle,
        searchQuery,
        errorMessage,
      ];  @override
  String toString() {
    return 'VoiceCommand(type: $type, confidence: $confidence, '
           'originalText: "$originalText", taskTitle: $taskTitle, '
           'parameters: $parameters)';
  }
}

/// Result of executing a voice command
class VoiceCommandResult extends Equatable {
  final bool success;
  final String message;
  final VoiceCommand command;
  final Map<String, dynamic> data;
  final String? errorCode;
  final DateTime timestamp;

  const VoiceCommandResult({
    required this.success,
    required this.message,
    required this.command,
    this.data = const {},
    this.errorCode,
    required this.timestamp,
  });

  /// Creates a successful command result
  factory VoiceCommandResult.success({
    required VoiceCommand command,
    required String message,
    Map<String, dynamic> data = const {},
  }) {
    return VoiceCommandResult(
      success: true,
      message: message,
      command: command,
      data: data,
      timestamp: DateTime.now(),
    );
  }

  /// Creates a failed command result
  factory VoiceCommandResult.failure({
    required VoiceCommand command,
    required String message,
    String? errorCode,
    Map<String, dynamic> data = const {},
  }) {
    return VoiceCommandResult(
      success: false,
      message: message,
      command: command,
      data: data,
      errorCode: errorCode,
      timestamp: DateTime.now(),
    );
  }  @override
  List<Object?> get props => [
        success,
        message,
        command,
        data,
        errorCode,
        timestamp,
      ];  @override
  String toString() {
    return 'VoiceCommandResult(success: $success, message: "$message", '
           'command: ${command.type})';
  }
}

/// Configuration for voice command processing
class VoiceCommandConfig {
  final double confidenceThreshold;
  final bool enableFuzzyMatching;
  final bool enableContextualParsing;
  final List<String> customCommands;
  final Map<String, String> commandAliases;
  final bool enableMultiLanguage;
  final String primaryLanguage;
  final Duration commandTimeout;

  const VoiceCommandConfig({
    this.confidenceThreshold = 0.7,
    this.enableFuzzyMatching = true,
    this.enableContextualParsing = true,
    this.customCommands = const [],
    this.commandAliases = const {},
    this.enableMultiLanguage = false,
    this.primaryLanguage = 'en',
    this.commandTimeout = const Duration(seconds: 30),
  });

  /// Creates a copy of this config with updated fields
  VoiceCommandConfig copyWith({
    double? confidenceThreshold,
    bool? enableFuzzyMatching,
    bool? enableContextualParsing,
    List<String>? customCommands,
    Map<String, String>? commandAliases,
    bool? enableMultiLanguage,
    String? primaryLanguage,
    Duration? commandTimeout,
  }) {
    return VoiceCommandConfig(
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      enableFuzzyMatching: enableFuzzyMatching ?? this.enableFuzzyMatching,
      enableContextualParsing: enableContextualParsing ?? this.enableContextualParsing,
      customCommands: customCommands ?? this.customCommands,
      commandAliases: commandAliases ?? this.commandAliases,
      enableMultiLanguage: enableMultiLanguage ?? this.enableMultiLanguage,
      primaryLanguage: primaryLanguage ?? this.primaryLanguage,
      commandTimeout: commandTimeout ?? this.commandTimeout,
    );
  }
}
