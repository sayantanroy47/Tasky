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

/// Hollow Knight Shadow Theme - "Ethereal Void"
/// A mysterious void-inspired theme with spectral effects and soul particles
/// Features deep shadow backgrounds, ethereal accents, and ghostly animations
class HollowKnightShadowTheme {
  static app_theme_data.AppThemeData create({bool isDark = true}) {
    final now = DateTime.now();
    
    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'hollow_knight_shadow_dark' : 'hollow_knight_shadow',
        name: isDark ? 'Hollow Knight Shadow Dark' : 'Hollow Knight Shadow Light',
        description: isDark 
          ? 'Ethereal void theme with spectral shadows and soul-like effects for deep focus'
          : 'Bright ethereal theme with ghostly mist and radiant soul energy',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['void', 'shadow', 'ethereal', 'gaming', 'mysterious', 'soul', 'spectral'],
        category: 'Gaming',
        previewIcon: PhosphorIcons.ghost(),
        primaryPreviewColor: isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF8F8FF),
        secondaryPreviewColor: const Color(0xFF4A90E2),
        createdAt: now,
        isPremium: true,
        popularityScore: 9.2,
      ),
      
      colors: _createShadowColors(isDark: isDark),
      typography: _createShadowTypography(isDark: isDark),
      animations: _createShadowAnimations(),
      effects: _createShadowEffects(),
      spacing: _createShadowSpacing(),
      components: _createShadowComponents(),
    );
  }

  /// Create light variant
  static app_theme_data.AppThemeData createLight() => create(isDark: false);
  
  /// Create dark variant
  static app_theme_data.AppThemeData createDark() => create(isDark: true);

  /// Create shadow-inspired color palette
  static ThemeColors _createShadowColors({bool isDark = true}) {
    if (!isDark) {
      // Shadow Light - Ethereal mist
      const soulBlue = Color(0xFF4A90E2);         // Soul essence
      const voidPurple = Color(0xFF8A2BE2);       // Void magic
      const spectraiWhite = Color(0xFFE6E6FA);    // Spectral white
      const shadowGray = Color(0xFF2F2F2F);       // Dark text
      const mistGray = Color(0xFF708090);         // Mist gray
      const etherealWhite = Color(0xFFF8F8FF);    // Background
      const lightVoid = Color(0xFFF0F8FF);        // Light surface
      const ghostGlow = Color(0xFFB0C4DE);        // Accent
      
      return ThemeColors(
        // Primary
        primary: soulBlue,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFE3F2FD),
        onPrimaryContainer: const Color(0xFF001B3E),
        
        // Secondary
        secondary: voidPurple,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFF3E5F5),
        onSecondaryContainer: const Color(0xFF31003D),
        
        // Tertiary
        tertiary: spectraiWhite,
        onTertiary: shadowGray,
        tertiaryContainer: const Color(0xFFF5F5FF),
        onTertiaryContainer: const Color(0xFF1A1A1F),
        
        // Surface
        surface: etherealWhite,
        onSurface: shadowGray,
        surfaceVariant: lightVoid,
        onSurfaceVariant: mistGray,
        inverseSurface: shadowGray,
        onInverseSurface: etherealWhite,
        
        // Background
        background: etherealWhite,
        onBackground: shadowGray,
        
        // Error
        error: const Color(0xFFB71C1C),
        onError: Colors.white,
        errorContainer: const Color(0xFFFFEBEE),
        onErrorContainer: const Color(0xFF2D0001),
        
        // Special
        accent: ghostGlow,
        highlight: spectraiWhite,
        shadow: Colors.black26,
        outline: mistGray,
        outlineVariant: const Color(0xFFCFCFD4),
        
        // Task Priority
        taskLowPriority: ghostGlow,
        taskMediumPriority: soulBlue,
        taskHighPriority: voidPurple,
        taskUrgentPriority: const Color(0xFF4527A0),
        
        // Status
        success: const Color(0xFF2E7D32),
        warning: const Color(0xFFF57C00),
        info: soulBlue,
        
        // Calendar Dots
        calendarTodayDot: soulBlue,
        calendarOverdueDot: voidPurple,
        calendarFutureDot: ghostGlow,
        calendarCompletedDot: const Color(0xFF2E7D32),
        calendarHighPriorityDot: const Color(0xFF4527A0),
        
        // Status Badges
        statusPendingBadge: ghostGlow,
        statusInProgressBadge: soulBlue,
        statusCompletedBadge: const Color(0xFF2E7D32),
        statusCancelledBadge: mistGray,
        statusOverdueBadge: voidPurple,
        statusOnHoldBadge: spectraiWhite,
        
        // Interactive
        hover: soulBlue.withValues(alpha: 0.8),
        pressed: soulBlue.withValues(alpha: 0.9),
        focus: soulBlue.withValues(alpha: 0.12),
        disabled: mistGray.withValues(alpha: 0.5),
      );
    } else {
      // Shadow Dark - Void depths
      const deepVoid = Color(0xFF0A0A0F);         // Void black
      const soulBlue = Color(0xFF4A90E2);         // Soul essence
      const voidPurple = Color(0xFF8A2BE2);       // Void magic
      const spectralWhite = Color(0xFFE6E6FA);    // Spectral energy
      const shadowGray = Color(0xFF1A1A1F);       // Surface
      const mistGray = Color(0xFF2A2A2F);         // Variant surface
      const ghostWhite = Color(0xFFCCCCCC);       // On surface
      
      return ThemeColors(
        // Primary
        primary: soulBlue,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFF1A237E),
        onPrimaryContainer: const Color(0xFFE3F2FD),
        
        // Secondary
        secondary: voidPurple,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFF4A148C),
        onSecondaryContainer: const Color(0xFFF3E5F5),
        
        // Tertiary
        tertiary: spectralWhite,
        onTertiary: Colors.black,
        tertiaryContainer: const Color(0xFF3A3A4F),
        onTertiaryContainer: const Color(0xFFF5F5FF),
        
        // Surface
        surface: deepVoid,
        onSurface: ghostWhite,
        surfaceVariant: shadowGray,
        onSurfaceVariant: const Color(0xFFAAAAAA),
        inverseSurface: ghostWhite,
        onInverseSurface: deepVoid,
        
        // Background
        background: deepVoid,
        onBackground: ghostWhite,
        
        // Error
        error: const Color(0xFFFF5252),
        onError: Colors.white,
        errorContainer: const Color(0xFF930006),
        onErrorContainer: const Color(0xFFFFEBEE),
        
        // Special
        accent: voidPurple,
        highlight: spectralWhite,
        shadow: Colors.black87,
        outline: const Color(0xFF5A5A5F),
        outlineVariant: const Color(0xFF3A3A3F),
        
        // Task Priority
        taskLowPriority: const Color(0xFF7986CB),
        taskMediumPriority: soulBlue,
        taskHighPriority: voidPurple,
        taskUrgentPriority: const Color(0xFF4527A0),
        
        // Status
        success: const Color(0xFF4CAF50),
        warning: const Color(0xFFFF9800),
        info: soulBlue,
        
        // Calendar Dots
        calendarTodayDot: soulBlue,
        calendarOverdueDot: const Color(0xFF4527A0),
        calendarFutureDot: voidPurple,
        calendarCompletedDot: const Color(0xFF4CAF50),
        calendarHighPriorityDot: const Color(0xFF4527A0),
        
        // Status Badges
        statusPendingBadge: voidPurple,
        statusInProgressBadge: soulBlue,
        statusCompletedBadge: const Color(0xFF4CAF50),
        statusCancelledBadge: const Color(0xFF5A5A5F),
        statusOverdueBadge: const Color(0xFF4527A0),
        statusOnHoldBadge: spectralWhite,
        
        // Interactive
        hover: soulBlue.withValues(alpha: 0.8),
        pressed: soulBlue.withValues(alpha: 0.9),
        focus: soulBlue.withValues(alpha: 0.12),
        disabled: const Color(0xFF5A5A5F).withValues(alpha: 0.5),
      );
    }
  }

  /// Create shadow-inspired typography with Exo 2 font
  static ThemeTypography _createShadowTypography({bool isDark = true}) {
    const fontFamily = 'Exo 2';
    final baseColor = isDark ? const Color(0xFFCCCCCC) : const Color(0xFF2F2F2F);
    final primaryColor = isDark ? const Color(0xFF4A90E2) : const Color(0xFF1A237E);
    
    return ThemeTypography(
      // Display styles - Light and ethereal
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 57.0,
        fontWeight: FontWeight.w200, // Ultra-light for ethereal feel
        letterSpacing: -0.25,
        height: 1.12,
        color: baseColor,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 45.0,
        fontWeight: FontWeight.w200,
        letterSpacing: -0.25,
        height: 1.16,
        color: baseColor,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 36.0,
        fontWeight: FontWeight.w300,
        letterSpacing: 0,
        height: 1.22,
        color: baseColor,
      ),
      
      // Headline styles - Ghostly presence
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32.0,
        fontWeight: FontWeight.w300, // Light for spectral feel
        letterSpacing: 0,
        height: 1.25,
        color: primaryColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.29,
        color: primaryColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.33,
        color: baseColor,
      ),
      
      // Title styles - Subtle presence
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22.0,
        fontWeight: FontWeight.w500, // Medium for void balance
        letterSpacing: 0.15,
        height: 1.27,
        color: baseColor,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.33,
        color: baseColor,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.25,
        color: baseColor,
      ),
      
      // Body styles - Ethereal readability
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16.0,
        fontWeight: FontWeight.w300, // Light for ghostly feel
        letterSpacing: 0.15,
        height: 1.5,
        color: baseColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.0,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.25,
        height: 1.43,
        color: baseColor,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.0,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.4,
        height: 1.33,
        color: baseColor.withValues(alpha: 0.7),
      ),
      
      // Label styles - Spectral guidance
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.27,
        color: baseColor,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.33,
        color: baseColor,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.45,
        color: baseColor.withValues(alpha: 0.7),
      ),
    );
  }

  /// Create shadow-inspired animations
  static ThemeAnimations _createShadowAnimations() {
    return ThemeAnimations(
      fast: const Duration(milliseconds: 150),    // Spectral fade
      medium: const Duration(milliseconds: 400),  // Soul drift
      slow: const Duration(milliseconds: 600),    // Void emergence
      verySlow: const Duration(milliseconds: 800), // Deep shadow
      
      primaryCurve: Curves.easeInOutSine,         // Ethereal flow
      secondaryCurve: Curves.easeInOutQuart,      // Void transition
      emphasisCurve: Curves.easeOutExpo,          // Soul burst
      
      pageTransition: theme_effects.PageTransitionType.fade,
      enableHoverAnimations: true,
      enableFocusAnimations: true,
    );
  }

  /// Create shadow-inspired effects
  static theme_effects.ThemeEffects _createShadowEffects() {
    return theme_effects.ThemeEffects(
      elevation: theme_effects.ElevationConfig(
        card: 2.0,         // Subtle ethereal lift
        button: 1.0,       // Minimal shadow presence
        fab: 4.0,
        appBar: 0.0,
        drawer: 16.0,
        dialog: 24.0,
      ),
      
      borderRadius: theme_effects.BorderRadiusConfig(
        small: 12.0,       // Ethereal curves
        medium: 16.0,
        large: 20.0,
        extraLarge: 28.0,
      ),
      
      animation: theme_effects.AnimationConfig(
        defaultDuration: const Duration(milliseconds: 400),
        fastDuration: const Duration(milliseconds: 150),
        slowDuration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutSine,
      ),
      
      blur: const theme_effects.BlurConfig(
        light: 6.0,        // Ethereal blur
        medium: 12.0,
        heavy: 20.0,
      ),
      
      glow: const theme_effects.GlowConfig(
        radius: 12.0,      // Soul glow
        opacity: 0.4,
        color: Color(0xFF4A90E2),
      ),
    );
  }

  /// Create shadow-inspired spacing
  static app_theme_data.ThemeSpacing _createShadowSpacing() {
    return app_theme_data.ThemeSpacing.fromBaseUnit(8.0).copyWith(
      cardPadding: 20.0,     // More space for ethereal feel
      screenPadding: 20.0,
      buttonPadding: 16.0,
      inputPadding: 16.0,
    );
  }

  /// Create shadow-inspired components
  static app_theme_data.ThemeComponents _createShadowComponents() {
    return const app_theme_data.ThemeComponents(
      appBar: app_theme_data.AppBarConfig(
        elevation: 0.0,
        centerTitle: true,
        toolbarHeight: kToolbarHeight,
      ),
      
      card: app_theme_data.CardConfig(
        elevation: 2.0,        // Ethereal lift
        borderRadius: 16.0,    // Soft ghostly curves
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: EdgeInsets.all(20.0),
      ),
      
      button: app_theme_data.ButtonConfig(
        borderRadius: 12.0,    // Ethereal curves
        padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 14.0),
        elevation: 1.0,        // Minimal shadow
        height: 48.0,
        style: app_theme_data.ButtonStyle.filled,
      ),
      
      input: app_theme_data.InputConfig(
        borderRadius: 12.0,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        borderStyle: app_theme_data.InputBorderStyle.outline,
        filled: true,
      ),
      
      fab: app_theme_data.FABConfig(
        shape: app_theme_data.FABShape.circular,
        elevation: 4.0,
        width: null,
        height: null,
      ),
      
      navigation: app_theme_data.NavigationConfig(
        type: app_theme_data.NavigationType.bottomNav,
        elevation: 6.0,
        showLabels: true,
      ),
      
      taskCard: app_theme_data.TaskCardConfig(
        borderRadius: 16.0,    // Consistent ethereal curves
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: EdgeInsets.all(20.0),
        elevation: 2.0,        // Subtle ethereal presence
        showPriorityStripe: true,
        enableSwipeActions: true,
      ),
    );
  }
}