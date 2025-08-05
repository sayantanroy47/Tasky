import 'package:flutter/material.dart';

/// Task priority levels
enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  /// Get display name
  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  /// Get priority value for sorting
  int get value {
    switch (this) {
      case TaskPriority.low:
        return 1;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.high:
        return 3;
      case TaskPriority.urgent:
        return 4;
    }
  }

  /// Get priority value for sorting (alias for value)
  int get sortValue => value;

  /// Get color for priority
  Color get color {
    switch (this) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.deepPurple;
    }
  }

  /// Check if this is high priority (high or urgent)
  bool get isHighPriority {
    return this == TaskPriority.high || this == TaskPriority.urgent;
  }
}

/// Task status
enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled;

  /// Get display name
  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Check if task is active
  bool get isActive {
    return this == TaskStatus.pending || this == TaskStatus.inProgress;
  }

  /// Check if task is finished
  bool get isFinished {
    return this == TaskStatus.completed || this == TaskStatus.cancelled;
  }

  /// Check if task is completed
  bool get isCompleted {
    return this == TaskStatus.completed;
  }

  /// Check if task is pending
  bool get isPending {
    return this == TaskStatus.pending;
  }

  /// Check if task is in progress
  bool get isInProgress {
    return this == TaskStatus.inProgress;
  }

  /// Check if task is cancelled
  bool get isCancelled {
    return this == TaskStatus.cancelled;
  }

  /// Get color for status
  Color get color {
    switch (this) {
      case TaskStatus.pending:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
    }
  }
}

/// Recurrence types
enum RecurrenceType {
  none,
  daily,
  weekly,
  monthly,
  yearly,
  custom;

  /// Get display name
  String get displayName {
    switch (this) {
      case RecurrenceType.none:
        return 'None';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.yearly:
        return 'Yearly';
      case RecurrenceType.custom:
        return 'Custom';
    }
  }
}

/// Notification types
enum NotificationType {
  reminder,
  overdue,
  dailySummary,
  locationBased,
  collaboration,
  taskReminder,
  overdueTask,
  taskCompleted,
  locationReminder;

  /// Get display name
  String get displayName {
    switch (this) {
      case NotificationType.reminder:
        return 'Reminder';
      case NotificationType.overdue:
        return 'Overdue';
      case NotificationType.dailySummary:
        return 'Daily Summary';
      case NotificationType.locationBased:
        return 'Location Based';
      case NotificationType.collaboration:
        return 'Collaboration';
      case NotificationType.taskReminder:
        return 'Task Reminder';
      case NotificationType.overdueTask:
        return 'Overdue Task';
      case NotificationType.taskCompleted:
        return 'Task Completed';
      case NotificationType.locationReminder:
        return 'Location Reminder';
    }
  }
}

/// Theme modes
enum AppThemeMode {
  system,
  light,
  dark,
  highContrastLight,
  highContrastDark;

  /// Get display name
  String get displayName {
    switch (this) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.highContrastLight:
        return 'High Contrast Light';
      case AppThemeMode.highContrastDark:
        return 'High Contrast Dark';
    }
  }

  /// Get Flutter ThemeMode
  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
      case AppThemeMode.highContrastLight:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.highContrastDark:
        return ThemeMode.dark;
    }
  }
}

/// Sync status
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  conflict;

  /// Get display name
  String get displayName {
    switch (this) {
      case SyncStatus.idle:
        return 'Idle';
      case SyncStatus.syncing:
        return 'Syncing';
      case SyncStatus.success:
        return 'Success';
      case SyncStatus.error:
        return 'Error';
      case SyncStatus.conflict:
        return 'Conflict';
    }
  }
}

/// Export formats
enum ExportFormat {
  json,
  csv,
  txt,
  pdf;

  /// Get display name
  String get displayName {
    switch (this) {
      case ExportFormat.json:
        return 'JSON';
      case ExportFormat.csv:
        return 'CSV';
      case ExportFormat.txt:
        return 'Text';
      case ExportFormat.pdf:
        return 'PDF';
    }
  }

  /// Get file extension
  String get extension {
    switch (this) {
      case ExportFormat.json:
        return '.json';
      case ExportFormat.csv:
        return '.csv';
      case ExportFormat.txt:
        return '.txt';
      case ExportFormat.pdf:
        return '.pdf';
    }
  }
}

/// Offline status
enum OfflineStatus {
  online,
  offline,
  syncing,
  error;

  /// Get display name
  String get displayName {
    switch (this) {
      case OfflineStatus.online:
        return 'Online';
      case OfflineStatus.offline:
        return 'Offline';
      case OfflineStatus.syncing:
        return 'Syncing';
      case OfflineStatus.error:
        return 'Error';
    }
  }
}

/// Sync queue status
enum SyncQueueStatus {
  pending,
  syncing,
  completed,
  failed;

  /// Get display name
  String get displayName {
    switch (this) {
      case SyncQueueStatus.pending:
        return 'Pending';
      case SyncQueueStatus.syncing:
        return 'Syncing';
      case SyncQueueStatus.completed:
        return 'Completed';
      case SyncQueueStatus.failed:
        return 'Failed';
    }
  }
}



/// Transcription result class
class TranscriptionResult {
  final String text;
  final double confidence;
  final bool isComplete;
  final Map<String, dynamic>? metadata;

  const TranscriptionResult({
    required this.text,
    required this.confidence,
    this.isComplete = true,
    this.metadata,
  });
}

/// Transcription config class
class TranscriptionConfig {
  final String language;
  final bool enablePunctuation;
  final bool enableWordTimestamps;
  final double confidenceThreshold;

  const TranscriptionConfig({
    this.language = 'en-US',
    this.enablePunctuation = true,
    this.enableWordTimestamps = false,
    this.confidenceThreshold = 0.5,
  });
}

/// Entity type enum
enum EntityType {
  task,
  event,
  project,
  note;

  String get displayName {
    switch (this) {
      case EntityType.task:
        return 'Task';
      case EntityType.event:
        return 'Event';
      case EntityType.project:
        return 'Project';
      case EntityType.note:
        return 'Note';
    }
  }
}

/// Conflict resolution strategies
enum ConflictResolutionStrategy {
  useLocal,
  useRemote,
  merge,
  askUser,
  createBoth,
}

/// Enhanced sync conflict class
class SyncConflict {
  final String id;
  final String type;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final DateTime timestamp;
  final String entityId;
  final EntityType entityType;
  final Map<String, dynamic> localEntity;
  final Map<String, dynamic> remoteEntity;
  final DateTime localModified;
  final DateTime remoteModified;

  const SyncConflict({
    required this.id,
    required this.type,
    required this.localData,
    required this.remoteData,
    required this.timestamp,
    required this.entityId,
    required this.entityType,
    required this.localEntity,
    required this.remoteEntity,
    required this.localModified,
    required this.remoteModified,
  });
}

/// Task filter for querying tasks
class TaskFilter {
  final TaskStatus? status;
  final TaskPriority? priority;
  final List<String>? tags;
  final String? projectId;
  final DateTime? dueDateFrom;
  final DateTime? dueDateTo;
  final bool? isOverdue;
  final bool? isPinned;
  final String? searchQuery;
  final TaskSortBy sortBy;
  final bool sortAscending;

  const TaskFilter({
    this.status,
    this.priority,
    this.tags,
    this.projectId,
    this.dueDateFrom,
    this.dueDateTo,
    this.isOverdue,
    this.isPinned,
    this.searchQuery,
    this.sortBy = TaskSortBy.createdAt,
    this.sortAscending = true,
  });

  /// Creates a copy of this filter with updated fields
  TaskFilter copyWith({
    TaskStatus? status,
    TaskPriority? priority,
    List<String>? tags,
    String? projectId,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
    bool? isOverdue,
    bool? isPinned,
    String? searchQuery,
    TaskSortBy? sortBy,
    bool? sortAscending,
  }) {
    return TaskFilter(
      status: status ?? this.status,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      projectId: projectId ?? this.projectId,
      dueDateFrom: dueDateFrom ?? this.dueDateFrom,
      dueDateTo: dueDateTo ?? this.dueDateTo,
      isOverdue: isOverdue ?? this.isOverdue,
      isPinned: isPinned ?? this.isPinned,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  /// Returns true if any filter is applied
  bool get hasFilters {
    return status != null ||
        priority != null ||
        tags != null ||
        projectId != null ||
        dueDateFrom != null ||
        dueDateTo != null ||
        isOverdue != null ||
        isPinned != null ||
        (searchQuery != null && searchQuery!.isNotEmpty);
  }
}

/// Task sorting options
enum TaskSortBy {
  createdAt,
  updatedAt,
  dueDate,
  priority,
  title,
  status;

  /// Get display name for sort option
  String get displayName {
    switch (this) {
      case TaskSortBy.createdAt:
        return 'Created Date';
      case TaskSortBy.updatedAt:
        return 'Updated Date';
      case TaskSortBy.dueDate:
        return 'Due Date';
      case TaskSortBy.priority:
        return 'Priority';
      case TaskSortBy.title:
        return 'Title';
      case TaskSortBy.status:
        return 'Status';
    }
  }
}

