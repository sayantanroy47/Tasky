// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskTemplate _$TaskTemplateFromJson(Map<String, dynamic> json) => TaskTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      titleTemplate: json['titleTemplate'] as String,
      descriptionTemplate: json['descriptionTemplate'] as String?,
      priority: $enumDecodeNullable(_$TaskPriorityEnumMap, json['priority']) ??
          TaskPriority.medium,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      subTaskTemplates: (json['subTaskTemplates'] as List<dynamic>?)
              ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      locationTrigger: json['locationTrigger'] as String?,
      recurrence: json['recurrence'] == null
          ? null
          : RecurrencePattern.fromJson(
              json['recurrence'] as Map<String, dynamic>),
      projectId: json['projectId'] as String?,
      estimatedDuration: (json['estimatedDuration'] as num?)?.toInt(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
      category: json['category'] as String?,
    );

Map<String, dynamic> _$TaskTemplateToJson(TaskTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'titleTemplate': instance.titleTemplate,
      'descriptionTemplate': instance.descriptionTemplate,
      'priority': _$TaskPriorityEnumMap[instance.priority]!,
      'tags': instance.tags,
      'subTaskTemplates': instance.subTaskTemplates,
      'locationTrigger': instance.locationTrigger,
      'recurrence': instance.recurrence,
      'projectId': instance.projectId,
      'estimatedDuration': instance.estimatedDuration,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'usageCount': instance.usageCount,
      'isFavorite': instance.isFavorite,
      'category': instance.category,
    };

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'low',
  TaskPriority.medium: 'medium',
  TaskPriority.high: 'high',
  TaskPriority.urgent: 'urgent',
};
