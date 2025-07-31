// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationData _$LocationDataFromJson(Map<String, dynamic> json) => LocationData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$LocationDataToJson(LocationData instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracy': instance.accuracy,
      'altitude': instance.altitude,
      'address': instance.address,
      'timestamp': instance.timestamp.toIso8601String(),
    };

GeofenceData _$GeofenceDataFromJson(Map<String, dynamic> json) => GeofenceData(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      type: $enumDecode(_$GeofenceTypeEnumMap, json['type']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$GeofenceDataToJson(GeofenceData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radius': instance.radius,
      'isActive': instance.isActive,
      'type': _$GeofenceTypeEnumMap[instance.type]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$GeofenceTypeEnumMap = {
  GeofenceType.enter: 'enter',
  GeofenceType.exit: 'exit',
  GeofenceType.both: 'both',
};

LocationTrigger _$LocationTriggerFromJson(Map<String, dynamic> json) =>
    LocationTrigger(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      geofence: GeofenceData.fromJson(json['geofence'] as Map<String, dynamic>),
      isEnabled: json['isEnabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$LocationTriggerToJson(LocationTrigger instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'geofence': instance.geofence,
      'isEnabled': instance.isEnabled,
      'createdAt': instance.createdAt.toIso8601String(),
    };
