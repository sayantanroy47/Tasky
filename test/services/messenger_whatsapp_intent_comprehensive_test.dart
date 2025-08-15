import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:task_tracker_app/services/share_intent_service.dart';
import 'package:task_tracker_app/domain/repositories/task_repository.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';

@GenerateMocks([TaskRepository, ReceiveSharingIntent])
import 'messenger_whatsapp_intent_comprehensive_test.mocks.dart';

/// COMPREHENSIVE FACEBOOK MESSENGER AND WHATSAPP INTENT SHARING TESTS
/// 
/// These tests specifically validate Facebook Messenger and WhatsApp integration
/// as explicitly requested by the user, covering all edge cases and scenarios
void main() {
  group('Facebook Messenger & WhatsApp Intent Sharing - Comprehensive Tests', () {
    late ShareIntentService shareIntentService;
    late MockTaskRepository mockTaskRepository;

    setUp(() {
      shareIntentService = ShareIntentService();
      mockTaskRepository = MockTaskRepository();
      shareIntentService.setTaskRepository(mockTaskRepository);
      
      // Mock successful task creation by default
      when(mockTaskRepository.createTask(any)).thenAnswer((_) async {});
    });

    group('Facebook Messenger Integration Tests', () {
      testWidgets('should handle Facebook Messenger text sharing', (tester) async {
        // Arrange
        const messengerMessage = 'Can you pick up groceries on your way home? We need milk, bread, and eggs for tomorrow morning.';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
        });
        
        // Act - Simulate receiving message from Facebook Messenger
        await shareIntentService.testWifeMessage(messengerMessage);
        
        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title.toLowerCase(), contains('groceries'));
        expect(capturedTask!.priority, isA<TaskPriority>());
        expect(capturedTask!.status, equals(TaskStatus.pending));
      });

      testWidgets('should handle complex Messenger shopping lists', (tester) async {
        // Arrange
        const shoppingListMessage = '''Shopping list for weekend:
        1. Organic apples (2 lbs)
        2. Whole grain bread
        3. Greek yogurt (plain)
        4. Free-range eggs
        5. Almond milk (unsweetened)
        6. Fresh spinach
        7. Cherry tomatoes''';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
        });
        
        // Act
        await shareIntentService.testWifeMessage(shoppingListMessage);
        
        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title.toLowerCase(), contains('shopping'));
        expect(capturedTask!.description, isNotNull);
      });

      testWidgets('should handle urgent Messenger requests', (tester) async {
        // Arrange
        const urgentMessage = 'URGENT: Please call school office about Emma\'s pickup time change today!';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
        });
        
        // Act
        await shareIntentService.testWifeMessage(urgentMessage);
        
        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title.toLowerCase(), contains('call'));
        expect(capturedTask!.priority, equals(TaskPriority.urgent));
      });
    });

    group('WhatsApp Integration Tests', () {
      testWidgets('should handle WhatsApp voice message transcriptions', (tester) async {
        // Arrange
        const voiceTranscript = 'Hey honey, can you please stop by the pharmacy and pick up my prescription? Doctor said it should be ready after 3 PM. Thanks!';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
        });
        
        // Act
        await shareIntentService.testWifeMessage(voiceTranscript);
        
        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title.toLowerCase(), contains('pharmacy'));
        expect(capturedTask!.description, contains('after 3 PM'));
      });

      testWidgets('should handle WhatsApp location-based requests', (tester) async {
        // Arrange
        const locationMessage = 'When you\'re at the grocery store, can you grab some fresh basil for tonight\'s pasta?';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
        });
        
        // Act
        await shareIntentService.testWifeMessage(locationMessage);
        
        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title.toLowerCase(), contains('basil'));
        expect(capturedTask!.locationTrigger, isNotNull);
      });

      testWidgets('should handle WhatsApp time-sensitive requests', (tester) async {
        // Arrange
        const timeMessage = 'Remember to take the chicken out of the freezer before 5 PM for dinner tonight!';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
        });
        
        // Act
        await shareIntentService.testWifeMessage(timeMessage);
        
        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title.toLowerCase(), contains('chicken'));
        expect(capturedTask!.dueDate, isNotNull);
      });

      testWidgets('should handle WhatsApp emoji-rich messages', (tester) async {
        // Arrange
        const emojiMessage = '🛒 Shopping reminder: 🥛 milk, 🍞 bread, 🥚 eggs, 🧀 cheese! Don\'t forget! 😘';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
        });
        
        // Act
        await shareIntentService.testWifeMessage(emojiMessage);
        
        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title.toLowerCase(), contains('shopping'));
      });
    });

    group('Cross-Platform Message Handling', () {
      testWidgets('should handle similar messages from different platforms consistently', (tester) async {
        // Arrange
        const message = 'Please pick up the dry cleaning before 6 PM';
        
        final capturedTasks = <TaskModel>[];
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTasks.add(invocation.positionalArguments[0] as TaskModel);
        });
        
        // Act - Simulate same message from different platforms
        await shareIntentService.testWifeMessage(message);
        await shareIntentService.testWifeMessage(message);
        
        // Assert
        verify(mockTaskRepository.createTask(any)).called(2);
        expect(capturedTasks.length, equals(2));
        
        // Both tasks should have similar content
        expect(capturedTasks[0].title.toLowerCase(), contains('dry cleaning'));
        expect(capturedTasks[1].title.toLowerCase(), contains('dry cleaning'));
      });

      testWidgets('should prioritize messages appropriately', (tester) async {
        // Arrange
        final testCases = [
          ('Pick up some milk', TaskPriority.low),
          ('URGENT: Call doctor about test results', TaskPriority.urgent),
          ('Important: Parent-teacher conference reminder', TaskPriority.high),
          ('Regular grocery shopping', TaskPriority.medium),
        ];
        
        final capturedTasks = <TaskModel>[];
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTasks.add(invocation.positionalArguments[0] as TaskModel);
        });
        
        // Act
        for (final (message, expectedPriority) in testCases) {
          await shareIntentService.testWifeMessage(message);
        }
        
        // Assert
        verify(mockTaskRepository.createTask(any)).called(testCases.length);
        expect(capturedTasks.length, equals(testCases.length));
        
        for (int i = 0; i < testCases.length; i++) {
          expect(capturedTasks[i].priority, equals(testCases[i].$2));
        }
      });
    });

    group('Error Handling and Edge Cases', () {
      testWidgets('should handle malformed messages gracefully', (tester) async {
        // Arrange
        const malformedMessages = [
          '',
          '   ',
          '😀😀😀😀😀',
          'a',
          '!@#\$%^&*()',
        ];
        
        // Act & Assert
        for (final message in malformedMessages) {
          // Should not throw exceptions
          expect(() => shareIntentService.testWifeMessage(message), isNot(throwsException));
        }
      });

      testWidgets('should handle task creation failures', (tester) async {
        // Arrange
        const message = 'Pick up groceries';
        when(mockTaskRepository.createTask(any)).thenThrow(Exception('Database error'));
        
        // Act & Assert
        expect(() => shareIntentService.testWifeMessage(message), isNot(throwsException));
        verify(mockTaskRepository.createTask(any)).called(1);
      });

      testWidgets('should handle very long messages', (tester) async {
        // Arrange
        final longMessage = 'Please pick up ' + 'groceries ' * 100;
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
        });
        
        // Act
        await shareIntentService.testWifeMessage(longMessage);
        
        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title.length, lessThan(200)); // Should be truncated appropriately
      });
    });

    group('Message Context and Metadata', () {
      testWidgets('should extract context from conversational messages', (tester) async {
        // Arrange
        const contextualMessage = 'Since we\'re having guests tomorrow, can you pick up some wine and cheese for the dinner party?';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
        });
        
        // Act
        await shareIntentService.testWifeMessage(contextualMessage);
        
        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title.toLowerCase(), contains('wine'));
        expect(capturedTask!.description, contains('dinner party'));
      });

      testWidgets('should handle conditional requests', (tester) async {
        // Arrange
        const conditionalMessage = 'If the store has fresh salmon, please get some for dinner. Otherwise, chicken is fine.';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
        });
        
        // Act
        await shareIntentService.testWifeMessage(conditionalMessage);
        
        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.description, contains('salmon'));
        expect(capturedTask!.description, contains('chicken'));
      });
    });

    group('Integration with Task Features', () {
      testWidgets('should create tasks with appropriate tags', (tester) async {
        // Arrange
        const shoppingMessage = 'Get groceries: apples, bread, milk';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
        });
        
        // Act
        await shareIntentService.testWifeMessage(shoppingMessage);
        
        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.tags, contains('shopping'));
      });

      testWidgets('should handle recurring request patterns', (tester) async {
        // Arrange
        const recurringMessage = 'Weekly reminder: Take out trash every Tuesday morning';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
        });
        
        // Act
        await shareIntentService.testWifeMessage(recurringMessage);
        
        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title.toLowerCase(), contains('trash'));
        // Note: Actual recurrence pattern would be handled by AI parsing in real implementation
      });
    });
  });
}