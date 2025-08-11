import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:task_tracker_app/services/ai/ai_task_parsing_service.dart';
import 'package:task_tracker_app/services/ai/composite_ai_task_parser.dart';
import 'package:task_tracker_app/services/ai/local_task_parser.dart';
import 'package:task_tracker_app/services/ai/openai_task_parser.dart';
import 'package:task_tracker_app/services/ai/claude_task_parser.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/services/security/api_key_manager.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AI Task Parsing Flow Integration Tests', () {
    late CompositeAITaskParser parser;
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      parser = CompositeAITaskParser();
    });

    tearDown(() {
      container.dispose();
    });

    test('local parser handles simple task creation', () async {
      const input = 'Buy groceries tomorrow at 5 PM high priority';
      
      final result = await parser.parseTask(input);
      
      expect(result.isSuccess, isTrue);
      expect(result.task?.title, contains('groceries'));
      expect(result.task?.priority, equals(TaskPriority.high));
      expect(result.task?.dueDate, isNotNull);
      expect(result.confidence, greaterThan(0.7));
    });

    test('local parser handles complex task with subtasks', () async {
      const input = '''
        Plan birthday party for next week:
        - Book venue
        - Send invitations  
        - Order cake
        - Buy decorations
      ''';
      
      final result = await parser.parseTask(input);
      
      expect(result.isSuccess, isTrue);
      expect(result.task?.title, contains('birthday party'));
      expect(result.task?.hasSubTasks, isTrue);
      expect(result.task?.subTasks.length, greaterThanOrEqualTo(3));
      expect(result.task?.subTasks.any((s) => s.title.contains('venue')), isTrue);
      expect(result.task?.subTasks.any((s) => s.title.contains('invitations')), isTrue);
    });

    test('parser handles date and time extraction', () async {
      const input = 'Meeting with client on Friday 3:30 PM urgent';
      
      final result = await parser.parseTask(input);
      
      expect(result.isSuccess, isTrue);
      expect(result.task?.dueDate, isNotNull);
      expect(result.task?.dueDate?.hour, equals(15));
      expect(result.task?.dueDate?.minute, equals(30));
      expect(result.task?.priority, equals(TaskPriority.urgent));
    });

    test('parser handles recurring tasks', () async {
      const input = 'Daily standup meeting every weekday at 9 AM';
      
      final result = await parser.parseTask(input);
      
      expect(result.isSuccess, isTrue);
      expect(result.task?.recurrence, isNotNull);
      expect(result.task?.recurrence?.type, equals(RecurrenceType.weekly));
      expect(result.task?.recurrence?.daysOfWeek, isNotNull);
    });

    test('parser handles location-based tasks', () async {
      const input = 'Pick up dry cleaning when I\'m near downtown';
      
      final result = await parser.parseTask(input);
      
      expect(result.isSuccess, isTrue);
      expect(result.task?.locationTrigger, isNotNull);
      expect(result.task?.locationTrigger, contains('downtown'));
    });

    test('parser handles project assignment', () async {
      const input = 'Review quarterly reports for Q4 project';
      
      final result = await parser.parseTask(input);
      
      expect(result.isSuccess, isTrue);
      expect(result.task?.title, contains('quarterly reports'));
      // Project assignment would be determined by existing projects
    });

    test('parser handles priority extraction variations', () async {
      final testCases = [
        ('urgent task call doctor', TaskPriority.urgent),
        ('high priority meeting', TaskPriority.high),
        ('low priority organize files', TaskPriority.low),
        ('medium task update website', TaskPriority.medium),
        ('important presentation prep', TaskPriority.high),
        ('ASAP fix the bug', TaskPriority.urgent),
      ];

      for (final testCase in testCases) {
        final result = await parser.parseTask(testCase.$1);
        
        expect(result.isSuccess, isTrue, 
          reason: 'Failed to parse: ${testCase.$1}');
        expect(result.task?.priority, equals(testCase.$2),
          reason: 'Wrong priority for: ${testCase.$1}');
      }
    });

    test('parser handles invalid input gracefully', () async {
      final invalidInputs = [
        '', // Empty string
        '   ', // Only whitespace
        '!@#\$%^&*()', // Only special characters
        'a', // Too short
      ];

      for (final input in invalidInputs) {
        final result = await parser.parseTask(input);
        
        expect(result.isSuccess, isFalse,
          reason: 'Should fail for invalid input: "$input"');
        expect(result.error, isNotNull);
      }
    });

    test('external API integration (mock) with fallback', () async {
      // Test that external API is attempted but falls back to local
      const input = 'Complex scheduling task with multiple dependencies';
      
      // This will attempt external API (which may fail in test environment)
      // but should fall back to local parser
      final result = await parser.parseTask(input);
      
      expect(result.isSuccess, isTrue);
      expect(result.task?.title, isNotNull);
      expect(result.parserUsed, isIn(['local', 'openai', 'claude']));
    });

    test('performance under load', () async {
      const inputs = [
        'Schedule dentist appointment',
        'Buy groceries milk bread eggs',
        'Call mom tonight',
        'Finish project report by Friday',
        'Weekly team meeting every Monday',
      ];

      final stopwatch = Stopwatch()..start();
      
      final futures = inputs.map((input) => parser.parseTask(input));
      final results = await Future.wait(futures);
      
      stopwatch.stop();
      
      // Should complete within reasonable time (5 seconds for 5 tasks)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      
      // All should succeed
      for (final result in results) {
        expect(result.isSuccess, isTrue);
      }
    });

    test('confidence scoring accuracy', () async {
      final testCases = [
        ('Buy milk', 0.9), // Simple, clear task
        ('Schedule important meeting with John next Tuesday 2 PM', 0.95), // Detailed
        ('Do stuff', 0.3), // Vague
        ('Asdfghjkl qwerty', 0.1), // Nonsensical
      ];

      for (final testCase in testCases) {
        final result = await parser.parseTask(testCase.$1);
        
        if (result.isSuccess) {
          expect(result.confidence, greaterThanOrEqualTo(testCase.$2 - 0.2),
            reason: 'Confidence too low for: ${testCase.$1}');
        }
      }
    });

    test('context preservation across multiple parsing calls', () async {
      // First task establishes context
      await parser.parseTask('Meeting about project Alpha tomorrow');
      
      // Second task should potentially inherit context
      final result2 = await parser.parseTask('Follow up on the discussion');
      
      expect(result2.isSuccess, isTrue);
      expect(result2.task?.title, contains('follow up'));
      // Context inheritance would be implementation-specific
    });

    test('batch parsing efficiency', () async {
      final inputs = List.generate(10, (i) => 'Task number ${i + 1}');
      
      final stopwatch = Stopwatch()..start();
      
      // Parse all tasks
      final results = <ParsedTaskResult>[];
      for (final input in inputs) {
        final result = await parser.parseTask(input);
        results.add(result);
      }
      
      stopwatch.stop();
      
      // Should complete within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      
      // All should succeed
      expect(results.every((r) => r.isSuccess), isTrue);
      
      // Each task should have unique content
      final titles = results.map((r) => r.task?.title).toSet();
      expect(titles.length, equals(inputs.length));
    });

    test('error recovery and logging', () async {
      // Input that might cause parsing issues
      const problematicInput = 'Task with \u0000 null characters and 📱 emoji';
      
      final result = await parser.parseTask(problematicInput);
      
      // Should either succeed or fail gracefully
      if (!result.isSuccess) {
        expect(result.error, isNotNull);
        expect(result.error!.length, greaterThan(0));
      } else {
        expect(result.task?.title, isNotNull);
      }
    });
  });

  group('AI Service Configuration Tests', () {
    test('service type switching', () async {
      // Test switching between different AI services
      final config = AIParsingConfig(
        serviceType: AIServiceType.local,
        fallbackEnabled: true,
        confidenceThreshold: 0.7,
      );

      final parser = CompositeAITaskParser();
      await parser.updateConfiguration(config);

      const input = 'Test task for service switching';
      final result = await parser.parseTask(input);

      expect(result.isSuccess, isTrue);
      expect(result.parserUsed, equals('local'));
    });

    test('fallback mechanism', () async {
      // Configure to prefer external but fall back to local
      final config = AIParsingConfig(
        serviceType: AIServiceType.openai,
        fallbackEnabled: true,
        confidenceThreshold: 0.8,
      );

      final parser = CompositeAITaskParser();
      await parser.updateConfiguration(config);

      const input = 'Test fallback mechanism';
      final result = await parser.parseTask(input);

      // Should succeed with either service
      expect(result.isSuccess, isTrue);
      expect(result.parserUsed, isIn(['local', 'openai']));
    });
  });
}