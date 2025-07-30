// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurrence_pattern.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurrencePattern _$RecurrencePatternFromJson(Map<String, dynamic> json) =>
    RecurrencePattern(
      type: $enumDecode(_$RecurrenceTypeEnumMap, json['type']),
      interval: (json['interval'] as num?)?.toInt() ?? 1,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      maxOccurrences: (json['maxOccurrences'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RecurrencePatternToJson(RecurrencePattern instance) =>
    <String, dynamic>{
      'type': _$RecurrenceTypeEnumMap[instance.type]!,
      'interval': instance.interval,
      'daysOfWeek': instance.daysOfWeek,
      'endDate': instance.endDate?.toIso8601String(),
      'maxOccurrences': instance.maxOccurrences,
    };

const _$RecurrenceTypeEnumMap = {
  RecurrenceType.none: 'none',
  RecurrenceType.daily: 'daily',
  RecurrenceType.weekly: 'weekly',
  RecurrenceType.monthly: 'monthly',
  RecurrenceType.yearly: 'yearly',
  RecurrenceType.custom: 'custom',
};
