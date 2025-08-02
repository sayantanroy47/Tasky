import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../models/enums.dart';

part 'recurrence_pattern.g.dart';

/// Defines how a task should recur over time
/// 
/// This class encapsulates all the information needed to generate
/// recurring instances of a task based on various patterns.
@JsonSerializable()
class RecurrencePattern extends Equatable {
  /// The type of recurrence (daily, weekly, monthly, etc.)
  final RecurrenceType type;
  
  /// Interval between recurrences (e.g., every 2 days, every 3 weeks)
  final int interval;
  
  /// For weekly recurrence: which days of the week (1=Monday, 7=Sunday)
  /// For monthly recurrence: which days of the month (1-31)
  final List<int>? daysOfWeek;
  
  /// When the recurrence pattern should end (null for no end date)
  final DateTime? endDate;
  
  /// Maximum number of occurrences (null for unlimited)
  final int? maxOccurrences;

  const RecurrencePattern({
    required this.type,
    this.interval = 1,
    this.daysOfWeek,
    this.endDate,
    this.maxOccurrences,
  });

  /// Creates a daily recurrence pattern
  factory RecurrencePattern.daily({
    int interval = 1,
    DateTime? endDate,
    int? maxOccurrences,
  }) {
    return RecurrencePattern(
      type: RecurrenceType.daily,
      interval: interval,
      endDate: endDate,
      maxOccurrences: maxOccurrences,
    );
  }

  /// Creates a weekly recurrence pattern
  factory RecurrencePattern.weekly({
    int interval = 1,
    List<int>? daysOfWeek,
    DateTime? endDate,
    int? maxOccurrences,
  }) {
    return RecurrencePattern(
      type: RecurrenceType.weekly,
      interval: interval,
      daysOfWeek: daysOfWeek,
      endDate: endDate,
      maxOccurrences: maxOccurrences,
    );
  }

  /// Creates a monthly recurrence pattern
  factory RecurrencePattern.monthly({
    int interval = 1,
    List<int>? daysOfMonth,
    DateTime? endDate,
    int? maxOccurrences,
  }) {
    return RecurrencePattern(
      type: RecurrenceType.monthly,
      interval: interval,
      daysOfWeek: daysOfMonth,
      endDate: endDate,
      maxOccurrences: maxOccurrences,
    );
  }

  /// Creates a yearly recurrence pattern
  factory RecurrencePattern.yearly({
    int interval = 1,
    DateTime? endDate,
    int? maxOccurrences,
  }) {
    return RecurrencePattern(
      type: RecurrenceType.yearly,
      interval: interval,
      endDate: endDate,
      maxOccurrences: maxOccurrences,
    );
  }

  /// Creates a RecurrencePattern from JSON
  factory RecurrencePattern.fromJson(Map<String, dynamic> json) => 
      _$RecurrencePatternFromJson(json);

  /// Converts this RecurrencePattern to JSON
  Map<String, dynamic> toJson() => _$RecurrencePatternToJson(this);

  /// Creates a copy of this pattern with updated fields
  RecurrencePattern copyWith({
    RecurrenceType? type,
    int? interval,
    List<int>? daysOfWeek,
    DateTime? endDate,
    int? maxOccurrences,
  }) {
    return RecurrencePattern(
      type: type ?? this.type,
      interval: interval ?? this.interval,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      endDate: endDate ?? this.endDate,
      maxOccurrences: maxOccurrences ?? this.maxOccurrences,
    );
  }

  /// Calculates the next occurrence date based on the current date
  DateTime? getNextOccurrence(DateTime currentDate, {int occurrenceCount = 0}) {
    if (type == RecurrenceType.none) return null;
    
    // Check if we've reached the end date
    if (endDate != null && currentDate.isAfter(endDate!)) {
      return null;
    }
    
    // Check if we've reached the maximum occurrences
    if (maxOccurrences != null && occurrenceCount >= maxOccurrences!) {
      return null;
    }

    switch (type) {
      case RecurrenceType.daily:
        return currentDate.add(Duration(days: interval));
        
      case RecurrenceType.weekly:
        if (daysOfWeek == null || daysOfWeek!.isEmpty) {
          return currentDate.add(Duration(days: 7 * interval));
        }
        return _getNextWeeklyOccurrence(currentDate);
        
      case RecurrenceType.monthly:
        return _getNextMonthlyOccurrence(currentDate);
        
      case RecurrenceType.yearly:
        return DateTime(
          currentDate.year + interval,
          currentDate.month,
          currentDate.day,
          currentDate.hour,
          currentDate.minute,
          currentDate.second,
        );
        
      case RecurrenceType.custom:
        // Custom logic would be implemented based on specific requirements
        return null;
        
      case RecurrenceType.none:
        return null;
    }
  }

  /// Calculates the next weekly occurrence
  DateTime _getNextWeeklyOccurrence(DateTime currentDate) {
    final currentWeekday = currentDate.weekday;
    final sortedDays = List<int>.from(daysOfWeek!)..sort();
    
    // Find the next day in the current week
    for (final day in sortedDays) {
      if (day > currentWeekday) {
        return currentDate.add(Duration(days: day - currentWeekday));
      }
    }
    
    // No more days in current week, go to next occurrence week
    final daysUntilNextWeek = 7 - currentWeekday + sortedDays.first;
    final weeksToAdd = interval - 1;
    return currentDate.add(Duration(days: daysUntilNextWeek + (7 * weeksToAdd)));
  }

  /// Calculates the next monthly occurrence
  DateTime? _getNextMonthlyOccurrence(DateTime currentDate) {
    if (daysOfWeek == null || daysOfWeek!.isEmpty) {
      // Same day of month
      final nextMonth = DateTime(
        currentDate.year,
        currentDate.month + interval,
        currentDate.day,
        currentDate.hour,
        currentDate.minute,
        currentDate.second,
      );
      return nextMonth;
    }
    
    // Specific days of month
    final currentDay = currentDate.day;
    final sortedDays = List<int>.from(daysOfWeek!)..sort();
    
    // Find next day in current month
    for (final day in sortedDays) {
      if (day > currentDay) {
        try {
          return DateTime(
            currentDate.year,
            currentDate.month,
            day,
            currentDate.hour,
            currentDate.minute,
            currentDate.second,
          );
        } catch (e) {
          // Invalid date (e.g., Feb 30), skip to next valid day
          continue;
        }
      }
    }
    
    // Go to next month
    final nextMonth = DateTime(currentDate.year, currentDate.month + interval);
    try {
      return DateTime(
        nextMonth.year,
        nextMonth.month,
        sortedDays.first,
        currentDate.hour,
        currentDate.minute,
        currentDate.second,
      );
    } catch (e) {
      // Invalid date, return null for this occurrence
      return null;
    }
  }

  /// Validates the recurrence pattern
  bool isValid() {
    if (interval <= 0) return false;
    
    if (daysOfWeek != null) {
      for (final day in daysOfWeek!) {
        if (type == RecurrenceType.weekly && (day < 1 || day > 7)) {
          return false;
        }
        if (type == RecurrenceType.monthly && (day < 1 || day > 31)) {
          return false;
        }
      }
    }
    
    if (maxOccurrences != null && maxOccurrences! <= 0) {
      return false;
    }
    
    return true;
  }

  /// Returns a human-readable description of the recurrence pattern
  String getDescription() {
    switch (type) {
      case RecurrenceType.none:
        return 'No recurrence';
        
      case RecurrenceType.daily:
        if (interval == 1) return 'Daily';
        return 'Every $interval days';
        
      case RecurrenceType.weekly:
        if (interval == 1 && (daysOfWeek == null || daysOfWeek!.isEmpty)) {
          return 'Weekly';
        }
        if (daysOfWeek != null && daysOfWeek!.isNotEmpty) {
          final dayNames = daysOfWeek!.map(_getDayName).join(', ');
          if (interval == 1) return 'Weekly on $dayNames';
          return 'Every $interval weeks on $dayNames';
        }
        return 'Every $interval weeks';
        
      case RecurrenceType.monthly:
        if (interval == 1) return 'Monthly';
        return 'Every $interval months';
        
      case RecurrenceType.yearly:
        if (interval == 1) return 'Yearly';
        return 'Every $interval years';
        
      case RecurrenceType.custom:
        return 'Custom recurrence';
    }
  }

  String _getDayName(int day) {
    const dayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return dayNames[day - 1];
  }
  @override
  List<Object?> get props => [
        type,
        interval,
        daysOfWeek,
        endDate,
        maxOccurrences,
      ];
  @override
  String toString() {
    return 'RecurrencePattern(type: $type, interval: $interval, '
           'daysOfWeek: $daysOfWeek, endDate: $endDate, '
           'maxOccurrences: $maxOccurrences)';
  }
}
