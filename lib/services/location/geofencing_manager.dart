import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'location_service.dart';
import 'location_models.dart';
import '../notification/notification_service.dart';
import '../../domain/entities/task.dart';

class GeofencingManager {
  final LocationService _locationService;
  final NotificationService _notificationService;
  final Ref _ref;
  
  StreamSubscription<GeofenceEvent>? _geofenceSubscription;
  StreamSubscription<LocationData>? _locationSubscription;
  final Map<String, LocationTrigger> _activeTriggers = {};
  final Map<String, bool> _geofenceStates = {}; // Track enter/exit states

  GeofencingManager(
    this._locationService,
    this._notificationService,
    this._ref,
  );

  /// Initialize geofencing manager
  Future<void> initialize() async {
    // Start listening to geofence events
    _geofenceSubscription = _locationService.getGeofenceEventStream().listen(
      _handleGeofenceEvent,
      onError: (error) {
        print('Geofence event error: $error');
      },
    );

    // Start listening to location updates for continuous monitoring
    _locationSubscription = _locationService.getLocationStream().listen(
      _handleLocationUpdate,
      onError: (error) {
        print('Location update error: $error');
      },
    );
  }

  /// Add a location trigger
  Future<void> addLocationTrigger(LocationTrigger trigger) async {
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
  Future<void> updateLocationTrigger(LocationTrigger trigger) async {
    await removeLocationTrigger(trigger.id);
    if (trigger.isEnabled) {
      await addLocationTrigger(trigger);
    }
  }

  /// Get all active triggers
  List<LocationTrigger> getActiveTriggers() {
    return _activeTriggers.values.toList();
  }

  /// Get triggers for a specific task
  List<LocationTrigger> getTriggersForTask(String taskId) {
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

  void _handleGeofenceEvent(GeofenceEvent event) async {
    final trigger = _activeTriggers.values
        .where((t) => t.geofence.id == event.geofenceId)
        .firstOrNull;

    if (trigger == null) return;

    final previousState = _geofenceStates[event.geofenceId] ?? false;
    final currentState = event.type == GeofenceEventType.enter;

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

  void _handleLocationUpdate(LocationData location) {
    // Check all active geofences against current location
    for (final trigger in _activeTriggers.values) {
      final isInside = _locationService.isWithinGeofence(location, trigger.geofence);
      final previousState = _geofenceStates[trigger.geofence.id] ?? false;

      if (isInside != previousState) {
        _geofenceStates[trigger.geofence.id] = isInside;
        
        final eventType = isInside ? GeofenceEventType.enter : GeofenceEventType.exit;
        final shouldTrigger = _shouldTriggerForEvent(trigger.geofence.type, eventType);
        
        if (shouldTrigger) {
          final event = GeofenceEvent(
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

  bool _shouldTriggerForEvent(GeofenceType geofenceType, GeofenceEventType eventType) {
    switch (geofenceType) {
      case GeofenceType.enter:
        return eventType == GeofenceEventType.enter;
      case GeofenceType.exit:
        return eventType == GeofenceEventType.exit;
      case GeofenceType.both:
        return true;
    }
  }

  Future<void> _sendLocationNotification(LocationTrigger trigger, GeofenceEvent event) async {
    try {
      // Get task details (this would typically come from a task repository)
      final taskTitle = 'Location Reminder'; // Placeholder
      
      final eventTypeText = event.type == GeofenceEventType.enter ? 'entered' : 'left';
      final title = 'Location Reminder';
      final body = 'You have $eventTypeText ${trigger.geofence.name}. Don\'t forget about your task: $taskTitle';

      await _notificationService.showNotification(
        id: trigger.id.hashCode,
        title: title,
        body: body,
        payload: 'location_trigger:${trigger.id}',
      );
    } catch (e) {
      print('Error sending location notification: $e');
    }
  }
}