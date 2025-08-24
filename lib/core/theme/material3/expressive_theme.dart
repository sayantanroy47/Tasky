import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../app_theme_data.dart' as app_theme_data;
import '../models/theme_effects.dart' as theme_effects;
import '../models/theme_metadata.dart';
import '../models/theme_typography.dart';
import '../typography_constants.dart';
import 'color_system.dart';
import 'motion_system.dart';

/// Material 3 Expressive Theme - "Future 2050"
/// A cutting-edge theme with dynamic colors, fluid animations, and futuristic design
class ExpressiveTheme {
  static app_theme_data.AppThemeData create({bool isDark = false}) {
    final now = DateTime.now();
    final colorSystem = ExpressiveColorSystem(isDark: isDark);

    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'expressive_dark' : 'expressive_light',
        name: isDark ? 'Expressive Dark 2050' : 'Expressive Light 2050',
        description: isDark
            ? 'Futuristic dark theme with dynamic gradients, fluid animations, and Material 3 expressive design'
            : 'Bright futuristic theme with vibrant colors, smooth transitions, and Material 3 expressive elements',
        author: 'Google Material Design + Tasky Team',
        version: '2.0.0',
        tags: ['material3', 'expressive', 'futuristic', 'dynamic', 'animated', '2050'],
        category: 'futuristic',
        previewIcon: PhosphorIcons.sparkle(),
        primaryPreviewColor: colorSystem.primary,
        secondaryPreviewColor: colorSystem.secondary,
        createdAt: now,
        isPremium: true,
        popularityScore: 10.0,
      ),
      colors: colorSystem.toThemeColors(),
      typography: _createExpressiveTypography(isDark: isDark, colorSystem: colorSystem),
      animations: ExpressiveMotionSystem.createAnimations(),
      effects: _createExpressiveEffects(isDark: isDark),
      spacing: _createExpressiveSpacing(),
      components: _createExpressiveComponents(isDark: isDark, colorSystem: colorSystem),
    );
  }

  /// Create light variant
  static app_theme_data.AppThemeData createLight() => create(isDark: false);

  /// Create dark variant
  static app_theme_data.AppThemeData createDark() => create(isDark: true);

  /// Create expressive typography with Google Sans
  static ThemeTypography _createExpressiveTypography({
    required bool isDark,
    required ExpressiveColorSystem colorSystem,
  }) {
    return ThemeTypography(
      fontFamily: 'Google Sans Text',
      displayFontFamily: 'Google Sans',
      monospaceFontFamily: 'Google Sans Mono',
      baseSize: 16.0,
      scaleRatio: 1.25,
      baseFontWeight: FontWeight.w400,
      baseLetterSpacing: 0.15,
      baseLineHeight: 1.5,
      // Display styles - Large, bold, expressive
      displayLarge: TextStyle(
        fontFamily: 'Google Sans',
        fontSize: TypographyConstants.displayLarge, // was 57, closest match
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
        color: colorSystem.onBackground,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Google Sans',
        fontSize: TypographyConstants.displayMedium, // was 45, closest match
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.16,
        color: colorSystem.onBackground,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Google Sans',
        fontSize: TypographyConstants.displaySmall, // was 36, now correct mapping
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.22,
        color: colorSystem.onBackground,
      ),

      // Headline styles - Expressive and dynamic
      headlineLarge: TextStyle(
        fontFamily: 'Google Sans',
        fontSize: TypographyConstants.headlineLarge, // was 32, now correct mapping
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.25,
        color: colorSystem.onBackground,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Google Sans',
        fontSize: TypographyConstants.headlineMedium, // was 28, now correct mapping
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.29,
        color: colorSystem.onBackground,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Google Sans',
        fontSize: TypographyConstants.headlineSmall, // was 24, now correct mapping
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.33,
        color: colorSystem.onBackground,
      ),

      // Title styles - Clear hierarchy
      titleLarge: TextStyle(
        fontFamily: 'Google Sans',
        fontSize: TypographyConstants.titleLarge, // was 22, now correct mapping
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.27,
        color: colorSystem.onBackground,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Google Sans Text',
        fontSize: TypographyConstants.titleMedium, // was 16, now correct mapping
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.5,
        color: colorSystem.onBackground,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Google Sans Text',
        fontSize: TypographyConstants.titleSmall, // was 14, now correct mapping
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
        color: colorSystem.onBackground,
      ),

      // Body styles - Readable and clean
      bodyLarge: TextStyle(
        fontFamily: 'Google Sans Text',
        fontSize: TypographyConstants.bodyLarge, // was 16
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
        color: colorSystem.onBackground,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Google Sans Text',
        fontSize: TypographyConstants.bodyMedium, // was 14
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: colorSystem.onBackground,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Google Sans Text',
        fontSize: TypographyConstants.bodySmall, // was 12
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
        color: colorSystem.onSurfaceVariant,
      ),

      // Label styles - UI elements
      labelLarge: TextStyle(
        fontFamily: 'Google Sans Text',
        fontSize: TypographyConstants.bodyMedium, // was 14
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
        color: colorSystem.onBackground,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Google Sans Text',
        fontSize: TypographyConstants.bodySmall, // was 12
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
        color: colorSystem.onBackground,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Google Sans Text',
        fontSize: TypographyConstants.labelSmall, // was 11
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
        color: colorSystem.onSurfaceVariant,
      ),

      // Custom App Styles
      taskTitle: TextStyle(
        fontFamily: 'Google Sans',
        fontSize: TypographyConstants.taskTitle, // was 18, now correct mapping
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.33,
        color: colorSystem.onSurface,
      ),
      taskDescription: TextStyle(
        fontFamily: 'Google Sans Text',
        fontSize: TypographyConstants.taskDescription, // was 14, now correct mapping
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: colorSystem.onSurfaceVariant,
      ),
      taskMeta: TextStyle(
        fontFamily: 'Google Sans Text',
        fontSize: TypographyConstants.taskMeta, // was 12, now correct mapping
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
        color: colorSystem.onSurfaceVariant,
      ),
      cardTitle: TextStyle(
        fontFamily: 'Google Sans',
        fontSize: TypographyConstants.titleSmall, // was 20, should be smaller for cards
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.3,
        color: colorSystem.onSurface,
      ),
      cardSubtitle: TextStyle(
        fontFamily: 'Google Sans Text',
        fontSize: TypographyConstants.bodyMedium, // was 14
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.43,
        color: colorSystem.onSurfaceVariant,
      ),
      buttonText: TextStyle(
        fontFamily: 'Google Sans Text',
        fontSize: TypographyConstants.buttonText, // was 14, now correct mapping
        fontWeight: FontWeight.w500,
        letterSpacing: 0.75,
        height: 1.43,
        color: colorSystem.onPrimary,
      ),
      inputText: TextStyle(
        fontFamily: 'Google Sans Text',
        fontSize: TypographyConstants.inputText, // was 16, now correct mapping
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
        color: colorSystem.onSurface,
      ),
      appBarTitle: TextStyle(
        fontFamily: 'Google Sans',
        fontSize: TypographyConstants.appBarTitle, // was 22, now correct mapping
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.27,
        color: colorSystem.onSurface,
      ),
      navigationLabel: TextStyle(
        fontFamily: 'Google Sans Text',
        fontSize: TypographyConstants.navigationLabel, // was 12, now correct mapping
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
        color: colorSystem.onSurface,
      ),
    );
  }

  /// Create expressive visual effects
  static theme_effects.ThemeEffects _createExpressiveEffects({required bool isDark}) {
    return theme_effects.ThemeEffects(
      shadowStyle: theme_effects.ShadowStyle.soft,
      gradientStyle: theme_effects.GradientStyle.subtle,
      borderStyle: theme_effects.BorderStyle.rounded,
      blurConfig: theme_effects.BlurConfig(
        enabled: true,
        style: theme_effects.BlurStyle.outer,
        intensity: isDark ? 0.3 : 0.2,
      ),
      glowConfig: theme_effects.GlowConfig(
        enabled: true,
        intensity: isDark ? 0.7 : 0.5,
        spread: 4.0,
        style: theme_effects.GlowStyle.outer,
      ),
      backgroundEffects: theme_effects.BackgroundEffectConfig(
        enableParticles: false, // Keep it performant
        enableGradientMesh: true,
        enableScanlines: false,
        particleType: theme_effects.BackgroundParticleType.floating,
        particleOpacity: 0.05,
        effectIntensity: isDark ? 0.3 : 0.2,
      ),
    );
  }

  /// Create expressive spacing
  static app_theme_data.ThemeSpacing _createExpressiveSpacing() {
    return const app_theme_data.ThemeSpacing(
      extraSmall: 4.0,
      small: 8.0,
      medium: 16.0,
      large: 24.0,
      extraLarge: 32.0,
      cardPadding: 20.0,
      screenPadding: 24.0,
      buttonPadding: 20.0,
      inputPadding: 16.0,
    );
  }

  /// Create expressive components with Material 3 design
  static app_theme_data.ThemeComponents _createExpressiveComponents({
    required bool isDark,
    required ExpressiveColorSystem colorSystem,
  }) {
    return const app_theme_data.ThemeComponents(
      appBar: app_theme_data.AppBarConfig(
        elevation: 0,
        centerTitle: false, // Material 3 style
        toolbarHeight: 64.0,
      ),
      card: app_theme_data.CardConfig(
        elevation: 0, // Use color/blur instead
        borderRadius: TypographyConstants.radiusStandard, // Large radius for expressive design
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: EdgeInsets.all(20.0),
      ),
      button: app_theme_data.ButtonConfig(
        borderRadius: TypographyConstants.radiusStandard, // Pill-shaped buttons
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        elevation: 0,
        height: 48.0,
        style: app_theme_data.ButtonStyle.filled,
      ),
      input: app_theme_data.InputConfig(
        borderRadius: TypographyConstants.radiusStandard,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        borderStyle: app_theme_data.InputBorderStyle.outline,
        filled: true,
      ),
      fab: app_theme_data.FABConfig(
        shape: app_theme_data.FABShape.extended,
        elevation: 0, // Use color instead
        width: null, // Auto size
        height: 56.0,
      ),
      navigation: app_theme_data.NavigationConfig(
        type: app_theme_data.NavigationType.bottomNav,
        elevation: 0,
        showLabels: true,
      ),
      taskCard: app_theme_data.TaskCardConfig(
        borderRadius: TypographyConstants.radiusStandard,
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: EdgeInsets.all(20.0),
        elevation: 0,
        showPriorityStripe: true,
        enableSwipeActions: true,
      ),
    );
  }

  /// Create Flutter ThemeData from ExpressiveTheme
  static ThemeData toFlutterTheme({required bool isDark}) {
    final expressive = create(isDark: isDark);
    final colors = expressive.colors;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,

      // Color scheme
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        primaryContainer: colors.primaryContainer,
        onPrimaryContainer: colors.onPrimaryContainer,
        secondary: colors.secondary,
        onSecondary: colors.onSecondary,
        secondaryContainer: colors.secondaryContainer,
        onSecondaryContainer: colors.onSecondaryContainer,
        tertiary: colors.tertiary,
        onTertiary: colors.onTertiary,
        tertiaryContainer: colors.tertiaryContainer,
        onTertiaryContainer: colors.onTertiaryContainer,
        error: colors.error,
        onError: colors.onError,
        errorContainer: colors.errorContainer,
        onErrorContainer: colors.onErrorContainer,
        surface: colors.surface,
        onSurface: colors.onSurface,
        onSurfaceVariant: colors.onSurfaceVariant,
        outline: colors.outline,
        outlineVariant: colors.outlineVariant,
        shadow: colors.shadow,
        inverseSurface: colors.inverseSurface,
        onInverseSurface: colors.onInverseSurface,
        inversePrimary: colors.primary,
        surfaceTint: colors.primary,
      ),

      // Typography
      textTheme: TextTheme(
        displayLarge: expressive.typography.displayLarge,
        displayMedium: expressive.typography.displayMedium,
        displaySmall: expressive.typography.displaySmall,
        headlineLarge: expressive.typography.headlineLarge,
        headlineMedium: expressive.typography.headlineMedium,
        headlineSmall: expressive.typography.headlineSmall,
        titleLarge: expressive.typography.titleLarge,
        titleMedium: expressive.typography.titleMedium,
        titleSmall: expressive.typography.titleSmall,
        bodyLarge: expressive.typography.bodyLarge,
        bodyMedium: expressive.typography.bodyMedium,
        bodySmall: expressive.typography.bodySmall,
        labelLarge: expressive.typography.labelLarge,
        labelMedium: expressive.typography.labelMedium,
        labelSmall: expressive.typography.labelSmall,
      ),

      // Component themes
      appBarTheme: AppBarTheme(
        elevation: expressive.components.appBar.elevation,
        centerTitle: expressive.components.appBar.centerTitle,
        toolbarHeight: expressive.components.appBar.toolbarHeight,
        backgroundColor: Colors.transparent,
        foregroundColor: colors.onSurface,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),

      cardTheme: CardThemeData(
        elevation: expressive.components.card.elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(expressive.components.card.borderRadius),
        ),
        color: colors.surface,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colors.onSurface.withValues(alpha: 0.12);
            }
            return colors.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return colors.onSurface.withValues(alpha: 0.38);
            }
            return colors.onPrimary;
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(expressive.components.button.borderRadius),
            ),
          ),
          padding: WidgetStateProperty.all(expressive.components.button.padding),
          minimumSize: WidgetStateProperty.all(Size(64, expressive.components.button.height)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: expressive.components.input.filled,
        fillColor: colors.surfaceVariant.withValues(alpha: 0.3),
        contentPadding: expressive.components.input.contentPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(expressive.components.input.borderRadius),
          borderSide: BorderSide(color: colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(expressive.components.input.borderRadius),
          borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(expressive.components.input.borderRadius),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colors.surface,
        indicatorColor: colors.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(expressive.typography.labelMedium),
      ),
    );
  }
}
