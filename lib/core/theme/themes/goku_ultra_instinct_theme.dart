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
        primaryPreviewColor: isDark ? const Color(0xFF1A0D26) : const Color(0xFFFFFFFF), // Purple void or heavenly white
        secondaryPreviewColor: const Color(0xFFC0C0C0), // Ultra Instinct Silver
        tertiaryPreviewColor: isDark ? const Color(0xFFFF8844) : const Color(0xFFDD5500), // Goku Orange signature accent
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
      // Dark Mode - "Cosmic Mastery": Super bright, maximum saturation divine energy
      const purpleVoid = Color(0xFF0F0520);           // Ultra-deep purple cosmic void
      const enhancedUltraSilver = Color(0xFFDDDDDD);  // Enhanced Ultra Instinct silver (brighter)
      const enhancedEtherealGlow = Color(0xFFFFFFFF); // Pure white ethereal glow
      const enhancedVibrantOrange = Color(0xFFFF7733); // Enhanced vibrant orange gi (brighter)
      const pureWhite = Color(0xFFFFFFFF);            // Pure white text
      const enhancedSilverMist = Color(0xFFEEEEEE);   // Enhanced silver mist (brighter)
      const purpleShadow = Color(0xFF1A0A2A);         // Deeper purple shadows
      const enhancedDivineBlue = Color(0xFFCCEEFF);   // Enhanced divine blue (brighter)
      const darkPurple = Color(0xFF2A1F3A);           // Enhanced dark purple material
      
      // Goku Orange Signature Accent - Maximum visibility orange energy
      const gokuOrangeSignature = Color(0xFFFF8844);         // Super bright signature orange
      const onGokuOrangeSignature = Color(0xFF000000);       // Pure black for maximum contrast
      const gokuOrangeContainer = Color(0xFF442211);         // Deep orange container
      const onGokuOrangeContainer = Color(0xFFFFFFFF);       // Pure white for container text
      
      return const ThemeColors(
        // Primary colors - Enhanced Ultra Instinct Silver
        primary: enhancedUltraSilver,
        onPrimary: Color(0xFF000000), // Pure black for maximum contrast
        primaryContainer: darkPurple,
        onPrimaryContainer: Color(0xFFFFFFFF), // Pure white for container text

        // Secondary colors - Enhanced Orange Gi Energy
        secondary: enhancedVibrantOrange,
        onSecondary: Color(0xFF000000), // Pure black for maximum contrast
        secondaryContainer: Color(0xFF553311), // Enhanced brown container
        onSecondaryContainer: Color(0xFFFFFFFF), // Pure white for container text

        // Tertiary colors - Enhanced Orange Gi Accents
        tertiary: enhancedVibrantOrange,
        onTertiary: Color(0xFF000000), // Pure black for maximum contrast
        tertiaryContainer: Color(0xFF553311), // Enhanced brown container
        onTertiaryContainer: Color(0xFFFFFFFF), // Pure white for container text

        // Surface colors - Enhanced cosmic materials
        surface: purpleShadow,
        onSurface: pureWhite, // Pure white text
        surfaceVariant: darkPurple,
        onSurfaceVariant: enhancedSilverMist, // Enhanced silver text
        inverseSurface: pureWhite,
        onInverseSurface: purpleVoid,

        // Background colors - Enhanced deep cosmic void
        background: purpleVoid,
        onBackground: pureWhite, // Pure white text

        // Error colors - Enhanced controlled destruction energy
        error: Color(0xFFFF5555), // Enhanced error red
        onError: Color(0xFF000000), // Pure black for maximum contrast
        errorContainer: Color(0xFF440A0A), // Enhanced red container
        onErrorContainer: Color(0xFFFFFFFF), // Pure white for container text

        // Special colors - Enhanced with signature accent
        accent: gokuOrangeSignature, // Use signature orange as primary accent
        highlight: enhancedVibrantOrange,
        shadow: Color(0xFF000000),
        outline: Color(0xFF666666), // Enhanced outline
        outlineVariant: darkPurple,

        // Goku Orange Signature Colors
        gokuOrange: gokuOrangeSignature,
        onGokuOrange: onGokuOrangeSignature,
        gokuOrangeContainer: gokuOrangeContainer,
        onGokuOrangeContainer: onGokuOrangeContainer,

        // Task priority colors - Enhanced divine power levels with signature
        taskLowPriority: Color(0xAABBEE90), // Enhanced light green
        taskMediumPriority: enhancedUltraSilver, // Enhanced Ultra Instinct silver
        taskHighPriority: gokuOrangeSignature, // Signature orange - High priority
        taskUrgentPriority: Color(0xFFFF5555), // Enhanced controlled power

        // Status colors - Enhanced divine states
        success: Color(0xAABBEE90), // Enhanced success green
        warning: enhancedVibrantOrange,
        info: enhancedDivineBlue,

        // Calendar dot colors - Enhanced Ultra Instinct System
        calendarTodayDot: enhancedEtherealGlow,
        calendarOverdueDot: Color(0xFFFF5555),
        calendarFutureDot: enhancedSilverMist,
        calendarCompletedDot: Color(0xAABBEE90),
        calendarHighPriorityDot: gokuOrangeSignature, // Signature orange for high priority
        
        // Status badge colors - Enhanced with signature orange
        statusPendingBadge: enhancedEtherealGlow,
        statusInProgressBadge: enhancedVibrantOrange,
        statusCompletedBadge: gokuOrangeSignature, // Signature orange for completed (achievement)
        statusCancelledBadge: darkPurple,
        statusOverdueBadge: Color(0xFFFF5555),
        statusOnHoldBadge: enhancedSilverMist,

        // Interactive colors - Enhanced divine responses
        hover: Color(0x66FF7733), // Enhanced orange hover
        pressed: Color(0xCCFF7733), // Enhanced orange pressed
        focus: gokuOrangeSignature, // Use signature orange for focus
        disabled: Color(0xFF444444), // Enhanced disabled
      );
    }
    
    // Light Mode - "Divine Awakening": Deep contrasting colors for maximum readability
    const heavenlyWhite = Color(0xFFFFFFFF);        // Pure white background
    const deepSilver = Color(0xFF556677);           // Deeper silver for better contrast
    const softGlow = Color(0xFFE0E8F0);             // Light ethereal glow
    const deepVibrantOrange = Color(0xFFDD5500);    // Deeper orange gi for better contrast
    const deepCharcoalText = Color(0xFF1A1A1A);     // Deep charcoal text for maximum readability
    
    // Goku Orange Signature Accent - Deep for light mode contrast
    const deepGokuOrangeSignature = Color(0xFFDD5500);        // Deep signature orange
    const onDeepGokuOrangeSignature = Color(0xFFFFFFFF);      // White text on deep orange
    const deepGokuOrangeContainer = Color(0xFFFFE5CC);        // Light orange container
    const onDeepGokuOrangeContainer = Color(0xFF441100);      // Deep orange container text
    const lightSilver = Color(0xFFF5F5F5);          // Light silver surface
    // const silverHighlight = Color(0xFFD3D3D3);      // Silver highlights (reserved for future use)
    // const paleBlue = Color(0xFFF0F8FF);             // Pale divine blue (reserved for future use)
    const lightGray = Color(0xFFF8F8F8);            // Light gray materials
    // const divineBlue = Color(0xFFB0E0E6);           // Soft divine blue accent (reserved for future use)
    
    return const ThemeColors(
      // Primary colors - Enhanced deep silver for better contrast
      primary: deepSilver,
      onPrimary: heavenlyWhite,
      primaryContainer: softGlow,
      onPrimaryContainer: Color(0xFF333344), // Deeper container text
      
      // Secondary colors - Enhanced deep orange gi
      secondary: deepVibrantOrange,
      onSecondary: heavenlyWhite,
      secondaryContainer: Color(0xFFFFF0DC),
      onSecondaryContainer: Color(0xFF663311), // Deeper container text
      
      // Tertiary colors - Enhanced deep orange
      tertiary: deepVibrantOrange,
      onTertiary: heavenlyWhite,
      tertiaryContainer: Color(0xFFFFF0DC),
      onTertiaryContainer: Color(0xFF663311), // Deeper container text
      
      // Surface colors - Enhanced contrast light materials
      surface: lightSilver,
      onSurface: deepCharcoalText, // Deep text for maximum readability
      surfaceVariant: lightGray,
      onSurfaceVariant: Color(0xFF333333), // Deeper variant text
      inverseSurface: deepCharcoalText,
      onInverseSurface: heavenlyWhite,
      
      // Background colors - Enhanced contrast heavenly realm
      background: heavenlyWhite, // Pure white for maximum contrast
      onBackground: deepCharcoalText, // Deep text for maximum readability
      
      // Error colors - Enhanced controlled power
      error: Color(0xFFBB1111), // Deeper error red
      onError: heavenlyWhite,
      errorContainer: Color(0xFFFEF0F0),
      onErrorContainer: Color(0xFF660000), // Deeper error container text
      
      // Special colors - Enhanced with signature accent
      accent: deepGokuOrangeSignature, // Use signature orange as primary accent
      highlight: deepVibrantOrange,
      shadow: Color(0xFF000000),
      outline: Color(0xFF888888), // Deeper outline for better visibility
      outlineVariant: Color(0xFFCCCCCC),
      
      // Goku Orange Signature Colors
      gokuOrange: deepGokuOrangeSignature,
      onGokuOrange: onDeepGokuOrangeSignature,
      gokuOrangeContainer: deepGokuOrangeContainer,
      onGokuOrangeContainer: onDeepGokuOrangeContainer,
      
      // Task priority colors - Enhanced with signature accent
      taskLowPriority: Color(0xFF118844), // Deeper success green
      taskMediumPriority: deepSilver,
      taskHighPriority: deepGokuOrangeSignature, // Signature orange - High priority
      taskUrgentPriority: Color(0xFFBB1111), // Deeper urgent red
      
      // Status colors - Enhanced light divine states
      success: Color(0xFF118844), // Deeper success green
      warning: deepVibrantOrange,
      info: Color(0xFF6699CC), // Deeper divine blue
      
      // Calendar dot colors - Enhanced light divine system
      calendarTodayDot: deepVibrantOrange,
      calendarOverdueDot: Color(0xFFBB1111),
      calendarFutureDot: deepSilver,
      calendarCompletedDot: Color(0xFF118844),
      calendarHighPriorityDot: deepGokuOrangeSignature, // Signature orange for high priority
      
      // Status badge colors - Enhanced with signature orange
      statusPendingBadge: deepSilver,
      statusInProgressBadge: deepVibrantOrange,
      statusCompletedBadge: deepGokuOrangeSignature, // Signature orange for completed (achievement)
      statusCancelledBadge: Color(0xFF888888),
      statusOverdueBadge: Color(0xFFBB1111),
      statusOnHoldBadge: Color(0xFFCC8800),
      
      // Interactive colors - Enhanced light divine responses
      hover: Color(0x60DD5500), // Deeper orange hover
      pressed: Color(0x99DD5500), // Deeper orange pressed
      focus: deepGokuOrangeSignature, // Use signature orange for focus
      disabled: Color(0xFFBBBBBB), // Enhanced disabled
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