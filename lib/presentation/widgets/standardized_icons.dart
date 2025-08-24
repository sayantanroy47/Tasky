import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';

/// Standardized icon system that eliminates icon chaos
/// 
/// Eliminates Icon Inconsistency by:
/// - Enforcing consistent icon sizes based on IconTokens hierarchy
/// - Providing semantic color mapping for all icon contexts
/// - Maintaining visual hierarchy through standardized sizing
/// - Preventing hardcoded icon colors and sizes throughout the app
class StandardizedIcon extends StatelessWidget {
  final IconData icon;
  final StandardizedIconSize size;
  final Color? color;
  final StandardizedIconStyle style;
  final String? semanticLabel;

  const StandardizedIcon(
    this.icon, {
    super.key,
    this.size = StandardizedIconSize.md,
    this.color,
    this.style = StandardizedIconStyle.primary,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveSize = _getIconSize(size);
    final effectiveColor = color ?? _getSemanticColor(theme, style);

    return Semantics(
      label: semanticLabel,
      child: Icon(
        icon,
        size: effectiveSize,
        color: effectiveColor,
      ),
    );
  }

  /// Get icon size based on standardized hierarchy
  double _getIconSize(StandardizedIconSize size) {
    switch (size) {
      case StandardizedIconSize.xs:
        return IconTokens.xs; // 12px - Small indicators
      case StandardizedIconSize.sm:
        return IconTokens.sm; // 16px - List icons
      case StandardizedIconSize.md:
        return IconTokens.md; // 20px - Default icons
      case StandardizedIconSize.lg:
        return IconTokens.lg; // 24px - Button icons
      case StandardizedIconSize.xl:
        return IconTokens.xl; // 32px - Header icons
      case StandardizedIconSize.xxl:
        return IconTokens.xxl; // 40px - Feature icons
      case StandardizedIconSize.xxxl:
        return IconTokens.xxxl; // 48px - Hero icons
    }
  }

  /// Get semantic color for icon based on context
  Color _getSemanticColor(ThemeData theme, StandardizedIconStyle style) {
    switch (style) {
      case StandardizedIconStyle.primary:
        return theme.colorScheme.onSurface;
      case StandardizedIconStyle.secondary:
        return theme.colorScheme.onSurfaceVariant;
      case StandardizedIconStyle.accent:
        return theme.colorScheme.primary;
      case StandardizedIconStyle.success:
        return theme.colorScheme.tertiary;
      case StandardizedIconStyle.warning:
        return theme.colorScheme.secondary;
      case StandardizedIconStyle.error:
        return theme.colorScheme.error;
      case StandardizedIconStyle.disabled:
        return theme.colorScheme.onSurface.withValues(alpha: 0.38);
      case StandardizedIconStyle.onPrimary:
        return theme.colorScheme.onPrimary;
      case StandardizedIconStyle.onSecondary:
        return theme.colorScheme.onSecondary;
    }
  }
}

/// Standardized icon sizes that map to IconTokens
enum StandardizedIconSize {
  xs,    // 12px - Small indicators, chips
  sm,    // 16px - List items, small buttons
  md,    // 20px - Default icon size
  lg,    // 24px - Standard buttons, nav icons
  xl,    // 32px - Header icons, large buttons
  xxl,   // 40px - Feature highlights
  xxxl,  // 48px - Hero sections, empty states
}

/// Semantic icon styles for consistent theming
enum StandardizedIconStyle {
  primary,    // Default icon color (onSurface)
  secondary,  // Subtle icon color (onSurfaceVariant)
  accent,     // Brand color (primary)
  success,    // Success state (tertiary)
  warning,    // Warning state (secondary)
  error,      // Error state (error)
  disabled,   // Disabled state (onSurface with alpha)
  onPrimary,  // Icons on primary surfaces
  onSecondary, // Icons on secondary surfaces
}

/// Pre-configured icon variants for common use cases
class StandardizedIconVariants {
  /// Navigation icons - consistent size and color
  static Widget navigation(
    IconData icon, {
    bool isSelected = false,
    String? semanticLabel,
  }) {
    return StandardizedIcon(
      icon,
      size: StandardizedIconSize.lg,
      style: isSelected 
        ? StandardizedIconStyle.accent 
        : StandardizedIconStyle.secondary,
      semanticLabel: semanticLabel,
    );
  }

  /// Button icons - consistent with button hierarchy
  static Widget button(
    IconData icon, {
    StandardizedButtonIconType type = StandardizedButtonIconType.primary,
    String? semanticLabel,
  }) {
    late StandardizedIconSize size;
    late StandardizedIconStyle style;
    
    switch (type) {
      case StandardizedButtonIconType.primary:
        size = StandardizedIconSize.lg;
        style = StandardizedIconStyle.onPrimary;
        break;
      case StandardizedButtonIconType.secondary:
        size = StandardizedIconSize.lg;
        style = StandardizedIconStyle.primary;
        break;
      case StandardizedButtonIconType.small:
        size = StandardizedIconSize.sm;
        style = StandardizedIconStyle.primary;
        break;
    }
    
    return StandardizedIcon(
      icon,
      size: size,
      style: style,
      semanticLabel: semanticLabel,
    );
  }

  /// List item icons - consistent for all list contexts
  static Widget listItem(
    IconData icon, {
    StandardizedIconStyle style = StandardizedIconStyle.secondary,
    String? semanticLabel,
  }) {
    return StandardizedIcon(
      icon,
      size: StandardizedIconSize.sm,
      style: style,
      semanticLabel: semanticLabel,
    );
  }

  /// Status icons - consistent for all status indicators
  static Widget status(
    IconData icon, {
    required StandardizedStatusType status,
    String? semanticLabel,
  }) {
    late StandardizedIconStyle style;
    
    switch (status) {
      case StandardizedStatusType.success:
        style = StandardizedIconStyle.success;
        break;
      case StandardizedStatusType.warning:
        style = StandardizedIconStyle.warning;
        break;
      case StandardizedStatusType.error:
        style = StandardizedIconStyle.error;
        break;
      case StandardizedStatusType.info:
        style = StandardizedIconStyle.accent;
        break;
    }
    
    return StandardizedIcon(
      icon,
      size: StandardizedIconSize.sm,
      style: style,
      semanticLabel: semanticLabel,
    );
  }

  /// Feature icons - large icons for highlighting features
  static Widget feature(
    IconData icon, {
    Color? customColor,
    String? semanticLabel,
  }) {
    return StandardizedIcon(
      icon,
      size: StandardizedIconSize.xxl,
      color: customColor,
      style: customColor == null ? StandardizedIconStyle.accent : StandardizedIconStyle.primary,
      semanticLabel: semanticLabel,
    );
  }

  /// Empty state icons - large, subtle icons for empty states
  static Widget emptyState(
    IconData icon, {
    String? semanticLabel,
  }) {
    return StandardizedIcon(
      icon,
      size: StandardizedIconSize.xxxl,
      style: StandardizedIconStyle.disabled,
      semanticLabel: semanticLabel,
    );
  }

  /// Card action icons - small icons for card actions
  static Widget cardAction(
    IconData icon, {
    String? semanticLabel,
  }) {
    return StandardizedIcon(
      icon,
      size: StandardizedIconSize.sm,
      style: StandardizedIconStyle.secondary,
      semanticLabel: semanticLabel,
    );
  }

  /// Priority indicators - consistent task priority icons
  static Widget priority(
    IconData icon, {
    required Color priorityColor,
    String? semanticLabel,
  }) {
    return StandardizedIcon(
      icon,
      size: StandardizedIconSize.sm,
      color: priorityColor,
      semanticLabel: semanticLabel,
    );
  }

  /// Completion status icons - task completion indicators
  static Widget completion(
    IconData icon, {
    required bool isCompleted,
    String? semanticLabel,
  }) {
    return StandardizedIcon(
      icon,
      size: StandardizedIconSize.md,
      style: isCompleted 
        ? StandardizedIconStyle.success 
        : StandardizedIconStyle.secondary,
      semanticLabel: semanticLabel,
    );
  }
}

/// Button icon types for consistent sizing
enum StandardizedButtonIconType {
  primary,   // Primary button icons (24px, onPrimary)
  secondary, // Secondary button icons (24px, primary)
  small,     // Small button icons (16px, primary)
}

/// Status types for consistent status theming
enum StandardizedStatusType {
  success,  // Success state (tertiary)
  warning,  // Warning state (secondary)
  error,    // Error state (error)
  info,     // Information state (primary)
}

/// Common icon patterns for the task management app
class TaskManagementIcons {
  /// Task-related icons with consistent sizing
  static Widget task({
    bool isCompleted = false,
    String? semanticLabel,
  }) {
    return StandardizedIconVariants.completion(
      isCompleted ? PhosphorIcons.checkCircle() : PhosphorIcons.circle(),
      isCompleted: isCompleted,
      semanticLabel: semanticLabel ?? (isCompleted ? 'Task completed' : 'Task incomplete'),
    );
  }

  /// Project-related icons
  static Widget project({
    StandardizedIconSize size = StandardizedIconSize.md,
    String? semanticLabel,
  }) {
    return StandardizedIcon(
      PhosphorIcons.folder(),
      size: size,
      style: StandardizedIconStyle.accent,
      semanticLabel: semanticLabel ?? 'Project',
    );
  }

  /// Due date icons with appropriate urgency colors
  static Widget dueDate({
    required bool isOverdue,
    required bool isDueToday,
    String? semanticLabel,
  }) {
    late StandardizedIconStyle style;
    if (isOverdue) {
      style = StandardizedIconStyle.error;
    } else if (isDueToday) {
      style = StandardizedIconStyle.warning;
    } else {
      style = StandardizedIconStyle.secondary;
    }
    
    return StandardizedIcon(
      PhosphorIcons.calendar(),
      size: StandardizedIconSize.sm,
      style: style,
      semanticLabel: semanticLabel ?? 'Due date',
    );
  }

  /// Priority icons with color mapping
  static Widget priorityIcon(TaskPriority priority, {String? semanticLabel}) {
    late IconData icon;
    late Color color;
    
    switch (priority) {
      case TaskPriority.low:
        icon = PhosphorIcons.arrowDown();
        color = const Color(0xFF4CAF50); // Green
        break;
      case TaskPriority.medium:
        icon = PhosphorIcons.minus();
        color = const Color(0xFFFF9800); // Orange
        break;
      case TaskPriority.high:
        icon = PhosphorIcons.arrowUp();
        color = const Color(0xFFFF5722); // Deep Orange
        break;
      case TaskPriority.urgent:
        icon = PhosphorIcons.warning();
        color = const Color(0xFFF44336); // Red
        break;
    }
    
    return StandardizedIconVariants.priority(
      icon,
      priorityColor: color,
      semanticLabel: semanticLabel ?? '${priority.name} priority',
    );
  }

  /// Voice/audio related icons
  static Widget voice({
    required VoiceState state,
    String? semanticLabel,
  }) {
    late IconData icon;
    late StandardizedIconStyle style;
    
    switch (state) {
      case VoiceState.idle:
        icon = PhosphorIcons.microphone();
        style = StandardizedIconStyle.secondary;
        break;
      case VoiceState.listening:
        icon = PhosphorIcons.waveform();
        style = StandardizedIconStyle.accent;
        break;
      case VoiceState.processing:
        icon = PhosphorIcons.circleNotch();
        style = StandardizedIconStyle.accent;
        break;
      case VoiceState.disabled:
        icon = PhosphorIcons.microphoneSlash();
        style = StandardizedIconStyle.disabled;
        break;
    }
    
    return StandardizedIcon(
      icon,
      size: StandardizedIconSize.lg,
      style: style,
      semanticLabel: semanticLabel ?? 'Voice ${state.name}',
    );
  }
}

/// Task priority enum for consistent priority handling
enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

/// Voice state enum for consistent voice UI
enum VoiceState {
  idle,
  listening,
  processing,
  disabled,
}