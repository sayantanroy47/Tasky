import 'package:flutter/material.dart';
import 'app_theme_data.dart';
import 'models/theme_effects.dart';

/// Factory for converting AppThemeData to Flutter ThemeData
class ThemeFactory {
  /// Convert AppThemeData to Flutter ThemeData
  static ThemeData createFlutterTheme(AppThemeData appTheme) {
    final colors = appTheme.colors;
    final typography = appTheme.typography;
    final effects = appTheme.effects;
    final spacing = appTheme.spacing;
    final components = appTheme.components;

    return ThemeData(
      useMaterial3: true,
      
      // Color scheme
      colorScheme: colors.toColorScheme(),
      
      // Typography
      textTheme: typography.toTextTheme(),
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        elevation: components.appBar.elevation,
        centerTitle: components.appBar.centerTitle,
        toolbarHeight: components.appBar.toolbarHeight,
        shape: components.appBar.shape,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        titleTextStyle: typography.appBarTitle,
        shadowColor: colors.shadow,
      ),
      
      // Card theme
      cardTheme: CardTheme(
        elevation: components.card.elevation,
        shape: RoundedRectangleBorder(
          borderRadius: effects.getBorderRadius(components.card.borderRadius),
        ),
        margin: components.card.margin,
        shadowColor: components.card.shadowColor ?? colors.shadow,
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: components.button.elevation,
          padding: components.button.padding,
          shape: RoundedRectangleBorder(
            borderRadius: effects.getBorderRadius(components.button.borderRadius),
          ),
          textStyle: typography.buttonText,
          minimumSize: Size.fromHeight(components.button.height),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: components.button.padding,
          shape: RoundedRectangleBorder(
            borderRadius: effects.getBorderRadius(components.button.borderRadius),
          ),
          textStyle: typography.buttonText,
          minimumSize: Size.fromHeight(components.button.height),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          padding: components.button.padding,
          shape: RoundedRectangleBorder(
            borderRadius: effects.getBorderRadius(components.button.borderRadius),
          ),
          textStyle: typography.buttonText,
          minimumSize: Size.fromHeight(components.button.height),
          side: BorderSide(color: colors.outline),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          elevation: 0,
          padding: components.button.padding,
          shape: RoundedRectangleBorder(
            borderRadius: effects.getBorderRadius(components.button.borderRadius),
          ),
          textStyle: typography.buttonText,
          minimumSize: Size.fromHeight(components.button.height),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: components.input.contentPadding,
        border: _getInputBorder(components.input, effects, colors.outline),
        enabledBorder: _getInputBorder(components.input, effects, colors.outline),
        focusedBorder: _getInputBorder(components.input, effects, colors.primary),
        errorBorder: _getInputBorder(components.input, effects, colors.error),
        filled: components.input.filled,
        fillColor: colors.surfaceVariant,
        labelStyle: typography.inputText,
        hintStyle: typography.inputText.copyWith(
          color: colors.onSurface.withOpacity(0.6),
        ),
      ),
      
      // FloatingActionButton theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: components.fab.elevation,
        shape: _getFABShape(components.fab, effects),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: components.navigation.elevation,
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.onSurface.withOpacity(0.6),
        showSelectedLabels: components.navigation.showLabels,
        showUnselectedLabels: components.navigation.showLabels,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: typography.navigationLabel,
        unselectedLabelStyle: typography.navigationLabel.copyWith(
          color: colors.onSurface.withOpacity(0.6),
        ),
      ),
      
      // Navigation rail theme
      navigationRailTheme: NavigationRailThemeData(
        elevation: components.navigation.elevation,
        backgroundColor: colors.surface,
        selectedIconTheme: IconThemeData(color: colors.primary),
        unselectedIconTheme: IconThemeData(color: colors.onSurface.withOpacity(0.6)),
        selectedLabelTextStyle: typography.navigationLabel,
        unselectedLabelTextStyle: typography.navigationLabel.copyWith(
          color: colors.onSurface.withOpacity(0.6),
        ),
      ),
      
      // Dialog theme
      dialogTheme: DialogTheme(
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: effects.getBorderRadius(16.0),
        ),
        backgroundColor: colors.surface,
        titleTextStyle: typography.headlineSmall,
        contentTextStyle: typography.bodyMedium,
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceVariant,
        selectedColor: colors.primaryContainer,
        disabledColor: colors.disabled,
        labelStyle: typography.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: effects.getBorderRadius(16.0),
        ),
        elevation: 0,
        pressElevation: 2,
      ),
      
      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return colors.primary;
          }
          return colors.outline;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return colors.primary.withOpacity(0.5);
          }
          return colors.surfaceVariant;
        }),
      ),
      
      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return colors.primary;
          }
          return colors.outline;
        }),
        checkColor: MaterialStateProperty.all(colors.onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: effects.getBorderRadius(2.0),
        ),
      ),
      
      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return colors.primary;
          }
          return colors.outline;
        }),
      ),
      
      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.primary,
        inactiveTrackColor: colors.outline,
        thumbColor: colors.primary,
        overlayColor: colors.primary.withOpacity(0.12),
        valueIndicatorColor: colors.primary,
        valueIndicatorTextStyle: typography.labelSmall.copyWith(
          color: colors.onPrimary,
        ),
      ),
      
      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.outline,
        circularTrackColor: colors.outline,
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: colors.outline,
        thickness: 1,
        space: spacing.small,
      ),
      
      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: spacing.medium),
        titleTextStyle: typography.bodyLarge,
        subtitleTextStyle: typography.bodyMedium,
        leadingAndTrailingTextStyle: typography.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: effects.getBorderRadius(8.0),
        ),
      ),
      
      // Icon theme
      iconTheme: IconThemeData(
        color: colors.onSurface,
        size: 24.0,
      ),
      
      // Primary icon theme
      primaryIconTheme: IconThemeData(
        color: colors.primary,
        size: 24.0,
      ),
      
      // Extensions for custom properties
      extensions: [
        CustomThemeExtension(
          taskCardTheme: _createTaskCardTheme(appTheme),
          animationDurations: _createAnimationDurations(appTheme),
          customColors: _createCustomColors(appTheme),
        ),
      ],
    );
  }

  /// Create input border based on style
  static InputBorder _getInputBorder(
    InputConfig config,
    ThemeEffects effects,
    Color color,
  ) {
    final borderRadius = effects.getBorderRadius(config.borderRadius);
    
    switch (config.borderStyle) {
      case InputBorderStyle.outline:
        return OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: color),
        );
      case InputBorderStyle.underline:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: color),
        );
      case InputBorderStyle.none:
        return InputBorder.none;
    }
  }

  /// Create FAB shape based on configuration
  static ShapeBorder _getFABShape(FABConfig config, ThemeEffects effects) {
    switch (config.shape) {
      case FABShape.circular:
        return const CircleBorder();
      case FABShape.extended:
        return RoundedRectangleBorder(
          borderRadius: effects.getBorderRadius(16.0),
        );
      case FABShape.square:
        return RoundedRectangleBorder(
          borderRadius: effects.getBorderRadius(8.0),
        );
    }
  }

  /// Create task card theme
  static TaskCardTheme _createTaskCardTheme(AppThemeData appTheme) {
    return TaskCardTheme(
      borderRadius: appTheme.components.taskCard.borderRadius,
      margin: appTheme.components.taskCard.margin,
      padding: appTheme.components.taskCard.padding,
      elevation: appTheme.components.taskCard.elevation,
      showPriorityStripe: appTheme.components.taskCard.showPriorityStripe,
      enableSwipeActions: appTheme.components.taskCard.enableSwipeActions,
    );
  }

  /// Create animation durations
  static AnimationDurations _createAnimationDurations(AppThemeData appTheme) {
    return AnimationDurations(
      fast: appTheme.animations.fast,
      medium: appTheme.animations.medium,
      slow: appTheme.animations.slow,
      verySlow: appTheme.animations.verySlow,
    );
  }

  /// Create custom colors
  static CustomColors _createCustomColors(AppThemeData appTheme) {
    return CustomColors(
      accent: appTheme.colors.accent,
      highlight: appTheme.colors.highlight,
      taskLowPriority: appTheme.colors.taskLowPriority,
      taskMediumPriority: appTheme.colors.taskMediumPriority,
      taskHighPriority: appTheme.colors.taskHighPriority,
      taskUrgentPriority: appTheme.colors.taskUrgentPriority,
      success: appTheme.colors.success,
      warning: appTheme.colors.warning,
      info: appTheme.colors.info,
    );
  }
}

/// Custom theme extension for app-specific properties
class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final TaskCardTheme taskCardTheme;
  final AnimationDurations animationDurations;
  final CustomColors customColors;

  const CustomThemeExtension({
    required this.taskCardTheme,
    required this.animationDurations,
    required this.customColors,
  });

  @override
  CustomThemeExtension copyWith({
    TaskCardTheme? taskCardTheme,
    AnimationDurations? animationDurations,
    CustomColors? customColors,
  }) {
    return CustomThemeExtension(
      taskCardTheme: taskCardTheme ?? this.taskCardTheme,
      animationDurations: animationDurations ?? this.animationDurations,
      customColors: customColors ?? this.customColors,
    );
  }

  @override
  CustomThemeExtension lerp(ThemeExtension<CustomThemeExtension>? other, double t) {
    if (other is! CustomThemeExtension) return this;
    
    return CustomThemeExtension(
      taskCardTheme: taskCardTheme,
      animationDurations: animationDurations,
      customColors: customColors.lerp(other.customColors, t),
    );
  }
}

/// Task card specific theme
class TaskCardTheme {
  final double borderRadius;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double elevation;
  final bool showPriorityStripe;
  final bool enableSwipeActions;

  const TaskCardTheme({
    required this.borderRadius,
    required this.margin,
    required this.padding,
    required this.elevation,
    required this.showPriorityStripe,
    required this.enableSwipeActions,
  });
}

/// Animation durations
class AnimationDurations {
  final Duration fast;
  final Duration medium;
  final Duration slow;
  final Duration verySlow;

  const AnimationDurations({
    required this.fast,
    required this.medium,
    required this.slow,
    required this.verySlow,
  });
}

/// Custom app colors
class CustomColors {
  final Color accent;
  final Color highlight;
  final Color taskLowPriority;
  final Color taskMediumPriority;
  final Color taskHighPriority;
  final Color taskUrgentPriority;
  final Color success;
  final Color warning;
  final Color info;

  const CustomColors({
    required this.accent,
    required this.highlight,
    required this.taskLowPriority,
    required this.taskMediumPriority,
    required this.taskHighPriority,
    required this.taskUrgentPriority,
    required this.success,
    required this.warning,
    required this.info,
  });

  CustomColors lerp(CustomColors other, double t) {
    return CustomColors(
      accent: Color.lerp(accent, other.accent, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      taskLowPriority: Color.lerp(taskLowPriority, other.taskLowPriority, t)!,
      taskMediumPriority: Color.lerp(taskMediumPriority, other.taskMediumPriority, t)!,
      taskHighPriority: Color.lerp(taskHighPriority, other.taskHighPriority, t)!,
      taskUrgentPriority: Color.lerp(taskUrgentPriority, other.taskUrgentPriority, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}