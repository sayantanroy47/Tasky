import 'package:flutter/material.dart';

/// Comprehensive color palette for themes
class ThemeColors {
  // Primary Colors
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  // Secondary Colors
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;

  // Tertiary Colors
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;

  // Surface Colors
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color inverseSurface;
  final Color onInverseSurface;

  // Background Colors
  final Color background;
  final Color onBackground;

  // Error Colors
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;

  // Special Theme Colors
  final Color accent;
  final Color highlight;
  final Color shadow;
  final Color outline;
  final Color outlineVariant;

  // Task Priority Colors
  final Color taskLowPriority;
  final Color taskMediumPriority;
  final Color taskHighPriority;
  final Color taskUrgentPriority;

  // Status Colors
  final Color success;
  final Color warning;
  final Color info;

  // Calendar Dot Colors (for task indicators in calendar)
  final Color calendarTodayDot;
  final Color calendarOverdueDot;
  final Color calendarFutureDot;
  final Color calendarCompletedDot;
  final Color calendarHighPriorityDot;
  
  // Status Badge Colors (for various app status indicators)
  final Color statusPendingBadge;
  final Color statusInProgressBadge;
  final Color statusCompletedBadge;
  final Color statusCancelledBadge;
  final Color statusOverdueBadge;
  final Color statusOnHoldBadge;
  
  // Interactive Colors
  final Color hover;
  final Color pressed;
  final Color focus;
  final Color disabled;

  const ThemeColors({
    // Primary
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,

    // Secondary
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,

    // Tertiary
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,

    // Surface
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.inverseSurface,
    required this.onInverseSurface,

    // Background
    required this.background,
    required this.onBackground,

    // Error
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,

    // Special
    required this.accent,
    required this.highlight,
    required this.shadow,
    required this.outline,
    required this.outlineVariant,

    // Task Priority
    required this.taskLowPriority,
    required this.taskMediumPriority,
    required this.taskHighPriority,
    required this.taskUrgentPriority,

    // Status
    required this.success,
    required this.warning,
    required this.info,

    // Calendar Dots
    required this.calendarTodayDot,
    required this.calendarOverdueDot,
    required this.calendarFutureDot,
    required this.calendarCompletedDot,
    required this.calendarHighPriorityDot,
    
    // Status Badges
    required this.statusPendingBadge,
    required this.statusInProgressBadge,
    required this.statusCompletedBadge,
    required this.statusCancelledBadge,
    required this.statusOverdueBadge,
    required this.statusOnHoldBadge,

    // Interactive
    required this.hover,
    required this.pressed,
    required this.focus,
    required this.disabled,
  });

  /// Convert to Flutter ColorScheme
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: _getBrightness(),
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      inverseSurface: inverseSurface,
      onInverseSurface: onInverseSurface,
      background: background,
      onBackground: onBackground,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
    );
  }

  /// Determine brightness based on background color
  Brightness _getBrightness() {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Brightness.light : Brightness.dark;
  }

  /// Get priority color by priority level
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return taskLowPriority;
      case 2:
        return taskMediumPriority;
      case 3:
        return taskHighPriority;
      case 4:
        return taskUrgentPriority;
      default:
        return taskMediumPriority;
    }
  }

  /// Create a copy with modified colors
  ThemeColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? onSecondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? tertiary,
    Color? onTertiary,
    Color? tertiaryContainer,
    Color? onTertiaryContainer,
    Color? surface,
    Color? onSurface,
    Color? surfaceVariant,
    Color? onSurfaceVariant,
    Color? inverseSurface,
    Color? onInverseSurface,
    Color? background,
    Color? onBackground,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? accent,
    Color? highlight,
    Color? shadow,
    Color? outline,
    Color? outlineVariant,
    Color? taskLowPriority,
    Color? taskMediumPriority,
    Color? taskHighPriority,
    Color? taskUrgentPriority,
    Color? success,
    Color? warning,
    Color? info,
    // Calendar dots
    Color? calendarTodayDot,
    Color? calendarOverdueDot,
    Color? calendarFutureDot,
    Color? calendarCompletedDot,
    Color? calendarHighPriorityDot,
    // Status badges
    Color? statusPendingBadge,
    Color? statusInProgressBadge,
    Color? statusCompletedBadge,
    Color? statusCancelledBadge,
    Color? statusOverdueBadge,
    Color? statusOnHoldBadge,
    // Interactive
    Color? hover,
    Color? pressed,
    Color? focus,
    Color? disabled,
  }) {
    return ThemeColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
      tertiary: tertiary ?? this.tertiary,
      onTertiary: onTertiary ?? this.onTertiary,
      tertiaryContainer: tertiaryContainer ?? this.tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer ?? this.onTertiaryContainer,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      onInverseSurface: onInverseSurface ?? this.onInverseSurface,
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      accent: accent ?? this.accent,
      highlight: highlight ?? this.highlight,
      shadow: shadow ?? this.shadow,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      taskLowPriority: taskLowPriority ?? this.taskLowPriority,
      taskMediumPriority: taskMediumPriority ?? this.taskMediumPriority,
      taskHighPriority: taskHighPriority ?? this.taskHighPriority,
      taskUrgentPriority: taskUrgentPriority ?? this.taskUrgentPriority,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      // Calendar dots
      calendarTodayDot: calendarTodayDot ?? this.calendarTodayDot,
      calendarOverdueDot: calendarOverdueDot ?? this.calendarOverdueDot,
      calendarFutureDot: calendarFutureDot ?? this.calendarFutureDot,
      calendarCompletedDot: calendarCompletedDot ?? this.calendarCompletedDot,
      calendarHighPriorityDot: calendarHighPriorityDot ?? this.calendarHighPriorityDot,
      // Status badges
      statusPendingBadge: statusPendingBadge ?? this.statusPendingBadge,
      statusInProgressBadge: statusInProgressBadge ?? this.statusInProgressBadge,
      statusCompletedBadge: statusCompletedBadge ?? this.statusCompletedBadge,
      statusCancelledBadge: statusCancelledBadge ?? this.statusCancelledBadge,
      statusOverdueBadge: statusOverdueBadge ?? this.statusOverdueBadge,
      statusOnHoldBadge: statusOnHoldBadge ?? this.statusOnHoldBadge,
      // Interactive
      hover: hover ?? this.hover,
      pressed: pressed ?? this.pressed,
      focus: focus ?? this.focus,
      disabled: disabled ?? this.disabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeColors &&
        other.primary == primary &&
        other.secondary == secondary &&
        other.background == background;
  }

  @override
  int get hashCode => Object.hash(primary, secondary, background);
}