import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography_constants.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../providers/task_provider.dart' show taskOperationsProvider;
import '../painters/glassmorphism_painter.dart';
import '../../core/theme/material3/motion_system.dart';
import 'dart:async';

/// Voice-Only Task Creation Dialog - records audio without transcription
class VoiceOnlyCreationDialog extends ConsumerStatefulWidget {
  const VoiceOnlyCreationDialog({super.key});
  
  @override
  ConsumerState<VoiceOnlyCreationDialog> createState() => _VoiceOnlyCreationDialogState();
}

class _VoiceOnlyCreationDialogState extends ConsumerState<VoiceOnlyCreationDialog>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _hasRecording = false;
  String _statusMessage = 'Tap to start recording';
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  String? _audioFilePath;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: ExpressiveMotionSystem.durationShort3,
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphicContainer(
        width: MediaQuery.of(context).size.width * 0.85,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        blur: 20,
        opacity: 0.95,
        color: theme.colorScheme.surface,
        borderColor: theme.colorScheme.secondary.withOpacity(0.3),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.secondary,
                        theme.colorScheme.tertiary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Voice Only Task',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Recording visualization
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return ScaleTransition(
                  scale: _scaleAnimation,
                  child: GestureDetector(
                    onTapDown: (_) => _scaleController.forward(),
                    onTapUp: (_) {
                      _scaleController.reverse();
                      _toggleRecording();
                    },
                    onTapCancel: () => _scaleController.reverse(),
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
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Status message
            Text(
              _statusMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Recording duration
            if (_isRecording || _hasRecording)
              Text(
                _formatDuration(_recordingDuration),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _isRecording ? Colors.red : theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            
            const SizedBox(height: 32),
            
            // Action buttons
            if (_hasRecording && !_isRecording) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _resetRecording,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Re-record'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isProcessing ? null : _saveVoiceTask,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: const Text('Save Task'),
                    ),
                  ),
                ],
              ),
            ] else if (!_isRecording) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  void _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }
  
  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _statusMessage = 'Recording... Tap to stop';
      _recordingDuration = Duration.zero;
    });
    
    _pulseController.repeat(reverse: true);
    
    // Start recording timer
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration = Duration(seconds: timer.tick);
      });
    });
    
    // TODO: Implement actual audio recording
    // For now, simulate recording
    _audioFilePath = 'simulated_recording_${DateTime.now().millisecondsSinceEpoch}.wav';
  }
  
  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false;
      _hasRecording = true;
      _statusMessage = 'Recording saved! Save as voice task or re-record.';
    });
    
    _pulseController.stop();
    _recordingTimer?.cancel();
    
    // TODO: Stop actual recording
  }
  
  void _resetRecording() {
    setState(() {
      _hasRecording = false;
      _statusMessage = 'Tap to start recording';
      _recordingDuration = Duration.zero;
      _audioFilePath = null;
    });
  }
  
  Future<void> _saveVoiceTask() async {
    if (_audioFilePath == null) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final task = TaskModel.create(
        title: 'Voice Task - ${_formatDate(DateTime.now())}',
        description: 'Audio recording duration: ${_formatDuration(_recordingDuration)}',
        priority: TaskPriority.medium,
        tags: ['voice'],
        metadata: {
          'audioFilePath': _audioFilePath,
          'recordingDuration': _recordingDuration.inSeconds,
        },
      );
      
      // Add task through provider
      await ref.read(taskOperationsProvider).createTask(task);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice task saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving voice task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
  
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