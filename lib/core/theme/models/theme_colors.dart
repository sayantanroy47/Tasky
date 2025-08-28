import 'package:flutter/material.dart';

/// Comprehensive color palette for themes
class ThemeColors {
  // Primary Colors
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  // Secondary Colors
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;

  // Tertiary Colors
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;

  // Surface Colors
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color inverseSurface;
  final Color onInverseSurface;

  // Background Colors
  final Color background;
  final Color onBackground;

  // Error Colors
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;

  // Special Theme Colors
  final Color accent;
  final Color highlight;
  final Color shadow;
  final Color outline;
  final Color outlineVariant;

  // Stellar Gold Accent Colors (new signature accent) - Optional for pilot
  final Color? stellarGold;
  final Color? onStellarGold;
  final Color? stellarGoldContainer;
  final Color? onStellarGoldContainer;

  // Theme-specific signature accent colors (optional for enhanced visual identity)
  final Color? draculaPurple;
  final Color? onDraculaPurple;
  final Color? draculaPurpleContainer;
  final Color? onDraculaPurpleContainer;

  final Color? cyberpunkNeon;
  final Color? onCyberpunkNeon;
  final Color? cyberpunkNeonContainer;
  final Color? onCyberpunkNeonContainer;

  final Color? vampireBlood;
  final Color? onVampireBlood;
  final Color? vampireBloodContainer;
  final Color? onVampireBloodContainer;

  final Color? matrixGreen;
  final Color? onMatrixGreen;
  final Color? matrixGreenContainer;
  final Color? onMatrixGreenContainer;

  final Color? koiOrange;
  final Color? onKoiOrange;
  final Color? koiOrangeContainer;
  final Color? onKoiOrangeContainer;

  final Color? citrusTangerine;
  final Color? onCitrusTangerine;
  final Color? citrusTangerineContainer;
  final Color? onCitrusTangerineContainer;

  final Color? autumnAmber;
  final Color? onAutumnAmber;
  final Color? autumnAmberContainer;
  final Color? onAutumnAmberContainer;

  final Color? artistTeal;
  final Color? onArtistTeal;
  final Color? artistTealContainer;
  final Color? onArtistTealContainer;

  final Color? demonFlame;
  final Color? onDemonFlame;
  final Color? demonFlameContainer;
  final Color? onDemonFlameContainer;

  final Color? gokuOrange;
  final Color? onGokuOrange;
  final Color? gokuOrangeContainer;
  final Color? onGokuOrangeContainer;

  final Color? vegetaSapphire;
  final Color? onVegetaSapphire;
  final Color? vegetaSapphireContainer;
  final Color? onVegetaSapphireContainer;

  final Color? hollowSilver;
  final Color? onHollowSilver;
  final Color? hollowSilverContainer;
  final Color? onHollowSilverContainer;

  final Color? executiveRose;
  final Color? onExecutiveRose;
  final Color? executiveRoseContainer;
  final Color? onExecutiveRoseContainer;

  final Color? midnightIndigo;
  final Color? onMidnightIndigo;
  final Color? midnightIndigoContainer;
  final Color? onMidnightIndigoContainer;

  final Color? starfieldAqua;
  final Color? onStarfieldAqua;
  final Color? starfieldAquaContainer;
  final Color? onStarfieldAquaContainer;

  final Color? unicornPink;
  final Color? onUnicornPink;
  final Color? unicornPinkContainer;
  final Color? onUnicornPinkContainer;

  // Task Priority Colors
  final Color taskLowPriority;
  final Color taskMediumPriority;
  final Color taskHighPriority;
  final Color taskUrgentPriority;

  // Status Colors
  final Color success;
  final Color warning;
  final Color info;

  // Calendar Dot Colors (for task indicators in calendar)
  final Color calendarTodayDot;
  final Color calendarOverdueDot;
  final Color calendarFutureDot;
  final Color calendarCompletedDot;
  final Color calendarHighPriorityDot;
  
  // Status Badge Colors (for various app status indicators)
  final Color statusPendingBadge;
  final Color statusInProgressBadge;
  final Color statusCompletedBadge;
  final Color statusCancelledBadge;
  final Color statusOverdueBadge;
  final Color statusOnHoldBadge;
  
  // Interactive Colors
  final Color hover;
  final Color pressed;
  final Color focus;
  final Color disabled;

  const ThemeColors({
    // Primary
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,

    // Secondary
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,

    // Tertiary
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,

    // Surface
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.inverseSurface,
    required this.onInverseSurface,

    // Background
    required this.background,
    required this.onBackground,

    // Error
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,

    // Special
    required this.accent,
    required this.highlight,
    required this.shadow,
    required this.outline,
    required this.outlineVariant,

    // Stellar Gold (optional for pilot - only Expressive theme has it)
    this.stellarGold,
    this.onStellarGold,
    this.stellarGoldContainer,
    this.onStellarGoldContainer,

    // Theme-specific signature accent colors (optional)
    this.draculaPurple,
    this.onDraculaPurple,
    this.draculaPurpleContainer,
    this.onDraculaPurpleContainer,
    this.cyberpunkNeon,
    this.onCyberpunkNeon,
    this.cyberpunkNeonContainer,
    this.onCyberpunkNeonContainer,
    this.vampireBlood,
    this.onVampireBlood,
    this.vampireBloodContainer,
    this.onVampireBloodContainer,
    this.matrixGreen,
    this.onMatrixGreen,
    this.matrixGreenContainer,
    this.onMatrixGreenContainer,
    this.koiOrange,
    this.onKoiOrange,
    this.koiOrangeContainer,
    this.onKoiOrangeContainer,
    this.citrusTangerine,
    this.onCitrusTangerine,
    this.citrusTangerineContainer,
    this.onCitrusTangerineContainer,
    this.autumnAmber,
    this.onAutumnAmber,
    this.autumnAmberContainer,
    this.onAutumnAmberContainer,
    this.artistTeal,
    this.onArtistTeal,
    this.artistTealContainer,
    this.onArtistTealContainer,
    this.demonFlame,
    this.onDemonFlame,
    this.demonFlameContainer,
    this.onDemonFlameContainer,
    this.gokuOrange,
    this.onGokuOrange,
    this.gokuOrangeContainer,
    this.onGokuOrangeContainer,
    this.vegetaSapphire,
    this.onVegetaSapphire,
    this.vegetaSapphireContainer,
    this.onVegetaSapphireContainer,
    this.hollowSilver,
    this.onHollowSilver,
    this.hollowSilverContainer,
    this.onHollowSilverContainer,
    this.executiveRose,
    this.onExecutiveRose,
    this.executiveRoseContainer,
    this.onExecutiveRoseContainer,
    this.midnightIndigo,
    this.onMidnightIndigo,
    this.midnightIndigoContainer,
    this.onMidnightIndigoContainer,
    this.starfieldAqua,
    this.onStarfieldAqua,
    this.starfieldAquaContainer,
    this.onStarfieldAquaContainer,
    this.unicornPink,
    this.onUnicornPink,
    this.unicornPinkContainer,
    this.onUnicornPinkContainer,

    // Task Priority
    required this.taskLowPriority,
    required this.taskMediumPriority,
    required this.taskHighPriority,
    required this.taskUrgentPriority,

    // Status
    required this.success,
    required this.warning,
    required this.info,

    // Calendar Dots
    required this.calendarTodayDot,
    required this.calendarOverdueDot,
    required this.calendarFutureDot,
    required this.calendarCompletedDot,
    required this.calendarHighPriorityDot,
    
    // Status Badges
    required this.statusPendingBadge,
    required this.statusInProgressBadge,
    required this.statusCompletedBadge,
    required this.statusCancelledBadge,
    required this.statusOverdueBadge,
    required this.statusOnHoldBadge,

    // Interactive
    required this.hover,
    required this.pressed,
    required this.focus,
    required this.disabled,
  });

  /// Convert to Flutter ColorScheme
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: _getBrightness(),
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      inverseSurface: inverseSurface,
      onInverseSurface: onInverseSurface,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
    );
  }

  /// Determine brightness based on background color
  Brightness _getBrightness() {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Brightness.light : Brightness.dark;
  }

  /// Get priority color by priority level
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return taskLowPriority;
      case 2:
        return taskMediumPriority;
      case 3:
        return taskHighPriority;
      case 4:
        return taskUrgentPriority;
      default:
        return taskMediumPriority;
    }
  }

  /// Create a copy with modified colors
  ThemeColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? onSecondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? tertiary,
    Color? onTertiary,
    Color? tertiaryContainer,
    Color? onTertiaryContainer,
    Color? surface,
    Color? onSurface,
    Color? surfaceVariant,
    Color? onSurfaceVariant,
    Color? inverseSurface,
    Color? onInverseSurface,
    Color? background,
    Color? onBackground,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? accent,
    Color? highlight,
    Color? shadow,
    Color? outline,
    Color? outlineVariant,
    Color? stellarGold,
    Color? onStellarGold,
    Color? stellarGoldContainer,
    Color? onStellarGoldContainer,
    // Theme-specific signature accent colors
    Color? draculaPurple,
    Color? onDraculaPurple,
    Color? draculaPurpleContainer,
    Color? onDraculaPurpleContainer,
    Color? cyberpunkNeon,
    Color? onCyberpunkNeon,
    Color? cyberpunkNeonContainer,
    Color? onCyberpunkNeonContainer,
    Color? vampireBlood,
    Color? onVampireBlood,
    Color? vampireBloodContainer,
    Color? onVampireBloodContainer,
    Color? matrixGreen,
    Color? onMatrixGreen,
    Color? matrixGreenContainer,
    Color? onMatrixGreenContainer,
    Color? koiOrange,
    Color? onKoiOrange,
    Color? koiOrangeContainer,
    Color? onKoiOrangeContainer,
    Color? citrusTangerine,
    Color? onCitrusTangerine,
    Color? citrusTangerineContainer,
    Color? onCitrusTangerineContainer,
    Color? autumnAmber,
    Color? onAutumnAmber,
    Color? autumnAmberContainer,
    Color? onAutumnAmberContainer,
    Color? artistTeal,
    Color? onArtistTeal,
    Color? artistTealContainer,
    Color? onArtistTealContainer,
    Color? demonFlame,
    Color? onDemonFlame,
    Color? demonFlameContainer,
    Color? onDemonFlameContainer,
    Color? gokuOrange,
    Color? onGokuOrange,
    Color? gokuOrangeContainer,
    Color? onGokuOrangeContainer,
    Color? vegetaSapphire,
    Color? onVegetaSapphire,
    Color? vegetaSapphireContainer,
    Color? onVegetaSapphireContainer,
    Color? hollowSilver,
    Color? onHollowSilver,
    Color? hollowSilverContainer,
    Color? onHollowSilverContainer,
    Color? executiveRose,
    Color? onExecutiveRose,
    Color? executiveRoseContainer,
    Color? onExecutiveRoseContainer,
    Color? midnightIndigo,
    Color? onMidnightIndigo,
    Color? midnightIndigoContainer,
    Color? onMidnightIndigoContainer,
    Color? starfieldAqua,
    Color? onStarfieldAqua,
    Color? starfieldAquaContainer,
    Color? onStarfieldAquaContainer,
    Color? unicornPink,
    Color? onUnicornPink,
    Color? unicornPinkContainer,
    Color? onUnicornPinkContainer,
    Color? taskLowPriority,
    Color? taskMediumPriority,
    Color? taskHighPriority,
    Color? taskUrgentPriority,
    Color? success,
    Color? warning,
    Color? info,
    // Calendar dots
    Color? calendarTodayDot,
    Color? calendarOverdueDot,
    Color? calendarFutureDot,
    Color? calendarCompletedDot,
    Color? calendarHighPriorityDot,
    // Status badges
    Color? statusPendingBadge,
    Color? statusInProgressBadge,
    Color? statusCompletedBadge,
    Color? statusCancelledBadge,
    Color? statusOverdueBadge,
    Color? statusOnHoldBadge,
    // Interactive
    Color? hover,
    Color? pressed,
    Color? focus,
    Color? disabled,
  }) {
    return ThemeColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
      tertiary: tertiary ?? this.tertiary,
      onTertiary: onTertiary ?? this.onTertiary,
      tertiaryContainer: tertiaryContainer ?? this.tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer ?? this.onTertiaryContainer,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      onInverseSurface: onInverseSurface ?? this.onInverseSurface,
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      accent: accent ?? this.accent,
      highlight: highlight ?? this.highlight,
      shadow: shadow ?? this.shadow,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      stellarGold: stellarGold ?? this.stellarGold,
      onStellarGold: onStellarGold ?? this.onStellarGold,
      stellarGoldContainer: stellarGoldContainer ?? this.stellarGoldContainer,
      onStellarGoldContainer: onStellarGoldContainer ?? this.onStellarGoldContainer,
      // Theme-specific signature colors
      draculaPurple: draculaPurple ?? this.draculaPurple,
      onDraculaPurple: onDraculaPurple ?? this.onDraculaPurple,
      draculaPurpleContainer: draculaPurpleContainer ?? this.draculaPurpleContainer,
      onDraculaPurpleContainer: onDraculaPurpleContainer ?? this.onDraculaPurpleContainer,
      cyberpunkNeon: cyberpunkNeon ?? this.cyberpunkNeon,
      onCyberpunkNeon: onCyberpunkNeon ?? this.onCyberpunkNeon,
      cyberpunkNeonContainer: cyberpunkNeonContainer ?? this.cyberpunkNeonContainer,
      onCyberpunkNeonContainer: onCyberpunkNeonContainer ?? this.onCyberpunkNeonContainer,
      vampireBlood: vampireBlood ?? this.vampireBlood,
      onVampireBlood: onVampireBlood ?? this.onVampireBlood,
      vampireBloodContainer: vampireBloodContainer ?? this.vampireBloodContainer,
      onVampireBloodContainer: onVampireBloodContainer ?? this.onVampireBloodContainer,
      matrixGreen: matrixGreen ?? this.matrixGreen,
      onMatrixGreen: onMatrixGreen ?? this.onMatrixGreen,
      matrixGreenContainer: matrixGreenContainer ?? this.matrixGreenContainer,
      onMatrixGreenContainer: onMatrixGreenContainer ?? this.onMatrixGreenContainer,
      koiOrange: koiOrange ?? this.koiOrange,
      onKoiOrange: onKoiOrange ?? this.onKoiOrange,
      koiOrangeContainer: koiOrangeContainer ?? this.koiOrangeContainer,
      onKoiOrangeContainer: onKoiOrangeContainer ?? this.onKoiOrangeContainer,
      citrusTangerine: citrusTangerine ?? this.citrusTangerine,
      onCitrusTangerine: onCitrusTangerine ?? this.onCitrusTangerine,
      citrusTangerineContainer: citrusTangerineContainer ?? this.citrusTangerineContainer,
      onCitrusTangerineContainer: onCitrusTangerineContainer ?? this.onCitrusTangerineContainer,
      autumnAmber: autumnAmber ?? this.autumnAmber,
      onAutumnAmber: onAutumnAmber ?? this.onAutumnAmber,
      autumnAmberContainer: autumnAmberContainer ?? this.autumnAmberContainer,
      onAutumnAmberContainer: onAutumnAmberContainer ?? this.onAutumnAmberContainer,
      artistTeal: artistTeal ?? this.artistTeal,
      onArtistTeal: onArtistTeal ?? this.onArtistTeal,
      artistTealContainer: artistTealContainer ?? this.artistTealContainer,
      onArtistTealContainer: onArtistTealContainer ?? this.onArtistTealContainer,
      demonFlame: demonFlame ?? this.demonFlame,
      onDemonFlame: onDemonFlame ?? this.onDemonFlame,
      demonFlameContainer: demonFlameContainer ?? this.demonFlameContainer,
      onDemonFlameContainer: onDemonFlameContainer ?? this.onDemonFlameContainer,
      gokuOrange: gokuOrange ?? this.gokuOrange,
      onGokuOrange: onGokuOrange ?? this.onGokuOrange,
      gokuOrangeContainer: gokuOrangeContainer ?? this.gokuOrangeContainer,
      onGokuOrangeContainer: onGokuOrangeContainer ?? this.onGokuOrangeContainer,
      vegetaSapphire: vegetaSapphire ?? this.vegetaSapphire,
      onVegetaSapphire: onVegetaSapphire ?? this.onVegetaSapphire,
      vegetaSapphireContainer: vegetaSapphireContainer ?? this.vegetaSapphireContainer,
      onVegetaSapphireContainer: onVegetaSapphireContainer ?? this.onVegetaSapphireContainer,
      hollowSilver: hollowSilver ?? this.hollowSilver,
      onHollowSilver: onHollowSilver ?? this.onHollowSilver,
      hollowSilverContainer: hollowSilverContainer ?? this.hollowSilverContainer,
      onHollowSilverContainer: onHollowSilverContainer ?? this.onHollowSilverContainer,
      executiveRose: executiveRose ?? this.executiveRose,
      onExecutiveRose: onExecutiveRose ?? this.onExecutiveRose,
      executiveRoseContainer: executiveRoseContainer ?? this.executiveRoseContainer,
      onExecutiveRoseContainer: onExecutiveRoseContainer ?? this.onExecutiveRoseContainer,
      midnightIndigo: midnightIndigo ?? this.midnightIndigo,
      onMidnightIndigo: onMidnightIndigo ?? this.onMidnightIndigo,
      midnightIndigoContainer: midnightIndigoContainer ?? this.midnightIndigoContainer,
      onMidnightIndigoContainer: onMidnightIndigoContainer ?? this.onMidnightIndigoContainer,
      starfieldAqua: starfieldAqua ?? this.starfieldAqua,
      onStarfieldAqua: onStarfieldAqua ?? this.onStarfieldAqua,
      starfieldAquaContainer: starfieldAquaContainer ?? this.starfieldAquaContainer,
      onStarfieldAquaContainer: onStarfieldAquaContainer ?? this.onStarfieldAquaContainer,
      unicornPink: unicornPink ?? this.unicornPink,
      onUnicornPink: onUnicornPink ?? this.onUnicornPink,
      unicornPinkContainer: unicornPinkContainer ?? this.unicornPinkContainer,
      onUnicornPinkContainer: onUnicornPinkContainer ?? this.onUnicornPinkContainer,
      taskLowPriority: taskLowPriority ?? this.taskLowPriority,
      taskMediumPriority: taskMediumPriority ?? this.taskMediumPriority,
      taskHighPriority: taskHighPriority ?? this.taskHighPriority,
      taskUrgentPriority: taskUrgentPriority ?? this.taskUrgentPriority,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      // Calendar dots
      calendarTodayDot: calendarTodayDot ?? this.calendarTodayDot,
      calendarOverdueDot: calendarOverdueDot ?? this.calendarOverdueDot,
      calendarFutureDot: calendarFutureDot ?? this.calendarFutureDot,
      calendarCompletedDot: calendarCompletedDot ?? this.calendarCompletedDot,
      calendarHighPriorityDot: calendarHighPriorityDot ?? this.calendarHighPriorityDot,
      // Status badges
      statusPendingBadge: statusPendingBadge ?? this.statusPendingBadge,
      statusInProgressBadge: statusInProgressBadge ?? this.statusInProgressBadge,
      statusCompletedBadge: statusCompletedBadge ?? this.statusCompletedBadge,
      statusCancelledBadge: statusCancelledBadge ?? this.statusCancelledBadge,
      statusOverdueBadge: statusOverdueBadge ?? this.statusOverdueBadge,
      statusOnHoldBadge: statusOnHoldBadge ?? this.statusOnHoldBadge,
      // Interactive
      hover: hover ?? this.hover,
      pressed: pressed ?? this.pressed,
      focus: focus ?? this.focus,
      disabled: disabled ?? this.disabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeColors &&
        other.primary == primary &&
        other.secondary == secondary &&
        other.background == background;
  }

  @override
  int get hashCode => Object.hash(primary, secondary, background);
}