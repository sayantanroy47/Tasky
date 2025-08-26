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

/// 🐟 Koi Mystic Theme - "Serene Koi Pond Mastery"
/// An epic zen-inspired theme featuring the tranquil beauty of a Japanese koi pond
/// Dark Mode: "Midnight Koi Pond" - Deep waters with moonlight reflections and vibrant koi accents  
/// Light Mode: "Dawn Koi Garden" - Crystal clear waters with golden sunrise and serene koi presence
class KoiMysticTheme {
  static app_theme_data.AppThemeData create({bool isDark = false}) {
    final now = DateTime.now();
    
    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'koi_mystic_dark' : 'koi_mystic_light',
        name: isDark ? 'Koi Mystic Dark' : 'Koi Mystic Light',
        description: isDark 
          ? 'Midnight Koi Pond theme featuring deep charcoal waters, moonlight silver reflections, and vibrant traditional koi red accents with flowing zen aesthetics'
          : 'Dawn Koi Garden theme featuring crystal clear waters, warm pearl tones, morning mist, and serene koi red accents with golden sunrise harmony',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['koi', 'japanese', 'zen', 'nature', 'water', 'epic', 'serene', 'pond', 'fish'],
        category: 'nature',
        previewIcon: PhosphorIcons.fish(),
        primaryPreviewColor: isDark ? const Color(0xFF21262D) : const Color(0xFFE1E4E8), // Koi pond waters
        secondaryPreviewColor: const Color(0xFFE53935), // Traditional koi red
        createdAt: now,
        isPremium: false,
        popularityScore: 9.5, // This is going to be EPIC!
      ),
      
      colors: _createKoiColors(isDark: isDark),
      typography: _createKoiTypography(isDark: isDark),
      animations: _createKoiAnimations(),
      effects: _createKoiEffects(),
      spacing: _createKoiSpacing(),
      components: _createKoiComponents(),
    );
  }

  /// Create light variant - Dawn Koi Garden
  static app_theme_data.AppThemeData createLight() => create(isDark: false);
  
  /// Create dark variant - Midnight Koi Pond  
  static app_theme_data.AppThemeData createDark() => create(isDark: true);

  /// Create mystical koi pond color palette
  static ThemeColors _createKoiColors({bool isDark = false}) {
    if (isDark) {
      // 🌙 Dark Mode - "Midnight Koi Pond": Deep waters under moonlight with vibrant koi
      const deepWater = Color(0xFF0D1117);           // Deep pond water at night
      const charcoalStone = Color(0xFF21262D);       // Dark pond stones  
      const moonlightSilver = Color(0xFFC9D1D9);     // Moonlight reflection on water
      const koiRed = Color(0xFFE53935);              // Traditional vibrant koi red
      const koiRedDeep = Color(0xFFD32F2F);          // Deeper koi red
      const koiRedDark = Color(0xFFB71C1C);          // Darkest koi red
      const slateRipple = Color(0xFF30363D);         // Dark water ripples
      const mistGray = Color(0xFF8B949E);            // Evening mist
      const pureWhite = Color(0xFFFFFFFF);           // Pure white contrast
      const softRipple = Color(0xFF484F58);          // Soft ripple highlights
      const lotusGreen = Color(0xFF238636);          // Lotus leaf green
      const lilyPink = Color(0xFFDA70D6);            // Lily flower pink
      
      return const ThemeColors(
        // Primary colors - Moonlight silver with koi accents
        primary: moonlightSilver,
        onPrimary: deepWater,
        primaryContainer: slateRipple,
        onPrimaryContainer: moonlightSilver,

        // Secondary colors - Traditional Koi Red
        secondary: koiRed,
        onSecondary: pureWhite,
        secondaryContainer: koiRedDeep,         // Deep koi red for container
        onSecondaryContainer: moonlightSilver,

        // Tertiary colors - Lotus and lily accents
        tertiary: lilyPink,
        onTertiary: pureWhite,
        tertiaryContainer: Color(0xFF3D1A3D),      // Dark pink container
        onTertiaryContainer: Color(0xFFE4C7E4),    // Light pink on container

        // Surface colors - Pond materials and stones
        surface: slateRipple,
        onSurface: moonlightSilver,
        surfaceVariant: softRipple,             // Soft ripple highlights variant
        onSurfaceVariant: mistGray,
        inverseSurface: moonlightSilver,
        onInverseSurface: deepWater,

        // Background colors - Deep nighttime pond
        background: deepWater,
        onBackground: moonlightSilver,

        // Error colors - Autumn koi warning colors
        error: koiRedDeep,
        onError: pureWhite,
        errorContainer: koiRedDark,             // Dark koi red error container
        onErrorContainer: Color(0xFFFF9999),

        // Special colors - Koi pond ecosystem  
        accent: koiRed,
        highlight: koiRed,
        shadow: Color(0xFF000000),
        outline: mistGray,
        outlineVariant: softRipple,

        // Task priority colors - Koi pond life hierarchy
        taskLowPriority: lotusGreen,           // Calm lotus green
        taskMediumPriority: moonlightSilver,   // Moonlight silver
        taskHighPriority: koiRed,              // Traditional koi red
        taskUrgentPriority: Color(0xFFFF4444), // Urgent red ripple

        // Status colors - Pond ecosystem health
        success: lotusGreen,
        warning: Color(0xFFFFAB40),            // Golden koi warning
        info: Color(0xFF64B5F6),               // Clear water blue

        // Calendar dot colors - Seasonal pond markers
        calendarTodayDot: koiRed,
        calendarOverdueDot: Color(0xFFFF6B6B),
        calendarFutureDot: mistGray,
        calendarCompletedDot: lotusGreen,
        calendarHighPriorityDot: koiRed,
        
        // Status badge colors - Koi pond activity states
        statusPendingBadge: mistGray,
        statusInProgressBadge: koiRed,
        statusCompletedBadge: lotusGreen,
        statusCancelledBadge: charcoalStone,
        statusOverdueBadge: Color(0xFFFF6B6B),
        statusOnHoldBadge: Color(0xFFFFAB40),

        // Interactive colors - Water ripple responses
        hover: Color(0x4DE53935),   // koiRed with 0.3 alpha
        pressed: Color(0xB3E53935), // koiRed with 0.7 alpha
        focus: koiRed,
        disabled: Color(0xFF3D3D3D),
      );
    }
    
    // ☀️ Light Mode - "Dawn Koi Garden": Crystal clear waters with golden sunrise
    const clearWater = Color(0xFFFFFFFF);         // Crystal clear water
    const morningMist = Color(0xFFF6F8FA);        // Soft morning mist
    const warmPearl = Color(0xFFE1E4E8);          // Warm pearl stone  
    const koiRed = Color(0xFFE53935);             // Traditional koi red
    const koiRedWarm = Color(0xFFD84315);         // Warm sunrise koi red
    const sunriseGold = Color(0xFFFFB74D);        // Golden sunrise accent
    const deepCharcoal = Color(0xFF24292F);       // Deep charcoal text
    const stoneGray = Color(0xFF656D76);          // Garden stone gray
    const lightRipple = Color(0xFFD0D7DE);        // Light water ripples
    const lotusGreen = Color(0xFF28A745);         // Bright lotus green
    const lilyPink = Color(0xFFE91E63);           // Bright lily pink
    const bambooGreen = Color(0xFF4CAF50);        // Fresh bamboo green
    
    return const ThemeColors(
      // Primary colors - Warm pearl with sunrise tones
      primary: stoneGray,
      onPrimary: clearWater,
      primaryContainer: morningMist,
      onPrimaryContainer: deepCharcoal,
      
      // Secondary colors - Traditional Koi Red (warm variant)
      secondary: koiRedWarm,
      onSecondary: clearWater,
      secondaryContainer: Color(0xFFFFEBEE),
      onSecondaryContainer: Color(0xFFB71C1C),
      
      // Tertiary colors - Bamboo and nature accents
      tertiary: bambooGreen,
      onTertiary: clearWater,
      tertiaryContainer: Color(0xFFE8F5E8),
      onTertiaryContainer: Color(0xFF1B5E20),
      
      // Surface colors - Light garden materials
      surface: morningMist,
      onSurface: deepCharcoal,
      surfaceVariant: warmPearl,
      onSurfaceVariant: stoneGray,
      inverseSurface: deepCharcoal,
      onInverseSurface: clearWater,
      
      // Background colors - Pure morning light
      background: clearWater,
      onBackground: deepCharcoal,
      
      // Error colors - Gentle warning tones
      error: Color(0xFFDC2626),
      onError: clearWater,
      errorContainer: Color(0xFFFEF2F2),
      onErrorContainer: Color(0xFF991B1B),
      
      // Special colors - Dawn garden serenity
      accent: koiRed,
      highlight: lilyPink,
      shadow: Color(0xFF000000),
      outline: lightRipple,
      outlineVariant: Color(0xFFE1E4E8),
      
      // Task priority colors - Garden vitality levels
      taskLowPriority: lotusGreen,
      taskMediumPriority: stoneGray,
      taskHighPriority: koiRed,
      taskUrgentPriority: Color(0xFFDC2626),
      
      // Status colors - Garden health indicators
      success: lotusGreen,
      warning: sunriseGold,
      info: Color(0xFF2196F3),
      
      // Calendar dot colors - Garden seasonal markers
      calendarTodayDot: koiRed,
      calendarOverdueDot: Color(0xFFDC2626),
      calendarFutureDot: stoneGray,
      calendarCompletedDot: lotusGreen,
      calendarHighPriorityDot: koiRed,
      
      // Status badge colors - Garden activity states
      statusPendingBadge: stoneGray,
      statusInProgressBadge: koiRed,
      statusCompletedBadge: lotusGreen,
      statusCancelledBadge: Color(0xFF9CA3AF),
      statusOverdueBadge: Color(0xFFDC2626),
      statusOnHoldBadge: sunriseGold,
      
      // Interactive colors - Gentle ripple responses
      hover: Color(0x33E53935),   // koiRed with 0.2 alpha
      pressed: Color(0x80E53935), // koiRed with 0.5 alpha
      focus: koiRed,
      disabled: Color(0xFFE1E4E8),
    );
  }

  /// Create zen-inspired typography using Sansation font
  static ThemeTypography _createKoiTypography({bool isDark = true}) {
    final colors = _KoiColorsHelper(isDark: isDark);
    const fontFamily = 'Sansation';
    
    return ThemeTypography(
      fontFamily: fontFamily,
      displayFontFamily: fontFamily,
      monospaceFontFamily: fontFamily,
      baseSize: TypographyConstants.bodyLarge,
      scaleRatio: 1.0,
      baseFontWeight: FontWeight.w400,
      baseLetterSpacing: TypographyConstants.wideLetterSpacing * 0.8, // Slightly tighter for zen feel
      baseLineHeight: TypographyConstants.relaxedLineHeight, // More relaxed like flowing water
      
      // Display styles - Majestic koi titles
      displayLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayLarge,
        fontWeight: FontWeight.w300, // Light weight for elegant feel
        letterSpacing: TypographyConstants.wideLetterSpacing * 0.6,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      displayMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayMedium,
        fontWeight: FontWeight.w300,
        letterSpacing: TypographyConstants.wideLetterSpacing * 0.6,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      displaySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displaySmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      
      // Headline styles - Flowing water headers
      headlineLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      headlineMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineMedium,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      headlineSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineSmall,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      
      // Title styles - Serene balance
      titleLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleLarge,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      titleMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleMedium,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.1, // Slightly more space for zen
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      titleSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.1,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      
      // Body styles - Gentle flow
      bodyLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      bodyMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyMedium,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      bodySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      
      // Label styles - Pond markers
      labelLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelLarge,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.wideLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      labelMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelMedium,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.wideLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      labelSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelSmall,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.wideLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Custom app styles - Koi pond zen precision
      taskTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskTitle,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.1,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      taskDescription: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskDescription,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      taskMeta: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskMeta,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      cardTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.1,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      cardSubtitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      buttonText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.buttonText,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.wideLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      inputText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.inputText,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      appBarTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.appBarTitle,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.1,
        height: TypographyConstants.relaxedLineHeight,
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

  /// Create water-like flowing animations with koi scale particles
  static ThemeAnimations _createKoiAnimations() {
    return ThemeAnimations.fromThemeStyle(ThemeAnimationStyle.smooth).copyWith(
      // Water flow timing - slower, more organic
      fast: const Duration(milliseconds: 250),
      medium: const Duration(milliseconds: 500),
      slow: const Duration(milliseconds: 750),
      verySlow: const Duration(milliseconds: 1200),
      
      // Organic water curves - flowing like koi swimming  
      primaryCurve: Curves.easeInOutSine,   // Smooth like water ripples
      secondaryCurve: Curves.easeOutCubic,  // Gentle deceleration
      entranceCurve: Curves.easeOutBack,    // Like koi emerging from water
      exitCurve: Curves.easeInCubic,        // Gentle submersion
      
      // Koi scale particle system
      enableParticles: true,
      particleConfig: const ParticleConfig(
        density: ParticleDensity.medium,     // Moderate koi scale density
        speed: ParticleSpeed.slow,           // Gentle floating motion
        style: ParticleStyle.organic,        // Natural koi scale shapes
        enableGlow: true,                    // Mystical koi scale glow
        opacity: 0.2,                        // Subtle, zen-like presence
        size: 0.6,                           // Small, delicate scales
      ),
    );
  }

  /// Create mystical koi pond visual effects
  static theme_effects.ThemeEffects _createKoiEffects() {
    return theme_effects.ThemeEffects.fromEffectStyle(theme_effects.ThemeEffectStyle.elegant).copyWith(
      shadowStyle: theme_effects.ShadowStyle.soft,         // Gentle pond shadows
      gradientStyle: theme_effects.GradientStyle.subtle,   // Water gradient effects
      borderStyle: theme_effects.BorderStyle.rounded,      // Organic pond shapes
      
      blurConfig: const theme_effects.BlurConfig(
        enabled: true,
        intensity: 2.5,                      // Soft water blur
        style: theme_effects.BlurStyle.normal,
      ),
      
      glowConfig: const theme_effects.GlowConfig(
        enabled: true,
        intensity: 0.3,                      // Gentle moonlight/sunrise glow
        spread: 12.0,                        // Wide, soft glow radius
        style: theme_effects.GlowStyle.outer,
      ),
      
      backgroundEffects: const theme_effects.BackgroundEffectConfig(
        enableParticles: true,               // Floating koi scales
        enableGradientMesh: true,            // Water surface gradients
        enableScanlines: false,              // No digital elements - pure zen
        particleType: theme_effects.BackgroundParticleType.floating, // Gentle floating
        particleOpacity: 0.1,                // Very subtle presence
        effectIntensity: 0.4,                // Moderate zen effects
        geometricPattern: theme_effects.BackgroundGeometricPattern.radial,
        patternAngle: 0.0,
        patternDensity: 0.6,
        accentColors: [
          Color(0x1AE53935), // Traditional koi red at 0.1 alpha
          Color(0x0C238636), // Lotus green at 0.05 alpha
        ],
      ),
    );
  }

  /// Create Japanese golden ratio spacing system
  static app_theme_data.ThemeSpacing _createKoiSpacing() {
    // Using phi (golden ratio ≈ 1.618) for harmonious Japanese-inspired proportions
    const phi = 1.618;
    const baseUnit = 8.0;
    
    return app_theme_data.ThemeSpacing.fromBaseUnit(baseUnit).copyWith(
      cardPadding: baseUnit * phi * 1.2,        // ~15.5 → Harmonious card padding
      screenPadding: baseUnit * phi * 1.5,      // ~19.4 → Comfortable screen margins  
      buttonPadding: baseUnit * phi,             // ~12.9 → Balanced button padding
      inputPadding: baseUnit * phi * 0.9,       // ~11.6 → Gentle input padding
    );
  }

  /// Create zen garden components with lily pad aesthetics
  static app_theme_data.ThemeComponents _createKoiComponents() {
    return const app_theme_data.ThemeComponents(
      appBar: app_theme_data.AppBarConfig(
        elevation: 0.0,                      // Flat like pond surface
        centerTitle: true,                   // Balanced zen layout
        toolbarHeight: kToolbarHeight,
      ),
      
      card: app_theme_data.CardConfig(
        elevation: 2.0,                      // Gentle lily pad elevation
        borderRadius: 16.0,                  // Organic lily pad curves
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: EdgeInsets.all(20.0),      // Comfortable lotus padding
      ),
      
      button: app_theme_data.ButtonConfig(
        borderRadius: 14.0,                  // Smooth stone corners
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        elevation: 2.0,                      // Gentle stone elevation
        height: 52.0,                        // Comfortable interaction size
        style: app_theme_data.ButtonStyle.filled,
      ),
      
      input: app_theme_data.InputConfig(
        borderRadius: 12.0,                  // Gentle pond ripple curves
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        borderStyle: app_theme_data.InputBorderStyle.outline,
        filled: true,
      ),
      
      fab: app_theme_data.FABConfig(
        shape: app_theme_data.FABShape.circular, // Perfect pond ripple
        elevation: 4.0,                      // Floating on water
        width: null,
        height: null,
      ),
      
      navigation: app_theme_data.NavigationConfig(
        type: app_theme_data.NavigationType.bottomNav,
        elevation: 8.0,                      // Above pond surface
        showLabels: true,
      ),
      
      taskCard: app_theme_data.TaskCardConfig(
        borderRadius: 14.0,                  // Lily pad curves
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: EdgeInsets.all(18.0),      // Generous lily pad space
        elevation: 1.5,                      // Gentle float on water
        showPriorityStripe: true,            // Koi color indicators
        enableSwipeActions: true,            // Fluid water interactions
      ),
    );
  }
}

/// Helper class for accessing koi colors in static context
class _KoiColorsHelper {
  final bool isDark;
  const _KoiColorsHelper({this.isDark = true});
  
  Color get onBackground => isDark 
    ? const Color(0xFFC9D1D9)   // Moonlight silver
    : const Color(0xFF24292F);  // Deep charcoal
    
  Color get primary => isDark 
    ? const Color(0xFFC9D1D9)   // Moonlight silver
    : const Color(0xFF656D76);  // Stone gray
    
  Color get koiRed => const Color(0xFFE53935); // Traditional koi red in both modes
}