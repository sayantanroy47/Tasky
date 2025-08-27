import 'package:flutter/material.dart';

import '../../domain/models/enums.dart' show TaskPriority;

/// Standardized color system that eliminates hardcoded color chaos
///
/// Eliminates Hardcoded Color Violations by:
/// - Providing semantic color mapping for all contexts
/// - Preventing usage of Colors.red, Colors.blue, etc.
/// - Ensuring proper theme integration and dark mode support
/// - Maintaining accessibility standards across all color usage
class StandardizedColors {
  final ThemeData theme;

  const StandardizedColors(this.theme);

  // State-based colors - semantic meaning over hardcoded colors
  Color get success => theme.colorScheme.tertiary; // Green semantic - success states
  Color get warning => theme.colorScheme.onTertiaryContainer; // Amber semantic - warning states
  Color get error => theme.colorScheme.error; // Red semantic - error states
  Color get info => theme.colorScheme.primary; // Blue semantic - info states

  // Interactive states
  Color get interactive => theme.colorScheme.primary;
  Color get interactiveHover => theme.colorScheme.primary.withValues(alpha: 0.8);
  Color get interactivePressed => theme.colorScheme.primary.withValues(alpha: 0.6);
  Color get interactiveDisabled => theme.colorScheme.onSurface.withValues(alpha: 0.38);

  // Tertiary interactive states - for secondary and accent interactions
  Color get tertiaryInteractive => theme.colorScheme.tertiary;
  Color get tertiaryInteractiveHover => theme.colorScheme.tertiary.withValues(alpha: 0.8);
  Color get tertiaryInteractivePressed => theme.colorScheme.tertiary.withValues(alpha: 0.6);
  Color get tertiaryInteractiveFocus => theme.colorScheme.tertiary.withValues(alpha: 0.12);
  Color get tertiaryInteractiveSelected => theme.colorScheme.tertiary.withValues(alpha: 0.16);

  // Enhanced tertiary interactive states - comprehensive Material 3 system
  Color get tertiaryFocused => theme.colorScheme.tertiary.withValues(alpha: 0.12);
  Color get tertiaryHovered => theme.colorScheme.tertiary.withValues(alpha: 0.08);
  Color get tertiaryPressed => theme.colorScheme.tertiary.withValues(alpha: 0.16);
  Color get tertiaryDragged => theme.colorScheme.tertiary.withValues(alpha: 0.20);
  Color get tertiaryActivated => theme.colorScheme.tertiary.withValues(alpha: 0.24);
  Color get tertiarySelected => theme.colorScheme.tertiary.withValues(alpha: 0.16);
  Color get tertiaryDisabled => theme.colorScheme.tertiary.withValues(alpha: 0.38);
  Color get tertiaryError =>
      Color.lerp(theme.colorScheme.tertiary, theme.colorScheme.error, 0.3) ?? theme.colorScheme.tertiary;

  // Tertiary semantic variations - alternatives to hardcoded colors
  Color get tertiaryWarning => _adjustColorTone(theme.colorScheme.tertiary, 85); // Amber alternative
  Color get tertiaryInfo => _adjustColorTone(theme.colorScheme.tertiary, 70); // Cyan alternative
  Color get tertiaryNeutral => _adjustColorTone(theme.colorScheme.tertiary, 50); // Grey alternative

  // Recording/voice states - semantic alternatives to hardcoded red
  Color get recordingActive => theme.colorScheme.error; // Use error color for recording
  Color get recordingInactive => theme.colorScheme.outline;
  Color get recordingBackground => theme.colorScheme.error.withValues(alpha: 0.1);
  Color get recordingBorder => theme.colorScheme.error.withValues(alpha: 0.3);

  // Transparent variations - semantic alternatives to Colors.transparent
  Color get backgroundTransparent => Colors.transparent;
  Color get surfaceTransparent => theme.colorScheme.surface.withValues(alpha: 0.0);
  Color get overlayLight => theme.colorScheme.surface.withValues(alpha: 0.8);
  Color get overlayMedium => theme.colorScheme.surface.withValues(alpha: 0.9);
  Color get overlayHeavy => theme.colorScheme.surface.withValues(alpha: 0.95);

  // High contrast alternatives - for accessibility
  Color get highContrastText => theme.brightness == Brightness.dark ? Colors.white : Colors.black;
  Color get highContrastBackground => theme.brightness == Brightness.dark ? Colors.black : Colors.white;

  // Priority-based colors - semantic task priority mapping
  Color get priorityCritical => theme.colorScheme.error;
  Color get priorityHigh => theme.colorScheme.onTertiaryContainer;
  Color get priorityMedium => theme.colorScheme.primary;
  Color get priorityLow => theme.colorScheme.outline;
  Color get priorityNone => theme.colorScheme.onSurfaceVariant;

  // Status-based colors - for task/project states
  Color get statusComplete => theme.colorScheme.tertiary;
  Color get statusInProgress => theme.colorScheme.primary;
  Color get statusPending => theme.colorScheme.onTertiaryContainer;
  Color get statusCancelled => theme.colorScheme.error;
  Color get statusDraft => theme.colorScheme.outline;

  // Tertiary color system - semantic usage for better hierarchy
  Color get tertiaryBase => theme.colorScheme.tertiary;
  Color get tertiaryContainer => theme.colorScheme.tertiaryContainer;
  Color get onTertiary => theme.colorScheme.onTertiary;
  Color get onTertiaryContainer => theme.colorScheme.onTertiaryContainer;

  // Tertiary variations with opacity
  Color get tertiaryLight => theme.colorScheme.tertiary.withValues(alpha: 0.1);
  Color get tertiaryMedium => theme.colorScheme.tertiary.withValues(alpha: 0.3);
  Color get tertiaryStrong => theme.colorScheme.tertiary.withValues(alpha: 0.8);

  // Navigation & chrome system - tertiary accents for UI chrome
  Color get navigationTertiary => theme.colorScheme.tertiary;
  Color get navigationTertiaryContainer => theme.colorScheme.tertiaryContainer;
  Color get appBarTertiary => _adjustColorTone(theme.colorScheme.tertiary, 90);
  Color get tabBarTertiary => _adjustColorTone(theme.colorScheme.tertiary, 95);
  Color get bottomNavTertiary => _adjustColorTone(theme.colorScheme.tertiary, 85);
  Color get sideNavTertiary => theme.colorScheme.tertiaryContainer.withValues(alpha: 0.8);

  // Component-specific tertiary variations - for FABs, cards, inputs, etc.
  Color get fabTertiary => theme.colorScheme.tertiary;
  Color get fabTertiaryContainer => theme.colorScheme.tertiaryContainer;
  Color get chipTertiary => _adjustColorTone(theme.colorScheme.tertiary, 80);
  Color get chipTertiarySelected => theme.colorScheme.tertiary;
  Color get cardTertiaryAccent => theme.colorScheme.tertiary.withValues(alpha: 0.12);
  Color get cardTertiaryBorder => theme.colorScheme.tertiary.withValues(alpha: 0.24);
  Color get inputTertiaryFocus => theme.colorScheme.tertiary;
  Color get inputTertiaryBorder => theme.colorScheme.tertiary.withValues(alpha: 0.6);
  Color get buttonTertiaryOutline => theme.colorScheme.tertiary;
  Color get buttonTertiaryFilled => theme.colorScheme.tertiary;
  Color get dividerTertiary => theme.colorScheme.tertiary.withValues(alpha: 0.12);
  Color get shadowTertiary => theme.colorScheme.tertiary.withValues(alpha: 0.08);

  // Glassmorphism-specific colors
  Color get glassTintLight => theme.colorScheme.surface.withValues(alpha: 0.8);
  Color get glassTintMedium => theme.colorScheme.surface.withValues(alpha: 0.9);
  Color get glassTintHeavy => theme.colorScheme.surface.withValues(alpha: 0.95);
  Color get glassBorder => theme.colorScheme.outline.withValues(alpha: 0.2);

  // Icon color semantics - context-aware icon coloring
  Color get iconPrimary => theme.colorScheme.onSurface;
  Color get iconSecondary => theme.colorScheme.onSurfaceVariant;
  Color get iconAccent => theme.colorScheme.primary;
  Color get iconSuccess => theme.colorScheme.tertiary;
  Color get iconWarning => theme.colorScheme.onTertiaryContainer;
  Color get iconError => theme.colorScheme.error;
  Color get iconDisabled => theme.colorScheme.onSurface.withValues(alpha: 0.38);
  Color get iconOnPrimary => theme.colorScheme.onPrimary;
  Color get iconOnSecondary => theme.colorScheme.onSecondary;
  Color get iconTertiary => theme.colorScheme.tertiary;
  Color get iconOnTertiary => theme.colorScheme.onTertiary;

  /// Get priority color by enum value
  Color getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return priorityCritical; // Map urgent to critical color
      case TaskPriority.high:
        return priorityHigh;
      case TaskPriority.medium:
        return priorityMedium;
      case TaskPriority.low:
        return priorityLow;
    }
  }

  // Status colors available as individual properties above

  /// Get tertiary color by semantic type
  Color getTertiaryColor(TertiaryColorType type) {
    switch (type) {
      case TertiaryColorType.featureHighlight:
        return tertiaryBase; // Use pure tertiary for feature highlights
      case TertiaryColorType.achievement:
        return tertiaryStrong; // Strong tertiary for achievements
      case TertiaryColorType.specialCategory:
        return tertiaryBase; // Pure tertiary for special categories
      case TertiaryColorType.interactiveAccent:
        return tertiaryMedium; // Medium opacity for interactive accents
      case TertiaryColorType.secondaryAction:
        return tertiaryContainer; // Container color for secondary actions
      case TertiaryColorType.progressIndicator:
        return tertiaryBase; // Pure tertiary for progress indicators
      case TertiaryColorType.cardAccent:
        return tertiaryLight; // Light tertiary for card accents
      case TertiaryColorType.navigationHighlight:
        return tertiaryMedium; // Medium tertiary for navigation
      case TertiaryColorType.dataVisualization:
        return tertiaryBase; // Pure tertiary for data viz
      case TertiaryColorType.formHighlight:
        return tertiaryLight; // Light tertiary for form success states
    }
  }

  /// Get contrasting text color for tertiary backgrounds
  Color getTertiaryTextColor(TertiaryColorType type) {
    switch (type) {
      case TertiaryColorType.featureHighlight:
      case TertiaryColorType.achievement:
      case TertiaryColorType.progressIndicator:
      case TertiaryColorType.dataVisualization:
        return onTertiary; // Use onTertiary for strong tertiary backgrounds
      case TertiaryColorType.secondaryAction:
        return onTertiaryContainer; // Use onTertiaryContainer for container backgrounds
      case TertiaryColorType.specialCategory:
      case TertiaryColorType.interactiveAccent:
      case TertiaryColorType.cardAccent:
      case TertiaryColorType.navigationHighlight:
      case TertiaryColorType.formHighlight:
        return theme.colorScheme.onSurface; // Use standard text color for light tertiary
    }
  }

  /// Create color with opacity - semantic alternative to hardcoded .withValues(alpha:)
  Color withSemanticOpacity(Color base, SemanticOpacity opacity) {
    switch (opacity) {
      case SemanticOpacity.subtle:
        return base.withValues(alpha: 0.1);
      case SemanticOpacity.light:
        return base.withValues(alpha: 0.3);
      case SemanticOpacity.medium:
        return base.withValues(alpha: 0.6);
      case SemanticOpacity.strong:
        return base.withValues(alpha: 0.8);
      case SemanticOpacity.opaque:
        return base.withValues(alpha: 1.0);
    }
  }

  /// Adjust color tone - helper for creating semantic color variations
  /// [tone] value from 0 (darkest) to 100 (lightest)
  Color _adjustColorTone(Color color, int tone) {
    // Simple tone adjustment - blend with white/black based on target tone
    if (tone > 50) {
      // Lighter tones - blend with white
      final ratio = (tone - 50) / 50.0;
      return Color.lerp(color, Colors.white, ratio * 0.6) ?? color;
    } else {
      // Darker tones - blend with black
      final ratio = (50 - tone) / 50.0;
      return Color.lerp(color, Colors.black, ratio * 0.4) ?? color;
    }
  }
}

/// Extension for easy access to standardized colors
extension StandardizedColorsExtension on BuildContext {
  StandardizedColors get colors => StandardizedColors(Theme.of(this));

  // Quick access to common colors
  Color get successColor => colors.success;
  Color get warningColor => colors.warning;
  Color get errorColor => colors.error;
  Color get infoColor => colors.info;

  Color get recordingColor => colors.recordingActive;
  Color get interactiveColor => colors.interactive;

  // Quick access to tertiary interactive states
  Color get tertiaryInteractiveColor => colors.tertiaryInteractive;
  Color get tertiaryHoverColor => colors.tertiaryInteractiveHover;
  Color get tertiaryPressedColor => colors.tertiaryInteractivePressed;
  Color get tertiaryFocusColor => colors.tertiaryInteractiveFocus;
  Color get tertiarySelectedColor => colors.tertiaryInteractiveSelected;

  // Quick access to tertiary colors
  Color get tertiaryColor => colors.tertiaryBase;
  Color get tertiaryContainerColor => colors.tertiaryContainer;

  // Quick access to enhanced tertiary interactive states
  Color get tertiaryFocusedColor => colors.tertiaryFocused;
  Color get tertiaryHoveredColor => colors.tertiaryHovered;
  Color get tertiaryActivatedColor => colors.tertiaryActivated;
  Color get tertiaryDraggedColor => colors.tertiaryDragged;
  Color get tertiaryDisabledColor => colors.tertiaryDisabled;

  // Quick access to semantic tertiary variations
  Color get tertiaryWarningColor => colors.tertiaryWarning;
  Color get tertiaryInfoColor => colors.tertiaryInfo;
  Color get tertiaryNeutralColor => colors.tertiaryNeutral;

  // Quick access to navigation tertiary colors
  Color get navigationTertiaryColor => colors.navigationTertiary;
  Color get appBarTertiaryColor => colors.appBarTertiary;
  Color get tabBarTertiaryColor => colors.tabBarTertiary;
  Color get bottomNavTertiaryColor => colors.bottomNavTertiary;

  // Quick access to component-specific tertiary colors
  Color get fabTertiaryColor => colors.fabTertiary;
  Color get chipTertiaryColor => colors.chipTertiary;
  Color get cardTertiaryAccentColor => colors.cardTertiaryAccent;
  Color get inputTertiaryFocusColor => colors.inputTertiaryFocus;
  Color get buttonTertiaryColor => colors.buttonTertiaryFilled;

  /// Get tertiary color by semantic type
  Color getTertiaryColor(TertiaryColorType type) => colors.getTertiaryColor(type);

  /// Get appropriate text color for tertiary backgrounds
  Color getTertiaryTextColor(TertiaryColorType type) => colors.getTertiaryTextColor(type);
}

/// Semantic opacity levels instead of hardcoded alpha values
enum SemanticOpacity {
  subtle, // 0.1 - Very light overlay
  light, // 0.3 - Light overlay
  medium, // 0.6 - Medium overlay
  strong, // 0.8 - Strong overlay
  opaque, // 1.0 - Fully opaque
}

// TaskPriority imported from domain layer

/// Helper widget for semantic color containers
class StandardizedColorContainer extends StatelessWidget {
  final Widget child;
  final SemanticColorType colorType;
  final SemanticOpacity opacity;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const StandardizedColorContainer({
    super.key,
    required this.child,
    required this.colorType,
    this.opacity = SemanticOpacity.light,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = StandardizedColors(Theme.of(context));

    Color backgroundColor;
    switch (colorType) {
      case SemanticColorType.success:
        backgroundColor = colors.withSemanticOpacity(colors.success, opacity);
        break;
      case SemanticColorType.warning:
        backgroundColor = colors.withSemanticOpacity(colors.warning, opacity);
        break;
      case SemanticColorType.error:
        backgroundColor = colors.withSemanticOpacity(colors.error, opacity);
        break;
      case SemanticColorType.info:
        backgroundColor = colors.withSemanticOpacity(colors.info, opacity);
        break;
      case SemanticColorType.recording:
        backgroundColor = colors.withSemanticOpacity(colors.recordingActive, opacity);
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

/// Semantic color types for containers
enum SemanticColorType {
  success,
  warning,
  error,
  info,
  recording,
}

/// Tertiary color usage types for systematic tertiary color application
enum TertiaryColorType {
  /// Feature highlights - New features, tips, discoveries
  featureHighlight,

  /// Achievement states - Completed goals, streaks, milestones
  achievement,

  /// Special categories - VIP tasks, starred items, featured content
  specialCategory,

  /// Interactive accents - Hover effects, selection indicators, focus states
  interactiveAccent,

  /// Secondary actions - Supporting buttons, secondary FABs
  secondaryAction,

  /// Progress indicators - Completion states, milestone markers
  progressIndicator,

  /// Card accents - Featured cards, pinned items, important content
  cardAccent,

  /// Navigation highlights - Active secondary nav, breadcrumbs
  navigationHighlight,

  /// Data visualization - Third-tier categories in charts/analytics
  dataVisualization,

  /// Form highlights - Success validation, completion indicators
  formHighlight,
}
