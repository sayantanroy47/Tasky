import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/theme/material3/motion_system.dart';
import '../../core/design_system/design_tokens.dart' hide BorderRadius;
import '../../domain/entities/task_model.dart';
import '../../domain/entities/recurrence_pattern.dart';
import '../../domain/models/enums.dart';
import '../providers/task_provider.dart' show taskOperationsProvider;
import '../providers/audio_providers.dart';
import '../../services/audio/audio_file_manager.dart';
import '../../services/audio/audio_recording_service.dart';
import 'glassmorphism_container.dart';
import 'recurring_task_scheduling_widget.dart';
import 'theme_aware_dialog_components.dart';
import 'dart:async';
import 'dart:io';

/// Voice-Only Task Creation Dialog - records audio without transcription
class VoiceOnlyCreationDialog extends ConsumerStatefulWidget {
  const VoiceOnlyCreationDialog({super.key});
  
  @override
  ConsumerState<VoiceOnlyCreationDialog> createState() => _VoiceOnlyCreationDialogState();
}

class _VoiceOnlyCreationDialogState extends ConsumerState<VoiceOnlyCreationDialog>
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _hasRecording = false;
  String _statusMessage = 'Tap to start recording';
  Duration _recordingDuration = Duration.zero;
  String? _audioFilePath;
  
  // Real audio recording service
  final AudioRecordingService _audioService = AudioRecordingService();
  bool _isAudioInitialized = false;
  
  // Recurring task scheduling
  RecurrencePattern? _recurrencePattern;
  
  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium3,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium2,
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: ExpressiveMotionSystem.emphasizedDecelerate,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: ExpressiveMotionSystem.emphasizedDecelerate,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _initializeAudioService();
    _fadeController.forward();
    _scaleController.forward();
  }
  
  Future<void> _initializeAudioService() async {
    try {
      _isAudioInitialized = await _audioService.initialize();
      if (_isAudioInitialized) {
        setState(() {
          _statusMessage = 'Ready to record';
        });
      } else {
        setState(() {
          _statusMessage = 'Audio recording not available';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error initializing audio: $e';
      });
      debugPrint('Error initializing audio service: $e');
    }
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _audioService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ThemeAwareTaskDialog(
          title: 'Voice Only Task',
          subtitle: 'Record audio task without transcription',
          icon: Icons.record_voice_over,
          onBack: () => Navigator.of(context).pop(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRecordingVisualization(theme),
                  const SizedBox(height: 24),
                  _buildStatusMessage(theme),
                  const SizedBox(height: 8),
                  _buildRecordingDuration(theme),
                  const SizedBox(height: 24),
                  _buildRecurrenceWidget(),
                  _buildActionButtons(theme),
                ],
              ),
            ),
        ),
      ),
    );
  }

  // Header is now handled by ThemeAwareTaskDialog - this method is no longer needed

  Widget _buildRecordingVisualization(ThemeData theme) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: _toggleRecording,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  _isRecording 
                      ? Colors.red.withOpacity(0.3)
                      : theme.colorScheme.secondary.withOpacity(0.3),
                  _isRecording 
                      ? Colors.red.withOpacity(0.1)
                      : theme.colorScheme.secondary.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.3, 0.6, 1.0],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: _isRecording 
                    ? Colors.red
                    : theme.colorScheme.secondary,
                width: _isRecording ? 3 : 2,
              ),
            ),
            child: Transform.scale(
              scale: _isRecording ? _pulseAnimation.value : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _isRecording 
                          ? Colors.red
                          : theme.colorScheme.secondary,
                      _isRecording 
                          ? Colors.red.shade700
                          : theme.colorScheme.tertiary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusMessage(ThemeData theme) {
    return Text(
      _statusMessage,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRecordingDuration(ThemeData theme) {
    if (!_isRecording && !_hasRecording) return const SizedBox.shrink();
    
    return Text(
      _formatDuration(_recordingDuration),
      style: theme.textTheme.titleMedium?.copyWith(
        color: _isRecording ? Colors.red : theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRecurrenceWidget() {
    if (!_hasRecording) return const SizedBox.shrink();
    
    return Column(
      children: [
        RecurringTaskSchedulingWidget(
          onRecurrenceChanged: (RecurrencePattern? pattern) {
            setState(() {
              _recurrencePattern = pattern;
            });
          },
          initiallyEnabled: _recurrencePattern != null,
          initialRecurrence: _recurrencePattern,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    if (_hasRecording && !_isRecording) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Continue to Edit button - attach audio to task form
          RoundedGlassButton(
            width: double.infinity,
            label: _isProcessing ? 'Processing...' : 'Attach Audio & Continue',
            onPressed: _isProcessing ? null : _continueToEdit,
            icon: _isProcessing ? null : Icons.attach_file,
            isPrimary: true,
            isLoading: _isProcessing,
          ),
          const SizedBox(height: 12),
          // Re-record button - start over
          RoundedGlassButton(
            width: double.infinity,
            label: 'Re-record Audio',
            onPressed: _resetRecording,
            icon: Icons.refresh,
          ),
        ],
      );
    } else if (!_isRecording) {
      return RoundedGlassButton(
        width: double.infinity,
        label: 'Cancel',
        onPressed: () => Navigator.of(context).pop(),
        icon: Icons.cancel,
      );
    }
    return const SizedBox.shrink();
  }
  
  void _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }
  
  Future<void> _startRecording() async {
    if (!_isAudioInitialized) {
      setState(() {
        _statusMessage = 'Audio service not ready';
      });
      return;
    }

    try {
      setState(() {
        _isRecording = true;
        _statusMessage = 'Recording... Tap to stop';
        _recordingDuration = Duration.zero;
      });
      
      _pulseController.repeat(reverse: true);
      
      // Start real audio recording
      _audioFilePath = await _audioService.startRecording(
        onDurationUpdate: (duration) {
          setState(() {
            _recordingDuration = duration;
          });
        },
        onMaxDurationReached: () {
          setState(() {
            _statusMessage = 'Maximum recording duration reached';
          });
          _stopRecording();
        },
      );
      
      debugPrint('VoiceDialog: Started real recording to $_audioFilePath');
    } catch (e) {
      setState(() {
        _isRecording = false;
        _statusMessage = 'Error starting recording: $e';
      });
      debugPrint('Error starting recording: $e');
    }
  }
  
  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      _pulseController.stop();
      
      // Stop real audio recording
      final recordingPath = await _audioService.stopRecording();
      
      setState(() {
        _isRecording = false;
        _hasRecording = recordingPath != null;
        _audioFilePath = recordingPath;
        _statusMessage = recordingPath != null 
            ? 'Recording saved! Attach to task or re-record.'
            : 'Recording failed. Please try again.';
      });
      
      debugPrint('VoiceDialog: Stopped real recording, saved to $_audioFilePath');
    } catch (e) {
      setState(() {
        _isRecording = false;
        _hasRecording = false;
        _statusMessage = 'Error stopping recording: $e';
      });
      debugPrint('Error stopping recording: $e');
    }
  }
  
  void _resetRecording() async {
    // Cancel current recording if in progress
    if (_isRecording) {
      await _audioService.cancelRecording();
    }
    
    setState(() {
      _hasRecording = false;
      _isRecording = false;
      _statusMessage = 'Ready to record';
      _recordingDuration = Duration.zero;
      _audioFilePath = null;
    });
  }
  
  void _continueToEdit() async {
    if (_audioFilePath == null) return;
    
    try {
      // Get file size for metadata - file should already exist from _startRecording
      final file = File(_audioFilePath!);
      final fileExists = await file.exists();
      final fileSize = fileExists ? await file.length() : 0;
      
      
      // Return ONLY audio data - no auto-generated title/description
      // User will manually enter title/description with audio attached
      final returnData = {
        'audioFilePath': _audioFilePath,
        'recordingDuration': _recordingDuration.inSeconds,
        'creationMode': 'voiceOnly',
        'audioData': {
          'filePath': _audioFilePath,
          'duration': _recordingDuration.inSeconds,
          'timestamp': DateTime.now().toIso8601String(),
          'fileSize': fileSize,
        },
        'recurrence': _recurrencePattern,
        // NO title or description - user will type these manually
      };
      
      Navigator.of(context).pop(returnData);
    } catch (e) {
      debugPrint('Error processing audio file: $e');
      setState(() {
        _statusMessage = 'Error saving recording. Please try again.';
      });
    }
  }
  
  // Real audio recording is now handled by AudioRecordingService
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}