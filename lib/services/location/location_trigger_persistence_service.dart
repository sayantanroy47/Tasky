import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import 'location_models.dart';
import 'geofencing_manager.dart';

/// Service for persisting and loading location triggers from the database
class LocationTriggerPersistenceService {
  final TaskRepository _taskRepository;
  final GeofencingManager _geofencingManager;

  LocationTriggerPersistenceService(
    this._taskRepository,
    this._geofencingManager,
  );

  /// Load all existing location triggers from tasks and activate them
  Future<void> loadAndActivateExistingTriggers() async {
    try {
      // Get all tasks from the database
      final tasks = await _taskRepository.getAllTasks();
      
      // Filter tasks that have location triggers
      final tasksWithLocationTriggers = tasks.where((task) => 
          task.locationTrigger != null && 
          task.locationTrigger!.isNotEmpty
      ).toList();

      // Parse and activate each location trigger
      for (final task in tasksWithLocationTriggers) {
        try {
          final triggerData = jsonDecode(task.locationTrigger!);
          final trigger = LocationTriggerPersistence.fromJson(triggerData, task.id);
          
          // Only activate if the trigger is enabled and the task is not completed
          if (trigger.isEnabled && task.status != TaskStatus.completed) {
            await _geofencingManager.addLocationTrigger(trigger);
          }
        } catch (e) {
          // Log error for individual trigger parsing failure but continue
          debugPrint('Warning: Failed to parse location trigger for task ${task.id}: $e');
        }
      }
      
      debugPrint('Successfully loaded and activated ${tasksWithLocationTriggers.length} location triggers');
    } catch (e) {
      debugPrint('Error loading location triggers: $e');
      rethrow;
    }
  }

  /// Save location trigger data to a task
  Future<void> saveLocationTriggerForTask(String taskId, LocationTrigger trigger) async {
    try {
      final task = await _taskRepository.getTaskById(taskId);
      if (task == null) {
        throw Exception('Task not found: $taskId');
      }

      // Update the task with the location trigger data
      final updatedTask = task.copyWith(
        locationTrigger: jsonEncode(trigger.toJson()),
        metadata: {
          ...task.metadata,
          'has_location_trigger': true,
          'trigger_type': trigger.geofence.type.name,
          'geofence_radius': trigger.geofence.radius,
          'location_display': '${trigger.geofence.latitude.toStringAsFixed(4)}, ${trigger.geofence.longitude.toStringAsFixed(4)}',
        },
      );

      await _taskRepository.updateTask(updatedTask);
    } catch (e) {
      debugPrint('Error saving location trigger for task $taskId: $e');
      rethrow;
    }
  }

  /// Remove location trigger data from a task
  Future<void> removeLocationTriggerForTask(String taskId) async {
    try {
      final task = await _taskRepository.getTaskById(taskId);
      if (task == null) {
        throw Exception('Task not found: $taskId');
      }

      // Remove the location trigger data from the task
      final updatedMetadata = Map<String, dynamic>.from(task.metadata);
      updatedMetadata.remove('has_location_trigger');
      updatedMetadata.remove('trigger_type');
      updatedMetadata.remove('geofence_radius');
      updatedMetadata.remove('location_display');

      final updatedTask = task.copyWith(
        locationTrigger: null,
        metadata: updatedMetadata,
      );

      await _taskRepository.updateTask(updatedTask);
    } catch (e) {
      debugPrint('Error removing location trigger for task $taskId: $e');
      rethrow;
    }
  }

  /// Get all tasks that have location triggers
  Future<List<TaskModel>> getTasksWithLocationTriggers() async {
    try {
      final allTasks = await _taskRepository.getAllTasks();
      return allTasks.where((task) => 
          task.locationTrigger != null && 
          task.locationTrigger!.isNotEmpty
      ).toList();
    } catch (e) {
      debugPrint('Error getting tasks with location triggers: $e');
      rethrow;
    }
  }

  /// Clean up orphaned location triggers (triggers for deleted tasks)
  Future<void> cleanupOrphanedTriggers() async {
    try {
      // Get all active triggers from the geofencing manager
      final activeTriggers = _geofencingManager.getActiveTriggers();
      
      // Check each trigger to see if its associated task still exists
      for (final trigger in activeTriggers) {
        final task = await _taskRepository.getTaskById(trigger.taskId);
        
        if (task == null) {
          // Task no longer exists, remove the trigger
          await _geofencingManager.removeLocationTrigger(trigger.id);
          debugPrint('Removed orphaned location trigger: ${trigger.id}');
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up orphaned triggers: $e');
      rethrow;
    }
  }

  /// Update location trigger when task is completed
  Future<void> handleTaskCompletion(String taskId) async {
    try {
      // Find and disable any location triggers for the completed task
      final activeTriggers = _geofencingManager.getTriggersForTask(taskId);
      
      for (final trigger in activeTriggers) {
        // Remove the trigger from active monitoring
        await _geofencingManager.removeLocationTrigger(trigger.id);
        debugPrint('Disabled location trigger for completed task: $taskId');
      }
    } catch (e) {
      debugPrint('Error handling task completion for location triggers: $e');
      rethrow;
    }
  }

  /// Update location trigger when task is deleted
  Future<void> handleTaskDeletion(String taskId) async {
    try {
      // Find and remove any location triggers for the deleted task
      final activeTriggers = _geofencingManager.getTriggersForTask(taskId);
      
      for (final trigger in activeTriggers) {
        await _geofencingManager.removeLocationTrigger(trigger.id);
        debugPrint('Removed location trigger for deleted task: $taskId');
      }
    } catch (e) {
      debugPrint('Error handling task deletion for location triggers: $e');
      rethrow;
    }
  }

  /// Reactivate location triggers when task is uncompleted
  Future<void> handleTaskReactivation(String taskId) async {
    try {
      final task = await _taskRepository.getTaskById(taskId);
      if (task?.locationTrigger != null) {
        final triggerData = jsonDecode(task!.locationTrigger!);
        final trigger = LocationTriggerPersistence.fromJson(triggerData, taskId);
        
        if (trigger.isEnabled) {
          await _geofencingManager.addLocationTrigger(trigger);
          debugPrint('Reactivated location trigger for task: $taskId');
        }
      }
    } catch (e) {
      debugPrint('Error handling task reactivation for location triggers: $e');
      rethrow;
    }
  }
}

/// Extension for LocationTrigger to support JSON serialization with task ID
extension LocationTriggerPersistence on LocationTrigger {
  /// Create LocationTrigger from JSON data
  static LocationTrigger fromJson(Map<String, dynamic> json, String taskId) {
    final geofenceData = json['geofence'] as Map<String, dynamic>;
    
    return LocationTrigger(
      id: json['id'] as String,
      taskId: taskId, // Use the provided task ID
      geofence: GeofenceData(
        id: geofenceData['id'] as String,
        name: geofenceData['name'] as String? ?? 'Task Location',
        latitude: geofenceData['latitude'] as double,
        longitude: geofenceData['longitude'] as double,
        radius: geofenceData['radius'] as double,
        isActive: geofenceData['isActive'] as bool? ?? true,
        type: GeofenceType.values.firstWhere(
          (type) => type.name == geofenceData['type'],
          orElse: () => GeofenceType.enter,
        ),
        createdAt: DateTime.parse(geofenceData['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      ),
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  /// Convert LocationTrigger to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'geofence': {
        'id': geofence.id,
        'name': geofence.name,
        'latitude': geofence.latitude,
        'longitude': geofence.longitude,
        'radius': geofence.radius,
        'isActive': geofence.isActive,
        'type': geofence.type.name,
        'createdAt': geofence.createdAt.toIso8601String(),
      },
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

