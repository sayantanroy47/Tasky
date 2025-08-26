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

/// Goku Ultra Instinct Theme - "Mastered Ultra Instinct"
/// A serene, powerful theme inspired by Goku's Ultra Instinct form
/// Features ethereal silver/white colors, divine glow effects, and Goku's orange gi
class GokuUltraInstinctTheme {
  static app_theme_data.AppThemeData create({bool isDark = false}) {
    final now = DateTime.now();
    
    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'goku_ultra_instinct_dark' : 'goku_ultra_instinct',
        name: isDark ? 'Goku Ultra Instinct Dark' : 'Goku Ultra Instinct Light',
        description: isDark 
          ? 'Mastered Ultra Instinct theme with cosmic void background, ethereal silver aura, and divine power aesthetics'
          : 'Ultra Instinct light theme featuring heavenly realm aesthetics with silver divine energy and warm orange accents',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['anime', 'ultra-instinct', 'silver', 'orange', 'divine', 'mastery', 'goku'],
        category: 'gaming',
        previewIcon: PhosphorIcons.sparkle(),
        primaryPreviewColor: const Color(0xFFC0C0C0), // Ultra Instinct Silver
        secondaryPreviewColor: const Color(0xFFFF8C00), // Goku's Orange Gi
        createdAt: now,
        isPremium: false,
        popularityScore: 9.2,
      ),
      
      colors: _createGokuColors(isDark: isDark),
      typography: _createGokuTypography(isDark: isDark),
      animations: _createGokuAnimations(),
      effects: _createGokuEffects(),
      spacing: _createGokuSpacing(),
      components: _createGokuComponents(),
    );
  }

  /// Create light variant
  static app_theme_data.AppThemeData createLight() => create(isDark: false);
  
  /// Create dark variant
  static app_theme_data.AppThemeData createDark() => create(isDark: true);

  /// Create Goku Ultra Instinct color palette
  static ThemeColors _createGokuColors({bool isDark = false}) {
    if (isDark) {
      // Dark Mode - "Cosmic Mastery": Purple void with ethereal silver energy
      const purpleVoid = Color(0xFF1A0D26);           // Purple-tinted cosmic void
      const ultraSilver = Color(0xFFC0C0C0);          // Ultra Instinct silver hair
      const etherealGlow = Color(0xFFF0F8FF);         // Ethereal aura glow
      const vibrantOrange = Color(0xFFFF6600);        // Vibrant orange gi
      const pureWhite = Color(0xFFFFFFFF);            // Pure white text
      const silverMist = Color(0xFFE8E8E8);           // Silver mist effects
      const purpleShadow = Color(0xFF2D1B3D);         // Purple-tinted shadows
      const divineBlue = Color(0xFFB0E0E6);           // Soft divine blue accent
      const darkPurple = Color(0xFF3D2A4F);           // Dark purple material
      
      return const ThemeColors(
        // Primary colors - Ultra Instinct Silver
        primary: ultraSilver,
        onPrimary: purpleVoid,
        primaryContainer: darkPurple,
        onPrimaryContainer: etherealGlow,

        // Secondary colors - Orange Gi Energy
        secondary: vibrantOrange,
        onSecondary: purpleVoid,
        secondaryContainer: Color(0xFF8B4513),
        onSecondaryContainer: etherealGlow,

        // Tertiary colors - Orange Gi Accents
        tertiary: vibrantOrange,
        onTertiary: purpleVoid,
        tertiaryContainer: Color(0xFF8B4513),
        onTertiaryContainer: pureWhite,

        // Surface colors - Cosmic Materials
        surface: purpleShadow,
        onSurface: pureWhite,
        surfaceVariant: darkPurple,
        onSurfaceVariant: silverMist,
        inverseSurface: pureWhite,
        onInverseSurface: purpleVoid,

        // Background colors - Deep Cosmic Void
        background: purpleVoid,
        onBackground: pureWhite,

        // Error colors - Controlled destruction energy
        error: Color(0xFFFF4444),
        onError: pureWhite,
        errorContainer: Color(0xFF2A0A0A),
        onErrorContainer: Color(0xFFFF8888),

        // Special colors - Ultra Instinct Energy System
        accent: vibrantOrange,
        highlight: vibrantOrange,
        shadow: Color(0xFF000000),
        outline: silverMist,
        outlineVariant: darkPurple,

        // Task priority colors - Divine Power Levels
        taskLowPriority: Color(0xFF90EE90),      // Light green
        taskMediumPriority: ultraSilver,         // Ultra Instinct silver
        taskHighPriority: vibrantOrange,         // Vibrant orange gi
        taskUrgentPriority: Color(0xFFFF4444),   // Controlled power

        // Status colors - Divine States
        success: Color(0xFF90EE90),
        warning: vibrantOrange,
        info: divineBlue,

        // Calendar dot colors - Ultra Instinct System
        calendarTodayDot: etherealGlow,
        calendarOverdueDot: Color(0xFFFF4444),
        calendarFutureDot: silverMist,
        calendarCompletedDot: Color(0xFF90EE90),
        calendarHighPriorityDot: vibrantOrange,
        
        // Status badge colors - Divine Power States
        statusPendingBadge: etherealGlow,
        statusInProgressBadge: vibrantOrange,
        statusCompletedBadge: Color(0xFF90EE90),
        statusCancelledBadge: darkPurple,
        statusOverdueBadge: Color(0xFFFF4444),
        statusOnHoldBadge: silverMist,

        // Interactive colors - Divine Responses
        hover: Color(0x4DFF6600),  // vibrantOrange with 0.3 alpha
        pressed: Color(0xB3FF6600),  // vibrantOrange with 0.7 alpha
        focus: vibrantOrange,
        disabled: Color(0xFF333333),
      );
    }
    
    // Light Mode - "Divine Awakening": Heavenly realm with warm energy
    const heavenlyWhite = Color(0xFFFFFFFF);        // Pure white background
    const deepSilver = Color(0xFF708090);           // Deep silver for contrast
    const softGlow = Color(0xFFE6F3FF);             // Soft ethereal glow
    const vibrantOrange = Color(0xFFFF6600);        // Vibrant orange gi
    const charcoalText = Color(0xFF2F4F4F);         // Dark charcoal text
    const lightSilver = Color(0xFFF5F5F5);          // Light silver surface
    const silverHighlight = Color(0xFFD3D3D3);      // Silver highlights
    const paleBlue = Color(0xFFF0F8FF);             // Pale divine blue
    const lightGray = Color(0xFFF8F8F8);            // Light gray materials
    const divineBlue = Color(0xFFB0E0E6);           // Soft divine blue accent
    
    return const ThemeColors(
      // Primary colors - Deep Silver (Light)
      primary: deepSilver,
      onPrimary: heavenlyWhite,
      primaryContainer: softGlow,
      onPrimaryContainer: deepSilver,
      
      // Secondary colors - Orange Gi (Light)
      secondary: vibrantOrange,
      onSecondary: heavenlyWhite,
      secondaryContainer: Color(0xFFFFF8DC),
      onSecondaryContainer: Color(0xFF8B4513),
      
      // Tertiary colors - Warm Orange (Light)
      tertiary: vibrantOrange,
      onTertiary: heavenlyWhite,
      tertiaryContainer: Color(0xFFFFF8DC),
      onTertiaryContainer: Color(0xFF8B4513),
      
      // Surface colors - Light Materials
      surface: lightSilver,
      onSurface: charcoalText,
      surfaceVariant: lightGray,
      onSurfaceVariant: Color(0xFF4A4A4A),
      inverseSurface: charcoalText,
      onInverseSurface: heavenlyWhite,
      
      // Background colors - Heavenly Realm
      background: paleBlue,                         // Pale divine blue background
      onBackground: charcoalText,
      
      // Error colors - Controlled power (light variant)
      error: Color(0xFFDC2626),
      onError: heavenlyWhite,
      errorContainer: Color(0xFFFEF2F2),
      onErrorContainer: Color(0xFF991B1B),
      
      // Special colors - Light Divine System
      accent: vibrantOrange,
      highlight: vibrantOrange,
      shadow: Color(0xFF000000),
      outline: Color(0xFFBBBBBB),
      outlineVariant: Color(0xFFDDDDDD),
      
      // Task priority colors - Light Divine System
      taskLowPriority: Color(0xFF22C55E),
      taskMediumPriority: deepSilver,
      taskHighPriority: vibrantOrange,
      taskUrgentPriority: Color(0xFFDC2626),
      
      // Status colors - Light Divine States
      success: Color(0xFF22C55E),
      warning: vibrantOrange,
      info: divineBlue,                            // Divine blue info
      
      // Calendar dot colors - Light Divine System
      calendarTodayDot: vibrantOrange,
      calendarOverdueDot: Color(0xFFDC2626),
      calendarFutureDot: silverHighlight,
      calendarCompletedDot: Color(0xFF22C55E),
      calendarHighPriorityDot: vibrantOrange,
      
      // Status badge colors - Light Divine States
      statusPendingBadge: Color(0xB3FF6600),  // vibrantOrange with 0.7 alpha
      statusInProgressBadge: vibrantOrange,
      statusCompletedBadge: Color(0xFF22C55E),
      statusCancelledBadge: Color(0xFF9CA3AF),
      statusOverdueBadge: Color(0xFFDC2626),
      statusOnHoldBadge: Color(0xFFEAB308),
      
      // Interactive colors - Light Divine Responses
      hover: Color(0x33FF6600),  // vibrantOrange with 0.2 alpha
      pressed: Color(0x80FF6600),  // vibrantOrange with 0.5 alpha
      focus: vibrantOrange,
      disabled: Color(0xFFE5E5E5),
    );
  }

  /// Create Ultra Instinct-inspired typography using Sansation font
  static ThemeTypography _createGokuTypography({bool isDark = true}) {
    final colors = _GokuColorsHelper(isDark: isDark);
    const fontFamily = 'Sansation';
    
    return ThemeTypography(
      fontFamily: fontFamily,
      displayFontFamily: fontFamily,
      monospaceFontFamily: fontFamily,
      baseSize: TypographyConstants.bodyLarge,
      scaleRatio: 1.0,
      baseFontWeight: FontWeight.w500,
      baseLetterSpacing: TypographyConstants.normalLetterSpacing,
      baseLineHeight: TypographyConstants.normalLineHeight,
      
      // Display styles - Divine power
      displayLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      displayMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayMedium,
        fontWeight: FontWeight.w700,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      displaySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displaySmall,
        fontWeight: FontWeight.w600,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Headline styles - Mastered control
      headlineLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      headlineMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      headlineSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineSmall,
        fontWeight: FontWeight.w600,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Title styles - Serene strength
      titleLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      titleMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      titleSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Body styles - Balanced flow
      bodyLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyLarge,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      bodyMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyMedium,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      bodySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Label styles - UI mastery
      labelLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      labelMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelMedium,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      labelSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelSmall,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Custom app styles - Ultra Instinct precision
      taskTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskTitle,
        fontWeight: FontWeight.w600,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      taskDescription: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskDescription,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      taskMeta: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskMeta,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      cardTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: FontWeight.w600,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      cardSubtitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      buttonText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.buttonText,
        fontWeight: FontWeight.w600,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      inputText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.inputText,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      appBarTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.appBarTitle,
        fontWeight: FontWeight.w600,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      navigationLabel: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.navigationLabel,
        fontWeight: FontWeight.w500,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
    );
  }

  /// Create serene, flowing animations
  static ThemeAnimations _createGokuAnimations() {
    return ThemeAnimations.fromThemeStyle(ThemeAnimationStyle.smooth).copyWith(
      // Serene, controlled animations
      fast: const Duration(milliseconds: 200),
      medium: const Duration(milliseconds: 400),
      slow: const Duration(milliseconds: 600),
      verySlow: const Duration(milliseconds: 800),
      
      // Smooth, flowing curves
      primaryCurve: Curves.easeInOutSine,
      secondaryCurve: Curves.easeOut,
      entranceCurve: Curves.easeOutCubic,
      exitCurve: Curves.easeInCubic,
      
      // Ethereal floating particles
      enableParticles: true,
      particleConfig: const ParticleConfig(
        density: ParticleDensity.low,
        speed: ParticleSpeed.slow,
        style: ParticleStyle.organic,
        enableGlow: true,
        opacity: 0.3,
        size: 0.8,
      ),
    );
  }

  /// Create ethereal visual effects
  static theme_effects.ThemeEffects _createGokuEffects() {
    return theme_effects.ThemeEffects.fromEffectStyle(theme_effects.ThemeEffectStyle.elegant).copyWith(
      shadowStyle: theme_effects.ShadowStyle.soft,
      gradientStyle: theme_effects.GradientStyle.subtle,
      borderStyle: theme_effects.BorderStyle.rounded,
      
      blurConfig: const theme_effects.BlurConfig(
        enabled: true,
        intensity: 1.5,
        style: theme_effects.BlurStyle.normal,
      ),
      
      glowConfig: const theme_effects.GlowConfig(
        enabled: true,
        intensity: 0.4,
        spread: 8.0,
        style: theme_effects.GlowStyle.outer,
      ),
      
      backgroundEffects: const theme_effects.BackgroundEffectConfig(
        enableParticles: true,
        enableGradientMesh: true,
        enableScanlines: false,
        particleType: theme_effects.BackgroundParticleType.floating,
        particleOpacity: 0.08,
        effectIntensity: 0.3,
        geometricPattern: theme_effects.BackgroundGeometricPattern.radial,
        patternAngle: 0.0,
        patternDensity: 0.8,
        accentColors: [
          Color(0x1AC0C0C0), // Ultra Instinct silver at 0.1 alpha
          Color(0x0DFF6600), // Vibrant orange gi at 0.05 alpha
        ],
      ),
    );
  }

  /// Create balanced, harmonious spacing
  static app_theme_data.ThemeSpacing _createGokuSpacing() {
    return app_theme_data.ThemeSpacing.fromBaseUnit(8.0).copyWith(
      cardPadding: 18.0,     // Slightly more spacious
      screenPadding: 20.0,   // Comfortable padding
      buttonPadding: 18.0,   // Balanced button padding
      inputPadding: 16.0,    // Generous input padding
    );
  }

  /// Create smooth, rounded components
  static app_theme_data.ThemeComponents _createGokuComponents() {
    return const app_theme_data.ThemeComponents(
      appBar: app_theme_data.AppBarConfig(
        elevation: 0.0,        // Clean, flat design
        centerTitle: true,
        toolbarHeight: kToolbarHeight,
      ),
      
      card: app_theme_data.CardConfig(
        elevation: 1.0,        // Subtle elevation
        borderRadius: 12.0,    // Smooth rounded corners
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        padding: EdgeInsets.all(18.0),
      ),
      
      button: app_theme_data.ButtonConfig(
        borderRadius: 12.0,    // Smooth corners
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        elevation: 1.0,        // Subtle elevation
        height: 50.0,          // Comfortable height
        style: app_theme_data.ButtonStyle.filled,
      ),
      
      input: app_theme_data.InputConfig(
        borderRadius: 12.0,    // Smooth corners
        contentPadding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
        borderStyle: app_theme_data.InputBorderStyle.outline,
        filled: true,
      ),
      
      fab: app_theme_data.FABConfig(
        shape: app_theme_data.FABShape.circular,
        elevation: 2.0,        // Gentle elevation
        width: null,
        height: null,
      ),
      
      navigation: app_theme_data.NavigationConfig(
        type: app_theme_data.NavigationType.bottomNav,
        elevation: 4.0,        // Soft elevation
        showLabels: true,
      ),
      
      taskCard: app_theme_data.TaskCardConfig(
        borderRadius: 10.0,    // Smooth corners
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
        padding: EdgeInsets.all(18.0),
        elevation: 0.5,        // Very subtle elevation
        showPriorityStripe: true,
        enableSwipeActions: true,
      ),
    );
  }
}

/// Helper class for accessing colors in static context
class _GokuColorsHelper {
  final bool isDark;
  const _GokuColorsHelper({this.isDark = true});
  
  Color get onBackground => isDark ? const Color(0xFFF8F8FF) : const Color(0xFF2F4F4F); // Silver-tinted white for Goku Ultra Instinct theme
  Color get primary => isDark ? const Color(0xFFC0C0C0) : const Color(0xFF708090);
  Color get secondary => isDark ? const Color(0xFFF0F8FF) : const Color(0xFF4682B4);
}