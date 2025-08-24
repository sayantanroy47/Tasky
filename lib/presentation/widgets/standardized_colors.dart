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
  Color get highContrastText => theme.brightness == Brightness.dark 
      ? Colors.white 
      : Colors.black;
  Color get highContrastBackground => theme.brightness == Brightness.dark 
      ? Colors.black 
      : Colors.white;

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

  /// Create color with opacity - semantic alternative to hardcoded .withOpacity()
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
}

/// Semantic opacity levels instead of hardcoded alpha values
enum SemanticOpacity {
  subtle, // 0.1 - Very light overlay
  light,  // 0.3 - Light overlay  
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