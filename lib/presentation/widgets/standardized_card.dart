import 'package:flutter/material.dart';

import '../../core/design_system/design_tokens.dart';
import '../../core/theme/typography_constants.dart';
import 'glassmorphism_container.dart';

/// Unified card system that eliminates card implementation chaos
/// 
/// Replaces all fragmented card implementations:
/// - GlassProjectCard
/// - AdvancedTaskCard (6 different styles)
/// - QuickTaskCard  
/// - Custom Container-based cards
///
/// Provides consistent visual hierarchy and theming across the entire app
class StandardizedCard extends StatelessWidget {
  final Widget child;
  final StandardizedCardStyle style;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Color? accentColor;
  final String? heroTag;
  final bool showAccentBorder;
  final bool enableFeedback;

  const StandardizedCard({
    super.key,
    required this.child,
    this.style = StandardizedCardStyle.elevated,
    this.onTap,
    this.onLongPress,
    this.margin,
    this.padding,
    this.elevation,
    this.accentColor,
    this.heroTag,
    this.showAccentBorder = false,
    this.enableFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget cardWidget;
    
    switch (style) {
      case StandardizedCardStyle.elevated:
        cardWidget = _buildElevatedCard(theme);
        break;
      case StandardizedCardStyle.glass:
        cardWidget = _buildGlassCard(theme);
        break;
      case StandardizedCardStyle.outlined:
        cardWidget = _buildOutlinedCard(theme);
        break;
      case StandardizedCardStyle.filled:
        cardWidget = _buildFilledCard(theme);
        break;
      case StandardizedCardStyle.minimal:
        cardWidget = _buildMinimalCard(theme);
        break;
      case StandardizedCardStyle.compact:
        cardWidget = _buildCompactCard(theme);
        break;
    }

    // Add consistent margin
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: heroTag != null 
        ? Hero(tag: heroTag!, child: cardWidget)
        : cardWidget,
    );
  }

  Widget _buildElevatedCard(ThemeData theme) {
    return Card(
      elevation: elevation ?? 4,
      shadowColor: accentColor?.withValues(alpha: 0.3),
      child: _buildCardInner(theme),
    );
  }

  Widget _buildGlassCard(ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: EdgeInsets.zero,
      borderColor: _getEffectiveBorderColor(theme),
      glassTint: accentColor?.withValues(alpha: 0.1),
      child: _buildCardInner(theme),
    );
  }

  Widget _buildOutlinedCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(
          color: _getEffectiveBorderColor(theme),
          width: showAccentBorder && accentColor != null ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      ),
      child: _buildCardInner(theme),
    );
  }

  Widget _buildFilledCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: accentColor?.withValues(alpha: 0.1) ?? theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        border: accentColor != null ? Border.all(
          color: accentColor!.withValues(alpha: 0.3),
          width: 1,
        ) : null,
      ),
      child: _buildCardInner(theme),
    );
  }

  Widget _buildMinimalCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      ),
      child: _buildCardInner(theme),
    );
  }

  Widget _buildCompactCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
      ),
      child: _buildCardInner(theme, compactPadding: true),
    );
  }

  Widget _buildCardInner(ThemeData theme, {bool compactPadding = false}) {
    final effectivePadding = padding ?? EdgeInsets.all(
      compactPadding ? SpacingTokens.md * 0.75 : SpacingTokens.md,
    );

    Widget inner = Padding(
      padding: effectivePadding,
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      inner = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          enableFeedback: enableFeedback,
          child: inner,
        ),
      );
    }

    return inner;
  }

  Color _getEffectiveBorderColor(ThemeData theme) {
    if (showAccentBorder && accentColor != null) {
      return accentColor!;
    }
    if (accentColor != null) {
      return accentColor!.withValues(alpha: 0.3);
    }
    return theme.colorScheme.outline.withValues(alpha: 0.3);
  }
}

/// Standardized card styles that replace all fragmented implementations
enum StandardizedCardStyle {
  /// Elevated Material card with shadow - replaces Card widgets
  elevated,
  
  /// Glass morphism card - replaces GlassProjectCard and AdvancedTaskCard.glass
  glass,
  
  /// Outlined card with border - replaces AdvancedTaskCard.outlined
  outlined,
  
  /// Filled background card - replaces AdvancedTaskCard.filled  
  filled,
  
  /// Minimal transparent card - replaces AdvancedTaskCard.minimal
  minimal,
  
  /// Compact card with reduced padding - replaces AdvancedTaskCard.compact
  compact,
}

/// Specialized standardized cards for common use cases
class StandardizedCardVariants {
  /// Project card with glass styling and project-specific defaults
  static Widget project({
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    Color? accentColor,
    EdgeInsetsGeometry? margin,
    bool showAccentBorder = true,
  }) {
    return StandardizedCard(
      style: StandardizedCardStyle.glass,
      onTap: onTap,
      onLongPress: onLongPress,
      accentColor: accentColor,
      margin: margin,
      showAccentBorder: showAccentBorder,
      child: child,
    );
  }

  /// Task card with elevated styling and task-specific defaults
  static Widget task({
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    Color? accentColor,
    EdgeInsetsGeometry? margin,
    double? elevation,
  }) {
    return StandardizedCard(
      style: StandardizedCardStyle.elevated,
      onTap: onTap,
      onLongPress: onLongPress,
      accentColor: accentColor,
      margin: margin,
      elevation: elevation,
      child: child,
    );
  }

  /// Quick/compact task card for lists
  static Widget quickTask({
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    Color? accentColor,
    EdgeInsetsGeometry? margin,
  }) {
    return StandardizedCard(
      style: StandardizedCardStyle.compact,
      onTap: onTap,
      onLongPress: onLongPress,
      accentColor: accentColor,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: child,
    );
  }

  /// Analytics/stats card with filled styling
  static Widget analytics({
    required Widget child,
    VoidCallback? onTap,
    Color? accentColor,
    EdgeInsetsGeometry? margin,
  }) {
    return StandardizedCard(
      style: StandardizedCardStyle.filled,
      onTap: onTap,
      accentColor: accentColor,
      margin: margin,
      child: child,
    );
  }

  /// Settings/preference card with outlined styling
  static Widget settings({
    required Widget child,
    VoidCallback? onTap,
    Color? accentColor,
    EdgeInsetsGeometry? margin,
  }) {
    return StandardizedCard(
      style: StandardizedCardStyle.outlined,
      onTap: onTap,
      accentColor: accentColor,
      margin: margin,
      child: child,
    );
  }

  /// Theme preview card with glass styling for theme galleries
  static Widget themePreview({
    required Widget child,
    VoidCallback? onTap,
    Color? accentColor,
    EdgeInsetsGeometry? margin,
    String? heroTag,
  }) {
    return StandardizedCard(
      style: StandardizedCardStyle.glass,
      onTap: onTap,
      accentColor: accentColor,
      margin: margin,
      heroTag: heroTag,
      showAccentBorder: true,
      child: child,
    );
  }
}