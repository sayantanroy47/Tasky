import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'task_enums.dart';
import 'subtask.dart';
import 'recurrence_pattern.dart';

part 'task_model.g.dart';

/// Core task model representing a single task in the system
/// 
/// This is the main entity that represents a task with all its properties,
/// including subtasks, recurrence patterns, and metadata.
@JsonSerializable()
class TaskModel extends Equatable {
  /// Unique identifier for the task
  final String id;
  
  /// Title of the task
  final String title;
  
  /// Optional detailed description
  final String? description;
  
  /// When this task was created
  final DateTime createdAt;
  
  /// When this task was last updated
  final DateTime? updatedAt;
  
  /// When this task is due (optional)
  final DateTime? dueDate;
  
  /// When this task was completed (null if not completed)
  final DateTime? completedAt;
  
  /// Priority level of the task
  final TaskPriority priority;
  
  /// Current status of the task
  final TaskStatus status;
  
  /// List of tags associated with this task
  final List<String> tags;
  
  /// List of subtasks/checklist items
  final List<SubTask> subTasks;
  
  /// Optional location trigger for location-based reminders
  final String? locationTrigger;
  
  /// Recurrence pattern if this is a recurring task
  final RecurrencePattern? recurrence;
  
  /// ID of the project this task belongs to (optional)
  final String? projectId;
  
  /// List of task IDs that this task depends on
  final List<String> dependencies;
  
  /// Additional metadata as key-value pairs
  final Map<String, dynamic> metadata;
  
  /// Whether this task is pinned to the top of lists
  final bool isPinned;
  
  /// Estimated duration in minutes (optional)
  final int? estimatedDuration;
  
  /// Actual time spent on the task in minutes (optional)
  final int? actualDuration;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.updatedAt,
    this.dueDate,
    this.completedAt,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.tags = const [],
    this.subTasks = const [],
    this.locationTrigger,
    this.recurrence,
    this.projectId,
    this.dependencies = const [],
    this.metadata = const {},
    this.isPinned = false,
    this.estimatedDuration,
    this.actualDuration,
  });

  /// Creates a new task with generated ID and current timestamp
  factory TaskModel.create({
    required String title,
    String? description,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
    List<String> tags = const [],
    String? locationTrigger,
    RecurrencePattern? recurrence,
    String? projectId,
    List<String> dependencies = const [],
    Map<String, dynamic> metadata = const {},
    bool isPinned = false,
    int? estimatedDuration,
  }) {
    return TaskModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      priority: priority,
      tags: tags,
      locationTrigger: locationTrigger,
      recurrence: recurrence,
      projectId: projectId,
      dependencies: dependencies,
      metadata: metadata,
      isPinned: isPinned,
      estimatedDuration: estimatedDuration,
    );
  }

  /// Creates a TaskModel from JSON
  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);

  /// Converts this TaskModel to JSON
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  /// Creates a copy of this task with updated fields
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    DateTime? completedAt,
    TaskPriority? priority,
    TaskStatus? status,
    List<String>? tags,
    List<SubTask>? subTasks,
    String? locationTrigger,
    RecurrencePattern? recurrence,
    String? projectId,
    List<String>? dependencies,
    Map<String, dynamic>? metadata,
    bool? isPinned,
    int? estimatedDuration,
    int? actualDuration,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      subTasks: subTasks ?? this.subTasks,
      locationTrigger: locationTrigger ?? this.locationTrigger,
      recurrence: recurrence ?? this.recurrence,
      projectId: projectId ?? this.projectId,
      dependencies: dependencies ?? this.dependencies,
      metadata: metadata ?? this.metadata,
      isPinned: isPinned ?? this.isPinned,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
    );
  }

  /// Marks this task as completed
  TaskModel markCompleted() {
    return copyWith(
      status: TaskStatus.completed,
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Marks this task as in progress
  TaskModel markInProgress() {
    return copyWith(
      status: TaskStatus.inProgress,
      updatedAt: DateTime.now(),
    );
  }

  /// Marks this task as cancelled
  TaskModel markCancelled() {
    return copyWith(
      status: TaskStatus.cancelled,
      updatedAt: DateTime.now(),
    );
  }

  /// Resets this task to pending status
  TaskModel resetToPending() {
    return TaskModel(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      dueDate: dueDate,
      completedAt: null,
      priority: priority,
      status: TaskStatus.pending,
      tags: tags,
      subTasks: subTasks,
      locationTrigger: locationTrigger,
      recurrence: recurrence,
      projectId: projectId,
      dependencies: dependencies,
      metadata: metadata,
      isPinned: isPinned,
      estimatedDuration: estimatedDuration,
      actualDuration: actualDuration,
    );
  }

  /// Adds a tag to this task
  TaskModel addTag(String tag) {
    if (tags.contains(tag)) return this;
    
    return copyWith(
      tags: [...tags, tag],
      updatedAt: DateTime.now(),
    );
  }

  /// Removes a tag from this task
  TaskModel removeTag(String tag) {
    if (!tags.contains(tag)) return this;
    
    final newTags = List<String>.from(tags)..remove(tag);
    return copyWith(
      tags: newTags,
      updatedAt: DateTime.now(),
    );
  }

  /// Adds a subtask to this task
  TaskModel addSubTask(SubTask subTask) {
    return copyWith(
      subTasks: [...subTasks, subTask],
      updatedAt: DateTime.now(),
    );
  }

  /// Updates a subtask in this task
  TaskModel updateSubTask(SubTask updatedSubTask) {
    final index = subTasks.indexWhere((st) => st.id == updatedSubTask.id);
    if (index == -1) return this;
    
    final newSubTasks = List<SubTask>.from(subTasks);
    newSubTasks[index] = updatedSubTask;
    
    return copyWith(
      subTasks: newSubTasks,
      updatedAt: DateTime.now(),
    );
  }

  /// Removes a subtask from this task
  TaskModel removeSubTask(String subTaskId) {
    final newSubTasks = subTasks.where((st) => st.id != subTaskId).toList();
    if (newSubTasks.length == subTasks.length) return this;
    
    return copyWith(
      subTasks: newSubTasks,
      updatedAt: DateTime.now(),
    );
  }

  /// Adds a dependency to this task
  TaskModel addDependency(String taskId) {
    if (dependencies.contains(taskId) || taskId == id) return this;
    
    return copyWith(
      dependencies: [...dependencies, taskId],
      updatedAt: DateTime.now(),
    );
  }

  /// Removes a dependency from this task
  TaskModel removeDependency(String taskId) {
    if (!dependencies.contains(taskId)) return this;
    
    final newDependencies = List<String>.from(dependencies)..remove(taskId);
    return copyWith(
      dependencies: newDependencies,
      updatedAt: DateTime.now(),
    );
  }

  /// Pins or unpins this task
  TaskModel togglePin() {
    return copyWith(
      isPinned: !isPinned,
      updatedAt: DateTime.now(),
    );
  }

  /// Updates the task's metadata
  TaskModel updateMetadata(Map<String, dynamic> newMetadata) {
    final updatedMetadata = Map<String, dynamic>.from(metadata)
      ..addAll(newMetadata);
    
    return copyWith(
      metadata: updatedMetadata,
      updatedAt: DateTime.now(),
    );
  }

  /// Validates the task data
  bool isValid() {
    if (id.isEmpty || title.trim().isEmpty) {
      return false;
    }
    
    // Validate that completed tasks have completion date
    if (status == TaskStatus.completed && completedAt == null) {
      return false;
    }
    
    // Validate that non-completed tasks don't have completion date
    if (status != TaskStatus.completed && completedAt != null) {
      return false;
    }
    
    // Validate subtasks
    for (final subTask in subTasks) {
      if (!subTask.isValid() || subTask.taskId != id) {
        return false;
      }
    }
    
    // Validate recurrence pattern if present
    if (recurrence != null && !recurrence!.isValid()) {
      return false;
    }
    
    // Validate dependencies don't include self
    if (dependencies.contains(id)) {
      return false;
    }
    
    return true;
  }

  /// Returns true if this task is due today
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDue = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return taskDue.isAtSameMomentAs(today);
  }

  /// Returns true if this task is overdue
  bool get isOverdue {
    if (dueDate == null || status.isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  /// Returns true if this task is due within the next 24 hours
  bool get isDueSoon {
    if (dueDate == null || status.isCompleted) return false;
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(hours: 24));
    return dueDate!.isBefore(tomorrow) && dueDate!.isAfter(now);
  }

  /// Returns true if this task has subtasks
  bool get hasSubTasks => subTasks.isNotEmpty;

  /// Returns the completion percentage of subtasks (0.0 to 1.0)
  double get subTaskCompletionPercentage {
    if (subTasks.isEmpty) return 0.0;
    final completedCount = subTasks.where((st) => st.isCompleted).length;
    return completedCount / subTasks.length;
  }

  /// Returns true if all subtasks are completed
  bool get allSubTasksCompleted {
    if (subTasks.isEmpty) return true;
    return subTasks.every((st) => st.isCompleted);
  }

  /// Returns true if this is a recurring task
  bool get isRecurring => recurrence != null && recurrence!.type != RecurrenceType.none;

  /// Returns true if this task belongs to a project
  bool get hasProject => projectId != null && projectId!.isNotEmpty;

  /// Returns true if this task has dependencies
  bool get hasDependencies => dependencies.isNotEmpty;

  /// Returns true if this task has a location trigger
  bool get hasLocationTrigger => locationTrigger != null && locationTrigger!.isNotEmpty;

  /// Returns the number of days until the due date (negative if overdue)
  int? get daysUntilDue {
    if (dueDate == null) return null;
    final now = DateTime.now();
    final difference = dueDate!.difference(now).inDays;
    return difference;
  }

  /// Generates the next recurring task instance
  TaskModel? generateNextRecurrence() {
    if (!isRecurring || status != TaskStatus.completed) return null;
    
    final nextDueDate = recurrence!.getNextOccurrence(
      dueDate ?? createdAt,
      occurrenceCount: 1, // This would need to be tracked separately
    );
    
    if (nextDueDate == null) return null;
    
    return TaskModel.create(
      title: title,
      description: description,
      dueDate: nextDueDate,
      priority: priority,
      tags: tags,
      locationTrigger: locationTrigger,
      recurrence: recurrence,
      projectId: projectId,
      dependencies: dependencies,
      metadata: metadata,
      isPinned: isPinned,
      estimatedDuration: estimatedDuration,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        createdAt,
        updatedAt,
        dueDate,
        completedAt,
        priority,
        status,
        tags,
        subTasks,
        locationTrigger,
        recurrence,
        projectId,
        dependencies,
        metadata,
        isPinned,
        estimatedDuration,
        actualDuration,
      ];

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, status: $status, '
           'priority: $priority, dueDate: $dueDate, '
           'subTasks: ${subTasks.length}, tags: ${tags.length})';
  }
}
