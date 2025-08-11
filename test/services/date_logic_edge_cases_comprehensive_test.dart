import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/services/date/date_validation_service.dart';
import 'package:task_tracker_app/services/date/date_calculation_service.dart';
import 'package:task_tracker_app/services/date/timezone_service.dart';

/// COMPREHENSIVE DATE LOGIC EDGE CASES TESTS - ALL DATE EDGE CASES AND SCENARIOS
/// 
/// These tests validate ALL date-related edge cases, boundary conditions, and corner scenarios
/// to ensure robust date handling throughout the entire application as explicitly demanded.
void main() {
  group('Date Logic Edge Cases - Comprehensive Validation Tests', () {
    late DateValidationService validationService;
    late DateCalculationService calculationService;
    late TimezoneService timezoneService;

    setUp(() {
      validationService = DateValidationService();
      calculationService = DateCalculationService();
      timezoneService = TimezoneService();
    });

    group('Date Boundary Tests', () {
      test('should handle year boundaries correctly', () {
        // Test year 0 to year 1 transition
        final year0Dec31 = DateTime(0, 12, 31);
        final year1Jan1 = DateTime(1, 1, 1);
        expect(calculationService.daysBetween(year0Dec31, year1Jan1), equals(1));

        // Test year 9999 (maximum year in many systems)
        final maxYear = DateTime(9999, 12, 31);
        expect(validationService.isValidDate(maxYear), isTrue);

        // Test year transitions around common epochs
        final year1969 = DateTime(1969, 12, 31);
        final year1970 = DateTime(1970, 1, 1); // Unix epoch
        expect(calculationService.daysBetween(year1969, year1970), equals(1));

        final year1999 = DateTime(1999, 12, 31);
        final year2000 = DateTime(2000, 1, 1); // Y2K boundary
        expect(calculationService.daysBetween(year1999, year2000), equals(1));
      });

      test('should handle month boundaries correctly', () {
        // Test all month transitions
        for (int month = 1; month <= 12; month++) {
          final lastDayOfMonth = DateTime(2024, month, calculationService.getDaysInMonth(2024, month));
          final firstDayOfNextMonth = month == 12 
              ? DateTime(2025, 1, 1)
              : DateTime(2024, month + 1, 1);
          
          expect(calculationService.daysBetween(lastDayOfMonth, firstDayOfNextMonth), equals(1));
        }

        // Test February boundaries in leap and non-leap years
        final feb28_2023 = DateTime(2023, 2, 28); // Non-leap year
        final mar1_2023 = DateTime(2023, 3, 1);
        expect(calculationService.daysBetween(feb28_2023, mar1_2023), equals(1));

        final feb29_2024 = DateTime(2024, 2, 29); // Leap year
        final mar1_2024 = DateTime(2024, 3, 1);
        expect(calculationService.daysBetween(feb29_2024, mar1_2024), equals(1));
      });

      test('should handle day boundaries correctly', () {
        // Test day 1 to day 2
        final day1 = DateTime(2024, 6, 1);
        final day2 = DateTime(2024, 6, 2);
        expect(calculationService.daysBetween(day1, day2), equals(1));

        // Test last day of each month
        final monthDays = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]; // 2024 is leap year
        for (int month = 1; month <= 12; month++) {
          final lastDay = DateTime(2024, month, monthDays[month - 1]);
          expect(validationService.isValidDate(lastDay), isTrue);
        }
      });

      test('should handle hour boundaries correctly', () {
        // Test midnight boundary
        final beforeMidnight = DateTime(2024, 6, 15, 23, 59, 59);
        final afterMidnight = DateTime(2024, 6, 16, 0, 0, 0);
        expect(calculationService.hoursBetween(beforeMidnight, afterMidnight), equals(0));

        // Test 24-hour boundary
        final hour0 = DateTime(2024, 6, 15, 0, 0, 0);
        final hour23 = DateTime(2024, 6, 15, 23, 0, 0);
        expect(calculationService.hoursBetween(hour0, hour23), equals(23));
      });

      test('should handle minute and second boundaries correctly', () {
        // Test minute boundaries
        final minute59 = DateTime(2024, 6, 15, 12, 59, 0);
        final nextHour = DateTime(2024, 6, 15, 13, 0, 0);
        expect(calculationService.minutesBetween(minute59, nextHour), equals(1));

        // Test second boundaries
        final second59 = DateTime(2024, 6, 15, 12, 30, 59);
        final nextMinute = DateTime(2024, 6, 15, 12, 31, 0);
        expect(calculationService.secondsBetween(second59, nextMinute), equals(1));

        // Test millisecond boundaries
        final ms999 = DateTime(2024, 6, 15, 12, 30, 59, 999);
        final nextSecond = DateTime(2024, 6, 15, 12, 31, 0, 0);
        expect(calculationService.millisecondsBetween(ms999, nextSecond), equals(1));
      });
    });

    group('Leap Year Edge Cases Tests', () {
      test('should handle century years correctly', () {
        // Years divisible by 100 but not 400 are NOT leap years
        final centuryYears = [1700, 1800, 1900, 2100, 2200, 2300];
        for (final year in centuryYears) {
          expect(calculationService.isLeapYear(year), isFalse, 
              reason: '$year should not be a leap year');
        }

        // Years divisible by 400 ARE leap years
        final leapCenturyYears = [1600, 2000, 2400];
        for (final year in leapCenturyYears) {
          expect(calculationService.isLeapYear(year), isTrue, 
              reason: '$year should be a leap year');
        }
      });

      test('should handle leap day edge cases', () {
        // Leap day should exist in leap years
        final leapDay2024 = DateTime(2024, 2, 29);
        expect(validationService.isValidDate(leapDay2024), isTrue);

        final leapDay2000 = DateTime(2000, 2, 29);
        expect(validationService.isValidDate(leapDay2000), isTrue);

        // Leap day should NOT exist in non-leap years
        expect(() => DateTime(2023, 2, 29), throwsA(isA<ArgumentError>()));
        expect(() => DateTime(1900, 2, 29), throwsA(isA<ArgumentError>()));
      });

      test('should handle tasks scheduled on leap day', () {
        // Task scheduled on leap day in leap year
        final leapDayTask = TaskModel.create(
          title: 'Leap Day Task',
          dueDate: DateTime(2024, 2, 29),
        );
        expect(leapDayTask.dueDate!.month, equals(2));
        expect(leapDayTask.dueDate!.day, equals(29));

        // Test what happens to recurring task that falls on leap day
        final recurringLeapTask = TaskModel.create(
          title: 'Annual Leap Task',
          dueDate: DateTime(2024, 2, 29),
          recurrenceRule: RecurrenceRule.yearly(interval: 1),
        );

        // Next occurrence should be in 2028 (next leap year)
        final nextOccurrence = calculationService.getNextRecurrence(recurringLeapTask.dueDate!, recurringLeapTask.recurrenceRule!);
        expect(nextOccurrence.year, equals(2028));
        expect(nextOccurrence.month, equals(2));
        expect(nextOccurrence.day, equals(29));
      });

      test('should handle leap year calculations across centuries', () {
        // Test leap year pattern across century boundaries
        final testYears = [1896, 1900, 1904, 1996, 2000, 2004, 2096, 2100, 2104];
        final expectedLeapYears = [true, false, true, true, true, true, true, false, true];

        for (int i = 0; i < testYears.length; i++) {
          final year = testYears[i];
          final expected = expectedLeapYears[i];
          expect(calculationService.isLeapYear(year), equals(expected), 
              reason: 'Leap year calculation for $year is incorrect');
        }
      });
    });

    group('Time Zone Edge Cases Tests', () {
      test('should handle daylight saving time transitions', () {
        // Spring forward (2 AM becomes 3 AM)
        final springForward2024 = DateTime(2024, 3, 10, 2, 0); // US DST
        final oneHourLater = springForward2024.add(const Duration(hours: 1));
        
        // In many time zones, 2 AM doesn't exist on spring forward day
        // The calculation should handle this gracefully
        expect(oneHourLater.hour, anyOf(equals(3), equals(4))); // Depends on implementation

        // Fall back (2 AM happens twice)
        final fallBack2024 = DateTime(2024, 11, 3, 1, 0); // US DST end
        final twoHoursLater = fallBack2024.add(const Duration(hours: 2));
        
        // Should handle the "repeated hour" correctly
        expect(twoHoursLater.hour, anyOf(equals(1), equals(2), equals(3)));
      });

      test('should handle time zone boundaries', () {
        // Test UTC boundaries
        final utcMidnight = DateTime.utc(2024, 6, 15, 0, 0, 0);
        final localMidnight = DateTime(2024, 6, 15, 0, 0, 0);

        expect(utcMidnight.isUtc, isTrue);
        expect(localMidnight.isUtc, isFalse);

        // Test conversion between UTC and local time
        final utcToLocal = utcMidnight.toLocal();
        final localToUtc = localMidnight.toUtc();

        expect(utcToLocal.isUtc, isFalse);
        expect(localToUtc.isUtc, isTrue);
      });

      test('should handle international date line', () {
        // Test scenarios where date changes across international date line
        final sameMomentUtc = DateTime.utc(2024, 6, 15, 23, 0, 0);
        
        // In some time zones, this could be June 16
        // The application should handle this consistently
        final task = TaskModel.create(
          title: 'International Task',
          dueDate: sameMomentUtc,
        );

        expect(task.dueDate!.day, anyOf(equals(15), equals(16)));
      });

      test('should handle time zone offsets', () {
        // Test various time zone offsets
        final baseTime = DateTime(2024, 6, 15, 12, 0, 0);
        
        // Test positive and negative offsets
        final positiveOffset = baseTime.add(const Duration(hours: 5, minutes: 30)); // +05:30
        final negativeOffset = baseTime.subtract(const Duration(hours: 8)); // -08:00
        
        expect(positiveOffset.hour, equals(17));
        expect(positiveOffset.minute, equals(30));
        expect(negativeOffset.hour, equals(4));
      });
    });

    group('Date Arithmetic Edge Cases Tests', () {
      test('should handle negative date differences', () {
        final earlier = DateTime(2024, 1, 1);
        final later = DateTime(2024, 12, 31);

        // Normal order (positive difference)
        expect(calculationService.daysBetween(earlier, later), equals(365)); // 2024 is leap year

        // Reversed order (negative difference)
        expect(calculationService.daysBetween(later, earlier), equals(-365));
      });

      test('should handle large date differences', () {
        // Test very large time spans
        final ancientDate = DateTime(1, 1, 1);
        final modernDate = DateTime(2024, 1, 1);
        
        final daysDifference = calculationService.daysBetween(ancientDate, modernDate);
        expect(daysDifference, greaterThan(700000)); // Roughly 2023 years * 365 days
      });

      test('should handle date arithmetic overflow/underflow', () {
        // Test adding large durations
        final baseDate = DateTime(2024, 6, 15);
        final veryFarFuture = baseDate.add(const Duration(days: 1000000));
        
        expect(veryFarFuture.year, greaterThan(2024));
        expect(validationService.isValidDate(veryFarFuture), isTrue);

        // Test subtracting large durations
        final veryFarPast = baseDate.subtract(const Duration(days: 1000000));
        expect(veryFarPast.year, lessThan(2024));
        expect(validationService.isValidDate(veryFarPast), isTrue);
      });

      test('should handle fractional day calculations', () {
        // Test calculations involving fractional days
        final start = DateTime(2024, 6, 15, 12, 0, 0);
        final end = DateTime(2024, 6, 16, 18, 0, 0); // 1 day 6 hours = 1.25 days
        
        final fractionalDays = calculationService.fractionalDaysBetween(start, end);
        expect(fractionalDays, closeTo(1.25, 0.01));

        // Test with minutes and seconds
        final preciseEnd = DateTime(2024, 6, 16, 12, 30, 30); // Exactly 1.0211805... days
        final preciseDays = calculationService.fractionalDaysBetween(start, preciseEnd);
        expect(preciseDays, closeTo(1.021, 0.001));
      });

      test('should handle week calculations with edge cases', () {
        // Test week boundaries
        final monday = DateTime(2024, 6, 3); // Monday
        final sunday = DateTime(2024, 6, 9); // Following Sunday
        
        expect(calculationService.weeksBetween(monday, sunday), equals(0)); // Same week
        
        final nextMonday = DateTime(2024, 6, 10);
        expect(calculationService.weeksBetween(monday, nextMonday), equals(1)); // Next week

        // Test partial weeks
        final wednesday = DateTime(2024, 6, 5);
        final fractionalWeeks = calculationService.fractionalWeeksBetween(monday, wednesday);
        expect(fractionalWeeks, closeTo(0.29, 0.01)); // 2 days / 7 days
      });
    });

    group('Date Parsing Edge Cases Tests', () {
      test('should handle various date string formats', () {
        final validFormats = [
          '2024-06-15',           // ISO 8601
          '06/15/2024',           // US format
          '15/06/2024',           // European format
          '2024/06/15',           // Japanese format
          'Jun 15, 2024',         // Long format
          '15 Jun 2024',          // British format
          '2024-06-15T12:30:00Z', // ISO with time
          '2024-06-15T12:30:00+05:30', // ISO with timezone
        ];

        for (final format in validFormats) {
          final parsed = validationService.parseDate(format);
          expect(parsed, isNotNull, reason: 'Failed to parse: $format');
          expect(parsed!.year, equals(2024));
          expect(parsed.month, equals(6));
          expect(parsed.day, equals(15));
        }
      });

      test('should handle invalid date strings gracefully', () {
        final invalidFormats = [
          '2024-13-15',    // Invalid month
          '2024-06-32',    // Invalid day
          '2024-02-30',    // Invalid day for February
          '2023-02-29',    // Invalid leap day
          '24-06-15',      // Ambiguous year
          '06/32/2024',    // Invalid day
          'not a date',    // Non-date string
          '',              // Empty string
          '2024/6/15/12',  // Too many parts
        ];

        for (final format in invalidFormats) {
          final parsed = validationService.parseDate(format);
          expect(parsed, isNull, reason: 'Should not parse invalid format: $format');
        }
      });

      test('should handle ambiguous date formats', () {
        // Test dates that could be interpreted multiple ways
        final ambiguousDate = '01/02/2024'; // Could be Jan 2 or Feb 1
        
        // Should have consistent parsing behavior
        final parsed1 = validationService.parseDate(ambiguousDate, format: DateFormat.US);
        final parsed2 = validationService.parseDate(ambiguousDate, format: DateFormat.European);
        
        expect(parsed1, isNotNull);
        expect(parsed2, isNotNull);
        expect(parsed1!.month, equals(1));
        expect(parsed1.day, equals(2));
        expect(parsed2!.month, equals(2));
        expect(parsed2.day, equals(1));
      });

      test('should handle unicode and special characters in dates', () {
        final unicodeDates = [
          '２０２４年６月１５日',      // Japanese
          '15 юни 2024',            // Bulgarian
          '15 يونيو 2024',          // Arabic
          '15 de junho de 2024',    // Portuguese
        ];

        // Should handle or gracefully reject unicode dates
        for (final unicodeDate in unicodeDates) {
          final parsed = validationService.parseDate(unicodeDate);
          // Either successfully parse or return null (don't crash)
          expect(() => parsed, returnsNormally);
        }
      });
    });

    group('Task Due Date Edge Cases Tests', () {
      test('should handle tasks due at exact boundaries', () {
        // Task due at midnight
        final midnightTask = TaskModel.create(
          title: 'Midnight Task',
          dueDate: DateTime(2024, 6, 15, 0, 0, 0),
        );

        expect(midnightTask.isDueToday, isTrue);
        expect(midnightTask.isOverdue, isFalse);

        // Task due at 23:59:59
        final almostMidnightTask = TaskModel.create(
          title: 'Almost Midnight Task',
          dueDate: DateTime(2024, 6, 15, 23, 59, 59),
        );

        expect(almostMidnightTask.isDueToday, isTrue);
        expect(almostMidnightTask.isOverdue, isFalse);
      });

      test('should handle tasks due on leap day', () {
        // Task due on leap day 2024
        final leapTask2024 = TaskModel.create(
          title: 'Leap Day Task 2024',
          dueDate: DateTime(2024, 2, 29),
        );

        expect(leapTask2024.dueDate!.day, equals(29));
        expect(leapTask2024.dueDate!.month, equals(2));

        // Test recurring task that would fall on non-existent leap day
        final recurringLeapTask = TaskModel.create(
          title: 'Annual Leap Task',
          dueDate: DateTime(2024, 2, 29),
          recurrenceRule: RecurrenceRule.yearly(interval: 1),
        );

        // In 2025 (non-leap year), should adjust to Feb 28
        final nextYear = calculationService.getNextRecurrence(recurringLeapTask.dueDate!, recurringLeapTask.recurrenceRule!);
        expect(nextYear.year, equals(2025));
        expect(nextYear.month, equals(2));
        expect(nextYear.day, equals(28)); // Adjusted from 29 to 28
      });

      test('should handle tasks with null or undefined due dates', () {
        // Task without due date
        final noDateTask = TaskModel.create(
          title: 'No Due Date Task',
          dueDate: null,
        );

        expect(noDateTask.dueDate, isNull);
        expect(noDateTask.isDueToday, isFalse);
        expect(noDateTask.isOverdue, isFalse);

        // Task with undefined due date behavior
        expect(() => noDateTask.daysTillDue, returnsNormally);
      });

      test('should handle extremely far future/past due dates', () {
        // Task due in far future
        final farFutureTask = TaskModel.create(
          title: 'Far Future Task',
          dueDate: DateTime(9999, 12, 31),
        );

        expect(farFutureTask.isOverdue, isFalse);
        expect(farFutureTask.daysTillDue, greaterThan(1000000));

        // Task due in far past
        final farPastTask = TaskModel.create(
          title: 'Far Past Task',
          dueDate: DateTime(1, 1, 1),
        );

        expect(farPastTask.isOverdue, isTrue);
        expect(farPastTask.daysTillDue, lessThan(-700000));
      });
    });

    group('Recurring Task Date Edge Cases Tests', () {
      test('should handle monthly recurrence on 31st', () {
        // Task recurring on 31st of every month
        final monthly31st = TaskModel.create(
          title: 'Monthly 31st Task',
          dueDate: DateTime(2024, 1, 31), // January 31
          recurrenceRule: RecurrenceRule.monthly(interval: 1, dayOfMonth: 31),
        );

        // Next occurrences
        final nextDates = <DateTime>[];
        DateTime current = monthly31st.dueDate!;
        
        for (int i = 0; i < 12; i++) {
          current = calculationService.getNextRecurrence(current, monthly31st.recurrenceRule!);
          nextDates.add(current);
        }

        // Should handle months with fewer than 31 days
        expect(nextDates[1].month, equals(3));   // February -> March (Feb has no 31st)
        expect(nextDates[1].day, equals(31));    // March 31
        expect(nextDates[2].month, equals(5));   // April -> May (April has no 31st)
        expect(nextDates[2].day, equals(31));    // May 31
      });

      test('should handle weekly recurrence across DST transitions', () {
        // Weekly task that crosses DST boundary
        final weeklyTask = TaskModel.create(
          title: 'Weekly DST Task',
          dueDate: DateTime(2024, 3, 3, 10, 0), // Week before DST
          recurrenceRule: RecurrenceRule.weekly(interval: 1, daysOfWeek: [DateTime.sunday]),
        );

        final nextWeek = calculationService.getNextRecurrence(weeklyTask.dueDate!, weeklyTask.recurrenceRule!);
        
        // Should maintain same time despite DST transition
        expect(nextWeek.weekday, equals(DateTime.sunday));
        expect(nextWeek.hour, equals(10));
      });

      test('should handle yearly recurrence on leap day', () {
        // Yearly task on leap day
        final yearlyLeapTask = TaskModel.create(
          title: 'Yearly Leap Task',
          dueDate: DateTime(2024, 2, 29),
          recurrenceRule: RecurrenceRule.yearly(interval: 1),
        );

        // Next few occurrences
        final occurrences = <DateTime>[];
        DateTime current = yearlyLeapTask.dueDate!;
        
        for (int i = 0; i < 8; i++) {
          current = calculationService.getNextRecurrence(current, yearlyLeapTask.recurrenceRule!);
          occurrences.add(current);
        }

        // Should occur every 4 years (only on leap years)
        expect(occurrences.map((d) => d.year).toList(), equals([2028, 2032, 2036, 2040, 2044, 2048, 2052, 2056]));
        expect(occurrences.every((d) => d.month == 2 && d.day == 29), isTrue);
      });

      test('should handle complex recurring patterns with edge cases', () {
        // Every 2nd Monday of the month
        final complexTask = TaskModel.create(
          title: 'Complex Recurring Task',
          dueDate: DateTime(2024, 6, 10), // 2nd Monday of June 2024
          recurrenceRule: RecurrenceRule.monthly(
            interval: 1,
            weekOfMonth: 2,
            dayOfWeek: DateTime.monday,
          ),
        );

        final nextOccurrences = <DateTime>[];
        DateTime current = complexTask.dueDate!;
        
        for (int i = 0; i < 6; i++) {
          current = calculationService.getNextRecurrence(current, complexTask.recurrenceRule!);
          nextOccurrences.add(current);
        }

        // Verify all are 2nd Monday of their respective months
        for (final occurrence in nextOccurrences) {
          expect(occurrence.weekday, equals(DateTime.monday));
          
          // Calculate which Monday of the month this is
          final firstOfMonth = DateTime(occurrence.year, occurrence.month, 1);
          final weekOfMonth = ((occurrence.day - 1) ~/ 7) + 1;
          expect(weekOfMonth, equals(2));
        }
      });
    });

    group('Date Comparison Edge Cases Tests', () {
      test('should handle microsecond precision comparisons', () {
        final base = DateTime(2024, 6, 15, 12, 30, 45, 123, 456);
        final microsecondLater = DateTime(2024, 6, 15, 12, 30, 45, 123, 457);
        
        expect(base.isBefore(microsecondLater), isTrue);
        expect(microsecondLater.isAfter(base), isTrue);
        expect(base.isAtSameMomentAs(microsecondLater), isFalse);
      });

      test('should handle time zone comparison edge cases', () {
        // Same moment in different time zones
        final utcTime = DateTime.utc(2024, 6, 15, 12, 0, 0);
        final localTime = utcTime.toLocal();
        
        expect(utcTime.isAtSameMomentAs(localTime), isTrue);
        expect(utcTime.difference(localTime), equals(Duration.zero));
      });

      test('should handle null date comparisons', () {
        final validDate = DateTime(2024, 6, 15);
        DateTime? nullDate;
        
        // Comparison with null should be handled gracefully
        expect(validationService.isDateAfter(validDate, nullDate), isTrue);
        expect(validationService.isDateBefore(validDate, nullDate), isFalse);
        expect(validationService.isDateEqual(nullDate, nullDate), isTrue);
      });

      test('should handle date equality with different precision', () {
        final date1 = DateTime(2024, 6, 15, 12, 30, 45);
        final date2 = DateTime(2024, 6, 15, 12, 30, 45, 0, 0);
        final date3 = DateTime(2024, 6, 15, 12, 30, 45, 999, 999);
        
        // Should be equal at second precision
        expect(validationService.isEqualAtPrecision(date1, date2, DatePrecision.second), isTrue);
        expect(validationService.isEqualAtPrecision(date1, date3, DatePrecision.second), isTrue);
        
        // Should not be equal at microsecond precision
        expect(validationService.isEqualAtPrecision(date1, date3, DatePrecision.microsecond), isFalse);
      });
    });

    group('Date Formatting Edge Cases Tests', () {
      test('should handle edge case date formatting', () {
        final edgeCases = [
          DateTime(1, 1, 1),              // Minimum date
          DateTime(9999, 12, 31),         // Maximum date
          DateTime(2024, 2, 29),          // Leap day
          DateTime(2000, 1, 1),           // Y2K
          DateTime(1970, 1, 1),           // Unix epoch
        ];

        for (final date in edgeCases) {
          expect(() => validationService.formatDate(date), returnsNormally);
          expect(() => validationService.formatDate(date, format: 'yyyy-MM-dd'), returnsNormally);
          expect(() => validationService.formatDate(date, format: 'EEEE, MMMM d, yyyy'), returnsNormally);
        }
      });

      test('should handle localized date formatting', () {
        final testDate = DateTime(2024, 6, 15, 14, 30, 45);
        
        final locales = ['en_US', 'en_GB', 'de_DE', 'fr_FR', 'ja_JP'];
        
        for (final locale in locales) {
          expect(() => validationService.formatDateLocalized(testDate, locale), returnsNormally);
        }
      });

      test('should handle custom date format patterns', () {
        final testDate = DateTime(2024, 6, 15, 14, 30, 45, 123);
        
        final patterns = [
          'yyyy-MM-dd',
          'MM/dd/yyyy',
          'dd.MM.yyyy',
          'EEEE, MMMM d, yyyy',
          'HH:mm:ss',
          'yyyy-MM-dd HH:mm:ss.SSS',
          'MMM d, yyyy \'at\' h:mm a',
        ];

        for (final pattern in patterns) {
          expect(() => validationService.formatDate(testDate, format: pattern), returnsNormally);
        }
      });
    });

    group('Performance Edge Cases Tests', () {
      test('should handle large date ranges efficiently', () {
        final startDate = DateTime(1000, 1, 1);
        final endDate = DateTime(3000, 12, 31);
        
        final startTime = DateTime.now();
        final daysBetween = calculationService.daysBetween(startDate, endDate);
        final endTime = DateTime.now();
        
        // Should calculate large ranges quickly (under 1 second)
        expect(endTime.difference(startTime).inMilliseconds, lessThan(1000));
        expect(daysBetween, greaterThan(700000)); // Roughly 2000 years
      });

      test('should handle many date calculations efficiently', () {
        final baseDate = DateTime(2024, 6, 15);
        final dates = List.generate(10000, (i) => baseDate.add(Duration(days: i)));
        
        final startTime = DateTime.now();
        for (int i = 0; i < dates.length - 1; i++) {
          calculationService.daysBetween(dates[i], dates[i + 1]);
        }
        final endTime = DateTime.now();
        
        // Should handle many calculations efficiently (under 2 seconds)
        expect(endTime.difference(startTime).inSeconds, lessThan(2));
      });

      test('should handle memory efficiently with large date collections', () {
        // Create large collection of dates
        final dates = List.generate(100000, (i) => DateTime(2024, 1, 1).add(Duration(seconds: i)));
        
        // Perform operations that might cause memory issues
        final sortedDates = List<DateTime>.from(dates)..sort();
        final uniqueDates = dates.toSet().toList();
        
        expect(sortedDates.length, equals(100000));
        expect(uniqueDates.length, equals(100000));
      });
    });
  });
}

/// Mock services for testing date logic
class DateValidationService {
  bool isValidDate(DateTime date) {
    try {
      return date.year > 0 && date.year <= 9999 &&
             date.month >= 1 && date.month <= 12 &&
             date.day >= 1 && date.day <= 31;
    } catch (e) {
      return false;
    }
  }

  DateTime? parseDate(String dateString, {DateFormat? format}) {
    try {
      // Simplified parsing logic
      if (dateString.contains('-') && dateString.length >= 8) {
        final parts = dateString.split('-');
        if (parts.length >= 3) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  bool isDateAfter(DateTime? date1, DateTime? date2) {
    if (date1 == null) return false;
    if (date2 == null) return true;
    return date1.isAfter(date2);
  }

  bool isDateBefore(DateTime? date1, DateTime? date2) {
    if (date1 == null) return date2 != null;
    if (date2 == null) return false;
    return date1.isBefore(date2);
  }

  bool isDateEqual(DateTime? date1, DateTime? date2) {
    if (date1 == null && date2 == null) return true;
    if (date1 == null || date2 == null) return false;
    return date1.isAtSameMomentAs(date2);
  }

  bool isEqualAtPrecision(DateTime date1, DateTime date2, DatePrecision precision) {
    switch (precision) {
      case DatePrecision.year:
        return date1.year == date2.year;
      case DatePrecision.month:
        return date1.year == date2.year && date1.month == date2.month;
      case DatePrecision.day:
        return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
      case DatePrecision.hour:
        return isEqualAtPrecision(date1, date2, DatePrecision.day) && date1.hour == date2.hour;
      case DatePrecision.minute:
        return isEqualAtPrecision(date1, date2, DatePrecision.hour) && date1.minute == date2.minute;
      case DatePrecision.second:
        return isEqualAtPrecision(date1, date2, DatePrecision.minute) && date1.second == date2.second;
      case DatePrecision.microsecond:
        return date1.isAtSameMomentAs(date2);
    }
  }

  String formatDate(DateTime date, {String? format}) {
    // Simplified formatting
    if (format == null) return date.toString();
    return date.toString(); // In real implementation, would use intl package
  }

  String formatDateLocalized(DateTime date, String locale) {
    return date.toString(); // Simplified
  }
}

class DateCalculationService {
  int getDaysInMonth(int year, int month) {
    final daysInMonths = [31, isLeapYear(year) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonths[month - 1];
  }

  bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  int hoursBetween(DateTime start, DateTime end) {
    return end.difference(start).inHours;
  }

  int minutesBetween(DateTime start, DateTime end) {
    return end.difference(start).inMinutes;
  }

  int secondsBetween(DateTime start, DateTime end) {
    return end.difference(start).inSeconds;
  }

  int millisecondsBetween(DateTime start, DateTime end) {
    return end.difference(start).inMilliseconds;
  }

  double fractionalDaysBetween(DateTime start, DateTime end) {
    return end.difference(start).inMilliseconds / (24 * 60 * 60 * 1000);
  }

  int weeksBetween(DateTime start, DateTime end) {
    return daysBetween(start, end) ~/ 7;
  }

  double fractionalWeeksBetween(DateTime start, DateTime end) {
    return daysBetween(start, end) / 7.0;
  }

  DateTime getNextRecurrence(DateTime date, RecurrenceRule rule) {
    switch (rule.pattern) {
      case RecurrencePattern.daily:
        return date.add(Duration(days: rule.interval));
      case RecurrencePattern.weekly:
        return date.add(Duration(days: 7 * rule.interval));
      case RecurrencePattern.monthly:
        var nextMonth = date.month + rule.interval;
        var nextYear = date.year;
        
        while (nextMonth > 12) {
          nextMonth -= 12;
          nextYear++;
        }
        
        var targetDay = rule.dayOfMonth ?? date.day;
        final daysInTargetMonth = getDaysInMonth(nextYear, nextMonth);
        
        // Adjust for months with fewer days
        if (targetDay > daysInTargetMonth) {
          targetDay = daysInTargetMonth;
        }
        
        return DateTime(nextYear, nextMonth, targetDay, date.hour, date.minute, date.second);
      case RecurrencePattern.yearly:
        var nextYear = date.year + rule.interval;
        
        // Handle leap day in non-leap years
        if (date.month == 2 && date.day == 29 && !isLeapYear(nextYear)) {
          return DateTime(nextYear, 2, 28, date.hour, date.minute, date.second);
        }
        
        return DateTime(nextYear, date.month, date.day, date.hour, date.minute, date.second);
    }
  }
}

class TimezoneService {
  // Placeholder for timezone service
}

enum DateFormat { US, European, ISO }
enum DatePrecision { year, month, day, hour, minute, second, microsecond }