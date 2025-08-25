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
      effects: _createUnicornEffects(),
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
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFFF3E5F5),
        onInverseSurface: Color(0xFF2E1B4C),
        inversePrimary: Color(0xFF9C27B0),
        
        // Additional required colors
        accent: Color(0xFFFFEB3B), // Magical gold accent
        disabled: Color(0xFF4A148C),
        focus: Color(0xFF7B1FA2), // Primary color for focus
        
        // Calendar dot colors - magical theme
        calendarTodayDot: Color(0xFF7B1FA2), // Magical purple
        calendarCompletedDot: Color(0xFF66BB6A), // Magical green
        calendarOverdueDot: Color(0xFFE91E63), // Magical pink
        calendarHighPriorityDot: Color(0xFFFFEB3B), // Magical gold
        calendarFutureDot: Color(0xFF3F51B5), // Magical blue
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
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFF2E1B4C),
        onInverseSurface: Color(0xFFF3E5F5),
        inversePrimary: Color(0xFFBA68C8),
        
        // Additional required colors
        accent: Color(0xFFFFEB3B), // Magical gold accent
        disabled: Color(0xFFD1C4E9),
        focus: Color(0xFF9C27B0), // Primary color for focus
        
        // Calendar dot colors - magical theme
        calendarTodayDot: Color(0xFF9C27B0), // Magical purple
        calendarCompletedDot: Color(0xFF66BB6A), // Magical green
        calendarOverdueDot: Color(0xFFE91E63), // Magical pink
        calendarHighPriorityDot: Color(0xFFFFEB3B), // Magical gold
        calendarFutureDot: Color(0xFF3F51B5), // Magical blue
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
    );
  }

  static ThemeAnimations _createUnicornAnimations() {
    return ThemeAnimations.fromThemeStyle(
      theme_effects.ThemeAnimationStyle.smooth, // Magical smooth transitions
      customCurves: {
        'magicalSparkle': Curves.elasticOut, // Sparkle animation
        'unicornGallop': Curves.bounceInOut, // Playful bouncing
        'rainbowShimmer': Curves.easeInOutSine, // Gentle shimmer
      },
    );
  }

  static theme_effects.ThemeEffects _createUnicornEffects() {
    return theme_effects.ThemeEffects.fromEffectStyle(
      theme_effects.ThemeEffectStyle.dramatic, // Magical dramatic effects
      backgroundEffect: theme_effects.BackgroundEffectConfig(
        enableParticles: true,
        enableGradientMesh: true,
        particleType: theme_effects.ParticleType.sparkle,
        particleCount: 25, // Lots of magical sparkles
        particleColors: [
          const Color(0xFF9C27B0), // Magical purple
          const Color(0xFFE91E63), // Magical pink
          const Color(0xFF3F51B5), // Magical blue
          const Color(0xFFFFEB3B), // Magical gold
          const Color(0xFF4CAF50), // Magical green
          const Color(0xFFFF9800), // Magical orange
          const Color(0xFFE91E63), // Magical red
        ],
        animationDuration: const Duration(seconds: 3), // Quick magical effects
        meshColors: [
          const Color(0xFF9C27B0).withOpacity(0.1), // Purple magic
          const Color(0xFFE91E63).withOpacity(0.1), // Pink magic
          const Color(0xFF3F51B5).withOpacity(0.1), // Blue magic
        ],
        intensity: 0.8, // High magical intensity
        speed: 1.2, // Fast magical movement
      ),
    );
  }

  static app_theme_data.ThemeSpacing _createUnicornSpacing() {
    return const app_theme_data.ThemeSpacing(
      xs: TypographyConstants.spacingSmall / 2, // 4px
      sm: TypographyConstants.spacingSmall, // 8px
      md: TypographyConstants.spacingMedium, // 16px
      lg: TypographyConstants.spacingLarge, // 24px
      xl: TypographyConstants.spacingXLarge, // 32px
    );
  }

  static app_theme_data.ThemeComponents _createUnicornComponents() {
    return const app_theme_data.ThemeComponents(
      cardElevation: 12.0, // Magical floating elevation
      borderRadius: TypographyConstants.radiusMedium, // Rounded magical edges
      buttonHeight: 48.0, // Whimsical interaction size
      inputHeight: 52.0, // Magical input size
      iconSize: 24.0, // Magical icons
      avatarSize: 40.0, // Magical profile size
      chipHeight: 36.0, // Magical chips
      tabHeight: 48.0, // Magical navigation
      listItemHeight: 64.0, // Spacious magical lists
      dividerThickness: 1.0, // Delicate dividers
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