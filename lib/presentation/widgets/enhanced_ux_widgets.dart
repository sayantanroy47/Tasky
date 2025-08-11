import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography_constants.dart';
import '../../services/responsive_design_service.dart';
import '../../services/accessibility_service.dart';

/// Enhanced responsive widget that adapts to screen size
class ResponsiveWidget extends ConsumerWidget {
  final Widget Function(BuildContext context, ResponsiveLayoutConfig config) builder;

  const ResponsiveWidget({super.key, required this.builder});  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(responsiveDesignServiceProvider);
    final screenSize = MediaQuery.of(context).size;
    final config = service.getLayoutConfig(screenSize);

    return builder(context, config);
  }
}

/// Enhanced button with ripple effects and haptic feedback
class EnhancedButton extends ConsumerStatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final ButtonStyle? style;
  final bool enableHaptics;
  final bool enableRipple;
  final Duration animationDuration;

  const EnhancedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.style,
    this.enableHaptics = true,
    this.enableRipple = true,
    this.animationDuration = const Duration(milliseconds: 200),
  });  @override
  ConsumerState<EnhancedButton> createState() => _EnhancedButtonState();
}

class _EnhancedButtonState extends ConsumerState<EnhancedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }  @override
  Widget build(BuildContext context) {
    final accessibilityService = ref.read(accessibilityServiceProvider);
    final settings = ref.watch(accessibilitySettingsProvider);

    return ResponsiveWidget(
      builder: (context, config) {
        return Semantics(
          label: widget.semanticLabel,
          button: true,
          enabled: widget.onPressed != null,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: ElevatedButton(
                  onPressed: widget.onPressed == null ? null : () async {
                    if (widget.enableHaptics) {
                      await accessibilityService.provideHapticFeedback(
                        HapticFeedbackType.selection,
                      );
                    }
                    
                    if (!settings.reducedMotionMode) {
                      await _animationController.forward();
                      await _animationController.reverse();
                    }
                    
                    widget.onPressed!();
                  },
                  style: widget.style?.copyWith(
                    minimumSize: WidgetStateProperty.all(
                      Size.fromHeight(config.buttonHeight),
                    ),
                  ),
                  child: widget.child,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Enhanced card with hover effects and animations
class EnhancedCard extends ConsumerStatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final bool enableHoverEffect;
  final bool enablePressEffect;

  const EnhancedCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.margin,
    this.padding,
    this.color,
    this.elevation,
    this.enableHoverEffect = true,
    this.enablePressEffect = true,
  });  @override
  ConsumerState<EnhancedCard> createState() => _EnhancedCardState();
}

class _EnhancedCardState extends ConsumerState<EnhancedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isPressed = false;  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 1.0,
      end: (widget.elevation ?? 1.0) + 4.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }  @override
  Widget build(BuildContext context) {
    final accessibilityService = ref.read(accessibilityServiceProvider);
    final settings = ref.watch(accessibilitySettingsProvider);

    return ResponsiveWidget(
      builder: (context, config) {
        return Semantics(
          label: widget.semanticLabel,
          button: widget.onTap != null,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _isPressed && widget.enablePressEffect && !settings.reducedMotionMode
                    ? _scaleAnimation.value
                    : 1.0,
                child: Card(
                  margin: widget.margin ?? config.margin,
                  color: widget.color,
                  elevation: _isHovered && widget.enableHoverEffect && !settings.reducedMotionMode
                      ? _elevationAnimation.value
                      : widget.elevation,
                  child: InkWell(
                    onTap: widget.onTap == null ? null : () async {
                      await accessibilityService.provideHapticFeedback(
                        HapticFeedbackType.selection,
                      );
                      widget.onTap!();
                    },
                    onTapDown: (_) {
                      if (widget.enablePressEffect && !settings.reducedMotionMode) {
                        setState(() => _isPressed = true);
                        _animationController.forward();
                      }
                    },
                    onTapUp: (_) {
                      if (widget.enablePressEffect && !settings.reducedMotionMode) {
                        setState(() => _isPressed = false);
                        _animationController.reverse();
                      }
                    },
                    onTapCancel: () {
                      if (widget.enablePressEffect && !settings.reducedMotionMode) {
                        setState(() => _isPressed = false);
                        _animationController.reverse();
                      }
                    },
                    onHover: (isHovered) {
                      if (widget.enableHoverEffect && !settings.reducedMotionMode) {
                        setState(() => _isHovered = isHovered);
                        if (isHovered) {
                          _animationController.forward();
                        } else {
                          _animationController.reverse();
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                    child: Padding(
                      padding: widget.padding ?? config.padding,
                      child: widget.child,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Enhanced gesture detector with customizable gestures
class EnhancedGestureDetector extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final GestureDragEndCallback? onSwipeLeft;
  final GestureDragEndCallback? onSwipeRight;
  final GestureDragEndCallback? onSwipeUp;
  final GestureDragEndCallback? onSwipeDown;
  final String? semanticLabel;
  final bool enableHaptics;

  const EnhancedGestureDetector({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.semanticLabel,
    this.enableHaptics = true,
  });  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibilityService = ref.read(accessibilityServiceProvider);

    return Semantics(
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap == null ? null : () async {
          if (enableHaptics) {
            await accessibilityService.provideHapticFeedback(
              HapticFeedbackType.selection,
            );
          }
          onTap!();
        },
        onDoubleTap: onDoubleTap == null ? null : () async {
          if (enableHaptics) {
            await accessibilityService.provideHapticFeedback(
              HapticFeedbackType.medium,
            );
          }
          onDoubleTap!();
        },
        onLongPress: onLongPress == null ? null : () async {
          if (enableHaptics) {
            await accessibilityService.provideHapticFeedback(
              HapticFeedbackType.heavy,
            );
          }
          onLongPress!();
        },
        onPanEnd: (details) {
          final velocity = details.velocity.pixelsPerSecond;
          final dx = velocity.dx;
          final dy = velocity.dy;

          // Determine swipe direction based on velocity
          if (dx.abs() > dy.abs()) {
            // Horizontal swipe
            if (dx > 0 && onSwipeRight != null) {
              if (enableHaptics) {
                accessibilityService.provideHapticFeedback(
                  HapticFeedbackType.light,
                );
              }
              onSwipeRight!(details);
            } else if (dx < 0 && onSwipeLeft != null) {
              if (enableHaptics) {
                accessibilityService.provideHapticFeedback(
                  HapticFeedbackType.light,
                );
              }
              onSwipeLeft!(details);
            }
          } else {
            // Vertical swipe
            if (dy > 0 && onSwipeDown != null) {
              if (enableHaptics) {
                accessibilityService.provideHapticFeedback(
                  HapticFeedbackType.light,
                );
              }
              onSwipeDown!(details);
            } else if (dy < 0 && onSwipeUp != null) {
              if (enableHaptics) {
                accessibilityService.provideHapticFeedback(
                  HapticFeedbackType.light,
                );
              }
              onSwipeUp!(details);
            }
          }
        },
        child: child,
      ),
    );
  }
}

/// Enhanced text field with smooth animations
class EnhancedTextField extends ConsumerStatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? semanticLabel;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;
  final FocusNode? focusNode;
  final bool autofocus;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const EnhancedTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.semanticLabel,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.focusNode,
    this.autofocus = false,
    this.prefixIcon,
    this.suffixIcon,
  });  @override
  ConsumerState<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends ConsumerState<EnhancedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _borderColorAnimation;
  late FocusNode _focusNode;
  bool _isFocused = false;  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _focusNode.addListener(_onFocusChange);
  }  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }  @override
  Widget build(BuildContext context) {
    final accessibilityService = ref.read(accessibilityServiceProvider);
    final settings = ref.watch(accessibilitySettingsProvider);

    _borderColorAnimation = ColorTween(
      begin: Theme.of(context).colorScheme.outline,
      end: Theme.of(context).colorScheme.primary,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    return ResponsiveWidget(
      builder: (context, config) {
        return Semantics(
          label: widget.semanticLabel ?? widget.labelText,
          textField: true,
          child: AnimatedBuilder(
            animation: _borderColorAnimation,
            builder: (context, child) {
              return TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  labelText: widget.labelText,
                  hintText: widget.hintText,
                  errorText: widget.errorText,
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                    borderSide: BorderSide(
                      color: settings.highContrastMode 
                          ? Colors.black 
                          : Theme.of(context).colorScheme.outline,
                      width: settings.highContrastMode ? 2 : 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                    borderSide: BorderSide(
                      color: _borderColorAnimation.value ?? Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: config.padding,
                ),
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                onChanged: widget.onChanged,
                onTap: widget.onTap == null ? null : () async {
                  await accessibilityService.provideHapticFeedback(
                    HapticFeedbackType.selection,
                  );
                  widget.onTap!();
                },
                readOnly: widget.readOnly,
                maxLines: widget.maxLines,
                autofocus: widget.autofocus,
                style: settings.largeTextMode 
                    ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18 * config.fontSizeMultiplier,
                      )
                    : Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: (Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16) * config.fontSizeMultiplier,
                      ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Enhanced loading indicator with custom animations
class EnhancedLoadingIndicator extends ConsumerStatefulWidget {
  final String? message;
  final Color? color;
  final double size;
  final LoadingIndicatorType type;

  const EnhancedLoadingIndicator({
    super.key,
    this.message,
    this.color,
    this.size = 40.0,
    this.type = LoadingIndicatorType.circular,
  });  @override
  ConsumerState<EnhancedLoadingIndicator> createState() => _EnhancedLoadingIndicatorState();
}

class _EnhancedLoadingIndicatorState extends ConsumerState<EnhancedLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_rotationController);
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(accessibilitySettingsProvider);

    if (settings.reducedMotionMode) {
      return _buildStaticIndicator();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAnimatedIndicator(),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildStaticIndicator() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        color: widget.color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildAnimatedIndicator() {
    switch (widget.type) {
      case LoadingIndicatorType.circular:
        return RotationTransition(
          turns: _rotationAnimation,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              color: widget.color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      
      case LoadingIndicatorType.pulse:
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color ?? Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          },
        );
      
      case LoadingIndicatorType.dots:
        return _buildDotsIndicator();
    }
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final delay = index * 0.2;
            final animationValue = (_pulseController.value + delay) % 1.0;
            final scale = 0.5 + (0.5 * (1 - (animationValue - 0.5).abs() * 2));
            
            return Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size / 4,
                height: widget.size / 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color ?? Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Enhanced floating action button with custom animations
class EnhancedFAB extends ConsumerStatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool mini;
  final bool enablePulseAnimation;

  const EnhancedFAB({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.mini = false,
    this.enablePulseAnimation = false,
  });  @override
  ConsumerState<EnhancedFAB> createState() => _EnhancedFABState();
}

class _EnhancedFABState extends ConsumerState<EnhancedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.enablePulseAnimation) {
      _animationController.repeat(reverse: true);
    }
  }  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }  @override
  Widget build(BuildContext context) {
    final accessibilityService = ref.read(accessibilityServiceProvider);
    final settings = ref.watch(accessibilitySettingsProvider);

    return Semantics(
      label: widget.semanticLabel ?? widget.tooltip,
      button: true,
      enabled: widget.onPressed != null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final scale = widget.enablePulseAnimation && !settings.reducedMotionMode
              ? _pulseAnimation.value
              : _scaleAnimation.value;
          
          return Transform.scale(
            scale: scale,
            child: FloatingActionButton(
              onPressed: widget.onPressed == null ? null : () async {
                await accessibilityService.provideHapticFeedback(
                  HapticFeedbackType.medium,
                );
                
                if (!widget.enablePulseAnimation && !settings.reducedMotionMode) {
                  await _animationController.forward();
                  await _animationController.reverse();
                }
                
                widget.onPressed!();
              },
              tooltip: widget.tooltip,
              backgroundColor: widget.backgroundColor,
              foregroundColor: widget.foregroundColor,
              mini: widget.mini,
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Loading indicator types
enum LoadingIndicatorType {
  circular,
  pulse,
  dots,
}