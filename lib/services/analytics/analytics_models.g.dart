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
