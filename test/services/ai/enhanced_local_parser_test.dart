import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/services/ai/enhanced_local_parser.dart';
import 'package:task_tracker_app/domain/models/enums.dart';

void main() {
  group('EnhancedLocalParser', () {
    late EnhancedLocalParser parser;

    setUp(() {
      parser = EnhancedLocalParser();
    });

    group('parseTaskFromText', () {
      test('should parse simple task correctly', () async {
        // Arrange
        const text = 'Buy milk';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.title, 'Buy milk');
        expect(result.priority, TaskPriority.medium);
        expect(result.suggestedTags, isNotEmpty);
      });

      test('should detect urgent priority', () async {
        // Arrange
        const text = 'URGENT: Call the doctor immediately';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.priority, TaskPriority.urgent);
        expect(result.title, contains('Call the doctor'));
        expect(result.suggestedTags, contains('health'));
      });

      test('should detect high priority', () async {
        // Arrange
        const text = 'Important meeting tomorrow at 3 PM';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.priority, TaskPriority.high);
        expect(result.suggestedTags, contains('work'));
      });

      test('should detect low priority', () async {
        // Arrange
        const text = 'When I have time, organize the garage';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.priority, TaskPriority.low);
      });

      test('should parse due dates correctly', () async {
        // Arrange
        const text = 'Submit report by Friday';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.dueDate, isNotNull);
        expect(result.dueDate!.weekday, DateTime.friday);
      });

      test('should handle relative dates', () async {
        // Arrange
        final testCases = [
          'Call mom tomorrow',
          'Meeting next week',
          'Doctor appointment in 3 days',
          'Project due in 2 weeks',
        ];

        // Act & Assert
        for (final text in testCases) {
          final result = await parser.parseTaskFromText(text);
          expect(result.dueDate, isNotNull, reason: 'Failed for: $text');
          expect(result.dueDate!.isAfter(DateTime.now()), true, reason: 'Failed for: $text');
        }
      });

      test('should handle specific dates', () async {
        // Arrange
        const text = 'Appointment on December 25th';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.dueDate, isNotNull);
        expect(result.dueDate!.month, 12);
        expect(result.dueDate!.day, 25);
      });

      test('should handle time specifications', () async {
        // Arrange
        const text = 'Meeting tomorrow at 2:30 PM';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.dueDate, isNotNull);
        expect(result.dueDate!.hour, 14); // 2 PM in 24-hour format
        expect(result.dueDate!.minute, 30);
      });
    });

    group('tag detection', () {
      test('should detect work-related tags', () async {
        // Arrange
        final workTexts = [
          'Schedule team meeting',
          'Review quarterly report',
          'Client presentation',
          'Send email to boss',
          'Complete project milestone',
        ];

        // Act & Assert
        for (final text in workTexts) {
          final result = await parser.parseTaskFromText(text);
          expect(result.suggestedTags, contains('work'), reason: 'Failed for: $text');
        }
      });

      test('should detect personal tags', () async {
        // Arrange
        final personalTexts = [
          'Call mom',
          'Family dinner',
          'Personal doctor appointment',
          'Visit grandmother',
        ];

        // Act & Assert
        for (final text in personalTexts) {
          final result = await parser.parseTaskFromText(text);
          expect(result.suggestedTags, contains('personal'), reason: 'Failed for: $text');
        }
      });

      test('should detect shopping tags', () async {
        // Arrange
        final shoppingTexts = [
          'Buy groceries',
          'Pick up milk',
          'Get bread from store',
          'Shopping for clothes',
          'Purchase new laptop',
        ];

        // Act & Assert
        for (final text in shoppingTexts) {
          final result = await parser.parseTaskFromText(text);
          expect(result.suggestedTags, contains('shopping'), reason: 'Failed for: $text');
        }
      });

      test('should detect health tags', () async {
        // Arrange
        final healthTexts = [
          'Doctor appointment',
          'Go to gym',
          'Take medication',
          'Dentist checkup',
          'Health screening',
        ];

        // Act & Assert
        for (final text in healthTexts) {
          final result = await parser.parseTaskFromText(text);
          expect(result.suggestedTags, contains('health'), reason: 'Failed for: $text');
        }
      });

      test('should detect communication tags', () async {
        // Arrange
        final commTexts = [
          'Call client',
          'Email professor',
          'Text message to friend',
          'Video call with team',
        ];

        // Act & Assert
        for (final text in commTexts) {
          final result = await parser.parseTaskFromText(text);
          expect(result.suggestedTags, contains('communication'), reason: 'Failed for: $text');
        }
      });

      test('should detect multiple tags', () async {
        // Arrange
        const text = 'Call doctor to schedule health checkup appointment';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.suggestedTags, contains('health'));
        expect(result.suggestedTags, contains('communication'));
      });
    });

    group('subtask extraction', () {
      test('should extract numbered subtasks', () async {
        // Arrange
        const text = '''Complete project setup:
1. Create repository
2. Set up development environment  
3. Write initial documentation
4. Configure CI/CD pipeline''';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.title, 'Complete project setup');
        expect(result.subtasks, hasLength(4));
        expect(result.subtasks, contains('Create repository'));
        expect(result.subtasks, contains('Set up development environment'));
        expect(result.subtasks, contains('Write initial documentation'));
        expect(result.subtasks, contains('Configure CI/CD pipeline'));
      });

      test('should extract bulleted subtasks', () async {
        // Arrange
        const text = '''Plan vacation:
• Book flights
• Reserve hotel
• Plan itinerary
• Pack bags''';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.title, 'Plan vacation');
        expect(result.subtasks, hasLength(4));
        expect(result.subtasks, contains('Book flights'));
        expect(result.subtasks, contains('Reserve hotel'));
      });

      test('should extract hyphenated subtasks', () async {
        // Arrange
        const text = '''Grocery shopping:
- Milk
- Bread  
- Eggs
- Cheese''';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.title, 'Grocery shopping');
        expect(result.subtasks, hasLength(4));
        expect(result.subtasks, contains('Milk'));
        expect(result.subtasks, contains('Bread'));
      });

      test('should handle mixed subtask formats', () async {
        // Arrange
        const text = '''Weekend tasks:
1. Clean house
• Vacuum living room
- Dust furniture
2. Do laundry''';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.title, 'Weekend tasks');
        expect(result.subtasks, hasLength(4));
      });
    });

    group('title extraction', () {
      test('should extract title from simple text', () async {
        // Arrange
        const text = 'Call John about the meeting';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.title, 'Call John about the meeting');
      });

      test('should extract title from complex text', () async {
        // Arrange
        const text = 'URGENT: Complete quarterly report by Friday afternoon for the board meeting';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.title, contains('Complete quarterly report'));
        expect(result.title.length, lessThan(60)); // Should be reasonably shortened
      });

      test('should extract title from multiline text', () async {
        // Arrange
        const text = '''Prepare presentation for client meeting
Include sales figures and growth projections
Schedule for next Tuesday at 10 AM''';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.title, 'Prepare presentation for client meeting');
        expect(result.description, contains('Include sales figures'));
      });

      test('should handle empty or whitespace text', () async {
        // Arrange
        const text = '   ';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.title, 'Untitled Task');
      });
    });

    group('description handling', () {
      test('should preserve original text as description', () async {
        // Arrange
        const text = 'Buy groceries for the weekly meal prep including vegetables and proteins';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.description, text);
      });

      test('should handle multiline descriptions', () async {
        // Arrange
        const text = '''Complete project documentation
Include API documentation
Add usage examples
Update README file''';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.description, text);
        expect(result.description, contains('Include API documentation'));
      });
    });

    group('error handling', () {
      test('should handle null input', () async {
        // Act & Assert
        expect(
          () => parser.parseTaskFromText(null as dynamic),
          throwsA(isA<TypeError>()),
        );
      });

      test('should handle empty string input', () async {
        // Arrange
        const text = '';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.title, 'Untitled Task');
        expect(result.priority, TaskPriority.medium);
        expect(result.suggestedTags, isEmpty);
      });

      test('should handle very long input', () async {
        // Arrange
        final longText = 'A' * 10000; // Very long string

        // Act
        final result = await parser.parseTaskFromText(longText);

        // Assert
        expect(result.title, isNotEmpty);
        expect(result.title.length, lessThan(100)); // Should be truncated
      });

      test('should handle special characters', () async {
        // Arrange
        const text = 'Task with émojis 🚀 and spécial chars (100% complete)';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.title, text);
      });
    });

    group('context-aware parsing', () {
      test('should handle wife-specific language patterns', () async {
        // Arrange
        final wifeTexts = [
          'Can you pick up milk on your way home?',
          'Please don\'t forget to call the dentist',
          'Could you get gas for the car?',
          'Would you mind taking out the trash?',
        ];

        // Act & Assert
        for (final text in wifeTexts) {
          final result = await parser.parseTaskFromText(text);
          expect(result.title, isNotEmpty, reason: 'Failed for: $text');
          // Should strip conversational elements and extract action
          expect(result.title, isNot(startsWith('Can you')), reason: 'Failed for: $text');
          expect(result.title, isNot(startsWith('Please')), reason: 'Failed for: $text');
        }
      });

      test('should handle question format', () async {
        // Arrange
        const text = 'Can you remind me to call mom tomorrow?';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.title, 'Call mom');
        expect(result.dueDate, isNotNull);
      });

      test('should handle imperative format', () async {
        // Arrange
        const text = 'Remember to buy groceries';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.title, 'Buy groceries');
      });
    });

    group('integration scenarios', () {
      test('should handle complete message scenario', () async {
        // Arrange
        const text = 'URGENT: Can you please pick up the dry cleaning today before 6 PM? We need the suits for tomorrow\'s wedding.';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.title, contains('pick up'));
        expect(result.title, contains('dry cleaning'));
        expect(result.priority, TaskPriority.urgent);
        expect(result.dueDate, isNotNull);
        expect(result.dueDate!.hour, 18); // 6 PM
        expect(result.suggestedTags, isNotEmpty);
        expect(result.description, text);
      });

      test('should handle shopping list scenario', () async {
        // Arrange
        const text = '''We need groceries for this week:
1. Milk (2%)
2. Bread (whole wheat)
3. Eggs (dozen)
4. Chicken breast
5. Vegetables (broccoli, carrots)''';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.title, contains('groceries'));
        expect(result.subtasks, hasLength(5));
        expect(result.suggestedTags, contains('shopping'));
        expect(result.priority, TaskPriority.medium);
      });

      test('should handle appointment scenario', () async {
        // Arrange
        const text = 'Don\'t forget - doctor appointment tomorrow at 2:30 PM for annual checkup';

        // Act
        final result = await parser.parseTaskFromText(text);

        // Assert
        expect(result.title, contains('doctor appointment'));
        expect(result.dueDate, isNotNull);
        expect(result.dueDate!.hour, 14);
        expect(result.dueDate!.minute, 30);
        expect(result.suggestedTags, contains('health'));
        expect(result.priority, TaskPriority.medium);
      });
    });

    group('performance tests', () {
      test('should parse simple text quickly', () async {
        // Arrange
        const text = 'Buy milk';
        final stopwatch = Stopwatch()..start();

        // Act
        await parser.parseTaskFromText(text);
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be very fast
      });

      test('should parse complex text reasonably quickly', () async {
        // Arrange
        const complexText = '''
URGENT: Complete quarterly business review presentation for board meeting next Tuesday at 10 AM.
Include the following sections:
1. Q3 financial summary and variance analysis
2. Key performance indicators and metrics
3. Market analysis and competitive positioning
4. Product roadmap and development updates
5. Risk assessment and mitigation strategies
6. Q4 objectives and strategic initiatives
Make sure to coordinate with finance team for latest numbers and marketing for competitive data.
''';
        final stopwatch = Stopwatch()..start();

        // Act
        await parser.parseTaskFromText(complexText);
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(500)); // Should be reasonably fast
      });
    });
  });
}
