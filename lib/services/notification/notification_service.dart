import '../../../domain/entities/task_model.dart';
import 'notification_models.dart';

/// Abstract interface for notification services
/// 
/// This interface defines the contract for notification functionality,
/// allowing for different implementations (local notifications, push notifications, etc.)
abstract class NotificationService {
  /// Initialize the notification service
  /// Returns true if initialization was successful
  Future<bool> initialize();

  /// Request notification permissions from the user
  /// Returns true if permissions were granted
  Future<bool> requestPermissions();

  /// Check if notification permissions are granted
  Future<bool> get hasPermissions;

  /// Schedule a notification for a task
  /// Returns the notification ID if successful, null otherwise
  Future<int?> scheduleTaskReminder({
    required TaskModel task,
    required DateTime scheduledTime,
    Duration? customReminder,
  });

  /// Schedule multiple reminders for a task (e.g., 1 hour before, 15 minutes before)
  Future<List<int>> scheduleMultipleReminders({
    required TaskModel task,
    required List<Duration> reminderIntervals,
  });

  /// Schedule a daily summary notification
  Future<int?> scheduleDailySummary({
    required DateTime scheduledTime,
    required List<TaskModel> tasks,
  });

  /// Schedule an overdue task notification
  Future<int?> scheduleOverdueNotification({
    required TaskModel task,
  });

  /// Cancel a specific notification by ID
  Future<void> cancelNotification(int notificationId);

  /// Cancel all notifications for a specific task
  Future<void> cancelTaskNotifications(String taskId);

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications();

  /// Get all scheduled notifications
  Future<List<ScheduledNotification>> getScheduledNotifications();

  /// Get scheduled notifications for a specific task
  Future<List<ScheduledNotification>> getTaskNotifications(String taskId);

  /// Handle notification action (complete, snooze, etc.)
  Future<void> handleNotificationAction({
    required String taskId,
    required NotificationAction action,
    Map<String, dynamic>? payload,
  });

  /// Update notification settings
  Future<void> updateSettings(NotificationSettings settings);

  /// Get current notification settings
  Future<NotificationSettings> getSettings();

  /// Show an immediate notification (for testing or urgent notifications)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? taskId,
    NotificationTypeModel type = NotificationTypeModel.taskReminder,
    Map<String, dynamic>? payload,
  });

  /// Reschedule all notifications (useful after settings changes)
  Future<void> rescheduleAllNotifications();

  /// Check if notifications should be sent based on quiet hours and DND settings
  Future<bool> shouldSendNotification(DateTime scheduledTime);

  /// Get the next scheduled notification time for a task
  Future<DateTime?> getNextNotificationTime(String taskId);

  /// Stream of notification events (for handling background notifications)
  Stream<NotificationEvent> get notificationEvents;

  /// Shows a notification immediately (alias for showImmediateNotification)
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

  /// Schedules a notification (alias for scheduleTaskReminder)
  Future<int?> scheduleNotification({
    required TaskModel task,
    required DateTime scheduledTime,
    Duration? customReminder,
  }) => scheduleTaskReminder(
    task: task,
    scheduledTime: scheduledTime,
    customReminder: customReminder,
  );
}

/// Events that can be emitted by the notification service
class NotificationEvent {
  final String type;
  final String? taskId;
  final NotificationAction? action;
  final Map<String, dynamic>? payload;

  const NotificationEvent({
    required this.type,
    this.taskId,
    this.action,
    this.payload,
  });
}
