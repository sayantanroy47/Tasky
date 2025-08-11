import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/typography_constants.dart';

/// Glassmorphism container widget that provides a consistent glass effect
/// across all components in the app with a subtle blue tint
class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final double blur;
  final double opacity;
  final Color? glassTint;
  final Color? borderColor;
  final double borderWidth;
  
  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 15.0,
    this.opacity = 0.15,
    this.glassTint,
    this.borderColor,
    this.borderWidth = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Default glass tint - TRANSPARENT WHITE for glassmorphism effect
    final defaultGlassTint = glassTint ?? Colors.white.withOpacity(opacity);
    final defaultBorderColor = borderColor ?? Colors.white.withOpacity(0.3);
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(TypographyConstants.radiusStandard),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              // Glassmorphism background with subtle blue tint
              color: defaultGlassTint,
              borderRadius: borderRadius ?? BorderRadius.circular(TypographyConstants.radiusStandard),
              border: Border.all(
                color: defaultBorderColor,
                width: borderWidth,
              ),
              // TRUE GLASSMORPHISM - WHITE transparent gradient
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.10),
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.20),
                ],
                stops: const [0.0, 0.4, 0.8, 1.0],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A glassmorphism card specifically for task-related components
class GlassTaskCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  
  const GlassTaskCard({
    super.key,
    required this.child,
    this.elevation = 2.0,
    this.onTap,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = GlassmorphismContainer(
      padding: padding ?? const EdgeInsets.all(16.0),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      blur: 15.0,
      opacity: 0.12, // Slightly more opaque for cards
      glassTint: Colors.blue.withOpacity(0.08),
      borderColor: Colors.white.withOpacity(0.25),
      child: child,
    );
    
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          child: cardWidget,
        ),
      );
    }
    
    return cardWidget;
  }
}

/// A glassmorphism container for project cards
class GlassProjectCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? accentColor;
  
  const GlassProjectCard({
    super.key,
    required this.child,
    this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = GlassmorphismContainer(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      blur: 18.0,
      opacity: 0.15,
      glassTint: (accentColor ?? Colors.blue).withOpacity(0.1),
      borderColor: Colors.white.withOpacity(0.3),
      borderWidth: 1.0,
      child: child,
    );
    
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          child: cardWidget,
        ),
      );
    }
    
    return cardWidget;
  }
}

/// Glassmorphism container for floating action buttons and controls
class GlassControlContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double size;
  
  const GlassControlContainer({
    super.key,
    required this.child,
    this.onTap,
    this.size = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphismContainer(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
      blur: 12.0,
      opacity: 0.2,
      glassTint: Colors.blue.withOpacity(0.15),
      borderColor: Colors.white.withOpacity(0.4),
      borderWidth: 1.0,
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(size / 2),
                child: Center(child: child),
              ),
            )
          : Center(child: child),
    );
  }
}