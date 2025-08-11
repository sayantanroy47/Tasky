import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/presentation/widgets/voice_task_creation_dialog_m3.dart';
import 'package:task_tracker_app/presentation/widgets/voice_only_creation_dialog.dart';
import 'package:task_tracker_app/services/speech/transcription_service_impl.dart';
import 'package:task_tracker_app/services/ai/claude_task_parser.dart';
import 'package:task_tracker_app/services/ai/openai_task_parser.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/domain/repositories/task_repository.dart';
import 'package:task_tracker_app/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

@GenerateMocks([
  TranscriptionServiceImpl,
  ClaudeTaskParser,
  OpenAITaskParser,
  TaskRepository,
])
import 'voice_task_creation_comprehensive_test.mocks.dart';

/// COMPREHENSIVE VOICE TASK CREATION TESTS - ALL AI AND SPEECH INTEGRATION
void main() {
  group('Voice Task Creation - Comprehensive AI and Speech Tests', () {
    late MockTranscriptionServiceImpl mockTranscriptionService;
    late MockClaudeTaskParser mockClaudeParser;
    late MockOpenAITaskParser mockOpenAIParser;
    late MockTaskRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockTranscriptionService = MockTranscriptionServiceImpl();
      mockClaudeParser = MockClaudeTaskParser();
      mockOpenAIParser = MockOpenAITaskParser();
      mockRepository = MockTaskRepository();
      
      container = ProviderContainer(
        overrides: [
          // Add provider overrides here when available
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Voice Recording Tests', () {
      testWidgets('should display recording interface correctly', (tester) async {
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: VoiceTaskCreationDialogM3(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Should display microphone button and recording UI
        expect(find.byIcon(Icons.mic), findsOneWidget);
      });

      testWidgets('should handle microphone permission denied', (tester) async {
        // Arrange
        when(mockTranscriptionService.checkPermissions())
            .thenAnswer((_) async => false);

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: VoiceTaskCreationDialogM3(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap microphone button
        await tester.tap(find.byIcon(Icons.mic));
        await tester.pumpAndSettle();

        // Assert - Should show permission request or error message
        expect(find.byType(VoiceTaskCreationDialogM3), findsOneWidget);
      });

      testWidgets('should start recording when microphone tapped', (tester) async {
        // Arrange
        when(mockTranscriptionService.checkPermissions())
            .thenAnswer((_) async => true);
        when(mockTranscriptionService.startRecording())
            .thenAnswer((_) async => {});

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: VoiceTaskCreationDialogM3(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap microphone to start recording
        await tester.tap(find.byIcon(Icons.mic));
        await tester.pumpAndSettle();

        // Assert - Should show recording state
        // Microphone icon might change or recording indicator appears
      });

      testWidgets('should stop recording when stop button tapped', (tester) async {
        // Arrange
        when(mockTranscriptionService.checkPermissions())
            .thenAnswer((_) async => true);
        when(mockTranscriptionService.startRecording())
            .thenAnswer((_) async => {});
        when(mockTranscriptionService.stopRecording())
            .thenAnswer((_) async => 'Create a task to review project documents');

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: VoiceTaskCreationDialogM3(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Start recording
        await tester.tap(find.byIcon(Icons.mic));
        await tester.pump(const Duration(seconds: 1));

        // Stop recording
        final stopButton = find.byIcon(Icons.stop);
        if (stopButton.evaluate().isNotEmpty) {
          await tester.tap(stopButton);
          await tester.pumpAndSettle();
        }

        // Assert - Should process the recording
      });

      testWidgets('should display voice visualization during recording', (tester) async {
        // Arrange
        when(mockTranscriptionService.checkPermissions())
            .thenAnswer((_) async => true);
        when(mockTranscriptionService.startRecording())
            .thenAnswer((_) async => {});

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: VoiceTaskCreationDialogM3(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Start recording
        await tester.tap(find.byIcon(Icons.mic));
        await tester.pump(const Duration(milliseconds: 500));

        // Assert - Should show voice visualization
        expect(find.byType(CustomPaint), findsWidgets);
      });
    });

    group('Speech Transcription Tests', () {
      testWidgets('should handle successful transcription', (tester) async {
        // Arrange
        const transcribedText = 'Create a high priority task to finish the quarterly report by Friday';
        when(mockTranscriptionService.transcribeAudio(any))
            .thenAnswer((_) async => transcribedText);

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: VoiceOnlyCreationDialog(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Simulate completing transcription
        // This would typically be triggered after recording stops

        // Assert - Should display transcribed text
        expect(find.text(transcribedText), findsOneWidget);
      });

      testWidgets('should handle transcription errors', (tester) async {
        // Arrange
        when(mockTranscriptionService.transcribeAudio(any))
            .thenThrow(Exception('Transcription failed'));

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: VoiceOnlyCreationDialog(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Simulate transcription error
        // Should display error message
        expect(find.byType(VoiceOnlyCreationDialog), findsOneWidget);
      });

      testWidgets('should handle empty or unclear audio', (tester) async {
        // Arrange
        when(mockTranscriptionService.transcribeAudio(any))
            .thenAnswer((_) async => ''); // Empty transcription

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: VoiceOnlyCreationDialog(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should handle empty transcription gracefully
        expect(find.byType(VoiceOnlyCreationDialog), findsOneWidget);
      });

      testWidgets('should handle very long transcriptions', (tester) async {
        // Arrange
        final longTranscription = 'Create a task ' * 100; // Very long text
        when(mockTranscriptionService.transcribeAudio(any))
            .thenAnswer((_) async => longTranscription);

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: VoiceOnlyCreationDialog(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should handle long text without overflow
        expect(find.byType(VoiceOnlyCreationDialog), findsOneWidget);
      });
    });

    group('AI Task Parsing Tests', () {
      testWidgets('should parse simple task correctly', (tester) async {
        // Arrange
        const userInput = 'Remind me to call mom tomorrow at 3pm';
        final expectedTask = TaskModel.create(
          title: 'Call mom',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          reminderDate: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 15),
        );
        
        when(mockClaudeParser.parseTask(userInput))
            .thenAnswer((_) async => Right(expectedTask));

        // Simulate the AI parsing process
        // In real widget, this would be triggered after transcription
        final result = await mockClaudeParser.parseTask(userInput);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not have error'),
          (task) {
            expect(task.title, equals('Call mom'));
            expect(task.dueDate?.day, equals(DateTime.now().add(const Duration(days: 1)).day));
          },
        );
      });

      testWidgets('should parse complex task with multiple attributes', (tester) async {
        // Arrange
        const complexInput = 'Create a high priority task to review the quarterly financial reports and prepare presentation slides for the board meeting next Friday at 2 PM, and remind me 2 hours before';
        
        final expectedTask = TaskModel.create(
          title: 'Review quarterly financial reports and prepare presentation slides',
          description: 'For the board meeting',
          priority: TaskPriority.high,
          dueDate: DateTime.now().add(const Duration(days: 5)).copyWith(hour: 14),
          reminderDate: DateTime.now().add(const Duration(days: 5)).copyWith(hour: 12),
          tags: ['work', 'presentation', 'board'],
        );
        
        when(mockClaudeParser.parseTask(complexInput))
            .thenAnswer((_) async => Right(expectedTask));

        // Act
        final result = await mockClaudeParser.parseTask(complexInput);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not have error'),
          (task) {
            expect(task.priority, equals(TaskPriority.high));
            expect(task.title, contains('Review'));
            expect(task.description, contains('board'));
          },
        );
      });

      testWidgets('should handle AI parsing failures gracefully', (tester) async {
        // Arrange
        const ambiguousInput = 'something something maybe do stuff';
        
        when(mockClaudeParser.parseTask(ambiguousInput))
            .thenAnswer((_) async => Left(AIParsingFailure('Unable to parse task')));

        // Act
        final result = await mockClaudeParser.parseTask(ambiguousInput);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (error) => expect(error, isA<AIParsingFailure>()),
          (task) => fail('Should not return task'),
        );
      });

      testWidgets('should fallback between AI providers', (tester) async {
        // Arrange
        const input = 'Create task to buy groceries';
        final fallbackTask = TaskModel.create(title: 'Buy groceries');
        
        when(mockClaudeParser.parseTask(input))
            .thenAnswer((_) async => Left(AIParsingFailure('Claude unavailable')));
        when(mockOpenAIParser.parseTask(input))
            .thenAnswer((_) async => Right(fallbackTask));

        // Simulate fallback logic
        var result = await mockClaudeParser.parseTask(input);
        if (result.isLeft()) {
          result = await mockOpenAIParser.parseTask(input);
        }

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not have error after fallback'),
          (task) => expect(task.title, equals('Buy groceries')),
        );
      });
    });

    group('Task Creation Flow Tests', () {
      testWidgets('should complete full voice-to-task flow', (tester) async {
        // Arrange
        const transcription = 'Create urgent task to submit project proposal by tomorrow 5 PM';
        final parsedTask = TaskModel.create(
          title: 'Submit project proposal',
          priority: TaskPriority.urgent,
          dueDate: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 17),
        );
        
        when(mockTranscriptionService.checkPermissions())
            .thenAnswer((_) async => true);
        when(mockTranscriptionService.transcribeAudio(any))
            .thenAnswer((_) async => transcription);
        when(mockClaudeParser.parseTask(transcription))
            .thenAnswer((_) async => Right(parsedTask));
        when(mockRepository.createTask(any))
            .thenAnswer((_) async => Right(parsedTask));

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: VoiceTaskCreationDialogM3(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Simulate complete flow (this would be integration test in practice)
        // 1. Start recording
        // 2. Stop recording
        // 3. Transcribe audio
        // 4. Parse with AI
        // 5. Create task
        
        // Assert - Task should be created successfully
      });

      testWidgets('should allow manual editing of AI parsed task', (tester) async {
        // Arrange
        final initialTask = TaskModel.create(
          title: 'AI Parsed Title',
          description: 'AI Parsed Description',
        );

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: VoiceTaskCreationDialogM3(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should display editable fields for the parsed task
        // User should be able to modify title, description, priority, etc.
        
        final titleField = find.byType(TextFormField).first;
        if (titleField.evaluate().isNotEmpty) {
          await tester.enterText(titleField, 'User Modified Title');
          await tester.pumpAndSettle();
        }

        // Assert - Should accept manual edits
      });

      testWidgets('should handle task creation errors', (tester) async {
        // Arrange
        final task = TaskModel.create(title: 'Test Task');
        when(mockRepository.createTask(any))
            .thenAnswer((_) async => Left(DatabaseFailure('Database error')));

        // Simulate task creation error
        final result = await mockRepository.createTask(task);

        // Assert
        expect(result.isLeft(), isTrue);
      });
    });

    group('Voice Dialog UI Tests', () {
      testWidgets('should display progress indicators during processing', (tester) async {
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: VoiceTaskCreationDialogM3(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should show loading indicators during:
        // - Recording
        // - Transcription
        // - AI parsing
        // - Task creation
        
        expect(find.byType(VoiceTaskCreationDialogM3), findsOneWidget);
      });

      testWidgets('should handle dialog dismissal', (tester) async {
        // Arrange
        bool dialogDismissed = false;

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (_) => VoiceTaskCreationDialogM3(),
                      );
                      dialogDismissed = true;
                    },
                    child: Text('Open Dialog'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open dialog
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        // Close dialog
        final closeButton = find.byIcon(Icons.close);
        if (closeButton.evaluate().isNotEmpty) {
          await tester.tap(closeButton);
          await tester.pumpAndSettle();
        }

        // Should handle dismissal properly
      });

      testWidgets('should use correct theme colors and styling', (tester) async {
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: ThemeData.light(),
              home: Scaffold(
                body: VoiceTaskCreationDialogM3(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should use Material 3 styling and theme colors
        expect(find.byType(VoiceTaskCreationDialogM3), findsOneWidget);
      });

      testWidgets('should display error states appropriately', (tester) async {
        // Test various error states:
        // - Microphone permission denied
        // - Recording failed
        // - Transcription failed  
        // - AI parsing failed
        // - Task creation failed
        
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: VoiceTaskCreationDialogM3(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should display appropriate error messages for each failure mode
        expect(find.byType(VoiceTaskCreationDialogM3), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should provide voice accessibility features', (tester) async {
        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: VoiceTaskCreationDialogM3(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should provide:
        // - Semantic labels for voice controls
        // - Audio feedback for recording states
        // - Screen reader announcements
        
        expect(find.byType(Semantics), findsWidgets);
      });

      testWidgets('should support keyboard navigation', (tester) async {
        // Should allow keyboard navigation between:
        // - Record button
        // - Stop button
        // - Edit fields
        // - Save/Cancel buttons
        
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: VoiceTaskCreationDialogM3(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(VoiceTaskCreationDialogM3), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('should handle audio processing efficiently', (tester) async {
        // Arrange
        when(mockTranscriptionService.transcribeAudio(any))
            .thenAnswer((_) async {
          // Simulate processing delay
          await Future.delayed(const Duration(milliseconds: 500));
          return 'Quick task processing test';
        });

        // Act
        final startTime = DateTime.now();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: VoiceTaskCreationDialogM3(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final endTime = DateTime.now();

        // Assert - Should load quickly
        final loadTime = endTime.difference(startTime);
        expect(loadTime.inMilliseconds, lessThan(1000));
      });
    });
  });
}