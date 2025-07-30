// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationSettings _$NotificationSettingsFromJson(
        Map<String, dynamic> json) =>
    NotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      defaultReminder: json['defaultReminder'] == null
          ? const Duration(hours: 1)
          : Duration(microseconds: (json['defaultReminder'] as num).toInt()),
      dailySummary: json['dailySummary'] as bool? ?? true,
      dailySummaryTime: json['dailySummaryTime'] == null
          ? const NotificationTime(hour: 8, minute: 0)
          : NotificationTime.fromJson(
              json['dailySummaryTime'] as Map<String, dynamic>),
      overdueNotifications: json['overdueNotifications'] as bool? ?? true,
      locationReminders: json['locationReminders'] as bool? ?? false,
      quietHoursStart: json['quietHoursStart'] == null
          ? null
          : NotificationTime.fromJson(
              json['quietHoursStart'] as Map<String, dynamic>),
      quietHoursEnd: json['quietHoursEnd'] == null
          ? null
          : NotificationTime.fromJson(
              json['quietHoursEnd'] as Map<String, dynamic>),
      respectDoNotDisturb: json['respectDoNotDisturb'] as bool? ?? true,
      notificationSound: json['notificationSound'] as String?,
      vibrate: json['vibrate'] as bool? ?? true,
      showBadges: json['showBadges'] as bool? ?? true,
    );

Map<String, dynamic> _$NotificationSettingsToJson(
        NotificationSettings instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'defaultReminder': instance.defaultReminder.inMicroseconds,
      'dailySummary': instance.dailySummary,
      'dailySummaryTime': instance.dailySummaryTime,
      'overdueNotifications': instance.overdueNotifications,
      'locationReminders': instance.locationReminders,
      'quietHoursStart': instance.quietHoursStart,
      'quietHoursEnd': instance.quietHoursEnd,
      'respectDoNotDisturb': instance.respectDoNotDisturb,
      'notificationSound': instance.notificationSound,
      'vibrate': instance.vibrate,
      'showBadges': instance.showBadges,
    };

ScheduledNotification _$ScheduledNotificationFromJson(
        Map<String, dynamic> json) =>
    ScheduledNotification(
      id: (json['id'] as num).toInt(),
      taskId: json['taskId'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      payload: json['payload'] as Map<String, dynamic>? ?? const {},
      sent: json['sent'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ScheduledNotificationToJson(
        ScheduledNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'scheduledTime': instance.scheduledTime.toIso8601String(),
      'title': instance.title,
      'body': instance.body,
      'payload': instance.payload,
      'sent': instance.sent,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.taskReminder: 'task_reminder',
  NotificationType.dailySummary: 'daily_summary',
  NotificationType.overdueTask: 'overdue_task',
  NotificationType.taskCompleted: 'task_completed',
  NotificationType.locationReminder: 'location_reminder',
};

NotificationHistoryEntry _$NotificationHistoryEntryFromJson(
        Map<String, dynamic> json) =>
    NotificationHistoryEntry(
      id: json['id'] as String,
      notificationId: (json['notificationId'] as num).toInt(),
      taskId: json['taskId'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      action: $enumDecodeNullable(_$NotificationActionEnumMap, json['action']),
      sentAt: DateTime.parse(json['sentAt'] as String),
      actionAt: json['actionAt'] == null
          ? null
          : DateTime.parse(json['actionAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$NotificationHistoryEntryToJson(
        NotificationHistoryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'notificationId': instance.notificationId,
      'taskId': instance.taskId,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'action': _$NotificationActionEnumMap[instance.action],
      'sentAt': instance.sentAt.toIso8601String(),
      'actionAt': instance.actionAt?.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$NotificationActionEnumMap = {
  NotificationAction.complete: 'complete',
  NotificationAction.snooze: 'snooze',
  NotificationAction.view: 'view',
  NotificationAction.dismiss: 'dismiss',
};

NotificationStats _$NotificationStatsFromJson(Map<String, dynamic> json) =>
    NotificationStats(
      totalScheduled: (json['totalScheduled'] as num).toInt(),
      todayScheduled: (json['todayScheduled'] as num).toInt(),
      pendingNotifications: (json['pendingNotifications'] as num).toInt(),
      sentNotifications: (json['sentNotifications'] as num).toInt(),
      actedUponNotifications:
          (json['actedUponNotifications'] as num?)?.toInt() ?? 0,
      mostCommonType: $enumDecodeNullable(
          _$NotificationTypeEnumMap, json['mostCommonType']),
      averageResponseTime: (json['averageResponseTime'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$NotificationStatsToJson(NotificationStats instance) =>
    <String, dynamic>{
      'totalScheduled': instance.totalScheduled,
      'todayScheduled': instance.todayScheduled,
      'pendingNotifications': instance.pendingNotifications,
      'sentNotifications': instance.sentNotifications,
      'actedUponNotifications': instance.actedUponNotifications,
      'mostCommonType': _$NotificationTypeEnumMap[instance.mostCommonType],
      'averageResponseTime': instance.averageResponseTime,
    };
