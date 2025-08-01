import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _displayDateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _displayTimeFormat = DateFormat('h:mm a');

  /// Format date for database storage
  static String formatForStorage(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format time for database storage
  static String formatTimeForStorage(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Format datetime for database storage
  static String formatDateTimeForStorage(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Format date for display to user
  static String formatForDisplay(DateTime date) {
    return _displayDateFormat.format(date);
  }

  /// Format time for display to user
  static String formatTimeForDisplay(DateTime date) {
    return _displayTimeFormat.format(date);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && 
           date.month == tomorrow.month && 
           date.day == tomorrow.day;
  }

  /// Check if date is overdue
  static bool isOverdue(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Get relative date string (Today, Tomorrow, Yesterday, or formatted date)
  static String getRelativeDateString(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isTomorrow(date)) {
      return 'Tomorrow';
    } else {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      if (date.year == yesterday.year && 
          date.month == yesterday.month && 
          date.day == yesterday.day) {
        return 'Yesterday';
      }
      return formatForDisplay(date);
    }
  }
}
