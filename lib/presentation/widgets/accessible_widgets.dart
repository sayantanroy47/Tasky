import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/accessibility_service.dart';

/// Accessible button with proper semantics and haptic feedback
class AccessibleButton extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final ButtonStyle? style;
  final bool autofocus;
  final FocusNode? focusNode;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.style,
    this.autofocus = false,
    this.focusNode,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibilityService = ref.read(accessibilityServiceProvider);
    
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: Tooltip(
        message: tooltip ?? '',
        child: ElevatedButton(
          onPressed: onPressed == null ? null : () async {
            await accessibilityService.provideHapticFeedback(HapticFeedbackType.selection);
            onPressed!();
          },
          style: style,
          autofocus: autofocus,
          focusNode: focusNode,
          child: child,
        ),
      ),
    );
  }
}

/// Accessible text field with proper semantics
class AccessibleTextField extends ConsumerWidget {
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

  const AccessibleTextField({
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
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibilityService = ref.read(accessibilityServiceProvider);
    final settings = ref.watch(accessibilitySettingsProvider);
    
    return Semantics(
      label: semanticLabel ?? labelText,
      textField: true,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          errorText: errorText,
          border: const OutlineInputBorder(),
          // Ensure good contrast for borders
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: settings.highContrastMode 
                  ? Colors.black 
                  : Theme.of(context).colorScheme.outline,
              width: settings.highContrastMode ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: settings.highContrastMode 
                  ? Colors.black 
                  : Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onTap: onTap == null ? null : () async {
          await accessibilityService.provideHapticFeedback(HapticFeedbackType.selection);
          onTap!();
        },
        readOnly: readOnly,
        maxLines: maxLines,
        focusNode: focusNode,
        autofocus: autofocus,
        style: settings.largeTextMode 
            ? Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18)
            : null,
      ),
    );
  }
}

/// Accessible list tile with proper semantics
class AccessibleListTile extends ConsumerWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool selected;
  final bool enabled;
  final FocusNode? focusNode;

  const AccessibleListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.selected = false,
    this.enabled = true,
    this.focusNode,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibilityService = ref.read(accessibilityServiceProvider);
    final settings = ref.watch(accessibilitySettingsProvider);
    
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      selected: selected,
      enabled: enabled,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap == null ? null : () async {
          await accessibilityService.provideHapticFeedback(HapticFeedbackType.selection);
          onTap!();
        },
        selected: selected,
        enabled: enabled,
        focusNode: focusNode,
        // Ensure good contrast for selected state
        selectedTileColor: settings.highContrastMode 
            ? Colors.grey[300] 
            : Theme.of(context).colorScheme.primaryContainer,
        // Larger touch target for accessibility
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

/// Accessible switch with proper semantics
class AccessibleSwitch extends ConsumerWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;
  final String? activeLabel;
  final String? inactiveLabel;

  const AccessibleSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.semanticLabel,
    this.activeLabel,
    this.inactiveLabel,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibilityService = ref.read(accessibilityServiceProvider);
    final settings = ref.watch(accessibilitySettingsProvider);
    final effectiveLabel = semanticLabel ?? 
        (value ? (activeLabel ?? 'On') : (inactiveLabel ?? 'Off'));

    return Semantics(
      label: effectiveLabel,
      toggled: value,
      child: Switch(
        value: value,
        onChanged: onChanged == null ? null : (newValue) async {
          await accessibilityService.provideHapticFeedback(HapticFeedbackType.selection);
          onChanged!(newValue);
          
          // Announce state change for screen readers
          accessibilityService.announceForScreenReader(
            newValue ? (activeLabel ?? 'Switched on') : (inactiveLabel ?? 'Switched off')
          );
        },
        // Ensure good contrast
        activeColor: settings.highContrastMode 
            ? Colors.black 
            : Theme.of(context).colorScheme.primary,
        inactiveThumbColor: settings.highContrastMode 
            ? Colors.white 
            : null,
        inactiveTrackColor: settings.highContrastMode 
            ? Colors.grey[400] 
            : null,
      ),
    );
  }
}

/// Accessible card with proper semantics and focus handling
class AccessibleCard extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final FocusNode? focusNode;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.margin,
    this.padding,
    this.color,
    this.elevation,
    this.focusNode,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibilityService = ref.read(accessibilityServiceProvider);
    final settings = ref.watch(accessibilitySettingsProvider);
    
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: Card(
        margin: margin,
        color: color,
        elevation: elevation,
        // Ensure good contrast
        shadowColor: settings.highContrastMode ? Colors.black : null,
        child: InkWell(
          onTap: onTap == null ? null : () async {
            await accessibilityService.provideHapticFeedback(HapticFeedbackType.selection);
            onTap!();
          },
          focusNode: focusNode,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Accessible icon button with proper semantics
class AccessibleIconButton extends ConsumerWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final double? iconSize;
  final Color? color;
  final FocusNode? focusNode;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.iconSize,
    this.color,
    this.focusNode,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibilityService = ref.read(accessibilityServiceProvider);
    final settings = ref.watch(accessibilitySettingsProvider);
    
    return Semantics(
      label: semanticLabel ?? tooltip,
      button: true,
      enabled: onPressed != null,
      child: Tooltip(
        message: tooltip ?? semanticLabel ?? '',
        child: IconButton(
          icon: Icon(
            icon,
            size: iconSize ?? (settings.largeTextMode ? 28 : 24),
            color: color,
          ),
          onPressed: onPressed == null ? null : () async {
            await accessibilityService.provideHapticFeedback(HapticFeedbackType.selection);
            onPressed!();
          },
          focusNode: focusNode,
          // Larger touch target for accessibility
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
      ),
    );
  }
}

/// Accessible floating action button
class AccessibleFAB extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool mini;

  const AccessibleFAB({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.mini = false,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibilityService = ref.read(accessibilityServiceProvider);
    
    return Semantics(
      label: semanticLabel ?? tooltip,
      button: true,
      enabled: onPressed != null,
      child: FloatingActionButton(
        onPressed: onPressed == null ? null : () async {
          await accessibilityService.provideHapticFeedback(HapticFeedbackType.medium);
          onPressed!();
        },
        tooltip: tooltip,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        mini: mini,
        child: child,
      ),
    );
  }
}

/// Accessible slider with proper semantics
class AccessibleSlider extends ConsumerWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? semanticLabel;
  final String Function(double)? semanticFormatterCallback;

  const AccessibleSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.semanticLabel,
    this.semanticFormatterCallback,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibilityService = ref.read(accessibilityServiceProvider);
    final settings = ref.watch(accessibilitySettingsProvider);
    
    return Semantics(
      label: semanticLabel,
      slider: true,
      value: value.toString(),
      child: Slider(
        value: value,
        onChanged: onChanged == null ? null : (newValue) async {
          await accessibilityService.provideHapticFeedback(HapticFeedbackType.selection);
          onChanged!(newValue);
        },
        min: min,
        max: max,
        divisions: divisions,
        semanticFormatterCallback: semanticFormatterCallback,
        // Ensure good contrast
        activeColor: settings.highContrastMode 
            ? Colors.black 
            : Theme.of(context).colorScheme.primary,
        inactiveColor: settings.highContrastMode 
            ? Colors.grey[400] 
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.24),
      ),
    );
  }
}

/// Accessible checkbox with proper semantics
class AccessibleCheckbox extends ConsumerWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? semanticLabel;
  final bool tristate;

  const AccessibleCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.semanticLabel,
    this.tristate = false,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibilityService = ref.read(accessibilityServiceProvider);
    final settings = ref.watch(accessibilitySettingsProvider);
    
    String stateLabel = '';
    if (value == true) {
      stateLabel = 'Checked';
    } else if (value == false) {
      stateLabel = 'Unchecked';
    } else {
      stateLabel = 'Partially checked';
    }

    return Semantics(
      label: semanticLabel != null ? '$semanticLabel, $stateLabel' : stateLabel,
      checked: value,
      child: Checkbox(
        value: value,
        onChanged: onChanged == null ? null : (newValue) async {
          await accessibilityService.provideHapticFeedback(HapticFeedbackType.selection);
          onChanged!(newValue);
          
          // Announce state change
          final newStateLabel = newValue == true ? 'Checked' : 'Unchecked';
          accessibilityService.announceForScreenReader(newStateLabel);
        },
        tristate: tristate,
        // Ensure good contrast
        activeColor: settings.highContrastMode 
            ? Colors.black 
            : Theme.of(context).colorScheme.primary,
        checkColor: settings.highContrastMode 
            ? Colors.white 
            : Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}

/// Accessible radio button with proper semantics
class AccessibleRadio<T> extends ConsumerWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String? semanticLabel;

  const AccessibleRadio({
    super.key,
    required this.value,
    this.groupValue,
    this.onChanged,
    this.semanticLabel,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibilityService = ref.read(accessibilityServiceProvider);
    final settings = ref.watch(accessibilitySettingsProvider);
    final isSelected = value == groupValue;
    final stateLabel = isSelected ? 'Selected' : 'Not selected';

    return Semantics(
      label: semanticLabel != null ? '$semanticLabel, $stateLabel' : stateLabel,
      inMutuallyExclusiveGroup: true,
      checked: isSelected,
      child: Radio<T>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged == null ? null : (newValue) async {
          await accessibilityService.provideHapticFeedback(HapticFeedbackType.selection);
          onChanged!(newValue);
          
          // Announce selection
          accessibilityService.announceForScreenReader('Selected');
        },
        // Ensure good contrast
        activeColor: settings.highContrastMode 
            ? Colors.black 
            : Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// Accessible progress indicator with semantic announcements
class AccessibleProgressIndicator extends ConsumerWidget {
  final double? value;
  final String? semanticLabel;
  final bool announceProgress;

  const AccessibleProgressIndicator({
    super.key,
    this.value,
    this.semanticLabel,
    this.announceProgress = false,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String progressLabel = semanticLabel ?? 'Loading';
    if (value != null) {
      final percentage = (value! * 100).round();
      progressLabel = '$progressLabel, $percentage percent complete';
    }

    return Semantics(
      label: progressLabel,
      value: value?.toString(),
      child: LinearProgressIndicator(
        value: value,
        semanticsLabel: progressLabel,
        semanticsValue: value?.toString(),
      ),
    );
  }
}

/// Accessible tab bar with proper semantics
class AccessibleTabBar extends ConsumerWidget {
  final List<Widget> tabs;
  final TabController? controller;
  final ValueChanged<int>? onTap;
  final bool isScrollable;

  const AccessibleTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.isScrollable = false,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibilityService = ref.read(accessibilityServiceProvider);
    final settings = ref.watch(accessibilitySettingsProvider);
    
    return Semantics(
      container: true,
      child: TabBar(
        tabs: tabs,
        controller: controller,
        onTap: onTap == null ? null : (index) async {
          await accessibilityService.provideHapticFeedback(HapticFeedbackType.selection);
          onTap!(index);
        },
        isScrollable: isScrollable,
        // Ensure good contrast
        labelColor: settings.highContrastMode 
            ? Colors.black 
            : Theme.of(context).colorScheme.primary,
        unselectedLabelColor: settings.highContrastMode 
            ? Colors.grey[600] 
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        indicatorColor: settings.highContrastMode 
            ? Colors.black 
            : Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// Focus traversal helper for keyboard navigation
class AccessibleFocusTraversalGroup extends StatelessWidget {
  final Widget child;
  final FocusTraversalPolicy? policy;

  const AccessibleFocusTraversalGroup({
    super.key,
    required this.child,
    this.policy,
  });
  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: policy ?? OrderedTraversalPolicy(),
      child: child,
    );
  }
}

/// Accessible dismissible with proper semantics
class AccessibleDismissible extends ConsumerWidget {
  final Widget child;
  final DismissDirectionCallback? onDismissed;
  final DismissDirection direction;
  final String? semanticLabel;
  final String? dismissLabel;

  const AccessibleDismissible({
    super.key,
    required this.child,
    this.onDismissed,
    this.direction = DismissDirection.horizontal,
    this.semanticLabel,
    this.dismissLabel,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      label: semanticLabel,
      customSemanticsActions: {
        if (onDismissed != null)
          CustomSemanticsAction(label: dismissLabel ?? 'Dismiss'): () {
            final accessibilityService = ref.read(accessibilityServiceProvider);
            accessibilityService.provideHapticFeedback(HapticFeedbackType.medium);
            onDismissed!(direction);
          },
      },
      child: Dismissible(
        key: key ?? ValueKey(child.hashCode),
        onDismissed: onDismissed,
        direction: direction,
        child: child,
      ),
    );
  }
}