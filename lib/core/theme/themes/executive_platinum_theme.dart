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

/// 💼 Executive Platinum Theme - "Corporate Excellence"
/// A sophisticated business theme with premium platinum aesthetics
/// Dark Mode: "Executive Night" - Deep charcoal with platinum highlights and gold accents
/// Light Mode: "Corporate Platinum" - Clean whites with platinum grays and executive elegance
class ExecutivePlatinumTheme {
  static app_theme_data.AppThemeData create({bool isDark = true}) {
    final now = DateTime.now();
    
    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'executive_platinum_dark' : 'executive_platinum_light',
        name: isDark ? 'Executive Platinum Dark' : 'Executive Platinum Light',
        description: isDark 
          ? 'Executive Night theme featuring deep charcoal backgrounds, platinum highlights, gold accents, and sophisticated business aesthetics'
          : 'Corporate Platinum theme with clean whites, platinum grays, gold details, and premium executive elegance',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['business', 'executive', 'platinum', 'professional', 'premium', 'corporate', 'elegant', 'sophisticated'],
        category: 'business',
        previewIcon: PhosphorIcons.briefcase(),
        primaryPreviewColor: const Color(0xFF424242), // Platinum gray
        secondaryPreviewColor: const Color(0xFFFFB300), // Executive gold
        createdAt: now,
        isPremium: false,
        popularityScore: 9.2, // High business appeal
      ),
      
      colors: _createExecutiveColors(isDark: isDark),
      typography: _createExecutiveTypography(isDark: isDark),
      animations: _createExecutiveAnimations(),
      effects: _createExecutiveEffects(isDark: isDark),
      spacing: _createExecutiveSpacing(),
      components: _createExecutiveComponents(),
    );
  }

  /// Create light variant - Corporate Platinum
  static app_theme_data.AppThemeData createLight() => create(isDark: false);
  
  /// Create dark variant - Executive Night
  static app_theme_data.AppThemeData createDark() => create(isDark: true);

  static ThemeColors _createExecutiveColors({required bool isDark}) {
    if (isDark) {
      return const ThemeColors(
        // Executive Night - Deep sophisticated colors
        primary: Color(0xFF616161), // Platinum gray
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFF424242),
        onPrimaryContainer: Color(0xFFE0E0E0),
        
        secondary: Color(0xFFFFB300), // Executive gold
        onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0xFFFF8F00),
        onSecondaryContainer: Color(0xFFFFF3C4),
        
        tertiary: Color(0xFF37474F), // Executive steel
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFF263238),
        onTertiaryContainer: Color(0xFFCFD8DC),
        
        error: Color(0xFFE57373), // Executive red
        onError: Color(0xFF000000),
        errorContainer: Color(0xFFD32F2F),
        onErrorContainer: Color(0xFFFFEBEE),
        
        surface: Color(0xFF121212), // Executive black
        onSurface: Color(0xFFf8f8f2),
        surfaceVariant: Color(0xFF1E1E1E), // Dark platinum
        onSurfaceVariant: Color(0xFFf8f8f2),
        inverseSurface: Color(0xFFE0E0E0),
        onInverseSurface: Color(0xFF212121),
        
        background: Color(0xFF121212), // Executive office
        onBackground: Color(0xFFf8f8f2),
        
        outline: Color(0xFF757575),
        outlineVariant: Color(0xFF424242),
        shadow: Color(0xFF000000),
        
        // Additional required colors
        accent: Color(0xFFFFB300), // Executive gold accent
        highlight: Color(0xFFFFD54F), // Bright executive gold highlight
        disabled: Color(0xFF424242),
        focus: Color(0xFF616161), // Primary color for focus
        hover: Color(0xFF757575), // Light platinum hover
        pressed: Color(0xFF303030), // Darker platinum pressed
        
        // Task priority colors
        taskLowPriority: Color(0xFF66BB6A), // Green
        taskMediumPriority: Color(0xFFFFB300), // Gold
        taskHighPriority: Color(0xFFFF8F00), // Orange
        taskUrgentPriority: Color(0xFFE57373), // Red
        
        // Status colors
        success: Color(0xFF66BB6A), // Success green
        warning: Color(0xFFFFB300), // Warning gold
        info: Color(0xFF42A5F5), // Info blue
        
        // Calendar dot colors - executive theme
        calendarTodayDot: Color(0xFF616161), // Platinum
        calendarCompletedDot: Color(0xFF66BB6A), // Success green
        calendarOverdueDot: Color(0xFFE57373), // Executive red
        calendarHighPriorityDot: Color(0xFFFFB300), // Gold
        calendarFutureDot: Color(0xFF37474F), // Steel
        
        // Status badge colors
        statusPendingBadge: Color(0xFF90A4AE), // Gray
        statusInProgressBadge: Color(0xFF42A5F5), // Blue
        statusCompletedBadge: Color(0xFF66BB6A), // Green
        statusCancelledBadge: Color(0xFF757575), // Dark gray
        statusOverdueBadge: Color(0xFFE57373), // Red
        statusOnHoldBadge: Color(0xFFFFB300), // Gold
      );
    } else {
      return const ThemeColors(
        // Corporate Platinum - Clean professional colors
        primary: Color(0xFF424242), // Platinum gray
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFE0E0E0),
        onPrimaryContainer: Color(0xFF1C1C1C),
        
        secondary: Color(0xFFFFB300), // Executive gold
        onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0xFFFFF3C4),
        onSecondaryContainer: Color(0xFF3E2000),
        
        tertiary: Color(0xFF607D8B), // Executive steel blue
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFFCFD8DC),
        onTertiaryContainer: Color(0xFF102027),
        
        error: Color(0xFFD32F2F), // Executive red
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFFFEBEE),
        onErrorContainer: Color(0xFF2C0009),
        
        surface: Color(0xFFFAFAFA), // Executive white
        onSurface: Color(0xFF2d2d2d),
        surfaceVariant: Color(0xFFF5F5F5), // Light platinum
        onSurfaceVariant: Color(0xFF2d2d2d),
        inverseSurface: Color(0xFF212121),
        onInverseSurface: Color(0xFFF5F5F5),
        
        background: Color(0xFFFAFAFA), // Executive office
        onBackground: Color(0xFF2d2d2d),
        
        outline: Color(0xFF757575),
        outlineVariant: Color(0xFFBDBDBD),
        shadow: Color(0xFF000000),
        
        // Additional required colors
        accent: Color(0xFFFFB300), // Executive gold accent
        highlight: Color(0xFFFFC107), // Bright gold highlight
        disabled: Color(0xFFBDBDBD),
        focus: Color(0xFF424242), // Primary color for focus
        hover: Color(0xFFE0E0E0), // Light hover
        pressed: Color(0xFF9E9E9E), // Darker pressed
        
        // Task priority colors
        taskLowPriority: Color(0xFF4CAF50), // Green
        taskMediumPriority: Color(0xFFFFB300), // Gold
        taskHighPriority: Color(0xFFFF9800), // Orange
        taskUrgentPriority: Color(0xFFD32F2F), // Red
        
        // Status colors
        success: Color(0xFF4CAF50), // Success green
        warning: Color(0xFFFFB300), // Warning gold
        info: Color(0xFF2196F3), // Info blue
        
        // Calendar dot colors - executive theme
        calendarTodayDot: Color(0xFF424242), // Platinum
        calendarCompletedDot: Color(0xFF4CAF50), // Success green
        calendarOverdueDot: Color(0xFFD32F2F), // Executive red
        calendarHighPriorityDot: Color(0xFFFFB300), // Gold
        calendarFutureDot: Color(0xFF607D8B), // Steel blue
        
        // Status badge colors
        statusPendingBadge: Color(0xFF9E9E9E), // Gray
        statusInProgressBadge: Color(0xFF2196F3), // Blue
        statusCompletedBadge: Color(0xFF4CAF50), // Green
        statusCancelledBadge: Color(0xFF757575), // Dark gray
        statusOverdueBadge: Color(0xFFD32F2F), // Red
        statusOnHoldBadge: Color(0xFFFFB300), // Gold
      );
    }
  }

  static ThemeTypography _createExecutiveTypography({required bool isDark}) {
    const fontFamily = 'Roboto'; // Clean, professional font
    final colors = _ExecutiveColorsHelper(isDark: isDark);
    
    return ThemeTypography(
      fontFamily: fontFamily,
      displayFontFamily: fontFamily,
      monospaceFontFamily: fontFamily,
      baseSize: TypographyConstants.bodyLarge,
      scaleRatio: 1.0,
      baseFontWeight: TypographyConstants.regular,
      baseLetterSpacing: TypographyConstants.normalLetterSpacing,
      baseLineHeight: TypographyConstants.normalLineHeight,
      
      // Display styles - Executive presence
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
      
      // Headline styles - Executive headers
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
      
      // Title styles - Professional emphasis
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
      
      // Body styles - Business communication
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
      
      // Label styles - Professional UI elements
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

  static ThemeAnimations _createExecutiveAnimations() {
    return const ThemeAnimations(
      // Crisp, professional transitions
      fast: Duration(milliseconds: 150),
      medium: Duration(milliseconds: 300),
      slow: Duration(milliseconds: 500),
      verySlow: Duration(milliseconds: 800),
      
      // Professional curves
      primaryCurve: Curves.easeInOutCubic, // Confident decisions
      secondaryCurve: Curves.easeOutQuart, // Smooth presentations
      entranceCurve: Curves.easeOutCubic,
      exitCurve: Curves.easeInCubic,
      
      enableParticles: true,
      particleConfig: ParticleConfig(
        density: ParticleDensity.low,
        speed: ParticleSpeed.medium,
        style: ParticleStyle.geometric,
        enableGlow: false,
        opacity: 0.3,
        size: 1.0,
      ),
    );
  }

  static theme_effects.ThemeEffects _createExecutiveEffects({required bool isDark}) {
    return theme_effects.ThemeEffects(
      // Refined professional effects
      shadowStyle: theme_effects.ShadowStyle.soft,
      gradientStyle: theme_effects.GradientStyle.subtle,
      borderStyle: theme_effects.BorderStyle.rounded,
      
      blurConfig: const theme_effects.BlurConfig(
        enabled: true,
        intensity: 1.0,
        style: theme_effects.BlurStyle.outer,
      ),
      
      glowConfig: theme_effects.GlowConfig(
        enabled: isDark, // Only enable subtle glow in dark executive mode
        intensity: isDark ? 0.3 : 0.0, // Very subtle platinum glow for night mode
        spread: isDark ? 4.0 : 0.0, // Minimal spread for professional look
        style: theme_effects.GlowStyle.outer,
      ),
      
      backgroundEffects: theme_effects.BackgroundEffectConfig(
        enableParticles: true,
        enableGradientMesh: true,
        enableScanlines: false,
        particleType: theme_effects.BackgroundParticleType.floating,
        particleOpacity: isDark ? 0.15 : 0.03, // Minimal particles for clean professional look
        effectIntensity: isDark ? 0.4 : 0.1, // Subtle effects maintaining business elegance
        geometricPattern: theme_effects.BackgroundGeometricPattern.linear, // Clean professional precision
        patternAngle: 0.0, // Vertical precision
        patternDensity: 0.8, // Fine professional pattern
        accentColors: [
          (isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0)).withValues(alpha: 0.1), // Platinum accent
          (isDark ? const Color(0xFFFFB300) : const Color(0xFFFFC107)).withValues(alpha: 0.05), // Gold accent
        ],
      ),
    );
  }

  static app_theme_data.ThemeSpacing _createExecutiveSpacing() {
    return const app_theme_data.ThemeSpacing(
      extraSmall: TypographyConstants.spacingSmall / 2, // 4px
      small: TypographyConstants.spacingSmall, // 8px
      medium: TypographyConstants.spacingMedium, // 16px
      large: TypographyConstants.spacingLarge, // 24px
      extraLarge: TypographyConstants.spacingXLarge, // 32px
      cardPadding: 16.0, // Professional card spacing
      screenPadding: 16.0, // Professional screen margins
      buttonPadding: 16.0, // Professional button spacing
      inputPadding: 16.0, // Professional input spacing
    );
  }

  static app_theme_data.ThemeComponents _createExecutiveComponents() {
    return const app_theme_data.ThemeComponents(
      appBar: app_theme_data.AppBarConfig(
        elevation: 2.0, // Professional subtle elevation
        centerTitle: true, // Executive alignment
        toolbarHeight: kToolbarHeight,
      ),
      card: app_theme_data.CardConfig(
        elevation: 4.0, // Professional depth
        borderRadius: TypographyConstants.radiusSmall, // Clean edges
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: EdgeInsets.all(16.0),
      ),
      button: app_theme_data.ButtonConfig(
        borderRadius: TypographyConstants.radiusSmall,
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        elevation: 2.0,
        height: 48.0, // Standard professional interaction
        style: app_theme_data.ButtonStyle.elevated,
      ),
      input: app_theme_data.InputConfig(
        borderRadius: TypographyConstants.radiusSmall,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        borderStyle: app_theme_data.InputBorderStyle.outline,
        filled: false,
      ),
      fab: app_theme_data.FABConfig(
        shape: app_theme_data.FABShape.circular,
        elevation: 6.0,
      ),
      navigation: app_theme_data.NavigationConfig(
        type: app_theme_data.NavigationType.bottomNav,
        elevation: 8.0,
        showLabels: true,
      ),
      taskCard: app_theme_data.TaskCardConfig(
        borderRadius: TypographyConstants.radiusSmall,
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        padding: EdgeInsets.all(16.0),
        elevation: 2.0, // Professional subtle elevation
        showPriorityStripe: true, // Executive visual emphasis
        enableSwipeActions: true, // Professional productivity
      ),
    );
  }
}

/// Helper class for accessing executive colors in static context
class _ExecutiveColorsHelper {
  final bool isDark;
  
  const _ExecutiveColorsHelper({required this.isDark});
  
  Color get primary => isDark ? const Color(0xFF616161) : const Color(0xFF424242);
  Color get onSurface => isDark ? const Color(0xFFf8f8f2) : const Color(0xFF2d2d2d);
  Color get onSurfaceVariant => isDark ? const Color(0xFFf8f8f2) : const Color(0xFF2d2d2d);
}