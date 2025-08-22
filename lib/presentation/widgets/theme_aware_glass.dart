import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'glassmorphism_container.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/theme/material3/motion_system.dart';
import '../../core/design_system/design_tokens.dart';

/// Theme-aware glassmorphism container that adapts to different themes
class ThemeAwareGlass extends StatefulWidget {
  final Widget child;
  final GlassLevel level;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final String? themeName;
  final bool enableThemeEffects;
  final bool enableHoverEnhancements;
  final bool enablePulseEffects;
  
  const ThemeAwareGlass({
    super.key,
    required this.child,
    this.level = GlassLevel.content,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.themeName,
    this.enableThemeEffects = true,
    this.enableHoverEnhancements = true,
    this.enablePulseEffects = false,
  });

  @override
  State<ThemeAwareGlass> createState() => _ThemeAwareGlassState();
}

class _ThemeAwareGlassState extends State<ThemeAwareGlass>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _hoverController;
  late AnimationController _specialController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _hoverAnimation;
  late Animation<double> _specialAnimation;

  ThemeVariant? _themeVariant;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _determineTheme();
  }

  @override
  void didUpdateWidget(ThemeAwareGlass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeName != widget.themeName) {
      _determineTheme();
    }
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _hoverController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium2,
      vsync: this,
    );

    _specialController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: ExpressiveMotionSystem.standard,
    ));

    _specialAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _specialController,
      curve: Curves.easeInOut,
    ));

    if (widget.enablePulseEffects) {
      _pulseController.repeat(reverse: true);
    }

    _specialController.repeat();
  }

  void _determineTheme() {
    final themeName = widget.themeName?.toLowerCase() ?? 
                     Theme.of(context).toString().toLowerCase();
    
    if (themeName.contains('matrix')) {
      _themeVariant = ThemeVariant.matrix;
    } else if (themeName.contains('vegeta') || themeName.contains('blue')) {
      _themeVariant = ThemeVariant.vegeta;
    } else if (themeName.contains('dracula')) {
      _themeVariant = ThemeVariant.dracula;
    } else {
      _themeVariant = ThemeVariant.defaultTheme;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _hoverController.dispose();
    _specialController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (!widget.enableHoverEnhancements) return;
    
    setState(() => _isHovered = isHovered);
    
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation,
          _hoverAnimation,
          _specialAnimation,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Base glassmorphism container
              _buildBaseGlass(theme),
              
              // Theme-specific overlay effects
              if (widget.enableThemeEffects && _themeVariant != null)
                _buildThemeOverlay(theme),
              
              // Hover enhancement overlay
              if (_isHovered && widget.enableHoverEnhancements)
                _buildHoverOverlay(theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBaseGlass(ThemeData theme) {
    final baseConfig = _getThemeConfig(_themeVariant ?? ThemeVariant.defaultTheme);
    
    return GlassmorphismContainer(
      level: widget.level,
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      margin: widget.margin,
      borderRadius: widget.borderRadius,
      glassTint: _getAnimatedGlassTint(theme, baseConfig),
      borderColor: _getAnimatedBorderColor(theme, baseConfig),
      child: widget.child,
    );
  }

  Widget _buildThemeOverlay(ThemeData theme) {
    final config = _getThemeConfig(_themeVariant!);
    
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ??
              BorderRadius.circular(TypographyConstants.radiusSmall),
          gradient: _buildThemeGradient(config),
        ),
        child: CustomPaint(
          painter: _getThemePainter(config),
        ),
      ),
    );
  }

  Widget _buildHoverOverlay(ThemeData theme) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ??
              BorderRadius.circular(TypographyConstants.radiusSmall),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 
              0.3 * _hoverAnimation.value,
            ),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 
                0.2 * _hoverAnimation.value,
              ),
              blurRadius: 10 * _hoverAnimation.value,
              spreadRadius: 2 * _hoverAnimation.value,
            ),
          ],
        ),
      ),
    );
  }

  Color _getAnimatedGlassTint(ThemeData theme, ThemeGlassConfig config) {
    final baseTint = config.glassTint ?? theme.colorScheme.surface.withValues(alpha: 0.1);
    final intensity = widget.enablePulseEffects ? _pulseAnimation.value : 1.0;
    
    return Color.lerp(
      baseTint,
      config.accentColor ?? theme.colorScheme.primary,
      0.1 * intensity * (widget.enableHoverEnhancements && _isHovered ? 2.0 : 1.0),
    ) ?? baseTint;
  }

  Color _getAnimatedBorderColor(ThemeData theme, ThemeGlassConfig config) {
    final baseBorder = config.borderColor ?? theme.colorScheme.outline.withValues(alpha: 0.2);
    final intensity = widget.enablePulseEffects ? _pulseAnimation.value : 1.0;
    
    return baseBorder.withValues(alpha: 
      baseBorder.opacity * intensity * (widget.enableHoverEnhancements && _isHovered ? 1.5 : 1.0),
    );
  }

  LinearGradient? _buildThemeGradient(ThemeGlassConfig config) {
    if (!config.hasGradientOverlay) return null;
    
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.transparent,
        (config.accentColor ?? Colors.blue).withValues(alpha: 
          0.05 * _specialAnimation.value,
        ),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  CustomPainter? _getThemePainter(ThemeGlassConfig config) {
    switch (_themeVariant!) {
      case ThemeVariant.matrix:
        return _MatrixEffectPainter(
          progress: _specialAnimation.value,
          color: config.accentColor ?? const Color(0xFF00FF41),
        );
      case ThemeVariant.vegeta:
        return _EnergyEffectPainter(
          progress: _specialAnimation.value,
          color: config.accentColor ?? const Color(0xFF3B82F6),
        );
      case ThemeVariant.dracula:
        return _PsychedelicEffectPainter(
          progress: _specialAnimation.value,
          colors: [
            const Color(0xFFBD93F9),
            const Color(0xFFFF79C6),
            const Color(0xFF8BE9FD),
          ],
        );
      case ThemeVariant.defaultTheme:
        return null;
    }
  }

  ThemeGlassConfig _getThemeConfig(ThemeVariant variant) {
    switch (variant) {
      case ThemeVariant.matrix:
        return ThemeGlassConfig.matrix();
      case ThemeVariant.vegeta:
        return ThemeGlassConfig.vegeta();
      case ThemeVariant.dracula:
        return ThemeGlassConfig.dracula();
      case ThemeVariant.defaultTheme:
        return ThemeGlassConfig.defaultTheme();
    }
  }
}

/// Theme variant enumeration
enum ThemeVariant {
  matrix,
  vegeta,
  dracula,
  defaultTheme,
}

/// Theme-specific glass configuration
class ThemeGlassConfig {
  final Color? glassTint;
  final Color? borderColor;
  final Color? accentColor;
  final bool hasGradientOverlay;
  final bool hasPulseEffect;
  final double intensity;

  const ThemeGlassConfig({
    this.glassTint,
    this.borderColor,
    this.accentColor,
    this.hasGradientOverlay = false,
    this.hasPulseEffect = false,
    this.intensity = 1.0,
  });

  factory ThemeGlassConfig.matrix() {
    return ThemeGlassConfig(
      glassTint: const Color(0xFF00FF41).withValues(alpha: 0.1),
      borderColor: const Color(0xFF00FF41).withValues(alpha: 0.3),
      accentColor: const Color(0xFF00FF41),
      hasGradientOverlay: true,
      hasPulseEffect: true,
      intensity: 1.2,
    );
  }

  factory ThemeGlassConfig.vegeta() {
    return ThemeGlassConfig(
      glassTint: const Color(0xFF3B82F6).withValues(alpha: 0.1),
      borderColor: const Color(0xFF60A5FA).withValues(alpha: 0.4),
      accentColor: const Color(0xFF3B82F6),
      hasGradientOverlay: true,
      hasPulseEffect: false,
      intensity: 1.0,
    );
  }

  factory ThemeGlassConfig.dracula() {
    return ThemeGlassConfig(
      glassTint: const Color(0xFFBD93F9).withValues(alpha: 0.1),
      borderColor: const Color(0xFFFF79C6).withValues(alpha: 0.3),
      accentColor: const Color(0xFFBD93F9),
      hasGradientOverlay: true,
      hasPulseEffect: true,
      intensity: 1.1,
    );
  }

  factory ThemeGlassConfig.defaultTheme() {
    return ThemeGlassConfig(
      glassTint: Colors.grey.withValues(alpha: 0.1),
      borderColor: Colors.grey.withValues(alpha: 0.2),
      accentColor: Colors.blue,
      hasGradientOverlay: false,
      hasPulseEffect: false,
      intensity: 1.0,
    );
  }
}

/// Matrix theme effect painter
class _MatrixEffectPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _MatrixEffectPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3 * math.sin(progress * 2 * math.pi))
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw matrix-like grid
    const gridSize = 20.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Vegeta theme energy effect painter
class _EnergyEffectPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _EnergyEffectPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw energy waves
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width > size.height ? size.width : size.height) * 0.5;
    
    for (int i = 0; i < 3; i++) {
      final waveRadius = radius * (0.3 + i * 0.2) * (1 + progress);
      final opacity = (1 - progress) * (1 - i * 0.3);
      
      final wavePaint = Paint()
        ..color = color.withValues(alpha: 0.1 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawCircle(center, waveRadius, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Dracula theme psychedelic effect painter
class _PsychedelicEffectPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  const _PsychedelicEffectPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw swirling colors
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.width > size.height ? size.width : size.height) * 0.5;

    for (int i = 0; i < colors.length; i++) {
      final angle = (progress * 2 * math.pi) + (i * 2 * math.pi / colors.length);
      final radius = maxRadius * 0.3;
      
      final position = Offset(
        center.dx + math.cos(angle) * radius * 0.5,
        center.dy + math.sin(angle) * radius * 0.5,
      );
      
      final paint = Paint()
        ..color = colors[i].withValues(alpha: 0.1 * math.sin(progress * math.pi))
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(position, 20, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}