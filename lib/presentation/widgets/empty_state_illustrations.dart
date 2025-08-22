import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Empty state illustrations for different sections of the app
class EmptyStateIllustrations {
  static Widget tasks(BuildContext context) {
    return _TasksEmptyIllustration(
      size: const Size(200, 200),
      primaryColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      animate: true,
    );
  }

  static Widget projects(BuildContext context) {
    return _ProjectsEmptyIllustration(
      size: const Size(200, 200),
      primaryColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      animate: true,
    );
  }

  static Widget calendar(BuildContext context) {
    return _CalendarEmptyIllustration(
      size: const Size(200, 200),
      primaryColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      animate: true,
    );
  }

  static Widget search(BuildContext context) {
    return _SearchEmptyIllustration(
      size: const Size(200, 200),
      primaryColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      animate: true,
    );
  }

  static Widget analytics(BuildContext context) {
    return _AnalyticsEmptyIllustration(
      size: const Size(200, 200),
      primaryColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      animate: true,
    );
  }

  /// Get appropriate size based on screen size
  static Size getAppropriateSize(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final minDimension = math.min(screenSize.width, screenSize.height);
    
    if (minDimension < 400) {
      return const Size(150, 150);
    } else if (minDimension < 600) {
      return const Size(200, 200);
    } else {
      return const Size(250, 250);
    }
  }

  /// Create custom illustration based on type
  static Widget createCustomIllustration({
    required String type,
    required Size size,
    required Color primaryColor,
    required Color backgroundColor,
    bool animate = true,
  }) {
    switch (type.toLowerCase()) {
      case 'tasks':
        return _TasksEmptyIllustration(
          size: size,
          primaryColor: primaryColor,
          backgroundColor: backgroundColor,
          animate: animate,
        );
      case 'projects':
        return _ProjectsEmptyIllustration(
          size: size,
          primaryColor: primaryColor,
          backgroundColor: backgroundColor,
          animate: animate,
        );
      case 'calendar':
        return _CalendarEmptyIllustration(
          size: size,
          primaryColor: primaryColor,
          backgroundColor: backgroundColor,
          animate: animate,
        );
      case 'search':
        return _SearchEmptyIllustration(
          size: size,
          primaryColor: primaryColor,
          backgroundColor: backgroundColor,
          animate: animate,
        );
      case 'analytics':
        return _AnalyticsEmptyIllustration(
          size: size,
          primaryColor: primaryColor,
          backgroundColor: backgroundColor,
          animate: animate,
        );
      default:
        return _TasksEmptyIllustration(
          size: size,
          primaryColor: primaryColor,
          backgroundColor: backgroundColor,
          animate: animate,
        );
    }
  }

  static Widget notifications(BuildContext context) {
    return _NotificationsEmptyIllustration(
      size: const Size(200, 200),
      primaryColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      animate: true,
    );
  }

  static Widget settings(BuildContext context) {
    return _SettingsEmptyIllustration(
      size: const Size(200, 200),
      primaryColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      animate: true,
    );
  }

  static Widget generic(BuildContext context) {
    return _GenericEmptyIllustration(
      size: const Size(200, 200),
      primaryColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      animate: true,
    );
  }
}

/// Tasks empty state illustration
class _TasksEmptyIllustration extends StatefulWidget {
  final Size size;
  final Color primaryColor;
  final Color backgroundColor;
  final bool animate;

  const _TasksEmptyIllustration({
    required this.size,
    required this.primaryColor,
    required this.backgroundColor,
    required this.animate,
  });

  @override
  State<_TasksEmptyIllustration> createState() => _TasksEmptyIllustrationState();
}

class _TasksEmptyIllustrationState extends State<_TasksEmptyIllustration>
    with TickerProviderStateMixin {
  late AnimationController _primaryController;
  late AnimationController _secondaryController;
  // late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _primaryController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _secondaryController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // _floatAnimation = Tween<double>(
    //   begin: 0.0,
    //   end: 1.0,
    // ).animate(CurvedAnimation(
    //   parent: _primaryController,
    //   curve: Curves.easeInOut,
    // ));

    _fadeAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _secondaryController,
      curve: Curves.easeInOut,
    ));

    if (widget.animate) {
      _primaryController.repeat(reverse: true);
      _secondaryController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return CustomPaint(
        size: widget.size,
        painter: _TasksEmptyPainter(
          primaryColor: widget.primaryColor,
          backgroundColor: widget.backgroundColor,
          animationValue: 0.5,
          fadeValue: 0.8,
        ),
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_primaryController, _secondaryController]),
      builder: (context, child) {
        return CustomPaint(
          size: widget.size,
          painter: _TasksEmptyPainter(
            primaryColor: widget.primaryColor,
            backgroundColor: widget.backgroundColor,
            animationValue: _primaryController.value,
            fadeValue: _fadeAnimation.value,
          ),
        );
      },
    );
  }
}

class _TasksEmptyPainter extends CustomPainter {
  final Color primaryColor;
  final Color backgroundColor;
  final double animationValue;
  final double fadeValue;

  _TasksEmptyPainter({
    required this.primaryColor,
    required this.backgroundColor,
    required this.animationValue,
    required this.fadeValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: fadeValue)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    // Draw animated circle
    canvas.drawCircle(
      center,
      radius + (animationValue * 10),
      paint,
    );

    // Draw checkmark
    final checkPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(center.dx - 20, center.dy);
    path.lineTo(center.dx - 5, center.dy + 15);
    path.lineTo(center.dx + 20, center.dy - 15);

    canvas.drawPath(path, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Projects empty state illustration
class _ProjectsEmptyIllustration extends StatefulWidget {
  final Size size;
  final Color primaryColor;
  final Color backgroundColor;
  final bool animate;

  const _ProjectsEmptyIllustration({
    required this.size,
    required this.primaryColor,
    required this.backgroundColor,
    required this.animate,
  });

  @override
  State<_ProjectsEmptyIllustration> createState() => _ProjectsEmptyIllustrationState();
}

class _ProjectsEmptyIllustrationState extends State<_ProjectsEmptyIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return CustomPaint(
        size: widget.size,
        painter: _ProjectsEmptyPainter(
          primaryColor: widget.primaryColor,
          backgroundColor: widget.backgroundColor,
          scaleValue: 1.0,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: widget.size,
          painter: _ProjectsEmptyPainter(
            primaryColor: widget.primaryColor,
            backgroundColor: widget.backgroundColor,
            scaleValue: _scaleAnimation.value,
          ),
        );
      },
    );
  }
}

class _ProjectsEmptyPainter extends CustomPainter {
  final Color primaryColor;
  final Color backgroundColor;
  final double scaleValue;

  _ProjectsEmptyPainter({
    required this.primaryColor,
    required this.backgroundColor,
    required this.scaleValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final rectSize = size.width * 0.4 * scaleValue;

    // Draw folder icon
    final rect = Rect.fromCenter(
      center: center,
      width: rectSize,
      height: rectSize * 0.8,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Calendar empty state illustration
class _CalendarEmptyIllustration extends StatelessWidget {
  final Size size;
  final Color primaryColor;
  final Color backgroundColor;
  final bool animate;

  const _CalendarEmptyIllustration({
    required this.size,
    required this.primaryColor,
    required this.backgroundColor,
    required this.animate,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _CalendarEmptyPainter(
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class _CalendarEmptyPainter extends CustomPainter {
  final Color primaryColor;
  final Color backgroundColor;

  _CalendarEmptyPainter({
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final rectSize = size.width * 0.6;

    // Draw calendar grid
    final rect = Rect.fromCenter(
      center: center,
      width: rectSize,
      height: rectSize,
    );

    canvas.drawRect(rect, paint);

    // Draw grid lines
    for (int i = 1; i < 4; i++) {
      final x = rect.left + (rect.width / 4) * i;
      canvas.drawLine(
        Offset(x, rect.top),
        Offset(x, rect.bottom),
        paint,
      );
    }

    for (int i = 1; i < 4; i++) {
      final y = rect.top + (rect.height / 4) * i;
      canvas.drawLine(
        Offset(rect.left, y),
        Offset(rect.right, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Search empty state illustration
class _SearchEmptyIllustration extends StatelessWidget {
  final Size size;
  final Color primaryColor;
  final Color backgroundColor;
  final bool animate;

  const _SearchEmptyIllustration({
    required this.size,
    required this.primaryColor,
    required this.backgroundColor,
    required this.animate,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _SearchEmptyPainter(
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class _SearchEmptyPainter extends CustomPainter {
  final Color primaryColor;
  final Color backgroundColor;

  _SearchEmptyPainter({
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.2;

    // Draw magnifying glass
    canvas.drawCircle(center, radius, paint);

    // Draw handle
    final handleStart = Offset(
      center.dx + radius * 0.7,
      center.dy + radius * 0.7,
    );
    final handleEnd = Offset(
      center.dx + radius * 1.3,
      center.dy + radius * 1.3,
    );

    canvas.drawLine(handleStart, handleEnd, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Analytics empty state illustration
class _AnalyticsEmptyIllustration extends StatelessWidget {
  final Size size;
  final Color primaryColor;
  final Color backgroundColor;
  final bool animate;

  const _AnalyticsEmptyIllustration({
    required this.size,
    required this.primaryColor,
    required this.backgroundColor,
    required this.animate,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _AnalyticsEmptyPainter(
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class _AnalyticsEmptyPainter extends CustomPainter {
  final Color primaryColor;
  final Color backgroundColor;

  _AnalyticsEmptyPainter({
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final barWidth = size.width * 0.1;
    final maxHeight = size.height * 0.4;

    // Draw bar chart
    for (int i = 0; i < 4; i++) {
      final x = center.dx - (barWidth * 2) + (barWidth * i);
      final height = maxHeight * (0.3 + (i * 0.2));
      final rect = Rect.fromLTWH(
        x,
        center.dy + (maxHeight / 2) - height,
        barWidth * 0.8,
        height,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Notifications empty state illustration
class _NotificationsEmptyIllustration extends StatelessWidget {
  final Size size;
  final Color primaryColor;
  final Color backgroundColor;
  final bool animate;

  const _NotificationsEmptyIllustration({
    required this.size,
    required this.primaryColor,
    required this.backgroundColor,
    required this.animate,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _NotificationsEmptyPainter(
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class _NotificationsEmptyPainter extends CustomPainter {
  final Color primaryColor;
  final Color backgroundColor;

  _NotificationsEmptyPainter({
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final bellSize = size.width * 0.3;

    // Draw bell shape
    final path = Path();
    path.moveTo(center.dx - bellSize / 2, center.dy);
    path.quadraticBezierTo(
      center.dx - bellSize / 2,
      center.dy - bellSize / 2,
      center.dx,
      center.dy - bellSize / 2,
    );
    path.quadraticBezierTo(
      center.dx + bellSize / 2,
      center.dy - bellSize / 2,
      center.dx + bellSize / 2,
      center.dy,
    );
    path.lineTo(center.dx - bellSize / 2, center.dy);

    canvas.drawPath(path, paint);

    // Draw bell bottom
    canvas.drawLine(
      Offset(center.dx - bellSize / 2, center.dy),
      Offset(center.dx + bellSize / 2, center.dy),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Settings empty state illustration
class _SettingsEmptyIllustration extends StatelessWidget {
  final Size size;
  final Color primaryColor;
  final Color backgroundColor;
  final bool animate;

  const _SettingsEmptyIllustration({
    required this.size,
    required this.primaryColor,
    required this.backgroundColor,
    required this.animate,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _SettingsEmptyPainter(
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class _SettingsEmptyPainter extends CustomPainter {
  final Color primaryColor;
  final Color backgroundColor;

  _SettingsEmptyPainter({
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.2;

    // Draw gear
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius * 0.5, paint);

    // Draw gear teeth
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8;
      final x1 = center.dx + math.cos(angle) * radius;
      final y1 = center.dy + math.sin(angle) * radius;
      final x2 = center.dx + math.cos(angle) * (radius + 10);
      final y2 = center.dy + math.sin(angle) * (radius + 10);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Generic empty state illustration
class _GenericEmptyIllustration extends StatelessWidget {
  final Size size;
  final Color primaryColor;
  final Color backgroundColor;
  final bool animate;

  const _GenericEmptyIllustration({
    required this.size,
    required this.primaryColor,
    required this.backgroundColor,
    required this.animate,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _GenericEmptyPainter(
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class _GenericEmptyPainter extends CustomPainter {
  final Color primaryColor;
  final Color backgroundColor;

  _GenericEmptyPainter({
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    // Draw simple circle
    canvas.drawCircle(center, radius, paint);

    // Draw question mark
    final textPainter = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          color: primaryColor,
          fontSize: radius,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}