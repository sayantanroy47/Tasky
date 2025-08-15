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
  }) : assert(interval > 0, 'Interval must be greater than 0'),
       assert(maxOccurrences == null || maxOccurrences > 0, 'Max occurrences must be positive');

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

    try {
      switch (type) {
        case RecurrenceType.daily:
          return _getNextDailyOccurrence(currentDate);
          
        case RecurrenceType.weekly:
          if (daysOfWeek == null || daysOfWeek!.isEmpty) {
            return currentDate.add(Duration(days: 7 * interval));
          }
          return _getNextWeeklyOccurrence(currentDate);
          
        case RecurrenceType.monthly:
          return _getNextMonthlyOccurrence(currentDate);
          
        case RecurrenceType.yearly:
          return _getNextYearlyOccurrence(currentDate);
          
        case RecurrenceType.custom:
          // Custom logic would be implemented based on specific requirements
          return null;
          
        case RecurrenceType.none:
          return null;
      }
    } catch (e) {
      // Handle date calculation errors (e.g., Feb 30)
      return null;
    }
  }

  /// Calculates the next daily occurrence with proper interval handling
  DateTime _getNextDailyOccurrence(DateTime currentDate) {
    return DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day + interval,
      currentDate.hour,
      currentDate.minute,
      currentDate.second,
      currentDate.millisecond,
      currentDate.microsecond,
    );
  }

  /// Calculates the next yearly occurrence with leap year handling
  DateTime _getNextYearlyOccurrence(DateTime currentDate) {
    final nextYear = currentDate.year + interval;
    
    // Handle leap year edge case (Feb 29)
    if (currentDate.month == 2 && currentDate.day == 29) {
      // If target year is not a leap year, use Feb 28
      if (!_isLeapYear(nextYear)) {
        return DateTime(
          nextYear,
          2,
          28,
          currentDate.hour,
          currentDate.minute,
          currentDate.second,
          currentDate.millisecond,
          currentDate.microsecond,
        );
      }
    }
    
    return DateTime(
      nextYear,
      currentDate.month,
      currentDate.day,
      currentDate.hour,
      currentDate.minute,
      currentDate.second,
      currentDate.millisecond,
      currentDate.microsecond,
    );
  }

  /// Checks if a year is a leap year
  bool _isLeapYear(int year) {
    return (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
  }

  /// Calculates the next weekly occurrence with proper week boundary handling
  DateTime _getNextWeeklyOccurrence(DateTime currentDate) {
    final currentWeekday = currentDate.weekday;
    final sortedDays = List<int>.from(daysOfWeek!)..sort();
    
    // Find the next day in the current week
    for (final day in sortedDays) {
      if (day > currentWeekday) {
        return DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day + (day - currentWeekday),
          currentDate.hour,
          currentDate.minute,
          currentDate.second,
          currentDate.millisecond,
          currentDate.microsecond,
        );
      }
    }
    
    // No more days in current week, go to next occurrence week
    final daysUntilNextWeek = 7 - currentWeekday + sortedDays.first;
    final weeksToAdd = interval - 1;
    final totalDaysToAdd = daysUntilNextWeek + (7 * weeksToAdd);
    
    return DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day + totalDaysToAdd,
      currentDate.hour,
      currentDate.minute,
      currentDate.second,
      currentDate.millisecond,
      currentDate.microsecond,
    );
  }

  /// Calculates the next monthly occurrence with proper month handling
  DateTime? _getNextMonthlyOccurrence(DateTime currentDate) {
    if (daysOfWeek == null || daysOfWeek!.isEmpty) {
      // Same day of month with proper handling of month boundaries
      return _getNextMonthSameDay(currentDate);
    }
    
    // Specific days of month
    final currentDay = currentDate.day;
    final sortedDays = List<int>.from(daysOfWeek!)..sort();
    
    // Find next day in current month
    for (final day in sortedDays) {
      if (day > currentDay && _isValidDayInMonth(currentDate.year, currentDate.month, day)) {
        return DateTime(
          currentDate.year,
          currentDate.month,
          day,
          currentDate.hour,
          currentDate.minute,
          currentDate.second,
          currentDate.millisecond,
          currentDate.microsecond,
        );
      }
    }
    
    // Go to next month interval
    final nextMonth = _addMonths(currentDate, interval);
    
    // Find first valid day in the next month
    for (final day in sortedDays) {
      if (_isValidDayInMonth(nextMonth.year, nextMonth.month, day)) {
        return DateTime(
          nextMonth.year,
          nextMonth.month,
          day,
          currentDate.hour,
          currentDate.minute,
          currentDate.second,
          currentDate.millisecond,
          currentDate.microsecond,
        );
      }
    }
    
    return null;
  }

  /// Gets the next occurrence for same day of month
  DateTime _getNextMonthSameDay(DateTime currentDate) {
    final nextMonth = _addMonths(currentDate, interval);
    final targetDay = currentDate.day;
    
    // Check if the target day exists in the next month
    final daysInNextMonth = _getDaysInMonth(nextMonth.year, nextMonth.month);
    final actualDay = targetDay <= daysInNextMonth ? targetDay : daysInNextMonth;
    
    return DateTime(
      nextMonth.year,
      nextMonth.month,
      actualDay,
      currentDate.hour,
      currentDate.minute,
      currentDate.second,
      currentDate.millisecond,
      currentDate.microsecond,
    );
  }

  /// Adds months to a date handling year rollovers properly
  DateTime _addMonths(DateTime date, int months) {
    final newMonth = date.month + months;
    final yearOffset = (newMonth - 1) ~/ 12;
    final finalMonth = ((newMonth - 1) % 12) + 1;
    
    return DateTime(
      date.year + yearOffset,
      finalMonth,
      1, // Start with day 1, adjust later
    );
  }

  /// Gets the number of days in a given month
  int _getDaysInMonth(int year, int month) {
    const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    
    if (month == 2 && _isLeapYear(year)) {
      return 29;
    }
    
    return daysInMonth[month - 1];
  }

  /// Checks if a day is valid in a given month
  bool _isValidDayInMonth(int year, int month, int day) {
    if (day < 1 || day > 31) return false;
    return day <= _getDaysInMonth(year, month);
  }

  /// Validates the recurrence pattern with comprehensive checks
  bool isValid() {
    if (interval <= 0) return false;
    
    // Validate end date is in the future (if specified)
    if (endDate != null && endDate!.isBefore(DateTime.now())) {
      return false;
    }
    
    // Validate max occurrences
    if (maxOccurrences != null && maxOccurrences! <= 0) {
      return false;
    }
    
    // Validate days of week/month based on recurrence type
    if (daysOfWeek != null && daysOfWeek!.isNotEmpty) {
      switch (type) {
        case RecurrenceType.weekly:
          // Check weekdays are valid (1=Monday, 7=Sunday)
          for (final day in daysOfWeek!) {
            if (day < 1 || day > 7) return false;
          }
          break;
          
        case RecurrenceType.monthly:
          // Check days of month are valid (1-31)
          for (final day in daysOfWeek!) {
            if (day < 1 || day > 31) return false;
          }
          break;
          
        case RecurrenceType.daily:
        case RecurrenceType.yearly:
          // These types don't use daysOfWeek
          break;
          
        case RecurrenceType.none:
        case RecurrenceType.custom:
          break;
      }
    }
    
    // Validate interval ranges for different types
    switch (type) {
      case RecurrenceType.daily:
        if (interval > 365) return false; // Max 1 year interval
        break;
      case RecurrenceType.weekly:
        if (interval > 52) return false; // Max 1 year interval
        break;
      case RecurrenceType.monthly:
        if (interval > 12) return false; // Max 1 year interval
        break;
      case RecurrenceType.yearly:
        if (interval > 10) return false; // Max 10 year interval
        break;
      case RecurrenceType.none:
      case RecurrenceType.custom:
        break;
    }
    
    return true;
  }

  /// Estimates the total number of occurrences for this pattern
  int? estimateTotalOccurrences(DateTime startDate) {
    if (maxOccurrences != null) {
      return maxOccurrences!;
    }
    
    if (endDate == null) {
      return null; // Infinite recurrence
    }
    
    final daysDifference = endDate!.difference(startDate).inDays;
    
    switch (type) {
      case RecurrenceType.daily:
        return (daysDifference / interval).ceil();
      case RecurrenceType.weekly:
        final occurrencesPerWeek = daysOfWeek?.length ?? 1;
        return ((daysDifference / 7) / interval).ceil() * occurrencesPerWeek;
      case RecurrenceType.monthly:
        final monthsDifference = _getMonthsDifference(startDate, endDate!);
        final occurrencesPerMonth = daysOfWeek?.length ?? 1;
        return (monthsDifference / interval).ceil() * occurrencesPerMonth;
      case RecurrenceType.yearly:
        final yearsDifference = endDate!.year - startDate.year;
        return (yearsDifference / interval).ceil();
      case RecurrenceType.none:
        return 0;
      case RecurrenceType.custom:
        return null;
    }
  }

  /// Calculates the difference in months between two dates
  int _getMonthsDifference(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + (end.month - start.month);
  }

  /// Returns a human-readable description of the recurrence pattern
  String getDescription() {
    final baseDescription = _getBaseDescription();
    final limitDescription = _getLimitDescription();
    
    return limitDescription.isEmpty ? baseDescription : '$baseDescription ($limitDescription)';
  }
  
  String _getBaseDescription() {
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
        if (daysOfWeek != null && daysOfWeek!.isNotEmpty) {
          final daysList = daysOfWeek!.join(', ');
          if (interval == 1) return 'Monthly on days $daysList';
          return 'Every $interval months on days $daysList';
        }
        if (interval == 1) return 'Monthly';
        return 'Every $interval months';
        
      case RecurrenceType.yearly:
        if (interval == 1) return 'Yearly';
        return 'Every $interval years';
        
      case RecurrenceType.custom:
        return 'Custom recurrence';
    }
  }
  
  String _getLimitDescription() {
    final parts = <String>[];
    
    if (maxOccurrences != null) {
      parts.add('$maxOccurrences times');
    }
    
    if (endDate != null) {
      final formattedDate = '${endDate!.day}/${endDate!.month}/${endDate!.year}';
      parts.add('until $formattedDate');
    }
    
    return parts.join(', ');
  }

  String _getDayName(int day) {
    const dayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    if (day < 1 || day > 7) return 'Invalid Day';
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
           'maxOccurrences: $maxOccurrences, description: "${getDescription()}")';
  }
  
  /// Creates a copy of this pattern with updated fields
  RecurrencePattern copyWithOccurrenceAdjustment({int occurrencesDone = 0}) {
    int? adjustedMaxOccurrences;
    if (maxOccurrences != null) {
      adjustedMaxOccurrences = maxOccurrences! - occurrencesDone;
      if (adjustedMaxOccurrences <= 0) {
        return RecurrencePattern(
          type: RecurrenceType.none,
          interval: interval,
        );
      }
    }
    
    return RecurrencePattern(
      type: type,
      interval: interval,
      daysOfWeek: daysOfWeek,
      endDate: endDate,
      maxOccurrences: adjustedMaxOccurrences,
    );
  }
}
