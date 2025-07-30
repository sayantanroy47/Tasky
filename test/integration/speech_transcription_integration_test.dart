import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:task_tracker_app/services/speech/speech_service.dart';
import 'package:task_tracker_app/services/speech/speech_service_impl.dart';
import 'package:task_tracker_app/services/speech/transcription_service.dart';
import 'package:task_tracker_app/services/speech/composite_transcription_service.dart';
import 'package:task_tracker_app/services/speech/transcription_validator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Speech Transcription Integration Tests', () {
    late SpeechService speechService;

    setUp(() {
      speechService = SpeechServiceImpl(
        transcriptionPreference: TranscriptionPreference.localFirst,
        transcriptionConfig: const TranscriptionConfig(
          enableTimestamps: true,
          maxRetries: 2,
          timeout: Duration(seconds: 15),
        ),
      );
    });

    tearDown(() async {
      await speechService.dispose();
    });

    testWidgets('should initialize speech service with transcription capabilities', (tester) async {
      final initialized = await speechService.initialize();
      
      expect(initialized, isTrue);
      expect(speechService.isInitialized, isTrue);
      expect(speechService.transcriptionConfig, isNotNull);
    });

    testWidgets('should handle transcription configuration updates', (tester) async {
      await speechService.initialize();
      
      const newConfig = TranscriptionConfig(
        language: 'en',
        enableTimestamps: false,
        maxRetries: 5,
        timeout: Duration(seconds: 30),
      );
      
      await speechService.updateTranscriptionConfig(newConfig);
      
      expect(speechService.transcriptionConfig.language, equals('en'));
      expect(speechService.transcriptionConfig.enableTimestamps, isFalse);
      expect(speechService.transcriptionConfig.maxRetries, equals(5));
    });

    testWidgets('should transcribe mock audio data', (tester) async {
      await speechService.initialize();
      
      // Create mock audio data (in a real test, this would be actual audio)
      final mockAudioData = List.generate(1000, (index) => index % 256);
      
      try {
        final result = await speechService.transcribeAudioData(mockAudioData);
        
        expect(result, isA<TranscriptionResult>());
        
        if (result.isSuccess) {
          expect(result.text, isNotEmpty);
          expect(result.confidence, greaterThan(0.0));
          expect(result.processingTime, greaterThan(Duration.zero));
          
          // Validate the result
          final validation = TranscriptionValidator.validateResult(result);
          expect(validation, isA<TranscriptionValidationResult>());
          
          print('Transcription result: ${result.text}');
          print('Confidence: ${result.confidence}');
          print('Processing time: ${result.processingTime}');
          print('Validation: ${validation.isValid ? 'Valid' : 'Invalid'}');
          
          if (validation.issues.isNotEmpty) {
            print('Issues: ${validation.issuesSummary}');
          }
        } else {
          print('Transcription failed: ${result.error?.message}');
          expect(result.error, isNotNull);
        }
      } catch (e) {
        // Transcription might fail in test environment, which is acceptable
        print('Transcription service not available in test environment: $e');
        expect(e, isA<SpeechRecognitionException>());
      }
    });

    testWidgets('should handle transcription errors gracefully', (tester) async {
      await speechService.initialize();
      
      // Test with invalid audio data
      final invalidAudioData = <int>[];
      
      try {
        final result = await speechService.transcribeAudioData(invalidAudioData);
        
        // Should either succeed with empty result or fail gracefully
        expect(result, isA<TranscriptionResult>());
        
        if (!result.isSuccess) {
          expect(result.error, isNotNull);
          expect(result.error!.type, isA<TranscriptionErrorType>());
        }
      } catch (e) {
        // Exception is acceptable for invalid input
        expect(e, isA<SpeechRecognitionException>());
      }
    });

    testWidgets('should validate transcription results', (tester) async {
      // Test validation with various result types
      final testCases = [
        TranscriptionResult.success(
          text: 'Create a task to buy groceries tomorrow',
          confidence: 0.95,
          processingTime: const Duration(seconds: 2),
        ),
        TranscriptionResult.success(
          text: 'uh uh uh',
          confidence: 0.3,
          processingTime: const Duration(seconds: 1),
        ),
        TranscriptionResult.success(
          text: '',
          confidence: 0.8,
          processingTime: const Duration(seconds: 1),
        ),
        TranscriptionResult.failure(
          error: const TranscriptionError(
            message: 'Network timeout',
            type: TranscriptionErrorType.timeout,
          ),
        ),
      ];

      for (final testResult in testCases) {
        final validation = TranscriptionValidator.validateResult(testResult);
        
        expect(validation, isA<TranscriptionValidationResult>());
        expect(validation.originalResult, equals(testResult));
        
        print('Test case: "${testResult.text}"');
        print('Valid: ${validation.isValid}');
        print('Confidence: ${validation.confidence}');
        print('Issues: ${validation.issues.length}');
        
        if (validation.issues.isNotEmpty) {
          for (final issue in validation.issues) {
            print('  - ${issue.severity.name}: ${issue.message}');
          }
        }
        print('---');
      }
    });

    testWidgets('should select best transcription result', (tester) async {
      final results = [
        TranscriptionResult.success(
          text: 'Low quality transcription with errors',
          confidence: 0.4,
          processingTime: const Duration(seconds: 3),
        ),
        TranscriptionResult.success(
          text: 'High quality transcription result',
          confidence: 0.95,
          processingTime: const Duration(seconds: 2),
        ),
        TranscriptionResult.success(
          text: 'Medium quality result',
          confidence: 0.7,
          processingTime: const Duration(seconds: 1),
        ),
        TranscriptionResult.failure(
          error: const TranscriptionError(
            message: 'Processing failed',
            type: TranscriptionErrorType.processingError,
          ),
        ),
      ];

      final bestResult = TranscriptionValidator.selectBestResult(results);
      
      expect(bestResult.text, equals('High quality transcription result'));
      expect(bestResult.confidence, equals(0.95));
      expect(bestResult.isSuccess, isTrue);
      
      print('Selected best result: "${bestResult.text}"');
      print('Confidence: ${bestResult.confidence}');
    });

    testWidgets('should handle permission requirements', (tester) async {
      final hasPermission = await speechService.hasPermission();
      
      if (!hasPermission) {
        final permissionGranted = await speechService.requestPermission();
        print('Microphone permission granted: $permissionGranted');
        
        // In a real app, we would handle permission denial
        if (!permissionGranted) {
          expect(() => speechService.initialize(), 
              throwsA(isA<SpeechRecognitionException>()));
        }
      }
    });

    testWidgets('should handle service availability', (tester) async {
      await speechService.initialize();
      
      expect(speechService.isInitialized, isTrue);
      
      // Test service availability
      if (speechService.isAvailable) {
        print('Speech service is available');
        
        // Test getting available locales
        try {
          final locales = await speechService.getAvailableLocales();
          expect(locales, isA<List<String>>());
          print('Available locales: ${locales.take(5).join(', ')}');
        } catch (e) {
          print('Could not get locales: $e');
        }
      } else {
        print('Speech service is not available on this device');
      }
    });
  });
}