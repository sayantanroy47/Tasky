import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/theme/typography_constants.dart';

/// Glassmorphism effect painter with performance optimizations
class GlassmorphismPainter extends CustomPainter {
  final Color color;
  final double blur;
  final double opacity;
  final BorderRadius borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final bool enableCaching;
  
  // Cache painted objects for better performance
  static Paint? _cachedFillPaint;
  static Paint? _cachedBorderPaint;
  static String? _cacheKey;
  
  GlassmorphismPainter({
    this.color = Colors.white,
    this.blur = 5.6, // Reduced by 25% from 7.5px
    this.opacity = 0.2,
    this.borderRadius = const BorderRadius.all(Radius.circular(TypographyConstants.radiusStandard)),
    this.borderColor,
    this.borderWidth = 1.5,
    this.enableCaching = true,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = borderRadius.toRRect(rect);
    
    // Use cached paint objects if caching is enabled
    final paint = enableCaching ? _getCachedFillPaint() : _createFillPaint();
    
    canvas.drawRRect(rrect, paint);
    
    // Draw border if specified
    if (borderColor != null) {
      final borderPaint = enableCaching ? _getCachedBorderPaint() : _createBorderPaint();
      canvas.drawRRect(rrect, borderPaint);
    }
  }
  
  /// Get or create cached fill paint
  Paint _getCachedFillPaint() {
    final currentKey = _buildPaintCacheKey();
    if (_cacheKey != currentKey || _cachedFillPaint == null) {
      _cachedFillPaint = _createFillPaint();
      _cacheKey = currentKey;
    }
    return _cachedFillPaint!;
  }
  
  /// Get or create cached border paint
  Paint _getCachedBorderPaint() {
    // For border paint, we can reuse if border properties haven't changed
    if (_cachedBorderPaint == null || 
        _cachedBorderPaint!.color != borderColor! ||
        _cachedBorderPaint!.strokeWidth != borderWidth) {
      _cachedBorderPaint = _createBorderPaint();
    }
    return _cachedBorderPaint!;
  }
  
  /// Create fill paint
  Paint _createFillPaint() {
    return Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
  }
  
  /// Create border paint
  Paint _createBorderPaint() {
    return Paint()
      ..color = borderColor!
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
  }
  
  /// Build cache key for paint objects
  String _buildPaintCacheKey() {
    return '${color.value}_${opacity}_$blur';
  }
  
  @override
  bool shouldRepaint(GlassmorphismPainter oldDelegate) {
    return color != oldDelegate.color ||
           blur != oldDelegate.blur ||
           opacity != oldDelegate.opacity ||
           borderRadius != oldDelegate.borderRadius ||
           borderColor != oldDelegate.borderColor ||
           borderWidth != oldDelegate.borderWidth;
  }
}

/// Glassmorphism container widget
class GlassmorphicContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final double blur;
  final double opacity;
  final Color color;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? child;
  
  const GlassmorphicContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(TypographyConstants.radiusStandard)),
    this.blur = 5.6, // Reduced by 25% from 7.5px
    this.opacity = 0.2,
    this.color = Colors.white,
    this.borderColor,
    this.borderWidth = 1.5,
    this.padding,
    this.margin,
    this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: blur,
            sigmaY: blur,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: color.withValues(alpha: opacity),
              border: borderColor != null
                ? Border.all(
                    color: borderColor!,
                    width: borderWidth,
                  )
                : null,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: (opacity * 1.2).clamp(0.0, 1.0)),
                  color.withValues(alpha: (opacity * 0.8).clamp(0.0, 1.0)),
                ],
              ),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Frosted glass effect widget
class FrostedGlass extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color color;
  final BorderRadius? borderRadius;
  
  const FrostedGlass({
    super.key,
    required this.child,
    this.blur = 8.4, // Reduced by 25% from 11.25px
    this.opacity = 0.1,
    this.color = Colors.white,
    this.borderRadius,
  });
  
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: opacity),
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: opacity * 0.5),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}