import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/project_health.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../../domain/entities/project_prediction.dart';
import '../../domain/repositories/project_smart_repository.dart';
import '../../services/database/database.dart';

/// Implementation of ProjectSmartRepository using SharedPreferences and SQLite
class ProjectSmartRepositoryImpl implements ProjectSmartRepository {
  // ignore: unused_field
  final AppDatabase _database;
  final SharedPreferences _prefs;
  
  // Cache keys
  static const String _healthCachePrefix = 'project_health_';
  static const String _suggestionsCachePrefix = 'ai_suggestions_';
  static const String _predictionsCachePrefix = 'predictions_';
  static const String _patternsCacheKey = 'project_patterns';
  static const String _configKey = 'smart_features_config';
  static const String _notificationPrefsKey = 'smart_notification_prefs';

  ProjectSmartRepositoryImpl(this._database, this._prefs);

  @override
  Future<ProjectHealth?> getProjectHealth(String projectId) async {
    try {
      final cached = _prefs.getString('$_healthCachePrefix$projectId');
      if (cached != null) {
        final data = jsonDecode(cached) as Map<String, dynamic>;
        return ProjectHealth.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting project health: $e');
      return null;
    }
  }

  @override
  Future<Map<String, ProjectHealth>> getProjectsHealth(List<String> projectIds) async {
    final healthMap = <String, ProjectHealth>{};
    
    for (final projectId in projectIds) {
      final health = await getProjectHealth(projectId);
      if (health != null) {
        healthMap[projectId] = health;
      }
    }
    
    return healthMap;
  }

  @override
  Future<void> saveProjectHealth(ProjectHealth health) async {
    try {
      final json = jsonEncode(health.toJson());
      await _prefs.setString('$_healthCachePrefix${health.projectId}', json);
      
      // Also save timestamp for cleanup
      await _prefs.setInt(
        '${_healthCachePrefix}timestamp_${health.projectId}', 
        health.calculatedAt.millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Error saving project health: $e');
      rethrow;
    }
  }

  @override
  Future<List<ProjectHealth>> getProjectHealthHistory(
    String projectId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // In a production system, this would query a dedicated health history table
    // For now, we'll return the current health if it falls within the date range
    final current = await getProjectHealth(projectId);
    if (current != null && 
        current.calculatedAt.isAfter(startDate) && 
        current.calculatedAt.isBefore(endDate)) {
      return [current];
    }
    return [];
  }

  @override
  Future<List<String>> getProjectsNeedingAttention() async {
    final allKeys = _prefs.getKeys().where((k) => k.startsWith(_healthCachePrefix)).toList();
    final needingAttention = <String>[];
    
    for (final key in allKeys) {
      if (key.contains('timestamp_')) continue; // Skip timestamp keys
      
      try {
        final projectId = key.replaceFirst(_healthCachePrefix, '');
        final health = await getProjectHealth(projectId);
        
        if (health != null && health.needsImmediateAttention) {
          needingAttention.add(projectId);
        }
      } catch (e) {
        continue; // Skip invalid entries
      }
    }
    
    return needingAttention;
  }

  @override
  Future<ProjectAISuggestions?> getProjectAISuggestions(String projectId) async {
    try {
      final cached = _prefs.getString('$_suggestionsCachePrefix$projectId');
      if (cached != null) {
        final data = jsonDecode(cached) as Map<String, dynamic>;
        return ProjectAISuggestions.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting AI suggestions: $e');
      return null;
    }
  }

  @override
  Future<void> saveProjectAISuggestions(ProjectAISuggestions suggestions) async {
    try {
      final json = jsonEncode(suggestions.toJson());
      await _prefs.setString('$_suggestionsCachePrefix${suggestions.projectId}', json);
      
      // Save timestamp for cleanup
      await _prefs.setInt(
        '${_suggestionsCachePrefix}timestamp_${suggestions.projectId}', 
        suggestions.lastUpdated.millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Error saving AI suggestions: $e');
      rethrow;
    }
  }

  @override
  Future<List<AISuggestion>> getActiveSuggestions({int? limit}) async {
    final allSuggestions = <AISuggestion>[];
    final keys = _prefs.getKeys().where((k) => k.startsWith(_suggestionsCachePrefix)).toList();
    
    for (final key in keys) {
      if (key.contains('timestamp_')) continue;
      
      try {
        final projectId = key.replaceFirst(_suggestionsCachePrefix, '');
        final suggestions = await getProjectAISuggestions(projectId);
        
        if (suggestions != null) {
          allSuggestions.addAll(suggestions.activeSuggestions);
        }
      } catch (e) {
        continue;
      }
    }
    
    // Sort by priority and creation date
    allSuggestions.sort((a, b) {
      final priorityComparison = _getPriorityWeight(b.priority).compareTo(_getPriorityWeight(a.priority));
      if (priorityComparison != 0) return priorityComparison;
      return b.generatedAt.compareTo(a.generatedAt);
    });
    
    if (limit != null && limit > 0) {
      return allSuggestions.take(limit).toList();
    }
    
    return allSuggestions;
  }

  @override
  Future<List<AISuggestion>> getUrgentSuggestions() async {
    final activeSuggestions = await getActiveSuggestions();
    return activeSuggestions.where((s) => 
        s.priority == SuggestionPriority.urgent || 
        s.priority == SuggestionPriority.high).toList();
  }

  @override
  Future<void> updateSuggestionStatus(
    String suggestionId,
    bool isAccepted,
    bool isDismissed,
    String? dismissalReason,
  ) async {
    // Find and update the suggestion across all projects
    final keys = _prefs.getKeys().where((k) => k.startsWith(_suggestionsCachePrefix)).toList();
    
    for (final key in keys) {
      if (key.contains('timestamp_')) continue;
      
      try {
        final projectId = key.replaceFirst(_suggestionsCachePrefix, '');
        final suggestions = await getProjectAISuggestions(projectId);
        
        if (suggestions != null) {
          final suggestionIndex = suggestions.suggestions.indexWhere((s) => s.id == suggestionId);
          
          if (suggestionIndex != -1) {
            final updatedSuggestions = List<AISuggestion>.from(suggestions.suggestions);
            final suggestion = updatedSuggestions[suggestionIndex];
            
            if (isAccepted) {
              updatedSuggestions[suggestionIndex] = suggestion.accept();
            } else if (isDismissed) {
              updatedSuggestions[suggestionIndex] = suggestion.dismiss(dismissalReason ?? 'Dismissed by user');
            }
            
            final updatedProjectSuggestions = suggestions.copyWith(
              suggestions: updatedSuggestions,
            );
            
            await saveProjectAISuggestions(updatedProjectSuggestions);
            return;
          }
        }
      } catch (e) {
        continue;
      }
    }
  }

  @override
  Future<Map<String, dynamic>> getSuggestionAnalytics() async {
    final analytics = <String, dynamic>{
      'total_suggestions': 0,
      'accepted_suggestions': 0,
      'dismissed_suggestions': 0,
      'active_suggestions': 0,
      'acceptance_rate': 0.0,
      'dismissal_rate': 0.0,
      'suggestions_by_type': <String, int>{},
      'suggestions_by_priority': <String, int>{},
    };
    
    final allSuggestions = <AISuggestion>[];
    final keys = _prefs.getKeys().where((k) => k.startsWith(_suggestionsCachePrefix)).toList();
    
    for (final key in keys) {
      if (key.contains('timestamp_')) continue;
      
      try {
        final projectId = key.replaceFirst(_suggestionsCachePrefix, '');
        final suggestions = await getProjectAISuggestions(projectId);
        
        if (suggestions != null) {
          allSuggestions.addAll(suggestions.suggestions);
        }
      } catch (e) {
        continue;
      }
    }
    
    if (allSuggestions.isEmpty) return analytics;
    
    analytics['total_suggestions'] = allSuggestions.length;
    analytics['accepted_suggestions'] = allSuggestions.where((s) => s.isAccepted).length;
    analytics['dismissed_suggestions'] = allSuggestions.where((s) => s.isDismissed).length;
    analytics['active_suggestions'] = allSuggestions.where((s) => s.isActive).length;
    
    final total = allSuggestions.length;
    analytics['acceptance_rate'] = analytics['accepted_suggestions'] / total;
    analytics['dismissal_rate'] = analytics['dismissed_suggestions'] / total;
    
    // Group by type and priority
    final byType = <String, int>{};
    final byPriority = <String, int>{};
    
    for (final suggestion in allSuggestions) {
      final type = suggestion.type.name;
      final priority = suggestion.priority.name;
      
      byType[type] = (byType[type] ?? 0) + 1;
      byPriority[priority] = (byPriority[priority] ?? 0) + 1;
    }
    
    analytics['suggestions_by_type'] = byType;
    analytics['suggestions_by_priority'] = byPriority;
    
    return analytics;
  }

  @override
  Future<ProjectPredictiveAnalytics?> getProjectPredictiveAnalytics(String projectId) async {
    try {
      final cached = _prefs.getString('$_predictionsCachePrefix$projectId');
      if (cached != null) {
        final data = jsonDecode(cached) as Map<String, dynamic>;
        return ProjectPredictiveAnalytics.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting predictive analytics: $e');
      return null;
    }
  }

  @override
  Future<void> saveProjectPredictiveAnalytics(ProjectPredictiveAnalytics analytics) async {
    try {
      final json = jsonEncode(analytics.toJson());
      await _prefs.setString('$_predictionsCachePrefix${analytics.projectId}', json);
      
      // Save timestamp for cleanup
      await _prefs.setInt(
        '${_predictionsCachePrefix}timestamp_${analytics.projectId}', 
        analytics.generatedAt.millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Error saving predictive analytics: $e');
      rethrow;
    }
  }

  @override
  Future<List<ProjectPrediction>> getPredictionsByType(PredictionType type) async {
    final predictions = <ProjectPrediction>[];
    final keys = _prefs.getKeys().where((k) => k.startsWith(_predictionsCachePrefix)).toList();
    
    for (final key in keys) {
      if (key.contains('timestamp_')) continue;
      
      try {
        final projectId = key.replaceFirst(_predictionsCachePrefix, '');
        final analytics = await getProjectPredictiveAnalytics(projectId);
        
        if (analytics != null) {
          predictions.addAll(analytics.predictions.where((p) => p.type == type));
        }
      } catch (e) {
        continue;
      }
    }
    
    return predictions;
  }

  @override
  Future<List<String>> getHighRiskProjects() async {
    final highRiskProjects = <String>[];
    final keys = _prefs.getKeys().where((k) => k.startsWith(_predictionsCachePrefix)).toList();
    
    for (final key in keys) {
      if (key.contains('timestamp_')) continue;
      
      try {
        final projectId = key.replaceFirst(_predictionsCachePrefix, '');
        final analytics = await getProjectPredictiveAnalytics(projectId);
        
        if (analytics != null && analytics.isHighRisk) {
          highRiskProjects.add(projectId);
        }
      } catch (e) {
        continue;
      }
    }
    
    return highRiskProjects;
  }

  @override
  Future<Map<String, DateTime>> getProjectCompletionPredictions() async {
    final predictions = <String, DateTime>{};
    final keys = _prefs.getKeys().where((k) => k.startsWith(_predictionsCachePrefix)).toList();
    
    for (final key in keys) {
      if (key.contains('timestamp_')) continue;
      
      try {
        final projectId = key.replaceFirst(_predictionsCachePrefix, '');
        final analytics = await getProjectPredictiveAnalytics(projectId);
        
        if (analytics?.predictedCompletionDate != null) {
          predictions[projectId] = analytics!.predictedCompletionDate!;
        }
      } catch (e) {
        continue;
      }
    }
    
    return predictions;
  }

  @override
  Future<void> updatePredictionAccuracy(
    String predictionId,
    dynamic actualValue,
    DateTime actualDate,
  ) async {
    // Find the prediction and update its accuracy
    final keys = _prefs.getKeys().where((k) => k.startsWith(_predictionsCachePrefix)).toList();
    
    for (final key in keys) {
      if (key.contains('timestamp_')) continue;
      
      try {
        final projectId = key.replaceFirst(_predictionsCachePrefix, '');
        final analytics = await getProjectPredictiveAnalytics(projectId);
        
        if (analytics != null) {
          final predictionIndex = analytics.predictions.indexWhere((p) => p.id == predictionId);
          
          if (predictionIndex != -1) {
            final updatedPredictions = List<ProjectPrediction>.from(analytics.predictions);
            final prediction = updatedPredictions[predictionIndex];
            
            // Calculate accuracy based on prediction type
            double accuracy = 0.0;
            if (prediction.type == PredictionType.completionDate && actualValue is DateTime) {
              final predictedDate = prediction.predictedValue as DateTime;
              final daysDifference = (actualValue.difference(predictedDate).inDays).abs();
              accuracy = (1.0 - (daysDifference / 30.0)).clamp(0.0, 1.0) * 100; // Max 30 days difference
            }
            
            // Update prediction with accuracy
            updatedPredictions[predictionIndex] = prediction.copyWith(
              historicalAccuracy: accuracy,
              metadata: {
                ...prediction.metadata,
                'actual_value': actualValue.toString(),
                'actual_date': actualDate.toIso8601String(),
                'accuracy_updated': true,
              },
            );
            
            final updatedAnalytics = ProjectPredictiveAnalytics(
              projectId: analytics.projectId,
              predictions: updatedPredictions,
              overallRisk: analytics.overallRisk,
              predictedCompletionDate: analytics.predictedCompletionDate,
              completionDateConfidence: analytics.completionDateConfidence,
              successProbability: analytics.successProbability,
              riskFactors: analytics.riskFactors,
              recommendedActions: analytics.recommendedActions,
              generatedAt: analytics.generatedAt,
              nextUpdateAt: analytics.nextUpdateAt,
            );
            
            await saveProjectPredictiveAnalytics(updatedAnalytics);
            return;
          }
        }
      } catch (e) {
        continue;
      }
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getProjectPatterns() async {
    final patterns = _prefs.getString(_patternsCacheKey);
    if (patterns != null) {
      final data = jsonDecode(patterns) as List;
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Future<void> saveProjectPattern(Map<String, dynamic> pattern) async {
    final existingPatterns = await getProjectPatterns();
    existingPatterns.add({
      ...pattern,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Keep only the last 100 patterns
    final patternsToKeep = existingPatterns.length > 100 
        ? existingPatterns.skip(existingPatterns.length - 100).toList()
        : existingPatterns;
    
    final json = jsonEncode(patternsToKeep);
    await _prefs.setString(_patternsCacheKey, json);
  }

  @override
  Future<Map<String, List<double>>> getProductivityTrends(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // This would typically query historical analytics data
    // For now, return empty trends
    return {};
  }

  @override
  Future<Map<String, dynamic>> getWorkloadDistribution() async {
    // This would analyze current task distribution
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'message': 'Workload distribution analysis not yet implemented',
    };
  }

  @override
  Future<Map<String, List<String>>> getBottleneckAnalysis() async {
    // This would identify project bottlenecks
    return {};
  }

  @override
  Future<Map<String, dynamic>> getSmartFeaturesConfig() async {
    final config = _prefs.getString(_configKey);
    if (config != null) {
      return jsonDecode(config) as Map<String, dynamic>;
    }
    
    // Return default configuration
    return {
      'health_monitoring_enabled': true,
      'ai_suggestions_enabled': true,
      'predictive_analytics_enabled': true,
      'smart_notifications_enabled': true,
      'automated_insights_enabled': true,
      'update_frequency_hours': 6,
      'retention_days': 30,
    };
  }

  @override
  Future<void> updateSmartFeaturesConfig(Map<String, dynamic> config) async {
    final json = jsonEncode(config);
    await _prefs.setString(_configKey, json);
  }

  @override
  Future<Map<String, bool>> getSmartNotificationPreferences() async {
    final prefs = _prefs.getString(_notificationPrefsKey);
    if (prefs != null) {
      final data = jsonDecode(prefs) as Map<String, dynamic>;
      return data.cast<String, bool>();
    }
    
    // Return default preferences
    return {
      'health_alerts': true,
      'ai_suggestions': true,
      'deadline_warnings': true,
      'productivity_insights': false,
      'risk_alerts': true,
      'milestone_celebrations': true,
      'idle_project_alerts': true,
      'blocker_notifications': true,
    };
  }

  @override
  Future<void> updateSmartNotificationPreferences(Map<String, bool> preferences) async {
    final json = jsonEncode(preferences);
    await _prefs.setString(_notificationPrefsKey, json);
  }

  @override
  Future<void> cleanupOldData(Duration retentionPeriod) async {
    final cutoffDate = DateTime.now().subtract(retentionPeriod);
    final keysToRemove = <String>[];
    
    // Clean up health data
    final healthKeys = _prefs.getKeys().where((k) => k.startsWith('${_healthCachePrefix}timestamp_')).toList();
    for (final key in healthKeys) {
      final timestamp = _prefs.getInt(key);
      if (timestamp != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (date.isBefore(cutoffDate)) {
          final projectId = key.replaceFirst('${_healthCachePrefix}timestamp_', '');
          keysToRemove.add(key);
          keysToRemove.add('$_healthCachePrefix$projectId');
        }
      }
    }
    
    // Clean up suggestions data
    final suggestionKeys = _prefs.getKeys().where((k) => k.startsWith('${_suggestionsCachePrefix}timestamp_')).toList();
    for (final key in suggestionKeys) {
      final timestamp = _prefs.getInt(key);
      if (timestamp != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (date.isBefore(cutoffDate)) {
          final projectId = key.replaceFirst('${_suggestionsCachePrefix}timestamp_', '');
          keysToRemove.add(key);
          keysToRemove.add('$_suggestionsCachePrefix$projectId');
        }
      }
    }
    
    // Clean up predictions data
    final predictionKeys = _prefs.getKeys().where((k) => k.startsWith('${_predictionsCachePrefix}timestamp_')).toList();
    for (final key in predictionKeys) {
      final timestamp = _prefs.getInt(key);
      if (timestamp != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (date.isBefore(cutoffDate)) {
          final projectId = key.replaceFirst('${_predictionsCachePrefix}timestamp_', '');
          keysToRemove.add(key);
          keysToRemove.add('$_predictionsCachePrefix$projectId');
        }
      }
    }
    
    // Remove all identified keys
    for (final key in keysToRemove) {
      await _prefs.remove(key);
    }
  }

  @override
  Future<void> archiveProcessedData(DateTime beforeDate) async {
    // This would move processed data to an archive table
    // For now, we'll just clean it up
    await cleanupOldData(DateTime.now().difference(beforeDate));
  }

  @override
  Future<Map<String, int>> getDataStatistics() async {
    final stats = <String, int>{};
    
    // Count health records
    final healthKeys = _prefs.getKeys().where((k) => 
        k.startsWith(_healthCachePrefix) && !k.contains('timestamp_')).length;
    stats['health_records'] = healthKeys;
    
    // Count suggestion records
    final suggestionKeys = _prefs.getKeys().where((k) => 
        k.startsWith(_suggestionsCachePrefix) && !k.contains('timestamp_')).length;
    stats['suggestion_records'] = suggestionKeys;
    
    // Count prediction records
    final predictionKeys = _prefs.getKeys().where((k) => 
        k.startsWith(_predictionsCachePrefix) && !k.contains('timestamp_')).length;
    stats['prediction_records'] = predictionKeys;
    
    // Count patterns
    final patterns = await getProjectPatterns();
    stats['pattern_records'] = patterns.length;
    
    return stats;
  }

  // Helper methods
  
  int _getPriorityWeight(SuggestionPriority priority) {
    switch (priority) {
      case SuggestionPriority.urgent:
        return 4;
      case SuggestionPriority.high:
        return 3;
      case SuggestionPriority.medium:
        return 2;
      case SuggestionPriority.low:
        return 1;
    }
  }
}