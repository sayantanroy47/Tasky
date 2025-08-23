import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:task_tracker_app/domain/models/audio_models.dart';
import 'package:task_tracker_app/presentation/pages/voice_only_creation_page.dart';
import 'package:task_tracker_app/presentation/providers/audio_providers.dart';
import 'package:task_tracker_app/services/audio/audio_recording_service.dart';
import 'package:task_tracker_app/services/audio/audio_concatenation_service.dart';

class MockAudioRecordingService extends Mock implements AudioRecordingService {}
class MockAudioConcatenationService extends Mock implements AudioConcatenationService {}

void main() {
  group('VoiceOnlyCreationPage Advanced Features', () {
    late MockAudioRecordingService mockAudioRecordingService;
    late MockAudioConcatenationService mockConcatenationService;

    setUp(() {
      mockAudioRecordingService = MockAudioRecordingService();
      mockConcatenationService = MockAudioConcatenationService();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          audioRecordingServiceProvider.overrideWithValue(mockAudioRecordingService),
        ],
        child: const MaterialApp(
          home: VoiceOnlyCreationPage(),
        ),
      );
    }

    group('Basic UI Elements', () {
      testWidgets('shows initial recording interface', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Voice Note'), findsOneWidget);
        expect(find.text('Tap to record your voice note'), findsOneWidget);
        expect(find.byIcon(Icons.mic), findsOneWidget);
      });

      testWidgets('shows file settings section', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('File Settings'), findsOneWidget);
        expect(find.text('Custom filename'), findsOneWidget);
        expect(find.text('Audio Quality'), findsOneWidget);
      });

      testWidgets('can set custom filename', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final filenameField = find.byType(TextFormField).first;
        await tester.enterText(filenameField, 'My Custom Recording');
        await tester.pumpAndSettle();

        expect(find.text('My Custom Recording'), findsOneWidget);
      });

      testWidgets('can select audio quality', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Tap audio quality dropdown
        await tester.tap(find.byType(DropdownButtonFormField<AudioQuality>));
        await tester.pumpAndSettle();

        // Select ultra quality
        await tester.tap(find.text('Ultra Quality (320kbps)'));
        await tester.pumpAndSettle();

        // Verify selection (dropdown should show selected value)
        expect(find.text('Ultra Quality (320kbps)'), findsOneWidget);
      });
    });

    group('Basic Recording Functionality', () {
      testWidgets('starts recording when microphone is tapped', (tester) async {
        when(mockAudioRecordingService.startRecording())
            .thenAnswer((_) async => '/temp/recording_path.aac');
        when(mockAudioRecordingService.stopRecording())
            .thenAnswer((_) async => '/path/to/audio1.aac');

        await tester.pumpWidget(createTestWidget());

        // Start recording
        await tester.tap(find.byIcon(Icons.mic));
        await tester.pump();

        expect(find.text('Recording voice note...'), findsOneWidget);
        verify(mockAudioRecordingService.startRecording()).called(1);
      });

      testWidgets('stops recording and shows ready state', (tester) async {
        when(mockAudioRecordingService.startRecording())
            .thenAnswer((_) async => '/temp/recording_path.aac');
        when(mockAudioRecordingService.stopRecording())
            .thenAnswer((_) async => '/path/to/audio1.aac');

        await tester.pumpWidget(createTestWidget());

        // Start recording
        await tester.tap(find.byIcon(Icons.mic));
        await tester.pump();

        // Stop recording
        await tester.tap(find.byIcon(Icons.stop));
        await tester.pumpAndSettle();

        expect(find.text('Voice note ready to save'), findsOneWidget);
        verify(mockAudioRecordingService.stopRecording()).called(1);
      });

      testWidgets('shows audio segments after recording', (tester) async {
        when(mockAudioRecordingService.startRecording())
            .thenAnswer((_) async => '/temp/recording_path.aac');
        when(mockAudioRecordingService.stopRecording())
            .thenAnswer((_) async => '/path/to/audio1.aac');

        await tester.pumpWidget(createTestWidget());

        // Create first segment
        await tester.tap(find.byIcon(Icons.mic));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.stop));
        await tester.pumpAndSettle();

        expect(find.text('Audio Segments (1)'), findsOneWidget);
        expect(find.text('Segment 1'), findsOneWidget);
      });
    });

    group('Playback Controls', () {
      testWidgets('shows playback controls after recording', (tester) async {
        when(mockAudioRecordingService.startRecording())
            .thenAnswer((_) async => '/temp/recording_path.aac');
        when(mockAudioRecordingService.stopRecording())
            .thenAnswer((_) async => '/path/to/audio1.aac');

        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.byIcon(Icons.mic));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.stop));
        await tester.pumpAndSettle();

        expect(find.text('Playback Controls'), findsOneWidget);
        expect(find.text('Speed: '), findsOneWidget);
        expect(find.text('0.5x'), findsOneWidget);
        expect(find.text('1.0x'), findsOneWidget);
        expect(find.text('1.5x'), findsOneWidget);
        expect(find.text('2.0x'), findsOneWidget);
      });

      testWidgets('shows play button initially', (tester) async {
        when(mockAudioRecordingService.startRecording())
            .thenAnswer((_) async => '/temp/recording_path.aac');
        when(mockAudioRecordingService.stopRecording())
            .thenAnswer((_) async => '/path/to/audio1.aac');

        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.byIcon(Icons.mic));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.stop));
        await tester.pumpAndSettle();

        // Initially shows "Play"
        expect(find.text('Play'), findsOneWidget);
      });

      testWidgets('can change playback speed', (tester) async {
        when(mockAudioRecordingService.startRecording())
            .thenAnswer((_) async => '/temp/recording_path.aac');
        when(mockAudioRecordingService.stopRecording())
            .thenAnswer((_) async => '/path/to/audio1.aac');

        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.byIcon(Icons.mic));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.stop));
        await tester.pumpAndSettle();

        // Test speed selection
        await tester.tap(find.text('1.5x'));
        await tester.pumpAndSettle();

        // Verify 1.5x is selected
        final speedChip = tester.widget<ChoiceChip>(
          find.descendant(
            of: find.text('1.5x'),
            matching: find.byType(ChoiceChip),
          ),
        );
        expect(speedChip.selected, isTrue);
      });
    });

    group('Task Creation', () {
      testWidgets('creates task with single segment', (tester) async {
        when(mockAudioRecordingService.startRecording())
            .thenAnswer((_) async => '/temp/recording_path.aac');
        when(mockAudioRecordingService.stopRecording())
            .thenAnswer((_) async => '/path/to/audio1.aac');

        await tester.pumpWidget(createTestWidget());

        // Record single segment
        await tester.tap(find.byIcon(Icons.mic));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.stop));
        await tester.pumpAndSettle();

        // Set title and create task
        await tester.enterText(find.byType(TextFormField).last, 'Test Voice Task');
        await tester.tap(find.text('Create Voice Note'));
        await tester.pumpAndSettle();

        // Verify task creation process was initiated
        // Note: This would require mocking the task provider
      });

      testWidgets('updates task title when filename changes', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Change custom filename
        final filenameField = find.byType(TextFormField).first;
        await tester.enterText(filenameField, 'Meeting Notes');
        await tester.pumpAndSettle();

        // Check that title field is updated
        final titleField = find.byType(TextFormField).last;
        final titleWidget = tester.widget<TextFormField>(titleField);
        expect(titleWidget.controller?.text, equals('Meeting Notes'));
      });
    });

    group('Error Handling', () {
      testWidgets('handles recording errors gracefully', (tester) async {
        when(mockAudioRecordingService.startRecording())
            .thenThrow(Exception('Microphone not available'));

        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.byIcon(Icons.mic));
        await tester.pumpAndSettle();

        expect(find.textContaining('Failed to start recording'), findsOneWidget);
      });
    });
  });
}