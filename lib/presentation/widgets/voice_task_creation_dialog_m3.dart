import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/design_tokens.dart' hide BorderRadius;
import 'package:speech_to_text/speech_to_text.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/recurrence_pattern.dart';
import '../../domain/models/enums.dart';
import '../../services/speech/speech_service_impl.dart';
import '../../services/ai/composite_ai_task_parser.dart';
import '../providers/task_provider.dart' show taskOperationsProvider;
import '../providers/audio_providers.dart';
import '../../services/audio/audio_file_manager.dart';
import 'glassmorphism_container.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/theme/material3/motion_system.dart';
import 'voice_visualization_painter.dart';
import 'recurring_task_scheduling_widget.dart';
import 'dart:async';
import 'dart:io';
import 'theme_aware_dialog_components.dart';

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
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ThemeAwareTaskDialog(
          title: 'Voice Task Creation',
          subtitle: 'Speak to create your task',
          icon: Icons.mic,
          onBack: () => Navigator.of(context).pop(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                
                // Sound wave visualization
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
                        theme.colorScheme.surfaceContainerHighest.withOpacity(0.1),
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
                          theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
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
                                  style: theme.textTheme.bodySmall,
                                ),
                                backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                labelStyle: theme.textTheme.bodySmall?.copyWith(
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
                
                // Universal Recurring Task Scheduling Widget (only show if task is parsed)
                if (_parsedTask != null) ...[
                  const SizedBox(height: 24),
                  RecurringTaskSchedulingWidget(
                    onRecurrenceChanged: (RecurrencePattern? pattern) {
                      setState(() {
                        _recurrencePattern = pattern;
                      });
                    },
                    initiallyEnabled: _recurrencePattern != null,
                    initialRecurrence: _recurrencePattern,
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Action buttons - Fixed layout to prevent constraint issues
                if (_parsedTask != null || _isProcessing)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Continue to Edit button (primary action for voice-to-text flow)
                      RoundedGlassButton(
                        width: double.infinity,
                        label: _isProcessing ? 'Processing...' : 'Continue to Edit',
                        onPressed: _isProcessing ? null : _continueToEdit,
                        icon: _isProcessing ? null : Icons.edit,
                        isPrimary: true,
                        isLoading: _isProcessing,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Row for secondary actions
                      Row(
                        children: [
                          // Try Again button - reset and start over
                          Expanded(
                            child: RoundedGlassButton(
                              label: 'Try Again',
                              onPressed: _isProcessing ? null : _reset,
                              icon: Icons.refresh,
                            ),
                          ),
                        ],
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
  
  void _continueToEdit() async {
    if (_parsedTask == null && _transcribedText.isEmpty) return;
    
    HapticFeedback.lightImpact();
    
    // Voice-to-Text does not need audio files - transcription is the output
    // The original speech is already converted to text, no need to store audio
    
    // Return the voice data to populate the unified task creation form
    final result = {
      'title': _parsedTask?.title ?? _transcribedText,
      'description': _parsedTask?.description,
      'priority': _parsedTask?.priority?.name ?? 'medium',
      'dueDate': _parsedTask?.dueDate?.toIso8601String(),
      'tags': _parsedTask?.tags ?? [],
      'transcription': _transcribedText,
      'recurrence': _recurrencePattern,
      'creationMode': 'voiceToText',
      // No audio data - Voice-to-Text only provides transcription
    };
    
    Navigator.of(context).pop(result);
  }
  
  // Voice-to-Text only provides transcription, no audio files needed
  
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