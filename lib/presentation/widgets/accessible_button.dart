import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/accessibility/accessibility_constants.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/theme/typography_constants.dart';
import 'glassmorphism_container.dart';

/// Accessible button with glassmorphism design and WCAG AA compliance
class AccessibleButton extends StatefulWidget {
  final String label;
  final String? semanticHint;
  final VoidCallback? onPressed;
  final Widget? child;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final bool enabled;
  final bool isSecondary;
  final bool showFocusIndicator;
  final GlassLevel glassLevel;
  final bool enableHapticFeedback;
  
  const AccessibleButton({
    super.key,
    required this.label,
    this.semanticHint,
    this.onPressed,
    this.child,
    this.icon,
    this.color,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.enabled = true,
    this.isSecondary = false,
    this.showFocusIndicator = true,
    this.glassLevel = GlassLevel.interactive,
    this.enableHapticFeedback = true,
  });
  
  /// Factory for primary button
  factory AccessibleButton.primary({
    Key? key,
    required String label,
    String? semanticHint,
    VoidCallback? onPressed,
    Widget? child,
    IconData? icon,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadiusGeometry? borderRadius,
    bool enabled = true,
    bool enableHapticFeedback = true,
  }) {
    return AccessibleButton(
      key: key,
      label: label,
      semanticHint: semanticHint,
      onPressed: onPressed,
      icon: icon,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      enabled: enabled,
      isSecondary: false,
      glassLevel: GlassLevel.interactive,
      enableHapticFeedback: enableHapticFeedback,
      child: child,
    );
  }
  
  /// Factory for secondary button
  factory AccessibleButton.secondary({
    Key? key,
    required String label,
    String? semanticHint,
    VoidCallback? onPressed,
    Widget? child,
    IconData? icon,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadiusGeometry? borderRadius,
    bool enabled = true,
    bool enableHapticFeedback = true,
  }) {
    return AccessibleButton(
      key: key,
      label: label,
      semanticHint: semanticHint,
      onPressed: onPressed,
      icon: icon,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      enabled: enabled,
      isSecondary: true,
      glassLevel: GlassLevel.content,
      enableHapticFeedback: enableHapticFeedback,
      child: child,
    );
  }

  @override
  State<AccessibleButton> createState() => _AccessibleButtonState();
}

class _AccessibleButtonState extends State<AccessibleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  bool _isPressed = false;
  bool _isHovered = false;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100), // Keep ultra-fast for accessibility feedback
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
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

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = true);
    _controller.forward();
    if (widget.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.enabled && widget.onPressed != null) {
      widget.onPressed!();
      if (widget.enableHapticFeedback) {
        HapticFeedback.lightImpact();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);
    final shouldReduceMotion = AccessibilityUtils.shouldReduceMotion(context);
    
    // Calculate minimum dimensions
    final minWidth = widget.width ?? AccessibilityConstants.minTouchTarget;
    final minHeight = widget.height ?? AccessibilityConstants.minTouchTarget;
    
    // Get colors based on button type and state
    final backgroundColor = _getBackgroundColor(theme);
    final foregroundColor = _getForegroundColor(theme);
    
    return Container(
      margin: widget.margin,
      child: Semantics(
        label: widget.label,
        hint: widget.semanticHint ?? 'Button',
        button: true,
        enabled: widget.enabled,
        onTap: widget.enabled ? _handleTap : null,
        child: Focus(
          child: Builder(
            builder: (context) {
              final hasFocus = Focus.of(context).hasFocus;
              
              return MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: GestureDetector(
                  onTapDown: _handleTapDown,
                  onTapUp: _handleTapUp,
                  onTapCancel: _handleTapCancel,
                  onTap: _handleTap,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      // Apply accessibility-aware animations
                      final scale = shouldReduceMotion ? 1.0 : _scaleAnimation.value;
                      final opacity = shouldReduceMotion ? 1.0 : _opacityAnimation.value;
                      
                      return Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: widget.enabled ? opacity : 0.6,
                          child: Container(
                            constraints: BoxConstraints(
                              minWidth: minWidth,
                              minHeight: minHeight,
                            ),
                            decoration: (hasFocus && widget.showFocusIndicator)
                                ? BoxDecoration(
                                    border: Border.all(
                                      color: AccessibilityConstants.focusIndicatorColor,
                                      width: AccessibilityConstants.focusIndicatorWidth,
                                    ),
                                    borderRadius: widget.borderRadius ??
                                        BorderRadius.circular(TypographyConstants.radiusStandard),
                                  )
                                : null,
                            child: GlassmorphismContainer(
                              level: widget.glassLevel,
                              width: widget.width,
                              height: widget.height,
                              padding: widget.padding ?? EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: isLargeText ? 16 : 12,
                              ),
                              borderRadius: widget.borderRadius ??
                                  BorderRadius.circular(TypographyConstants.radiusStandard),
                              glassTint: backgroundColor,
                              borderColor: _getBorderColor(theme),
                              child: _buildButtonContent(theme, foregroundColor, isLargeText),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(ThemeData theme, Color foregroundColor, bool isLargeText) {
    if (widget.child != null) {
      return widget.child!;
    }

    final List<Widget> children = [];

    if (widget.icon != null) {
      children.add(
        Icon(
          widget.icon,
          size: isLargeText ? 24 : 20,
          color: foregroundColor,
        ),
      );
      
      if (widget.label.isNotEmpty) {
        children.add(const SizedBox(width: 8));
      }
    }

    if (widget.label.isNotEmpty) {
      children.add(
        Text(
          widget.label,
          style: TextStyle(
            fontSize: isLargeText 
                ? TypographyConstants.textLG 
                : TypographyConstants.textBase,
            fontWeight: widget.isSecondary 
                ? TypographyConstants.medium 
                : TypographyConstants.medium,
            color: foregroundColor,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (widget.color != null) return widget.color!;
    
    if (!widget.enabled) {
      return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    }
    
    if (_isPressed) {
      return widget.isSecondary
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.8)
          : theme.colorScheme.primary.withValues(alpha: 0.9);
    }
    
    if (_isHovered) {
      return widget.isSecondary
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.6)
          : theme.colorScheme.primary.withValues(alpha: 0.8);
    }
    
    return widget.isSecondary
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
        : theme.colorScheme.primary.withValues(alpha: 0.7);
  }

  Color _getForegroundColor(ThemeData theme) {
    if (widget.textColor != null) return widget.textColor!;
    
    if (!widget.enabled) {
      return theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6);
    }
    
    return widget.isSecondary
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onPrimary;
  }

  Color _getBorderColor(ThemeData theme) {
    if (!widget.enabled) {
      return theme.colorScheme.outline.withValues(alpha: 0.2);
    }
    
    if (_isPressed) {
      return theme.colorScheme.primary.withValues(alpha: 0.6);
    }
    
    if (_isHovered) {
      return theme.colorScheme.primary.withValues(alpha: 0.4);
    }
    
    return theme.colorScheme.outline.withValues(alpha: 0.3);
  }
}

/// Accessible icon button with glassmorphism design
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? semanticHint;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? iconColor;
  final double size;
  final bool enabled;
  final bool showTooltip;
  final EdgeInsetsGeometry? margin;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.semanticHint,
    this.onPressed,
    this.color,
    this.iconColor,
    this.size = AccessibilityConstants.minTouchTarget,
    this.enabled = true,
    this.showTooltip = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final button = AccessibleButton(
      label: label,
      semanticHint: semanticHint ?? '$label button',
      onPressed: onPressed,
      width: size,
      height: size,
      padding: EdgeInsets.zero,
      margin: margin,
      borderRadius: BorderRadius.circular(size / 2),
      enabled: enabled,
      glassLevel: GlassLevel.interactive,
      child: Icon(
        icon,
        size: size * 0.5,
        color: iconColor ?? theme.colorScheme.onPrimary,
      ),
    );

    if (showTooltip && enabled) {
      return Tooltip(
        message: label,
        preferBelow: false,
        child: button,
      );
    }

    return button;
  }
}