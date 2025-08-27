import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/project_health.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../../domain/entities/project_prediction.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../notification/enhanced_notification_service.dart';
import '../notification/notification_models.dart';

/// Smart notification service that provides context-aware alerts and intelligent reminders
class SmartNotificationService {
  final EnhancedNotificationService _notificationService;
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;
  
  final Map<String, DateTime> _lastNotificationTimes = {};
  final Map<String, Duration> _notificationCooldowns = {};
  Timer? _smartMonitoringTimer;

  SmartNotificationService({
    required EnhancedNotificationService notificationService,
    required TaskRepository taskRepository,
    required ProjectRepository projectRepository,
  })  : _notificationService = notificationService,
        _taskRepository = taskRepository,
        _projectRepository = projectRepository;

  /// Starts intelligent notification monitoring
  Future<void> startSmartMonitoring() async {
    await stopSmartMonitoring();
    
    // Run smart notifications every hour
    _smartMonitoringTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _performSmartNotificationCheck(),
    );
    
    // Initial check
    await _performSmartNotificationCheck();
  }

  /// Stops smart notification monitoring
  Future<void> stopSmartMonitoring() async {
    _smartMonitoringTimer?.cancel();
    _smartMonitoringTimer = null;
  }

  /// Processes project health status and sends appropriate notifications
  Future<void> processHealthNotifications(ProjectHealth health) async {
    final project = await _projectRepository.getProjectById(health.projectId);
    if (project == null) return;

    // Critical health issues
    final criticalIssues = health.criticalIssues;
    if (criticalIssues.isNotEmpty && !_isOnCooldown('critical_health_${health.projectId}')) {
      await _sendCriticalHealthAlert(project, health, criticalIssues);
      _setCooldown('critical_health_${health.projectId}', const Duration(hours: 6));
    }

    // Health deterioration alerts
    if (health.healthScore < 40 && !_isOnCooldown('health_deterioration_${health.projectId}')) {
      await _sendHealthDeteriorationAlert(project, health);
      _setCooldown('health_deterioration_${health.projectId}', const Duration(hours: 12));
    }

    // Milestone alerts for improving health
    if (health.healthScore > 80 && !_isOnCooldown('health_improvement_${health.projectId}')) {
      await _sendHealthImprovementAlert(project, health);
      _setCooldown('health_improvement_${health.projectId}', const Duration(days: 2));
    }
  }

  /// Processes AI suggestions and sends appropriate notifications
  Future<void> processAISuggestionNotifications(ProjectAISuggestions suggestions) async {
    final project = await _projectRepository.getProjectById(suggestions.projectId);
    if (project == null) return;

    // Urgent AI suggestions
    final urgentSuggestions = suggestions.urgentSuggestions;
    if (urgentSuggestions.isNotEmpty && !_isOnCooldown('urgent_ai_${suggestions.projectId}')) {
      await _sendUrgentAISuggestionAlert(project, urgentSuggestions);
      _setCooldown('urgent_ai_${suggestions.projectId}', const Duration(hours: 4));
    }

    // High-confidence suggestions
    final highConfidenceSuggestions = suggestions.highConfidenceSuggestions
        .where((s) => s.priority == SuggestionPriority.high)
        .toList();
    
    if (highConfidenceSuggestions.isNotEmpty && 
        !_isOnCooldown('high_confidence_ai_${suggestions.projectId}')) {
      await _sendHighConfidenceAISuggestionAlert(project, highConfidenceSuggestions);
      _setCooldown('high_confidence_ai_${suggestions.projectId}', const Duration(hours: 8));
    }

    // Weekly AI digest
    if (_shouldSendWeeklyDigest(suggestions.projectId)) {
      await _sendWeeklyAIDigest(project, suggestions);
      _setCooldown('weekly_ai_digest_${suggestions.projectId}', const Duration(days: 7));
    }
  }

  /// Processes predictive analytics and sends appropriate notifications
  Future<void> processPredictiveNotifications(ProjectPredictiveAnalytics analytics) async {
    final project = await _projectRepository.getProjectById(analytics.projectId);
    if (project == null) return;

    // High-risk predictions
    if (analytics.isHighRisk && !_isOnCooldown('high_risk_prediction_${analytics.projectId}')) {
      await _sendHighRiskPredictionAlert(project, analytics);
      _setCooldown('high_risk_prediction_${analytics.projectId}', const Duration(hours: 12));
    }

    // Completion date alerts
    if (analytics.predictedCompletionDate != null && project.deadline != null) {
      final daysLate = analytics.predictedCompletionDate!.difference(project.deadline!).inDays;
      
      if (daysLate > 7 && !_isOnCooldown('completion_delay_${analytics.projectId}')) {
        await _sendCompletionDelayAlert(project, analytics, daysLate);
        _setCooldown('completion_delay_${analytics.projectId}', const Duration(hours: 24));
      }
    }

    // Success probability alerts
    if (analytics.successProbability < 30 && !_isOnCooldown('low_success_${analytics.projectId}')) {
      await _sendLowSuccessProbabilityAlert(project, analytics);
      _setCooldown('low_success_${analytics.projectId}', const Duration(hours: 8));
    }
  }

  /// Sends context-aware task reminders
  Future<void> sendContextAwareTaskReminder(TaskModel task) async {
    final context = await _buildTaskContext(task);
    
    String title = 'Task Reminder';
    String body = task.title;
    NotificationPriority priority = NotificationPriority.normal;
    List<NotificationAction> actions = [
      NotificationAction.complete,
      NotificationAction.snooze,
    ];

    // Customize based on context
    if (task.isOverdue) {
      title = '⚠️ Overdue Task';
      body = '${task.title} was due ${_formatTimeAgo(task.dueDate!)}';
      priority = NotificationPriority.high;
      actions = [NotificationAction.complete, NotificationAction.reschedule];
    } else if (task.dueDate != null) {
      final hoursUntilDue = task.dueDate!.difference(DateTime.now()).inHours;
      
      if (hoursUntilDue <= 2) {
        title = '🔥 Due Soon';
        body = '${task.title} is due in ${_formatTimeUntil(task.dueDate!)}';
        priority = NotificationPriority.high;
      } else if (hoursUntilDue <= 24) {
        title = '📅 Due Tomorrow';
        body = '${task.title} is due ${_formatTimeUntil(task.dueDate!)}';
      }
    }

    // Add context information
    if (context['projectName'] != null) {
      body += ' • ${context['projectName']}';
    }

    if (context['dependentTasks'] > 0) {
      body += ' • ${context['dependentTasks']} tasks waiting';
      priority = NotificationPriority.high;
    }

    if (context['isBlocker']) {
      title = '🚧 $title (Blocking Others)';
      priority = NotificationPriority.high;
    }

    await _notificationService.scheduleNotification(
      task: task,
      scheduledTime: DateTime.now(),
    );
  }

  /// Sends smart milestone reminders
  Future<void> sendSmartMilestoneReminder(Project project, Map<String, dynamic> milestoneData) async {
    if (_isOnCooldown('milestone_${project.id}')) return;

    final completionRate = milestoneData['completion_rate'] as double;
    final tasksCompleted = milestoneData['tasks_completed'] as int;
    final milestone = milestoneData['milestone'] as String;

    String title = '🎯 Milestone Achievement';
    String body = 'Great progress on ${project.name}! ';

    if (completionRate >= 1.0) {
      title = '🎉 Project Complete';
      body = 'Congratulations! ${project.name} is now complete.';
    } else if (completionRate >= 0.75) {
      body += 'You\'re ${(completionRate * 100).round()}% done ($tasksCompleted tasks completed).';
    } else {
      body += 'You\'ve reached the $milestone milestone with $tasksCompleted tasks completed.';
    }

    await _notificationService.showImmediateNotification(
      title: title,
      body: body,
      type: NotificationTypeModel.taskCompleted,
      payload: {
        'project_id': project.id,
        'milestone': milestone,
        'completion_rate': completionRate,
      },
    );

    _setCooldown('milestone_${project.id}', const Duration(hours: 4));
  }

  /// Sends intelligent deadline warnings
  Future<void> sendIntelligentDeadlineWarning(Project project, int daysUntilDeadline) async {
    if (_isOnCooldown('deadline_warning_${project.id}')) return;

    final tasks = await _taskRepository.getTasksForProject(project.id);
    final remainingTasks = tasks.where((t) => !t.status.isCompleted).length;
    final tasksPerDay = remainingTasks / daysUntilDeadline;

    String title = '📅 Deadline Approaching';
    String body = '${project.name} deadline is in $daysUntilDeadline days.';
    NotificationPriority priority = NotificationPriority.normal;

    if (tasksPerDay > 3) {
      title = '⚠️ Deadline Risk';
      body += ' You need to complete ${tasksPerDay.toStringAsFixed(1)} tasks per day.';
      priority = NotificationPriority.high;
    } else if (tasksPerDay > 1) {
      body += ' ${tasksPerDay.toStringAsFixed(1)} tasks per day to finish on time.';
    } else {
      title = '✅ On Track';
      body += ' You\'re on track with $remainingTasks tasks remaining.';
    }

    await _notificationService.showImmediateNotification(
      title: title,
      body: body,
      type: NotificationTypeModel.overdueTask,
      payload: {
        'project_id': project.id,
        'days_until_deadline': daysUntilDeadline,
        'remaining_tasks': remainingTasks,
        'tasks_per_day': tasksPerDay,
      },
    );

    _setCooldown('deadline_warning_${project.id}', const Duration(days: 1));
  }

  /// Performs comprehensive smart notification check
  Future<void> _performSmartNotificationCheck() async {
    try {
      await _checkOverdueTaskAlerts();
      await _checkDeadlineWarnings();
      await _checkProductivityInsights();
      await _checkBlockerAlerts();
      await _checkIdleProjectAlerts();
    } catch (e) {
      debugPrint('Error in smart notification check: $e');
    }
  }

  /// Checks for overdue task alerts
  Future<void> _checkOverdueTaskAlerts() async {
    final allTasks = await _taskRepository.getAllTasks();
    final overdueTasks = allTasks.where((t) => t.isOverdue && !t.status.isCompleted).toList();

    for (final task in overdueTasks) {
      if (!_isOnCooldown('overdue_${task.id}')) {
        await sendContextAwareTaskReminder(task);
        _setCooldown('overdue_${task.id}', const Duration(hours: 4));
      }
    }
  }

  /// Checks for deadline warnings across all projects
  Future<void> _checkDeadlineWarnings() async {
    final allProjects = await _projectRepository.getAllProjects();
    final now = DateTime.now();

    for (final project in allProjects) {
      if (project.deadline == null || project.isArchived) continue;

      final daysUntilDeadline = project.deadline!.difference(now).inDays;
      
      if (daysUntilDeadline == 7 || daysUntilDeadline == 3 || daysUntilDeadline == 1) {
        await sendIntelligentDeadlineWarning(project, daysUntilDeadline);
      }
    }
  }

  /// Checks for productivity insights and sends notifications
  Future<void> _checkProductivityInsights() async {
    if (!_shouldSendProductivityInsights()) return;

    // Simple productivity insight: completed tasks today vs. yesterday
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    final allTasks = await _taskRepository.getAllTasks();
    final tasksCompletedToday = allTasks.where((t) =>
        t.status.isCompleted &&
        t.completedAt != null &&
        t.completedAt!.isAfter(today)).length;
    
    final tasksCompletedYesterday = allTasks.where((t) =>
        t.status.isCompleted &&
        t.completedAt != null &&
        t.completedAt!.isAfter(yesterday) &&
        t.completedAt!.isBefore(today)).length;

    if (tasksCompletedToday > tasksCompletedYesterday && tasksCompletedToday >= 3) {
      await _sendProductivityBoostNotification(tasksCompletedToday, tasksCompletedYesterday);
    } else if (tasksCompletedToday == 0 && tasksCompletedYesterday > 0) {
      await _sendProductivityEncouragementNotification();
    }
    
    _setCooldown('productivity_insights', const Duration(days: 1));
  }

  /// Checks for blocker alerts
  Future<void> _checkBlockerAlerts() async {
    final allTasks = await _taskRepository.getAllTasks();
    
    for (final task in allTasks) {
      if (task.status.isCompleted || task.dependencies.isEmpty) continue;
      
      // Check if this task is blocking others and its dependencies are complete
      final blockingTasks = allTasks.where((t) => t.dependencies.contains(task.id)).toList();
      if (blockingTasks.isEmpty) continue;
      
      final incompleteDependencies = task.dependencies.where((depId) {
        final depTask = allTasks.firstWhere((t) => t.id == depId, orElse: () => task);
        return !depTask.status.isCompleted;
      }).length;
      
      if (incompleteDependencies == 0 && !_isOnCooldown('blocker_ready_${task.id}')) {
        await _sendBlockerReadyNotification(task, blockingTasks.length);
        _setCooldown('blocker_ready_${task.id}', const Duration(hours: 6));
      }
    }
  }

  /// Checks for idle project alerts
  Future<void> _checkIdleProjectAlerts() async {
    final allProjects = await _projectRepository.getAllProjects();
    final now = DateTime.now();
    
    for (final project in allProjects) {
      if (project.isArchived) continue;
      
      final tasks = await _taskRepository.getTasksForProject(project.id);
      if (tasks.isEmpty) continue;
      
      final lastActivity = tasks
          .map((t) => t.updatedAt ?? t.createdAt)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      
      final daysSinceActivity = now.difference(lastActivity).inDays;
      
      if (daysSinceActivity >= 7 && !_isOnCooldown('idle_project_${project.id}')) {
        await _sendIdleProjectAlert(project, daysSinceActivity);
        _setCooldown('idle_project_${project.id}', const Duration(days: 3));
      }
    }
  }

  // Notification sending methods

  Future<void> _sendCriticalHealthAlert(
    Project project,
    ProjectHealth health,
    List<ProjectHealthIssue> issues,
  ) async {
    final issueCount = issues.length;
    final topIssue = issues.first;

    await _notificationService.showImmediateNotification(
      title: '🚨 Critical Project Issues',
      body: '${project.name} has $issueCount critical issues. ${topIssue.title}',
      type: NotificationTypeModel.emergency,
      payload: {
        'project_id': project.id,
        'health_score': health.healthScore,
        'critical_issues': issueCount,
      },
    );
  }

  Future<void> _sendHealthDeteriorationAlert(Project project, ProjectHealth health) async {
    await _notificationService.showImmediateNotification(
      title: '⚠️ Project Health Declining',
      body: '${project.name} health score is ${health.healthScore.round()}/100. Review needed.',
      type: NotificationTypeModel.emergency,
      payload: {
        'project_id': project.id,
        'health_score': health.healthScore,
      },
    );
  }

  Future<void> _sendHealthImprovementAlert(Project project, ProjectHealth health) async {
    await _notificationService.showImmediateNotification(
      title: '🎉 Project Thriving',
      body: '${project.name} is in excellent health (${health.healthScore.round()}/100). Keep it up!',
      type: NotificationTypeModel.taskCompleted,
      payload: {
        'project_id': project.id,
        'health_score': health.healthScore,
      },
    );
  }

  Future<void> _sendUrgentAISuggestionAlert(
    Project project,
    List<AISuggestion> suggestions,
  ) async {
    final topSuggestion = suggestions.first;

    await _notificationService.showImmediateNotification(
      title: '🤖 Urgent AI Recommendation',
      body: '${project.name}: ${topSuggestion.title}',
      type: NotificationTypeModel.smartSuggestion,
      payload: {
        'project_id': project.id,
        'suggestion_id': topSuggestion.id,
        'suggestion_count': suggestions.length,
      },
    );
  }

  Future<void> _sendHighConfidenceAISuggestionAlert(
    Project project,
    List<AISuggestion> suggestions,
  ) async {
    final suggestionCount = suggestions.length;
    final topSuggestion = suggestions.first;

    await _notificationService.showImmediateNotification(
      title: '💡 High-Confidence AI Insights',
      body: '${project.name}: ${topSuggestion.title} + ${suggestionCount - 1} more',
      type: NotificationTypeModel.smartSuggestion,
      payload: {
        'project_id': project.id,
        'suggestion_count': suggestionCount,
      },
    );
  }

  Future<void> _sendWeeklyAIDigest(Project project, ProjectAISuggestions suggestions) async {
    final activeCount = suggestions.activeSuggestions.length;

    await _notificationService.showImmediateNotification(
      title: '📊 Weekly AI Insights',
      body: '${project.name}: $activeCount optimization opportunities available',
      type: NotificationTypeModel.smartSuggestion,
      payload: {
        'project_id': project.id,
        'active_suggestions': activeCount,
        'overall_confidence': suggestions.overallConfidence,
      },
    );
  }

  Future<void> _sendHighRiskPredictionAlert(
    Project project,
    ProjectPredictiveAnalytics analytics,
  ) async {
    final riskCount = analytics.riskFactors.length;
    final topRisk = analytics.riskFactors.isNotEmpty ? analytics.riskFactors.first : 'Multiple risk factors';

    await _notificationService.showImmediateNotification(
      title: '⚠️ High Risk Detected',
      body: '${project.name}: $topRisk (${analytics.successProbability.round()}% success probability)',
      type: NotificationTypeModel.emergency,
      payload: {
        'project_id': project.id,
        'success_probability': analytics.successProbability,
        'risk_factors_count': riskCount,
      },
    );
  }

  Future<void> _sendCompletionDelayAlert(
    Project project,
    ProjectPredictiveAnalytics analytics,
    int daysLate,
  ) async {
    await _notificationService.showImmediateNotification(
      title: '📅 Predicted Delay',
      body: '${project.name} may finish $daysLate days late. Consider adjusting timeline.',
      type: NotificationTypeModel.overdueTask,
      payload: {
        'project_id': project.id,
        'predicted_delay_days': daysLate,
        'predicted_completion': analytics.predictedCompletionDate?.toIso8601String(),
      },
    );
  }

  Future<void> _sendLowSuccessProbabilityAlert(
    Project project,
    ProjectPredictiveAnalytics analytics,
  ) async {
    await _notificationService.showImmediateNotification(
      title: '🎯 Success Risk Alert',
      body: '${project.name} has ${analytics.successProbability.round()}% success probability. Action needed.',
      type: NotificationTypeModel.emergency,
      payload: {
        'project_id': project.id,
        'success_probability': analytics.successProbability,
      },
    );
  }

  Future<void> _sendProductivityBoostNotification(int today, int yesterday) async {
    await _notificationService.showImmediateNotification(
      title: '🚀 Productivity Boost',
      body: 'Great job! You completed $today tasks today vs $yesterday yesterday.',
      type: NotificationTypeModel.dailySummary,
      payload: {
        'tasks_today': today,
        'tasks_yesterday': yesterday,
      },
    );
  }

  Future<void> _sendProductivityEncouragementNotification() async {
    await _notificationService.showImmediateNotification(
      title: '💪 Stay Motivated',
      body: 'No tasks completed today yet. Even small progress counts!',
      type: NotificationTypeModel.dailySummary,
      payload: {},
    );
  }

  Future<void> _sendBlockerReadyNotification(TaskModel task, int blockingCount) async {
    await _notificationService.showImmediateNotification(
      title: '🚧 Blocker Ready',
      body: '${task.title} can now be started (unblocking $blockingCount tasks)',
      type: NotificationTypeModel.overdueTask,
      payload: {
        'task_id': task.id,
        'blocked_tasks_count': blockingCount,
      },
    );
  }

  Future<void> _sendIdleProjectAlert(Project project, int daysSinceActivity) async {
    await _notificationService.showImmediateNotification(
      title: '😴 Project Idle',
      body: '${project.name} has been inactive for $daysSinceActivity days. Time to check in?',
      type: NotificationTypeModel.overdueTask,
      payload: {
        'project_id': project.id,
        'days_since_activity': daysSinceActivity,
      },
    );
  }

  // Helper methods

  Future<Map<String, dynamic>> _buildTaskContext(TaskModel task) async {
    final context = <String, dynamic>{};

    // Get project context
    if (task.projectId != null) {
      final project = await _projectRepository.getProjectById(task.projectId!);
      context['projectName'] = project?.name;
    }

    // Check if task is blocking others
    final allTasks = await _taskRepository.getAllTasks();
    final dependentTasks = allTasks.where((t) => t.dependencies.contains(task.id)).length;
    context['dependentTasks'] = dependentTasks;
    context['isBlocker'] = dependentTasks > 0;

    // Check estimated vs actual completion patterns
    if (task.estimatedDuration != null) {
      context['hasEstimate'] = true;
      context['estimatedMinutes'] = task.estimatedDuration;
    }

    return context;
  }

  bool _isOnCooldown(String key) {
    final lastTime = _lastNotificationTimes[key];
    if (lastTime == null) return false;

    final cooldown = _notificationCooldowns[key] ?? const Duration(hours: 1);
    return DateTime.now().difference(lastTime) < cooldown;
  }

  void _setCooldown(String key, Duration duration) {
    _lastNotificationTimes[key] = DateTime.now();
    _notificationCooldowns[key] = duration;
  }

  bool _shouldSendWeeklyDigest(String projectId) {
    final now = DateTime.now();
    return now.weekday == DateTime.monday && now.hour >= 9 && now.hour <= 11;
  }

  bool _shouldSendProductivityInsights() {
    return !_isOnCooldown('productivity_insights');
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    }
  }

  String _formatTimeUntil(DateTime dateTime) {
    final difference = dateTime.difference(DateTime.now());
    
    if (difference.inDays > 0) {
      return 'in ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'now';
    }
  }
}