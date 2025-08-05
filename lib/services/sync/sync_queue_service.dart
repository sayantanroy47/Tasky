import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../domain/entities/task_model.dart';

/// Service for managing offline sync queue
/// 
/// This service handles:
/// - Queuing changes when offline
/// - Processing queued changes when online
/// - Conflict detection and resolution
/// - Retry mechanisms for failed sync operations
class SyncQueueService {
  static const String _queueFileName = 'sync_queue.json';
  
  /// Adds a sync operation to the queue
  Future<void> queueSyncOperation(SyncOperation operation) async {
    final queue = await _loadSyncQueue();
    queue.add(operation);
    await _saveSyncQueue(queue);
  }
  
  /// Gets all pending sync operations
  Future<List<SyncOperation>> getPendingSyncOperations() async {
    return await _loadSyncQueue();
  }
  
  /// Removes a sync operation from the queue
  Future<void> removeSyncOperation(String operationId) async {
    final queue = await _loadSyncQueue();
    queue.removeWhere((op) => op.id == operationId);
    await _saveSyncQueue(queue);
  }
  
  /// Clears all sync operations from the queue
  Future<void> clearSyncQueue() async {
    await _saveSyncQueue([]);
  }
  
  /// Processes all pending sync operations
  Future<SyncResult> processSyncQueue() async {
    final queue = await _loadSyncQueue();
    final results = <String, bool>{};
    final errors = <String, String>{};
    
    for (final operation in queue) {
      try {
        final success = await _processSyncOperation(operation);
        results[operation.id] = success;
        
        if (success) {
          await removeSyncOperation(operation.id);
        } else {
          // Increment retry count
          operation.retryCount++;
          if (operation.retryCount >= operation.maxRetries) {
            // Mark as failed permanently
            errors[operation.id] = 'Max retries exceeded';
            await removeSyncOperation(operation.id);
          }
        }
      } catch (e) {
        errors[operation.id] = e.toString();
        operation.retryCount++;
        
        if (operation.retryCount >= operation.maxRetries) {
          await removeSyncOperation(operation.id);
        }
      }
    }
    
    // Save updated queue with retry counts
    final updatedQueue = queue.where((op) => 
      results[op.id] != true && op.retryCount < op.maxRetries
    ).toList();
    await _saveSyncQueue(updatedQueue);
    
    return SyncResult(
      totalOperations: queue.length,
      successfulOperations: results.values.where((success) => success).length,
      failedOperations: errors.length,
      errors: errors,
    );
  }
  
  /// Loads the sync queue from local storage
  Future<List<SyncOperation>> _loadSyncQueue() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(path.join(directory.path, _queueFileName));
      
      if (!await file.exists()) {
        return [];
      }
      
      final jsonString = await file.readAsString();
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      
      return jsonList.map((json) => SyncOperation.fromJson(json)).toList();
    } catch (e) {
      print('Error loading sync queue: $e');
      return [];
    }
  }
  
  /// Saves the sync queue to local storage
  Future<void> _saveSyncQueue(List<SyncOperation> queue) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(path.join(directory.path, _queueFileName));
      
      final jsonList = queue.map((op) => op.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving sync queue: $e');
    }
  }
  
  /// Processes a single sync operation
  Future<bool> _processSyncOperation(SyncOperation operation) async {
    // This is where you would implement actual sync logic
    // For now, simulate success/failure
    
    switch (operation.type) {
      case SyncOperationType.create:
        return await _syncCreateTask(operation);
      case SyncOperationType.update:
        return await _syncUpdateTask(operation);
      case SyncOperationType.delete:
        return await _syncDeleteTask(operation);
    }
  }
  
  /// Simulates syncing a task creation
  Future<bool> _syncCreateTask(SyncOperation operation) async {
    // In production, this would make API calls to sync server
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Simulate 90% success rate
    return DateTime.now().millisecond % 10 != 0;
  }
  
  /// Simulates syncing a task update
  Future<bool> _syncUpdateTask(SyncOperation operation) async {
    // In production, this would make API calls to sync server
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Simulate 85% success rate
    return DateTime.now().millisecond % 7 != 0;
  }
  
  /// Simulates syncing a task deletion
  Future<bool> _syncDeleteTask(SyncOperation operation) async {
    // In production, this would make API calls to sync server
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Simulate 95% success rate
    return DateTime.now().millisecond % 20 != 0;
  }
  
  /// Checks if device is online
  Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  /// Gets sync queue statistics
  Future<SyncQueueStats> getSyncQueueStats() async {
    final queue = await _loadSyncQueue();
    
    final createOps = queue.where((op) => op.type == SyncOperationType.create).length;
    final updateOps = queue.where((op) => op.type == SyncOperationType.update).length;  
    final deleteOps = queue.where((op) => op.type == SyncOperationType.delete).length;
    
    final highRetryOps = queue.where((op) => op.retryCount > 2).length;
    
    return SyncQueueStats(
      totalOperations: queue.length,
      createOperations: createOps,
      updateOperations: updateOps,
      deleteOperations: deleteOps,
      highRetryOperations: highRetryOps,
      oldestOperation: queue.isNotEmpty 
        ? queue.map((op) => op.timestamp).reduce((a, b) => a.isBefore(b) ? a : b)
        : null,
    );
  }
}

/// Represents a sync operation in the queue
class SyncOperation {
  final String id;
  final SyncOperationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  int retryCount;
  final int maxRetries;
  
  SyncOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
    this.maxRetries = 3,
  });
  
  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'],
      type: SyncOperationType.values[json['type']],
      data: Map<String, dynamic>.from(json['data']),
      timestamp: DateTime.parse(json['timestamp']),
      retryCount: json['retryCount'] ?? 0,
      maxRetries: json['maxRetries'] ?? 3,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
      'maxRetries': maxRetries,
    };
  }
  
  /// Creates a sync operation for task creation
  factory SyncOperation.createTask(TaskModel task) {
    return SyncOperation(
      id: 'create_${task.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: SyncOperationType.create,
      data: task.toJson(),
      timestamp: DateTime.now(),
    );
  }
  
  /// Creates a sync operation for task update
  factory SyncOperation.updateTask(TaskModel task) {
    return SyncOperation(
      id: 'update_${task.id}_${DateTime.now().millisecondsSinceEpoch}',
      type: SyncOperationType.update,
      data: task.toJson(),
      timestamp: DateTime.now(),
    );
  }
  
  /// Creates a sync operation for task deletion
  factory SyncOperation.deleteTask(String taskId) {
    return SyncOperation(
      id: 'delete_${taskId}_${DateTime.now().millisecondsSinceEpoch}',
      type: SyncOperationType.delete,
      data: {'taskId': taskId},
      timestamp: DateTime.now(),
    );
  }
}

/// Types of sync operations
enum SyncOperationType {
  create,
  update,
  delete,
}

/// Result of processing sync queue
class SyncResult {
  final int totalOperations;
  final int successfulOperations;
  final int failedOperations;
  final Map<String, String> errors;
  
  const SyncResult({
    required this.totalOperations,
    required this.successfulOperations,
    required this.failedOperations,
    required this.errors,
  });
  
  bool get hasErrors => errors.isNotEmpty;
  bool get allSuccessful => successfulOperations == totalOperations;
  double get successRate => totalOperations > 0 ? successfulOperations / totalOperations : 1.0;
}

/// Statistics about the sync queue
class SyncQueueStats {
  final int totalOperations;
  final int createOperations;
  final int updateOperations;
  final int deleteOperations;
  final int highRetryOperations;
  final DateTime? oldestOperation;
  
  const SyncQueueStats({
    required this.totalOperations,
    required this.createOperations,
    required this.updateOperations,
    required this.deleteOperations,
    required this.highRetryOperations,
    this.oldestOperation,
  });
  
  bool get isEmpty => totalOperations == 0;
  bool get hasStuckOperations => highRetryOperations > 0;
}