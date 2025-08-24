import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'project_prediction.g.dart';

/// Enumeration of prediction types
enum PredictionType {
  completionDate,
  riskAssessment,
  workloadForecast,
  resourceRequirement,
  budgetProjection,
  qualityMetrics,
}

/// Enumeration of risk levels
enum RiskLevel {
  veryLow,
  low,
  medium,
  high,
  veryHigh,
}

/// Enumeration of confidence levels
enum PredictionConfidence {
  veryLow,
  low,
  medium,
  high,
  veryHigh,
}

/// Represents a specific prediction about a project aspect
@JsonSerializable()
class ProjectPrediction extends Equatable {
  /// Unique identifier for this prediction
  final String id;
  
  /// Project ID this prediction belongs to
  final String projectId;
  
  /// Type of prediction
  final PredictionType type;
  
  /// Human-readable title
  final String title;
  
  /// Detailed description of the prediction
  final String description;
  
  /// Predicted value (could be date, percentage, number, etc.)
  final dynamic predictedValue;
  
  /// Current baseline value for comparison
  final dynamic currentValue;
  
  /// Confidence level in this prediction
  final PredictionConfidence confidence;
  
  /// Numerical confidence score (0-100)
  final double confidenceScore;
  
  /// Risk level associated with this prediction
  final RiskLevel riskLevel;
  
  /// Factors that influence this prediction
  final List<String> influencingFactors;
  
  /// Scenarios that could affect the outcome
  final List<PredictionScenario> scenarios;
  
  /// When this prediction was generated
  final DateTime generatedAt;
  
  /// When this prediction is valid until
  final DateTime validUntil;
  
  /// Historical accuracy of similar predictions
  final double historicalAccuracy;
  
  /// Additional metadata and supporting data
  final Map<String, dynamic> metadata;

  const ProjectPrediction({
    required this.id,
    required this.projectId,
    required this.type,
    required this.title,
    required this.description,
    required this.predictedValue,
    this.currentValue,
    required this.confidence,
    required this.confidenceScore,
    required this.riskLevel,
    this.influencingFactors = const [],
    this.scenarios = const [],
    required this.generatedAt,
    required this.validUntil,
    this.historicalAccuracy = 0.0,
    this.metadata = const {},
  });

  /// Creates a ProjectPrediction from JSON
  factory ProjectPrediction.fromJson(Map<String, dynamic> json) =>
      _$ProjectPredictionFromJson(json);

  /// Converts this ProjectPrediction to JSON
  Map<String, dynamic> toJson() => _$ProjectPredictionToJson(this);

  /// Creates a copy with updated fields
  ProjectPrediction copyWith({
    String? id,
    String? projectId,
    PredictionType? type,
    String? title,
    String? description,
    dynamic predictedValue,
    dynamic currentValue,
    PredictionConfidence? confidence,
    double? confidenceScore,
    RiskLevel? riskLevel,
    List<String>? influencingFactors,
    List<PredictionScenario>? scenarios,
    DateTime? generatedAt,
    DateTime? validUntil,
    double? historicalAccuracy,
    Map<String, dynamic>? metadata,
  }) {
    return ProjectPrediction(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      predictedValue: predictedValue ?? this.predictedValue,
      currentValue: currentValue ?? this.currentValue,
      confidence: confidence ?? this.confidence,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      riskLevel: riskLevel ?? this.riskLevel,
      influencingFactors: influencingFactors ?? this.influencingFactors,
      scenarios: scenarios ?? this.scenarios,
      generatedAt: generatedAt ?? this.generatedAt,
      validUntil: validUntil ?? this.validUntil,
      historicalAccuracy: historicalAccuracy ?? this.historicalAccuracy,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Returns true if this prediction is still valid
  bool get isValid => DateTime.now().isBefore(validUntil);

  /// Returns true if this prediction has high confidence
  bool get isHighConfidence => confidence == PredictionConfidence.high ||
      confidence == PredictionConfidence.veryHigh;

  /// Returns true if this prediction indicates high risk
  bool get isHighRisk => riskLevel == RiskLevel.high ||
      riskLevel == RiskLevel.veryHigh;

  @override
  List<Object?> get props => [
        id,
        projectId,
        type,
        title,
        description,
        predictedValue,
        currentValue,
        confidence,
        confidenceScore,
        riskLevel,
        influencingFactors,
        scenarios,
        generatedAt,
        validUntil,
        historicalAccuracy,
        metadata,
      ];
}

/// Represents a scenario that could affect a prediction
@JsonSerializable()
class PredictionScenario extends Equatable {
  /// Name of the scenario
  final String name;
  
  /// Description of the scenario
  final String description;
  
  /// Probability of this scenario occurring (0-100)
  final double probability;
  
  /// Impact on the prediction if this scenario occurs
  final String impact;
  
  /// Adjusted predicted value under this scenario
  final dynamic adjustedValue;

  const PredictionScenario({
    required this.name,
    required this.description,
    required this.probability,
    required this.impact,
    this.adjustedValue,
  });

  /// Creates a PredictionScenario from JSON
  factory PredictionScenario.fromJson(Map<String, dynamic> json) =>
      _$PredictionScenarioFromJson(json);

  /// Converts this PredictionScenario to JSON
  Map<String, dynamic> toJson() => _$PredictionScenarioToJson(this);

  @override
  List<Object?> get props => [
        name,
        description,
        probability,
        impact,
        adjustedValue,
      ];
}

/// Represents predictive analytics for a project
@JsonSerializable()
class ProjectPredictiveAnalytics extends Equatable {
  /// Project ID these predictions belong to
  final String projectId;
  
  /// List of predictions
  final List<ProjectPrediction> predictions;
  
  /// Overall risk assessment
  final RiskLevel overallRisk;
  
  /// Predicted completion date
  final DateTime? predictedCompletionDate;
  
  /// Confidence in completion date prediction
  final double completionDateConfidence;
  
  /// Predicted success probability (0-100)
  final double successProbability;
  
  /// Key risk factors
  final List<String> riskFactors;
  
  /// Recommended actions based on predictions
  final List<String> recommendedActions;
  
  /// When these predictions were generated
  final DateTime generatedAt;
  
  /// Next update time for predictions
  final DateTime nextUpdateAt;

  const ProjectPredictiveAnalytics({
    required this.projectId,
    required this.predictions,
    required this.overallRisk,
    this.predictedCompletionDate,
    required this.completionDateConfidence,
    required this.successProbability,
    this.riskFactors = const [],
    this.recommendedActions = const [],
    required this.generatedAt,
    required this.nextUpdateAt,
  });

  /// Creates ProjectPredictiveAnalytics from JSON
  factory ProjectPredictiveAnalytics.fromJson(Map<String, dynamic> json) =>
      _$ProjectPredictiveAnalyticsFromJson(json);

  /// Converts this ProjectPredictiveAnalytics to JSON
  Map<String, dynamic> toJson() => _$ProjectPredictiveAnalyticsToJson(this);

  /// Returns high-risk predictions
  List<ProjectPrediction> get highRiskPredictions =>
      predictions.where((p) => p.isHighRisk).toList();

  /// Returns high-confidence predictions
  List<ProjectPrediction> get highConfidencePredictions =>
      predictions.where((p) => p.isHighConfidence).toList();

  /// Returns valid predictions
  List<ProjectPrediction> get validPredictions =>
      predictions.where((p) => p.isValid).toList();

  /// Returns true if overall project risk is high
  bool get isHighRisk => overallRisk == RiskLevel.high ||
      overallRisk == RiskLevel.veryHigh;

  /// Returns true if project is likely to succeed (>70% probability)
  bool get isLikelyToSucceed => successProbability >= 70;

  @override
  List<Object?> get props => [
        projectId,
        predictions,
        overallRisk,
        predictedCompletionDate,
        completionDateConfidence,
        successProbability,
        riskFactors,
        recommendedActions,
        generatedAt,
        nextUpdateAt,
      ];
}