import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/material3/motion_system.dart';

/// Dynamic background with theme-specific particle systems and effects
class DynamicThemeBackground extends StatefulWidget {
  final Widget child;
  final String themeName;
  final bool enableParticles;
  final bool enableDynamicBlur;
  final double baseBlur;
  final ParticleStyle particleStyle;
  
  const DynamicThemeBackground({
    super.key,
    required this.child,
    required this.themeName,
    this.enableParticles = true,
    this.enableDynamicBlur = true,
    this.baseBlur = 0.0,
    this.particleStyle = ParticleStyle.floating,
  });

  @override
  State<DynamicThemeBackground> createState() => _DynamicThemeBackgroundState();
}

class _DynamicThemeBackgroundState extends State<DynamicThemeBackground>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _blurController;
  late AnimationController _pulseController;
  
  List<Particle> _particles = [];
  late ThemeConfig _themeConfig;
  
  @override
  void initState() {
    super.initState();
    _setupThemeConfig();
    _setupAnimations();
    _generateParticles();
    _startAnimations();
  }

  void _setupThemeConfig() {
    _themeConfig = _getThemeConfig(widget.themeName);
  }

  void _setupAnimations() {
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _blurController = AnimationController(
      duration: ExpressiveMotionSystem.durationLong4,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  void _generateParticles() {
    if (!widget.enableParticles) return;
    
    final random = math.Random();
    _particles = List.generate(_themeConfig.particleCount, (index) {
      return Particle(
        position: Offset(
          random.nextDouble(),
          random.nextDouble(),
        ),
        velocity: Offset(
          (random.nextDouble() - 0.5) * _themeConfig.particleSpeed,
          (random.nextDouble() - 0.5) * _themeConfig.particleSpeed,
        ),
        size: _themeConfig.particleMinSize + 
               random.nextDouble() * (_themeConfig.particleMaxSize - _themeConfig.particleMinSize),
        opacity: _themeConfig.particleOpacity,
        color: _themeConfig.particleColors[random.nextInt(_themeConfig.particleColors.length)],
        phase: random.nextDouble() * 2 * math.pi,
      );
    });
  }

  void _startAnimations() {
    _particleController.repeat();
    _pulseController.repeat();
    
    if (widget.enableDynamicBlur) {
      _blurController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    _blurController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base background
        Container(
          decoration: BoxDecoration(
            gradient: _themeConfig.backgroundGradient,
          ),
        ),
        
        // Particle system
        if (widget.enableParticles)
          AnimatedBuilder(
            animation: Listenable.merge([
              _particleController,
              _pulseController,
            ]),
            builder: (context, child) {
              return CustomPaint(
                painter: _ParticleSystemPainter(
                  particles: _particles,
                  animationValue: _particleController.value,
                  pulseValue: _pulseController.value,
                  themeConfig: _themeConfig,
                  particleStyle: widget.particleStyle,
                ),
                size: Size.infinite,
              );
            },
          ),
        
        // Dynamic blur overlay
        if (widget.enableDynamicBlur)
          AnimatedBuilder(
            animation: _blurController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.transparent,
                      _themeConfig.accentColor.withValues(alpha: 
                        0.05 + _blurController.value * 0.03,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
        
        // Content
        widget.child,
      ],
    );
  }

  ThemeConfig _getThemeConfig(String themeName) {
    switch (themeName.toLowerCase()) {
      case 'matrix':
        return ThemeConfig.matrix();
      case 'vegeta':
      case 'vegeta_blue':
        return ThemeConfig.vegeta();
      case 'dracula':
      case 'dracula_ide':
        return ThemeConfig.dracula();
      default:
        return ThemeConfig.defaultTheme();
    }
  }
}

/// Particle system painter
class _ParticleSystemPainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  final double pulseValue;
  final ThemeConfig themeConfig;
  final ParticleStyle particleStyle;

  _ParticleSystemPainter({
    required this.particles,
    required this.animationValue,
    required this.pulseValue,
    required this.themeConfig,
    required this.particleStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < particles.length; i++) {
      final particle = particles[i];
      _updateParticle(particle, size);
      _drawParticle(canvas, particle, size);
    }
  }

  void _updateParticle(Particle particle, Size size) {
    // Update position
    particle.position += particle.velocity * 0.01;
    
    // Wrap around edges
    if (particle.position.dx < 0) particle.position = Offset(1.0, particle.position.dy);
    if (particle.position.dx > 1) particle.position = Offset(0.0, particle.position.dy);
    if (particle.position.dy < 0) particle.position = Offset(particle.position.dx, 1.0);
    if (particle.position.dy > 1) particle.position = Offset(particle.position.dx, 0.0);
    
    // Update phase for pulsing effect
    particle.phase += 0.05;
  }

  void _drawParticle(Canvas canvas, Particle particle, Size size) {
    final position = Offset(
      particle.position.dx * size.width,
      particle.position.dy * size.height,
    );

    final pulseMultiplier = 1.0 + math.sin(particle.phase + pulseValue * 2 * math.pi) * 0.3;
    final effectiveSize = particle.size * pulseMultiplier;
    final effectiveOpacity = particle.opacity * (0.7 + pulseMultiplier * 0.3);

    final paint = Paint()
      ..color = particle.color.withValues(alpha: effectiveOpacity)
      ..style = PaintingStyle.fill;

    switch (particleStyle) {
      case ParticleStyle.floating:
        // Simple circle particles
        canvas.drawCircle(position, effectiveSize / 2, paint);
        break;
        
      case ParticleStyle.glowing:
        // Particles with glow effect
        final glowPaint = Paint()
          ..color = particle.color.withValues(alpha: effectiveOpacity * 0.3)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
        
        canvas.drawCircle(position, effectiveSize, glowPaint);
        canvas.drawCircle(position, effectiveSize / 2, paint);
        break;
        
      case ParticleStyle.geometric:
        // Geometric shape particles
        final path = Path();
        const sides = 6; // Hexagon
        const angle = 2 * math.pi / sides;
        
        for (int i = 0; i < sides; i++) {
          final x = position.dx + effectiveSize * math.cos(i * angle + particle.phase);
          final y = position.dy + effectiveSize * math.sin(i * angle + particle.phase);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
        break;
        
      case ParticleStyle.matrix:
        // Matrix-style digital particles
        final textPainter = TextPainter(
          text: TextSpan(
            text: _getMatrixChar(),
            style: TextStyle(
              color: particle.color.withValues(alpha: effectiveOpacity),
              fontSize: effectiveSize,
              fontFamily: 'Courier',
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, position);
        break;
    }
  }

  String _getMatrixChar() {
    final chars = ['0', '1', 'ア', 'イ', 'ウ', 'エ', 'オ', 'カ', 'キ', 'ク'];
    return chars[math.Random().nextInt(chars.length)];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Particle data class
class Particle {
  Offset position;
  Offset velocity;
  double size;
  double opacity;
  Color color;
  double phase;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.color,
    required this.phase,
  });
}

/// Theme configuration for different themes
class ThemeConfig {
  final Gradient backgroundGradient;
  final List<Color> particleColors;
  final int particleCount;
  final double particleSpeed;
  final double particleMinSize;
  final double particleMaxSize;
  final double particleOpacity;
  final Color accentColor;

  ThemeConfig({
    required this.backgroundGradient,
    required this.particleColors,
    required this.particleCount,
    required this.particleSpeed,
    required this.particleMinSize,
    required this.particleMaxSize,
    required this.particleOpacity,
    required this.accentColor,
  });

  factory ThemeConfig.matrix() {
    return ThemeConfig(
      backgroundGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0D1B0D),
          Color(0xFF1A2F1A),
          Color(0xFF0D1B0D),
        ],
      ),
      particleColors: [
        const Color(0xFF00FF41),
        const Color(0xFF00CC33),
        const Color(0xFF008F11),
      ],
      particleCount: 50,
      particleSpeed: 0.5,
      particleMinSize: 2.0,
      particleMaxSize: 4.0,
      particleOpacity: 0.7,
      accentColor: const Color(0xFF00FF41),
    );
  }

  factory ThemeConfig.vegeta() {
    return ThemeConfig(
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0A0E3F),
          Color(0xFF1E3A8A),
          Color(0xFF3B82F6),
          Color(0xFF1E3A8A),
        ],
      ),
      particleColors: [
        const Color(0xFF60A5FA),
        const Color(0xFF93C5FD),
        const Color(0xFFDDD6FE),
      ],
      particleCount: 30,
      particleSpeed: 0.3,
      particleMinSize: 1.5,
      particleMaxSize: 3.0,
      particleOpacity: 0.6,
      accentColor: const Color(0xFF3B82F6),
    );
  }

  factory ThemeConfig.dracula() {
    return ThemeConfig(
      backgroundGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF282A36),
          Color(0xFF44475A),
          Color(0xFF282A36),
        ],
      ),
      particleColors: [
        const Color(0xFFBD93F9),
        const Color(0xFFFF79C6),
        const Color(0xFF8BE9FD),
        const Color(0xFF50FA7B),
      ],
      particleCount: 40,
      particleSpeed: 0.4,
      particleMinSize: 2.0,
      particleMaxSize: 5.0,
      particleOpacity: 0.5,
      accentColor: const Color(0xFFBD93F9),
    );
  }

  factory ThemeConfig.defaultTheme() {
    return ThemeConfig(
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF8FAFC),
          Color(0xFFE2E8F0),
          Color(0xFFF1F5F9),
        ],
      ),
      particleColors: [
        const Color(0xFF64748B),
        const Color(0xFF94A3B8),
        const Color(0xFFCBD5E1),
      ],
      particleCount: 20,
      particleSpeed: 0.2,
      particleMinSize: 1.0,
      particleMaxSize: 2.0,
      particleOpacity: 0.3,
      accentColor: const Color(0xFF3B82F6),
    );
  }
}

/// Particle style enumeration
enum ParticleStyle {
  floating,   // Simple floating circles
  glowing,    // Particles with glow effect
  geometric,  // Geometric shapes
  matrix,     // Matrix-style characters
}