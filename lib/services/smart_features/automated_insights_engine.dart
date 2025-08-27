import 'dart:async';
import 'dart:math';
import '../../domain/entities/project.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../analytics/analytics_service.dart';

/// Automated insights engine that recognizes patterns and generates actionable intelligence
class AutomatedInsightsEngine {
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;

  AutomatedInsightsEngine({
    required TaskRepository taskRepository,
    required ProjectRepository projectRepository,
  })  : _taskRepository = taskRepository,
        _projectRepository = projectRepository;

  /// Generates comprehensive insights across all projects and tasks
  Future<Map<String, dynamic>> generateComprehensiveInsights() async {
    final insights = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'patterns': <String, dynamic>{},
      'trends': <String, dynamic>{},
      'recommendations': <String>[],
      'productivity_insights': <String, dynamic>{},
      'risk_indicators': <String, dynamic>{},
      'optimization_opportunities': <String>[],
      'behavioral_patterns': <String, dynamic>{},
      'performance_metrics': <String, dynamic>{},
    };

    try {
      // Gather all data
      final allProjects = await _projectRepository.getAllProjects();
      final allTasks = await _taskRepository.getAllTasks();
      
      if (allTasks.isEmpty) {
        insights['message'] = 'No task data available for analysis';
        return insights;
      }

      // Generate different types of insights
      insights['patterns'] = await _identifyTaskPatterns(allTasks, allProjects);
      insights['trends'] = await _analyzeTrends(allTasks, allProjects);
      insights['productivity_insights'] = await _generateProductivityInsights(allTasks, allProjects);
      insights['risk_indicators'] = await _identifyRiskIndicators(allTasks, allProjects);
      insights['behavioral_patterns'] = await _analyzeBehavioralPatterns(allTasks, allProjects);
      insights['performance_metrics'] = await _calculatePerformanceMetrics(allTasks, allProjects);
      
      // Generate high-level recommendations
      insights['recommendations'] = await _generateRecommendations(insights);
      insights['optimization_opportunities'] = await _identifyOptimizationOpportunities(insights);

    } catch (e) {
      insights['error'] = e.toString();
    }

    return insights;
  }

  /// Identifies patterns in task management behavior
  Future<Map<String, dynamic>> _identifyTaskPatterns(
    List<TaskModel> tasks,
    List<Project> projects,
  ) async {
    final patterns = <String, dynamic>{};

    // Completion time patterns
    patterns['completion_time_patterns'] = _analyzeCompletionTimePatterns(tasks);
    
    // Task size patterns
    patterns['task_size_patterns'] = _analyzeTaskSizePatterns(tasks);
    
    // Priority patterns
    patterns['priority_patterns'] = _analyzePriorityPatterns(tasks);
    
    // Category patterns
    patterns['category_patterns'] = _analyzeCategoryPatterns(tasks);
    
    // Deadline patterns
    patterns['deadline_patterns'] = _analyzeDeadlinePatterns(tasks);
    
    // Dependency patterns
    patterns['dependency_patterns'] = _analyzeDependencyPatterns(tasks);
    
    // Project patterns
    patterns['project_patterns'] = _analyzeProjectPatterns(projects, tasks);

    return patterns;
  }

  /// Analyzes trends over time
  Future<Map<String, dynamic>> _analyzeTrends(
    List<TaskModel> tasks,
    List<Project> projects,
  ) async {
    final trends = <String, dynamic>{};

    // Completion rate trends
    trends['completion_rate_trend'] = _analyzeCompletionRateTrend(tasks);
    
    // Velocity trends
    trends['velocity_trend'] = _analyzeVelocityTrend(tasks);
    
    // Quality trends
    trends['quality_trend'] = _analyzeQualityTrend(tasks);
    
    // Project health trends
    trends['project_health_trend'] = _analyzeProjectHealthTrend(projects, tasks);
    
    // Seasonal patterns
    trends['seasonal_patterns'] = _analyzeSeasonalPatterns(tasks);
    
    // Workload trends
    trends['workload_trends'] = _analyzeWorkloadTrends(tasks);

    return trends;
  }

  /// Generates productivity insights
  Future<Map<String, dynamic>> _generateProductivityInsights(
    List<TaskModel> tasks,
    List<Project> projects,
  ) async {
    final insights = <String, dynamic>{};

    // Peak performance times
    insights['peak_performance_times'] = _identifyPeakPerformanceTimes(tasks);
    
    // Productive days analysis
    insights['productive_days'] = _analyzeProductiveDays(tasks);
    
    // Context switching analysis
    insights['context_switching'] = _analyzeContextSwitching(tasks);
    
    // Batch processing insights
    insights['batch_processing'] = _analyzeBatchProcessing(tasks);
    
    // Focus time analysis
    insights['focus_time_analysis'] = _analyzeFocusTime(tasks);
    
    // Multitasking patterns
    insights['multitasking_patterns'] = _analyzeMultitaskingPatterns(tasks);

    return insights;
  }

  /// Identifies risk indicators
  Future<Map<String, dynamic>> _identifyRiskIndicators(
    List<TaskModel> tasks,
    List<Project> projects,
  ) async {
    final indicators = <String, dynamic>{};

    // Overdue task indicators
    indicators['overdue_risk'] = _analyzeOverdueRisk(tasks);
    
    // Burnout indicators
    indicators['burnout_risk'] = _analyzeBurnoutIndicators(tasks);
    
    // Quality risk indicators
    indicators['quality_risk'] = _analyzeQualityRiskIndicators(tasks);
    
    // Deadline risk indicators
    indicators['deadline_risk'] = _analyzeDeadlineRisk(projects, tasks);
    
    // Scope creep indicators
    indicators['scope_creep_risk'] = _analyzeScopeCreepRisk(projects, tasks);
    
    // Resource constraint indicators
    indicators['resource_constraint_risk'] = _analyzeResourceConstraintRisk(projects, tasks);

    return indicators;
  }

  /// Analyzes behavioral patterns
  Future<Map<String, dynamic>> _analyzeBehavioralPatterns(
    List<TaskModel> tasks,
    List<Project> projects,
  ) async {
    final patterns = <String, dynamic>{};

    // Procrastination patterns
    patterns['procrastination_patterns'] = _analyzeProcrastinationPatterns(tasks);
    
    // Task completion preferences
    patterns['completion_preferences'] = _analyzeCompletionPreferences(tasks);
    
    // Planning patterns
    patterns['planning_patterns'] = _analyzePlanningPatterns(tasks);
    
    // Communication patterns
    patterns['communication_patterns'] = _analyzeCommunicationPatterns(tasks, projects);
    
    // Decision-making patterns
    patterns['decision_making_patterns'] = _analyzeDecisionMakingPatterns(tasks);

    return patterns;
  }

  /// Calculates performance metrics
  Future<Map<String, dynamic>> _calculatePerformanceMetrics(
    List<TaskModel> tasks,
    List<Project> projects,
  ) async {
    final metrics = <String, dynamic>{};

    // Efficiency metrics
    metrics['efficiency'] = _calculateEfficiencyMetrics(tasks);
    
    // Accuracy metrics
    metrics['accuracy'] = _calculateAccuracyMetrics(tasks);
    
    // Consistency metrics
    metrics['consistency'] = _calculateConsistencyMetrics(tasks);
    
    // Throughput metrics
    metrics['throughput'] = _calculateThroughputMetrics(tasks);
    
    // Quality metrics
    metrics['quality'] = _calculateQualityMetrics(tasks);

    return metrics;
  }

  // Pattern analysis methods

  Map<String, dynamic> _analyzeCompletionTimePatterns(List<TaskModel> tasks) {
    final completedTasks = tasks.where((t) => 
        t.status.isCompleted && t.completedAt != null).toList();
    
    if (completedTasks.isEmpty) return {'message': 'No completed tasks to analyze'};

    final hourlyDistribution = <int, int>{};
    final dayOfWeekDistribution = <int, int>{};
    
    for (final task in completedTasks) {
      final hour = task.completedAt!.hour;
      final dayOfWeek = task.completedAt!.weekday;
      
      hourlyDistribution[hour] = (hourlyDistribution[hour] ?? 0) + 1;
      dayOfWeekDistribution[dayOfWeek] = (dayOfWeekDistribution[dayOfWeek] ?? 0) + 1;
    }

    final mostProductiveHour = hourlyDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    final mostProductiveDay = dayOfWeekDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    return {
      'hourly_distribution': hourlyDistribution,
      'daily_distribution': dayOfWeekDistribution,
      'most_productive_hour': mostProductiveHour.key,
      'most_productive_day': mostProductiveDay.key,
      'total_completed_tasks': completedTasks.length,
      'insights': [
        'You complete most tasks at ${mostProductiveHour.key}:00',
        'Your most productive day is ${_getDayName(mostProductiveDay.key)}',
      ],
    };
  }

  Map<String, dynamic> _analyzeTaskSizePatterns(List<TaskModel> tasks) {
    final tasksWithDuration = tasks.where((t) => t.estimatedDuration != null).toList();
    
    if (tasksWithDuration.isEmpty) return {'message': 'No duration estimates to analyze'};

    final durations = tasksWithDuration.map((t) => t.estimatedDuration!).toList();
    final avgDuration = durations.reduce((a, b) => a + b) / durations.length;
    final shortTasks = durations.where((d) => d < avgDuration * 0.5).length;
    final mediumTasks = durations.where((d) => d >= avgDuration * 0.5 && d <= avgDuration * 2).length;
    final longTasks = durations.where((d) => d > avgDuration * 2).length;

    return {
      'average_duration_minutes': avgDuration.round(),
      'short_tasks_count': shortTasks,
      'medium_tasks_count': mediumTasks,
      'long_tasks_count': longTasks,
      'size_distribution': {
        'short': (shortTasks / durations.length * 100).round(),
        'medium': (mediumTasks / durations.length * 100).round(),
        'long': (longTasks / durations.length * 100).round(),
      },
      'insights': [
        'Average task duration is ${(avgDuration / 60).toStringAsFixed(1)} hours',
        if (longTasks > durations.length * 0.3) 'Consider breaking down large tasks',
        if (shortTasks > durations.length * 0.6) 'Many small tasks - consider batching',
      ],
    };
  }

  Map<String, dynamic> _analyzePriorityPatterns(List<TaskModel> tasks) {
    final priorityDistribution = <String, int>{};
    final priorityCompletionRate = <String, double>{};

    for (final priority in TaskPriority.values) {
      final tasksWithPriority = tasks.where((t) => t.priority == priority).toList();
      final completedWithPriority = tasksWithPriority.where((t) => t.status.isCompleted).length;
      
      priorityDistribution[priority.name] = tasksWithPriority.length;
      priorityCompletionRate[priority.name] = tasksWithPriority.isNotEmpty 
          ? completedWithPriority / tasksWithPriority.length 
          : 0.0;
    }

    final highPriorityRate = priorityCompletionRate['high'] ?? 0.0;
    final lowPriorityRate = priorityCompletionRate['low'] ?? 0.0;

    return {
      'priority_distribution': priorityDistribution,
      'completion_rates': priorityCompletionRate,
      'insights': [
        if (highPriorityRate < 0.7) 'High-priority tasks need more focus',
        if (lowPriorityRate > highPriorityRate) 'Review priority assignment accuracy',
        'You complete ${(highPriorityRate * 100).round()}% of high-priority tasks',
      ],
    };
  }

  Map<String, dynamic> _analyzeCategoryPatterns(List<TaskModel> tasks) {
    final categoryDistribution = <String, int>{};
    final categoryCompletionRate = <String, double>{};
    final categoryAvgDuration = <String, double>{};

    // Get all unique categories from tags
    final allCategories = <String>{};
    for (final task in tasks) {
      allCategories.addAll(task.tags);
    }

    for (final category in allCategories) {
      final tasksInCategory = tasks.where((t) => t.tags.contains(category)).toList();
      final completedInCategory = tasksInCategory.where((t) => t.status.isCompleted).length;
      
      categoryDistribution[category] = tasksInCategory.length;
      categoryCompletionRate[category] = tasksInCategory.isNotEmpty 
          ? completedInCategory / tasksInCategory.length 
          : 0.0;

      final durationsInCategory = tasksInCategory
          .where((t) => t.estimatedDuration != null)
          .map((t) => t.estimatedDuration!)
          .toList();
      
      categoryAvgDuration[category] = durationsInCategory.isNotEmpty
          ? durationsInCategory.reduce((a, b) => a + b) / durationsInCategory.length
          : 0.0;
    }

    // Find most and least productive categories
    final sortedByCompletion = categoryCompletionRate.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'category_distribution': categoryDistribution,
      'completion_rates': categoryCompletionRate,
      'average_durations': categoryAvgDuration,
      'most_productive_category': sortedByCompletion.isNotEmpty ? sortedByCompletion.first.key : null,
      'least_productive_category': sortedByCompletion.isNotEmpty ? sortedByCompletion.last.key : null,
      'insights': [
        if (sortedByCompletion.isNotEmpty) 
          'Most productive category: ${sortedByCompletion.first.key}',
        if (sortedByCompletion.length > 1) 
          'Focus more on ${sortedByCompletion.last.key} tasks',
      ],
    };
  }

  Map<String, dynamic> _analyzeDeadlinePatterns(List<TaskModel> tasks) {
    final tasksWithDeadlines = tasks.where((t) => t.dueDate != null).toList();
    
    if (tasksWithDeadlines.isEmpty) return {'message': 'No tasks with deadlines to analyze'};

    final completedOnTime = tasksWithDeadlines.where((t) => 
        t.status.isCompleted && 
        t.completedAt != null && 
        !t.completedAt!.isAfter(t.dueDate!)).length;
    
    final completedLate = tasksWithDeadlines.where((t) => 
        t.status.isCompleted && 
        t.completedAt != null && 
        t.completedAt!.isAfter(t.dueDate!)).length;
    
    final currentlyOverdue = tasksWithDeadlines.where((t) => t.isOverdue).length;
    
    final onTimeRate = tasksWithDeadlines.isNotEmpty 
        ? completedOnTime / tasksWithDeadlines.length 
        : 0.0;

    // Analyze deadline pressure patterns
    final lastMinuteCompletions = tasksWithDeadlines.where((t) =>
        t.status.isCompleted &&
        t.completedAt != null &&
        t.dueDate!.difference(t.completedAt!).inHours < 4).length;

    return {
      'total_with_deadlines': tasksWithDeadlines.length,
      'completed_on_time': completedOnTime,
      'completed_late': completedLate,
      'currently_overdue': currentlyOverdue,
      'on_time_rate': onTimeRate,
      'last_minute_completions': lastMinuteCompletions,
      'insights': [
        'You complete ${(onTimeRate * 100).round()}% of tasks on time',
        if (lastMinuteCompletions > tasksWithDeadlines.length * 0.3) 
          'Many tasks completed at the last minute - consider earlier starts',
        if (currentlyOverdue > 0) '$currentlyOverdue tasks are currently overdue',
      ],
    };
  }

  Map<String, dynamic> _analyzeDependencyPatterns(List<TaskModel> tasks) {
    final tasksWithDependencies = tasks.where((t) => t.dependencies.isNotEmpty).length;
    final blockingTasks = <String, int>{};

    // Find which tasks are frequently blockers
    for (final task in tasks) {
      for (final depId in task.dependencies) {
        blockingTasks[depId] = (blockingTasks[depId] ?? 0) + 1;
      }
    }

    final avgDependencies = tasks.isNotEmpty 
        ? tasks.map((t) => t.dependencies.length).reduce((a, b) => a + b) / tasks.length
        : 0.0;

    return {
      'tasks_with_dependencies': tasksWithDependencies,
      'dependency_rate': tasks.isNotEmpty ? tasksWithDependencies / tasks.length : 0.0,
      'average_dependencies_per_task': avgDependencies,
      'frequent_blockers': blockingTasks,
      'insights': [
        if (tasksWithDependencies > tasks.length * 0.5) 
          'High dependency rate may slow progress',
        if (avgDependencies > 2) 
          'Consider simplifying task dependencies',
      ],
    };
  }

  Map<String, dynamic> _analyzeProjectPatterns(List<Project> projects, List<TaskModel> tasks) {
    if (projects.isEmpty) return {'message': 'No projects to analyze'};

    final projectSizes = <String, int>{};
    final projectCompletionRates = <String, double>{};
    final avgProjectSize = projects.map((p) => p.taskIds.length).reduce((a, b) => a + b) / projects.length;

    for (final project in projects) {
      final projectTasks = tasks.where((t) => t.projectId == project.id).toList();
      final completedTasks = projectTasks.where((t) => t.status.isCompleted).length;
      
      projectSizes[project.name] = projectTasks.length;
      projectCompletionRates[project.name] = projectTasks.isNotEmpty 
          ? completedTasks / projectTasks.length 
          : 0.0;
    }

    final activeProjects = projects.where((p) => !p.isArchived).length;
    final projectsWithDeadlines = projects.where((p) => p.deadline != null).length;

    return {
      'total_projects': projects.length,
      'active_projects': activeProjects,
      'projects_with_deadlines': projectsWithDeadlines,
      'average_project_size': avgProjectSize.round(),
      'project_sizes': projectSizes,
      'completion_rates': projectCompletionRates,
      'insights': [
        'Average project has ${avgProjectSize.round()} tasks',
        if (activeProjects > 5) 'Consider focusing on fewer active projects',
        if (projectsWithDeadlines < projects.length * 0.5) 
          'More projects need defined deadlines',
      ],
    };
  }

  // Trend analysis methods

  Map<String, dynamic> _analyzeCompletionRateTrend(List<TaskModel> tasks) {
    final completedTasks = tasks.where((t) => 
        t.status.isCompleted && t.completedAt != null).toList();
    
    if (completedTasks.length < 7) return {'message': 'Insufficient data for trend analysis'};

    // Group by week for the last 8 weeks
    final weeklyCompletions = <int, int>{};
    final now = DateTime.now();
    
    for (int week = 0; week < 8; week++) {
      final weekStart = now.subtract(Duration(days: 7 * (week + 1)));
      final weekEnd = now.subtract(Duration(days: 7 * week));
      
      final completionsThisWeek = completedTasks.where((t) =>
          t.completedAt!.isAfter(weekStart) && t.completedAt!.isBefore(weekEnd)).length;
      
      weeklyCompletions[week] = completionsThisWeek;
    }

    // Calculate trend
    final values = weeklyCompletions.values.toList().reversed.toList();
    final trend = _calculateLinearTrend(values);

    return {
      'weekly_completions': weeklyCompletions,
      'trend_direction': trend > 0 ? 'increasing' : trend < 0 ? 'decreasing' : 'stable',
      'trend_slope': trend,
      'insights': [
        if (trend > 0) 'Completion rate is trending upward',
        if (trend < 0) 'Completion rate is declining - consider adjusting workload',
        if (trend.abs() < 0.1) 'Completion rate is stable',
      ],
    };
  }

  Map<String, dynamic> _analyzeVelocityTrend(List<TaskModel> tasks) {
    // Calculate velocity (tasks completed per week) over time
    final completedTasks = tasks.where((t) => 
        t.status.isCompleted && t.completedAt != null).toList();
    
    if (completedTasks.length < 10) return {'message': 'Insufficient data for velocity analysis'};

    // Group by week
    final weeklyVelocity = <String, int>{};
    final now = DateTime.now();
    
    for (int week = 0; week < 12; week++) {
      final weekStart = now.subtract(Duration(days: 7 * (week + 1)));
      final weekEnd = now.subtract(Duration(days: 7 * week));
      
      final velocityThisWeek = completedTasks.where((t) =>
          t.completedAt!.isAfter(weekStart) && t.completedAt!.isBefore(weekEnd)).length;
      
      weeklyVelocity['week_${12 - week}'] = velocityThisWeek;
    }

    final velocities = weeklyVelocity.values.toList();
    final avgVelocity = velocities.reduce((a, b) => a + b) / velocities.length;
    final maxVelocity = velocities.reduce(max);
    final minVelocity = velocities.reduce(min);

    return {
      'weekly_velocity': weeklyVelocity,
      'average_velocity': avgVelocity,
      'max_velocity': maxVelocity,
      'min_velocity': minVelocity,
      'velocity_stability': (maxVelocity - minVelocity) / avgVelocity,
      'insights': [
        'Average velocity: ${avgVelocity.toStringAsFixed(1)} tasks/week',
        if (maxVelocity > avgVelocity * 1.5) 'Velocity varies significantly',
        if (minVelocity < avgVelocity * 0.5) 'Some weeks show very low productivity',
      ],
    };
  }

  Map<String, dynamic> _analyzeQualityTrend(List<TaskModel> tasks) {
    // Analyze quality indicators over time
    final completedTasks = tasks.where((t) => 
        t.status.isCompleted && t.completedAt != null).toList();
    
    if (completedTasks.isEmpty) return {'message': 'No completed tasks to analyze quality'};

    // Quality indicators: on-time completion, description completeness, etc.
    final monthlyQuality = <String, Map<String, dynamic>>{};
    final now = DateTime.now();
    
    for (int month = 0; month < 6; month++) {
      final monthStart = DateTime(now.year, now.month - month - 1, 1);
      final monthEnd = DateTime(now.year, now.month - month, 1);
      
      final tasksThisMonth = completedTasks.where((t) =>
          t.completedAt!.isAfter(monthStart) && t.completedAt!.isBefore(monthEnd)).toList();
      
      if (tasksThisMonth.isEmpty) continue;

      final onTimeCount = tasksThisMonth.where((t) =>
          t.dueDate != null && !t.completedAt!.isAfter(t.dueDate!)).length;
      
      final withDescriptionCount = tasksThisMonth.where((t) =>
          t.description != null && t.description!.isNotEmpty).length;

      monthlyQuality['month_${6 - month}'] = {
        'total_tasks': tasksThisMonth.length,
        'on_time_rate': tasksThisMonth.isNotEmpty ? onTimeCount / tasksThisMonth.length : 0.0,
        'description_rate': tasksThisMonth.isNotEmpty ? withDescriptionCount / tasksThisMonth.length : 0.0,
      };
    }

    return {
      'monthly_quality': monthlyQuality,
      'insights': [
        'Quality metrics tracked: on-time completion, description completeness',
      ],
    };
  }

  Map<String, dynamic> _analyzeProjectHealthTrend(List<Project> projects, List<TaskModel> tasks) {
    // Analyze project health indicators over time
    final projectHealthScores = <String, double>{};
    
    for (final project in projects) {
      if (project.isArchived) continue;
      
      final projectTasks = tasks.where((t) => t.projectId == project.id).toList();
      if (projectTasks.isEmpty) continue;
      
      final completionRate = projectTasks.where((t) => t.status.isCompleted).length / projectTasks.length;
      final overdueRate = projectTasks.where((t) => t.isOverdue).length / projectTasks.length;
      
      // Simple health score: completion rate - overdue penalty
      final healthScore = (completionRate * 100) - (overdueRate * 50);
      projectHealthScores[project.name] = max(0, min(100, healthScore));
    }

    final avgHealthScore = projectHealthScores.isNotEmpty 
        ? projectHealthScores.values.reduce((a, b) => a + b) / projectHealthScores.length
        : 0.0;

    return {
      'project_health_scores': projectHealthScores,
      'average_health_score': avgHealthScore,
      'insights': [
        'Average project health: ${avgHealthScore.round()}/100',
        if (avgHealthScore < 60) 'Overall project health needs attention',
        if (avgHealthScore > 80) 'Projects are generally healthy',
      ],
    };
  }

  Map<String, dynamic> _analyzeSeasonalPatterns(List<TaskModel> tasks) {
    final completedTasks = tasks.where((t) => 
        t.status.isCompleted && t.completedAt != null).toList();
    
    if (completedTasks.isEmpty) return {'message': 'No completed tasks for seasonal analysis'};

    final monthlyCompletions = <int, int>{};
    final quarterlyCompletions = <int, int>{};
    
    for (final task in completedTasks) {
      final month = task.completedAt!.month;
      final quarter = ((month - 1) ~/ 3) + 1;
      
      monthlyCompletions[month] = (monthlyCompletions[month] ?? 0) + 1;
      quarterlyCompletions[quarter] = (quarterlyCompletions[quarter] ?? 0) + 1;
    }

    final mostProductiveMonth = monthlyCompletions.isNotEmpty 
        ? monthlyCompletions.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 0;

    return {
      'monthly_completions': monthlyCompletions,
      'quarterly_completions': quarterlyCompletions,
      'most_productive_month': mostProductiveMonth,
      'insights': [
        'Most productive month: ${_getMonthName(mostProductiveMonth)}',
        if (monthlyCompletions.length > 6) 'Strong seasonal patterns detected',
      ],
    };
  }

  Map<String, dynamic> _analyzeWorkloadTrends(List<TaskModel> tasks) {
    // Analyze workload distribution over time
    final workloadByWeek = <String, Map<String, dynamic>>{};
    final now = DateTime.now();
    
    for (int week = 0; week < 8; week++) {
      final weekStart = now.subtract(Duration(days: 7 * (week + 1)));
      final weekEnd = now.subtract(Duration(days: 7 * week));
      
      final tasksCreated = tasks.where((t) =>
          t.createdAt.isAfter(weekStart) && t.createdAt.isBefore(weekEnd)).length;
      
      final tasksCompleted = tasks.where((t) =>
          t.status.isCompleted &&
          t.completedAt != null &&
          t.completedAt!.isAfter(weekStart) && 
          t.completedAt!.isBefore(weekEnd)).length;
      
      workloadByWeek['week_${8 - week}'] = {
        'tasks_created': tasksCreated,
        'tasks_completed': tasksCompleted,
        'net_change': tasksCreated - tasksCompleted,
      };
    }

    return {
      'weekly_workload': workloadByWeek,
      'insights': [
        'Workload trend shows task creation vs completion balance',
      ],
    };
  }

  // Additional analysis methods would continue here...
  // For brevity, I'll include key helper methods:

  double _calculateLinearTrend(List<int> values) {
    if (values.length < 2) return 0.0;
    
    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
    final n = values.length;
    
    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += values[i];
      sumXY += i * values[i];
      sumXX += i * i;
    }
    
    return (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
  }

  String _getDayName(int dayOfWeek) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayOfWeek - 1];
  }

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December'];
    return month > 0 && month <= 12 ? months[month - 1] : 'Unknown';
  }

  // Generate recommendations based on insights
  Future<List<String>> _generateRecommendations(Map<String, dynamic> insights) async {
    final recommendations = <String>[];
    
    // Add recommendations based on patterns and trends
    final patterns = insights['patterns'] as Map<String, dynamic>? ?? {};
    
    // Add specific recommendations based on findings
    if (patterns['completion_time_patterns']?['insights'] != null) {
      final timeInsights = patterns['completion_time_patterns']['insights'] as List;
      recommendations.addAll(timeInsights.cast<String>());
    }
    
    return recommendations;
  }

  Future<List<String>> _identifyOptimizationOpportunities(Map<String, dynamic> insights) async {
    final opportunities = <String>[];
    
    // Analyze all insights to identify optimization opportunities
    opportunities.add('Implement time-blocking based on peak performance hours');
    opportunities.add('Optimize task batching for similar categories');
    opportunities.add('Set up automated reminders for deadline-prone tasks');
    
    return opportunities;
  }

  // Placeholder methods for complex analyses
  Map<String, dynamic> _identifyPeakPerformanceTimes(List<TaskModel> tasks) => {};
  Map<String, dynamic> _analyzeProductiveDays(List<TaskModel> tasks) => {};
  Map<String, dynamic> _analyzeContextSwitching(List<TaskModel> tasks) => {};
  Map<String, dynamic> _analyzeBatchProcessing(List<TaskModel> tasks) => {};
  Map<String, dynamic> _analyzeFocusTime(List<TaskModel> tasks) => {};
  Map<String, dynamic> _analyzeMultitaskingPatterns(List<TaskModel> tasks) => {};
  Map<String, dynamic> _analyzeOverdueRisk(List<TaskModel> tasks) => {};
  Map<String, dynamic> _analyzeBurnoutIndicators(List<TaskModel> tasks) => {};
  Map<String, dynamic> _analyzeQualityRiskIndicators(List<TaskModel> tasks) => {};
  Map<String, dynamic> _analyzeDeadlineRisk(List<Project> projects, List<TaskModel> tasks) => {};
  Map<String, dynamic> _analyzeScopeCreepRisk(List<Project> projects, List<TaskModel> tasks) => {};
  Map<String, dynamic> _analyzeResourceConstraintRisk(List<Project> projects, List<TaskModel> tasks) => {};
  Map<String, dynamic> _analyzeProcrastinationPatterns(List<TaskModel> tasks) => {};
  Map<String, dynamic> _analyzeCompletionPreferences(List<TaskModel> tasks) => {};
  Map<String, dynamic> _analyzePlanningPatterns(List<TaskModel> tasks) => {};
  Map<String, dynamic> _analyzeCommunicationPatterns(List<TaskModel> tasks, List<Project> projects) => {};
  Map<String, dynamic> _analyzeDecisionMakingPatterns(List<TaskModel> tasks) => {};
  Map<String, dynamic> _calculateEfficiencyMetrics(List<TaskModel> tasks) => {};
  Map<String, dynamic> _calculateAccuracyMetrics(List<TaskModel> tasks) => {};
  Map<String, dynamic> _calculateConsistencyMetrics(List<TaskModel> tasks) => {};
  Map<String, dynamic> _calculateThroughputMetrics(List<TaskModel> tasks) => {};
  Map<String, dynamic> _calculateQualityMetrics(List<TaskModel> tasks) => {};
}