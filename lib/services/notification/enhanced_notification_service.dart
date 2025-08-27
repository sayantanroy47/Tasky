import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';
import 'notification_models.dart';
import 'local_notification_service.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/task_enums.dart';
import '../../domain/repositories/task_repository.dart';

/// Enhanced notification service with advanced features
class EnhancedNotificationService implements NotificationService {
  final LocalNotificationService _baseService;
  
  // Advanced feature state
  final Map<String, NotificationTemplate> _templates = {};
  final Map<String, NotificationGroup> _groups = {};
  final List<NotificationHistoryEntry> _history = [];
  final Map<NotificationPriority, List<ScheduledNotification>> _priorityQueue = {};
  
  Timer? _smartSchedulingTimer;
  Timer? _analyticsTimer;
  StreamController<NotificationEvent>? _eventController;

  EnhancedNotificationService({
    required TaskRepository taskRepository,
  }) : _baseService = LocalNotificationService(taskRepository) {
    _eventController = StreamController<NotificationEvent>.broadcast();
    _initializeDefaultTemplates();
    _startSmartScheduling();
    _startAnalyticsCollection();
  }

  // Delegate basic functionality to base service
  @override
  Future<bool> initialize() => _baseService.initialize();

  @override
  Future<bool> requestPermissions() => _baseService.requestPermissions();

  @override
  Future<bool> get hasPermissions => _baseService.hasPermissions;

  @override
  Stream<NotificationEvent> get notificationEvents => 
      _eventController?.stream ?? const Stream.empty();

  /// Initialize default notification templates
  void _initializeDefaultTemplates() {
    final now = DateTime.now();
    
    _templates['task_reminder'] = NotificationTemplate(
      id: 'task_reminder',
      name: 'Task Reminder',
      type: NotificationTypeModel.taskReminder,
      titleTemplate: '{{priority_emoji}} Task Reminder',
      bodyTemplate: '{{task_title}}{{due_time_text}}',
      availableActions: const [
        NotificationAction.complete,
        NotificationAction.snooze,
        NotificationAction.reschedule,
      ],
      defaultPriority: NotificationPriority.normal,
      createdAt: now,
      updatedAt: now,
    );

    _templates['location_based'] = NotificationTemplate(
      id: 'location_based', 
      name: 'Location Reminder',
      type: NotificationTypeModel.locationBased,
      titleTemplate: '{{location_event_title}}',
      bodyTemplate: '{{location_message}}: {{task_title}}',
      availableActions: const [
        NotificationAction.complete,
        NotificationAction.view,
        NotificationAction.dismiss,
      ],
      defaultPriority: NotificationPriority.high,
      createdAt: now,
      updatedAt: now,
    );

    _templates['emergency'] = NotificationTemplate(
      id: 'emergency',
      name: 'Emergency Alert',
      type: NotificationTypeModel.emergency,
      titleTemplate: 'URGENT: {{task_title}}',
      bodyTemplate: 'Critical task requires immediate attention: {{task_description}}',
      availableActions: const [
        NotificationAction.view,
        NotificationAction.complete,
      ],
      defaultPriority: NotificationPriority.critical,
      createdAt: now,
      updatedAt: now,
    );

    _templates['smart_suggestion'] = NotificationTemplate(
      id: 'smart_suggestion',
      name: 'Smart Suggestion',
      type: NotificationTypeModel.smartSuggestion,
      titleTemplate: 'Suggestion: {{suggestion_title}}',
      bodyTemplate: '{{suggestion_message}}',
      availableActions: const [
        NotificationAction.view,
        NotificationAction.dismiss,
      ],
      defaultPriority: NotificationPriority.low,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Start smart notification scheduling
  void _startSmartScheduling() {
    _smartSchedulingTimer = Timer.periodic(const Duration(minutes: 15), (_) async {
      await _processSmartScheduling();
    });
  }

  /// Start analytics data collection
  void _startAnalyticsCollection() {
    _analyticsTimer = Timer.periodic(const Duration(hours: 1), (_) async {
      await _collectNotificationAnalytics();
    });
  }

  /// Process intelligent notification scheduling
  Future<void> _processSmartScheduling() async {
    try {
      // Get user's activity patterns
      final patterns = await _analyzeUserPatterns();
      
      // Get pending notifications
      final pending = await getScheduledNotifications();
      
      // Re-schedule based on optimal times
      for (final notification in pending) {
        if (_shouldRescheduleForOptimalTime(notification, patterns)) {
          final optimalTime = _calculateOptimalTime(notification, patterns);
          if (optimalTime != null) {
            await _rescheduleNotification(notification, optimalTime);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in smart scheduling: $e');
      }
    }
  }

  /// Collect analytics about notification effectiveness
  Future<void> _collectNotificationAnalytics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final analyticsData = await _generateAnalyticsData();
      
      // Store analytics data
      await prefs.setString('notification_analytics', 
          analyticsData.toString());
      
      if (kDebugMode) {
        print('Notification analytics collected: ${analyticsData.length} entries');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error collecting notification analytics: $e');
      }
    }
  }

  @override
  Future<int?> scheduleTaskReminder({
    required TaskModel task,
    required DateTime scheduledTime,
    Duration? customReminder,
  }) async {
    // Check if we should use smart scheduling
    if (await _shouldUseSmartScheduling()) {
      final optimalTime = await _calculateOptimalScheduleTime(task, scheduledTime);
      scheduledTime = optimalTime ?? scheduledTime;
    }

    // Apply priority-based scheduling
    final priority = _calculateNotificationPriority(task);
    final template = _getTemplateForTask(task);
    
    // Create enhanced notification
    final notificationId = await _createEnhancedNotification(
      task: task,
      scheduledTime: scheduledTime,
      template: template,
      priority: priority,
    );

    // Add to priority queue
    if (notificationId != null) {
      _addToPriorityQueue(ScheduledNotification(
        id: notificationId,
        taskId: task.id,
        type: NotificationTypeModel.taskReminder,
        scheduledTime: scheduledTime,
        title: _processTemplate(template.titleTemplate, task),
        body: _processTemplate(template.bodyTemplate, task),
        createdAt: DateTime.now(),
      ), priority);
    }

    return notificationId;
  }

  @override
  Future<List<int>> scheduleMultipleReminders({
    required TaskModel task,
    required List<Duration> reminderIntervals,
  }) async {
    final scheduledIds = <int>[];
    
    if (task.dueDate == null) return scheduledIds;

    // Apply smart spacing for multiple reminders
    final optimizedIntervals = await _optimizeReminderIntervals(
      task, reminderIntervals);

    for (final interval in optimizedIntervals) {
      final reminderTime = task.dueDate!.subtract(interval);
      if (reminderTime.isAfter(DateTime.now())) {
        final id = await scheduleTaskReminder(
          task: task,
          scheduledTime: reminderTime,
          customReminder: interval,
        );
        if (id != null) {
          scheduledIds.add(id);
        }
      }
    }

    return scheduledIds;
  }

  @override
  Future<int?> scheduleDailySummary({
    required DateTime scheduledTime,
    required List<TaskModel> tasks,
  }) async {
    // Use base service for daily summary with smart timing
    final optimalTime = await _calculateOptimalSummaryTime(scheduledTime);
    return _baseService.scheduleDailySummary(
      scheduledTime: optimalTime,
      tasks: tasks,
    );
  }

  @override
  Future<int?> scheduleOverdueNotification({
    required TaskModel task,
  }) async {
    const priority = NotificationPriority.urgent;
    final template = _templates['emergency']!;
    
    return await _createEnhancedNotification(
      task: task,
      scheduledTime: DateTime.now(),
      template: template,
      priority: priority,
      isImmediate: true,
    );
  }

  /// Create enhanced notification with advanced features
  Future<int?> _createEnhancedNotification({
    required TaskModel task,
    required DateTime scheduledTime,
    required NotificationTemplate template,
    required NotificationPriority priority,
    bool isImmediate = false,
  }) async {
    final notificationId = DateTime.now().millisecondsSinceEpoch + task.hashCode;
    
    try {
      // Process templates
      final title = _processTemplate(template.titleTemplate, task);
      final body = _processTemplate(template.bodyTemplate, task);
      
      // Setup platform-specific details for potential future use
      // Rich content and platform details could be used for advanced notification configurations

      if (isImmediate) {
        await _baseService.showImmediateNotification(
          title: title,
          body: body,
          taskId: task.id,
          type: template.type,
          payload: {'template_id': template.id},
        );
      } else {
        // Use the base service's scheduling method
        return await _baseService.scheduleTaskReminder(
          task: task,
          scheduledTime: scheduledTime,
          customReminder: null,
        );
      }

      // Add to history
      _addToHistory(NotificationHistoryEntry(
        id: 'history_$notificationId',
        notificationId: notificationId,
        taskId: task.id,
        type: template.type,
        sentAt: isImmediate ? DateTime.now() : scheduledTime,
      ));

      return notificationId;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating enhanced notification: $e');
      }
      return null;
    }
  }


  /// Process notification template with task data
  String _processTemplate(String template, TaskModel task) {
    var processed = template;
    
    // Replace placeholders
    processed = processed.replaceAll('{{task_title}}', task.title);
    processed = processed.replaceAll('{{task_description}}', 
        task.description ?? '');
    processed = processed.replaceAll('{{priority_emoji}}', 
        _getPriorityIndicator(task.priority));
    
    if (task.dueDate != null) {
      processed = processed.replaceAll('{{due_time_text}}', 
          ' (Due ${_formatDueTime(task.dueDate!)})');
    } else {
      processed = processed.replaceAll('{{due_time_text}}', '');
    }
    
    return processed;
  }


  /// Calculate notification priority based on task
  NotificationPriority _calculateNotificationPriority(TaskModel task) {
    switch (task.priority) {
      case TaskPriority.urgent:
        return NotificationPriority.critical;
      case TaskPriority.high:
        return NotificationPriority.urgent;
      case TaskPriority.medium:
        return NotificationPriority.normal;
      case TaskPriority.low:
        return NotificationPriority.low;
    }
  }

  /// Get notification template for task
  NotificationTemplate _getTemplateForTask(TaskModel task) {
    // Can be extended with more sophisticated template selection
    return _templates['task_reminder']!;
  }

  /// Add notification to priority queue
  void _addToPriorityQueue(
    ScheduledNotification notification,
    NotificationPriority priority,
  ) {
    _priorityQueue.putIfAbsent(priority, () => []).add(notification);
    // Sort by scheduled time within priority level
    _priorityQueue[priority]!.sort((a, b) => 
        a.scheduledTime.compareTo(b.scheduledTime));
  }

  /// Add entry to notification history
  void _addToHistory(NotificationHistoryEntry entry) {
    _history.add(entry);
    // Keep only last 1000 entries
    if (_history.length > 1000) {
      _history.removeRange(0, _history.length - 1000);
    }
  }

  // Helper methods for smart scheduling and analytics
  
  Future<Map<String, dynamic>> _analyzeUserPatterns() async {
    // Analyze when user typically interacts with notifications
    // This is a simplified implementation
    return {
      'most_active_hours': [9, 10, 11, 14, 15, 16],
      'least_active_hours': [22, 23, 0, 1, 2, 3, 4, 5, 6, 7],
      'preferred_reminder_advance': const Duration(hours: 1),
      'response_rate': 0.75,
    };
  }

  bool _shouldRescheduleForOptimalTime(
    ScheduledNotification notification,
    Map<String, dynamic> patterns,
  ) {
    final hour = notification.scheduledTime.hour;
    final leastActiveHours = patterns['least_active_hours'] as List<int>;
    return leastActiveHours.contains(hour);
  }

  DateTime? _calculateOptimalTime(
    ScheduledNotification notification,
    Map<String, dynamic> patterns,
  ) {
    final mostActiveHours = patterns['most_active_hours'] as List<int>;
    final currentTime = notification.scheduledTime;
    
    // Find the next active hour
    for (final hour in mostActiveHours) {
      final proposedTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        hour,
        currentTime.minute,
      );
      
      if (proposedTime.isAfter(DateTime.now()) && 
          proposedTime.isBefore(currentTime.add(const Duration(hours: 8)))) {
        return proposedTime;
      }
    }
    
    return null;
  }

  Future<void> _rescheduleNotification(
    ScheduledNotification notification,
    DateTime newTime,
  ) async {
    await cancelNotification(notification.id);
    // Re-schedule with new time (simplified)
    if (kDebugMode) {
      print('Rescheduled notification ${notification.id} to $newTime');
    }
  }

  Future<bool> _shouldUseSmartScheduling() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('smart_scheduling_enabled') ?? true;
  }

  Future<DateTime?> _calculateOptimalScheduleTime(
    TaskModel task,
    DateTime proposedTime,
  ) async {
    final patterns = await _analyzeUserPatterns();
    return _calculateOptimalTime(
      ScheduledNotification(
        id: 0,
        taskId: task.id,
        type: NotificationTypeModel.taskReminder,
        scheduledTime: proposedTime,
        title: task.title,
        body: task.description ?? '',
        createdAt: DateTime.now(),
      ),
      patterns,
    );
  }

  Future<List<Duration>> _optimizeReminderIntervals(
    TaskModel task,
    List<Duration> intervals,
  ) async {
    // Apply intelligent spacing based on task priority
    // Future enhancement: analyze user patterns for optimal timing
    
    // Adjust intervals based on task priority
    return intervals.map((interval) {
      if (task.priority == TaskPriority.urgent) {
        return Duration(milliseconds: (interval.inMilliseconds * 0.7).round());
      } else if (task.priority == TaskPriority.low) {
        return Duration(milliseconds: (interval.inMilliseconds * 1.3).round());
      }
      return interval;
    }).toList();
  }

  Future<DateTime> _calculateOptimalSummaryTime(DateTime proposedTime) async {
    final patterns = await _analyzeUserPatterns();
    final mostActiveHours = patterns['most_active_hours'] as List<int>;
    
    // Schedule summary at start of most active period
    if (mostActiveHours.isNotEmpty) {
      return DateTime(
        proposedTime.year,
        proposedTime.month,
        proposedTime.day,
        mostActiveHours.first,
        0,
      );
    }
    
    return proposedTime;
  }

  Future<Map<String, dynamic>> _generateAnalyticsData() async {
    return {
      'total_sent': _history.length,
      'response_rate': _calculateResponseRate(),
      'most_effective_time': _findMostEffectiveTime(),
      'priority_distribution': _analyzePriorityDistribution(),
    };
  }

  double _calculateResponseRate() {
    if (_history.isEmpty) return 0.0;
    final responded = _history.where((entry) => entry.action != null).length;
    return responded / _history.length;
  }

  int _findMostEffectiveTime() {
    final hourCounts = <int, int>{};
    
    for (final entry in _history) {
      if (entry.action != null) {
        final hour = entry.sentAt.hour;
        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      }
    }
    
    if (hourCounts.isEmpty) return 9; // Default
    
    return hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  Map<String, int> _analyzePriorityDistribution() {
    final distribution = <String, int>{};
    
    for (final entry in _history) {
      final type = entry.type.displayName;
      distribution[type] = (distribution[type] ?? 0) + 1;
    }
    
    return distribution;
  }

  // Helper methods

  String _getPriorityIndicator(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return '[URGENT]';
      case TaskPriority.high:
        return '[HIGH]';
      case TaskPriority.medium:
        return '[MED]';
      case TaskPriority.low:
        return '[LOW]';
    }
  }

  String _formatDueTime(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    if (difference.inDays > 0) {
      return 'in ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} minutes';
    } else {
      return 'overdue';
    }
  }

  // Delegate remaining methods to base service
  @override
  Future<void> cancelNotification(int notificationId) =>
      _baseService.cancelNotification(notificationId);

  @override
  Future<void> cancelTaskNotifications(String taskId) =>
      _baseService.cancelTaskNotifications(taskId);

  @override
  Future<void> cancelAllNotifications() =>
      _baseService.cancelAllNotifications();

  @override
  Future<List<ScheduledNotification>> getScheduledNotifications() =>
      _baseService.getScheduledNotifications();

  @override
  Future<List<ScheduledNotification>> getTaskNotifications(String taskId) =>
      _baseService.getTaskNotifications(taskId);

  @override
  Future<void> handleNotificationAction({
    required String taskId,
    required NotificationAction action,
    Map<String, dynamic>? payload,
  }) async {
    await _baseService.handleNotificationAction(
      taskId: taskId,
      action: action,
      payload: payload,
    );
    
    _eventController?.add(NotificationEvent(
      type: 'enhanced_action',
      taskId: taskId,
      action: action,
      payload: payload,
    ));
  }

  @override
  Future<void> updateSettings(NotificationSettings settings) =>
      _baseService.updateSettings(settings);

  @override
  Future<NotificationSettings> getSettings() =>
      _baseService.getSettings();

  @override
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? taskId,
    NotificationTypeModel type = NotificationTypeModel.taskReminder,
    Map<String, dynamic>? payload,
  }) =>
      _baseService.showImmediateNotification(
        title: title,
        body: body,
        taskId: taskId,
        type: type,
        payload: payload,
      );

  @override
  Future<void> showNotification({
    required String title,
    required String body,
    String? taskId,
    NotificationTypeModel type = NotificationTypeModel.taskReminder,
    Map<String, dynamic>? payload,
  }) => showImmediateNotification(
    title: title,
    body: body,
    taskId: taskId,
    type: type,
    payload: payload,
  );

  @override
  Future<int?> scheduleNotification({
    required TaskModel task,
    required DateTime scheduledTime,
    Duration? customReminder,
  }) => scheduleTaskReminder(
    task: task,
    scheduledTime: scheduledTime,
    customReminder: customReminder,
  );

  @override
  Future<void> rescheduleAllNotifications() =>
      _baseService.rescheduleAllNotifications();

  @override
  Future<bool> shouldSendNotification(DateTime scheduledTime) =>
      _baseService.shouldSendNotification(scheduledTime);

  @override
  Future<DateTime?> getNextNotificationTime(String taskId) =>
      _baseService.getNextNotificationTime(taskId);

  /// Dispose of resources
  void dispose() {
    _smartSchedulingTimer?.cancel();
    _analyticsTimer?.cancel();
    _eventController?.close();
    _baseService.dispose();
  }

  /// Advanced API methods
  
  /// Get notification templates
  List<NotificationTemplate> getNotificationTemplates() {
    return _templates.values.toList();
  }

  /// Add custom notification template
  Future<void> addNotificationTemplate(NotificationTemplate template) async {
    _templates[template.id] = template;
  }

  /// Get notification groups
  List<NotificationGroup> getNotificationGroups() {
    return _groups.values.toList();
  }

  /// Create notification group
  Future<NotificationGroup> createNotificationGroup({
    required String name,
    required String description,
  }) async {
    final group = NotificationGroup(
      id: 'group_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _groups[group.id] = group;
    return group;
  }

  /// Get notification history
  List<NotificationHistoryEntry> getNotificationHistory({
    int? limit,
    NotificationTypeModel? type,
    String? taskId,
  }) {
    var filtered = _history.asMap().entries;
    
    if (type != null) {
      filtered = filtered.where((entry) => entry.value.type == type);
    }
    
    if (taskId != null) {
      filtered = filtered.where((entry) => entry.value.taskId == taskId);
    }
    
    final result = filtered.map((entry) => entry.value).toList();
    
    if (limit != null && result.length > limit) {
      return result.take(limit).toList();
    }
    
    return result;
  }

  /// Get notification statistics
  Future<NotificationStats> getNotificationStats() async {
    final scheduled = await getScheduledNotifications();
    final todayScheduled = scheduled.where((n) => 
        DateTime(n.scheduledTime.year, n.scheduledTime.month, n.scheduledTime.day) ==
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
    ).length;

    return NotificationStats(
      totalScheduled: scheduled.length,
      todayScheduled: todayScheduled,
      pendingNotifications: scheduled.where((n) => !n.sent).length,
      sentNotifications: _history.length,
      actedUponNotifications: _history.where((h) => h.action != null).length,
      averageResponseTime: _calculateAverageResponseTime(),
    );
  }

  double? _calculateAverageResponseTime() {
    final respondedEntries = _history.where((entry) => 
        entry.action != null && entry.actionAt != null).toList();
    
    if (respondedEntries.isEmpty) return null;
    
    final totalMinutes = respondedEntries.fold<int>(0, (sum, entry) =>
        sum + entry.actionAt!.difference(entry.sentAt).inMinutes);
    
    return totalMinutes / respondedEntries.length;
  }
}