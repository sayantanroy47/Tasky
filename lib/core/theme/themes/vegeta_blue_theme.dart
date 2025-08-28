import 'package:flutter/material.dart';
import '../local_fonts.dart';
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
        primaryPreviewColor: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF), // Enhanced dark vs pure white
        secondaryPreviewColor: isDark ? const Color(0xFF009DFF) : const Color(0xFF1E3A8A), // Azure blue (mode-specific)
        tertiaryPreviewColor: isDark ? const Color(0xFF0F52BA) : const Color(0xFF0A3377), // Vegeta Sapphire signature accent
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
      // SSGSS Dark Variant: Deep cosmic void with azure energy
      const deepestVoid = Color(0xFF000000);         // Pure black void background
      const royalNavy = Color(0xFF1E3A8A);           // Vegeta's battle suit
      const azureBlue = Color(0xFF009DFF);           // SSGSS Azure blue base
      const skyBlue = Color(0xFF00BFFF);             // Saturated sky blue
      const pureWhite = Color(0xFFFFFFFF);           // Pure white text
      const plasmaYellow = Color(0xFFFACC15);        // Gold armor accents and sparks
      const deepShadow = Color(0xFF050505);          // Nearly black shadows
      const lightAzure = Color(0xFF87CEEB);          // Light azure highlights
      const darkPurple = Color(0xFF0A0A0F);          // Very dark cosmic depth
      
      // Vegeta Sapphire Signature Accent - Enhanced for dark mode visibility
      const vegetaSapphireSignature = Color(0xFF0F52BA);     // Super bright signature sapphire
      const onVegetaSapphireSignature = Color(0xFFFFFFFF);   // Pure white for maximum contrast
      const vegetaSapphireContainer = Color(0xFF1A3C6B);     // Enhanced sapphire container
      const onVegetaSapphireContainer = Color(0xFFFFFFFF);   // Pure white for container text
      
      return const ThemeColors(
        // Primary colors - SSGSS Azure
        primary: azureBlue,
        onPrimary: pureWhite,
        primaryContainer: royalNavy,
        onPrimaryContainer: pureWhite,

        // Secondary colors - Azure Aura Core
        secondary: azureBlue,
        onSecondary: deepestVoid,
        secondaryContainer: lightAzure,
        onSecondaryContainer: deepestVoid,

        // Tertiary colors - Golden Armor Accents
        tertiary: plasmaYellow,
        onTertiary: deepestVoid,
        tertiaryContainer: Color(0xFFD97706),
        onTertiaryContainer: deepestVoid,

        // Surface colors - Dark Materials
        surface: deepShadow,
        onSurface: pureWhite,
        surfaceVariant: darkPurple,
        onSurfaceVariant: skyBlue,
        inverseSurface: pureWhite,
        onInverseSurface: deepestVoid,

        // Background colors - Deepest Void
        background: deepestVoid,
        onBackground: pureWhite,

        // Error colors - Destructive Ki Energy
        error: Color(0xFFEF4444),
        onError: deepestVoid,
        errorContainer: Color(0xFFDC2626),
        onErrorContainer: pureWhite,

        // Special colors - SSGSS Energy System with Signature Accent
        accent: vegetaSapphireSignature,        // Use signature sapphire as primary accent
        highlight: plasmaYellow,
        shadow: Color(0xFF000000),
        outline: lightAzure,
        outlineVariant: darkPurple,

        // Task priority colors - Power Level System with Signature Accent
        taskLowPriority: Color(0xFF10B981),      // Calm energy green
        taskMediumPriority: azureBlue,           // SSGSS azure blue
        taskHighPriority: vegetaSapphireSignature, // Signature sapphire power
        taskUrgentPriority: Color(0xFFEF4444),   // Destructive red

        // Status colors - Energy States
        success: Color(0xFF10B981),
        warning: plasmaYellow,
        info: skyBlue,

        // Calendar dot colors - SSGSS Power System with Signature Accent
        calendarTodayDot: skyBlue,
        calendarOverdueDot: Color(0xFFEF4444),
        calendarFutureDot: lightAzure,
        calendarCompletedDot: Color(0xFF10B981),
        calendarHighPriorityDot: vegetaSapphireSignature,  // Signature sapphire for high priority
        
        // Status badge colors - Saiyan Power States with Signature Accent
        statusPendingBadge: skyBlue,
        statusInProgressBadge: plasmaYellow,
        statusCompletedBadge: vegetaSapphireSignature,     // Signature sapphire for completed (achievement)
        statusCancelledBadge: darkPurple,
        statusOverdueBadge: Color(0xFFEF4444),
        statusOnHoldBadge: lightAzure,

        // Interactive colors - Energy Responses
        hover: lightAzure,
        pressed: royalNavy,
        focus: vegetaSapphireSignature,                    // Signature sapphire for focus
        disabled: darkPurple,
        
        // Vegeta Sapphire Signature Colors
        vegetaSapphire: vegetaSapphireSignature,
        onVegetaSapphire: onVegetaSapphireSignature,
        vegetaSapphireContainer: vegetaSapphireContainer,
        onVegetaSapphireContainer: onVegetaSapphireContainer,
      );
    }
    
    // SSGSS Light Variant: Clean battlefield with controlled energy
    
    // Refined SSGSS colors for light variant
    const darkRoyalNavy = Color(0xFF1E3A8A);          // Strong suit accent
    const darkAzureBlue = Color(0xFF009DFF);          // SSGSS Azure blue base
    const darkAzureGlow = Color(0xFF66B3FF);          // Saturated sky blue
    const darkPlasmaYellow = Color(0xFFFACC15);       // Golden highlight
    
    // Light variant backgrounds and accents
    const pureWhite = Color(0xFFFFFFFF);              // Clean background
    const lightSilver = Color(0xFFF3F4F6);            // Soft armor gray
    const paleBlue = Color(0xFFDBEAFE);               // Gentle aura tint
    const lightAzure = Color(0xFFB3D9FF);             // Light azure highlight
    
    // Vegeta Sapphire Signature Accent - Deeper for light mode contrast
    const deepVegetaSapphire = Color(0xFF0A3377);          // Deep signature sapphire
    const onDeepVegetaSapphire = Color(0xFFFFFFFF);         // White text on deep sapphire
    const deepVegetaSapphireContainer = Color(0xFFE6F3FF);  // Light sapphire container
    const onDeepVegetaSapphireContainer = Color(0xFF001B44); // Deep sapphire container text
    
    return const ThemeColors(
      // Primary colors - SSGSS Battle Suit (Light)
      primary: darkRoyalNavy,
      onPrimary: pureWhite,
      primaryContainer: paleBlue,
      onPrimaryContainer: darkRoyalNavy,
      
      // Secondary colors - Azure Aura (Light)
      secondary: darkAzureBlue,
      onSecondary: pureWhite,
      secondaryContainer: lightAzure,
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
      
      // Special colors - SSGSS Light Energy System with Signature Accent
      accent: deepVegetaSapphire,            // Use signature sapphire as primary accent
      highlight: darkPlasmaYellow,
      shadow: Color(0xFF000000),
      outline: Color(0xFF64748B), // Slate outline
      outlineVariant: Color(0xFF94A3B8), // Light slate outline
      
      // Task priority colors - Light Power Level System with Signature Accent
      taskLowPriority: Color(0xFF059669),      // Strong green
      taskMediumPriority: darkAzureBlue,       // SSGSS azure blue
      taskHighPriority: deepVegetaSapphire,    // Signature sapphire power
      taskUrgentPriority: Color(0xFFDC2626),   // Strong red
      
      // Status colors - Light Energy States
      success: Color(0xFF059669), // Strong green
      warning: Color(0xFFD97706), // Strong amber
      info: darkAzureGlow,
      
      // Calendar dot colors - SSGSS Light Power System with Signature Accent
      calendarTodayDot: darkAzureGlow,
      calendarOverdueDot: Color(0xFFDC2626),
      calendarFutureDot: lightAzure,
      calendarCompletedDot: Color(0xFF059669),
      calendarHighPriorityDot: deepVegetaSapphire,       // Signature sapphire for high priority
      
      // Status badge colors - Light Saiyan Power States with Signature Accent
      statusPendingBadge: darkAzureGlow,
      statusInProgressBadge: darkPlasmaYellow,
      statusCompletedBadge: deepVegetaSapphire,           // Signature sapphire for completed (achievement)
      statusCancelledBadge: Color(0xFF64748B), // Neutral slate
      statusOverdueBadge: Color(0xFFDC2626),
      statusOnHoldBadge: Color(0xFFD97706), // Amber
      
      // Interactive colors - Light Energy Responses
      hover: lightAzure,
      pressed: darkRoyalNavy,
      focus: deepVegetaSapphire,              // Signature sapphire for focus
      disabled: Color(0xFF94A3B8), // Light slate
      
      // Vegeta Sapphire Signature Colors
      vegetaSapphire: deepVegetaSapphire,
      onVegetaSapphire: onDeepVegetaSapphire,
      vegetaSapphireContainer: deepVegetaSapphireContainer,
      onVegetaSapphireContainer: onDeepVegetaSapphireContainer,
    );
  }

  /// Create Vegeta-inspired typography using Sansation (clean, futuristic font)
  static ThemeTypography _createVegetaTypography({bool isDark = false}) {
    final colors = _VegetaColorsHelper(isDark: isDark);
    const fontFamily = 'Sansation';
    
    return ThemeTypography(
      fontFamily: fontFamily,
      displayFontFamily: fontFamily,
      monospaceFontFamily: fontFamily,
      baseSize: TypographyConstants.bodyLarge,
      scaleRatio: 1.0, // No scaling - use exact constants
      baseFontWeight: TypographyConstants.medium, // Medium weight for Saira
      baseLetterSpacing: TypographyConstants.normalLetterSpacing, // Consistent spacing
      baseLineHeight: TypographyConstants.normalLineHeight, // Consistent line height
      
      // Use EXACT typography constants for all sizes
      displayLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayLarge,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      displayMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayMedium,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      displaySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displaySmall,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      headlineLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineLarge,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      headlineMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineMedium,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      headlineSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineSmall,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      titleLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleLarge,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      titleMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleMedium,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      titleSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      bodyLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyLarge,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      bodyMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyMedium,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      bodySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      labelLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelLarge,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      labelMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelMedium,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      labelSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelSmall,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Custom app styles with exact constants
      taskTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskTitle,
        fontWeight: TypographyConstants.medium, // No bold fonts - using medium
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      taskDescription: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskDescription,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      taskMeta: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskMeta,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      cardTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      cardSubtitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      buttonText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.buttonText,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      inputText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.inputText,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      appBarTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.appBarTitle,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      navigationLabel: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.navigationLabel,
        fontWeight: TypographyConstants.smallTextWeight,
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
        geometricPattern: theme_effects.BackgroundGeometricPattern.diamond,
        patternAngle: 0.0,
        patternDensity: 0.8,
        accentColors: [
          Color(0x1A0F52BA), // Vegeta Sapphire signature accent at 0.1 alpha
          Color(0x1A009DFF), // SSGSS Azure blue at 0.1 alpha
          Color(0x1AFACC15), // Golden plasma yellow at 0.1 alpha
        ],
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
  
  Color get onBackground => isDark ? const Color(0xFFE8F4FF) : const Color(0xFF1a1a1a); // Blue-tinted white for Vegeta theme consistency
  Color get primary => const Color(0xFF009DFF);  // Updated azure base
  Color get secondary => isDark ? const Color(0xFF87CEEB) : const Color(0xFF66B3FF);
}


