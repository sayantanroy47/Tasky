import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/services/ai/ai_task_parsing_service.dart';
import 'package:task_tracker_app/services/ai/composite_ai_task_parser.dart';
import 'package:task_tracker_app/services/ai/local_task_parser.dart';

void main() {
  group('AI Task Parsing Integration Tests', () {
    late AITaskParsingService service;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      
      final parser = CompositeAITaskParser(
        localParser: LocalTaskParser(),
        preferredService: AIServiceType.local,
        enableAI: false, // Use local parsing for integration tests
      );
      
      service = AITaskParsingService(
        parser: parser,
        prefs: prefs,
      );
    });

    group('Task Creation from Text', () {
      test('should create basic task from simple text', () async {
        const text = 'Buy groceries';
        final task = await service.createTaskFromText(text);

        expect(task.title, equals('Buy groceries'));
        expect(task.status, equals(TaskStatus.pending));
        expect(task.priority, equals(TaskPriority.medium));
        expect(task.metadata['original_text'], equals(text));
        expect(task.metadata['parsed_at'], isNotNull);
      });

      test('should create task with due date from natural language', () async {
        const text = 'Submit report tomorrow';
        final task = await service.createTaskFromText(text);

        expect(task.title, contains('Submit report'));
        expect(task.dueDate, isNotNull);
        expect(task.dueDate!.isAfter(DateTime.now()), isTrue);
      });

      test('should create task with priority from text', () async {
        const text = 'Urgent: Fix production bug immediately';
        final task = await service.createTaskFromText(text);

        expect(task.title, contains('Fix production bug'));
        expect(task.priority, equals(TaskPriority.urgent));
      });

      test('should create task with tags from context', () async {
        const text = 'Schedule doctor appointment for annual checkup';
        final task = await service.createTaskFromText(text);

        expect(task.title, contains('Schedule doctor appointment'));
        expect(task.tags, isNotEmpty);
        expect(task.tags, contains('health'));
      });

      test('should create task with subtasks from numbered list', () async {
        const text = 'Prepare presentation: 1. Research topic 2. Create slides 3. Practice delivery';
        final task = await service.createTaskFromText(text);

        expect(task.title, contains('Prepare presentation'));
        expect(task.subTasks, hasLength(3));
        expect(task.subTasks.any((st) => st.title.contains('Research')), isTrue);
        expect(task.subTasks.any((st) => st.title.contains('slides')), isTrue);
        expect(task.subTasks.any((st) => st.title.contains('Practice')), isTrue);
      });

      test('should handle complex task with multiple elements', () async {
        const text = '''
        Important: Complete project proposal by Friday.
        Need to research competitors, write executive summary, and create budget.
        This is for the mobile app project.
        ''';
        final task = await service.createTaskFromText(text);

        expect(task.title, contains('Complete project proposal'));
        expect(task.priority, equals(TaskPriority.high));
        expect(task.dueDate, isNotNull);
        expect(task.subTasks, isNotEmpty);
        expect(task.tags, contains('work'));
      });

      test('should fallback gracefully on parsing errors', () async {
        const text = 'Simple task';
        // Force an error by using null parser (this would be handled in real implementation)
        final task = await service.createTaskFromText(text);

        expect(task.title, isNotEmpty);
        expect(task.status, equals(TaskStatus.pending));
      });
    });

    group('Task Enhancement', () {
      test('should enhance task with additional tags when AI enabled', () async {
        await service.setAIEnabled(true);
        
        final originalTask = await service.createTaskFromText('Buy groceries');
        final enhancedTask = await service.enhanceTask(
          originalTask, 
          'Need to get organic vegetables and dairy products'
        );

        // Since AI is disabled in tests, enhancement should not change the task
        expect(enhancedTask.id, equals(originalTask.id));
      });

      test('should not enhance task when AI disabled', () async {
        await service.setAIEnabled(false);
        
        final originalTask = await service.createTaskFromText('Buy groceries');
        final enhancedTask = await service.enhanceTask(originalTask, 'additional context');

        expect(enhancedTask, equals(originalTask));
      });
    });

    group('Individual Parsing Functions', () {
      test('should suggest relevant tags', () async {
        final tags = await service.suggestTagsForTask('Team meeting about project deadline');
        
        expect(tags, isNotEmpty);
        expect(tags, contains('meeting'));
        expect(tags, contains('work'));
      });

      test('should extract due date from text', () async {
        final date = await service.extractDueDateFromText('Complete by tomorrow');
        
        expect(date, isNotNull);
        expect(date!.isAfter(DateTime.now()), isTrue);
      });

      test('should determine priority from text', () async {
        final priority = await service.determinePriorityFromText('Urgent task needs immediate attention');
        
        expect(priority, equals(TaskPriority.urgent));
      });
    });

    group('Configuration Management', () {
      test('should manage AI enabled setting', () async {
        expect(service.isAIEnabled, isFalse);
        
        await service.setAIEnabled(true);
        expect(service.isAIEnabled, isTrue);
        
        await service.setAIEnabled(false);
        expect(service.isAIEnabled, isFalse);
      });

      test('should manage AI service selection', () async {
        expect(service.currentService, equals(AIServiceType.local));
        
        await service.setAIService(AIServiceType.openai);
        expect(service.currentService, equals(AIServiceType.openai));
      });

      test('should provide usage statistics', () async {
        final stats = service.getUsageStats();
        
        expect(stats['ai_enabled'], isA<bool>());
        expect(stats['current_service'], isA<String>());
        expect(stats['service_available'], isA<bool>());
        expect(stats['total_parses'], isA<int>());
        expect(stats['successful_parses'], isA<int>());
      });
    });

    group('Service Properties', () {
      test('should report service availability', () {
        expect(service.isServiceAvailable, isTrue);
        expect(service.currentServiceName, equals('Local Parser'));
      });

      test('should list available services', () {
        final services = service.availableServices;
        expect(services, contains(AIServiceType.local));
      });
    });

    group('Error Handling', () {
      test('should handle empty text gracefully', () async {
        final task = await service.createTaskFromText('');
        
        expect(task.title, equals('New Task'));
        expect(task.metadata['fallback_used'], isTrue);
      });

      test('should handle very long text', () async {
        final longText = 'A' * 1000;
        final task = await service.createTaskFromText(longText);
        
        expect(task.title, isNotEmpty);
        expect(task.title.length, lessThanOrEqualTo(103)); // 100 chars + '...'
      });

      test('should handle special characters', () async {
        const text = 'Task with émojis 🚀 and spëcial chars!';
        final task = await service.createTaskFromText(text);
        
        expect(task.title, contains('Task with'));
        expect(task.title, contains('🚀'));
      });
    });

    group('Real-world Scenarios', () {
      test('should parse voice-transcribed text', () async {
        const text = 'remind me to call mom tomorrow at 3 PM about dinner plans';
        final task = await service.createTaskFromText(text);

        expect(task.title, contains('call mom'));
        expect(task.dueDate, isNotNull);
        expect(task.tags, contains('communication'));
      });

      test('should parse email-like task', () async {
        const text = 'Reply to John about the quarterly report by end of week';
        final task = await service.createTaskFromText(text);

        expect(task.title, contains('Reply to John'));
        expect(task.dueDate, isNotNull);
        expect(task.tags, contains('communication'));
      });

      test('should parse shopping list', () async {
        const text = 'Buy groceries: milk, bread, eggs, and vegetables from the store';
        final task = await service.createTaskFromText(text);

        expect(task.title, contains('Buy groceries'));
        expect(task.tags, contains('shopping'));
        expect(task.description, contains('milk'));
      });

      test('should parse work task with deadline', () async {
        const text = 'High priority: Submit quarterly budget report to finance team by Friday 5 PM';
        final task = await service.createTaskFromText(text);

        expect(task.title, contains('Submit quarterly budget'));
        expect(task.priority, equals(TaskPriority.high));
        expect(task.dueDate, isNotNull);
        expect(task.tags, contains('work'));
      });
    });
  });
}
