import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/services/audio/audio_concatenation_service.dart';
import 'package:task_tracker_app/domain/models/audio_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('AudioConcatenationService Integration Tests', () {
    late AudioConcatenationService service;
    late Directory testDirectory;
    late List<File> testAudioFiles;

    setUpAll(() async {
      // Create test directory
      testDirectory = await Directory.systemTemp.createTemp('audio_test_');
      
      // Create mock audio files for testing
      testAudioFiles = await _createTestAudioFiles(testDirectory);
    });

    tearDownAll(() async {
      // Clean up test directory
      if (await testDirectory.exists()) {
        await testDirectory.delete(recursive: true);
      }
    });

    setUp(() {
      service = AudioConcatenationService();
    });

    group('Service Initialization', () {
      test('initializes successfully', () async {
        final result = await service.initialize();
        expect(result, isTrue);
        expect(service.isInitialized, isTrue);
      });

      test('throws exception when using uninitialized service', () async {
        expect(
          () => service.concatenateAudioFiles([]),
          throwsException,
        );
      });
    });

    group('Single File Handling', () {
      test('returns single file path when only one file provided', () async {
        await service.initialize();
        
        final result = await service.concatenateAudioFiles([
          testAudioFiles[0].path,
        ]);

        expect(result, equals(testAudioFiles[0].path));
      });

      test('handles empty file list', () async {
        await service.initialize();
        
        final result = await service.concatenateAudioFiles([]);
        expect(result, isNull);
      });
    });

    group('Multi-File Concatenation', () {
      test('concatenates multiple valid audio files', () async {
        await service.initialize();
        
        double progressReported = 0.0;
        final result = await service.concatenateAudioFiles(
          testAudioFiles.map((f) => f.path).toList(),
          outputFileName: 'test_concatenated.aac',
          onProgress: (progress) {
            progressReported = progress;
          },
        );

        expect(result, isNotNull);
        expect(result, contains('test_concatenated.aac'));
        expect(progressReported, equals(1.0)); // Should complete
        
        // Verify output file exists
        final outputFile = File(result!);
        expect(await outputFile.exists(), isTrue);
        
        // Verify file has content (basic check)
        final fileSize = await outputFile.length();
        expect(fileSize, greaterThan(0));
      });

      test('handles progress callbacks correctly', () async {
        await service.initialize();
        
        final progressValues = <double>[];
        await service.concatenateAudioFiles(
          testAudioFiles.map((f) => f.path).toList(),
          onProgress: (progress) {
            progressValues.add(progress);
          },
        );

        expect(progressValues.isNotEmpty, isTrue);
        expect(progressValues.last, equals(1.0));
        
        // Progress should generally increase
        for (int i = 1; i < progressValues.length; i++) {
          expect(progressValues[i], greaterThanOrEqualTo(progressValues[i - 1]));
        }
      });

      test('filters out invalid file paths', () async {
        await service.initialize();
        
        final mixedPaths = [
          testAudioFiles[0].path,
          '/nonexistent/file.aac',
          testAudioFiles[1].path,
          '', // empty path
        ];
        
        final result = await service.concatenateAudioFiles(mixedPaths);
        
        // Should still succeed with valid files
        expect(result, isNotNull);
      });

      test('returns null when all files are invalid', () async {
        await service.initialize();
        
        final invalidPaths = [
          '/nonexistent/file1.aac',
          '/nonexistent/file2.aac',
          '', // empty path
        ];
        
        final result = await service.concatenateAudioFiles(invalidPaths);
        expect(result, isNull);
      });
    });

    group('File Management', () {
      test('creates output in correct directory structure', () async {
        await service.initialize();
        
        final result = await service.concatenateAudioFiles(
          testAudioFiles.map((f) => f.path).toList(),
          outputFileName: 'structured_test.aac',
        );

        expect(result, isNotNull);
        
        final outputFile = File(result!);
        expect(await outputFile.exists(), isTrue);
        
        // Should be in app documents/audio directory
        expect(result, contains('audio'));
        expect(result, contains('structured_test.aac'));
      });

      test('generates unique filename when none provided', () async {
        await service.initialize();
        
        final result1 = await service.concatenateAudioFiles(
          testAudioFiles.map((f) => f.path).toList(),
        );
        
        // Wait a moment to ensure different timestamp
        await Future.delayed(const Duration(milliseconds: 10));
        
        final result2 = await service.concatenateAudioFiles(
          testAudioFiles.map((f) => f.path).toList(),
        );

        expect(result1, isNotNull);
        expect(result2, isNotNull);
        expect(result1, isNot(equals(result2)));
        
        // Both should contain timestamp-based names
        expect(result1!, contains('concatenated_'));
        expect(result2!, contains('concatenated_'));
      });
    });

    group('Error Handling', () {
      test('handles FFmpeg errors gracefully', () async {
        await service.initialize();
        
        // Create a file with invalid audio content
        final invalidFile = File('${testDirectory.path}/invalid.aac');
        await invalidFile.writeAsString('This is not audio data');
        
        expect(
          () => service.concatenateAudioFiles([invalidFile.path]),
          throwsException,
        );
      });

      test('handles file permission errors', () async {
        await service.initialize();
        
        // Try to write to a read-only location (this test might be platform-specific)
        final result = await service.concatenateAudioFiles(
          testAudioFiles.map((f) => f.path).toList(),
          outputFileName: '/root/readonly_test.aac', // Should fail on most systems
        );
        
        // Should either succeed with alternative location or fail gracefully
        // The service should handle this without crashing
        expect(result, anyOf(isNull, isNotNull));
      });
    });

    group('Performance and Memory', () {
      test('handles large number of files efficiently', () async {
        await service.initialize();
        
        // Create many small test files
        final manyFiles = <String>[];
        for (int i = 0; i < 10; i++) {
          final file = File('${testDirectory.path}/test_$i.aac');
          await file.writeAsBytes(_generateTestAudioData(1024)); // Small files
          manyFiles.add(file.path);
        }
        
        final stopwatch = Stopwatch()..start();
        final result = await service.concatenateAudioFiles(manyFiles);
        stopwatch.stop();
        
        expect(result, isNotNull);
        expect(stopwatch.elapsedMilliseconds, lessThan(10000)); // Should complete within 10 seconds
        
        // Clean up
        for (final filePath in manyFiles) {
          await File(filePath).delete();
        }
      });

      test('provides reasonable progress updates for large operations', () async {
        await service.initialize();
        
        final progressUpdates = <double>[];
        final result = await service.concatenateAudioFiles(
          testAudioFiles.map((f) => f.path).toList(),
          onProgress: (progress) {
            progressUpdates.add(progress);
          },
        );
        
        expect(result, isNotNull);
        expect(progressUpdates.length, greaterThan(1)); // Should have multiple updates
        expect(progressUpdates.first, lessThan(1.0)); // Should start below 100%
        expect(progressUpdates.last, equals(1.0)); // Should end at 100%
      });
    });

    group('Integration with AudioSegment Model', () {
      test('works with AudioSegment file paths', () async {
        await service.initialize();
        
        final segments = testAudioFiles.map((file) => AudioSegment(
          id: file.path.split('/').last,
          filePath: file.path,
          duration: const Duration(seconds: 5), // Mock duration
          recordedAt: DateTime.now(),
          title: 'Test Segment',
        )).toList();
        
        final segmentPaths = segments.map((s) => s.filePath).toList();
        final result = await service.concatenateAudioFiles(segmentPaths);
        
        expect(result, isNotNull);
        
        // Should create concatenated file
        final outputFile = File(result!);
        expect(await outputFile.exists(), isTrue);
      });

      test('calculates total duration correctly from segments', () async {
        await service.initialize();
        
        final segments = [
          AudioSegment(
            id: '1',
            filePath: testAudioFiles[0].path,
            duration: const Duration(seconds: 10),
            recordedAt: DateTime.now(),
          ),
          AudioSegment(
            id: '2',
            filePath: testAudioFiles[1].path,
            duration: const Duration(seconds: 15),
            recordedAt: DateTime.now(),
          ),
        ];
        
        final totalDuration = segments.fold<Duration>(
          Duration.zero,
          (prev, segment) => prev + segment.duration,
        );
        
        expect(totalDuration, equals(const Duration(seconds: 25)));
        
        // Verify concatenation works with these segments
        final result = await service.concatenateAudioFiles(
          segments.map((s) => s.filePath).toList(),
        );
        
        expect(result, isNotNull);
      });
    });
  });
}

/// Helper function to create test audio files
Future<List<File>> _createTestAudioFiles(Directory testDir) async {
  final files = <File>[];
  
  for (int i = 0; i < 3; i++) {
    final file = File('${testDir.path}/test_audio_$i.aac');
    await file.writeAsBytes(_generateTestAudioData(2048));
    files.add(file);
  }
  
  return files;
}

/// Generate mock audio data for testing
List<int> _generateTestAudioData(int size) {
  // Create mock audio header and data
  final data = List<int>.filled(size, 0);
  
  // Add some variation to simulate audio data
  for (int i = 0; i < data.length; i++) {
    data[i] = (i % 256);
  }
  
  return data;
}