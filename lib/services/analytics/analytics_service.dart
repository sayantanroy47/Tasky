import 'dart:convert';
import 'dart:math';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/task_enums.dart';
import '../../domain/repositories/task_repository.dart';
import 'analytics_models.dart';

/// Service for calculating analytics and productivity metrics
/// 
/// This service provides comprehensive analytics functionality including:
/// - Task completion tracking
/// - Productivity metrics calculation
/// - Streak tracking and consistency metrics
/// - Category-based analytics
abstract class AnalyticsService {
  /// Gets analytics summary for a specific time period
  Future<AnalyticsSummary> getAnalyticsSummary(
    AnalyticsTimePeriod period, {
    DateRange? customRange,
  });

  /// Gets productivity metrics
  Future<ProductivityMetrics> getProductivityMetrics();

  /// Gets streak information
  Future<StreakInfo> getStreakInfo();

  /// Gets category-based analytics
  Future<List<CategoryAnalytics>> getCategoryAnalytics(
    AnalyticsTimePeriod period, {
    DateRange? customRange,
  });

  /// Gets daily statistics for a date range
  Future<List<DailyStats>> getDailyStats(DateRange dateRange);

  /// Gets hourly productivity data
  Future<Map<int, int>> getHourlyProductivity(DateRange dateRange);

  /// Gets weekday productivity data
  Future<Map<int, int>> getWeekdayProductivity(DateRange dateRange);

  /// Gets completion rate trend over time
  Future<List<double>> getCompletionRateTrend(
    DateRange dateRange,
    int intervalDays,
  );

  /// Updates streak information when a task is completed
  Future<void> updateStreakOnTaskCompletion(DateTime completionDate);

  /// Recalculates all analytics (useful for data migration or cleanup)
  Future<void> recalculateAnalytics();

  /// Gets productivity pattern analysis
  Future<ProductivityPatterns> getProductivityPatterns(DateRange dateRange);

  /// Gets peak hours analysis with optimization suggestions
  Future<PeakHoursAnalysis> getPeakHoursAnalysis(DateRange dateRange);

  /// Gets advanced category analytics with breakdowns
  Future<AdvancedCategoryAnalytics> getAdvancedCategoryAnalytics(
    AnalyticsTimePeriod period, {
    DateRange? customRange,
  });

  /// Exports analytics data in various formats
  Future<String> exportAnalytics(
    AnalyticsExportFormat format,
    AnalyticsTimePeriod period, {
    DateRange? customRange,
  });

  /// Gets productivity insights and suggestions
  Future<ProductivityInsights> getProductivityInsights(DateRange dateRange);
}

/// Implementation of AnalyticsService
class AnalyticsServiceImpl implements AnalyticsService {
  final TaskRepository _taskRepository;

  const AnalyticsServiceImpl(this._taskRepository);

  @override
  Future<AnalyticsSummary> getAnalyticsSummary(
    AnalyticsTimePeriod period, {
    DateRange? customRange,
  }) async {
    final dateRange = customRange ?? period.dateRange;
    final tasks = await _getTasksInDateRange(dateRange);

    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.status.isCompleted).length;
    final pendingTasks = tasks.where((t) => t.status.isPending).length;
    final cancelledTasks = tasks.where((t) => t.status.isCancelled).length;
    final completionRate = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    final streakInfo = await getStreakInfo();
    final dailyStats = await getDailyStats(dateRange);

    // Calculate average task duration
    final completedTasksWithDuration = tasks
        .where((t) => t.status.isCompleted && t.actualDuration != null)
        .toList();
    final averageTaskDuration = completedTasksWithDuration.isNotEmpty
        ? completedTasksWithDuration
                .map((t) => t.actualDuration!)
                .reduce((a, b) => a + b) /
            completedTasksWithDuration.length
        : 0.0;

    // Group tasks by various categories
    final tasksByPriority = <String, int>{};
    final tasksByStatus = <String, int>{};
    final tasksByTag = <String, int>{};
    final tasksByProject = <String, int>{};

    for (final task in tasks) {
      // Priority distribution
      final priority = task.priority.displayName;
      tasksByPriority[priority] = (tasksByPriority[priority] ?? 0) + 1;

      // Status distribution
      final status = task.status.displayName;
      tasksByStatus[status] = (tasksByStatus[status] ?? 0) + 1;

      // Tag distribution
      for (final tag in task.tags) {
        tasksByTag[tag] = (tasksByTag[tag] ?? 0) + 1;
      }

      // Project distribution
      if (task.projectId != null) {
        tasksByProject[task.projectId!] =
            (tasksByProject[task.projectId!] ?? 0) + 1;
      }
    }

    return AnalyticsSummary(
      startDate: dateRange.start,
      endDate: dateRange.end,
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      pendingTasks: pendingTasks,
      cancelledTasks: cancelledTasks,
      completionRate: completionRate,
      currentStreak: streakInfo.currentStreak,
      longestStreak: streakInfo.longestStreak,
      averageTaskDuration: averageTaskDuration,
      tasksByPriority: tasksByPriority,
      tasksByStatus: tasksByStatus,
      tasksByTag: tasksByTag,
      tasksByProject: tasksByProject,
      dailyStats: dailyStats,
    );
  }

  @override
  Future<ProductivityMetrics> getProductivityMetrics() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get tasks for different time periods
    final weekRange = DateRange(
      start: today.subtract(const Duration(days: 7)),
      end: today.add(const Duration(days: 1)),
    );
    final monthRange = DateRange(
      start: today.subtract(const Duration(days: 30)),
      end: today.add(const Duration(days: 1)),
    );

    final weeklyTasks = await _getTasksInDateRange(weekRange);
    final monthlyTasks = await _getTasksInDateRange(monthRange);

    final weeklyCompleted = weeklyTasks.where((t) => t.status.isCompleted).length;
    final monthlyCompleted = monthlyTasks.where((t) => t.status.isCompleted).length;

    final weeklyCompletionRate = weeklyTasks.isNotEmpty ? weeklyCompleted / weeklyTasks.length : 0.0;
    final monthlyCompletionRate = monthlyTasks.isNotEmpty ? monthlyCompleted / monthlyTasks.length : 0.0;

    // Get streak info
    final streakInfo = await getStreakInfo();

    // Calculate trends
    final weeklyTrend = await _calculateWeeklyTrend();
    final monthlyTrend = await _calculateMonthlyTrend();

    // Get productivity patterns
    final hourlyProductivity = await getHourlyProductivity(monthRange);
    final weekdayProductivity = await getWeekdayProductivity(monthRange);

    // Calculate averages
    final averageTasksPerDay = monthlyTasks.length / 30.0;
    final completedTasksWithDuration = monthlyTasks
        .where((t) => t.status.isCompleted && t.actualDuration != null)
        .toList();
    final averageCompletionTime = completedTasksWithDuration.isNotEmpty
        ? completedTasksWithDuration
                .map((t) => t.actualDuration!)
                .reduce((a, b) => a + b) /
            completedTasksWithDuration.length
        : 0.0;

    return ProductivityMetrics(
      weeklyCompletionRate: weeklyCompletionRate,
      monthlyCompletionRate: monthlyCompletionRate,
      tasksCompletedThisWeek: weeklyCompleted,
      tasksCompletedThisMonth: monthlyCompleted,
      currentStreak: streakInfo.currentStreak,
      longestStreak: streakInfo.longestStreak,
      weeklyTrend: weeklyTrend,
      monthlyTrend: monthlyTrend,
      hourlyProductivity: hourlyProductivity,
      weekdayProductivity: weekdayProductivity,
      averageTasksPerDay: averageTasksPerDay,
      averageCompletionTime: averageCompletionTime,
    );
  }

  @override
  Future<StreakInfo> getStreakInfo() async {
    final allTasks = await _taskRepository.getAllTasks();
    final completedTasks = allTasks
        .where((t) => t.status.isCompleted && t.completedAt != null)
        .toList();

    if (completedTasks.isEmpty) {
      return const StreakInfo(
        currentStreak: 0,
        longestStreak: 0,
        completionDates: [],
      );
    }

    // Group completion dates by day
    final completionDates = completedTasks
        .map((t) => DateTime(
              t.completedAt!.year,
              t.completedAt!.month,
              t.completedAt!.day,
            ))
        .toSet()
        .toList()
      ..sort();

    // Calculate current streak
    int currentStreak = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    DateTime? streakStartDate;
    DateTime? lastCompletionDate;

    if (completionDates.isNotEmpty) {
      lastCompletionDate = completionDates.last;
      
      // Check if streak is still active (completed today or yesterday)
      if (lastCompletionDate.isAtSameMomentAs(today) ||
          lastCompletionDate.isAtSameMomentAs(yesterday)) {
        DateTime currentDate = lastCompletionDate;
        currentStreak = 1;
        streakStartDate = currentDate;

        // Count backwards to find streak length
        for (int i = completionDates.length - 2; i >= 0; i--) {
          final prevDate = completionDates[i];
          final expectedPrevDate = currentDate.subtract(const Duration(days: 1));
          
          if (prevDate.isAtSameMomentAs(expectedPrevDate)) {
            currentStreak++;
            streakStartDate = prevDate;
            currentDate = prevDate;
          } else {
            break;
          }
        }
      }
    }

    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? longestStreakStartDate;
    DateTime? longestStreakEndDate;
    DateTime? tempStreakStart;

    for (int i = 0; i < completionDates.length; i++) {
      if (i == 0) {
        tempStreak = 1;
        tempStreakStart = completionDates[i];
      } else {
        final currentDate = completionDates[i];
        final prevDate = completionDates[i - 1];
        final expectedDate = prevDate.add(const Duration(days: 1));

        if (currentDate.isAtSameMomentAs(expectedDate)) {
          tempStreak++;
        } else {
          if (tempStreak > longestStreak) {
            longestStreak = tempStreak;
            longestStreakStartDate = tempStreakStart;
            longestStreakEndDate = completionDates[i - 1];
          }
          tempStreak = 1;
          tempStreakStart = currentDate;
        }
      }
    }

    // Check if the last streak is the longest
    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
      longestStreakStartDate = tempStreakStart;
      longestStreakEndDate = completionDates.last;
    }

    return StreakInfo(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastCompletionDate: lastCompletionDate,
      streakStartDate: streakStartDate,
      longestStreakStartDate: longestStreakStartDate,
      longestStreakEndDate: longestStreakEndDate,
      completionDates: completionDates,
    );
  }

  @override
  Future<List<CategoryAnalytics>> getCategoryAnalytics(
    AnalyticsTimePeriod period, {
    DateRange? customRange,
  }) async {
    final dateRange = customRange ?? period.dateRange;
    final tasks = await _getTasksInDateRange(dateRange);

    // Group tasks by tags (categories)
    final categoryMap = <String, List<TaskModel>>{};
    
    for (final task in tasks) {
      if (task.tags.isEmpty) {
        categoryMap['Uncategorized'] = (categoryMap['Uncategorized'] ?? [])..add(task);
      } else {
        for (final tag in task.tags) {
          categoryMap[tag] = (categoryMap[tag] ?? [])..add(task);
        }
      }
    }

    final categoryAnalytics = <CategoryAnalytics>[];

    for (final entry in categoryMap.entries) {
      final categoryTasks = entry.value;
      final totalTasks = categoryTasks.length;
      final completedTasks = categoryTasks.where((t) => t.status.isCompleted).length;
      final pendingTasks = categoryTasks.where((t) => t.status.isPending).length;
      final completionRate = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

      // Calculate average duration
      final completedTasksWithDuration = categoryTasks
          .where((t) => t.status.isCompleted && t.actualDuration != null)
          .toList();
      final averageDuration = completedTasksWithDuration.isNotEmpty
          ? completedTasksWithDuration
                  .map((t) => t.actualDuration!)
                  .reduce((a, b) => a + b) /
              completedTasksWithDuration.length
          : 0.0;

      // Priority distribution
      final priorityDistribution = <String, int>{};
      for (final task in categoryTasks) {
        final priority = task.priority.displayName;
        priorityDistribution[priority] = (priorityDistribution[priority] ?? 0) + 1;
      }

      categoryAnalytics.add(CategoryAnalytics(
        categoryName: entry.key,
        categoryId: entry.key,
        totalTasks: totalTasks,
        completedTasks: completedTasks,
        pendingTasks: pendingTasks,
        completionRate: completionRate,
        averageDuration: averageDuration,
        priorityDistribution: priorityDistribution,
      ));
    }

    // Sort by total tasks descending
    categoryAnalytics.sort((a, b) => b.totalTasks.compareTo(a.totalTasks));

    return categoryAnalytics;
  }

  @override
  Future<List<DailyStats>> getDailyStats(DateRange dateRange) async {
    final tasks = await _getTasksInDateRange(dateRange);
    final dailyStatsMap = <DateTime, DailyStats>{};

    // Initialize all days in range with empty stats
    DateTime currentDate = dateRange.start;
    while (currentDate.isBefore(dateRange.end)) {
      final dayKey = DateTime(currentDate.year, currentDate.month, currentDate.day);
      dailyStatsMap[dayKey] = DailyStats(
        date: dayKey,
        totalTasks: 0,
        completedTasks: 0,
        createdTasks: 0,
        completionRate: 0.0,
        totalDuration: 0.0,
        tasksByPriority: {},
        tasksByTag: {},
      );
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Process tasks
    for (final task in tasks) {
      // Count created tasks
      final createdDay = DateTime(
        task.createdAt.year,
        task.createdAt.month,
        task.createdAt.day,
      );
      if (dailyStatsMap.containsKey(createdDay)) {
        final existing = dailyStatsMap[createdDay]!;
        dailyStatsMap[createdDay] = DailyStats(
          date: existing.date,
          totalTasks: existing.totalTasks + 1,
          completedTasks: existing.completedTasks,
          createdTasks: existing.createdTasks + 1,
          completionRate: existing.completionRate,
          totalDuration: existing.totalDuration,
          tasksByPriority: Map.from(existing.tasksByPriority)
            ..[task.priority.displayName] = 
                (existing.tasksByPriority[task.priority.displayName] ?? 0) + 1,
          tasksByTag: Map.from(existing.tasksByTag)
            ..addAll(Map.fromIterable(
              task.tags,
              key: (tag) => tag,
              value: (tag) => (existing.tasksByTag[tag] ?? 0) + 1,
            )),
        );
      }

      // Count completed tasks
      if (task.status.isCompleted && task.completedAt != null) {
        final completedDay = DateTime(
          task.completedAt!.year,
          task.completedAt!.month,
          task.completedAt!.day,
        );
        if (dailyStatsMap.containsKey(completedDay)) {
          final existing = dailyStatsMap[completedDay]!;
          final duration = task.actualDuration?.toDouble() ?? 0.0;
          dailyStatsMap[completedDay] = DailyStats(
            date: existing.date,
            totalTasks: existing.totalTasks,
            completedTasks: existing.completedTasks + 1,
            createdTasks: existing.createdTasks,
            completionRate: existing.totalTasks > 0 
                ? (existing.completedTasks + 1) / existing.totalTasks 
                : 0.0,
            totalDuration: existing.totalDuration + duration,
            tasksByPriority: existing.tasksByPriority,
            tasksByTag: existing.tasksByTag,
          );
        }
      }
    }

    // Recalculate completion rates
    for (final entry in dailyStatsMap.entries) {
      final stats = entry.value;
      if (stats.totalTasks > 0) {
        dailyStatsMap[entry.key] = DailyStats(
          date: stats.date,
          totalTasks: stats.totalTasks,
          completedTasks: stats.completedTasks,
          createdTasks: stats.createdTasks,
          completionRate: stats.completedTasks / stats.totalTasks,
          totalDuration: stats.totalDuration,
          tasksByPriority: stats.tasksByPriority,
          tasksByTag: stats.tasksByTag,
        );
      }
    }

    return dailyStatsMap.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<Map<int, int>> getHourlyProductivity(DateRange dateRange) async {
    final tasks = await _getTasksInDateRange(dateRange);
    final hourlyProductivity = <int, int>{};

    // Initialize all hours
    for (int hour = 0; hour < 24; hour++) {
      hourlyProductivity[hour] = 0;
    }

    // Count completed tasks by hour
    for (final task in tasks) {
      if (task.status.isCompleted && task.completedAt != null) {
        final hour = task.completedAt!.hour;
        hourlyProductivity[hour] = (hourlyProductivity[hour] ?? 0) + 1;
      }
    }

    return hourlyProductivity;
  }

  @override
  Future<Map<int, int>> getWeekdayProductivity(DateRange dateRange) async {
    final tasks = await _getTasksInDateRange(dateRange);
    final weekdayProductivity = <int, int>{};

    // Initialize all weekdays (1 = Monday, 7 = Sunday)
    for (int weekday = 1; weekday <= 7; weekday++) {
      weekdayProductivity[weekday] = 0;
    }

    // Count completed tasks by weekday
    for (final task in tasks) {
      if (task.status.isCompleted && task.completedAt != null) {
        final weekday = task.completedAt!.weekday;
        weekdayProductivity[weekday] = (weekdayProductivity[weekday] ?? 0) + 1;
      }
    }

    return weekdayProductivity;
  }

  @override
  Future<List<double>> getCompletionRateTrend(
    DateRange dateRange,
    int intervalDays,
  ) async {
    final trends = <double>[];
    DateTime currentStart = dateRange.start;

    while (currentStart.isBefore(dateRange.end)) {
      final intervalEnd = currentStart.add(Duration(days: intervalDays));
      final intervalRange = DateRange(
        start: currentStart,
        end: intervalEnd.isBefore(dateRange.end) ? intervalEnd : dateRange.end,
      );

      final intervalTasks = await _getTasksInDateRange(intervalRange);
      final completedTasks = intervalTasks.where((t) => t.status.isCompleted).length;
      final completionRate = intervalTasks.isNotEmpty ? completedTasks / intervalTasks.length : 0.0;
      
      trends.add(completionRate);
      currentStart = intervalEnd;
    }

    return trends;
  }

  @override
  Future<void> updateStreakOnTaskCompletion(DateTime completionDate) async {
    // This method would typically update a separate streak tracking table
    // For now, we'll rely on recalculating from task data
    // In a production app, you might want to maintain streak data separately for performance
  }

  @override
  Future<void> recalculateAnalytics() async {
    // This method would recalculate all cached analytics data
    // For now, since we calculate on-demand, this is a no-op
    // In a production app, you might cache analytics data for performance
  }

  @override
  Future<ProductivityPatterns> getProductivityPatterns(DateRange dateRange) async {
    final tasks = await _getTasksInDateRange(dateRange);
    final completedTasks = tasks.where((t) => t.status.isCompleted && t.completedAt != null).toList();

    // Calculate hourly efficiency
    final hourlyEfficiency = <int, double>{};
    final hourlyTaskCounts = <int, int>{};
    final hourlyCompletedCounts = <int, int>{};

    for (int hour = 0; hour < 24; hour++) {
      hourlyTaskCounts[hour] = 0;
      hourlyCompletedCounts[hour] = 0;
    }

    for (final task in tasks) {
      final hour = task.createdAt.hour;
      hourlyTaskCounts[hour] = (hourlyTaskCounts[hour] ?? 0) + 1;
      
      if (task.status.isCompleted && task.completedAt != null) {
        final completionHour = task.completedAt!.hour;
        hourlyCompletedCounts[completionHour] = (hourlyCompletedCounts[completionHour] ?? 0) + 1;
      }
    }

    for (int hour = 0; hour < 24; hour++) {
      final totalTasks = hourlyTaskCounts[hour] ?? 0;
      final completedTasks = hourlyCompletedCounts[hour] ?? 0;
      hourlyEfficiency[hour] = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    }

    // Calculate weekday efficiency
    final weekdayEfficiency = <int, double>{};
    final weekdayTaskCounts = <int, int>{};
    final weekdayCompletedCounts = <int, int>{};

    for (int weekday = 1; weekday <= 7; weekday++) {
      weekdayTaskCounts[weekday] = 0;
      weekdayCompletedCounts[weekday] = 0;
    }

    for (final task in tasks) {
      final weekday = task.createdAt.weekday;
      weekdayTaskCounts[weekday] = (weekdayTaskCounts[weekday] ?? 0) + 1;
      
      if (task.status.isCompleted && task.completedAt != null) {
        final completionWeekday = task.completedAt!.weekday;
        weekdayCompletedCounts[completionWeekday] = (weekdayCompletedCounts[completionWeekday] ?? 0) + 1;
      }
    }

    for (int weekday = 1; weekday <= 7; weekday++) {
      final totalTasks = weekdayTaskCounts[weekday] ?? 0;
      final completedTasks = weekdayCompletedCounts[weekday] ?? 0;
      weekdayEfficiency[weekday] = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    }

    // Find peaks and troughs
    final peaks = <ProductivityPeak>[];
    final troughs = <ProductivityTrough>[];
    
    final sortedHours = hourlyEfficiency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Top 3 peak hours
    for (int i = 0; i < 3 && i < sortedHours.length; i++) {
      final entry = sortedHours[i];
      if (entry.value > 0) {
        peaks.add(ProductivityPeak(
          hour: entry.key,
          efficiency: entry.value,
          taskCount: hourlyCompletedCounts[entry.key] ?? 0,
          description: _getHourDescription(entry.key),
        ));
      }
    }

    // Bottom 3 trough hours (excluding zero efficiency hours)
    final nonZeroHours = sortedHours.where((e) => e.value > 0).toList();
    for (int i = nonZeroHours.length - 1; i >= nonZeroHours.length - 3 && i >= 0; i--) {
      final entry = nonZeroHours[i];
      troughs.add(ProductivityTrough(
        hour: entry.key,
        efficiency: entry.value,
        taskCount: hourlyCompletedCounts[entry.key] ?? 0,
        description: _getHourDescription(entry.key),
      ));
    }

    // Calculate consistency score
    final efficiencyValues = hourlyEfficiency.values.where((v) => v > 0).toList();
    final consistencyScore = efficiencyValues.isNotEmpty 
        ? 1.0 - (_calculateStandardDeviation(efficiencyValues) / _calculateMean(efficiencyValues))
        : 0.0;

    // Calculate category efficiency
    final categoryEfficiency = <String, double>{};
    final categoryMap = <String, List<TaskModel>>{};
    
    for (final task in tasks) {
      if (task.tags.isEmpty) {
        categoryMap['Uncategorized'] = (categoryMap['Uncategorized'] ?? [])..add(task);
      } else {
        for (final tag in task.tags) {
          categoryMap[tag] = (categoryMap[tag] ?? [])..add(task);
        }
      }
    }

    for (final entry in categoryMap.entries) {
      final categoryTasks = entry.value;
      final completedCount = categoryTasks.where((t) => t.status.isCompleted).length;
      categoryEfficiency[entry.key] = categoryTasks.isNotEmpty 
          ? completedCount / categoryTasks.length 
          : 0.0;
    }

    // Calculate trends
    final trends = await _calculateProductivityTrends(dateRange);

    return ProductivityPatterns(
      hourlyEfficiency: hourlyEfficiency,
      weekdayEfficiency: weekdayEfficiency,
      peaks: peaks,
      troughs: troughs,
      consistencyScore: consistencyScore.clamp(0.0, 1.0),
      categoryEfficiency: categoryEfficiency,
      trends: trends,
    );
  }

  @override
  Future<PeakHoursAnalysis> getPeakHoursAnalysis(DateRange dateRange) async {
    final tasks = await _getTasksInDateRange(dateRange);
    final completedTasks = tasks.where((t) => t.status.isCompleted && t.completedAt != null).toList();

    // Calculate hourly productivity scores
    final hourlyScores = <int, double>{};
    final hourlyTaskTypes = <int, TaskTypeDistribution>{};
    
    for (int hour = 0; hour < 24; hour++) {
      final hourTasks = tasks.where((t) => t.createdAt.hour == hour).toList();
      final hourCompleted = completedTasks.where((t) => t.completedAt!.hour == hour).toList();
      
      final completionRate = hourTasks.isNotEmpty ? hourCompleted.length / hourTasks.length : 0.0;
      final taskCount = hourCompleted.length;
      final avgDuration = hourCompleted.isNotEmpty && hourCompleted.any((t) => t.actualDuration != null)
          ? hourCompleted.where((t) => t.actualDuration != null)
              .map((t) => t.actualDuration!)
              .reduce((a, b) => a + b) / hourCompleted.where((t) => t.actualDuration != null).length
          : 0.0;
      
      // Productivity score combines completion rate, task count, and efficiency
      hourlyScores[hour] = (completionRate * 0.5) + (taskCount / 10.0 * 0.3) + (avgDuration > 0 ? 0.2 : 0.0);
      
      // Task type distribution
      final priorityDist = <String, int>{};
      final categoryDist = <String, int>{};
      
      for (final task in hourTasks) {
        priorityDist[task.priority.displayName] = (priorityDist[task.priority.displayName] ?? 0) + 1;
        for (final tag in task.tags) {
          categoryDist[tag] = (categoryDist[tag] ?? 0) + 1;
        }
        if (task.tags.isEmpty) {
          categoryDist['Uncategorized'] = (categoryDist['Uncategorized'] ?? 0) + 1;
        }
      }
      
      hourlyTaskTypes[hour] = TaskTypeDistribution(
        priorityDistribution: priorityDist,
        categoryDistribution: categoryDist,
        averageDuration: avgDuration,
        completionRate: completionRate,
      );
    }

    // Find peak and low hours
    final sortedHours = hourlyScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final peakHours = sortedHours.take(6).map((e) => e.key).toList();
    final lowHours = sortedHours.reversed.take(6).map((e) => e.key).toList();
    
    final peakProductivityScore = peakHours.isNotEmpty 
        ? peakHours.map((h) => hourlyScores[h]!).reduce((a, b) => a + b) / peakHours.length
        : 0.0;
    final averageProductivityScore = hourlyScores.values.isNotEmpty
        ? hourlyScores.values.reduce((a, b) => a + b) / hourlyScores.values.length
        : 0.0;

    // Generate optimization suggestions
    final suggestions = _generateOptimizationSuggestions(hourlyScores, hourlyTaskTypes);
    
    // Calculate optimal working hours
    final optimalWorkingHours = peakHours.length;
    
    // Recommend working window
    final recommendedWorkingWindow = _calculateRecommendedWorkingWindow(peakHours);

    return PeakHoursAnalysis(
      peakHours: peakHours,
      lowHours: lowHours,
      peakProductivityScore: peakProductivityScore,
      averageProductivityScore: averageProductivityScore,
      suggestions: suggestions,
      hourlyTaskTypes: hourlyTaskTypes,
      optimalWorkingHours: optimalWorkingHours,
      recommendedWorkingWindow: recommendedWorkingWindow,
    );
  }

  @override
  Future<AdvancedCategoryAnalytics> getAdvancedCategoryAnalytics(
    AnalyticsTimePeriod period, {
    DateRange? customRange,
  }) async {
    final dateRange = customRange ?? period.dateRange;
    final basicCategories = await getCategoryAnalytics(period, customRange: customRange);
    
    // Calculate category trends
    final categoryTrends = <String, CategoryTrend>{};
    for (final category in basicCategories) {
      final trend = await _calculateCategoryTrend(category.categoryId, dateRange);
      categoryTrends[category.categoryId] = trend;
    }
    
    // Calculate correlations
    final correlations = <String, List<CategoryCorrelation>>{};
    for (final category in basicCategories) {
      correlations[category.categoryId] = await _calculateCategoryCorrelations(category.categoryId, basicCategories);
    }
    
    // Calculate performance ranking
    final ranking = _calculateCategoryPerformanceRanking(basicCategories);
    
    // Generate insights
    final insights = await _generateCategoryInsights(basicCategories, categoryTrends);
    
    // Calculate hourly and weekday distributions
    final categoryHourlyDistribution = <String, Map<int, int>>{};
    final categoryWeekdayDistribution = <String, Map<int, int>>{};
    
    for (final category in basicCategories) {
      categoryHourlyDistribution[category.categoryId] = await _getCategoryHourlyDistribution(category.categoryId, dateRange);
      categoryWeekdayDistribution[category.categoryId] = await _getCategoryWeekdayDistribution(category.categoryId, dateRange);
    }

    return AdvancedCategoryAnalytics(
      categories: basicCategories,
      categoryTrends: categoryTrends,
      correlations: correlations,
      ranking: ranking,
      insights: insights,
      categoryHourlyDistribution: categoryHourlyDistribution,
      categoryWeekdayDistribution: categoryWeekdayDistribution,
    );
  }

  @override
  Future<String> exportAnalytics(
    AnalyticsExportFormat format,
    AnalyticsTimePeriod period, {
    DateRange? customRange,
  }) async {
    final dateRange = customRange ?? period.dateRange;
    final summary = await getAnalyticsSummary(period, customRange: customRange);
    final metrics = await getProductivityMetrics();
    final patterns = await getProductivityPatterns(dateRange);
    
    switch (format) {
      case AnalyticsExportFormat.json:
        return _exportToJson(summary, metrics, patterns);
      case AnalyticsExportFormat.csv:
        return _exportToCsv(summary, metrics, patterns);
      case AnalyticsExportFormat.pdf:
        return _exportToPdf(summary, metrics, patterns);
      case AnalyticsExportFormat.excel:
        return _exportToExcel(summary, metrics, patterns);
    }
  }

  @override
  Future<ProductivityInsights> getProductivityInsights(DateRange dateRange) async {
    final patterns = await getProductivityPatterns(dateRange);
    final peakAnalysis = await getPeakHoursAnalysis(dateRange);
    final summary = await getAnalyticsSummary(AnalyticsTimePeriod.custom, customRange: dateRange);
    
    // Generate insights
    final insights = <ProductivityInsight>[];
    
    // Pattern insights
    if (patterns.peaks.isNotEmpty) {
      insights.add(ProductivityInsight(
        type: 'pattern',
        title: 'Peak Productivity Hours',
        description: 'Your most productive hours are ${patterns.peaks.map((p) => _formatHour(p.hour)).join(', ')}',
        confidence: 0.8,
        data: {'peaks': patterns.peaks.map((p) => p.toJson()).toList()},
      ));
    }
    
    // Trend insights
    for (final trend in patterns.trends) {
      insights.add(ProductivityInsight(
        type: 'trend',
        title: '${trend.category} Trend',
        description: trend.description,
        confidence: 0.7,
        data: trend.toJson(),
      ));
    }
    
    // Calculate overall productivity score
    final overallScore = _calculateProductivityScore(summary, patterns, peakAnalysis);
    
    // Generate recommended goals
    final recommendedGoals = _generateRecommendedGoals(patterns, peakAnalysis);
    
    // Identify strength and improvement areas
    final strengthAreas = <String, double>{};
    final improvementAreas = <String, double>{};
    
    for (final entry in patterns.categoryEfficiency.entries) {
      if (entry.value >= 0.8) {
        strengthAreas[entry.key] = entry.value;
      } else if (entry.value < 0.5) {
        improvementAreas[entry.key] = entry.value;
      }
    }

    return ProductivityInsights(
      insights: insights,
      suggestions: peakAnalysis.suggestions,
      overallScore: overallScore,
      recommendedGoals: recommendedGoals,
      strengthAreas: strengthAreas,
      improvementAreas: improvementAreas,
    );
  }

  // Private helper methods

  Future<List<TaskModel>> _getTasksInDateRange(DateRange dateRange) async {
    final allTasks = await _taskRepository.getAllTasks();
    return allTasks.where((task) {
      // Include tasks created in the range or completed in the range
      final createdInRange = task.createdAt.isAfter(dateRange.start) &&
          task.createdAt.isBefore(dateRange.end);
      final completedInRange = task.completedAt != null &&
          task.completedAt!.isAfter(dateRange.start) &&
          task.completedAt!.isBefore(dateRange.end);
      return createdInRange || completedInRange;
    }).toList();
  }

  Future<List<int>> _calculateWeeklyTrend() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final trends = <int>[];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateRange = DateRange(
        start: date,
        end: date.add(const Duration(days: 1)),
      );
      final tasks = await _getTasksInDateRange(dateRange);
      final completedTasks = tasks.where((t) => t.status.isCompleted).length;
      trends.add(completedTasks);
    }

    return trends;
  }

  Future<List<int>> _calculateMonthlyTrend() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final trends = <int>[];

    for (int i = 29; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateRange = DateRange(
        start: date,
        end: date.add(const Duration(days: 1)),
      );
      final tasks = await _getTasksInDateRange(dateRange);
      final completedTasks = tasks.where((t) => t.status.isCompleted).length;
      trends.add(completedTasks);
    }

    return trends;
  }

  // Helper methods for advanced analytics

  String _getHourDescription(int hour) {
    if (hour >= 5 && hour < 12) {
      return 'Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Evening';
    } else {
      return 'Night';
    }
  }

  double _calculateStandardDeviation(List<double> values) {
    if (values.isEmpty) return 0.0;
    final mean = _calculateMean(values);
    final variance = values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / values.length;
    return sqrt(variance);
  }

  double _calculateMean(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  Future<List<ProductivityTrend>> _calculateProductivityTrends(DateRange dateRange) async {
    final trends = <ProductivityTrend>[];
    
    // Calculate weekly trends for the past 4 weeks
    final now = DateTime.now();
    final weekRanges = <DateRange>[];
    
    for (int i = 3; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: (i + 1) * 7));
      final weekEnd = now.subtract(Duration(days: i * 7));
      weekRanges.add(DateRange(start: weekStart, end: weekEnd));
    }
    
    final weeklyCompletionRates = <double>[];
    for (final range in weekRanges) {
      final tasks = await _getTasksInDateRange(range);
      final completedTasks = tasks.where((t) => t.status.isCompleted).length;
      final rate = tasks.isNotEmpty ? completedTasks / tasks.length : 0.0;
      weeklyCompletionRates.add(rate);
    }
    
    // Analyze trend
    if (weeklyCompletionRates.length >= 2) {
      final recent = weeklyCompletionRates.last;
      final previous = weeklyCompletionRates[weeklyCompletionRates.length - 2];
      final changeRate = previous != 0 ? (recent - previous) / previous : 0.0;
      
      String trendType;
      String description;
      
      if (changeRate > 0.1) {
        trendType = 'improving';
        description = 'Your productivity is improving with ${(changeRate * 100).toStringAsFixed(1)}% increase';
      } else if (changeRate < -0.1) {
        trendType = 'declining';
        description = 'Your productivity is declining with ${(changeRate.abs() * 100).toStringAsFixed(1)}% decrease';
      } else {
        trendType = 'stable';
        description = 'Your productivity is stable with minimal changes';
      }
      
      trends.add(ProductivityTrend(
        type: trendType,
        category: 'Overall',
        changeRate: changeRate,
        description: description,
      ));
    }
    
    return trends;
  }

  List<OptimizationSuggestion> _generateOptimizationSuggestions(
    Map<int, double> hourlyScores,
    Map<int, TaskTypeDistribution> hourlyTaskTypes,
  ) {
    final suggestions = <OptimizationSuggestion>[];
    
    // Find peak hours
    final sortedHours = hourlyScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (sortedHours.isNotEmpty) {
      final peakHour = sortedHours.first.key;
      suggestions.add(OptimizationSuggestion(
        title: 'Schedule Important Tasks During Peak Hours',
        description: 'Your peak productivity hour is ${_formatHour(peakHour)}. Schedule your most important tasks during this time.',
        category: 'scheduling',
        impactScore: 0.8,
        actionType: 'schedule',
        metadata: {'peakHour': peakHour},
      ));
    }
    
    // Find low productivity hours
    final lowHours = sortedHours.reversed.take(3).toList();
    if (lowHours.isNotEmpty) {
      suggestions.add(OptimizationSuggestion(
        title: 'Avoid Complex Tasks During Low Hours',
        description: 'Consider scheduling breaks or routine tasks during ${lowHours.map((h) => _formatHour(h.key)).join(', ')}.',
        category: 'scheduling',
        impactScore: 0.6,
        actionType: 'schedule',
        metadata: {'lowHours': lowHours.map((h) => h.key).toList()},
      ));
    }
    
    // Consistency suggestion
    final scores = hourlyScores.values.where((s) => s > 0).toList();
    if (scores.isNotEmpty) {
      final consistency = 1.0 - (_calculateStandardDeviation(scores) / _calculateMean(scores));
      if (consistency < 0.7) {
        suggestions.add(OptimizationSuggestion(
          title: 'Improve Consistency',
          description: 'Your productivity varies significantly throughout the day. Try to establish more consistent work patterns.',
          category: 'habit',
          impactScore: 0.7,
          actionType: 'habit',
          metadata: {'consistencyScore': consistency},
        ));
      }
    }
    
    return suggestions;
  }

  TimeRange _calculateRecommendedWorkingWindow(List<int> peakHours) {
    if (peakHours.isEmpty) {
      return const TimeRange(startHour: 9, endHour: 17, description: 'Standard working hours');
    }
    
    peakHours.sort();
    final startHour = peakHours.first;
    final endHour = peakHours.last + 1;
    
    return TimeRange(
      startHour: startHour,
      endHour: endHour,
      description: 'Recommended based on your peak productivity hours',
    );
  }

  Future<CategoryTrend> _calculateCategoryTrend(String categoryId, DateRange dateRange) async {
    final completionRates = <double>[];
    final intervalDays = dateRange.durationInDays ~/ 4; // Split into 4 intervals
    
    DateTime currentStart = dateRange.start;
    while (currentStart.isBefore(dateRange.end)) {
      final intervalEnd = currentStart.add(Duration(days: intervalDays));
      final intervalRange = DateRange(
        start: currentStart,
        end: intervalEnd.isBefore(dateRange.end) ? intervalEnd : dateRange.end,
      );
      
      final tasks = await _getTasksInDateRange(intervalRange);
      final categoryTasks = tasks.where((t) => t.tags.contains(categoryId) || (categoryId == 'Uncategorized' && t.tags.isEmpty)).toList();
      final completedTasks = categoryTasks.where((t) => t.status.isCompleted).length;
      final rate = categoryTasks.isNotEmpty ? completedTasks / categoryTasks.length : 0.0;
      
      completionRates.add(rate);
      currentStart = intervalEnd;
    }
    
    // Determine trend direction
    String trendDirection = 'stable';
    double changeRate = 0.0;
    
    if (completionRates.length >= 2) {
      final recent = completionRates.last;
      final first = completionRates.first;
      changeRate = first != 0 ? (recent - first) / first : 0.0;
      
      if (changeRate > 0.1) {
        trendDirection = 'up';
      } else if (changeRate < -0.1) {
        trendDirection = 'down';
      }
    }
    
    return CategoryTrend(
      categoryId: categoryId,
      completionRates: completionRates,
      trendDirection: trendDirection,
      changeRate: changeRate,
    );
  }

  Future<List<CategoryCorrelation>> _calculateCategoryCorrelations(
    String categoryId,
    List<CategoryAnalytics> allCategories,
  ) async {
    final correlations = <CategoryCorrelation>[];
    
    for (final otherCategory in allCategories) {
      if (otherCategory.categoryId == categoryId) continue;
      
      // Simple correlation based on completion rates
      final categoryA = allCategories.firstWhere((c) => c.categoryId == categoryId);
      final categoryB = otherCategory;
      
      // Calculate correlation score (simplified)
      final rateA = categoryA.completionRate;
      final rateB = categoryB.completionRate;
      final correlationScore = (rateA - 0.5) * (rateB - 0.5) * 2; // Simplified correlation
      
      String description;
      if (correlationScore > 0.3) {
        description = 'High positive correlation - these categories tend to be completed together';
      } else if (correlationScore < -0.3) {
        description = 'Negative correlation - when one category is high, the other tends to be low';
      } else {
        description = 'Low correlation - these categories are independent';
      }
      
      correlations.add(CategoryCorrelation(
        categoryA: categoryId,
        categoryB: otherCategory.categoryId,
        correlationScore: correlationScore.clamp(-1.0, 1.0),
        description: description,
      ));
    }
    
    return correlations;
  }

  CategoryPerformanceRanking _calculateCategoryPerformanceRanking(List<CategoryAnalytics> categories) {
    final categoryScores = <String, double>{};
    
    for (final category in categories) {
      // Performance score combines completion rate, task volume, and consistency
      final volumeScore = (category.totalTasks / 10.0).clamp(0.0, 1.0);
      final completionScore = category.completionRate;
      final performanceScore = (completionScore * 0.7) + (volumeScore * 0.3);
      
      categoryScores[category.categoryId] = performanceScore;
    }
    
    final sortedCategories = categoryScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topPerforming = sortedCategories.take(3).map((e) => e.key).toList();
    final underperforming = sortedCategories.reversed.take(3).map((e) => e.key).toList();
    
    return CategoryPerformanceRanking(
      topPerformingCategories: topPerforming,
      underperformingCategories: underperforming,
      categoryScores: categoryScores,
    );
  }

  Future<List<CategoryInsight>> _generateCategoryInsights(
    List<CategoryAnalytics> categories,
    Map<String, CategoryTrend> trends,
  ) async {
    final insights = <CategoryInsight>[];
    
    for (final category in categories) {
      final trend = trends[category.categoryId];
      
      // Peak time insight
      final hourlyDist = await _getCategoryHourlyDistribution(category.categoryId, DateRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ));
      
      final peakHour = hourlyDist.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      
      insights.add(CategoryInsight(
        categoryId: category.categoryId,
        insightType: 'peak_time',
        title: 'Peak Time for ${category.categoryName}',
        description: 'Most ${category.categoryName} tasks are completed at ${_formatHour(peakHour)}',
        confidence: 0.7,
      ));
      
      // Trend insight
      if (trend != null && trend.trendDirection != 'stable') {
        insights.add(CategoryInsight(
          categoryId: category.categoryId,
          insightType: 'completion_trend',
          title: '${category.categoryName} Trend',
          description: '${category.categoryName} completion rate is ${trend.trendDirection == 'up' ? 'improving' : 'declining'}',
          confidence: 0.8,
        ));
      }
    }
    
    return insights;
  }

  Future<Map<int, int>> _getCategoryHourlyDistribution(String categoryId, DateRange dateRange) async {
    final tasks = await _getTasksInDateRange(dateRange);
    final categoryTasks = tasks.where((t) => 
      t.tags.contains(categoryId) || (categoryId == 'Uncategorized' && t.tags.isEmpty)
    ).toList();
    
    final hourlyDist = <int, int>{};
    for (int hour = 0; hour < 24; hour++) {
      hourlyDist[hour] = 0;
    }
    
    for (final task in categoryTasks) {
      if (task.status.isCompleted && task.completedAt != null) {
        final hour = task.completedAt!.hour;
        hourlyDist[hour] = (hourlyDist[hour] ?? 0) + 1;
      }
    }
    
    return hourlyDist;
  }

  Future<Map<int, int>> _getCategoryWeekdayDistribution(String categoryId, DateRange dateRange) async {
    final tasks = await _getTasksInDateRange(dateRange);
    final categoryTasks = tasks.where((t) => 
      t.tags.contains(categoryId) || (categoryId == 'Uncategorized' && t.tags.isEmpty)
    ).toList();
    
    final weekdayDist = <int, int>{};
    for (int weekday = 1; weekday <= 7; weekday++) {
      weekdayDist[weekday] = 0;
    }
    
    for (final task in categoryTasks) {
      if (task.status.isCompleted && task.completedAt != null) {
        final weekday = task.completedAt!.weekday;
        weekdayDist[weekday] = (weekdayDist[weekday] ?? 0) + 1;
      }
    }
    
    return weekdayDist;
  }

  String _exportToJson(AnalyticsSummary summary, ProductivityMetrics metrics, ProductivityPatterns patterns) {
    final data = {
      'summary': summary.toJson(),
      'metrics': metrics.toJson(),
      'patterns': patterns.toJson(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
    return jsonEncode(data);
  }

  String _exportToCsv(AnalyticsSummary summary, ProductivityMetrics metrics, ProductivityPatterns patterns) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('Metric,Value,Period');
    
    // Summary data
    buffer.writeln('Total Tasks,${summary.totalTasks},${summary.startDate.toIso8601String()} - ${summary.endDate.toIso8601String()}');
    buffer.writeln('Completed Tasks,${summary.completedTasks},${summary.startDate.toIso8601String()} - ${summary.endDate.toIso8601String()}');
    buffer.writeln('Completion Rate,${(summary.completionRate * 100).toStringAsFixed(1)}%,${summary.startDate.toIso8601String()} - ${summary.endDate.toIso8601String()}');
    buffer.writeln('Current Streak,${summary.currentStreak} days,Current');
    buffer.writeln('Longest Streak,${summary.longestStreak} days,All Time');
    
    // Metrics data
    buffer.writeln('Weekly Completion Rate,${(metrics.weeklyCompletionRate * 100).toStringAsFixed(1)}%,Last 7 Days');
    buffer.writeln('Monthly Completion Rate,${(metrics.monthlyCompletionRate * 100).toStringAsFixed(1)}%,Last 30 Days');
    buffer.writeln('Average Tasks Per Day,${metrics.averageTasksPerDay.toStringAsFixed(1)},Last 30 Days');
    
    return buffer.toString();
  }

  String _exportToPdf(AnalyticsSummary summary, ProductivityMetrics metrics, ProductivityPatterns patterns) {
    // For now, return a placeholder. In a real implementation, you'd use a PDF library
    return 'PDF export not implemented yet. Use JSON or CSV format.';
  }

  String _exportToExcel(AnalyticsSummary summary, ProductivityMetrics metrics, ProductivityPatterns patterns) {
    // For now, return a placeholder. In a real implementation, you'd use an Excel library
    return 'Excel export not implemented yet. Use JSON or CSV format.';
  }

  ProductivityScore _calculateProductivityScore(
    AnalyticsSummary summary,
    ProductivityPatterns patterns,
    PeakHoursAnalysis peakAnalysis,
  ) {
    final completion = summary.completionRate * 100;
    final consistency = patterns.consistencyScore * 100;
    final efficiency = peakAnalysis.peakProductivityScore * 100;
    final timeManagement = (peakAnalysis.optimalWorkingHours / 8.0).clamp(0.0, 1.0) * 100;
    
    final overall = (completion * 0.4) + (consistency * 0.2) + (efficiency * 0.2) + (timeManagement * 0.2);
    
    String grade;
    if (overall >= 90) grade = 'A+';
    else if (overall >= 85) grade = 'A';
    else if (overall >= 80) grade = 'A-';
    else if (overall >= 75) grade = 'B+';
    else if (overall >= 70) grade = 'B';
    else if (overall >= 65) grade = 'B-';
    else if (overall >= 60) grade = 'C+';
    else if (overall >= 55) grade = 'C';
    else if (overall >= 50) grade = 'C-';
    else grade = 'D';
    
    return ProductivityScore(
      overall: overall,
      consistency: consistency,
      efficiency: efficiency,
      completion: completion,
      timeManagement: timeManagement,
      grade: grade,
    );
  }

  List<ProductivityGoal> _generateRecommendedGoals(
    ProductivityPatterns patterns,
    PeakHoursAnalysis peakAnalysis,
  ) {
    final goals = <ProductivityGoal>[];
    
    // Completion rate goal
    final avgCompletionRate = patterns.categoryEfficiency.values.isNotEmpty
        ? patterns.categoryEfficiency.values.reduce((a, b) => a + b) / patterns.categoryEfficiency.values.length
        : 0.0;
    
    if (avgCompletionRate < 0.8) {
      goals.add(ProductivityGoal(
        title: 'Improve Task Completion Rate',
        description: 'Increase your overall task completion rate to 80%',
        category: 'completion',
        targetValue: 0.8,
        timeframe: '30 days',
        actionSteps: [
          'Break large tasks into smaller, manageable subtasks',
          'Set realistic deadlines for your tasks',
          'Review and adjust your task priorities regularly',
        ],
      ));
    }
    
    // Consistency goal
    if (patterns.consistencyScore < 0.7) {
      goals.add(ProductivityGoal(
        title: 'Improve Productivity Consistency',
        description: 'Maintain more consistent productivity throughout the day',
        category: 'consistency',
        targetValue: 0.7,
        timeframe: '21 days',
        actionSteps: [
          'Establish a regular daily routine',
          'Schedule tasks during your peak hours',
          'Take regular breaks to maintain energy levels',
        ],
      ));
    }
    
    // Peak hours utilization goal
    if (peakAnalysis.peakProductivityScore < 0.6) {
      goals.add(ProductivityGoal(
        title: 'Optimize Peak Hours Usage',
        description: 'Better utilize your most productive hours',
        category: 'scheduling',
        targetValue: 0.8,
        timeframe: '14 days',
        actionSteps: [
          'Schedule your most important tasks during peak hours',
          'Minimize distractions during high-productivity periods',
          'Block calendar time for focused work during peak hours',
        ],
      ));
    }
    
    return goals;
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }
}