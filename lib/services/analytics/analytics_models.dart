import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'analytics_models.g.dart';

/// Analytics data models for task completion tracking and productivity metrics

/// Overall analytics summary for a given time period
@JsonSerializable()
class AnalyticsSummary extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int cancelledTasks;
  final double completionRate;
  final int currentStreak;
  final int longestStreak;
  final double averageTaskDuration;
  final Map<String, int> tasksByPriority;
  final Map<String, int> tasksByStatus;
  final Map<String, int> tasksByTag;
  final Map<String, int> tasksByProject;
  final List<DailyStats> dailyStats;

  const AnalyticsSummary({
    required this.startDate,
    required this.endDate,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.cancelledTasks,
    required this.completionRate,
    required this.currentStreak,
    required this.longestStreak,
    required this.averageTaskDuration,
    required this.tasksByPriority,
    required this.tasksByStatus,
    required this.tasksByTag,
    required this.tasksByProject,
    required this.dailyStats,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsSummaryToJson(this);

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        totalTasks,
        completedTasks,
        pendingTasks,
        cancelledTasks,
        completionRate,
        currentStreak,
        longestStreak,
        averageTaskDuration,
        tasksByPriority,
        tasksByStatus,
        tasksByTag,
        tasksByProject,
        dailyStats,
      ];
}

/// Daily statistics for task completion
@JsonSerializable()
class DailyStats extends Equatable {
  final DateTime date;
  final int totalTasks;
  final int completedTasks;
  final int createdTasks;
  final double completionRate;
  final double totalDuration;
  final Map<String, int> tasksByPriority;
  final Map<String, int> tasksByTag;

  const DailyStats({
    required this.date,
    required this.totalTasks,
    required this.completedTasks,
    required this.createdTasks,
    required this.completionRate,
    required this.totalDuration,
    required this.tasksByPriority,
    required this.tasksByTag,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) =>
      _$DailyStatsFromJson(json);

  Map<String, dynamic> toJson() => _$DailyStatsToJson(this);

  @override
  List<Object?> get props => [
        date,
        totalTasks,
        completedTasks,
        createdTasks,
        completionRate,
        totalDuration,
        tasksByPriority,
        tasksByTag,
      ];
}

/// Productivity metrics for tracking patterns and trends
@JsonSerializable()
class ProductivityMetrics extends Equatable {
  final double weeklyCompletionRate;
  final double monthlyCompletionRate;
  final int tasksCompletedThisWeek;
  final int tasksCompletedThisMonth;
  final int currentStreak;
  final int longestStreak;
  final List<int> weeklyTrend; // Last 7 days completion counts
  final List<int> monthlyTrend; // Last 30 days completion counts
  final Map<int, int> hourlyProductivity; // Hour of day -> completion count
  final Map<int, int> weekdayProductivity; // Day of week -> completion count
  final double averageTasksPerDay;
  final double averageCompletionTime;

  const ProductivityMetrics({
    required this.weeklyCompletionRate,
    required this.monthlyCompletionRate,
    required this.tasksCompletedThisWeek,
    required this.tasksCompletedThisMonth,
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyTrend,
    required this.monthlyTrend,
    required this.hourlyProductivity,
    required this.weekdayProductivity,
    required this.averageTasksPerDay,
    required this.averageCompletionTime,
  });

  factory ProductivityMetrics.fromJson(Map<String, dynamic> json) =>
      _$ProductivityMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$ProductivityMetricsToJson(this);

  @override
  List<Object?> get props => [
        weeklyCompletionRate,
        monthlyCompletionRate,
        tasksCompletedThisWeek,
        tasksCompletedThisMonth,
        currentStreak,
        longestStreak,
        weeklyTrend,
        monthlyTrend,
        hourlyProductivity,
        weekdayProductivity,
        averageTasksPerDay,
        averageCompletionTime,
      ];
}

/// Streak tracking information
@JsonSerializable()
class StreakInfo extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletionDate;
  final DateTime? streakStartDate;
  final DateTime? longestStreakStartDate;
  final DateTime? longestStreakEndDate;
  final List<DateTime> completionDates;

  const StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    this.lastCompletionDate,
    this.streakStartDate,
    this.longestStreakStartDate,
    this.longestStreakEndDate,
    required this.completionDates,
  });

  factory StreakInfo.fromJson(Map<String, dynamic> json) =>
      _$StreakInfoFromJson(json);

  Map<String, dynamic> toJson() => _$StreakInfoToJson(this);

  bool get isStreakActive {
    if (lastCompletionDate == null) return false;
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final today = DateTime(now.year, now.month, now.day);
    final lastCompletion = DateTime(
      lastCompletionDate!.year,
      lastCompletionDate!.month,
      lastCompletionDate!.day,
    );
    return lastCompletion.isAtSameMomentAs(today) ||
        lastCompletion.isAtSameMomentAs(yesterday);
  }

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        lastCompletionDate,
        streakStartDate,
        longestStreakStartDate,
        longestStreakEndDate,
        completionDates,
      ];
}

/// Category analytics for task distribution
@JsonSerializable()
class CategoryAnalytics extends Equatable {
  final String categoryName;
  final String categoryId;
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final double completionRate;
  final double averageDuration;
  final Map<String, int> priorityDistribution;

  const CategoryAnalytics({
    required this.categoryName,
    required this.categoryId,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.completionRate,
    required this.averageDuration,
    required this.priorityDistribution,
  });

  factory CategoryAnalytics.fromJson(Map<String, dynamic> json) =>
      _$CategoryAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryAnalyticsToJson(this);

  @override
  List<Object?> get props => [
        categoryName,
        categoryId,
        totalTasks,
        completedTasks,
        pendingTasks,
        completionRate,
        averageDuration,
        priorityDistribution,
      ];
}

/// Time period for analytics queries
enum AnalyticsTimePeriod {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  last7Days,
  last30Days,
  last90Days,
  custom,
}

extension AnalyticsTimePeriodExtension on AnalyticsTimePeriod {
  String get displayName {
    switch (this) {
      case AnalyticsTimePeriod.today:
        return 'Today';
      case AnalyticsTimePeriod.thisWeek:
        return 'This Week';
      case AnalyticsTimePeriod.thisMonth:
        return 'This Month';
      case AnalyticsTimePeriod.thisYear:
        return 'This Year';
      case AnalyticsTimePeriod.last7Days:
        return 'Last 7 Days';
      case AnalyticsTimePeriod.last30Days:
        return 'Last 30 Days';
      case AnalyticsTimePeriod.last90Days:
        return 'Last 90 Days';
      case AnalyticsTimePeriod.custom:
        return 'Custom Range';
    }
  }

  DateRange get dateRange {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (this) {
      case AnalyticsTimePeriod.today:
        return DateRange(
          start: today,
          end: today.add(const Duration(days: 1)),
        );
      case AnalyticsTimePeriod.thisWeek:
        final weekday = now.weekday;
        final startOfWeek = today.subtract(Duration(days: weekday - 1));
        return DateRange(
          start: startOfWeek,
          end: startOfWeek.add(const Duration(days: 7)),
        );
      case AnalyticsTimePeriod.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 1);
        return DateRange(start: startOfMonth, end: endOfMonth);
      case AnalyticsTimePeriod.thisYear:
        final startOfYear = DateTime(now.year, 1, 1);
        final endOfYear = DateTime(now.year + 1, 1, 1);
        return DateRange(start: startOfYear, end: endOfYear);
      case AnalyticsTimePeriod.last7Days:
        return DateRange(
          start: today.subtract(const Duration(days: 7)),
          end: today.add(const Duration(days: 1)),
        );
      case AnalyticsTimePeriod.last30Days:
        return DateRange(
          start: today.subtract(const Duration(days: 30)),
          end: today.add(const Duration(days: 1)),
        );
      case AnalyticsTimePeriod.last90Days:
        return DateRange(
          start: today.subtract(const Duration(days: 90)),
          end: today.add(const Duration(days: 1)),
        );
      case AnalyticsTimePeriod.custom:
        return DateRange(start: today, end: today.add(const Duration(days: 1)));
    }
  }
}

/// Date range for analytics queries
@JsonSerializable()
class DateRange extends Equatable {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) =>
      _$DateRangeFromJson(json);

  Map<String, dynamic> toJson() => _$DateRangeToJson(this);

  int get durationInDays => end.difference(start).inDays;

  bool contains(DateTime date) {
    return date.isAfter(start) && date.isBefore(end);
  }

  @override
  List<Object?> get props => [start, end];
}

/// Productivity patterns analysis
@JsonSerializable()
class ProductivityPatterns extends Equatable {
  final Map<int, double> hourlyEfficiency; // Hour -> completion rate
  final Map<int, double> weekdayEfficiency; // Weekday -> completion rate
  final List<ProductivityPeak> peaks;
  final List<ProductivityTrough> troughs;
  final double consistencyScore; // 0-1 score for consistency
  final Map<String, double> categoryEfficiency; // Category -> completion rate
  final List<ProductivityTrend> trends;

  const ProductivityPatterns({
    required this.hourlyEfficiency,
    required this.weekdayEfficiency,
    required this.peaks,
    required this.troughs,
    required this.consistencyScore,
    required this.categoryEfficiency,
    required this.trends,
  });

  factory ProductivityPatterns.fromJson(Map<String, dynamic> json) =>
      _$ProductivityPatternsFromJson(json);

  Map<String, dynamic> toJson() => _$ProductivityPatternsToJson(this);

  @override
  List<Object?> get props => [
        hourlyEfficiency,
        weekdayEfficiency,
        peaks,
        troughs,
        consistencyScore,
        categoryEfficiency,
        trends,
      ];
}

/// Peak hours analysis with optimization suggestions
@JsonSerializable()
class PeakHoursAnalysis extends Equatable {
  final List<int> peakHours; // Hours with highest productivity
  final List<int> lowHours; // Hours with lowest productivity
  final double peakProductivityScore;
  final double averageProductivityScore;
  final List<OptimizationSuggestion> suggestions;
  final Map<int, TaskTypeDistribution> hourlyTaskTypes;
  final int optimalWorkingHours;
  final TimeRange recommendedWorkingWindow;

  const PeakHoursAnalysis({
    required this.peakHours,
    required this.lowHours,
    required this.peakProductivityScore,
    required this.averageProductivityScore,
    required this.suggestions,
    required this.hourlyTaskTypes,
    required this.optimalWorkingHours,
    required this.recommendedWorkingWindow,
  });

  factory PeakHoursAnalysis.fromJson(Map<String, dynamic> json) =>
      _$PeakHoursAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$PeakHoursAnalysisToJson(this);

  @override
  List<Object?> get props => [
        peakHours,
        lowHours,
        peakProductivityScore,
        averageProductivityScore,
        suggestions,
        hourlyTaskTypes,
        optimalWorkingHours,
        recommendedWorkingWindow,
      ];
}

/// Advanced category analytics with detailed breakdowns
@JsonSerializable()
class AdvancedCategoryAnalytics extends Equatable {
  final List<CategoryAnalytics> categories;
  final Map<String, CategoryTrend> categoryTrends;
  final Map<String, List<CategoryCorrelation>> correlations;
  final CategoryPerformanceRanking ranking;
  final List<CategoryInsight> insights;
  final Map<String, Map<int, int>> categoryHourlyDistribution;
  final Map<String, Map<int, int>> categoryWeekdayDistribution;

  const AdvancedCategoryAnalytics({
    required this.categories,
    required this.categoryTrends,
    required this.correlations,
    required this.ranking,
    required this.insights,
    required this.categoryHourlyDistribution,
    required this.categoryWeekdayDistribution,
  });

  factory AdvancedCategoryAnalytics.fromJson(Map<String, dynamic> json) =>
      _$AdvancedCategoryAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$AdvancedCategoryAnalyticsToJson(this);

  @override
  List<Object?> get props => [
        categories,
        categoryTrends,
        correlations,
        ranking,
        insights,
        categoryHourlyDistribution,
        categoryWeekdayDistribution,
      ];
}

/// Productivity insights and suggestions
@JsonSerializable()
class ProductivityInsights extends Equatable {
  final List<ProductivityInsight> insights;
  final List<OptimizationSuggestion> suggestions;
  final ProductivityScore overallScore;
  final List<ProductivityGoal> recommendedGoals;
  final Map<String, double> strengthAreas;
  final Map<String, double> improvementAreas;

  const ProductivityInsights({
    required this.insights,
    required this.suggestions,
    required this.overallScore,
    required this.recommendedGoals,
    required this.strengthAreas,
    required this.improvementAreas,
  });

  factory ProductivityInsights.fromJson(Map<String, dynamic> json) =>
      _$ProductivityInsightsFromJson(json);

  Map<String, dynamic> toJson() => _$ProductivityInsightsToJson(this);

  @override
  List<Object?> get props => [
        insights,
        suggestions,
        overallScore,
        recommendedGoals,
        strengthAreas,
        improvementAreas,
      ];
}

/// Supporting models for advanced analytics

@JsonSerializable()
class ProductivityPeak extends Equatable {
  final int hour;
  final double efficiency;
  final int taskCount;
  final String description;

  const ProductivityPeak({
    required this.hour,
    required this.efficiency,
    required this.taskCount,
    required this.description,
  });

  factory ProductivityPeak.fromJson(Map<String, dynamic> json) =>
      _$ProductivityPeakFromJson(json);

  Map<String, dynamic> toJson() => _$ProductivityPeakToJson(this);

  @override
  List<Object?> get props => [hour, efficiency, taskCount, description];
}

@JsonSerializable()
class ProductivityTrough extends Equatable {
  final int hour;
  final double efficiency;
  final int taskCount;
  final String description;

  const ProductivityTrough({
    required this.hour,
    required this.efficiency,
    required this.taskCount,
    required this.description,
  });

  factory ProductivityTrough.fromJson(Map<String, dynamic> json) =>
      _$ProductivityTroughFromJson(json);

  Map<String, dynamic> toJson() => _$ProductivityTroughToJson(this);

  @override
  List<Object?> get props => [hour, efficiency, taskCount, description];
}

@JsonSerializable()
class ProductivityTrend extends Equatable {
  final String type; // 'improving', 'declining', 'stable'
  final String category;
  final double changeRate;
  final String description;

  const ProductivityTrend({
    required this.type,
    required this.category,
    required this.changeRate,
    required this.description,
  });

  factory ProductivityTrend.fromJson(Map<String, dynamic> json) =>
      _$ProductivityTrendFromJson(json);

  Map<String, dynamic> toJson() => _$ProductivityTrendToJson(this);

  @override
  List<Object?> get props => [type, category, changeRate, description];
}

@JsonSerializable()
class OptimizationSuggestion extends Equatable {
  final String title;
  final String description;
  final String category;
  final double impactScore; // 0-1 potential impact
  final String actionType; // 'schedule', 'habit', 'tool', etc.
  final Map<String, dynamic> metadata;

  const OptimizationSuggestion({
    required this.title,
    required this.description,
    required this.category,
    required this.impactScore,
    required this.actionType,
    required this.metadata,
  });

  factory OptimizationSuggestion.fromJson(Map<String, dynamic> json) =>
      _$OptimizationSuggestionFromJson(json);

  Map<String, dynamic> toJson() => _$OptimizationSuggestionToJson(this);

  @override
  List<Object?> get props => [
        title,
        description,
        category,
        impactScore,
        actionType,
        metadata,
      ];
}

@JsonSerializable()
class TaskTypeDistribution extends Equatable {
  final Map<String, int> priorityDistribution;
  final Map<String, int> categoryDistribution;
  final double averageDuration;
  final double completionRate;

  const TaskTypeDistribution({
    required this.priorityDistribution,
    required this.categoryDistribution,
    required this.averageDuration,
    required this.completionRate,
  });

  factory TaskTypeDistribution.fromJson(Map<String, dynamic> json) =>
      _$TaskTypeDistributionFromJson(json);

  Map<String, dynamic> toJson() => _$TaskTypeDistributionToJson(this);

  @override
  List<Object?> get props => [
        priorityDistribution,
        categoryDistribution,
        averageDuration,
        completionRate,
      ];
}

@JsonSerializable()
class TimeRange extends Equatable {
  final int startHour;
  final int endHour;
  final String description;

  const TimeRange({
    required this.startHour,
    required this.endHour,
    required this.description,
  });

  factory TimeRange.fromJson(Map<String, dynamic> json) =>
      _$TimeRangeFromJson(json);

  Map<String, dynamic> toJson() => _$TimeRangeToJson(this);

  @override
  List<Object?> get props => [startHour, endHour, description];
}

@JsonSerializable()
class CategoryTrend extends Equatable {
  final String categoryId;
  final List<double> completionRates; // Historical completion rates
  final String trendDirection; // 'up', 'down', 'stable'
  final double changeRate;

  const CategoryTrend({
    required this.categoryId,
    required this.completionRates,
    required this.trendDirection,
    required this.changeRate,
  });

  factory CategoryTrend.fromJson(Map<String, dynamic> json) =>
      _$CategoryTrendFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryTrendToJson(this);

  @override
  List<Object?> get props => [categoryId, completionRates, trendDirection, changeRate];
}

@JsonSerializable()
class CategoryCorrelation extends Equatable {
  final String categoryA;
  final String categoryB;
  final double correlationScore; // -1 to 1
  final String description;

  const CategoryCorrelation({
    required this.categoryA,
    required this.categoryB,
    required this.correlationScore,
    required this.description,
  });

  factory CategoryCorrelation.fromJson(Map<String, dynamic> json) =>
      _$CategoryCorrelationFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryCorrelationToJson(this);

  @override
  List<Object?> get props => [categoryA, categoryB, correlationScore, description];
}

@JsonSerializable()
class CategoryPerformanceRanking extends Equatable {
  final List<String> topPerformingCategories;
  final List<String> underperformingCategories;
  final Map<String, double> categoryScores;

  const CategoryPerformanceRanking({
    required this.topPerformingCategories,
    required this.underperformingCategories,
    required this.categoryScores,
  });

  factory CategoryPerformanceRanking.fromJson(Map<String, dynamic> json) =>
      _$CategoryPerformanceRankingFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryPerformanceRankingToJson(this);

  @override
  List<Object?> get props => [
        topPerformingCategories,
        underperformingCategories,
        categoryScores,
      ];
}

@JsonSerializable()
class CategoryInsight extends Equatable {
  final String categoryId;
  final String insightType; // 'peak_time', 'duration_pattern', 'completion_trend'
  final String title;
  final String description;
  final double confidence; // 0-1 confidence score

  const CategoryInsight({
    required this.categoryId,
    required this.insightType,
    required this.title,
    required this.description,
    required this.confidence,
  });

  factory CategoryInsight.fromJson(Map<String, dynamic> json) =>
      _$CategoryInsightFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryInsightToJson(this);

  @override
  List<Object?> get props => [
        categoryId,
        insightType,
        title,
        description,
        confidence,
      ];
}

@JsonSerializable()
class ProductivityInsight extends Equatable {
  final String type; // 'pattern', 'trend', 'anomaly', 'opportunity'
  final String title;
  final String description;
  final double confidence;
  final Map<String, dynamic> data;

  const ProductivityInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.confidence,
    required this.data,
  });

  factory ProductivityInsight.fromJson(Map<String, dynamic> json) =>
      _$ProductivityInsightFromJson(json);

  Map<String, dynamic> toJson() => _$ProductivityInsightToJson(this);

  @override
  List<Object?> get props => [type, title, description, confidence, data];
}

@JsonSerializable()
class ProductivityScore extends Equatable {
  final double overall; // 0-100
  final double consistency;
  final double efficiency;
  final double completion;
  final double timeManagement;
  final String grade; // A+, A, B+, etc.

  const ProductivityScore({
    required this.overall,
    required this.consistency,
    required this.efficiency,
    required this.completion,
    required this.timeManagement,
    required this.grade,
  });

  factory ProductivityScore.fromJson(Map<String, dynamic> json) =>
      _$ProductivityScoreFromJson(json);

  Map<String, dynamic> toJson() => _$ProductivityScoreToJson(this);

  @override
  List<Object?> get props => [
        overall,
        consistency,
        efficiency,
        completion,
        timeManagement,
        grade,
      ];
}

@JsonSerializable()
class ProductivityGoal extends Equatable {
  final String title;
  final String description;
  final String category;
  final double targetValue;
  final String timeframe;
  final List<String> actionSteps;

  const ProductivityGoal({
    required this.title,
    required this.description,
    required this.category,
    required this.targetValue,
    required this.timeframe,
    required this.actionSteps,
  });

  factory ProductivityGoal.fromJson(Map<String, dynamic> json) =>
      _$ProductivityGoalFromJson(json);

  Map<String, dynamic> toJson() => _$ProductivityGoalToJson(this);

  @override
  List<Object?> get props => [
        title,
        description,
        category,
        targetValue,
        timeframe,
        actionSteps,
      ];
}

/// Export format options
enum AnalyticsExportFormat {
  json,
  csv,
  pdf,
  excel,
}

extension AnalyticsExportFormatExtension on AnalyticsExportFormat {
  String get displayName {
    switch (this) {
      case AnalyticsExportFormat.json:
        return 'JSON';
      case AnalyticsExportFormat.csv:
        return 'CSV';
      case AnalyticsExportFormat.pdf:
        return 'PDF';
      case AnalyticsExportFormat.excel:
        return 'Excel';
    }
  }

  String get fileExtension {
    switch (this) {
      case AnalyticsExportFormat.json:
        return '.json';
      case AnalyticsExportFormat.csv:
        return '.csv';
      case AnalyticsExportFormat.pdf:
        return '.pdf';
      case AnalyticsExportFormat.excel:
        return '.xlsx';
    }
  }

  String get mimeType {
    switch (this) {
      case AnalyticsExportFormat.json:
        return 'application/json';
      case AnalyticsExportFormat.csv:
        return 'text/csv';
      case AnalyticsExportFormat.pdf:
        return 'application/pdf';
      case AnalyticsExportFormat.excel:
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
  }
}