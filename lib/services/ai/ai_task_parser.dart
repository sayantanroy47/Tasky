import '../../domain/entities/task_enums.dart';

/// Interface for AI-powered task parsing services
abstract class AITaskParser {
  /// Parses natural language text into structured task data
  Future<ParsedTaskData> parseTaskFromText(String text);
  
  /// Suggests tags based on task content
  Future<List<String>> suggestTags(String taskText);
  
  /// Extracts due date from natural language text
  Future<DateTime?> extractDueDate(String text);
  
  /// Determines task priority from text content
  Future<TaskPriority> determinePriority(String text);
  
  /// Extracts subtasks from text content
  Future<List<String>> extractSubtasks(String text);
  
  /// Determines if the service is available and configured
  bool get isAvailable;
  
  /// Returns the name of the AI service being used
  String get serviceName;
}

/// Data class containing parsed task information from AI
class ParsedTaskData {
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final List<String> suggestedTags;
  final List<String> subtasks;
  final double confidence;
  final Map<String, dynamic> metadata;

  const ParsedTaskData({
    required this.title,
    this.description,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.suggestedTags = const [],
    this.subtasks = const [],
    this.confidence = 0.0,
    this.metadata = const {},
  });

  /// Creates a copy with updated fields
  ParsedTaskData copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    List<String>? suggestedTags,
    List<String>? subtasks,
    double? confidence,
    Map<String, dynamic>? metadata,
  }) {
    return ParsedTaskData(
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      suggestedTags: suggestedTags ?? this.suggestedTags,
      subtasks: subtasks ?? this.subtasks,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'ParsedTaskData(title: $title, priority: $priority, '
           'dueDate: $dueDate, tags: ${suggestedTags.length}, '
           'subtasks: ${subtasks.length}, confidence: $confidence)';
  }
}

/// Exception thrown when AI parsing fails
class AIParsingException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  const AIParsingException(this.message, {this.code, this.originalError});
  
  @override
  String toString() => 'AIParsingException: $message';
}