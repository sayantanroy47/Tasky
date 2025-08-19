import 'dart:async';
import 'package:flutter/material.dart';

import '../../../domain/entities/task_model.dart';
import '../../../domain/entities/task_enums.dart';
import '../../../domain/repositories/task_repository.dart';
import '../../../domain/models/enums.dart';
import 'notification_service.dart';
import 'notification_models.dart';
import 'local_notification_service.dart';

/// High-level notification manager that coordinates notification scheduling
/// and handles business logic for different types of notifications
class NotificationManager {
  final NotificationService _notificationService;
  final TaskRepository _taskRepository;
  NotificationSettings settings;
  
  Timer? _dailySummaryTimer;
  Timer? _overdueCheckTimer;
  StreamSubscription? _notificationEventSubscription;

  NotificationManager({
    NotificationService? notificationService,
    required TaskRepository taskRepository,
    this.settings = const NotificationSettings(),
  }) : _notificationService = notificationService ?? LocalNotificationService(taskRepository),
        _taskRepository = taskRepository {
    _setupEventHandling();
  }

  /// Initialize the notification manager
  Future<bool> initialize() async {
    final initialized = await _notificationService.initialize();
    
    if (initialized) {
      // Load persisted notifications first
      if (_notificationService is LocalNotificationService) {
        await (_notificationService as LocalNotificationService).loadPersistedNotifications();
      }
      
      // Process immediate overdue notifications
      if (_notificationService is LocalNotificationService) {
        await (_notificationService as LocalNotificationService).processImmediateOverdueNotifications();
      }
      
      await _setupPeriodicTasks();
      await _rescheduleExistingTaskNotifications();
    }
    
    return initialized;
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    return await _notificationService.requestPermissions();
  }

  /// Check if permissions are granted
  Future<bool> get hasPermissions => _notificationService.hasPermissions;

  /// Schedule notifications for a task based on its due date and user settings
  Future<void> scheduleTaskNotifications(TaskModel task) async {
    if (task.dueDate == null) return;

    // Cancel existing notifications for this task
    await _notificationService.cancelTaskNotifications(task.id);
    if (!settings.enabled) return;

    try {
      // Schedule default reminder
      final defaultReminderTime = task.dueDate!.subtract(settings.defaultReminder);
      if (defaultReminderTime.isAfter(DateTime.now())) {
        final notificationId = await _notificationService.scheduleTaskReminder(
          task: task,
          scheduledTime: defaultReminderTime,
        );
        
        if (notificationId == null) {
          // Retry failed scheduling
          await _retryScheduleTaskReminder(task, defaultReminderTime, 0);
        }
      }

      // Schedule additional reminders based on priority
      final additionalReminders = _getAdditionalReminders(task.priority);
      if (additionalReminders.isNotEmpty) {
        final scheduledIds = await _notificationService.scheduleMultipleReminders(
          task: task,
          reminderIntervals: additionalReminders,
        );
        
        // Check if any reminders failed and retry
        if (scheduledIds.length < additionalReminders.length) {
          await _retryMultipleReminders(task, additionalReminders, scheduledIds);
        }
      }

      // Schedule overdue notification if task becomes overdue
      if (settings.overdueNotifications) {
        // Check if task is already overdue
        if (task.dueDate!.isBefore(DateTime.now())) {
          await _notificationService.scheduleOverdueNotification(task: task);
        } else {
          // Schedule overdue check for 1 hour after due date
          final overdueCheckTime = task.dueDate!.add(const Duration(hours: 1));
          if (overdueCheckTime.isAfter(DateTime.now())) {
            Timer(overdueCheckTime.difference(DateTime.now()), () async {
              final updatedTask = await _taskRepository.getTaskById(task.id);
              if (updatedTask != null && updatedTask.isOverdue && updatedTask.status.isActive) {
                await _notificationService.scheduleOverdueNotification(task: updatedTask);
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error scheduling task notifications: $e');
      // Attempt to reschedule after a delay
      Timer(const Duration(minutes: 5), () {
        scheduleTaskNotifications(task);
      });
    }
  }

  /// Update notifications when a task is modified
  Future<void> updateTaskNotifications(TaskModel task) async {
    await scheduleTaskNotifications(task);
  }

  /// Remove all notifications for a task (when task is completed or deleted)
  Future<void> removeTaskNotifications(String taskId) async {
    await _notificationService.cancelTaskNotifications(taskId);
  }

  /// Schedule daily summary notification
  Future<void> scheduleDailySummary() async {
    if (!settings.enabled || !settings.dailySummary) return;

    final now = DateTime.now();
    final summaryTime = DateTime(
      now.year,
      now.month,
      now.day,
      settings.dailySummaryTime.hour,
      settings.dailySummaryTime.minute,
    );

    // If today's summary time has passed, schedule for tomorrow
    final scheduledTime = summaryTime.isBefore(now) 
        ? summaryTime.add(const Duration(days: 1))
        : summaryTime;

    final tasks = await _taskRepository.getAllTasks();
    await _notificationService.scheduleDailySummary(
      scheduledTime: scheduledTime,
      tasks: tasks,
    );
  }

  /// Update notification settings
  Future<void> updateSettings(NotificationSettings newSettings) async {
    settings = newSettings;
    await _notificationService.updateSettings(newSettings);
    
    // Reschedule all notifications with new settings
    await _notificationService.rescheduleAllNotifications();
    
    // Update periodic tasks
    await _setupPeriodicTasks();
  }

  /// Get current notification settings
  Future<NotificationSettings> getSettings() async {
    return settings;
  }

  /// Get all scheduled notifications
  Future<List<ScheduledNotification>> getScheduledNotifications() async {
    return await _notificationService.getScheduledNotifications();
  }

  /// Show immediate notification for testing
  Future<void> showTestNotification() async {
    await _notificationService.showImmediateNotification(
      title: 'Test Notification',
      body: 'This is a test notification from Task Tracker',
      type: NotificationTypeModel.taskReminder,
    );
  }

  /// Handle notification actions (complete, snooze, etc.)
  Future<void> handleNotificationAction({
    required String taskId,
    required NotificationAction action,
    Map<String, dynamic>? payload,
  }) async {
    switch (action) {
      case NotificationAction.complete:
        await _completeTaskFromNotification(taskId);
        break;
      case NotificationAction.snooze:
        await _snoozeTaskNotification(taskId);
        break;
      case NotificationAction.reschedule:
        await _rescheduleTaskNotification(taskId);
        break;
      case NotificationAction.postpone:
        await _postponeTaskNotification(taskId);
        break;
      case NotificationAction.view:
        // This would typically navigate to the task detail screen
        // The UI layer should handle this through the event stream
        break;
      case NotificationAction.dismiss:
        // Just dismiss the notification, no action needed
        break;
      default:
        // Handle any other actions
        break;
    }
    
    // Log the action for notification history
    await _logNotificationAction(taskId, action, payload);
  }

  /// Schedule enhanced daily summary with detailed task breakdown
  Future<void> scheduleEnhancedDailySummary() async {
    if (!settings.enabled || !settings.dailySummary) return;

    final now = DateTime.now();
    final summaryTime = DateTime(
      now.year,
      now.month,
      now.day,
      settings.dailySummaryTime.hour,
      settings.dailySummaryTime.minute,
    );

    // If today's summary time has passed, schedule for tomorrow
    final scheduledTime = summaryTime.isBefore(now) 
        ? summaryTime.add(const Duration(days: 1))
        : summaryTime;

    final tasks = await _taskRepository.getAllTasks();
    final todayTasks = tasks.where((task) => task.isDueToday).toList();
    final overdueTasks = tasks.where((task) => task.isOverdue).toList();
    final upcomingTasks = tasks.where((task) => 
      task.dueDate != null && 
      task.dueDate!.isAfter(DateTime.now()) && 
      task.dueDate!.isBefore(DateTime.now().add(const Duration(days: 3)))
    ).toList();

    await _scheduleDetailedDailySummary(
      scheduledTime: scheduledTime,
      todayTasks: todayTasks,
      overdueTasks: overdueTasks,
      upcomingTasks: upcomingTasks,
    );
  }

  /// Get notification history for analytics
  Future<List<NotificationHistoryEntry>> getNotificationHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? taskId,
  }) async {
    // This would typically be stored in a database
    // For now, return empty list as placeholder
    return [];
  }

  /// Get notification statistics
  Future<NotificationStats> getNotificationStats() async {
    final notifications = await _notificationService.getScheduledNotifications();
    final now = DateTime.now();
    
    final todayNotifications = notifications.where((n) => 
      n.scheduledTime.year == now.year &&
      n.scheduledTime.month == now.month &&
      n.scheduledTime.day == now.day
    ).length;
    
    final pendingNotifications = notifications.where((n) => 
      !n.sent && n.scheduledTime.isAfter(now)
    ).length;
    
    final sentNotifications = notifications.where((n) => n.sent).length;
    
    return NotificationStats(
      totalScheduled: notifications.length,
      todayScheduled: todayNotifications,
      pendingNotifications: pendingNotifications,
      sentNotifications: sentNotifications,
    );
  }

  /// Stream of notification events for the UI to handle
  Stream<NotificationEvent> get notificationEvents => _notificationService.notificationEvents;

  // Private helper methods

  List<Duration> _getAdditionalReminders(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return [
          const Duration(days: 1),
          const Duration(hours: 4),
          const Duration(hours: 1),
          const Duration(minutes: 15),
        ];
      case TaskPriority.high:
        return [
          const Duration(hours: 4),
          const Duration(hours: 1),
        ];
      case TaskPriority.medium:
        return [
          const Duration(hours: 2),
        ];
      case TaskPriority.low:
        return [];
    }
  }

  Future<void> _setupPeriodicTasks() async {
    // Cancel existing timers
    _dailySummaryTimer?.cancel();
    _overdueCheckTimer?.cancel();
    // Setup daily summary timer
    if (settings.enabled && settings.dailySummary) {
      _dailySummaryTimer = Timer.periodic(const Duration(days: 1), (timer) {
        scheduleDailySummary();
      });
      
      // Schedule initial daily summary
      await scheduleDailySummary();
    }

    // Setup overdue check timer (every hour)
    if (settings.enabled && settings.overdueNotifications) {
      _overdueCheckTimer = Timer.periodic(const Duration(hours: 1), (timer) {
        _checkOverdueTasks();
      });
    }
  }

  Future<void> _rescheduleExistingTaskNotifications() async {
    try {
      final tasks = await _taskRepository.getAllTasks();
      final activeTasks = tasks.where((task) => 
        task.status.isActive && task.dueDate != null && task.dueDate!.isAfter(DateTime.now())
      );

      for (final task in activeTasks) {
        await scheduleTaskNotifications(task);
      }
    } catch (e) {
      debugPrint('Error rescheduling task notifications: $e');
    }
  }

  Future<void> _checkOverdueTasks() async {
    try {
      final tasks = await _taskRepository.getAllTasks();
      final overdueTasks = tasks.where((task) => task.isOverdue && task.status.isActive);

      for (final task in overdueTasks) {
        // Check if we've already sent an overdue notification for this task
        final existingNotifications = await _notificationService.getTaskNotifications(task.id);
        final hasOverdueNotification = existingNotifications.any(
          (n) => n.type == NotificationTypeModel.overdueTask && n.sent
        );

        if (!hasOverdueNotification) {
          await _notificationService.scheduleOverdueNotification(task: task);
        }
      }
    } catch (e) {
      debugPrint('Error checking overdue tasks: $e');
    }
  }


  Future<void> _completeTaskFromNotification(String taskId) async {
    try {
      final task = await _taskRepository.getTaskById(taskId);
      if (task != null && task.status.isActive) {
        final completedTask = task.markCompleted();
        await _taskRepository.updateTask(completedTask);
        
        // Cancel remaining notifications for this task
        await _notificationService.cancelTaskNotifications(taskId);
        
        // Show completion confirmation
        await _notificationService.showImmediateNotification(
          title: 'Task Completed',
          body: '${task.title} has been marked as completed',
          taskId: taskId,
          type: NotificationTypeModel.taskCompleted,
        );
      }
    } catch (e) {
      debugPrint('Error completing task from notification: $e');
    }
  }

  Future<void> _snoozeTaskNotification(String taskId) async {
    try {
      final task = await _taskRepository.getTaskById(taskId);
      if (task != null && task.status.isActive) {
        // Cancel existing notifications
        await _notificationService.cancelTaskNotifications(taskId);
        
        // Schedule new notification in 15 minutes
        final snoozeTime = DateTime.now().add(const Duration(minutes: 15));
        await _notificationService.scheduleTaskReminder(
          task: task,
          scheduledTime: snoozeTime,
        );
      }
    } catch (e) {
      debugPrint('Error snoozing task notification: $e');
    }
  }

  Future<void> _rescheduleTaskNotification(String taskId) async {
    try {
      final task = await _taskRepository.getTaskById(taskId);
      if (task != null && task.status.isActive) {
        // Cancel existing notifications
        await _notificationService.cancelTaskNotifications(taskId);
        
        // Schedule new notification in 1 hour (for reschedule)
        final rescheduleTime = DateTime.now().add(const Duration(hours: 1));
        await _notificationService.scheduleTaskReminder(
          task: task,
          scheduledTime: rescheduleTime,
        );
      }
    } catch (e) {
      debugPrint('Error rescheduling task notification: $e');
    }
  }

  Future<void> _postponeTaskNotification(String taskId) async {
    try {
      final task = await _taskRepository.getTaskById(taskId);
      if (task != null && task.status.isActive) {
        // Cancel existing notifications
        await _notificationService.cancelTaskNotifications(taskId);
        
        // Schedule new notification in 4 hours (for postpone)
        final postponeTime = DateTime.now().add(const Duration(hours: 4));
        await _notificationService.scheduleTaskReminder(
          task: task,
          scheduledTime: postponeTime,
        );
      }
    } catch (e) {
      debugPrint('Error postponing task notification: $e');
    }
  }

  Future<void> _scheduleDetailedDailySummary({
    required DateTime scheduledTime,
    required List<TaskModel> todayTasks,
    required List<TaskModel> overdueTasks,
    required List<TaskModel> upcomingTasks,
  }) async {
    const String title = 'Daily Task Summary';
    final String body = _buildDailySummaryBody(todayTasks, overdueTasks, upcomingTasks);
    
    final payload = {
      'type': NotificationTypeModel.dailySummary.name,
      'todayCount': todayTasks.length,
      'overdueCount': overdueTasks.length,
      'upcomingCount': upcomingTasks.length,
    };

    await _notificationService.showImmediateNotification(
      title: title,
      body: body,
      type: NotificationTypeModel.dailySummary,
      payload: payload,
    );
  }

  String _buildDailySummaryBody(
    List<TaskModel> todayTasks,
    List<TaskModel> overdueTasks,
    List<TaskModel> upcomingTasks,
  ) {
    final buffer = StringBuffer();
    
    if (overdueTasks.isNotEmpty) {
      buffer.write('${overdueTasks.length} overdue task${overdueTasks.length == 1 ? '' : 's'}');
    }
    
    if (todayTasks.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' • ');
      buffer.write('${todayTasks.length} due today');
    }
    
    if (upcomingTasks.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' • ');
      buffer.write('${upcomingTasks.length} upcoming');
    }
    
    if (buffer.isEmpty) {
      return 'All caught up! No pending tasks.';
    }
    
    return buffer.toString();
  }

  Future<void> _logNotificationAction(
    String taskId,
    NotificationAction action,
    Map<String, dynamic>? payload,
  ) async {
    // This would typically save to a database for analytics
    // For now, just log to debug console
    debugPrint('Notification action: $action for task $taskId');
  }

  /// Retry scheduling a task reminder with exponential backoff
  Future<void> _retryScheduleTaskReminder(TaskModel task, DateTime scheduledTime, int attemptCount) async {
    if (attemptCount >= 3) {
      debugPrint('Max retry attempts reached for task ${task.id} reminder');
      return;
    }

    final delayMinutes = (attemptCount + 1) * 2; // 2, 4, 6 minutes
    await Future.delayed(Duration(minutes: delayMinutes));

    try {
      final notificationId = await _notificationService.scheduleTaskReminder(
        task: task,
        scheduledTime: scheduledTime,
      );

      if (notificationId != null) {
        debugPrint('Successfully retried reminder for task ${task.id} (attempt ${attemptCount + 1})');
      } else {
        await _retryScheduleTaskReminder(task, scheduledTime, attemptCount + 1);
      }
    } catch (e) {
      debugPrint('Retry attempt ${attemptCount + 1} failed for task ${task.id}: $e');
      await _retryScheduleTaskReminder(task, scheduledTime, attemptCount + 1);
    }
  }

  /// Retry scheduling multiple reminders
  Future<void> _retryMultipleReminders(TaskModel task, List<Duration> intervals, List<int> scheduledIds) async {
    final failedCount = intervals.length - scheduledIds.length;
    debugPrint('Retrying $failedCount failed reminder(s) for task ${task.id}');

    // Wait a bit before retrying
    await Future.delayed(const Duration(minutes: 1));

    try {
      final retryIds = await _notificationService.scheduleMultipleReminders(
        task: task,
        reminderIntervals: intervals,
      );

      debugPrint('Retry scheduled ${retryIds.length} reminders for task ${task.id}');
    } catch (e) {
      debugPrint('Failed to retry multiple reminders for task ${task.id}: $e');
    }
  }

  void _setupEventHandling() {
    _notificationEventSubscription = _notificationService.notificationEvents.listen(
      (event) {
        if (event.type == 'action' && event.taskId != null && event.action != null) {
          handleNotificationAction(
            taskId: event.taskId!,
            action: event.action!,
            payload: event.payload,
          );
        }
      },
      onError: (error) {
        debugPrint('Error handling notification event: $error');
      },
    );
  }

  /// Dispose of resources
  void dispose() {
    _dailySummaryTimer?.cancel();
    _overdueCheckTimer?.cancel();
    _notificationEventSubscription?.cancel();
    
    if (_notificationService is LocalNotificationService) {
      (_notificationService as LocalNotificationService).dispose();
    }
  }
}
