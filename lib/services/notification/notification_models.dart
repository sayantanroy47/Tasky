import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_models.g.dart';

/// Types of notifications that can be sent
enum NotificationType {
  @JsonValue('task_reminder')
  taskReminder,
  
  @JsonValue('daily_summary')
  dailySummary,
  
  @JsonValue('overdue_task')
  overdueTask,
  
  @JsonValue('task_completed')
  taskCompleted,
  
  @JsonValue('location_reminder')
  locationReminder;

  String get displayName {
    switch (this) {
      case NotificationType.taskReminder:
        return 'Task Reminder';
      case NotificationType.dailySummary:
        return 'Daily Summary';
      case NotificationType.overdueTask:
        return 'Overdue Task';
      case NotificationType.taskCompleted:
        return 'Task Completed';
      case NotificationType.locationReminder:
        return 'Location Reminder';
    }
  }
}

/// Notification action types for interactive notifications
enum NotificationAction {
  @JsonValue('complete')
  complete,
  
  @JsonValue('snooze')
  snooze,
  
  @JsonValue('view')
  view,
  
  @JsonValue('dismiss')
  dismiss;

  String get displayName {
    switch (this) {
      case NotificationAction.complete:
        return 'Complete';
      case NotificationAction.snooze:
        return 'Snooze';
      case NotificationAction.view:
        return 'View';
      case NotificationAction.dismiss:
        return 'Dismiss';
    }
  }
}

/// Settings for notification behavior
@JsonSerializable()
class NotificationSettings extends Equatable {
  /// Whether notifications are enabled globally
  final bool enabled;
  
  /// Default reminder time before due date
  final Duration defaultReminder;
  
  /// Whether to send daily summary notifications
  final bool dailySummary;
  
  /// Time to send daily summary
  final NotificationTime dailySummaryTime;
  
  /// Whether to send overdue task notifications
  final bool overdueNotifications;
  
  /// Whether to send location-based reminders
  final bool locationReminders;
  
  /// Quiet hours start time
  final NotificationTime? quietHoursStart;
  
  /// Quiet hours end time
  final NotificationTime? quietHoursEnd;
  
  /// Whether to respect system do-not-disturb settings
  final bool respectDoNotDisturb;
  
  /// Sound to play for notifications
  final String? notificationSound;
  
  /// Whether to vibrate for notifications
  final bool vibrate;
  
  /// Whether to show notification badges
  final bool showBadges;

  const NotificationSettings({
    this.enabled = true,
    this.defaultReminder = const Duration(hours: 1),
    this.dailySummary = true,
    this.dailySummaryTime = const NotificationTime(hour: 8, minute: 0),
    this.overdueNotifications = true,
    this.locationReminders = false,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.respectDoNotDisturb = true,
    this.notificationSound,
    this.vibrate = true,
    this.showBadges = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationSettingsToJson(this);

  NotificationSettings copyWith({
    bool? enabled,
    Duration? defaultReminder,
    bool? dailySummary,
    NotificationTime? dailySummaryTime,
    bool? overdueNotifications,
    bool? locationReminders,
    NotificationTime? quietHoursStart,
    NotificationTime? quietHoursEnd,
    bool? respectDoNotDisturb,
    String? notificationSound,
    bool? vibrate,
    bool? showBadges,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      defaultReminder: defaultReminder ?? this.defaultReminder,
      dailySummary: dailySummary ?? this.dailySummary,
      dailySummaryTime: dailySummaryTime ?? this.dailySummaryTime,
      overdueNotifications: overdueNotifications ?? this.overdueNotifications,
      locationReminders: locationReminders ?? this.locationReminders,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      respectDoNotDisturb: respectDoNotDisturb ?? this.respectDoNotDisturb,
      notificationSound: notificationSound ?? this.notificationSound,
      vibrate: vibrate ?? this.vibrate,
      showBadges: showBadges ?? this.showBadges,
    );
  }

  @override
  List<Object?> get props => [
        enabled,
        defaultReminder,
        dailySummary,
        dailySummaryTime,
        overdueNotifications,
        locationReminders,
        quietHoursStart,
        quietHoursEnd,
        respectDoNotDisturb,
        notificationSound,
        vibrate,
        showBadges,
      ];
}

/// Represents a scheduled notification
@JsonSerializable()
class ScheduledNotification extends Equatable {
  /// Unique identifier for the notification
  final int id;
  
  /// ID of the task this notification is for
  final String taskId;
  
  /// Type of notification
  final NotificationType type;
  
  /// When the notification should be sent
  final DateTime scheduledTime;
  
  /// Title of the notification
  final String title;
  
  /// Body text of the notification
  final String body;
  
  /// Additional payload data
  final Map<String, dynamic> payload;
  
  /// Whether this notification has been sent
  final bool sent;
  
  /// When this notification was created
  final DateTime createdAt;

  const ScheduledNotification({
    required this.id,
    required this.taskId,
    required this.type,
    required this.scheduledTime,
    required this.title,
    required this.body,
    this.payload = const {},
    this.sent = false,
    required this.createdAt,
  });

  factory ScheduledNotification.fromJson(Map<String, dynamic> json) =>
      _$ScheduledNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduledNotificationToJson(this);

  ScheduledNotification copyWith({
    int? id,
    String? taskId,
    NotificationType? type,
    DateTime? scheduledTime,
    String? title,
    String? body,
    Map<String, dynamic>? payload,
    bool? sent,
    DateTime? createdAt,
  }) {
    return ScheduledNotification(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      type: type ?? this.type,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      sent: sent ?? this.sent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        type,
        scheduledTime,
        title,
        body,
        payload,
        sent,
        createdAt,
      ];
}

/// Custom NotificationTime class for JSON serialization
class NotificationTime {
  final int hour;
  final int minute;

  const NotificationTime({required this.hour, required this.minute});

  factory NotificationTime.fromJson(Map<String, dynamic> json) {
    return NotificationTime(
      hour: json['hour'] as int,
      minute: json['minute'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationTime && other.hour == hour && other.minute == minute;
  }

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;

  @override
  String toString() => 'NotificationTime(${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')})';
}

/// Notification history entry for tracking notification interactions
@JsonSerializable()
class NotificationHistoryEntry extends Equatable {
  /// Unique identifier for the history entry
  final String id;
  
  /// ID of the notification
  final int notificationId;
  
  /// ID of the task this notification was for
  final String taskId;
  
  /// Type of notification
  final NotificationType type;
  
  /// Action taken on the notification
  final NotificationAction? action;
  
  /// When the notification was sent
  final DateTime sentAt;
  
  /// When the action was taken (if any)
  final DateTime? actionAt;
  
  /// Additional data about the interaction
  final Map<String, dynamic> metadata;

  const NotificationHistoryEntry({
    required this.id,
    required this.notificationId,
    required this.taskId,
    required this.type,
    this.action,
    required this.sentAt,
    this.actionAt,
    this.metadata = const {},
  });

  factory NotificationHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$NotificationHistoryEntryFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationHistoryEntryToJson(this);

  NotificationHistoryEntry copyWith({
    String? id,
    int? notificationId,
    String? taskId,
    NotificationType? type,
    NotificationAction? action,
    DateTime? sentAt,
    DateTime? actionAt,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationHistoryEntry(
      id: id ?? this.id,
      notificationId: notificationId ?? this.notificationId,
      taskId: taskId ?? this.taskId,
      type: type ?? this.type,
      action: action ?? this.action,
      sentAt: sentAt ?? this.sentAt,
      actionAt: actionAt ?? this.actionAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        notificationId,
        taskId,
        type,
        action,
        sentAt,
        actionAt,
        metadata,
      ];
}

/// Statistics about notification usage
@JsonSerializable()
class NotificationStats extends Equatable {
  /// Total number of scheduled notifications
  final int totalScheduled;
  
  /// Number of notifications scheduled for today
  final int todayScheduled;
  
  /// Number of pending notifications
  final int pendingNotifications;
  
  /// Number of sent notifications
  final int sentNotifications;
  
  /// Number of notifications that were acted upon
  final int actedUponNotifications;
  
  /// Most common notification type
  final NotificationType? mostCommonType;
  
  /// Average response time to notifications (in minutes)
  final double? averageResponseTime;

  const NotificationStats({
    required this.totalScheduled,
    required this.todayScheduled,
    required this.pendingNotifications,
    required this.sentNotifications,
    this.actedUponNotifications = 0,
    this.mostCommonType,
    this.averageResponseTime,
  });

  factory NotificationStats.fromJson(Map<String, dynamic> json) =>
      _$NotificationStatsFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationStatsToJson(this);

  NotificationStats copyWith({
    int? totalScheduled,
    int? todayScheduled,
    int? pendingNotifications,
    int? sentNotifications,
    int? actedUponNotifications,
    NotificationType? mostCommonType,
    double? averageResponseTime,
  }) {
    return NotificationStats(
      totalScheduled: totalScheduled ?? this.totalScheduled,
      todayScheduled: todayScheduled ?? this.todayScheduled,
      pendingNotifications: pendingNotifications ?? this.pendingNotifications,
      sentNotifications: sentNotifications ?? this.sentNotifications,
      actedUponNotifications: actedUponNotifications ?? this.actedUponNotifications,
      mostCommonType: mostCommonType ?? this.mostCommonType,
      averageResponseTime: averageResponseTime ?? this.averageResponseTime,
    );
  }

  @override
  List<Object?> get props => [
        totalScheduled,
        todayScheduled,
        pendingNotifications,
        sentNotifications,
        actedUponNotifications,
        mostCommonType,
        averageResponseTime,
      ];
}
