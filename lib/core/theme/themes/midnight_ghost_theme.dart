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

/// 👻 Midnight Ghost Theme - "Spectral Presence"
/// A haunting supernatural theme inspired by ghostly apparitions and ethereal spirits
/// Dark Mode: "Phantom Realm" - Deep void with spectral blues, phantom grays, and ectoplasm greens
/// Light Mode: "Spirit Sanctuary" - Ethereal whites with ghostly accents and translucent beauty
class MidnightGhostTheme {
  static app_theme_data.AppThemeData create({bool isDark = true}) {
    final now = DateTime.now();
    
    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'midnight_ghost_dark' : 'midnight_ghost_light',
        name: isDark ? 'Midnight Ghost Dark' : 'Midnight Ghost Light',
        description: isDark 
          ? 'Phantom Realm theme featuring deep void backgrounds, spectral blue highlights, phantom gray surfaces, ectoplasm green accents, and haunting spirit particle effects'
          : 'Spirit Sanctuary theme with ethereal white backgrounds, ghostly blue accents, translucent elements, and serene supernatural aesthetics',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['ghost', 'spectral', 'haunting', 'supernatural', 'ethereal', 'phantom', 'spirit', 'mysterious'],
        category: 'dark',
        previewIcon: PhosphorIcons.ghost(),
        primaryPreviewColor: isDark ? const Color(0xFF0C0C1A) : const Color(0xFFF8F8FF), // Enhanced dark vs light
        secondaryPreviewColor: isDark ? const Color(0xFF4169E1) : const Color(0xFF2F2F2F), // Spectral blue (mode-specific)
        tertiaryPreviewColor: isDark ? const Color(0xFF4B0082) : const Color(0xFF330055), // Midnight Indigo signature accent
        createdAt: now,
        isPremium: false,
        popularityScore: 9.0, // Mysterious haunting appeal
      ),
      
      colors: _createSpectralColors(isDark: isDark),
      typography: _createSpectralTypography(isDark: isDark),
      animations: _createSpectralAnimations(),
      effects: _createSpectralEffects(),
      spacing: _createSpectralSpacing(),
      components: _createSpectralComponents(),
    );
  }

  /// Create light variant - Spirit Sanctuary
  static app_theme_data.AppThemeData createLight() => create(isDark: false);
  
  /// Create dark variant - Phantom Realm
  static app_theme_data.AppThemeData createDark() => create(isDark: true);

  /// Create haunting spectral color palette
  static ThemeColors _createSpectralColors({bool isDark = true}) {
    if (isDark) {
      // 👻 Dark Mode - "Phantom Realm": Deep void with supernatural manifestations
      const voidBlack = Color(0xFF0C0C0C);            // Deep phantom void
      const spectralBlue = Color(0xFF4169E1);          // Spectral blue manifestation
      const phantomGray = Color(0xFF708090);           // Phantom gray ectoplasm
      const ectoplasmGreen = Color(0xFF98FB98);        // Ectoplasm green glow
      const ghostWhite = Color(0xFFF8F8FF);            // Pure ghost white
      const shadowGray = Color(0xFF2F4F4F);            // Deep shadow gray
      const spiritPurple = Color(0xFF9370DB);          // Spirit purple aura
      const hauntingBlue = Color(0xFF6495ED);          // Haunting blue light
      const mistyGray = Color(0xFF778899);             // Misty gray fog
      const etherealCyan = Color(0xFF48D1CC);          // Ethereal cyan energy
      
      // Midnight Indigo Signature Accent - Enhanced for dark mode visibility
      const midnightIndigoSignature = Color(0xFF4B0082);      // Super bright signature indigo
      const onMidnightIndigoSignature = Color(0xFFFFFFFF);    // Pure white for maximum contrast
      const midnightIndigoContainer = Color(0xFF2A1A3F);      // Enhanced indigo container
      const onMidnightIndigoContainer = Color(0xFFFFFFFF);    // Pure white for container text
      
      return const ThemeColors(
        // Primary colors - Spectral Blue manifestation
        primary: spectralBlue,
        onPrimary: ghostWhite,
        primaryContainer: shadowGray,
        onPrimaryContainer: hauntingBlue,

        // Secondary colors - Phantom Gray presence
        secondary: phantomGray,
        onSecondary: ghostWhite,
        secondaryContainer: Color(0xFF4A5568),
        onSecondaryContainer: Color(0xFFE2E8F0),

        // Tertiary colors - Ectoplasm Green energy
        tertiary: ectoplasmGreen,
        onTertiary: voidBlack,
        tertiaryContainer: Color(0xFF2D5A3D),
        onTertiaryContainer: Color(0xFFB8FFB8),

        // Surface colors - Phantom realm materials
        surface: Color(0xFF1A202C),
        onSurface: ghostWhite,
        surfaceVariant: shadowGray,
        onSurfaceVariant: mistyGray,
        inverseSurface: ghostWhite,
        onInverseSurface: voidBlack,

        // Background colors - Deep spectral void
        background: voidBlack,
        onBackground: ghostWhite,

        // Error colors - Supernatural danger
        error: Color(0xFFFF6B6B),
        onError: ghostWhite,
        errorContainer: Color(0xFF2D1B1B),
        onErrorContainer: Color(0xFFFFB3B3),

        // Special colors - Spectral essence with Midnight Indigo signature accent
        accent: midnightIndigoSignature,       // Use signature indigo as primary accent
        highlight: ectoplasmGreen,
        shadow: voidBlack,
        outline: mistyGray,
        outlineVariant: shadowGray,

        // Task priority colors - Spectral energy levels with Midnight Indigo signature accent
        taskLowPriority: etherealCyan,           // Low energy - Ethereal cyan
        taskMediumPriority: spectralBlue,        // Medium energy - Spectral blue
        taskHighPriority: midnightIndigoSignature, // Signature indigo power
        taskUrgentPriority: Color(0xFFFF6B6B),   // Critical energy - Danger manifestation

        // Status colors - Supernatural states
        success: ectoplasmGreen,
        warning: Color(0xFFFFD700),
        info: hauntingBlue,

        // Calendar dot colors - Spectral calendar with Midnight Indigo signature accent
        calendarTodayDot: spectralBlue,
        calendarOverdueDot: Color(0xFFFF6B6B),
        calendarFutureDot: phantomGray,
        calendarCompletedDot: ectoplasmGreen,
        calendarHighPriorityDot: midnightIndigoSignature,   // Signature indigo for high priority
        
        // Status badge colors - Phantom activity states with Midnight Indigo signature accent
        statusPendingBadge: mistyGray,
        statusInProgressBadge: spectralBlue,
        statusCompletedBadge: midnightIndigoSignature,     // Signature indigo for completed (achievement)
        statusCancelledBadge: shadowGray,
        statusOverdueBadge: Color(0xFFFF6B6B),
        statusOnHoldBadge: spiritPurple,

        // Interactive colors - Spectral responses
        hover: Color(0x4D4169E1),    // spectralBlue with 0.3 alpha
        pressed: Color(0x80708090),  // phantomGray with 0.5 alpha
        focus: midnightIndigoSignature,                    // Signature indigo for focus
        disabled: Color(0xFF1A1A1A),
        
        // Midnight Indigo Signature Colors
        midnightIndigo: midnightIndigoSignature,
        onMidnightIndigo: onMidnightIndigoSignature,
        midnightIndigoContainer: midnightIndigoContainer,
        onMidnightIndigoContainer: onMidnightIndigoContainer,
      );
    }
    
    // ☀️ Light Mode - "Spirit Sanctuary": Ethereal whites with ghostly accents
    const etherealWhite = Color(0xFFF8F8FF);         // Ethereal ghost white
    const spiritMist = Color(0xFFF5F5F5);            // Spirit mist surface
    const lightGray = Color(0xFFE8E8E8);             // Light ethereal gray
    const mediumBlue = Color(0xFF4169E1);            // Medium spectral blue
    const softGray = Color(0xFF708090);              // Soft phantom gray
    const lightGreen = Color(0xFF90EE90);            // Light ectoplasm green
    const charcoalText = Color(0xFF2F2F2F);          // Charcoal text
    const mistyBlue = Color(0xFFB0C4DE);             // Misty blue accent
    const ghostPurple = Color(0xFF9370DB);           // Ghost purple
    const silverMist = Color(0xFFD3D3D3);            // Silver mist
    
    // Midnight Indigo Signature Accent - Deeper for light mode contrast
    const deepMidnightIndigo = Color(0xFF330055);          // Deep signature indigo
    const onDeepMidnightIndigo = Color(0xFFFFFFFF);         // White text on deep indigo
    const deepMidnightIndigoContainer = Color(0xFFE8E0FF);  // Light indigo container
    const onDeepMidnightIndigoContainer = Color(0xFF1A0033); // Deep indigo container text
    
    return const ThemeColors(
      // Primary colors - Medium Blue on ethereal backgrounds
      primary: mediumBlue,
      onPrimary: etherealWhite,
      primaryContainer: Color(0xFFE6F3FF),
      onPrimaryContainer: Color(0xFF1A365D),
      
      // Secondary colors - Soft Gray presence
      secondary: softGray,
      onSecondary: etherealWhite,
      secondaryContainer: Color(0xFFF7FAFC),
      onSecondaryContainer: Color(0xFF2D3748),
      
      // Tertiary colors - Light Green energy
      tertiary: Color(0xFF48BB78), // Darker green for better contrast
      onTertiary: etherealWhite,
      tertiaryContainer: Color(0xFFF0FFF4),
      onTertiaryContainer: Color(0xFF1A202C),
      
      // Surface colors - Spirit sanctuary materials
      surface: spiritMist,
      onSurface: charcoalText,
      surfaceVariant: lightGray,
      onSurfaceVariant: Color(0xFF4A5568),
      inverseSurface: charcoalText,
      onInverseSurface: etherealWhite,
      
      // Background colors - Ethereal sanctuary
      background: etherealWhite,
      onBackground: charcoalText,
      
      // Error colors - Light supernatural danger
      error: Color(0xFFDC2626),
      onError: etherealWhite,
      errorContainer: Color(0xFFFEF2F2),
      onErrorContainer: Color(0xFF991B1B),
      
      // Special colors - Light spectral essence with Midnight Indigo signature accent
      accent: deepMidnightIndigo,            // Use signature indigo as primary accent
      highlight: lightGreen,
      shadow: Color(0xFF000000),
      outline: silverMist,
      outlineVariant: lightGray,
      
      // Task priority colors - Light spectral energy with Midnight Indigo signature accent
      taskLowPriority: Color(0xFF38B2AC),
      taskMediumPriority: mediumBlue,
      taskHighPriority: deepMidnightIndigo,  // Signature indigo power
      taskUrgentPriority: Color(0xFFDC2626),
      
      // Status colors - Light supernatural states
      success: Color(0xFF22C55E),
      warning: Color(0xFFF59E0B),
      info: mistyBlue,
      
      // Calendar dot colors - Light spectral calendar with Midnight Indigo signature accent
      calendarTodayDot: mediumBlue,
      calendarOverdueDot: Color(0xFFDC2626),
      calendarFutureDot: softGray,
      calendarCompletedDot: Color(0xFF22C55E),
      calendarHighPriorityDot: deepMidnightIndigo,       // Signature indigo for high priority
      
      // Status badge colors - Light spirit activity with Midnight Indigo signature accent
      statusPendingBadge: silverMist,
      statusInProgressBadge: mediumBlue,
      statusCompletedBadge: deepMidnightIndigo,          // Signature indigo for completed (achievement)
      statusCancelledBadge: lightGray,
      statusOverdueBadge: Color(0xFFDC2626),
      statusOnHoldBadge: ghostPurple,
      
      // Interactive colors - Light spectral responses
      hover: Color(0x334169E1),    // mediumBlue with 0.2 alpha
      pressed: Color(0x66708090),  // softGray with 0.4 alpha
      focus: deepMidnightIndigo,               // Signature indigo for focus
      disabled: lightGray,
      
      // Midnight Indigo Signature Colors
      midnightIndigo: deepMidnightIndigo,
      onMidnightIndigo: onDeepMidnightIndigo,
      midnightIndigoContainer: deepMidnightIndigoContainer,
      onMidnightIndigoContainer: onDeepMidnightIndigoContainer,
    );
  }

  /// Create haunting spectral typography using Exo 2 font
  static ThemeTypography _createSpectralTypography({bool isDark = true}) {
    final colors = _SpectralColorsHelper(isDark: isDark);
    const fontFamily = 'Exo 2';
    
    return ThemeTypography(
      fontFamily: fontFamily,
      displayFontFamily: fontFamily,
      monospaceFontFamily: fontFamily,
      baseSize: TypographyConstants.bodyLarge,
      scaleRatio: 1.0,
      baseFontWeight: FontWeight.w300, // Light weight for ethereal feel
      baseLetterSpacing: TypographyConstants.wideLetterSpacing, // Wide for haunting presence
      baseLineHeight: TypographyConstants.relaxedLineHeight, // Spacious for ghostly feel
      
      // Display styles - Spectral manifestations
      displayLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayLarge,
        fontWeight: FontWeight.w200, // Ultra light for ethereal
        letterSpacing: TypographyConstants.wideLetterSpacing * 1.3,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      displayMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayMedium,
        fontWeight: FontWeight.w200,
        letterSpacing: TypographyConstants.wideLetterSpacing * 1.3,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      displaySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displaySmall,
        fontWeight: FontWeight.w300,
        letterSpacing: TypographyConstants.wideLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      
      // Headline styles - Phantom headers
      headlineLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineLarge,
        fontWeight: FontWeight.w300,
        letterSpacing: TypographyConstants.wideLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      headlineMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineMedium,
        fontWeight: FontWeight.w300,
        letterSpacing: TypographyConstants.wideLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      headlineSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineSmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      
      // Title styles - Ghostly whispers
      titleLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      titleMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleMedium,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.2,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      titleSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.2,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      
      // Body styles - Spirit messages
      bodyLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyLarge,
        fontWeight: FontWeight.w300,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      bodyMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyMedium,
        fontWeight: FontWeight.w300,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      bodySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: FontWeight.w300,
        letterSpacing: TypographyConstants.normalLetterSpacing,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      
      // Label styles - Spectral markers
      labelLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.wideLetterSpacing * 1.4,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      labelMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelMedium,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.wideLetterSpacing * 1.4,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      labelSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelSmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.wideLetterSpacing * 1.4,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Custom app styles - Phantom realm precision
      taskTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskTitle,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.2,
        height: TypographyConstants.relaxedLineHeight,
        color: colors.onBackground,
      ),
      taskDescription: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskDescription,
        fontWeight: FontWeight.w300,
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
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.2,
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
        letterSpacing: TypographyConstants.wideLetterSpacing * 1.3,
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
        letterSpacing: TypographyConstants.normalLetterSpacing * 1.2,
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

  /// Create haunting spectral animations with ectoplasm particle effects
  static ThemeAnimations _createSpectralAnimations() {
    return ThemeAnimations.fromThemeStyle(ThemeAnimationStyle.smooth).copyWith(
      // Slow, haunting timing like drifting spirits
      fast: const Duration(milliseconds: 350),
      medium: const Duration(milliseconds: 700),
      slow: const Duration(milliseconds: 1000),
      verySlow: const Duration(milliseconds: 1500),
      
      // Ethereal, floating curves
      primaryCurve: Curves.easeInOutSine,       // Smooth spectral waves
      secondaryCurve: Curves.easeOutQuart,      // Gentle phantom fade
      entranceCurve: Curves.easeOutCubic,       // Ghost materialization
      exitCurve: Curves.easeInCubic,            // Spirit dematerialization
      
      // Ectoplasm particle system
      enableParticles: true,
      particleConfig: const ParticleConfig(
        density: ParticleDensity.low,            // Sparse haunting spirits
        speed: ParticleSpeed.verySlow,           // Very slowly drifting ectoplasm
        style: ParticleStyle.organic,            // Organic spirit shapes
        enableGlow: true,                        // Ghostly ectoplasm glow
        opacity: 0.3,                            // Very translucent spirits
        size: 1.0,                               // Medium spirit wisps
      ),
    );
  }

  /// Create ethereal spectral visual effects
  static theme_effects.ThemeEffects _createSpectralEffects() {
    return theme_effects.ThemeEffects.fromEffectStyle(theme_effects.ThemeEffectStyle.elegant).copyWith(
      shadowStyle: theme_effects.ShadowStyle.soft,         // Soft spectral shadows
      gradientStyle: theme_effects.GradientStyle.subtle,   // Subtle ghost gradients
      borderStyle: theme_effects.BorderStyle.rounded,      // Organic spirit shapes
      
      blurConfig: const theme_effects.BlurConfig(
        enabled: true,
        intensity: 2.5,                          // Strong ethereal blur
        style: theme_effects.BlurStyle.normal,
      ),
      
      glowConfig: const theme_effects.GlowConfig(
        enabled: true,
        intensity: 0.6,                          // Moderate spectral glow
        spread: 14.0,                            // Wide ghostly glow radius
        style: theme_effects.GlowStyle.outer,
      ),
      
      backgroundEffects: const theme_effects.BackgroundEffectConfig(
        enableParticles: true,                   // Floating ectoplasm particles
        enableGradientMesh: true,                // Spectral gradient mesh
        enableScanlines: false,                  // No digital elements
        particleType: theme_effects.BackgroundParticleType.floating, // Floating spirits
        particleOpacity: 0.2,                    // Very subtle spirit presence
        effectIntensity: 0.4,                    // Moderate haunting effects
        geometricPattern: theme_effects.BackgroundGeometricPattern.radial,
        patternAngle: 0.0,
        patternDensity: 0.7,
        accentColors: [
          Color(0x1A4B0082), // Midnight Indigo signature accent at 0.1 alpha
          Color(0x194169E1), // Spectral blue at 0.1 alpha
          Color(0x1498FB98), // Ectoplasm green at 0.08 alpha
        ],
      ),
    );
  }

  /// Create ethereal spectral spacing with haunting proportions
  static app_theme_data.ThemeSpacing _createSpectralSpacing() {
    const spectralRatio = 1.333; // 4:3 ratio for spectral proportions
    const baseUnit = 9.0;
    
    return app_theme_data.ThemeSpacing.fromBaseUnit(baseUnit).copyWith(
      cardPadding: baseUnit * spectralRatio * 1.7,      // ~20.4 → Ethereal card padding
      screenPadding: baseUnit * spectralRatio * 2.3,    // ~27.6 → Spacious spectral margins
      buttonPadding: baseUnit * spectralRatio * 1.4,    // ~16.8 → Ghostly button padding
      inputPadding: baseUnit * spectralRatio * 1.1,     // ~13.2 → Haunting input padding
    );
  }

  /// Create ethereal spectral components with ghost aesthetics
  static app_theme_data.ThemeComponents _createSpectralComponents() {
    return const app_theme_data.ThemeComponents(
      appBar: app_theme_data.AppBarConfig(
        elevation: 0.0,                          // Floating in spectral realm
        centerTitle: true,                       // Centered spectral balance
        toolbarHeight: kToolbarHeight,
      ),
      
      card: app_theme_data.CardConfig(
        elevation: 1.5,                          // Gentle spectral elevation
        borderRadius: 22.0,                      // Very soft ghost curves
        margin: EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        padding: EdgeInsets.all(24.0),          // Spacious ethereal padding
      ),
      
      input: app_theme_data.InputConfig(
        borderRadius: 18.0,                      // Soft spectral input
        contentPadding: EdgeInsets.symmetric(horizontal: 22.0, vertical: 18.0),
        borderStyle: app_theme_data.InputBorderStyle.outline,
        filled: false,
      ),
      
      button: app_theme_data.ButtonConfig(
        borderRadius: 20.0,                      // Very soft spectral curves
        padding: EdgeInsets.symmetric(horizontal: 34.0, vertical: 18.0),
        elevation: 1.0,                          // Subtle spectral elevation
        height: 58.0,                            // Generous spectral interaction
        style: app_theme_data.ButtonStyle.outlined,
      ),
      
      fab: app_theme_data.FABConfig(
        shape: app_theme_data.FABShape.circular, // Perfect spectral orb
        elevation: 3.0,                          // Gentle spectral floating
        width: null,
        height: null,
      ),
      
      navigation: app_theme_data.NavigationConfig(
        type: app_theme_data.NavigationType.bottomNav,
        elevation: 6.0,                          // Floating above spectral realm
        showLabels: false,                       // Minimalist ghost design
      ),
      
      taskCard: app_theme_data.TaskCardConfig(
        borderRadius: 20.0,                      // Very soft spectral curves
        margin: EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
        padding: EdgeInsets.all(22.0),          // Spacious spectral space
        elevation: 0.8,                          // Barely floating spirits
        showPriorityStripe: true,                // Spectral energy indicators
        enableSwipeActions: true,                // Ethereal spectral interactions
      ),
    );
  }
}

/// Helper class for accessing spectral colors in static context
class _SpectralColorsHelper {
  final bool isDark;
  const _SpectralColorsHelper({this.isDark = true});
  
  Color get onBackground => isDark 
    ? const Color(0xFFF8F8FF)   // Ghost white
    : const Color(0xFF2F2F2F);  // Charcoal text
    
  Color get primary => isDark 
    ? const Color(0xFF4169E1)   // Spectral blue
    : const Color(0xFF4169E1);  // Spectral blue (consistent)
    
  Color get spectralGreen => const Color(0xFF98FB98); // Ectoplasm green in both modes
}