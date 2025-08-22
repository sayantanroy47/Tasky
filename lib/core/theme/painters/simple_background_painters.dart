import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Simple Matrix rain background painter
class SimpleMatrixRainPainter extends CustomPainter {
  final bool isDark;
  final Animation<double>? animation;

  SimpleMatrixRainPainter({
    required this.isDark,
    this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed for consistency
    
    // Matrix characters
    final textStyle = TextStyle(
      color: isDark 
          ? const Color(0xFF00FF00).withValues(alpha: 0.6)
          : const Color(0xFF006600).withValues(alpha: 0.3),
      fontSize: 12,
      fontFamily: 'monospace',
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw matrix rain
    for (int col = 0; col < (size.width / 20).floor(); col++) {
      final x = col * 20.0;
      for (int row = 0; row < (size.height / 20).floor(); row++) {
        if (random.nextDouble() > 0.85) {
          final y = row * 20.0;
          final char = String.fromCharCode(0x30A0 + random.nextInt(96)); // Katakana
          
          textPainter.text = TextSpan(text: char, style: textStyle);
          textPainter.layout();
          textPainter.paint(canvas, Offset(x, y));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple Vegeta metallic mesh painter
class SimpleVegetaMeshPainter extends CustomPainter {
  final bool isDark;

  SimpleVegetaMeshPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark 
          ? [
              const Color(0xFF1e3a8a).withValues(alpha: 0.4),
              const Color(0xFF60a5fa).withValues(alpha: 0.6),
              const Color(0xFF93c5fd).withValues(alpha: 0.3),
            ]
          : [
              const Color(0xFF1e3a8a).withValues(alpha: 0.1),
              const Color(0xFF60a5fa).withValues(alpha: 0.15),
              const Color(0xFF93c5fd).withValues(alpha: 0.08),
            ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Angular metallic pattern
    final path = Path();
    for (int i = 0; i < 15; i++) {
      final startX = i * (size.width / 15);
      path.moveTo(startX, 0);
      path.lineTo(startX + size.width / 10, size.height / 2);
      path.lineTo(startX, size.height);
      path.close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple Dracula floating elements painter
class SimpleDraculaFloatingPainter extends CustomPainter {
  final bool isDark;

  SimpleDraculaFloatingPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(123);
    
    // Dracula colors
    final colors = isDark 
      ? [
          const Color(0xFFff79c6).withValues(alpha: 0.3),
          const Color(0xFFbd93f9).withValues(alpha: 0.25),
          const Color(0xFF8be9fd).withValues(alpha: 0.2),
          const Color(0xFF50fa7b).withValues(alpha: 0.15),
          const Color(0xFFffb86c).withValues(alpha: 0.2),
        ]
      : [
          const Color(0xFFff79c6).withValues(alpha: 0.08),
          const Color(0xFFbd93f9).withValues(alpha: 0.06),
          const Color(0xFF8be9fd).withValues(alpha: 0.05),
          const Color(0xFF50fa7b).withValues(alpha: 0.04),
          const Color(0xFFffb86c).withValues(alpha: 0.05),
        ];

    // Draw floating elements
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 15 + random.nextDouble() * 40;
      
      final paint = Paint()..color = colors[i % colors.length];
      
      if (i % 3 == 0) {
        // Circles
        canvas.drawCircle(Offset(x, y), radius, paint);
      } else {
        // Rounded rectangles
        final rect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: radius * 2, height: radius),
          Radius.circular(radius / 4),
        );
        canvas.drawRRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple Expressive geometric painter
class SimpleExpressiveGeometricPainter extends CustomPainter {
  final bool isDark;

  SimpleExpressiveGeometricPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark 
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.03);

    // Modern geometric patterns
    for (int i = 0; i < 12; i++) {
      final x = i * (size.width / 12);
      final height = size.height * (0.3 + (i % 3) * 0.2);
      final y = (size.height - height) / 2;
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, size.width / 15, height),
        const Radius.circular(8),
      );
      canvas.drawRRect(rect, paint);
    }

    // Additional diagonal lines
    final linePaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.02)
      ..strokeWidth = 1;

    for (int i = 0; i < 8; i++) {
      final startX = i * (size.width / 8);
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + size.width / 4, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}