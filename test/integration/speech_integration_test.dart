
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:task_tracker_app/main.dart' as app;
import 'package:task_tracker_app/services/speech/speech_service.dart';
import 'package:task_tracker_app/services/speech/speech_service_impl.dart';
import 'package:task_tracker_app/services/speech/audio_manager.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Speech Recognition Integration Tests', () {
    testWidgets('Speech service initialization', (WidgetTester tester) async {
      // Initialize the app
      app.main();
      await tester.pumpAndSettle();

      // Create speech service instance
      final speechService = SpeechServiceImpl();

      // Test basic properties
      expect(speechService.isInitialized, false);
      expect(speechService.isAvailable, false);
      expect(speechService.isListening, false);

      // Clean up
      await speechService.dispose();
    });

    testWidgets('Audio manager functionality', (WidgetTester tester) async {
      // Initialize the app
      app.main();
      await tester.pumpAndSettle();

      // Create audio manager instance
      final audioManager = AudioManager();

      // Test file size formatting
      expect(audioManager.formatFileSize(1024), '1.0 KB');
      expect(audioManager.formatFileSize(1024 * 1024), '1.0 MB');

      // Test cleanup operations (should not throw)
      final tempCleanupCount = await audioManager.cleanupTempFiles();
      expect(tempCleanupCount, isA<int>());

      final oldCleanupCount = await audioManager.cleanupOldFiles();
      expect(oldCleanupCount, isA<int>());

      // Test file listing
      final audioFiles = await audioManager.getAllAudioFiles();
      expect(audioFiles, isA<List<String>>());

      // Test total size calculation
      final totalSize = await audioManager.getTotalAudioFilesSize();
      expect(totalSize, isA<int>());
    });

    testWidgets('Speech recognition result creation', (WidgetTester tester) async {
      // Test SpeechRecognitionResult creation
      const result = SpeechRecognitionResult(
        recognizedWords: 'test words',
        finalResult: true,
        confidence: 0.95,
      );

      expect(result.recognizedWords, 'test words');
      expect(result.finalResult, true);
      expect(result.confidence, 0.95);
      expect(result.alternativeText, null);

      // Test toString
      final stringRepresentation = result.toString();
      expect(stringRepresentation, contains('test words'));
      expect(stringRepresentation, contains('true'));
      expect(stringRepresentation, contains('0.95'));
    });

    testWidgets('Speech recognition exception handling', (WidgetTester tester) async {
      // Test SpeechRecognitionException creation
      const exception = SpeechRecognitionException(
        'Test error message',
        errorType: 'test_error',
      );

      expect(exception.message, 'Test error message');
      expect(exception.errorType, 'test_error');

      // Test toString
      final stringRepresentation = exception.toString();
      expect(stringRepresentation, contains('Test error message'));
      expect(stringRepresentation, contains('test_error'));
    });
  });
}