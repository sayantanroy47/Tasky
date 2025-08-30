import 'dart:async';
import 'dart:math';
import '../../domain/entities/project.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/project_repository.dart';

/// Service for AI-powered project analysis and intelligent suggestions
class AIProjectAnalysisService {
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;

  AIProjectAnalysisService({
    required TaskRepository taskRepository,
    required ProjectRepository projectRepository,
  })  : _taskRepository = taskRepository,
        _projectRepository = projectRepository;

  /// Analyzes a project and generates AI-powered suggestions
  Future<ProjectAISuggestions> analyzeProject(String projectId) async {
    final project = await _projectRepository.getProjectById(projectId);
    if (project == null) {
      throw ArgumentError('Project not found: $projectId');
    }

    final tasks = await _taskRepository.getTasksByProject(projectId);
    final suggestions = <AISuggestion>[];

    // Generate different types of suggestions
    suggestions.addAll(await _generateTaskPrioritizationSuggestions(project, tasks));
    suggestions.addAll(await _generateScheduleOptimizationSuggestions(project, tasks));
    suggestions.addAll(await _generateBottleneckSuggestions(project, tasks));
    suggestions.addAll(await _generateResourceAllocationSuggestions(project, tasks));
    suggestions.addAll(await _generateDeadlineAdjustmentSuggestions(project, tasks));
    suggestions.addAll(await _generateWorkflowImprovementSuggestions(project, tasks));
    suggestions.addAll(await _generateRiskMitigationSuggestions(project, tasks));
    suggestions.addAll(await _generatePerformanceOptimizationSuggestions(project, tasks));

    // Calculate overall confidence based on data quality and quantity
    final overallConfidence = _calculateOverallConfidence(tasks, suggestions);
    
    // Generate key insights
    final keyInsights = await _generateKeyInsights(project, tasks, suggestions);

    return ProjectAISuggestions(
      projectId: projectId,
      suggestions: suggestions,
      lastUpdated: DateTime.now(),
      overallConfidence: overallConfidence,
      keyInsights: keyInsights,
    );
  }

  /// Generates task prioritization suggestions
  Future<List<AISuggestion>> _generateTaskPrioritizationSuggestions(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final suggestions = <AISuggestion>[];
    
    // Analyze task priorities and suggest reordering
    final highPriorityTasks = tasks.where((t) => t.priority.isHighPriority).toList();
    final overdueTasks = tasks.where((t) => t.isOverdue).toList();
    
    if (overdueTasks.isNotEmpty && highPriorityTasks.length > overdueTasks.length) {
      suggestions.add(AISuggestion(
        id: 'priority_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        projectId: project.id,
        type: AISuggestionType.taskPrioritization,
        priority: SuggestionPriority.high,
        category: SuggestionCategory.productivity,
        title: 'Reprioritize Overdue Tasks',
        description: 'You have ${overdueTasks.length} overdue tasks that should be prioritized. Consider elevating their priority to ensure they get completed.',
        recommendations: const [
          'Review all overdue tasks and increase their priority',
          'Consider breaking down complex overdue tasks into smaller subtasks',
          'Set specific time blocks for completing overdue items',
        ],
        expectedImpact: 'Improved task completion rate and reduced project delays',
        confidence: 85.0,
        generatedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        relatedTaskIds: overdueTasks.map((t) => t.id).toList(),
        supportingData: {
          'overdue_count': overdueTasks.length,
          'high_priority_count': highPriorityTasks.length,
          'completion_rate': _calculateCompletionRate(tasks),
        },
      ));
    }

    // Analyze task dependencies for priority suggestions
    final blockedTasks = tasks.where((t) => t.dependencies.isNotEmpty).toList();
    if (blockedTasks.isNotEmpty) {
      suggestions.add(AISuggestion(
        id: 'dependency_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        projectId: project.id,
        type: AISuggestionType.taskPrioritization,
        priority: SuggestionPriority.medium,
        category: SuggestionCategory.planning,
        title: 'Optimize Task Dependencies',
        description: 'Several tasks have dependencies that might be blocking progress. Consider prioritizing prerequisite tasks.',
        recommendations: const [
          'Review task dependencies and prioritize blocker tasks',
          'Consider parallel work streams where possible',
          'Create a dependency map to visualize critical paths',
        ],
        expectedImpact: 'Reduced bottlenecks and improved project flow',
        confidence: 75.0,
        generatedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        relatedTaskIds: blockedTasks.map((t) => t.id).toList(),
        supportingData: {
          'dependent_tasks_count': blockedTasks.length,
          'total_tasks': tasks.length,
        },
      ));
    }

    return suggestions;
  }

  /// Generates schedule optimization suggestions
  Future<List<AISuggestion>> _generateScheduleOptimizationSuggestions(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final suggestions = <AISuggestion>[];
    
    // Analyze task distribution over time
    final tasksWithDueDates = tasks.where((t) => t.dueDate != null).toList();
    if (tasksWithDueDates.isEmpty) return suggestions;

    final now = DateTime.now();
    final upcomingTasks = tasksWithDueDates
        .where((t) => t.dueDate!.isAfter(now) && 
                     t.dueDate!.isBefore(now.add(const Duration(days: 7))))
        .toList();

    if (upcomingTasks.length > 5) {
      suggestions.add(AISuggestion(
        id: 'schedule_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        projectId: project.id,
        type: AISuggestionType.scheduleOptimization,
        priority: SuggestionPriority.medium,
        category: SuggestionCategory.planning,
        title: 'Heavy Workload Next Week',
        description: 'You have ${upcomingTasks.length} tasks due in the next 7 days. Consider redistributing some deadlines.',
        recommendations: const [
          'Review task deadlines and negotiate extensions where possible',
          'Delegate tasks that can be handled by team members',
          'Break down large tasks to spread work more evenly',
          'Consider working on some tasks early to reduce the upcoming load',
        ],
        expectedImpact: 'More balanced workload and reduced stress',
        confidence: 80.0,
        generatedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        relatedTaskIds: upcomingTasks.map((t) => t.id).toList(),
        supportingData: {
          'upcoming_tasks_count': upcomingTasks.length,
          'time_window_days': 7,
        },
      ));
    }

    // Analyze task duration estimates
    final tasksWithEstimates = tasks.where((t) => t.estimatedDuration != null).toList();
    if (tasksWithEstimates.length > 3) {
      final avgDuration = tasksWithEstimates
          .map((t) => t.estimatedDuration!)
          .reduce((a, b) => a + b) / tasksWithEstimates.length;
      
      final longTasks = tasksWithEstimates.where((t) => t.estimatedDuration! > avgDuration * 2).toList();
      
      if (longTasks.isNotEmpty) {
        suggestions.add(AISuggestion(
          id: 'duration_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
          projectId: project.id,
          type: AISuggestionType.scheduleOptimization,
          priority: SuggestionPriority.low,
          category: SuggestionCategory.planning,
          title: 'Break Down Large Tasks',
          description: 'Some tasks have significantly longer duration estimates than others. Breaking them down could improve planning accuracy.',
          recommendations: [
            'Split tasks longer than ${(avgDuration * 2).round()} minutes into smaller subtasks',
            'Create intermediate milestones for large tasks',
            'Review duration estimates regularly based on actual completion times',
          ],
          expectedImpact: 'Improved planning accuracy and better progress tracking',
          confidence: 70.0,
          generatedAt: DateTime.now(),
          updatedAt: DateTime.now(),
          relatedTaskIds: longTasks.map((t) => t.id).toList(),
          supportingData: {
            'long_tasks_count': longTasks.length,
            'average_duration': avgDuration,
            'threshold_duration': avgDuration * 2,
          },
        ));
      }
    }

    return suggestions;
  }

  /// Generates bottleneck identification suggestions
  Future<List<AISuggestion>> _generateBottleneckSuggestions(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final suggestions = <AISuggestion>[];
    
    // Identify status bottlenecks
    final inProgressTasks = tasks.where((t) => t.status.isInProgress).toList();
    final pendingTasks = tasks.where((t) => t.status.isPending).toList();
    
    if (inProgressTasks.length > 3 && pendingTasks.length < 2) {
      suggestions.add(AISuggestion(
        id: 'bottleneck_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        projectId: project.id,
        type: AISuggestionType.bottleneckIdentification,
        priority: SuggestionPriority.high,
        category: SuggestionCategory.productivity,
        title: 'Too Many Tasks In Progress',
        description: 'You have ${inProgressTasks.length} tasks in progress simultaneously. This might be causing focus fragmentation.',
        recommendations: const [
          'Complete some in-progress tasks before starting new ones',
          'Implement a work-in-progress (WIP) limit of 2-3 tasks',
          'Prioritize tasks based on deadline and importance',
          'Consider time-blocking to focus on one task at a time',
        ],
        expectedImpact: 'Improved focus and faster task completion',
        confidence: 90.0,
        generatedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        relatedTaskIds: inProgressTasks.map((t) => t.id).toList(),
        supportingData: {
          'in_progress_count': inProgressTasks.length,
          'pending_count': pendingTasks.length,
          'recommended_wip_limit': 3,
        },
      ));
    }

    // Identify category bottlenecks
    final categoryDistribution = <String, int>{};
    for (final task in tasks) {
      final category = task.tags.isNotEmpty ? task.tags.first : 'uncategorized';
      categoryDistribution[category] = (categoryDistribution[category] ?? 0) + 1;
    }
    
    final dominantCategory = categoryDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    
    if (dominantCategory.value > tasks.length * 0.6) {
      suggestions.add(AISuggestion(
        id: 'category_bottleneck_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        projectId: project.id,
        type: AISuggestionType.bottleneckIdentification,
        priority: SuggestionPriority.medium,
        category: SuggestionCategory.planning,
        title: 'Unbalanced Task Categories',
        description: 'Most tasks (${((dominantCategory.value / tasks.length) * 100).round()}%) fall under "${dominantCategory.key}". Consider diversifying task types.',
        recommendations: [
          'Review if all "${dominantCategory.key}" tasks are necessary',
          'Consider outsourcing or delegating some tasks in this category',
          'Break down large tasks into different categories where appropriate',
          'Plan for more balanced task distribution in future sprints',
        ],
        expectedImpact: 'More balanced workflow and reduced single-point-of-failure risk',
        confidence: 75.0,
        generatedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        supportingData: {
          'dominant_category': dominantCategory.key,
          'dominant_percentage': (dominantCategory.value / tasks.length) * 100,
          'total_categories': categoryDistribution.length,
        },
      ));
    }

    return suggestions;
  }

  /// Generates resource allocation suggestions
  Future<List<AISuggestion>> _generateResourceAllocationSuggestions(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final suggestions = <AISuggestion>[];
    
    // Analyze workload distribution (if tasks have estimated durations)
    final tasksWithDuration = tasks.where((t) => t.estimatedDuration != null).toList();
    if (tasksWithDuration.length < 3) return suggestions;

    final remainingTasks = tasksWithDuration.where((t) => !t.status.isCompleted).toList();
    final remainingHours = remainingTasks
        .map((t) => t.estimatedDuration!)
        .fold(0.0, (a, b) => a + b) / 60;

    // Check if project deadline is realistic given remaining work
    if (project.deadline != null && remainingHours > 0) {
      final daysUntilDeadline = project.deadline!.difference(DateTime.now()).inDays;
      final hoursPerDay = remainingHours / daysUntilDeadline;
      
      if (hoursPerDay > 8) { // More than 8 hours per day needed
        suggestions.add(AISuggestion(
          id: 'resource_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
          projectId: project.id,
          type: AISuggestionType.resourceAllocation,
          priority: SuggestionPriority.urgent,
          category: SuggestionCategory.riskManagement,
          title: 'Insufficient Time for Current Workload',
          description: 'Based on task estimates, you need ${hoursPerDay.toStringAsFixed(1)} hours/day to meet the deadline. Consider additional resources or deadline adjustment.',
          recommendations: const [
            'Negotiate deadline extension with stakeholders',
            'Identify tasks that can be delegated to team members',
            'Review task estimates - some might be overestimated',
            'Consider reducing project scope by deferring non-critical tasks',
            'Hire additional resources or contractors for specific tasks',
          ],
          expectedImpact: 'Realistic project timeline and reduced team burnout',
          confidence: 85.0,
          generatedAt: DateTime.now(),
          updatedAt: DateTime.now(),
          relatedTaskIds: remainingTasks.map((t) => t.id).toList(),
          supportingData: {
            'remaining_hours': remainingHours,
            'days_until_deadline': daysUntilDeadline,
            'hours_per_day_needed': hoursPerDay,
            'recommended_max_hours_per_day': 8,
          },
        ));
      } else if (hoursPerDay < 2 && daysUntilDeadline > 7) {
        // Project might finish early
        suggestions.add(AISuggestion(
          id: 'early_completion_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
          projectId: project.id,
          type: AISuggestionType.resourceAllocation,
          priority: SuggestionPriority.low,
          category: SuggestionCategory.productivity,
          title: 'Project Ahead of Schedule',
          description: 'Based on current estimates, you only need ${hoursPerDay.toStringAsFixed(1)} hours/day. Consider adding value-adding features or moving up the deadline.',
          recommendations: const [
            'Add additional features or improvements to the project',
            'Conduct thorough testing and quality assurance',
            'Move the deadline earlier to free up resources for other projects',
            'Use extra time for team learning and development',
          ],
          expectedImpact: 'Maximized value delivery and optimal resource utilization',
          confidence: 70.0,
          generatedAt: DateTime.now(),
          updatedAt: DateTime.now(),
          supportingData: {
            'remaining_hours': remainingHours,
            'days_until_deadline': daysUntilDeadline,
            'hours_per_day_needed': hoursPerDay,
          },
        ));
      }
    }

    return suggestions;
  }

  /// Generates deadline adjustment suggestions
  Future<List<AISuggestion>> _generateDeadlineAdjustmentSuggestions(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final suggestions = <AISuggestion>[];
    
    if (project.deadline == null) return suggestions;

    final overdueTasks = tasks.where((t) => t.isOverdue).toList();
    final atRiskTasks = tasks.where((t) => 
        t.dueDate != null && 
        t.dueDate!.isBefore(DateTime.now().add(const Duration(days: 2))) &&
        !t.status.isCompleted
    ).toList();

    if (overdueTasks.isNotEmpty || atRiskTasks.length > 3) {
      suggestions.add(AISuggestion(
        id: 'deadline_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        projectId: project.id,
        type: AISuggestionType.deadlineAdjustment,
        priority: SuggestionPriority.high,
        category: SuggestionCategory.riskManagement,
        title: 'Project Deadline at Risk',
        description: 'With ${overdueTasks.length} overdue tasks and ${atRiskTasks.length} tasks at risk, the project deadline may not be achievable.',
        recommendations: const [
          'Negotiate deadline extension with stakeholders',
          'Identify critical path tasks and focus resources there',
          'Consider reducing project scope to meet original deadline',
          'Implement daily stand-ups to track progress more closely',
          'Add buffer time to remaining task estimates',
        ],
        expectedImpact: 'Realistic project timeline and stakeholder expectation management',
        confidence: 80.0,
        generatedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        relatedTaskIds: [...overdueTasks.map((t) => t.id), ...atRiskTasks.map((t) => t.id)],
        supportingData: {
          'overdue_tasks': overdueTasks.length,
          'at_risk_tasks': atRiskTasks.length,
          'total_tasks': tasks.length,
          'project_deadline': project.deadline!.toIso8601String(),
        },
      ));
    }

    return suggestions;
  }

  /// Generates workflow improvement suggestions
  Future<List<AISuggestion>> _generateWorkflowImprovementSuggestions(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final suggestions = <AISuggestion>[];
    
    // Check for tasks without descriptions
    final tasksWithoutDescription = tasks.where((t) => 
        t.description == null || t.description!.trim().isEmpty).toList();
    
    if (tasksWithoutDescription.length > tasks.length * 0.3) {
      suggestions.add(AISuggestion(
        id: 'description_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        projectId: project.id,
        type: AISuggestionType.workflowImprovement,
        priority: SuggestionPriority.medium,
        category: SuggestionCategory.quality,
        title: 'Add Task Descriptions',
        description: '${tasksWithoutDescription.length} tasks lack detailed descriptions. This can lead to confusion and rework.',
        recommendations: const [
          'Add clear descriptions to all tasks explaining what needs to be done',
          'Include acceptance criteria for complex tasks',
          'Add relevant context and background information',
          'Use templates for common task types',
        ],
        expectedImpact: 'Reduced confusion, better task clarity, and fewer misunderstandings',
        confidence: 75.0,
        generatedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        relatedTaskIds: tasksWithoutDescription.map((t) => t.id).toList(),
        supportingData: {
          'tasks_without_description': tasksWithoutDescription.length,
          'total_tasks': tasks.length,
          'percentage': (tasksWithoutDescription.length / tasks.length) * 100,
        },
      ));
    }

    // Check for tasks without tags
    final tasksWithoutTags = tasks.where((t) => t.tags.isEmpty).toList();
    
    if (tasksWithoutTags.length > tasks.length * 0.4) {
      suggestions.add(AISuggestion(
        id: 'tagging_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        projectId: project.id,
        type: AISuggestionType.workflowImprovement,
        priority: SuggestionPriority.low,
        category: SuggestionCategory.productivity,
        title: 'Improve Task Categorization',
        description: '${tasksWithoutTags.length} tasks don\'t have tags. Adding tags improves organization and filtering.',
        recommendations: const [
          'Add relevant tags to categorize tasks by type, priority, or area',
          'Create a consistent tagging system for the project',
          'Use tags to identify which team member or skill set is needed',
          'Consider using tags for progress tracking (e.g., "review-needed", "testing")',
        ],
        expectedImpact: 'Better task organization and improved filtering capabilities',
        confidence: 70.0,
        generatedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        relatedTaskIds: tasksWithoutTags.map((t) => t.id).toList(),
        supportingData: {
          'tasks_without_tags': tasksWithoutTags.length,
          'total_tasks': tasks.length,
          'percentage': (tasksWithoutTags.length / tasks.length) * 100,
        },
      ));
    }

    return suggestions;
  }

  /// Generates risk mitigation suggestions
  Future<List<AISuggestion>> _generateRiskMitigationSuggestions(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final suggestions = <AISuggestion>[];
    
    // Check for single points of failure
    final criticalTasks = tasks.where((t) => 
        t.priority.isHighPriority && 
        !t.status.isCompleted &&
        t.dependencies.isEmpty // No backup if this fails
    ).toList();
    
    if (criticalTasks.length > 2) {
      suggestions.add(AISuggestion(
        id: 'risk_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        projectId: project.id,
        type: AISuggestionType.riskMitigation,
        priority: SuggestionPriority.medium,
        category: SuggestionCategory.riskManagement,
        title: 'Mitigate Critical Task Risks',
        description: 'You have ${criticalTasks.length} high-priority tasks with no backup plans. Consider risk mitigation strategies.',
        recommendations: const [
          'Create backup plans for critical tasks',
          'Cross-train team members on critical skills',
          'Break down critical tasks into smaller, manageable pieces',
          'Identify alternative approaches for achieving the same outcomes',
          'Add buffer time to critical path tasks',
        ],
        expectedImpact: 'Reduced project risk and improved resilience to setbacks',
        confidence: 80.0,
        generatedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        relatedTaskIds: criticalTasks.map((t) => t.id).toList(),
        supportingData: {
          'critical_tasks_count': criticalTasks.length,
          'total_high_priority': tasks.where((t) => t.priority.isHighPriority).length,
        },
      ));
    }

    // Check project deadline risk
    if (project.deadline != null) {
      final daysUntilDeadline = project.deadline!.difference(DateTime.now()).inDays;
      final incompleteTasks = tasks.where((t) => !t.status.isCompleted).toList();
      
      if (daysUntilDeadline < 7 && incompleteTasks.length > 5) {
        suggestions.add(AISuggestion(
          id: 'deadline_risk_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
          projectId: project.id,
          type: AISuggestionType.riskMitigation,
          priority: SuggestionPriority.urgent,
          category: SuggestionCategory.riskManagement,
          title: 'Urgent: Deadline Risk',
          description: 'Only $daysUntilDeadline days until deadline with ${incompleteTasks.length} incomplete tasks. Immediate action required.',
          recommendations: const [
            'Focus only on critical and high-priority tasks',
            'Defer non-essential tasks to a later phase',
            'Work additional hours or bring in extra help',
            'Communicate with stakeholders about potential delays',
            'Prepare a contingency plan for partial delivery',
          ],
          expectedImpact: 'Maximized chances of meeting deadline or managed stakeholder expectations',
          confidence: 95.0,
          generatedAt: DateTime.now(),
          expiresAt: project.deadline,
          updatedAt: DateTime.now(),
          relatedTaskIds: incompleteTasks.map((t) => t.id).toList(),
          supportingData: {
            'days_until_deadline': daysUntilDeadline,
            'incomplete_tasks': incompleteTasks.length,
            'completion_rate': _calculateCompletionRate(tasks),
          },
        ));
      }
    }

    return suggestions;
  }

  /// Generates performance optimization suggestions
  Future<List<AISuggestion>> _generatePerformanceOptimizationSuggestions(
    Project project,
    List<TaskModel> tasks,
  ) async {
    final suggestions = <AISuggestion>[];
    
    // Analyze task completion patterns
    final completedTasks = tasks.where((t) => t.status.isCompleted).toList();
    if (completedTasks.length < 3) return suggestions;

    // Check for tasks that took much longer than estimated
    final tasksWithActualDuration = completedTasks.where((t) => 
        t.estimatedDuration != null && 
        t.actualDuration != null).toList();
    
    if (tasksWithActualDuration.length >= 3) {
      final overEstimatedTasks = tasksWithActualDuration.where((t) =>
          t.actualDuration! > t.estimatedDuration! * 1.5).toList();
      
      if (overEstimatedTasks.length > tasksWithActualDuration.length * 0.3) {
        suggestions.add(AISuggestion(
          id: 'estimation_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
          projectId: project.id,
          type: AISuggestionType.performanceOptimization,
          priority: SuggestionPriority.medium,
          category: SuggestionCategory.productivity,
          title: 'Improve Time Estimation',
          description: '${overEstimatedTasks.length} tasks took significantly longer than estimated. Better estimation could improve planning.',
          recommendations: const [
            'Review completed tasks to understand why they took longer',
            'Include buffer time in estimates for similar tasks',
            'Break down complex tasks for better estimation accuracy',
            'Track time spent on tasks to improve future estimates',
            'Consider external factors that might affect task duration',
          ],
          expectedImpact: 'More accurate project planning and better deadline management',
          confidence: 75.0,
          generatedAt: DateTime.now(),
          updatedAt: DateTime.now(),
          relatedTaskIds: overEstimatedTasks.map((t) => t.id).toList(),
          supportingData: {
            'over_estimated_tasks': overEstimatedTasks.length,
            'total_with_durations': tasksWithActualDuration.length,
            'estimation_accuracy': _calculateEstimationAccuracy(tasksWithActualDuration),
          },
        ));
      }
    }

    // Check task completion velocity
    final recentCompletions = completedTasks.where((t) =>
        t.completedAt != null &&
        t.completedAt!.isAfter(DateTime.now().subtract(const Duration(days: 7)))
    ).toList();

    final weeklyVelocity = recentCompletions.length;
    final remainingTasks = tasks.where((t) => !t.status.isCompleted).length;
    
    if (weeklyVelocity > 0 && project.deadline != null) {
      final weeksUntilDeadline = project.deadline!.difference(DateTime.now()).inDays / 7;
      final projectedCompletion = weeklyVelocity * weeksUntilDeadline;
      
      if (projectedCompletion < remainingTasks * 0.9) {
        suggestions.add(AISuggestion(
          id: 'velocity_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
          projectId: project.id,
          type: AISuggestionType.performanceOptimization,
          priority: SuggestionPriority.high,
          category: SuggestionCategory.productivity,
          title: 'Increase Task Completion Velocity',
          description: 'Current velocity ($weeklyVelocity tasks/week) may not be sufficient to complete all tasks by the deadline.',
          recommendations: const [
            'Identify and eliminate blockers that slow down task completion',
            'Focus on completing smaller tasks first to build momentum',
            'Reduce context switching by batching similar tasks',
            'Consider pair programming or collaboration for complex tasks',
            'Review and streamline your task completion process',
          ],
          expectedImpact: 'Improved project completion probability and team productivity',
          confidence: 80.0,
          generatedAt: DateTime.now(),
          updatedAt: DateTime.now(),
          supportingData: {
            'weekly_velocity': weeklyVelocity,
            'remaining_tasks': remainingTasks,
            'weeks_until_deadline': weeksUntilDeadline,
            'projected_completion': projectedCompletion,
          },
        ));
      }
    }

    return suggestions;
  }

  /// Calculates overall confidence based on data quality and suggestion reliability
  double _calculateOverallConfidence(List<TaskModel> tasks, List<AISuggestion> suggestions) {
    if (tasks.isEmpty || suggestions.isEmpty) return 0.0;

    // Base confidence on data availability
    double dataQualityScore = 0.0;
    
    // Task data completeness
    final tasksWithDescriptions = tasks.where((t) => t.description?.isNotEmpty == true).length;
    final tasksWithDurations = tasks.where((t) => t.estimatedDuration != null).length;
    final tasksWithDueDates = tasks.where((t) => t.dueDate != null).length;
    final completedTasks = tasks.where((t) => t.status.isCompleted).length;

    dataQualityScore += (tasksWithDescriptions / tasks.length) * 20; // Max 20 points
    dataQualityScore += (tasksWithDurations / tasks.length) * 20; // Max 20 points
    dataQualityScore += (tasksWithDueDates / tasks.length) * 20; // Max 20 points
    dataQualityScore += (completedTasks / tasks.length) * 20; // Max 20 points
    
    // Suggestion confidence average
    final avgSuggestionConfidence = suggestions
        .map((s) => s.confidence)
        .reduce((a, b) => a + b) / suggestions.length;

    dataQualityScore += avgSuggestionConfidence * 0.2; // Max 20 points

    return min(dataQualityScore, 100.0);
  }

  /// Generates key insights based on project analysis
  Future<List<String>> _generateKeyInsights(
    Project project,
    List<TaskModel> tasks,
    List<AISuggestion> suggestions,
  ) async {
    final insights = <String>[];
    
    final completionRate = _calculateCompletionRate(tasks);
    final overdueTasks = tasks.where((t) => t.isOverdue).length;
    final highPrioritySuggestions = suggestions.where((s) => 
        s.priority == SuggestionPriority.high || 
        s.priority == SuggestionPriority.urgent).length;

    if (completionRate > 0.8) {
      insights.add('Project is on track with ${(completionRate * 100).round()}% completion rate');
    } else if (completionRate < 0.4) {
      insights.add('Project needs attention - only ${(completionRate * 100).round()}% of tasks completed');
    }

    if (overdueTasks > 0) {
      insights.add('$overdueTasks overdue tasks require immediate attention');
    }

    if (highPrioritySuggestions > 2) {
      insights.add('Multiple high-priority optimizations available');
    }

    if (project.deadline != null) {
      final daysRemaining = project.deadline!.difference(DateTime.now()).inDays;
      if (daysRemaining < 7) {
        insights.add('Project deadline is approaching in $daysRemaining days');
      }
    }

    // Add category-specific insights
    final categoryDistribution = <String, int>{};
    for (final task in tasks) {
      for (final tag in task.tags) {
        categoryDistribution[tag] = (categoryDistribution[tag] ?? 0) + 1;
      }
    }

    if (categoryDistribution.isNotEmpty) {
      final topCategory = categoryDistribution.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      insights.add('Most tasks are in "${topCategory.key}" category (${topCategory.value} tasks)');
    }

    return insights;
  }

  /// Calculates completion rate for a list of tasks
  double _calculateCompletionRate(List<TaskModel> tasks) {
    if (tasks.isEmpty) return 0.0;
    final completedTasks = tasks.where((t) => t.status.isCompleted).length;
    return completedTasks / tasks.length;
  }

  /// Calculates estimation accuracy for tasks with both estimated and actual durations
  double _calculateEstimationAccuracy(List<TaskModel> tasks) {
    if (tasks.isEmpty) return 0.0;
    
    double totalAccuracy = 0.0;
    for (final task in tasks) {
      if (task.estimatedDuration != null && task.actualDuration != null) {
        final accuracy = min(task.estimatedDuration!, task.actualDuration!) / 
                        max(task.estimatedDuration!, task.actualDuration!);
        totalAccuracy += accuracy;
      }
    }
    
    return totalAccuracy / tasks.length;
  }
}