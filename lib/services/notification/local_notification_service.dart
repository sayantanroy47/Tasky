import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../domain/repositories/task_repository.dart';
import 'notification_service.dart';
import 'notification_models.dart';

/// Local notification service implementation using flutter_local_notifications
class LocalNotificationService implements NotificationService {
  static const String _channelId = 'task_reminders';
  static const String _channelName = 'Task Reminders';
  static const String _channelDescription = 'Notifications for task reminders and updates';
  
  // SharedPreferences keys for settings persistence
  static const String _keyNotificationSettings = 'notification_settings';
  
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final TaskRepository _taskRepository;
  final StreamController<NotificationEvent> _eventController;
  
  NotificationSettings _settings = const NotificationSettings();
  
  LocalNotificationService(this._taskRepository) 
      : _notificationsPlugin = FlutterLocalNotificationsPlugin(),
        _eventController = StreamController<NotificationEvent>.broadcast() {
    _loadSavedSettings();
  }
  
  @override
  Stream<NotificationEvent> get notificationEvents => _eventController.stream;
  
  @override
  Future<bool> initialize() async {
    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      
      // Android initialization settings
      const androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization settings
      const iosInitializationSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      // Combined initialization settings
      const initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      );
      
      // Initialize with settings and callback
      final initialized = await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      if (initialized ?? false) {
        await _createNotificationChannel();
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      return false;
    }
  }
  
  /// Creates the notification channel for Android
  Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      const androidNotificationChannel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      );
      
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidNotificationChannel);
    }
  }
  
  @override
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      final granted = await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      
      final granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    
    return true; // Other platforms assume granted
  }
  
  @override
  Future<bool> get hasPermissions async {
    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }
    
    return true; // Assume enabled for other platforms
  }
  
  @override
  Future<int?> scheduleTaskReminder({
    required TaskModel task,
    required DateTime scheduledTime,
    Duration? customReminder,
  }) async {
    if (scheduledTime.isBefore(DateTime.now())) {
      return null; // Don't schedule notifications in the past
    }
    
    if (!_settings.enabled) {
      return null; // Notifications disabled
    }
    
    final notificationId = _generateNotificationId(task.id, 'reminder');
    
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      actions: _settings.enabled ? [
        const AndroidNotificationAction(
          'complete',
          'Complete',
          titleColor: Color(0xFF008000),
        ),
        const AndroidNotificationAction(
          'snooze',
          'Snooze 15min',
          titleColor: Color(0xFFFFA500),
        ),
        const AndroidNotificationAction(
          'reschedule',
          'Reschedule',
          titleColor: Color(0xFF007BFF),
        ),
      ] : null,
    );
    
    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'task_reminder',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );
    
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);
    
    try {
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        _getTaskReminderTitle(task),
        _getTaskReminderBody(task),
        scheduledDate,
        notificationDetails,
        payload: '${task.id}|reminder',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,);
      
      return notificationId;
    } catch (e) {
      debugPrint('Error scheduling task reminder: $e');
      return null;
    }
  }
  
  @override
  Future<List<int>> scheduleMultipleReminders({
    required TaskModel task,
    required List<Duration> reminderIntervals,
  }) async {
    if (task.dueDate == null) return [];
    
    final scheduledIds = <int>[];
    
    for (final interval in reminderIntervals) {
      final reminderTime = task.dueDate!.subtract(interval);
      final id = await scheduleTaskReminder(
        task: task,
        scheduledTime: reminderTime,
        customReminder: interval,
      );
      
      if (id != null) {
        scheduledIds.add(id);
      }
    }
    
    return scheduledIds;
  }
  
  @override
  Future<int?> scheduleDailySummary({
    required DateTime scheduledTime,
    required List<TaskModel> tasks,
  }) async {
    if (!_settings.dailySummary) {
      return null;
    }
    
    const notificationId = 999999; // Fixed ID for daily summary
    
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'daily_summary',
    );
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // Ensure proper timezone conversion with validation
    tz.TZDateTime? scheduledDate;
    try {
      // Try to get system timezone first
      final systemTimezone = DateTime.now().timeZoneName;
      late tz.Location location;
      
      try {
        location = tz.getLocation(systemTimezone);
      } catch (e) {
        debugPrint('Failed to get system timezone ($systemTimezone), falling back to local: $e');
        location = tz.local;
      }
      
      scheduledDate = tz.TZDateTime.from(scheduledTime, location);
      
      // Validate the conversion is reasonable (within 24 hours of original)
      final timeDifference = scheduledDate.difference(scheduledTime).abs();
      if (timeDifference.inHours > 24) {
        debugPrint('Timezone conversion resulted in unreasonable time difference: ${timeDifference.inHours} hours');
        scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);
      }
    } catch (e) {
      debugPrint('Timezone conversion failed: $e');
      scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);
    }
    
    // Calculate task counts
    final todayTasks = tasks.where((t) => _isDueToday(t)).toList();
    final overdueTasks = tasks.where((t) => _isOverdue(t)).toList();
    final completedToday = tasks.where((t) => 
      t.status == TaskStatus.completed &&
      t.completedAt != null &&
      _isToday(t.completedAt!)
    ).length;
    
    const title = 'Daily Task Summary';
    final body = 'Today: $completedToday completed, ${todayTasks.length - completedToday} remaining, ${overdueTasks.length} overdue';
    
    try {
      // Cancel existing daily summary to avoid duplicates
      await _notificationsPlugin.cancel(notificationId);
      
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledDate,
        notificationDetails,
        payload: 'daily_summary|summary',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      );
      
      // Store notification info for persistence
      await _saveScheduledNotification(notificationId, 'daily_summary', scheduledTime);
      
      return notificationId;
    } catch (e) {
      debugPrint('Error scheduling daily summary: $e');
      return null;
    }
  }
  
  @override
  Future<int?> scheduleOverdueNotification({
    required TaskModel task,
  }) async {
    if (!_settings.overdueNotifications) {
      return null;
    }
    
    final notificationId = _generateNotificationId(task.id, 'overdue');
    
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color.fromARGB(255, 255, 0, 0),
    );
    
    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'overdue_task',
      interruptionLevel: InterruptionLevel.timeSensitive,
    );
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    try {
      await _notificationsPlugin.show(
        notificationId,
        'Task Overdue',
        task.title,
        notificationDetails,
        payload: '${task.id}|overdue',
      );
      
      return notificationId;
    } catch (e) {
      debugPrint('Error scheduling overdue notification: $e');
      return null;
    }
  }
  
  @override
  Future<void> cancelNotification(int notificationId) async {
    await _notificationsPlugin.cancel(notificationId);
  }
  
  @override
  Future<void> cancelTaskNotifications(String taskId) async {
    final pendingNotifications = await _notificationsPlugin.pendingNotificationRequests();
    
    for (final notification in pendingNotifications) {
      if (notification.payload?.startsWith(taskId) == true) {
        await cancelNotification(notification.id);
      }
    }
  }
  
  @override
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
  
  @override
  Future<List<ScheduledNotification>> getScheduledNotifications() async {
    final pendingNotifications = await _notificationsPlugin.pendingNotificationRequests();
    
    return pendingNotifications.map((notification) {
      // Validate and parse payload safely
      final payload = notification.payload;
      String? taskId;
      String type = 'unknown';
      
      if (payload != null && payload.isNotEmpty) {
        final payloadParts = payload.split('|');
        if (payloadParts.isNotEmpty) {
          final potentialTaskId = payloadParts[0].trim();
          // Basic validation for task ID (should be non-empty and reasonable length)
          if (potentialTaskId.isNotEmpty && potentialTaskId.length <= 100) {
            taskId = potentialTaskId;
          }
        }
        if (payloadParts.length > 1) {
          final potentialType = payloadParts[1].trim();
          // Validate notification type
          if (potentialType.isNotEmpty && potentialType.length <= 50) {
            type = potentialType;
          }
        }
      }
      
      return ScheduledNotification(
        id: notification.id,
        taskId: taskId ?? '',
        title: notification.title ?? '',
        body: notification.body ?? '',
        type: _parseNotificationType(type),
        scheduledTime: DateTime.now(),
        createdAt: DateTime.now(),
      );
    }).cast<ScheduledNotification>().toList();
  }
  
  @override
  Future<List<ScheduledNotification>> getTaskNotifications(String taskId) async {
    final allNotifications = await getScheduledNotifications();
    return allNotifications.where((n) => n.taskId == taskId).toList();
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
    
    switch (action) {
      case NotificationAction.complete:
        await _markTaskCompleted(taskId);
        break;
      case NotificationAction.snooze:
        await _snoozeTaskReminder(taskId);
        break;
      case NotificationAction.reschedule:
        await _rescheduleTask(taskId);
        break;
      case NotificationAction.postpone:
        await _postponeTask(taskId);
        break;
      case NotificationAction.view:
        // Open task details
        break;
      case NotificationAction.dismiss:
        // Just dismiss, no action needed
        break;
      default:
        // Handle any other actions
        break;
    }
  }
  
  @override
  Future<void> updateSettings(NotificationSettings settings) async {
    _settings = settings;
    await _saveSettings(settings);
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
    NotificationTypeModel type = NotificationTypeModel.taskReminder,
    Map<String, dynamic>? payload,
  }) async {
    final notificationId = DateTime.now().millisecondsSinceEpoch;
    
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'immediate',
    );
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    final payloadString = taskId != null ? '$taskId|${type.name}' : type.name;
    
    await _notificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: payloadString,
    );
  }
  
  @override
  Future<void> rescheduleAllNotifications() async {
    // This would require rebuilding all notifications based on current tasks and settings
    // For now, just cancel all and let the app reschedule as needed
    await cancelAllNotifications();
  }
  
  @override
  Future<bool> shouldSendNotification(DateTime scheduledTime) async {
    // Check quiet hours with proper logic for midnight-crossing ranges
    if (_settings.quietHoursStart != null && _settings.quietHoursEnd != null) {
      final hour = scheduledTime.hour;
      final minute = scheduledTime.minute;
      final currentTime = hour * 60 + minute; // Total minutes since midnight
      
      final startHour = _settings.quietHoursStart!.hour;
      final startMinute = _settings.quietHoursStart!.minute;
      final startTime = startHour * 60 + startMinute;
      
      final endHour = _settings.quietHoursEnd!.hour;
      final endMinute = _settings.quietHoursEnd!.minute;
      final endTime = endHour * 60 + endMinute;
      
      bool isInQuietHours;
      if (startTime <= endTime) {
        // Normal range (e.g., 08:00 to 22:00)
        isInQuietHours = currentTime >= startTime && currentTime <= endTime;
      } else {
        // Midnight-crossing range (e.g., 22:00 to 06:00)
        isInQuietHours = currentTime >= startTime || currentTime <= endTime;
      }
      
      if (isInQuietHours) {
        debugPrint('Notification blocked by quiet hours: ${_formatTimeOfDay(scheduledTime)}');
        return false;
      }
    }
    
    // Check do not disturb (platform specific)
    // This would require platform channels to check system DND status
    
    return true;
  }
  
  @override
  Future<DateTime?> getNextNotificationTime(String taskId) async {
    final notifications = await getTaskNotifications(taskId);
    if (notifications.isEmpty) return null;
    
    // Return the earliest scheduled time
    return notifications
        .map((n) => n.scheduledTime)
        .where((time) => time.isAfter(DateTime.now()))
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }
  
  // Private helper methods
  
  /// Handles notification tap events
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      final parts = payload.split('|');
      if (parts.isNotEmpty) {
        final taskId = parts[0].trim();
        // Validate task ID
        if (taskId.isEmpty || taskId.length > 100) {
          debugPrint('Invalid task ID in notification payload: $taskId');
          return;
        }
        
        final actionId = response.actionId;
        
        if (actionId != null) {
          final action = _parseNotificationAction(actionId);
          handleNotificationAction(taskId: taskId, action: action);
        } else {
          // Default tap action
          _eventController.add(NotificationEvent(
            type: 'tap',
            taskId: taskId,
            payload: {'payload': payload},
          ));
        }
      }
    }
  }
  
  /// Generates a unique notification ID for a task and type
  /// Uses timestamp to prevent collisions
  int _generateNotificationId(String taskId, String type) {
    final baseString = '${taskId}_$type';
    final hash = baseString.hashCode.abs();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Combine hash with timestamp to reduce collision probability
    // Use modulo to keep it within int32 range
    final uniqueId = ((hash << 16) + (timestamp & 0xFFFF)) % 0x7FFFFFFF;
    
    return uniqueId;
  }
  
  /// Gets the title for a task reminder notification
  String _getTaskReminderTitle(TaskModel task) {
    final priorityIndicator = _getPriorityIndicator(task.priority);
    return '$priorityIndicator Task Reminder';
  }
  
  /// Gets the body for a task reminder notification
  String _getTaskReminderBody(TaskModel task) {
    var body = task.title;
    
    if (task.dueDate != null) {
      final dueTime = _formatTime(task.dueDate!);
      body += ' (Due $dueTime)';
    }
    
    return body;
  }
  
  /// Gets priority indicator for task priority
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
  
  /// Formats time for notification display
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (taskDate == today) {
      return 'today at ${_formatTimeOfDay(dateTime)}';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'tomorrow at ${_formatTimeOfDay(dateTime)}';
    } else {
      return '${dateTime.month}/${dateTime.day} at ${_formatTimeOfDay(dateTime)}';
    }
  }
  
  /// Formats time of day
  String _formatTimeOfDay(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$displayHour:$minute $period';
  }
  
  /// Checks if a date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  /// Checks if a task is due today
  bool _isDueToday(TaskModel task) {
    return task.dueDate != null && _isToday(task.dueDate!);
  }
  
  /// Checks if a task is overdue
  bool _isOverdue(TaskModel task) {
    return task.dueDate != null && 
           task.dueDate!.isBefore(DateTime.now()) &&
           task.status != TaskStatus.completed;
  }
  
  /// Parses notification type from string
  NotificationTypeModel _parseNotificationType(String type) {
    switch (type) {
      case 'reminder':
        return NotificationTypeModel.taskReminder;
      case 'overdue':
        return NotificationTypeModel.overdueTask;
      case 'summary':
        return NotificationTypeModel.dailySummary;
      default:
        return NotificationTypeModel.taskReminder;
    }
  }
  
  /// Parses notification action from string
  NotificationAction _parseNotificationAction(String actionId) {
    switch (actionId) {
      case 'complete':
        return NotificationAction.complete;
      case 'snooze':
        return NotificationAction.snooze;
      case 'reschedule':
        return NotificationAction.view;
      default:
        return NotificationAction.dismiss;
    }
  }
  
  // Action handlers (these would integrate with your app's operations)
  
  Future<void> _markTaskCompleted(String taskId) async {
    _eventController.add(NotificationEvent(
      type: 'task_completion_requested',
      taskId: taskId,
    ));
  }
  
  Future<void> _snoozeTaskReminder(String taskId) async {
    final task = await _taskRepository.getTaskById(taskId);
    if (task != null) {
      final newReminderTime = DateTime.now().add(const Duration(minutes: 15));
      await scheduleTaskReminder(
        task: task,
        scheduledTime: newReminderTime,
      );
    }
  }
  
  Future<void> _rescheduleTask(String taskId) async {
    _eventController.add(NotificationEvent(
      type: 'task_reschedule_requested',
      taskId: taskId,
    ));
  }

  Future<void> _postponeTask(String taskId) async {
    _eventController.add(NotificationEvent(
      type: 'task_postpone_requested',
      taskId: taskId,
    ));
  }
  
  /// Load notification settings from SharedPreferences
  Future<void> _loadSavedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_keyNotificationSettings);
      
      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson);
        _settings = NotificationSettings.fromJson(settingsMap);
      }
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
      // Continue with default settings if loading fails
    }
  }
  
  /// Save notification settings to SharedPreferences
  Future<void> _saveSettings(NotificationSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(settings.toJson());
      await prefs.setString(_keyNotificationSettings, settingsJson);
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
  }

  /// Save scheduled notification info for persistence
  Future<void> _saveScheduledNotification(int notificationId, String type, DateTime scheduledTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingNotifications = prefs.getStringList('scheduled_notifications') ?? [];
      
      final notificationInfo = jsonEncode({
        'id': notificationId,
        'type': type,
        'scheduledTime': scheduledTime.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      existingNotifications.add(notificationInfo);
      
      // Keep only recent notifications (last 100)
      if (existingNotifications.length > 100) {
        existingNotifications.removeRange(0, existingNotifications.length - 100);
      }
      
      await prefs.setStringList('scheduled_notifications', existingNotifications);
    } catch (e) {
      debugPrint('Error saving scheduled notification: $e');
    }
  }

  /// Load and reschedule persisted notifications on app restart
  Future<void> loadPersistedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationStrings = prefs.getStringList('scheduled_notifications') ?? [];
      
      for (final notificationString in notificationStrings) {
        final notificationData = jsonDecode(notificationString) as Map<String, dynamic>;
        final scheduledTime = DateTime.parse(notificationData['scheduledTime'] as String);
        
        // Only reschedule future notifications
        if (scheduledTime.isAfter(DateTime.now())) {
          final type = notificationData['type'] as String;
          await _reschedulePersistedNotification(notificationData, type);
        }
      }
      
      // Clear processed notifications
      await prefs.remove('scheduled_notifications');
    } catch (e) {
      debugPrint('Error loading persisted notifications: $e');
    }
  }

  /// Reschedule a persisted notification
  Future<void> _reschedulePersistedNotification(Map<String, dynamic> data, String type) async {
    try {
      final scheduledTime = DateTime.parse(data['scheduledTime'] as String);
      
      if (type == 'daily_summary') {
        // Reschedule daily summary - this would need task repository access
        debugPrint('Would reschedule daily summary for $scheduledTime');
      }
      // Add more type handling as needed
    } catch (e) {
      debugPrint('Error rescheduling persisted notification: $e');
    }
  }

  /// Retry failed notifications with exponential backoff
  Future<void> retryFailedNotification(int notificationId, String taskId, int attemptCount) async {
    try {
      if (attemptCount >= 3) {
        debugPrint('Max retry attempts reached for notification $notificationId');
        return;
      }
      
      final delayMinutes = (attemptCount + 1) * 5; // 5, 10, 15 minutes
      await Future.delayed(Duration(minutes: delayMinutes));
      
      // Try to get the task and reschedule
      final task = await _taskRepository.getTaskById(taskId);
      if (task != null && task.dueDate != null && task.dueDate!.isAfter(DateTime.now())) {
        final newScheduleTime = DateTime.now().add(const Duration(minutes: 30));
        await scheduleTaskReminder(
          task: task,
          scheduledTime: newScheduleTime,
        );
        debugPrint('Retried notification for task $taskId (attempt ${attemptCount + 1})');
      }
    } catch (e) {
      debugPrint('Error retrying notification: $e');
      // Schedule another retry
      if (attemptCount < 2) {
        Timer(Duration(minutes: (attemptCount + 2) * 10), () {
          retryFailedNotification(notificationId, taskId, attemptCount + 1);
        });
      }
    }
  }

  /// Handle immediate overdue notifications on app startup
  Future<void> processImmediateOverdueNotifications() async {
    try {
      final tasks = await _taskRepository.getAllTasks();
      final overdueTasks = tasks.where((task) => 
        task.isOverdue && 
        task.status.isActive &&
        task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now().subtract(const Duration(hours: 1)))
      );

      for (final task in overdueTasks) {
        // Check if we've already sent overdue notification recently
        final recentNotifications = await getTaskNotifications(task.id);
        final hasRecentOverdue = recentNotifications.any((n) => 
          n.type == NotificationTypeModel.overdueTask &&
          n.createdAt.isAfter(DateTime.now().subtract(const Duration(hours: 6)))
        );

        if (!hasRecentOverdue) {
          await scheduleOverdueNotification(task: task);
        }
      }
    } catch (e) {
      debugPrint('Error processing immediate overdue notifications: $e');
    }
  }
  
  void dispose() {
    _eventController.close();
  }
}