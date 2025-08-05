import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/services/speech/speech_service_impl.dart';
import 'package:task_tracker_app/services/speech/speech_service.dart';

void main() {
  group('SpeechServiceImpl (Stub)', () {
    late SpeechService speechService;

    setUp(() {
      speechService = SpeechServiceImpl();
    });

    tearDown(() async {
      await speechService.dispose();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        final result = await speechService.initialize();
        expect(result, isFalse); // Stub always returns false
        expect(speechService.isInitialized, isTrue);
        expect(speechService.isAvailable, isFalse);
      });

      test('should report correct initial state', () {
        expect(speechService.isInitialized, isFalse);
        expect(speechService.isListening, isFalse);
        expect(speechService.isAvailable, isFalse);
      });
    });

    group('Permissions (Stub)', () {
      test('should return false for permission check', () async {
        final result = await speechService.hasPermission();
        expect(result, isFalse);
      });

      test('should return false for permission request', () async {
        final result = await speechService.requestPermission();
        expect(result, isFalse);
      });
    });

    group('Speech Recognition', () {
      test('should handle start listening with error callback', () async {
        await speechService.initialize();
        
        String? errorMessage;
        await speechService.startListening(
          onResult: (result) {},
          onError: (error) => errorMessage = error,
        );

        expect(errorMessage, 'Speech recognition not available');
        expect(speechService.isListening, isFalse); // Stub doesn't actually start listening
      });

      test('should stop listening', () async {
        await speechService.initialize();
        
        // The stub doesn't actually start listening, so just test the stop method
        await speechService.stopListening();
        expect(speechService.isListening, isFalse);
      });

      test('should cancel listening', () async {
        await speechService.initialize();
        
        // The stub doesn't actually start listening, so just test the cancel method
        await speechService.cancel();
        expect(speechService.isListening, isFalse);
      });
    });

    group('Stub Behavior', () {
      test('should handle dispose gracefully', () async {
        expect(() => speechService.dispose(), returnsNormally);
      });
    });
  });
}