import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'location_models.g.dart';

@JsonSerializable()
class LocationData extends Equatable {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final String? address;
  final DateTime timestamp;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.address,
    required this.timestamp,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) =>
      _$LocationDataFromJson(json);

  Map<String, dynamic> toJson() => _$LocationDataToJson(this);  @override
  List<Object?> get props => [
        latitude,
        longitude,
        accuracy,
        altitude,
        address,
        timestamp,
      ];

  LocationData copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    String? address,
    DateTime? timestamp,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      address: address ?? this.address,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

@JsonSerializable()
class GeofenceData extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;
  final bool isActive;
  final GeofenceType type;
  final DateTime createdAt;

  const GeofenceData({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.isActive,
    required this.type,
    required this.createdAt,
  });

  factory GeofenceData.fromJson(Map<String, dynamic> json) =>
      _$GeofenceDataFromJson(json);

  Map<String, dynamic> toJson() => _$GeofenceDataToJson(this);  @override
  List<Object?> get props => [
        id,
        name,
        latitude,
        longitude,
        radius,
        isActive,
        type,
        createdAt,
      ];

  GeofenceData copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    double? radius,
    bool? isActive,
    GeofenceType? type,
    DateTime? createdAt,
  }) {
    return GeofenceData(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      isActive: isActive ?? this.isActive,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum GeofenceType {
  @JsonValue('enter')
  enter,
  @JsonValue('exit')
  exit,
  @JsonValue('both')
  both,
}

@JsonSerializable()
class LocationTrigger extends Equatable {
  final String id;
  final String taskId;
  final GeofenceData geofence;
  final bool isEnabled;
  final DateTime createdAt;

  const LocationTrigger({
    required this.id,
    required this.taskId,
    required this.geofence,
    required this.isEnabled,
    required this.createdAt,
  });

  factory LocationTrigger.fromJson(Map<String, dynamic> json) =>
      _$LocationTriggerFromJson(json);

  Map<String, dynamic> toJson() => _$LocationTriggerToJson(this);  @override
  List<Object?> get props => [
        id,
        taskId,
        geofence,
        isEnabled,
        createdAt,
      ];

  LocationTrigger copyWith({
    String? id,
    String? taskId,
    GeofenceData? geofence,
    bool? isEnabled,
    DateTime? createdAt,
  }) {
    return LocationTrigger(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      geofence: geofence ?? this.geofence,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  whileInUse,
  always,
  unableToDetermine,
}

enum LocationAccuracy {
  low,
  medium,
  high,
  best,
}

@JsonSerializable()
class GeofenceEvent extends Equatable {
  final String geofenceId;
  final GeofenceEventType type;
  final LocationData location;
  final DateTime timestamp;

  const GeofenceEvent({
    required this.geofenceId,
    required this.type,
    required this.location,
    required this.timestamp,
  });

  factory GeofenceEvent.fromJson(Map<String, dynamic> json) =>
      _$GeofenceEventFromJson(json);

  Map<String, dynamic> toJson() => _$GeofenceEventToJson(this);  @override
  List<Object?> get props => [geofenceId, type, location, timestamp];
}

enum GeofenceEventType {
  @JsonValue('enter')
  enter,
  @JsonValue('exit')
  exit,
}

@JsonSerializable()
class LocationSettings extends Equatable {
  final bool locationEnabled;
  final bool geofencingEnabled;
  final LocationAccuracy locationAccuracy;
  final bool backgroundLocationEnabled;
  final bool locationHistoryEnabled;
  final int locationUpdateIntervalSeconds;

  const LocationSettings({
    this.locationEnabled = false,
    this.geofencingEnabled = false,
    this.locationAccuracy = LocationAccuracy.medium,
    this.backgroundLocationEnabled = false,
    this.locationHistoryEnabled = false,
    this.locationUpdateIntervalSeconds = 30,
  });

  factory LocationSettings.fromJson(Map<String, dynamic> json) =>
      _$LocationSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$LocationSettingsToJson(this);  @override
  List<Object?> get props => [
        locationEnabled,
        geofencingEnabled,
        locationAccuracy,
        backgroundLocationEnabled,
        locationHistoryEnabled,
        locationUpdateIntervalSeconds,
      ];

  LocationSettings copyWith({
    bool? locationEnabled,
    bool? geofencingEnabled,
    LocationAccuracy? locationAccuracy,
    bool? backgroundLocationEnabled,
    bool? locationHistoryEnabled,
    int? locationUpdateIntervalSeconds,
  }) {
    return LocationSettings(
      locationEnabled: locationEnabled ?? this.locationEnabled,
      geofencingEnabled: geofencingEnabled ?? this.geofencingEnabled,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      backgroundLocationEnabled: backgroundLocationEnabled ?? this.backgroundLocationEnabled,
      locationHistoryEnabled: locationHistoryEnabled ?? this.locationHistoryEnabled,
      locationUpdateIntervalSeconds: locationUpdateIntervalSeconds ?? this.locationUpdateIntervalSeconds,
    );
  }
}

class LocationServiceException implements Exception {
  final String message;
  final String? code;

  const LocationServiceException(this.message, [this.code]);  @override
  String toString() => 'LocationServiceException: $message${code != null ? ' ($code)' : ''}';
}
