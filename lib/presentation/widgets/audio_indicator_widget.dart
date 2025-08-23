import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/task_audio_extensions.dart';
import 'task_audio_controls.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Enhanced audio indicator widget with playback controls
/// 
/// Modes:
/// - simple: Just shows audio icon (for very compact spaces)
/// - playButton: Shows play/pause button 
/// - compact: Shows play button with duration
/// - expanded: Shows full controls with progress
class AudioIndicatorWidget extends ConsumerWidget {
  final TaskModel task;
  final double size;
  final AudioIndicatorMode mode;
  final VoidCallback? onTap;
  final bool showDuration;
  final bool showProgress;
  final Color? accentColor;

  const AudioIndicatorWidget({
    super.key,
    required this.task,
    this.size = 20,
    this.mode = AudioIndicatorMode.playButton,
    this.onTap,
    this.showDuration = false,
    this.showProgress = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Only show if task has playable audio
    if (!task.hasPlayableAudio) return const SizedBox.shrink();
    
    switch (mode) {
      case AudioIndicatorMode.simple:
        return _buildSimpleIndicator(theme);
      case AudioIndicatorMode.playButton:
        return QuickAudioPlayButton(
          taskId: task.id,
          audioFilePath: task.audioFilePath!,
          size: size,
          duration: task.audioDuration,
        );
      case AudioIndicatorMode.compact:
        return TaskAudioControls(
          taskId: task.id,
          audioFilePath: task.audioFilePath!,
          mode: AudioControlsMode.compact,
          width: size * 4,
          duration: task.audioDuration,
        );
      case AudioIndicatorMode.expanded:
        return TaskAudioControls(
          taskId: task.id,
          audioFilePath: task.audioFilePath!,
          mode: AudioControlsMode.expanded,
          width: size * 6,
          duration: task.audioDuration,
        );
    }
  }

  Widget _buildSimpleIndicator(ThemeData theme) {
    return GestureDetector(
      onTap: onTap ?? () => _handleTap(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: (accentColor ?? theme.colorScheme.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(
            color: (accentColor ?? theme.colorScheme.primary).withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Icon(
          PhosphorIcons.waveform(),
          size: size * 0.6,
          color: accentColor ?? theme.colorScheme.primary,
        ),
      ),
    );
  }

  void _handleTap() {
    // If custom tap handler provided, use it
    if (onTap != null) {
      onTap!();
      return;
    }
    
    // Otherwise show audio controls dialog
    // This could be implemented to show a modal with full audio controls
  }
}

/// Display modes for audio indicators
enum AudioIndicatorMode {
  simple,    // Just shows audio icon
  playButton, // Shows play/pause button (recommended)
  compact,   // Shows compact controls with duration
  expanded,  // Shows full controls with progress
}

/// Legacy support - simple audio indicator
/// 
/// @deprecated Use AudioIndicatorWidget with mode parameter instead
class SimpleAudioIndicator extends ConsumerWidget {
  final TaskModel task;
  final double size;
  final VoidCallback? onTap;

  const SimpleAudioIndicator({
    super.key,
    required this.task,
    this.size = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AudioIndicatorWidget(
      task: task,
      size: size,
      mode: AudioIndicatorMode.simple,
      onTap: onTap,
    );
  }
}

