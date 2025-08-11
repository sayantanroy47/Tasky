import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated gradient mesh background painter
class GradientMeshPainter extends CustomPainter {
  final List<Color> colors;
  final double animationValue;
  final int meshPoints;
  final double waveAmplitude;
  final double waveFrequency;
  
  GradientMeshPainter({
    required this.colors,
    required this.animationValue,
    this.meshPoints = 5,
    this.waveAmplitude = 50.0,
    this.waveFrequency = 2.0,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Create mesh points
    final points = <Offset>[];
    final cellWidth = size.width / (meshPoints - 1);
    final cellHeight = size.height / (meshPoints - 1);
    
    for (int y = 0; y < meshPoints; y++) {
      for (int x = 0; x < meshPoints; x++) {
        final baseX = x * cellWidth;
        final baseY = y * cellHeight;
        
        // Add wave animation
        final waveX = math.sin(animationValue * waveFrequency + y * 0.5) * waveAmplitude;
        final waveY = math.cos(animationValue * waveFrequency + x * 0.5) * waveAmplitude;
        
        points.add(Offset(
          baseX + waveX,
          baseY + waveY,
        ));
      }
    }
    
    // Draw gradient mesh
    for (int y = 0; y < meshPoints - 1; y++) {
      for (int x = 0; x < meshPoints - 1; x++) {
        final index = y * meshPoints + x;
        final topLeft = points[index];
        final topRight = points[index + 1];
        final bottomLeft = points[index + meshPoints];
        final bottomRight = points[index + meshPoints + 1];
        
        // Create gradient for this cell
        final colorIndex = (index * colors.length ~/ points.length) % colors.length;
        final nextColorIndex = (colorIndex + 1) % colors.length;
        
        final gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[colorIndex].withOpacity(0.6),
            colors[nextColorIndex].withOpacity(0.6),
          ],
        );
        
        // Draw cell
        final path = Path()
          ..moveTo(topLeft.dx, topLeft.dy)
          ..lineTo(topRight.dx, topRight.dy)
          ..lineTo(bottomRight.dx, bottomRight.dy)
          ..lineTo(bottomLeft.dx, bottomLeft.dy)
          ..close();
        
        paint.shader = gradient.createShader(
          Rect.fromPoints(topLeft, bottomRight),
        );
        
        canvas.drawPath(path, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(GradientMeshPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
           colors != oldDelegate.colors;
  }
}

/// Animated gradient mesh background widget
class AnimatedGradientMesh extends StatefulWidget {
  final List<Color> colors;
  final Duration duration;
  final int meshPoints;
  final double waveAmplitude;
  final double waveFrequency;
  final Widget? child;
  
  const AnimatedGradientMesh({
    super.key,
    required this.colors,
    this.duration = const Duration(seconds: 10),
    this.meshPoints = 5,
    this.waveAmplitude = 50.0,
    this.waveFrequency = 2.0,
    this.child,
  });
  
  @override
  State<AnimatedGradientMesh> createState() => _AnimatedGradientMeshState();
}

class _AnimatedGradientMeshState extends State<AnimatedGradientMesh>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
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
          painter: GradientMeshPainter(
            colors: widget.colors,
            animationValue: _animation.value,
            meshPoints: widget.meshPoints,
            waveAmplitude: widget.waveAmplitude,
            waveFrequency: widget.waveFrequency,
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Simple animated gradient background
class AnimatedGradientBackground extends StatefulWidget {
  final List<Color> colors;
  final Duration duration;
  final Widget? child;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  
  const AnimatedGradientBackground({
    super.key,
    required this.colors,
    this.duration = const Duration(seconds: 5),
    this.child,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });
  
  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
        // Shift colors based on animation
        final shiftedColors = <Color>[];
        for (int i = 0; i < widget.colors.length; i++) {
          final hsl = HSLColor.fromColor(widget.colors[i]);
          final shiftedHue = (hsl.hue + _animation.value * 30) % 360;
          shiftedColors.add(hsl.withHue(shiftedHue).toColor());
        }
        
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: widget.begin,
              end: widget.end,
              colors: shiftedColors,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Shimmer effect widget for loading states
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;
  
  const ShimmerEffect({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.duration = const Duration(milliseconds: 1500),
  });
  
  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
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
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                _animation.value - 0.5,
                _animation.value,
                _animation.value + 0.5,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcOver,
          child: widget.child,
        );
      },
    );
  }
}