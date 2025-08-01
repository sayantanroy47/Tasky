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
  Future<LocationData?> getCurrentLocation() async {
    return null; // No location available
  }

  @override
  Stream<LocationData> getLocationStream() {
    return Stream.empty(); // Empty stream
  }

  @override
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    return null; // No address available
  }

  @override
  Future<LocationData?> getLocationFromAddress(String address) async {
    return null; // No location available
  }

  @override
  Future<double> getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) async {
    return 0.0; // Return 0 distance
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }
}
