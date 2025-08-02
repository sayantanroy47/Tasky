import 'dart:async';
import 'location_service.dart';
import 'location_models.dart';

/// Stub implementation of LocationService when geolocator is not available
class LocationServiceStub implements LocationService {
  StreamSubscription<LocationData>? _positionSubscription;
  @override
  Future<bool> isLocationServiceEnabled() async {
    return false; // Always false for stub
  }
  @override
  Future<LocationPermissionStatus> checkPermission() async {
    return LocationPermissionStatus.denied;
  }
  @override
  Future<LocationPermissionStatus> requestPermission() async {
    return LocationPermissionStatus.denied;
  }
  @override
  Future<LocationData> getCurrentLocation() async {
    throw UnsupportedError('Location service not available in stub mode');
  }
  @override
  Stream<LocationData> getLocationStream() {
    return const Stream.empty(); // Empty stream
  }
  @override
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    return null; // No address available
  }
  @override
  Future<LocationData?> getCoordinatesFromAddress(String address) async {
    return null; // No location available
  }

  @override
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return 0.0; // Return 0 distance
  }

  @override
  bool isWithinGeofence(
    LocationData location,
    GeofenceData geofence,
  ) {
    return false; // Always false for stub
  }

  @override
  Future<void> startGeofenceMonitoring(GeofenceData geofence) async {
    // No-op for stub
  }

  @override
  Future<void> stopGeofenceMonitoring(String geofenceId) async {
    // No-op for stub
  }

  @override
  Future<void> stopAllGeofenceMonitoring() async {
    // No-op for stub
  }

  @override
  Stream<GeofenceEvent> getGeofenceEventStream() {
    return const Stream.empty(); // Empty stream
  }
  @override
  void dispose() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }
}
