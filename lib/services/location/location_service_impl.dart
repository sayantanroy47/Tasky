import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'location_service.dart';
import 'location_models.dart';

class LocationServiceImpl implements LocationService {
  StreamSubscription<Position>? _positionSubscription;
  final StreamController<GeofenceEvent> _geofenceController = StreamController<GeofenceEvent>.broadcast();
  final Map<String, GeofenceData> _activeGeofences = {};
  LocationData? _lastKnownLocation;

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      throw LocationServiceException('Failed to check location service status: $e');
    }
  }

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return _mapPermissionStatus(permission);
    } catch (e) {
      throw LocationServiceException('Failed to check location permission: $e');
    }
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return _mapPermissionStatus(permission);
    } catch (e) {
      throw LocationServiceException('Failed to request location permission: $e');
    }
  }

  @override
  Future<LocationData> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      if (!await isLocationServiceEnabled()) {
        throw const LocationServiceException('Location services are disabled');
      }

      // Check permissions
      final permission = await checkPermission();
      if (permission == LocationPermissionStatus.denied ||
          permission == LocationPermissionStatus.deniedForever) {
        throw const LocationServiceException('Location permission denied');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final locationData = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        timestamp: position.timestamp ?? DateTime.now(),
      );

      _lastKnownLocation = locationData;
      return locationData;
    } catch (e) {
      if (e is LocationServiceException) rethrow;
      throw LocationServiceException('Failed to get current location: $e');
    }
  }

  @override
  Stream<LocationData> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).map((position) {
      final locationData = LocationData(
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
      throw LocationServiceException('Location stream error: $error');
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
      throw LocationServiceException('Failed to get address from coordinates: $e');
    }
  }

  @override
  Future<LocationData?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return LocationData(
          latitude: location.latitude,
          longitude: location.longitude,
          address: address,
          timestamp: DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      throw LocationServiceException('Failed to get coordinates from address: $e');
    }
  }

  @override
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  @override
  bool isWithinGeofence(LocationData location, GeofenceData geofence) {
    final distance = calculateDistance(
      location.latitude,
      location.longitude,
      geofence.latitude,
      geofence.longitude,
    );
    return distance <= geofence.radius;
  }

  @override
  Future<void> startGeofenceMonitoring(GeofenceData geofence) async {
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
  Stream<GeofenceEvent> getGeofenceEventStream() {
    return _geofenceController.stream;
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _geofenceController.close();
    _activeGeofences.clear();
  }

  // Private helper methods

  LocationPermissionStatus _mapPermissionStatus(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
        return LocationPermissionStatus.always;
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.whileInUse;
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.unableToDetermine;
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

  void _checkGeofences(LocationData location) {
    for (final geofence in _activeGeofences.values) {
      _checkSingleGeofence(location, geofence);
    }
  }

  void _checkSingleGeofence(LocationData location, GeofenceData geofence) {
    final isInside = isWithinGeofence(location, geofence);
    
    // For simplicity, we'll emit events based on current state
    // In a real implementation, you'd track previous state to detect enter/exit
    if (isInside) {
      if (geofence.type == GeofenceType.enter || geofence.type == GeofenceType.both) {
        _geofenceController.add(GeofenceEvent(
          geofenceId: geofence.id,
          type: GeofenceEventType.enter,
          location: location,
          timestamp: DateTime.now(),
        ));
      }
    } else {
      if (geofence.type == GeofenceType.exit || geofence.type == GeofenceType.both) {
        _geofenceController.add(GeofenceEvent(
          geofenceId: geofence.id,
          type: GeofenceEventType.exit,
          location: location,
          timestamp: DateTime.now(),
        ));
      }
    }
  }
}