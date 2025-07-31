import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'location_models.dart';
import 'geofencing_manager.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

class LocationTaskService {
  final TaskRepository _taskRepository;
  final GeofencingManager _geofencingManager;
  final Ref _ref;

  LocationTaskService(
    this._taskRepository,
    this._geofencingManager,
    this._ref,
  );

  /// Create a location-based task
  Future<Task> createLocationTask({
    required String title,
    required String description,
    required GeofenceData geofence,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
    List<String> tags = const [],
  }) async {
    // Create the task
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      isCompleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      dueDate: dueDate,
      priority: priority,
      tags: tags,
      projectId: null,
      subtasks: [],
      dependencies: [],
      isRecurring: false,
      recurrencePattern: null,
      templateId: null,
    );

    // Save the task
    final savedTask = await _taskRepository.createTask(task);

    // Create location trigger
    final locationTrigger = LocationTrigger(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: savedTask.id,
      geofence: geofence,
      isEnabled: true,
      createdAt: DateTime.now(),
    );

    // Add the location trigger to geofencing manager
    await _geofencingManager.addLocationTrigger(locationTrigger);

    return savedTask;
  }

  /// Add location trigger to existing task
  Future<LocationTrigger> addLocationTriggerToTask({
    required String taskId,
    required GeofenceData geofence,
  }) async {
    // Verify task exists
    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      throw Exception('Task not found');
    }

    // Create location trigger
    final locationTrigger = LocationTrigger(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: taskId,
      geofence: geofence,
      isEnabled: true,
      createdAt: DateTime.now(),
    );

    // Add the location trigger to geofencing manager
    await _geofencingManager.addLocationTrigger(locationTrigger);

    return locationTrigger;
  }

  /// Remove location trigger from task
  Future<void> removeLocationTriggerFromTask(String triggerId) async {
    await _geofencingManager.removeLocationTrigger(triggerId);
  }

  /// Update location trigger
  Future<void> updateLocationTrigger(LocationTrigger trigger) async {
    await _geofencingManager.updateLocationTrigger(trigger);
  }

  /// Get location triggers for a task
  List<LocationTrigger> getLocationTriggersForTask(String taskId) {
    return _geofencingManager.getTriggersForTask(taskId);
  }

  /// Get all location-based tasks
  Future<List<Task>> getLocationBasedTasks() async {
    final allTasks = await _taskRepository.getAllTasks();
    final activeTriggers = _geofencingManager.getActiveTriggers();
    final locationTaskIds = activeTriggers.map((t) => t.taskId).toSet();

    return allTasks.where((task) => locationTaskIds.contains(task.id)).toList();
  }

  /// Get tasks near a location
  Future<List<TaskLocationInfo>> getTasksNearLocation({
    required LocationData location,
    double radiusInMeters = 1000,
  }) async {
    final activeTriggers = _geofencingManager.getActiveTriggers();
    final nearbyTasks = <TaskLocationInfo>[];

    for (final trigger in activeTriggers) {
      final distance = _calculateDistance(
        location.latitude,
        location.longitude,
        trigger.geofence.latitude,
        trigger.geofence.longitude,
      );

      if (distance <= radiusInMeters) {
        final task = await _taskRepository.getTaskById(trigger.taskId);
        if (task != null) {
          nearbyTasks.add(TaskLocationInfo(
            task: task,
            trigger: trigger,
            distance: distance,
          ));
        }
      }
    }

    // Sort by distance
    nearbyTasks.sort((a, b) => a.distance.compareTo(b.distance));
    return nearbyTasks;
  }

  /// Get tasks for current location
  Future<List<TaskLocationInfo>> getTasksForCurrentLocation({
    double radiusInMeters = 1000,
  }) async {
    // This would typically get current location from location service
    // For now, we'll return empty list as placeholder
    return [];
  }

  /// Enable/disable location features for a task
  Future<void> toggleLocationFeaturesForTask(String taskId, bool enabled) async {
    final triggers = _geofencingManager.getTriggersForTask(taskId);
    
    for (final trigger in triggers) {
      final updatedTrigger = trigger.copyWith(isEnabled: enabled);
      await _geofencingManager.updateLocationTrigger(updatedTrigger);
    }
  }

  /// Get location statistics
  Future<LocationStatistics> getLocationStatistics() async {
    final activeTriggers = _geofencingManager.getActiveTriggers();
    final locationTasks = await getLocationBasedTasks();

    return LocationStatistics(
      totalLocationTriggers: activeTriggers.length,
      activeLocationTriggers: activeTriggers.where((t) => t.isEnabled).length,
      totalLocationTasks: locationTasks.length,
      completedLocationTasks: locationTasks.where((t) => t.isCompleted).length,
    );
  }

  // Private helper methods

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Simple distance calculation (Haversine formula would be more accurate)
    const double earthRadius = 6371000; // Earth's radius in meters
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.cos() * lat2.cos() * (dLon / 2).sin() * (dLon / 2).sin();
    final double c = 2 * a.sqrt().asin();
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}

class TaskLocationInfo {
  final Task task;
  final LocationTrigger trigger;
  final double distance;

  const TaskLocationInfo({
    required this.task,
    required this.trigger,
    required this.distance,
  });
}

class LocationStatistics {
  final int totalLocationTriggers;
  final int activeLocationTriggers;
  final int totalLocationTasks;
  final int completedLocationTasks;

  const LocationStatistics({
    required this.totalLocationTriggers,
    required this.activeLocationTriggers,
    required this.totalLocationTasks,
    required this.completedLocationTasks,
  });

  double get completionRate {
    if (totalLocationTasks == 0) return 0.0;
    return completedLocationTasks / totalLocationTasks;
  }

  double get activeTriggerRate {
    if (totalLocationTriggers == 0) return 0.0;
    return activeLocationTriggers / totalLocationTriggers;
  }
}