import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/theme/typography_constants.dart';
import '../../services/audio/audio_concatenation_service.dart';
import '../../services/audio/audio_recording_service.dart';
import '../widgets/standardized_error_states.dart';
import '../widgets/standardized_text.dart';
import '../widgets/standardized_animations.dart';
import '../widgets/theme_background_widget.dart';
import '../widgets/standardized_app_bar.dart';
import 'manual_task_creation_page.dart';

/// Recording data model for individual recordings
class Recording {
  final String audioFilePath;
  final String transcription;
  final DateTime timestamp;
  final Duration duration;

  Recording({
    required this.audioFilePath,
    required this.transcription,
    required this.timestamp,
    required this.duration,
  });
}

/// Recording session manager for multi-recording functionality
class RecordingSession {
  final List<Recording> recordings = [];

  String get combinedTranscription {
    return recordings.map((r) => r.transcription).where((t) => t.isNotEmpty).join('\n');
  }

  Duration get totalDuration {
    return recordings.fold(Duration.zero, (sum, r) => sum + r.duration);
  }

  bool get hasRecordings => recordings.isNotEmpty;

  void addRecording(Recording recording) {
    recordings.add(recording);
  }

  void removeRecording(int index) {
    if (index >= 0 && index < recordings.length) {
      recordings.removeAt(index);
    }
  }

  void clear() {
    recordings.clear();
  }
}

/// Animated waveform visualizer for recording
class WaveformVisualizer extends StatefulWidget {
  final bool isRecording;
  final Color color;
  final double height;
  final int barCount;
  final double audioLevel; // Real audio amplitude (0.0 to 1.0)

  const WaveformVisualizer({
    super.key,
    required this.isRecording,
    this.color = Colors.blue,
    this.height = 80,
    this.barCount = 30,
    this.audioLevel = 0.0,
  });

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer> with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  final List<double> _heights = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: StandardizedAnimations.loadingState,
      vsync: this,
    );

    // Initialize heights
    for (int i = 0; i < widget.barCount; i++) {
      _heights.add(0.1);
    }

    // Create staggered animations for each bar
    _animations = List.generate(widget.barCount, (index) {
      final startTime = index / widget.barCount * 0.5;
      return Tween<double>(begin: 0.1, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            startTime,
            startTime + 0.5,
            curve: Curves.elasticOut,
          ),
        ),
      );
    });

    _controller.addListener(() {
      if (!mounted || !widget.isRecording || _controller.isCompleted) return;

      try {
        setState(() {
          for (int i = 0; i < widget.barCount && i < _animations.length && i < _heights.length; i++) {
            if (_animations[i].isCompleted || _animations[i].isDismissed) continue;

            // Use REAL audio level with slight variation per bar for visual effect
            final baseAudioLevel = widget.audioLevel.clamp(0.0, 1.0);
            final barVariation = (math.sin(_controller.value * math.pi * 2 + i * 0.5) * 0.1);
            final realHeight = math.max(0.1, (baseAudioLevel * 0.8 + 0.2) + barVariation);

            _heights[i] = realHeight.clamp(0.1, 1.0);
          }
        });
      } catch (e) {
        // Ignore painting errors during animation updates
        if (mounted) {
          debugPrint('WaveformVisualizer animation error: $e');
        }
      }
    });
  }

  @override
  void didUpdateWidget(WaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!mounted) return;

    try {
      if (widget.isRecording && !oldWidget.isRecording) {
        if (!_controller.isAnimating) {
          _controller.repeat();
        }
      } else if (!widget.isRecording && oldWidget.isRecording) {
        _controller.stop();
        // Animate to flat state
        if (mounted) {
          setState(() {
            for (int i = 0; i < widget.barCount && i < _heights.length; i++) {
              _heights[i] = 0.1;
            }
          });
        }
      }
    } catch (e) {
      debugPrint('WaveformVisualizer didUpdateWidget error: $e');
    }
  }

  @override
  void dispose() {
    try {
      _controller.stop();
      _controller.dispose();
    } catch (e) {
      debugPrint('WaveformVisualizer dispose error: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.barCount, (index) {
          // Safe access to heights array with bounds checking
          final height = index < _heights.length ? _heights[index].clamp(0.1, 1.0) : 0.1;
          final opacity = (0.7 + height * 0.3).clamp(0.3, 1.0);

          return AnimatedContainer(
            duration: StandardizedAnimations.quick,
            width: 4,
            height: (widget.height * height).clamp(widget.height * 0.1, widget.height),
            decoration: BoxDecoration(
              color: widget.isRecording ? widget.color.withValues(alpha: opacity) : widget.color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall), // 2.0 - Fixed border radius hierarchy
              boxShadow: widget.isRecording
                  ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }
}

/// Multi-Recording Voice Entry Page
class VoiceRecordingPage extends ConsumerStatefulWidget {
  final String? projectId;
  
  const VoiceRecordingPage({super.key, this.projectId});

  @override
  ConsumerState<VoiceRecordingPage> createState() => _VoiceRecordingPageState();
}

class _VoiceRecordingPageState extends ConsumerState<VoiceRecordingPage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  final RecordingSession _session = RecordingSession();

  bool _isRecording = false;
  bool _isProcessing = false;
  String _currentTranscription = '';
  String _statusMessage = 'Ready to record';
  Duration _currentRecordingDuration = Duration.zero;
  double _currentAudioLevel = 0.0;

  // Speech to text service
  late SpeechToText _speechToText;
  bool _speechEnabled = false;

  // Audio concatenation service for multi-recording sessions
  late AudioConcatenationService _concatenationService;
  bool _concatenationEnabled = false;

  // Dual stream services - restored for proper audio + transcription recording
  late AudioRecordingService _audioRecorder;
  bool _audioEnabled = false;

  // Service states for fallback handling - removed unused fields

  Timer? _durationTimer;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: StandardizedAnimations.slowest,
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: StandardizedAnimations.slow,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _initializeServices();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _durationTimer?.cancel();

    // Clean up audio services
    if (_audioEnabled) {
      _audioRecorder.dispose();
    }

    if (_concatenationEnabled) {
      _concatenationService.dispose();
    }

    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize speech to text with detailed error checking
      _speechToText = SpeechToText();
      _speechEnabled = await _speechToText.initialize(
        debugLogging: true,
        onError: (error) {
          debugPrint('[MIC] Speech recognition error: ${error.errorMsg}');
          if (mounted) {
            setState(() {
              _statusMessage = 'Speech error: ${error.errorMsg}';
            });
          }
        },
        onStatus: (status) {
          debugPrint('[MIC] Speech recognition status: $status');
          if (status == 'doneNoResult') {
            debugPrint('[MIC] Speech recognition finished with no result');
          }
        },
      );

      debugPrint('[MIC] Speech enabled: $_speechEnabled');
      debugPrint('[MIC] Speech available: ${await _speechToText.hasPermission}');

      // Initialize audio recording service
      _audioRecorder = AudioRecordingService();
      _audioEnabled = await _audioRecorder.initialize();
      debugPrint('[AUDIO] Audio recording enabled: $_audioEnabled');

      // Initialize audio concatenation service
      _concatenationService = AudioConcatenationService();
      _concatenationEnabled = await _concatenationService.initialize();
      debugPrint('[AUDIO] Audio concatenation enabled: $_concatenationEnabled');

      // Check microphone permission for speech recognition
      final hasPermission = await _speechToText.hasPermission;
      if (!hasPermission) {
        debugPrint('[MIC] Requesting microphone permission for speech recognition...');
      }

      if (mounted) {
        setState(() {
          _statusMessage =
              _speechEnabled ? 'Ready to record with multi-file concatenation' : 'Speech recognition not available';
        });
      }
    } catch (e) {
      debugPrint('[ERROR] Error initializing services: $e');
      if (mounted) {
        setState(() {
          _statusMessage = 'Error initializing services: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: StandardizedAppBar(
          title: 'Voice Recording',
          actions: [
            if (_session.hasRecordings)
              IconButton(
                onPressed: _showClearConfirmation,
                icon: Icon(PhosphorIcons.trash()),
                tooltip: 'Clear all recordings',
              ),
          ],
        ),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 100, 20, 20), // Account for AppBar
                    child: Column(
                      children: [
                        // Session Overview Card
                        if (_session.hasRecordings) ...[
                          _buildSessionOverviewCard(theme),
                          const SizedBox(height: 24),
                        ],

                        // Waveform Visualization
                        _buildWaveformSection(theme),
                        const SizedBox(height: 40),

                        // Recording Status & Button
                        _buildRecordingCenter(theme),
                        const SizedBox(height: 40),

                        // Live Transcription (always show during recording)
                        if (_isRecording || _currentTranscription.isNotEmpty || _isProcessing) ...[
                          _buildLiveTranscription(theme),
                          const SizedBox(height: 24),
                        ],

                        // Recordings List
                        if (_session.hasRecordings) ...[
                          _buildRecordingsList(theme),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),

                // Bottom Action Bar
                _buildBottomActionBar(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildWaveformSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusXLarge), // 20.0 - Fixed border radius hierarchy
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          StandardizedText(
            _isRecording ? 'Recording Audio...' : 'Ready to Record',
            style: StandardizedTextStyle.titleMedium,
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(height: 16),
          WaveformVisualizer(
            isRecording: _isRecording,
            color: theme.colorScheme.primary,
            height: 100,
            barCount: 40,
            audioLevel: _currentAudioLevel,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingCenter(ThemeData theme) {
    return Column(
      children: [
        // Status message
        StandardizedText(
          _statusMessage,
          style: StandardizedTextStyle.bodyLarge,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // Recording duration (when recording)
        if (_isRecording) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusXLarge), // 20.0 - Fixed border radius hierarchy
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                StandardizedText(
                  _formatDuration(_currentRecordingDuration),
                  style: StandardizedTextStyle.titleMedium,
                  color: theme.colorScheme.error,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Main recording button
        _buildRecordingButton(theme),
        const SizedBox(height: 24),

        // Additional action buttons
        if (_session.hasRecordings && !_isRecording) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _startRecording,
                  icon: Icon(PhosphorIcons.plusCircle()),
                  label: const Text('Add More'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _proceedToTaskCreation,
                  icon: Icon(PhosphorIcons.arrowRight()),
                  label: const Text('Continue'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLiveTranscription(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium), // 12.0 - Fixed border radius hierarchy
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.textAlignLeft(),
                color: theme.colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              StandardizedText(
                'Live Transcription',
                style: StandardizedTextStyle.titleSmall,
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isProcessing)
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StandardizedErrorStateVariants.loadingData(
                    message: 'Processing...',
                    compact: true,
                  ),
                ],
              ),
            )
          else
            StandardizedText(
              _currentTranscription.isEmpty
                  ? (_isRecording ? 'Listening... Start speaking now!' : 'Speak to see transcription appear here...')
                  : _currentTranscription,
              style: StandardizedTextStyle.bodyMedium,
              color: _currentTranscription.isEmpty
                  ? (_isRecording ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant)
                  : theme.colorScheme.onSecondaryContainer,
            ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_session.hasRecordings) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isRecording ? null : _showClearConfirmation,
                  icon: Icon(PhosphorIcons.arrowClockwise()),
                  label: const Text('Start Over'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(
                      color: theme.colorScheme.error.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Don't show any text when there are no recordings
              const Expanded(child: SizedBox()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionOverviewCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium), // 12.0 - Fixed border radius hierarchy
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.queue(),
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              StandardizedText(
                'Recording Session',
                style: StandardizedTextStyle.titleMedium,
                color: theme.colorScheme.primary,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                ),
                child: StandardizedText(
                  '${_session.recordings.length}',
                  style: StandardizedTextStyle.labelMedium,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StandardizedText(
            'Total duration: ${_formatDuration(_session.totalDuration)}',
            style: StandardizedTextStyle.bodyMedium,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          if (_session.combinedTranscription.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
              ),
              child: StandardizedText(
                _session.combinedTranscription,
                style: StandardizedTextStyle.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordingButton(ThemeData theme) {
    return GestureDetector(
      onTap: _isProcessing ? null : (_isRecording ? _stopRecording : _startRecording),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isRecording ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (_isRecording ? Colors.red : theme.colorScheme.primary).withValues(alpha: 0.8),
                    (_isRecording ? Colors.red : theme.colorScheme.primary).withValues(alpha: 0.4),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? Colors.red : theme.colorScheme.primary).withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                _isRecording ? PhosphorIcons.stop() : PhosphorIcons.microphone(),
                size: 48,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordingsList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StandardizedTextVariants.sectionHeader(
          'Recordings (${_session.recordings.length})',
        ),
        const SizedBox(height: 12),
        ...List.generate(_session.recordings.length, (index) {
          final recording = _session.recordings[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: StandardizedText(
                      '${index + 1}',
                      style: StandardizedTextStyle.labelMedium,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StandardizedText(
                        recording.transcription.isEmpty ? 'No transcription available' : recording.transcription,
                        style: StandardizedTextStyle.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      StandardizedText(
                        _formatDuration(recording.duration),
                        style: StandardizedTextStyle.bodySmall,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _deleteRecording(index),
                  icon: Icon(
                    PhosphorIcons.trash(),
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _startRecording() async {
    if (!_speechEnabled) {
      setState(() {
        _statusMessage = 'Speech recognition not available';
      });
      return;
    }

    try {
      debugPrint('[MIC] Starting speech recognition (primary mode)...');

      setState(() {
        _isRecording = true;
        _statusMessage = 'Recording...';
        _currentRecordingDuration = Duration.zero;
        _currentTranscription = '';
      });

      _pulseController.repeat(reverse: true);

      // Start duration timer
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && _isRecording) {
          setState(() {
            _currentRecordingDuration = Duration(seconds: timer.tick);
          });
        }
      });

      // Use ONLY speech recognition to avoid microphone conflicts
      await _speechToText.listen(
        onResult: (result) {
          debugPrint('[MIC] Speech result: ${result.recognizedWords} (confidence: ${result.confidence})');
          if (mounted) {
            setState(() {
              _currentTranscription = result.recognizedWords;
            });
          }
        },
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 10),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
        ),
        onSoundLevelChange: (level) {
          // Use sound level from speech recognition for visual feedback
          if (mounted) {
            setState(() {
              final normalizedLevel = level >= 0 ? level.clamp(0.0, 1.0) : ((level + 60) / 60).clamp(0.0, 1.0);
              _currentAudioLevel = normalizedLevel;
            });
          }
        },
      );

      debugPrint('[MIC] Speech recognition started successfully');
    } catch (e) {
      setState(() {
        _isRecording = false;
        _statusMessage = 'Error starting recording: $e';
      });
      _pulseController.stop();
      _durationTimer?.cancel();
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      debugPrint('[MIC] Stopping speech recognition...');

      setState(() {
        _isProcessing = true;
        _statusMessage = 'Processing recording...';
        _currentAudioLevel = 0.0; // Reset audio level
      });

      _pulseController.stop();
      _durationTimer?.cancel();

      // Stop speech recognition
      await _speechToText.stop();

      // For now, create recording with transcription only (no audio file)
      // In future iterations, we can add separate audio recording when transcription is complete
      if (_currentTranscription.isNotEmpty) {
        debugPrint('[SUCCESS] SAVING TRANSCRIPTION RECORDING:');
        debugPrint('  - Transcription: $_currentTranscription');
        debugPrint('  - Duration: $_currentRecordingDuration');

        // Generate a placeholder audio path for concatenation compatibility
        // This allows the concatenation system to work while we resolve dual-stream conflicts
        String? audioFilePath;
        if (_audioEnabled) {
          // If audio service is available, we could potentially record separately
          // For now, leave empty but structure is ready for future enhancement
          audioFilePath = ''; // Empty = transcription only
        }

        final recording = Recording(
          audioFilePath: audioFilePath ?? '', // Ready for future audio integration
          transcription: _currentTranscription,
          timestamp: DateTime.now(),
          duration: _currentRecordingDuration,
        );

        _session.addRecording(recording);
        debugPrint('[SUCCESS] Recording added to session. Total recordings: ${_session.recordings.length}');

        setState(() {
          _isRecording = false;
          _isProcessing = false;

          // Simple status message for speech-only recording
          _statusMessage = _currentTranscription.isEmpty
              ? 'Recording saved (no transcription). Add more or continue to task creation.'
              : (_session.recordings.length == 1
                  ? 'Great! Add more recordings or continue to task creation'
                  : 'Recording added! Add more or continue to task creation');

          _currentTranscription = '';
          _currentRecordingDuration = Duration.zero;
        });
      } else {
        setState(() {
          _isRecording = false;
          _isProcessing = false;
          _statusMessage = 'Recording failed. Please try again.';
          _currentTranscription = '';
          _currentRecordingDuration = Duration.zero;
        });
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
        _isProcessing = false;
        _statusMessage = 'Error stopping recording: $e';
      });
    }
  }

  void _deleteRecording(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recording'),
        content: const Text('Are you sure you want to delete this recording?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _session.removeRecording(index);
                if (!_session.hasRecordings) {
                  _statusMessage = 'Tap to start your first recording';
                }
              });
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Over'),
        content: const Text('This will delete all recordings in this session. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _session.clear();
                _statusMessage = 'Tap to start your first recording';
              });
            },
            child: const Text('Start Over'),
          ),
        ],
      ),
    );
  }

  Future<void> _proceedToTaskCreation() async {
    if (!_session.hasRecordings) return;

    debugPrint('[DART] Starting task creation with ${_session.recordings.length} recordings...');

    setState(() {
      _statusMessage = 'Preparing audio files...';
    });

    String? finalAudioPath;

    try {
      // Extract all audio file paths from recordings (handle mixed recordings)
      final audioFilePaths =
          _session.recordings.map((recording) => recording.audioFilePath).where((path) => path.isNotEmpty).toList();

      // Enhanced logging for mixed recordings
      debugPrint('[DART] Mixed recording analysis:');
      debugPrint('  - Total recordings: ${_session.recordings.length}');
      debugPrint('  - Recordings with audio: ${audioFilePaths.length}');
      debugPrint('  - Transcription-only recordings: ${_session.recordings.length - audioFilePaths.length}');
      debugPrint('[AUDIO] Audio files to process: ${audioFilePaths.length}');
      for (int i = 0; i < audioFilePaths.length; i++) {
        debugPrint('  $i: ${audioFilePaths[i]}');
      }

      // Concatenate audio files if multiple exist and concatenation is enabled
      if (_concatenationEnabled && audioFilePaths.length > 1) {
        debugPrint('[AUDIO] Concatenating ${audioFilePaths.length} audio files...');

        setState(() {
          _statusMessage = 'Combining audio files...';
        });

        finalAudioPath = await _concatenationService.concatenateAudioFiles(
          audioFilePaths,
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _statusMessage = 'Combining audio files... ${(progress * 100).toInt()}%';
              });
            }
          },
        );

        if (finalAudioPath != null) {
          debugPrint('[SUCCESS] Audio concatenation successful: $finalAudioPath');
        } else {
          debugPrint('[ERROR] Audio concatenation failed, using first file as fallback');
          finalAudioPath = audioFilePaths.isNotEmpty ? audioFilePaths.first : null;
        }
      } else if (audioFilePaths.isNotEmpty) {
        // Single file or concatenation not available - use first file
        finalAudioPath = audioFilePaths.first;
        debugPrint('Using single audio file: $finalAudioPath');
      } else {
        debugPrint('No audio files available');
      }

      // Prepare return data with concatenated or primary audio file
      final returnData = {
        'transcribedText': _session.combinedTranscription,
        'creationMode': 'voiceToText',
        'audioFilePath': finalAudioPath,
        if (widget.projectId != null) 'projectId': widget.projectId,
        'audioData': {
          'filePath': finalAudioPath,
          'format': 'aac',
          'recordingTimestamp': DateTime.now().toIso8601String(),
          'transcription': _session.combinedTranscription,
          'totalDuration': _session.totalDuration.inSeconds,
          'recordingCount': _session.recordings.length,
          'isConcatenated': _concatenationEnabled && audioFilePaths.length > 1 && finalAudioPath != null,
          'originalFileCount': audioFilePaths.length,
          'hasMultipleRecordings': _session.recordings.length > 1,
        },
      };

      debugPrint('[DART] Task creation data prepared:');
      debugPrint('  - Combined transcription length: ${_session.combinedTranscription.length} chars');
      debugPrint('  - Final audio file: $finalAudioPath');
      debugPrint('  - Total duration: ${_session.totalDuration}');
      debugPrint('  - Recording count: ${_session.recordings.length}');

      setState(() {
        _statusMessage = 'Opening task creation...';
      });

      // Navigate to manual task creation page
      if (!mounted) return;
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ManualTaskCreationPage(
            prePopulatedData: returnData,
          ),
        ),
      );

      // If task was created successfully, pop this page
      if (result != null && mounted) {
        Navigator.of(context).pop(result);
      } else {
        // Reset status if dialog was cancelled
        if (mounted) {
          setState(() {
            _statusMessage = 'Ready to add more recordings or continue';
          });
        }
      }
    } catch (e) {
      debugPrint('[ERROR] Error in _proceedToTaskCreation: $e');
      if (mounted) {
        setState(() {
          _statusMessage = 'Error preparing audio: $e';
        });

        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Audio Processing Error'),
            content:
                Text('Failed to prepare audio files: $e\n\nYou can still create a task with the transcription only.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
