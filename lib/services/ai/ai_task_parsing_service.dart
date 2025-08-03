import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/task_model.dart';
import '../../domain/entities/task_enums.dart';
import '../../domain/entities/subtask.dart';
import 'composite_ai_task_parser.dart';

/// Service for managing AI-powered task parsing with configuration
class AITaskParsingService {
  final CompositeAITaskParser _parser;
  final SharedPreferences _prefs;

  AITaskParsingService({
    required CompositeAITaskParser parser,
    required SharedPreferences prefs,
  })  : _parser = parser,
        _prefs = prefs;

  /// Creates a TaskModel from natural language text
  Future<TaskModel> createTaskFromText(String text) async {
    try {
      final parsedData = await _parser.parseTaskFromText(text);
      
      // Convert subtask strings to SubTask objects
      final subtasks = parsedData.subtasks
          .map((subtaskText) => SubTask.create(
                title: subtaskText,
                taskId: '', // Will be set when task is created
              ))
          .toList();

      return TaskModel.create(
        title: parsedData.title,
        description: parsedData.description,
        dueDate: parsedData.dueDate,
        priority: parsedData.priority,
        tags: parsedData.suggestedTags,
        metadata: {
          ...parsedData.metadata,
          'ai_confidence': parsedData.confidence,
          'original_text': text,
          'parsed_at': DateTime.now().toIso8601String(),
        },
      ).copyWith(subTasks: subtasks);
    } catch (e) {
      // Fallback to basic task creation
      return TaskModel.create(
        title: _extractBasicTitle(text),
        description: text.length > 100 ? text : null,
        metadata: {
          'parsing_error': e.toString(),
          'original_text': text,
          'fallback_used': true,
        },
      );
    }
  }

  /// Enhances an existing task with AI-suggested improvements
  Future<TaskModel> enhanceTask(TaskModel task, String? additionalContext) async {
    if (!isAIEnabled) return task;

    try {
      final contextText = [
        task.title,
        task.description,
        additionalContext,
      ].where((text) => text != null && text.isNotEmpty).join(' ');

      final suggestions = await _parser.suggestTags(contextText);
      final existingTags = Set<String>.from(task.tags);
      final newTags = suggestions.where((tag) => !existingTags.contains(tag)).toList();

      if (newTags.isNotEmpty) {
        return task.copyWith(
          tags: [...task.tags, ...newTags.take(3)], // Add up to 3 new tags
          metadata: {
            ...task.metadata,
            'ai_enhanced': true,
            'suggested_tags': newTags,
            'enhanced_at': DateTime.now().toIso8601String(),
          },
        );
      }
    } catch (e) {
      // Fail silently for enhancement
    }

    return task;
  }

  /// Suggests tags for a task
  Future<List<String>> suggestTagsForTask(String taskText) async {
    try {
      return await _parser.suggestTags(taskText);
    } catch (e) {
      return [];
    }
  }

  /// Extracts due date from text
  Future<DateTime?> extractDueDateFromText(String text) async {
    try {
      return await _parser.extractDueDate(text);
    } catch (e) {
      return null;
    }
  }

  /// Determines priority from text
  Future<TaskPriority> determinePriorityFromText(String text) async {
    try {
      return await _parser.determinePriority(text);
    } catch (e) {
      return TaskPriority.medium;
    }
  }

  /// Gets the current AI service being used
  String get currentServiceName => _parser.serviceName;

  /// Checks if AI parsing is enabled
  bool get isAIEnabled => _prefs.getBool('ai_parsing_enabled') ?? false;

  /// Checks if the AI service is available
  bool get isServiceAvailable => _parser.isAvailable;

  /// Gets available AI services
  List<AIServiceType> get availableServices => _parser.getAvailableServices();

  /// Gets current AI service type
  AIServiceType get currentService {
    final serviceString = _prefs.getString('ai_service_type') ?? 'local';
    return AIServiceType.values.firstWhere(
      (type) => type.name == serviceString,
      orElse: () => AIServiceType.local,
    );
  }

  /// Enables or disables AI parsing
  Future<void> setAIEnabled(bool enabled) async {
    await _prefs.setBool('ai_parsing_enabled', enabled);
  }

  /// Sets the preferred AI service
  Future<void> setAIService(AIServiceType service) async {
    await _prefs.setString('ai_service_type', service.name);
  }

  /// Gets AI usage statistics
  Map<String, dynamic> getUsageStats() {
    return {
      'ai_enabled': isAIEnabled,
      'current_service': currentService.displayName,
      'service_available': isServiceAvailable,
      'total_parses': _prefs.getInt('ai_total_parses') ?? 0,
      'successful_parses': _prefs.getInt('ai_successful_parses') ?? 0,
      'last_used': _prefs.getString('ai_last_used'),
    };
  }

  /// Records AI usage for statistics
  // Future<void> _recordUsage() async {
  //   await _prefs.setString('ai_last_used', DateTime.now().toIso8601String());
  // }

  /// Basic title extraction fallback
  String _extractBasicTitle(String text) {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return 'New Task';

    // Take first sentence or first 50 characters
    final sentences = cleanText.split(RegExp(r'[.!?]'));
    final firstSentence = sentences.first.trim();
    
    if (firstSentence.isNotEmpty) {
      return firstSentence.length > 100 
          ? '${firstSentence.substring(0, 100)}...'
          : firstSentence;
    }

    return cleanText.length > 50 ? '${cleanText.substring(0, 50)}...' : cleanText;
  }

  /// Disposes the service
  void dispose() {
    _parser.dispose();
  }
}

/// Provider for AI task parsing service
final aiTaskParsingServiceProvider = Provider<AITaskParsingService>((ref) {
  throw UnimplementedError('AITaskParsingService provider must be overridden');
});

/// Provider for AI parsing configuration
final aiParsingConfigProvider = StateNotifierProvider<AIParsingConfigNotifier, AIParsingConfig>((ref) {
  return AIParsingConfigNotifier();
});

/// Configuration state for AI parsing
class AIParsingConfig {
  final bool enabled;
  final AIServiceType serviceType;
  final bool showConfidence;
  final bool autoApplyTags;
  final bool autoApplyPriority;
  final bool autoApplyDueDate;

  const AIParsingConfig({
    this.enabled = false,
    this.serviceType = AIServiceType.local,
    this.showConfidence = true,
    this.autoApplyTags = true,
    this.autoApplyPriority = true,
    this.autoApplyDueDate = true,
  });

  AIParsingConfig copyWith({
    bool? enabled,
    AIServiceType? serviceType,
    bool? showConfidence,
    bool? autoApplyTags,
    bool? autoApplyPriority,
    bool? autoApplyDueDate,
  }) {
    return AIParsingConfig(
      enabled: enabled ?? this.enabled,
      serviceType: serviceType ?? this.serviceType,
      showConfidence: showConfidence ?? this.showConfidence,
      autoApplyTags: autoApplyTags ?? this.autoApplyTags,
      autoApplyPriority: autoApplyPriority ?? this.autoApplyPriority,
      autoApplyDueDate: autoApplyDueDate ?? this.autoApplyDueDate,
    );
  }
}

/// State notifier for AI parsing configuration
class AIParsingConfigNotifier extends StateNotifier<AIParsingConfig> {
  AIParsingConfigNotifier() : super(const AIParsingConfig());

  void setEnabled(bool enabled) {
    state = state.copyWith(enabled: enabled);
  }

  void setServiceType(AIServiceType serviceType) {
    state = state.copyWith(serviceType: serviceType);
  }

  void setShowConfidence(bool show) {
    state = state.copyWith(showConfidence: show);
  }

  void setAutoApplyTags(bool autoApply) {
    state = state.copyWith(autoApplyTags: autoApply);
  }

  void setAutoApplyPriority(bool autoApply) {
    state = state.copyWith(autoApplyPriority: autoApply);
  }

  void setAutoApplyDueDate(bool autoApply) {
    state = state.copyWith(autoApplyDueDate: autoApply);
  }
}
