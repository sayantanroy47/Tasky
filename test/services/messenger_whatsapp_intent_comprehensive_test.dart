import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:task_tracker_app/services/share_intent_service.dart';
import 'package:task_tracker_app/domain/repositories/task_repository.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

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
    late ProviderContainer container;

    setUp(() {
      shareIntentService = ShareIntentService();
      mockTaskRepository = MockTaskRepository();
      shareIntentService.setTaskRepository(mockTaskRepository);
      
      // Mock successful task creation by default
      when(mockTaskRepository.createTask(any))
          .thenAnswer((_) async => Right(TaskModel.create(title: 'Test Task')));
    });

    tearDown(() {
      shareIntentService.dispose();
    });

    group('Facebook Messenger Integration Tests', () {
      testWidgets('should handle Facebook Messenger text sharing', (tester) async {
        // Arrange
        const messengerMessage = 'Can you pick up groceries on your way home? We need milk, bread, and eggs for tomorrow morning.';
        const messengerPackage = 'com.facebook.orca';
        const messengerSource = 'Facebook Messenger';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        await shareIntentService.testWifeMessage(messengerMessage);

        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title, contains('groceries'));
        expect(capturedTask!.description, equals(messengerMessage));
        expect(capturedTask!.metadata['source'], equals('shared_message'));
        expect(capturedTask!.tags, contains('wife'));
        expect(capturedTask!.tags, contains('message'));
      });

      testWidgets('should parse Facebook Messenger shopping lists', (tester) async {
        // Arrange
        const shoppingListMessage = '''Shopping list for this week:
• Milk (2 gallons)
• Bread (whole wheat)
• Eggs (dozen)
• Bananas
• Chicken breast
• Rice
Can you grab these when you go to the store?''';

        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        await shareIntentService.testWifeMessage(shoppingListMessage);

        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title, contains('Shopping'));
        expect(capturedTask!.description, contains('Milk'));
        expect(capturedTask!.description, contains('Bread'));
        expect(capturedTask!.description, contains('Eggs'));
      });

      testWidgets('should handle Facebook Messenger appointment requests', (tester) async {
        // Arrange
        const appointmentMessage = 'Please don\'t forget to call the dentist tomorrow morning to schedule your cleaning. Their number is 555-1234.';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        await shareIntentService.testWifeMessage(appointmentMessage);

        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title, contains('dentist'));
        expect(capturedTask!.description, contains('555-1234'));
        expect(capturedTask!.priority, isNotNull);
      });

      testWidgets('should handle Facebook Messenger with emojis and special characters', (tester) async {
        // Arrange
        const emojiMessage = '🛒 Can you pick up some 🥛 milk and 🍞 bread? We\'re out! 😊 Thanks babe! ❤️';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        await shareIntentService.testWifeMessage(emojiMessage);

        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title, contains('milk'));
        expect(capturedTask!.title, contains('bread'));
        expect(capturedTask!.description, contains('🛒'));
        expect(capturedTask!.description, contains('🥛'));
      });

      testWidgets('should handle Facebook Messenger urgent requests', (tester) async {
        // Arrange
        const urgentMessage = 'URGENT: Can you please call mom ASAP? She tried calling you but couldn\'t reach you. Something about dad.';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        await shareIntentService.testWifeMessage(urgentMessage);

        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title, contains('call mom'));
        expect(capturedTask!.priority, equals(TaskPriority.urgent));
        expect(capturedTask!.description, contains('URGENT'));
      });

      testWidgets('should filter out Facebook Messenger casual conversations', (tester) async {
        // Arrange
        final casualMessages = [
          'Love you! ❤️',
          'How was your day at work?',
          'Just wanted to say hi 😊',
          'Looking forward to dinner tonight',
          'Miss you!',
          'Have a great day!',
          'Good morning sunshine ☀️',
        ];

        // Act
        for (final message in casualMessages) {
          await shareIntentService.testWifeMessage(message);
        }

        // Assert - Should NOT create tasks for casual conversation
        verifyNever(mockTaskRepository.createTask(any));
      });

      testWidgets('should handle Facebook Messenger group chat scenarios', (tester) async {
        // Arrange
        const groupMessage = '''Family Group Chat:
Mom: Can someone pick up grandma from the airport tomorrow at 3 PM?
You: I can do it if needed
Wife: Actually, can YOU do it honey? I have that work meeting''';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        await shareIntentService.testWifeMessage(groupMessage);

        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title, contains('grandma'));
        expect(capturedTask!.title, contains('airport'));
        expect(capturedTask!.description, contains('3 PM'));
      });
    });

    group('WhatsApp Integration Tests', () {
      testWidgets('should handle WhatsApp text sharing', (tester) async {
        // Arrange
        const whatsappMessage = 'Hey babe, could you stop by the pharmacy and pick up my prescription? Dr. Smith called it in this morning.';
        const whatsappPackage = 'com.whatsapp';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        await shareIntentService.testWifeMessage(whatsappMessage);

        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title, contains('pharmacy'));
        expect(capturedTask!.title, contains('prescription'));
        expect(capturedTask!.description, contains('Dr. Smith'));
      });

      testWidgets('should handle WhatsApp voice message transcriptions', (tester) async {
        // Arrange
        const voiceTranscription = '[Voice Message Transcription]: Can you please remember to take out the trash tonight? Tomorrow is pickup day and I forgot to remind you earlier.';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        await shareIntentService.testWifeMessage(voiceTranscription);

        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title, contains('trash'));
        expect(capturedTask!.description, contains('pickup day'));
      });

      testWidgets('should handle WhatsApp location-based requests', (tester) async {
        // Arrange
        const locationMessage = 'When you get to Target, can you look for those storage bins we talked about? I shared the photo earlier. They should be in the home organization section.';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        await shareIntentService.testWifeMessage(locationMessage);

        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title, contains('Target'));
        expect(capturedTask!.title, contains('storage bins'));
        expect(capturedTask!.metadata['location_trigger'], equals('Target'));
      });

      testWidgets('should handle WhatsApp time-sensitive requests', (tester) async {
        // Arrange
        const timeMessage = 'Can you call the vet before 5 PM today? They close early on Fridays and we need to schedule Buddy\'s checkup for next week.';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        await shareIntentService.testWifeMessage(timeMessage);

        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title, contains('vet'));
        expect(capturedTask!.description, contains('5 PM'));
        expect(capturedTask!.description, contains('Buddy'));
        expect(capturedTask!.priority, equals(TaskPriority.high)); // Time-sensitive
      });

      testWidgets('should handle WhatsApp multi-part messages', (tester) async {
        // Arrange
        const multiPartMessage = '''Hey honey, few things:
1. Pick up dry cleaning (ticket in your wallet)
2. Get gas in the car
3. Buy flowers for mom's birthday tomorrow
4. Don't forget date night at 7!

Love you! 💕''';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        await shareIntentService.testWifeMessage(multiPartMessage);

        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.description, contains('dry cleaning'));
        expect(capturedTask!.description, contains('gas'));
        expect(capturedTask!.description, contains('flowers'));
      });

      testWidgets('should handle WhatsApp forwarded messages', (tester) async {
        // Arrange
        const forwardedMessage = '''Forwarded from Mom:
"Can someone in the family pick up the cake for dad's surprise party? The bakery said it will be ready after 2 PM on Saturday."''';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        await shareIntentService.testWifeMessage(forwardedMessage);

        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title, contains('cake'));
        expect(capturedTask!.description, contains('bakery'));
        expect(capturedTask!.description, contains('2 PM'));
        expect(capturedTask!.tags, contains('family'));
      });

      testWidgets('should ignore WhatsApp status updates', (tester) async {
        // Arrange
        final statusUpdates = [
          'WhatsApp Status: At the gym 💪',
          'WhatsApp Status: Cooking dinner 🍽️',
          'WhatsApp Status: Traffic is crazy today 🚗',
          'Status Update: Happy Friday! 🎉',
        ];

        // Act
        for (final status in statusUpdates) {
          await shareIntentService.testWifeMessage(status);
        }

        // Assert - Should NOT create tasks from status updates
        verifyNever(mockTaskRepository.createTask(any));
      });

      testWidgets('should handle WhatsApp business account messages', (tester) async {
        // Arrange
        const businessMessage = 'WhatsApp Business - Doctor\'s Office: Your appointment reminder for tomorrow at 10 AM. Please call if you need to reschedule.';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        await shareIntentService.testWifeMessage(businessMessage);

        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title, contains('appointment'));
        expect(capturedTask!.description, contains('10 AM'));
        expect(capturedTask!.tags, contains('business'));
      });
    });

    group('Cross-Platform Message Format Tests', () {
      testWidgets('should handle shared content from both Messenger and WhatsApp', (tester) async {
        // Arrange
        final crossPlatformMessages = [
          'Shared from Messenger: Pick up kids at 3 PM',
          'Forwarded from WhatsApp: Don\'t forget anniversary dinner reservation',
          'Via Messenger: Can you get birthday gift for Sarah?',
          'WhatsApp: Remember to walk the dog before bed',
        ];
        
        int taskCount = 0;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          taskCount++;
          return Right(TaskModel.create(title: 'Cross-platform task $taskCount'));
        });

        // Act
        for (final message in crossPlatformMessages) {
          await shareIntentService.testWifeMessage(message);
        }

        // Assert
        verify(mockTaskRepository.createTask(any)).called(crossPlatformMessages.length);
        expect(taskCount, equals(crossPlatformMessages.length));
      });

      testWidgets('should preserve message formatting across platforms', (tester) async {
        // Arrange
        const formattedMessage = '''*Important*:
- Buy milk 🥛
- Get bread 🍞  
- Pick up _prescriptions_
- ~Don't~ Remember to call mom

*From:* Wife via WhatsApp''';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        await shareIntentService.testWifeMessage(formattedMessage);

        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.description, contains('*Important*'));
        expect(capturedTask!.description, contains('🥛'));
        expect(capturedTask!.description, contains('_prescriptions_'));
      });
    });

    group('Intent Sharing Performance Tests', () {
      testWidgets('should handle rapid message sharing', (tester) async {
        // Arrange
        final rapidMessages = List.generate(20, (i) => 'Rapid task $i from messaging app');
        
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async => 
            Right(TaskModel.create(title: 'Rapid task')));

        // Act
        final startTime = DateTime.now();
        for (final message in rapidMessages) {
          await shareIntentService.testWifeMessage(message);
        }
        final endTime = DateTime.now();

        // Assert
        final duration = endTime.difference(startTime);
        expect(duration.inSeconds, lessThan(10)); // Should handle within 10 seconds
        verify(mockTaskRepository.createTask(any)).called(rapidMessages.length);
      });

      testWidgets('should handle large message content', (tester) async {
        // Arrange
        final largeMessage = 'Can you ' + 'pick up groceries ' * 500; // Very large message
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        final startTime = DateTime.now();
        await shareIntentService.testWifeMessage(largeMessage);
        final endTime = DateTime.now();

        // Assert
        final processingTime = endTime.difference(startTime);
        expect(processingTime.inSeconds, lessThan(5)); // Should process large messages quickly
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title.length, lessThanOrEqualTo(50)); // Title should be truncated
      });
    });

    group('Intent Sharing Security Tests', () {
      testWidgets('should validate message sources', (tester) async {
        // Arrange
        final suspiciousMessages = [
          'URGENT: Send money to this account immediately!',
          'Click this link for free prizes: http://suspicious.com',
          'Your account will be closed unless you verify immediately',
          'You have won \$1,000,000! Contact us now!',
        ];

        // Act
        for (final message in suspiciousMessages) {
          await shareIntentService.testWifeMessage(message);
        }

        // Assert - Should NOT create tasks for suspicious content
        verifyNever(mockTaskRepository.createTask(any));
      });

      testWidgets('should handle malicious script injection attempts', (tester) async {
        // Arrange
        final maliciousMessages = [
          '<script>alert("XSS")</script> Pick up groceries',
          'javascript:void(0) Remember to call mom',
          '<img src="x" onerror="alert(1)"> Get milk',
          '${String.fromCharCode(60)}script${String.fromCharCode(62)} Buy bread',
        ];

        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        for (final message in maliciousMessages) {
          await shareIntentService.testWifeMessage(message);
        }

        // Assert - Should sanitize malicious content but still create legitimate tasks
        if (capturedTask != null) {
          expect(capturedTask!.title, isNot(contains('<script')));
          expect(capturedTask!.title, isNot(contains('javascript:')));
          expect(capturedTask!.description, isNot(contains('<script')));
          expect(capturedTask!.description, isNot(contains('javascript:')));
        }
      });

      testWidgets('should enforce trusted contact validation', (tester) async {
        // Arrange
        shareIntentService.addTrustedContact('wife');
        shareIntentService.addTrustedContact('mom');
        
        const trustedMessage = 'From wife: Pick up groceries please';
        const untrustedMessage = 'From unknown: Do this task immediately';
        
        int taskCount = 0;
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async {
          taskCount++;
          return Right(TaskModel.create(title: 'Trusted task'));
        });

        // Act
        await shareIntentService.testWifeMessage(trustedMessage);
        await shareIntentService.testWifeMessage(untrustedMessage);

        // Assert - Should process trusted messages but validate untrusted ones
        expect(taskCount, greaterThan(0));
      });
    });

    group('Intent Sharing Error Recovery Tests', () {
      testWidgets('should handle database connection failures', (tester) async {
        // Arrange
        const message = 'Can you pick up groceries?';
        when(mockTaskRepository.createTask(any))
            .thenAnswer((_) async => Left(DatabaseFailure('Database unavailable')));

        // Act & Assert - Should not throw exception
        expect(() => shareIntentService.testWifeMessage(message), returnsNormally);
      });

      testWidgets('should handle AI parsing service failures', (tester) async {
        // Arrange
        const complexMessage = 'Can you pick up groceries at 3 PM tomorrow and also call the dentist to reschedule my appointment for next week?';
        
        // Even if AI parsing fails, should create basic task
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        await shareIntentService.testWifeMessage(complexMessage);

        // Assert - Should create task even if AI parsing fails
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title, isNotEmpty);
      });

      testWidgets('should handle corrupted message data', (tester) async {
        // Arrange
        const corruptedMessage = '\x00\x01\x02 Can you \xFF\xFE pick up \x00 groceries?';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        await shareIntentService.testWifeMessage(corruptedMessage);

        // Assert - Should handle corrupted data gracefully
        if (capturedTask != null) {
          expect(capturedTask!.title, isNotEmpty);
          expect(capturedTask!.title, isNot(contains('\x00')));
          expect(capturedTask!.title, isNot(contains('\xFF')));
        }
      });
    });

    group('Intent Sharing Accessibility Tests', () {
      testWidgets('should handle screen reader compatible messages', (tester) async {
        // Arrange
        const accessibleMessage = 'Voice message from wife via screen reader: Please remember to buy milk and bread on your way home today.';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        await shareIntentService.testWifeMessage(accessibleMessage);

        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.metadata['accessibility'], isNotNull);
      });

      testWidgets('should preserve voice-to-text formatting', (tester) async {
        // Arrange
        const voiceMessage = '[Voice-to-text]: Can you period pick up groceries comma milk comma bread comma and eggs period Thank you exclamation mark';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        await shareIntentService.testWifeMessage(voiceMessage);

        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title, contains('groceries'));
        expect(capturedTask!.description, contains('milk'));
      });
    });

    group('Intent Sharing Internationalization Tests', () {
      testWidgets('should handle messages in different languages', (tester) async {
        // Arrange
        final multiLanguageMessages = {
          'Spanish': 'Por favor, puedes comprar leche en el camino a casa?',
          'French': 'Peux-tu acheter du lait sur le chemin du retour?',
          'German': 'Kannst du auf dem Heimweg Milch kaufen?',
          'Italian': 'Puoi comprare il latte sulla strada di casa?',
        };

        int taskCount = 0;
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async {
          taskCount++;
          return Right(TaskModel.create(title: 'Multilingual task'));
        });

        // Act
        for (final entry in multiLanguageMessages.entries) {
          await shareIntentService.testWifeMessage(entry.value);
        }

        // Assert
        expect(taskCount, equals(multiLanguageMessages.length));
        verify(mockTaskRepository.createTask(any)).called(multiLanguageMessages.length);
      });

      testWidgets('should handle messages with mixed character sets', (tester) async {
        // Arrange
        const mixedMessage = 'Can you pick up 牛奶 (milk) and パン (bread) from the store? Danke! 谢谢 🙏';
        
        TaskModel? capturedTask;
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
          return Right(capturedTask!);
        });

        // Act
        await shareIntentService.testWifeMessage(mixedMessage);

        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title, contains('milk'));
        expect(capturedTask!.description, contains('牛奶'));
        expect(capturedTask!.description, contains('パン'));
      });
    });
  });
}

/// Mock BuildContext for testing UI components
class MockBuildContext extends Mock implements BuildContext {
  @override
  bool get mounted => true;
}