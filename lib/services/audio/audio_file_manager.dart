import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'lazy_audio_playback_service.dart';

/// Audio file metadata
class AudioFileMetadata {
  final String filePath;
  final String fileName;
  final int fileSizeBytes;
  final DateTime createdAt;
  final Duration? duration;
  final String format;
  final int? sampleRate;
  final int? bitRate;

  const AudioFileMetadata({
    required this.filePath,
    required this.fileName,
    required this.fileSizeBytes,
    required this.createdAt,
    this.duration,
    this.format = 'wav',
    this.sampleRate,
    this.bitRate,
  });

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) {
      return '${fileSizeBytes}B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  String get durationFormatted {
    if (duration == null) return 'Unknown';
    final minutes = duration!.inMinutes.remainder(60);
    final seconds = duration!.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'fileName': fileName,
      'fileSizeBytes': fileSizeBytes,
      'createdAt': createdAt.toIso8601String(),
      'duration': duration?.inMilliseconds,
      'format': format,
      'sampleRate': sampleRate,
      'bitRate': bitRate,
    };
  }

  factory AudioFileMetadata.fromJson(Map<String, dynamic> json) {
    return AudioFileMetadata(
      filePath: json['filePath'] as String,
      fileName: json['fileName'] as String,
      fileSizeBytes: json['fileSizeBytes'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      duration: json['duration'] != null 
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      format: json['format'] as String? ?? 'wav',
      sampleRate: json['sampleRate'] as int?,
      bitRate: json['bitRate'] as int?,
    );
  }
}

/// Result of audio file operations
class AudioFileResult {
  final bool success;
  final String? filePath;
  final AudioFileMetadata? metadata;
  final String? error;

  const AudioFileResult({
    required this.success,
    this.filePath,
    this.metadata,
    this.error,
  });

  factory AudioFileResult.success(String filePath, [AudioFileMetadata? metadata]) {
    return AudioFileResult(
      success: true,
      filePath: filePath,
      metadata: metadata,
    );
  }

  factory AudioFileResult.error(String error) {
    return AudioFileResult(
      success: false,
      error: error,
    );
  }
}

/// Service for managing audio files and their metadata
class AudioFileManager {
  static final AudioFileManager _instance = AudioFileManager._internal();
  factory AudioFileManager() => _instance;
  AudioFileManager._internal();

  static const String _audioFolderName = 'voice_tasks';
  static const String _metadataFileName = 'audio_metadata.json';

  Directory? _audioDirectory;
  File? _metadataFile;
  Map<String, AudioFileMetadata> _metadataCache = {};
  
  // Lazy audio playback service for getting actual durations
  final LazyAudioPlaybackService _playbackService = LazyAudioPlaybackService.instance;
  bool _playbackInitialized = false;

  /// Initialize the audio file manager
  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _audioDirectory = Directory(path.join(appDir.path, _audioFolderName));
      _metadataFile = File(path.join(_audioDirectory!.path, _metadataFileName));

      // Create audio directory if it doesn't exist
      if (!await _audioDirectory!.exists()) {
        await _audioDirectory!.create(recursive: true);
      }

      // Mark playback service as available (it will initialize lazily when needed)
      _playbackInitialized = true;
      debugPrint('AudioFileManager: Using lazy audio playback service for duration extraction');

      // Load existing metadata
      await _loadMetadata();

      debugPrint('AudioFileManager initialized: ${_audioDirectory!.path}');
    } catch (e) {
      debugPrint('Error initializing AudioFileManager: $e');
      throw Exception('Failed to initialize audio file manager: $e');
    }
  }

  /// Generate a unique file path for a new audio recording
  String generateAudioFilePath(String taskId) {
    if (_audioDirectory == null) {
      throw StateError('AudioFileManager not initialized');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'voice_${taskId}_$timestamp.wav';
    return path.join(_audioDirectory!.path, fileName);
  }

  /// Save audio file and create metadata entry
  Future<AudioFileResult> saveAudioFile(
    String sourceFilePath, 
    String targetFilePath,
    {Map<String, dynamic>? additionalMetadata}
  ) async {
    try {
      if (_audioDirectory == null) {
        throw StateError('AudioFileManager not initialized');
      }

      final sourceFile = File(sourceFilePath);
      final targetFile = File(targetFilePath);

      // Check if source file exists
      if (!await sourceFile.exists()) {
        return AudioFileResult.error('Source audio file not found: $sourceFilePath');
      }

      // Copy file to target location
      await sourceFile.copy(targetFilePath);

      // Create metadata
      final metadata = await _createMetadata(targetFile, additionalMetadata);

      // Cache metadata
      _metadataCache[targetFilePath] = metadata;

      // Save metadata to file
      await _saveMetadata();

      debugPrint('Audio file saved: $targetFilePath');
      return AudioFileResult.success(targetFilePath, metadata);

    } catch (e) {
      debugPrint('Error saving audio file: $e');
      return AudioFileResult.error('Failed to save audio file: $e');
    }
  }

  /// Get metadata for an audio file
  Future<AudioFileMetadata?> getFileMetadata(String filePath) async {
    // Check cache first
    if (_metadataCache.containsKey(filePath)) {
      return _metadataCache[filePath];
    }

    // Try to create metadata from file if it exists
    final file = File(filePath);
    if (await file.exists()) {
      final metadata = await _createMetadata(file);
      _metadataCache[filePath] = metadata;
      return metadata;
    }

    return null;
  }

  /// Check if an audio file exists and is accessible
  Future<bool> audioFileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking audio file existence: $e');
      return false;
    }
  }

  /// Delete an audio file and its metadata
  Future<AudioFileResult> deleteAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      
      if (await file.exists()) {
        await file.delete();
      }

      // Remove from metadata cache
      _metadataCache.remove(filePath);

      // Save updated metadata
      await _saveMetadata();

      debugPrint('Audio file deleted: $filePath');
      return AudioFileResult.success(filePath);

    } catch (e) {
      debugPrint('Error deleting audio file: $e');
      return AudioFileResult.error('Failed to delete audio file: $e');
    }
  }

  /// Get all audio files in the directory
  Future<List<AudioFileMetadata>> getAllAudioFiles() async {
    try {
      if (_audioDirectory == null || !await _audioDirectory!.exists()) {
        return [];
      }

      final files = await _audioDirectory!
          .list()
          .where((entity) => entity is File && 
                 path.extension(entity.path).toLowerCase() == '.wav')
          .cast<File>()
          .toList();

      final List<AudioFileMetadata> metadataList = [];

      for (final file in files) {
        final metadata = await getFileMetadata(file.path);
        if (metadata != null) {
          metadataList.add(metadata);
        }
      }

      return metadataList;

    } catch (e) {
      debugPrint('Error getting all audio files: $e');
      return [];
    }
  }

  /// Clean up orphaned files (files without metadata or vice versa)
  Future<void> cleanupOrphanedFiles() async {
    try {
      if (_audioDirectory == null) return;

      // final files = await _audioDirectory!
      //     .list()
      //     .where((entity) => entity is File && 
      //            path.extension(entity.path).toLowerCase() == '.wav')
      //     .cast<File>()
      //     .toList();

      // Remove metadata for non-existent files
      final keysToRemove = <String>[];
      for (final filePath in _metadataCache.keys) {
        if (!await File(filePath).exists()) {
          keysToRemove.add(filePath);
        }
      }

      for (final key in keysToRemove) {
        _metadataCache.remove(key);
      }

      // Save cleaned metadata
      await _saveMetadata();

      debugPrint('Cleanup completed. Removed ${keysToRemove.length} orphaned metadata entries');

    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }
  }

  /// Get total storage used by audio files
  Future<int> getTotalStorageUsed() async {
    try {
      final files = await getAllAudioFiles();
      return files.fold<int>(0, (sum, metadata) => sum + metadata.fileSizeBytes);
    } catch (e) {
      debugPrint('Error calculating storage usage: $e');
      return 0;
    }
  }

  Future<AudioFileMetadata> _createMetadata(File file, [Map<String, dynamic>? additionalData]) async {
    final stat = await file.stat();
    final fileName = path.basename(file.path);
    
    // Get real audio duration from the playback service
    Duration? actualDuration;
    if (_playbackInitialized) {
      try {
        actualDuration = await _playbackService.getAudioDuration(file.path);
        debugPrint('Real audio duration for $fileName: ${actualDuration?.inSeconds ?? 0}s');
      } catch (e) {
        debugPrint('Error getting real audio duration for $fileName: $e');
        actualDuration = null;
      }
    }
    
    // Improved fallback duration calculation if real duration couldn't be obtained
    // Better estimation: assume average bitrate for typical voice recordings
    // Typical voice: 16kHz sample rate, 16-bit, mono = ~32KB per second
    final fallbackDurationSeconds = (stat.size / 32000).round().clamp(5, 300);
    final finalDuration = actualDuration ?? Duration(seconds: fallbackDurationSeconds);
    
    if (actualDuration == null) {
      debugPrint('Using improved fallback duration for $fileName: ${finalDuration.inSeconds}s (file size: ${stat.size} bytes, calculated from ${stat.size / 32000} seconds)');
    }
    
    return AudioFileMetadata(
      filePath: file.path,
      fileName: fileName,
      fileSizeBytes: stat.size,
      createdAt: stat.modified,
      duration: finalDuration,
      format: path.extension(fileName).toLowerCase().substring(1),
      sampleRate: additionalData?['sampleRate'] as int? ?? 16000, // Use provided or default
      bitRate: additionalData?['bitRate'] as int? ?? 64000,       // Use provided or default
    );
  }

  Future<void> _loadMetadata() async {
    try {
      if (_metadataFile == null || !await _metadataFile!.exists()) {
        _metadataCache = {};
        return;
      }

      final content = await _metadataFile!.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);

      _metadataCache = data.map((key, value) => 
        MapEntry(key, AudioFileMetadata.fromJson(value as Map<String, dynamic>))
      );

      debugPrint('Loaded metadata for ${_metadataCache.length} audio files');

    } catch (e) {
      debugPrint('Error loading metadata: $e');
      _metadataCache = {};
    }
  }

  Future<void> _saveMetadata() async {
    try {
      if (_metadataFile == null) return;

      final data = _metadataCache.map((key, value) => 
        MapEntry(key, value.toJson())
      );

      final content = jsonEncode(data);
      await _metadataFile!.writeAsString(content);

      debugPrint('Saved metadata for ${_metadataCache.length} audio files');

    } catch (e) {
      debugPrint('Error saving metadata: $e');
    }
  }

  /// Dispose resources and cleanup
  Future<void> dispose() async {
    if (_playbackInitialized) {
      await _playbackService.dispose();
      _playbackInitialized = false;
    }
  }
}