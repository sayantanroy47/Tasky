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

/// 🦄 Unicorn Dream Theme - "Magical Rainbow"
/// A whimsical, magical theme with vibrant rainbow colors and enchanting effects
/// Dark Mode: "Midnight Magic" - Deep purples with rainbow accents and sparkle effects
/// Light Mode: "Rainbow Dreams" - Bright pastels with vibrant rainbow highlights
class UnicornDreamTheme {
  static app_theme_data.AppThemeData create({bool isDark = true}) {
    final now = DateTime.now();
    
    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'unicorn_dream_dark' : 'unicorn_dream_light',
        name: isDark ? 'Unicorn Dream Dark' : 'Unicorn Dream Light',
        description: isDark 
          ? 'Midnight Magic theme featuring deep purples, rainbow accents, sparkle effects, and enchanting magical atmosphere'
          : 'Rainbow Dreams theme with bright pastels, vibrant rainbow highlights, magical sparkles, and whimsical unicorn aesthetics',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['magical', 'rainbow', 'unicorn', 'whimsical', 'colorful', 'fantasy', 'sparkle', 'dreamy'],
        category: 'fantasy',
        previewIcon: PhosphorIcons.sparkle(),
        primaryPreviewColor: const Color(0xFF9C27B0), // Magical purple
        secondaryPreviewColor: const Color(0xFFE91E63), // Pink magic
        createdAt: now,
        isPremium: false,
        popularityScore: 8.9, // High fantasy appeal
      ),
      
      colors: _createUnicornColors(isDark: isDark),
      typography: _createUnicornTypography(isDark: isDark),
      animations: _createUnicornAnimations(),
      effects: _createUnicornEffects(isDark: isDark),
      spacing: _createUnicornSpacing(),
      components: _createUnicornComponents(),
    );
  }

  /// Create light variant - Rainbow Dreams
  static app_theme_data.AppThemeData createLight() => create(isDark: false);
  
  /// Create dark variant - Midnight Magic
  static app_theme_data.AppThemeData createDark() => create(isDark: true);

  static ThemeColors _createUnicornColors({required bool isDark}) {
    if (isDark) {
      return const ThemeColors(
        // Midnight Magic - Deep magical colors
        primary: Color(0xFF7B1FA2), // Deep magical purple
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFF4A148C),
        onPrimaryContainer: Color(0xFFF3E5F5),
        
        secondary: Color(0xFFC2185B), // Deep magical pink
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFF880E4F),
        onSecondaryContainer: Color(0xFFFCE4EC),
        
        tertiary: Color(0xFF3F51B5), // Deep magical blue
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFF1A237E),
        onTertiaryContainer: Color(0xFFE8EAF6),
        
        error: Color(0xFFE91E63), // Magical error pink
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFF880E4F),
        onErrorContainer: Color(0xFFFCE4EC),
        
        surface: Color(0xFF1A0E2E), // Deep magical night
        onSurface: Color(0xFFf8f8f2),
        surfaceVariant: Color(0xFF2E1B4C), // Dark magical mist
        onSurfaceVariant: Color(0xFFf8f8f2),
        
        background: Color(0xFF1A0E2E), // Magical night sky
        onBackground: Color(0xFFf8f8f2),
        
        outline: Color(0xFF9C27B0),
        outlineVariant: Color(0xFF4A148C),
        shadow: Color(0xFF000000),
        inverseSurface: Color(0xFFF3E5F5),
        onInverseSurface: Color(0xFF2E1B4C),
        
        // Additional required colors
        accent: Color(0xFFFFEB3B), // Magical gold accent
        highlight: Color(0xFF3F51B5), // Magical blue highlight  
        
        // Task priority colors
        taskLowPriority: Color(0xFF66BB6A), // Magical green
        taskMediumPriority: Color(0xFFFFEB3B), // Magical gold
        taskHighPriority: Color(0xFFFF9800), // Magical orange
        taskUrgentPriority: Color(0xFFE91E63), // Magical pink
        
        // Status colors
        success: Color(0xFF66BB6A), // Magical green
        warning: Color(0xFFFF9800), // Magical orange
        info: Color(0xFF3F51B5), // Magical blue
        
        // Calendar dot colors - magical theme
        calendarTodayDot: Color(0xFF7B1FA2), // Magical purple
        calendarCompletedDot: Color(0xFF66BB6A), // Magical green
        calendarOverdueDot: Color(0xFFE91E63), // Magical pink
        calendarHighPriorityDot: Color(0xFFFFEB3B), // Magical gold
        calendarFutureDot: Color(0xFF3F51B5), // Magical blue
        
        // Status badge colors
        statusPendingBadge: Color(0xFFFFEB3B), // Magical gold
        statusInProgressBadge: Color(0xFF3F51B5), // Magical blue
        statusCompletedBadge: Color(0xFF66BB6A), // Magical green
        statusCancelledBadge: Color(0xFF4A148C), // Muted purple
        statusOverdueBadge: Color(0xFFE91E63), // Magical pink
        statusOnHoldBadge: Color(0xFFFF9800), // Magical orange
        
        // Interactive colors
        hover: Color(0x147B1FA2), // Primary with alpha
        pressed: Color(0x1F7B1FA2), // Primary with alpha
        focus: Color(0xFF7B1FA2), // Primary color for focus
        disabled: Color(0xFF4A148C)
      );
    } else {
      return const ThemeColors(
        // Rainbow Dreams - Bright magical colors
        primary: Color(0xFF9C27B0), // Magical purple
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFF3E5F5),
        onPrimaryContainer: Color(0xFF3E064D),
        
        secondary: Color(0xFFE91E63), // Magical pink
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFFCE4EC),
        onSecondaryContainer: Color(0xFF3E001F),
        
        tertiary: Color(0xFF3F51B5), // Magical blue
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFFE8EAF6),
        onTertiaryContainer: Color(0xFF1A1F71),
        
        error: Color(0xFFE91E63), // Magical error pink
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFFCE4EC),
        onErrorContainer: Color(0xFF3E001F),
        
        surface: Color(0xFFFFF8FC), // Magical cloud white
        onSurface: Color(0xFF2d2d2d),
        surfaceVariant: Color(0xFFF3E5F5), // Magical mist
        onSurfaceVariant: Color(0xFF2d2d2d),
        
        background: Color(0xFFFFF8FC), // Magical sky
        onBackground: Color(0xFF2d2d2d),
        
        outline: Color(0xFF9C27B0),
        outlineVariant: Color(0xFFD1C4E9),
        shadow: Color(0xFF000000),
        inverseSurface: Color(0xFF2E1B4C),
        onInverseSurface: Color(0xFFF3E5F5),
        
        // Additional required colors
        accent: Color(0xFFFFEB3B), // Magical gold accent
        highlight: Color(0xFF3F51B5), // Magical blue highlight
        
        // Task priority colors
        taskLowPriority: Color(0xFF66BB6A), // Magical green
        taskMediumPriority: Color(0xFFFFEB3B), // Magical gold
        taskHighPriority: Color(0xFFFF9800), // Magical orange
        taskUrgentPriority: Color(0xFFE91E63), // Magical pink
        
        // Status colors
        success: Color(0xFF66BB6A), // Magical green
        warning: Color(0xFFFF9800), // Magical orange
        info: Color(0xFF3F51B5), // Magical blue
        
        // Calendar dot colors - magical theme
        calendarTodayDot: Color(0xFF9C27B0), // Magical purple
        calendarCompletedDot: Color(0xFF66BB6A), // Magical green
        calendarOverdueDot: Color(0xFFE91E63), // Magical pink
        calendarHighPriorityDot: Color(0xFFFFEB3B), // Magical gold
        calendarFutureDot: Color(0xFF3F51B5), // Magical blue
        
        // Status badge colors
        statusPendingBadge: Color(0xFFFFEB3B), // Magical gold
        statusInProgressBadge: Color(0xFF3F51B5), // Magical blue
        statusCompletedBadge: Color(0xFF66BB6A), // Magical green
        statusCancelledBadge: Color(0xFFD1C4E9), // Muted purple
        statusOverdueBadge: Color(0xFFE91E63), // Magical pink
        statusOnHoldBadge: Color(0xFFFF9800), // Magical orange
        
        // Interactive colors
        hover: Color(0x149C27B0), // Primary with alpha
        pressed: Color(0x1F9C27B0), // Primary with alpha
        focus: Color(0xFF9C27B0), // Primary color for focus
        disabled: Color(0xFFD1C4E9)
      );
    }
  }

  static ThemeTypography _createUnicornTypography({required bool isDark}) {
    const fontFamily = 'Quicksand'; // Whimsical, rounded font
    final colors = _UnicornColorsHelper(isDark: isDark);
    
    return ThemeTypography(
      fontFamily: fontFamily,
      
      // Display styles - Magical presence
      displayLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayLarge,
        fontWeight: TypographyConstants.light,
        letterSpacing: TypographyConstants.tightLetterSpacing,
        height: TypographyConstants.tightLineHeight,
        color: colors.primary,
      ),
      displayMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayMedium,
        fontWeight: TypographyConstants.light,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.primary,
      ),
      displaySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displaySmall,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      
      // Headline styles - Magical headers
      headlineLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineLarge,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.primary,
      ),
      headlineMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineMedium,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      headlineSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineSmall,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      
      // Title styles - Whimsical emphasis
      titleLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleLarge,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      titleMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleMedium,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      titleSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurfaceVariant,
      ),
      
      // Body styles - Dreamy content
      bodyLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyLarge,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onSurface,
      ),
      bodyMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyMedium,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      bodySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.relaxedLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurfaceVariant,
      ),
      
      // Label styles - Magical UI elements
      labelLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelLarge,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.primary,
      ),
      labelMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelMedium,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.relaxedLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      labelSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelSmall,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.relaxedLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurfaceVariant,
      ),
      
      // Task-specific styles
      taskTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskTitle,
        fontWeight: TypographyConstants.medium,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      taskDescription: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskDescription,
        fontWeight: TypographyConstants.regular,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onSurfaceVariant,
      ),
      
      // Additional required typography styles
      taskMeta: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelSmall,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurfaceVariant,
      ),
      cardTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      cardSubtitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurfaceVariant,
      ),
      buttonText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelLarge,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      inputText: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyMedium,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      appBarTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleLarge,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
      navigationLabel: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelMedium,
        fontWeight: TypographyConstants.smallTextWeight,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.normalLineHeight,
        color: colors.onSurface,
      ),
    );
  }

  static ThemeAnimations _createUnicornAnimations() {
    return const ThemeAnimations(
      fast: Duration(milliseconds: 100), // Sparkle animation
      medium: Duration(milliseconds: 300), // Standard magical transitions
      slow: Duration(milliseconds: 500), // Gentle shimmer
      verySlow: Duration(milliseconds: 800), // Dramatic unicorn effects
      
      primaryCurve: Curves.easeInOutCubic, // Smooth magical transitions
      secondaryCurve: Curves.easeInOut, // Standard transitions
      entranceCurve: Curves.easeOut, // Gentle entrance
      exitCurve: Curves.easeIn, // Gentle exit
    );
  }

  static theme_effects.ThemeEffects _createUnicornEffects({required bool isDark}) {
    return theme_effects.ThemeEffects(
      shadowStyle: theme_effects.ShadowStyle.dramatic, // Magical dramatic shadows
      gradientStyle: theme_effects.GradientStyle.subtle, // Colorful gradients
      borderStyle: theme_effects.BorderStyle.rounded, // Soft magical edges
      blurConfig: const theme_effects.BlurConfig(
        enabled: true,
        style: theme_effects.BlurStyle.outer, // Magical glow effect
        intensity: 0.4, // Medium intensity
      ),
      glowConfig: theme_effects.GlowConfig(
        enabled: true,
        intensity: isDark ? 0.9 : 0.6, // More intense glow in dark mode for midnight magic
        spread: isDark ? 8.0 : 4.0, // Wider spread in dark mode
        style: theme_effects.GlowStyle.outer, // Outer glow
      ),
      backgroundEffects: theme_effects.BackgroundEffectConfig(
        enableParticles: true, // Magical sparkles
        enableGradientMesh: true, // Magical gradients
        enableScanlines: false, // Keep it clean
        particleType: theme_effects.BackgroundParticleType.floating, // Floating sparkles
        particleOpacity: isDark ? 0.9 : 0.5, // Higher opacity for midnight magic sparkles
        effectIntensity: isDark ? 1.4 : 0.8, // More intense effects for dark magical atmosphere
        geometricPattern: theme_effects.BackgroundGeometricPattern.mesh, // Magical precision
        patternAngle: 30.0, // Magical angle for sparkle distribution
        patternDensity: 1.1, // Fine magical density
        accentColors: [
          (isDark ? const Color(0xFF7B1FA2) : const Color(0xFF9C27B0)).withValues(alpha: 0.12), // Magical purple
          (isDark ? const Color(0xFFFFEB3B) : const Color(0xFFFFC107)).withValues(alpha: 0.08), // Magical gold
        ],
      ),
    );
  }

  static app_theme_data.ThemeSpacing _createUnicornSpacing() {
    return const app_theme_data.ThemeSpacing(
      extraSmall: 4.0, // Magical compact spacing
      small: 8.0, // Small magical spacing
      medium: 16.0, // Standard magical spacing
      large: 24.0, // Generous magical spacing
      extraLarge: 32.0, // Dramatic magical spacing
      cardPadding: 20.0, // Magical card padding
      screenPadding: 24.0, // Magical screen padding
      buttonPadding: 20.0, // Magical button padding
      inputPadding: 16.0, // Magical input padding
    );
  }

  static app_theme_data.ThemeComponents _createUnicornComponents() {
    return const app_theme_data.ThemeComponents(
      appBar: app_theme_data.AppBarConfig(
        elevation: 2.0, // Magical floating app bar
        centerTitle: true, // Centered magical titles
        toolbarHeight: 64.0, // Spacious magical toolbar
      ),
      card: app_theme_data.CardConfig(
        elevation: 12.0, // Magical floating elevation
        borderRadius: TypographyConstants.radiusMedium, // Rounded magical edges
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Magical spacing
        padding: EdgeInsets.all(20.0), // Generous magical padding
      ),
      button: app_theme_data.ButtonConfig(
        borderRadius: TypographyConstants.radiusMedium, // Rounded magical buttons
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0), // Magical padding
        elevation: 4.0, // Subtle magical elevation
        height: 48.0, // Standard magical height
      ),
      input: app_theme_data.InputConfig(
        borderRadius: TypographyConstants.radiusMedium, // Rounded magical inputs
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Magical padding
        borderStyle: app_theme_data.InputBorderStyle.outline,
        filled: true, // Magical filled inputs
      ),
      fab: app_theme_data.FABConfig(
        shape: app_theme_data.FABShape.circular, // Fully rounded magical FAB
        elevation: 8.0, // Higher magical elevation
      ),
      navigation: app_theme_data.NavigationConfig(
        type: app_theme_data.NavigationType.bottomNav,
        elevation: 8.0, // Magical navigation elevation
        showLabels: true, // Show magical navigation labels
      ),
      taskCard: app_theme_data.TaskCardConfig(
        borderRadius: TypographyConstants.radiusSmall, // Rounded magical task cards
        elevation: 6.0, // Floating magical task cards
        padding: EdgeInsets.all(16.0), // Magical task card padding
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Magical spacing
        showPriorityStripe: true, // Show magical priority indicators
        enableSwipeActions: true, // Enable magical swipe actions
      ),
    );
  }
}

/// Helper class for accessing unicorn colors in static context
class _UnicornColorsHelper {
  final bool isDark;
  
  const _UnicornColorsHelper({required this.isDark});
  
  Color get primary => isDark ? const Color(0xFF7B1FA2) : const Color(0xFF9C27B0);
  Color get onSurface => isDark ? const Color(0xFFf8f8f2) : const Color(0xFF2d2d2d);
  Color get onSurfaceVariant => isDark ? const Color(0xFFf8f8f2) : const Color(0xFF2d2d2d);
}