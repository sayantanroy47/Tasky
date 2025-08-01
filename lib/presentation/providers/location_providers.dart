import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/location/location_service.dart';
import '../../services/location/location_service_impl.dart';
import '../../services/location/location_models.dart';
import '../../services/location/geofencing_manager.dart';
import '../../services/location/location_task_service.dart';
import '../../domain/entities/task_model.dart';
import 'task_providers.dart';
import 'notification_providers.dart';

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

// Geofencing manager provider
final geofencingManagerProvider = Provider<GeofencingManager>((ref) {
  final locationService = ref.read(locationServiceProvider);
  final notificationService = ref.read(notificationServiceProvider);
  final taskRepository = ref.read(taskRepositoryProvider);
  
  return GeofencingManager(
    locationService,
    notificationService,
    taskRepository,
    ref,
  );
});

// Location task service provider
final locationTaskServiceProvider = Provider<LocationTaskService>((ref) {
  final taskRepository = ref.read(taskRepositoryProvider);
  final geofencingManager = ref.read(geofencingManagerProvider);
  
  return LocationTaskService(
    taskRepository,
    geofencingManager,
    ref,
  );
});

// Location triggers state provider
final locationTriggersProvider = StateNotifierProvider<LocationTriggersNotifier, List<LocationTrigger>>((ref) {
  final geofencingManager = ref.read(geofencingManagerProvider);
  return LocationTriggersNotifier(geofencingManager);
});

class LocationTriggersNotifier extends StateNotifier<List<LocationTrigger>> {
  final GeofencingManager _geofencingManager;

  LocationTriggersNotifier(this._geofencingManager) : super([]) {
    // Initialize with existing triggers from geofencing manager
    state = _geofencingManager.getActiveTriggers();
  }

  Future<void> addLocationTrigger(LocationTrigger trigger) async {
    await _geofencingManager.addLocationTrigger(trigger);
    state = [...state, trigger];
  }

  Future<void> removeLocationTrigger(String triggerId) async {
    await _geofencingManager.removeLocationTrigger(triggerId);
    state = state.where((trigger) => trigger.id != triggerId).toList();
  }

  Future<void> updateLocationTrigger(LocationTrigger updatedTrigger) async {
    await _geofencingManager.updateLocationTrigger(updatedTrigger);
    state = state.map((trigger) {
      return trigger.id == updatedTrigger.id ? updatedTrigger : trigger;
    }).toList();
  }

  Future<void> toggleLocationTrigger(String triggerId) async {
    final trigger = state.firstWhere((t) => t.id == triggerId);
    final updatedTrigger = trigger.copyWith(isEnabled: !trigger.isEnabled);
    await updateLocationTrigger(updatedTrigger);
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

  void updateBackgroundLocationEnabled(bool enabled) {
    state = state.copyWith(backgroundLocationEnabled: enabled);
  }

  void updateLocationHistoryEnabled(bool enabled) {
    state = state.copyWith(locationHistoryEnabled: enabled);
  }

  void updateLocationUpdateInterval(int intervalSeconds) {
    state = state.copyWith(locationUpdateIntervalSeconds: intervalSeconds);
  }
}

// Location-based task filtering provider
final nearbyTasksProvider = FutureProvider.family<List<TaskModel>, double>((ref, radiusInMeters) async {
  final locationService = ref.read(locationServiceProvider);
  final taskRepository = ref.read(taskRepositoryProvider);
  final triggers = ref.watch(locationTriggersProvider);
  
  try {
    final currentLocation = await locationService.getCurrentLocation();
    final nearbyTasks = <TaskModel>[];
    
    for (final trigger in triggers) {
      final distance = locationService.calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        trigger.geofence.latitude,
        trigger.geofence.longitude,
      );
      
      if (distance <= radiusInMeters) {
        final task = await taskRepository.getTaskById(trigger.taskId);
        if (task != null) {
          nearbyTasks.add(task);
        }
      }
    }
    
    return nearbyTasks;
  } catch (e) {
    return [];
  }
});

// Location privacy controls provider
final locationPrivacyProvider = StateNotifierProvider<LocationPrivacyNotifier, LocationPrivacySettings>((ref) {
  return LocationPrivacyNotifier();
});

class LocationPrivacyNotifier extends StateNotifier<LocationPrivacySettings> {
  LocationPrivacyNotifier() : super(const LocationPrivacySettings());

  void updateLocationDataRetention(int days) {
    state = state.copyWith(locationDataRetentionDays: days);
  }

  void updateLocationSharingEnabled(bool enabled) {
    state = state.copyWith(locationSharingEnabled: enabled);
  }

  void updateLocationAnalyticsEnabled(bool enabled) {
    state = state.copyWith(locationAnalyticsEnabled: enabled);
  }

  void updateLocationHistoryEnabled(bool enabled) {
    state = state.copyWith(locationHistoryEnabled: enabled);
  }
}

class LocationPrivacySettings {
  final int locationDataRetentionDays;
  final bool locationSharingEnabled;
  final bool locationAnalyticsEnabled;
  final bool locationHistoryEnabled;

  const LocationPrivacySettings({
    this.locationDataRetentionDays = 30,
    this.locationSharingEnabled = false,
    this.locationAnalyticsEnabled = false,
    this.locationHistoryEnabled = false,
  });

  LocationPrivacySettings copyWith({
    int? locationDataRetentionDays,
    bool? locationSharingEnabled,
    bool? locationAnalyticsEnabled,
    bool? locationHistoryEnabled,
  }) {
    return LocationPrivacySettings(
      locationDataRetentionDays: locationDataRetentionDays ?? this.locationDataRetentionDays,
      locationSharingEnabled: locationSharingEnabled ?? this.locationSharingEnabled,
      locationAnalyticsEnabled: locationAnalyticsEnabled ?? this.locationAnalyticsEnabled,
      locationHistoryEnabled: locationHistoryEnabled ?? this.locationHistoryEnabled,
    );
  }
}
