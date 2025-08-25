import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

/// Service for concatenating multiple audio files into a single file using FFmpeg
class AudioConcatenationService {
  bool _isInitialized = false;

  /// Initialize the audio concatenation service
  Future<bool> initialize() async {
    try {
      _isInitialized = true;
      debugPrint('AudioConcatenationService initialized with FFmpeg support');
      return true;
    } catch (e) {
      debugPrint('AudioConcatenationService initialization failed: $e');
      return false;
    }
  }

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Concatenate multiple audio files into a single file using FFmpeg
  /// 
  /// [audioFilePaths] - List of audio file paths to concatenate
  /// [outputFileName] - Optional custom output filename (defaults to timestamped name)
  /// 
  /// Returns the path to the concatenated audio file, or null if failed
  Future<String?> concatenateAudioFiles(
    List<String> audioFilePaths, {
    String? outputFileName,
    Function(double)? onProgress,
  }) async {
    if (!_isInitialized) {
      throw Exception('Audio concatenation service not initialized');
    }

    if (audioFilePaths.isEmpty) {
      debugPrint('No audio files to concatenate');
      return null;
    }

    if (audioFilePaths.length == 1) {
      debugPrint('Single audio file, returning as-is: ${audioFilePaths.first}');
      onProgress?.call(1.0);
      return audioFilePaths.first;
    }

    debugPrint('[AUDIO] Starting REAL audio concatenation for ${audioFilePaths.length} files...');
    
    try {
      // Create output directory
      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory(path.join(directory.path, 'audio'));
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      // Generate output file path
      final fileName = outputFileName ?? 'concatenated_${DateTime.now().millisecondsSinceEpoch}.aac';
      final outputPath = path.join(audioDir.path, fileName);
      
      // Ensure output directory exists (handles subdirectories in fileName)
      final outputFile = File(outputPath);
      final outputFileDir = outputFile.parent;
      if (!await outputFileDir.exists()) {
        await outputFileDir.create(recursive: true);
        debugPrint('[AUDIO] Created output directory: ${outputFileDir.path}');
      }

      // Filter valid audio files
      final validFiles = <String>[];
      for (final filePath in audioFilePaths) {
        final file = File(filePath);
        if (await file.exists() && filePath.isNotEmpty) {
          validFiles.add(filePath);
          debugPrint('Valid audio file: $filePath');
        } else {
          debugPrint('Skipping invalid/missing file: $filePath');
        }
      }

      if (validFiles.isEmpty) {
        debugPrint('[EMOJI] No valid audio files found for concatenation');
        onProgress?.call(1.0);
        return null;
      }

      if (validFiles.length == 1) {
        debugPrint('[EMOJI] Only one valid file, returning as-is: ${validFiles.first}');
        onProgress?.call(1.0);
        return validFiles.first;
      }

      onProgress?.call(0.1); // Starting FFmpeg processing

      // Create optimized FFmpeg command for concatenation
      // Using concat filter method as recommended by ffmpeg_kit_flutter_new docs
      
      onProgress?.call(0.2); // Starting FFmpeg processing
      
      // Build input files part of command
      final inputFiles = validFiles.asMap().entries.map((entry) => '-i "${entry.value}"').join(' ');
      
      // Build filter_complex for concatenation
      final filterInputs = List.generate(validFiles.length, (i) => '[$i:a]').join('');
      final filterCommand = '${filterInputs}concat=n=${validFiles.length}:v=0:a=1[out]';
      
      // Complete FFmpeg command with optimized approach
      final ffmpegCommand = '$inputFiles -filter_complex "$filterCommand" -map "[out]" -c:a aac -b:a 128k "$outputPath"';
      
      debugPrint('[AUDIO] Executing optimized FFmpeg command: $ffmpegCommand');
      debugPrint('[AUDIO] Input files: ${validFiles.length}');
      
      onProgress?.call(0.3); // Starting FFmpeg execution
      
      final session = await FFmpegKit.execute(ffmpegCommand);
      final returnCode = await session.getReturnCode();
      
      onProgress?.call(0.8); // FFmpeg execution complete
      
      if (ReturnCode.isSuccess(returnCode)) {
        // Verify output file was created
        final outputFile = File(outputPath);
        if (await outputFile.exists()) {
          final fileSize = await outputFile.length();
          debugPrint('Audio concatenation successful!');
          debugPrint('   Command: $ffmpegCommand');
          debugPrint('   Output: $outputPath');
          debugPrint('   Size: $fileSize bytes');
          debugPrint('   Files concatenated: ${validFiles.length}');
          
          onProgress?.call(1.0); // Complete
          return outputPath;
        } else {
          debugPrint('Concatenated file was not created despite success code');
          final logs = await session.getAllLogsAsString();
          debugPrint('   Session logs: $logs');
          onProgress?.call(1.0);
          return null;
        }
      } else {
        // Enhanced error handling with detailed session logs
        final logs = await session.getAllLogsAsString();
        final failureStackTrace = await session.getFailStackTrace();
        
        debugPrint('FFmpeg concatenation failed!');
        debugPrint('   Return code: $returnCode');
        debugPrint('   Command: $ffmpegCommand');
        debugPrint('   Session logs: $logs');
        if (failureStackTrace != null) {
          debugPrint('   Stack trace: $failureStackTrace');
        }
        
        onProgress?.call(1.0);
        
        // Fallback to first file with better error context
        debugPrint('[EMOJI] Falling back to first audio file: ${validFiles.first}');
        debugPrint('   Fallback reason: FFmpeg concatenation failed, preserving first recording');
        return validFiles.first;
      }

    } catch (e) {
      debugPrint('Audio concatenation failed: $e');
      onProgress?.call(1.0);
      
      // Fallback to first file
      final fallbackFile = audioFilePaths.isNotEmpty ? audioFilePaths.first : null;
      debugPrint('[EMOJI] Falling back to first audio file: $fallbackFile');
      return fallbackFile;
    }
  }

  /// Get the duration of an audio file (approximate)
  Future<Duration?> getAudioDuration(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }

      // For AAC files, we can estimate duration based on file size
      // This is approximate - for precise duration, we'd need audio analysis
      final fileSize = await file.length();
      
      // Rough estimate: AAC 128kbps ≈ 16KB per second
      const bytesPerSecond = 16000; // 128kbps / 8 bits per byte
      final estimatedSeconds = fileSize / bytesPerSecond;
      
      return Duration(milliseconds: (estimatedSeconds * 1000).round());
    } catch (e) {
      debugPrint('Error estimating audio duration: $e');
      return null;
    }
  }

  /// Delete a concatenated audio file
  Future<bool> deleteAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Deleted concatenated audio file: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting audio file: $e');
      return false;
    }
  }

  /// Clean up old concatenated files (keep only recent ones)
  Future<void> cleanupOldFiles({int keepCount = 10}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final audioDir = Directory(path.join(directory.path, 'audio'));
      
      if (!await audioDir.exists()) {
        return;
      }

      final files = await audioDir
          .list()
          .where((entity) => entity is File && entity.path.contains('concatenated_'))
          .cast<File>()
          .toList();

      if (files.length <= keepCount) {
        return;
      }

      // Sort by modification time (newest first)
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      // Delete old files
      final filesToDelete = files.skip(keepCount);
      for (final file in filesToDelete) {
        try {
          await file.delete();
          debugPrint('Cleaned up old concatenated file: ${file.path}');
        } catch (e) {
          debugPrint('Error deleting old file ${file.path}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }
  }

  /// Dispose of the audio concatenation service
  Future<void> dispose() async {
    _isInitialized = false;
    debugPrint('AudioConcatenationService disposed');
  }
}