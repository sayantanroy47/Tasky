import 'package:flutter/material.dart';

/// Modern RadioGroup-based wrapper to replace deprecated Radio patterns
/// This provides backward compatibility while using the new Radio patterns
class ModernRadioGroup<T> extends StatelessWidget {
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final List<ModernRadioOption<T>> options;
  final CrossAxisAlignment crossAxisAlignment;

  const ModernRadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.options,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: options.map((option) {
        return ModernRadioListTile<T>(
          value: option.value,
          groupValue: groupValue,
          onChanged: onChanged,
          title: option.title,
          subtitle: option.subtitle,
          leading: option.leading,
          trailing: option.trailing,
          dense: option.dense,
        );
      }).toList(),
    );
  }
}

/// Option model for ModernRadioGroup
class ModernRadioOption<T> {
  final T value;
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool dense;

  const ModernRadioOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.dense = false,
  });
}

/// Modern RadioListTile replacement that uses the new Radio patterns
class ModernRadioListTile<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool dense;

  const ModernRadioListTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final theme = Theme.of(context);
    
    return ListTile(
      dense: dense,
      leading: leading ?? Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
            width: 2,
          ),
        ),
        child: isSelected 
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary,
                ),
              ),
            )
          : null,
      ),
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: () => onChanged?.call(value),
      selected: isSelected,
    );
  }
}

/// Simple radio button group for inline selections
class ModernRadioButtonGroup<T> extends StatelessWidget {
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final List<ModernRadioButton<T>> buttons;
  final Axis direction;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;

  const ModernRadioButtonGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.buttons,
    this.direction = Axis.horizontal,
    this.spacing = 8.0,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final children = buttons.map((button) {
      return ModernRadioButton<T>(
        value: button.value,
        groupValue: groupValue,
        onChanged: onChanged,
        label: button.label,
        icon: button.icon,
      );
    }).toList();

    if (direction == Axis.horizontal) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        children: _addSpacing(children, spacing),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _addSpacing(children, spacing),
      );
    }
  }

  List<Widget> _addSpacing(List<Widget> children, double spacing) {
    if (children.isEmpty) return children;
    
    final result = <Widget>[children.first];
    for (int i = 1; i < children.length; i++) {
      if (direction == Axis.horizontal) {
        result.add(SizedBox(width: spacing));
      } else {
        result.add(SizedBox(height: spacing));
      }
      result.add(children[i]);
    }
    return result;
  }
}

/// Radio button widget for ModernRadioButtonGroup  
class ModernRadioButton<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String label;
  final IconData? icon;

  const ModernRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => onChanged?.call(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? theme.colorScheme.primaryContainer : null,
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
            ],
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                  width: 2,
                ),
              ),
              child: isSelected 
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  )
                : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}