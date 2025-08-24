import 'package:flutter/material.dart';

import '../../core/design_system/design_tokens.dart';

/// Standardized border radius system that eliminates border radius chaos
/// 
/// Eliminates Border Radius Inconsistency by:
/// - Enforcing consistent border radius values based on BorderRadiusTokens
/// - Providing semantic radius patterns for different component types
/// - Preventing hardcoded BorderRadius.circular() throughout the app
/// - Maintaining visual hierarchy through standardized corner rounding
class StandardizedBorderRadius {
  /// Get border radius for different component types
  static BorderRadius get none => BorderRadius.zero;
  static BorderRadius get xs => BorderRadius.circular(BorderRadiusTokens.xs); // 2px
  static BorderRadius get sm => BorderRadius.circular(BorderRadiusTokens.sm); // 4px  
  static BorderRadius get md => BorderRadius.circular(BorderRadiusTokens.md); // 8px
  static BorderRadius get lg => BorderRadius.circular(BorderRadiusTokens.lg); // 12px
  static BorderRadius get xl => BorderRadius.circular(BorderRadiusTokens.xl); // 16px
  static BorderRadius get xxl => BorderRadius.circular(BorderRadiusTokens.xxl); // 20px
  static BorderRadius get xxxl => BorderRadius.circular(BorderRadiusTokens.xxl); // 24px

  /// Semantic border radius for component types
  static BorderRadius get button => BorderRadius.circular(BorderRadiusTokens.lg); // 12px - Standard buttons
  static BorderRadius get card => BorderRadius.circular(BorderRadiusTokens.xl); // 16px - Cards and containers
  static BorderRadius get dialog => BorderRadius.circular(BorderRadiusTokens.xxl); // 20px - Dialogs and sheets
  static BorderRadius get input => BorderRadius.circular(BorderRadiusTokens.lg); // 12px - Input fields
  static BorderRadius get chip => BorderRadius.circular(BorderRadiusTokens.xxl); // 24px - Pills and chips
  static BorderRadius get fab => BorderRadius.circular(BorderRadiusTokens.full); // Circular FABs
  static BorderRadius get avatar => BorderRadius.circular(BorderRadiusTokens.full); // Circular avatars

  /// Custom radius with design token validation
  static BorderRadius custom(double radius) {
    // Ensure radius aligns with design token values
    final tokenRadius = _getClosestTokenRadius(radius);
    return BorderRadius.circular(tokenRadius);
  }

  /// Get the closest valid design token radius
  static double _getClosestTokenRadius(double radius) {
    final tokens = [
      BorderRadiusTokens.xs,
      BorderRadiusTokens.sm, 
      BorderRadiusTokens.md,
      BorderRadiusTokens.lg,
      BorderRadiusTokens.xl,
      BorderRadiusTokens.xxl,
      BorderRadiusTokens.xxl,
    ];
    
    return tokens.reduce((a, b) => 
      (radius - a).abs() < (radius - b).abs() ? a : b
    );
  }

  /// Directional radius helpers
  static BorderRadius topLeft(double radius) => BorderRadius.only(
    topLeft: Radius.circular(_getClosestTokenRadius(radius)),
  );
  
  static BorderRadius topRight(double radius) => BorderRadius.only(
    topRight: Radius.circular(_getClosestTokenRadius(radius)),
  );
  
  static BorderRadius bottomLeft(double radius) => BorderRadius.only(
    bottomLeft: Radius.circular(_getClosestTokenRadius(radius)),
  );
  
  static BorderRadius bottomRight(double radius) => BorderRadius.only(
    bottomRight: Radius.circular(_getClosestTokenRadius(radius)),
  );
  
  static BorderRadius top(double radius) => BorderRadius.vertical(
    top: Radius.circular(_getClosestTokenRadius(radius)),
  );
  
  static BorderRadius bottom(double radius) => BorderRadius.vertical(
    bottom: Radius.circular(_getClosestTokenRadius(radius)),
  );
  
  static BorderRadius left(double radius) => BorderRadius.horizontal(
    left: Radius.circular(_getClosestTokenRadius(radius)),
  );
  
  static BorderRadius right(double radius) => BorderRadius.horizontal(
    right: Radius.circular(_getClosestTokenRadius(radius)),
  );
}

/// Extension for easy context-aware border radius
extension StandardizedBorderRadiusExtension on BuildContext {
  /// Get semantic border radius for current context
  BorderRadius get buttonRadius => StandardizedBorderRadius.button;
  BorderRadius get cardRadius => StandardizedBorderRadius.card;
  BorderRadius get dialogRadius => StandardizedBorderRadius.dialog;
  BorderRadius get inputRadius => StandardizedBorderRadius.input;
  BorderRadius get chipRadius => StandardizedBorderRadius.chip;
}

/// Widget wrapper for standardized border radius containers
class StandardizedContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;

  const StandardizedContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.color,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.alignment,
  });

  const StandardizedContainer.card({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.alignment,
  }) : borderRadius = null;

  const StandardizedContainer.button({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.alignment,
  }) : borderRadius = null;

  @override
  Widget build(BuildContext context) {
    BorderRadius effectiveRadius;
    if (borderRadius != null) {
      effectiveRadius = borderRadius!;
    } else if (runtimeType.toString().contains('card')) {
      effectiveRadius = StandardizedBorderRadius.card;
    } else if (runtimeType.toString().contains('button')) {
      effectiveRadius = StandardizedBorderRadius.button;
    } else {
      effectiveRadius = StandardizedBorderRadius.md;
    }

    return Container(
      width: width,
      height: height,
      constraints: constraints,
      alignment: alignment,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: effectiveRadius,
      ),
      child: child,
    );
  }
}