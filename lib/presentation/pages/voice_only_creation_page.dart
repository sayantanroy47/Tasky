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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _recordingTimer?.cancel();
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
          children: [// Main content - full screen
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
                    SizedBox(height: 20),
                    
                    // Title Section
                    _buildTitleSection(context, theme),
                    
                    SizedBox(height: 32),
                    
                    // Priority Section
                    _buildPrioritySection(context, theme),
                    
                    SizedBox(height: 32),
                    
                    // Recording Section - Main focal point
                    _buildRecordingSection(context, theme),
                    
                    SizedBox(height: 32),
                    
                    // Action Buttons
                    if (_hasRecording)
                      _buildActionButtons(context, theme),
                    
                    SizedBox(height: 100), // Bottom padding
                  ],
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
                      offset: Offset(0, 2),
                    )]),
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
            if (_hasRecording)
              Positioned(
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
                      )]),
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
              )]),
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
        children: [Row(
            children: [
              Icon(
                PhosphorIcons.chatCircle(),
                size: 24,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Voice Note',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )]),
          SizedBox(height: 12),
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
          )]),
    );
  }
  
  Widget _buildPrioritySection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Row(
            children: [
              Icon(
                PhosphorIcons.flag(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Priority',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )]),
          SizedBox(height: 12),
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
                            SizedBox(height: 4),
                            Text(
                              priority.name.toUpperCase(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                              ),
                            )]),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          )]),
    );
  }
  
  Widget _buildRecordingSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(32),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        children: [// Status text
          Text(
            _getStatusText(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: _isRecording
                  ? theme.colorScheme.error
                  : _hasRecording
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 32),
          
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
                  )]),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(60),
                  onTap: _isProcessing ? null : _toggleRecording,
                  child: Center(
                    child: _isProcessing 
                        ? SizedBox(width: 32,
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
          
          SizedBox(height: 24),
          
          // Duration display
          Text(
            _formatDuration(_recordingDuration),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontFamily: 'Courier',
              fontWeight: FontWeight.bold,
              color: _isRecording
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
          
          if (_hasRecording && !_isRecording) ...[ 
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _deleteRecording,
                    icon: PhosphorIcon(PhosphorIcons.trash(), size: 18),
                    label: Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _playRecording,
                    icon: PhosphorIcon(PhosphorIcons.play(), size: 18),
                    label: const Text(""), ))]),
          ]]),
    );
  }
  
  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Row(
      children: [Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: PhosphorIcon(PhosphorIcons.x()),
            label: Text('Cancel'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _canCreateTask() && !_isProcessing ? _createVoiceTask : null,
            icon: _isProcessing
                ? SizedBox(width: 16,
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
        )]);
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
      await audioService.startRecording();

      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });

      _pulseController.repeat(reverse: true);

      _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordingDuration = Duration(seconds: timer.tick);
          });
        }
      });
    } catch (e) {
      _showError('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final audioService = ref.read(audioRecordingServiceProvider);
      final audioPath = await audioService.stopRecording();

      setState(() {
        _isRecording = false;
        _hasRecording = audioPath != null;
        _audioFilePath = audioPath;
      });

      _pulseController.stop();
      _recordingTimer?.cancel();

      if (_hasRecording && _titleController.text.isEmpty) {
        _titleController.text = 'Voice Note ${DateTime.now().day}/${DateTime.now().month}';
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
    });
  }

  Future<void> _playRecording() async {
    if (_audioFilePath != null) {
      try {
        final audioControls = ref.read(audioControlsProvider);
        await audioControls.playTask('temp', _audioFilePath!);
      } catch (e) {
        _showError('Failed to play recording: $e');
      }
    }
  }

  Future<void> _createVoiceTask() async {
    if (!_canCreateTask()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final task = TaskModel.create(
        title: _titleController.text.trim(),
        priority: _priority,
        metadata: {
          'creation_mode': 'voiceOnly',
          'has_audio': true,
          'has_transcription': false,
          'audio_file_path': _audioFilePath,
          'audio_duration_seconds': _recordingDuration.inSeconds,
        },
      );

      await ref.read(taskOperationsProvider).createTask(task);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voice note created successfully!'),
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
    return _titleController.text.trim().isNotEmpty && _hasRecording;
  }

  String _getStatusText() {
    if (_isRecording) return 'Recording voice note...';
    if (_hasRecording) return 'Voice note ready to save';
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
}

