import '../entities/task_model.dart';

/// Helper class for managing audio-related metadata in tasks
class TaskAudioMetadata {
  /// Key for audio file path in task metadata
  static const String audioFilePathKey = 'audio_file_path';
  
  /// Key for audio duration in task metadata (in milliseconds)
  static const String audioDurationKey = 'audio_duration_ms';
  
  /// Key for audio recording timestamp in task metadata
  static const String audioRecordedAtKey = 'audio_recorded_at';
  
  /// Key for task type (text, voice, transcribed)
  static const String taskTypeKey = 'task_type';

  /// Check if a task has audio attached
  static bool hasAudio(TaskModel task) {
    return task.metadata.containsKey(audioFilePathKey) &&
           task.metadata[audioFilePathKey] != null &&
           (task.metadata[audioFilePathKey] as String).isNotEmpty;
  }

  /// Get the audio file path from a task
  static String? getAudioFilePath(TaskModel task) {
    return task.metadata[audioFilePathKey] as String?;
  }

  /// Get the audio duration from a task
  static Duration? getAudioDuration(TaskModel task) {
    final durationMs = task.metadata[audioDurationKey] as int?;
    return durationMs != null ? Duration(milliseconds: durationMs) : null;
  }

  /// Get when the audio was recorded
  static DateTime? getAudioRecordedAt(TaskModel task) {
    final timestamp = task.metadata[audioRecordedAtKey] as String?;
    return timestamp != null ? DateTime.tryParse(timestamp) : null;
  }

  /// Get the task type
  static TaskType getTaskType(TaskModel task) {
    final typeString = task.metadata[taskTypeKey] as String?;
    switch (typeString) {
      case 'voice':
        return TaskType.voice;
      case 'transcribed':
        return TaskType.transcribed;
      default:
        return TaskType.text;
    }
  }

  /// Create a task with audio metadata
  static TaskModel withAudio(
    TaskModel task, {
    required String audioFilePath,
    Duration? audioDuration,
    DateTime? recordedAt,
    TaskType taskType = TaskType.voice,
  }) {
    final updatedMetadata = Map<String, dynamic>.from(task.metadata);
    updatedMetadata[audioFilePathKey] = audioFilePath;
    updatedMetadata[taskTypeKey] = taskType.name;
    
    if (audioDuration != null) {
      updatedMetadata[audioDurationKey] = audioDuration.inMilliseconds;
    }
    
    if (recordedAt != null) {
      updatedMetadata[audioRecordedAtKey] = recordedAt.toIso8601String();
    }

    return task.copyWith(metadata: updatedMetadata);
  }

  /// Remove audio metadata from a task
  static TaskModel removeAudio(TaskModel task) {
    final updatedMetadata = Map<String, dynamic>.from(task.metadata);
    updatedMetadata.remove(audioFilePathKey);
    updatedMetadata.remove(audioDurationKey);
    updatedMetadata.remove(audioRecordedAtKey);
    updatedMetadata[taskTypeKey] = TaskType.text.name;

    return task.copyWith(metadata: updatedMetadata);
  }

  /// Format audio duration for display
  static String formatAudioDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Enum for different types of tasks
enum TaskType {
  text,       // Manually entered text task
  voice,      // Raw voice recording
  transcribed // Voice-to-text transcribed task
}

/// Extension on TaskType for display purposes
extension TaskTypeExtension on TaskType {
  String get displayName {
    switch (this) {
      case TaskType.text:
        return 'Text';
      case TaskType.voice:
        return 'Voice';
      case TaskType.transcribed:
        return 'Transcribed';
    }
  }

  String get icon {
    switch (this) {
      case TaskType.text:
        return '📝';
      case TaskType.voice:
        return '🎤';
      case TaskType.transcribed:
        return '📝🎤';
    }
  }
}