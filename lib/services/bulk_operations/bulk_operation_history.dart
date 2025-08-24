import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/task_model.dart';
import 'bulk_operation_service.dart';

/// Manages history of bulk operations for undo/redo functionality
/// 
/// This service provides persistent storage of operation history with
/// automatic cleanup and efficient serialization.
class BulkOperationHistory {
  static const String _historyKey = 'bulk_operation_history';
  static const int _maxHistoryItems = 50; // Keep last 50 operations
  static const Duration _historyRetention = Duration(days: 7); // Keep for 7 days
  
  final StreamController<List<BulkOperationRecord>> _historyController = 
      StreamController<List<BulkOperationRecord>>.broadcast();
  
  List<BulkOperationRecord> _cachedHistory = [];
  bool _isInitialized = false;
  
  /// Initialize the history service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _loadHistory();
    await _cleanupExpiredHistory();
    _isInitialized = true;
  }
  
  /// Record a new bulk operation
  Future<void> recordOperation(BulkOperationRecord record) async {
    await initialize();
    
    // Add to the beginning of the list (most recent first)
    _cachedHistory.insert(0, record);
    
    // Limit history size
    if (_cachedHistory.length > _maxHistoryItems) {
      _cachedHistory = _cachedHistory.take(_maxHistoryItems).toList();
    }
    
    await _saveHistory();
    _historyController.add(List.from(_cachedHistory));
  }
  
  /// Get an operation by ID
  Future<BulkOperationRecord?> getOperation(String operationId) async {
    await initialize();
    
    try {
      return _cachedHistory.firstWhere((record) => record.id == operationId);
    } catch (e) {
      return null;
    }
  }
  
  /// Mark an operation as undone
  Future<void> markOperationUndone(String operationId) async {
    await initialize();
    
    final index = _cachedHistory.indexWhere((record) => record.id == operationId);
    if (index != -1) {
      final record = _cachedHistory[index];
      final updatedRecord = record.copyWith(isUndone: true);
      _cachedHistory[index] = updatedRecord;
      
      await _saveHistory();
      _historyController.add(List.from(_cachedHistory));
    }
  }
  
  /// Get the stream of operation history
  Stream<List<BulkOperationRecord>> getOperationHistory() {
    initialize(); // Ensure initialized
    return _historyController.stream;
  }
  
  /// Get the current history list
  Future<List<BulkOperationRecord>> getCurrentHistory() async {
    await initialize();
    return List.from(_cachedHistory);
  }
  
  /// Get operations that can be undone
  Future<List<BulkOperationRecord>> getUndoableOperations() async {
    await initialize();
    
    return _cachedHistory
        .where((record) => !record.isUndone && record.canUndo)
        .toList();
  }
  
  /// Clear all history
  Future<void> clearHistory() async {
    _cachedHistory.clear();
    await _saveHistory();
    _historyController.add([]);
  }
  
  /// Remove operations older than retention period
  Future<void> _cleanupExpiredHistory() async {
    final cutoffTime = DateTime.now().subtract(_historyRetention);
    
    _cachedHistory.removeWhere((record) => record.timestamp.isBefore(cutoffTime));
    
    if (_cachedHistory.length != _cachedHistory.length) {
      await _saveHistory();
      _historyController.add(List.from(_cachedHistory));
    }
  }
  
  /// Load history from persistent storage
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      
      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        _cachedHistory = historyList
            .map((json) => BulkOperationRecord.fromJson(json))
            .toList();
      }
    } catch (e) {
      // If loading fails, start with empty history
      _cachedHistory = [];
    }
  }
  
  /// Save history to persistent storage
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(
        _cachedHistory.map((record) => record.toJson()).toList(),
      );
      await prefs.setString(_historyKey, historyJson);
    } catch (e) {
      // Log error but don't throw - history is not critical
      print('Failed to save bulk operation history: $e');
    }
  }
  
  /// Get history statistics
  HistoryStatistics getStatistics() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    final lastWeek = now.subtract(const Duration(days: 7));
    
    final recentOperations = _cachedHistory
        .where((record) => record.timestamp.isAfter(last24Hours))
        .length;
    
    final weeklyOperations = _cachedHistory
        .where((record) => record.timestamp.isAfter(lastWeek))
        .length;
    
    final undoableCount = _cachedHistory
        .where((record) => !record.isUndone && record.canUndo)
        .length;
    
    final operationTypeBreakdown = <BulkOperationType, int>{};
    for (final record in _cachedHistory) {
      operationTypeBreakdown[record.type] = 
          (operationTypeBreakdown[record.type] ?? 0) + 1;
    }
    
    return HistoryStatistics(
      totalOperations: _cachedHistory.length,
      recentOperations: recentOperations,
      weeklyOperations: weeklyOperations,
      undoableOperations: undoableCount,
      operationTypeBreakdown: operationTypeBreakdown,
    );
  }
  
  /// Dispose resources
  void dispose() {
    _historyController.close();
  }
}

/// Record of a bulk operation for history tracking
class BulkOperationRecord {
  final String id;
  final BulkOperationType type;
  final List<TaskModel> taskSnapshots;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final bool isUndone;
  final Duration executionTime;
  final int successfulTasks;
  final int failedTasks;
  
  const BulkOperationRecord({
    required this.id,
    required this.type,
    required this.taskSnapshots,
    required this.timestamp,
    this.metadata = const {},
    this.isUndone = false,
    this.executionTime = Duration.zero,
    this.successfulTasks = 0,
    this.failedTasks = 0,
  });
  
  BulkOperationRecord copyWith({
    String? id,
    BulkOperationType? type,
    List<TaskModel>? taskSnapshots,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    bool? isUndone,
    Duration? executionTime,
    int? successfulTasks,
    int? failedTasks,
  }) {
    return BulkOperationRecord(
      id: id ?? this.id,
      type: type ?? this.type,
      taskSnapshots: taskSnapshots ?? this.taskSnapshots,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      isUndone: isUndone ?? this.isUndone,
      executionTime: executionTime ?? this.executionTime,
      successfulTasks: successfulTasks ?? this.successfulTasks,
      failedTasks: failedTasks ?? this.failedTasks,
    );
  }
  
  /// Create from JSON
  factory BulkOperationRecord.fromJson(Map<String, dynamic> json) {
    final taskSnapshotsJson = json['taskSnapshots'] as List<dynamic>?;
    final taskSnapshots = taskSnapshotsJson
        ?.map((taskJson) => TaskModel.fromJson(taskJson as Map<String, dynamic>))
        .toList() ?? [];
    
    return BulkOperationRecord(
      id: json['id'] as String,
      type: BulkOperationType.values.byName(json['type'] as String),
      taskSnapshots: taskSnapshots,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      isUndone: json['isUndone'] as bool? ?? false,
      executionTime: Duration(milliseconds: json['executionTimeMs'] as int? ?? 0),
      successfulTasks: json['successfulTasks'] as int? ?? 0,
      failedTasks: json['failedTasks'] as int? ?? 0,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'taskSnapshots': taskSnapshots.map((task) => task.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'isUndone': isUndone,
      'executionTimeMs': executionTime.inMilliseconds,
      'successfulTasks': successfulTasks,
      'failedTasks': failedTasks,
    };
  }
  
  /// Check if this operation can be undone
  bool get canUndo {
    // Can't undo if already undone
    if (isUndone) return false;
    
    // Can't undo certain operation types
    if (type == BulkOperationType.duplicate) return false;
    
    // Can't undo if too old (older than 24 hours)
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    if (timestamp.isBefore(cutoff)) return false;
    
    return true;
  }
  
  /// Get display title for the operation
  String get displayTitle {
    switch (type) {
      case BulkOperationType.delete:
        return 'Deleted ${taskSnapshots.length} tasks';
      case BulkOperationType.updateStatus:
        final newStatus = metadata['newStatus'];
        return 'Updated status of ${taskSnapshots.length} tasks to $newStatus';
      case BulkOperationType.updatePriority:
        final newPriority = metadata['newPriority'];
        return 'Updated priority of ${taskSnapshots.length} tasks to $newPriority';
      case BulkOperationType.moveToProject:
        return 'Moved ${taskSnapshots.length} tasks to project';
      case BulkOperationType.addTags:
        final tags = metadata['tagsToAdd'] as List<String>? ?? [];
        return 'Added tags ${tags.join(', ')} to ${taskSnapshots.length} tasks';
      case BulkOperationType.removeTags:
        final tags = metadata['tagsToRemove'] as List<String>? ?? [];
        return 'Removed tags ${tags.join(', ')} from ${taskSnapshots.length} tasks';
      case BulkOperationType.reschedule:
        return 'Rescheduled ${taskSnapshots.length} tasks';
      case BulkOperationType.duplicate:
        return 'Duplicated ${taskSnapshots.length} tasks';
      case BulkOperationType.restore:
        return 'Restored ${taskSnapshots.length} tasks';
    }
  }
  
  /// Get display description for the operation
  String get displayDescription {
    final timeAgo = _getTimeAgoString(timestamp);
    if (isUndone) {
      return 'Undone $timeAgo';
    } else if (canUndo) {
      return 'Can undo • $timeAgo';
    } else {
      return 'Cannot undo • $timeAgo';
    }
  }
  
  /// Get time ago string
  String _getTimeAgoString(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
  
  @override
  String toString() {
    return 'BulkOperationRecord(id: $id, type: $type, tasks: ${taskSnapshots.length}, '
           'timestamp: $timestamp, isUndone: $isUndone)';
  }
}

/// Statistics about operation history
class HistoryStatistics {
  final int totalOperations;
  final int recentOperations;
  final int weeklyOperations;
  final int undoableOperations;
  final Map<BulkOperationType, int> operationTypeBreakdown;
  
  const HistoryStatistics({
    required this.totalOperations,
    required this.recentOperations,
    required this.weeklyOperations,
    required this.undoableOperations,
    required this.operationTypeBreakdown,
  });
  
  /// Get the most common operation type
  BulkOperationType? get mostCommonOperationType {
    if (operationTypeBreakdown.isEmpty) return null;
    
    return operationTypeBreakdown.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  /// Get operation frequency (operations per day)
  double get averageOperationsPerDay {
    if (weeklyOperations == 0) return 0.0;
    return weeklyOperations / 7.0;
  }
}