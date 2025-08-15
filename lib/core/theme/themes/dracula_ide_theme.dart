import 'package:flutter/material.dart';
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
          ? 'The beloved developer theme with sophisticated dark purple backgrounds and vibrant syntax highlighting colors'
          : 'Light variant of the Dracula IDE theme with subtle purple tints and vibrant accents',
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

  /// Helper method to reduce color brightness by 25%
  static Color _reduceBrightness(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness * factor).clamp(0.0, 1.0)).toColor();
  }

  /// Create Dracula-inspired color palette
  static ThemeColors _createDraculaColors({bool isDark = true}) {
    if (!isDark) {
      // Light variant: Use dark theme colors reduced by 25% brightness + light backgrounds
      
      // Get dark theme colors first
      const darkDraculaPink = Color(0xFFff79c6);          // Dark theme primary
      const darkDraculaPurple = Color(0xFFbd93f9);        // Dark theme secondary  
      const darkDraculaCyan = Color(0xFF8be9fd);          // Dark theme tertiary
      const darkDraculaGreen = Color(0xFF50fa7b);         // Dark theme success
      const darkDraculaOrange = Color(0xFFffb86c);        // Dark theme warning
      const darkDraculaRed = Color(0xFFff5555);           // Dark theme error
      const darkDraculaYellow = Color(0xFFf1fa8c);        // Dark theme highlight
      const darkDraculaComment = Color(0xFF6272a4);       // Dark theme comment
      
      // Reduce brightness by 25% (factor of 0.75)
      final lightPink = _reduceBrightness(darkDraculaPink, 0.75);
      final lightPurple = _reduceBrightness(darkDraculaPurple, 0.75);
      final lightCyan = _reduceBrightness(darkDraculaCyan, 0.75);
      final lightGreen = _reduceBrightness(darkDraculaGreen, 0.75);
      final lightOrange = _reduceBrightness(darkDraculaOrange, 0.75);
      final lightRed = _reduceBrightness(darkDraculaRed, 0.75);
      final lightYellow = _reduceBrightness(darkDraculaYellow, 0.75);
      final lightComment = _reduceBrightness(darkDraculaComment, 0.75);
      
      // Light backgrounds
      const pureWhite = Color(0xFFfafafa);        // Background - Softer white
      const lightSurface = Color(0xFFf5f5f5);     // Surface - Light gray
      const paleContainer = Color(0xFFede7f6);    // Container - Light purple tint
      
      return ThemeColors(
        // Primary colors - Reduced brightness from dark theme
        primary: lightPink,
        onPrimary: pureWhite,
        primaryContainer: paleContainer,
        onPrimaryContainer: lightPink,

        // Secondary colors - Reduced brightness from dark theme
        secondary: lightPurple,
        onSecondary: pureWhite,
        secondaryContainer: paleContainer,
        onSecondaryContainer: lightPurple,

        // Tertiary colors - Reduced brightness from dark theme
        tertiary: lightCyan,
        onTertiary: pureWhite,
        tertiaryContainer: paleContainer,
        onTertiaryContainer: lightCyan,

        // Surface colors - Light backgrounds
        surface: lightSurface,
        onSurface: const Color(0xFF1a1a1a), // Dark text for light surfaces
        surfaceVariant: const Color(0xFFf0f0f0),
        onSurfaceVariant: const Color(0xFF2a2a2a), // Dark text for light surfaces
        inverseSurface: lightPink,
        onInverseSurface: pureWhite,

        // Background colors - Light backgrounds
        background: pureWhite,
        onBackground: const Color(0xFF0a0a0a), // Very dark text for light backgrounds

        // Error colors - Reduced brightness
        error: lightRed,
        onError: pureWhite,
        errorContainer: const Color(0xFFfff5f5),
        onErrorContainer: lightRed,

        // Special colors
        accent: lightCyan,
        highlight: lightYellow,
        shadow: const Color(0xFF000000),
        outline: lightComment,
        outlineVariant: lightComment,

        // Task priority colors - Reduced brightness syntax colors
        taskLowPriority: lightGreen,     // Reduced green
        taskMediumPriority: lightCyan,   // Reduced cyan
        taskHighPriority: lightOrange,   // Reduced orange
        taskUrgentPriority: lightRed,    // Reduced red

        // Status colors - Reduced brightness
        success: lightGreen,
        warning: lightOrange,
        info: lightCyan,

        // Calendar dot colors - Dracula IDE theme (light) - reduced brightness
        calendarTodayDot: lightPink,                  // Reduced pink for today
        calendarOverdueDot: lightRed,                 // Reduced red for overdue
        calendarFutureDot: lightCyan,                 // Reduced cyan for future
        calendarCompletedDot: lightGreen,             // Reduced green for completed
        calendarHighPriorityDot: lightOrange,         // Reduced orange for high priority
        
        // Status badge colors - Dracula IDE themed (light) - reduced brightness
        statusPendingBadge: lightCyan,                // Reduced cyan for pending
        statusInProgressBadge: lightOrange,           // Reduced orange for in progress
        statusCompletedBadge: lightGreen,             // Reduced green for completed
        statusCancelledBadge: lightComment,           // Reduced comment color for cancelled
        statusOverdueBadge: lightRed,                 // Reduced red for overdue
        statusOnHoldBadge: lightYellow,               // Reduced yellow for on hold

        // Interactive colors - Reduced brightness
        hover: _reduceBrightness(const Color(0xFFf565a7), 0.75),
        pressed: _reduceBrightness(const Color(0xFFe84d96), 0.75),
        focus: lightYellow,
        disabled: lightComment,
      );
    }
    
    // Dark variant: Original Dracula colors
    const draculaBackground = Color(0xFF282a36);    // Dark purple background
    const draculaCurrentLine = Color(0xFF44475a);   // Lighter purple
    const draculaForeground = Color(0xFFf8f8f2);    // Light foreground
    const draculaComment = Color(0xFF6272a4);       // Blue-gray comments
    const draculaCyan = Color(0xFF8be9fd);          // Cyan
    const draculaGreen = Color(0xFF50fa7b);         // Green
    const draculaOrange = Color(0xFFffb86c);        // Orange
    const draculaPink = Color(0xFFff79c6);          // Pink - primary
    const draculaPurple = Color(0xFFbd93f9);        // Purple
    const draculaRed = Color(0xFFff5555);           // Red
    const draculaYellow = Color(0xFFf1fa8c);        // Yellow
    
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
      baseLetterSpacing: 0.2, // Slightly wider for JetBrains Mono readability
      baseLineHeight: 1.5, // More comfortable line height for code
      
      // Use EXACT typography constants for all sizes
      displayLarge: TypographyConstants.getStyle(
        fontSize: TypographyConstants.displayLarge,
        fontWeight: TypographyConstants.light,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      displayMedium: TypographyConstants.getStyle(
        fontSize: TypographyConstants.displayMedium,
        fontWeight: TypographyConstants.light,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      displaySmall: TypographyConstants.getStyle(
        fontSize: TypographyConstants.displaySmall,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      
      headlineLarge: TypographyConstants.getStyle(
        fontSize: TypographyConstants.headlineLarge,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      headlineMedium: TypographyConstants.getStyle(
        fontSize: TypographyConstants.headlineMedium,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      headlineSmall: TypographyConstants.getStyle(
        fontSize: TypographyConstants.headlineSmall,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      
      titleLarge: TypographyConstants.getStyle(
        fontSize: TypographyConstants.titleLarge,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      titleMedium: TypographyConstants.getStyle(
        fontSize: TypographyConstants.titleMedium,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      titleSmall: TypographyConstants.getStyle(
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      
      bodyLarge: TypographyConstants.getStyle(
        fontSize: TypographyConstants.bodyLarge,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      bodyMedium: TypographyConstants.getStyle(
        fontSize: TypographyConstants.bodyMedium,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      bodySmall: TypographyConstants.getStyle(
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      
      labelLarge: TypographyConstants.getStyle(
        fontSize: TypographyConstants.labelLarge,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      labelMedium: TypographyConstants.getStyle(
        fontSize: TypographyConstants.labelMedium,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      labelSmall: TypographyConstants.getStyle(
        fontSize: TypographyConstants.labelSmall,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      
      // Custom app styles with exact constants
      taskTitle: TypographyConstants.getStyle(
        fontSize: TypographyConstants.taskTitle,
        fontWeight: TypographyConstants.semiBold,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      taskDescription: TypographyConstants.getStyle(
        fontSize: TypographyConstants.taskDescription,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      taskMeta: TypographyConstants.getStyle(
        fontSize: TypographyConstants.taskMeta,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      cardTitle: TypographyConstants.getStyle(
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      cardSubtitle: TypographyConstants.getStyle(
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      buttonText: TypographyConstants.getStyle(
        fontSize: TypographyConstants.buttonText,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      inputText: TypographyConstants.getStyle(
        fontSize: TypographyConstants.inputText,
        fontWeight: TypographyConstants.regular,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      appBarTitle: TypographyConstants.getStyle(
        fontSize: TypographyConstants.appBarTitle,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
        color: colors.onBackground,
      ),
      navigationLabel: TypographyConstants.getStyle(
        fontSize: TypographyConstants.navigationLabel,
        fontWeight: TypographyConstants.medium,
        fontFamily: fontFamily,
        letterSpacing: 0.2,
        height: 1.5,
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