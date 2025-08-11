import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/theme_effects.dart';

/// Base class for background effect painters
abstract class BackgroundEffectPainter extends CustomPainter {
  final Animation<double>? animation; // Made optional for static backgrounds
  final Color primaryColor;
  final Color secondaryColor;
  final BackgroundEffectConfig config;
  final double opacity;

  BackgroundEffectPainter({
    this.animation, // Optional for static backgrounds
    required this.primaryColor,
    required this.secondaryColor,
    required this.config,
    this.opacity = 1.0,
  }); // Removed repaint: animation for static backgrounds

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false; // Static backgrounds don't need repainting
}

/// Static metallic gradient mesh for Vegeta theme
class MetallicGradientMeshPainter extends BackgroundEffectPainter {
  late final math.Random _random;

  MetallicGradientMeshPainter({
    super.animation, // Optional now
    required super.primaryColor,
    required super.secondaryColor,
    required super.config,
    super.opacity,
  }) {
    _random = math.Random(42); // Fixed seed for consistent pattern
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!config.enableGradientMesh) return;
    
    // Create static base metallic gradient
    _paintStaticMetallicBase(canvas, size);
    
    // Add static energy wave pattern
    _paintStaticEnergyWaves(canvas, size);
    
    // Add geometric patterns
    _paintStaticGeometricPattern(canvas, size);
  }

  void _paintStaticMetallicBase(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    
    // Static diagonal gradient
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor.withOpacity(opacity * config.effectIntensity * 0.08),
        secondaryColor.withOpacity(opacity * config.effectIntensity * 0.12),
        primaryColor.withOpacity(opacity * config.effectIntensity * 0.06),
        secondaryColor.withOpacity(opacity * config.effectIntensity * 0.10),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _paintStaticEnergyWaves(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..blendMode = BlendMode.screen;

    // Draw multiple static energy wave patterns
    for (int i = 0; i < 4; i++) {
      final waveOffset = i * 80.0;
      final path = Path();
      
      for (double x = 0; x <= size.width; x += 8) {
        final y = size.height * (0.2 + i * 0.2) + 
                 math.sin((x + waveOffset) * 0.015) * 25 +
                 math.sin((x + waveOffset) * 0.03) * 12;
        
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      paint.color = primaryColor.withOpacity(
        opacity * config.effectIntensity * 0.2 * (1.0 - i * 0.15)
      );
      
      canvas.drawPath(path, paint);
    }
  }

  void _paintStaticGeometricPattern(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = secondaryColor.withOpacity(opacity * config.effectIntensity * 0.15);

    const hexSize = 30.0;
    const spacing = hexSize * 1.2;
    
    for (double x = -hexSize; x < size.width + hexSize; x += spacing) {
      for (double y = -hexSize; y < size.height + hexSize; y += spacing * 0.866) {
        final offsetX = (y / (spacing * 0.866)).floor() % 2 == 1 ? spacing * 0.5 : 0.0;
        _drawHexagon(canvas, Offset(x + offsetX, y), hexSize * 0.25, paint);
      }
    }
    
    // Add some diamond accents
    _paintStaticDiamondAccents(canvas, size);
  }
  
  void _paintStaticDiamondAccents(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withOpacity(opacity * config.effectIntensity * 0.1);
    
    // Add scattered diamond shapes for accent
    for (int i = 0; i < 8; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      final diamondSize = _random.nextDouble() * 15 + 8;
      _drawDiamond(canvas, Offset(x, y), diamondSize, paint);
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60.0) * math.pi / 180.0;
      final x = center.dx + size * math.cos(angle);
      final y = center.dy + size * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size, center.dy);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx - size, center.dy);
    path.close();
    
    canvas.drawPath(path, paint);
  }
}


/// Static subtle elements for Dracula theme
class SubtleFloatingElementsPainter extends BackgroundEffectPainter {
  late final List<StaticFloatingElement> _elements;
  late final math.Random _random;

  SubtleFloatingElementsPainter({
    super.animation, // Optional now
    required super.primaryColor,
    required super.secondaryColor,
    required super.config,
    super.opacity,
  }) {
    _random = math.Random(123); // Fixed seed
    _initializeStaticElements();
  }

  void _initializeStaticElements() {
    _elements = List.generate(18, (index) {
      return StaticFloatingElement(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 25 + 8,
        opacity: _random.nextDouble() * 0.25 + 0.08,
        shape: FloatingElementShape.values[_random.nextInt(FloatingElementShape.values.length)],
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!config.enableParticles) return;

    for (final element in _elements) {
      _paintStaticFloatingElement(canvas, size, element);
    }
    
    // Add subtle gradient overlay
    _paintGradientOverlay(canvas, size);
  }

  void _paintStaticFloatingElement(Canvas canvas, Size size, StaticFloatingElement element) {
    final x = element.x * size.width;
    final y = element.y * size.height;
    
    // Create both filled and stroke paints for more visibility
    final strokePaint = Paint()
      ..color = primaryColor.withOpacity(
        opacity * config.effectIntensity * element.opacity * 2.0
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
      
    final fillPaint = Paint()
      ..color = secondaryColor.withOpacity(
        opacity * config.effectIntensity * element.opacity * 0.8
      )
      ..style = PaintingStyle.fill;

    final center = Offset(x, y);
    final currentSize = element.size * 0.4;

    switch (element.shape) {
      case FloatingElementShape.circle:
        // Draw filled circle first
        canvas.drawCircle(center, currentSize * 0.7, fillPaint);
        // Then stroke outline
        canvas.drawCircle(center, currentSize, strokePaint);
        // Add inner circle for some elements
        if (element.opacity > 0.15) {
          strokePaint.strokeWidth = 0.8;
          canvas.drawCircle(center, currentSize * 0.6, strokePaint);
        }
        break;
      case FloatingElementShape.square:
        final rect = Rect.fromCenter(center: center, width: currentSize * 2, height: currentSize * 2);
        // Draw filled square first
        canvas.drawRect(rect, fillPaint);
        // Then stroke outline
        canvas.drawRect(rect, strokePaint);
        break;
      case FloatingElementShape.diamond:
        final path = Path();
        path.moveTo(center.dx, center.dy - currentSize);
        path.lineTo(center.dx + currentSize, center.dy);
        path.lineTo(center.dx, center.dy + currentSize);
        path.lineTo(center.dx - currentSize, center.dy);
        path.close();
        // Draw filled diamond first
        canvas.drawPath(path, fillPaint);
        // Then stroke outline
        canvas.drawPath(path, strokePaint);
        break;
      case FloatingElementShape.triangle:
        final path = Path();
        path.moveTo(center.dx, center.dy - currentSize);
        path.lineTo(center.dx - currentSize * 0.866, center.dy + currentSize * 0.5);
        path.lineTo(center.dx + currentSize * 0.866, center.dy + currentSize * 0.5);
        path.close();
        // Draw filled triangle first
        canvas.drawPath(path, fillPaint);
        // Then stroke outline
        canvas.drawPath(path, strokePaint);
        break;
    }
  }
  
  void _paintGradientOverlay(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.2,
      colors: [
        Colors.transparent,
        primaryColor.withOpacity(opacity * config.effectIntensity * 0.02),
        secondaryColor.withOpacity(opacity * config.effectIntensity * 0.12),
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..blendMode = BlendMode.screen;
    
    canvas.drawRect(rect, paint);
  }
}

/// Data classes for background effects
class StaticFloatingElement {
  final double x, y;
  final double size;
  final double opacity;
  final FloatingElementShape shape;

  StaticFloatingElement({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.shape,
  });
}

enum FloatingElementShape {
  circle,
  square,
  diamond,
  triangle,
}

/// Static Matrix pattern painter for Matrix theme
class MatrixRainPainter extends BackgroundEffectPainter {
  late final math.Random _random;
  static const String _matrixChars = '01アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン';
  late final List<StaticMatrixCharacter> _staticChars;
  bool _initialized = false;

  MatrixRainPainter({
    super.animation, // Optional now
    required super.primaryColor,
    required super.secondaryColor,
    required super.config,
    super.opacity,
  }) {
    _random = math.Random(42); // Fixed seed for consistent static pattern
    _staticChars = [];
  }

  void _initializeStaticPattern(Size size) {
    if (!_initialized) {
      _staticChars.clear();
      
      // Create a static matrix pattern with proper spacing to avoid overlaps
      for (double x = 0; x < size.width; x += 25) { // Increased spacing
        for (double y = 0; y < size.height; y += 30) { // Increased spacing
          final char = _matrixChars[_random.nextInt(_matrixChars.length)];
          final baseOpacity = _random.nextDouble() * 0.6 + 0.2; // Adjusted opacity
          final fontSize = _random.nextDouble() * 6 + 16; // More consistent sizes
          
          _staticChars.add(StaticMatrixCharacter(
            char: char,
            x: x + (_random.nextDouble() - 0.5) * 4, // Smaller random offset to prevent overlap
            y: y + (_random.nextDouble() - 0.5) * 4,
            opacity: baseOpacity,
            fontSize: fontSize,
          ));
        }
      }
      
      // Add some brighter "accent" characters for visual interest - with better spacing
      final accentCount = (size.width * size.height / 15000).floor(); // Fewer accents
      for (int i = 0; i < accentCount; i++) {
        final char = _matrixChars[_random.nextInt(_matrixChars.length)];
        final x = _random.nextDouble() * (size.width - 40) + 20; // Keep away from edges
        final y = _random.nextDouble() * (size.height - 40) + 20; // Keep away from edges
        
        _staticChars.add(StaticMatrixCharacter(
          char: char,
          x: x,
          y: y,
          opacity: 0.9, // Bright but not overwhelming
          fontSize: 20, // Slightly larger for accent
          isAccent: true,
        ));
      }
      
      _initialized = true;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Check for zero or invalid size
    if (size.width <= 0 || size.height <= 0) return;
    
    if (!config.enableParticles || config.particleType != BackgroundParticleType.codeRain) return;

    if (!_initialized) {
      _initializeStaticPattern(size);
    }
    
    // Draw all static matrix characters
    for (final matrixChar in _staticChars) {
      final textStyle = TextStyle(
        fontFamily: 'Courier',
        fontSize: matrixChar.fontSize,
        fontWeight: matrixChar.isAccent ? FontWeight.bold : FontWeight.w500,
        color: matrixChar.isAccent 
          ? Colors.white.withOpacity(matrixChar.opacity * opacity * config.effectIntensity * 0.45) // 50% higher opacity
          : primaryColor.withOpacity(matrixChar.opacity * opacity * config.effectIntensity * 0.225), // 50% higher opacity
      );
      
      final painter = TextPainter(
        text: TextSpan(
          text: matrixChar.char,
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      
      painter.layout();
      painter.paint(canvas, Offset(matrixChar.x, matrixChar.y));
    }
    
    // Add subtle grid pattern overlay
    _drawGridPattern(canvas, size);
  }
  
  void _drawGridPattern(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withOpacity(opacity * config.effectIntensity * 0.045) // 50% higher opacity
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    // Vertical lines - aligned with character spacing
    for (double x = 0; x < size.width; x += 50) { // Aligned with character spacing
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Horizontal lines - aligned with character spacing
    for (double y = 0; y < size.height; y += 60) { // Aligned with character spacing
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
}

/// Data classes for static Matrix pattern
class StaticMatrixCharacter {
  final String char;
  final double x;
  final double y;
  final double opacity;
  final double fontSize;
  final bool isAccent;

  StaticMatrixCharacter({
    required this.char,
    required this.x,
    required this.y,
    required this.opacity,
    required this.fontSize,
    this.isAccent = false,
  });
}

/// Expressive geometric painter for modern colorful themes
class ExpressiveGeometricPainter extends BackgroundEffectPainter {
  late final math.Random _random;
  late final List<StaticGeometricShape> _shapes;

  ExpressiveGeometricPainter({
    super.animation,
    required super.primaryColor,
    required super.secondaryColor,
    required super.config,
    super.opacity,
  }) {
    _random = math.Random(789); // Fixed seed
    _initializeStaticShapes();
  }

  void _initializeStaticShapes() {
    _shapes = List.generate(12, (index) {
      return StaticGeometricShape(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 40 + 15,
        rotation: _random.nextDouble() * math.pi * 2,
        opacity: _random.nextDouble() * 0.25 + 0.08,
        shape: GeometricShape.values[_random.nextInt(GeometricShape.values.length)],
        colorIndex: _random.nextInt(3), // 0 = primary, 1 = secondary, 2 = white
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Paint colorful gradient background
    _paintColorfulGradient(canvas, size);
    
    // Paint geometric shapes
    for (final shape in _shapes) {
      _paintGeometricShape(canvas, size, shape);
    }
    
    // Add decorative lines
    _paintDecorativeLines(canvas, size);
  }

  void _paintColorfulGradient(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = RadialGradient(
      center: const Alignment(0.3, -0.4),
      radius: 1.5,
      colors: [
        primaryColor.withOpacity(opacity * config.effectIntensity * 0.12),
        secondaryColor.withOpacity(opacity * config.effectIntensity * 0.15),
        primaryColor.withOpacity(opacity * config.effectIntensity * 0.08),
        Colors.transparent,
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..blendMode = BlendMode.screen;
    
    canvas.drawRect(rect, paint);
  }

  void _paintGeometricShape(Canvas canvas, Size size, StaticGeometricShape shape) {
    final x = shape.x * size.width;
    final y = shape.y * size.height;
    
    Color shapeColor;
    switch (shape.colorIndex) {
      case 0:
        shapeColor = primaryColor;
        break;
      case 1:
        shapeColor = secondaryColor;
        break;
      default:
        shapeColor = Colors.white;
    }
    
    final paint = Paint()
      ..color = shapeColor.withOpacity(opacity * config.effectIntensity * shape.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(shape.rotation);

    switch (shape.shape) {
      case GeometricShape.circle:
        canvas.drawCircle(Offset.zero, shape.size, paint);
        break;
      case GeometricShape.square:
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: shape.size * 2, height: shape.size * 2),
          paint,
        );
        break;
      case GeometricShape.triangle:
        final path = Path();
        path.moveTo(0, -shape.size);
        path.lineTo(-shape.size * 0.866, shape.size * 0.5);
        path.lineTo(shape.size * 0.866, shape.size * 0.5);
        path.close();
        canvas.drawPath(path, paint);
        break;
      case GeometricShape.hexagon:
        _drawHexagonShape(canvas, Offset.zero, shape.size, paint);
        break;
      case GeometricShape.star:
        _drawStarShape(canvas, Offset.zero, shape.size, paint);
        break;
    }

    canvas.restore();
  }

  void _drawHexagonShape(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60.0) * math.pi / 180.0;
      final x = center.dx + size * math.cos(angle);
      final y = center.dy + size * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawStarShape(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    const numPoints = 5;
    final outerRadius = size;
    final innerRadius = size * 0.4;
    
    for (int i = 0; i < numPoints * 2; i++) {
      final angle = (i * math.pi) / numPoints;
      final radius = (i % 2 == 0) ? outerRadius : innerRadius;
      final x = center.dx + radius * math.cos(angle - math.pi / 2);
      final y = center.dy + radius * math.sin(angle - math.pi / 2);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _paintDecorativeLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = primaryColor.withOpacity(opacity * config.effectIntensity * 0.1);

    // Draw some connecting lines between shapes
    for (int i = 0; i < _shapes.length - 1; i += 2) {
      final shape1 = _shapes[i];
      final shape2 = _shapes[i + 1];
      
      final start = Offset(shape1.x * size.width, shape1.y * size.height);
      final end = Offset(shape2.x * size.width, shape2.y * size.height);
      
      // Only draw line if shapes aren't too far apart
      final distance = (end - start).distance;
      if (distance < size.width * 0.4) {
        canvas.drawLine(start, end, paint);
      }
    }
  }
}

/// Data classes for geometric shapes
class StaticGeometricShape {
  final double x, y;
  final double size;
  final double rotation;
  final double opacity;
  final GeometricShape shape;
  final int colorIndex;

  StaticGeometricShape({
    required this.x,
    required this.y,
    required this.size,
    required this.rotation,
    required this.opacity,
    required this.shape,
    required this.colorIndex,
  });
}

enum GeometricShape {
  circle,
  square,
  triangle,
  hexagon,
  star,
}