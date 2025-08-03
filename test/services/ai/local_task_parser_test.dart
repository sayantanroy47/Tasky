import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/services/ai/local_task_parser.dart';

void main() {
  late LocalTaskParser parser;

  setUp(() {
    parser = LocalTaskParser();
  });

  group('LocalTaskParser', () {
    test('should always be available', () {
      expect(parser.isAvailable, isTrue);
      expect(parser.serviceName, equals('Local Parser'));
    });

    group('parseTaskFromText', () {
      test('should parse simple task', () async {
        const text = 'Buy groceries';
        final result = await parser.parseTaskFromText(text);

        expect(result.title, equals('Buy groceries'));
        expect(result.confidence, equals(0.7));
        expect(result.metadata['source'], equals('local'));
      });

      test('should parse task with description', () async {
        const text = 'Buy groceries. Need milk, bread, and eggs from the store.';
        final result = await parser.parseTaskFromText(text);

        expect(result.title, equals('Buy groceries'));
        expect(result.description, equals('Need milk, bread, and eggs from the store.'));
      });

      test('should parse task with due date', () async {
        const text = 'Submit report tomorrow';
        final result = await parser.parseTaskFromText(text);

        expect(result.title, equals('Submit report tomorrow'));
        expect(result.dueDate, isNotNull);
        expect(result.dueDate!.day, equals(DateTime.now().add(const Duration(days: 1)).day));
      });

      test('should parse task with priority', () async {
        const text = 'Urgent: Fix critical bug in production';
        final result = await parser.parseTaskFromText(text);

        expect(result.title, contains('Fix critical bug'));
        expect(result.priority, equals(TaskPriority.urgent));
      });

      test('should parse task with subtasks', () async {
        const text = 'Prepare presentation: 1. Research topic 2. Create slides 3. Practice delivery';
        final result = await parser.parseTaskFromText(text);

        expect(result.title, contains('Prepare presentation'));
        expect(result.subtasks, hasLength(3));
        expect(result.subtasks, contains('Research topic'));
        expect(result.subtasks, contains('Create slides'));
        expect(result.subtasks, contains('Practice delivery'));
      });
    });

    group('suggestTags', () {
      test('should suggest work-related tags', () async {
        const text = 'Attend team meeting about project deadline';
        final tags = await parser.suggestTags(text);

        expect(tags, contains('meeting'));
        expect(tags, contains('work'));
      });

      test('should suggest shopping tags', () async {
        const text = 'Buy groceries at the store';
        final tags = await parser.suggestTags(text);

        expect(tags, contains('shopping'));
      });

      test('should suggest health tags', () async {
        const text = 'Schedule doctor appointment for checkup';
        final tags = await parser.suggestTags(text);

        expect(tags, contains('health'));
      });

      test('should suggest priority tags', () async {
        const text = 'Urgent task that needs immediate attention';
        final tags = await parser.suggestTags(text);

        expect(tags, contains('urgent'));
      });

      test('should limit tags to 5', () async {
        const text = 'Urgent important meeting call email project work deadline';
        final tags = await parser.suggestTags(text);

        expect(tags.length, lessThanOrEqualTo(5));
      });
    });

    group('extractDueDate', () {
      test('should extract "today"', () async {
        const text = 'Complete task today';
        final date = await parser.extractDueDate(text);

        expect(date, isNotNull);
        expect(date!.day, equals(DateTime.now().day));
        expect(date.hour, equals(23));
        expect(date.minute, equals(59));
      });

      test('should extract "tomorrow"', () async {
        const text = 'Submit report tomorrow';
        final date = await parser.extractDueDate(text);

        expect(date, isNotNull);
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(date!.day, equals(tomorrow.day));
      });

      test('should extract "this week"', () async {
        const text = 'Finish project this week';
        final date = await parser.extractDueDate(text);

        expect(date, isNotNull);
        expect(date!.weekday, equals(5)); // Friday
        expect(date.hour, equals(17)); // 5 PM
      });

      test('should extract "next week"', () async {
        const text = 'Start new project next week';
        final date = await parser.extractDueDate(text);

        expect(date, isNotNull);
        final nextWeek = DateTime.now().add(const Duration(days: 7));
        expect(date!.isAfter(nextWeek.subtract(const Duration(days: 1))), isTrue);
      });

      test('should extract specific weekday', () async {
        const text = 'Meeting on Friday';
        final date = await parser.extractDueDate(text);

        expect(date, isNotNull);
        expect(date!.weekday, equals(5)); // Friday
      });

      test('should extract relative days', () async {
        const text = 'Due in 3 days';
        final date = await parser.extractDueDate(text);

        expect(date, isNotNull);
        final expected = DateTime.now().add(const Duration(days: 3));
        expect(date!.day, equals(expected.day));
      });

      test('should extract date formats', () async {
        final now = DateTime.now();
        final nextYear = now.year + 1;
        final text = 'Due on 12/25/$nextYear';
        final date = await parser.extractDueDate(text);

        expect(date, isNotNull);
        expect(date!.month, equals(12));
        expect(date.day, equals(25));
        expect(date.year, equals(nextYear));
      });

      test('should return null for no date', () async {
        const text = 'Simple task with no date';
        final date = await parser.extractDueDate(text);

        expect(date, isNull);
      });
    });

    group('determinePriority', () {
      test('should detect urgent priority', () async {
        const text = 'Urgent: Fix production bug immediately';
        final priority = await parser.determinePriority(text);

        expect(priority, equals(TaskPriority.urgent));
      });

      test('should detect high priority', () async {
        const text = 'Important deadline for project';
        final priority = await parser.determinePriority(text);

        expect(priority, equals(TaskPriority.high));
      });

      test('should detect low priority', () async {
        const text = 'Low priority task when possible';
        final priority = await parser.determinePriority(text);

        expect(priority, equals(TaskPriority.low));
      });

      test('should default to medium priority', () async {
        const text = 'Regular task without priority indicators';
        final priority = await parser.determinePriority(text);

        expect(priority, equals(TaskPriority.medium));
      });
    });

    group('extractSubtasks', () {
      test('should extract numbered list', () async {
        const text = 'Project tasks: 1. Design 2. Develop 3. Test';
        final subtasks = await parser.extractSubtasks(text);

        expect(subtasks, hasLength(3));
        expect(subtasks, contains('Design'));
        expect(subtasks, contains('Develop'));
        expect(subtasks, contains('Test'));
      });

      test('should extract bulleted list', () async {
        const text = 'Shopping list: - Milk - Bread - Eggs';
        final subtasks = await parser.extractSubtasks(text);

        expect(subtasks, hasLength(3));
        expect(subtasks, contains('Milk'));
        expect(subtasks, contains('Bread'));
        expect(subtasks, contains('Eggs'));
      });

      test('should extract sequential indicators', () async {
        const text = 'First, prepare materials. Then, start work. Finally, review results.';
        final subtasks = await parser.extractSubtasks(text);

        expect(subtasks, isNotEmpty);
        expect(subtasks.any((task) => task.contains('prepare materials')), isTrue);
      });

      test('should limit subtasks to 10', () async {
        const text = '''
        Tasks: 1. One 2. Two 3. Three 4. Four 5. Five 
        6. Six 7. Seven 8. Eight 9. Nine 10. Ten 
        11. Eleven 12. Twelve
        ''';
        final subtasks = await parser.extractSubtasks(text);

        expect(subtasks.length, lessThanOrEqualTo(10));
      });

      test('should return empty list for no subtasks', () async {
        const text = 'Simple task with no subtasks';
        final subtasks = await parser.extractSubtasks(text);

        expect(subtasks, isEmpty);
      });
    });
  });
}
