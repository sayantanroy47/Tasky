import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget that provides voice recording UI with visual feedback
class VoiceRecordingWidget extends StatefulWidget {
  final VoidCallback? onStartRecording;
  final VoidCallback? onStopRecording;
  final VoidCallback? onCancelRecording;
  final Function(String)? onTranscriptionResult;
  final Function(String)? onError;
  final bool isRecording;
  final bool isProcessing;
  final String? transcriptionText;
  final double? soundLevel;
  final String? errorMessage;

  const VoiceRecordingWidget({
    super.key,
    this.onStartRecording,
    this.onStopRecording,
    this.onCancelRecording,
    this.onTranscriptionResult,
    this.onError,
    this.isRecording = false,
    this.isProcessing = false,
    this.transcriptionText,
    this.soundLevel,
    this.errorMessage,
  });  @override
  State<VoiceRecordingWidget> createState() => _VoiceRecordingWidgetState();
}

class _VoiceRecordingWidgetState extends State<VoiceRecordingWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    ));
  }  @override
  void didUpdateWidget(VoiceRecordingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isRecording && !oldWidget.isRecording) {
      _startAnimations();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _stopAnimations();
    }
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _waveController.repeat();
  }

  void _stopAnimations() {
    _pulseController.stop();
    _waveController.stop();
    _pulseController.reset();
    _waveController.reset();
  }  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity( 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status text
          _buildStatusText(theme),
          const SizedBox(height: 24.0),
          
          // Visual feedback area
          _buildVisualFeedback(colorScheme),
          const SizedBox(height: 24.0),
          
          // Transcription display
          if (widget.transcriptionText != null) ...[
            _buildTranscriptionDisplay(theme),
            const SizedBox(height: 16.0),
          ],
          
          // Error display
          if (widget.errorMessage != null) ...[
            _buildErrorDisplay(theme),
            const SizedBox(height: 16.0),
          ],
          
          // Control buttons
          _buildControlButtons(colorScheme),
        ],
      ),
    );
  }

  Widget _buildStatusText(ThemeData theme) {
    String statusText;
    if (widget.isProcessing) {
      statusText = 'Processing speech...';
    } else if (widget.isRecording) {
      statusText = 'Listening...';
    } else {
      statusText = 'Tap to start recording';
    }

    return Text(
      statusText,
      style: theme.textTheme.titleMedium?.copyWith(
        color: widget.isRecording 
            ? theme.colorScheme.primary 
            : theme.colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildVisualFeedback(ColorScheme colorScheme) {
    return SizedBox(
      height: 120.0,
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _waveAnimation]),
          builder: (context, child) {
            return CustomPaint(
              size: const Size(120.0, 120.0),
              painter: VoiceVisualizerPainter(
                isRecording: widget.isRecording,
                isProcessing: widget.isProcessing,
                soundLevel: widget.soundLevel ?? 0.0,
                pulseValue: _pulseAnimation.value,
                waveValue: _waveAnimation.value,
                primaryColor: colorScheme.primary,
                surfaceColor: colorScheme.surface,
                onSurfaceColor: colorScheme.onSurface,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTranscriptionDisplay(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity( 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity( 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transcription:',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity( 0.1),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            widget.transcriptionText!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity( 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity( 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 20.0,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              widget.errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(ColorScheme colorScheme) {
    if (widget.isProcessing) {
      return const CircularProgressIndicator();
    }

    if (widget.isRecording) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Cancel button
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onCancelRecording?.call();
            },
            icon: const Icon(Icons.close),
            iconSize: 32.0,
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.errorContainer,
              foregroundColor: colorScheme.error,
              padding: const EdgeInsets.all(16.0),
            ),
          ),
          
          // Stop button
          IconButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              widget.onStopRecording?.call();
            },
            icon: const Icon(Icons.stop),
            iconSize: 32.0,
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.all(16.0),
            ),
          ),
        ],
      );
    }

    // Start recording button
    return IconButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        widget.onStartRecording?.call();
      },
      icon: const Icon(Icons.mic),
      iconSize: 32.0,
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.all(20.0),
      ),
    );
  }
}

/// Custom painter for voice visualization
class VoiceVisualizerPainter extends CustomPainter {
  final bool isRecording;
  final bool isProcessing;
  final double soundLevel;
  final double pulseValue;
  final double waveValue;
  final Color primaryColor;
  final Color surfaceColor;
  final Color onSurfaceColor;

  VoiceVisualizerPainter({
    required this.isRecording,
    required this.isProcessing,
    required this.soundLevel,
    required this.pulseValue,
    required this.waveValue,
    required this.primaryColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
  });  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 4;

    if (isProcessing) {
      _drawProcessingIndicator(canvas, center, baseRadius);
    } else if (isRecording) {
      _drawRecordingIndicator(canvas, center, baseRadius);
    } else {
      _drawIdleIndicator(canvas, center, baseRadius);
    }
  }

  void _drawIdleIndicator(Canvas canvas, Offset center, double baseRadius) {
    final paint = Paint()
      ..color = onSurfaceColor.withOpacity( 0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, baseRadius, paint);

    // Microphone icon representation
    final micPaint = Paint()
      ..color = onSurfaceColor.withOpacity( 0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, baseRadius * 0.4, micPaint);
  }

  void _drawRecordingIndicator(Canvas canvas, Offset center, double baseRadius) {
    // Pulsing outer circle
    final outerPaint = Paint()
      ..color = primaryColor.withOpacity( 0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, baseRadius * pulseValue, outerPaint);

    // Sound level visualization
    final soundRadius = baseRadius * (0.6 + soundLevel * 0.4);
    final soundPaint = Paint()
      ..color = primaryColor.withOpacity( 0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, soundRadius, soundPaint);

    // Inner recording circle
    final innerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, baseRadius * 0.4, innerPaint);

    // Wave animation
    _drawWaveAnimation(canvas, center, baseRadius);
  }

  void _drawProcessingIndicator(Canvas canvas, Offset center, double baseRadius) {
    final paint = Paint()
      ..color = primaryColor.withOpacity( 0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, baseRadius, paint);

    // Rotating dots
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + waveValue;
      final dotCenter = Offset(
        center.dx + math.cos(angle) * baseRadius * 0.7,
        center.dy + math.sin(angle) * baseRadius * 0.7,
      );

      final dotPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(dotCenter, 4.0, dotPaint);
    }
  }

  void _drawWaveAnimation(Canvas canvas, Offset center, double baseRadius) {
    final wavePaint = Paint()
      ..color = primaryColor.withOpacity( 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 1; i <= 3; i++) {
      final waveRadius = baseRadius * (1.2 + i * 0.3) * 
          (1.0 + math.sin(waveValue + i * math.pi / 3) * 0.1);
      canvas.drawCircle(center, waveRadius, wavePaint);
    }
  }  @override
  bool shouldRepaint(VoiceVisualizerPainter oldDelegate) {
    return oldDelegate.isRecording != isRecording ||
        oldDelegate.isProcessing != isProcessing ||
        oldDelegate.soundLevel != soundLevel ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.waveValue != waveValue;
  }
}
