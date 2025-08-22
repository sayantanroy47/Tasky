import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'glassmorphism_container.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/theme/material3/motion_system.dart';
import '../../core/design_system/design_tokens.dart';

/// Enhanced glassmorphism button with dynamic intensity changes and micro-interactions
class EnhancedGlassButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final GlassLevel level;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? glassTint;
  final Color? pressedGlassTint;
  final bool isLoading;
  final HapticFeedbackType hapticFeedback;
  final Duration animationDuration;
  
  const EnhancedGlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.level = GlassLevel.interactive,
    this.width,
    this.height,
    this.borderRadius,
    this.glassTint,
    this.pressedGlassTint,
    this.isLoading = false,
    this.hapticFeedback = HapticFeedbackType.selectionClick,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  // Named constructors for common button types
  const EnhancedGlassButton.primary({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = false,
  }) : level = GlassLevel.floating,
       glassTint = null,
       pressedGlassTint = null,
       hapticFeedback = HapticFeedbackType.lightImpact,
       animationDuration = const Duration(milliseconds: 150);

  const EnhancedGlassButton.secondary({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = false,
  }) : level = GlassLevel.interactive,
       glassTint = null,
       pressedGlassTint = null,
       hapticFeedback = HapticFeedbackType.selectionClick,
       animationDuration = const Duration(milliseconds: 150);

  const EnhancedGlassButton.floating({
    super.key,
    required this.onPressed,
    required this.child,
    this.width = 56.0,
    this.height = 56.0,
    this.isLoading = false,
  }) : level = GlassLevel.floating,
       borderRadius = const BorderRadius.all(Radius.circular(28.0)),
       glassTint = null,
       pressedGlassTint = null,
       hapticFeedback = HapticFeedbackType.mediumImpact,
       animationDuration = const Duration(milliseconds: 200);

  @override
  State<EnhancedGlassButton> createState() => _EnhancedGlassButtonState();
}

class _EnhancedGlassButtonState extends State<EnhancedGlassButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _glassController;
  late AnimationController _rippleController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _glassIntensityAnimation;
  late Animation<double> _rippleAnimation;
  
  bool _isPressed = false;
  // bool _isHovered = false;


  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Press/scale animation
    _pressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Glass intensity animation
    _glassController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Ripple animation
    _rippleController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium2,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: ExpressiveMotionSystem.emphasizedDecelerate,
    ));

    _glassIntensityAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _glassController,
      curve: ExpressiveMotionSystem.standard,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: ExpressiveMotionSystem.emphasizedEasing,
    ));
  }

  @override
  void dispose() {
    _pressController.dispose();
    _glassController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _pressController.forward();
      _glassController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _pressController.reverse();
      _glassController.reverse();
      _rippleController.forward().then((_) {
        _rippleController.reset();
      });
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _pressController.reverse();
      _glassController.reverse();
    }
  }

  void _handleTap() {
    if (widget.onPressed != null && !widget.isLoading) {
      // Haptic feedback
      switch (widget.hapticFeedback) {
        case HapticFeedbackType.lightImpact:
          HapticFeedback.lightImpact();
          break;
        case HapticFeedbackType.mediumImpact:
          HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackType.heavyImpact:
          HapticFeedback.heavyImpact();
          break;
        case HapticFeedbackType.selectionClick:
          HapticFeedback.selectionClick();
          break;
        case HapticFeedbackType.vibrate:
          HapticFeedback.vibrate();
          break;
      }
      
      widget.onPressed!();
    }
  }

  void _handleHover(bool isHovered) {
    // setState(() => _isHovered = isHovered);
    if (isHovered && !_isPressed) {
      _glassController.forward();
    } else if (!isHovered && !_isPressed) {
      _glassController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    
    // Determine glass tint colors
    final baseGlassTint = widget.glassTint ?? _getDefaultGlassTint(theme);
    final pressedGlassTint = widget.pressedGlassTint ?? 
        (widget.glassTint?.withValues(alpha: 0.3) ?? _getDefaultPressedGlassTint(theme));

    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            _glassIntensityAnimation,
            _rippleAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // Main button container
                  GlassmorphismContainer(
                    level: widget.level,
                    width: widget.width,
                    height: widget.height,
                    borderRadius: widget.borderRadius ?? 
                        BorderRadius.circular(TypographyConstants.radiusSmall),
                    glassTint: Color.lerp(
                      baseGlassTint,
                      pressedGlassTint,
                      _glassIntensityAnimation.value - 1.0,
                    )?.withValues(alpha: 
                      (baseGlassTint.opacity * _glassIntensityAnimation.value)
                          .clamp(0.0, 1.0),
                    ),
                    child: Container(
                      width: widget.width,
                      height: widget.height,
                      decoration: BoxDecoration(
                        borderRadius: widget.borderRadius ?? 
                            BorderRadius.circular(TypographyConstants.radiusSmall),
                      ),
                      child: Center(
                        child: widget.isLoading 
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.onSurface,
                                  ),
                                ),
                              )
                            : DefaultTextStyle(
                                style: TextStyle(
                                  color: isEnabled 
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                                ),
                                child: widget.child,
                              ),
                      ),
                    ),
                  ),
                  
                  // Ripple effect overlay
                  if (_rippleAnimation.value > 0) 
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: widget.borderRadius ?? 
                            BorderRadius.circular(TypographyConstants.radiusSmall),
                        child: CustomPaint(
                          painter: _RipplePainter(
                            progress: _rippleAnimation.value,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getDefaultGlassTint(ThemeData theme) {
    switch (widget.level) {
      case GlassLevel.floating:
        return theme.colorScheme.primary.withValues(alpha: 0.2);
      case GlassLevel.interactive:
        return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
      case GlassLevel.content:
        return theme.colorScheme.surface.withValues(alpha: 0.2);
      case GlassLevel.background:
        return theme.colorScheme.surface.withValues(alpha: 0.1);
    }
  }

  Color _getDefaultPressedGlassTint(ThemeData theme) {
    switch (widget.level) {
      case GlassLevel.floating:
        return theme.colorScheme.primary.withValues(alpha: 0.4);
      case GlassLevel.interactive:
        return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
      case GlassLevel.content:
        return theme.colorScheme.surface.withValues(alpha: 0.4);
      case GlassLevel.background:
        return theme.colorScheme.surface.withValues(alpha: 0.2);
    }
  }
}

/// Custom painter for button ripple effect
class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;

  _RipplePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width > size.height ? size.width : size.height) * progress;
    
    final paint = Paint()
      ..color = color.withValues(alpha: (1.0 - progress) * 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Enum for haptic feedback types
enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
  vibrate,
}