import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geocoding/geocoding.dart';
import 'location_service.dart';
import 'location_models.dart' as models;

class LocationServiceImpl implements LocationService {
  StreamSubscription<geo.Position>? _positionSubscription;
  final StreamController<models.GeofenceEvent> _geofenceController = StreamController<models.GeofenceEvent>.broadcast();
  final Map<String, models.GeofenceData> _activeGeofences = {};
  models.LocationData? _lastKnownLocation;

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await geo.Geolocator.isLocationServiceEnabled();
    } catch (e) {
      throw models.LocationServiceException('Failed to check location service status: $e');
    }
  }

  @override
  Future<models.LocationPermissionStatus> checkPermission() async {
    try {
      final permission = await geo.Geolocator.checkPermission();
      return _mapPermissionStatus(permission);
    } catch (e) {
      throw models.LocationServiceException('Failed to check location permission: $e');
    }
  }

  @override
  Future<models.LocationPermissionStatus> requestPermission() async {
    try {
      final permission = await geo.Geolocator.requestPermission();
      return _mapPermissionStatus(permission);
    } catch (e) {
      throw models.LocationServiceException('Failed to request location permission: $e');
    }
  }

  @override
  Future<models.LocationData> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      if (!await isLocationServiceEnabled()) {
        throw const models.LocationServiceException('Location services are disabled');
      }

      // Check permissions
      final permission = await checkPermission();
      if (permission == models.LocationPermissionStatus.denied ||
          permission == models.LocationPermissionStatus.deniedForever) {
        throw const models.LocationServiceException('Location permission denied');
      }

      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final locationData = models.LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        timestamp: position.timestamp ?? DateTime.now(),
      );

      _lastKnownLocation = locationData;
      return locationData;
    } catch (e) {
      if (e is models.LocationServiceException) rethrow;
      throw models.LocationServiceException('Failed to get current location: $e');
    }
  }

  @override
  Stream<models.LocationData> getLocationStream() {
    return geo.Geolocator.getPositionStream(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).map((position) {
      final locationData = models.LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        timestamp: position.timestamp ?? DateTime.now(),
      );

      _lastKnownLocation = locationData;
      _checkGeofences(locationData);
      return locationData;
    }).handleError((error) {
      throw models.LocationServiceException('Location stream error: $error');
    });
  }

  @override
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return _formatAddress(placemark);
      }
      return null;
    } catch (e) {
      throw models.LocationServiceException('Failed to get address from coordinates: $e');
    }
  }

  @override
  Future<models.LocationData?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return models.LocationData(
          latitude: location.latitude,
          longitude: location.longitude,
          address: address,
          timestamp: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      throw models.LocationServiceException('Failed to get coordinates from address: $e');
    }
  }

  @override
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return geo.Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  @override
  bool isWithinGeofence(models.LocationData location, models.GeofenceData geofence) {
    final distance = calculateDistance(
      location.latitude,
      location.longitude,
      geofence.latitude,
      geofence.longitude,
    );
    return distance <= geofence.radius;
  }

  @override
  Future<void> startGeofenceMonitoring(models.GeofenceData geofence) async {
    if (!geofence.isActive) return;

    _activeGeofences[geofence.id] = geofence;

    // Check current location against geofence if available
    if (_lastKnownLocation != null) {
      _checkSingleGeofence(_lastKnownLocation!, geofence);
    }
  }

  @override
  Future<void> stopGeofenceMonitoring(String geofenceId) async {
    _activeGeofences.remove(geofenceId);
  }

  @override
  Future<void> stopAllGeofenceMonitoring() async {
    _activeGeofences.clear();
  }

  @override
  Stream<models.GeofenceEvent> getGeofenceEventStream() {
    return _geofenceController.stream;
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _geofenceController.close();
    _activeGeofences.clear();
  }

  // Private helper methods

  models.LocationPermissionStatus _mapPermissionStatus(geo.LocationPermission permission) {
    switch (permission) {
      case geo.LocationPermission.always:
        return models.LocationPermissionStatus.always;
      case geo.LocationPermission.whileInUse:
        return models.LocationPermissionStatus.whileInUse;
      case geo.LocationPermission.denied:
        return models.LocationPermissionStatus.denied;
      case geo.LocationPermission.deniedForever:
        return models.LocationPermissionStatus.deniedForever;
      case geo.LocationPermission.unableToDetermine:
        return models.LocationPermissionStatus.unableToDetermine;
    }
  }

  String _formatAddress(Placemark placemark) {
    final parts = <String>[];
    
    if (placemark.street?.isNotEmpty == true) {
      parts.add(placemark.street!);
    }
    if (placemark.locality?.isNotEmpty == true) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea?.isNotEmpty == true) {
      parts.add(placemark.administrativeArea!);
    }
    if (placemark.country?.isNotEmpty == true) {
      parts.add(placemark.country!);
    }

    return parts.join(', ');
  }

  void _checkGeofences(models.LocationData location) {
    for (final geofence in _activeGeofences.values) {
      _checkSingleGeofence(location, geofence);
    }
  }

  void _checkSingleGeofence(models.LocationData location, models.GeofenceData geofence) {
    final isInside = isWithinGeofence(location, geofence);
    
    // For simplicity, we'll emit events based on current state
    // In a real implementation, you'd track previous state to detect enter/exit
    if (isInside) {
      if (geofence.type == models.GeofenceType.enter || geofence.type == models.GeofenceType.both) {
        _geofenceController.add(models.GeofenceEvent(
          geofenceId: geofence.id,
          type: models.GeofenceEventType.enter,
          location: location,
          timestamp: DateTime.now(),
        ));
      }
    } else {
      if (geofence.type == models.GeofenceType.exit || geofence.type == models.GeofenceType.both) {
        _geofenceController.add(models.GeofenceEvent(
          geofenceId: geofence.id,
          type: models.GeofenceEventType.exit,
          location: location,
          timestamp: DateTime.now(),
        ));
      }
    }
  }
}