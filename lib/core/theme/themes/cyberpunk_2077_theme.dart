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

/// ⚡ Cyberpunk 2077 Theme - "Welcome to Night City"
/// An edgy cyberpunk theme inspired by the dystopian future of Cyberpunk 2077
/// Dark Mode: "Night City Streets" - Deep tech black with neon yellow, cyber magenta, and electric blue
/// Light Mode: "Corporate Plaza" - Clean tech whites with neon accents and holographic elements
class Cyberpunk2077Theme {
  static app_theme_data.AppThemeData create({bool isDark = true}) {
    final now = DateTime.now();
    
    return app_theme_data.AppThemeData(
      metadata: ThemeMetadata(
        id: isDark ? 'cyberpunk_2077_dark' : 'cyberpunk_2077_light',
        name: isDark ? 'Cyberpunk 2077 Dark' : 'Cyberpunk 2077 Light',
        description: isDark 
          ? 'Night City Streets theme featuring deep tech black backgrounds, neon yellow highlights, cyber magenta accents, electric blue details, and holographic glitch effects'
          : 'Corporate Plaza theme with clean tech white backgrounds, neon accent colors, holographic elements, and futuristic corporate aesthetics',
        author: 'Tasky Team',
        version: '1.0.0',
        tags: ['cyberpunk', 'futuristic', 'neon', 'tech', 'edgy', 'holographic', 'dystopian', 'night-city'],
        category: 'gaming',
        previewIcon: PhosphorIcons.robot(),
        primaryPreviewColor: const Color(0xFFFFFF00), // Neon yellow
        secondaryPreviewColor: const Color(0xFFFF00FF), // Cyber magenta
        createdAt: now,
        isPremium: false,
        popularityScore: 9.6, // Very popular cyberpunk aesthetic
      ),
      
      colors: _createCyberColors(isDark: isDark),
      typography: _createCyberTypography(isDark: isDark),
      animations: _createCyberAnimations(),
      effects: _createCyberEffects(),
      spacing: _createCyberSpacing(),
      components: _createCyberComponents(),
    );
  }

  /// Create light variant - Corporate Plaza
  static app_theme_data.AppThemeData createLight() => create(isDark: false);
  
  /// Create dark variant - Night City Streets
  static app_theme_data.AppThemeData createDark() => create(isDark: true);

  /// Create edgy cyberpunk color palette
  static ThemeColors _createCyberColors({bool isDark = true}) {
    if (isDark) {
      // ⚡ Dark Mode - "Night City Streets": Deep tech black with neon highlights
      const techBlack = Color(0xFF0D0D0D);           // Deep tech black background
      const neonYellow = Color(0xFFFFFF00);          // Neon yellow primary
      const cyberMagenta = Color(0xFFFF00FF);        // Cyber magenta secondary
      const electricBlue = Color(0xFF00BFFF);        // Electric blue accent
      const darkGray = Color(0xFF1A1A1A);            // Dark gray surface
      const neonWhite = Color(0xFFF0F0F0);           // Neon white text
      const glitchGreen = Color(0xFF00FF41);          // Matrix-like green
      const holoPurple = Color(0xFF8A2BE2);          // Holographic purple
      const cyberRed = Color(0xFFFF073A);            // Cyber danger red
      const carbonGray = Color(0xFF2A2A2A);          // Carbon fiber gray
      
      return const ThemeColors(
        // Primary colors - Neon Yellow dominance
        primary: neonYellow,
        onPrimary: techBlack,
        primaryContainer: Color(0xFF333300),
        onPrimaryContainer: neonYellow,

        // Secondary colors - Cyber Magenta energy
        secondary: cyberMagenta,
        onSecondary: neonWhite,
        secondaryContainer: Color(0xFF330033),
        onSecondaryContainer: Color(0xFFFF66FF),

        // Tertiary colors - Electric Blue power
        tertiary: electricBlue,
        onTertiary: techBlack,
        tertiaryContainer: Color(0xFF001F3F),
        onTertiaryContainer: Color(0xFF66DDFF),

        // Surface colors - Tech materials
        surface: darkGray,
        onSurface: neonWhite,
        surfaceVariant: carbonGray,
        onSurfaceVariant: Color(0xFF999999),
        inverseSurface: neonWhite,
        onInverseSurface: techBlack,

        // Background colors - Night City void
        background: techBlack,
        onBackground: neonWhite,

        // Error colors - Cyber danger
        error: cyberRed,
        onError: neonWhite,
        errorContainer: Color(0xFF330A0A),
        onErrorContainer: Color(0xFFFF6666),

        // Special colors - Cyber essence
        accent: cyberMagenta,
        highlight: electricBlue,
        shadow: techBlack,
        outline: Color(0xFF444444),
        outlineVariant: carbonGray,

        // Task priority colors - Cyber threat levels
        taskLowPriority: glitchGreen,            // Low threat - Matrix green
        taskMediumPriority: neonYellow,          // Medium threat - Neon yellow
        taskHighPriority: cyberMagenta,          // High threat - Cyber magenta
        taskUrgentPriority: cyberRed,            // Critical threat - Danger red

        // Status colors - System states
        success: glitchGreen,
        warning: neonYellow,
        info: electricBlue,

        // Calendar dot colors - Cyber calendar
        calendarTodayDot: neonYellow,
        calendarOverdueDot: cyberRed,
        calendarFutureDot: electricBlue,
        calendarCompletedDot: glitchGreen,
        calendarHighPriorityDot: cyberMagenta,
        
        // Status badge colors - System activity states
        statusPendingBadge: Color(0xFF666666),
        statusInProgressBadge: cyberMagenta,
        statusCompletedBadge: glitchGreen,
        statusCancelledBadge: carbonGray,
        statusOverdueBadge: cyberRed,
        statusOnHoldBadge: holoPurple,

        // Interactive colors - Cyber responses
        hover: Color(0x80FFFF00),    // neonYellow with 0.5 alpha
        pressed: Color(0xB3FF00FF),  // cyberMagenta with 0.7 alpha
        focus: electricBlue,
        disabled: Color(0xFF333333),
      );
    }
    
    // ☀️ Light Mode - "Corporate Plaza": Clean tech whites with neon accents
    const techWhite = Color(0xFFF8F8FF);            // Clean tech white
    const lightGray = Color(0xFFE8E8E8);            // Light tech gray
    const silverMetal = Color(0xFFD3D3D3);          // Silver metallic
    const darkYellow = Color(0xFFE6E600);           // Darker neon yellow for contrast
    const darkMagenta = Color(0xFFCC00CC);          // Darker cyber magenta
    const darkBlue = Color(0xFF0080CC);             // Darker electric blue
    const charcoalText = Color(0xFF1A1A1A);         // Dark charcoal text
    const hologramBlue = Color(0xFF4169E1);         // Hologram blue
    const neonGreen = Color(0xFF32CD32);            // Bright neon green
    const cyberPink = Color(0xFFFF1493);            // Cyber pink accent
    
    return const ThemeColors(
      // Primary colors - Dark Yellow on light backgrounds
      primary: darkYellow,
      onPrimary: techWhite,
      primaryContainer: Color(0xFFFFFACD),
      onPrimaryContainer: Color(0xFF666600),
      
      // Secondary colors - Dark Magenta energy
      secondary: darkMagenta,
      onSecondary: techWhite,
      secondaryContainer: Color(0xFFFFE6FF),
      onSecondaryContainer: Color(0xFF660066),
      
      // Tertiary colors - Dark Blue power
      tertiary: darkBlue,
      onTertiary: techWhite,
      tertiaryContainer: Color(0xFFE6F3FF),
      onTertiaryContainer: Color(0xFF003366),
      
      // Surface colors - Light tech materials
      surface: lightGray,
      onSurface: charcoalText,
      surfaceVariant: silverMetal,
      onSurfaceVariant: Color(0xFF4A4A4A),
      inverseSurface: charcoalText,
      onInverseSurface: techWhite,
      
      // Background colors - Corporate cleanliness
      background: techWhite,
      onBackground: charcoalText,
      
      // Error colors - Corporate danger
      error: Color(0xFFDC2626),
      onError: techWhite,
      errorContainer: Color(0xFFFEF2F2),
      onErrorContainer: Color(0xFF991B1B),
      
      // Special colors - Corporate cyber essence
      accent: darkMagenta,
      highlight: hologramBlue,
      shadow: Color(0xFF000000),
      outline: Color(0xFFBBBBBB),
      outlineVariant: silverMetal,
      
      // Task priority colors - Corporate threat levels
      taskLowPriority: neonGreen,
      taskMediumPriority: darkYellow,
      taskHighPriority: darkMagenta,
      taskUrgentPriority: Color(0xFFDC2626),
      
      // Status colors - Corporate system states
      success: neonGreen,
      warning: Color(0xFFF59E0B),
      info: hologramBlue,
      
      // Calendar dot colors - Corporate cyber calendar
      calendarTodayDot: darkYellow,
      calendarOverdueDot: Color(0xFFDC2626),
      calendarFutureDot: hologramBlue,
      calendarCompletedDot: neonGreen,
      calendarHighPriorityDot: darkMagenta,
      
      // Status badge colors - Corporate activity states
      statusPendingBadge: Color(0xFF9CA3AF),
      statusInProgressBadge: darkMagenta,
      statusCompletedBadge: neonGreen,
      statusCancelledBadge: silverMetal,
      statusOverdueBadge: Color(0xFFDC2626),
      statusOnHoldBadge: Color(0xFF8B5CF6),
      
      // Interactive colors - Corporate cyber responses
      hover: Color(0x40E6E600),    // darkYellow with 0.25 alpha
      pressed: Color(0x80CC00CC),  // darkMagenta with 0.5 alpha
      focus: hologramBlue,
      disabled: silverMetal,
    );
  }

  /// Create edgy cyberpunk typography using Space Mono font
  static ThemeTypography _createCyberTypography({bool isDark = true}) {
    final colors = _CyberColorsHelper(isDark: isDark);
    const fontFamily = 'Space Mono';
    
    return ThemeTypography(
      fontFamily: fontFamily,
      displayFontFamily: fontFamily,
      monospaceFontFamily: fontFamily,
      baseSize: TypographyConstants.bodyLarge,
      scaleRatio: 1.0,
      baseFontWeight: FontWeight.w400, // Regular monospace weight
      baseLetterSpacing: TypographyConstants.normalLetterSpacing * 0.8, // Tighter for tech feel
      baseLineHeight: TypographyConstants.tightLineHeight, // Compact like terminal
      
      // Display styles - Cyber headers
      displayLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayLarge,
        fontWeight: FontWeight.w700, // Bold for impact
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.6,
        height: TypographyConstants.tightLineHeight,
        color: colors.onBackground,
      ),
      displayMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displayMedium,
        fontWeight: FontWeight.w700,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.6,
        height: TypographyConstants.tightLineHeight,
        color: colors.onBackground,
      ),
      displaySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.displaySmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.8,
        height: TypographyConstants.tightLineHeight,
        color: colors.onBackground,
      ),
      
      // Headline styles - Terminal headers
      headlineLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.8,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      headlineMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineMedium,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.8,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      headlineSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.headlineSmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.8,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Title styles - System titles
      titleLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.9,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      titleMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleMedium,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.9,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      titleSmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.9,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Body styles - Terminal text
      bodyLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.8,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      bodyMedium: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodyMedium,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.8,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      bodySmall: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.8,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      
      // Label styles - System labels
      labelLarge: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.labelLarge,
        fontWeight: FontWeight.w700, // Bold labels for visibility
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
      
      // Custom app styles - Cyberpunk precision
      taskTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskTitle,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.9,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      taskDescription: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskDescription,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.8,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      taskMeta: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.taskMeta,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.8,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      cardTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.titleSmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.9,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      cardSubtitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.bodySmall,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.8,
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
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.8,
        height: TypographyConstants.normalLineHeight,
        color: colors.onBackground,
      ),
      appBarTitle: LocalFonts.getFont(
        fontFamily,
        fontSize: TypographyConstants.appBarTitle,
        fontWeight: FontWeight.w400,
        letterSpacing: TypographyConstants.normalLetterSpacing * 0.9,
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

  /// Create fast cyberpunk animations with glitch effects
  static ThemeAnimations _createCyberAnimations() {
    return ThemeAnimations.fromThemeStyle(ThemeAnimationStyle.digital).copyWith(
      // Ultra-fast cyber timing
      fast: const Duration(milliseconds: 80),
      medium: const Duration(milliseconds: 150),
      slow: const Duration(milliseconds: 250),
      verySlow: const Duration(milliseconds: 400),
      
      // Sharp, digital glitch curves
      primaryCurve: Curves.easeInOutQuart,     // Sharp cyber curves
      secondaryCurve: Curves.bounceOut,        // Glitch bounce
      entranceCurve: Curves.easeOutBack,       // System boot
      exitCurve: Curves.easeInExpo,            // System shutdown
      
      // High-density cyber particle system
      enableParticles: true,
      particleConfig: const ParticleConfig(
        density: ParticleDensity.ultra,         // Dense cyber particles
        speed: ParticleSpeed.veryFast,          // Fast-moving data
        style: ParticleStyle.digital,           // Digital particle style
        enableGlow: true,                       // Neon particle glow
        opacity: 1.0,                           // Full intensity
        size: 1.0,                              // Standard cyber size
      ),
    );
  }

  /// Create holographic cyberpunk visual effects
  static theme_effects.ThemeEffects _createCyberEffects() {
    return theme_effects.ThemeEffects.fromEffectStyle(theme_effects.ThemeEffectStyle.digital).copyWith(
      shadowStyle: theme_effects.ShadowStyle.none,        // No shadows in digital space
      gradientStyle: theme_effects.GradientStyle.none,    // Flat neon colors
      borderStyle: theme_effects.BorderStyle.sharp,       // Sharp cyber edges
      
      blurConfig: const theme_effects.BlurConfig(
        enabled: false,                         // Sharp digital precision
      ),
      
      glowConfig: const theme_effects.GlowConfig(
        enabled: true,
        intensity: 1.0,                         // Maximum neon glow
        spread: 8.0,                            // Wide cyber glow
        style: theme_effects.GlowStyle.outer,
      ),
      
      backgroundEffects: const theme_effects.BackgroundEffectConfig(
        enableParticles: true,                  // Cyber data particles
        enableGradientMesh: false,              // No gradients in digital space
        enableScanlines: true,                  // Cyber scanlines
        particleType: theme_effects.BackgroundParticleType.energy, // Energy data
        particleOpacity: 1.0,                   // Full visibility cyber data
        effectIntensity: 1.0,                   // Maximum cyber intensity
      ),
    );
  }

  /// Create precise cyberpunk spacing with tech proportions
  static app_theme_data.ThemeSpacing _createCyberSpacing() {
    const cyberRatio = 1.5; // 3:2 ratio for tech proportions
    const baseUnit = 6.0; // Smaller base unit for compact cyber feel
    
    return app_theme_data.ThemeSpacing.fromBaseUnit(baseUnit).copyWith(
      cardPadding: baseUnit * cyberRatio * 2.0,     // ~18.0 → Tech card padding
      screenPadding: baseUnit * cyberRatio * 1.8,   // ~16.2 → Compact screen margins
      buttonPadding: baseUnit * cyberRatio * 1.5,   // ~13.5 → Tech button padding
      inputPadding: baseUnit * cyberRatio,           // ~9.0 → Minimal input padding
    );
  }

  /// Create cyberpunk components with neon aesthetics
  static app_theme_data.ThemeComponents _createCyberComponents() {
    return const app_theme_data.ThemeComponents(
      appBar: app_theme_data.AppBarConfig(
        elevation: 0.0,                          // Flat digital surface
        centerTitle: false,                      // Terminal-style left align
        toolbarHeight: kToolbarHeight,
      ),
      
      card: app_theme_data.CardConfig(
        elevation: 0.0,                          // Flat cyber cards
        borderRadius: 4.0,                       // Sharp cyber corners
        margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        padding: EdgeInsets.all(16.0),          // Compact cyber padding
      ),
      
      button: app_theme_data.ButtonConfig(
        borderRadius: 4.0,                       // Sharp cyber buttons
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
        elevation: 0.0,                          // Flat cyber buttons
        height: 48.0,                            // Standard cyber height
        style: app_theme_data.ButtonStyle.outlined,
      ),
      
      input: app_theme_data.InputConfig(
        borderRadius: 4.0,                       // Sharp cyber inputs
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        borderStyle: app_theme_data.InputBorderStyle.outline,
        filled: false,
      ),
      
      fab: app_theme_data.FABConfig(
        shape: app_theme_data.FABShape.square,   // Square cyber FAB
        elevation: 0.0,                          // Flat cyber floating
        width: 56.0,
        height: 56.0,
      ),
      
      navigation: app_theme_data.NavigationConfig(
        type: app_theme_data.NavigationType.bottomNav,
        elevation: 0.0,                          // Flat cyber navigation
        showLabels: false,                       // Icon-only cyber style
      ),
      
      taskCard: app_theme_data.TaskCardConfig(
        borderRadius: 6.0,                       // Slightly rounded cyber tasks
        margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        padding: EdgeInsets.all(16.0),          // Compact cyber task padding
        elevation: 0.0,                          // Flat cyber tasks
        showPriorityStripe: true,                // Cyber threat indicators
        enableSwipeActions: true,                // Fast cyber interactions
      ),
    );
  }
}

/// Helper class for accessing cyberpunk colors in static context
class _CyberColorsHelper {
  final bool isDark;
  const _CyberColorsHelper({this.isDark = true});
  
  Color get onBackground => isDark 
    ? const Color(0xFFF0F0F0)   // Neon white
    : const Color(0xFF1A1A1A);  // Charcoal text
    
  Color get primary => isDark 
    ? const Color(0xFFFFFF00)   // Neon yellow
    : const Color(0xFFE6E600);  // Dark yellow
    
  Color get cyberMagenta => isDark 
    ? const Color(0xFFFF00FF)   // Full cyber magenta
    : const Color(0xFFCC00CC);  // Darker magenta
}