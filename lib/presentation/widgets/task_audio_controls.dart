import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/typography_constants.dart';
import '../providers/audio_providers.dart';
import '../../services/audio/audio_player_service.dart';

enum AudioControlsMode {
  minimal,    // Just play button (28x28px)
  compact,    // Play button with duration (configurable width)  
  expanded,   // Full controls with seeking and skip buttons
}

/// Comprehensive audio playback controls for voice note tasks
class TaskAudioControls extends ConsumerStatefulWidget {
  final String taskId;
  final String audioFilePath;
  final AudioControlsMode mode;
  final double? width;
  final Duration? duration;
  final VoidCallback? onPlayToggle;

  const TaskAudioControls({
    super.key,
    required this.taskId,
    required this.audioFilePath,
    this.mode = AudioControlsMode.compact,
    this.width,
    this.duration,
    this.onPlayToggle,
  });

  @override
  ConsumerState<TaskAudioControls> createState() => _TaskAudioControlsState();
}

class _TaskAudioControlsState extends ConsumerState<TaskAudioControls> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAudioControls();
  }

  void _initializeAudioControls() {
    // Initialize audio controls if needed
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final audioControls = ref.read(audioControlsProvider);
    
    // Watch the audio playback state to get real-time updates
    final audioState = ref.watch(audioPlaybackStateProvider);
    final currentTaskId = ref.watch(currentPlayingTaskProvider);
    
    final isPlaying = audioState.when(
      data: (state) => currentTaskId == widget.taskId && state.isPlaying,
      loading: () => false,
      error: (_, __) => false,
    );

    switch (widget.mode) {
      case AudioControlsMode.minimal:
        return _buildMinimalControls(theme, audioControls, isPlaying);
      case AudioControlsMode.compact:
        return _buildCompactControls(theme, audioControls, isPlaying);
      case AudioControlsMode.expanded:
        return _buildExpandedControls(theme, audioControls, isPlaying);
    }
  }

  Widget _buildMinimalControls(ThemeData theme, AudioControls audioControls, bool isPlaying) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _togglePlayback(audioControls, isPlaying),
          child: Center(
            child: Icon(
              isPlaying ? PhosphorIcons.pause() : PhosphorIcons.play(),
              size: 14,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactControls(ThemeData theme, AudioControls audioControls, bool isPlaying) {
    final containerWidth = widget.width ?? 120.0;
    
    return Container(
      width: containerWidth,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/pause button
          GestureDetector(
            onTap: () => _togglePlayback(audioControls, isPlaying),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                isPlaying ? PhosphorIcons.pause() : PhosphorIcons.play(),
                size: 12,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Duration display
          Expanded(
            child: Text(
              _formatDuration(widget.duration ?? Duration.zero),
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: TypographyConstants.labelSmall, // 11.0 - Fixed accessibility violation (was 10px)
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedControls(ThemeData theme, AudioControls audioControls, bool isPlaying) {
    final audioState = ref.watch(audioPlaybackStateProvider);
    final currentTaskId = ref.watch(currentPlayingTaskProvider);
    final isCurrentTask = currentTaskId == widget.taskId;
    
    return Container(
      width: widget.width ?? 260.0, // Increased width for more controls
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Main controls row
          Row(
            children: [
              // Skip backward
              GestureDetector(
                onTap: () => _skipBackward(audioControls),
                child: Icon(
                  PhosphorIcons.skipBack(),
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Play/pause button
              GestureDetector(
                onTap: () => _togglePlayback(audioControls, isPlaying),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlaying ? PhosphorIcons.pause() : PhosphorIcons.play(),
                    size: 16,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Skip forward  
              GestureDetector(
                onTap: () => _skipForward(audioControls),
                child: Icon(
                  PhosphorIcons.skipForward(),
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Speed control
              GestureDetector(
                onTap: () => _showSpeedMenu(context, theme),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  ),
                  child: Text(
                    audioState.when(
                      data: (state) => isCurrentTask ? state.speed.label : '1x',
                      loading: () => '1x',
                      error: (_, __) => '1x',
                    ),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Duration display
              Text(
                audioState.when(
                  data: (state) => isCurrentTask ? 
                    '${_formatDuration(state.position)} / ${_formatDuration(state.duration)}' :
                    _formatDuration(widget.duration ?? Duration.zero),
                  loading: () => _formatDuration(widget.duration ?? Duration.zero),
                  error: (_, __) => _formatDuration(widget.duration ?? Duration.zero),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: TypographyConstants.labelSmall, // 11.0 - Fixed accessibility violation (was 10px)
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          
          // Progress bar
          const SizedBox(height: 4),
          if (isCurrentTask)
            audioState.when(
              data: (state) => LinearProgressIndicator(
                value: state.progress,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                minHeight: 3,
              ),
              loading: () => LinearProgressIndicator(
                value: null,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                minHeight: 3,
              ),
              error: (_, __) => const SizedBox.shrink(),
            )
          else
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
        ],
      ),
    );
  }

  bool _isCurrentTaskPlaying() {
    try {
      final audioControls = ref.read(audioControlsProvider);
      return audioControls.isTaskPlaying(widget.taskId);
    } catch (e) {
      debugPrint('Error checking task playing status: $e');
      return false;
    }
  }

  Future<void> _togglePlayback(AudioControls audioControls, bool isCurrentlyPlaying) async {
    try {
      if (isCurrentlyPlaying) {
        await audioControls.stopAll();
      } else {
        await audioControls.playTask(widget.taskId, widget.audioFilePath);
      }
      
      // Call the callback if provided
      widget.onPlayToggle?.call();
      
      // Trigger rebuild to update UI
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error toggling playback: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play audio: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _skipBackward(AudioControls audioControls) async {
    try {
      // Skip backward 10 seconds - would need to be implemented in audio controls
      debugPrint('Skip backward requested for task: ${widget.taskId}');
    } catch (e) {
      debugPrint('Error skipping backward: $e');
    }
  }

  Future<void> _skipForward(AudioControls audioControls) async {
    try {
      // Skip forward 10 seconds - would need to be implemented in audio controls
      debugPrint('Skip forward requested for task: ${widget.taskId}');
    } catch (e) {
      debugPrint('Error skipping forward: $e');
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _showSpeedMenu(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Playback Speed',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...PlaybackSpeed.values.map((speed) => ListTile(
              title: Text(speed.label),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final audioControls = ref.read(audioControlsProvider);
                  final notifier = ref.read(audioPlayerProvider.notifier);
                  await notifier.setSpeed(speed);
                } catch (e) {
                  debugPrint('Error setting playback speed: $e');
                }
              },
              contentPadding: EdgeInsets.zero,
            )),
          ],
        ),
      ),
    );
  }
}

/// Quick play button widget for simple audio playback
class QuickAudioPlayButton extends ConsumerWidget {
  final String taskId;
  final String audioFilePath;
  final double size;
  final Duration? duration;

  const QuickAudioPlayButton({
    super.key,
    required this.taskId,
    required this.audioFilePath,
    this.size = 20.0,
    this.duration,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TaskAudioControls(
      taskId: taskId,
      audioFilePath: audioFilePath,
      mode: AudioControlsMode.minimal,
      width: size,
      duration: duration,
    );
  }
}