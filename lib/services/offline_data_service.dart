import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../domain/entities/task_model.dart';
import '../domain/models/enums.dart';
import '../domain/repositories/task_repository.dart';
import '../core/providers/core_providers.dart';

/// Service for managing offline-first data operations
class OfflineDataService {
  final TaskRepository _taskRepository;
  final List<SyncOperation> _syncQueue = [];
  bool _isOnline = false;
  bool _isSyncing = false;

  OfflineDataService(this._taskRepository) {
    _initializeConnectivityListener();
  }

  /// Initialize connectivity listener
  void _initializeConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final wasOnline = _isOnline;
      _isOnline = results.isNotEmpty && results.first != ConnectivityResult.none;
      
      if (!wasOnline && _isOnline) {
        // Just came online, process sync queue
        _processSyncQueue();
      }
    });
    
    // Check initial connectivity
    _checkInitialConnectivity();
  }

  /// Check initial connectivity status
  Future<void> _checkInitialConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);
  }

  /// Get current online status
  bool get isOnline => _isOnline;

  /// Get sync queue status
  SyncQueueStatus get syncQueueStatus => SyncQueueStatus(
    pendingOperations: _syncQueue.length,
    isProcessing: _isSyncing,
    lastSyncAttempt: _lastSyncAttempt,
    lastSuccessfulSync: _lastSuccessfulSync,
  );

  DateTime? _lastSyncAttempt;
  DateTime? _lastSuccessfulSync;

  /// Create task with offline support
  Future<TaskModel> createTaskOffline(TaskModel task) async {
    // Save locally first
    await _taskRepository.createTask(task);
    
    // Add to sync queue
    _addToSyncQueue(SyncOperation(
      id: _generateOperationId(),
      type: SyncOperationType.create,
      entityType: EntityType.task,
      entityId: task.id,
      data: task.toJson(),
      timestamp: DateTime.now(),
    ));

    return task;
  }

  /// Update task with offline support
  Future<TaskModel> updateTaskOffline(TaskModel task) async {
    // Save locally first
    await _taskRepository.updateTask(task);
    
    // Add to sync queue
    _addToSyncQueue(SyncOperation(
      id: _generateOperationId(),
      type: SyncOperationType.update,
      entityType: EntityType.task,
      entityId: task.id,
      data: task.toJson(),
      timestamp: DateTime.now(),
    ));

    return task;
  }

  /// Delete task with offline support
  Future<void> deleteTaskOffline(String taskId) async {
    // Delete locally first
    await _taskRepository.deleteTask(taskId);
    
    // Add to sync queue
    _addToSyncQueue(SyncOperation(
      id: _generateOperationId(),
      type: SyncOperationType.delete,
      entityType: EntityType.task,
      entityId: taskId,
      data: {'id': taskId},
      timestamp: DateTime.now(),
    ));
  }

  /// Add operation to sync queue
  void _addToSyncQueue(SyncOperation operation) {
    // Remove any existing operations for the same entity
    _syncQueue.removeWhere((op) => 
        op.entityType == operation.entityType && 
        op.entityId == operation.entityId);
    
    _syncQueue.add(operation);
    
    // Try to sync immediately if online
    if (_isOnline && !_isSyncing) {
      _processSyncQueue();
    }
  }

  /// Process sync queue
  Future<void> _processSyncQueue() async {
    if (_isSyncing || _syncQueue.isEmpty || !_isOnline) {
      return;
    }

    _isSyncing = true;
    _lastSyncAttempt = DateTime.now();

    try {
      final operationsToProcess = List<SyncOperation>.from(_syncQueue);
      final results = <SyncResult>[];

      for (final operation in operationsToProcess) {
        try {
          final result = await _processSyncOperation(operation);
          results.add(result);
          
          if (result.success) {
            _syncQueue.remove(operation);
          }
        } catch (e) {
          results.add(SyncResult(
            operationId: operation.id,
            success: false,
            error: e.toString(),
          ));
        }
      }

      final successCount = results.where((r) => r.success).length;
      if (successCount == results.length) {
        _lastSuccessfulSync = DateTime.now();
      }

    } catch (e) {
      // print('Error processing sync queue: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Process individual sync operation
  Future<SyncResult> _processSyncOperation(SyncOperation operation) async {
    try {
      switch (operation.type) {
        case SyncOperationType.create:
          return await _syncCreate(operation);
        case SyncOperationType.update:
          return await _syncUpdate(operation);
        case SyncOperationType.delete:
          return await _syncDelete(operation);
      }
    } catch (e) {
      return SyncResult(
        operationId: operation.id,
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Sync create operation
  Future<SyncResult> _syncCreate(SyncOperation operation) async {
    // This would sync with your cloud service
    // For now, we'll simulate the operation
    await Future.delayed(const Duration(milliseconds: 500));
    
    return SyncResult(
      operationId: operation.id,
      success: true,
    );
  }

  /// Sync update operation
  Future<SyncResult> _syncUpdate(SyncOperation operation) async {
    // This would sync with your cloud service
    // For now, we'll simulate the operation
    await Future.delayed(const Duration(milliseconds: 500));
    
    return SyncResult(
      operationId: operation.id,
      success: true,
    );
  }

  /// Sync delete operation
  Future<SyncResult> _syncDelete(SyncOperation operation) async {
    // This would sync with your cloud service
    // For now, we'll simulate the operation
    await Future.delayed(const Duration(milliseconds: 500));
    
    return SyncResult(
      operationId: operation.id,
      success: true,
    );
  }

  /// Force sync all data
  Future<FullSyncResult> performFullSync() async {
    if (!_isOnline) {
      return const FullSyncResult(
        success: false,
        error: 'No internet connection',
      );
    }

    try {
      _isSyncing = true;
      _lastSyncAttempt = DateTime.now();

      // Get all local data
      final localTasks = await _taskRepository.getAllTasks();
      
      // This would sync with cloud service
      // For now, we'll simulate the operation
      await Future.delayed(const Duration(seconds: 2));

      // Clear sync queue on successful full sync
      _syncQueue.clear();
      _lastSuccessfulSync = DateTime.now();

      return FullSyncResult(
        success: true,
        syncedTasks: localTasks.length,
        syncedEvents: 0, // Would include calendar events
      );

    } catch (e) {
      return FullSyncResult(
        success: false,
        error: e.toString(),
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Handle conflict resolution
  Future<ConflictResolutionResult> resolveConflict(
    SyncConflict conflict,
    ConflictResolutionStrategy strategy,
  ) async {
    try {
      switch (strategy) {
        case ConflictResolutionStrategy.useLocal:
          return await _resolveWithLocal(conflict);
        case ConflictResolutionStrategy.useRemote:
          return await _resolveWithRemote(conflict);
        case ConflictResolutionStrategy.merge:
          return await _resolveWithMerge(conflict);
        case ConflictResolutionStrategy.createBoth:
          return await _resolveWithBoth(conflict);
        case ConflictResolutionStrategy.askUser:
          // This should be handled by the UI layer
          return const ConflictResolutionResult(
            success: false,
            error: 'User interaction required',
            action: 'ask_user',
          );
      }
    } catch (e) {
      return ConflictResolutionResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Resolve conflict using local version
  Future<ConflictResolutionResult> _resolveWithLocal(SyncConflict conflict) async {
    // Keep local version, update remote
    return ConflictResolutionResult(
      success: true,
      resolvedEntity: conflict.localEntity,
      action: 'Used local version',
    );
  }

  /// Resolve conflict using remote version
  Future<ConflictResolutionResult> _resolveWithRemote(SyncConflict conflict) async {
    // Use remote version, update local
    if (conflict.entityType == EntityType.task) {
      final remoteTask = TaskModel.fromJson(conflict.remoteEntity);
      await _taskRepository.updateTask(remoteTask);
    }
    
    return ConflictResolutionResult(
      success: true,
      resolvedEntity: conflict.remoteEntity,
      action: 'Used remote version',
    );
  }

  /// Resolve conflict by merging
  Future<ConflictResolutionResult> _resolveWithMerge(SyncConflict conflict) async {
    // Implement merge logic based on entity type
    if (conflict.entityType == EntityType.task) {
      final localTask = TaskModel.fromJson(conflict.localEntity);
      final remoteTask = TaskModel.fromJson(conflict.remoteEntity);
      
      // Simple merge strategy - use most recent update
      final mergedTask = localTask.updatedAt?.isAfter(remoteTask.updatedAt ?? DateTime.now()) == true
          ? localTask
          : remoteTask;
      
      await _taskRepository.updateTask(mergedTask);
      
      return ConflictResolutionResult(
        success: true,
        resolvedEntity: mergedTask.toJson(),
        action: 'Merged versions',
      );
    }
    
    return const ConflictResolutionResult(
      success: false,
      error: 'Merge not supported for this entity type',
    );
  }

  /// Resolve conflict by creating both versions
  Future<ConflictResolutionResult> _resolveWithBoth(SyncConflict conflict) async {
    // Create both versions with different IDs
    if (conflict.entityType == EntityType.task) {
      final remoteTask = TaskModel.fromJson(conflict.remoteEntity);
      final duplicateTask = remoteTask.copyWith(
        id: _generateEntityId(),
        title: '${remoteTask.title} (Remote)',
      );
      
      await _taskRepository.createTask(duplicateTask);
      
      return ConflictResolutionResult(
        success: true,
        resolvedEntity: duplicateTask.toJson(),
        action: 'Created both versions',
      );
    }
    
    return const ConflictResolutionResult(
      success: false,
      error: 'Create both not supported for this entity type',
    );
  }

  /// Get offline status indicator
  OfflineStatus getOfflineStatus() {
    return OfflineStatus(
      isOnline: _isOnline,
      hasPendingChanges: _syncQueue.isNotEmpty,
      pendingOperationsCount: _syncQueue.length,
      lastSyncTime: _lastSuccessfulSync,
      isSyncing: _isSyncing,
    );
  }

  /// Clear sync queue (for testing or reset)
  void clearSyncQueue() {
    _syncQueue.clear();
  }

  /// Generate unique operation ID
  String _generateOperationId() {
    return 'op_${DateTime.now().millisecondsSinceEpoch}_${_syncQueue.length}';
  }

  /// Generate unique entity ID
  String _generateEntityId() {
    return 'entity_${DateTime.now().millisecondsSinceEpoch}';
  }
}

/// Sync operation types
enum SyncOperationType {
  create,
  update,
  delete,
}





/// Sync operation data structure
class SyncOperation {
  final String id;
  final SyncOperationType type;
  final EntityType entityType;
  final String entityId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  int retryCount;

  SyncOperation({
    required this.id,
    required this.type,
    required this.entityType,
    required this.entityId,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'entityType': entityType.name,
    'entityId': entityId,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'retryCount': retryCount,
  };

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
    id: json['id'],
    type: SyncOperationType.values.byName(json['type']),
    entityType: EntityType.values.byName(json['entityType']),
    entityId: json['entityId'],
    data: json['data'],
    timestamp: DateTime.parse(json['timestamp']),
    retryCount: json['retryCount'] ?? 0,
  );
}

/// Sync result
class SyncResult {
  final String operationId;
  final bool success;
  final String? error;
  final Map<String, dynamic>? responseData;

  const SyncResult({
    required this.operationId,
    required this.success,
    this.error,
    this.responseData,
  });
}

/// Full sync result
class FullSyncResult {
  final bool success;
  final String? error;
  final int syncedTasks;
  final int syncedEvents;
  final List<SyncConflict> conflicts;

  const FullSyncResult({
    required this.success,
    this.error,
    this.syncedTasks = 0,
    this.syncedEvents = 0,
    this.conflicts = const [],
  });
}



/// Conflict resolution result
class ConflictResolutionResult {
  final bool success;
  final String? error;
  final Map<String, dynamic>? resolvedEntity;
  final String? action;

  const ConflictResolutionResult({
    required this.success,
    this.error,
    this.resolvedEntity,
    this.action,
  });
}

/// Sync queue status
class SyncQueueStatus {
  final int pendingOperations;
  final bool isProcessing;
  final DateTime? lastSyncAttempt;
  final DateTime? lastSuccessfulSync;

  const SyncQueueStatus({
    required this.pendingOperations,
    required this.isProcessing,
    this.lastSyncAttempt,
    this.lastSuccessfulSync,
  });
}

/// Offline status indicator
class OfflineStatus {
  final bool isOnline;
  final bool hasPendingChanges;
  final int pendingOperationsCount;
  final DateTime? lastSyncTime;
  final bool isSyncing;

  const OfflineStatus({
    required this.isOnline,
    required this.hasPendingChanges,
    required this.pendingOperationsCount,
    this.lastSyncTime,
    required this.isSyncing,
  });

  String get statusText {
    if (isSyncing) return 'Syncing...';
    if (!isOnline && hasPendingChanges) return 'Offline - $pendingOperationsCount pending';
    if (!isOnline) return 'Offline';
    if (hasPendingChanges) return 'Online - $pendingOperationsCount pending';
    return 'Online - Synced';
  }

  /// Get semantic status color - UI components should apply theme colors
  OfflineStatusColor get statusColorType {
    if (isSyncing) return OfflineStatusColor.syncing;
    if (!isOnline) return OfflineStatusColor.offline;
    if (hasPendingChanges) return OfflineStatusColor.pending;
    return OfflineStatusColor.online;
  }
  
  @Deprecated('Use statusColorType instead and apply theme colors in UI')
  Color get statusColor {
    // Kept for backward compatibility but should be replaced with theme-aware colors
    if (isSyncing) return Colors.blue;
    if (!isOnline) return Colors.red;
    if (hasPendingChanges) return Colors.orange;
    return Colors.green;
  }
}

/// Provider for offline data service
final offlineDataServiceProvider = Provider<OfflineDataService>((ref) {
  final taskRepository = ref.read(taskRepositoryProvider);
  return OfflineDataService(taskRepository);
});

/// Provider for offline status
final offlineStatusProvider = Provider<OfflineStatus>((ref) {
  final service = ref.read(offlineDataServiceProvider);
  return service.getOfflineStatus();
});

/// Provider for sync queue status
final syncQueueStatusProvider = Provider<SyncQueueStatus>((ref) {
  final service = ref.read(offlineDataServiceProvider);
  return service.syncQueueStatus;
});

/// Semantic offline status colors for theme-aware UI implementation
enum OfflineStatusColor {
  /// Service is online and synced
  online,
  /// Service has pending changes to sync
  pending, 
  /// Service is currently syncing
  syncing,
  /// Service is offline
  offline,
}