import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:async';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../providers/audio_providers.dart';
import '../providers/task_provider.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/theme_background_widget.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/theme/material3/motion_system.dart';
import '../../services/audio/audio_concatenation_service.dart';
import '../../domain/models/audio_models.dart';
import 'task_detail_page.dart';

/// Ultra-modern full-screen voice-only task creation page
class VoiceOnlyCreationPage extends ConsumerStatefulWidget {
  const VoiceOnlyCreationPage({super.key});

  @override
  ConsumerState<VoiceOnlyCreationPage> createState() => _VoiceOnlyCreationPageState();
}

class _VoiceOnlyCreationPageState extends ConsumerState<VoiceOnlyCreationPage>
    with TickerProviderStateMixin {
  
  // Controllers
  final _titleController = TextEditingController();
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  
  // State
  bool _isRecording = false;
  bool _hasRecording = false;
  bool _isProcessing = false;
  String? _audioFilePath;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  TaskPriority _priority = TaskPriority.medium;
  
  // Advanced audio features
  final List<AudioSegment> _audioSegments = [];
  bool _isPlaying = false;
  bool _isPaused = false;
  double _playbackSpeed = 1.0;
  Duration _playbackPosition = Duration.zero;
  final Duration _totalDuration = Duration.zero;
  Timer? _playbackTimer;
  String _customFileName = '';
  AudioQuality _selectedQuality = AudioQuality.high;
  String? _currentPlaybackTaskId;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: ExpressiveMotionSystem.durationLong1,
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium2,
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _fadeController.forward();
    
    // Initialize custom filename with timestamp
    _customFileName = 'Voice Note ${DateTime.now().day}/${DateTime.now().month}';
    
    // Initialize audio recording service
    _initializeAudioService();
  }
  
  Future<void> _initializeAudioService() async {
    try {
      final audioService = ref.read(audioRecordingServiceProvider);
      await audioService.initialize();
      debugPrint('Audio recording service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize audio recording service: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize audio recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Main content - full screen
            SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 60, // Account for status bar + floating button
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Title Section
                    _buildTitleSection(context, theme),
                    
                    const SizedBox(height: 32),
                    
                    // Priority Section
                    _buildPrioritySection(context, theme),
                    
                    const SizedBox(height: 32),
                    
                    // Recording Section - Main focal point
                    _buildRecordingSection(context, theme),
                    
                    const SizedBox(height: 16),
                    
                    // Audio Segments Section
                    if (_audioSegments.isNotEmpty)
                      _buildAudioSegmentsSection(context, theme),
                    
                    const SizedBox(height: 16),
                    
                    // Advanced Controls Section
                    if (_hasRecording || _audioSegments.isNotEmpty)
                      _buildAdvancedControlsSection(context, theme),
                    
                    const SizedBox(height: 16),
                    
                    // File Management Section
                    _buildFileManagementSection(context, theme),
                    
                    const SizedBox(height: 16),
                    
                    // Action Buttons
                    if (_hasRecording || _audioSegments.isNotEmpty)
                      _buildActionButtons(context, theme),
                    
                    const SizedBox(height: 100), // Bottom padding
                  ],
                ),
              ),
            ),
            
            // Floating navigation buttons
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface.withValues(alpha: 0.9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      PhosphorIcons.arrowLeft(),
                      color: theme.colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            
            // Floating clear button (only show if has recording)
            _hasRecording ? Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: _deleteRecording,
                      child: Icon(
                        PhosphorIcons.trash(),
                        color: theme.colorScheme.onErrorContainer,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ) : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTitleSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.chatCircle(),
                size: 24,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Voice Note',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: TypographyConstants.medium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Enter a title for your voice note...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              ),
            ),
            enabled: !_isProcessing && !_isRecording,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPrioritySection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.flag(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Priority',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: TypographyConstants.medium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: TaskPriority.values.map((priority) {
              final isSelected = _priority == priority;
              final color = priority == TaskPriority.high
                  ? theme.colorScheme.error
                  : priority == TaskPriority.medium
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.tertiary;
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() => _priority = priority),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? color : theme.colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              priority == TaskPriority.high ? PhosphorIcons.caretUp() :
                              priority == TaskPriority.medium ? PhosphorIcons.minus() :
                              PhosphorIcons.caretDown(),
                              color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              priority.name.toUpperCase(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: TypographyConstants.medium,
                                color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecordingSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(32),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        children: [
          // Status text
          Text(
            _getStatusText(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: TypographyConstants.medium,
              color: _isRecording
                  ? theme.colorScheme.error
                  : _hasRecording
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Recording button
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _getRecordingButtonColors(theme),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getRecordingButtonColors(theme)[0].withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(60),
                  onTap: _isProcessing ? null : _toggleRecording,
                  child: Center(
                    child: _isProcessing 
                        ? const SizedBox(width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Icon(
                            _getRecordingButtonIcon(),
                            color: Colors.white,
                            size: 48,
                          ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Duration display
          Text(
            _formatDuration(_recordingDuration),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontFamily: 'Courier',
              fontWeight: FontWeight.w500,
              color: _isRecording
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
          
          if ((_hasRecording || _audioSegments.isNotEmpty) && !_isRecording) ...[ 
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: OutlinedButton.icon(
                    onPressed: _deleteRecording,
                    icon: PhosphorIcon(PhosphorIcons.trash(), size: 14),
                    label: const Text(
                      'Delete All',
                      style: TextStyle(fontSize: 11),
                      overflow: TextOverflow.visible,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      minimumSize: const Size(80, 44),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: _addNewSegment,
                    icon: PhosphorIcon(PhosphorIcons.plus(), size: 14),
                    label: const Text(
                      'Add',
                      style: TextStyle(fontSize: 11),
                      overflow: TextOverflow.visible,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      minimumSize: const Size(60, 44),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: _playRecording,
                    icon: PhosphorIcon(
                      _isPlaying ? PhosphorIcons.pause() : 
                      _isPaused ? PhosphorIcons.play() : PhosphorIcons.play(),
                      size: 14,
                    ),
                    label: Text(
                      _isPlaying ? 'Pause' : 
                      _isPaused ? 'Resume' : 'Play',
                      style: const TextStyle(fontSize: 11),
                      overflow: TextOverflow.visible,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      minimumSize: const Size(70, 44),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: PhosphorIcon(PhosphorIcons.x()),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _canCreateTask() && !_isProcessing ? _createVoiceTask : null,
            icon: _isProcessing
                ? const SizedBox(width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : PhosphorIcon(PhosphorIcons.plus()),
            label: Text(_isProcessing ? 'Creating...' : 'Create Voice Note'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      final audioService = ref.read(audioRecordingServiceProvider);
      
      // Check if service is initialized
      if (!audioService.isInitialized) {
        await audioService.initialize();
      }
      
      // Check permissions
      if (!await audioService.hasPermission()) {
        final granted = await audioService.requestPermission();
        if (!granted) {
          _showError('Microphone permission is required to record audio');
          return;
        }
      }
      
      await audioService.startRecording();

      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });

      _pulseController.repeat(reverse: true);

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordingDuration = Duration(seconds: timer.tick);
          });
        }
      });
    } catch (e) {
      debugPrint('Recording error: $e');
      _showError('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final audioService = ref.read(audioRecordingServiceProvider);
      final audioPath = await audioService.stopRecording();

      if (audioPath != null) {
        // Create audio segment for multi-segment recording
        final segment = AudioSegment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          filePath: audioPath,
          duration: _recordingDuration,
          recordedAt: DateTime.now(),
          title: 'Segment ${_audioSegments.length + 1}',
        );
        
        _audioSegments.add(segment);
        
        // If this is the first recording, set it as the main audio file
        if (_audioSegments.length == 1) {
          _audioFilePath = audioPath;
        }
      }

      setState(() {
        _isRecording = false;
        _hasRecording = _audioSegments.isNotEmpty;
      });

      _pulseController.stop();
      _recordingTimer?.cancel();

      if (_hasRecording && _titleController.text.isEmpty) {
        _titleController.text = _customFileName;
      }
    } catch (e) {
      _showError('Failed to stop recording: $e');
      setState(() {
        _isRecording = false;
      });
      _pulseController.stop();
      _recordingTimer?.cancel();
    }
  }

  Future<void> _deleteRecording() async {
    setState(() {
      _hasRecording = false;
      _audioFilePath = null;
      _recordingDuration = Duration.zero;
      _audioSegments.clear();
    });
  }
  
  Future<void> _deleteSegment(int index) async {
    if (index >= 0 && index < _audioSegments.length) {
      setState(() {
        _audioSegments.removeAt(index);
        _hasRecording = _audioSegments.isNotEmpty;
        if (_audioSegments.isEmpty) {
          _audioFilePath = null;
        } else {
          _audioFilePath = _audioSegments.first.filePath;
        }
      });
    }
  }
  
  Future<void> _addNewSegment() async {
    // Reset for new recording
    setState(() {
      _recordingDuration = Duration.zero;
    });
    await _startRecording();
  }

  Future<void> _playRecording() async {
    if (_isPlaying) {
      await _pausePlayback();
    } else if (_isPaused) {
      await _resumePlayback();
    } else {
      await _startPlayback();
    }
  }
  
  Future<void> _startPlayback() async {
    try {
      // Determine which audio file to play
      String? audioPath;
      Duration totalDuration = Duration.zero;
      
      if (_audioSegments.isNotEmpty) {
        // For multi-segment recordings, concatenate first if we have more than one segment
        if (_audioSegments.length > 1) {
          try {
            final concatenationService = AudioConcatenationService();
            await concatenationService.initialize();
            
            final segmentPaths = _audioSegments.map((s) => s.filePath).toList();
            final concatenatedPath = await concatenationService.concatenateAudioFiles(
              segmentPaths,
              outputFileName: 'preview_${DateTime.now().millisecondsSinceEpoch}.aac',
            );
            
            if (concatenatedPath != null) {
              audioPath = concatenatedPath;
              debugPrint('✅ Using concatenated audio file: $audioPath');
            } else {
              // Fallback to last segment if concatenation fails
              audioPath = _audioSegments.last.filePath;
              debugPrint('⚠️ Concatenation failed, using last segment: $audioPath');
            }
          } catch (e) {
            debugPrint('⚠️ Concatenation error: $e, using last segment');
            audioPath = _audioSegments.last.filePath;
          }
        } else {
          // Single segment
          audioPath = _audioSegments.first.filePath;
        }
        
        totalDuration = _audioSegments.fold(
          Duration.zero, 
          (prev, segment) => prev + segment.duration,
        );
      } else if (_audioFilePath != null) {
        audioPath = _audioFilePath;
        totalDuration = _recordingDuration;
      }
      
      if (audioPath != null && audioPath.isNotEmpty) {
        debugPrint('🎵 Starting playback of: $audioPath');
        final audioControls = ref.read(audioControlsProvider);
        
        // Make sure any previous playback is stopped
        await audioControls.stopAll();
        
        // Start playback with unique task ID
        _currentPlaybackTaskId = 'voice_preview_${DateTime.now().millisecondsSinceEpoch}';
        await audioControls.playTask(_currentPlaybackTaskId!, audioPath);
        
        setState(() {
          _isPlaying = true;
          _isPaused = false;
          _playbackPosition = Duration.zero;
        });
        
        _startPlaybackTimer(totalDuration);
        debugPrint('✅ Playback started successfully');
      } else {
        _showError('No audio file available to play');
      }
    } catch (e) {
      debugPrint('❌ Playback error: $e');
      _showError('Failed to play recording: $e');
      setState(() {
        _isPlaying = false;
        _isPaused = false;
      });
    }
  }
  
  Future<void> _pausePlayback() async {
    try {
      if (_currentPlaybackTaskId != null) {
        final audioControls = ref.read(audioControlsProvider);
        await audioControls.pauseTask(_currentPlaybackTaskId!);
        
        setState(() {
          _isPlaying = false;
          _isPaused = true;
        });
        
        _playbackTimer?.cancel();
      }
    } catch (e) {
      _showError('Failed to pause playback: $e');
    }
  }
  
  Future<void> _resumePlayback() async {
    try {
      if (_currentPlaybackTaskId != null) {
        final audioControls = ref.read(audioControlsProvider);
        await audioControls.resumeTask(_currentPlaybackTaskId!);
        
        setState(() {
          _isPlaying = true;
          _isPaused = false;
        });
        
        // Calculate total duration for timer
        final totalDuration = _audioSegments.isNotEmpty
            ? _audioSegments.fold(Duration.zero, (prev, segment) => prev + segment.duration)
            : _recordingDuration;
        _startPlaybackTimer(totalDuration);
      }
    } catch (e) {
      _showError('Failed to resume playback: $e');
    }
  }
  
  Future<void> _stopPlayback() async {
    try {
      if (_currentPlaybackTaskId != null) {
        final audioControls = ref.read(audioControlsProvider);
        await audioControls.stopTask(_currentPlaybackTaskId!);
        
        setState(() {
          _isPlaying = false;
          _isPaused = false;
          _playbackPosition = Duration.zero;
        });
        
        _currentPlaybackTaskId = null; // Clear task ID
        
        _playbackTimer?.cancel();
      }
    } catch (e) {
      _showError('Failed to stop playback: $e');
    }
  }
  
  void _startPlaybackTimer(Duration totalDuration) {
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && _isPlaying) {
        setState(() {
          _playbackPosition += const Duration(milliseconds: 100);
          if (_playbackPosition >= totalDuration) {
            _stopPlayback();
          }
        });
      }
    });
  }
  
  Future<void> _seekTo(Duration position) async {
    try {
      if (_currentPlaybackTaskId != null) {
        final audioControls = ref.read(audioControlsProvider);
        await audioControls.seekTask(_currentPlaybackTaskId!, position);
        
        setState(() {
          _playbackPosition = position;
        });
      }
    } catch (e) {
      _showError('Failed to seek: $e');
    }
  }
  
  Future<void> _setPlaybackSpeed(double speed) async {
    setState(() {
      _playbackSpeed = speed;
    });
    // Note: Speed control would need to be implemented in audio service
  }

  Future<void> _createVoiceTask() async {
    if (!_canCreateTask()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      String? finalAudioPath = _audioFilePath;
      Duration totalDuration = _recordingDuration;
      
      // If multiple segments, concatenate them
      if (_audioSegments.length > 1) {
        final concatenationService = AudioConcatenationService();
        await concatenationService.initialize();
        
        final segmentPaths = _audioSegments.map((s) => s.filePath).toList();
        finalAudioPath = await concatenationService.concatenateAudioFiles(
          segmentPaths,
          outputFileName: '${_customFileName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.aac',
          onProgress: (progress) {
            if (mounted) {
              // Could show progress indicator here
            }
          },
        );
        
        // Calculate total duration from all segments
        totalDuration = _audioSegments.fold(
          Duration.zero, 
          (prev, segment) => prev + segment.duration,
        );
      }

      final task = TaskModel.create(
        title: _titleController.text.trim(),
        priority: _priority,
        metadata: {
          // Standard audio metadata format for compatibility
          'audio': {
            'filePath': finalAudioPath,
            'duration': totalDuration.inSeconds,
            'format': 'aac',
            'fileSize': null, // Could be added later if needed
            'recordingTimestamp': DateTime.now().toIso8601String(),
          },
          // Creation metadata
          'creationMode': 'voiceOnly',
          'isVoiceCreated': true,
          'hasTranscription': false,
          // Additional voice metadata
          'voice': {
            'segmentsCount': _audioSegments.length,
            'quality': _selectedQuality.name,
            'customFileName': _customFileName,
          },
        },
      );

      await ref.read(taskOperationsProvider).createTask(task);

      if (mounted) {
        // REQ 7: Guide to task edit page after recording (consistent UX flow)
        Navigator.of(context).pop(); // Pop the voice creation page
        
        // Navigate to task detail page for editing
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailPage(taskId: task.id),
          ),
        );
        
        final segmentText = _audioSegments.length > 1 
            ? ' (${_audioSegments.length} segments combined)' 
            : '';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice note created$segmentText! You can now add more details.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to create voice task: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  bool _canCreateTask() {
    return _titleController.text.trim().isNotEmpty && (_hasRecording || _audioSegments.isNotEmpty);
  }

  String _getStatusText() {
    if (_isRecording) return 'Recording voice note...';
    if (_audioSegments.isNotEmpty) {
      if (_audioSegments.length == 1) {
        return 'Voice note ready to save';
      } else {
        return '${_audioSegments.length} segments recorded';
      }
    }
    return 'Tap to record your voice note';
  }

  List<Color> _getRecordingButtonColors(ThemeData theme) {
    if (_isRecording) return [Colors.red, Colors.red.withValues(alpha: 0.8)];
    if (_hasRecording) return [Colors.green, Colors.green.withValues(alpha: 0.8)];
    return [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)];
  }

  IconData _getRecordingButtonIcon() {
    if (_isRecording) return PhosphorIcons.stop();
    if (_hasRecording) return PhosphorIcons.check();
    return PhosphorIcons.microphone();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}';
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Build audio segments section for multi-segment recording
  Widget _buildAudioSegmentsSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.waveform(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Audio Segments (${_audioSegments.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: TypographyConstants.medium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(_audioSegments.length, (index) {
            final segment = _audioSegments[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.waveform(),
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          segment.title ?? 'Segment ${index + 1}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatDuration(segment.duration),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(PhosphorIcons.trash(), size: 16),
                    onPressed: () => _deleteSegment(index),
                    color: theme.colorScheme.error,
                    iconSize: 16,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Build advanced controls section
  Widget _buildAdvancedControlsSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.sliders(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Playback Controls',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: TypographyConstants.medium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Seek bar
          if (_totalDuration.inSeconds > 0) ...[
            Row(
              children: [
                Text(
                  _formatDuration(_playbackPosition),
                  style: theme.textTheme.bodySmall,
                ),
                Expanded(
                  child: Slider(
                    value: _totalDuration.inSeconds > 0 
                        ? _playbackPosition.inSeconds / _totalDuration.inSeconds
                        : 0.0,
                    onChanged: (value) {
                      final newPosition = Duration(
                        seconds: (_totalDuration.inSeconds * value).round(),
                      );
                      _seekTo(newPosition);
                    },
                  ),
                ),
                Text(
                  _formatDuration(_totalDuration),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          
          // Playback speed controls
          Row(
            children: [
              Text(
                'Speed: ',
                style: theme.textTheme.bodyMedium,
              ),
              ...List.generate([0.5, 1.0, 1.5, 2.0].length, (index) {
                final speed = [0.5, 1.0, 1.5, 2.0][index];
                final isSelected = _playbackSpeed == speed;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text('${speed}x'),
                    selected: isSelected,
                    onSelected: (_) => _setPlaybackSpeed(speed),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  /// Build file management section
  Widget _buildFileManagementSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.folder(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'File Settings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: TypographyConstants.medium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Custom filename
          TextFormField(
            initialValue: _customFileName,
            decoration: InputDecoration(
              labelText: 'Custom filename',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(PhosphorIcons.textT()),
            ),
            onChanged: (value) {
              setState(() {
                _customFileName = value;
                if (value.isNotEmpty) {
                  _titleController.text = value;
                }
              });
            },
          ),
          
          const SizedBox(height: 12),
          
          // Audio quality selection
          DropdownButtonFormField<AudioQuality>(
            initialValue: _selectedQuality,
            decoration: InputDecoration(
              labelText: 'Audio Quality',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(PhosphorIcons.waveform()),
            ),
            items: AudioQuality.values.map((quality) {
              return DropdownMenuItem(
                value: quality,
                child: Text(quality.displayName),
              );
            }).toList(),
            onChanged: (quality) {
              if (quality != null) {
                setState(() {
                  _selectedQuality = quality;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}

