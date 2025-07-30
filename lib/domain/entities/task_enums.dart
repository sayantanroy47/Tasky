import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

/// Enums for task-related data models
/// 
/// This file contains all the enums used throughout the task tracker app
/// for consistent type safety and validation.

/// Status of a task in its lifecycle
enum TaskStatus {
  @JsonValue('pending')
  pending,
  
  @JsonValue('in_progress')
  inProgress,
  
  @JsonValue('completed')
  completed,
  
  @JsonValue('cancelled')
  cancelled;

  /// Returns true if the task is considered active (not completed or cancelled)
  bool get isActive => this == TaskStatus.pending || this == TaskStatus.inProgress;
  
  /// Returns true if the task is completed
  bool get isCompleted => this == TaskStatus.completed;
  
  /// Returns true if the task is cancelled
  bool get isCancelled => this == TaskStatus.cancelled;
  
  /// Returns true if the task is pending
  bool get isPending => this == TaskStatus.pending;
  
  /// Returns true if the task is in progress
  bool get isInProgress => this == TaskStatus.inProgress;
  
  /// Returns a human-readable display name for the status
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
  
  /// Returns the color associated with this status
  Color get color {
    switch (this) {
      case TaskStatus.pending:
        return Colors.orange;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.red;
    }
  }
}

/// Priority level of a task
enum TaskPriority {
  @JsonValue('low')
  low,
  
  @JsonValue('medium')
  medium,
  
  @JsonValue('high')
  high,
  
  @JsonValue('urgent')
  urgent;

  /// Returns the numeric value for sorting (higher number = higher priority)
  int get sortValue {
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
  
  /// Returns a human-readable display name for the priority
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
  
  /// Returns true if this is a high priority task (high or urgent)
  bool get isHighPriority => this == TaskPriority.high || this == TaskPriority.urgent;
  
  /// Returns the color associated with this priority
  Color get color {
    switch (this) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.purple;
    }
  }
}

/// Type of recurrence pattern for recurring tasks
enum RecurrenceType {
  @JsonValue('none')
  none,
  
  @JsonValue('daily')
  daily,
  
  @JsonValue('weekly')
  weekly,
  
  @JsonValue('monthly')
  monthly,
  
  @JsonValue('yearly')
  yearly,
  
  @JsonValue('custom')
  custom;

  /// Returns a human-readable display name for the recurrence type
  String get displayName {
    switch (this) {
      case RecurrenceType.none:
        return 'No Recurrence';
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