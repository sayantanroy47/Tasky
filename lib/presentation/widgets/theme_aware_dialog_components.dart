import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';
import 'glassmorphism_container.dart';
import 'theme_aware_dialog_background.dart';

/// Full-page theme-aware dialog that respects all theme configurations
class ThemeAwareTaskDialog extends ConsumerWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  const ThemeAwareTaskDialog({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.actions,
    this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ThemeAwareDialogBackground(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            if (title != null) _buildHeader(context, theme),
            Expanded(child: child),
            if (actions != null) _buildFooter(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return SafeArea(
      bottom: false,
      child: GlassmorphismContainer(
        level: GlassLevel.content,
        borderRadius: BorderRadius.zero, // No radius for full-page dialogs
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        glassTint: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderColor: Colors.transparent,
        child: Row(
          children: [
            // Back button (only show if onBack is provided)
            if (onBack != null) ...[
              GlassmorphismContainer(
                level: GlassLevel.interactive,
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                glassTint: theme.colorScheme.surface.withValues(alpha: 0.8),
                borderColor: theme.colorScheme.outline.withValues(alpha: 0.2),
                child: IconButton(
                  onPressed: onBack,
                  icon: Icon(PhosphorIcons.arrowLeft()),
                  padding: EdgeInsets.zero,
                  iconSize: 24,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 16),
            ],
            if (icon != null)
              GlassmorphismContainer(
                level: GlassLevel.interactive,
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                glassTint: theme.colorScheme.primary.withValues(alpha: 0.2),
                borderColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                child: Icon(
                  icon!,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
            if (icon != null) const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme) {
    return SafeArea(
      top: false,
      child: GlassmorphismContainer(
        level: GlassLevel.content,
        borderRadius: BorderRadius.zero, // No radius for full-page dialogs
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        glassTint: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderColor: Colors.transparent,
        child: Row(
          children: actions!
              .expand((action) => [action, const SizedBox(width: 16)])
              .take(actions!.length * 2 - 1)
              .toList(),
        ),
      ),
    );
  }
}

/// Theme-aware form field that respects theme typography and colors
class ThemeAwareFormField extends ConsumerWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final int maxLines;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool required;
  final bool autofocus;

  const ThemeAwareFormField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.maxLines = 1,
    this.textInputAction,
    this.keyboardType,
    this.validator,
    this.required = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GlassmorphismContainer(
      level: GlassLevel.interactive,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
      glassTint: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      borderColor: theme.colorScheme.outline.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(2),
      child: TextFormField(
        controller: controller,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        maxLines: maxLines,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        validator: validator,
        autofocus: autofocus,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon!,
                  color: theme.colorScheme.primary,
                  size: 20,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
            borderSide: BorderSide.none,
          ),
          filled: false,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

/// Theme-aware priority selector that adapts to theme styles
class ThemeAwarePrioritySelector extends ConsumerWidget {
  final String selectedPriority;
  final ValueChanged<String> onPriorityChanged;
  final List<PriorityOption> priorities;

  const ThemeAwarePrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
    required this.priorities,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority *',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: priorities.map((priority) {
            final isSelected = selectedPriority == priority.value;
            
            return GestureDetector(
              onTap: () => onPriorityChanged(priority.value),
              child: GlassmorphismContainer(
                level: isSelected ? GlassLevel.interactive : GlassLevel.content,
                glassTint: isSelected 
                    ? priority.color.withValues(alpha: 0.3)
                    : null,
                borderColor: isSelected 
                    ? priority.color 
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                borderWidth: isSelected ? 2.0 : 1.0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      priority.icon,
                      size: 18,
                      color: priority.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      priority.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected 
                            ? FontWeight.w500 
                            : FontWeight.normal,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Theme-aware button that respects theme styling
class ThemeAwareButton extends ConsumerWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isLoading;

  const ThemeAwareButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isPrimary = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (isPrimary) {
      return FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : (icon != null ? Icon(icon) : const SizedBox.shrink()),
        label: Text(label),
        style: FilledButton.styleFrom(
          textStyle: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          textStyle: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );
    }
  }
}

/// Rounded glass button for task creation with glassmorphism effect
class RoundedGlassButton extends ConsumerWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isLoading;
  final double? width;
  final double? height;

  const RoundedGlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isPrimary = false,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return GlassmorphismContainer(
      level: isPrimary ? GlassLevel.interactive : GlassLevel.content,
      width: width,
      height: height ?? 56,
      borderRadius: BorderRadius.circular(28), // Fully rounded
      glassTint: isPrimary 
          ? theme.colorScheme.primary.withValues(alpha: 0.3)
          : theme.colorScheme.surface.withValues(alpha: 0.8),
      borderColor: isPrimary 
          ? theme.colorScheme.primary.withValues(alpha: 0.5)
          : theme.colorScheme.outline.withValues(alpha: 0.3),
      borderWidth: isPrimary ? 2.0 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isPrimary 
                          ? theme.colorScheme.onPrimary 
                          : theme.colorScheme.primary,
                    ),
                  )
                else if (icon != null)
                  Icon(
                    icon!,
                    size: 20,
                    color: isPrimary 
                        ? theme.colorScheme.onPrimary 
                        : theme.colorScheme.primary,
                  ),
                if ((icon != null || isLoading) && label.isNotEmpty) 
                  const SizedBox(width: 8),
                if (label.isNotEmpty)
                  Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isPrimary 
                          ? theme.colorScheme.onPrimary 
                          : theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Priority option data class
class PriorityOption {
  final String value;
  final String name;
  final IconData icon;
  final Color color;

  const PriorityOption({
    required this.value,
    required this.name,
    required this.icon,
    required this.color,
  });
}
