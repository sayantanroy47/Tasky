import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/task_model.dart';
import '../../../domain/entities/task_enums.dart';
import 'notification_service.dart';
import 'notification_models.dart';

/// Local notification service implementation using flutter_local_notifications
class LocalNotificationService implements NotificationService {
  static const String _settingsKey = 'notification_settings';
  static const String _scheduledNotificationsKey = 'scheduled_notifications';
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final StreamController<NotificationEvent> _eventController = StreamController<NotificationEvent>.broadcast();
  
  bool _initialized = false;
  NotificationSettings _settings = const NotificationSettings();
  final List<ScheduledNotification> _scheduledNotifications = [];

  @override
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      // Initialize notification settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationResponse,
      );

      if (initialized == true) {
        await _loadSettings();
        await _loadScheduledNotifications();
        _initialized = true;
        
        // Schedule periodic cleanup of sent notifications
        _schedulePeriodicCleanup();
        
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Failed to initialize notification service: $e');
      return false;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result == true;
    }
    return false;
  }

  @override
  Future<bool> get hasPermissions async {
    if (Platform.isAndroid) {
      return await Permission.notification.isGranted;
    } else if (Platform.isIOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return result?.isEnabled == true;
    }
    return false;
  }

  @override
  Future<int?> scheduleTaskReminder({
    required TaskModel task,
    required DateTime scheduledTime,
    Duration? customReminder,
  }) async {
    if (!_initialized || !_settings.enabled) return null;
    
    if (!(await shouldSendNotification(scheduledTime))) return null;

    final notificationId = _generateNotificationId();
    
    final title = 'Task Reminder';
    final body = task.title;
    final payload = {
      'taskId': task.id,
      'type': NotificationType.taskReminder.name,
      'action': 'view',
    };

    final scheduledNotification = ScheduledNotification(
      id: notificationId,
      taskId: task.id,
      type: NotificationType.taskReminder,
      scheduledTime: scheduledTime,
      title: title,
      body: body,
      payload: payload,
      createdAt: DateTime.now(),
    );

    await _scheduleNotification(scheduledNotification);
    _scheduledNotifications.add(scheduledNotification);
    await _saveScheduledNotifications();

    return notificationId;
  }

  @override
  Future<List<int>> scheduleMultipleReminders({
    required TaskModel task,
    required List<Duration> reminderIntervals,
  }) async {
    if (task.dueDate == null) return [];
    
    final notificationIds = <int>[];
    
    for (final interval in reminderIntervals) {
      final scheduledTime = task.dueDate!.subtract(interval);
      
      // Don't schedule notifications in the past
      if (scheduledTime.isBefore(DateTime.now())) continue;
      
      final id = await scheduleTaskReminder(
        task: task,
        scheduledTime: scheduledTime,
        customReminder: interval,
      );
      
      if (id != null) {
        notificationIds.add(id);
      }
    }
    
    return notificationIds;
  }

  @override
  Future<int?> scheduleDailySummary({
    required DateTime scheduledTime,
    required List<TaskModel> tasks,
  }) async {
    if (!_initialized || !_settings.enabled || !_settings.dailySummary) return null;
    
    if (!(await shouldSendNotification(scheduledTime))) return null;

    final notificationId = _generateNotificationId();
    final pendingTasks = tasks.where((t) => t.status.isActive).length;
    final overdueTasks = tasks.where((t) => t.isOverdue).length;
    
    final title = 'Daily Task Summary';
    String body;
    
    if (pendingTasks == 0) {
      body = 'Great! You have no pending tasks today.';
    } else {
      body = 'You have $pendingTasks pending task${pendingTasks == 1 ? '' : 's'}';
      if (overdueTasks > 0) {
        body += ' ($overdueTasks overdue)';
      }
    }

    final payload = {
      'type': NotificationType.dailySummary.name,
      'taskCount': pendingTasks,
      'overdueCount': overdueTasks,
    };

    final scheduledNotification = ScheduledNotification(
      id: notificationId,
      taskId: '', // Daily summary doesn't belong to a specific task
      type: NotificationType.dailySummary,
      scheduledTime: scheduledTime,
      title: title,
      body: body,
      payload: payload,
      createdAt: DateTime.now(),
    );

    await _scheduleNotification(scheduledNotification);
    _scheduledNotifications.add(scheduledNotification);
    await _saveScheduledNotifications();

    return notificationId;
  }

  @override
  Future<int?> scheduleOverdueNotification({
    required TaskModel task,
  }) async {
    if (!_initialized || !_settings.enabled || !_settings.overdueNotifications) return null;
    
    final notificationId = _generateNotificationId();
    final scheduledTime = DateTime.now().add(const Duration(minutes: 1)); // Send immediately
    
    final title = 'Overdue Task';
    final body = '${task.title} is overdue';
    final payload = {
      'taskId': task.id,
      'type': NotificationType.overdueTask.name,
      'action': 'view',
    };

    final scheduledNotification = ScheduledNotification(
      id: notificationId,
      taskId: task.id,
      type: NotificationType.overdueTask,
      scheduledTime: scheduledTime,
      title: title,
      body: body,
      payload: payload,
      createdAt: DateTime.now(),
    );

    await _scheduleNotification(scheduledNotification);
    _scheduledNotifications.add(scheduledNotification);
    await _saveScheduledNotifications();

    return notificationId;
  }

  @override
  Future<void> cancelNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
    _scheduledNotifications.removeWhere((n) => n.id == notificationId);
    await _saveScheduledNotifications();
  }

  @override
  Future<void> cancelTaskNotifications(String taskId) async {
    final taskNotifications = _scheduledNotifications.where((n) => n.taskId == taskId).toList();
    
    for (final notification in taskNotifications) {
      await _notifications.cancel(notification.id);
    }
    
    _scheduledNotifications.removeWhere((n) => n.taskId == taskId);
    await _saveScheduledNotifications();
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    _scheduledNotifications.clear();
    await _saveScheduledNotifications();
  }

  @override
  Future<List<ScheduledNotification>> getScheduledNotifications() async {
    return List.from(_scheduledNotifications);
  }

  @override
  Future<List<ScheduledNotification>> getTaskNotifications(String taskId) async {
    return _scheduledNotifications.where((n) => n.taskId == taskId).toList();
  }

  @override
  Future<void> handleNotificationAction({
    required String taskId,
    required NotificationAction action,
    Map<String, dynamic>? payload,
  }) async {
    _eventController.add(NotificationEvent(
      type: 'action',
      taskId: taskId,
      action: action,
      payload: payload,
    ));
  }

  @override
  Future<void> updateSettings(NotificationSettings settings) async {
    _settings = settings;
    await _saveSettings();
    
    if (!settings.enabled) {
      await cancelAllNotifications();
    }
  }

  @override
  Future<NotificationSettings> getSettings() async {
    return _settings;
  }

  @override
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? taskId,
    NotificationType type = NotificationType.taskReminder,
    Map<String, dynamic>? payload,
  }) async {
    if (!_initialized || !_settings.enabled) return;

    final notificationId = _generateNotificationId();
    
    await _notifications.show(
      notificationId,
      title,
      body,
      _getNotificationDetails(type),
      payload: jsonEncode(payload ?? {}),
    );
  }

  @override
  Future<void> rescheduleAllNotifications() async {
    // Cancel all existing notifications
    await _notifications.cancelAll();
    
    // Reschedule all non-sent notifications
    final activeNotifications = _scheduledNotifications
        .where((n) => !n.sent && n.scheduledTime.isAfter(DateTime.now()))
        .toList();
    
    for (final notification in activeNotifications) {
      await _scheduleNotification(notification);
    }
  }

  @override
  Future<bool> shouldSendNotification(DateTime scheduledTime) async {
    if (!_settings.enabled) return false;
    
    // Check quiet hours
    if (_settings.quietHoursStart != null && _settings.quietHoursEnd != null) {
      final hour = scheduledTime.hour;
      final minute = scheduledTime.minute;
      final currentTime = hour * 60 + minute;
      
      final startTime = _settings.quietHoursStart!.hour * 60 + _settings.quietHoursStart!.minute;
      final endTime = _settings.quietHoursEnd!.hour * 60 + _settings.quietHoursEnd!.minute;
      
      if (startTime <= endTime) {
        // Same day quiet hours
        if (currentTime >= startTime && currentTime <= endTime) {
          return false;
        }
      } else {
        // Overnight quiet hours
        if (currentTime >= startTime || currentTime <= endTime) {
          return false;
        }
      }
    }
    
    return true;
  }

  @override
  Future<DateTime?> getNextNotificationTime(String taskId) async {
    final taskNotifications = _scheduledNotifications
        .where((n) => n.taskId == taskId && !n.sent && n.scheduledTime.isAfter(DateTime.now()))
        .toList();
    
    if (taskNotifications.isEmpty) return null;
    
    taskNotifications.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return taskNotifications.first.scheduledTime;
  }

  @override
  Stream<NotificationEvent> get notificationEvents => _eventController.stream;

  // Private helper methods

  Future<void> _scheduleNotification(ScheduledNotification notification) async {
    await _notifications.zonedSchedule(
      notification.id,
      notification.title,
      notification.body,
      _convertToTZDateTime(notification.scheduledTime),
      _getNotificationDetails(notification.type),
      payload: jsonEncode(notification.payload),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  NotificationDetails _getNotificationDetails(NotificationType type) {
    switch (type) {
      case NotificationType.taskReminder:
        return _getTaskReminderNotificationDetails();
      case NotificationType.overdueTask:
        return _getOverdueTaskNotificationDetails();
      case NotificationType.dailySummary:
        return _getDailySummaryNotificationDetails();
      case NotificationType.taskCompleted:
        return _getTaskCompletedNotificationDetails();
      case NotificationType.locationReminder:
        return _getLocationReminderNotificationDetails();
    }
  }

  NotificationDetails _getTaskReminderNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'task_reminder_channel',
      'Task Reminders',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      category: AndroidNotificationCategory.reminder,
      actions: [
        AndroidNotificationAction(
          'complete',
          'Complete',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'snooze',
          'Snooze 15m',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'view',
          'View',
          showsUserInterface: true,
          cancelNotification: false,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'task_reminder',
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  NotificationDetails _getOverdueTaskNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'overdue_task_channel',
      'Overdue Tasks',
      channelDescription: 'Notifications for overdue tasks',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      enableVibration: true,
      category: AndroidNotificationCategory.reminder,
      color: Color(0xFFFF5722), // Red color for overdue
      actions: [
        AndroidNotificationAction(
          'complete',
          'Complete Now',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'reschedule',
          'Reschedule',
          showsUserInterface: true,
          cancelNotification: false,
        ),
        AndroidNotificationAction(
          'view',
          'View Details',
          showsUserInterface: true,
          cancelNotification: false,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'overdue_task',
      interruptionLevel: InterruptionLevel.critical,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  NotificationDetails _getDailySummaryNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'daily_summary_channel',
      'Daily Summary',
      channelDescription: 'Daily task summary notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
      enableVibration: false,
      category: AndroidNotificationCategory.status,
      styleInformation: BigTextStyleInformation(''),
      actions: [
        AndroidNotificationAction(
          'view_tasks',
          'View Tasks',
          showsUserInterface: true,
          cancelNotification: false,
        ),
        AndroidNotificationAction(
          'add_task',
          'Add Task',
          showsUserInterface: true,
          cancelNotification: false,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
      categoryIdentifier: 'daily_summary',
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  NotificationDetails _getTaskCompletedNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'task_completed_channel',
      'Task Completed',
      channelDescription: 'Notifications for completed tasks',
      importance: Importance.low,
      priority: Priority.low,
      showWhen: true,
      enableVibration: false,
      category: AndroidNotificationCategory.status,
      color: Color(0xFF4CAF50), // Green color for completed
      timeoutAfter: 5000, // Auto-dismiss after 5 seconds
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
      categoryIdentifier: 'task_completed',
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  NotificationDetails _getLocationReminderNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'location_reminder_channel',
      'Location Reminders',
      channelDescription: 'Location-based task reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      category: AndroidNotificationCategory.reminder,
      actions: [
        AndroidNotificationAction(
          'complete',
          'Complete',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'view',
          'View Task',
          showsUserInterface: true,
          cancelNotification: false,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'location_reminder',
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  int _generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  // Convert DateTime to TZDateTime (required for scheduling)
  // Note: This is a simplified implementation. In a real app, you'd use the timezone package
  dynamic _convertToTZDateTime(DateTime dateTime) {
    return dateTime; // Simplified - flutter_local_notifications will handle this
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        final taskId = data['taskId'] as String?;
        final actionName = response.actionId ?? 'view';
        
        NotificationAction? action;
        switch (actionName) {
          case 'complete':
            action = NotificationAction.complete;
            break;
          case 'snooze':
            action = NotificationAction.snooze;
            break;
          case 'view':
            action = NotificationAction.view;
            break;
          default:
            action = NotificationAction.view;
        }
        
        if (taskId != null) {
          handleNotificationAction(
            taskId: taskId,
            action: action,
            payload: data,
          );
        }
      } catch (e) {
        debugPrint('Error handling notification response: $e');
      }
    }
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    // Handle background notification responses
    // This would typically involve calling a background service
    debugPrint('Background notification response: ${response.payload}');
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
        _settings = NotificationSettings.fromJson(settingsMap);
      }
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(_settings.toJson());
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
  }

  Future<void> _loadScheduledNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString(_scheduledNotificationsKey);
      
      if (notificationsJson != null) {
        final notificationsList = jsonDecode(notificationsJson) as List<dynamic>;
        _scheduledNotifications.clear();
        
        for (final notificationMap in notificationsList) {
          final notification = ScheduledNotification.fromJson(notificationMap as Map<String, dynamic>);
          _scheduledNotifications.add(notification);
        }
      }
    } catch (e) {
      debugPrint('Error loading scheduled notifications: $e');
    }
  }

  Future<void> _saveScheduledNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsList = _scheduledNotifications.map((n) => n.toJson()).toList();
      final notificationsJson = jsonEncode(notificationsList);
      await prefs.setString(_scheduledNotificationsKey, notificationsJson);
    } catch (e) {
      debugPrint('Error saving scheduled notifications: $e');
    }
  }

  void _schedulePeriodicCleanup() {
    // Clean up sent notifications every hour
    Timer.periodic(const Duration(hours: 1), (timer) {
      _cleanupSentNotifications();
    });
  }

  void _cleanupSentNotifications() {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(days: 7)); // Keep notifications for 7 days
    
    _scheduledNotifications.removeWhere((notification) {
      return notification.sent && notification.scheduledTime.isBefore(cutoff);
    });
    
    _saveScheduledNotifications();
  }

  void dispose() {
    _eventController.close();
  }
}