import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:geocoding/geocoding.dart';
import 'location_service.dart';
import 'location_models.dart';

// Platform-specific geolocator imports
import 'dart:io' show Platform;
const kIsWeb = identical(0, 0.0);

/// Real implementation of LocationService using geolocator
class RealLocationService implements LocationService {
  StreamSubscription<geolocator.Position>? _positionSubscription;
  StreamController<LocationData>? _locationController;
  final Map<String, GeofenceData> _activeGeofences = {};
  final StreamController<GeofenceEvent> _geofenceController = 
      StreamController<GeofenceEvent>.broadcast();
  Timer? _geofenceMonitoringTimer;
  LocationData? _lastKnownLocation;

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
      // First check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) {
          print('Location services are disabled');
        }
        return LocationPermissionStatus.serviceDisabled;
      }

      final permission = await geolocator.Geolocator.requestPermission();
      final status = _mapGeolocatorPermission(permission);
      
      if (kDebugMode) {
        print('Location permission requested: $permission -> $status');
      }
      
      return status;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting location permission: $e');
      }
      return LocationPermissionStatus.denied;
    }
  }

  @override
  Future<LocationData> getCurrentLocation() async {
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

      // Get current position with platform-specific settings
      late geolocator.LocationSettings locationSettings;
      
      if (!kIsWeb && Platform.isAndroid) {
        locationSettings = const geolocator.LocationSettings(
          accuracy: geolocator.LocationAccuracy.high,
          distanceFilter: 0,
        );
      } else if (!kIsWeb && Platform.isIOS) {
        locationSettings = const geolocator.LocationSettings(
          accuracy: geolocator.LocationAccuracy.high,
          distanceFilter: 0,
        );
      } else {
        locationSettings = const geolocator.LocationSettings(
          accuracy: geolocator.LocationAccuracy.high,
          distanceFilter: 0,
        );
      }
      
      final position = await geolocator.Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Location request timed out after 10 seconds'),
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        timestamp: position.timestamp,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current location: $e');
      }
      rethrow;
    }
  }

  @override
  Stream<LocationData> getLocationStream() {
    try {
      _locationController?.close();
      _locationController = StreamController<LocationData>.broadcast();

      // Configure location settings
      const locationSettings = geolocator.LocationSettings(
        accuracy: geolocator.LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );

      _positionSubscription?.cancel();
      _positionSubscription = geolocator.Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (geolocator.Position position) {
          final locationData = LocationData(
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
            altitude: position.altitude,
            timestamp: position.timestamp,
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
  @override
  bool isWithinGeofence(
    LocationData location,
    GeofenceData geofence,
  ) {
    try {
      final distance = _calculateDistance(
        location.latitude,
        location.longitude,
        geofence.latitude,
        geofence.longitude,
      );
      
      return distance <= geofence.radius;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking geofence: $e');
      }
      return false;
    }
  }

  /// Get coordinates from address string
  @override
  Future<LocationData?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        final location = locations.first;
        return LocationData(
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
    _stopGeofenceMonitoringTimer();
    _geofenceController.close();
  }

  @override
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return geolocator.Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  bool isLocationWithinGeofence(
    LocationData location,
    GeofenceData geofence,
  ) {
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
    _activeGeofences[geofence.id] = geofence;
    _startGeofenceMonitoringTimer();
  }

  @override
  Future<void> stopGeofenceMonitoring(String geofenceId) async {
    _activeGeofences.remove(geofenceId);
    if (_activeGeofences.isEmpty) {
      _stopGeofenceMonitoringTimer();
    }
  }

  @override
  Future<void> stopAllGeofenceMonitoring() async {
    _activeGeofences.clear();
    _stopGeofenceMonitoringTimer();
  }

  @override
  Stream<GeofenceEvent> getGeofenceEventStream() {
    return _geofenceController.stream;
  }

  void _startGeofenceMonitoringTimer() {
    _geofenceMonitoringTimer?.cancel();
    _geofenceMonitoringTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
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

  void _stopGeofenceMonitoringTimer() {
    _geofenceMonitoringTimer?.cancel();
    _geofenceMonitoringTimer = null;
  }

  void _checkGeofences(LocationData currentLocation) {
    for (final geofence in _activeGeofences.values) {
      if (!geofence.isActive) continue;

      final isCurrentlyInside = isLocationWithinGeofence(currentLocation, geofence);
      final wasInside = _lastKnownLocation != null ? 
          isLocationWithinGeofence(_lastKnownLocation!, geofence) : false;

      // Check for enter event
      if (isCurrentlyInside && !wasInside) {
        if (geofence.type == GeofenceType.enter || 
            geofence.type == GeofenceType.both) {
          _geofenceController.add(GeofenceEvent(
            geofenceId: geofence.id,
            type: GeofenceEventType.enter,
            location: currentLocation,
            timestamp: DateTime.now(),
          ));
        }
      }

      // Check for exit event
      if (!isCurrentlyInside && wasInside) {
        if (geofence.type == GeofenceType.exit || 
            geofence.type == GeofenceType.both) {
          _geofenceController.add(GeofenceEvent(
            geofenceId: geofence.id,
            type: GeofenceEventType.exit,
            location: currentLocation,
            timestamp: DateTime.now(),
          ));
        }
      }
    }
  }

  /// Maps Geolocator permission to our permission enum
  LocationPermissionStatus _mapGeolocatorPermission(geolocator.LocationPermission permission) {
    switch (permission) {
      case geolocator.LocationPermission.always:
        return LocationPermissionStatus.always;
      case geolocator.LocationPermission.whileInUse:
        return LocationPermissionStatus.whileInUse;
      case geolocator.LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case geolocator.LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case geolocator.LocationPermission.unableToDetermine:
        return LocationPermissionStatus.denied;
    }
  }

  /// Calculate distance between two points in meters using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // Earth radius in meters
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}

/// Enhanced location service with geofencing capabilities
class EnhancedLocationService extends RealLocationService {
  final Map<String, GeofenceRegion> _geofences = {};
  Timer? _geofenceTimer;

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

  @override
  void _checkGeofences(LocationData currentLocation) {
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
          geofenceId: geofence.id,
          type: GeofenceEventType.enter,
          location: currentLocation,
          timestamp: DateTime.now(),
        ));
      } else if (!isInside && wasInside) {
        // Exited geofence
        geofence.isInside = false;
        _geofenceController.add(GeofenceEvent(
          geofenceId: geofence.id,
          type: GeofenceEventType.exit,
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


/// Geofence event data
