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
      type: $enumDecode(_$NotificationTypeModelEnumMap, json['type']),
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
      'type': _$NotificationTypeModelEnumMap[instance.type]!,
      'scheduledTime': instance.scheduledTime.toIso8601String(),
      'title': instance.title,
      'body': instance.body,
      'payload': instance.payload,
      'sent': instance.sent,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$NotificationTypeModelEnumMap = {
  NotificationTypeModel.taskReminder: 'task_reminder',
  NotificationTypeModel.dailySummary: 'daily_summary',
  NotificationTypeModel.overdueTask: 'overdue_task',
  NotificationTypeModel.taskCompleted: 'task_completed',
  NotificationTypeModel.locationReminder: 'location_reminder',
  NotificationTypeModel.locationBased: 'location_based',
  NotificationTypeModel.emergency: 'emergency',
  NotificationTypeModel.smartSuggestion: 'smart_suggestion',
  NotificationTypeModel.collaboration: 'collaboration',
  NotificationTypeModel.automationTrigger: 'automation_trigger',
};

NotificationHistoryEntry _$NotificationHistoryEntryFromJson(
        Map<String, dynamic> json) =>
    NotificationHistoryEntry(
      id: json['id'] as String,
      notificationId: (json['notificationId'] as num).toInt(),
      taskId: json['taskId'] as String,
      type: $enumDecode(_$NotificationTypeModelEnumMap, json['type']),
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
      'type': _$NotificationTypeModelEnumMap[instance.type]!,
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
  NotificationAction.reschedule: 'reschedule',
  NotificationAction.postpone: 'postpone',
  NotificationAction.delegate: 'delegate',
  NotificationAction.archive: 'archive',
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
          _$NotificationTypeModelEnumMap, json['mostCommonType']),
      averageResponseTime: (json['averageResponseTime'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$NotificationStatsToJson(NotificationStats instance) =>
    <String, dynamic>{
      'totalScheduled': instance.totalScheduled,
      'todayScheduled': instance.todayScheduled,
      'pendingNotifications': instance.pendingNotifications,
      'sentNotifications': instance.sentNotifications,
      'actedUponNotifications': instance.actedUponNotifications,
      'mostCommonType': _$NotificationTypeModelEnumMap[instance.mostCommonType],
      'averageResponseTime': instance.averageResponseTime,
    };

NotificationTemplate _$NotificationTemplateFromJson(
        Map<String, dynamic> json) =>
    NotificationTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$NotificationTypeModelEnumMap, json['type']),
      titleTemplate: json['titleTemplate'] as String,
      bodyTemplate: json['bodyTemplate'] as String,
      availableActions: (json['availableActions'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$NotificationActionEnumMap, e))
              .toList() ??
          const [],
      defaultPriority: $enumDecodeNullable(
              _$NotificationPriorityEnumMap, json['defaultPriority']) ??
          NotificationPriority.normal,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$NotificationTemplateToJson(
        NotificationTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$NotificationTypeModelEnumMap[instance.type]!,
      'titleTemplate': instance.titleTemplate,
      'bodyTemplate': instance.bodyTemplate,
      'availableActions': instance.availableActions
          .map((e) => _$NotificationActionEnumMap[e]!)
          .toList(),
      'defaultPriority':
          _$NotificationPriorityEnumMap[instance.defaultPriority]!,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$NotificationPriorityEnumMap = {
  NotificationPriority.low: 'low',
  NotificationPriority.normal: 'normal',
  NotificationPriority.high: 'high',
  NotificationPriority.urgent: 'urgent',
  NotificationPriority.critical: 'critical',
};

NotificationGroup _$NotificationGroupFromJson(Map<String, dynamic> json) =>
    NotificationGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      notificationIds: (json['notificationIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isCollapsed: json['isCollapsed'] as bool? ?? false,
    );

Map<String, dynamic> _$NotificationGroupToJson(NotificationGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'notificationIds': instance.notificationIds,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isCollapsed': instance.isCollapsed,
    };

RichNotificationContent _$RichNotificationContentFromJson(
        Map<String, dynamic> json) =>
    RichNotificationContent(
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      customButtons: (json['customButtons'] as List<dynamic>?)
              ?.map(
                  (e) => NotificationButton.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      customFields: (json['customFields'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      backgroundColor: json['backgroundColor'] as String?,
      textColor: json['textColor'] as String?,
      accentColor: json['accentColor'] as String?,
    );

Map<String, dynamic> _$RichNotificationContentToJson(
        RichNotificationContent instance) =>
    <String, dynamic>{
      'imageUrl': instance.imageUrl,
      'videoUrl': instance.videoUrl,
      'audioUrl': instance.audioUrl,
      'customButtons': instance.customButtons,
      'customFields': instance.customFields,
      'backgroundColor': instance.backgroundColor,
      'textColor': instance.textColor,
      'accentColor': instance.accentColor,
    };

NotificationButton _$NotificationButtonFromJson(Map<String, dynamic> json) =>
    NotificationButton(
      id: json['id'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String?,
      action: $enumDecode(_$NotificationActionEnumMap, json['action']),
      payload: json['payload'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$NotificationButtonToJson(NotificationButton instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'icon': instance.icon,
      'action': _$NotificationActionEnumMap[instance.action]!,
      'payload': instance.payload,
    };
