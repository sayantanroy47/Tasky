import 'package:flutter/material.dart';
import 'models/theme_metadata.dart';
import 'models/theme_colors.dart';
import 'models/theme_typography.dart';
import 'models/theme_animations.dart';
import 'models/theme_effects.dart';

/// Comprehensive theme data model
class AppThemeData {
  final ThemeMetadata metadata;
  final ThemeColors colors;
  final ThemeTypography typography;
  final ThemeAnimations animations;
  final ThemeEffects effects;

  // Component-specific configurations
  final ThemeSpacing spacing;
  final ThemeComponents components;

  const AppThemeData({
    required this.metadata,
    required this.colors,
    required this.typography,
    required this.animations,
    required this.effects,
    required this.spacing,
    required this.components,
  });

  /// Create a copy with modified properties
  AppThemeData copyWith({
    ThemeMetadata? metadata,
    ThemeColors? colors,
    ThemeTypography? typography,
    ThemeAnimations? animations,
    ThemeEffects? effects,
    ThemeSpacing? spacing,
    ThemeComponents? components,
  }) {
    return AppThemeData(
      metadata: metadata ?? this.metadata,
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      animations: animations ?? this.animations,
      effects: effects ?? this.effects,
      spacing: spacing ?? this.spacing,
      components: components ?? this.components,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppThemeData && other.metadata.id == metadata.id;
  }

  @override
  int get hashCode => metadata.id.hashCode;

  @override
  String toString() {
    return 'AppThemeData(${metadata.name})';
  }
}

/// Spacing configuration for themes
class ThemeSpacing {
  final double extraSmall;
  final double small;
  final double medium;
  final double large;
  final double extraLarge;
  
  final double cardPadding;
  final double screenPadding;
  final double buttonPadding;
  final double inputPadding;
  
  const ThemeSpacing({
    this.extraSmall = 4.0,
    this.small = 8.0,
    this.medium = 16.0,
    this.large = 24.0,
    this.extraLarge = 32.0,
    this.cardPadding = 16.0,
    this.screenPadding = 16.0,
    this.buttonPadding = 16.0,
    this.inputPadding = 12.0,
  });

  /// Create spacing configuration from base unit
  factory ThemeSpacing.fromBaseUnit(double baseUnit) {
    return ThemeSpacing(
      extraSmall: baseUnit * 0.5,
      small: baseUnit,
      medium: baseUnit * 2,
      large: baseUnit * 3,
      extraLarge: baseUnit * 4,
      cardPadding: baseUnit * 2,
      screenPadding: baseUnit * 2,
      buttonPadding: baseUnit * 2,
      inputPadding: baseUnit * 1.5,
    );
  }

  /// Get spacing value by name
  double getSpacing(String name) {
    switch (name) {
      case 'extraSmall':
        return extraSmall;
      case 'small':
        return small;
      case 'medium':
        return medium;
      case 'large':
        return large;
      case 'extraLarge':
        return extraLarge;
      case 'cardPadding':
        return cardPadding;
      case 'screenPadding':
        return screenPadding;
      case 'buttonPadding':
        return buttonPadding;
      case 'inputPadding':
        return inputPadding;
      default:
        return medium;
    }
  }

  /// Create a copy with modified spacing values
  ThemeSpacing copyWith({
    double? extraSmall,
    double? small,
    double? medium,
    double? large,
    double? extraLarge,
    double? cardPadding,
    double? screenPadding,
    double? buttonPadding,
    double? inputPadding,
  }) {
    return ThemeSpacing(
      extraSmall: extraSmall ?? this.extraSmall,
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
      extraLarge: extraLarge ?? this.extraLarge,
      cardPadding: cardPadding ?? this.cardPadding,
      screenPadding: screenPadding ?? this.screenPadding,
      buttonPadding: buttonPadding ?? this.buttonPadding,
      inputPadding: inputPadding ?? this.inputPadding,
    );
  }
}

/// Component-specific theme configurations
class ThemeComponents {
  final AppBarConfig appBar;
  final CardConfig card;
  final ButtonConfig button;
  final InputConfig input;
  final FABConfig fab;
  final NavigationConfig navigation;
  final TaskCardConfig taskCard;

  const ThemeComponents({
    required this.appBar,
    required this.card,
    required this.button,
    required this.input,
    required this.fab,
    required this.navigation,
    required this.taskCard,
  });
}

/// AppBar component configuration
class AppBarConfig {
  final double elevation;
  final bool centerTitle;
  final double toolbarHeight;
  final ShapeBorder? shape;

  const AppBarConfig({
    this.elevation = 0,
    this.centerTitle = true,
    this.toolbarHeight = kToolbarHeight,
    this.shape,
  });
}

/// Card component configuration
class CardConfig {
  final double elevation;
  final double borderRadius;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Color? shadowColor;

  const CardConfig({
    this.elevation = 2.0,
    this.borderRadius = 5.0,
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.padding = const EdgeInsets.all(16.0),
    this.shadowColor,
  });
}

/// Button component configuration
class ButtonConfig {
  final double borderRadius;
  final EdgeInsets padding;
  final double elevation;
  final double height;
  final ButtonStyle style;

  const ButtonConfig({
    this.borderRadius = 5.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    this.elevation = 2.0,
    this.height = 48.0,
    this.style = ButtonStyle.elevated,
  });
}

/// Input field configuration
class InputConfig {
  final double borderRadius;
  final EdgeInsets contentPadding;
  final InputBorderStyle borderStyle;
  final bool filled;

  const InputConfig({
    this.borderRadius = 5.0,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.borderStyle = InputBorderStyle.outline,
    this.filled = false,
  });
}

/// FAB configuration
class FABConfig {
  final FABShape shape;
  final double elevation;
  final double? width;
  final double? height;

  const FABConfig({
    this.shape = FABShape.circular,
    this.elevation = 6.0,
    this.width,
    this.height,
  });
}

/// Navigation configuration
class NavigationConfig {
  final NavigationType type;
  final double elevation;
  final bool showLabels;

  const NavigationConfig({
    this.type = NavigationType.bottomNav,
    this.elevation = 8.0,
    this.showLabels = true,
  });
}

/// Task card configuration
class TaskCardConfig {
  final double borderRadius;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double elevation;
  final bool showPriorityStripe;
  final bool enableSwipeActions;

  const TaskCardConfig({
    this.borderRadius = 5.0,
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    this.padding = const EdgeInsets.all(16.0),
    this.elevation = 1.0,
    this.showPriorityStripe = true,
    this.enableSwipeActions = true,
  });
}

/// Enums for component configurations
enum ButtonStyle { elevated, filled, outlined, text }
enum InputBorderStyle { outline, underline, none }
enum FABShape { circular, extended, square }
enum NavigationType { bottomNav, drawer, rail }