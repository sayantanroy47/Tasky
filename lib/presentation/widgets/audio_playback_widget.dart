import 'package:flutter/material.dart';
import '../../core/theme/typography_constants.dart';
import '../../services/audio/audio_playback_service.dart';
import '../../domain/entities/task_audio_metadata.dart';

/// Widget for playing back audio files attached to tasks
class AudioPlaybackWidget extends StatefulWidget {
  final String audioFilePath;
  final Duration? audioDuration;
  final bool isCompact;

  const AudioPlaybackWidget({
    super.key,
    required this.audioFilePath,
    this.audioDuration,
    this.isCompact = false,
  });

  @override
  State<AudioPlaybackWidget> createState() => _AudioPlaybackWidgetState();
}

class _AudioPlaybackWidgetState extends State<AudioPlaybackWidget> {
  final AudioPlaybackService _playbackService = AudioPlaybackService();
  bool _isInitialized = false;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final initialized = await _playbackService.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = initialized;
          _totalDuration = widget.audioDuration ?? Duration.zero;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize audio player';
        });
      }
    }
  }

  @override
  void dispose() {
    _playbackService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (!_isInitialized) {
      return _buildLoadingWidget();
    }

    if (widget.isCompact) {
      return _buildCompactPlayer();
    } else {
      return _buildFullPlayer();
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 4),
          Text(
            'Audio error',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text(
            'Loading audio...',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPlayer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.audiotrack,
            size: 16,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: _togglePlayback,
            child: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              size: 20,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _formatDuration(_totalDuration),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullPlayer() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.audiotrack,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Voice Recording',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  _formatDuration(_totalDuration),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress bar
            if (_totalDuration > Duration.zero) ...[
              LinearProgressIndicator(
                value: _totalDuration > Duration.zero 
                  ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds 
                  : 0.0,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_currentPosition),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    _formatDuration(_totalDuration - _currentPosition),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Playback controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _rewind,
                  icon: const Icon(Icons.replay_10),
                  tooltip: 'Rewind 10s',
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _togglePlayback,
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle : Icons.play_circle,
                    size: 48,
                  ),
                  tooltip: _isPlaying ? 'Pause' : 'Play',
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _fastForward,
                  icon: const Icon(Icons.forward_10),
                  tooltip: 'Fast forward 10s',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePlayback() async {
    if (!_isInitialized) return;

    try {
      if (_isPlaying) {
        await _playbackService.stopPlayback();
        setState(() {
          _isPlaying = false;
          _currentPosition = Duration.zero;
        });
      } else {
        await _playbackService.playAudioFile(
          widget.audioFilePath,
          onProgress: (position, duration) {
            if (mounted) {
              setState(() {
                _currentPosition = position;
                if (duration > Duration.zero && _totalDuration == Duration.zero) {
                  _totalDuration = duration;
                }
              });
            }
          },
          onComplete: () {
            if (mounted) {
              setState(() {
                _isPlaying = false;
                _currentPosition = Duration.zero;
              });
            }
          },
        );
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Playback error: ${e.toString()}';
        _isPlaying = false;
      });
    }
  }

  Future<void> _rewind() async {
    if (!_isPlaying) return;
    
    final newPosition = _currentPosition - const Duration(seconds: 10);
    final targetPosition = newPosition < Duration.zero ? Duration.zero : newPosition;
    await _playbackService.seekTo(targetPosition);
  }

  Future<void> _fastForward() async {
    if (!_isPlaying) return;
    
    final newPosition = _currentPosition + const Duration(seconds: 10);
    final targetPosition = newPosition > _totalDuration ? _totalDuration : newPosition;
    await _playbackService.seekTo(targetPosition);
  }

  String _formatDuration(Duration duration) {
    return TaskAudioMetadata.formatAudioDuration(duration);
  }
}