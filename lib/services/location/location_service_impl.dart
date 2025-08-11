import 'dart:async';
import 'package:flutter/foundation.dart';
import 'location_service.dart';
import 'location_models.dart';
import 'real_location_service.dart';

/// Main location service implementation - delegates to real or stub based on availability
class LocationServiceImpl implements LocationService {
  static LocationService? _instance;
  late final LocationService _delegate;

  LocationServiceImpl() {
    try {
      // Try to use real location service
      _delegate = RealLocationService();
    } catch (e) {
      if (kDebugMode) {
        print('Real location service not available, using stub: $e');
      }
      _delegate = _StubLocationService();
    }
  }

  static LocationServiceImpl getInstance() {
    return _instance ??= LocationServiceImpl() as LocationServiceImpl;
  }

  @override
  Future<bool> isLocationServiceEnabled() => _delegate.isLocationServiceEnabled();

  @override
  Future<LocationPermissionStatus> checkPermission() => _delegate.checkPermission();

  @override
  Future<LocationPermissionStatus> requestPermission() => _delegate.requestPermission();

  @override
  Future<LocationData> getCurrentLocation() => _delegate.getCurrentLocation();

  @override
  Stream<LocationData> getLocationStream() => _delegate.getLocationStream();

  @override
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) =>
      _delegate.getAddressFromCoordinates(latitude, longitude);

  @override
  Future<LocationData?> getCoordinatesFromAddress(String address) =>
      _delegate.getCoordinatesFromAddress(address);

  @override
  double calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) =>
      _delegate.calculateDistance(startLatitude, startLongitude, endLatitude, endLongitude);

  @override
  bool isWithinGeofence(LocationData location, GeofenceData geofence) =>
      _delegate.isWithinGeofence(location, geofence);

  @override
  Future<void> startGeofenceMonitoring(GeofenceData geofence) =>
      _delegate.startGeofenceMonitoring(geofence);

  @override
  Future<void> stopGeofenceMonitoring(String geofenceId) =>
      _delegate.stopGeofenceMonitoring(geofenceId);

  @override
  Future<void> stopAllGeofenceMonitoring() =>
      _delegate.stopAllGeofenceMonitoring();

  @override
  Stream<GeofenceEvent> getGeofenceEventStream() =>
      _delegate.getGeofenceEventStream();

  @override
  void dispose() => _delegate.dispose();
}

/// Stub implementation fallback when geolocator is not available
class _StubLocationService implements LocationService {
  StreamSubscription<LocationData>? _positionSubscription;  @override
  Future<bool> isLocationServiceEnabled() async {
    return false; // Always false for stub
  }  @override
  Future<LocationPermissionStatus> checkPermission() async {
    return LocationPermissionStatus.denied;
  }  @override
  Future<LocationPermissionStatus> requestPermission() async {
    return LocationPermissionStatus.denied;
  }  @override
  Future<LocationData> getCurrentLocation() async {
    throw Exception('Location service not available in stub mode');
  }  @override
  Stream<LocationData> getLocationStream() {
    return const Stream.empty(); // Empty stream
  }  @override
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    return null; // No address available
  }  Future<double> getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) async {
    return 0.0; // Return 0 distance
  }  @override
  void dispose() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }  @override
  noSuchMethod(Invocation invocation) {
    if (kDebugMode) {
      // print('Stub: LocationService method ${invocation.memberName} called');
    }
    
    // Return appropriate default values based on return type
    final returnType = invocation.memberName.toString();
    if (returnType.contains('Future<bool>')) {
      return Future.value(false);
    } else if (returnType.contains('Future<LocationData?>')) {
      return Future.value(null);
    } else if (returnType.contains('Future<double>')) {
      return Future.value(0.0);
    } else if (returnType.contains('Future<void>')) {
      return Future.value();
    } else if (returnType.contains('Stream<')) {
      return const Stream.empty();
    } else if (returnType.contains('double')) {
      return 0.0;
    } else if (returnType.contains('bool')) {
      return false;
    }
    
    return super.noSuchMethod(invocation);
  }
}