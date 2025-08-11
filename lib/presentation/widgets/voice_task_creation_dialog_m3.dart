import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../services/speech/speech_service_impl.dart';
import '../../services/ai/composite_ai_task_parser.dart';
import '../providers/task_provider.dart' show taskOperationsProvider;
import '../painters/glassmorphism_painter.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/theme/material3/motion_system.dart';
import 'voice_visualization_painter.dart';
import 'dart:async';

/// Enhanced Voice Task Creation Dialog with M3 design
class VoiceTaskCreationDialog extends ConsumerStatefulWidget {
  const VoiceTaskCreationDialog({super.key});
  
  @override
  ConsumerState<VoiceTaskCreationDialog> createState() => _VoiceTaskCreationDialogState();
}

class _VoiceTaskCreationDialogState extends ConsumerState<VoiceTaskCreationDialog>
    with TickerProviderStateMixin {
  final SpeechServiceImpl _speechService = SpeechServiceImpl();
  final CompositeAITaskParser _aiParser = CompositeAITaskParser();
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isInitialized = false;
  String _transcribedText = '';
  String _statusMessage = 'Tap the microphone to start';
  TaskModel? _parsedTask;
  
  Timer? _silenceTimer;
  
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
      duration: const Duration(seconds: 1),
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
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _initializeSpeech();
    _fadeController.forward();
    _scaleController.forward();
  }
  
  Future<void> _initializeSpeech() async {
    try {
      _isInitialized = await _speechService.initialize();
      if (_isInitialized) {
        setState(() {
          _statusMessage = 'Ready to listen';
        });
      } else {
        setState(() {
          _statusMessage = 'Speech recognition not available';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error initializing speech: $e';
      });
    }
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _silenceTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GlassmorphicContainer(
            width: size.width * 0.9,
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            blur: 20,
            opacity: 0.95,
            color: theme.colorScheme.surface,
            borderColor: theme.colorScheme.primary.withOpacity(0.2),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                          ),
                          child: const Icon(
                            Icons.mic,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Voice Task Creation',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Sound wave visualization
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primaryContainer.withOpacity(0.1),
                        theme.colorScheme.secondaryContainer.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                    child: AnimatedSoundWave(
                      isRecording: _isListening,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                        theme.colorScheme.tertiary,
                      ],
                      height: 150,
                      style: WaveStyle.linear,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Microphone button
                GestureDetector(
                  onTap: _toggleListening,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isListening ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isListening
                                ? [
                                    theme.colorScheme.error,
                                    theme.colorScheme.error.withOpacity(0.7),
                                  ]
                                : [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary,
                                  ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_isListening
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.primary
                                ).withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isListening ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Status message
                Text(
                  _statusMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Transcribed text
                if (_transcribedText.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.text_fields,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Transcription',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _transcribedText,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                
                // Parsed task preview
                if (_parsedTask != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primaryContainer.withOpacity(0.5),
                          theme.colorScheme.secondaryContainer.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AI Parsed Task',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _parsedTask!.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_parsedTask!.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _parsedTask!.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (_parsedTask!.dueDate != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Due: ${_formatDate(_parsedTask!.dueDate!)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (_parsedTask!.tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: _parsedTask!.tags.map((tag) => 
                              Chip(
                                label: Text(
                                  '#$tag',
                                  style: TextStyle(fontSize: TypographyConstants.bodySmall),
                                ),
                                backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
                                labelStyle: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                            ).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Action buttons
                if (_parsedTask != null || _isProcessing)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isProcessing ? null : _reset,
                        child: const Text('Try Again'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _isProcessing ? null : _saveTask,
                        icon: _isProcessing
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                        label: Text(_isProcessing ? 'Processing...' : 'Save Task'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _toggleListening() async {
    if (!_isInitialized) {
      setState(() {
        _statusMessage = 'Speech recognition not available';
      });
      return;
    }
    
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }
  
  Future<void> _startListening() async {
    HapticFeedback.mediumImpact();
    _pulseController.repeat(reverse: true);
    
    setState(() {
      _isListening = true;
      _statusMessage = 'Listening... Speak now';
      _transcribedText = '';
      _parsedTask = null;
    });
    
    await _speechService.startListening(
      onResult: (result) {
        setState(() {
          _transcribedText = result;
        });
        
        // Reset silence timer
        _silenceTimer?.cancel();
        _silenceTimer = Timer(const Duration(seconds: 2), () {
          if (_isListening) {
            _stopListening();
          }
        });
      },
      onError: (error) {
        setState(() {
          _statusMessage = 'Error: $error';
          _isListening = false;
        });
        _pulseController.stop();
      },
    );
  }
  
  Future<void> _stopListening() async {
    HapticFeedback.lightImpact();
    _pulseController.stop();
    _silenceTimer?.cancel();
    
    await _speechService.stopListening();
    
    setState(() {
      _isListening = false;
      _statusMessage = 'Processing...';
      _isProcessing = true;
    });
    
    if (_transcribedText.isNotEmpty) {
      await _parseTask();
    } else {
      setState(() {
        _statusMessage = 'No speech detected. Try again.';
        _isProcessing = false;
      });
    }
  }
  
  Future<void> _parseTask() async {
    try {
      final parsedData = await _aiParser.parseTaskFromText(_transcribedText);
      
      setState(() {
        _parsedTask = TaskModel.create(
          title: parsedData.title,
          description: parsedData.description,
          dueDate: parsedData.dueDate,
          priority: parsedData.priority,
          tags: parsedData.suggestedTags,
          metadata: {
            'source': 'voice',
            'transcription': _transcribedText,
          },
        );
        _statusMessage = 'Task parsed successfully!';
        _isProcessing = false;
      });
      
      HapticFeedback.lightImpact();
    } catch (e) {
      setState(() {
        _statusMessage = 'Error parsing task: $e';
        _isProcessing = false;
      });
    }
  }
  
  void _saveTask() async {
    if (_parsedTask == null) return;
    
    HapticFeedback.mediumImpact();
    
    try {
      await ref.read(taskOperationsProvider).createTask(_parsedTask!);
      
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${_parsedTask!.title}" created successfully!'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                Navigator.of(context).pushNamed('/tasks');
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create task: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  
  void _reset() {
    HapticFeedback.selectionClick();
    setState(() {
      _transcribedText = '';
      _parsedTask = null;
      _statusMessage = 'Ready to listen';
      _isProcessing = false;
    });
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}