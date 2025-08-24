import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ai_suggestion.g.dart';

/// Enumeration of AI suggestion types
enum AISuggestionType {
  taskPrioritization,
  scheduleOptimization,
  bottleneckIdentification,
  resourceAllocation,
  deadlineAdjustment,
  workflowImprovement,
  riskMitigation,
  performanceOptimization,
}

/// Enumeration of suggestion priorities
enum SuggestionPriority {
  low,
  medium,
  high,
  urgent,
}

/// Enumeration of suggestion categories
enum SuggestionCategory {
  productivity,
  planning,
  quality,
  communication,
  automation,
  riskManagement,
}

/// Represents an AI-generated suggestion for project management
@JsonSerializable()
class AISuggestion extends Equatable {
  /// Unique identifier for this suggestion
  final String id;
  
  /// Project ID this suggestion belongs to
  final String projectId;
  
  /// Type of AI suggestion
  final AISuggestionType type;
  
  /// Priority level of this suggestion
  final SuggestionPriority priority;
  
  /// Category of this suggestion
  final SuggestionCategory category;
  
  /// Title of the suggestion
  final String title;
  
  /// Detailed description and rationale
  final String description;
  
  /// Specific actionable recommendations
  final List<String> recommendations;
  
  /// Expected impact or benefit
  final String expectedImpact;
  
  /// Confidence level (0-100)
  final double confidence;
  
  /// When this suggestion was generated
  final DateTime generatedAt;
  
  /// When this suggestion expires or becomes less relevant
  final DateTime? expiresAt;
  
  /// Whether this suggestion has been accepted
  final bool isAccepted;
  
  /// Whether this suggestion has been dismissed
  final bool isDismissed;
  
  /// Reason for dismissal if applicable
  final String? dismissalReason;
  
  /// When this suggestion was last updated
  final DateTime updatedAt;
  
  /// Associated task IDs if applicable
  final List<String> relatedTaskIds;
  
  /// Metrics and data that support this suggestion
  final Map<String, dynamic> supportingData;
  
  /// Additional metadata
  final Map<String, dynamic> metadata;

  const AISuggestion({
    required this.id,
    required this.projectId,
    required this.type,
    required this.priority,
    required this.category,
    required this.title,
    required this.description,
    required this.recommendations,
    required this.expectedImpact,
    required this.confidence,
    required this.generatedAt,
    this.expiresAt,
    this.isAccepted = false,
    this.isDismissed = false,
    this.dismissalReason,
    required this.updatedAt,
    this.relatedTaskIds = const [],
    this.supportingData = const {},
    this.metadata = const {},
  });

  /// Creates an AISuggestion from JSON
  factory AISuggestion.fromJson(Map<String, dynamic> json) =>
      _$AISuggestionFromJson(json);

  /// Converts this AISuggestion to JSON
  Map<String, dynamic> toJson() => _$AISuggestionToJson(this);

  /// Creates a copy with updated fields
  AISuggestion copyWith({
    String? id,
    String? projectId,
    AISuggestionType? type,
    SuggestionPriority? priority,
    SuggestionCategory? category,
    String? title,
    String? description,
    List<String>? recommendations,
    String? expectedImpact,
    double? confidence,
    DateTime? generatedAt,
    DateTime? expiresAt,
    bool? isAccepted,
    bool? isDismissed,
    String? dismissalReason,
    DateTime? updatedAt,
    List<String>? relatedTaskIds,
    Map<String, dynamic>? supportingData,
    Map<String, dynamic>? metadata,
  }) {
    return AISuggestion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      recommendations: recommendations ?? this.recommendations,
      expectedImpact: expectedImpact ?? this.expectedImpact,
      confidence: confidence ?? this.confidence,
      generatedAt: generatedAt ?? this.generatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isAccepted: isAccepted ?? this.isAccepted,
      isDismissed: isDismissed ?? this.isDismissed,
      dismissalReason: dismissalReason ?? this.dismissalReason,
      updatedAt: updatedAt ?? this.updatedAt,
      relatedTaskIds: relatedTaskIds ?? this.relatedTaskIds,
      supportingData: supportingData ?? this.supportingData,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Marks this suggestion as accepted
  AISuggestion accept() {
    return copyWith(
      isAccepted: true,
      isDismissed: false,
      dismissalReason: null,
      updatedAt: DateTime.now(),
    );
  }

  /// Marks this suggestion as dismissed
  AISuggestion dismiss(String reason) {
    return copyWith(
      isDismissed: true,
      isAccepted: false,
      dismissalReason: reason,
      updatedAt: DateTime.now(),
    );
  }

  /// Returns true if this suggestion is still active
  bool get isActive => !isDismissed && !isAccepted &&
      (expiresAt == null || expiresAt!.isAfter(DateTime.now()));

  /// Returns true if this suggestion is expired
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  /// Returns true if this suggestion has high confidence (>= 80%)
  bool get isHighConfidence => confidence >= 80;

  @override
  List<Object?> get props => [
        id,
        projectId,
        type,
        priority,
        category,
        title,
        description,
        recommendations,
        expectedImpact,
        confidence,
        generatedAt,
        expiresAt,
        isAccepted,
        isDismissed,
        dismissalReason,
        updatedAt,
        relatedTaskIds,
        supportingData,
        metadata,
      ];
}

/// Represents a collection of AI suggestions for a project
@JsonSerializable()
class ProjectAISuggestions extends Equatable {
  /// Project ID these suggestions belong to
  final String projectId;
  
  /// List of active suggestions
  final List<AISuggestion> suggestions;
  
  /// When suggestions were last updated
  final DateTime lastUpdated;
  
  /// Overall AI confidence in the suggestions
  final double overallConfidence;
  
  /// Summary of key insights
  final List<String> keyInsights;

  const ProjectAISuggestions({
    required this.projectId,
    required this.suggestions,
    required this.lastUpdated,
    required this.overallConfidence,
    this.keyInsights = const [],
  });

  /// Creates ProjectAISuggestions from JSON
  factory ProjectAISuggestions.fromJson(Map<String, dynamic> json) =>
      _$ProjectAISuggestionsFromJson(json);

  /// Converts this ProjectAISuggestions to JSON
  Map<String, dynamic> toJson() => _$ProjectAISuggestionsToJson(this);

  /// Returns suggestions by priority (urgent first)
  List<AISuggestion> get suggestionsByPriority {
    final sorted = List<AISuggestion>.from(suggestions);
    sorted.sort((a, b) {
      const priorityOrder = {
        SuggestionPriority.urgent: 0,
        SuggestionPriority.high: 1,
        SuggestionPriority.medium: 2,
        SuggestionPriority.low: 3,
      };
      return (priorityOrder[a.priority] ?? 999)
          .compareTo(priorityOrder[b.priority] ?? 999);
    });
    return sorted;
  }

  /// Returns only active suggestions
  List<AISuggestion> get activeSuggestions =>
      suggestions.where((s) => s.isActive).toList();

  /// Returns high-confidence suggestions
  List<AISuggestion> get highConfidenceSuggestions =>
      suggestions.where((s) => s.isHighConfidence).toList();

  /// Returns urgent suggestions
  List<AISuggestion> get urgentSuggestions =>
      suggestions.where((s) => s.priority == SuggestionPriority.urgent).toList();

  /// Creates a copy with updated fields
  ProjectAISuggestions copyWith({
    String? projectId,
    List<AISuggestion>? suggestions,
    DateTime? lastUpdated,
    double? overallConfidence,
    List<String>? keyInsights,
  }) {
    return ProjectAISuggestions(
      projectId: projectId ?? this.projectId,
      suggestions: suggestions ?? this.suggestions,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      overallConfidence: overallConfidence ?? this.overallConfidence,
      keyInsights: keyInsights ?? this.keyInsights,
    );
  }

  @override
  List<Object?> get props => [
        projectId,
        suggestions,
        lastUpdated,
        overallConfidence,
        keyInsights,
      ];
}