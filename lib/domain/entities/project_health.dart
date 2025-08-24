import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'project_health.g.dart';

/// Enumeration of project health levels
enum ProjectHealthLevel {
  excellent,
  good,
  warning,
  critical,
}

/// Enumeration of health issue types
enum HealthIssueType {
  overdueTasks,
  lowCompletionRate,
  stagnantProject,
  blockedTasks,
  resourceBottleneck,
  missedDeadlines,
  unbalancedWorkload,
  communicationGaps,
}

/// Represents a specific health issue in a project
@JsonSerializable()
class ProjectHealthIssue extends Equatable {
  /// Unique identifier for this issue
  final String id;
  
  /// Type of health issue
  final HealthIssueType type;
  
  /// Severity level from 1 (minor) to 10 (critical)
  final int severity;
  
  /// Human-readable title of the issue
  final String title;
  
  /// Detailed description of the issue
  final String description;
  
  /// Suggested actions to resolve the issue
  final List<String> suggestedActions;
  
  /// When this issue was first detected
  final DateTime detectedAt;
  
  /// When this issue was last updated
  final DateTime updatedAt;
  
  /// Associated task IDs if applicable
  final List<String> affectedTaskIds;
  
  /// Additional metadata about the issue
  final Map<String, dynamic> metadata;

  const ProjectHealthIssue({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.suggestedActions,
    required this.detectedAt,
    required this.updatedAt,
    this.affectedTaskIds = const [],
    this.metadata = const {},
  });

  /// Creates a ProjectHealthIssue from JSON
  factory ProjectHealthIssue.fromJson(Map<String, dynamic> json) =>
      _$ProjectHealthIssueFromJson(json);

  /// Converts this ProjectHealthIssue to JSON
  Map<String, dynamic> toJson() => _$ProjectHealthIssueToJson(this);

  /// Creates a copy with updated fields
  ProjectHealthIssue copyWith({
    String? id,
    HealthIssueType? type,
    int? severity,
    String? title,
    String? description,
    List<String>? suggestedActions,
    DateTime? detectedAt,
    DateTime? updatedAt,
    List<String>? affectedTaskIds,
    Map<String, dynamic>? metadata,
  }) {
    return ProjectHealthIssue(
      id: id ?? this.id,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      description: description ?? this.description,
      suggestedActions: suggestedActions ?? this.suggestedActions,
      detectedAt: detectedAt ?? this.detectedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      affectedTaskIds: affectedTaskIds ?? this.affectedTaskIds,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Returns true if this issue is critical (severity >= 8)
  bool get isCritical => severity >= 8;
  
  /// Returns true if this issue needs attention (severity >= 6)
  bool get needsAttention => severity >= 6;

  @override
  List<Object?> get props => [
        id,
        type,
        severity,
        title,
        description,
        suggestedActions,
        detectedAt,
        updatedAt,
        affectedTaskIds,
        metadata,
      ];
}

/// Represents the overall health status of a project
@JsonSerializable()
class ProjectHealth extends Equatable {
  /// Project ID this health status belongs to
  final String projectId;
  
  /// Overall health level
  final ProjectHealthLevel level;
  
  /// Health score from 0-100 (higher is better)
  final double healthScore;
  
  /// List of active health issues
  final List<ProjectHealthIssue> issues;
  
  /// Key performance indicators
  final Map<String, double> kpis;
  
  /// Health trends over time
  final List<HealthTrend> trends;
  
  /// When this health status was calculated
  final DateTime calculatedAt;
  
  /// Additional insights and recommendations
  final List<String> insights;

  const ProjectHealth({
    required this.projectId,
    required this.level,
    required this.healthScore,
    required this.issues,
    required this.kpis,
    required this.trends,
    required this.calculatedAt,
    this.insights = const [],
  });

  /// Creates a ProjectHealth from JSON
  factory ProjectHealth.fromJson(Map<String, dynamic> json) =>
      _$ProjectHealthFromJson(json);

  /// Converts this ProjectHealth to JSON
  Map<String, dynamic> toJson() => _$ProjectHealthToJson(this);

  /// Creates a copy with updated fields
  ProjectHealth copyWith({
    String? projectId,
    ProjectHealthLevel? level,
    double? healthScore,
    List<ProjectHealthIssue>? issues,
    Map<String, double>? kpis,
    List<HealthTrend>? trends,
    DateTime? calculatedAt,
    List<String>? insights,
  }) {
    return ProjectHealth(
      projectId: projectId ?? this.projectId,
      level: level ?? this.level,
      healthScore: healthScore ?? this.healthScore,
      issues: issues ?? this.issues,
      kpis: kpis ?? this.kpis,
      trends: trends ?? this.trends,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      insights: insights ?? this.insights,
    );
  }

  /// Returns critical issues (severity >= 8)
  List<ProjectHealthIssue> get criticalIssues =>
      issues.where((issue) => issue.isCritical).toList();

  /// Returns issues that need attention (severity >= 6)
  List<ProjectHealthIssue> get issuesNeedingAttention =>
      issues.where((issue) => issue.needsAttention).toList();

  /// Returns true if the project is in a healthy state
  bool get isHealthy => level == ProjectHealthLevel.excellent ||
      level == ProjectHealthLevel.good;

  /// Returns true if the project needs immediate attention
  bool get needsImmediateAttention => level == ProjectHealthLevel.critical;

  @override
  List<Object?> get props => [
        projectId,
        level,
        healthScore,
        issues,
        kpis,
        trends,
        calculatedAt,
        insights,
      ];
}

/// Represents a health trend data point
@JsonSerializable()
class HealthTrend extends Equatable {
  /// Date of this trend point
  final DateTime date;
  
  /// Health score at this date
  final double healthScore;
  
  /// Number of issues at this date
  final int issuesCount;
  
  /// Completion rate at this date
  final double completionRate;
  
  /// Additional metrics
  final Map<String, double> metrics;

  const HealthTrend({
    required this.date,
    required this.healthScore,
    required this.issuesCount,
    required this.completionRate,
    this.metrics = const {},
  });

  /// Creates a HealthTrend from JSON
  factory HealthTrend.fromJson(Map<String, dynamic> json) =>
      _$HealthTrendFromJson(json);

  /// Converts this HealthTrend to JSON
  Map<String, dynamic> toJson() => _$HealthTrendToJson(this);

  @override
  List<Object?> get props => [
        date,
        healthScore,
        issuesCount,
        completionRate,
        metrics,
      ];
}