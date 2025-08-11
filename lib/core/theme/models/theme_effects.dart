import 'package:flutter/material.dart';

/// Visual effects configuration for themes
class ThemeEffects {
  final ShadowStyle shadowStyle;
  final GradientStyle gradientStyle;
  final BorderStyle borderStyle;
  final BlurConfig blurConfig;
  final GlowConfig glowConfig;
  final BackgroundEffectConfig backgroundEffects;

  const ThemeEffects({
    this.shadowStyle = ShadowStyle.subtle,
    this.gradientStyle = GradientStyle.none,
    this.borderStyle = BorderStyle.rounded,
    this.blurConfig = const BlurConfig(),
    this.glowConfig = const GlowConfig(),
    this.backgroundEffects = const BackgroundEffectConfig(),
  });

  /// Create theme-specific effects
  factory ThemeEffects.fromEffectStyle(ThemeEffectStyle style) {
    switch (style) {
      case ThemeEffectStyle.dramatic:
        return const ThemeEffects(
          shadowStyle: ShadowStyle.dramatic,
          gradientStyle: GradientStyle.metallic,
          borderStyle: BorderStyle.angular,
          blurConfig: BlurConfig(enabled: false),
          glowConfig: GlowConfig(
            enabled: true,
            intensity: 0.8,
            spread: 4.0,
          ),
          backgroundEffects: BackgroundEffectConfig(
            enableParticles: true,
            enableGradientMesh: true,
            particleType: BackgroundParticleType.energy,
          ),
        );

      case ThemeEffectStyle.digital:
        return const ThemeEffects(
          shadowStyle: ShadowStyle.none,
          gradientStyle: GradientStyle.none,
          borderStyle: BorderStyle.sharp,
          blurConfig: BlurConfig(enabled: false),
          glowConfig: GlowConfig(
            enabled: true,
            intensity: 1.0,
            spread: 2.0,
          ),
          backgroundEffects: BackgroundEffectConfig(
            enableScanlines: true,
            enableParticles: true,
            particleType: BackgroundParticleType.codeRain,
          ),
        );

      case ThemeEffectStyle.elegant:
        return const ThemeEffects(
          shadowStyle: ShadowStyle.soft,
          gradientStyle: GradientStyle.subtle,
          borderStyle: BorderStyle.rounded,
          blurConfig: BlurConfig(
            enabled: true,
            intensity: 2.0,
          ),
          glowConfig: GlowConfig(
            enabled: true,
            intensity: 0.3,
            spread: 8.0,
          ),
          backgroundEffects: BackgroundEffectConfig(
            enableParticles: true,
            particleType: BackgroundParticleType.floating,
          ),
        );
    }
  }

  /// Get shadow list based on style and elevation
  List<BoxShadow> getShadows(double elevation, Color shadowColor) {
    switch (shadowStyle) {
      case ShadowStyle.none:
        return [];
      
      case ShadowStyle.subtle:
        return [
          BoxShadow(
            color: shadowColor.withOpacity(0.1),
            offset: Offset(0, elevation * 0.5),
            blurRadius: elevation * 2,
            spreadRadius: 0,
          ),
        ];
      
      case ShadowStyle.soft:
        return [
          BoxShadow(
            color: shadowColor.withOpacity(0.15),
            offset: Offset(0, elevation * 0.5),
            blurRadius: elevation * 3,
            spreadRadius: elevation * 0.5,
          ),
          BoxShadow(
            color: shadowColor.withOpacity(0.05),
            offset: Offset(0, elevation),
            blurRadius: elevation * 6,
            spreadRadius: 0,
          ),
        ];
      
      case ShadowStyle.dramatic:
        return [
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            offset: Offset(0, elevation),
            blurRadius: elevation * 4,
            spreadRadius: elevation * 0.5,
          ),
          BoxShadow(
            color: shadowColor.withOpacity(0.1),
            offset: Offset(0, elevation * 2),
            blurRadius: elevation * 8,
            spreadRadius: 0,
          ),
        ];
    }
  }

  /// Get border radius based on style
  BorderRadius getBorderRadius(double radius) {
    switch (borderStyle) {
      case BorderStyle.sharp:
        return BorderRadius.zero;
      case BorderStyle.rounded:
        return BorderRadius.circular(radius);
      case BorderStyle.angular:
        return BorderRadius.only(
          topLeft: Radius.circular(radius * 0.3),
          topRight: Radius.circular(radius),
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius * 0.3),
        );
    }
  }

  /// Create a copy with modified effects
  ThemeEffects copyWith({
    ShadowStyle? shadowStyle,
    GradientStyle? gradientStyle,
    BorderStyle? borderStyle,
    BlurConfig? blurConfig,
    GlowConfig? glowConfig,
    BackgroundEffectConfig? backgroundEffects,
  }) {
    return ThemeEffects(
      shadowStyle: shadowStyle ?? this.shadowStyle,
      gradientStyle: gradientStyle ?? this.gradientStyle,
      borderStyle: borderStyle ?? this.borderStyle,
      blurConfig: blurConfig ?? this.blurConfig,
      glowConfig: glowConfig ?? this.glowConfig,
      backgroundEffects: backgroundEffects ?? this.backgroundEffects,
    );
  }
}

/// Effect style presets
enum ThemeEffectStyle {
  dramatic, // Strong shadows, metallic gradients (Vegeta)
  digital,  // No shadows, sharp edges, glows (Matrix)
  elegant,  // Soft shadows, subtle effects (Dracula)
}

/// Shadow styles
enum ShadowStyle {
  none,
  subtle,
  soft,
  dramatic,
}

/// Gradient styles
enum GradientStyle {
  none,
  subtle,
  metallic,
}

/// Border styles
enum BorderStyle {
  sharp,
  rounded,
  angular,
}

/// Blur effect configuration
class BlurConfig {
  final bool enabled;
  final double intensity;
  final BlurStyle style;

  const BlurConfig({
    this.enabled = false,
    this.intensity = 1.0,
    this.style = BlurStyle.normal,
  });
}

/// Blur styles
enum BlurStyle {
  normal,
  inner,
  outer,
}

/// Glow effect configuration
class GlowConfig {
  final bool enabled;
  final double intensity;
  final double spread;
  final GlowStyle style;

  const GlowConfig({
    this.enabled = false,
    this.intensity = 0.5,
    this.spread = 4.0,
    this.style = GlowStyle.outer,
  });
}

/// Glow styles
enum GlowStyle {
  outer,
  inner,
  both,
}

/// Background effect configuration
class BackgroundEffectConfig {
  final bool enableParticles;
  final bool enableGradientMesh;
  final bool enableScanlines;
  final BackgroundParticleType particleType;
  final double particleOpacity;
  final double effectIntensity;

  const BackgroundEffectConfig({
    this.enableParticles = false,
    this.enableGradientMesh = false,
    this.enableScanlines = false,
    this.particleType = BackgroundParticleType.floating,
    this.particleOpacity = 0.1,
    this.effectIntensity = 0.5,
  });
}

/// Background particle types
enum BackgroundParticleType {
  floating,   // Subtle floating particles (Dracula)
  energy,     // Energy orbs and particles (Vegeta)
  codeRain,   // Falling code characters (Matrix)
}