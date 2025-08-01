import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'task_enums.dart';
import 'subtask.dart';
import 'recurrence_pattern.dart';
import 'task_model.dart';

part 'task_template.g.dart';

/// Template for creating tasks with predefined settings
/// 
/// Task templates allow users to quickly create tasks with predefined
/// titles, descriptions, priorities, tags, and other settings.
@JsonSerializable()
class TaskTemplate extends Equatable {
  /// Unique identifier for the template
  final String id;
  
  /// Name of the template
  final String name;
  
  /// Optional description of what this template is for
  final String? description;
  
  /// Template for the task title
  final String titleTemplate;
  
  /// Template for the task description
  final String? descriptionTemplate;
  
  /// Default priority for tasks created from this template
  final TaskPriority priority;
  
  /// Default tags for tasks created from this template
  final List<String> tags;
  
  /// Default subtasks for tasks created from this template
  final List<SubTask> subTaskTemplates;
  
  /// Default location trigger for tasks created from this template
  final String? locationTrigger;
  
  /// Default recurrence pattern for tasks created from this template
  final RecurrencePattern? recurrence;
  
  /// Default project ID for tasks created from this template
  final String? projectId;
  
  /// Default estimated duration in minutes
  final int? estimatedDuration;
  
  /// Additional metadata for the template
  final Map<String, dynamic> metadata;
  
  /// When this template was created
  final DateTime createdAt;
  
  /// When this template was last updated
  final DateTime? updatedAt;
  
  /// How many times this template has been used
  final int usageCount;
  
  /// Whether this template is marked as favorite
  final bool isFavorite;
  
  /// Category of the template (e.g., "Work", "Personal", "Health")
  final String? category;

  const TaskTemplate({
    required this.id,
    required this.name,
    this.description,
    required this.titleTemplate,
    this.descriptionTemplate,
    this.priority = TaskPriority.medium,
    this.tags = const [],
    this.subTaskTemplates = const [],
    this.locationTrigger,
    this.recurrence,
    this.projectId,
    this.estimatedDuration,
    this.metadata = const {},
    required this.createdAt,
    this.updatedAt,
    this.usageCount = 0,
    this.isFavorite = false,
    this.category,
  });

  /// Creates a new template with generated ID and current timestamp
  factory TaskTemplate.create({
    required String name,
    String? description,
    required String titleTemplate,
    String? descriptionTemplate,
    TaskPriority priority = TaskPriority.medium,
    List<String> tags = const [],
    List<SubTask> subTaskTemplates = const [],
    String? locationTrigger,
    RecurrencePattern? recurrence,
    String? projectId,
    int? estimatedDuration,
    Map<String, dynamic> metadata = const {},
    bool isFavorite = false,
    String? category,
  }) {
    return TaskTemplate(
      id: const Uuid().v4(),
      name: name,
      description: description,
      titleTemplate: titleTemplate,
      descriptionTemplate: descriptionTemplate,
      priority: priority,
      tags: tags,
      subTaskTemplates: subTaskTemplates,
      locationTrigger: locationTrigger,
      recurrence: recurrence,
      projectId: projectId,
      estimatedDuration: estimatedDuration,
      metadata: metadata,
      createdAt: DateTime.now(),
      isFavorite: isFavorite,
      category: category,
    );
  }

  /// Creates a template from an existing task
  factory TaskTemplate.fromTask({
    required TaskModel task,
    required String name,
    String? description,
    String? category,
  }) {
    return TaskTemplate.create(
      name: name,
      description: description,
      titleTemplate: task.title,
      descriptionTemplate: task.description,
      priority: task.priority,
      tags: task.tags,
      subTaskTemplates: task.subTasks,
      locationTrigger: task.locationTrigger,
      recurrence: task.recurrence,
      projectId: task.projectId,
      estimatedDuration: task.estimatedDuration,
      metadata: task.metadata,
      category: category,
    );
  }

  /// Creates a TaskTemplate from JSON
  factory TaskTemplate.fromJson(Map<String, dynamic> json) => 
      _$TaskTemplateFromJson(json);

  /// Converts this TaskTemplate to JSON
  Map<String, dynamic> toJson() => _$TaskTemplateToJson(this);

  /// Creates a copy of this template with updated fields
  TaskTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? titleTemplate,
    String? descriptionTemplate,
    TaskPriority? priority,
    List<String>? tags,
    List<SubTask>? subTaskTemplates,
    String? locationTrigger,
    RecurrencePattern? recurrence,
    String? projectId,
    int? estimatedDuration,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? usageCount,
    bool? isFavorite,
    String? category,
  }) {
    return TaskTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      titleTemplate: titleTemplate ?? this.titleTemplate,
      descriptionTemplate: descriptionTemplate ?? this.descriptionTemplate,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      subTaskTemplates: subTaskTemplates ?? this.subTaskTemplates,
      locationTrigger: locationTrigger ?? this.locationTrigger,
      recurrence: recurrence ?? this.recurrence,
      projectId: projectId ?? this.projectId,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      usageCount: usageCount ?? this.usageCount,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
    );
  }

  /// Creates a task from this template
  TaskModel createTask({
    String? customTitle,
    String? customDescription,
    DateTime? dueDate,
    Map<String, String> placeholders = const {},
  }) {
    // Replace placeholders in title and description
    final String finalTitle = customTitle ?? _replacePlaceholders(titleTemplate, placeholders);
    final String? finalDescription = customDescription ?? 
        (descriptionTemplate != null ? _replacePlaceholders(descriptionTemplate!, placeholders) : null);

    // Create subtasks from templates
    final List<SubTask> finalSubTasks = subTaskTemplates.map((template) {
      return SubTask.create(
        title: _replacePlaceholders(template.title, placeholders),
        taskId: '', // Will be set when the task is created
      );
    }).toList();

    return TaskModel.create(
      title: finalTitle,
      description: finalDescription,
      dueDate: dueDate,
      priority: priority,
      tags: List.from(tags),
      locationTrigger: locationTrigger,
      recurrence: recurrence,
      projectId: projectId,
      estimatedDuration: estimatedDuration,
      metadata: Map.from(metadata),
    ).copyWith(subTasks: finalSubTasks);
  }

  /// Replaces placeholders in text with provided values
  String _replacePlaceholders(String text, Map<String, String> placeholders) {
    String result = text;
    for (final entry in placeholders.entries) {
      result = result.replaceAll('{{${entry.key}}}', entry.value);
    }
    
    // Replace common date placeholders
    final now = DateTime.now();
    result = result.replaceAll('{{today}}', _formatDate(now));
    result = result.replaceAll('{{tomorrow}}', _formatDate(now.add(const Duration(days: 1))));
    result = result.replaceAll('{{next_week}}', _formatDate(now.add(const Duration(days: 7))));
    
    return result;
  }

  /// Formats a date for placeholder replacement
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Increments the usage count
  TaskTemplate incrementUsage() {
    return copyWith(
      usageCount: usageCount + 1,
      updatedAt: DateTime.now(),
    );
  }

  /// Toggles the favorite status
  TaskTemplate toggleFavorite() {
    return copyWith(
      isFavorite: !isFavorite,
      updatedAt: DateTime.now(),
    );
  }

  /// Validates the template data
  bool isValid() {
    if (id.isEmpty || name.trim().isEmpty || titleTemplate.trim().isEmpty) {
      return false;
    }
    
    // Validate subtask templates
    for (final subTask in subTaskTemplates) {
      if (!subTask.isValid()) {
        return false;
      }
    }
    
    // Validate recurrence pattern if present
    if (recurrence != null && !recurrence!.isValid()) {
      return false;
    }
    
    return true;
  }

  /// Returns true if this template has subtasks
  bool get hasSubTasks => subTaskTemplates.isNotEmpty;

  /// Returns true if this template has a recurrence pattern
  bool get isRecurring => recurrence != null && recurrence!.type != RecurrenceType.none;

  /// Returns true if this template belongs to a project
  bool get hasProject => projectId != null && projectId!.isNotEmpty;

  /// Returns true if this template has a location trigger
  bool get hasLocationTrigger => locationTrigger != null && locationTrigger!.isNotEmpty;

  /// Returns true if this template has a category
  bool get hasCategory => category != null && category!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        titleTemplate,
        descriptionTemplate,
        priority,
        tags,
        subTaskTemplates,
        locationTrigger,
        recurrence,
        projectId,
        estimatedDuration,
        metadata,
        createdAt,
        updatedAt,
        usageCount,
        isFavorite,
        category,
      ];

  @override
  String toString() {
    return 'TaskTemplate(id: $id, name: $name, titleTemplate: $titleTemplate, '
           'priority: $priority, tags: ${tags.length}, usageCount: $usageCount)';
  }
}
