import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/services/speech/transcription_service.dart';
import 'package:task_tracker_app/services/speech/local_transcription_service.dart';

import 'package:task_tracker_app/services/speech/composite_transcription_service.dart';
import 'package:task_tracker_app/services/speech/transcription_validator.dart';

void main() {
  group('TranscriptionService', () {
    group('TranscriptionResult', () {
      test('should create successful result', () {
        final result = TranscriptionResult.success(
          text: 'Hello world',
          confidence: 0.95,
          processingTime: const Duration(seconds: 2),
          language: 'en',
        );

        expect(result.isSuccess, isTrue);
        expect(result.text, equals('Hello world'));
        expect(result.confidence, equals(0.95));
        expect(result.language, equals('en'));
        expect(result.error, isNull);
      });

      test('should create failure result', () {
        const error = TranscriptionError(
          message: 'Network error',
          type: TranscriptionErrorType.networkError,
        );
        
        final result = TranscriptionResult.failure(
          error: error,
          processingTime: const Duration(seconds: 1),
        );

        expect(result.isSuccess, isFalse);
        expect(result.text, isEmpty);
        expect(result.confidence, equals(0.0));
        expect(result.error, equals(error));
      });
    });

    group('TranscriptionSegment', () {
      test('should create segment with timing information', () {
        const segment = TranscriptionSegment(
          text: 'Hello',
          startTime: Duration(seconds: 1),
          endTime: Duration(seconds: 2),
          confidence: 0.9,
        );

        expect(segment.text, equals('Hello'));
        expect(segment.startTime, equals(const Duration(seconds: 1)));
        expect(segment.endTime, equals(const Duration(seconds: 2)));
        expect(segment.confidence, equals(0.9));
      });
    });

    group('TranscriptionError', () {
      test('should create error with all properties', () {
        const error = TranscriptionError(
          message: 'API quota exceeded',
          type: TranscriptionErrorType.quotaExceeded,
          statusCode: 429,
        );

        expect(error.message, equals('API quota exceeded'));
        expect(error.type, equals(TranscriptionErrorType.quotaExceeded));
        expect(error.statusCode, equals(429));
      });
    });

    group('TranscriptionConfig', () {
      test('should create config with default values', () {
        const config = TranscriptionConfig();

        expect(config.language, isNull);
        expect(config.temperature, isNull);
        expect(config.prompt, isNull);
        expect(config.enableTimestamps, isFalse);
        expect(config.maxRetries, equals(3));
        expect(config.timeout, equals(const Duration(seconds: 30)));
      });

      test('should create config with custom values', () {
        const config = TranscriptionConfig(
          language: 'en',
          temperature: 0.5,
          prompt: 'Task creation',
          enableTimestamps: true,
          maxRetries: 5,
          timeout: Duration(seconds: 60),
        );

        expect(config.language, equals('en'));
        expect(config.temperature, equals(0.5));
        expect(config.prompt, equals('Task creation'));
        expect(config.enableTimestamps, isTrue);
        expect(config.maxRetries, equals(5));
        expect(config.timeout, equals(const Duration(seconds: 60)));
      });
    });
  });

  group('LocalTranscriptionService', () {
    late LocalTranscriptionService service;

    setUp(() {
      service = const LocalTranscriptionService();
    });

    tearDown(() async {
      await service.dispose();
    });

    test('should initialize successfully', () async {
      final result = await service.initialize();
      
      expect(service.isInitialized, isTrue);
      expect(result, isA<bool>());
    });

    test('should have supported formats', () {
      expect(service.supportedFormats, isNotEmpty);
      expect(service.supportedFormats, contains('wav'));
      expect(service.supportedFormats, contains('mp3'));
    });

    test('should throw exception when transcribing without initialization', () async {
      expect(
        () => service.transcribeAudioData([1, 2, 3]),
        throwsA(isA<TranscriptionException>()),
      );
    });

    test('should transcribe audio data after initialization', () async {
      await service.initialize();
      
      if (service.isAvailable) {
        final result = await service.transcribeAudioData([1, 2, 3, 4, 5]);
        
        expect(result, isA<TranscriptionResult>());
        if (result.isSuccess) {
          expect(result.text, isNotEmpty);
          expect(result.confidence, greaterThan(0.0));
          expect(result.processingTime, greaterThan(Duration.zero));
        }
      }
    });
  });

  group('CompositeTranscriptionService', () {
    late CompositeTranscriptionService service;
    late LocalTranscriptionService localService;

    setUp(() {
      localService = const LocalTranscriptionService();
      service = CompositeTranscriptionService(
        localService: localService,
        preference: TranscriptionPreference.localOnly,
      );
    });

    tearDown(() async {
      await service.dispose();
    });

    test('should initialize with local service only', () async {
      final result = await service.initialize();
      
      expect(service.isInitialized, isTrue);
      expect(result, isA<bool>());
    });

    test('should have combined supported formats', () async {
      await service.initialize();
      
      expect(service.supportedFormats, isNotEmpty);
      expect(service.supportedFormats, containsAll(['wav', 'mp3']));
    });

    test('should transcribe using local service when preference is localOnly', () async {
      await service.initialize();
      
      if (service.isAvailable) {
        final result = await service.transcribeAudioData([1, 2, 3, 4, 5]);
        
        expect(result, isA<TranscriptionResult>());
      }
    });
  });

  group('TranscriptionValidator', () {
    test('should validate successful transcription result', () {
      final result = TranscriptionResult.success(
        text: 'Create a task to buy groceries',
        confidence: 0.95,
        processingTime: const Duration(seconds: 2),
      );

      final validation = TranscriptionValidator.validateResult(result);

      expect(validation.isValid, isTrue);
      expect(validation.confidence, greaterThanOrEqualTo(0.6));
      expect(validation.originalResult, equals(result));
    });

    test('should invalidate failed transcription result', () {
      final result = TranscriptionResult.failure(
        error: const TranscriptionError(
          message: 'Network error',
          type: TranscriptionErrorType.networkError,
        ),
      );

      final validation = TranscriptionValidator.validateResult(result);

      expect(validation.isValid, isFalse);
      expect(validation.confidence, equals(0.0));
      expect(validation.hasCriticalIssues, isTrue);
    });

    test('should flag low confidence results', () {
      final result = TranscriptionResult.success(
        text: 'Unclear speech',
        confidence: 0.3,
        processingTime: const Duration(seconds: 1),
      );

      final validation = TranscriptionValidator.validateResult(result);

      expect(validation.isValid, isFalse);
      expect(validation.issues, isNotEmpty);
      expect(
        validation.issues.any((issue) => 
          issue.type == ValidationIssueType.lowConfidence),
        isTrue,
      );
    });

    test('should flag empty text results', () {
      final result = TranscriptionResult.success(
        text: '   ',
        confidence: 0.8,
        processingTime: const Duration(seconds: 1),
      );

      final validation = TranscriptionValidator.validateResult(result);

      expect(validation.isValid, isFalse);
      expect(validation.hasCriticalIssues, isTrue);
      expect(
        validation.issues.any((issue) => 
          issue.type == ValidationIssueType.emptyText),
        isTrue,
      );
    });

    test('should select best result from multiple options', () {
      final results = [
        TranscriptionResult.success(
          text: 'Low confidence result',
          confidence: 0.4,
          processingTime: const Duration(seconds: 1),
        ),
        TranscriptionResult.success(
          text: 'High confidence result',
          confidence: 0.95,
          processingTime: const Duration(seconds: 2),
        ),
        TranscriptionResult.success(
          text: 'Medium confidence result',
          confidence: 0.7,
          processingTime: const Duration(seconds: 1),
        ),
      ];

      final bestResult = TranscriptionValidator.selectBestResult(results);

      expect(bestResult.text, equals('High confidence result'));
      expect(bestResult.confidence, equals(0.95));
    });

    test('should throw error when selecting from empty list', () {
      expect(
        () => TranscriptionValidator.selectBestResult([]),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('TranscriptionPreference', () {
    test('should have all expected preference values', () {
      expect(TranscriptionPreference.values, hasLength(6));
      expect(TranscriptionPreference.values, contains(TranscriptionPreference.localOnly));
      expect(TranscriptionPreference.values, contains(TranscriptionPreference.cloudOnly));
      expect(TranscriptionPreference.values, contains(TranscriptionPreference.localFirst));
      expect(TranscriptionPreference.values, contains(TranscriptionPreference.cloudFirst));
      expect(TranscriptionPreference.values, contains(TranscriptionPreference.fastest));
      expect(TranscriptionPreference.values, contains(TranscriptionPreference.mostAccurate));
    });
  });
}