import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme_data.dart' as app_theme_data;
import '../models/theme_metadata.dart';
import '../models/theme_colors.dart';
import '../models/theme_typography.dart';
import '../models/theme_animations.dart';
import '../models/theme_effects.dart' as theme_effects;
import '../typography_constants.dart';

/// Dracula IDE Theme - "Developer's Dream"
/// A sophisticated dark theme inspired by the popular Dracula color scheme
/// Features dark purple backgrounds, pink accents, and developer-friendly design
class DraculaIDETheme {
  static app_theme_data.AppThemeData create({bool isDark = true}) {
    final now = DateTime.now();
    
    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'dracula_ide_dark' : 'dracula_ide',
        name: isDark ? 'Dracula IDE Dark' : 'Dracula IDE Light',
        description: isDark 
          ? 'Refined Dracula IDE theme with moody purple backgrounds and bright neon-like highlights for modern readability'
          : 'Dracula IDE light variant maintaining playful vibrancy with refined tones for excellent UI usability',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['developer', 'ide', 'dark', 'purple', 'pink', 'elegant', 'syntax'],
        category: 'developer',
        previewIcon: Icons.code,
        primaryPreviewColor: isDark ? const Color(0xFF282a36) : const Color(0xFFf8f8f2), // Dark purple or light
        secondaryPreviewColor: const Color(0xFFff79c6), // Pink (same)
        createdAt: now,
        isPremium: false,
        popularityScore: 9.7,
      ),
      
      colors: _createDraculaColors(isDark: isDark),
      typography: _createDraculaTypography(isDark: isDark),
      animations: _createDraculaAnimations(),
      effects: _createDraculaEffects(),
      spacing: _createDraculaSpacing(),
      components: _createDraculaComponents(),
    );
  }

  /// Create light variant
  static app_theme_data.AppThemeData createLight() => create(isDark: false);
  
  /// Create dark variant (standard Dracula)
  static app_theme_data.AppThemeData createDark() => create(isDark: true);


  /// Create Dracula IDE-inspired color palette with refined usability
  static ThemeColors _createDraculaColors({bool isDark = true}) {
    if (!isDark) {
      // Dracula Light Variant: Refined & Usable
      
      // Dracula colors maintained at full vibrancy
      const darkDraculaPink = Color(0xFFFF79C6);          // Pink primary
      const darkDraculaPurple = Color(0xFFBD93F9);        // Purple secondary  
      const darkDraculaCyan = Color(0xFF8BE9FD);          // Bright cyan
      const darkDraculaGreen = Color(0xFF50FA7B);         // Vibrant green
      const darkDraculaOrange = Color(0xFFFFB86C);        // Warm orange
      const darkDraculaRed = Color(0xFFFF5555);           // Strong red
      const darkDraculaYellow = Color(0xFFF1FA8C);        // Yellow highlight
      const darkDraculaComment = Color(0xFF6B7280);       // Adjusted for readability on light bg
      
      // Light backgrounds and containers
      const pureWhite = Color(0xFFFFFFFF);                // Background
      const lightSurface = Color(0xFFF3F4F6);             // Soft gray surface
      const paleContainer = Color(0xFFEDE9FE);            // Light purple tint container
      const accentInk = Color(0xFF1E293B);                // Neutral text ink
      
      
      return const ThemeColors(
        // Primary colors - Dracula pink
        primary: darkDraculaPink,
        onPrimary: pureWhite,
        primaryContainer: paleContainer,
        onPrimaryContainer: darkDraculaPink,

        // Secondary colors - Dracula purple
        secondary: darkDraculaPurple,
        onSecondary: pureWhite,
        secondaryContainer: paleContainer,
        onSecondaryContainer: darkDraculaPurple,

        // Tertiary colors - Dracula cyan
        tertiary: darkDraculaCyan,
        onTertiary: pureWhite,
        tertiaryContainer: paleContainer,
        onTertiaryContainer: darkDraculaCyan,

        // Surface colors - Light backgrounds
        surface: lightSurface,
        onSurface: accentInk,
        surfaceVariant: lightSurface,
        onSurfaceVariant: accentInk,
        inverseSurface: darkDraculaPink,
        onInverseSurface: pureWhite,

        // Background colors - Light backgrounds
        background: pureWhite,
        onBackground: accentInk,

        // Error colors - Dracula red
        error: darkDraculaRed,
        onError: pureWhite,
        errorContainer: paleContainer,
        onErrorContainer: darkDraculaRed,

        // Special colors
        accent: darkDraculaCyan,
        highlight: darkDraculaYellow,
        shadow: Color(0xFF000000),
        outline: darkDraculaComment,
        outlineVariant: darkDraculaComment,

        // Task priority colors - Dracula syntax colors
        taskLowPriority: darkDraculaGreen,
        taskMediumPriority: darkDraculaCyan,
        taskHighPriority: darkDraculaOrange,
        taskUrgentPriority: darkDraculaRed,

        // Status colors
        success: darkDraculaGreen,
        warning: darkDraculaOrange,
        info: darkDraculaCyan,

        // Calendar dot colors - Dracula IDE theme (light)
        calendarTodayDot: darkDraculaPink,
        calendarOverdueDot: darkDraculaRed,
        calendarFutureDot: darkDraculaCyan,
        calendarCompletedDot: darkDraculaGreen,
        calendarHighPriorityDot: darkDraculaOrange,
        
        // Status badge colors - Dracula IDE themed (light)
        statusPendingBadge: darkDraculaCyan,
        statusInProgressBadge: darkDraculaOrange,
        statusCompletedBadge: darkDraculaGreen,
        statusCancelledBadge: darkDraculaComment,
        statusOverdueBadge: darkDraculaRed,
        statusOnHoldBadge: darkDraculaYellow,

        // Interactive colors
        hover: Color(0xFFf565a7),
        pressed: Color(0xFFe84d96),
        focus: darkDraculaYellow,
        disabled: darkDraculaComment,
      );
    }
    
    // Dracula Dark Variant: Refined & Usable moody aesthetics
    const draculaBackground = Color(0xFF282A36);    // Dark purple background
    const draculaCurrentLine = Color(0xFF44475A);   // Lighter purple for contrast
    const draculaForeground = Color(0xFFF8F8F2);    // Foreground text
    const draculaComment = Color(0xFF6272A4);       // Subdued blue-gray comments
    const draculaCyan = Color(0xFF8BE9FD);          // Bright cyan
    const draculaGreen = Color(0xFF50FA7B);         // Vibrant green
    const draculaOrange = Color(0xFFFFB86C);        // Warm orange
    const draculaPink = Color(0xFFFF79C6);          // Pink primary
    const draculaPurple = Color(0xFFBD93F9);        // Purple secondary
    const draculaRed = Color(0xFFFF5555);           // Strong red
    const draculaYellow = Color(0xFFF1FA8C);        // Yellow highlight
    
    return const ThemeColors(
      // Primary colors - Dracula pink
      primary: draculaPink,
      onPrimary: draculaBackground,
      primaryContainer: Color(0xFF4a1a36),
      onPrimaryContainer: draculaPink,

      // Secondary colors - Dracula purple
      secondary: draculaPurple,
      onSecondary: draculaBackground,
      secondaryContainer: Color(0xFF3d2a4f),
      onSecondaryContainer: draculaPurple,

      // Tertiary colors - Dracula cyan
      tertiary: draculaCyan,
      onTertiary: draculaBackground,
      tertiaryContainer: Color(0xFF1a3a3f),
      onTertiaryContainer: draculaCyan,

      // Surface colors - Dracula current line
      surface: draculaCurrentLine,
      onSurface: draculaForeground,
      surfaceVariant: Color(0xFF3a3c4a),
      onSurfaceVariant: Color(0xFFc6c8d0),
      inverseSurface: draculaForeground,
      onInverseSurface: draculaBackground,

      // Background colors - Dracula background
      background: draculaBackground,
      onBackground: draculaForeground,

      // Error colors - Dracula red
      error: draculaRed,
      onError: draculaForeground,
      errorContainer: Color(0xFF4a1a1a),
      onErrorContainer: draculaRed,

      // Special colors
      accent: draculaCyan,
      highlight: draculaYellow,
      shadow: Color(0xFF000000),
      outline: draculaComment,
      outlineVariant: Color(0xFF4a4d5a),

      // Task priority colors - Dracula syntax colors
      taskLowPriority: draculaGreen,     // Green - Low priority
      taskMediumPriority: draculaCyan,   // Cyan - Medium priority
      taskHighPriority: draculaOrange,   // Orange - High priority
      taskUrgentPriority: draculaRed,    // Red - Urgent priority

      // Status colors
      success: draculaGreen,
      warning: draculaOrange,
      info: draculaCyan,

      // Calendar dot colors - Dracula IDE theme (dark)
      calendarTodayDot: draculaPink,                  // Pink for today
      calendarOverdueDot: draculaRed,                 // Red for overdue
      calendarFutureDot: draculaCyan,                 // Cyan for future
      calendarCompletedDot: draculaGreen,             // Green for completed
      calendarHighPriorityDot: draculaOrange,         // Orange for high priority
      
      // Status badge colors - Dracula IDE themed (dark)
      statusPendingBadge: draculaCyan,                // Cyan for pending
      statusInProgressBadge: draculaOrange,           // Orange for in progress
      statusCompletedBadge: draculaGreen,             // Green for completed
      statusCancelledBadge: draculaComment,           // Comment color for cancelled
      statusOverdueBadge: draculaRed,                 // Red for overdue
      statusOnHoldBadge: draculaYellow,               // Yellow for on hold

      // Interactive colors
      hover: Color(0xFFf565a7),
      pressed: Color(0xFFe84d96),
      focus: draculaYellow,
      disabled: draculaComment,
    );
  }

  /// Create Dracula-inspired typography using JetBrains Mono
  static ThemeTypography _createDraculaTypography({bool isDark = true}) {
    final colors = _DraculaColorsHelper(isDark: isDark);
    const fontFamily = 'JetBrains Mono';
    
    return ThemeTypography(
      fontFamily: fontFamily,
      displayFontFamily: fontFamily,
      monospaceFontFamily: fontFamily,
      baseSize: TypographyConstants.bodyLarge,
      scaleRatio: 1.0, // No scaling - use exact constants
      baseFontWeight: TypographyConstants.regular,
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
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      headlineMedium: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineMedium,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      headlineSmall: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineSmall,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      titleLarge: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleLarge,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      titleMedium: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleMedium,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      titleSmall: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      bodyLarge: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyLarge,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      bodyMedium: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyMedium,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      bodySmall: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      labelLarge: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelLarge,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      labelMedium: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelMedium,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      labelSmall: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelSmall,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Custom app styles with exact constants
      taskTitle: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskTitle,
        fontWeight: TypographyConstants.semiBold,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      taskDescription: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskDescription,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      taskMeta: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskMeta,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      cardTitle: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      cardSubtitle: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      buttonText: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.buttonText,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      inputText: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.inputText,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      appBarTitle: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.appBarTitle,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      navigationLabel: GoogleFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.navigationLabel,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
    );
  }

  /// Create smooth, professional animations
  static ThemeAnimations _createDraculaAnimations() {
    return ThemeAnimations.fromThemeStyle(ThemeAnimationStyle.smooth).copyWith(
      // Silky smooth, luxurious animations
      fast: const Duration(milliseconds: 150),
      medium: const Duration(milliseconds: 300),
      slow: const Duration(milliseconds: 500),
      verySlow: const Duration(milliseconds: 800),
      
      // Elegant, sophisticated curves
      primaryCurve: Curves.easeInOutCubic,
      secondaryCurve: Curves.decelerate,
      entranceCurve: Curves.easeOutBack,
      exitCurve: Curves.easeInQuart,
      
      // Sophisticated floating particles
      enableParticles: true,
      particleConfig: const ParticleConfig(
        density: ParticleDensity.medium,
        speed: ParticleSpeed.medium,
        style: ParticleStyle.organic,
        enableGlow: true,
        opacity: 0.4,
        size: 1.0,
      ),
    );
  }

  /// Create elegant visual effects
  static theme_effects.ThemeEffects _createDraculaEffects() {
    return theme_effects.ThemeEffects.fromEffectStyle(theme_effects.ThemeEffectStyle.elegant).copyWith(
      shadowStyle: theme_effects.ShadowStyle.soft,
      gradientStyle: theme_effects.GradientStyle.subtle,
      borderStyle: theme_effects.BorderStyle.rounded,
      
      blurConfig: const theme_effects.BlurConfig(
        enabled: true,
        intensity: 2.0,
        style: theme_effects.BlurStyle.normal,
      ),
      
      glowConfig: const theme_effects.GlowConfig(
        enabled: true,
        intensity: 0.6,
        spread: 10.0,
        style: theme_effects.GlowStyle.outer,
      ),
      
      backgroundEffects: const theme_effects.BackgroundEffectConfig(
        enableParticles: true,
        enableGradientMesh: true,
        enableScanlines: false,
        particleType: theme_effects.BackgroundParticleType.floating,
        particleOpacity: 0.12,
        effectIntensity: 0.5,
      ),
    );
  }

  /// Create comfortable, developer-friendly spacing
  static app_theme_data.ThemeSpacing _createDraculaSpacing() {
    return app_theme_data.ThemeSpacing.fromBaseUnit(8.0).copyWith(
      cardPadding: 16.0,     // Comfortable padding
      screenPadding: 16.0,   // Standard screen padding
      buttonPadding: 20.0,   // Comfortable button padding
      inputPadding: 14.0,    // Good input padding
    );
  }

  /// Create modern, rounded components
  static app_theme_data.ThemeComponents _createDraculaComponents() {
    return const app_theme_data.ThemeComponents(
      appBar: app_theme_data.AppBarConfig(
        elevation: 0.0,        // Modern flat design
        centerTitle: true,
        toolbarHeight: kToolbarHeight,
      ),
      
      card: app_theme_data.CardConfig(
        elevation: 2.0,        // Subtle elevation
        borderRadius: 5.0,    // Modern rounded corners
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: EdgeInsets.all(16.0),
      ),
      
      button: app_theme_data.ButtonConfig(
        borderRadius: 5.0,     // Rounded corners
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        elevation: 2.0,        // Subtle elevation
        height: 48.0,          // Comfortable height
        style: app_theme_data.ButtonStyle.filled,
      ),
      
      input: app_theme_data.InputConfig(
        borderRadius: 5.0,     // Rounded corners
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        borderStyle: app_theme_data.InputBorderStyle.outline,
        filled: true,          // Filled input style
      ),
      
      fab: app_theme_data.FABConfig(
        shape: app_theme_data.FABShape.circular, // Classic circular FAB
        elevation: 6.0,           // Standard elevation
        width: null,              // Default size
        height: null,
      ),
      
      navigation: app_theme_data.NavigationConfig(
        type: app_theme_data.NavigationType.bottomNav,
        elevation: 8.0,        // Standard elevation
        showLabels: true,
      ),
      
      taskCard: app_theme_data.TaskCardConfig(
        borderRadius: 5.0,    // Rounded corners
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        padding: EdgeInsets.all(16.0),
        elevation: 1.0,        // Subtle elevation
        showPriorityStripe: true,
        enableSwipeActions: true,
      ),
    );
  }
}

/// Helper class for accessing colors in static context
class _DraculaColorsHelper {
  final bool isDark;
  const _DraculaColorsHelper({this.isDark = true});
  
  Color get onBackground => isDark ? const Color(0xFFf8f8f2) : const Color(0xFF2d2d2d);
  Color get primary => const Color(0xFFff79c6);  // Pink in both variants
  Color get secondary => isDark ? const Color(0xFFbd93f9) : const Color(0xFF9d6fd9);
}