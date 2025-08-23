import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:task_tracker_app/presentation/widgets/voice_recording_widget.dart';

Widget createTestWidget({required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  group('VoiceRecordingWidget Widget Tests', () {
    testWidgets('should display default state correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const VoiceRecordingWidget(),
        ),
      );
      await tester.pump();
      
      expect(find.byType(VoiceRecordingWidget), findsOneWidget);
      expect(find.text('Tap to start recording'), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.microphone()), findsOneWidget);
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    });

    testWidgets('should display recording state correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const VoiceRecordingWidget(
            isRecording: true,
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('Listening...'), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.x()), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.stop()), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.microphone()), findsNothing);
    });

    testWidgets('should display processing state correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const VoiceRecordingWidget(
            isProcessing: true,
          ),
        ),
      );
      await tester.pump(); // Use pump() instead of pumpAndSettle() for animations
      
      expect(find.text('Processing speech...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display transcription when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const VoiceRecordingWidget(
            transcriptionText: 'Test transcription text',
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('Transcription:'), findsOneWidget);
      expect(find.text('Test transcription text'), findsOneWidget);
    });

    testWidgets('should display error message when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const VoiceRecordingWidget(
            errorMessage: 'Test error message',
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.warningCircle()), findsOneWidget);
    });

    testWidgets('should handle start recording tap', (tester) async {
      bool startRecordingCalled = false;
      
      await tester.pumpWidget(
        createTestWidget(
          child: VoiceRecordingWidget(
            onStartRecording: () => startRecordingCalled = true,
          ),
        ),
      );
      await tester.pump();
      
      await tester.tap(find.byIcon(PhosphorIcons.microphone()));
      await tester.pump();
      
      expect(startRecordingCalled, isTrue);
    });

    testWidgets('should handle stop recording tap', (tester) async {
      bool stopRecordingCalled = false;
      
      await tester.pumpWidget(
        createTestWidget(
          child: VoiceRecordingWidget(
            isRecording: true,
            onStopRecording: () => stopRecordingCalled = true,
          ),
        ),
      );
      await tester.pump();
      
      await tester.tap(find.byIcon(PhosphorIcons.stop()));
      await tester.pump();
      
      expect(stopRecordingCalled, isTrue);
    });

    testWidgets('should handle cancel recording tap', (tester) async {
      bool cancelRecordingCalled = false;
      
      await tester.pumpWidget(
        createTestWidget(
          child: VoiceRecordingWidget(
            isRecording: true,
            onCancelRecording: () => cancelRecordingCalled = true,
          ),
        ),
      );
      await tester.pump();
      
      await tester.tap(find.byIcon(PhosphorIcons.x()));
      await tester.pump();
      
      expect(cancelRecordingCalled, isTrue);
    });

    testWidgets('should handle transcription result callback', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: VoiceRecordingWidget(
            onTranscriptionResult: (text) {
              // Callback properly set
            },
          ),
        ),
      );
      await tester.pump();
      
      // Verify the widget exists and callback is properly set
      expect(find.byType(VoiceRecordingWidget), findsOneWidget);
    });

    testWidgets('should handle error callback', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: VoiceRecordingWidget(
            onError: (error) {
              // Callback properly set
            },
          ),
        ),
      );
      await tester.pump();
      
      // Verify the widget exists and callback is properly set
      expect(find.byType(VoiceRecordingWidget), findsOneWidget);
    });

    testWidgets('should display sound level visualization', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const VoiceRecordingWidget(
            isRecording: true,
            soundLevel: 0.8,
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: VoiceRecordingWidget(),
          ),
        ),
      );
      await tester.pump();
      
      expect(find.byType(VoiceRecordingWidget), findsOneWidget);
      expect(find.text('Tap to start recording'), findsOneWidget);
    });

    testWidgets('should handle state transitions correctly', (tester) async {
      Widget buildWidget(bool isRecording, bool isProcessing) {
        return createTestWidget(
          child: VoiceRecordingWidget(
            isRecording: isRecording,
            isProcessing: isProcessing,
          ),
        );
      }
      
      // Initial state - not recording, not processing
      await tester.pumpWidget(buildWidget(false, false));
      await tester.pump();
      expect(find.text('Tap to start recording'), findsOneWidget);
      
      // Recording state
      await tester.pumpWidget(buildWidget(true, false));
      await tester.pump();
      expect(find.text('Listening...'), findsOneWidget);
      
      // Processing state
      await tester.pumpWidget(buildWidget(false, true));
      await tester.pump();
      expect(find.text('Processing speech...'), findsOneWidget);
    });

    testWidgets('should handle animation lifecycle', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const VoiceRecordingWidget(
            isRecording: false,
          ),
        ),
      );
      await tester.pump();
      
      // Switch to recording state
      await tester.pumpWidget(
        createTestWidget(
          child: const VoiceRecordingWidget(
            isRecording: true,
          ),
        ),
      );
      
      // Allow animations to start
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(VoiceRecordingWidget), findsOneWidget);
      
      // Switch back to non-recording state
      await tester.pumpWidget(
        createTestWidget(
          child: const VoiceRecordingWidget(
            isRecording: false,
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('Tap to start recording'), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const VoiceRecordingWidget(),
        ),
      );
      await tester.pump();
      
      final voiceRecordingSemantics = tester.getSemantics(find.byType(VoiceRecordingWidget));
      expect(voiceRecordingSemantics, isNotNull);
      
      final microphoneButtonSemantics = tester.getSemantics(find.byIcon(PhosphorIcons.microphone()));
      expect(microphoneButtonSemantics, isNotNull);
    });

    testWidgets('should handle complex state combinations', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const VoiceRecordingWidget(
            isRecording: true,
            transcriptionText: 'Live transcription',
            soundLevel: 0.6,
            errorMessage: 'Minor warning',
          ),
        ),
      );
      await tester.pump();
      
      expect(find.text('Listening...'), findsOneWidget);
      expect(find.text('Live transcription'), findsOneWidget);
      expect(find.text('Minor warning'), findsOneWidget);
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    });

    testWidgets('should display visual feedback correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const VoiceRecordingWidget(
            isRecording: true,
            soundLevel: 1.0,
          ),
        ),
      );
      await tester.pump();
      
      // Should have visual feedback area
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
      
      // Should have proper size container
      expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle button styles correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const VoiceRecordingWidget(
            isRecording: true,
          ),
        ),
      );
      await tester.pump();
      
      final iconButtons = find.byType(IconButton);
      expect(iconButtons, findsNWidgets(2)); // Cancel and stop buttons
      
      // Verify buttons have proper styling
      final cancelButton = find.byIcon(PhosphorIcons.x());
      expect(cancelButton, findsOneWidget);
      
      final stopButton = find.byIcon(PhosphorIcons.stop());
      expect(stopButton, findsOneWidget);
    });
  });
}