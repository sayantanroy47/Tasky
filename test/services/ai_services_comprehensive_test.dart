import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/services/ai/claude_task_parser.dart';
import 'package:task_tracker_app/services/ai/openai_task_parser.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

@GenerateMocks([http.Client])
import 'ai_services_comprehensive_test.mocks.dart';

/// COMPREHENSIVE AI SERVICES TESTS - ALL AI PARSING FUNCTIONALITY AND EDGE CASES
void main() {
  group('AI Services - Comprehensive Task Parsing Tests', () {
    late MockClient mockHttpClient;
    late ClaudeTaskParser claudeParser;
    late OpenAITaskParser openAIParser;

    setUp(() {
      mockHttpClient = MockClient();
      claudeParser = ClaudeTaskParser(client: mockHttpClient);
      openAIParser = OpenAITaskParser(client: mockHttpClient);
    });

    group('Claude Task Parser Tests', () {
      test('should parse simple task successfully', () async {
        // Arrange
        const userInput = 'Remind me to call Mom tomorrow at 3 PM';
        const mockResponse = '''
        {
          "title": "Call Mom",
          "description": null,
          "priority": "medium",
          "dueDate": "2024-12-25T15:00:00Z",
          "reminderDate": "2024-12-25T15:00:00Z",
          "tags": ["personal", "family"],
          "confidence": 0.95
        }
        ''';

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response(mockResponse, 200));

        // Act
        final result = await claudeParser.parseTask(userInput);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (task) {
            expect(task.title, equals('Call Mom'));
            expect(task.priority, equals(TaskPriority.medium));
            expect(task.tags, contains('personal'));
            expect(task.tags, contains('family'));
          },
        );
      });

      test('should parse complex task with multiple attributes', () async {
        // Arrange
        const complexInput = 'Create a high priority urgent task to review the Q4 financial reports, prepare presentation slides for the board meeting next Friday at 2 PM, and set a reminder for Thursday evening at 8 PM';
        const mockResponse = '''
        {
          "title": "Review Q4 financial reports and prepare presentation slides",
          "description": "For the board meeting",
          "priority": "urgent",
          "dueDate": "2024-12-27T14:00:00Z",
          "reminderDate": "2024-12-26T20:00:00Z",
          "tags": ["work", "financial", "presentation", "board", "urgent"],
          "subtasks": [
            "Review Q4 financial reports",
            "Prepare presentation slides",
            "Schedule board meeting room"
          ],
          "confidence": 0.92
        }
        ''';

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response(mockResponse, 200));

        // Act
        final result = await claudeParser.parseTask(complexInput);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (task) {
            expect(task.title, contains('financial reports'));
            expect(task.priority, equals(TaskPriority.urgent));
            expect(task.description, equals('For the board meeting'));
            expect(task.subtasks.length, equals(3));
            expect(task.tags, contains('work'));
            expect(task.tags, contains('urgent'));
          },
        );
      });

      test('should handle recurring task parsing', () async {
        // Arrange
        const recurringInput = 'Set up a daily reminder to take vitamins every morning at 8 AM starting tomorrow';
        const mockResponse = '''
        {
          "title": "Take vitamins",
          "description": "Daily vitamin reminder",
          "priority": "medium",
          "dueDate": "2024-12-25T08:00:00Z",
          "reminderDate": "2024-12-25T08:00:00Z",
          "tags": ["health", "daily"],
          "recurrence": {
            "pattern": "daily",
            "interval": 1,
            "endDate": null
          },
          "confidence": 0.88
        }
        ''';

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response(mockResponse, 200));

        // Act
        final result = await claudeParser.parseTask(recurringInput);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (task) {
            expect(task.title, equals('Take vitamins'));
            expect(task.isRecurring, isTrue);
            expect(task.tags, contains('health'));
            expect(task.tags, contains('daily'));
          },
        );
      });

      test('should handle location-based task parsing', () async {
        // Arrange
        const locationInput = 'When I get to the grocery store, remind me to buy milk, bread, and eggs';
        const mockResponse = '''
        {
          "title": "Buy milk, bread, and eggs",
          "description": "Grocery shopping list",
          "priority": "medium",
          "dueDate": null,
          "reminderDate": null,
          "tags": ["shopping", "groceries"],
          "location": {
            "name": "grocery store",
            "trigger": "arrival",
            "radius": 100
          },
          "subtasks": [
            "Buy milk",
            "Buy bread", 
            "Buy eggs"
          ],
          "confidence": 0.91
        }
        ''';

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response(mockResponse, 200));

        // Act
        final result = await claudeParser.parseTask(locationInput);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (task) {
            expect(task.title, contains('milk'));
            expect(task.subtasks.length, equals(3));
            expect(task.tags, contains('shopping'));
            expect(task.metadata['location'], isNotNull);
          },
        );
      });

      test('should handle ambiguous input gracefully', () async {
        // Arrange
        const ambiguousInput = 'maybe do something later idk';
        const mockResponse = '''
        {
          "error": "Unable to parse clear task from input",
          "suggestions": [
            "Please provide more specific details about what you want to do",
            "Consider including when you want to do it",
            "What is the main action you want to take?"
          ],
          "confidence": 0.15
        }
        ''';

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response(mockResponse, 400));

        // Act
        final result = await claudeParser.parseTask(ambiguousInput);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<AIParsingFailure>()),
          (task) => fail('Should not return task'),
        );
      });

      test('should handle API key missing error', () async {
        // Arrange
        const input = 'Create task to test API';
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('{"error": "API key required"}', 401));

        // Act
        final result = await claudeParser.parseTask(input);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<AuthenticationFailure>()),
          (task) => fail('Should not return task'),
        );
      });

      test('should handle network timeout', () async {
        // Arrange
        const input = 'Create task that times out';
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenThrow(TimeoutException('Request timeout', const Duration(seconds: 30)));

        // Act
        final result = await claudeParser.parseTask(input);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<TimeoutFailure>()),
          (task) => fail('Should not return task'),
        );
      });

      test('should handle malformed API response', () async {
        // Arrange
        const input = 'Valid input with invalid response';
        const malformedResponse = '{"title": "Incomplete JSON...';

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response(malformedResponse, 200));

        // Act
        final result = await claudeParser.parseTask(input);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ParseFailure>()),
          (task) => fail('Should not return task'),
        );
      });

      test('should handle rate limiting', () async {
        // Arrange
        const input = 'Create task when rate limited';
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('{"error": "Rate limit exceeded"}', 429));

        // Act
        final result = await claudeParser.parseTask(input);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<RateLimitFailure>()),
          (task) => fail('Should not return task'),
        );
      });
    });

    group('OpenAI Task Parser Tests', () {
      test('should parse task using OpenAI format', () async {
        // Arrange
        const userInput = 'Schedule dentist appointment for next Tuesday at 10 AM';
        const mockResponse = '''
        {
          "choices": [{
            "message": {
              "content": "{\\"title\\": \\"Dentist appointment\\", \\"description\\": \\"Regular checkup\\", \\"priority\\": \\"medium\\", \\"dueDate\\": \\"2024-12-24T10:00:00Z\\", \\"reminderDate\\": \\"2024-12-23T18:00:00Z\\", \\"tags\\": [\\"health\\", \\"appointment\\"]}"
            }
          }],
          "usage": {
            "prompt_tokens": 45,
            "completion_tokens": 67,
            "total_tokens": 112
          }
        }
        ''';

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response(mockResponse, 200));

        // Act
        final result = await openAIParser.parseTask(userInput);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should not return failure'),
          (task) {
            expect(task.title, equals('Dentist appointment'));
            expect(task.description, equals('Regular checkup'));
            expect(task.tags, contains('health'));
            expect(task.tags, contains('appointment'));
          },
        );
      });

      test('should handle OpenAI API errors', () async {
        // Arrange
        const input = 'Create task with OpenAI error';
        const errorResponse = '''
        {
          "error": {
            "message": "Invalid API key provided",
            "type": "invalid_request_error",
            "code": "invalid_api_key"
          }
        }
        ''';

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response(errorResponse, 401));

        // Act
        final result = await openAIParser.parseTask(input);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<AuthenticationFailure>()),
          (task) => fail('Should not return task'),
        );
      });

      test('should handle OpenAI content filtering', () async {
        // Arrange
        const input = 'Inappropriate content that gets filtered';
        const filteredResponse = '''
        {
          "choices": [{
            "message": {
              "content": null,
              "finish_reason": "content_filter"
            }
          }]
        }
        ''';

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response(filteredResponse, 200));

        // Act
        final result = await openAIParser.parseTask(input);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ContentFilterFailure>()),
          (task) => fail('Should not return task'),
        );
      });
    });

    group('AI Parser Fallback Tests', () {
      test('should fallback from Claude to OpenAI on failure', () async {
        // Arrange
        const input = 'Create task with fallback test';
        final expectedTask = TaskModel.create(title: 'Fallback Task');

        // Claude fails
        when(mockHttpClient.post(
          Uri.parse('https://api.anthropic.com/v1/messages'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('{"error": "Service unavailable"}', 503));

        // OpenAI succeeds
        const openAIResponse = '''
        {
          "choices": [{
            "message": {
              "content": "{\\"title\\": \\"Fallback Task\\", \\"priority\\": \\"medium\\"}"
            }
          }]
        }
        ''';

        when(mockHttpClient.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(openAIResponse, 200));

        // Simulate fallback logic
        var result = await claudeParser.parseTask(input);
        if (result.isLeft()) {
          result = await openAIParser.parseTask(input);
        }

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should succeed with fallback'),
          (task) => expect(task.title, equals('Fallback Task')),
        );
      });

      test('should handle both AI services failing', () async {
        // Arrange
        const input = 'Task when both services fail';
        
        // Both services fail
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('{"error": "Service unavailable"}', 503));

        // Act - Simulate fallback logic
        var result = await claudeParser.parseTask(input);
        if (result.isLeft()) {
          result = await openAIParser.parseTask(input);
        }

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (task) => fail('Should not return task when both fail'),
        );
      });
    });

    group('AI Parser Edge Cases and Robustness Tests', () {
      test('should handle empty input', () async {
        // Act
        final result = await claudeParser.parseTask('');

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (task) => fail('Should not return task for empty input'),
        );
      });

      test('should handle very long input', () async {
        // Arrange
        final longInput = 'Create a task ' * 1000; // Very long input
        const mockResponse = '''
        {
          "title": "Long input task",
          "description": "Truncated due to length",
          "priority": "medium",
          "confidence": 0.7
        }
        ''';

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response(mockResponse, 200));

        // Act
        final result = await claudeParser.parseTask(longInput);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should handle long input'),
          (task) => expect(task.title, isNotEmpty),
        );
      });

      test('should handle special characters and Unicode', () async {
        // Arrange
        const unicodeInput = 'Créér üne tâche avec des caractères spéciaux 🎯📅 @#%&';
        const mockResponse = '''
        {
          "title": "Créér üne tâche avec des caractères spéciaux",
          "description": "Task with special characters and emojis",
          "priority": "medium",
          "tags": ["unicode", "special"],
          "confidence": 0.85
        }
        ''';

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response(mockResponse, 200, headers: {'content-type': 'application/json; charset=utf-8'}));

        // Act
        final result = await claudeParser.parseTask(unicodeInput);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Should handle Unicode input'),
          (task) {
            expect(task.title, contains('Créér'));
            expect(task.title, contains('tâche'));
          },
        );
      });

      test('should handle multiple language inputs', () async {
        // Test various languages
        final languageTests = {
          'Spanish': 'Crear una tarea para llamar al doctor mañana',
          'French': 'Créer une tâche pour appeler le médecin demain',
          'German': 'Erstelle eine Aufgabe, um morgen den Arzt anzurufen',
          'Japanese': '明日医者に電話するタスクを作成する',
        };

        for (final entry in languageTests.entries) {
          final language = entry.key;
          final input = entry.value;
          
          final mockResponse = '''
          {
            "title": "Call doctor",
            "description": "Parsed from $language input",
            "priority": "medium",
            "language_detected": "${language.toLowerCase()}",
            "confidence": 0.8
          }
          ''';

          when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
              .thenAnswer((_) async => http.Response(mockResponse, 200));

          // Act
          final result = await claudeParser.parseTask(input);

          // Assert
          expect(result.isRight(), isTrue, reason: 'Should handle $language input');
          result.fold(
            (failure) => fail('Should handle $language input'),
            (task) => expect(task.title, isNotEmpty),
          );
        }
      });

      test('should handle date parsing edge cases', () async {
        // Test various date formats
        final dateTests = [
          'tomorrow at 3pm',
          'next Monday',
          'in 2 weeks',
          'December 25th',
          '2024-12-25 15:30',
          'end of the month',
          'next quarter',
          'beginning of next year',
        ];

        for (final dateInput in dateTests) {
          final input = 'Create task due $dateInput';
          
          const mockResponse = '''
          {
            "title": "Date parsing task",
            "dueDate": "2024-12-25T15:30:00Z",
            "confidence": 0.9
          }
          ''';

          when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
              .thenAnswer((_) async => http.Response(mockResponse, 200));

          // Act
          final result = await claudeParser.parseTask(input);

          // Assert
          expect(result.isRight(), isTrue, reason: 'Should handle date format: $dateInput');
        }
      });

      test('should handle priority parsing variations', () async {
        // Test various priority expressions
        final priorityTests = {
          'urgent': TaskPriority.urgent,
          'URGENT': TaskPriority.urgent,
          'high priority': TaskPriority.high,
          'important': TaskPriority.high,
          'low priority': TaskPriority.low,
          'not important': TaskPriority.low,
          'normal': TaskPriority.medium,
        };

        for (final entry in priorityTests.entries) {
          final priorityText = entry.key;
          final expectedPriority = entry.value;
          final input = 'Create $priorityText task';
          
          final mockResponse = '''
          {
            "title": "Priority test task",
            "priority": "${expectedPriority.name}",
            "confidence": 0.9
          }
          ''';

          when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
              .thenAnswer((_) async => http.Response(mockResponse, 200));

          // Act
          final result = await claudeParser.parseTask(input);

          // Assert
          expect(result.isRight(), isTrue);
          result.fold(
            (failure) => fail('Should parse priority: $priorityText'),
            (task) => expect(task.priority, equals(expectedPriority)),
          );
        }
      });

      test('should handle confidence score filtering', () async {
        // Arrange - Low confidence response
        const input = 'Ambiguous input with low confidence';
        const lowConfidenceResponse = '''
        {
          "title": "Uncertain task",
          "priority": "medium",
          "confidence": 0.3
        }
        ''';

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response(lowConfidenceResponse, 200));

        // Act
        final result = await claudeParser.parseTask(input);

        // Assert - Should reject low confidence results
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<LowConfidenceFailure>()),
          (task) => fail('Should reject low confidence task'),
        );
      });
    });

    group('AI Parser Performance Tests', () {
      test('should handle concurrent parsing requests', () async {
        // Arrange
        final inputs = List.generate(10, (i) => 'Create task number $i');
        const mockResponse = '''
        {
          "title": "Concurrent task",
          "priority": "medium",
          "confidence": 0.9
        }
        ''';

        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response(mockResponse, 200));

        // Act - Parse multiple tasks concurrently
        final startTime = DateTime.now();
        final results = await Future.wait(
          inputs.map((input) => claudeParser.parseTask(input))
        );
        final endTime = DateTime.now();

        // Assert
        expect(results.every((r) => r.isRight()), isTrue);
        final duration = endTime.difference(startTime);
        expect(duration.inSeconds, lessThan(10)); // Should complete within reasonable time
      });

      test('should handle parsing timeout appropriately', () async {
        // Arrange - Slow response that times out
        const input = 'Task that times out';
        
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 35)); // Exceed timeout
          return http.Response('{"title": "Too late"}', 200);
        });

        // Act
        final result = await claudeParser.parseTask(input);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<TimeoutFailure>()),
          (task) => fail('Should timeout'),
        );
      });
    });
  });
}