import 'dart:async';
import 'location_service.dart';
import 'location_models.dart' as models;
import '../notification/notification_service.dart';

import '../../domain/repositories/task_repository.dart';

class GeofencingManager {
  final LocationService _locationService;
  final NotificationService _notificationService;
  final TaskRepository _taskRepository;
  StreamSubscription<models.GeofenceEvent>? _geofenceSubscription;
  StreamSubscription<models.LocationData>? _locationSubscription;
  final Map<String, models.LocationTrigger> _activeTriggers = {};
  final Map<String, bool> _geofenceStates = {}; // Track enter/exit states

  GeofencingManager(
    this._locationService,
    this._notificationService,
    this._taskRepository,
  );

  /// Initialize geofencing manager
  Future<void> initialize() async {
    // Start listening to geofence events
    _geofenceSubscription = _locationService.getGeofenceEventStream().listen(
      _handleGeofenceEvent,
      onError: (error) {
        // print('Geofence event error: $error');
      },
    );

    // Start listening to location updates for continuous monitoring
    _locationSubscription = _locationService.getLocationStream().listen(
      _handleLocationUpdate,
      onError: (error) {
        // print('Location update error: $error');
      },
    );
  }

  /// Add a location trigger
  Future<void> addLocationTrigger(models.LocationTrigger trigger) async {
    if (!trigger.isEnabled) return;

    _activeTriggers[trigger.id] = trigger;
    
    // Start monitoring the geofence
    await _locationService.startGeofenceMonitoring(trigger.geofence);
    
    // Initialize geofence state
    _geofenceStates[trigger.geofence.id] = false;
  }

  /// Remove a location trigger
  Future<void> removeLocationTrigger(String triggerId) async {
    final trigger = _activeTriggers.remove(triggerId);
    if (trigger != null) {
      await _locationService.stopGeofenceMonitoring(trigger.geofence.id);
      _geofenceStates.remove(trigger.geofence.id);
    }
  }

  /// Update a location trigger
  Future<void> updateLocationTrigger(models.LocationTrigger trigger) async {
    await removeLocationTrigger(trigger.id);
    if (trigger.isEnabled) {
      await addLocationTrigger(trigger);
    }
  }

  /// Get all active triggers
  List<models.LocationTrigger> getActiveTriggers() {
    return _activeTriggers.values.toList();
  }

  /// Get triggers for a specific task
  List<models.LocationTrigger> getTriggersForTask(String taskId) {
    return _activeTriggers.values
        .where((trigger) => trigger.taskId == taskId)
        .toList();
  }

  /// Dispose resources
  void dispose() {
    _geofenceSubscription?.cancel();
    _locationSubscription?.cancel();
    _locationService.stopAllGeofenceMonitoring();
    _activeTriggers.clear();
    _geofenceStates.clear();
  }

  // Private methods

  void _handleGeofenceEvent(models.GeofenceEvent event) async {
    final trigger = _activeTriggers.values
        .where((t) => t.geofence.id == event.geofenceId)
        .firstOrNull;

    if (trigger == null) return;

    final previousState = _geofenceStates[event.geofenceId] ?? false;
    final currentState = event.type == models.GeofenceEventType.enter;

    // Only trigger if state actually changed
    if (previousState != currentState) {
      _geofenceStates[event.geofenceId] = currentState;
      
      // Check if this event type should trigger a notification
      final shouldTrigger = _shouldTriggerForEvent(trigger.geofence.type, event.type);
      
      if (shouldTrigger) {
        await _sendLocationNotification(trigger, event);
      }
    }
  }

  void _handleLocationUpdate(models.LocationData location) {
    // Check all active geofences against current location
    for (final trigger in _activeTriggers.values) {
      final isInside = _locationService.isWithinGeofence(location, trigger.geofence);
      final previousState = _geofenceStates[trigger.geofence.id] ?? false;

      if (isInside != previousState) {
        _geofenceStates[trigger.geofence.id] = isInside;
        
        final eventType = isInside ? models.GeofenceEventType.enter : models.GeofenceEventType.exit;
        final shouldTrigger = _shouldTriggerForEvent(trigger.geofence.type, eventType);
        
        if (shouldTrigger) {
          final event = models.GeofenceEvent(
            geofenceId: trigger.geofence.id,
            type: eventType,
            location: location,
            timestamp: DateTime.now(),
          );
          
          _sendLocationNotification(trigger, event);
        }
      }
    }
  }

  bool _shouldTriggerForEvent(models.GeofenceType geofenceType, models.GeofenceEventType eventType) {
    switch (geofenceType) {
      case models.GeofenceType.enter:
        return eventType == models.GeofenceEventType.enter;
      case models.GeofenceType.exit:
        return eventType == models.GeofenceEventType.exit;
      case models.GeofenceType.both:
        return true;
    }
  }

  Future<void> _sendLocationNotification(models.LocationTrigger trigger, models.GeofenceEvent event) async {
    try {
      // Get task details from repository
      final task = await _taskRepository.getTaskById(trigger.taskId);
      final taskTitle = task?.title ?? 'Unknown Task';
      
      final eventTypeText = event.type == models.GeofenceEventType.enter ? 'entered' : 'left';
      const title = 'Location Reminder';
      const body = 'You have $eventTypeText ${trigger.geofence.name}. Don\'t forget about your task: $taskTitle';

      await _notificationService.showImmediateNotification(
        title: title,
        body: body,
        taskId: trigger.taskId,
        payload: {
          'type': 'location_trigger',
          'triggerId': trigger.id,
          'taskId': trigger.taskId,
        },
      );
    } catch (e) {
      // print('Error sending location notification: $e');
    }
  }
}
