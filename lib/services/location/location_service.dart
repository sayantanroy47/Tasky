import 'location_models.dart';

abstract class LocationService {
  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled();

  /// Check current location permission status
  Future<LocationPermissionStatus> checkPermission();

  /// Request location permission from user
  Future<LocationPermissionStatus> requestPermission();

  /// Get current location
  Future<LocationData> getCurrentLocation();

  /// Get location stream for continuous updates
  Stream<LocationData> getLocationStream();

  /// Convert coordinates to address
  Future<String?> getAddressFromCoordinates(double latitude, double longitude);

  /// Convert address to coordinates
  Future<LocationData?> getCoordinatesFromAddress(String address);

  /// Calculate distance between two points in meters
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  );

  /// Check if a point is within a geofence
  bool isWithinGeofence(
    LocationData location,
    GeofenceData geofence,
  );

  /// Start monitoring a geofence
  Future<void> startGeofenceMonitoring(GeofenceData geofence);

  /// Stop monitoring a geofence
  Future<void> stopGeofenceMonitoring(String geofenceId);

  /// Stop monitoring all geofences
  Future<void> stopAllGeofenceMonitoring();

  /// Get stream of geofence events
  Stream<GeofenceEvent> getGeofenceEventStream();

  /// Dispose resources
  void dispose();
}

class GeofenceEvent {
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
}

enum GeofenceEventType {
  enter,
  exit,
}