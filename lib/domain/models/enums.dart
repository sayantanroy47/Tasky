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
  collaboration;

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

