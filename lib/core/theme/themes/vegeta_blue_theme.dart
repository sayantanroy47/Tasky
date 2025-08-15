import 'package:flutter/material.dart';
import '../app_theme_data.dart' as app_theme_data;
import '../models/theme_metadata.dart';
import '../models/theme_colors.dart';
import '../models/theme_typography.dart';
import '../models/theme_animations.dart';
import '../models/theme_effects.dart' as theme_effects;
import '../typography_constants.dart';

/// Vegeta Blue Theme - "Saiyan Power"
/// A dramatic, powerful theme inspired by Dragon Ball Z's Prince Vegeta
/// Features deep blue colors, sharp angular design, and explosive animations
class VegetaBlueTheme {
  static app_theme_data.AppThemeData create({bool isDark = false}) {
    final now = DateTime.now();
    
    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'vegeta_blue_dark' : 'vegeta_blue',
        name: isDark ? 'Vegeta Blue Dark' : 'Vegeta Blue',
        description: isDark 
          ? 'Dark variant of the Saiyan prince theme with deep space backgrounds and brilliant energy auras'
          : 'Channel your inner Saiyan prince with this powerful, angular theme featuring deep blues and explosive energy',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['gaming', 'anime', 'dramatic', 'blue', 'angular', 'energy'],
        category: 'gaming',
        previewIcon: Icons.flash_on,
        primaryPreviewColor: const Color(0xFF1e3a8a), // Deep royal blue
        secondaryPreviewColor: const Color(0xFF3b82f6), // Electric blue
        createdAt: now,
        isPremium: false,
        popularityScore: 8.5,
      ),
      
      colors: _createVegetaColors(isDark: isDark),
      typography: _createVegetaTypography(isDark: isDark),
      animations: _createVegetaAnimations(),
      effects: _createVegetaEffects(),
      spacing: _createVegetaSpacing(),
      components: _createVegetaComponents(),
    );
  }

  /// Create light variant
  static app_theme_data.AppThemeData createLight() => create(isDark: false);
  
  /// Create dark variant
  static app_theme_data.AppThemeData createDark() => create(isDark: true);

  /// Helper method to reduce color brightness by 25%
  static Color _reduceBrightness(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness * factor).clamp(0.0, 1.0)).toColor();
  }

  /// Create Vegeta-inspired color palette
  static ThemeColors _createVegetaColors({bool isDark = false}) {
    if (isDark) {
      // Dark variant: Deeper space colors with brighter energy
      const deepSpaceBlue = Color(0xFF0c1527);       // Darker background - Deep space
      const royalNavy = Color(0xFF1e3a8a);           // Primary - Vegeta's aura (same)
      const brilliantBlue = Color(0xFF60a5fa);       // Secondary - Brighter energy
      const silverWhite = Color(0xFFf1f5f9);         // On colors - Armor shine
      const spaceDark = Color(0xFF0f172a);           // Surface - Space darkness  
      const energyGlow = Color(0xFF93c5fd);          // Accent - Intense glow
      const plasmaYellow = Color(0xFFfde047);        // Highlight - Plasma sparks
      
      return ThemeColors(
        // Primary colors - Vegeta's aura
        primary: royalNavy,
        onPrimary: silverWhite,
        primaryContainer: const Color(0xFF1e40af),
        onPrimaryContainer: silverWhite,

        // Secondary colors - Brilliant energy
        secondary: brilliantBlue,
        onSecondary: deepSpaceBlue,
        secondaryContainer: const Color(0xFF1d4ed8),
        onSecondaryContainer: silverWhite,

        // Tertiary colors - Plasma energy
        tertiary: plasmaYellow,
        onTertiary: deepSpaceBlue,
        tertiaryContainer: const Color(0xFFca8a04),
        onTertiaryContainer: deepSpaceBlue,

        // Surface colors - Space materials
        surface: spaceDark,
        onSurface: silverWhite,
        surfaceVariant: const Color(0xFF1e293b),
        onSurfaceVariant: const Color(0xFFcbd5e1),
        inverseSurface: silverWhite,
        onInverseSurface: deepSpaceBlue,

        // Background colors - Deep space
        background: deepSpaceBlue,
        onBackground: silverWhite,

        // Error colors - Destructive power (same)
        error: const Color(0xFFf87171),
        onError: deepSpaceBlue,
        errorContainer: const Color(0xFFdc2626),
        onErrorContainer: silverWhite,

        // Special colors
        accent: energyGlow,
        highlight: plasmaYellow,
        shadow: const Color(0xFF000000),
        outline: const Color(0xFF475569),
        outlineVariant: const Color(0xFF334155),

        // Task priority colors - Enhanced power levels
        taskLowPriority: const Color(0xFF4ade80),    // Bright green
        taskMediumPriority: brilliantBlue,           // Brilliant blue
        taskHighPriority: plasmaYellow,              // Plasma yellow
        taskUrgentPriority: const Color(0xFFf87171), // Bright red

        // Status colors
        success: const Color(0xFF22c55e),
        warning: const Color(0xFFf59e0b),
        info: energyGlow,

        // Calendar dot colors - Vegeta blue theme (dark)
        calendarTodayDot: energyGlow,                    // Energy blue for today
        calendarOverdueDot: const Color(0xFFdc2626),     // Red for overdue
        calendarFutureDot: deepSpaceBlue,                // Deep blue for future
        calendarCompletedDot: const Color(0xFF22c55e),   // Green for completed
        calendarHighPriorityDot: plasmaYellow,           // Yellow for high priority
        
        // Status badge colors - Vegeta themed (dark)
        statusPendingBadge: energyGlow,                  // Energy blue for pending
        statusInProgressBadge: plasmaYellow,             // Yellow for in progress
        statusCompletedBadge: const Color(0xFF22c55e),   // Green for completed
        statusCancelledBadge: const Color(0xFF64748b),   // Gray for cancelled
        statusOverdueBadge: const Color(0xFFdc2626),     // Red for overdue
        statusOnHoldBadge: const Color(0xFFf59e0b),      // Orange for on hold

        // Interactive colors
        hover: const Color(0xFF3730a3),
        pressed: const Color(0xFF312e81),
        focus: plasmaYellow,
        disabled: const Color(0xFF64748b),
      );
    }
    
    // Light variant: Use dark theme colors reduced by 25% brightness + light backgrounds
    
    // Get dark theme colors first  
    const darkRoyalNavy = Color(0xFF1e3a8a);          // Dark theme primary
    const darkBrilliantBlue = Color(0xFF60a5fa);      // Dark theme secondary
    const darkEnergyGlow = Color(0xFF93c5fd);         // Dark theme accent
    const darkPlasmaYellow = Color(0xFFfde047);       // Dark theme highlight
    
    // Reduce brightness by 25% (factor of 0.75)
    final lightPrimary = _reduceBrightness(darkRoyalNavy, 0.75);
    final lightSecondary = _reduceBrightness(darkBrilliantBlue, 0.75);
    final lightAccent = _reduceBrightness(darkEnergyGlow, 0.75);
    final lightHighlight = _reduceBrightness(darkPlasmaYellow, 0.75);
    
    // Light backgrounds
    const pureWhite = Color(0xFFfafafa);          // Background - Softer white
    const lightSilver = Color(0xFFf1f5f9);        // Surface - Light silver
    const paleBlue = Color(0xFFe0f2fe);           // Container - More visible blue tint
    
    return ThemeColors(
      // Primary colors - Reduced brightness from dark theme
      primary: lightPrimary,
      onPrimary: pureWhite,
      primaryContainer: paleBlue,
      onPrimaryContainer: lightPrimary,

      // Secondary colors - Reduced brightness from dark theme
      secondary: lightSecondary,
      onSecondary: pureWhite,
      secondaryContainer: paleBlue,
      onSecondaryContainer: lightSecondary,

      // Tertiary colors - Reduced brightness from dark theme
      tertiary: lightHighlight,
      onTertiary: pureWhite,
      tertiaryContainer: paleBlue,
      onTertiaryContainer: lightSecondary,

      // Surface colors - Light backgrounds
      surface: lightSilver,
      onSurface: const Color(0xFF1a1a1a), // Dark text for light surfaces
      surfaceVariant: const Color(0xFFe2e8f0),
      onSurfaceVariant: const Color(0xFF2a2a2a), // Dark text for light surfaces
      inverseSurface: lightPrimary,
      onInverseSurface: pureWhite,

      // Background colors - Light backgrounds
      background: pureWhite,
      onBackground: const Color(0xFF0a0a0a), // Very dark text for light backgrounds

      // Error colors - Reduced brightness
      error: _reduceBrightness(const Color(0xFFf87171), 0.75),
      onError: pureWhite,
      errorContainer: const Color(0xFFfef2f2),
      onErrorContainer: _reduceBrightness(const Color(0xFFdc2626), 0.75),

      // Special colors
      accent: lightAccent,
      highlight: lightHighlight,
      shadow: const Color(0xFF000000),
      outline: _reduceBrightness(const Color(0xFF475569), 0.75),
      outlineVariant: _reduceBrightness(const Color(0xFF64748b), 0.75),

      // Task priority colors - Reduced brightness power levels
      taskLowPriority: _reduceBrightness(const Color(0xFF4ade80), 0.75),    // Reduced green
      taskMediumPriority: lightSecondary,                                   // Reduced blue
      taskHighPriority: lightHighlight,                                     // Reduced yellow
      taskUrgentPriority: _reduceBrightness(const Color(0xFFf87171), 0.75), // Reduced red

      // Status colors - Reduced brightness
      success: _reduceBrightness(const Color(0xFF22c55e), 0.75),
      warning: _reduceBrightness(const Color(0xFFf59e0b), 0.75),
      info: lightAccent,

      // Calendar dot colors - Vegeta blue theme (light) - reduced brightness
      calendarTodayDot: lightAccent,                                        // Reduced energy blue for today
      calendarOverdueDot: _reduceBrightness(const Color(0xFFdc2626), 0.75), // Reduced red for overdue
      calendarFutureDot: lightSecondary,                                    // Reduced blue for future
      calendarCompletedDot: _reduceBrightness(const Color(0xFF22c55e), 0.75), // Reduced green for completed
      calendarHighPriorityDot: lightHighlight,                             // Reduced yellow for high priority
      
      // Status badge colors - Vegeta themed (light) - reduced brightness
      statusPendingBadge: lightSecondary,                                   // Reduced blue for pending
      statusInProgressBadge: lightHighlight,                                // Reduced yellow for in progress
      statusCompletedBadge: _reduceBrightness(const Color(0xFF22c55e), 0.75), // Reduced green for completed
      statusCancelledBadge: _reduceBrightness(const Color(0xFF64748b), 0.75), // Reduced gray for cancelled
      statusOverdueBadge: _reduceBrightness(const Color(0xFFdc2626), 0.75),  // Reduced red for overdue
      statusOnHoldBadge: _reduceBrightness(const Color(0xFFf59e0b), 0.75),   // Reduced orange for on hold

      // Interactive colors - Reduced brightness
      hover: _reduceBrightness(const Color(0xFF3730a3), 0.75),
      pressed: _reduceBrightness(const Color(0xFF312e81), 0.75),
      focus: lightHighlight,
      disabled: _reduceBrightness(const Color(0xFF64748b), 0.75),
    );
  }

  /// Create Vegeta-inspired typography using Orbitron (futuristic, angular font)
  static ThemeTypography _createVegetaTypography({bool isDark = false}) {
    final colors = _VegetaColorsHelper(isDark: isDark);
    const fontFamily = 'Orbitron';
    
    return ThemeTypography(
      fontFamily: fontFamily,
      displayFontFamily: fontFamily,
      monospaceFontFamily: fontFamily,
      baseSize: TypographyConstants.bodyLarge,
      scaleRatio: 1.0, // No scaling - use exact constants
      baseFontWeight: TypographyConstants.semiBold, // Bold and powerful
      baseLetterSpacing: 0.5, // Spaced out for dramatic effect
      baseLineHeight: 1.3, // Tight for intensity
      
      // Use EXACT typography constants for all sizes
      displayLarge: TypographyConstants.getStyle(
        fontSize: TypographyConstants.displayLarge,
        fontWeight: TypographyConstants.light,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      displayMedium: TypographyConstants.getStyle(
        fontSize: TypographyConstants.displayMedium,
        fontWeight: TypographyConstants.light,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      displaySmall: TypographyConstants.getStyle(
        fontSize: TypographyConstants.displaySmall,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      
      headlineLarge: TypographyConstants.getStyle(
        fontSize: TypographyConstants.headlineLarge,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      headlineMedium: TypographyConstants.getStyle(
        fontSize: TypographyConstants.headlineMedium,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      headlineSmall: TypographyConstants.getStyle(
        fontSize: TypographyConstants.headlineSmall,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      
      titleLarge: TypographyConstants.getStyle(
        fontSize: TypographyConstants.titleLarge,
        fontWeight: TypographyConstants.semiBold,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      titleMedium: TypographyConstants.getStyle(
        fontSize: TypographyConstants.titleMedium,
        fontWeight: TypographyConstants.semiBold,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      titleSmall: TypographyConstants.getStyle(
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.semiBold,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      
      bodyLarge: TypographyConstants.getStyle(
        fontSize: TypographyConstants.bodyLarge,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      bodyMedium: TypographyConstants.getStyle(
        fontSize: TypographyConstants.bodyMedium,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      bodySmall: TypographyConstants.getStyle(
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      
      labelLarge: TypographyConstants.getStyle(
        fontSize: TypographyConstants.labelLarge,
        fontWeight: TypographyConstants.semiBold,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      labelMedium: TypographyConstants.getStyle(
        fontSize: TypographyConstants.labelMedium,
        fontWeight: TypographyConstants.semiBold,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      labelSmall: TypographyConstants.getStyle(
        fontSize: TypographyConstants.labelSmall,
        fontWeight: TypographyConstants.semiBold,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      
      // Custom app styles with exact constants
      taskTitle: TypographyConstants.getStyle(
        fontSize: TypographyConstants.taskTitle,
        fontWeight: TypographyConstants.bold, // Extra bold for Vegeta
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      taskDescription: TypographyConstants.getStyle(
        fontSize: TypographyConstants.taskDescription,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      taskMeta: TypographyConstants.getStyle(
        fontSize: TypographyConstants.taskMeta,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      cardTitle: TypographyConstants.getStyle(
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.semiBold,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      cardSubtitle: TypographyConstants.getStyle(
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      buttonText: TypographyConstants.getStyle(
        fontSize: TypographyConstants.buttonText,
        fontWeight: TypographyConstants.semiBold,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      inputText: TypographyConstants.getStyle(
        fontSize: TypographyConstants.inputText,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      appBarTitle: TypographyConstants.getStyle(
        fontSize: TypographyConstants.appBarTitle,
        fontWeight: TypographyConstants.semiBold,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
      navigationLabel: TypographyConstants.getStyle(
        fontSize: TypographyConstants.navigationLabel,
        fontWeight: TypographyConstants.semiBold,
        fontFamily: fontFamily,
        letterSpacing: 0.5,
        height: 1.3,
        color: colors.onBackground,
      ),
    );
  }

  /// Create explosive, sharp animations
  static ThemeAnimations _createVegetaAnimations() {
    return ThemeAnimations.fromThemeStyle(ThemeAnimationStyle.sharp).copyWith(
      // Ultra-fast, explosive animations
      fast: const Duration(milliseconds: 80),
      medium: const Duration(milliseconds: 150),
      slow: const Duration(milliseconds: 280),
      verySlow: const Duration(milliseconds: 420),
      
      // Explosive, power-up curves
      primaryCurve: Curves.easeOutExpo,
      secondaryCurve: Curves.elasticOut,
      entranceCurve: Curves.bounceOut,
      exitCurve: Curves.easeInQuart,
      
      // Enable ultra high-energy particles
      enableParticles: true,
      particleConfig: const ParticleConfig(
        density: ParticleDensity.ultra,
        speed: ParticleSpeed.veryFast,
        style: ParticleStyle.geometric,
        enableGlow: true,
        opacity: 0.9,
        size: 1.5,
      ),
    );
  }

  /// Create dramatic visual effects
  static theme_effects.ThemeEffects _createVegetaEffects() {
    return theme_effects.ThemeEffects.fromEffectStyle(theme_effects.ThemeEffectStyle.dramatic).copyWith(
      shadowStyle: theme_effects.ShadowStyle.dramatic,
      gradientStyle: theme_effects.GradientStyle.metallic,
      borderStyle: theme_effects.BorderStyle.angular,
      
      glowConfig: const theme_effects.GlowConfig(
        enabled: true,
        intensity: 1.0,
        spread: 8.0,
        style: theme_effects.GlowStyle.outer,
      ),
      
      backgroundEffects: const theme_effects.BackgroundEffectConfig(
        enableParticles: true,
        enableGradientMesh: true,
        enableScanlines: false,
        particleType: theme_effects.BackgroundParticleType.energy,
        particleOpacity: 0.2,
        effectIntensity: 1.0,
      ),
    );
  }

  /// Create powerful spacing - more dramatic gaps
  static app_theme_data.ThemeSpacing _createVegetaSpacing() {
    return app_theme_data.ThemeSpacing.fromBaseUnit(8.0).copyWith(
      cardPadding: 20.0,     // More padding for impact
      screenPadding: 20.0,   // Generous screen padding
      buttonPadding: 24.0,   // Chunky buttons
      inputPadding: 16.0,    // Substantial input padding
    );
  }

  /// Create angular, powerful components
  static app_theme_data.ThemeComponents _createVegetaComponents() {
    return const app_theme_data.ThemeComponents(
      appBar: app_theme_data.AppBarConfig(
        elevation: 8.0,        // Strong elevation
        centerTitle: true,
        toolbarHeight: kToolbarHeight,
      ),
      
      card: app_theme_data.CardConfig(
        elevation: 6.0,        // Dramatic elevation
        borderRadius: 5.0,     // Sharp, angular corners
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: EdgeInsets.all(20.0),
      ),
      
      button: app_theme_data.ButtonConfig(
        borderRadius: 5.0,     // Sharp corners
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        elevation: 4.0,        // Strong button elevation
        height: 52.0,          // Chunky buttons
        style: app_theme_data.ButtonStyle.elevated,
      ),
      
      input: app_theme_data.InputConfig(
        borderRadius: 5.0,     // Sharp corners
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        borderStyle: app_theme_data.InputBorderStyle.outline,
        filled: false,
      ),
      
      fab: app_theme_data.FABConfig(
        shape: app_theme_data.FABShape.square,  // Angular FAB instead of circular
        elevation: 8.0,          // High elevation
        width: 64.0,
        height: 64.0,
      ),
      
      navigation: app_theme_data.NavigationConfig(
        type: app_theme_data.NavigationType.bottomNav,
        elevation: 12.0,       // Strong elevation
        showLabels: true,
      ),
      
      taskCard: app_theme_data.TaskCardConfig(
        borderRadius: 5.0,     // Slightly rounded but still angular
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: EdgeInsets.all(20.0),
        elevation: 4.0,        // Strong card elevation
        showPriorityStripe: true,
        enableSwipeActions: true,
      ),
    );
  }
}

/// Helper class for accessing colors in static context
class _VegetaColorsHelper {
  final bool isDark;
  const _VegetaColorsHelper({this.isDark = false});
  
  Color get onBackground => isDark ? const Color(0xFFf1f5f9) : const Color(0xFF1a1a1a); // Fixed: dark text for light theme
  Color get primary => const Color(0xFF1e3a8a);  // Same in both variants
  Color get secondary => isDark ? const Color(0xFF60a5fa) : const Color(0xFF3b82f6);
}