import 'dart:async';
import 'dart:math';
import '../../domain/entities/project.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/project_health.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../analytics/analytics_service.dart';

/// Service for automated project health monitoring and issue detection
class ProjectHealthMonitoringService {
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;

  ProjectHealthMonitoringService({
    required TaskRepository taskRepository,
    required ProjectRepository projectRepository,
  })  : _taskRepository = taskRepository,
        _projectRepository = projectRepository;

  /// Analyzes and generates health status for a specific project
  Future<ProjectHealth> analyzeProjectHealth(String projectId) async {
    final project = await _projectRepository.getProjectById(projectId);
    if (project == null) {
      throw ArgumentError('Project not found: $projectId');
    }

    final tasks = await _taskRepository.getTasksByProject(projectId);
    final issues = <ProjectHealthIssue>[];
    
    // Run all health checks
    issues.addAll(await _checkOverdueTasks(project, tasks));
    issues.addAll(await _checkCompletionRate(project, tasks));
    issues.addAll(await _checkProjectStagnation(project, tasks));
    issues.addAll(await _checkBlockedTasks(project, tasks));
    issues.addAll(await _checkResourceBottlenecks(project, tasks));
    issues.addAll(await _checkMissedDeadlines(project, tasks));
    issues.addAll(await _checkWorkloadBalance(project, tasks));
    issues.addAll(await _checkCommunicationGaps(project, tasks));

    // Calculate health score and level
    final healthScore = _calculateHealthScore(project, tasks, issues);
    final healthLevel = _determineHealthLevel(healthScore, issues);
    
    // Generate KPIs
    final kpis = await _generateHealthKPIs(project, tasks);
    
    // Generate trends (simplified - in production would pull from historical data)
    final trends = await _generateHealthTrends(project, tasks);
    
    // Generate insights
    final insights = _generateHealthInsights(project, tasks, issues, healthScore);

    return ProjectHealth(
      projectId: projectId,
      level: healthLevel,
      healthScore: healthScore,
      issues: issues,
      kpis: kpis,
      trends: trends,
      calculatedAt: DateTime.now(),
      insights: insights,
    );
  }

  /// Checks for overdue tasks and generates related health issues
  Future<List<ProjectHealthIssue>> _checkOverdueTasks(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final issues = <ProjectHealthIssue>[];
    final overdueTasks = tasks.where((t) => t.isOverdue && !t.status.isCompleted).toList();
    
    if (overdueTasks.isEmpty) return issues;

    // Calculate severity based on how overdue and how many
    final now = DateTime.now();
    final maxOverdueDays = overdueTasks
        .map((t) => now.difference(t.dueDate!).inDays)
        .reduce(max);
    
    final severity = min(3 + overdueTasks.length + (maxOverdueDays ~/ 7), 10);
    
    issues.add(ProjectHealthIssue(
      id: 'overdue_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: HealthIssueType.overdueTasks,
      severity: severity,
      title: 'Overdue Tasks Detected',
      description: '${overdueTasks.length} tasks are overdue. The longest overdue task is $maxOverdueDays days past its due date.',
      suggestedActions: const [
        'Prioritize overdue tasks and complete them immediately',
        'Review and adjust remaining task deadlines',
        'Identify root causes for delays',
        'Consider redistributing workload or extending project timeline',
        'Implement daily stand-ups to prevent future overdue tasks',
      ],
      detectedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      affectedTaskIds: overdueTasks.map((t) => t.id).toList(),
      metadata: {
        'overdue_count': overdueTasks.length,
        'max_overdue_days': maxOverdueDays,
        'average_overdue_days': overdueTasks
            .map((t) => now.difference(t.dueDate!).inDays)
            .reduce((a, b) => a + b) / overdueTasks.length,
      },
    ));

    return issues;
  }

  /// Checks completion rate and generates related health issues
  Future<List<ProjectHealthIssue>> _checkCompletionRate(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final issues = <ProjectHealthIssue>[];
    
    if (tasks.isEmpty) return issues;

    final completedTasks = tasks.where((t) => t.status.isCompleted).length;
    final completionRate = completedTasks / tasks.length;
    
    // Check if completion rate is too low for project timeline
    if (project.deadline != null) {
      final now = DateTime.now();
      final totalDuration = project.deadline!.difference(project.createdAt);
      final elapsedDuration = now.difference(project.createdAt);
      final expectedCompletionRate = elapsedDuration.inMilliseconds / totalDuration.inMilliseconds;
      
      if (completionRate < expectedCompletionRate * 0.7 && expectedCompletionRate > 0.1) {
        final severity = min(10, ((expectedCompletionRate - completionRate) * 10).round() + 3);
        
        issues.add(ProjectHealthIssue(
          id: 'completion_rate_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
          type: HealthIssueType.lowCompletionRate,
          severity: severity,
          title: 'Low Completion Rate',
          description: 'Project completion rate (${(completionRate * 100).round()}%) is below expected for timeline (${(expectedCompletionRate * 100).round()}% expected).',
          suggestedActions: const [
            'Accelerate task completion by removing blockers',
            'Consider reducing project scope or extending deadline',
            'Add more resources to critical path tasks',
            'Improve task estimation and planning accuracy',
            'Implement daily progress tracking and accountability',
          ],
          detectedAt: DateTime.now(),
          updatedAt: DateTime.now(),
          metadata: {
            'actual_completion_rate': completionRate,
            'expected_completion_rate': expectedCompletionRate,
            'completed_tasks': completedTasks,
            'total_tasks': tasks.length,
            'days_until_deadline': project.deadline!.difference(now).inDays,
          },
        ));
      }
    } else if (completionRate < 0.3 && tasks.length > 5) {
      // General low completion rate warning for projects without deadlines
      issues.add(ProjectHealthIssue(
        id: 'low_progress_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        type: HealthIssueType.lowCompletionRate,
        severity: 4,
        title: 'Low Project Progress',
        description: 'Only ${(completionRate * 100).round()}% of tasks completed. Project may need attention.',
        suggestedActions: const [
          'Review project goals and priorities',
          'Identify and address blockers',
          'Break down large tasks into smaller, manageable pieces',
          'Set intermediate milestones to track progress',
        ],
        detectedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {
          'completion_rate': completionRate,
          'completed_tasks': completedTasks,
          'total_tasks': tasks.length,
        },
      ));
    }

    return issues;
  }

  /// Checks for project stagnation
  Future<List<ProjectHealthIssue>> _checkProjectStagnation(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final issues = <ProjectHealthIssue>[];
    
    if (tasks.isEmpty) return issues;

    final now = DateTime.now();
    final recentActivity = tasks.where((t) => 
        t.updatedAt?.isAfter(now.subtract(const Duration(days: 7))) == true).length;
    
    if (recentActivity == 0 && tasks.length > 2) {
      // No activity in the past week
      final daysSinceLastActivity = tasks
          .where((t) => t.updatedAt != null)
          .map((t) => now.difference(t.updatedAt!).inDays)
          .fold<int>(0, (prev, element) => prev == 0 ? element : min(prev, element));
      
      final severity = min(10, 2 + (daysSinceLastActivity ~/ 7));
      
      issues.add(ProjectHealthIssue(
        id: 'stagnation_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        type: HealthIssueType.stagnantProject,
        severity: severity,
        title: 'Project Stagnation Detected',
        description: 'No task activity in the past 7 days. Project appears stagnant.',
        suggestedActions: const [
          'Review project status with team members',
          'Identify blockers preventing progress',
          'Re-evaluate project priorities and relevance',
          'Set up regular check-ins to prevent future stagnation',
          'Consider pausing or canceling if project is no longer needed',
        ],
        detectedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {
          'days_since_last_activity': daysSinceLastActivity,
          'total_tasks': tasks.length,
          'recent_activity_count': recentActivity,
        },
      ));
    } else if (recentActivity < tasks.length * 0.1 && tasks.length > 10) {
      // Very low activity relative to project size
      issues.add(ProjectHealthIssue(
        id: 'low_activity_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        type: HealthIssueType.stagnantProject,
        severity: 5,
        title: 'Low Project Activity',
        description: 'Only $recentActivity of ${tasks.length} tasks have been active recently.',
        suggestedActions: const [
          'Review inactive tasks and prioritize them',
          'Check if team members need support or resources',
          'Consider redistributing tasks to more active contributors',
          'Set up accountability measures for task progress',
        ],
        detectedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {
          'recent_activity_count': recentActivity,
          'total_tasks': tasks.length,
          'activity_rate': recentActivity / tasks.length,
        },
      ));
    }

    return issues;
  }

  /// Checks for blocked tasks
  Future<List<ProjectHealthIssue>> _checkBlockedTasks(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final issues = <ProjectHealthIssue>[];
    
    final blockedTasks = tasks.where((t) => 
        t.dependencies.isNotEmpty && 
        !t.status.isCompleted).toList();
    
    if (blockedTasks.isEmpty) return issues;

    // Check if blocking tasks are completed
    final actuallyBlockedTasks = <TaskModel>[];
    for (final task in blockedTasks) {
      for (final depId in task.dependencies) {
        final blockingTask = tasks.firstWhere(
          (t) => t.id == depId,
          orElse: () => throw StateError('Dependency not found'),
        );
        if (!blockingTask.status.isCompleted) {
          actuallyBlockedTasks.add(task);
          break;
        }
      }
    }

    if (actuallyBlockedTasks.isNotEmpty) {
      final severity = min(10, 3 + actuallyBlockedTasks.length);
      
      issues.add(ProjectHealthIssue(
        id: 'blocked_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        type: HealthIssueType.blockedTasks,
        severity: severity,
        title: 'Tasks Blocked by Dependencies',
        description: '${actuallyBlockedTasks.length} tasks are blocked waiting for dependencies to complete.',
        suggestedActions: const [
          'Prioritize completion of blocking tasks',
          'Review dependencies - some may no longer be necessary',
          'Consider parallel work streams where possible',
          'Communicate with task owners about blocking issues',
          'Create workarounds for non-critical dependencies',
        ],
        detectedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        affectedTaskIds: actuallyBlockedTasks.map((t) => t.id).toList(),
        metadata: {
          'blocked_tasks_count': actuallyBlockedTasks.length,
          'total_dependent_tasks': blockedTasks.length,
        },
      ));
    }

    return issues;
  }

  /// Checks for resource bottlenecks
  Future<List<ProjectHealthIssue>> _checkResourceBottlenecks(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final issues = <ProjectHealthIssue>[];
    
    // Check for too many tasks in progress simultaneously
    final inProgressTasks = tasks.where((t) => t.status.isInProgress).toList();
    
    if (inProgressTasks.length > 5) {
      issues.add(ProjectHealthIssue(
        id: 'bottleneck_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        type: HealthIssueType.resourceBottleneck,
        severity: min(10, 2 + inProgressTasks.length),
        title: 'Too Many Tasks in Progress',
        description: '${inProgressTasks.length} tasks are in progress simultaneously, which may cause focus fragmentation.',
        suggestedActions: const [
          'Implement work-in-progress (WIP) limits',
          'Complete existing tasks before starting new ones',
          'Prioritize tasks based on impact and urgency',
          'Consider team capacity when assigning new tasks',
          'Use time-boxing to maintain focus',
        ],
        detectedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        affectedTaskIds: inProgressTasks.map((t) => t.id).toList(),
        metadata: {
          'in_progress_count': inProgressTasks.length,
          'recommended_wip_limit': 3,
        },
      ));
    }

    // Check for uneven workload distribution based on estimated durations
    final tasksWithDuration = tasks.where((t) => 
        t.estimatedDuration != null && 
        !t.status.isCompleted).toList();
    
    if (tasksWithDuration.length > 3 && project.deadline != null) {
      final totalRemainingHours = tasksWithDuration
          .map((t) => t.estimatedDuration!)
          .reduce((a, b) => a + b) / 60;
      
      final daysUntilDeadline = project.deadline!.difference(DateTime.now()).inDays;
      
      if (daysUntilDeadline > 0) {
        final requiredHoursPerDay = totalRemainingHours / daysUntilDeadline;
        
        if (requiredHoursPerDay > 10) {
          issues.add(ProjectHealthIssue(
            id: 'workload_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
            type: HealthIssueType.resourceBottleneck,
            severity: min(10, (requiredHoursPerDay / 2).round()),
            title: 'Excessive Workload for Timeline',
            description: 'Current workload requires ${requiredHoursPerDay.toStringAsFixed(1)} hours/day to meet deadline.',
            suggestedActions: const [
              'Negotiate deadline extension',
              'Add additional team members or contractors',
              'Reduce project scope by deferring non-critical tasks',
              'Optimize task efficiency and eliminate waste',
              'Consider outsourcing some tasks',
            ],
            detectedAt: DateTime.now(),
            updatedAt: DateTime.now(),
            affectedTaskIds: tasksWithDuration.map((t) => t.id).toList(),
            metadata: {
              'required_hours_per_day': requiredHoursPerDay,
              'total_remaining_hours': totalRemainingHours,
              'days_until_deadline': daysUntilDeadline,
              'sustainable_hours_per_day': 8,
            },
          ));
        }
      }
    }

    return issues;
  }

  /// Checks for missed deadlines pattern
  Future<List<ProjectHealthIssue>> _checkMissedDeadlines(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final issues = <ProjectHealthIssue>[];
    
    final completedTasks = tasks.where((t) => 
        t.status.isCompleted && 
        t.dueDate != null && 
        t.completedAt != null).toList();
    
    if (completedTasks.length < 3) return issues;

    final missedDeadlineTasks = completedTasks.where((t) =>
        t.completedAt!.isAfter(t.dueDate!)).toList();
    
    final missedDeadlineRate = missedDeadlineTasks.length / completedTasks.length;
    
    if (missedDeadlineRate > 0.3) { // More than 30% of tasks missed deadlines
      final severity = min(10, (missedDeadlineRate * 10).round() + 2);
      
      issues.add(ProjectHealthIssue(
        id: 'deadline_pattern_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        type: HealthIssueType.missedDeadlines,
        severity: severity,
        title: 'Pattern of Missed Deadlines',
        description: '${(missedDeadlineRate * 100).round()}% of completed tasks missed their deadlines.',
        suggestedActions: const [
          'Review and improve task estimation practices',
          'Add buffer time to task estimates',
          'Identify common causes of delays',
          'Implement early warning systems for at-risk tasks',
          'Improve task planning and time management',
        ],
        detectedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        affectedTaskIds: missedDeadlineTasks.map((t) => t.id).toList(),
        metadata: {
          'missed_deadline_count': missedDeadlineTasks.length,
          'completed_tasks_count': completedTasks.length,
          'missed_deadline_rate': missedDeadlineRate,
          'average_delay_days': _calculateAverageDelay(missedDeadlineTasks),
        },
      ));
    }

    return issues;
  }

  /// Checks for unbalanced workload
  Future<List<ProjectHealthIssue>> _checkWorkloadBalance(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final issues = <ProjectHealthIssue>[];
    
    if (tasks.length < 5) return issues;

    // Check priority distribution
    final highPriorityTasks = tasks.where((t) => t.priority.isHighPriority).length;
    final highPriorityRate = highPriorityTasks / tasks.length;
    
    if (highPriorityRate > 0.7) {
      issues.add(ProjectHealthIssue(
        id: 'priority_imbalance_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        type: HealthIssueType.unbalancedWorkload,
        severity: 6,
        title: 'Too Many High-Priority Tasks',
        description: '${(highPriorityRate * 100).round()}% of tasks are high priority, which may dilute focus.',
        suggestedActions: const [
          'Review task priorities and downgrade non-critical items',
          'Use relative prioritization (rank order) instead of absolute priorities',
          'Focus on the top 3 most critical tasks first',
          'Defer lower-impact high-priority tasks to later phases',
        ],
        detectedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {
          'high_priority_count': highPriorityTasks,
          'total_tasks': tasks.length,
          'high_priority_rate': highPriorityRate,
          'recommended_max_rate': 0.3,
        },
      ));
    }

    // Check task size distribution
    final tasksWithDuration = tasks.where((t) => t.estimatedDuration != null).toList();
    if (tasksWithDuration.length > 3) {
      final durations = tasksWithDuration.map((t) => t.estimatedDuration!).toList();
      final avgDuration = durations.reduce((a, b) => a + b) / durations.length;
      final maxDuration = durations.reduce(max);
      
      if (maxDuration > avgDuration * 5) {
        final largeTasks = tasksWithDuration.where((t) => 
            t.estimatedDuration! > avgDuration * 3).toList();
        
        issues.add(ProjectHealthIssue(
          id: 'task_size_imbalance_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
          type: HealthIssueType.unbalancedWorkload,
          severity: 5,
          title: 'Uneven Task Size Distribution',
          description: 'Some tasks are significantly larger than others, which may affect planning accuracy.',
          suggestedActions: const [
            'Break down large tasks into smaller, manageable pieces',
            'Aim for tasks that take 1-4 hours to complete',
            'Create subtasks for complex work items',
            'Use story points or relative sizing for better estimation',
          ],
          detectedAt: DateTime.now(),
          updatedAt: DateTime.now(),
          affectedTaskIds: largeTasks.map((t) => t.id).toList(),
          metadata: {
            'large_tasks_count': largeTasks.length,
            'average_duration': avgDuration,
            'max_duration': maxDuration,
            'size_variance': maxDuration / avgDuration,
          },
        ));
      }
    }

    return issues;
  }

  /// Checks for communication gaps
  Future<List<ProjectHealthIssue>> _checkCommunicationGaps(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final issues = <ProjectHealthIssue>[];
    
    // Skip communication checks for empty projects
    if (tasks.isEmpty) return issues;
    
    // Check for tasks without descriptions
    final tasksWithoutDescription = tasks.where((t) => 
        t.description == null || t.description!.trim().isEmpty).toList();
    
    if (tasksWithoutDescription.length > tasks.length * 0.4) {
      issues.add(ProjectHealthIssue(
        id: 'missing_descriptions_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        type: HealthIssueType.communicationGaps,
        severity: 4,
        title: 'Missing Task Descriptions',
        description: '${tasksWithoutDescription.length} tasks lack proper descriptions, which may cause confusion.',
        suggestedActions: const [
          'Add clear descriptions to all tasks',
          'Include acceptance criteria for complex tasks',
          'Specify deliverables and expected outcomes',
          'Create task templates for consistent information',
        ],
        detectedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        affectedTaskIds: tasksWithoutDescription.map((t) => t.id).toList(),
        metadata: {
          'tasks_without_description': tasksWithoutDescription.length,
          'total_tasks': tasks.length,
          'percentage': (tasksWithoutDescription.length / tasks.length) * 100,
        },
      ));
    }

    // Check for project without description
    if (project.description == null || project.description!.trim().isEmpty) {
      issues.add(ProjectHealthIssue(
        id: 'project_description_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        type: HealthIssueType.communicationGaps,
        severity: 3,
        title: 'Project Lacks Description',
        description: 'Project has no description, which may cause confusion about goals and scope.',
        suggestedActions: const [
          'Add a clear project description with goals and objectives',
          'Define project scope and success criteria',
          'Include stakeholder information and contacts',
          'Document key assumptions and constraints',
        ],
        detectedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: const {
          'project_has_description': false,
        },
      ));
    }

    return issues;
  }

  /// Calculates overall health score (0-100)
  double _calculateHealthScore(
    Project project,
    List<TaskModel> tasks,
    List<ProjectHealthIssue> issues,
  ) {
    if (tasks.isEmpty) return 50.0; // Neutral score for empty projects

    double score = 100.0;

    // Deduct points for each issue based on severity
    for (final issue in issues) {
      final deduction = issue.severity * 2.0; // Max 20 points per critical issue
      score -= deduction;
    }

    // Bonus for good metrics
    final completionRate = tasks.where((t) => t.status.isCompleted).length / tasks.length;
    score += completionRate * 10; // Up to 10 bonus points for high completion

    final onTimeRate = _calculateOnTimeCompletionRate(tasks);
    score += onTimeRate * 5; // Up to 5 bonus points for on-time completion

    // Ensure score is between 0 and 100
    return max(0.0, min(100.0, score));
  }

  /// Determines health level based on score and critical issues
  ProjectHealthLevel _determineHealthLevel(double score, List<ProjectHealthIssue> issues) {
    final criticalIssues = issues.where((i) => i.severity >= 8).length;
    final highSeverityIssues = issues.where((i) => i.severity >= 6).length;

    // Special case: if no issues, consider it good even with neutral score
    if (issues.isEmpty) {
      return ProjectHealthLevel.good;
    }

    if (criticalIssues > 0 || score < 30) {
      return ProjectHealthLevel.critical;
    } else if (highSeverityIssues > 1 || score < 60) {
      return ProjectHealthLevel.warning;
    } else if (score < 80) {
      return ProjectHealthLevel.good;
    } else {
      return ProjectHealthLevel.excellent;
    }
  }

  /// Generates health KPIs
  Future<Map<String, double>> _generateHealthKPIs(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final kpis = <String, double>{};

    if (tasks.isNotEmpty) {
      kpis['completion_rate'] = tasks.where((t) => t.status.isCompleted).length / tasks.length;
      kpis['overdue_rate'] = tasks.where((t) => t.isOverdue).length / tasks.length;
      kpis['on_time_completion_rate'] = _calculateOnTimeCompletionRate(tasks);
      
      final inProgressTasks = tasks.where((t) => t.status.isInProgress).length;
      kpis['work_in_progress'] = inProgressTasks.toDouble();
      
      final avgTaskAge = _calculateAverageTaskAge(tasks);
      kpis['average_task_age_days'] = avgTaskAge;
      
      if (project.deadline != null) {
        final daysUntilDeadline = project.deadline!.difference(DateTime.now()).inDays;
        kpis['days_until_deadline'] = daysUntilDeadline.toDouble();
        
        final totalDuration = project.deadline!.difference(project.createdAt).inDays;
        final elapsedDuration = DateTime.now().difference(project.createdAt).inDays;
        kpis['project_progress_vs_time'] = totalDuration > 0 ? elapsedDuration / totalDuration : 0;
      }
      
      kpis['task_velocity'] = _calculateTaskVelocity(tasks);
    }

    return kpis;
  }

  /// Generates health trends (simplified version)
  Future<List<HealthTrend>> _generateHealthTrends(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final trends = <HealthTrend>[];
    final now = DateTime.now();

    // Generate trends for the last 30 days (simplified)
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final tasksAtDate = tasks.where((t) => t.createdAt.isBefore(date.add(const Duration(days: 1)))).toList();
      final completedAtDate = tasksAtDate.where((t) => 
          t.status.isCompleted && 
          t.completedAt != null && 
          t.completedAt!.isBefore(date.add(const Duration(days: 1)))).length;
      
      final completionRate = tasksAtDate.isNotEmpty ? completedAtDate / tasksAtDate.length : 0.0;
      final issuesCount = tasksAtDate.where((t) => t.isOverdue).length;
      
      trends.add(HealthTrend(
        date: date,
        healthScore: min(100.0, completionRate * 100 - issuesCount * 5),
        issuesCount: issuesCount,
        completionRate: completionRate,
        metrics: {
          'tasks_created': tasksAtDate.length.toDouble(),
          'tasks_completed': completedAtDate.toDouble(),
        },
      ));
    }

    return trends;
  }

  /// Generates health insights
  List<String> _generateHealthInsights(
    Project project,
    List<TaskModel> tasks,
    List<ProjectHealthIssue> issues,
    double healthScore,
  ) {
    final insights = <String>[];

    if (healthScore >= 80) {
      insights.add('Project is in excellent health with minimal issues');
    } else if (healthScore >= 60) {
      insights.add('Project health is good but has some areas for improvement');
    } else if (healthScore >= 40) {
      insights.add('Project requires attention to address several health issues');
    } else {
      insights.add('Project health is critical and needs immediate intervention');
    }

    final criticalIssues = issues.where((i) => i.severity >= 8).length;
    if (criticalIssues > 0) {
      insights.add('$criticalIssues critical issues require immediate attention');
    }

    if (tasks.isNotEmpty) {
      final completionRate = tasks.where((t) => t.status.isCompleted).length / tasks.length;
      if (completionRate > 0.8) {
        insights.add('Strong completion rate indicates good task management');
      } else if (completionRate < 0.3) {
        insights.add('Low completion rate suggests project may be struggling');
      }

      final overdueTasks = tasks.where((t) => t.isOverdue).length;
      if (overdueTasks > 0) {
        insights.add('$overdueTasks overdue tasks need immediate attention');
      }
    }

    if (project.deadline != null) {
      final daysUntilDeadline = project.deadline!.difference(DateTime.now()).inDays;
      if (daysUntilDeadline < 7 && daysUntilDeadline > 0) {
        insights.add('Project deadline is approaching in $daysUntilDeadline days');
      } else if (daysUntilDeadline < 0) {
        insights.add('Project deadline has passed - review timeline and scope');
      }
    }

    return insights;
  }

  // Helper methods

  double _calculateOnTimeCompletionRate(List<TaskModel> tasks) {
    final completedWithDueDates = tasks.where((t) => 
        t.status.isCompleted && 
        t.dueDate != null && 
        t.completedAt != null).toList();
    
    if (completedWithDueDates.isEmpty) return 0.0;

    final onTimeCompletions = completedWithDueDates.where((t) =>
        t.completedAt!.isBefore(t.dueDate!) || 
        t.completedAt!.isAtSameMomentAs(t.dueDate!)).length;
    
    return onTimeCompletions / completedWithDueDates.length;
  }

  double _calculateAverageTaskAge(List<TaskModel> tasks) {
    if (tasks.isEmpty) return 0.0;

    final now = DateTime.now();
    final totalAgeDays = tasks
        .map((t) => now.difference(t.createdAt).inDays)
        .reduce((a, b) => a + b);
    
    return totalAgeDays / tasks.length;
  }

  double _calculateTaskVelocity(List<TaskModel> tasks) {
    final recentCompletions = tasks.where((t) =>
        t.status.isCompleted &&
        t.completedAt != null &&
        t.completedAt!.isAfter(DateTime.now().subtract(const Duration(days: 7)))
    ).length;
    
    return recentCompletions.toDouble(); // Tasks completed per week
  }

  double _calculateAverageDelay(List<TaskModel> missedDeadlineTasks) {
    if (missedDeadlineTasks.isEmpty) return 0.0;

    final totalDelayDays = missedDeadlineTasks
        .map((t) => t.completedAt!.difference(t.dueDate!).inDays)
        .reduce((a, b) => a + b);
    
    return totalDelayDays / missedDeadlineTasks.length;
  }
}