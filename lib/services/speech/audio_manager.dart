import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for managing audio files and cleanup
class AudioManager {
  static const String _audioDirectoryName = 'voice_recordings';
  static const String _tempAudioPrefix = 'temp_recording_';
  static const String _audioExtension = '.wav';

  /// Get the directory for storing audio files
  Future<Directory> getAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(path.join(appDir.path, _audioDirectoryName));
    
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    
    return audioDir;
  }

  /// Create a temporary audio file path
  Future<String> createTempAudioFilePath() async {
    final audioDir = await getAudioDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    const fileName = '$_tempAudioPrefix$timestamp$_audioExtension';
    return path.join(audioDir.path, fileName);
  }

  /// Save audio data to a file
  Future<String> saveAudioData(Uint8List audioData, {String? fileName}) async {
    final audioDir = await getAudioDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final finalFileName = fileName ?? 'recording_$timestamp$_audioExtension';
    final filePath = path.join(audioDir.path, finalFileName);
    
    final file = File(filePath);
    await file.writeAsBytes(audioData);
    
    return filePath;
  }

  /// Delete a specific audio file
  Future<bool> deleteAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Clean up temporary audio files
  Future<int> cleanupTempFiles() async {
    try {
      final audioDir = await getAudioDirectory();
      final files = await audioDir.list().toList();
      int deletedCount = 0;

      for (final entity in files) {
        if (entity is File && 
            path.basename(entity.path).startsWith(_tempAudioPrefix)) {
          try {
            await entity.delete();
            deletedCount++;
          } catch (e) {
            // Continue with other files if one fails
          }
        }
      }

      return deletedCount;
    } catch (e) {
      return 0;
    }
  }

  /// Clean up old audio files (older than specified days)
  Future<int> cleanupOldFiles({int daysOld = 7}) async {
    try {
      final audioDir = await getAudioDirectory();
      final files = await audioDir.list().toList();
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      int deletedCount = 0;

      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            try {
              await entity.delete();
              deletedCount++;
            } catch (e) {
              // Continue with other files if one fails
            }
          }
        }
      }

      return deletedCount;
    } catch (e) {
      return 0;
    }
  }

  /// Get all audio files in the directory
  Future<List<String>> getAllAudioFiles() async {
    try {
      final audioDir = await getAudioDirectory();
      final files = await audioDir.list().toList();
      
      return files
          .where((entity) => entity is File && 
                 entity.path.endsWith(_audioExtension))
          .map((entity) => entity.path)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get the size of all audio files in bytes
  Future<int> getTotalAudioFilesSize() async {
    try {
      final audioFiles = await getAllAudioFiles();
      int totalSize = 0;

      for (final filePath in audioFiles) {
        final file = File(filePath);
        if (await file.exists()) {
          final stat = await file.stat();
          totalSize += stat.size;
        }
      }

      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Format file size in human readable format
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Check if there's enough storage space (basic check)
  Future<bool> hasEnoughSpace({int requiredBytes = 10 * 1024 * 1024}) async {
    try {
      final audioDir = await getAudioDirectory();
      await audioDir.stat(); // Check if directory exists
      // This is a basic check - in a real app you might want to check actual free space
      return true; // Assume we have space for now
    } catch (e) {
      return false;
    }
  }

  /// Clean up all audio files (use with caution)
  Future<int> cleanupAllFiles() async {
    try {
      final audioDir = await getAudioDirectory();
      final files = await audioDir.list().toList();
      int deletedCount = 0;

      for (final entity in files) {
        if (entity is File) {
          try {
            await entity.delete();
            deletedCount++;
          } catch (e) {
            // Continue with other files if one fails
          }
        }
      }

      return deletedCount;
    } catch (e) {
      return 0;
    }
  }
}
