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