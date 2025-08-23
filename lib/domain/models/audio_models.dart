import 'package:equatable/equatable.dart';

/// Audio segment for multi-segment recording
class AudioSegment extends Equatable {
  final String id;
  final String filePath;
  final Duration duration;
  final DateTime recordedAt;
  final String? title;
  final bool isProcessed;

  const AudioSegment({
    required this.id,
    required this.filePath,
    required this.duration,
    required this.recordedAt,
    this.title,
    this.isProcessed = false,
  });

  AudioSegment copyWith({
    String? id,
    String? filePath,
    Duration? duration,
    DateTime? recordedAt,
    String? title,
    bool? isProcessed,
  }) {
    return AudioSegment(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      recordedAt: recordedAt ?? this.recordedAt,
      title: title ?? this.title,
      isProcessed: isProcessed ?? this.isProcessed,
    );
  }

  @override
  List<Object?> get props => [id, filePath, duration, recordedAt, title, isProcessed];
}

/// Audio quality settings
enum AudioQuality {
  low(bitrate: 64, sampleRate: 22050, description: 'Low Quality (64kbps)'),
  medium(bitrate: 128, sampleRate: 44100, description: 'Medium Quality (128kbps)'),
  high(bitrate: 192, sampleRate: 44100, description: 'High Quality (192kbps)'),
  ultra(bitrate: 320, sampleRate: 48000, description: 'Ultra Quality (320kbps)');

  const AudioQuality({
    required this.bitrate,
    required this.sampleRate,
    required this.description,
  });

  final int bitrate;
  final int sampleRate;
  final String description;

  String get displayName => description;
}

/// Audio playback state
enum AudioPlaybackState {
  stopped,
  playing,
  paused,
  buffering,
  error,
}

/// Audio enhancement options
class AudioEnhancementOptions {
  final bool noiseReduction;
  final bool autoGain;
  final double volume;
  final bool compressionEnabled;

  const AudioEnhancementOptions({
    this.noiseReduction = false,
    this.autoGain = true,
    this.volume = 1.0,
    this.compressionEnabled = false,
  });

  AudioEnhancementOptions copyWith({
    bool? noiseReduction,
    bool? autoGain,
    double? volume,
    bool? compressionEnabled,
  }) {
    return AudioEnhancementOptions(
      noiseReduction: noiseReduction ?? this.noiseReduction,
      autoGain: autoGain ?? this.autoGain,
      volume: volume ?? this.volume,
      compressionEnabled: compressionEnabled ?? this.compressionEnabled,
    );
  }
}