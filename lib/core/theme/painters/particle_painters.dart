import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/theme_animations.dart';

/// Base class for particle painters
abstract class ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final Color primaryColor;
  final Color secondaryColor;
  final ParticleConfig config;
  final double opacity;

  ParticlePainter({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
    required this.config,
    this.opacity = 1.0,
  }) : super(repaint: animation);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Energy orb particles for Vegeta theme
class EnergyOrbParticlePainter extends ParticlePainter {
  final List<EnergyOrb> _orbs = [];
  late final math.Random _random;

  EnergyOrbParticlePainter({
    required super.animation,
    required super.primaryColor,
    required super.secondaryColor,
    required super.config,
    super.opacity,
  }) {
    _random = math.Random();
    _initializeOrbs();
  }

  void _initializeOrbs() {
    final orbCount = _getOrbCount();
    _orbs.clear();
    
    for (int i = 0; i < orbCount; i++) {
      _orbs.add(EnergyOrb(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 8 + 4,
        speed: _random.nextDouble() * 2 + 0.5,
        phase: _random.nextDouble() * math.pi * 2,
        pulseRate: _random.nextDouble() * 0.5 + 0.3,
      ));
    }
  }

  int _getOrbCount() {
    switch (config.density) {
      case ParticleDensity.none:
        return 0;
      case ParticleDensity.low:
        return 8;
      case ParticleDensity.medium:
        return 15;
      case ParticleDensity.high:
        return 25;
      case ParticleDensity.ultra:
        return 40;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!config.enableGlow || _orbs.isEmpty) return;

    final paint = Paint()
      ..blendMode = BlendMode.screen;

    final time = animation.value * 10; // Slow down animation

    for (final orb in _orbs) {
      _paintEnergyOrb(canvas, size, orb, time, paint);
    }
  }

  void _paintEnergyOrb(Canvas canvas, Size size, EnergyOrb orb, double time, Paint paint) {
    // Calculate position with floating movement
    final x = (orb.x + math.sin(time * orb.speed + orb.phase) * 0.1) * size.width;
    final y = (orb.y + math.cos(time * orb.speed * 0.7 + orb.phase) * 0.08) * size.height;
    
    // Pulsing effect
    final pulse = math.sin(time * orb.pulseRate) * 0.3 + 0.7;
    final currentSize = orb.size * pulse * config.size;
    
    // Draw energy orb with gradient
    final gradient = RadialGradient(
      colors: [
        primaryColor.withOpacity(opacity * config.opacity * 0.8),
        secondaryColor.withOpacity(opacity * config.opacity * 0.4),
        Colors.transparent,
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    paint.shader = gradient.createShader(
      Rect.fromCircle(center: Offset(x, y), radius: currentSize),
    );

    // Draw outer glow
    if (config.enableGlow) {
      canvas.drawCircle(
        Offset(x, y),
        currentSize * 1.8,
        paint..shader = RadialGradient(
          colors: [
            primaryColor.withOpacity(opacity * config.opacity * 0.3),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(center: Offset(x, y), radius: currentSize * 1.8),
        ),
      );
    }

    // Draw core orb
    canvas.drawCircle(Offset(x, y), currentSize, paint);
  }
}

/// Code rain particles for Matrix theme
class CodeRainParticlePainter extends ParticlePainter {
  final List<CodeDrop> _drops = [];
  late final math.Random _random;
  final String _chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

  CodeRainParticlePainter({
    required super.animation,
    required super.primaryColor,
    required super.secondaryColor,
    required super.config,
    super.opacity,
  }) {
    _random = math.Random();
  }

  void _initializeDrops(Size size) {
    if (_drops.isNotEmpty) return;
    
    final dropCount = _getDropCount();
    _drops.clear();
    
    final columnWidth = 20.0;
    final columnCount = (size.width / columnWidth).floor();
    
    for (int i = 0; i < math.min(dropCount, columnCount); i++) {
      _drops.add(CodeDrop(
        x: i * columnWidth + _random.nextDouble() * columnWidth,
        y: _random.nextDouble() * size.height - size.height,
        speed: _random.nextDouble() * 3 + 1,
        chars: _generateCharString(),
        brightness: _random.nextDouble() * 0.5 + 0.5,
      ));
    }
  }

  int _getDropCount() {
    switch (config.density) {
      case ParticleDensity.none:
        return 0;
      case ParticleDensity.low:
        return 15;
      case ParticleDensity.medium:
        return 25;
      case ParticleDensity.high:
        return 40;
      case ParticleDensity.ultra:
        return 60;
    }
  }

  String _generateCharString() {
    final length = _random.nextInt(15) + 5;
    return List.generate(length, (index) => _chars[_random.nextInt(_chars.length)]).join();
  }

  @override
  void paint(Canvas canvas, Size size) {
    _initializeDrops(size);
    if (_drops.isEmpty) return;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final time = animation.value * 5; // Animation speed

    for (final drop in _drops) {
      _paintCodeDrop(canvas, size, drop, time, textPainter);
    }
  }

  void _paintCodeDrop(Canvas canvas, Size size, CodeDrop drop, double time, TextPainter textPainter) {
    final currentY = (drop.y + time * drop.speed * 50) % (size.height + 200) - 100;
    
    // Split characters and paint with fade
    final chars = drop.chars.split('');
    const charHeight = 16.0;
    
    for (int i = 0; i < chars.length; i++) {
      final charY = currentY + i * charHeight;
      if (charY < -charHeight || charY > size.height + charHeight) continue;
      
      // Calculate fade based on position in string
      final fade = i == 0 
          ? 1.0 
          : math.max(0.0, 1.0 - (i / chars.length.toDouble()));
      
      final color = i == 0 
          ? secondaryColor // Bright head
          : primaryColor.withOpacity(fade * drop.brightness);
      
      textPainter.text = TextSpan(
        text: chars[i],
        style: TextStyle(
          color: color.withOpacity(opacity * config.opacity),
          fontSize: 14,
          fontFamily: 'Courier',
          fontWeight: FontWeight.bold,
        ),
      );
      
      textPainter.layout();
      textPainter.paint(canvas, Offset(drop.x, charY));
    }
  }
}

/// Floating code symbols for Dracula theme
class FloatingSymbolParticlePainter extends ParticlePainter {
  final List<FloatingSymbol> _symbols = [];
  late final math.Random _random;
  final List<String> _codeSymbols = ['{', '}', '(', ')', '[', ']', '<', '>', ';', ':', '=', '+', '-', '*', '/', '%', '&', '|', '!', '?'];

  FloatingSymbolParticlePainter({
    required super.animation,
    required super.primaryColor,
    required super.secondaryColor,
    required super.config,
    super.opacity,
  }) {
    _random = math.Random();
    _initializeSymbols();
  }

  void _initializeSymbols() {
    final symbolCount = _getSymbolCount();
    _symbols.clear();
    
    for (int i = 0; i < symbolCount; i++) {
      _symbols.add(FloatingSymbol(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        symbol: _codeSymbols[_random.nextInt(_codeSymbols.length)],
        size: _random.nextDouble() * 12 + 8,
        speed: _random.nextDouble() * 0.5 + 0.2,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.5,
        opacity: _random.nextDouble() * 0.3 + 0.2,
      ));
    }
  }

  int _getSymbolCount() {
    switch (config.density) {
      case ParticleDensity.none:
        return 0;
      case ParticleDensity.low:
        return 8;
      case ParticleDensity.medium:
        return 15;
      case ParticleDensity.high:
        return 25;
      case ParticleDensity.ultra:
        return 35;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_symbols.isEmpty) return;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final time = animation.value * 2; // Slow animation

    for (final symbol in _symbols) {
      _paintFloatingSymbol(canvas, size, symbol, time, textPainter);
    }
  }

  void _paintFloatingSymbol(Canvas canvas, Size size, FloatingSymbol symbol, double time, TextPainter textPainter) {
    // Calculate floating position
    final x = (symbol.x + math.sin(time * symbol.speed) * 0.1) * size.width;
    final y = (symbol.y + math.cos(time * symbol.speed * 0.8) * 0.08) * size.height;
    
    // Calculate rotation
    final rotation = symbol.rotation + time * symbol.rotationSpeed;
    
    // Color cycling between primary and secondary
    final colorLerp = (math.sin(time * 0.5) + 1) / 2;
    final color = Color.lerp(primaryColor, secondaryColor, colorLerp)!;
    
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rotation);
    
    textPainter.text = TextSpan(
      text: symbol.symbol,
      style: TextStyle(
        color: color.withOpacity(opacity * config.opacity * symbol.opacity),
        fontSize: symbol.size * config.size,
        fontFamily: 'JetBrains Mono',
        fontWeight: FontWeight.w300,
      ),
    );
    
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    
    canvas.restore();
  }
}

/// Data classes for particles
class EnergyOrb {
  final double x, y;
  final double size;
  final double speed;
  final double phase;
  final double pulseRate;

  EnergyOrb({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.pulseRate,
  });
}

class CodeDrop {
  final double x;
  final double y;
  final double speed;
  final String chars;
  final double brightness;

  CodeDrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.chars,
    required this.brightness,
  });
}

class FloatingSymbol {
  final double x, y;
  final String symbol;
  final double size;
  final double speed;
  final double rotation;
  final double rotationSpeed;
  final double opacity;

  FloatingSymbol({
    required this.x,
    required this.y,
    required this.symbol,
    required this.size,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
    required this.opacity,
  });
}