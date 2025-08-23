import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/domain/models/audio_models.dart';

void main() {
  group('AudioSegment', () {
    test('creates audio segment with required fields', () {
      final segment = AudioSegment(
        id: 'test-id',
        filePath: '/path/to/audio.aac',
        duration: const Duration(seconds: 30),
        recordedAt: DateTime(2024, 1, 1),
      );

      expect(segment.id, equals('test-id'));
      expect(segment.filePath, equals('/path/to/audio.aac'));
      expect(segment.duration, equals(const Duration(seconds: 30)));
      expect(segment.recordedAt, equals(DateTime(2024, 1, 1)));
      expect(segment.title, isNull);
      expect(segment.isProcessed, isFalse);
    });

    test('creates audio segment with optional fields', () {
      final segment = AudioSegment(
        id: 'test-id',
        filePath: '/path/to/audio.aac',
        duration: const Duration(seconds: 30),
        recordedAt: DateTime(2024, 1, 1),
        title: 'Meeting Notes',
        isProcessed: true,
      );

      expect(segment.title, equals('Meeting Notes'));
      expect(segment.isProcessed, isTrue);
    });

    test('copyWith updates specified fields', () {
      final original = AudioSegment(
        id: 'test-id',
        filePath: '/path/to/audio.aac',
        duration: const Duration(seconds: 30),
        recordedAt: DateTime(2024, 1, 1),
        title: 'Original Title',
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        isProcessed: true,
      );

      expect(updated.id, equals(original.id));
      expect(updated.filePath, equals(original.filePath));
      expect(updated.duration, equals(original.duration));
      expect(updated.recordedAt, equals(original.recordedAt));
      expect(updated.title, equals('Updated Title'));
      expect(updated.isProcessed, isTrue);
    });

    test('equality works correctly', () {
      final segment1 = AudioSegment(
        id: 'test-id',
        filePath: '/path/to/audio.aac',
        duration: const Duration(seconds: 30),
        recordedAt: DateTime(2024, 1, 1),
      );

      final segment2 = AudioSegment(
        id: 'test-id',
        filePath: '/path/to/audio.aac',
        duration: const Duration(seconds: 30),
        recordedAt: DateTime(2024, 1, 1),
      );

      final segment3 = AudioSegment(
        id: 'different-id',
        filePath: '/path/to/audio.aac',
        duration: const Duration(seconds: 30),
        recordedAt: DateTime(2024, 1, 1),
      );

      expect(segment1, equals(segment2));
      expect(segment1, isNot(equals(segment3)));
    });
  });

  group('AudioQuality', () {
    test('has correct bitrates and sample rates', () {
      expect(AudioQuality.low.bitrate, equals(64));
      expect(AudioQuality.low.sampleRate, equals(22050));
      
      expect(AudioQuality.medium.bitrate, equals(128));
      expect(AudioQuality.medium.sampleRate, equals(44100));
      
      expect(AudioQuality.high.bitrate, equals(192));
      expect(AudioQuality.high.sampleRate, equals(44100));
      
      expect(AudioQuality.ultra.bitrate, equals(320));
      expect(AudioQuality.ultra.sampleRate, equals(48000));
    });

    test('has correct display names', () {
      expect(AudioQuality.low.displayName, equals('Low Quality (64kbps)'));
      expect(AudioQuality.medium.displayName, equals('Medium Quality (128kbps)'));
      expect(AudioQuality.high.displayName, equals('High Quality (192kbps)'));
      expect(AudioQuality.ultra.displayName, equals('Ultra Quality (320kbps)'));
    });

    test('all quality levels are available', () {
      expect(AudioQuality.values.length, equals(4));
      expect(AudioQuality.values, contains(AudioQuality.low));
      expect(AudioQuality.values, contains(AudioQuality.medium));
      expect(AudioQuality.values, contains(AudioQuality.high));
      expect(AudioQuality.values, contains(AudioQuality.ultra));
    });
  });

  group('AudioPlaybackState', () {
    test('has all expected states', () {
      expect(AudioPlaybackState.values.length, equals(5));
      expect(AudioPlaybackState.values, contains(AudioPlaybackState.stopped));
      expect(AudioPlaybackState.values, contains(AudioPlaybackState.playing));
      expect(AudioPlaybackState.values, contains(AudioPlaybackState.paused));
      expect(AudioPlaybackState.values, contains(AudioPlaybackState.buffering));
      expect(AudioPlaybackState.values, contains(AudioPlaybackState.error));
    });
  });

  group('AudioEnhancementOptions', () {
    test('has default values', () {
      const options = AudioEnhancementOptions();
      
      expect(options.noiseReduction, isFalse);
      expect(options.autoGain, isTrue);
      expect(options.volume, equals(1.0));
      expect(options.compressionEnabled, isFalse);
    });

    test('accepts custom values', () {
      const options = AudioEnhancementOptions(
        noiseReduction: true,
        autoGain: false,
        volume: 0.8,
        compressionEnabled: true,
      );
      
      expect(options.noiseReduction, isTrue);
      expect(options.autoGain, isFalse);
      expect(options.volume, equals(0.8));
      expect(options.compressionEnabled, isTrue);
    });

    test('copyWith updates specified fields', () {
      const original = AudioEnhancementOptions(
        noiseReduction: false,
        volume: 1.0,
      );

      final updated = original.copyWith(
        noiseReduction: true,
        volume: 0.5,
      );

      expect(updated.noiseReduction, isTrue);
      expect(updated.autoGain, equals(original.autoGain)); // unchanged
      expect(updated.volume, equals(0.5));
      expect(updated.compressionEnabled, equals(original.compressionEnabled)); // unchanged
    });

    test('volume constraints are reasonable', () {
      const options = AudioEnhancementOptions(volume: 2.0); // Above 1.0 is valid
      expect(options.volume, equals(2.0));
      
      const quietOptions = AudioEnhancementOptions(volume: 0.1);
      expect(quietOptions.volume, equals(0.1));
    });
  });
}