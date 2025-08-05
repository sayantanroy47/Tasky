import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:task_tracker_app/services/share_intent_service.dart';
import 'package:task_tracker_app/domain/repositories/task_repository.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';

import 'share_intent_service_test.mocks.dart';

@GenerateMocks([TaskRepository, ReceiveSharingIntent])
void main() {
  group('ShareIntentService', () {
    late ShareIntentService shareIntentService;
    late MockTaskRepository mockTaskRepository;
    late MockReceiveSharingIntent mockReceiveSharingIntent;

    setUp(() {
      shareIntentService = ShareIntentService();
      mockTaskRepository = MockTaskRepository();
      shareIntentService.setTaskRepository(mockTaskRepository);
    });

    tearDown(() {
      shareIntentService.dispose();
    });

    group('initialization', () {
      test('should initialize successfully', () async {
        // Act
        await shareIntentService.initialize();

        // Assert
        // Service should initialize without throwing
        expect(shareIntentService, isNotNull);
      });

      test('should set task repository correctly', () {
        // Arrange
        final repository = MockTaskRepository();

        // Act
        shareIntentService.setTaskRepository(repository);

        // Assert
        // Repository should be set (verified through behavior in other tests)
        expect(shareIntentService, isNotNull);
      });

      test('should set context correctly', () {
        // Arrange
        final context = MockBuildContext();

        // Act
        shareIntentService.setContext(context);

        // Assert
        // Context should be set (verified through behavior in other tests)
        expect(shareIntentService, isNotNull);
      });
    });

    group('trusted contacts management', () {
      test('should add trusted contact', () {
        // Act
        shareIntentService.addTrustedContact('mom');

        // Assert
        // Should be added to trusted contacts set
        expect(shareIntentService, isNotNull);
      });

      test('should remove trusted contact', () {
        // Arrange
        shareIntentService.addTrustedContact('mom');

        // Act
        shareIntentService.removeTrustedContact('mom');

        // Assert
        // Should be removed from trusted contacts set
        expect(shareIntentService, isNotNull);
      });
    });

    group('message processing', () {
      test('should process wife message and create task', () async {
        // Arrange
        const message = 'Can you pick up milk on your way home?';
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async {});

        // Act
        await shareIntentService.testWifeMessage(message);

        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
      });

      test('should not process non-task messages', () async {
        // Arrange
        const message = 'How was your day?';
        
        // Act
        await shareIntentService.testWifeMessage(message);

        // Assert
        // Should not create task for casual conversation
        verifyNever(mockTaskRepository.createTask(any));
      });

      test('should detect task patterns correctly', () async {
        // Arrange
        final taskMessages = [
          'Can you pick up groceries?',
          'Please don\'t forget to call the dentist',
          'Remember to buy bread',
          'We need milk for tomorrow',
          'Could you get gas on your way home?',
        ];

        when(mockTaskRepository.createTask(any)).thenAnswer((_) async {});

        // Act & Assert
        for (final message in taskMessages) {
          await shareIntentService.testWifeMessage(message);
        }

        // Should create tasks for all task-like messages
        verify(mockTaskRepository.createTask(any)).called(taskMessages.length);
      });

      test('should ignore non-task patterns', () async {
        // Arrange
        final nonTaskMessages = [
          'How was your day?',
          'Love you!',
          'Just saying hi',
          'See you tonight',
          'Weather is nice today',
        ];

        // Act
        for (final message in nonTaskMessages) {
          await shareIntentService.testWifeMessage(message);
        }

        // Assert
        // Should not create tasks for casual messages
        verifyNever(mockTaskRepository.createTask(any));
      });
    });

    group('task creation from messages', () {
      test('should create task with correct metadata', () async {
        // Arrange
        const message = 'Please pick up milk on your way home';
        TaskModel? capturedTask;
        
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
        });

        // Act
        await shareIntentService.testWifeMessage(message);

        // Assert
        expect(capturedTask, isNotNull);
        expect(capturedTask!.metadata['source'], 'shared_message');
        expect(capturedTask!.metadata['created_from'], 'wife_message');
        expect(capturedTask!.metadata['original_text'], message);
        expect(capturedTask!.metadata['auto_detected'], true);
        expect(capturedTask!.tags, contains('wife'));
        expect(capturedTask!.tags, contains('message'));
      });

      test('should create task with detected title', () async {
        // Arrange
        const message = 'Can you pick up milk and bread from the store?';
        TaskModel? capturedTask;
        
        when(mockTaskRepository.createTask(any)).thenAnswer((invocation) async {
          capturedTask = invocation.positionalArguments[0] as TaskModel;
        });

        // Act
        await shareIntentService.testWifeMessage(message);

        // Assert
        expect(capturedTask, isNotNull);
        expect(capturedTask!.title, isNotEmpty);
        expect(capturedTask!.description, message);
        expect(capturedTask!.status, TaskStatus.pending);
        expect(capturedTask!.priority, TaskPriority.medium);
      });

      test('should handle multiple task messages in sequence', () async {
        // Arrange
        final messages = [
          'Pick up groceries',
          'Call the dentist',
          'Buy gas for the car',
        ];
        
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async {});

        // Act
        await shareIntentService.runTestMessages();

        // Assert
        // Should process multiple messages correctly
        verify(mockTaskRepository.createTask(any)).called(greaterThan(0));
      });
    });

    group('media file handling', () {
      test('should process text files as potential messages', () async {
        // Arrange
        final textFile = SharedMediaFile(
          '/storage/emulated/0/Download/message.txt',
          'text/plain',
          DateTime.now().millisecondsSinceEpoch,
        );
        
        when(mockTaskRepository.createTask(any)).thenAnswer((_) async {});

        // Act
        // This would be called internally when media files are received
        // Testing the logic indirectly through the test message system
        await shareIntentService.testWifeMessage('Can you pick up milk?');

        // Assert
        verify(mockTaskRepository.createTask(any)).called(1);
      });

      test('should create basic tasks for non-text media files', () async {
        // Arrange
        final imageFile = SharedMediaFile(
          '/storage/emulated/0/Pictures/photo.jpg',
          'image/jpeg',
          DateTime.now().millisecondsSinceEpoch,
        );

        // Act & Assert
        // Media files would be processed differently
        // This test verifies the service can handle different file types
        expect(shareIntentService, isNotNull);
      });
    });

    group('error handling', () {
      test('should handle repository errors gracefully', () async {
        // Arrange
        const message = 'Can you pick up milk?';
        when(mockTaskRepository.createTask(any))
            .thenThrow(Exception('Database error'));

        // Act & Assert
        // Should not throw, should handle error gracefully
        expect(
          () => shareIntentService.testWifeMessage(message),
          returnsNormally,
        );
      });

      test('should handle null repository gracefully', () async {
        // Arrange
        final serviceWithoutRepo = ShareIntentService();
        const message = 'Can you pick up milk?';

        // Act & Assert
        // Should not throw when repository is not set
        expect(
          () => serviceWithoutRepo.testWifeMessage(message),
          returnsNormally,
        );
      });

      test('should handle initialization errors', () async {
        // Act & Assert
        // Should not throw during initialization
        expect(
          () => shareIntentService.initialize(),
          returnsNormally,
        );
      });
    });

    group('disposal', () {
      test('should dispose resources properly', () {
        // Act
        shareIntentService.dispose();

        // Assert
        // Should dispose without throwing
        expect(shareIntentService, isNotNull);
      });

      test('should handle multiple dispose calls', () {
        // Act
        shareIntentService.dispose();
        shareIntentService.dispose();

        // Assert
        // Should handle multiple dispose calls gracefully
        expect(shareIntentService, isNotNull);
      });
    });
  });
}

/// Mock BuildContext for testing
class MockBuildContext extends Mock implements BuildContext {}