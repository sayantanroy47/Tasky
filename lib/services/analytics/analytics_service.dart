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
}