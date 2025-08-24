import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'timeline_milestone.g.dart';

/// Represents a milestone in a project timeline
/// 
/// Milestones are significant events or checkpoints in a project
/// that mark important progress or deliverables.
@JsonSerializable()
class TimelineMilestone extends Equatable {
  /// Unique identifier for the milestone
  final String id;
  
  /// Name/title of the milestone
  final String title;
  
  /// Optional description of the milestone
  final String? description;
  
  /// Date when the milestone is scheduled
  final DateTime date;
  
  /// Project ID this milestone belongs to
  final String projectId;
  
  /// Color for the milestone marker (hex color code)
  final String color;
  
  /// Icon name for the milestone (from PhosphorIcons)
  final String iconName;
  
  /// Priority level of the milestone
  final MilestonePriority priority;
  
  /// Whether the milestone has been achieved
  final bool isCompleted;
  
  /// When the milestone was completed (null if not completed)
  final DateTime? completedAt;
  
  /// When this milestone was created
  final DateTime createdAt;
  
  /// When this milestone was last updated
  final DateTime? updatedAt;
  
  /// List of task IDs that must be completed for this milestone
  final List<String> requiredTaskIds;
  
  /// Additional metadata
  final Map<String, dynamic> metadata;

  const TimelineMilestone({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.projectId,
    required this.color,
    this.iconName = 'flag-banner',
    this.priority = MilestonePriority.normal,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    this.updatedAt,
    this.requiredTaskIds = const [],
    this.metadata = const {},
  });

  /// Creates a new milestone with generated ID and current timestamp
  factory TimelineMilestone.create({
    required String title,
    String? description,
    required DateTime date,
    required String projectId,
    String color = '#FF6B35',
    String iconName = 'flag-banner',
    MilestonePriority priority = MilestonePriority.normal,
    List<String> requiredTaskIds = const [],
    Map<String, dynamic> metadata = const {},
  }) {
    return TimelineMilestone(
      id: const Uuid().v4(),
      title: title,
      description: description,
      date: date,
      projectId: projectId,
      color: color,
      iconName: iconName,
      priority: priority,
      createdAt: DateTime.now(),
      requiredTaskIds: requiredTaskIds,
      metadata: metadata,
    );
  }

  /// Creates a TimelineMilestone from JSON
  factory TimelineMilestone.fromJson(Map<String, dynamic> json) =>
      _$TimelineMilestoneFromJson(json);

  /// Converts this TimelineMilestone to JSON
  Map<String, dynamic> toJson() => _$TimelineMilestoneToJson(this);

  /// Creates a copy with updated fields
  TimelineMilestone copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? projectId,
    String? color,
    String? iconName,
    MilestonePriority? priority,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? requiredTaskIds,
    Map<String, dynamic>? metadata,
  }) {
    return TimelineMilestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      projectId: projectId ?? this.projectId,
      color: color ?? this.color,
      iconName: iconName ?? this.iconName,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      requiredTaskIds: requiredTaskIds ?? this.requiredTaskIds,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Marks this milestone as completed
  TimelineMilestone markCompleted() {
    return copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Marks this milestone as incomplete
  TimelineMilestone markIncomplete() {
    return copyWith(
      isCompleted: false,
      completedAt: null,
      updatedAt: DateTime.now(),
    );
  }

  /// Returns true if this milestone is overdue
  bool get isOverdue {
    if (isCompleted) return false;
    return date.isBefore(DateTime.now());
  }

  /// Returns true if this milestone is due today
  bool get isDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final milestoneDate = DateTime(date.year, date.month, date.day);
    return milestoneDate.isAtSameMomentAs(today);
  }

  /// Returns true if this milestone is due soon (within 7 days)
  bool get isDueSoon {
    if (isCompleted) return false;
    final now = DateTime.now();
    final sevenDaysFromNow = now.add(const Duration(days: 7));
    return date.isBefore(sevenDaysFromNow) && date.isAfter(now);
  }

  /// Returns the number of days until the milestone date
  int get daysUntilDue {
    final now = DateTime.now();
    return date.difference(now).inDays;
  }

  /// Validates the milestone data
  bool isValid() {
    if (id.isEmpty || title.trim().isEmpty) {
      return false;
    }
    
    // Validate color format
    if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(color)) {
      return false;
    }
    
    // Validate icon name
    if (iconName.isEmpty) {
      return false;
    }
    
    // Validate project ID
    if (projectId.isEmpty) {
      return false;
    }
    
    // Validate completed status consistency
    if (isCompleted && completedAt == null) {
      return false;
    }
    
    if (!isCompleted && completedAt != null) {
      return false;
    }
    
    return true;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        date,
        projectId,
        color,
        iconName,
        priority,
        isCompleted,
        completedAt,
        createdAt,
        updatedAt,
        requiredTaskIds,
        metadata,
      ];

  @override
  String toString() {
    return 'TimelineMilestone(id: $id, title: $title, date: $date, '
           'projectId: $projectId, isCompleted: $isCompleted)';
  }
}

/// Priority levels for milestones
enum MilestonePriority {
  low,
  normal,
  high,
  critical;

  /// Returns display name for the priority
  String get displayName {
    switch (this) {
      case MilestonePriority.low:
        return 'Low';
      case MilestonePriority.normal:
        return 'Normal';
      case MilestonePriority.high:
        return 'High';
      case MilestonePriority.critical:
        return 'Critical';
    }
  }

  /// Returns color for the priority level
  String get color {
    switch (this) {
      case MilestonePriority.low:
        return '#6B7280'; // Gray
      case MilestonePriority.normal:
        return '#3B82F6'; // Blue
      case MilestonePriority.high:
        return '#F59E0B'; // Orange
      case MilestonePriority.critical:
        return '#EF4444'; // Red
    }
  }
}