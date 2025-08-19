import 'task_model.dart';

/// Extension to add audio-related functionality to TaskModel
extension TaskAudioExtensions on TaskModel {
  
  /// Check if this task has audio recording
  bool get hasAudio {
    return audioFilePath != null && audioFilePath!.isNotEmpty;
  }
  
  /// Check if this task has playable audio file (both metadata and valid file path)
  bool get hasPlayableAudio {
    return audioFilePath != null && audioFilePath!.isNotEmpty;
  }
  
  /// Check if this task has voice-related metadata (created via voice, may or may not have audio file)
  bool get hasVoiceMetadata {
    return metadata.containsKey('audio') || 
           metadata.containsKey('voice') || 
           creationMode == 'voiceToText' || 
           creationMode == 'voiceOnly';
  }
  
  /// Get the audio file path from metadata
  String? get audioFilePath {
    final audioData = metadata['audio'] as Map<String, dynamic>?;
    return audioData?['filePath'] as String?;
  }
  
  /// Get the audio duration from metadata
  Duration? get audioDuration {
    final audioData = metadata['audio'] as Map<String, dynamic>?;
    final durationSeconds = audioData?['duration'] as int?;
    return durationSeconds != null ? Duration(seconds: durationSeconds) : null;
  }
  
  /// Get formatted audio duration string
  String get audioDurationFormatted {
    final duration = audioDuration;
    if (duration == null) return '--:--';
    
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  /// Get the creation mode (manual, voiceToText, voiceOnly)
  String get creationMode {
    return metadata['creationMode'] as String? ?? 'manual';
  }
  
  /// Check if this task was created using voice
  bool get isVoiceCreated {
    return metadata['isVoiceCreated'] as bool? ?? false;
  }
  
  /// Check if this task has transcription
  bool get hasTranscription {
    return metadata['hasTranscription'] as bool? ?? false;
  }
  
  /// Get the voice transcription text
  String? get transcriptionText {
    final voiceData = metadata['voice'] as Map<String, dynamic>?;
    return voiceData?['transcription'] as String?;
  }
  
  /// Check if this is a voice-only task (has audio but no transcription)
  bool get isVoiceOnly {
    return creationMode == 'voiceOnly' && hasAudio && !hasTranscription;
  }
  
  /// Check if this is a voice-to-text task (has transcription)
  bool get isVoiceToText {
    return creationMode == 'voiceToText' && hasTranscription;
  }
  
  /// Get audio file size from metadata
  String? get audioFileSize {
    final audioData = metadata['audio'] as Map<String, dynamic>?;
    final fileSize = audioData?['fileSize'] as int?;
    if (fileSize == null) return null;
    
    if (fileSize < 1024) {
      return '${fileSize}B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
  
  /// Get audio format from metadata
  String get audioFormat {
    final audioData = metadata['audio'] as Map<String, dynamic>?;
    return audioData?['format'] as String? ?? 'wav';
  }
  
  /// Get the timestamp when the audio was recorded
  DateTime? get audioRecordingTimestamp {
    final audioData = metadata['audio'] as Map<String, dynamic>?;
    final timestampString = audioData?['recordingTimestamp'] as String?;
    return timestampString != null ? DateTime.tryParse(timestampString) : null;
  }
  
  /// Create a copy of this task with updated audio metadata
  TaskModel copyWithAudioMetadata({
    String? audioFilePath,
    Duration? audioDuration,
    String? audioFormat,
    int? audioFileSize,
    DateTime? recordingTimestamp,
    String? transcriptionText,
    String? creationMode,
    bool? isVoiceCreated,
    bool? hasTranscription,
    Map<String, dynamic>? additionalAudioData,
  }) {
    final Map<String, dynamic> newMetadata = Map<String, dynamic>.from(metadata);
    
    // Update creation mode
    if (creationMode != null) {
      newMetadata['creationMode'] = creationMode;
    }
    
    // Update voice creation flag
    if (isVoiceCreated != null) {
      newMetadata['isVoiceCreated'] = isVoiceCreated;
    }
    
    // Update transcription flag
    if (hasTranscription != null) {
      newMetadata['hasTranscription'] = hasTranscription;
    }
    
    // Update audio metadata
    if (audioFilePath != null || audioDuration != null || audioFormat != null || 
        audioFileSize != null || recordingTimestamp != null || additionalAudioData != null) {
      
      final Map<String, dynamic> audioData = Map<String, dynamic>.from(
        newMetadata['audio'] as Map<String, dynamic>? ?? {}
      );
      
      if (audioFilePath != null) audioData['filePath'] = audioFilePath;
      if (audioDuration != null) audioData['duration'] = audioDuration.inSeconds;
      if (audioFormat != null) audioData['format'] = audioFormat;
      if (audioFileSize != null) audioData['fileSize'] = audioFileSize;
      if (recordingTimestamp != null) {
        audioData['recordingTimestamp'] = recordingTimestamp.toIso8601String();
      }
      if (additionalAudioData != null) {
        audioData.addAll(additionalAudioData);
      }
      
      newMetadata['audio'] = audioData;
    }
    
    // Update voice/transcription metadata
    if (transcriptionText != null) {
      final Map<String, dynamic> voiceData = Map<String, dynamic>.from(
        newMetadata['voice'] as Map<String, dynamic>? ?? {}
      );
      voiceData['transcription'] = transcriptionText;
      voiceData['originalText'] = transcriptionText;
      newMetadata['voice'] = voiceData;
    }
    
    return copyWith(metadata: newMetadata);
  }
  
  /// Remove all audio metadata from this task
  TaskModel removeAudioMetadata() {
    final Map<String, dynamic> newMetadata = Map<String, dynamic>.from(metadata);
    
    // Remove audio-related metadata
    newMetadata.remove('audio');
    newMetadata.remove('voice');
    newMetadata['isVoiceCreated'] = false;
    newMetadata['hasTranscription'] = false;
    newMetadata['creationMode'] = 'manual';
    
    return copyWith(metadata: newMetadata);
  }
  
  /// Get a summary of the audio metadata for debugging/display purposes
  Map<String, dynamic> get audioMetadataSummary {
    return {
      'hasAudio': hasAudio,
      'audioFilePath': audioFilePath,
      'audioDuration': audioDurationFormatted,
      'creationMode': creationMode,
      'isVoiceCreated': isVoiceCreated,
      'hasTranscription': hasTranscription,
      'isVoiceOnly': isVoiceOnly,
      'isVoiceToText': isVoiceToText,
      'audioFormat': audioFormat,
      'audioFileSize': audioFileSize,
    };
  }
}

/// Helper class for audio metadata constants
class AudioMetadataKeys {
  static const String audio = 'audio';
  static const String voice = 'voice';
  static const String creationMode = 'creationMode';
  static const String isVoiceCreated = 'isVoiceCreated';
  static const String hasTranscription = 'hasTranscription';
  static const String filePath = 'filePath';
  static const String duration = 'duration';
  static const String format = 'format';
  static const String fileSize = 'fileSize';
  static const String recordingTimestamp = 'recordingTimestamp';
  static const String transcription = 'transcription';
  static const String originalText = 'originalText';
}

/// Audio creation modes
class AudioCreationModes {
  static const String manual = 'manual';
  static const String voiceToText = 'voiceToText';
  static const String voiceOnly = 'voiceOnly';
}