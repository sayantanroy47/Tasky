import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/typography_constants.dart';

/// Sound wave visualization painter
class SoundWavePainter extends CustomPainter {
  final double animationValue;
  final double amplitude;
  final List<Color> colors;
  final int waveCount;
  final bool isActive;
  
  SoundWavePainter({
    required this.animationValue,
    required this.amplitude,
    required this.colors,
    this.waveCount = 60,
    this.isActive = true,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    final barWidth = size.width / waveCount;
    final centerY = size.height / 2;
    
    for (int i = 0; i < waveCount; i++) {
      final x = i * barWidth;
      
      // Create wave effect
      double waveHeight;
      if (isActive) {
        final phase = (animationValue * 2 * math.pi) + (i * 0.2);
        final baseHeight = math.sin(phase) * amplitude;
        final randomFactor = math.sin(i * 0.5 + animationValue * 3) * 0.3;
        waveHeight = (baseHeight + randomFactor * amplitude).abs();
      } else {
        waveHeight = 2.0;
      }
      
      // Gradient color based on position
      final colorIndex = (i / waveCount * colors.length).floor();
      final nextColorIndex = (colorIndex + 1) % colors.length;
      final colorProgress = (i / waveCount * colors.length) - colorIndex;
      
      paint.color = Color.lerp(
        colors[colorIndex],
        colors[nextColorIndex],
        colorProgress,
      )!.withValues(alpha: isActive ? 0.8 : 0.3);
      
      // Draw wave bar
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x + barWidth / 2, centerY),
          width: barWidth * 0.6,
          height: waveHeight * 2,
        ),
        const Radius.circular(TypographyConstants.radiusStandard),
      );
      
      canvas.drawRRect(rect, paint);
    }
  }
  
  @override
  bool shouldRepaint(SoundWavePainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
           amplitude != oldDelegate.amplitude ||
           isActive != oldDelegate.isActive;
  }
}

/// Circular sound wave visualization
class CircularSoundWavePainter extends CustomPainter {
  final double animationValue;
  final double amplitude;
  final List<Color> colors;
  final int segments;
  final bool isActive;
  
  CircularSoundWavePainter({
    required this.animationValue,
    required this.amplitude,
    required this.colors,
    this.segments = 72,
    this.isActive = true,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 3;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    
    for (int i = 0; i < segments; i++) {
      final angle = (i / segments) * 2 * math.pi;
      
      // Create wave effect
      double waveRadius;
      if (isActive) {
        final phase = (animationValue * 2 * math.pi) + (i * 0.1);
        final waveOffset = math.sin(phase) * amplitude;
        waveRadius = radius + waveOffset;
      } else {
        waveRadius = radius;
      }
      
      final x = center.dx + waveRadius * math.cos(angle);
      final y = center.dy + waveRadius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    
    // Create gradient shader
    paint.shader = LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawPath(path, paint);
    
    // Draw center circle
    if (isActive) {
      paint
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            colors.first.withValues(alpha: 0.8),
            colors.last.withValues(alpha: 0.3),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius / 3));
      
      canvas.drawCircle(center, radius / 3, paint);
    }
  }
  
  @override
  bool shouldRepaint(CircularSoundWavePainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
           amplitude != oldDelegate.amplitude ||
           isActive != oldDelegate.isActive;
  }
}

/// Animated sound wave widget
class AnimatedSoundWave extends StatefulWidget {
  final bool isRecording;
  final List<Color> colors;
  final double height;
  final WaveStyle style;
  
  const AnimatedSoundWave({
    super.key,
    required this.isRecording,
    required this.colors,
    this.height = 100,
    this.style = WaveStyle.linear,
  });
  
  @override
  State<AnimatedSoundWave> createState() => _AnimatedSoundWaveState();
}

class _AnimatedSoundWaveState extends State<AnimatedSoundWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    
    if (widget.isRecording) {
      _controller.repeat();
    }
  }
  
  @override
  void didUpdateWidget(AnimatedSoundWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: widget.style == WaveStyle.linear
            ? SoundWavePainter(
                animationValue: _animation.value,
                amplitude: widget.isRecording ? 30 : 0,
                colors: widget.colors,
                isActive: widget.isRecording,
              )
            : CircularSoundWavePainter(
                animationValue: _animation.value,
                amplitude: widget.isRecording ? 20 : 0,
                colors: widget.colors,
                isActive: widget.isRecording,
              ),
        );
      },
    );
  }
}

enum WaveStyle {
  linear,
  circular,
}