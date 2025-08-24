import 'package:flutter/material.dart';

import '../../core/theme/typography_constants.dart';

/// Standardized text component that enforces typography hierarchy
/// 
/// Eliminates Information Hierarchy Breakdown by:
/// - Enforcing TypographyConstants instead of hardcoded values
/// - Providing consistent text styling across all components  
/// - Preventing FontWeight.w500 and fontSize hardcoding
/// - Maintaining visual hierarchy through standardized scales
class StandardizedText extends StatelessWidget {
  final String text;
  final StandardizedTextStyle style;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextDecoration? decoration;
  final double? letterSpacing;
  final double? lineHeight;

  const StandardizedText(
    this.text, {
    super.key,
    this.style = StandardizedTextStyle.bodyMedium,
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.decoration,
    this.letterSpacing,
    this.lineHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = _getTextStyle(theme, style);

    return Text(
      text,
      style: textStyle.copyWith(
        color: color,
        decoration: decoration,
        letterSpacing: letterSpacing ?? textStyle.letterSpacing,
        height: lineHeight,
      ),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }

  TextStyle _getTextStyle(ThemeData theme, StandardizedTextStyle style) {
    switch (style) {
      // Display hierarchy - largest text
      case StandardizedTextStyle.displayLarge:
        return TextStyle(
          fontSize: TypographyConstants.displayLarge,
          fontWeight: TypographyConstants.medium,
          letterSpacing: TypographyConstants.tightLetterSpacing,
          height: TypographyConstants.tightLineHeight,
          color: theme.colorScheme.onSurface,
        );
      case StandardizedTextStyle.displayMedium:
        return TextStyle(
          fontSize: TypographyConstants.displayMedium,
          fontWeight: TypographyConstants.medium,
          letterSpacing: TypographyConstants.tightLetterSpacing,
          height: TypographyConstants.tightLineHeight,
          color: theme.colorScheme.onSurface,
        );
      case StandardizedTextStyle.displaySmall:
        return TextStyle(
          fontSize: TypographyConstants.displaySmall,
          fontWeight: TypographyConstants.medium,
          letterSpacing: TypographyConstants.normalLetterSpacing,
          height: TypographyConstants.tightLineHeight,
          color: theme.colorScheme.onSurface,
        );

      // Headline hierarchy
      case StandardizedTextStyle.headlineLarge:
        return TextStyle(
          fontSize: TypographyConstants.headlineLarge,
          fontWeight: TypographyConstants.medium,
          letterSpacing: TypographyConstants.normalLetterSpacing,
          height: TypographyConstants.tightLineHeight,
          color: theme.colorScheme.onSurface,
        );
      case StandardizedTextStyle.headlineMedium:
        return TextStyle(
          fontSize: TypographyConstants.headlineMedium,
          fontWeight: TypographyConstants.medium,
          letterSpacing: TypographyConstants.normalLetterSpacing,
          height: TypographyConstants.normalLineHeight,
          color: theme.colorScheme.onSurface,
        );
      case StandardizedTextStyle.headlineSmall:
        return TextStyle(
          fontSize: TypographyConstants.headlineSmall,
          fontWeight: TypographyConstants.medium,
          letterSpacing: TypographyConstants.normalLetterSpacing,
          height: TypographyConstants.normalLineHeight,
          color: theme.colorScheme.onSurface,
        );

      // Title hierarchy
      case StandardizedTextStyle.titleLarge:
        return TextStyle(
          fontSize: TypographyConstants.titleLarge,
          fontWeight: TypographyConstants.medium,
          letterSpacing: TypographyConstants.normalLetterSpacing,
          height: TypographyConstants.normalLineHeight,
          color: theme.colorScheme.onSurface,
        );
      case StandardizedTextStyle.titleMedium:
        return TextStyle(
          fontSize: TypographyConstants.titleMedium,
          fontWeight: TypographyConstants.medium,
          letterSpacing: TypographyConstants.normalLetterSpacing,
          height: TypographyConstants.normalLineHeight,
          color: theme.colorScheme.onSurface,
        );
      case StandardizedTextStyle.titleSmall:
        return TextStyle(
          fontSize: TypographyConstants.titleSmall,
          fontWeight: TypographyConstants.regular,
          letterSpacing: TypographyConstants.normalLetterSpacing,
          height: TypographyConstants.normalLineHeight,
          color: theme.colorScheme.onSurface,
        );

      // Body hierarchy - most common
      case StandardizedTextStyle.bodyLarge:
        return TextStyle(
          fontSize: TypographyConstants.bodyLarge,
          fontWeight: TypographyConstants.regular,
          letterSpacing: TypographyConstants.normalLetterSpacing,
          height: TypographyConstants.normalLineHeight,
          color: theme.colorScheme.onSurface,
        );
      case StandardizedTextStyle.bodyMedium:
        return TextStyle(
          fontSize: TypographyConstants.bodyMedium,
          fontWeight: TypographyConstants.regular,
          letterSpacing: TypographyConstants.normalLetterSpacing,
          height: TypographyConstants.normalLineHeight,
          color: theme.colorScheme.onSurface,
        );
      case StandardizedTextStyle.bodySmall:
        return TextStyle(
          fontSize: TypographyConstants.bodySmall,
          fontWeight: TypographyConstants.regular,
          letterSpacing: TypographyConstants.normalLetterSpacing,
          height: TypographyConstants.relaxedLineHeight,
          color: theme.colorScheme.onSurfaceVariant,
        );

      // Label hierarchy - UI elements
      case StandardizedTextStyle.labelLarge:
        return TextStyle(
          fontSize: TypographyConstants.labelLarge,
          fontWeight: TypographyConstants.medium,
          letterSpacing: TypographyConstants.relaxedLetterSpacing,
          height: TypographyConstants.normalLineHeight,
          color: theme.colorScheme.onSurface,
        );
      case StandardizedTextStyle.labelMedium:
        return TextStyle(
          fontSize: TypographyConstants.labelMedium,
          fontWeight: TypographyConstants.medium,
          letterSpacing: TypographyConstants.relaxedLetterSpacing,
          height: TypographyConstants.normalLineHeight,
          color: theme.colorScheme.onSurfaceVariant,
        );
      case StandardizedTextStyle.labelSmall:
        return TextStyle(
          fontSize: TypographyConstants.labelSmall,
          fontWeight: TypographyConstants.regular,
          letterSpacing: TypographyConstants.relaxedLetterSpacing,
          height: TypographyConstants.normalLineHeight,
          color: theme.colorScheme.onSurfaceVariant,
        );

      // Specialized component styles
      case StandardizedTextStyle.taskTitle:
        return TextStyle(
          fontSize: TypographyConstants.taskTitle,
          fontWeight: TypographyConstants.medium,
          letterSpacing: TypographyConstants.normalLetterSpacing,
          height: TypographyConstants.normalLineHeight,
          color: theme.colorScheme.onSurface,
        );
      case StandardizedTextStyle.taskDescription:
        return TextStyle(
          fontSize: TypographyConstants.taskDescription,
          fontWeight: TypographyConstants.regular,
          letterSpacing: TypographyConstants.normalLetterSpacing,
          height: TypographyConstants.relaxedLineHeight,
          color: theme.colorScheme.onSurfaceVariant,
        );
      case StandardizedTextStyle.taskMeta:
        return TextStyle(
          fontSize: TypographyConstants.taskMeta,
          fontWeight: TypographyConstants.regular,
          letterSpacing: TypographyConstants.normalLetterSpacing,
          height: TypographyConstants.normalLineHeight,
          color: theme.colorScheme.onSurfaceVariant,
        );
      case StandardizedTextStyle.buttonText:
        return TextStyle(
          fontSize: TypographyConstants.buttonText,
          fontWeight: TypographyConstants.medium,
          letterSpacing: TypographyConstants.relaxedLetterSpacing,
          height: TypographyConstants.normalLineHeight,
          color: theme.colorScheme.onSurface,
        );
    }
  }
}

/// Standardized text styles that map to typography constants
/// 
/// Eliminates hardcoded font sizes and weights throughout the app
enum StandardizedTextStyle {
  // Display hierarchy - hero content
  displayLarge,    // 30px, w500 - Hero text
  displayMedium,   // 28px, w500 - Large display
  displaySmall,    // 26px, w500 - Small display
  
  // Headline hierarchy - section headers  
  headlineLarge,   // 24px, w500 - Large headlines
  headlineMedium,  // 22px, w500 - Page titles
  headlineSmall,   // 20px, w500 - Section headers
  
  // Title hierarchy - card/component headers
  titleLarge,      // 18px, w500 - App bar, card titles
  titleMedium,     // 16px, w500 - Subheadings  
  titleSmall,      // 16px, w400 - Small headings
  
  // Body hierarchy - content text
  bodyLarge,       // 15px, w400 - Primary body text
  bodyMedium,      // 13px, w400 - Standard body text
  bodySmall,       // 11px, w400 - Secondary text
  
  // Label hierarchy - UI labels
  labelLarge,      // 14px, w500 - Button text, large labels
  labelMedium,     // 12px, w500 - UI labels  
  labelSmall,      // 11px, w400 - Fine print, captions
  
  // Specialized component styles
  taskTitle,       // 16px, w500 - Task titles (mobile-optimized)
  taskDescription, // 13px, w400 - Task descriptions
  taskMeta,        // 11px, w400 - Task metadata
  buttonText,      // 14px, w500 - Button text
}

/// Convenience widgets for common text patterns
class StandardizedTextVariants {
  /// Page header text
  static Widget pageHeader(
    String text, {
    Color? color,
    TextAlign? textAlign,
  }) {
    return StandardizedText(
      text,
      style: StandardizedTextStyle.headlineMedium,
      color: color,
      textAlign: textAlign,
    );
  }

  /// Section header text  
  static Widget sectionHeader(
    String text, {
    Color? color,
    TextAlign? textAlign,
  }) {
    return StandardizedText(
      text,
      style: StandardizedTextStyle.titleLarge,
      color: color,
      textAlign: textAlign,
    );
  }

  /// Card title text
  static Widget cardTitle(
    String text, {
    Color? color,
    TextAlign? textAlign,
    TextDecoration? decoration,
    int? maxLines,
  }) {
    return StandardizedText(
      text,
      style: StandardizedTextStyle.titleMedium,
      color: color,
      textAlign: textAlign,
      decoration: decoration,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }

  /// Task title with consistent styling
  static Widget taskTitle(
    String text, {
    Color? color,
    bool isCompleted = false,
    int? maxLines,
  }) {
    return StandardizedText(
      text,
      style: StandardizedTextStyle.taskTitle,
      color: color,
      decoration: isCompleted ? TextDecoration.lineThrough : null,
      maxLines: maxLines ?? 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Task description text
  static Widget taskDescription(
    String text, {
    Color? color,
    int? maxLines,
  }) {
    return StandardizedText(
      text,
      style: StandardizedTextStyle.taskDescription,
      color: color,
      maxLines: maxLines ?? 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Body text for content
  static Widget body(
    String text, {
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
  }) {
    return StandardizedText(
      text,
      style: StandardizedTextStyle.bodyMedium,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }

  /// Small meta information text
  static Widget meta(
    String text, {
    Color? color,
    TextAlign? textAlign,
  }) {
    return StandardizedText(
      text,
      style: StandardizedTextStyle.taskMeta,
      color: color,
      textAlign: textAlign,
    );
  }

  /// Button text with proper weight
  static Widget button(
    String text, {
    Color? color,
  }) {
    return StandardizedText(
      text,
      style: StandardizedTextStyle.buttonText,
      color: color,
    );
  }
}