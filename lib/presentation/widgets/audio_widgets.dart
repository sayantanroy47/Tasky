import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_providers.dart';
import '../../services/audio/audio_file_manager.dart';
import '../../core/theme/typography_constants.dart';

/// Simple audio control bar for tasks with audio files
class AudioControlBar extends ConsumerWidget {
  final String taskId;
  final String audioFilePath;
  final Duration? duration;

  const AudioControlBar({
    super.key,
    required this.taskId,
    required this.audioFilePath,
    this.duration,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerProvider);
    final audioControls = ref.read(audioControlsProvider);
    final isTaskPlaying = ref.watch(isTaskPlayingProvider(taskId));
    final currentPlayingTask = ref.watch(currentPlayingTaskProvider);
    final theme = Theme.of(context);

    final isCurrentTask = currentPlayingTask == taskId;
    final showProgress = isCurrentTask && audioState.duration > Duration.zero;
    final progress = showProgress ? ref.watch(audioProgressProvider(audioState)) : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Play/Pause button
              IconButton(
                onPressed: () => _togglePlayback(audioControls),
                icon: Icon(
                  isTaskPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: 32,
                ),
                color: theme.colorScheme.primary,
              ),
              
              const SizedBox(width: 8),
              
              // Time display
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showProgress) ...[
                      // Progress bar
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Time labels
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(audioState.position),
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            _formatDuration(audioState.duration),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        'Voice Recording',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (duration != null)
                        Text(
                          _formatDuration(duration!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              
              // Additional controls for current playing task
              if (isCurrentTask) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _rewind(ref),
                  icon: const Icon(Icons.replay_10),
                  iconSize: 20,
                  tooltip: 'Rewind 10s',
                ),
                IconButton(
                  onPressed: () => _fastForward(ref),
                  icon: const Icon(Icons.forward_10),
                  iconSize: 20,
                  tooltip: 'Fast forward 10s',
                ),
              ],
            ],
          ),
        ],
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

/// Minimal audio badge for showing audio presence
class AudioBadge extends ConsumerWidget {
  final String taskId;
  final String audioFilePath;
  final VoidCallback? onTap;

  const AudioBadge({
    super.key,
    required this.taskId,
    required this.audioFilePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTaskPlaying = ref.watch(isTaskPlayingProvider(taskId));
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap ?? () => _togglePlayback(ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isTaskPlaying
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isTaskPlaying
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isTaskPlaying ? Icons.pause : Icons.volume_up,
              size: 16,
              color: isTaskPlaying
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              isTaskPlaying ? 'Playing' : 'Audio',
              style: TextStyle(
                fontSize: 12,
                color: isTaskPlaying
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isTaskPlaying ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePlayback(WidgetRef ref) async {
    try {
      final audioControls = ref.read(audioControlsProvider);
      await audioControls.togglePlayPauseForTask(taskId, audioFilePath);
    } catch (e) {
      debugPrint('Error toggling playback: $e');
    }
  }
}

/// Audio file list widget for displaying all audio files
class AudioFileList extends ConsumerWidget {
  const AudioFileList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioFilesAsync = ref.watch(allAudioFilesProvider);
    final storageUsageAsync = ref.watch(audioStorageUsageProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Storage usage header
        storageUsageAsync.when(
          data: (usage) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Audio Storage: ${_formatFileSize(usage)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        
        // Audio files list
        audioFilesAsync.when(
          data: (files) {
            if (files.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.audiotrack_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No audio files',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return AudioFileListItem(file: file);
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                'Error loading audio files: $error',
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// Individual audio file list item
class AudioFileListItem extends ConsumerWidget {
  final AudioFileMetadata file;

  const AudioFileListItem({
    super.key,
    required this.file,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        Icons.audiotrack,
        color: theme.colorScheme.primary,
      ),
      title: Text(
        file.fileName,
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Duration: ${file.duration != null ? _formatDuration(file.duration!) : 'Unknown'}',
            style: theme.textTheme.bodySmall,
          ),
          Text(
            'Size: ${_formatFileSize(file.fileSizeBytes)}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
      trailing: IconButton(
        onPressed: () => _playAudio(ref),
        icon: const Icon(Icons.play_arrow),
        tooltip: 'Play audio',
      ),
    );
  }

  Future<void> _playAudio(WidgetRef ref) async {
    try {
      final audioControls = ref.read(audioControlsProvider);
      // Extract task ID from filename or use a default
      final taskId = _extractTaskIdFromPath(file.filePath) ?? 'unknown';
      await audioControls.playTask(taskId, file.filePath);
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  String? _extractTaskIdFromPath(String filePath) {
    // Try to extract task ID from file path or filename
    // Assuming the filename might contain task ID
    final fileName = filePath.split('/').last.split('\\').last;
    if (fileName.contains('_')) {
      return fileName.split('_').first;
    }
    return null;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}