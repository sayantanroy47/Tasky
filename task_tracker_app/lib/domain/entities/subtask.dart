import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'subtask.g.dart';

/// Represents a subtask or checklist item within a main task
/// 
/// SubTasks are used to break down complex tasks into smaller, manageable pieces.
/// They maintain their own completion status and can be reordered within a task.
@JsonSerializable()
class SubTask extends Equatable {
  /// Unique identifier for the subtask
  final String id;
  
  /// The parent task ID this subtask belongs to
  final String taskId;
  
  /// Title/description of the subtask
  final String title;
  
  /// Whether this subtask has been completed
  final bool isCompleted;
  
  /// When this subtask was completed (null if not completed)
  final DateTime? completedAt;
  
  /// Sort order within the parent task (0-based)
  final int sortOrder;
  
  /// When this subtask was created
  final DateTime createdAt;

  const SubTask({
    required this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
    this.completedAt,
    this.sortOrder = 0,
    required this.createdAt,
  });

  /// Creates a new subtask with generated ID and current timestamp
  factory SubTask.create({
    required String taskId,
    required String title,
    int sortOrder = 0,
  }) {
    return SubTask(
      id: const Uuid().v4(),
      taskId: taskId,
      title: title,
      sortOrder: sortOrder,
      createdAt: DateTime.now(),
    );
  }

  /// Creates a SubTask from JSON
  factory SubTask.fromJson(Map<String, dynamic> json) => _$SubTaskFromJson(json);

  /// Converts this SubTask to JSON
  Map<String, dynamic> toJson() => _$SubTaskToJson(this);

  /// Creates a copy of this subtask with updated fields
  SubTask copyWith({
    String? id,
    String? taskId,
    String? title,
    bool? isCompleted,
    DateTime? completedAt,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return SubTask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Marks this subtask as completed
  SubTask markCompleted() {
    return copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
  }

  /// Marks this subtask as not completed
  SubTask markIncomplete() {
    return copyWith(
      isCompleted: false,
      completedAt: null,
    );
  }

  /// Validates the subtask data
  bool isValid() {
    if (id.isEmpty || taskId.isEmpty || title.trim().isEmpty) {
      return false;
    }
    
    if (isCompleted && completedAt == null) {
      return false;
    }
    
    if (!isCompleted && completedAt != null) {
      return false;
    }
    
    return sortOrder >= 0;
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        title,
        isCompleted,
        completedAt,
        sortOrder,
        createdAt,
      ];

  @override
  String toString() {
    return 'SubTask(id: $id, taskId: $taskId, title: $title, '
           'isCompleted: $isCompleted, sortOrder: $sortOrder)';
  }
}