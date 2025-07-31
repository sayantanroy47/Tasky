// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsSummary _$AnalyticsSummaryFromJson(Map<String, dynamic> json) =>
    AnalyticsSummary(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalTasks: (json['totalTasks'] as num).toInt(),
      completedTasks: (json['completedTasks'] as num).toInt(),
      pendingTasks: (json['pendingTasks'] as num).toInt(),
      cancelledTasks: (json['cancelledTasks'] as num).toInt(),
      completionRate: (json['completionRate'] as num).toDouble(),
      currentStreak: (json['currentStreak'] as num).toInt(),
      longestStreak: (json['longestStreak'] as num).toInt(),
      averageTaskDuration: (json['averageTaskDuration'] as num).toDouble(),
      tasksByPriority: Map<String, int>.from(json['tasksByPriority'] as Map),
      tasksByStatus: Map<String, int>.from(json['tasksByStatus'] as Map),
      tasksByTag: Map<String, int>.from(json['tasksByTag'] as Map),
      tasksByProject: Map<String, int>.from(json['tasksByProject'] as Map),
      dailyStats: (json['dailyStats'] as List<dynamic>)
          .map((e) => DailyStats.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AnalyticsSummaryToJson(AnalyticsSummary instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'totalTasks': instance.totalTasks,
      'completedTasks': instance.completedTasks,
      'pendingTasks': instance.pendingTasks,
      'cancelledTasks': instance.cancelledTasks,
      'completionRate': instance.completionRate,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'averageTaskDuration': instance.averageTaskDuration,
      'tasksByPriority': instance.tasksByPriority,
      'tasksByStatus': instance.tasksByStatus,
      'tasksByTag': instance.tasksByTag,
      'tasksByProject': instance.tasksByProject,
      'dailyStats': instance.dailyStats,
    };

DailyStats _$DailyStatsFromJson(Map<String, dynamic> json) => DailyStats(
      date: DateTime.parse(json['date'] as String),
      totalTasks: (json['totalTasks'] as num).toInt(),
      completedTasks: (json['completedTasks'] as num).toInt(),
      createdTasks: (json['createdTasks'] as num).toInt(),
      completionRate: (json['completionRate'] as num).toDouble(),
      totalDuration: (json['totalDuration'] as num).toDouble(),
      tasksByPriority: Map<String, int>.from(json['tasksByPriority'] as Map),
      tasksByTag: Map<String, int>.from(json['tasksByTag'] as Map),
    );

Map<String, dynamic> _$DailyStatsToJson(DailyStats instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'totalTasks': instance.totalTasks,
      'completedTasks': instance.completedTasks,
      'createdTasks': instance.createdTasks,
      'completionRate': instance.completionRate,
      'totalDuration': instance.totalDuration,
      'tasksByPriority': instance.tasksByPriority,
      'tasksByTag': instance.tasksByTag,
    };

ProductivityMetrics _$ProductivityMetricsFromJson(Map<String, dynamic> json) =>
    ProductivityMetrics(
      weeklyCompletionRate: (json['weeklyCompletionRate'] as num).toDouble(),
      monthlyCompletionRate: (json['monthlyCompletionRate'] as num).toDouble(),
      tasksCompletedThisWeek: (json['tasksCompletedThisWeek'] as num).toInt(),
      tasksCompletedThisMonth: (json['tasksCompletedThisMonth'] as num).toInt(),
      currentStreak: (json['currentStreak'] as num).toInt(),
      longestStreak: (json['longestStreak'] as num).toInt(),
      weeklyTrend: (json['weeklyTrend'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      monthlyTrend: (json['monthlyTrend'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      hourlyProductivity:
          (json['hourlyProductivity'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
      ),
      weekdayProductivity:
          (json['weekdayProductivity'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
      ),
      averageTasksPerDay: (json['averageTasksPerDay'] as num).toDouble(),
      averageCompletionTime: (json['averageCompletionTime'] as num).toDouble(),
    );

Map<String, dynamic> _$ProductivityMetricsToJson(
        ProductivityMetrics instance) =>
    <String, dynamic>{
      'weeklyCompletionRate': instance.weeklyCompletionRate,
      'monthlyCompletionRate': instance.monthlyCompletionRate,
      'tasksCompletedThisWeek': instance.tasksCompletedThisWeek,
      'tasksCompletedThisMonth': instance.tasksCompletedThisMonth,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'weeklyTrend': instance.weeklyTrend,
      'monthlyTrend': instance.monthlyTrend,
      'hourlyProductivity':
          instance.hourlyProductivity.map((k, e) => MapEntry(k.toString(), e)),
      'weekdayProductivity':
          instance.weekdayProductivity.map((k, e) => MapEntry(k.toString(), e)),
      'averageTasksPerDay': instance.averageTasksPerDay,
      'averageCompletionTime': instance.averageCompletionTime,
    };

StreakInfo _$StreakInfoFromJson(Map<String, dynamic> json) => StreakInfo(
      currentStreak: (json['currentStreak'] as num).toInt(),
      longestStreak: (json['longestStreak'] as num).toInt(),
      lastCompletionDate: json['lastCompletionDate'] == null
          ? null
          : DateTime.parse(json['lastCompletionDate'] as String),
      streakStartDate: json['streakStartDate'] == null
          ? null
          : DateTime.parse(json['streakStartDate'] as String),
      longestStreakStartDate: json['longestStreakStartDate'] == null
          ? null
          : DateTime.parse(json['longestStreakStartDate'] as String),
      longestStreakEndDate: json['longestStreakEndDate'] == null
          ? null
          : DateTime.parse(json['longestStreakEndDate'] as String),
      completionDates: (json['completionDates'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
    );

Map<String, dynamic> _$StreakInfoToJson(StreakInfo instance) =>
    <String, dynamic>{
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'lastCompletionDate': instance.lastCompletionDate?.toIso8601String(),
      'streakStartDate': instance.streakStartDate?.toIso8601String(),
      'longestStreakStartDate':
          instance.longestStreakStartDate?.toIso8601String(),
      'longestStreakEndDate': instance.longestStreakEndDate?.toIso8601String(),
      'completionDates':
          instance.completionDates.map((e) => e.toIso8601String()).toList(),
    };

CategoryAnalytics _$CategoryAnalyticsFromJson(Map<String, dynamic> json) =>
    CategoryAnalytics(
      categoryName: json['categoryName'] as String,
      categoryId: json['categoryId'] as String,
      totalTasks: (json['totalTasks'] as num).toInt(),
      completedTasks: (json['completedTasks'] as num).toInt(),
      pendingTasks: (json['pendingTasks'] as num).toInt(),
      completionRate: (json['completionRate'] as num).toDouble(),
      averageDuration: (json['averageDuration'] as num).toDouble(),
      priorityDistribution:
          Map<String, int>.from(json['priorityDistribution'] as Map),
    );

Map<String, dynamic> _$CategoryAnalyticsToJson(CategoryAnalytics instance) =>
    <String, dynamic>{
      'categoryName': instance.categoryName,
      'categoryId': instance.categoryId,
      'totalTasks': instance.totalTasks,
      'completedTasks': instance.completedTasks,
      'pendingTasks': instance.pendingTasks,
      'completionRate': instance.completionRate,
      'averageDuration': instance.averageDuration,
      'priorityDistribution': instance.priorityDistribution,
    };

DateRange _$DateRangeFromJson(Map<String, dynamic> json) => DateRange(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );

Map<String, dynamic> _$DateRangeToJson(DateRange instance) => <String, dynamic>{
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
    };

ProductivityPatterns _$ProductivityPatternsFromJson(
        Map<String, dynamic> json) =>
    ProductivityPatterns(
      hourlyEfficiency: (json['hourlyEfficiency'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), (e as num).toDouble()),
      ),
      weekdayEfficiency:
          (json['weekdayEfficiency'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), (e as num).toDouble()),
      ),
      peaks: (json['peaks'] as List<dynamic>)
          .map((e) => ProductivityPeak.fromJson(e as Map<String, dynamic>))
          .toList(),
      troughs: (json['troughs'] as List<dynamic>)
          .map((e) => ProductivityTrough.fromJson(e as Map<String, dynamic>))
          .toList(),
      consistencyScore: (json['consistencyScore'] as num).toDouble(),
      categoryEfficiency:
          (json['categoryEfficiency'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      trends: (json['trends'] as List<dynamic>)
          .map((e) => ProductivityTrend.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProductivityPatternsToJson(
        ProductivityPatterns instance) =>
    <String, dynamic>{
      'hourlyEfficiency':
          instance.hourlyEfficiency.map((k, e) => MapEntry(k.toString(), e)),
      'weekdayEfficiency':
          instance.weekdayEfficiency.map((k, e) => MapEntry(k.toString(), e)),
      'peaks': instance.peaks,
      'troughs': instance.troughs,
      'consistencyScore': instance.consistencyScore,
      'categoryEfficiency': instance.categoryEfficiency,
      'trends': instance.trends,
    };

PeakHoursAnalysis _$PeakHoursAnalysisFromJson(Map<String, dynamic> json) =>
    PeakHoursAnalysis(
      peakHours: (json['peakHours'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      lowHours: (json['lowHours'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      peakProductivityScore: (json['peakProductivityScore'] as num).toDouble(),
      averageProductivityScore:
          (json['averageProductivityScore'] as num).toDouble(),
      suggestions: (json['suggestions'] as List<dynamic>)
          .map(
              (e) => OptimizationSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      hourlyTaskTypes: (json['hourlyTaskTypes'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k),
            TaskTypeDistribution.fromJson(e as Map<String, dynamic>)),
      ),
      optimalWorkingHours: (json['optimalWorkingHours'] as num).toInt(),
      recommendedWorkingWindow: TimeRange.fromJson(
          json['recommendedWorkingWindow'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PeakHoursAnalysisToJson(PeakHoursAnalysis instance) =>
    <String, dynamic>{
      'peakHours': instance.peakHours,
      'lowHours': instance.lowHours,
      'peakProductivityScore': instance.peakProductivityScore,
      'averageProductivityScore': instance.averageProductivityScore,
      'suggestions': instance.suggestions,
      'hourlyTaskTypes':
          instance.hourlyTaskTypes.map((k, e) => MapEntry(k.toString(), e)),
      'optimalWorkingHours': instance.optimalWorkingHours,
      'recommendedWorkingWindow': instance.recommendedWorkingWindow,
    };

AdvancedCategoryAnalytics _$AdvancedCategoryAnalyticsFromJson(
        Map<String, dynamic> json) =>
    AdvancedCategoryAnalytics(
      categories: (json['categories'] as List<dynamic>)
          .map((e) => CategoryAnalytics.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryTrends: (json['categoryTrends'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, CategoryTrend.fromJson(e as Map<String, dynamic>)),
      ),
      correlations: (json['correlations'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            (e as List<dynamic>)
                .map((e) =>
                    CategoryCorrelation.fromJson(e as Map<String, dynamic>))
                .toList()),
      ),
      ranking: CategoryPerformanceRanking.fromJson(
          json['ranking'] as Map<String, dynamic>),
      insights: (json['insights'] as List<dynamic>)
          .map((e) => CategoryInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryHourlyDistribution:
          (json['categoryHourlyDistribution'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            (e as Map<String, dynamic>).map(
              (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
            )),
      ),
      categoryWeekdayDistribution:
          (json['categoryWeekdayDistribution'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            (e as Map<String, dynamic>).map(
              (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
            )),
      ),
    );

Map<String, dynamic> _$AdvancedCategoryAnalyticsToJson(
        AdvancedCategoryAnalytics instance) =>
    <String, dynamic>{
      'categories': instance.categories,
      'categoryTrends': instance.categoryTrends,
      'correlations': instance.correlations,
      'ranking': instance.ranking,
      'insights': instance.insights,
      'categoryHourlyDistribution': instance.categoryHourlyDistribution.map(
          (k, e) => MapEntry(k, e.map((k, e) => MapEntry(k.toString(), e)))),
      'categoryWeekdayDistribution': instance.categoryWeekdayDistribution.map(
          (k, e) => MapEntry(k, e.map((k, e) => MapEntry(k.toString(), e)))),
    };

ProductivityInsights _$ProductivityInsightsFromJson(
        Map<String, dynamic> json) =>
    ProductivityInsights(
      insights: (json['insights'] as List<dynamic>)
          .map((e) => ProductivityInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
      suggestions: (json['suggestions'] as List<dynamic>)
          .map(
              (e) => OptimizationSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallScore: ProductivityScore.fromJson(
          json['overallScore'] as Map<String, dynamic>),
      recommendedGoals: (json['recommendedGoals'] as List<dynamic>)
          .map((e) => ProductivityGoal.fromJson(e as Map<String, dynamic>))
          .toList(),
      strengthAreas: (json['strengthAreas'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      improvementAreas: (json['improvementAreas'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$ProductivityInsightsToJson(
        ProductivityInsights instance) =>
    <String, dynamic>{
      'insights': instance.insights,
      'suggestions': instance.suggestions,
      'overallScore': instance.overallScore,
      'recommendedGoals': instance.recommendedGoals,
      'strengthAreas': instance.strengthAreas,
      'improvementAreas': instance.improvementAreas,
    };

ProductivityPeak _$ProductivityPeakFromJson(Map<String, dynamic> json) =>
    ProductivityPeak(
      hour: (json['hour'] as num).toInt(),
      efficiency: (json['efficiency'] as num).toDouble(),
      taskCount: (json['taskCount'] as num).toInt(),
      description: json['description'] as String,
    );

Map<String, dynamic> _$ProductivityPeakToJson(ProductivityPeak instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'efficiency': instance.efficiency,
      'taskCount': instance.taskCount,
      'description': instance.description,
    };

ProductivityTrough _$ProductivityTroughFromJson(Map<String, dynamic> json) =>
    ProductivityTrough(
      hour: (json['hour'] as num).toInt(),
      efficiency: (json['efficiency'] as num).toDouble(),
      taskCount: (json['taskCount'] as num).toInt(),
      description: json['description'] as String,
    );

Map<String, dynamic> _$ProductivityTroughToJson(ProductivityTrough instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'efficiency': instance.efficiency,
      'taskCount': instance.taskCount,
      'description': instance.description,
    };

ProductivityTrend _$ProductivityTrendFromJson(Map<String, dynamic> json) =>
    ProductivityTrend(
      type: json['type'] as String,
      category: json['category'] as String,
      changeRate: (json['changeRate'] as num).toDouble(),
      description: json['description'] as String,
    );

Map<String, dynamic> _$ProductivityTrendToJson(ProductivityTrend instance) =>
    <String, dynamic>{
      'type': instance.type,
      'category': instance.category,
      'changeRate': instance.changeRate,
      'description': instance.description,
    };

OptimizationSuggestion _$OptimizationSuggestionFromJson(
        Map<String, dynamic> json) =>
    OptimizationSuggestion(
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      impactScore: (json['impactScore'] as num).toDouble(),
      actionType: json['actionType'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$OptimizationSuggestionToJson(
        OptimizationSuggestion instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'impactScore': instance.impactScore,
      'actionType': instance.actionType,
      'metadata': instance.metadata,
    };

TaskTypeDistribution _$TaskTypeDistributionFromJson(
        Map<String, dynamic> json) =>
    TaskTypeDistribution(
      priorityDistribution:
          Map<String, int>.from(json['priorityDistribution'] as Map),
      categoryDistribution:
          Map<String, int>.from(json['categoryDistribution'] as Map),
      averageDuration: (json['averageDuration'] as num).toDouble(),
      completionRate: (json['completionRate'] as num).toDouble(),
    );

Map<String, dynamic> _$TaskTypeDistributionToJson(
        TaskTypeDistribution instance) =>
    <String, dynamic>{
      'priorityDistribution': instance.priorityDistribution,
      'categoryDistribution': instance.categoryDistribution,
      'averageDuration': instance.averageDuration,
      'completionRate': instance.completionRate,
    };

TimeRange _$TimeRangeFromJson(Map<String, dynamic> json) => TimeRange(
      startHour: (json['startHour'] as num).toInt(),
      endHour: (json['endHour'] as num).toInt(),
      description: json['description'] as String,
    );

Map<String, dynamic> _$TimeRangeToJson(TimeRange instance) => <String, dynamic>{
      'startHour': instance.startHour,
      'endHour': instance.endHour,
      'description': instance.description,
    };

CategoryTrend _$CategoryTrendFromJson(Map<String, dynamic> json) =>
    CategoryTrend(
      categoryId: json['categoryId'] as String,
      completionRates: (json['completionRates'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      trendDirection: json['trendDirection'] as String,
      changeRate: (json['changeRate'] as num).toDouble(),
    );

Map<String, dynamic> _$CategoryTrendToJson(CategoryTrend instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'completionRates': instance.completionRates,
      'trendDirection': instance.trendDirection,
      'changeRate': instance.changeRate,
    };

CategoryCorrelation _$CategoryCorrelationFromJson(Map<String, dynamic> json) =>
    CategoryCorrelation(
      categoryA: json['categoryA'] as String,
      categoryB: json['categoryB'] as String,
      correlationScore: (json['correlationScore'] as num).toDouble(),
      description: json['description'] as String,
    );

Map<String, dynamic> _$CategoryCorrelationToJson(
        CategoryCorrelation instance) =>
    <String, dynamic>{
      'categoryA': instance.categoryA,
      'categoryB': instance.categoryB,
      'correlationScore': instance.correlationScore,
      'description': instance.description,
    };

CategoryPerformanceRanking _$CategoryPerformanceRankingFromJson(
        Map<String, dynamic> json) =>
    CategoryPerformanceRanking(
      topPerformingCategories:
          (json['topPerformingCategories'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      underperformingCategories:
          (json['underperformingCategories'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      categoryScores: (json['categoryScores'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
    );

Map<String, dynamic> _$CategoryPerformanceRankingToJson(
        CategoryPerformanceRanking instance) =>
    <String, dynamic>{
      'topPerformingCategories': instance.topPerformingCategories,
      'underperformingCategories': instance.underperformingCategories,
      'categoryScores': instance.categoryScores,
    };

CategoryInsight _$CategoryInsightFromJson(Map<String, dynamic> json) =>
    CategoryInsight(
      categoryId: json['categoryId'] as String,
      insightType: json['insightType'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$CategoryInsightToJson(CategoryInsight instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'insightType': instance.insightType,
      'title': instance.title,
      'description': instance.description,
      'confidence': instance.confidence,
    };

ProductivityInsight _$ProductivityInsightFromJson(Map<String, dynamic> json) =>
    ProductivityInsight(
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      data: json['data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ProductivityInsightToJson(
        ProductivityInsight instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'confidence': instance.confidence,
      'data': instance.data,
    };

ProductivityScore _$ProductivityScoreFromJson(Map<String, dynamic> json) =>
    ProductivityScore(
      overall: (json['overall'] as num).toDouble(),
      consistency: (json['consistency'] as num).toDouble(),
      efficiency: (json['efficiency'] as num).toDouble(),
      completion: (json['completion'] as num).toDouble(),
      timeManagement: (json['timeManagement'] as num).toDouble(),
      grade: json['grade'] as String,
    );

Map<String, dynamic> _$ProductivityScoreToJson(ProductivityScore instance) =>
    <String, dynamic>{
      'overall': instance.overall,
      'consistency': instance.consistency,
      'efficiency': instance.efficiency,
      'completion': instance.completion,
      'timeManagement': instance.timeManagement,
      'grade': instance.grade,
    };

ProductivityGoal _$ProductivityGoalFromJson(Map<String, dynamic> json) =>
    ProductivityGoal(
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      targetValue: (json['targetValue'] as num).toDouble(),
      timeframe: json['timeframe'] as String,
      actionSteps: (json['actionSteps'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ProductivityGoalToJson(ProductivityGoal instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'targetValue': instance.targetValue,
      'timeframe': instance.timeframe,
      'actionSteps': instance.actionSteps,
    };
