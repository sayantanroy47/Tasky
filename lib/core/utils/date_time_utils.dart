import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;

/// Comprehensive date and time utilities with proper timezone handling
/// 
/// This utility class provides consistent date/time operations across the app,
/// handling timezone conversions, validation, and business logic properly.
class DateTimeUtils {
  static const String _defaultTimeZone = 'UTC';
  static String _userTimeZone = _defaultTimeZone;
  
  /// Sets the user's timezone for consistent operations
  static void setUserTimeZone(String timeZoneName) {
    try {
      tz.getLocation(timeZoneName);
      _userTimeZone = timeZoneName;
    } catch (e) {
      debugPrint('Warning: Invalid timezone $timeZoneName, using UTC');
      _userTimeZone = _defaultTimeZone;
    }
  }
  
  /// Gets the current user timezone
  static String get userTimeZone => _userTimeZone;
  
  /// Gets current date/time in user's timezone
  static tz.TZDateTime now() {
    return tz.TZDateTime.now(tz.getLocation(_userTimeZone));
  }
  
  /// Converts a DateTime to user's timezone
  static tz.TZDateTime toUserTimeZone(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.getLocation(_userTimeZone));
  }
  
  /// Converts a DateTime to UTC
  static tz.TZDateTime toUtc(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.UTC);
  }
  
  /// Creates a TZDateTime in user's timezone
  static tz.TZDateTime createInUserTimeZone(
    int year, [
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    int microsecond = 0,
  ]) {
    return tz.TZDateTime(
      tz.getLocation(_userTimeZone),
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }
  
  /// Validates if a date is reasonable for task scheduling
  static DateValidationResult validateDate(DateTime? date) {
    if (date == null) {
      return DateValidationResult.valid();
    }
    
    final now = DateTime.now();
    final oneYearAgo = now.subtract(const Duration(days: 365));
    final tenYearsFromNow = now.add(const Duration(days: 365 * 10));
    
    // Check if date is too far in the past
    if (date.isBefore(oneYearAgo)) {
      return DateValidationResult.warning(
        'Date is more than one year in the past'
      );
    }
    
    // Check if date is too far in the future
    if (date.isAfter(tenYearsFromNow)) {
      return DateValidationResult.invalid(
        'Date cannot be more than 10 years in the future'
      );
    }
    
    return DateValidationResult.valid();
  }
  
  /// Validates if a due date makes sense relative to created date
  static DateValidationResult validateDueDate(DateTime? dueDate, DateTime createdDate) {
    if (dueDate == null) {
      return DateValidationResult.valid();
    }
    
    // Basic date validation first
    final basicValidation = validateDate(dueDate);
    if (!basicValidation.isValid) {
      return basicValidation;
    }
    
    // Due date should not be before creation date (with some tolerance)
    final createdDateStart = DateTime(createdDate.year, createdDate.month, createdDate.day);
    final dueDateStart = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    if (dueDateStart.isBefore(createdDateStart)) {
      return DateValidationResult.warning(
        'Due date is before creation date'
      );
    }
    
    return DateValidationResult.valid();
  }
  
  /// Checks if a task is overdue considering timezone
  static bool isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    
    final nowInUserTz = now();
    final dueDateInUserTz = toUserTimeZone(dueDate);
    
    // Compare at day level to avoid timezone-related issues
    final todayStart = createInUserTimeZone(
      nowInUserTz.year,
      nowInUserTz.month,
      nowInUserTz.day,
    );
    
    final dueDateStart = createInUserTimeZone(
      dueDateInUserTz.year,
      dueDateInUserTz.month,
      dueDateInUserTz.day,
    );
    
    return dueDateStart.isBefore(todayStart);
  }
  
  /// Checks if a task is due today
  static bool isDueToday(DateTime? dueDate) {
    if (dueDate == null) return false;
    
    final nowInUserTz = now();
    final dueDateInUserTz = toUserTimeZone(dueDate);
    
    return nowInUserTz.year == dueDateInUserTz.year &&
           nowInUserTz.month == dueDateInUserTz.month &&
           nowInUserTz.day == dueDateInUserTz.day;
  }
  
  /// Checks if a task is due within the next N days
  static bool isDueWithinDays(DateTime? dueDate, int days) {
    if (dueDate == null) return false;
    
    final nowInUserTz = now();
    final dueDateInUserTz = toUserTimeZone(dueDate);
    final futureDate = nowInUserTz.add(Duration(days: days));
    
    return dueDateInUserTz.isAfter(nowInUserTz) && 
           dueDateInUserTz.isBefore(futureDate);
  }
  
  /// Gets start of day in user's timezone
  static tz.TZDateTime getStartOfDay(DateTime date) {
    final dateInUserTz = toUserTimeZone(date);
    return createInUserTimeZone(
      dateInUserTz.year,
      dateInUserTz.month,
      dateInUserTz.day,
    );
  }
  
  /// Gets end of day in user's timezone
  static tz.TZDateTime getEndOfDay(DateTime date) {
    final dateInUserTz = toUserTimeZone(date);
    return createInUserTimeZone(
      dateInUserTz.year,
      dateInUserTz.month,
      dateInUserTz.day,
      23,
      59,
      59,
      999,
    );
  }
  
  /// Gets start of week in user's timezone (Monday = start of week)
  static tz.TZDateTime getStartOfWeek(DateTime date) {
    final dateInUserTz = toUserTimeZone(date);
    final startOfDay = getStartOfDay(dateInUserTz);
    final daysFromMonday = startOfDay.weekday - 1;
    return startOfDay.subtract(Duration(days: daysFromMonday));
  }
  
  /// Gets end of week in user's timezone (Sunday = end of week)
  static tz.TZDateTime getEndOfWeek(DateTime date) {
    final startOfWeek = getStartOfWeek(date);
    return getEndOfDay(startOfWeek.add(const Duration(days: 6)));
  }
  
  /// Gets start of month in user's timezone
  static tz.TZDateTime getStartOfMonth(DateTime date) {
    final dateInUserTz = toUserTimeZone(date);
    return createInUserTimeZone(dateInUserTz.year, dateInUserTz.month, 1);
  }
  
  /// Gets end of month in user's timezone
  static tz.TZDateTime getEndOfMonth(DateTime date) {
    final dateInUserTz = toUserTimeZone(date);
    final nextMonth = dateInUserTz.month == 12 
      ? createInUserTimeZone(dateInUserTz.year + 1, 1, 1)
      : createInUserTimeZone(dateInUserTz.year, dateInUserTz.month + 1, 1);
    return getEndOfDay(nextMonth.subtract(const Duration(days: 1)));
  }
  
  /// Formats date for display considering user timezone
  static String formatDate(DateTime? date, {String format = 'yyyy-MM-dd'}) {
    if (date == null) return '';
    
    final dateInUserTz = toUserTimeZone(date);
    
    // Simple formatting - can be enhanced with intl package
    switch (format) {
      case 'yyyy-MM-dd':
        return '${dateInUserTz.year}-${dateInUserTz.month.toString().padLeft(2, '0')}-${dateInUserTz.day.toString().padLeft(2, '0')}';
      case 'dd/MM/yyyy':
        return '${dateInUserTz.day.toString().padLeft(2, '0')}/${dateInUserTz.month.toString().padLeft(2, '0')}/${dateInUserTz.year}';
      case 'MMM dd, yyyy':
        final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                           'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${monthNames[dateInUserTz.month - 1]} ${dateInUserTz.day}, ${dateInUserTz.year}';
      case 'full':
        return dateInUserTz.toString();
      default:
        return dateInUserTz.toString();
    }
  }
  
  /// Parses a date string considering timezone
  static DateTime? parseDate(String? dateString, {String? timeZone}) {
    if (dateString == null || dateString.isEmpty) return null;
    
    try {
      final parsed = DateTime.parse(dateString);
      final location = tz.getLocation(timeZone ?? _userTimeZone);
      return tz.TZDateTime.from(parsed, location);
    } catch (e) {
      return null;
    }
  }
  
  /// Gets a human-readable relative time string
  static String getRelativeTime(DateTime? date) {
    if (date == null) return '';
    
    final nowInUserTz = now();
    final dateInUserTz = toUserTimeZone(date);
    final difference = nowInUserTz.difference(dateInUserTz);
    
    if (difference.inDays > 7) {
      return formatDate(dateInUserTz, format: 'MMM dd, yyyy');
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
  
  /// Gets days until a due date (negative if overdue)
  static int? getDaysUntilDue(DateTime? dueDate) {
    if (dueDate == null) return null;
    
    final nowInUserTz = now();
    final dueDateInUserTz = toUserTimeZone(dueDate);
    
    final nowStart = getStartOfDay(nowInUserTz);
    final dueStart = getStartOfDay(dueDateInUserTz);
    
    return dueStart.difference(nowStart).inDays;
  }
  
  /// Adjusts a recurring task's next due date for timezone changes
  static DateTime adjustRecurringDateForTimezone(
    DateTime originalDate,
    String originalTimezone,
    String newTimezone,
  ) {
    try {
      final originalLocation = tz.getLocation(originalTimezone);
      final newLocation = tz.getLocation(newTimezone);
      
      final originalTzDate = tz.TZDateTime.from(originalDate, originalLocation);
      return tz.TZDateTime.from(originalTzDate, newLocation);
    } catch (e) {
      // If timezone conversion fails, return original date
      return originalDate;
    }
  }
  
  /// Validates timezone name
  static bool isValidTimeZone(String timeZoneName) {
    try {
      tz.getLocation(timeZoneName);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Gets available timezone names
  static List<String> getAvailableTimeZones() {
    return tz.timeZoneDatabase.locations.keys.toList()..sort();
  }
}

/// Result of date validation
class DateValidationResult {
  final bool isValid;
  final String? message;
  final bool isWarning;
  
  const DateValidationResult._(this.isValid, this.message, this.isWarning);
  
  factory DateValidationResult.valid() => 
    const DateValidationResult._(true, null, false);
  
  factory DateValidationResult.invalid(String message) => 
    DateValidationResult._(false, message, false);
  
  factory DateValidationResult.warning(String message) => 
    DateValidationResult._(true, message, true);
}

/// Extensions for better DateTime handling
extension DateTimeExtensions on DateTime {
  /// Converts to user timezone using DateTimeUtils
  tz.TZDateTime toUserTimeZone() => DateTimeUtils.toUserTimeZone(this);
  
  /// Checks if this date is overdue
  bool get isOverdue => DateTimeUtils.isOverdue(this);
  
  /// Checks if this date is today
  bool get isDueToday => DateTimeUtils.isDueToday(this);
  
  /// Gets days until this date
  int get daysUntilDue => DateTimeUtils.getDaysUntilDue(this) ?? 0;
  
  /// Gets relative time string
  String get relativeTime => DateTimeUtils.getRelativeTime(this);
  
  /// Gets start of day
  tz.TZDateTime get startOfDay => DateTimeUtils.getStartOfDay(this);
  
  /// Gets end of day
  tz.TZDateTime get endOfDay => DateTimeUtils.getEndOfDay(this);
}