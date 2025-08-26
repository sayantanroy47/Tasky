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

/// ⭐ Starfield Cosmic Theme - "Infinite Horizons"
/// A cosmic exploration theme inspired by the vast beauty of deep space and stellar phenomena
/// Dark Mode: "Deep Space Explorer" - Cosmic void with stellar whites, nebula purples, and twinkling stars
/// Light Mode: "Stellar Observatory" - Bright nebula backgrounds with cosmic accents and celestial beauty
class StarfieldCosmicTheme {
  static app_theme_data.AppThemeData create({bool isDark = true}) {
    final now = DateTime.now();
    
    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'starfield_cosmic_dark' : 'starfield_cosmic_light',
        name: isDark ? 'Starfield Cosmic Dark' : 'Starfield Cosmic Light',
        description: isDark 
          ? 'Deep Space Explorer theme featuring cosmic void backgrounds, stellar white highlights, nebula purple accents, cosmic blue details, and twinkling star particle effects'
          : 'Stellar Observatory theme with bright nebula backgrounds, cosmic blue accents, stellar highlights, and celestial beauty for space exploration',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['space', 'cosmic', 'stars', 'nebula', 'exploration', 'infinite', 'stellar', 'astronomy'],
        category: 'nature',
        previewIcon: PhosphorIcons.planet(),
        primaryPreviewColor: const Color(0xFF191970), // Deep space navy
        secondaryPreviewColor: const Color(0xFF9370DB), // Nebula purple
        createdAt: now,
        isPremium: false,
        popularityScore: 9.3, // Popular space aesthetic
      ),
      
      colors: _createCosmicColors(isDark: isDark),
      typography: _createCosmicTypography(isDark: isDark),
      animations: _createCosmicAnimations(),
      effects: _createCosmicEffects(),
      spacing: _createCosmicSpacing(),
      components: _createCosmicComponents(),
    );
  }

  /// Create light variant - Stellar Observatory
  static app_theme_data.AppThemeData createLight() => create(isDark: false);
  
  /// Create dark variant - Deep Space Explorer
  static app_theme_data.AppThemeData createDark() => create(isDark: true);

  /// Create infinite cosmic color palette
  static ThemeColors _createCosmicColors({bool isDark = true}) {
    if (isDark) {
      // 🌌 Dark Mode - "Deep Space Explorer": Cosmic void with stellar phenomena
      const cosmicVoid = Color(0xFF0C0C1A);            // Deep cosmic void
      const deepSpaceNavy = Color(0xFF191970);          // Deep space navy
      const stellarWhite = Color(0xFFF0F8FF);           // Stellar white
      const nebulaPurple = Color(0xFF9370DB);           // Nebula purple
      const cosmicBlue = Color(0xFF4682B4);             // Cosmic blue
      const stardustGray = Color(0xFF2F3349);           // Stardust gray
      const galaxyPurple = Color(0xFF6A5ACD);           // Galaxy purple
      const solarGold = Color(0xFFFFD700);              // Solar gold accent
      const asteroidGray = Color(0xFF708090);           // Asteroid gray
      const quantumTeal = Color(0xFF008B8B);            // Quantum teal
      
      return const ThemeColors(
        // Primary colors - Stellar White brilliance
        primary: stellarWhite,
        onPrimary: deepSpaceNavy,
        primaryContainer: stardustGray,
        onPrimaryContainer: stellarWhite,

        // Secondary colors - Nebula Purple mystery
        secondary: nebulaPurple,
        onSecondary: stellarWhite,
        secondaryContainer: Color(0xFF4B0082),
        onSecondaryContainer: Color(0xFFDDA0DD),

        // Tertiary colors - Cosmic Blue exploration
        tertiary: cosmicBlue,
        onTertiary: stellarWhite,
        tertiaryContainer: Color(0xFF2F4F4F),
        onTertiaryContainer: Color(0xFF87CEEB),

        // Surface colors - Space station materials
        surface: deepSpaceNavy,
        onSurface: stellarWhite,
        surfaceVariant: stardustGray,
        onSurfaceVariant: asteroidGray,
        inverseSurface: stellarWhite,
        onInverseSurface: cosmicVoid,

        // Background colors - Infinite cosmic void
        background: cosmicVoid,
        onBackground: stellarWhite,

        // Error colors - Solar flare danger
        error: Color(0xFFFF4500),
        onError: stellarWhite,
        errorContainer: Color(0xFF330A00),
        onErrorContainer: Color(0xFFFF8866),

        // Special colors - Cosmic essence
        accent: nebulaPurple,
        highlight: solarGold,
        shadow: cosmicVoid,
        outline: asteroidGray,
        outlineVariant: stardustGray,

        // Task priority colors - Cosmic energy levels
        taskLowPriority: quantumTeal,            // Low energy - Quantum teal
        taskMediumPriority: cosmicBlue,          // Medium energy - Cosmic blue
        taskHighPriority: nebulaPurple,          // High energy - Nebula purple
        taskUrgentPriority: solarGold,           // Critical energy - Solar gold

        // Status colors - Stellar states
        success: Color(0xFF32CD32),
        warning: solarGold,
        info: cosmicBlue,

        // Calendar dot colors - Cosmic calendar
        calendarTodayDot: stellarWhite,
        calendarOverdueDot: Color(0xFFFF4500),
        calendarFutureDot: cosmicBlue,
        calendarCompletedDot: Color(0xFF32CD32),
        calendarHighPriorityDot: nebulaPurple,
        
        // Status badge colors - Space mission states
        statusPendingBadge: asteroidGray,
        statusInProgressBadge: nebulaPurple,
        statusCompletedBadge: Color(0xFF32CD32),
        statusCancelledBadge: stardustGray,
        statusOverdueBadge: Color(0xFFFF4500),
        statusOnHoldBadge: galaxyPurple,

        // Interactive colors - Cosmic responses
        hover: Color(0x4D9370DB),    // nebulaPurple with 0.3 alpha
        pressed: Color(0x804682B4),  // cosmicBlue with 0.5 alpha
        focus: solarGold,
        disabled: Color(0xFF1A1A2E),
      );
    }
    
    // ☀️ Light Mode - "Stellar Observatory": Bright nebula with cosmic accents
    const nebulaWhite = Color(0xFFF8F8FF);           // Nebula white background
    const stellarBlue = Color(0xFFE6F3FF);           // Stellar blue surface
    const cosmicSilver = Color(0xFFD3D3D3);          // Cosmic silver
    const deepCosmic = Color(0xFF191970);            // Deep cosmic (for contrast)
    const darkNebula = Color(0xFF6A5ACD);            // Dark nebula purple
    const spaceBlue = Color(0xFF4682B4);             // Space blue
    const charcoalText = Color(0xFF2F2F2F);          // Charcoal text
    const stellarGray = Color(0xFF708090);           // Stellar gray
    const galaxyGold = Color(0xFFFFD700);            // Galaxy gold
    const quantumBlue = Color(0xFF008B8B);           // Quantum blue
    
    return const ThemeColors(
      // Primary colors - Deep Cosmic on light backgrounds
      primary: deepCosmic,
      onPrimary: nebulaWhite,
      primaryContainer: stellarBlue,
      onPrimaryContainer: charcoalText,
      
      // Secondary colors - Dark Nebula beauty
      secondary: darkNebula,
      onSecondary: nebulaWhite,
      secondaryContainer: Color(0xFFE6E6FA),
      onSecondaryContainer: Color(0xFF4B0082),
      
      // Tertiary colors - Space Blue exploration
      tertiary: spaceBlue,
      onTertiary: nebulaWhite,
      tertiaryContainer: Color(0xFFE0F6FF),
      onTertiaryContainer: Color(0xFF2F4F4F),
      
      // Surface colors - Observatory materials
      surface: stellarBlue,
      onSurface: charcoalText,
      surfaceVariant: Color(0xFFF0F8FF),
      onSurfaceVariant: stellarGray,
      inverseSurface: charcoalText,
      onInverseSurface: nebulaWhite,
      
      // Background colors - Stellar observatory
      background: nebulaWhite,
      onBackground: charcoalText,
      
      // Error colors - Solar warning
      error: Color(0xFFDC2626),
      onError: nebulaWhite,
      errorContainer: Color(0xFFFEF2F2),
      onErrorContainer: Color(0xFF991B1B),
      
      // Special colors - Light cosmic essence
      accent: darkNebula,
      highlight: galaxyGold,
      shadow: Color(0xFF000000),
      outline: cosmicSilver,
      outlineVariant: Color(0xFFE8E8E8),
      
      // Task priority colors - Light cosmic energy
      taskLowPriority: quantumBlue,
      taskMediumPriority: spaceBlue,
      taskHighPriority: darkNebula,
      taskUrgentPriority: Color(0xFFFF8C00),
      
      // Status colors - Light stellar states
      success: Color(0xFF22C55E),
      warning: Color(0xFFF59E0B),
      info: spaceBlue,
      
      // Calendar dot colors - Light cosmic calendar
      calendarTodayDot: deepCosmic,
      calendarOverdueDot: Color(0xFFDC2626),
      calendarFutureDot: spaceBlue,
      calendarCompletedDot: Color(0xFF22C55E),
      calendarHighPriorityDot: darkNebula,
      
      // Status badge colors - Light mission states
      statusPendingBadge: stellarGray,
      statusInProgressBadge: darkNebula,
      statusCompletedBadge: Color(0xFF22C55E),
      statusCancelledBadge: cosmicSilver,
      statusOverdueBadge: Color(0xFFDC2626),
      statusOnHoldBadge: Color(0xFF8B5CF6),
      
      // Interactive colors - Light cosmic responses
      hover: Color(0x336A5ACD),    // darkNebula with 0.2 alpha
      pressed: Color(0x664682B4),  // spaceBlue with 0.4 alpha
      focus: galaxyGold,
      disabled: cosmicSilver,
    );
  }

  /// Create cosmic exploration typography using Space Mono font
  static ThemeTypography _createCosmicTypography({bool isDark = true}) {
    final colors = _CosmicColorsHelper(isDark: isDark);
    const fontFamily = 'Space Mono';
    
    return ThemeTypography(
      fontFamily: fontFamily,
      displayFontFamily: fontFamily,
      monospaceFontFamily: fontFamily,
      baseSize: TypographyConstants.bodyLarge,
      scaleRatio: 1.0,
      baseFontWeight: FontWeight.w400, // Regular space weight
      baseLetterSpacing: TypographyConstants.wideLetterSpacing * 0.8, // Slightly wider for space feel
      baseLineHeight: TypographyConstants.normalLineHeight,
      
      // Display styles - Cosmic exploration headers
      displayLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.wideLetterSpacing * 0.9,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      displayMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayMedium,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.wideLetterSpacing * 0.9,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      displaySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displaySmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Headline styles - Space mission headers
      headlineLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      headlineMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineMedium,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      headlineSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineSmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Title styles - Stellar navigation
      titleLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      titleMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleMedium,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.1,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      titleSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.1,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Body styles - Space communication
      bodyLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.9,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      bodyMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyMedium,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.9,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      bodySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.9,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Label styles - Space station labels
      labelLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelLarge,
        fontWeight: FontWeight.w700, // Bold for visibility in space
        letterSpacing: TypographyConstants.wideLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      labelMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelMedium,
        fontWeight: FontWeight.w700,
        letterSpacing: TypographyConstants.wideLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      labelSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelSmall,
        fontWeight: FontWeight.w700,
        letterSpacing: TypographyConstants.wideLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Custom app styles - Space exploration precision
      taskTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskTitle,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.1,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      taskDescription: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskDescription,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.9,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      taskMeta: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskMeta,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.9,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      cardTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.1,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      cardSubtitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.9,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      buttonText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.buttonText,
        fontWeight: FontWeight.w700,
        letterSpacing: TypographyConstants.wideLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      inputText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.inputText,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.9,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      appBarTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.appBarTitle,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.1,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      navigationLabel: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.navigationLabel,
        fontWeight: FontWeight.w700,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
    );
  }

  /// Create cosmic exploration animations with star particle effects
  static ThemeAnimations _createCosmicAnimations() {
    return ThemeAnimations.fromThemeStyle(ThemeAnimationStyle.smooth).copyWith(
      // Steady, cosmic timing like celestial motion
      fast: const Duration(milliseconds: 200),
      medium: const Duration(milliseconds: 400),
      slow: const Duration(milliseconds: 700),
      verySlow: const Duration(milliseconds: 1000),
      
      // Smooth, orbital curves
      primaryCurve: Curves.easeInOutSine,       // Smooth like planetary motion
      secondaryCurve: Curves.easeOutQuart,      // Gentle deceleration
      entranceCurve: Curves.easeOutCubic,       // Smooth emergence from void
      exitCurve: Curves.easeInCubic,            // Smooth return to space
      
      // Stellar particle system
      enableParticles: true,
      particleConfig: const ParticleConfig(
        density: ParticleDensity.medium,         // Star field density
        speed: ParticleSpeed.slow,               // Slowly drifting stars
        style: ParticleStyle.organic,            // Organic star shapes
        enableGlow: true,                        // Twinkling star glow
        opacity: 0.7,                            // Bright starlight
        size: 0.9,                               // Small twinkling stars
      ),
    );
  }

  /// Create cosmic visual effects
  static theme_effects.ThemeEffects _createCosmicEffects() {
    return theme_effects.ThemeEffects.fromEffectStyle(theme_effects.ThemeEffectStyle.elegant).copyWith(
      shadowStyle: theme_effects.ShadowStyle.soft,         // Soft cosmic shadows
      gradientStyle: theme_effects.GradientStyle.subtle,   // Subtle nebula gradients
      borderStyle: theme_effects.BorderStyle.rounded,      // Smooth celestial shapes
      
      blurConfig: const theme_effects.BlurConfig(
        enabled: true,
        intensity: 1.8,                          // Cosmic atmospheric blur
        style: theme_effects.BlurStyle.normal,
      ),
      
      glowConfig: const theme_effects.GlowConfig(
        enabled: true,
        intensity: 0.6,                          // Stellar glow
        spread: 12.0,                            // Wide stellar glow radius
        style: theme_effects.GlowStyle.outer,
      ),
      
      backgroundEffects: const theme_effects.BackgroundEffectConfig(
        enableParticles: true,                   // Floating star particles
        enableGradientMesh: true,                // Nebula gradient mesh
        enableScanlines: false,                  // No digital elements in space
        particleType: theme_effects.BackgroundParticleType.floating, // Floating stars
        particleOpacity: 0.5,                    // Stellar particle visibility
        effectIntensity: 0.6,                    // Moderate cosmic effects
        geometricPattern: theme_effects.BackgroundGeometricPattern.radial, // Cosmic symmetry
        patternAngle: 0.0, // Centered like a star
        patternDensity: 1.1, // Stellar density
        accentColors: [
          Color(0x1A3F51B5), // Deep space blue at 0.1 alpha
          Color(0x149C27B0), // Cosmic purple at 0.08 alpha
        ],
      ),
    );
  }

  /// Create cosmic spacing with astronomical proportions
  static app_theme_data.ThemeSpacing _createCosmicSpacing() {
    const cosmicRatio = 1.618; // Golden ratio for cosmic harmony
    const baseUnit = 8.0;
    
    return app_theme_data.ThemeSpacing.fromBaseUnit(baseUnit).copyWith(
      cardPadding: baseUnit * cosmicRatio * 1.4,     // ~18.1 → Spacious cosmic padding
      screenPadding: baseUnit * cosmicRatio * 2.2,   // ~28.4 → Wide cosmic margins
      buttonPadding: baseUnit * cosmicRatio * 1.1,   // ~14.2 → Generous button padding
      inputPadding: baseUnit * cosmicRatio * 0.9,    // ~11.7 → Comfortable input padding
    );
  }

  /// Create cosmic components with stellar aesthetics
  static app_theme_data.ThemeComponents _createCosmicComponents() {
    return const app_theme_data.ThemeComponents(
      appBar: app_theme_data.AppBarConfig(
        elevation: 2.0,                          // Floating in space
        centerTitle: true,                       // Centered cosmic balance
        toolbarHeight: kToolbarHeight,
      ),
      
      card: app_theme_data.CardConfig(
        elevation: 2.0,                          // Gentle stellar elevation
        borderRadius: 16.0,                      // Smooth cosmic curves
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: EdgeInsets.all(20.0),          // Spacious cosmic padding
      ),
      
      button: app_theme_data.ButtonConfig(
        borderRadius: 12.0,                      // Smooth stellar curves
        padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
        elevation: 2.0,                          // Stellar button elevation
        height: 52.0,                            // Comfortable space interaction
        style: app_theme_data.ButtonStyle.filled,
      ),
      
      input: app_theme_data.InputConfig(
        borderRadius: 12.0,                      // Smooth cosmic input
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        borderStyle: app_theme_data.InputBorderStyle.outline,
        filled: true,
      ),
      
      fab: app_theme_data.FABConfig(
        shape: app_theme_data.FABShape.circular, // Perfect stellar orb
        elevation: 4.0,                          // Floating in space
        width: null,
        height: null,
      ),
      
      navigation: app_theme_data.NavigationConfig(
        type: app_theme_data.NavigationType.bottomNav,
        elevation: 6.0,                          // Above cosmic surface
        showLabels: true,
      ),
      
      taskCard: app_theme_data.TaskCardConfig(
        borderRadius: 14.0,                      // Stellar task curves
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: EdgeInsets.all(18.0),          // Spacious stellar space
        elevation: 1.0,                          // Gentle cosmic float
        showPriorityStripe: true,                // Cosmic energy indicators
        enableSwipeActions: true,                // Smooth space interactions
      ),
    );
  }
}

/// Helper class for accessing cosmic colors in static context
class _CosmicColorsHelper {
  final bool isDark;
  const _CosmicColorsHelper({this.isDark = true});
  
  Color get onBackground => isDark 
    ? const Color(0xFFF0F8FF)   // Stellar white
    : const Color(0xFF2F2F2F);  // Charcoal text
    
  Color get primary => isDark 
    ? const Color(0xFFF0F8FF)   // Stellar white
    : const Color(0xFF191970);  // Deep space navy
    
  Color get nebulaPurple => isDark 
    ? const Color(0xFF9370DB)   // Full nebula purple
    : const Color(0xFF6A5ACD);  // Dark nebula
}