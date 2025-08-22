import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography_constants.dart';
import '../../services/audio/audio_player_service.dart';
import '../providers/audio_providers.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Widget for playing back audio files attached to tasks
class AudioPlaybackWidget extends ConsumerWidget {
  final String taskId;
  final String audioFilePath;
  final Duration? audioDuration;
  final bool isCompact;

  const AudioPlaybackWidget({
    super.key,
    required this.taskId,
    required this.audioFilePath,
    this.audioDuration,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerProvider);
    final audioControls = ref.read(audioControlsProvider);
    final isTaskPlaying = ref.watch(isTaskPlayingProvider(taskId));
    final currentPlayingTask = ref.watch(currentPlayingTaskProvider);
    final theme = Theme.of(context);

    return _buildAudioPlayer(
      context, 
      ref, 
      audioState, 
      audioControls, 
      isTaskPlaying, 
      currentPlayingTask,
      theme,
    );
  }

  Widget _buildAudioPlayer(
    BuildContext context,
    WidgetRef ref,
    AudioPlaybackInfo audioState,
    AudioControls audioControls,
    bool isTaskPlaying,
    String? currentPlayingTask,
    ThemeData theme,
  ) {
    if (isCompact) {
      return _buildCompactPlayer(context, audioControls, isTaskPlaying, theme);
    } else {
      return _buildFullPlayer(context, ref, audioState, audioControls, isTaskPlaying, currentPlayingTask, theme);
    }
  }

  Widget _buildCompactPlayer(
    BuildContext context,
    AudioControls audioControls,
    bool isTaskPlaying,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIcons.musicNote(),
            size: 16,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => _togglePlayback(audioControls),
            child: Icon(
              isTaskPlaying ? PhosphorIcons.pause() : PhosphorIcons.play(),
              size: 20,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _formatDuration(audioDuration ?? Duration.zero),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullPlayer(
    BuildContext context,
    WidgetRef ref,
    AudioPlaybackInfo audioState,
    AudioControls audioControls,
    bool isTaskPlaying,
    String? currentPlayingTask,
    ThemeData theme,
  ) {
    final isCurrentTask = currentPlayingTask == taskId;
    final duration = isCurrentTask ? audioState.duration : (audioDuration ?? Duration.zero);
    final position = isCurrentTask ? audioState.position : Duration.zero;
    final progress = ref.watch(audioProgressProvider(audioState));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  PhosphorIcons.musicNote(),
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Voice Recording',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress bar (only show for current playing task)
            if (isCurrentTask && duration > Duration.zero) ...[
              LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(position),
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    _formatDuration(duration - position),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Playback controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCurrentTask) ...[
                  IconButton(
                    onPressed: () => _rewind(ref),
                    icon: Icon(PhosphorIcons.skipBack()),
                    tooltip: 'Rewind 10s',
                  ),
                  const SizedBox(width: 16),
                ],
                IconButton(
                  onPressed: () => _togglePlayback(audioControls),
                  icon: Icon(
                    isTaskPlaying ? PhosphorIcons.pauseCircle() : PhosphorIcons.playCircle(),
                    size: 48,
                  ),
                  tooltip: isTaskPlaying ? 'Pause' : 'Play',
                ),
                if (isCurrentTask) ...[
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () => _fastForward(ref),
                    icon: Icon(PhosphorIcons.skipForward()),
                    tooltip: 'Fast forward 10s',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePlayback(AudioControls audioControls) async {
    try {
      await audioControls.togglePlayPauseForTask(taskId, audioFilePath);
    } catch (e) {
      debugPrint('Error toggling playback: $e');
    }
  }

  Future<void> _rewind(WidgetRef ref) async {
    try {
      final notifier = ref.read(audioPlayerProvider.notifier);
      await notifier.skipBackward();
    } catch (e) {
      debugPrint('Error rewinding: $e');
    }
  }

  Future<void> _fastForward(WidgetRef ref) async {
    try {
      final notifier = ref.read(audioPlayerProvider.notifier);
      await notifier.skipForward();
    } catch (e) {
      debugPrint('Error fast forwarding: $e');
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

