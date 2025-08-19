import 'dart:async';
import 'package:flutter/foundation.dart';
import '../system_calendar_service.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../domain/repositories/task_repository.dart';

/// Enhanced calendar integration service with advanced features
class EnhancedCalendarIntegrationService extends SystemCalendarService {
  final TaskRepository _taskRepository;
  final Map<String, String> _taskToEventMapping = {}; // task_id -> event_id
  final Map<String, String> _eventToTaskMapping = {}; // event_id -> task_id
  
  Timer? _syncTimer;
  StreamController<CalendarSyncEvent>? _syncEventController;
  
  // Sync settings
  bool _autoSyncEnabled = false;
  Duration _syncInterval = const Duration(minutes: 15);
  DateTime? _lastSyncTime;
  
  EnhancedCalendarIntegrationService({
    required TaskRepository taskRepository,
  }) : _taskRepository = taskRepository {
    _syncEventController = StreamController<CalendarSyncEvent>.broadcast();
  }

  /// Stream of sync events
  Stream<CalendarSyncEvent> get syncEvents => 
      _syncEventController?.stream ?? const Stream<CalendarSyncEvent>.empty();

  /// Initialize enhanced calendar service
  @override
  Future<bool> initialize() async {
    final initialized = await super.initialize();
    if (initialized) {
      await _loadSyncMappings();
      if (_autoSyncEnabled) {
        startAutoSync();
      }
    }
    return initialized;
  }

  /// Enable auto-sync with customizable interval
  void enableAutoSync({Duration? interval}) {
    _autoSyncEnabled = true;
    if (interval != null) {
      _syncInterval = interval;
    }
    startAutoSync();
  }

  /// Disable auto-sync
  void disableAutoSync() {
    _autoSyncEnabled = false;
    stopAutoSync();
  }

  /// Start auto-sync timer
  void startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) async {
      try {
        await performEnhancedSync();
      } catch (e) {
        if (kDebugMode) {
          print('Auto-sync error: $e');
        }
      }
    });
  }

  /// Stop auto-sync timer
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Perform enhanced bidirectional sync
  Future<EnhancedSyncResult> performEnhancedSync() async {
    _syncEventController?.add(CalendarSyncEvent(
      type: CalendarSyncEventType.syncStarted,
      message: 'Starting enhanced sync...',
    ));

    try {
      final result = EnhancedSyncResult();
      
      // 1. Export new tasks to calendar
      await _exportNewTasksToCalendar(result);
      
      // 2. Update modified tasks in calendar
      await _updateModifiedTasksInCalendar(result);
      
      // 3. Import new events from calendar as tasks
      await _importNewEventsFromCalendar(result);
      
      // 4. Handle deleted events/tasks
      await _handleDeletedItems(result);
      
      // 5. Resolve conflicts
      await _resolveConflicts(result);
      
      _lastSyncTime = DateTime.now();
      
      _syncEventController?.add(CalendarSyncEvent(
        type: CalendarSyncEventType.syncCompleted,
        message: 'Sync completed successfully',
        details: {
          'exported': result.exportedCount,
          'imported': result.importedCount,
          'updated': result.updatedCount,
          'conflicts': result.conflictsResolved,
        },
      ));
      
      return result;
    } catch (e) {
      _syncEventController?.add(CalendarSyncEvent(
        type: CalendarSyncEventType.syncFailed,
        message: 'Sync failed: $e',
        error: e.toString(),
      ));
      
      return EnhancedSyncResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Export new tasks that haven't been synced to calendar
  Future<void> _exportNewTasksToCalendar(EnhancedSyncResult result) async {
    final tasks = await _taskRepository.getAllTasks();
    final unsyncedTasks = tasks.where((task) => 
        !_taskToEventMapping.containsKey(task.id) && 
        task.dueDate != null &&
        task.status != TaskStatus.completed
    ).toList();

    for (final task in unsyncedTasks) {
      try {
        final startTime = task.dueDate!;
        final endTime = task.estimatedDuration != null
            ? startTime.add(Duration(minutes: task.estimatedDuration!))
            : startTime.add(const Duration(hours: 1));

        final syncResult = await syncTaskToCalendar(
          task,
          startTime,
          endTime,
          location: _extractLocationFromTask(task),
        );

        if (syncResult.success && syncResult.eventId != null) {
          _taskToEventMapping[task.id] = syncResult.eventId!;
          _eventToTaskMapping[syncResult.eventId!] = task.id;
          result.exportedCount++;
          
          _syncEventController?.add(CalendarSyncEvent(
            type: CalendarSyncEventType.taskExported,
            message: 'Exported task: ${task.title}',
            taskId: task.id,
            eventId: syncResult.eventId,
          ));
        }
      } catch (e) {
        result.errors.add('Failed to export task ${task.title}: $e');
      }
    }
  }

  /// Update modified tasks in calendar
  Future<void> _updateModifiedTasksInCalendar(EnhancedSyncResult result) async {
    final tasks = await _taskRepository.getAllTasks();
    final syncedTasks = tasks.where((task) => 
        _taskToEventMapping.containsKey(task.id)
    ).toList();

    for (final task in syncedTasks) {
      try {
        final eventId = _taskToEventMapping[task.id]!;
        
        // Check if task has been modified since last sync
        if (_wasTaskModifiedSinceLastSync(task)) {
          final calendarEvent = _createCalendarEventFromTask(task);
          final syncResult = await updateCalendarEvent(eventId, calendarEvent);
          
          if (syncResult.success) {
            result.updatedCount++;
            
            _syncEventController?.add(CalendarSyncEvent(
              type: CalendarSyncEventType.taskUpdated,
              message: 'Updated task in calendar: ${task.title}',
              taskId: task.id,
              eventId: eventId,
            ));
          }
        }
      } catch (e) {
        result.errors.add('Failed to update task ${task.title}: $e');
      }
    }
  }

  /// Import new events from calendar as tasks
  Future<void> _importNewEventsFromCalendar(EnhancedSyncResult result) async {
    final events = await importEventsFromCalendar(
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 30)),
    );

    final newEvents = events.where((event) => 
        !_eventToTaskMapping.containsKey(event.id)
    ).toList();

    for (final event in newEvents) {
      try {
        // Only import events that look like tasks (have certain keywords or patterns)
        if (_shouldImportEventAsTask(event)) {
          final task = _createTaskFromCalendarEvent(event);
          await _taskRepository.createTask(task);
          
          _eventToTaskMapping[event.id] = task.id;
          _taskToEventMapping[task.id] = event.id;
          result.importedCount++;
          
          _syncEventController?.add(CalendarSyncEvent(
            type: CalendarSyncEventType.eventImported,
            message: 'Imported event as task: ${event.title}',
            taskId: task.id,
            eventId: event.id,
          ));
        }
      } catch (e) {
        result.errors.add('Failed to import event ${event.title}: $e');
      }
    }
  }

  /// Handle deleted events/tasks
  Future<void> _handleDeletedItems(EnhancedSyncResult result) async {
    // Check for tasks that were deleted but still have calendar events
    final tasks = await _taskRepository.getAllTasks();
    final existingTaskIds = tasks.map((t) => t.id).toSet();
    
    final orphanedEventIds = _taskToEventMapping.keys
        .where((taskId) => !existingTaskIds.contains(taskId))
        .map((taskId) => _taskToEventMapping[taskId]!)
        .toList();

    for (final eventId in orphanedEventIds) {
      try {
        await deleteCalendarEvent(eventId);
        _cleanupMappings(taskId: _eventToTaskMapping[eventId], eventId: eventId);
        result.deletedCount++;
      } catch (e) {
        result.errors.add('Failed to delete orphaned calendar event: $e');
      }
    }
  }

  /// Resolve sync conflicts
  Future<void> _resolveConflicts(EnhancedSyncResult result) async {
    // This is a simplified conflict resolution
    // In a real implementation, you'd want to detect conflicts and let users choose
    
    final conflicts = await _detectConflicts();
    for (final conflict in conflicts) {
      try {
        await _resolveConflict(conflict);
        result.conflictsResolved++;
      } catch (e) {
        result.errors.add('Failed to resolve conflict: $e');
      }
    }
  }

  /// Create a calendar event from a task
  CalendarEvent _createCalendarEventFromTask(TaskModel task) {
    final startTime = task.dueDate ?? DateTime.now();
    final endTime = task.estimatedDuration != null
        ? startTime.add(Duration(minutes: task.estimatedDuration!))
        : startTime.add(const Duration(hours: 1));

    return CalendarEvent.create(
      title: task.title,
      description: _buildEventDescription(task),
      startTime: startTime,
      endTime: endTime,
      location: _extractLocationFromTask(task),
      reminders: _getRemindersForTask(task),
      metadata: {
        'taskId': task.id,
        'priority': task.priority.name,
        'tags': task.tags,
        'syncSource': 'tasky_app',
      },
    );
  }

  /// Create a task from a calendar event
  TaskModel _createTaskFromCalendarEvent(CalendarEvent event) {
    final priority = _extractPriorityFromEvent(event);
    final tags = _extractTagsFromEvent(event);

    return TaskModel.create(
      title: event.title,
      description: event.description,
      priority: priority,
      dueDate: event.startTime,
      estimatedDuration: event.endTime.difference(event.startTime).inMinutes,
      tags: tags,
      metadata: {
        'importedFromCalendar': true,
        'calendarEventId': event.id,
        'originalLocation': event.location,
      },
    );
  }

  /// Extract location from task description or title
  String? _extractLocationFromTask(TaskModel task) {
    // Look for location patterns in task description
    final text = '${task.title} ${task.description ?? ''}'.toLowerCase();
    
    // Simple location detection patterns
    final locationPatterns = [
      RegExp(r'at ([^,\n]+)'),
      RegExp(r'@ ([^,\n]+)'),
      RegExp(r'location:?\s*([^,\n]+)'),
    ];

    for (final pattern in locationPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }

    return null;
  }

  /// Build event description from task
  String _buildEventDescription(TaskModel task) {
    final buffer = StringBuffer();
    
    if (task.description?.isNotEmpty == true) {
      buffer.writeln(task.description);
      buffer.writeln();
    }

    buffer.writeln('Priority: ${task.priority.name.toUpperCase()}');
    
    if (task.tags.isNotEmpty) {
      buffer.writeln('Tags: ${task.tags.join(', ')}');
    }

    if (task.projectId != null) {
      buffer.writeln('Project ID: ${task.projectId}');
    }

    buffer.writeln();
    buffer.writeln('Created in Tasky App');

    return buffer.toString();
  }

  /// Check if an event should be imported as a task
  bool _shouldImportEventAsTask(CalendarEvent event) {
    // Don't import events that were originally synced from tasks
    if (event.metadata['syncSource'] == 'tasky_app') {
      return false;
    }

    // Import events that contain task-like keywords
    final text = '${event.title} ${event.description ?? ''}'.toLowerCase();
    final taskKeywords = [
      'todo',
      'task',
      'deadline',
      'project',
      'complete',
      'finish',
      'work on',
      'review',
      'prepare',
    ];

    return taskKeywords.any((keyword) => text.contains(keyword));
  }

  /// Extract priority from calendar event
  TaskPriority _extractPriorityFromEvent(CalendarEvent event) {
    final text = '${event.title} ${event.description ?? ''}'.toLowerCase();
    
    if (text.contains('urgent') || text.contains('critical') || text.contains('asap')) {
      return TaskPriority.urgent;
    } else if (text.contains('important') || text.contains('high priority')) {
      return TaskPriority.high;
    } else if (text.contains('low priority') || text.contains('when possible')) {
      return TaskPriority.low;
    }
    
    return TaskPriority.medium;
  }

  /// Extract tags from calendar event
  List<String> _extractTagsFromEvent(CalendarEvent event) {
    final tags = <String>[];
    final text = '${event.title} ${event.description ?? ''}';
    
    // Look for hashtags
    final hashtagPattern = RegExp(r'#(\w+)');
    final hashtagMatches = hashtagPattern.allMatches(text);
    tags.addAll(hashtagMatches.map((match) => match.group(1)!));
    
    // Look for location as tag
    if (event.location?.isNotEmpty == true) {
      tags.add('location:${event.location}');
    }

    return tags;
  }

  /// Get reminders for a task
  List<int> _getRemindersForTask(TaskModel task) {
    // Default reminders based on priority
    switch (task.priority) {
      case TaskPriority.urgent:
        return [5, 15]; // 5 and 15 minutes before
      case TaskPriority.high:
        return [15]; // 15 minutes before
      case TaskPriority.medium:
        return [30]; // 30 minutes before
      case TaskPriority.low:
        return [60]; // 1 hour before
    }
  }

  /// Check if task was modified since last sync
  bool _wasTaskModifiedSinceLastSync(TaskModel task) {
    // In a real implementation, you'd store sync timestamps per task
    // For now, check if task was updated after last sync
    if (_lastSyncTime == null || task.updatedAt == null) {
      return true;
    }
    
    return task.updatedAt!.isAfter(_lastSyncTime!);
  }

  /// Detect sync conflicts
  Future<List<SyncConflict>> _detectConflicts() async {
    final conflicts = <SyncConflict>[];
    // Simplified conflict detection
    // In a real implementation, you'd compare modification timestamps
    // and detect when both task and calendar event were modified
    return conflicts;
  }

  /// Resolve a sync conflict
  Future<void> _resolveConflict(SyncConflict conflict) async {
    // Simplified resolution: use the most recently modified version
    // In a real implementation, you'd want user input for conflict resolution
  }

  /// Load sync mappings from persistent storage
  Future<void> _loadSyncMappings() async {
    // In a real implementation, you'd load these from SharedPreferences or database
    // For now, they start empty
  }

  /// Save sync mappings to persistent storage
  Future<void> _saveSyncMappings() async {
    // In a real implementation, you'd save to SharedPreferences or database
  }

  /// Clean up mappings when items are deleted
  void _cleanupMappings({String? taskId, String? eventId}) {
    if (taskId != null) {
      final eventId = _taskToEventMapping.remove(taskId);
      if (eventId != null) {
        _eventToTaskMapping.remove(eventId);
      }
    }
    
    if (eventId != null) {
      final taskId = _eventToTaskMapping.remove(eventId);
      if (taskId != null) {
        _taskToEventMapping.remove(taskId);
      }
    }
  }

  /// Get comprehensive sync statistics
  Future<CalendarSyncStatistics> getSyncStatistics() async {
    final tasks = await _taskRepository.getAllTasks();
    final syncedTasks = tasks.where((task) => _taskToEventMapping.containsKey(task.id)).length;
    
    return CalendarSyncStatistics(
      totalTasks: tasks.length,
      syncedTasks: syncedTasks,
      totalSyncedItems: _taskToEventMapping.length,
      lastSyncTime: _lastSyncTime,
      autoSyncEnabled: _autoSyncEnabled,
      syncInterval: _syncInterval,
      syncErrors: [], // Would track recent errors
    );
  }

  /// Force sync specific task
  Future<SystemCalendarResult> forceSyncTask(String taskId) async {
    try {
      final task = await _taskRepository.getTaskById(taskId);
      if (task == null) {
        return const SystemCalendarResult(
          success: false,
          error: 'Task not found',
        );
      }

      if (task.dueDate == null) {
        return const SystemCalendarResult(
          success: false,
          error: 'Task has no due date to sync',
        );
      }

      final startTime = task.dueDate!;
      final endTime = task.estimatedDuration != null
          ? startTime.add(Duration(minutes: task.estimatedDuration!))
          : startTime.add(const Duration(hours: 1));

      final result = await syncTaskToCalendar(
        task,
        startTime,
        endTime,
        location: _extractLocationFromTask(task),
      );

      if (result.success && result.eventId != null) {
        _taskToEventMapping[task.id] = result.eventId!;
        _eventToTaskMapping[result.eventId!] = task.id;
        await _saveSyncMappings();
      }

      return result;
    } catch (e) {
      return SystemCalendarResult(
        success: false,
        error: 'Failed to sync task: $e',
      );
    }
  }

  /// Remove task from calendar sync
  Future<bool> unsyncTask(String taskId) async {
    try {
      final eventId = _taskToEventMapping[taskId];
      if (eventId != null) {
        await deleteCalendarEvent(eventId);
        _cleanupMappings(taskId: taskId, eventId: eventId);
        await _saveSyncMappings();
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error unsyncing task: $e');
      }
      return false;
    }
  }

  /// Check if auto-sync is enabled
  bool get isAutoSyncEnabled => _autoSyncEnabled;

  /// Sync all tasks to calendar
  Future<void> syncAllTasksToCalendar(List<TaskModel> tasks) async {
    for (final task in tasks) {
      if (task.dueDate != null) {
        final startTime = task.dueDate!;
        final endTime = task.estimatedDuration != null
            ? startTime.add(Duration(minutes: task.estimatedDuration!))
            : startTime.add(const Duration(hours: 1));
        await syncTaskToCalendar(task, startTime, endTime);
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _syncEventController?.close();
  }
}

/// Enhanced sync result with detailed information
class EnhancedSyncResult {
  bool success;
  int exportedCount;
  int importedCount;
  int updatedCount;
  int deletedCount;
  int conflictsResolved;
  List<String> errors;
  String? error;

  EnhancedSyncResult({
    this.success = true,
    this.exportedCount = 0,
    this.importedCount = 0,
    this.updatedCount = 0,
    this.deletedCount = 0,
    this.conflictsResolved = 0,
    List<String>? errors,
    this.error,
  }) : errors = errors ?? [];

  int get totalProcessed => exportedCount + importedCount + updatedCount + deletedCount;
}

/// Calendar sync event for real-time updates
class CalendarSyncEvent {
  final CalendarSyncEventType type;
  final String message;
  final String? taskId;
  final String? eventId;
  final Map<String, dynamic>? details;
  final String? error;
  final DateTime timestamp;

  CalendarSyncEvent({
    required this.type,
    required this.message,
    this.taskId,
    this.eventId,
    this.details,
    this.error,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Types of calendar sync events
enum CalendarSyncEventType {
  syncStarted,
  syncCompleted,
  syncFailed,
  taskExported,
  taskUpdated,
  eventImported,
  conflictDetected,
  conflictResolved,
}

/// Sync conflict information
class SyncConflict {
  final String taskId;
  final String eventId;
  final ConflictType type;
  final Map<String, dynamic> taskData;
  final Map<String, dynamic> eventData;
  final DateTime detectedAt;

  const SyncConflict({
    required this.taskId,
    required this.eventId,
    required this.type,
    required this.taskData,
    required this.eventData,
    required this.detectedAt,
  });
}

/// Types of sync conflicts
enum ConflictType {
  titleMismatch,
  timeMismatch,
  descriptionMismatch,
  deletionConflict,
}

/// Calendar sync statistics
class CalendarSyncStatistics {
  final int totalTasks;
  final int syncedTasks;
  final int totalSyncedItems;
  final DateTime? lastSyncTime;
  final bool autoSyncEnabled;
  final Duration syncInterval;
  final List<String> syncErrors;

  const CalendarSyncStatistics({
    required this.totalTasks,
    required this.syncedTasks,
    required this.totalSyncedItems,
    this.lastSyncTime,
    required this.autoSyncEnabled,
    required this.syncInterval,
    required this.syncErrors,
  });

  double get syncPercentage => totalTasks > 0 ? (syncedTasks / totalTasks) * 100 : 0;
}