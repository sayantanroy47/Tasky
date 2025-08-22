import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_providers.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/task_audio_extensions.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Audio indicator widget for tasks with audio
class AudioIndicatorWidget extends ConsumerWidget {
  final TaskModel task;
  final double size;
  final VoidCallback? onTap;

  const AudioIndicatorWidget({
    super.key,
    required this.task,
    this.size = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Only show if task has playable audio
    if (!task.hasPlayableAudio) return const SizedBox.shrink();
    
    return GestureDetector(
      onTap: onTap ?? () => _playAudio(context, ref),
      child: Container(
        width: size + 4,
        height: size + 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular((size + 4) / 2),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          PhosphorIcons.speakerHigh(),
          size: size * 0.7,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  void _playAudio(BuildContext context, WidgetRef ref) async {
    final audioFilePath = task.audioFilePath;
    if (audioFilePath == null) return;
    
    try {
      final audioControls = ref.read(audioControlsProvider);
      await audioControls.togglePlayPauseForTask(task.id, audioFilePath);
      
      if (context.mounted) {
        final isPlaying = ref.read(isTaskPlayingProvider(task.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isPlaying ? 'Playing audio...' : 'Audio paused'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

