import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme_data.dart' as app_theme_data;
import '../models/theme_metadata.dart';
import '../models/theme_colors.dart';
import '../models/theme_typography.dart';
import '../models/theme_animations.dart';
import '../models/theme_effects.dart' as theme_effects;
import '../typography_constants.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Vegeta Blue Theme - "Saiyan Power"
/// A dramatic, powerful theme inspired by Dragon Ball Z's Prince Vegeta
/// Features deep blue colors, sharp angular design, and explosive animations
class VegetaBlueTheme {
  static app_theme_data.AppThemeData create({bool isDark = false}) {
    final now = DateTime.now();
    
    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'vegeta_blue_dark' : 'vegeta_blue',
        name: isDark ? 'Vegeta SSGSS Dark' : 'Vegeta SSGSS Light',
        description: isDark 
          ? 'SSGSS Vegeta theme with cosmic void backgrounds, brilliant azure energy, and royal battle suit aesthetics'
          : 'Super Saiyan God Super Saiyan theme featuring controlled azure power, golden accents, and clean battlefield aesthetics',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['anime', 'ssgss', 'cosmic', 'azure', 'royal', 'energy', 'dramatic'],
        category: 'gaming',
        previewIcon: PhosphorIcons.lightning(),
        primaryPreviewColor: const Color(0xFF1E3A8A), // SSGSS battle suit
        secondaryPreviewColor: const Color(0xFF1F8FFF), // Azure aura core
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


  /// Create Vegeta SSGSS-inspired color palette with maximum accuracy
  static ThemeColors _createVegetaColors({bool isDark = false}) {
    if (isDark) {
      // SSGSS Dark Variant: Cosmic void with brilliant azure energy
      const deepSpaceBlue = Color(0xFF0A0F1C);       // Cosmic void background
      const royalNavy = Color(0xFF1E3A8A);           // Vegeta's battle suit
      const brilliantBlue = Color(0xFF1F8FFF);       // SSJ Blue hair & aura core
      const energyGlow = Color(0xFF60A5FA);          // Aura edges, glow effects
      const silverWhite = Color(0xFFE5E9F0);         // Armor shine
      const plasmaYellow = Color(0xFFFACC15);        // Gold armor accents and sparks
      const spaceDark = Color(0xFF111827);           // Deep shadows
      const auraCyan = Color(0xFF38BDF8);            // Extra highlight for glowing energy
      const voidPurple = Color(0xFF1C1B29);          // Subtle cosmic depth
      
      return const ThemeColors(
        // Primary colors - SSGSS Battle Suit
        primary: royalNavy,
        onPrimary: silverWhite,
        primaryContainer: brilliantBlue,
        onPrimaryContainer: silverWhite,

        // Secondary colors - Azure Aura Core
        secondary: brilliantBlue,
        onSecondary: deepSpaceBlue,
        secondaryContainer: auraCyan,
        onSecondaryContainer: deepSpaceBlue,

        // Tertiary colors - Golden Armor Accents
        tertiary: plasmaYellow,
        onTertiary: deepSpaceBlue,
        tertiaryContainer: Color(0xFFD97706),
        onTertiaryContainer: deepSpaceBlue,

        // Surface colors - Cosmic Materials
        surface: spaceDark,
        onSurface: silverWhite,
        surfaceVariant: voidPurple,
        onSurfaceVariant: silverWhite,
        inverseSurface: silverWhite,
        onInverseSurface: deepSpaceBlue,

        // Background colors - Deep Space Void
        background: deepSpaceBlue,
        onBackground: silverWhite,

        // Error colors - Destructive Ki Energy
        error: Color(0xFFEF4444),
        onError: deepSpaceBlue,
        errorContainer: Color(0xFFDC2626),
        onErrorContainer: silverWhite,

        // Special colors - SSGSS Energy System
        accent: energyGlow,
        highlight: plasmaYellow,
        shadow: Color(0xFF000000),
        outline: auraCyan,
        outlineVariant: voidPurple,

        // Task priority colors - Power Level System
        taskLowPriority: Color(0xFF10B981),      // Calm energy green
        taskMediumPriority: brilliantBlue,       // SSGSS blue
        taskHighPriority: plasmaYellow,          // Golden power
        taskUrgentPriority: Color(0xFFEF4444),   // Destructive red

        // Status colors - Energy States
        success: Color(0xFF10B981),
        warning: plasmaYellow,
        info: energyGlow,

        // Calendar dot colors - SSGSS Power System
        calendarTodayDot: energyGlow,
        calendarOverdueDot: Color(0xFFEF4444),
        calendarFutureDot: auraCyan,
        calendarCompletedDot: Color(0xFF10B981),
        calendarHighPriorityDot: plasmaYellow,
        
        // Status badge colors - Saiyan Power States
        statusPendingBadge: energyGlow,
        statusInProgressBadge: plasmaYellow,
        statusCompletedBadge: Color(0xFF10B981),
        statusCancelledBadge: voidPurple,
        statusOverdueBadge: Color(0xFFEF4444),
        statusOnHoldBadge: auraCyan,

        // Interactive colors - Energy Responses
        hover: auraCyan,
        pressed: royalNavy,
        focus: plasmaYellow,
        disabled: voidPurple,
      );
    }
    
    // SSGSS Light Variant: Clean battlefield with controlled energy
    
    // Refined SSGSS colors for light variant
    const darkRoyalNavy = Color(0xFF1E3A8A);          // Strong suit accent
    const darkBrilliantBlue = Color(0xFF1F8FFF);      // Aura highlight  
    const darkEnergyGlow = Color(0xFF60A5FA);         // Aura edge glow
    const darkPlasmaYellow = Color(0xFFFACC15);       // Golden highlight
    
    // Light variant backgrounds and accents
    const pureWhite = Color(0xFFFFFFFF);              // Clean background
    const lightSilver = Color(0xFFF3F4F6);            // Soft armor gray
    const paleBlue = Color(0xFFDBEAFE);               // Gentle aura tint
    const auraCyanLight = Color(0xFFBAE6FD);          // Glow highlight
    
    return const ThemeColors(
      // Primary colors - SSGSS Battle Suit (Light)
      primary: darkRoyalNavy,
      onPrimary: pureWhite,
      primaryContainer: paleBlue,
      onPrimaryContainer: darkRoyalNavy,
      
      // Secondary colors - Azure Aura (Light)
      secondary: darkBrilliantBlue,
      onSecondary: pureWhite,
      secondaryContainer: auraCyanLight,
      onSecondaryContainer: darkRoyalNavy,
      
      // Tertiary colors - Golden Energy Accents (Light)
      tertiary: darkPlasmaYellow,
      onTertiary: darkRoyalNavy,
      tertiaryContainer: Color(0xFFFEF3C7), // Light yellow container
      onTertiaryContainer: darkRoyalNavy,
      
      // Surface colors - Light battlefield materials
      surface: lightSilver,
      onSurface: Color(0xFF1a1a1a), // Dark text for light surfaces
      surfaceVariant: Color(0xFFE2E8F0), // Light slate
      onSurfaceVariant: Color(0xFF2a2a2a), // Dark text for light surfaces
      inverseSurface: darkRoyalNavy,
      onInverseSurface: pureWhite,
      
      // Background colors - Clean battlefield
      background: pureWhite,
      onBackground: Color(0xFF0a0a0a), // Very dark text for light backgrounds
      
      // Error colors - Destructive energy (light variant)
      error: Color(0xFFDC2626), // Strong red but not overwhelming
      onError: pureWhite,
      errorContainer: Color(0xFFFEF2F2), // Light red container
      onErrorContainer: Color(0xFF991B1B), // Dark red text
      
      // Special colors - SSGSS Light Energy System
      accent: darkEnergyGlow,
      highlight: darkPlasmaYellow,
      shadow: Color(0xFF000000),
      outline: Color(0xFF64748B), // Slate outline
      outlineVariant: Color(0xFF94A3B8), // Light slate outline
      
      // Task priority colors - Light Power Level System
      taskLowPriority: Color(0xFF059669),      // Strong green
      taskMediumPriority: darkBrilliantBlue,   // SSGSS blue
      taskHighPriority: darkPlasmaYellow,      // Golden power
      taskUrgentPriority: Color(0xFFDC2626),   // Strong red
      
      // Status colors - Light Energy States
      success: Color(0xFF059669), // Strong green
      warning: Color(0xFFD97706), // Strong amber
      info: darkEnergyGlow,
      
      // Calendar dot colors - SSGSS Light Power System
      calendarTodayDot: darkEnergyGlow,
      calendarOverdueDot: Color(0xFFDC2626),
      calendarFutureDot: auraCyanLight,
      calendarCompletedDot: Color(0xFF059669),
      calendarHighPriorityDot: darkPlasmaYellow,
      
      // Status badge colors - Light Saiyan Power States
      statusPendingBadge: darkEnergyGlow,
      statusInProgressBadge: darkPlasmaYellow,
      statusCompletedBadge: Color(0xFF059669),
      statusCancelledBadge: Color(0xFF64748B), // Neutral slate
      statusOverdueBadge: Color(0xFFDC2626),
      statusOnHoldBadge: Color(0xFFD97706), // Amber
      
      // Interactive colors - Light Energy Responses
      hover: auraCyanLight,
      pressed: darkRoyalNavy,
      focus: darkPlasmaYellow,
      disabled: Color(0xFF94A3B8), // Light slate
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
      baseLetterSpacing: TypographyConstants.normalLetterSpacing, // Consistent spacing
      baseLineHeight: TypographyConstants.normalLineHeight, // Consistent line height
      
      // Use EXACT typography constants for all sizes
      displayLarge: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayLarge,
        fontWeight: TypographyConstants.light,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      displayMedium: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayMedium,
        fontWeight: TypographyConstants.light,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      displaySmall: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displaySmall,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      headlineLarge: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineLarge,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      headlineMedium: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineMedium,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      headlineSmall: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineSmall,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      titleLarge: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleLarge,
        fontWeight: TypographyConstants.semiBold,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      titleMedium: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleMedium,
        fontWeight: TypographyConstants.semiBold,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      titleSmall: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.semiBold,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      bodyLarge: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyLarge,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      bodyMedium: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyMedium,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      bodySmall: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      labelLarge: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelLarge,
        fontWeight: TypographyConstants.semiBold,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      labelMedium: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelMedium,
        fontWeight: TypographyConstants.semiBold,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      labelSmall: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelSmall,
        fontWeight: TypographyConstants.semiBold,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Custom app styles with exact constants
      taskTitle: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskTitle,
        fontWeight: TypographyConstants.bold, // Extra bold for Vegeta
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      taskDescription: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskDescription,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      taskMeta: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskMeta,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      cardTitle: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.semiBold,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      cardSubtitle: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      buttonText: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.buttonText,
        fontWeight: TypographyConstants.semiBold,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      inputText: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.inputText,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      appBarTitle: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.appBarTitle,
        fontWeight: TypographyConstants.semiBold,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      navigationLabel: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.navigationLabel,
        fontWeight: TypographyConstants.semiBold,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
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


