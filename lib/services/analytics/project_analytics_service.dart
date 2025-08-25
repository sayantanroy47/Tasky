import 'dart:math';

import '../../domain/entities/project.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../project_service.dart';

/// Comprehensive analytics service for project insights and metrics
class ProjectAnalyticsService {
  final ProjectRepository _projectRepository;
  final TaskRepository _taskRepository;
  final ProjectService _projectService;

  const ProjectAnalyticsService(
    this._projectRepository,
    this._taskRepository,
    this._projectService,
  );

  /// Gets comprehensive analytics data for a project
  Future<ProjectAnalytics> getProjectAnalytics(
    String projectId, {
    TimePeriod period = TimePeriod.last30Days,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final project = await _projectRepository.getProjectById(projectId);
    if (project == null) {
      throw ProjectNotFoundException('Project not found: $projectId');
    }

    final tasks = await _taskRepository.getTasksByProject(projectId);
    final periodData = _calculateTimePeriod(period, startDate, endDate);
    
    // Get basic stats
    final basicStats = await _projectService.getProjectStats(projectId);
    
    // Calculate advanced metrics
    final progressData = await _calculateProgressOverTime(tasks, periodData);
    final velocityData = _calculateVelocityMetrics(tasks, periodData);
    final distributionData = _calculateTaskDistribution(tasks);
    final performanceData = _calculatePerformanceMetrics(tasks);
    final riskData = _calculateRiskIndicators(tasks, project);
    final milestoneData = _calculateMilestoneProgress(tasks, project);
    
    return ProjectAnalytics(
      projectId: projectId,
      period: period,
      startDate: periodData.start,
      endDate: periodData.end,
      basicStats: basicStats,
      progressData: progressData,
      velocityData: velocityData,
      distributionData: distributionData,
      performanceData: performanceData,
      riskData: riskData,
      milestoneData: milestoneData,
      healthScore: _calculateProjectHealthScore(basicStats, performanceData, riskData),
      predictedCompletionDate: _calculatePredictedCompletion(tasks, velocityData, project),
    );
  }

  /// Calculate progress data over time
  Future<ProgressOverTime> _calculateProgressOverTime(
    List<TaskModel> tasks, 
    _TimePeriodData periodData,
  ) async {
    final dailyProgress = <ProgressPoint>[];
    final burndownData = <BurndownPoint>[];
    final cumulativeFlow = <CumulativeFlowPoint>[];
    
    final totalTasks = tasks.length;
    var currentDate = DateTime(periodData.start.year, periodData.start.month, periodData.start.day);
    
    while (currentDate.isBefore(periodData.end) || currentDate.isAtSameMomentAs(periodData.end)) {
      final endOfDay = currentDate.add(const Duration(days: 1));
      
      // Calculate completed tasks by this date
      final completedByDate = tasks.where((task) =>
        task.status.isCompleted &&
        task.completedAt != null &&
        task.completedAt!.isBefore(endOfDay)
      ).length;
      
      // Calculate started tasks by this date
      final startedByDate = tasks.where((task) =>
        task.status.isInProgress &&
        task.updatedAt != null &&
        task.updatedAt!.isBefore(endOfDay)
      ).length;
      
      // Calculate remaining work
      final remainingTasks = totalTasks - completedByDate;
      final completionPercentage = totalTasks > 0 ? completedByDate / totalTasks : 0.0;
      
      // Progress point
      dailyProgress.add(ProgressPoint(
        date: DateTime(currentDate.year, currentDate.month, currentDate.day),
        completedTasks: completedByDate,
        totalTasks: totalTasks,
        completionPercentage: completionPercentage,
        velocity: _calculateDayVelocity(tasks, currentDate),
      ));
      
      // Burndown point
      burndownData.add(BurndownPoint(
        date: DateTime(currentDate.year, currentDate.month, currentDate.day),
        remainingWork: remainingTasks,
        idealBurndown: _calculateIdealBurndown(totalTasks, periodData, currentDate),
      ));
      
      // Cumulative flow
      final pendingTasks = tasks.where((task) => 
        task.status.isPending && 
        task.createdAt.isBefore(endOfDay)
      ).length;
      
      final inProgressTasks = tasks.where((task) =>
        task.status.isInProgress &&
        task.updatedAt != null &&
        task.updatedAt!.isBefore(endOfDay)
      ).length;
      
      cumulativeFlow.add(CumulativeFlowPoint(
        date: DateTime(currentDate.year, currentDate.month, currentDate.day),
        pendingTasks: pendingTasks,
        inProgressTasks: inProgressTasks,
        completedTasks: completedByDate,
      ));
      
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return ProgressOverTime(
      dailyProgress: dailyProgress,
      burndownData: burndownData,
      cumulativeFlow: cumulativeFlow,
    );
  }
  
  /// Calculate velocity metrics
  VelocityMetrics _calculateVelocityMetrics(
    List<TaskModel> tasks, 
    _TimePeriodData periodData,
  ) {
    final completedTasks = tasks.where((task) => 
      task.status.isCompleted && 
      task.completedAt != null &&
      task.completedAt!.isAfter(periodData.start) &&
      task.completedAt!.isBefore(periodData.end)
    ).toList();
    
    final totalDays = periodData.end.difference(periodData.start).inDays;
    final avgTasksPerDay = totalDays > 0 ? completedTasks.length / totalDays : 0.0;
    
    // Calculate weekly velocities
    final weeklyVelocities = <WeeklyVelocity>[];
    var currentWeek = _getWeekStart(periodData.start);
    
    while (currentWeek.isBefore(periodData.end)) {
      final weekEnd = currentWeek.add(const Duration(days: 7));
      final weekCompleted = completedTasks.where((task) =>
        task.completedAt!.isAfter(currentWeek) &&
        task.completedAt!.isBefore(weekEnd)
      ).length;
      
      weeklyVelocities.add(WeeklyVelocity(
        weekStart: currentWeek,
        tasksCompleted: weekCompleted,
        velocity: weekCompleted / 7.0,
      ));
      
      currentWeek = weekEnd;
    }
    
    final avgWeeklyVelocity = weeklyVelocities.isNotEmpty 
      ? weeklyVelocities.map((w) => w.tasksCompleted).reduce((a, b) => a + b) / weeklyVelocities.length
      : 0.0;
    
    return VelocityMetrics(
      averageTasksPerDay: avgTasksPerDay,
      averageTasksPerWeek: avgWeeklyVelocity,
      weeklyVelocities: weeklyVelocities,
      trend: _calculateVelocityTrend(weeklyVelocities),
    );
  }
  
  /// Calculate task distribution across different dimensions
  TaskDistribution _calculateTaskDistribution(List<TaskModel> tasks) {
    final priorityDistribution = <TaskPriority, int>{};
    final statusDistribution = <TaskStatus, int>{};
    final tagDistribution = <String, int>{};
    
    for (final priority in TaskPriority.values) {
      priorityDistribution[priority] = tasks.where((t) => t.priority == priority).length;
    }
    
    for (final status in TaskStatus.values) {
      statusDistribution[status] = tasks.where((t) => t.status == status).length;
    }
    
    // Calculate tag distribution
    final allTags = tasks.expand((task) => task.tags).toList();
    for (final tag in allTags) {
      tagDistribution[tag] = (tagDistribution[tag] ?? 0) + 1;
    }
    
    return TaskDistribution(
      byPriority: priorityDistribution,
      byStatus: statusDistribution,
      byTag: tagDistribution,
      totalTasks: tasks.length,
    );
  }
  
  /// Calculate performance metrics
  PerformanceMetrics _calculatePerformanceMetrics(List<TaskModel> tasks) {
    final completedTasks = tasks.where((t) => t.status.isCompleted && t.completedAt != null).toList();
    
    if (completedTasks.isEmpty) {
      return const PerformanceMetrics(
        averageCompletionTime: Duration.zero,
        estimationAccuracy: 0.0,
        onTimeCompletionRate: 0.0,
        bottlenecks: [],
        productivityTrends: [],
      );
    }
    
    // Calculate average completion time
    final completionTimes = completedTasks.map((task) {
      return task.completedAt!.difference(task.createdAt);
    }).toList();
    
    final totalCompletionTime = completionTimes.fold<Duration>(
      Duration.zero,
      (sum, duration) => sum + duration,
    );
    
    final avgCompletionTime = Duration(
      milliseconds: totalCompletionTime.inMilliseconds ~/ completedTasks.length,
    );
    
    // Calculate estimation accuracy
    final tasksWithEstimates = completedTasks.where((t) => 
      t.estimatedDuration != null && t.actualDuration != null
    ).toList();
    
    double estimationAccuracy = 0.0;
    if (tasksWithEstimates.isNotEmpty) {
      final accuracySum = tasksWithEstimates.map((task) {
        final estimated = task.estimatedDuration!;
        final actual = task.actualDuration!;
        return 1 - (estimated - actual).abs() / estimated;
      }).fold<double>(0.0, (sum, accuracy) => sum + max(0.0, accuracy));
      
      estimationAccuracy = accuracySum / tasksWithEstimates.length;
    }
    
    // Calculate on-time completion rate
    final tasksWithDueDate = completedTasks.where((t) => t.dueDate != null).toList();
    double onTimeRate = 0.0;
    if (tasksWithDueDate.isNotEmpty) {
      final onTimeTasks = tasksWithDueDate.where((t) =>
        t.completedAt!.isBefore(t.dueDate!) || t.completedAt!.isAtSameMomentAs(t.dueDate!)
      ).length;
      onTimeRate = onTimeTasks / tasksWithDueDate.length;
    }
    
    // Identify bottlenecks
    final bottlenecks = _identifyBottlenecks(tasks);
    
    // Calculate productivity trends
    final productivityTrends = _calculateProductivityTrends(completedTasks);
    
    return PerformanceMetrics(
      averageCompletionTime: avgCompletionTime,
      estimationAccuracy: estimationAccuracy,
      onTimeCompletionRate: onTimeRate,
      bottlenecks: bottlenecks,
      productivityTrends: productivityTrends,
    );
  }
  
  /// Calculate risk indicators
  RiskIndicators _calculateRiskIndicators(List<TaskModel> tasks, Project project) {
    final overdueTasks = tasks.where((t) => t.isOverdue).length;
    final totalTasks = tasks.length;
    final overdueRisk = totalTasks > 0 ? overdueTasks / totalTasks : 0.0;
    
    final upcomingDeadlines = tasks.where((t) => 
      t.dueDate != null && 
      t.dueDate!.isAfter(DateTime.now()) &&
      t.dueDate!.difference(DateTime.now()).inDays <= 7
    ).length;
    
    final blockedTasks = tasks.where((t) => t.dependencies.isNotEmpty).length;
    final blockageRisk = totalTasks > 0 ? blockedTasks / totalTasks : 0.0;
    
    final highPriorityPending = tasks.where((t) => 
      (t.priority == TaskPriority.high || t.priority == TaskPriority.urgent) &&
      !t.status.isCompleted
    ).length;
    
    var scheduleRisk = 0.0;
    if (project.deadline != null) {
      final timeRemaining = project.deadline!.difference(DateTime.now()).inDays;
      final completedTasks = tasks.where((t) => t.status.isCompleted).length;
      final completionRate = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
      
      if (timeRemaining <= 0 && completionRate < 1.0) {
        scheduleRisk = 1.0;
      } else if (timeRemaining > 0) {
        final requiredVelocity = (totalTasks - completedTasks) / timeRemaining;
        // Simplified risk calculation based on required vs. current velocity
        scheduleRisk = min(1.0, max(0.0, requiredVelocity - 1.0));
      }
    }
    
    return RiskIndicators(
      overdueTasksRatio: overdueRisk,
      upcomingDeadlines: upcomingDeadlines,
      blockageRisk: blockageRisk,
      scheduleRisk: scheduleRisk,
      highPriorityPendingTasks: highPriorityPending,
      riskLevel: _calculateOverallRisk(overdueRisk, blockageRisk, scheduleRisk),
    );
  }
  
  /// Calculate milestone progress
  MilestoneProgress _calculateMilestoneProgress(List<TaskModel> tasks, Project project) {
    final milestones = tasks.where((task) =>
      task.priority == TaskPriority.high ||
      task.priority == TaskPriority.urgent ||
      task.dueDate != null ||
      task.dependencies.isNotEmpty
    ).toList();
    
    final completedMilestones = milestones.where((t) => t.status.isCompleted).length;
    final upcomingMilestones = milestones.where((t) =>
      !t.status.isCompleted &&
      t.dueDate != null &&
      t.dueDate!.difference(DateTime.now()).inDays <= 30
    ).toList();
    
    final milestoneData = milestones.map((task) => MilestoneData(
      taskId: task.id,
      title: task.title,
      dueDate: task.dueDate,
      status: task.status,
      priority: task.priority,
      isCompleted: task.status.isCompleted,
      isOverdue: task.isOverdue,
      dependentTasks: task.dependencies.length,
    )).toList();
    
    return MilestoneProgress(
      totalMilestones: milestones.length,
      completedMilestones: completedMilestones,
      upcomingMilestones: upcomingMilestones.length,
      milestones: milestoneData,
    );
  }
  
  /// Calculate project health score (0.0 to 1.0)
  double _calculateProjectHealthScore(
    ProjectStats basicStats,
    PerformanceMetrics performance,
    RiskIndicators risk,
  ) {
    final completionScore = basicStats.completionPercentage;
    final onTimeScore = performance.onTimeCompletionRate;
    final riskScore = 1.0 - risk.riskLevel;
    final overdueScore = 1.0 - risk.overdueTasksRatio;
    
    // Weighted average
    return (completionScore * 0.3 + 
            onTimeScore * 0.3 + 
            riskScore * 0.25 + 
            overdueScore * 0.15).clamp(0.0, 1.0);
  }
  
  /// Predict completion date based on current velocity
  DateTime? _calculatePredictedCompletion(
    List<TaskModel> tasks,
    VelocityMetrics velocity,
    Project project,
  ) {
    final remainingTasks = tasks.where((t) => !t.status.isCompleted).length;
    if (remainingTasks == 0) return DateTime.now();
    
    if (velocity.averageTasksPerDay <= 0) {
      return project.deadline; // Fallback to project deadline
    }
    
    final daysNeeded = remainingTasks / velocity.averageTasksPerDay;
    return DateTime.now().add(Duration(days: daysNeeded.ceil()));
  }
  
  // Helper methods
  _TimePeriodData _calculateTimePeriod(TimePeriod period, DateTime? startDate, DateTime? endDate) {
    final now = DateTime.now();
    
    if (startDate != null && endDate != null) {
      return _TimePeriodData(startDate, endDate);
    }
    
    switch (period) {
      case TimePeriod.last7Days:
        return _TimePeriodData(now.subtract(const Duration(days: 7)), now);
      case TimePeriod.last30Days:
        return _TimePeriodData(now.subtract(const Duration(days: 30)), now);
      case TimePeriod.last3Months:
        return _TimePeriodData(now.subtract(const Duration(days: 90)), now);
      case TimePeriod.allTime:
        return _TimePeriodData(DateTime(2020), now);
    }
  }
  
  double _calculateDayVelocity(List<TaskModel> tasks, DateTime date) {
    final endOfDay = date.add(const Duration(days: 1));
    return tasks.where((task) =>
      task.status.isCompleted &&
      task.completedAt != null &&
      task.completedAt!.isAfter(date) &&
      task.completedAt!.isBefore(endOfDay)
    ).length.toDouble();
  }
  
  double _calculateIdealBurndown(int totalTasks, _TimePeriodData period, DateTime currentDate) {
    final totalDays = period.end.difference(period.start).inDays;
    final daysPassed = currentDate.difference(period.start).inDays;
    
    if (totalDays <= 0) return totalTasks.toDouble();
    
    final burndownRate = totalTasks / totalDays;
    return totalTasks - (burndownRate * daysPassed);
  }
  
  DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return date.subtract(Duration(days: daysFromMonday));
  }
  
  VelocityTrend _calculateVelocityTrend(List<WeeklyVelocity> weeklyVelocities) {
    if (weeklyVelocities.length < 2) return VelocityTrend.stable;
    
    final recent = weeklyVelocities.skip(weeklyVelocities.length - 3).map((w) => w.tasksCompleted).toList();
    final earlier = weeklyVelocities.take(weeklyVelocities.length - 3).map((w) => w.tasksCompleted).toList();
    
    if (recent.isEmpty || earlier.isEmpty) return VelocityTrend.stable;
    
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final earlierAvg = earlier.reduce((a, b) => a + b) / earlier.length;
    
    final difference = recentAvg - earlierAvg;
    
    if (difference > 0.5) return VelocityTrend.increasing;
    if (difference < -0.5) return VelocityTrend.decreasing;
    return VelocityTrend.stable;
  }
  
  List<Bottleneck> _identifyBottlenecks(List<TaskModel> tasks) {
    final bottlenecks = <Bottleneck>[];
    
    // Identify tasks stuck in progress for too long
    final stuckTasks = tasks.where((task) =>
      task.status.isInProgress &&
      task.updatedAt != null &&
      DateTime.now().difference(task.updatedAt!).inDays > 7
    ).toList();
    
    if (stuckTasks.isNotEmpty) {
      bottlenecks.add(Bottleneck(
        type: BottleneckType.stuckInProgress,
        description: '${stuckTasks.length} tasks stuck in progress for over a week',
        affectedTasks: stuckTasks.length,
        severity: stuckTasks.length > 5 ? BottleneckSeverity.high : BottleneckSeverity.medium,
      ));
    }
    
    // Identify dependency bottlenecks
    final blockedTasks = tasks.where((task) => task.dependencies.isNotEmpty).length;
    if (blockedTasks > 0) {
      final severity = blockedTasks > 10 ? BottleneckSeverity.high : 
                       blockedTasks > 5 ? BottleneckSeverity.medium : BottleneckSeverity.low;
                       
      bottlenecks.add(Bottleneck(
        type: BottleneckType.dependencies,
        description: '$blockedTasks tasks waiting on dependencies',
        affectedTasks: blockedTasks,
        severity: severity,
      ));
    }
    
    return bottlenecks;
  }
  
  List<ProductivityTrend> _calculateProductivityTrends(List<TaskModel> completedTasks) {
    final trends = <ProductivityTrend>[];
    final now = DateTime.now();
    
    for (int i = 0; i < 4; i++) {
      final weekStart = now.subtract(Duration(days: (i + 1) * 7));
      final weekEnd = now.subtract(Duration(days: i * 7));
      
      final weekTasks = completedTasks.where((task) =>
        task.completedAt!.isAfter(weekStart) &&
        task.completedAt!.isBefore(weekEnd)
      ).length;
      
      trends.add(ProductivityTrend(
        period: 'Week ${i + 1}',
        tasksCompleted: weekTasks,
        date: weekStart,
      ));
    }
    
    return trends.reversed.toList();
  }
  
  double _calculateOverallRisk(double overdueRisk, double blockageRisk, double scheduleRisk) {
    return (overdueRisk * 0.4 + blockageRisk * 0.3 + scheduleRisk * 0.3).clamp(0.0, 1.0);
  }
}

// Data models for analytics
class ProjectAnalytics {
  final String projectId;
  final TimePeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final ProjectStats basicStats;
  final ProgressOverTime progressData;
  final VelocityMetrics velocityData;
  final TaskDistribution distributionData;
  final PerformanceMetrics performanceData;
  final RiskIndicators riskData;
  final MilestoneProgress milestoneData;
  final double healthScore;
  final DateTime? predictedCompletionDate;

  const ProjectAnalytics({
    required this.projectId,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.basicStats,
    required this.progressData,
    required this.velocityData,
    required this.distributionData,
    required this.performanceData,
    required this.riskData,
    required this.milestoneData,
    required this.healthScore,
    this.predictedCompletionDate,
  });
}

class ProgressOverTime {
  final List<ProgressPoint> dailyProgress;
  final List<BurndownPoint> burndownData;
  final List<CumulativeFlowPoint> cumulativeFlow;

  const ProgressOverTime({
    required this.dailyProgress,
    required this.burndownData,
    required this.cumulativeFlow,
  });
}

class ProgressPoint {
  final DateTime date;
  final int completedTasks;
  final int totalTasks;
  final double completionPercentage;
  final double velocity;

  const ProgressPoint({
    required this.date,
    required this.completedTasks,
    required this.totalTasks,
    required this.completionPercentage,
    required this.velocity,
  });
}

class BurndownPoint {
  final DateTime date;
  final int remainingWork;
  final double idealBurndown;

  const BurndownPoint({
    required this.date,
    required this.remainingWork,
    required this.idealBurndown,
  });
}

class CumulativeFlowPoint {
  final DateTime date;
  final int pendingTasks;
  final int inProgressTasks;
  final int completedTasks;

  const CumulativeFlowPoint({
    required this.date,
    required this.pendingTasks,
    required this.inProgressTasks,
    required this.completedTasks,
  });
}

class VelocityMetrics {
  final double averageTasksPerDay;
  final double averageTasksPerWeek;
  final List<WeeklyVelocity> weeklyVelocities;
  final VelocityTrend trend;

  const VelocityMetrics({
    required this.averageTasksPerDay,
    required this.averageTasksPerWeek,
    required this.weeklyVelocities,
    required this.trend,
  });
}

class WeeklyVelocity {
  final DateTime weekStart;
  final int tasksCompleted;
  final double velocity;

  const WeeklyVelocity({
    required this.weekStart,
    required this.tasksCompleted,
    required this.velocity,
  });
}

class TaskDistribution {
  final Map<TaskPriority, int> byPriority;
  final Map<TaskStatus, int> byStatus;
  final Map<String, int> byTag;
  final int totalTasks;

  const TaskDistribution({
    required this.byPriority,
    required this.byStatus,
    required this.byTag,
    required this.totalTasks,
  });
}

class PerformanceMetrics {
  final Duration averageCompletionTime;
  final double estimationAccuracy;
  final double onTimeCompletionRate;
  final List<Bottleneck> bottlenecks;
  final List<ProductivityTrend> productivityTrends;

  const PerformanceMetrics({
    required this.averageCompletionTime,
    required this.estimationAccuracy,
    required this.onTimeCompletionRate,
    required this.bottlenecks,
    required this.productivityTrends,
  });
}

class RiskIndicators {
  final double overdueTasksRatio;
  final int upcomingDeadlines;
  final double blockageRisk;
  final double scheduleRisk;
  final int highPriorityPendingTasks;
  final double riskLevel;

  const RiskIndicators({
    required this.overdueTasksRatio,
    required this.upcomingDeadlines,
    required this.blockageRisk,
    required this.scheduleRisk,
    required this.highPriorityPendingTasks,
    required this.riskLevel,
  });
}

class MilestoneProgress {
  final int totalMilestones;
  final int completedMilestones;
  final int upcomingMilestones;
  final List<MilestoneData> milestones;

  const MilestoneProgress({
    required this.totalMilestones,
    required this.completedMilestones,
    required this.upcomingMilestones,
    required this.milestones,
  });
}

class MilestoneData {
  final String taskId;
  final String title;
  final DateTime? dueDate;
  final TaskStatus status;
  final TaskPriority priority;
  final bool isCompleted;
  final bool isOverdue;
  final int dependentTasks;

  const MilestoneData({
    required this.taskId,
    required this.title,
    required this.dueDate,
    required this.status,
    required this.priority,
    required this.isCompleted,
    required this.isOverdue,
    required this.dependentTasks,
  });
}

class Bottleneck {
  final BottleneckType type;
  final String description;
  final int affectedTasks;
  final BottleneckSeverity severity;

  const Bottleneck({
    required this.type,
    required this.description,
    required this.affectedTasks,
    required this.severity,
  });
}

class ProductivityTrend {
  final String period;
  final int tasksCompleted;
  final DateTime date;

  const ProductivityTrend({
    required this.period,
    required this.tasksCompleted,
    required this.date,
  });
}

class _TimePeriodData {
  final DateTime start;
  final DateTime end;

  const _TimePeriodData(this.start, this.end);
}

// Enums
enum TimePeriod { last7Days, last30Days, last3Months, allTime }

enum VelocityTrend { increasing, stable, decreasing }

enum BottleneckType { stuckInProgress, dependencies, overdue, resources }

enum BottleneckSeverity { low, medium, high }

// Extension methods
extension TaskStatusExtensions on TaskStatus {
  bool get isPending => this == TaskStatus.pending;
  bool get isInProgress => this == TaskStatus.inProgress;
  bool get isCompleted => this == TaskStatus.completed;
  bool get isCancelled => this == TaskStatus.cancelled;
}

extension TaskModelExtensions on TaskModel {
  bool get isOverdue {
    if (dueDate == null || status.isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final due = dueDate!;
    return now.year == due.year && now.month == due.month && now.day == due.day;
  }

  bool get isDueSoon {
    if (dueDate == null) return false;
    return dueDate!.difference(DateTime.now()).inDays <= 3;
  }

  bool get hasDependencies => dependencies.isNotEmpty;
}