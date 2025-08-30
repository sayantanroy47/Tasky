import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/core_providers.dart';
import '../../data/repositories/project_smart_repository_impl.dart';
import '../../domain/entities/project_health.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../../domain/entities/project_prediction.dart';
import '../../domain/repositories/project_smart_repository.dart';
import '../../services/smart_features/ai_project_analysis_service.dart';
import '../../services/smart_features/project_health_monitoring_service.dart';
import '../../services/smart_features/predictive_analytics_engine.dart';
import '../../services/smart_features/smart_notification_service.dart';
import '../../services/smart_features/automated_insights_engine.dart';
import '../../services/notification/enhanced_notification_service.dart';
import '../../services/ai/composite_ai_task_parser.dart';
import '../../services/ai/openai_task_parser.dart';
import '../../services/ai/claude_task_parser.dart';
import '../../services/ai/local_task_parser.dart';
import '../../services/security/api_key_manager.dart';
import '../../domain/models/ai_service_type.dart';

/// Providers for smart project management features

/// Smart repository provider (alias for smartRepositoryProvider)
final projectSmartRepositoryProvider = FutureProvider<ProjectSmartRepository>((ref) async {
  return await ref.watch(smartRepositoryProvider.future);
});

/// Provider for SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Actual smart repository implementation
final smartRepositoryProvider = FutureProvider<ProjectSmartRepository>((ref) async {
  final database = ref.watch(databaseProvider);
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return ProjectSmartRepositoryImpl(database, prefs);
});

/// OpenAI Task Parser Provider
final openAITaskParserProvider = FutureProvider<OpenAITaskParser?>((ref) async {
  final apiKey = await APIKeyManager.getOpenAIApiKey();
  if (apiKey == null || apiKey.isEmpty) {
    return null; // No API key available
  }
  return OpenAITaskParser(apiKey: apiKey);
});

/// Claude Task Parser Provider
final claudeTaskParserProvider = FutureProvider<ClaudeTaskParser?>((ref) async {
  final apiKey = await APIKeyManager.getClaudeApiKey();
  if (apiKey == null || apiKey.isEmpty) {
    return null; // No API key available
  }
  return ClaudeTaskParser(apiKey: apiKey);
});

/// Local Task Parser Provider
final localTaskParserProvider = Provider<LocalTaskParser>((ref) {
  return LocalTaskParser();
});

/// Composite AI Task Parser Provider
final compositeAITaskParserProvider = FutureProvider<CompositeAITaskParser>((ref) async {
  final openAIParser = await ref.watch(openAITaskParserProvider.future);
  final claudeParser = await ref.watch(claudeTaskParserProvider.future);
  final localParser = ref.watch(localTaskParserProvider);
  
  return CompositeAITaskParser(
    openAIParser: openAIParser,
    claudeParser: claudeParser,
    localParser: localParser,
    preferredService: AIServiceType.openai,
    enableAI: openAIParser != null || claudeParser != null,
  );
});

/// AI Project Analysis Service
final aiProjectAnalysisServiceProvider = Provider<AIProjectAnalysisService>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  final projectRepository = ref.watch(projectRepositoryProvider);
  return AIProjectAnalysisService(
    taskRepository: taskRepository,
    projectRepository: projectRepository,
  );
});

/// Project Health Monitoring Service
final projectHealthMonitoringServiceProvider = Provider<ProjectHealthMonitoringService>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  final projectRepository = ref.watch(projectRepositoryProvider);
  
  return ProjectHealthMonitoringService(
    taskRepository: taskRepository,
    projectRepository: projectRepository,
  );
});

/// Predictive Analytics Engine
final predictiveAnalyticsEngineProvider = Provider<PredictiveAnalyticsEngine>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  final projectRepository = ref.watch(projectRepositoryProvider);
  
  return PredictiveAnalyticsEngine(
    taskRepository: taskRepository,
    projectRepository: projectRepository,
  );
});

/// Enhanced Notification Service Provider
final enhancedNotificationServiceProvider = Provider<EnhancedNotificationService>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return EnhancedNotificationService(taskRepository: taskRepository);
});

/// Smart Notification Service
final smartNotificationServiceProvider = Provider<SmartNotificationService>((ref) {
  final enhancedNotificationService = ref.watch(enhancedNotificationServiceProvider);
  final taskRepository = ref.watch(taskRepositoryProvider);
  final projectRepository = ref.watch(projectRepositoryProvider);
  return SmartNotificationService(
    notificationService: enhancedNotificationService,
    taskRepository: taskRepository,
    projectRepository: projectRepository,
  );
});

/// Automated Insights Engine
final automatedInsightsEngineProvider = Provider<AutomatedInsightsEngine>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  final projectRepository = ref.watch(projectRepositoryProvider);
  
  return AutomatedInsightsEngine(
    taskRepository: taskRepository,
    projectRepository: projectRepository,
  );
});

/// Project Health Providers

/// Single project health provider
final projectHealthProvider = FutureProvider.family<ProjectHealth?, String>((ref, projectId) async {
  final repository = await ref.watch(smartRepositoryProvider.future);
  return await repository.getProjectHealth(projectId);
});

/// Multiple projects health provider
final projectsHealthProvider = FutureProvider.family<Map<String, ProjectHealth>, List<String>>((ref, projectIds) async {
  final repository = await ref.watch(smartRepositoryProvider.future);
  return await repository.getProjectsHealth(projectIds);
});

/// Projects needing attention provider
final projectsNeedingAttentionProvider = FutureProvider<List<String>>((ref) async {
  final repository = await ref.watch(smartRepositoryProvider.future);
  return await repository.getProjectsNeedingAttention();
});

/// Generate project health analysis
final generateProjectHealthProvider = FutureProvider.family<ProjectHealth, String>((ref, projectId) async {
  final service = ref.watch(projectHealthMonitoringServiceProvider);
  return await service.analyzeProjectHealth(projectId);
});

/// AI Suggestions Providers

/// Project AI suggestions provider
final projectAISuggestionsProvider = FutureProvider.family<ProjectAISuggestions?, String>((ref, projectId) async {
  final repository = await ref.watch(smartRepositoryProvider.future);
  return await repository.getProjectAISuggestions(projectId);
});

/// Active suggestions provider
final activeSuggestionsProvider = FutureProvider<List<AISuggestion>>((ref) async {
  final repository = await ref.watch(smartRepositoryProvider.future);
  return await repository.getActiveSuggestions(limit: 20);
});

/// Urgent suggestions provider
final urgentSuggestionsProvider = FutureProvider<List<AISuggestion>>((ref) async {
  final repository = await ref.watch(smartRepositoryProvider.future);
  return await repository.getUrgentSuggestions();
});

/// Suggestion analytics provider
final suggestionAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = await ref.watch(smartRepositoryProvider.future);
  return await repository.getSuggestionAnalytics();
});

/// Generate AI suggestions for a project
final generateAISuggestionsProvider = FutureProvider.family<ProjectAISuggestions, String>((ref, projectId) async {
  final service = ref.watch(aiProjectAnalysisServiceProvider);
  return await service.analyzeProject(projectId);
});

/// Predictive Analytics Providers

/// Project predictive analytics provider
final projectPredictiveAnalyticsProvider = FutureProvider.family<ProjectPredictiveAnalytics?, String>((ref, projectId) async {
  final repository = await ref.watch(smartRepositoryProvider.future);
  return await repository.getProjectPredictiveAnalytics(projectId);
});

/// High-risk projects provider
final highRiskProjectsProvider = FutureProvider<List<String>>((ref) async {
  final repository = await ref.watch(smartRepositoryProvider.future);
  return await repository.getHighRiskProjects();
});

/// Project completion predictions provider
final projectCompletionPredictionsProvider = FutureProvider<Map<String, DateTime>>((ref) async {
  final repository = await ref.watch(smartRepositoryProvider.future);
  return await repository.getProjectCompletionPredictions();
});

/// Generate predictive analytics for a project
final generatePredictiveAnalyticsProvider = FutureProvider.family<ProjectPredictiveAnalytics, String>((ref, projectId) async {
  final service = ref.watch(predictiveAnalyticsEngineProvider);
  return await service.generatePredictiveAnalytics(projectId);
});

/// Predictions by type provider
final predictionsByTypeProvider = FutureProvider.family<List<ProjectPrediction>, PredictionType>((ref, type) async {
  final repository = await ref.watch(smartRepositoryProvider.future);
  return await repository.getPredictionsByType(type);
});

/// Insights and Analytics Providers

/// Comprehensive insights provider
final comprehensiveInsightsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(automatedInsightsEngineProvider);
  return await service.generateComprehensiveInsights();
});

/// Project patterns provider
final projectPatternsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = await ref.watch(smartRepositoryProvider.future);
  return await repository.getProjectPatterns();
});

/// Productivity trends provider
final productivityTrendsProvider = FutureProvider.family<Map<String, List<double>>, ({DateTime start, DateTime end})>((ref, params) async {
  final repository = await ref.watch(smartRepositoryProvider.future);
  return await repository.getProductivityTrends(params.start, params.end);
});

/// Workload distribution provider
final workloadDistributionProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = await ref.watch(smartRepositoryProvider.future);
  return await repository.getWorkloadDistribution();
});

/// Bottleneck analysis provider
final bottleneckAnalysisProvider = FutureProvider<Map<String, List<String>>>((ref) async {
  final repository = await ref.watch(smartRepositoryProvider.future);
  return await repository.getBottleneckAnalysis();
});

/// Configuration and Settings Providers

/// Smart features configuration provider
final smartFeaturesConfigProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = await ref.watch(smartRepositoryProvider.future);
  return await repository.getSmartFeaturesConfig();
});

/// Smart notification preferences provider
final smartNotificationPreferencesProvider = FutureProvider<Map<String, bool>>((ref) async {
  final repository = await ref.watch(smartRepositoryProvider.future);
  return await repository.getSmartNotificationPreferences();
});

/// Data statistics provider
final smartFeaturesDataStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = await ref.watch(smartRepositoryProvider.future);
  return await repository.getDataStatistics();
});

/// State Notifiers for Interactive Features

/// Smart features state notifier
class SmartFeaturesNotifier extends StateNotifier<SmartFeaturesState> {
  final ProjectSmartRepository _repository;

  SmartFeaturesNotifier(this._repository) : super(const SmartFeaturesState());

  /// Updates configuration
  Future<void> updateConfig(Map<String, dynamic> config) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.updateSmartFeaturesConfig(config);
      state = state.copyWith(
        isLoading: false,
        config: config,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Updates notification preferences
  Future<void> updateNotificationPreferences(Map<String, bool> preferences) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.updateSmartNotificationPreferences(preferences);
      state = state.copyWith(
        isLoading: false,
        notificationPreferences: preferences,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Updates suggestion status
  Future<void> updateSuggestionStatus(
    String suggestionId,
    bool isAccepted,
    bool isDismissed,
    String? dismissalReason,
  ) async {
    try {
      await _repository.updateSuggestionStatus(
        suggestionId,
        isAccepted,
        isDismissed,
        dismissalReason,
      );
      // Trigger refresh of suggestions
      state = state.copyWith(lastUpdated: DateTime.now());
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Cleans up old data
  Future<void> cleanupOldData(Duration retentionPeriod) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.cleanupOldData(retentionPeriod);
      state = state.copyWith(
        isLoading: false,
        lastCleanup: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clears error state
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Smart features state
class SmartFeaturesState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> config;
  final Map<String, bool> notificationPreferences;
  final DateTime? lastUpdated;
  final DateTime? lastCleanup;

  const SmartFeaturesState({
    this.isLoading = false,
    this.error,
    this.config = const {},
    this.notificationPreferences = const {},
    this.lastUpdated,
    this.lastCleanup,
  });

  SmartFeaturesState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    Map<String, dynamic>? config,
    Map<String, bool>? notificationPreferences,
    DateTime? lastUpdated,
    DateTime? lastCleanup,
  }) {
    return SmartFeaturesState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      config: config ?? this.config,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastCleanup: lastCleanup ?? this.lastCleanup,
    );
  }
}

/// Smart features state notifier provider
final smartFeaturesNotifierProvider = FutureProvider<SmartFeaturesNotifier>((ref) async {
  final repository = await ref.watch(smartRepositoryProvider.future);
  return SmartFeaturesNotifier(repository);
});

/// Convenience providers for refreshing data

/// Refresh all smart features data
final refreshSmartFeaturesProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    ref.invalidate(projectsNeedingAttentionProvider);
    ref.invalidate(activeSuggestionsProvider);
    ref.invalidate(urgentSuggestionsProvider);
    ref.invalidate(suggestionAnalyticsProvider);
    ref.invalidate(highRiskProjectsProvider);
    ref.invalidate(projectCompletionPredictionsProvider);
    ref.invalidate(comprehensiveInsightsProvider);
    ref.invalidate(smartFeaturesDataStatsProvider);
  };
});

/// Refresh project-specific data
final refreshProjectSmartDataProvider = Provider.family<Future<void> Function(), String>((ref, projectId) {
  return () async {
    ref.invalidate(projectHealthProvider(projectId));
    ref.invalidate(projectAISuggestionsProvider(projectId));
    ref.invalidate(projectPredictiveAnalyticsProvider(projectId));
  };
});

/// Dashboard integration providers

/// Smart features dashboard summary
final smartFeaturesDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final results = await Future.wait([
    ref.watch(projectsNeedingAttentionProvider.future),
    ref.watch(urgentSuggestionsProvider.future),
    ref.watch(highRiskProjectsProvider.future),
    ref.watch(smartFeaturesDataStatsProvider.future),
  ]);
  
  final projectsNeedingAttention = results[0] as List;
  final urgentSuggestions = results[1] as List;
  final highRiskProjects = results[2] as List;
  final dataStats = results[3] as Map<String, dynamic>;

  return {
    'projects_needing_attention': projectsNeedingAttention.length,
    'urgent_suggestions': urgentSuggestions.length,
    'high_risk_projects': highRiskProjects.length,
    'health_records': dataStats['health_records'] ?? 0,
    'suggestion_records': dataStats['suggestion_records'] ?? 0,
    'prediction_records': dataStats['prediction_records'] ?? 0,
    'last_updated': DateTime.now().toIso8601String(),
  };
});

/// Smart features enabled check
final smartFeaturesEnabledProvider = FutureProvider<bool>((ref) async {
  final config = await ref.watch(smartFeaturesConfigProvider.future);
  return config['health_monitoring_enabled'] == true ||
         config['ai_suggestions_enabled'] == true ||
         config['predictive_analytics_enabled'] == true;
});