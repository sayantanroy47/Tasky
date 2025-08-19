import 'package:flutter/material.dart';
import 'glassmorphism_container.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/theme/material3/motion_system.dart';
import '../../core/design_system/design_tokens.dart';

/// Beautiful glassmorphism-based loading widget for various contexts
class GlassLoadingWidget extends StatefulWidget {
  final String? message;
  final GlassLevel level;
  final double size;
  final Color? accentColor;
  final bool showPulse;
  
  const GlassLoadingWidget({
    super.key,
    this.message,
    this.level = GlassLevel.content,
    this.size = 80.0,
    this.accentColor,
    this.showPulse = true,
  });

  // Named constructors for common use cases
  const GlassLoadingWidget.inline({
    super.key,
    this.message,
    this.size = 40.0,
    this.accentColor,
  }) : level = GlassLevel.interactive,
       showPulse = false;

  const GlassLoadingWidget.overlay({
    super.key,
    this.message,
    this.size = 100.0,
    this.accentColor,
  }) : level = GlassLevel.floating,
       showPulse = true;

  const GlassLoadingWidget.dialog({
    super.key,
    this.message,
    this.size = 60.0,
    this.accentColor,
  }) : level = GlassLevel.floating,
       showPulse = true;

  @override
  State<GlassLoadingWidget> createState() => _GlassLoadingWidgetState();
}

class _GlassLoadingWidgetState extends State<GlassLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Rotation animation for the loading ring
    _rotationController = AnimationController(
      duration: ExpressiveMotionSystem.durationLong2,
      vsync: this,
    );

    // Pulse animation for the glass container
    _pulseController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium3,
      vsync: this,
    );

    // Shimmer animation for the glass effect
    _shimmerController = AnimationController(
      duration: ExpressiveMotionSystem.durationLong3,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _rotationController.repeat();
    if (widget.showPulse) {
      _pulseController.repeat(reverse: true);
    }
    _shimmerController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveAccentColor = widget.accentColor ?? theme.colorScheme.primary;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main loading animation
        AnimatedBuilder(
          animation: Listenable.merge([
            _rotationAnimation,
            _pulseAnimation,
            _shimmerAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: widget.showPulse ? _pulseAnimation.value : 1.0,
              child: GlassmorphismContainer(
                level: widget.level,
                width: widget.size,
                height: widget.size,
                borderRadius: BorderRadius.circular(widget.size / 2),
                glassTint: effectiveAccentColor.withOpacity(0.1),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Shimmer effect background
                    Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
                          end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
                          colors: [
                            Colors.transparent,
                            effectiveAccentColor.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    // Rotating loading ring
                    Transform.rotate(
                      angle: _rotationAnimation.value * 2 * 3.14159,
                      child: CustomPaint(
                        size: Size(widget.size * 0.7, widget.size * 0.7),
                        painter: _LoadingRingPainter(
                          color: effectiveAccentColor,
                          strokeWidth: 3.0,
                        ),
                      ),
                    ),
                    // Center icon
                    Icon(
                      Icons.hourglass_empty,
                      size: widget.size * 0.3,
                      color: effectiveAccentColor.withOpacity(0.8),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        
        // Optional message
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          GlassmorphismContainer(
            level: GlassLevel.content,
            borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            glassTint: theme.colorScheme.surfaceContainerHighest.withOpacity(0.1),
            child: Text(
              widget.message!,
              style: TextStyle(
                fontSize: TypographyConstants.textSM,
                fontWeight: TypographyConstants.medium,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom painter for the loading ring with glassmorphism effect
class _LoadingRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _LoadingRingPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle (faint)
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Active arc (bright)
    final activePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const sweepAngle = 3.14159 * 0.75; // 135 degrees
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Overlay loading widget that covers the entire screen
class GlassLoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isVisible;
  final Color? backgroundColor;
  
  const GlassLoadingOverlay({
    super.key,
    this.message,
    this.isVisible = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    
    return Material(
      color: backgroundColor ?? Colors.black.withOpacity(0.3),
      child: Center(
        child: GlassLoadingWidget.overlay(
          message: message ?? 'Loading...',
          accentColor: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// Shimmer loading effect for content placeholders
class GlassShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final GlassLevel level;
  
  const GlassShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.level = GlassLevel.content,
  });

  @override
  State<GlassShimmerLoading> createState() => _GlassShimmerLoadingState();
}

class _GlassShimmerLoadingState extends State<GlassShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: ExpressiveMotionSystem.durationLong2,
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return GlassmorphismContainer(
          level: widget.level,
          width: widget.width,
          height: widget.height,
          borderRadius: widget.borderRadius ?? 
              BorderRadius.circular(TypographyConstants.radiusSmall),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? 
                  BorderRadius.circular(TypographyConstants.radiusSmall),
              gradient: LinearGradient(
                begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
                end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
                colors: [
                  Colors.transparent,
                  theme.colorScheme.onSurface.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}