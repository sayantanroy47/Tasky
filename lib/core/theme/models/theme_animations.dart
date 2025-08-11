import 'package:flutter/material.dart';

/// Animation configuration for themes
class ThemeAnimations {
  final Duration fast;
  final Duration medium;
  final Duration slow;
  final Duration verySlow;
  
  final Curve primaryCurve;
  final Curve secondaryCurve;
  final Curve entranceCurve;
  final Curve exitCurve;
  
  final bool enableParticles;
  final ParticleConfig particleConfig;
  
  final Map<String, AnimationConfig> customAnimations;

  const ThemeAnimations({
    this.fast = const Duration(milliseconds: 150),
    this.medium = const Duration(milliseconds: 300),
    this.slow = const Duration(milliseconds: 500),
    this.verySlow = const Duration(milliseconds: 800),
    this.primaryCurve = Curves.easeInOut,
    this.secondaryCurve = Curves.easeOut,
    this.entranceCurve = Curves.easeOut,
    this.exitCurve = Curves.easeIn,
    this.enableParticles = true,
    this.particleConfig = const ParticleConfig(),
    this.customAnimations = const {},
  });

  /// Create theme-specific animations
  factory ThemeAnimations.fromThemeStyle(ThemeAnimationStyle style) {
    switch (style) {
      case ThemeAnimationStyle.sharp:
        return const ThemeAnimations(
          fast: Duration(milliseconds: 100),
          medium: Duration(milliseconds: 200),
          slow: Duration(milliseconds: 350),
          verySlow: Duration(milliseconds: 500),
          primaryCurve: Curves.easeInOut,
          secondaryCurve: Curves.bounceOut,
          entranceCurve: Curves.elasticOut,
          exitCurve: Curves.easeInBack,
          particleConfig: ParticleConfig(
            density: ParticleDensity.high,
            speed: ParticleSpeed.fast,
            style: ParticleStyle.geometric,
          ),
        );
      
      case ThemeAnimationStyle.smooth:
        return const ThemeAnimations(
          fast: Duration(milliseconds: 200),
          medium: Duration(milliseconds: 400),
          slow: Duration(milliseconds: 600),
          verySlow: Duration(milliseconds: 1000),
          primaryCurve: Curves.easeInOutCubic,
          secondaryCurve: Curves.decelerate,
          entranceCurve: Curves.easeOutCubic,
          exitCurve: Curves.easeInCubic,
          particleConfig: ParticleConfig(
            density: ParticleDensity.medium,
            speed: ParticleSpeed.medium,
            style: ParticleStyle.organic,
          ),
        );
      
      case ThemeAnimationStyle.digital:
        return const ThemeAnimations(
          fast: Duration(milliseconds: 80),
          medium: Duration(milliseconds: 150),
          slow: Duration(milliseconds: 300),
          verySlow: Duration(milliseconds: 450),
          primaryCurve: Curves.linear,
          secondaryCurve: Curves.easeInOut,
          entranceCurve: Curves.easeOut,
          exitCurve: Curves.easeIn,
          particleConfig: ParticleConfig(
            density: ParticleDensity.high,
            speed: ParticleSpeed.fast,
            style: ParticleStyle.digital,
          ),
        );
    }
  }

  /// Get animation duration by name
  Duration getDuration(String name) {
    switch (name) {
      case 'fast':
        return fast;
      case 'medium':
        return medium;
      case 'slow':
        return slow;
      case 'verySlow':
        return verySlow;
      default:
        return medium;
    }
  }

  /// Get curve by name
  Curve getCurve(String name) {
    switch (name) {
      case 'primary':
        return primaryCurve;
      case 'secondary':
        return secondaryCurve;
      case 'entrance':
        return entranceCurve;
      case 'exit':
        return exitCurve;
      default:
        return primaryCurve;
    }
  }

  /// Create a copy with modified values
  ThemeAnimations copyWith({
    Duration? fast,
    Duration? medium,
    Duration? slow,
    Duration? verySlow,
    Curve? primaryCurve,
    Curve? secondaryCurve,
    Curve? entranceCurve,
    Curve? exitCurve,
    bool? enableParticles,
    ParticleConfig? particleConfig,
    Map<String, AnimationConfig>? customAnimations,
  }) {
    return ThemeAnimations(
      fast: fast ?? this.fast,
      medium: medium ?? this.medium,
      slow: slow ?? this.slow,
      verySlow: verySlow ?? this.verySlow,
      primaryCurve: primaryCurve ?? this.primaryCurve,
      secondaryCurve: secondaryCurve ?? this.secondaryCurve,
      entranceCurve: entranceCurve ?? this.entranceCurve,
      exitCurve: exitCurve ?? this.exitCurve,
      enableParticles: enableParticles ?? this.enableParticles,
      particleConfig: particleConfig ?? this.particleConfig,
      customAnimations: customAnimations ?? this.customAnimations,
    );
  }
}

/// Animation style presets
enum ThemeAnimationStyle {
  sharp,   // Quick, bouncy animations (Vegeta theme)
  smooth,  // Slow, elegant animations (Dracula theme)
  digital, // Linear, fast animations (Matrix theme)
}

/// Particle system configuration
class ParticleConfig {
  final ParticleDensity density;
  final ParticleSpeed speed;
  final ParticleStyle style;
  final bool enableGlow;
  final double opacity;
  final double size;

  const ParticleConfig({
    this.density = ParticleDensity.medium,
    this.speed = ParticleSpeed.medium,
    this.style = ParticleStyle.organic,
    this.enableGlow = true,
    this.opacity = 0.7,
    this.size = 1.0,
  });
}

/// Particle density levels
enum ParticleDensity {
  none,
  low,
  medium,
  high,
  ultra,
}

/// Particle movement speed
enum ParticleSpeed {
  verySlow,
  slow,
  medium,
  fast,
  veryFast,
}

/// Particle visual style
enum ParticleStyle {
  organic,    // Smooth, rounded particles
  geometric,  // Sharp, angular particles
  digital,    // Pixelated, code-like particles
}

/// Custom animation configuration
class AnimationConfig {
  final Duration duration;
  final Curve curve;
  final bool reverse;
  final bool repeat;
  final int repeatCount;

  const AnimationConfig({
    required this.duration,
    this.curve = Curves.easeInOut,
    this.reverse = false,
    this.repeat = false,
    this.repeatCount = 1,
  });
}