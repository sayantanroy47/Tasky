import 'package:json_annotation/json_annotation.dart';

part 'sync_models.g.dart';

/// Enumeration of sync status states
enum SyncStatus {
  idle,
  syncing,
  completed,
  failed,
  conflicted,
}

/// Enumeration of entity types that can be synced
enum SyncEntityType {
  task,
  project,
  tag,
}

/// Enumeration of conflict resolution strategies
enum ConflictResolution {
  useLocal,
  useServer,
  merge,
}

/// Represents a sync conflict between local and server data
@JsonSerializable()
class SyncConflict {
  final String entityId;
  final SyncEntityType entityType;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> serverData;
  final DateTime conflictTime;

  const SyncConflict({
    required this.entityId,
    required this.entityType,
    required this.localData,
    required this.serverData,
    required this.conflictTime,
  });

  factory SyncConflict.fromJson(Map<String, dynamic> json) =>
      _$SyncConflictFromJson(json);

  Map<String, dynamic> toJson() => _$SyncConflictToJson(this);
}

/// Represents a resolution for a sync conflict
@JsonSerializable()
class SyncConflictResolution {
  final String entityId;
  final SyncEntityType entityType;
  final ConflictResolution resolution;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> serverData;

  const SyncConflictResolution({
    required this.entityId,
    required this.entityType,
    required this.resolution,
    required this.localData,
    required this.serverData,
  });

  factory SyncConflictResolution.fromJson(Map<String, dynamic> json) =>
      _$SyncConflictResolutionFromJson(json);

  Map<String, dynamic> toJson() => _$SyncConflictResolutionToJson(this);
}

/// Represents sync statistics and metrics
@JsonSerializable()
class SyncStatistics {
  final DateTime lastSyncTime;
  final int totalSyncs;
  final int successfulSyncs;
  final int failedSyncs;
  final int conflictsSyncs;
  final Duration averageSyncDuration;
  final int tasksSynced;
  final int projectsSynced;
  final int tagsSynced;

  const SyncStatistics({
    required this.lastSyncTime,
    required this.totalSyncs,
    required this.successfulSyncs,
    required this.failedSyncs,
    required this.conflictsSyncs,
    required this.averageSyncDuration,
    required this.tasksSynced,
    required this.projectsSynced,
    required this.tagsSynced,
  });

  factory SyncStatistics.fromJson(Map<String, dynamic> json) =>
      _$SyncStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$SyncStatisticsToJson(this);

  /// Calculates success rate as a percentage
  double get successRate {
    if (totalSyncs == 0) return 0.0;
    return (successfulSyncs / totalSyncs) * 100;
  }

  /// Returns true if the last sync was recent (within last hour)
  bool get isRecentSync {
    return DateTime.now().difference(lastSyncTime).inHours < 1;
  }
}

/// Represents sync queue item for offline operations
@JsonSerializable()
class SyncQueueItem {
  final String id;
  final SyncEntityType entityType;
  final String entityId;
  final SyncOperation operation;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;

  const SyncQueueItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) =>
      _$SyncQueueItemFromJson(json);

  Map<String, dynamic> toJson() => _$SyncQueueItemToJson(this);

  /// Creates a copy with updated retry count
  SyncQueueItem withRetry() {
    return SyncQueueItem(
      id: id,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      data: data,
      timestamp: timestamp,
      retryCount: retryCount + 1,
    );
  }
}

/// Enumeration of sync operations
enum SyncOperation {
  create,
  update,
  delete,
}

/// Represents sync settings and preferences
@JsonSerializable()
class SyncSettings {
  final bool autoSyncEnabled;
  final Duration autoSyncInterval;
  final bool syncOnWifiOnly;
  final bool syncInBackground;
  final ConflictResolution defaultConflictResolution;
  final int maxRetryAttempts;
  final Duration retryDelay;

  const SyncSettings({
    this.autoSyncEnabled = true,
    this.autoSyncInterval = const Duration(minutes: 15),
    this.syncOnWifiOnly = false,
    this.syncInBackground = true,
    this.defaultConflictResolution = ConflictResolution.merge,
    this.maxRetryAttempts = 3,
    this.retryDelay = const Duration(seconds: 30),
  });

  factory SyncSettings.fromJson(Map<String, dynamic> json) =>
      _$SyncSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SyncSettingsToJson(this);

  /// Creates a copy with updated settings
  SyncSettings copyWith({
    bool? autoSyncEnabled,
    Duration? autoSyncInterval,
    bool? syncOnWifiOnly,
    bool? syncInBackground,
    ConflictResolution? defaultConflictResolution,
    int? maxRetryAttempts,
    Duration? retryDelay,
  }) {
    return SyncSettings(
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      autoSyncInterval: autoSyncInterval ?? this.autoSyncInterval,
      syncOnWifiOnly: syncOnWifiOnly ?? this.syncOnWifiOnly,
      syncInBackground: syncInBackground ?? this.syncInBackground,
      defaultConflictResolution: defaultConflictResolution ?? this.defaultConflictResolution,
      maxRetryAttempts: maxRetryAttempts ?? this.maxRetryAttempts,
      retryDelay: retryDelay ?? this.retryDelay,
    );
  }
}