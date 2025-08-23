import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/domain/entities/recurrence_pattern.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';

void main() {
  group('RecurrencePattern', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30); // Monday
    });

    group('constructor', () {
      test('should create RecurrencePattern with required fields', () {
        final pattern = RecurrencePattern(
          type: RecurrenceType.daily,
          interval: 2,
          daysOfWeek: const [1, 3, 5],
          endDate: testDate.add(const Duration(days: 30)),
          maxOccurrences: 10,
        );

        expect(pattern.type, RecurrenceType.daily);
        expect(pattern.interval, 2);
        expect(pattern.daysOfWeek, [1, 3, 5]);
        expect(pattern.endDate, testDate.add(const Duration(days: 30)));
        expect(pattern.maxOccurrences, 10);
      });

      test('should create RecurrencePattern with default interval', () {
        const pattern = RecurrencePattern(type: RecurrenceType.weekly);
        expect(pattern.interval, 1);
      });
    });

    group('factory constructors', () {
      test('daily should create daily recurrence pattern', () {
        final pattern = RecurrencePattern.daily(
          interval: 2,
          endDate: testDate,
          maxOccurrences: 5,
        );

        expect(pattern.type, RecurrenceType.daily);
        expect(pattern.interval, 2);
        expect(pattern.endDate, testDate);
        expect(pattern.maxOccurrences, 5);
        expect(pattern.daysOfWeek, isNull);
      });

      test('weekly should create weekly recurrence pattern', () {
        final pattern = RecurrencePattern.weekly(
          interval: 2,
          daysOfWeek: const [1, 3, 5],
          endDate: testDate,
          maxOccurrences: 5,
        );

        expect(pattern.type, RecurrenceType.weekly);
        expect(pattern.interval, 2);
        expect(pattern.daysOfWeek, [1, 3, 5]);
        expect(pattern.endDate, testDate);
        expect(pattern.maxOccurrences, 5);
      });

      test('monthly should create monthly recurrence pattern', () {
        final pattern = RecurrencePattern.monthly(
          interval: 3,
          daysOfMonth: const [1, 15],
          endDate: testDate,
          maxOccurrences: 5,
        );

        expect(pattern.type, RecurrenceType.monthly);
        expect(pattern.interval, 3);
        expect(pattern.daysOfWeek, [1, 15]); // daysOfWeek is reused for days of month
        expect(pattern.endDate, testDate);
        expect(pattern.maxOccurrences, 5);
      });

      test('yearly should create yearly recurrence pattern', () {
        final pattern = RecurrencePattern.yearly(
          interval: 2,
          endDate: testDate,
          maxOccurrences: 5,
        );

        expect(pattern.type, RecurrenceType.yearly);
        expect(pattern.interval, 2);
        expect(pattern.endDate, testDate);
        expect(pattern.maxOccurrences, 5);
        expect(pattern.daysOfWeek, isNull);
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final pattern = RecurrencePattern(
          type: RecurrenceType.weekly,
          interval: 2,
          daysOfWeek: const [1, 3, 5],
          endDate: testDate,
          maxOccurrences: 10,
        );

        final json = pattern.toJson();

        expect(json['type'], 'weekly');
        expect(json['interval'], 2);
        expect(json['daysOfWeek'], [1, 3, 5]);
        expect(json['endDate'], testDate.toIso8601String());
        expect(json['maxOccurrences'], 10);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'type': 'weekly',
          'interval': 2,
          'daysOfWeek': [1, 3, 5],
          'endDate': testDate.toIso8601String(),
          'maxOccurrences': 10,
        };

        final pattern = RecurrencePattern.fromJson(json);

        expect(pattern.type, RecurrenceType.weekly);
        expect(pattern.interval, 2);
        expect(pattern.daysOfWeek, [1, 3, 5]);
        expect(pattern.endDate, testDate);
        expect(pattern.maxOccurrences, 10);
      });

      test('should handle null values in JSON', () {
        final json = {
          'type': 'daily',
          'interval': 1,
        };

        final pattern = RecurrencePattern.fromJson(json);

        expect(pattern.type, RecurrenceType.daily);
        expect(pattern.interval, 1);
        expect(pattern.daysOfWeek, isNull);
        expect(pattern.endDate, isNull);
        expect(pattern.maxOccurrences, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final original = RecurrencePattern.daily(interval: 1);
        final updated = original.copyWith(
          type: RecurrenceType.weekly,
          interval: 2,
          daysOfWeek: [1, 3, 5],
        );

        expect(updated.type, RecurrenceType.weekly);
        expect(updated.interval, 2);
        expect(updated.daysOfWeek, [1, 3, 5]);
        expect(updated.endDate, original.endDate);
        expect(updated.maxOccurrences, original.maxOccurrences);
      });
    });

    group('getNextOccurrence', () {
      test('should return null for none type', () {
        const pattern = RecurrencePattern(type: RecurrenceType.none);
        final next = pattern.getNextOccurrence(testDate);
        expect(next, isNull);
      });

      test('should return null when past end date', () {
        final endDate = testDate.subtract(const Duration(days: 1));
        final pattern = RecurrencePattern.daily(endDate: endDate);
        final next = pattern.getNextOccurrence(testDate);
        expect(next, isNull);
      });

      test('should return null when max occurrences reached', () {
        final pattern = RecurrencePattern.daily(maxOccurrences: 5);
        final next = pattern.getNextOccurrence(testDate, occurrenceCount: 5);
        expect(next, isNull);
      });

      test('should calculate next daily occurrence', () {
        final pattern = RecurrencePattern.daily(interval: 2);
        final next = pattern.getNextOccurrence(testDate);
        expect(next, testDate.add(const Duration(days: 2)));
      });

      test('should calculate next weekly occurrence without specific days', () {
        final pattern = RecurrencePattern.weekly(interval: 2);
        final next = pattern.getNextOccurrence(testDate);
        expect(next, testDate.add(const Duration(days: 14)));
      });

      test('should calculate next weekly occurrence with specific days', () {
        // Test date is Monday (weekday 1), pattern includes Wednesday (weekday 3)
        final pattern = RecurrencePattern.weekly(daysOfWeek: const [1, 3, 5]);
        final next = pattern.getNextOccurrence(testDate);
        expect(next, testDate.add(const Duration(days: 2))); // Next Wednesday
      });

      test('should calculate next weekly occurrence when no more days in current week', () {
        // Test date is Monday (weekday 1), pattern only includes Monday
        final pattern = RecurrencePattern.weekly(daysOfWeek: const [1], interval: 2);
        final next = pattern.getNextOccurrence(testDate);
        expect(next, testDate.add(const Duration(days: 14))); // Next occurrence in 2 weeks
      });

      test('should calculate next monthly occurrence', () {
        final pattern = RecurrencePattern.monthly(interval: 2);
        final next = pattern.getNextOccurrence(testDate);
        final expected = DateTime(2024, 3, 15, 10, 30); // 2 months later
        expect(next, expected);
      });

      test('should calculate next yearly occurrence', () {
        final pattern = RecurrencePattern.yearly(interval: 2);
        final next = pattern.getNextOccurrence(testDate);
        final expected = DateTime(2026, 1, 15, 10, 30); // 2 years later
        expect(next, expected);
      });

      test('should return null for custom type', () {
        const pattern = RecurrencePattern(type: RecurrenceType.custom);
        final next = pattern.getNextOccurrence(testDate);
        expect(next, isNull);
      });
    });

    group('isValid', () {
      test('should return true for valid pattern', () {
        final pattern = RecurrencePattern.daily(interval: 1);
        expect(pattern.isValid(), true);
      });

      test('should return false for zero interval', () {
        expect(() => RecurrencePattern(type: RecurrenceType.daily, interval: 0), 
               throwsA(isA<AssertionError>()));
      });

      test('should return false for negative interval', () {
        expect(() => RecurrencePattern(type: RecurrenceType.daily, interval: -1), 
               throwsA(isA<AssertionError>()));
      });

      test('should return false for invalid weekly days', () {
        final pattern = RecurrencePattern.weekly(daysOfWeek: const [0, 8]);
        expect(pattern.isValid(), false);
      });

      test('should return false for invalid monthly days', () {
        final pattern = RecurrencePattern.monthly(daysOfMonth: const [0, 32]);
        expect(pattern.isValid(), false);
      });

      test('should return false for zero max occurrences', () {
        final pattern = RecurrencePattern.daily(maxOccurrences: 0);
        expect(pattern.isValid(), false);
      });

      test('should return false for negative max occurrences', () {
        final pattern = RecurrencePattern.daily(maxOccurrences: -1);
        expect(pattern.isValid(), false);
      });
    });

    group('getDescription', () {
      test('should return correct description for none', () {
        const pattern = RecurrencePattern(type: RecurrenceType.none);
        expect(pattern.getDescription(), 'No recurrence');
      });

      test('should return correct description for daily', () {
        final pattern1 = RecurrencePattern.daily();
        expect(pattern1.getDescription(), 'Daily');

        final pattern2 = RecurrencePattern.daily(interval: 3);
        expect(pattern2.getDescription(), 'Every 3 days');
      });

      test('should return correct description for weekly', () {
        final pattern1 = RecurrencePattern.weekly();
        expect(pattern1.getDescription(), 'Weekly');

        final pattern2 = RecurrencePattern.weekly(interval: 2);
        expect(pattern2.getDescription(), 'Every 2 weeks');

        final pattern3 = RecurrencePattern.weekly(daysOfWeek: const [1, 3, 5]);
        expect(pattern3.getDescription(), 'Weekly on Monday, Wednesday, Friday');

        final pattern4 = RecurrencePattern.weekly(interval: 2, daysOfWeek: const [1, 5]);
        expect(pattern4.getDescription(), 'Every 2 weeks on Monday, Friday');
      });

      test('should return correct description for monthly', () {
        final pattern1 = RecurrencePattern.monthly();
        expect(pattern1.getDescription(), 'Monthly');

        final pattern2 = RecurrencePattern.monthly(interval: 3);
        expect(pattern2.getDescription(), 'Every 3 months');
      });

      test('should return correct description for yearly', () {
        final pattern1 = RecurrencePattern.yearly();
        expect(pattern1.getDescription(), 'Yearly');

        final pattern2 = RecurrencePattern.yearly(interval: 2);
        expect(pattern2.getDescription(), 'Every 2 years');
      });

      test('should return correct description for custom', () {
        const pattern = RecurrencePattern(type: RecurrenceType.custom);
        expect(pattern.getDescription(), 'Custom recurrence');
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final pattern1 = RecurrencePattern.weekly(
          interval: 2,
          daysOfWeek: const [1, 3, 5],
          endDate: testDate,
          maxOccurrences: 10,
        );

        final pattern2 = RecurrencePattern.weekly(
          interval: 2,
          daysOfWeek: const [1, 3, 5],
          endDate: testDate,
          maxOccurrences: 10,
        );

        expect(pattern1, equals(pattern2));
        expect(pattern1.hashCode, equals(pattern2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final pattern1 = RecurrencePattern.daily(interval: 1);
        final pattern2 = RecurrencePattern.daily(interval: 2);

        expect(pattern1, isNot(equals(pattern2)));
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        final pattern = RecurrencePattern.weekly(
          interval: 2,
          daysOfWeek: const [1, 3, 5],
          endDate: testDate,
          maxOccurrences: 10,
        );

        final string = pattern.toString();

        expect(string, contains('RecurrencePattern'));
        expect(string, contains('weekly'));
        expect(string, contains('2'));
        expect(string, contains('[1, 3, 5]'));
        expect(string, contains('10'));
      });
    });
  });
}
