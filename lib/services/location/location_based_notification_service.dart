import 'dart:async';
import 'package:flutter/foundation.dart';
import '../notification/notification_service.dart';
import '../notification/notification_models.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/task_enums.dart';
import '../../domain/repositories/task_repository.dart';
import 'location_service.dart';
import 'location_models.dart';

/// Service that handles location-based notifications and geofence triggers
class LocationBasedNotificationService {
  final LocationService _locationService;
  final NotificationService _notificationService;
  final TaskRepository _taskRepository;
  
  StreamSubscription<GeofenceEvent>? _geofenceSubscription;
  final Map<String, LocationTrigger> _activeTriggers = {};

  LocationBasedNotificationService({
    required LocationService locationService,
    required NotificationService notificationService,
    required TaskRepository taskRepository,
  }) : _locationService = locationService,
       _notificationService = notificationService,
       _taskRepository = taskRepository {
    _initializeGeofenceListening();
  }

  /// Initialize geofence event listening
  void _initializeGeofenceListening() {
    _geofenceSubscription = _locationService.getGeofenceEventStream().listen(
      _handleGeofenceEvent,
      onError: (error) {
        if (kDebugMode) {
          print('Geofence event stream error: $error');
        }
      },
    );
  }

  /// Handle geofence enter/exit events
  Future<void> _handleGeofenceEvent(GeofenceEvent event) async {
    try {
      final trigger = _activeTriggers[event.geofenceId];
      if (trigger == null || !trigger.isEnabled) return;

      final task = await _taskRepository.getTaskById(trigger.taskId);
      if (task == null) {
        // Clean up orphaned trigger
        await removeLocationTrigger(trigger.id);
        return;
      }

      // Don't send notifications for completed tasks
      if (task.status == TaskStatus.completed) return;

      await _sendLocationBasedNotification(task, event, trigger);
    } catch (e) {
      if (kDebugMode) {
        print('Error handling geofence event: $e');
      }
    }
  }

  /// Send location-based notification
  Future<void> _sendLocationBasedNotification(
    TaskModel task,
    GeofenceEvent event,
    LocationTrigger trigger,
  ) async {
    final isEnterEvent = event.type == GeofenceEventType.enter;
    
    String title;
    String body;
    NotificationTypeModel notificationType;

    if (isEnterEvent) {
      title = 'Location Reminder';
      body = 'You\'re at ${trigger.geofence.name}: ${task.title}';
      notificationType = NotificationTypeModel.locationBased;
    } else {
      title = 'Leaving Location';
      body = 'Leaving ${trigger.geofence.name}: Don\'t forget "${task.title}"';
      notificationType = NotificationTypeModel.locationBased;
    }

    await _notificationService.showImmediateNotification(
      title: title,
      body: body,
      taskId: task.id,
      type: notificationType,
      payload: {
        'geofenceId': event.geofenceId,
        'eventType': event.type.name,
        'location': {
          'latitude': event.location.latitude,
          'longitude': event.location.longitude,
        },
      },
    );

    if (kDebugMode) {
      print('Location-based notification sent: $title - $body');
    }
  }

  /// Add a location trigger for a task
  Future<LocationTrigger> addLocationTrigger({
    required String taskId,
    required String locationName,
    required double latitude,
    required double longitude,
    required double radiusMeters,
    GeofenceType triggerType = GeofenceType.both,
  }) async {
    final geofenceId = 'geofence_${taskId}_${DateTime.now().millisecondsSinceEpoch}';
    
    final geofence = GeofenceData(
      id: geofenceId,
      name: locationName,
      latitude: latitude,
      longitude: longitude,
      radius: radiusMeters,
      isActive: true,
      type: triggerType,
      createdAt: DateTime.now(),
    );

    final trigger = LocationTrigger(
      id: 'trigger_$geofenceId',
      taskId: taskId,
      geofence: geofence,
      isEnabled: true,
      createdAt: DateTime.now(),
    );

    // Start monitoring this geofence
    await _locationService.startGeofenceMonitoring(geofence);
    
    // Store the trigger
    _activeTriggers[geofenceId] = trigger;

    if (kDebugMode) {
      print('Added location trigger for task $taskId at $locationName');
    }

    return trigger;
  }

  /// Remove a location trigger
  Future<void> removeLocationTrigger(String triggerId) async {
    final trigger = _activeTriggers.values
        .cast<LocationTrigger?>()
        .firstWhere((t) => t?.id == triggerId, orElse: () => null);
    
    if (trigger != null) {
      await _locationService.stopGeofenceMonitoring(trigger.geofence.id);
      _activeTriggers.remove(trigger.geofence.id);
      
      if (kDebugMode) {
        print('Removed location trigger: $triggerId');
      }
    }
  }

  /// Remove all location triggers for a task
  Future<void> removeTaskLocationTriggers(String taskId) async {
    final taskTriggers = _activeTriggers.values
        .where((trigger) => trigger.taskId == taskId)
        .toList();

    for (final trigger in taskTriggers) {
      await removeLocationTrigger(trigger.id);
    }
  }

  /// Get all active location triggers
  List<LocationTrigger> getActiveLocationTriggers() {
    return _activeTriggers.values.toList();
  }

  /// Get location triggers for a specific task
  List<LocationTrigger> getTaskLocationTriggers(String taskId) {
    return _activeTriggers.values
        .where((trigger) => trigger.taskId == taskId)
        .toList();
  }

  /// Enable or disable a location trigger
  Future<void> setLocationTriggerEnabled(String triggerId, bool enabled) async {
    final trigger = _activeTriggers.values
        .cast<LocationTrigger?>()
        .firstWhere((t) => t?.id == triggerId, orElse: () => null);
    
    if (trigger != null) {
      final updatedTrigger = trigger.copyWith(isEnabled: enabled);
      _activeTriggers[trigger.geofence.id] = updatedTrigger;
      
      if (kDebugMode) {
        print('Location trigger $triggerId ${enabled ? "enabled" : "disabled"}');
      }
    }
  }

  /// Get nearby active location triggers
  Future<List<LocationTrigger>> getNearbyLocationTriggers({
    double radiusKm = 5.0,
  }) async {
    try {
      final currentLocation = await _locationService.getCurrentLocation();
      final nearbyTriggers = <LocationTrigger>[];

      for (final trigger in _activeTriggers.values) {
        if (!trigger.isEnabled) continue;

        final distance = _locationService.calculateDistance(
          currentLocation.latitude,
          currentLocation.longitude,
          trigger.geofence.latitude,
          trigger.geofence.longitude,
        );

        // Convert radius from km to meters
        if (distance <= radiusKm * 1000) {
          nearbyTriggers.add(trigger);
        }
      }

      return nearbyTriggers;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting nearby location triggers: $e');
      }
      return [];
    }
  }

  /// Create location trigger from address
  Future<LocationTrigger?> addLocationTriggerFromAddress({
    required String taskId,
    required String address,
    required double radiusMeters,
    GeofenceType triggerType = GeofenceType.both,
  }) async {
    try {
      final locationData = await _locationService.getCoordinatesFromAddress(address);
      if (locationData == null) {
        if (kDebugMode) {
          print('Could not find coordinates for address: $address');
        }
        return null;
      }

      return await addLocationTrigger(
        taskId: taskId,
        locationName: address,
        latitude: locationData.latitude,
        longitude: locationData.longitude,
        radiusMeters: radiusMeters,
        triggerType: triggerType,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating location trigger from address: $e');
      }
      return null;
    }
  }

  /// Get location suggestions for a task based on common places
  Future<List<LocationSuggestion>> getLocationSuggestions(TaskModel task) async {
    final suggestions = <LocationSuggestion>[];

    // Add common location suggestions based on task content
    final taskTitle = task.title.toLowerCase();
    final taskDescription = task.description?.toLowerCase() ?? '';

    // Work-related locations
    if (taskTitle.contains('work') || taskTitle.contains('office') ||
        taskDescription.contains('work') || taskDescription.contains('office')) {
      suggestions.add(const LocationSuggestion(
        name: 'Office',
        description: 'When you arrive at or leave the office',
        icon: '🏢',
        suggestedRadius: 100,
      ));
    }

    // Home-related locations
    if (taskTitle.contains('home') || taskDescription.contains('home')) {
      suggestions.add(const LocationSuggestion(
        name: 'Home',
        description: 'When you arrive at or leave home',
        icon: '🏠',
        suggestedRadius: 50,
      ));
    }

    // Shopping-related locations
    if (taskTitle.contains('shop') || taskTitle.contains('buy') ||
        taskTitle.contains('grocery') || taskDescription.contains('shop')) {
      suggestions.addAll([
        const LocationSuggestion(
          name: 'Grocery Store',
          description: 'When you visit the grocery store',
          icon: '🛒',
          suggestedRadius: 100,
        ),
        const LocationSuggestion(
          name: 'Shopping Mall',
          description: 'When you visit the mall',
          icon: '🏬',
          suggestedRadius: 200,
        ),
      ]);
    }

    // Gym-related locations
    if (taskTitle.contains('gym') || taskTitle.contains('workout') ||
        taskTitle.contains('exercise') || taskDescription.contains('gym')) {
      suggestions.add(const LocationSuggestion(
        name: 'Gym',
        description: 'When you arrive at or leave the gym',
        icon: '💪',
        suggestedRadius: 100,
      ));
    }

    return suggestions;
  }

  /// Test location trigger by simulating entry/exit
  Future<void> testLocationTrigger(String triggerId) async {
    final trigger = _activeTriggers.values
        .cast<LocationTrigger?>()
        .firstWhere((t) => t?.id == triggerId, orElse: () => null);
    
    if (trigger == null) return;

    try {
      // Simulate an enter event
      final testEvent = GeofenceEvent(
        geofenceId: trigger.geofence.id,
        type: GeofenceEventType.enter,
        location: LocationData(
          latitude: trigger.geofence.latitude,
          longitude: trigger.geofence.longitude,
          timestamp: DateTime.now(),
        ),
        timestamp: DateTime.now(),
      );

      await _handleGeofenceEvent(testEvent);

      if (kDebugMode) {
        print('Test notification sent for location trigger: $triggerId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error testing location trigger: $e');
      }
    }
  }

  /// Dispose of resources
  void dispose() {
    _geofenceSubscription?.cancel();
    _geofenceSubscription = null;
    
    // Stop all geofence monitoring
    for (final trigger in _activeTriggers.values) {
      _locationService.stopGeofenceMonitoring(trigger.geofence.id);
    }
    _activeTriggers.clear();
  }
}

/// Location suggestion for tasks
class LocationSuggestion {
  final String name;
  final String description;
  final String icon;
  final double suggestedRadius;

  const LocationSuggestion({
    required this.name,
    required this.description,
    required this.icon,
    required this.suggestedRadius,
  });
}

/// Extended notification types for location-based notifications
extension NotificationTypeModelExtension on NotificationTypeModel {
  static const locationBased = NotificationTypeModel.taskReminder; // Reuse existing type for now
}