import 'dart:async';
import 'package:flutter/foundation.dart';
import 'location_service.dart';
import 'location_models.dart';

/// Stub implementation of LocationService when geolocator is not available
class LocationServiceImpl implements LocationService {
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
    throw Exception('Location service not available in stub mode');
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

  @override
  noSuchMethod(Invocation invocation) {
    if (kDebugMode) {
      print('Stub: LocationService method ${invocation.memberName} called');
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
      return Stream.empty();
    } else if (returnType.contains('double')) {
      return 0.0;
    } else if (returnType.contains('bool')) {
      return false;
    }
    
    return super.noSuchMethod(invocation);
  }
}