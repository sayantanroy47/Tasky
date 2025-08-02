import '../../domain/entities/task_enums.dart';
import 'voice_command_models.dart';

/// Service for parsing voice commands from transcribed text
class VoiceCommandParser {
  final VoiceCommandConfig config;
  
  // Command patterns for different types of voice commands
  static const Map<VoiceCommandType, List<String>> _commandPatterns = {
    VoiceCommandType.createTask: [
      r'create task (.+)',
      r'create (.+) task (.+)',
      r'create (.+)',
      r'add task (.+)',
      r'new task (.+)',
      r'make task (.+)',
      r'add (.+) to my tasks',
      r'remind me to (.+)',
      r'i need to (.+)',
    ],
    VoiceCommandType.completeTask: [
      r'complete task (.+)',
      r'mark (.+) as complete',
      r'mark (.+) as done',
      r'finish task (.+)',
      r'done with (.+)',
      r'completed (.+)',
      r'mark complete (.+)',
      r'i finished (.+)',
      r'i completed (.+)',
    ],
    VoiceCommandType.deleteTask: [
      r'delete task (.+)',
      r'remove task (.+)',
      r'cancel task (.+)',
      r'delete (.+)',
      r'remove (.+)',
      r'get rid of (.+)',
    ],
    VoiceCommandType.rescheduleTask: [
      r'reschedule (.+) to (.+)',
      r'move (.+) to (.+)',
      r'change (.+) due date to (.+)',
      r'postpone (.+) to (.+)',
      r'delay (.+) until (.+)',
    ],
    VoiceCommandType.setPriority: [
      r'set (.+) priority to (.+)',
      r'make (.+) (.+) priority',
      r'change (.+) priority to (.+)',
      r'(.+) is (.+) priority',
    ],
    VoiceCommandType.addTag: [
      r'add tag (.+) to (.+)',
      r'tag (.+) with (.+)',
      r'label (.+) as (.+)',
    ],
    VoiceCommandType.searchTasks: [
      r'search for (.+)',
      r'find tasks (.+)',
      r'show me (.+)',
      r'look for (.+)',
      r'find (.+)',
    ],
    VoiceCommandType.listTasks: [
      r'list tasks',
      r'show tasks',
      r'what are my tasks',
      r'show my tasks',
      r'list all tasks',
      r'what do i need to do',
    ],
    VoiceCommandType.markInProgress: [
      r'start working on (.+)',
      r'begin (.+)',
      r'start (.+)',
      r'mark (.+) in progress',
    ],
    VoiceCommandType.addSubtask: [
      r'add subtask (.+) to (.+)',
      r'add (.+) as subtask to (.+)',
      r'create subtask (.+) for (.+)',
    ],
  };

  // Priority keywords mapping
  static const Map<String, TaskPriority> _priorityKeywords = {
    'low': TaskPriority.low,
    'medium': TaskPriority.medium,
    'normal': TaskPriority.medium,
    'high': TaskPriority.high,
    'urgent': TaskPriority.urgent,
    'critical': TaskPriority.urgent,
    'important': TaskPriority.high,
  };

  // Date/time keywords and patterns
  static const Map<String, int> _dateKeywords = {
    'today': 0,
    'tomorrow': 1,
    'day after tomorrow': 2,
    'next week': 7,
    'next monday': -1, // Special handling needed
    'next tuesday': -1,
    'next wednesday': -1,
    'next thursday': -1,
    'next friday': -1,
    'next saturday': -1,
    'next sunday': -1,
  };

  const VoiceCommandParser({
    this.config = const VoiceCommandConfig(),
  });

  /// Parses a transcribed text into a voice command
  Future<VoiceCommand> parseCommand(String transcription) async {
    if (transcription.trim().isEmpty) {
      return VoiceCommand.unknown(
        originalText: transcription,
        errorMessage: 'Empty transcription',
      );
    }

    final normalizedText = _normalizeText(transcription);
    
    // Try to match against known command patterns in priority order
    final prioritizedTypes = [
      VoiceCommandType.listTasks,
      VoiceCommandType.createTask, // Create task should be early to match specific patterns
      VoiceCommandType.completeTask,
      VoiceCommandType.deleteTask,
      VoiceCommandType.rescheduleTask,
      VoiceCommandType.setPriority,
      VoiceCommandType.addTag,
      VoiceCommandType.searchTasks,
      VoiceCommandType.markInProgress,
      VoiceCommandType.addSubtask,
    ];
    
    for (final commandType in prioritizedTypes) {
      final patterns = _commandPatterns[commandType] ?? [];
      for (final pattern in patterns) {
        final match = RegExp(pattern, caseSensitive: false).firstMatch(normalizedText);
        if (match != null) {
          return await _buildCommand(commandType, match, transcription);
        }
      }
    }

    // If no specific pattern matches, try to infer the command type
    return await _inferCommand(transcription);
  }

  /// Normalizes text for better pattern matching
  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .replaceAll('gonna', 'going to')
        .replaceAll('wanna', 'want to')
        .replaceAll('gotta', 'got to')
        .replaceAll('hafta', 'have to')
        .replaceAll('lemme', 'let me');
  }

  /// Builds a voice command from a matched pattern
  Future<VoiceCommand> _buildCommand(
    VoiceCommandType type,
    RegExpMatch match,
    String originalText,
  ) async {
    switch (type) {
      case VoiceCommandType.createTask:
        return _buildCreateTaskCommand(match, originalText);
      
      case VoiceCommandType.completeTask:
        return _buildCompleteTaskCommand(match, originalText);
      
      case VoiceCommandType.deleteTask:
        return _buildDeleteTaskCommand(match, originalText);
      
      case VoiceCommandType.rescheduleTask:
        return _buildRescheduleTaskCommand(match, originalText);
      
      case VoiceCommandType.setPriority:
        return _buildSetPriorityCommand(match, originalText);
      
      case VoiceCommandType.addTag:
        return _buildAddTagCommand(match, originalText);
      
      case VoiceCommandType.searchTasks:
        return _buildSearchTasksCommand(match, originalText);
      
      case VoiceCommandType.listTasks:
        return VoiceCommand(
          type: VoiceCommandType.listTasks,
          confidence: CommandConfidence.high,
          originalText: originalText,
          timestamp: DateTime.now(),
        );
      
      case VoiceCommandType.markInProgress:
        return _buildMarkInProgressCommand(match, originalText);
      
      case VoiceCommandType.addSubtask:
        return _buildAddSubtaskCommand(match, originalText);
      
      default:
        return VoiceCommand.unknown(
          originalText: originalText,
          errorMessage: 'Unsupported command type: $type',
        );
    }
  }

  /// Builds a create task command
  VoiceCommand _buildCreateTaskCommand(RegExpMatch match, String originalText) {
    // Handle different patterns with different capture groups
    String taskTitle = '';
    
    // For patterns like "create (.+) task (.+)", we want the last group
    if (match.groupCount >= 2 && match.group(2) != null && match.group(2)!.trim().isNotEmpty) {
      taskTitle = match.group(2)!.trim();
    } else if (match.group(1) != null) {
      taskTitle = match.group(1)!.trim();
    }
    
    if (taskTitle.isEmpty) {
      return VoiceCommand.unknown(
        originalText: originalText,
        errorMessage: 'No task title found',
      );
    }

    // Extract priority from the original text (before cleaning)
    final priority = _extractPriority(originalText);
    
    // Extract due date from the original text
    final dueDate = _extractDueDate(originalText);
    
    // Extract tags from the original text
    final tags = _extractTags(originalText);
    
    // Clean the task title by removing extracted information
    final cleanTitle = _cleanTaskTitle(taskTitle, priority, dueDate, tags);

    return VoiceCommand.createTask(
      originalText: originalText,
      taskTitle: cleanTitle,
      confidence: _calculateConfidence(originalText, taskTitle),
      priority: priority,
      dueDate: dueDate,
      tags: tags,
    );
  }

  /// Builds a complete task command
  VoiceCommand _buildCompleteTaskCommand(RegExpMatch match, String originalText) {
    final taskTitle = match.group(1)?.trim() ?? '';
    
    return VoiceCommand.completeTask(
      originalText: originalText,
      taskTitle: taskTitle.isNotEmpty ? taskTitle : null,
      confidence: _calculateConfidence(originalText, taskTitle),
    );
  }

  /// Builds a delete task command
  VoiceCommand _buildDeleteTaskCommand(RegExpMatch match, String originalText) {
    final taskTitle = match.group(1)?.trim() ?? '';
    
    return VoiceCommand.deleteTask(
      originalText: originalText,
      taskTitle: taskTitle.isNotEmpty ? taskTitle : null,
      confidence: _calculateConfidence(originalText, taskTitle),
    );
  }

  /// Builds a reschedule task command
  VoiceCommand _buildRescheduleTaskCommand(RegExpMatch match, String originalText) {
    final taskTitle = match.group(1)?.trim() ?? '';
    final dateText = match.group(2)?.trim() ?? '';
    
    final newDueDate = _extractDueDate(dateText);
    
    return VoiceCommand.rescheduleTask(
      originalText: originalText,
      taskTitle: taskTitle.isNotEmpty ? taskTitle : null,
      newDueDate: newDueDate,
      confidence: _calculateConfidence(originalText, taskTitle),
    );
  }

  /// Builds a set priority command
  VoiceCommand _buildSetPriorityCommand(RegExpMatch match, String originalText) {
    final taskTitle = match.group(1)?.trim() ?? '';
    final priorityText = match.group(2)?.trim() ?? '';
    
    final priority = _priorityKeywords[priorityText.toLowerCase()];
    
    return VoiceCommand.setPriority(
      originalText: originalText,
      taskTitle: taskTitle.isNotEmpty ? taskTitle : null,
      priority: priority ?? TaskPriority.medium,
      confidence: priority != null ? CommandConfidence.high : CommandConfidence.medium,
    );
  }

  /// Builds an add tag command
  VoiceCommand _buildAddTagCommand(RegExpMatch match, String originalText) {
    final tag = match.group(1)?.trim() ?? '';
    final taskTitle = match.group(2)?.trim() ?? '';
    
    return VoiceCommand(
      type: VoiceCommandType.addTag,
      confidence: _calculateConfidence(originalText, taskTitle),
      originalText: originalText,
      timestamp: DateTime.now(),
      taskTitle: taskTitle.isNotEmpty ? taskTitle : null,
      tags: tag.isNotEmpty ? [tag] : [],
      parameters: {
        'tag': tag,
        if (taskTitle.isNotEmpty) 'taskTitle': taskTitle,
      },
    );
  }

  /// Builds a search tasks command
  VoiceCommand _buildSearchTasksCommand(RegExpMatch match, String originalText) {
    final searchQuery = match.group(1)?.trim() ?? '';
    
    return VoiceCommand.searchTasks(
      originalText: originalText,
      searchQuery: searchQuery,
      confidence: searchQuery.isNotEmpty ? CommandConfidence.high : CommandConfidence.low,
    );
  }

  /// Builds a mark in progress command
  VoiceCommand _buildMarkInProgressCommand(RegExpMatch match, String originalText) {
    final taskTitle = match.group(1)?.trim() ?? '';
    
    return VoiceCommand(
      type: VoiceCommandType.markInProgress,
      confidence: _calculateConfidence(originalText, taskTitle),
      originalText: originalText,
      timestamp: DateTime.now(),
      taskTitle: taskTitle.isNotEmpty ? taskTitle : null,
      status: TaskStatus.inProgress,
      parameters: {
        if (taskTitle.isNotEmpty) 'taskTitle': taskTitle,
        'status': TaskStatus.inProgress.name,
      },
    );
  }

  /// Builds an add subtask command
  VoiceCommand _buildAddSubtaskCommand(RegExpMatch match, String originalText) {
    final subtaskTitle = match.group(1)?.trim() ?? '';
    final taskTitle = match.group(2)?.trim() ?? '';
    
    return VoiceCommand(
      type: VoiceCommandType.addSubtask,
      confidence: _calculateConfidence(originalText, taskTitle),
      originalText: originalText,
      timestamp: DateTime.now(),
      taskTitle: taskTitle.isNotEmpty ? taskTitle : null,
      subtaskTitle: subtaskTitle.isNotEmpty ? subtaskTitle : null,
      parameters: {
        if (subtaskTitle.isNotEmpty) 'subtaskTitle': subtaskTitle,
        if (taskTitle.isNotEmpty) 'taskTitle': taskTitle,
      },
    );
  }

  /// Attempts to infer command type from unmatched text
  Future<VoiceCommand> _inferCommand(String normalizedText) async {
    // Check if it looks like a task creation (most common case)
    if (_looksLikeTaskCreation(normalizedText)) {
      final match = RegExp(r'(.+)').firstMatch(normalizedText);
      if (match != null) {
        return _buildCreateTaskCommand(match, normalizedText);
      }
    }

    // Check if it looks like a search query
    if (_looksLikeSearch(normalizedText)) {
      return VoiceCommand.searchTasks(
        originalText: normalizedText,
        searchQuery: normalizedText,
        confidence: CommandConfidence.medium,
      );
    }

    return VoiceCommand.unknown(
      originalText: normalizedText,
      errorMessage: 'Could not determine command type',
    );
  }

  /// Checks if text looks like a task creation command
  bool _looksLikeTaskCreation(String text) {
    final taskCreationIndicators = [
      'buy', 'call', 'email', 'write', 'read', 'finish', 'complete',
      'prepare', 'schedule', 'book', 'order', 'pay', 'send', 'review',
      'update', 'fix', 'clean', 'organize', 'plan', 'research',
    ];

    return taskCreationIndicators.any((indicator) => 
        text.toLowerCase().contains(indicator));
  }

  /// Checks if text looks like a search query
  bool _looksLikeSearch(String text) {
    final searchIndicators = ['where', 'what', 'when', 'how', 'show', 'find'];
    return searchIndicators.any((indicator) => 
        text.toLowerCase().startsWith(indicator));
  }

  /// Extracts priority from task text
  TaskPriority? _extractPriority(String text) {
    for (final entry in _priorityKeywords.entries) {
      if (text.toLowerCase().contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  /// Extracts due date from text
  DateTime? _extractDueDate(String text) {
    final lowerText = text.toLowerCase();
    
    // Check for relative date keywords, sorted by length (longest first)
    final sortedKeywords = _dateKeywords.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    
    for (final entry in sortedKeywords) {
      if (lowerText.contains(entry.key)) {
        if (entry.value >= 0) {
          return DateTime.now().add(Duration(days: entry.value));
        } else {
          // Handle "next [day]" patterns
          return _getNextWeekday(entry.key.replaceAll('next ', ''));
        }
      }
    }

    // Check for time patterns (e.g., "at 3pm", "by 5:30")
    final timePattern = RegExp(r'(?:at|by)\s+(\d{1,2})(?::(\d{2}))?\s*(am|pm)?');
    final timeMatch = timePattern.firstMatch(lowerText);
    if (timeMatch != null) {
      final hour = int.parse(timeMatch.group(1)!);
      final minute = int.tryParse(timeMatch.group(2) ?? '0') ?? 0;
      final ampm = timeMatch.group(3);
      
      var adjustedHour = hour;
      if (ampm == 'pm' && hour != 12) {
        adjustedHour += 12;
      } else if (ampm == 'am' && hour == 12) {
        adjustedHour = 0;
      }
      
      final now = DateTime.now();
      var targetTime = DateTime(now.year, now.month, now.day, adjustedHour, minute);
      
      // If the time has passed today, schedule for tomorrow
      if (targetTime.isBefore(now)) {
        targetTime = targetTime.add(const Duration(days: 1));
      }
      
      return targetTime;
    }

    return null;
  }

  /// Gets the next occurrence of a specific weekday
  DateTime? _getNextWeekday(String dayName) {
    final dayMap = {
      'monday': DateTime.monday,
      'tuesday': DateTime.tuesday,
      'wednesday': DateTime.wednesday,
      'thursday': DateTime.thursday,
      'friday': DateTime.friday,
      'saturday': DateTime.saturday,
      'sunday': DateTime.sunday,
    };

    final targetDay = dayMap[dayName.toLowerCase()];
    if (targetDay == null) return null;

    final now = DateTime.now();
    final daysUntilTarget = (targetDay - now.weekday) % 7;
    final daysToAdd = daysUntilTarget == 0 ? 7 : daysUntilTarget; // Next week if today
    
    return now.add(Duration(days: daysToAdd));
  }

  /// Extracts tags from task text (looks for hashtags or "tagged with" patterns)
  List<String> _extractTags(String text) {
    final tags = <String>[];
    
    // Extract hashtags
    final hashtagPattern = RegExp(r'#(\w+)');
    final hashtagMatches = hashtagPattern.allMatches(text);
    for (final match in hashtagMatches) {
      tags.add(match.group(1)!);
    }
    
    // Extract "tagged with" patterns
    final taggedPattern = RegExp(r'tagged? with (.+?)(?:\s|$)');
    final taggedMatch = taggedPattern.firstMatch(text.toLowerCase());
    if (taggedMatch != null) {
      final tagText = taggedMatch.group(1)!;
      tags.addAll(tagText.split(RegExp(r'[,\s]+'))
          .where((tag) => tag.isNotEmpty));
    }
    
    return tags;
  }

  /// Cleans task title by removing extracted information
  String _cleanTaskTitle(
    String title,
    TaskPriority? priority,
    DateTime? dueDate,
    List<String> tags,
  ) {
    var cleanTitle = title;
    
    // Remove priority keywords (only if they appear as separate words)
    if (priority != null) {
      for (final keyword in _priorityKeywords.keys) {
        cleanTitle = cleanTitle.replaceAll(RegExp(r'\b' + keyword + r'\b\s*', caseSensitive: false), '');
        cleanTitle = cleanTitle.replaceAll(RegExp(r'\s*\b' + keyword + r'\s+priority\b', caseSensitive: false), '');
      }
    }
    
    // Remove date keywords (only if they appear as separate words)
    for (final keyword in _dateKeywords.keys) {
      cleanTitle = cleanTitle.replaceAll(RegExp(r'\b' + keyword + r'\b', caseSensitive: false), '');
    }
    
    // Remove time patterns
    cleanTitle = cleanTitle.replaceAll(RegExp(r'(?:at|by)\s+\d{1,2}(?::\d{2})?\s*(?:am|pm)?', caseSensitive: false), '');
    
    // Remove hashtags
    cleanTitle = cleanTitle.replaceAll(RegExp(r'#\w+'), '');
    
    // Remove "tagged with" patterns
    cleanTitle = cleanTitle.replaceAll(RegExp(r'tagged? with .+', caseSensitive: false), '');
    
    // Clean up whitespace and extra words
    cleanTitle = cleanTitle.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // If the cleaned title is too short or empty, return the original
    if (cleanTitle.length < 3) {
      return title;
    }
    
    return cleanTitle;
  }

  /// Calculates confidence level for a command
  CommandConfidence _calculateConfidence(String originalText, String extractedContent) {
    if (extractedContent.isEmpty) return CommandConfidence.low;
    
    final originalLength = originalText.length;
    final extractedLength = extractedContent.length;
    
    // Base confidence on content ratio
    final ratio = extractedLength / originalLength;
    
    // Boost confidence if we have clear command structure
    final lowerOriginal = originalText.toLowerCase();
    bool hasStrongIndicators = false;
    
    // Check for strong command indicators
    if (lowerOriginal.contains(RegExp(r'\b(create|add|new|make)\s+(task|todo)\b')) ||
        lowerOriginal.contains(RegExp(r'\b(complete|finish|done)\s+(task)?\b')) ||
        lowerOriginal.contains(RegExp(r'\b(delete|remove|cancel)\s+(task)?\b'))) {
      hasStrongIndicators = true;
    }
    
    // Check if we extracted additional structured information
    final bool hasAdditionalInfo = _extractPriority(originalText) != null ||
                            _extractDueDate(originalText) != null ||
                            _extractTags(originalText).isNotEmpty;
    
    if (hasStrongIndicators && ratio > 0.2) return CommandConfidence.high;
    if (hasAdditionalInfo && ratio > 0.3) return CommandConfidence.high;
    if (ratio > 0.7) return CommandConfidence.high;
    if (ratio > 0.4) return CommandConfidence.medium;
    return CommandConfidence.low;
  }
}

