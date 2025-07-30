import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/services/ai/ai_task_parser.dart';

void main() {
  group('ParsedTaskData', () {
    test('should create ParsedTaskData with required fields', () {
      const parsedData = ParsedTaskData(
        title: 'Test Task',
        priority: TaskPriority.high,
        confidence: 0.8,
      );

      expect(parsedData.title, equals('Test Task'));
      expect(parsedData.priority, equals(TaskPriority.high));
      expect(parsedData.confidence, equals(0.8));
      expect(parsedData.description, isNull);
      expect(parsedData.dueDate, isNull);
      expect(parsedData.suggestedTags, isEmpty);
      expect(parsedData.subtasks, isEmpty);
      expect(parsedData.metadata, isEmpty);
    });

    test('should create ParsedTaskData with all fields', () {
      final dueDate = DateTime.now().add(const Duration(days: 1));
      final parsedData = ParsedTaskData(
        title: 'Complete project',
        description: 'Finish the mobile app project',
        dueDate: dueDate,
        priority: TaskPriority.urgent,
        suggestedTags: ['work', 'project'],
        subtasks: ['Design UI', 'Implement features', 'Test app'],
        confidence: 0.9,
        metadata: {'source': 'openai'},
      );

      expect(parsedData.title, equals('Complete project'));
      expect(parsedData.description, equals('Finish the mobile app project'));
      expect(parsedData.dueDate, equals(dueDate));
      expect(parsedData.priority, equals(TaskPriority.urgent));
      expect(parsedData.suggestedTags, equals(['work', 'project']));
      expect(parsedData.subtasks, equals(['Design UI', 'Implement features', 'Test app']));
      expect(parsedData.confidence, equals(0.9));
      expect(parsedData.metadata, equals({'source': 'openai'}));
    });

    test('should create copy with updated fields', () {
      const original = ParsedTaskData(
        title: 'Original Task',
        priority: TaskPriority.medium,
        confidence: 0.5,
      );

      final updated = original.copyWith(
        title: 'Updated Task',
        priority: TaskPriority.high,
        suggestedTags: ['updated'],
      );

      expect(updated.title, equals('Updated Task'));
      expect(updated.priority, equals(TaskPriority.high));
      expect(updated.suggestedTags, equals(['updated']));
      expect(updated.confidence, equals(0.5)); // Unchanged
    });

    test('should have meaningful toString', () {
      const parsedData = ParsedTaskData(
        title: 'Test Task',
        priority: TaskPriority.high,
        suggestedTags: ['tag1', 'tag2'],
        subtasks: ['subtask1'],
        confidence: 0.8,
      );

      final string = parsedData.toString();
      expect(string, contains('Test Task'));
      expect(string, contains('TaskPriority.high'));
      expect(string, contains('tags: 2'));
      expect(string, contains('subtasks: 1'));
      expect(string, contains('confidence: 0.8'));
    });
  });

  group('AIParsingException', () {
    test('should create exception with message', () {
      const exception = AIParsingException('Test error');
      
      expect(exception.message, equals('Test error'));
      expect(exception.code, isNull);
      expect(exception.originalError, isNull);
    });

    test('should create exception with all fields', () {
      const originalError = 'Network error';
      const exception = AIParsingException(
        'AI parsing failed',
        code: 'NETWORK_ERROR',
        originalError: originalError,
      );
      
      expect(exception.message, equals('AI parsing failed'));
      expect(exception.code, equals('NETWORK_ERROR'));
      expect(exception.originalError, equals(originalError));
    });

    test('should have meaningful toString', () {
      const exception = AIParsingException('Test error');
      expect(exception.toString(), equals('AIParsingException: Test error'));
    });
  });
}