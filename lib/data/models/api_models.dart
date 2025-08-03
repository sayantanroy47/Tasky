import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/tag.dart';

part 'api_models.g.dart';

/// API request/response models for external service communication

/// Request model for creating a task via API
@JsonSerializable()
class CreateTaskRequest {
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String priority;
  final List<String> tags;
  final String? projectId;

  const CreateTaskRequest({
    required this.title,
    this.description,
    this.dueDate,
    required this.priority,
    this.tags = const [],
    this.projectId,
  });

  factory CreateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTaskRequestToJson(this);

  /// Creates a request from a TaskModel
  factory CreateTaskRequest.fromTaskModel(TaskModel task) {
    return CreateTaskRequest(
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority.name,
      tags: task.tags,
      projectId: task.projectId,
    );
  }
}

/// Response model for task operations
@JsonSerializable()
class TaskResponse {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final String priority;
  final String status;
  final List<String> tags;
  final String? projectId;
  final Map<String, dynamic> metadata;

  const TaskResponse({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.updatedAt,
    this.dueDate,
    this.completedAt,
    required this.priority,
    required this.status,
    this.tags = const [],
    this.projectId,
    this.metadata = const {},
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) =>
      _$TaskResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TaskResponseToJson(this);
}

/// Sync request model for batch operations
@JsonSerializable()
class SyncRequest {
  final List<TaskResponse> tasks;
  final List<ProjectResponse> projects;
  final List<TagResponse> tags;
  final DateTime lastSyncTime;

  const SyncRequest({
    required this.tasks,
    required this.projects,
    required this.tags,
    required this.lastSyncTime,
  });

  factory SyncRequest.fromJson(Map<String, dynamic> json) =>
      _$SyncRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SyncRequestToJson(this);
}

/// Sync response model
@JsonSerializable()
class SyncResponse {
  final List<TaskResponse> tasks;
  final List<ProjectResponse> projects;
  final List<TagResponse> tags;
  final List<ConflictResponse> conflicts;
  final DateTime serverTime;

  const SyncResponse({
    required this.tasks,
    required this.projects,
    required this.tags,
    required this.conflicts,
    required this.serverTime,
  });

  factory SyncResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SyncResponseToJson(this);
}

/// Project response model
@JsonSerializable()
class ProjectResponse {
  final String id;
  final String name;
  final String? description;
  final String color;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isArchived;

  const ProjectResponse({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    required this.createdAt,
    this.updatedAt,
    this.isArchived = false,
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> json) =>
      _$ProjectResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectResponseToJson(this);
}

/// Tag response model
@JsonSerializable()
class TagResponse {
  final String id;
  final String name;
  final String? color;
  final DateTime createdAt;

  const TagResponse({
    required this.id,
    required this.name,
    this.color,
    required this.createdAt,
  });

  factory TagResponse.fromJson(Map<String, dynamic> json) =>
      _$TagResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TagResponseToJson(this);
}

/// Conflict response model for sync conflicts
@JsonSerializable()
class ConflictResponse {
  final String entityId;
  final String entityType;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> serverData;
  final DateTime conflictTime;

  const ConflictResponse({
    required this.entityId,
    required this.entityType,
    required this.localData,
    required this.serverData,
    required this.conflictTime,
  });

  factory ConflictResponse.fromJson(Map<String, dynamic> json) =>
      _$ConflictResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ConflictResponseToJson(this);
}

/// Error response model
@JsonSerializable()
class ErrorResponse {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  const ErrorResponse({
    required this.code,
    required this.message,
    this.details,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}