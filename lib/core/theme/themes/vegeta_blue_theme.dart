import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    
    // Light variant: Original Vegeta colors
    const deepRoyalBlue = Color(0xFF1e3a8a);     // Primary - Vegeta's aura
    const electricBlue = Color(0xFF3b82f6);       // Secondary - Energy blasts
    const silverWhite = Color(0xFFf8fafc);        // On colors - Saiyan armor
    const darkNavy = Color(0xFF0f172a);           // Background - Space darkness
    const metallicSilver = Color(0xFFe2e8f0);     // Surface - Armor shine
    const energyBlue = Color(0xFF60a5fa);         // Accent - Power aura
    const lightningYellow = Color(0xFFfbbf24);    // Highlight - Energy sparks
    
    return const ThemeColors(
      // Primary colors - Deep royal blue like Vegeta's aura
      primary: deepRoyalBlue,
      onPrimary: silverWhite,
      primaryContainer: Color(0xFF1e40af),
      onPrimaryContainer: silverWhite,

      // Secondary colors - Electric blue energy
      secondary: electricBlue,
      onSecondary: silverWhite,
      secondaryContainer: Color(0xFF2563eb),
      onSecondaryContainer: silverWhite,

      // Tertiary colors - Lightning accents
      tertiary: lightningYellow,
      onTertiary: darkNavy,
      tertiaryContainer: Color(0xFFf59e0b),
      onTertiaryContainer: darkNavy,

      // Surface colors - Metallic armor
      surface: metallicSilver,
      onSurface: darkNavy,
      surfaceVariant: Color(0xFFcbd5e1),
      onSurfaceVariant: Color(0xFF334155),
      inverseSurface: darkNavy,
      onInverseSurface: silverWhite,

      // Background colors - Space darkness
      background: darkNavy,
      onBackground: silverWhite,

      // Error colors - Destructive power
      error: Color(0xFFdc2626),
      onError: silverWhite,
      errorContainer: Color(0xFFef4444),
      onErrorContainer: silverWhite,

      // Special colors
      accent: energyBlue,
      highlight: lightningYellow,
      shadow: Color(0xFF000000),
      outline: Color(0xFF475569),
      outlineVariant: Color(0xFF64748b),

      // Task priority colors - Power levels
      taskLowPriority: Color(0xFF10b981),    // Green - Low power
      taskMediumPriority: electricBlue,       // Blue - Medium power
      taskHighPriority: Color(0xFFf59e0b),   // Yellow - High power
      taskUrgentPriority: Color(0xFFdc2626), // Red - Maximum power

      // Status colors
      success: Color(0xFF059669),
      warning: Color(0xFFd97706),
      info: energyBlue,

      // Calendar dot colors - Vegeta blue theme (light)
      calendarTodayDot: deepRoyalBlue,                // Deep royal blue for today
      calendarOverdueDot: Color(0xFFdc2626),          // Red for overdue
      calendarFutureDot: electricBlue,                // Electric blue for future
      calendarCompletedDot: Color(0xFF059669),        // Success green for completed
      calendarHighPriorityDot: lightningYellow,       // Lightning yellow for high priority
      
      // Status badge colors - Vegeta themed (light)
      statusPendingBadge: electricBlue,               // Electric blue for pending
      statusInProgressBadge: lightningYellow,         // Lightning yellow for in progress
      statusCompletedBadge: Color(0xFF059669),        // Success green for completed
      statusCancelledBadge: Color(0xFF6b7280),        // Gray for cancelled
      statusOverdueBadge: Color(0xFFdc2626),          // Red for overdue
      statusOnHoldBadge: Color(0xFFd97706),           // Orange for on hold

      // Interactive colors
      hover: Color(0xFF2563eb),
      pressed: Color(0xFF1d4ed8),
      focus: lightningYellow,
      disabled: Color(0xFF6b7280),
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
  
  Color get onBackground => isDark ? const Color(0xFFf1f5f9) : const Color(0xFFf8fafc);
  Color get primary => const Color(0xFF1e3a8a);  // Same in both variants
  Color get secondary => isDark ? const Color(0xFF60a5fa) : const Color(0xFF3b82f6);
}