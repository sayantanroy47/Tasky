import 'dart:async';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'location_service.dart';
import 'location_models.dart' as models;

/// Real implementation of LocationService using geolocator
class RealLocationService implements LocationService {
  StreamSubscription<geolocator.Position>? _positionSubscription;
  StreamController<models.LocationData>? _locationController;

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await geolocator.Geolocator.isLocationServiceEnabled();
    } catch (e) {
      if (kDebugMode) {
        print('Error checking location service: $e');
      }
      return false;
    }
  }

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    try {
      final permission = await geolocator.Geolocator.checkPermission();
      return _mapGeolocatorPermission(permission);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking location permission: $e');
      }
      return LocationPermissionStatus.denied;
    }
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    try {
      final permission = await geolocator.Geolocator.requestPermission();
      return _mapGeolocatorPermission(permission);
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting location permission: $e');
      }
      return LocationPermissionStatus.denied;
    }
  }

  @override
  Future<models.LocationData> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permissions
      final permission = await checkPermission();
      if (permission == LocationPermissionStatus.denied) {
        final requestResult = await requestPermission();
        if (requestResult == LocationPermissionStatus.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermissionStatus.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      final position = await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return models.LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        heading: position.heading,
        speed: position.speed,
        timestamp: position.timestamp ?? DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current location: $e');
      }
      rethrow;
    }
  }

  @override
  Stream<models.LocationData> getLocationStream() {
    try {
      _locationController?.close();
      _locationController = StreamController<models.LocationData>.broadcast();

      // Configure location settings
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );

      _positionSubscription?.cancel();
      _positionSubscription = geolocator.Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          final locationData = models.LocationData(
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
            altitude: position.altitude,
            heading: position.heading,
            speed: position.speed,
            timestamp: position.timestamp ?? DateTime.now(),
          );
          _locationController?.add(locationData);
        },
        onError: (error) {
          if (kDebugMode) {
            print('Location stream error: $error');
          }
          _locationController?.addError(error);
        },
      );

      return _locationController!.stream;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating location stream: $e');
      }
      return Stream.error(e);
    }
  }

  @override
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final addressParts = <String>[];
        
        if (place.street?.isNotEmpty == true) addressParts.add(place.street!);
        if (place.locality?.isNotEmpty == true) addressParts.add(place.locality!);
        if (place.administrativeArea?.isNotEmpty == true) addressParts.add(place.administrativeArea!);
        if (place.country?.isNotEmpty == true) addressParts.add(place.country!);
        
        return addressParts.join(', ');
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting address from coordinates: $e');
      }
      return null;
    }
  }

  Future<double> getDistanceBetween(
    double startLatitude,
    double startLongitude,  
    double endLatitude,
    double endLongitude,
  ) async {
    try {
      return geolocator.Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating distance: $e');
      }
      return 0.0;
    }
  }

  /// Calculate bearing between two points
  Future<double> getBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) async {
    try {
      return geolocator.Geolocator.bearingBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating bearing: $e');
      }
      return 0.0;
    }
  }

  /// Check if device is within a geofenced area
  Future<bool> isWithinGeofence(
    double centerLatitude,
    double centerLongitude,
    double radiusInMeters,
  ) async {
    try {
      final currentLocation = await getCurrentLocation();
      final distance = await getDistanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        centerLatitude,
        centerLongitude,
      );
      
      return distance <= radiusInMeters;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking geofence: $e');
      }
      return false;
    }
  }

  /// Get coordinates from address string
  Future<models.LocationData?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        final location = locations.first;
        return models.LocationData(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
        );
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting coordinates from address: $e');
      }
      return null;
    }
  }

  /// Open device settings for location permissions
  Future<bool> openLocationSettings() async {
    try {
      return await geolocator.Geolocator.openLocationSettings();
    } catch (e) {
      if (kDebugMode) {
        print('Error opening location settings: $e');
      }
      return false;
    }
  }

  /// Open app settings for permissions
  Future<bool> openAppSettings() async {
    try {
      return await geolocator.Geolocator.openAppSettings();
    } catch (e) {
      if (kDebugMode) {
        print('Error opening app settings: $e');
      }
      return false;
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _locationController?.close();
    _locationController = null;
  }

  /// Maps Geolocator permission to our permission enum
  LocationPermissionStatus _mapGeolocatorPermission(LocationPermission permission) {
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
        return LocationPermissionStatus.denied;
    }
  }
}

/// Enhanced location service with geofencing capabilities
class EnhancedLocationService extends RealLocationService {
  final Map<String, GeofenceRegion> _geofences = {};
  Timer? _geofenceTimer;
  models.LocationData? _lastKnownLocation;

  /// Add a geofence region
  void addGeofence(GeofenceRegion region) {
    _geofences[region.id] = region;
    _startGeofenceMonitoring();
  }

  /// Remove a geofence region
  void removeGeofence(String regionId) {
    _geofences.remove(regionId);
    if (_geofences.isEmpty) {
      _stopGeofenceMonitoring();
    }
  }

  /// Get all active geofences
  List<GeofenceRegion> getActiveGeofences() {
    return _geofences.values.toList();
  }

  /// Stream of geofence events
  Stream<GeofenceEvent> get geofenceEvents => _geofenceController.stream;
  final StreamController<GeofenceEvent> _geofenceController = 
      StreamController<GeofenceEvent>.broadcast();

  void _startGeofenceMonitoring() {
    _geofenceTimer?.cancel();
    _geofenceTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        final currentLocation = await getCurrentLocation();
        _checkGeofences(currentLocation);
        _lastKnownLocation = currentLocation;
      } catch (e) {
        if (kDebugMode) {
          print('Geofence monitoring error: $e');
        }
      }
    });
  }

  void _stopGeofenceMonitoring() {
    _geofenceTimer?.cancel();
    _geofenceTimer = null;
  }

  void _checkGeofences(models.LocationData currentLocation) {
    for (final geofence in _geofences.values) {
      final distance = geolocator.Geolocator.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        geofence.latitude,
        geofence.longitude,
      );

      final isInside = distance <= geofence.radius;
      final wasInside = geofence.isInside;

      if (isInside && !wasInside) {
        // Entered geofence
        geofence.isInside = true;
        _geofenceController.add(GeofenceEvent(
          type: GeofenceEventType.enter,
          region: geofence,
          location: currentLocation,
          timestamp: DateTime.now(),
        ));
      } else if (!isInside && wasInside) {
        // Exited geofence
        geofence.isInside = false;
        _geofenceController.add(GeofenceEvent(
          type: GeofenceEventType.exit,
          region: geofence,
          location: currentLocation,
          timestamp: DateTime.now(),
        ));
      }
    }
  }

  @override
  void dispose() {
    _stopGeofenceMonitoring();
    _geofenceController.close();
    super.dispose();
  }
}

/// Geofence region definition
class GeofenceRegion {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius; // in meters
  bool isInside;

  GeofenceRegion({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.isInside = false,
  });
}

/// Geofence event types
enum GeofenceEventType { enter, exit }

/// Geofence event data
class GeofenceEvent {
  final GeofenceEventType type;
  final GeofenceRegion region;
  final models.LocationData location;
  final DateTime timestamp;

  const GeofenceEvent({
    required this.type,
    required this.region,
    required this.location,
    required this.timestamp,
  });
}