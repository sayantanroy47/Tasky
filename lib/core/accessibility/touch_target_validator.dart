import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'accessibility_constants.dart';

/// Touch target validation and enforcement utilities
class TouchTargetValidator {
  /// Validate if a widget meets minimum touch target requirements
  static bool validateTouchTarget(Size size, {double minSize = AccessibilityConstants.minTouchTarget}) {
    return size.width >= minSize && size.height >= minSize;
  }

  /// Get the minimum padding needed to reach target size
  static EdgeInsets getMinimumPadding(
    Size currentSize, 
    {double targetSize = AccessibilityConstants.minTouchTarget}
  ) {
    final widthPadding = math.max(0, (targetSize - currentSize.width) / 2).toDouble();
    final heightPadding = math.max(0, (targetSize - currentSize.height) / 2).toDouble();
    
    return EdgeInsets.symmetric(
      horizontal: widthPadding,
      vertical: heightPadding,
    );
  }

  /// Create accessible touch target wrapper
  static Widget createAccessibleTouchTarget({
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    String? semanticLabel,
    String? tooltip,
    double minSize = AccessibilityConstants.minTouchTarget,
    EdgeInsets? additionalPadding,
    bool enableFeedback = true,
  }) {
    return AccessibleTouchTarget(
      onTap: onTap,
      onLongPress: onLongPress,
      semanticLabel: semanticLabel,
      tooltip: tooltip,
      minSize: minSize,
      additionalPadding: additionalPadding,
      enableFeedback: enableFeedback,
      child: child,
    );
  }
}

/// Widget that automatically enforces minimum touch target size
class AccessibleTouchTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final String? tooltip;
  final double minSize;
  final EdgeInsets? additionalPadding;
  final bool enableFeedback;
  final BorderRadius? borderRadius;

  const AccessibleTouchTarget({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.tooltip,
    this.minSize = AccessibilityConstants.minTouchTarget,
    this.additionalPadding,
    this.enableFeedback = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget wrappedChild = child;

    // Add tooltip if provided
    if (tooltip != null) {
      wrappedChild = Tooltip(
        message: tooltip!,
        child: wrappedChild,
      );
    }

    // Add semantics if provided
    if (semanticLabel != null) {
      wrappedChild = Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: wrappedChild,
      );
    }

    // Ensure minimum touch target size
    wrappedChild = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: wrappedChild,
    );

    // Add additional padding if specified
    if (additionalPadding != null) {
      wrappedChild = Padding(
        padding: additionalPadding!,
        child: wrappedChild,
      );
    }

    // Add interactive behavior
    if (onTap != null || onLongPress != null) {
      wrappedChild = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: borderRadius,
          enableFeedback: enableFeedback,
          child: wrappedChild,
        ),
      );
    }

    return wrappedChild;
  }
}

/// Accessible icon button with enforced touch target
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final String? semanticLabel;
  final double? iconSize;
  final Color? iconColor;
  final double minTouchTarget;
  final EdgeInsets? padding;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.semanticLabel,
    this.iconSize,
    this.iconColor,
    this.minTouchTarget = AccessibilityConstants.minTouchTarget,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconSize = iconSize ?? 24.0;

    return AccessibleTouchTarget(
      onTap: onPressed,
      tooltip: tooltip,
      semanticLabel: semanticLabel ?? tooltip,
      minSize: minTouchTarget,
      additionalPadding: padding,
      borderRadius: BorderRadius.circular(minTouchTarget / 2),
      child: Icon(
        icon,
        size: effectiveIconSize,
        color: iconColor ?? theme.colorScheme.onSurface,
      ),
    );
  }
}

/// Accessible floating action button with enforced size
class AccessibleFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;
  final String? semanticLabel;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool mini;
  final double? customSize;

  const AccessibleFAB({
    super.key,
    this.onPressed,
    required this.child,
    this.tooltip,
    this.semanticLabel,
    this.backgroundColor,
    this.foregroundColor,
    this.mini = false,
    this.customSize,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSize = customSize ?? 
        (mini ? AccessibilityConstants.minTouchTarget : AccessibilityConstants.recommendedTouchTarget);

    return Semantics(
      label: semanticLabel ?? tooltip,
      button: true,
      enabled: onPressed != null,
      child: SizedBox(
        width: effectiveSize,
        height: effectiveSize,
        child: FloatingActionButton(
          onPressed: onPressed,
          tooltip: tooltip,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          mini: false, // Always use regular size for accessibility
          child: child,
        ),
      ),
    );
  }
}

/// Accessible card with proper touch targets
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final double minTouchTarget;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.margin,
    this.padding,
    this.elevation,
    this.color,
    this.borderRadius,
    this.minTouchTarget = AccessibilityConstants.minTouchTarget,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);

    return Container(
      margin: margin,
      child: Card(
        elevation: elevation,
        color: color,
        shape: RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
        child: AccessibleTouchTarget(
          onTap: onTap,
          onLongPress: onLongPress,
          semanticLabel: semanticLabel,
          minSize: minTouchTarget,
          borderRadius: effectiveBorderRadius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Accessible list tile with proper touch targets
class AccessibleListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final bool selected;
  final bool enabled;
  final double minTouchTarget;
  final EdgeInsets? contentPadding;

  const AccessibleListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.selected = false,
    this.enabled = true,
    this.minTouchTarget = AccessibilityConstants.minTouchTarget,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      selected: selected,
      enabled: enabled,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: minTouchTarget,
        ),
        child: ListTile(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          onTap: enabled ? onTap : null,
          onLongPress: enabled ? onLongPress : null,
          selected: selected,
          enabled: enabled,
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),
    );
  }
}

/// Accessible checkbox with proper touch target
class AccessibleCheckbox extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? semanticLabel;
  final bool tristate;
  final double minTouchTarget;

  const AccessibleCheckbox({
    super.key,
    this.value,
    this.onChanged,
    this.semanticLabel,
    this.tristate = false,
    this.minTouchTarget = AccessibilityConstants.minTouchTarget,
  });

  @override
  Widget build(BuildContext context) {
    String stateLabel = '';
    if (value == true) {
      stateLabel = 'Checked';
    } else if (value == false) {
      stateLabel = 'Unchecked';
    } else {
      stateLabel = 'Partially checked';
    }

    return AccessibleTouchTarget(
      onTap: onChanged != null ? () => onChanged!(!tristate && value == true ? false : true) : null,
      semanticLabel: semanticLabel != null ? '$semanticLabel, $stateLabel' : stateLabel,
      minSize: minTouchTarget,
      child: SizedBox(
        width: minTouchTarget,
        height: minTouchTarget,
        child: Checkbox(
          value: value,
          onChanged: onChanged,
          tristate: tristate,
        ),
      ),
    );
  }
}

/// Accessible radio button with proper touch target
class AccessibleRadio<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String? semanticLabel;
  final double minTouchTarget;

  const AccessibleRadio({
    super.key,
    required this.value,
    this.groupValue,
    this.onChanged,
    this.semanticLabel,
    this.minTouchTarget = AccessibilityConstants.minTouchTarget,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final stateLabel = isSelected ? 'Selected' : 'Not selected';

    return AccessibleTouchTarget(
      onTap: onChanged != null ? () => onChanged!(value) : null,
      semanticLabel: semanticLabel != null ? '$semanticLabel, $stateLabel' : stateLabel,
      minSize: minTouchTarget,
      child: SizedBox(
        width: minTouchTarget,
        height: minTouchTarget,
        child: GestureDetector(
          onTap: onChanged != null ? () => onChanged!(value) : null,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

/// Accessible switch with proper touch target
class AccessibleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;
  final String? activeLabel;
  final String? inactiveLabel;
  final double minTouchTarget;

  const AccessibleSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.semanticLabel,
    this.activeLabel,
    this.inactiveLabel,
    this.minTouchTarget = AccessibilityConstants.minTouchTarget,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = semanticLabel ?? 
        (value ? (activeLabel ?? 'On') : (inactiveLabel ?? 'Off'));

    return AccessibleTouchTarget(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      semanticLabel: effectiveLabel,
      minSize: minTouchTarget,
      child: SizedBox(
        height: minTouchTarget,
        child: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Accessible text button with enforced touch target
class AccessibleTextButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final ButtonStyle? style;
  final double minTouchTarget;

  const AccessibleTextButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.style,
    this.minTouchTarget = AccessibilityConstants.minTouchTarget,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minTouchTarget,
          minHeight: minTouchTarget,
        ),
        child: TextButton(
          onPressed: onPressed,
          style: style,
          child: child,
        ),
      ),
    );
  }
}

/// Accessible elevated button with enforced touch target
class AccessibleElevatedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final ButtonStyle? style;
  final double minTouchTarget;

  const AccessibleElevatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.style,
    this.minTouchTarget = AccessibilityConstants.minTouchTarget,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minTouchTarget,
          minHeight: minTouchTarget,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: style,
          child: child,
        ),
      ),
    );
  }
}

/// Accessible outlined button with enforced touch target
class AccessibleOutlinedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final ButtonStyle? style;
  final double minTouchTarget;

  const AccessibleOutlinedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.style,
    this.minTouchTarget = AccessibilityConstants.minTouchTarget,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minTouchTarget,
          minHeight: minTouchTarget,
        ),
        child: OutlinedButton(
          onPressed: onPressed,
          style: style,
          child: child,
        ),
      ),
    );
  }
}