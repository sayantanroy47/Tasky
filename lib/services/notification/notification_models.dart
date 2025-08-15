import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_models.g.dart';

/// Types of notifications that can be sent
enum NotificationTypeModel {
  @JsonValue('task_reminder')
  taskReminder,
  
  @JsonValue('daily_summary')
  dailySummary,
  
  @JsonValue('overdue_task')
  overdueTask,
  
  @JsonValue('task_completed')
  taskCompleted,
  
  @JsonValue('location_reminder')
  locationReminder,
  
  @JsonValue('location_based')
  locationBased,
  
  @JsonValue('emergency')
  emergency,
  
  @JsonValue('smart_suggestion')
  smartSuggestion,
  
  @JsonValue('collaboration')
  collaboration,
  
  @JsonValue('automation_trigger')
  automationTrigger;

  String get displayName {
    switch (this) {
      case NotificationTypeModel.taskReminder:
        return 'Task Reminder';
      case NotificationTypeModel.dailySummary:
        return 'Daily Summary';
      case NotificationTypeModel.overdueTask:
        return 'Overdue Task';
      case NotificationTypeModel.taskCompleted:
        return 'Task Completed';
      case NotificationTypeModel.locationReminder:
        return 'Location Reminder';
      case NotificationTypeModel.locationBased:
        return 'Location Based';
      case NotificationTypeModel.emergency:
        return 'Emergency';
      case NotificationTypeModel.smartSuggestion:
        return 'Smart Suggestion';
      case NotificationTypeModel.collaboration:
        return 'Collaboration';
      case NotificationTypeModel.automationTrigger:
        return 'Automation Trigger';
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
  dismiss,
  
  @JsonValue('reschedule')
  reschedule,
  
  @JsonValue('postpone')
  postpone,
  
  @JsonValue('delegate')
  delegate,
  
  @JsonValue('archive')
  archive;

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
      case NotificationAction.reschedule:
        return 'Reschedule';
      case NotificationAction.postpone:
        return 'Postpone';
      case NotificationAction.delegate:
        return 'Delegate';
      case NotificationAction.archive:
        return 'Archive';
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
  final NotificationTypeModel type;
  
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
    NotificationTypeModel? type,
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
  final NotificationTypeModel type;
  
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
    NotificationTypeModel? type,
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
  final NotificationTypeModel? mostCommonType;
  
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
    NotificationTypeModel? mostCommonType,
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

/// Priority levels for notifications
enum NotificationPriority {
  @JsonValue('low')
  low,
  
  @JsonValue('normal') 
  normal,
  
  @JsonValue('high')
  high,
  
  @JsonValue('urgent')
  urgent,
  
  @JsonValue('critical')
  critical;

  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
      case NotificationPriority.critical:
        return 'Critical';
    }
  }

  int get weight {
    switch (this) {
      case NotificationPriority.low:
        return 1;
      case NotificationPriority.normal:
        return 2;
      case NotificationPriority.high:
        return 3;
      case NotificationPriority.urgent:
        return 4;
      case NotificationPriority.critical:
        return 5;
    }
  }
}

/// Notification template for customizable notifications
@JsonSerializable()
class NotificationTemplate extends Equatable {
  final String id;
  final String name;
  final NotificationTypeModel type;
  final String titleTemplate;
  final String bodyTemplate;
  final List<NotificationAction> availableActions;
  final NotificationPriority defaultPriority;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.titleTemplate,
    required this.bodyTemplate,
    this.availableActions = const [],
    this.defaultPriority = NotificationPriority.normal,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationTemplate.fromJson(Map<String, dynamic> json) =>
      _$NotificationTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationTemplateToJson(this);

  NotificationTemplate copyWith({
    String? id,
    String? name,
    NotificationTypeModel? type,
    String? titleTemplate,
    String? bodyTemplate,
    List<NotificationAction>? availableActions,
    NotificationPriority? defaultPriority,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      titleTemplate: titleTemplate ?? this.titleTemplate,
      bodyTemplate: bodyTemplate ?? this.bodyTemplate,
      availableActions: availableActions ?? this.availableActions,
      defaultPriority: defaultPriority ?? this.defaultPriority,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        titleTemplate,
        bodyTemplate,
        availableActions,
        defaultPriority,
        metadata,
        createdAt,
        updatedAt,
      ];
}

/// Notification group for organizing related notifications
@JsonSerializable()
class NotificationGroup extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<int> notificationIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCollapsed;

  const NotificationGroup({
    required this.id,
    required this.name,
    required this.description,
    this.notificationIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isCollapsed = false,
  });

  factory NotificationGroup.fromJson(Map<String, dynamic> json) =>
      _$NotificationGroupFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationGroupToJson(this);

  NotificationGroup copyWith({
    String? id,
    String? name,
    String? description,
    List<int>? notificationIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCollapsed,
  }) {
    return NotificationGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      notificationIds: notificationIds ?? this.notificationIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCollapsed: isCollapsed ?? this.isCollapsed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        notificationIds,
        createdAt,
        updatedAt,
        isCollapsed,
      ];
}

/// Rich notification content with media and formatting
@JsonSerializable()
class RichNotificationContent extends Equatable {
  final String? imageUrl;
  final String? videoUrl;
  final String? audioUrl;
  final List<NotificationButton> customButtons;
  final Map<String, String> customFields;
  final String? backgroundColor;
  final String? textColor;
  final String? accentColor;

  const RichNotificationContent({
    this.imageUrl,
    this.videoUrl,
    this.audioUrl,
    this.customButtons = const [],
    this.customFields = const {},
    this.backgroundColor,
    this.textColor,
    this.accentColor,
  });

  factory RichNotificationContent.fromJson(Map<String, dynamic> json) =>
      _$RichNotificationContentFromJson(json);

  Map<String, dynamic> toJson() => _$RichNotificationContentToJson(this);

  RichNotificationContent copyWith({
    String? imageUrl,
    String? videoUrl,
    String? audioUrl,
    List<NotificationButton>? customButtons,
    Map<String, String>? customFields,
    String? backgroundColor,
    String? textColor,
    String? accentColor,
  }) {
    return RichNotificationContent(
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      customButtons: customButtons ?? this.customButtons,
      customFields: customFields ?? this.customFields,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  @override
  List<Object?> get props => [
        imageUrl,
        videoUrl,
        audioUrl,
        customButtons,
        customFields,
        backgroundColor,
        textColor,
        accentColor,
      ];
}

/// Custom notification button
@JsonSerializable()
class NotificationButton extends Equatable {
  final String id;
  final String label;
  final String? icon;
  final NotificationAction action;
  final Map<String, dynamic> payload;

  const NotificationButton({
    required this.id,
    required this.label,
    this.icon,
    required this.action,
    this.payload = const {},
  });

  factory NotificationButton.fromJson(Map<String, dynamic> json) =>
      _$NotificationButtonFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationButtonToJson(this);

  NotificationButton copyWith({
    String? id,
    String? label,
    String? icon,
    NotificationAction? action,
    Map<String, dynamic>? payload,
  }) {
    return NotificationButton(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      action: action ?? this.action,
      payload: payload ?? this.payload,
    );
  }

  @override
  List<Object?> get props => [id, label, icon, action, payload];
}
