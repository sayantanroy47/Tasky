import '../entities/project_health.dart';
import '../entities/ai_suggestion.dart';
import '../entities/project_prediction.dart';

/// Repository interface for smart project features
abstract class ProjectSmartRepository {
  /// Project Health Monitoring
  
  /// Gets the current health status of a project
  Future<ProjectHealth?> getProjectHealth(String projectId);
  
  /// Gets health status for multiple projects
  Future<Map<String, ProjectHealth>> getProjectsHealth(List<String> projectIds);
  
  /// Saves or updates project health status
  Future<void> saveProjectHealth(ProjectHealth health);
  
  /// Gets health history for a project within a date range
  Future<List<ProjectHealth>> getProjectHealthHistory(
    String projectId,
    DateTime startDate,
    DateTime endDate,
  );
  
  /// Gets projects that need attention based on health status
  Future<List<String>> getProjectsNeedingAttention();
  
  /// AI Suggestions
  
  /// Gets AI suggestions for a project
  Future<ProjectAISuggestions?> getProjectAISuggestions(String projectId);
  
  /// Saves or updates AI suggestions for a project
  Future<void> saveProjectAISuggestions(ProjectAISuggestions suggestions);
  
  /// Gets active suggestions across all projects
  Future<List<AISuggestion>> getActiveSuggestions({int? limit});
  
  /// Gets urgent suggestions that need immediate attention
  Future<List<AISuggestion>> getUrgentSuggestions();
  
  /// Updates a suggestion status (accept/dismiss)
  Future<void> updateSuggestionStatus(
    String suggestionId,
    bool isAccepted,
    bool isDismissed,
    String? dismissalReason,
  );
  
  /// Gets suggestion analytics (acceptance rate, effectiveness, etc.)
  Future<Map<String, dynamic>> getSuggestionAnalytics();
  
  /// Predictive Analytics
  
  /// Gets predictive analytics for a project
  Future<ProjectPredictiveAnalytics?> getProjectPredictiveAnalytics(String projectId);
  
  /// Saves or updates predictive analytics
  Future<void> saveProjectPredictiveAnalytics(ProjectPredictiveAnalytics analytics);
  
  /// Gets predictions by type across all projects
  Future<List<ProjectPrediction>> getPredictionsByType(PredictionType type);
  
  /// Gets high-risk projects based on predictions
  Future<List<String>> getHighRiskProjects();
  
  /// Gets projects with completion date predictions
  Future<Map<String, DateTime>> getProjectCompletionPredictions();
  
  /// Updates prediction accuracy after actual outcomes
  Future<void> updatePredictionAccuracy(
    String predictionId,
    dynamic actualValue,
    DateTime actualDate,
  );
  
  /// Smart Insights and Pattern Recognition
  
  /// Gets patterns identified across projects
  Future<List<Map<String, dynamic>>> getProjectPatterns();
  
  /// Saves identified patterns for future analysis
  Future<void> saveProjectPattern(Map<String, dynamic> pattern);
  
  /// Gets productivity trends across projects
  Future<Map<String, List<double>>> getProductivityTrends(
    DateTime startDate,
    DateTime endDate,
  );
  
  /// Gets workload distribution analysis
  Future<Map<String, dynamic>> getWorkloadDistribution();
  
  /// Gets bottleneck analysis for projects
  Future<Map<String, List<String>>> getBottleneckAnalysis();
  
  /// Configuration and Settings
  
  /// Gets smart features configuration
  Future<Map<String, dynamic>> getSmartFeaturesConfig();
  
  /// Updates smart features configuration
  Future<void> updateSmartFeaturesConfig(Map<String, dynamic> config);
  
  /// Gets notification preferences for smart features
  Future<Map<String, bool>> getSmartNotificationPreferences();
  
  /// Updates notification preferences for smart features
  Future<void> updateSmartNotificationPreferences(Map<String, bool> preferences);
  
  /// Data Management
  
  /// Cleans up old health records, predictions, and suggestions
  Future<void> cleanupOldData(Duration retentionPeriod);
  
  /// Archives processed suggestions and predictions
  Future<void> archiveProcessedData(DateTime beforeDate);
  
  /// Gets data statistics for dashboard
  Future<Map<String, int>> getDataStatistics();
}

/// Exception thrown when smart features are not available
class SmartFeaturesUnavailableException implements Exception {
  final String message;
  const SmartFeaturesUnavailableException(this.message);
  
  @override
  String toString() => 'SmartFeaturesUnavailableException: $message';
}

/// Exception thrown when AI services are not configured
class AIServiceNotConfiguredException implements Exception {
  final String message;
  const AIServiceNotConfiguredException(this.message);
  
  @override
  String toString() => 'AIServiceNotConfiguredException: $message';
}

/// Exception thrown when prediction data is insufficient
class InsufficientDataException implements Exception {
  final String message;
  const InsufficientDataException(this.message);
  
  @override
  String toString() => 'InsufficientDataException: $message';
}