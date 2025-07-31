import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/location/location_service.dart';
import '../../services/location/location_service_impl.dart';
import '../../services/location/location_models.dart';

// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationServiceImpl();
});

// Current location provider
final currentLocationProvider = FutureProvider<LocationData>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return await locationService.getCurrentLocation();
});

// Location stream provider
final locationStreamProvider = StreamProvider<LocationData>((ref) {
  final locationService = ref.read(locationServiceProvider);
  return locationService.getLocationStream();
});

// Location permission status provider
final locationPermissionProvider = FutureProvider<LocationPermissionStatus>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return await locationService.checkPermission();
});

// Location service enabled provider
final locationServiceEnabledProvider = FutureProvider<bool>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return await locationService.isLocationServiceEnabled();
});

// Geofence events stream provider
final geofenceEventsProvider = StreamProvider<GeofenceEvent>((ref) {
  final locationService = ref.read(locationServiceProvider);
  return locationService.getGeofenceEventStream();
});

// Location triggers state provider
final locationTriggersProvider = StateNotifierProvider<LocationTriggersNotifier, List<LocationTrigger>>((ref) {
  return LocationTriggersNotifier();
});

class LocationTriggersNotifier extends StateNotifier<List<LocationTrigger>> {
  LocationTriggersNotifier() : super([]);

  void addLocationTrigger(LocationTrigger trigger) {
    state = [...state, trigger];
  }

  void removeLocationTrigger(String triggerId) {
    state = state.where((trigger) => trigger.id != triggerId).toList();
  }

  void updateLocationTrigger(LocationTrigger updatedTrigger) {
    state = state.map((trigger) {
      return trigger.id == updatedTrigger.id ? updatedTrigger : trigger;
    }).toList();
  }

  void toggleLocationTrigger(String triggerId) {
    state = state.map((trigger) {
      if (trigger.id == triggerId) {
        return trigger.copyWith(isEnabled: !trigger.isEnabled);
      }
      return trigger;
    }).toList();
  }

  List<LocationTrigger> getTriggersForTask(String taskId) {
    return state.where((trigger) => trigger.taskId == taskId).toList();
  }
}

// Location settings provider
final locationSettingsProvider = StateNotifierProvider<LocationSettingsNotifier, LocationSettings>((ref) {
  return LocationSettingsNotifier();
});

class LocationSettingsNotifier extends StateNotifier<LocationSettings> {
  LocationSettingsNotifier() : super(const LocationSettings());

  void updateLocationEnabled(bool enabled) {
    state = state.copyWith(locationEnabled: enabled);
  }

  void updateGeofencingEnabled(bool enabled) {
    state = state.copyWith(geofencingEnabled: enabled);
  }

  void updateLocationAccuracy(LocationAccuracy accuracy) {
    state = state.copyWith(locationAccuracy: accuracy);
  }

  void updateLocationUpdateInterval(Duration interval) {
    state = state.copyWith(locationUpdateInterval: interval);
  }
}

class LocationSettings {
  final bool locationEnabled;
  final bool geofencingEnabled;
  final LocationAccuracy locationAccuracy;
  final Duration locationUpdateInterval;

  const LocationSettings({
    this.locationEnabled = false,
    this.geofencingEnabled = false,
    this.locationAccuracy = LocationAccuracy.high,
    this.locationUpdateInterval = const Duration(minutes: 5),
  });

  LocationSettings copyWith({
    bool? locationEnabled,
    bool? geofencingEnabled,
    LocationAccuracy? locationAccuracy,
    Duration? locationUpdateInterval,
  }) {
    return LocationSettings(
      locationEnabled: locationEnabled ?? this.locationEnabled,
      geofencingEnabled: geofencingEnabled ?? this.geofencingEnabled,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      locationUpdateInterval: locationUpdateInterval ?? this.locationUpdateInterval,
    );
  }
}

enum LocationAccuracy {
  low,
  medium,
  high,
  best,
}