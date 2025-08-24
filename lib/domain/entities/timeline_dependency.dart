import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'timeline_dependency.g.dart';

/// Represents a dependency relationship between tasks in a timeline
/// 
/// Dependencies define which tasks must be completed before others can start,
/// enabling critical path analysis and proper task scheduling.
@JsonSerializable()
class TimelineDependency extends Equatable {
  /// Unique identifier for the dependency
  final String id;
  
  /// ID of the task that depends on another (the successor)
  final String dependentTaskId;
  
  /// ID of the task that must be completed first (the predecessor)
  final String prerequisiteTaskId;
  
  /// Type of dependency relationship
  final DependencyType type;
  
  /// Minimum lag time in hours between tasks (can be negative for overlap)
  final int lagTimeHours;
  
  /// When this dependency was created
  final DateTime createdAt;
  
  /// When this dependency was last updated
  final DateTime? updatedAt;
  
  /// Additional metadata
  final Map<String, dynamic> metadata;

  const TimelineDependency({
    required this.id,
    required this.dependentTaskId,
    required this.prerequisiteTaskId,
    this.type = DependencyType.finishToStart,
    this.lagTimeHours = 0,
    required this.createdAt,
    this.updatedAt,
    this.metadata = const {},
  });

  /// Creates a new dependency with generated ID and current timestamp
  factory TimelineDependency.create({
    required String dependentTaskId,
    required String prerequisiteTaskId,
    DependencyType type = DependencyType.finishToStart,
    int lagTimeHours = 0,
    Map<String, dynamic> metadata = const {},
  }) {
    return TimelineDependency(
      id: const Uuid().v4(),
      dependentTaskId: dependentTaskId,
      prerequisiteTaskId: prerequisiteTaskId,
      type: type,
      lagTimeHours: lagTimeHours,
      createdAt: DateTime.now(),
      metadata: metadata,
    );
  }

  /// Creates a TimelineDependency from JSON
  factory TimelineDependency.fromJson(Map<String, dynamic> json) =>
      _$TimelineDependencyFromJson(json);

  /// Converts this TimelineDependency to JSON
  Map<String, dynamic> toJson() => _$TimelineDependencyToJson(this);

  /// Creates a copy with updated fields
  TimelineDependency copyWith({
    String? id,
    String? dependentTaskId,
    String? prerequisiteTaskId,
    DependencyType? type,
    int? lagTimeHours,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return TimelineDependency(
      id: id ?? this.id,
      dependentTaskId: dependentTaskId ?? this.dependentTaskId,
      prerequisiteTaskId: prerequisiteTaskId ?? this.prerequisiteTaskId,
      type: type ?? this.type,
      lagTimeHours: lagTimeHours ?? this.lagTimeHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      metadata: metadata ?? this.metadata,
    );
  }

  /// Validates the dependency
  bool isValid() {
    if (id.isEmpty) return false;
    if (dependentTaskId.isEmpty || prerequisiteTaskId.isEmpty) return false;
    if (dependentTaskId == prerequisiteTaskId) return false; // Self-dependency
    return true;
  }

  /// Returns true if this is a critical dependency (no lag time allowed)
  bool get isCritical => lagTimeHours == 0;

  /// Returns lag time as duration
  Duration get lagTime => Duration(hours: lagTimeHours);

  @override
  List<Object?> get props => [
        id,
        dependentTaskId,
        prerequisiteTaskId,
        type,
        lagTimeHours,
        createdAt,
        updatedAt,
        metadata,
      ];

  @override
  String toString() {
    return 'TimelineDependency(id: $id, dependent: $dependentTaskId, '
           'prerequisite: $prerequisiteTaskId, type: $type, lag: ${lagTimeHours}h)';
  }
}

/// Types of dependency relationships between tasks
enum DependencyType {
  /// The predecessor task must finish before the successor task can start
  finishToStart,
  
  /// The predecessor task must start before the successor task can start
  startToStart,
  
  /// The predecessor task must finish before the successor task can finish
  finishToFinish,
  
  /// The predecessor task must start before the successor task can finish
  startToFinish;

  /// Returns display name for the dependency type
  String get displayName {
    switch (this) {
      case DependencyType.finishToStart:
        return 'Finish-to-Start';
      case DependencyType.startToStart:
        return 'Start-to-Start';
      case DependencyType.finishToFinish:
        return 'Finish-to-Finish';
      case DependencyType.startToFinish:
        return 'Start-to-Finish';
    }
  }

  /// Returns short abbreviation for the dependency type
  String get abbreviation {
    switch (this) {
      case DependencyType.finishToStart:
        return 'FS';
      case DependencyType.startToStart:
        return 'SS';
      case DependencyType.finishToFinish:
        return 'FF';
      case DependencyType.startToFinish:
        return 'SF';
    }
  }

  /// Returns description of the dependency type
  String get description {
    switch (this) {
      case DependencyType.finishToStart:
        return 'Task B cannot start until Task A finishes';
      case DependencyType.startToStart:
        return 'Task B cannot start until Task A starts';
      case DependencyType.finishToFinish:
        return 'Task B cannot finish until Task A finishes';
      case DependencyType.startToFinish:
        return 'Task B cannot finish until Task A starts';
    }
  }
}