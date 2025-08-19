import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import '../domain/entities/task_model.dart';
import '../domain/entities/calendar_event.dart';
import '../domain/models/enums.dart' as enums;
import 'offline_data_service.dart';

/// Service for cloud synchronization using Supabase
class CloudSyncService {
  final SupabaseClient _supabase;
  final OfflineDataService _offlineDataService;
  
  CloudSyncService(this._supabase, this._offlineDataService);

  /// Initialize cloud sync service
  Future<bool> initialize() async {
    try {
      // Check if user is authenticated
      final session = _supabase.auth.currentSession;
      return session != null;
    } catch (e) {
      // print('Error initializing cloud sync: $e');
      return false;
    }
  }

  /// Authenticate user for cloud sync
  Future<CloudAuthResult> authenticateUser(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        return CloudAuthResult(
          success: true,
          userId: response.user?.id,
          message: 'Authentication successful',
        );
      } else {
        return const CloudAuthResult(
          success: false,
          error: 'Authentication failed',
        );
      }
    } catch (e) {
      return CloudAuthResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Sign up new user
  Future<CloudAuthResult> signUpUser(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.session != null) {
        return CloudAuthResult(
          success: true,
          userId: response.user?.id,
          message: 'Account created successfully',
        );
      } else {
        return const CloudAuthResult(
          success: false,
          error: 'Sign up failed',
        );
      }
    } catch (e) {
      return CloudAuthResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Check if user is authenticated
  bool get isAuthenticated => _supabase.auth.currentSession != null;

  /// Sync tasks to cloud
  Future<CloudSyncResult> syncTasksToCloud(List<TaskModel> tasks) async {
    if (!isAuthenticated) {
      return const CloudSyncResult(
        success: false,
        error: 'User not authenticated',
      );
    }

    try {
      final userId = currentUserId!;
      final syncedTasks = <String>[];
      final errors = <String>[];

      for (final task in tasks) {
        try {
          final taskData = {
            ...task.toJson(),
            'user_id': userId,
            'synced_at': DateTime.now().toIso8601String(),
          };

          // Upsert task (insert or update)
          await _supabase
              .from('tasks')
              .upsert(taskData, onConflict: 'id');

          syncedTasks.add(task.id);
        } catch (e) {
          errors.add('Task ${task.id}: $e');
        }
      }

      return CloudSyncResult(
        success: errors.isEmpty,
        syncedCount: syncedTasks.length,
        errors: errors,
        message: 'Synced ${syncedTasks.length} tasks to cloud',
      );

    } catch (e) {
      return CloudSyncResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Sync tasks from cloud
  Future<CloudSyncResult> syncTasksFromCloud({DateTime? lastSyncTime}) async {
    if (!isAuthenticated) {
      return const CloudSyncResult(
        success: false,
        error: 'User not authenticated',
      );
    }

    try {
      final userId = currentUserId!;
      
      // Build query
      var query = _supabase
          .from('tasks')
          .select()
          .eq('user_id', userId);

      // Add timestamp filter if provided
      if (lastSyncTime != null) {
        query = query.gte('synced_at', lastSyncTime.toIso8601String());
      }

      final response = await query;
      final cloudTasks = (response as List)
          .map((data) => TaskModel.fromJson(data))
          .toList();

      // Process each cloud task
      final conflicts = <enums.SyncConflict>[];
      final syncedTasks = <String>[];

      for (final cloudTask in cloudTasks) {
        try {
          // Check for local version
          final localTask = await _getLocalTask(cloudTask.id);
          
          if (localTask != null) {
            // Check for conflicts
            final conflict = _detectTaskConflict(localTask, cloudTask);
            if (conflict != null) {
              conflicts.add(conflict);
              continue;
            }
          }

          // Update local task
          await _offlineDataService.updateTaskOffline(cloudTask);
          syncedTasks.add(cloudTask.id);

        } catch (e) {
          // print('Error syncing task ${cloudTask.id}: $e');
        }
      }

      return CloudSyncResult(
        success: true,
        syncedCount: syncedTasks.length,
        conflicts: conflicts,
        message: 'Synced ${syncedTasks.length} tasks from cloud',
      );

    } catch (e) {
      return CloudSyncResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Sync calendar events to cloud
  Future<CloudSyncResult> syncEventsToCloud(List<CalendarEvent> events) async {
    if (!isAuthenticated) {
      return const CloudSyncResult(
        success: false,
        error: 'User not authenticated',
      );
    }

    try {
      final userId = currentUserId!;
      final syncedEvents = <String>[];
      final errors = <String>[];

      for (final event in events) {
        try {
          final eventData = {
            ...event.toJson(),
            'user_id': userId,
            'synced_at': DateTime.now().toIso8601String(),
          };

          await _supabase
              .from('calendar_events')
              .upsert(eventData, onConflict: 'id');

          syncedEvents.add(event.id);
        } catch (e) {
          errors.add('Event ${event.id}: $e');
        }
      }

      return CloudSyncResult(
        success: errors.isEmpty,
        syncedCount: syncedEvents.length,
        errors: errors,
        message: 'Synced ${syncedEvents.length} events to cloud',
      );

    } catch (e) {
      return CloudSyncResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Sync calendar events from cloud
  Future<CloudSyncResult> syncEventsFromCloud({DateTime? lastSyncTime}) async {
    if (!isAuthenticated) {
      return const CloudSyncResult(
        success: false,
        error: 'User not authenticated',
      );
    }

    try {
      final userId = currentUserId!;
      
      var query = _supabase
          .from('calendar_events')
          .select()
          .eq('user_id', userId);

      if (lastSyncTime != null) {
        query = query.gte('synced_at', lastSyncTime.toIso8601String());
      }

      final response = await query;
      final cloudEvents = (response as List)
          .map((data) => CalendarEvent.fromJson(data))
          .toList();

      return CloudSyncResult(
        success: true,
        syncedCount: cloudEvents.length,
        message: 'Synced ${cloudEvents.length} events from cloud',
      );

    } catch (e) {
      return CloudSyncResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Perform full bidirectional sync
  Future<FullCloudSyncResult> performFullSync() async {
    if (!isAuthenticated) {
      return const FullCloudSyncResult(
        success: false,
        error: 'User not authenticated',
      );
    }

    try {
      final results = <String, CloudSyncResult>{};
      final allConflicts = <enums.SyncConflict>[];

      // Get local data
      final localTasks = await _getAllLocalTasks();
      final localEvents = await _getAllLocalEvents();

      // Sync tasks to cloud
      final tasksToCloudResult = await syncTasksToCloud(localTasks);
      results['tasksToCloud'] = tasksToCloudResult;
      
      // Sync tasks from cloud
      final tasksFromCloudResult = await syncTasksFromCloud();
      results['tasksFromCloud'] = tasksFromCloudResult;
      allConflicts.addAll(tasksFromCloudResult.conflicts);

      // Sync events to cloud
      final eventsToCloudResult = await syncEventsToCloud(localEvents);
      results['eventsToCloud'] = eventsToCloudResult;

      // Sync events from cloud
      final eventsFromCloudResult = await syncEventsFromCloud();
      results['eventsFromCloud'] = eventsFromCloudResult;
      allConflicts.addAll(eventsFromCloudResult.conflicts);

      final totalSynced = results.values
          .map((r) => r.syncedCount)
          .fold(0, (a, b) => a + b);

      final hasErrors = results.values.any((r) => !r.success);

      return FullCloudSyncResult(
        success: !hasErrors,
        totalSynced: totalSynced,
        conflicts: allConflicts,
        results: results,
        message: hasErrors 
            ? 'Sync completed with errors'
            : 'Full sync completed successfully',
      );

    } catch (e) {
      return FullCloudSyncResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Delete task from cloud
  Future<CloudSyncResult> deleteTaskFromCloud(String taskId) async {
    if (!isAuthenticated) {
      return const CloudSyncResult(
        success: false,
        error: 'User not authenticated',
      );
    }

    try {
      await _supabase
          .from('tasks')
          .delete()
          .eq('id', taskId)
          .eq('user_id', currentUserId!);

      return const CloudSyncResult(
        success: true,
        message: 'Task deleted from cloud',
      );

    } catch (e) {
      return CloudSyncResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Delete event from cloud
  Future<CloudSyncResult> deleteEventFromCloud(String eventId) async {
    if (!isAuthenticated) {
      return const CloudSyncResult(
        success: false,
        error: 'User not authenticated',
      );
    }

    try {
      await _supabase
          .from('calendar_events')
          .delete()
          .eq('id', eventId)
          .eq('user_id', currentUserId!);

      return const CloudSyncResult(
        success: true,
        message: 'Event deleted from cloud',
      );

    } catch (e) {
      return CloudSyncResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Get sync statistics
  Future<CloudSyncStats> getSyncStats() async {
    if (!isAuthenticated) {
      return const CloudSyncStats(
        isAuthenticated: false,
        totalCloudTasks: 0,
        totalCloudEvents: 0,
        lastSyncTime: null,
      );
    }

    try {
      final userId = currentUserId!;

      // Count cloud tasks
      final tasksCount = await _supabase
          .from('tasks')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('user_id', userId);

      // Count cloud events
      final eventsCount = await _supabase
          .from('calendar_events')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('user_id', userId);

      // Get last sync time (would be stored locally)
      final lastSyncTime = await _getLastSyncTime();

      return CloudSyncStats(
        isAuthenticated: true,
        totalCloudTasks: tasksCount.count ?? 0,
        totalCloudEvents: eventsCount.count ?? 0,
        lastSyncTime: lastSyncTime,
      );

    } catch (e) {
      return CloudSyncStats(
        isAuthenticated: true,
        totalCloudTasks: 0,
        totalCloudEvents: 0,
        lastSyncTime: null,
        error: e.toString(),
      );
    }
  }

  /// Setup real-time sync listeners
  void setupRealtimeSync() {
    if (!isAuthenticated) return;

    final userId = currentUserId!;

    // Listen to task changes
    _supabase
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((data) {
          _handleRealtimeTaskUpdate(data);
        });

    // Listen to event changes
    _supabase
        .from('calendar_events')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((data) {
          _handleRealtimeEventUpdate(data);
        });
  }

  /// Handle real-time task updates
  void _handleRealtimeTaskUpdate(List<Map<String, dynamic>> data) {
    // Process real-time updates
    for (final taskData in data) {
      try {
        final task = TaskModel.fromJson(taskData);
        // Update local task without triggering sync
        _updateLocalTaskSilently(task);
      } catch (e) {
        // print('Error processing real-time task update: $e');
      }
    }
  }

  /// Handle real-time event updates
  void _handleRealtimeEventUpdate(List<Map<String, dynamic>> data) {
    // Process real-time updates
    for (final eventData in data) {
      try {
        final event = CalendarEvent.fromJson(eventData);
        // Update local event without triggering sync
        _updateLocalEventSilently(event);
      } catch (e) {
        // print('Error processing real-time event update: $e');
      }
    }
  }

  /// Helper methods (these would be implemented based on your local storage)
  Future<TaskModel?> _getLocalTask(String taskId) async {
    // Implementation depends on your local storage
    return null;
  }

  Future<List<TaskModel>> _getAllLocalTasks() async {
    // Implementation depends on your local storage
    return [];
  }

  Future<List<CalendarEvent>> _getAllLocalEvents() async {
    // Implementation depends on your local storage
    return [];
  }

  Future<DateTime?> _getLastSyncTime() async {
    // Implementation depends on your local storage
    return null;
  }

  Future<void> _updateLocalTaskSilently(TaskModel task) async {
    // Update local task without triggering sync queue
  }

  Future<void> _updateLocalEventSilently(CalendarEvent event) async {
    // Update local event without triggering sync queue
  }

  /// Upload all local data to cloud
  Future<FullCloudSyncResult> uploadAllLocalData() async {
    if (!isAuthenticated) {
      return const FullCloudSyncResult(
        success: false,
        error: 'User not authenticated',
      );
    }

    try {
      final results = <String, CloudSyncResult>{};
      int totalSynced = 0;
      final conflicts = <enums.SyncConflict>[];

      // Upload all local tasks
      final localTasks = await _getAllLocalTasks();
      for (final task in localTasks) {
        final result = await syncTasksToCloud([task]);
        results['task_${task.id}'] = result;
        if (result.success) {
          totalSynced++;
        }
        conflicts.addAll(result.conflicts);
      }

      // Upload all local events
      final localEvents = await _getAllLocalEvents();
      for (final event in localEvents) {
        final result = await syncEventsToCloud([event]);
        results['event_${event.id}'] = result;
        if (result.success) {
          totalSynced++;
        }
        conflicts.addAll(result.conflicts);
      }

      return FullCloudSyncResult(
        success: true,
        totalSynced: totalSynced,
        conflicts: conflicts,
        results: results,
        message: 'Successfully uploaded $totalSynced items to cloud',
      );

    } catch (e) {
      return FullCloudSyncResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Download all cloud data to local storage
  Future<FullCloudSyncResult> downloadAllCloudData() async {
    if (!isAuthenticated) {
      return const FullCloudSyncResult(
        success: false,
        error: 'User not authenticated',
      );
    }

    try {
      final results = <String, CloudSyncResult>{};
      int totalSynced = 0;
      final conflicts = <enums.SyncConflict>[];

      // Download all cloud tasks
      final cloudTasks = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', currentUserId!);

      for (final taskData in cloudTasks) {
        try {
          final task = TaskModel.fromJson(taskData);
          
          // Check for local conflicts
          final localTask = await _getLocalTask(task.id);
          if (localTask != null) {
            final conflict = _detectTaskConflict(localTask, task);
            if (conflict != null) {
              conflicts.add(conflict);
              continue;
            }
          }

          // Update local task
          await _updateLocalTaskSilently(task);
          totalSynced++;
          
          results['task_${task.id}'] = const CloudSyncResult(
            success: true,
            syncedCount: 1,
          );
        } catch (e) {
          results['task_error'] = CloudSyncResult(
            success: false,
            error: e.toString(),
          );
        }
      }

      // Download all cloud events
      final cloudEvents = await _supabase
          .from('calendar_events')
          .select()
          .eq('user_id', currentUserId!);

      for (final eventData in cloudEvents) {
        try {
          final event = CalendarEvent.fromJson(eventData);
          await _updateLocalEventSilently(event);
          totalSynced++;
          
          results['event_${event.id}'] = const CloudSyncResult(
            success: true,
            syncedCount: 1,
          );
        } catch (e) {
          results['event_error'] = CloudSyncResult(
            success: false,
            error: e.toString(),
          );
        }
      }

      return FullCloudSyncResult(
        success: true,
        totalSynced: totalSynced,
        conflicts: conflicts,
        results: results,
        message: 'Successfully downloaded $totalSynced items from cloud',
      );

    } catch (e) {
      return FullCloudSyncResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Detect conflicts between local and cloud tasks
  enums.SyncConflict? _detectTaskConflict(TaskModel localTask, TaskModel cloudTask) {
    // Simple conflict detection based on update time
    if (localTask.updatedAt != null && 
        cloudTask.updatedAt != null &&
        localTask.updatedAt!.isAfter(cloudTask.updatedAt!)) {
      
      return enums.SyncConflict(
        id: '${localTask.id}_conflict_${DateTime.now().millisecondsSinceEpoch}',
        type: 'task_conflict',
        localData: localTask.toJson(),
        remoteData: cloudTask.toJson(),
        timestamp: DateTime.now(),
        entityId: localTask.id,
        entityType: enums.EntityType.task,
        localEntity: localTask.toJson(),
        remoteEntity: cloudTask.toJson(),
        localModified: localTask.updatedAt!,
        remoteModified: cloudTask.updatedAt!,
      );
    }
    
    return null;
  }
}

/// Cloud authentication result
class CloudAuthResult {
  final bool success;
  final String? userId;
  final String? message;
  final String? error;

  const CloudAuthResult({
    required this.success,
    this.userId,
    this.message,
    this.error,
  });
}

/// Cloud sync result
class CloudSyncResult {
  final bool success;
  final int syncedCount;
  final List<String> errors;
  final List<enums.SyncConflict> conflicts;
  final String? message;
  final String? error;

  const CloudSyncResult({
    required this.success,
    this.syncedCount = 0,
    this.errors = const [],
    this.conflicts = const [],
    this.message,
    this.error,
  });
}

/// Full cloud sync result
class FullCloudSyncResult {
  final bool success;
  final int totalSynced;
  final List<enums.SyncConflict> conflicts;
  final Map<String, CloudSyncResult> results;
  final String? message;
  final String? error;

  const FullCloudSyncResult({
    required this.success,
    this.totalSynced = 0,
    this.conflicts = const [],
    this.results = const {},
    this.message,
    this.error,
  });
}

/// Cloud sync statistics
class CloudSyncStats {
  final bool isAuthenticated;
  final int totalCloudTasks;
  final int totalCloudEvents;
  final DateTime? lastSyncTime;
  final String? error;

  const CloudSyncStats({
    required this.isAuthenticated,
    required this.totalCloudTasks,
    required this.totalCloudEvents,
    this.lastSyncTime,
    this.error,
  });
}

/// Provider for Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for cloud sync service
final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  final supabase = ref.read(supabaseClientProvider);
  final offlineService = ref.read(offlineDataServiceProvider);
  return CloudSyncService(supabase, offlineService);
});

/// Provider for cloud sync stats
final cloudSyncStatsProvider = FutureProvider<CloudSyncStats>((ref) async {
  final service = ref.read(cloudSyncServiceProvider);
  return await service.getSyncStats();
});

/// Provider for authentication status
final authStatusProvider = Provider<bool>((ref) {
  final service = ref.read(cloudSyncServiceProvider);
  return service.isAuthenticated;
});