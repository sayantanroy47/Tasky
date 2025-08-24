import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for managing mobile-optimized touch targets and interactions
/// Ensures proper sizing, spacing, and accessibility for mobile devices
class MobileTouchTargetsService {
  static const double _minTouchTargetSize = 44.0; // Apple/Google guidelines
  static const double _preferredTouchTargetSize = 48.0;
  static const double _largeTouchTargetSize = 56.0;
  static const double _minTouchTargetSpacing = 8.0;
  static const double _preferredTouchTargetSpacing = 12.0;

  /// Creates a touch-optimized container with proper sizing and feedback
  Widget createTouchTarget({
    required Widget child,
    required VoidCallback? onTap,
    VoidCallback? onLongPress,
    VoidCallback? onDoubleTap,
    String? semanticLabel,
    String? tooltip,
    TouchTargetSize size = TouchTargetSize.standard,
    TouchTargetType type = TouchTargetType.button,
    bool enableHapticFeedback = true,
    bool enableVisualFeedback = true,
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? foregroundColor,
    BorderRadius? borderRadius,
  }) {
    final targetSize = _getTouchTargetSize(size);
    final targetPadding = padding ?? const EdgeInsets.all(_preferredTouchTargetSpacing / 2);

    return _TouchTargetWidget(
      size: targetSize,
      onTap: onTap,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      semanticLabel: semanticLabel,
      tooltip: tooltip,
      type: type,
      enableHapticFeedback: enableHapticFeedback,
      enableVisualFeedback: enableVisualFeedback,
      padding: targetPadding,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderRadius: borderRadius ?? BorderRadius.circular(targetSize / 8),
      child: child,
    );
  }

  /// Creates a touch-optimized button with proper feedback
  Widget createTouchButton({
    required Widget child,
    required VoidCallback? onPressed,
    String? semanticLabel,
    String? tooltip,
    TouchTargetSize size = TouchTargetSize.standard,
    ButtonStyle? style,
    bool enableHapticFeedback = true,
    bool enableVisualFeedback = true,
  }) {
    return createTouchTarget(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      tooltip: tooltip,
      size: size,
      type: TouchTargetType.button,
      enableHapticFeedback: enableHapticFeedback,
      enableVisualFeedback: enableVisualFeedback,
      child: child,
    );
  }

  /// Creates a touch-optimized icon button
  Widget createTouchIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    String? semanticLabel,
    String? tooltip,
    TouchTargetSize size = TouchTargetSize.standard,
    Color? color,
    bool enableHapticFeedback = true,
    bool enableVisualFeedback = true,
  }) {
    final iconSize = _getIconSize(size);
    
    return createTouchTarget(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      tooltip: tooltip,
      size: size,
      type: TouchTargetType.iconButton,
      enableHapticFeedback: enableHapticFeedback,
      enableVisualFeedback: enableVisualFeedback,
      child: Icon(
        icon,
        size: iconSize,
        color: color,
      ),
    );
  }

  /// Creates a touch-optimized list tile
  Widget createTouchListTile({
    required Widget title,
    Widget? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    String? semanticLabel,
    bool enableHapticFeedback = true,
    bool enableVisualFeedback = true,
    EdgeInsets? contentPadding,
  }) {
    return createTouchTarget(
      onTap: onTap,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel,
      size: TouchTargetSize.large,
      type: TouchTargetType.listItem,
      enableHapticFeedback: enableHapticFeedback,
      enableVisualFeedback: enableVisualFeedback,
      padding: contentPadding ?? const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading,
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                title,
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  subtitle,
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 16),
            trailing,
          ],
        ],
      ),
    );
  }

  /// Creates a touch-optimized floating action button
  Widget createTouchFAB({
    required Widget child,
    required VoidCallback? onPressed,
    String? semanticLabel,
    String? tooltip,
    Color? backgroundColor,
    Color? foregroundColor,
    bool mini = false,
    bool enableHapticFeedback = true,
    bool enableVisualFeedback = true,
  }) {
    final fabSize = mini ? TouchTargetSize.standard : TouchTargetSize.large;
    
    return createTouchTarget(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      tooltip: tooltip,
      size: fabSize,
      type: TouchTargetType.fab,
      enableHapticFeedback: enableHapticFeedback,
      enableVisualFeedback: enableVisualFeedback,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderRadius: BorderRadius.circular(mini ? 20 : 28),
      child: child,
    );
  }

  /// Creates a touch-optimized toggle button (switch, checkbox, radio)
  Widget createTouchToggle({
    required Widget child,
    required bool value,
    required ValueChanged<bool>? onChanged,
    String? semanticLabel,
    TouchToggleType toggleType = TouchToggleType.toggle,
    bool enableHapticFeedback = true,
    bool enableVisualFeedback = true,
  }) {
    return createTouchTarget(
      onTap: onChanged != null ? () => onChanged(!value) : null,
      semanticLabel: semanticLabel,
      size: TouchTargetSize.standard,
      type: TouchTargetType.toggle,
      enableHapticFeedback: enableHapticFeedback,
      enableVisualFeedback: enableVisualFeedback,
      child: child,
    );
  }

  /// Creates a spacing widget that ensures proper touch target separation
  Widget createTouchSpacing({
    TouchTargetSize fromSize = TouchTargetSize.standard,
    TouchTargetSize toSize = TouchTargetSize.standard,
    Axis direction = Axis.horizontal,
  }) {
    final spacing = _calculateOptimalSpacing(fromSize, toSize);
    
    return direction == Axis.horizontal
        ? SizedBox(width: spacing)
        : SizedBox(height: spacing);
  }

  /// Validates touch target accessibility and provides recommendations
  TouchTargetValidation validateTouchTarget({
    required double width,
    required double height,
    required EdgeInsets padding,
    TouchTargetType type = TouchTargetType.button,
  }) {
    final totalWidth = width + padding.horizontal;
    final totalHeight = height + padding.vertical;
    final issues = <TouchTargetIssue>[];
    final recommendations = <String>[];

    // Check minimum size requirements
    if (totalWidth < _minTouchTargetSize) {
      issues.add(TouchTargetIssue.tooSmallWidth);
      recommendations.add('Increase width to at least ${_minTouchTargetSize}dp');
    }

    if (totalHeight < _minTouchTargetSize) {
      issues.add(TouchTargetIssue.tooSmallHeight);
      recommendations.add('Increase height to at least ${_minTouchTargetSize}dp');
    }

    // Check preferred size recommendations
    if (totalWidth < _preferredTouchTargetSize && !issues.contains(TouchTargetIssue.tooSmallWidth)) {
      recommendations.add('Consider increasing width to ${_preferredTouchTargetSize}dp for better accessibility');
    }

    if (totalHeight < _preferredTouchTargetSize && !issues.contains(TouchTargetIssue.tooSmallHeight)) {
      recommendations.add('Consider increasing height to ${_preferredTouchTargetSize}dp for better accessibility');
    }

    // Type-specific validations
    switch (type) {
      case TouchTargetType.fab:
        if (totalWidth < _largeTouchTargetSize || totalHeight < _largeTouchTargetSize) {
          recommendations.add('FABs should be at least ${_largeTouchTargetSize}dp for optimal touch experience');
        }
        break;
      case TouchTargetType.listItem:
        if (totalHeight < _largeTouchTargetSize) {
          recommendations.add('List items should be at least ${_largeTouchTargetSize}dp tall for easy selection');
        }
        break;
      default:
        break;
    }

    return TouchTargetValidation(
      isValid: issues.isEmpty,
      issues: issues,
      recommendations: recommendations,
      actualSize: Size(totalWidth, totalHeight),
      minRecommendedSize: const Size(_minTouchTargetSize, _minTouchTargetSize),
      preferredSize: const Size(_preferredTouchTargetSize, _preferredTouchTargetSize),
    );
  }

  /// Gets the appropriate touch target size for the given size enum
  double _getTouchTargetSize(TouchTargetSize size) {
    switch (size) {
      case TouchTargetSize.small:
        return _minTouchTargetSize;
      case TouchTargetSize.standard:
        return _preferredTouchTargetSize;
      case TouchTargetSize.large:
        return _largeTouchTargetSize;
    }
  }

  /// Gets the appropriate icon size for the given touch target size
  double _getIconSize(TouchTargetSize size) {
    switch (size) {
      case TouchTargetSize.small:
        return 18.0;
      case TouchTargetSize.standard:
        return 24.0;
      case TouchTargetSize.large:
        return 32.0;
    }
  }

  /// Calculates optimal spacing between touch targets
  double _calculateOptimalSpacing(TouchTargetSize fromSize, TouchTargetSize toSize) {
    final fromTargetSize = _getTouchTargetSize(fromSize);
    final toTargetSize = _getTouchTargetSize(toSize);
    final averageSize = (fromTargetSize + toTargetSize) / 2;
    
    // Use a percentage of average target size as spacing
    return (averageSize * 0.25).clamp(_minTouchTargetSpacing, 24.0);
  }
}

/// Custom touch target widget with proper feedback and accessibility
class _TouchTargetWidget extends StatefulWidget {
  final double size;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final String? semanticLabel;
  final String? tooltip;
  final TouchTargetType type;
  final bool enableHapticFeedback;
  final bool enableVisualFeedback;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius borderRadius;

  const _TouchTargetWidget({
    required this.size,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.semanticLabel,
    this.tooltip,
    required this.type,
    required this.enableHapticFeedback,
    required this.enableVisualFeedback,
    required this.padding,
    this.backgroundColor,
    this.foregroundColor,
    required this.borderRadius,
  });

  @override
  State<_TouchTargetWidget> createState() => _TouchTargetWidgetState();
}

class _TouchTargetWidgetState extends State<_TouchTargetWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget child = Container(
      constraints: BoxConstraints(
        minWidth: widget.size,
        minHeight: widget.size,
      ),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: widget.borderRadius,
      ),
      child: widget.child,
    );

    if (widget.tooltip != null) {
      child = Tooltip(
        message: widget.tooltip!,
        child: child,
      );
    }

    child = Semantics(
      label: widget.semanticLabel,
      button: widget.type == TouchTargetType.button || 
              widget.type == TouchTargetType.iconButton ||
              widget.type == TouchTargetType.fab,
      child: child,
    );

    if (widget.enableVisualFeedback) {
      child = AnimatedBuilder(
        animation: _animationController,
        builder: (context, animatedChild) {
          return Transform.scale(
            scale: _isPressed ? _scaleAnimation.value : 1.0,
            child: Opacity(
              opacity: _isPressed ? _opacityAnimation.value : 1.0,
              child: animatedChild,
            ),
          );
        },
        child: child,
      );
    }

    return GestureDetector(
      onTap: widget.onTap == null ? null : () => _handleTap(context),
      onLongPress: widget.onLongPress == null ? null : () => _handleLongPress(context),
      onDoubleTap: widget.onDoubleTap == null ? null : () => _handleDoubleTap(context),
      onTapDown: widget.enableVisualFeedback ? _handleTapDown : null,
      onTapUp: widget.enableVisualFeedback ? _handleTapUp : null,
      onTapCancel: widget.enableVisualFeedback ? _handleTapCancel : null,
      child: child,
    );
  }

  void _handleTap(BuildContext context) {
    if (widget.enableHapticFeedback) {
      _provideHapticFeedback(widget.type);
    }
    widget.onTap!();
  }

  void _handleLongPress(BuildContext context) {
    if (widget.enableHapticFeedback) {
      HapticFeedback.heavyImpact();
    }
    widget.onLongPress!();
  }

  void _handleDoubleTap(BuildContext context) {
    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    widget.onDoubleTap!();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enableVisualFeedback) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enableVisualFeedback) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enableVisualFeedback) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _provideHapticFeedback(TouchTargetType type) {
    switch (type) {
      case TouchTargetType.button:
      case TouchTargetType.iconButton:
        HapticFeedback.selectionClick();
        break;
      case TouchTargetType.fab:
        HapticFeedback.mediumImpact();
        break;
      case TouchTargetType.listItem:
        HapticFeedback.lightImpact();
        break;
      case TouchTargetType.toggle:
        HapticFeedback.selectionClick();
        break;
      case TouchTargetType.card:
        HapticFeedback.lightImpact();
        break;
    }
  }
}

/// Enumeration for touch target sizes
enum TouchTargetSize {
  small,   // 44dp - minimum accessible size
  standard, // 48dp - preferred size
  large,   // 56dp - for prominent actions
}

/// Enumeration for touch target types
enum TouchTargetType {
  button,
  iconButton,
  fab,
  listItem,
  toggle,
  card,
}

/// Enumeration for toggle types
enum TouchToggleType {
  toggle,
  checkbox,
  radio,
}

/// Touch target validation result
class TouchTargetValidation {
  final bool isValid;
  final List<TouchTargetIssue> issues;
  final List<String> recommendations;
  final Size actualSize;
  final Size minRecommendedSize;
  final Size preferredSize;

  const TouchTargetValidation({
    required this.isValid,
    required this.issues,
    required this.recommendations,
    required this.actualSize,
    required this.minRecommendedSize,
    required this.preferredSize,
  });
}

/// Touch target issues
enum TouchTargetIssue {
  tooSmallWidth,
  tooSmallHeight,
  insufficientSpacing,
  noSemanticLabel,
  noHapticFeedback,
}

/// Provider for mobile touch targets service
final mobileTouchTargetsServiceProvider = Provider<MobileTouchTargetsService>((ref) {
  return MobileTouchTargetsService();
});