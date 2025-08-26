import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'standardized_colors.dart';


/// Standardized Floating Action Button with consistent glassmorphism design
/// Eliminates FAB implementation anarchy across the app
class StandardizedFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? tooltip;
  final String? heroTag;
  final IconData? icon;
  final bool isLarge;
  final FABColorType colorType;
  
  const StandardizedFAB({
    super.key,
    required this.onPressed,
    this.tooltip,
    this.heroTag,
    this.icon,
    this.isLarge = false,
    this.colorType = FABColorType.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final size = isLarge ? 72.0 : 56.0;
    final iconSize = isLarge ? 28.0 : 24.0;
    
    final fabColors = _getFABColors(theme, colors, colorType);
    
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        // No shadow for clean appearance
      ),
      child: Semantics(
        label: tooltip ?? 'Create',
        hint: 'Double tap to create new item',
        button: true,
        child: SizedBox(
          width: size,
          height: size,
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Consistent theme border
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  // Clean solid color without tertiary gradient
                  color: fabColors.baseColor,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onPressed,
                    borderRadius: BorderRadius.circular(size / 2),
                    child: Center(
                      child: Icon(
                        icon ?? PhosphorIcons.plus(),
                        size: iconSize,
                        color: fabColors.iconColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Get colors for different FAB types
  _FABColors _getFABColors(ThemeData theme, StandardizedColors colors, FABColorType colorType) {
    switch (colorType) {
      case FABColorType.primary:
        return _FABColors(
          baseColor: colors.interactive,
          accentColor: colors.fabTertiary, // Enhanced: Use dedicated FAB tertiary color
          iconColor: theme.brightness == Brightness.dark 
            ? colors.iconOnPrimary 
            : theme.colorScheme.onPrimary, // Use onPrimary (white) for light theme contrast
        );
      case FABColorType.secondary:
        return _FABColors(
          baseColor: colors.fabTertiaryContainer, // Enhanced: Use FAB tertiary container
          accentColor: colors.fabTertiary, // Enhanced: Tertiary accent
          iconColor: colors.getTertiaryTextColor(TertiaryColorType.secondaryAction),
        );
      case FABColorType.tertiary:
        return _FABColors(
          baseColor: colors.fabTertiary, // Direct tertiary FAB color
          accentColor: colors.navigationTertiary, // Navigation tertiary blend
          iconColor: colors.getTertiaryTextColor(TertiaryColorType.interactiveAccent),
        );
      case FABColorType.accent:
        return _FABColors(
          baseColor: colors.getTertiaryColor(TertiaryColorType.achievement), // Achievement tertiary
          accentColor: colors.tertiaryActivated, // Enhanced tertiary state
          iconColor: colors.getTertiaryTextColor(TertiaryColorType.achievement),
        );
    }
  }
}

/// Internal class for FAB color configuration
class _FABColors {
  final Color baseColor;
  final Color accentColor;
  final Color iconColor;
  
  const _FABColors({
    required this.baseColor,
    required this.accentColor,
    required this.iconColor,
  });
}

/// FAB color types for semantic usage
enum FABColorType {
  /// Primary action FAB - main call-to-action (create task, main action)
  primary,
  
  /// Secondary action FAB - supporting actions (add to project, secondary create)
  secondary,
  
  /// Tertiary accent FAB - feature highlights, special actions
  tertiary,
  
  /// Accent FAB - achievements, celebrations, featured content
  accent,
}

/// FAB variants for different contexts with tertiary color support
class StandardizedFABVariants {
  // Primary variants
  static Widget create({
    required VoidCallback? onPressed,
    String? heroTag,
    bool isLarge = false,
  }) {
    return StandardizedFAB(
      onPressed: onPressed,
      tooltip: 'Create new task',
      heroTag: heroTag ?? 'createFAB',
      icon: PhosphorIcons.plus(),
      isLarge: isLarge,
      colorType: FABColorType.primary,
    );
  }
  
  static Widget createProject({
    required VoidCallback? onPressed,
    String? heroTag,
    bool isLarge = false,
  }) {
    return StandardizedFAB(
      onPressed: onPressed,
      tooltip: 'Create new project',
      heroTag: heroTag ?? 'createProjectFAB',
      icon: PhosphorIcons.folder(),
      isLarge: isLarge,
      colorType: FABColorType.primary,
    );
  }
  
  // Secondary variants using tertiary colors
  static Widget addToProject({
    required VoidCallback? onPressed,
    String? heroTag,
    bool isLarge = false,
  }) {
    return StandardizedFAB(
      onPressed: onPressed,
      tooltip: 'Add to project',
      heroTag: heroTag ?? 'addToProjectFAB',
      icon: PhosphorIcons.folderPlus(),
      isLarge: isLarge,
      colorType: FABColorType.secondary,
    );
  }
  
  static Widget quickNote({
    required VoidCallback? onPressed,
    String? heroTag,
    bool isLarge = false,
  }) {
    return StandardizedFAB(
      onPressed: onPressed,
      tooltip: 'Quick note',
      heroTag: heroTag ?? 'quickNoteFAB',
      icon: PhosphorIcons.notepad(),
      isLarge: isLarge,
      colorType: FABColorType.secondary,
    );
  }
  
  // Tertiary accent variants
  static Widget voiceCreate({
    required VoidCallback? onPressed,
    String? heroTag,
    bool isLarge = false,
  }) {
    return StandardizedFAB(
      onPressed: onPressed,
      tooltip: 'Voice create',
      heroTag: heroTag ?? 'voiceCreateFAB',
      icon: PhosphorIcons.microphone(),
      isLarge: isLarge,
      colorType: FABColorType.tertiary,
    );
  }
  
  static Widget aiAssist({
    required VoidCallback? onPressed,
    String? heroTag,
    bool isLarge = false,
  }) {
    return StandardizedFAB(
      onPressed: onPressed,
      tooltip: 'AI Assistant',
      heroTag: heroTag ?? 'aiAssistFAB',
      icon: PhosphorIcons.sparkle(),
      isLarge: isLarge,
      colorType: FABColorType.tertiary,
    );
  }
  
  // Accent variants for special occasions
  static Widget celebration({
    required VoidCallback? onPressed,
    String? heroTag,
    bool isLarge = false,
  }) {
    return StandardizedFAB(
      onPressed: onPressed,
      tooltip: 'Celebrate achievement',
      heroTag: heroTag ?? 'celebrationFAB',
      icon: PhosphorIcons.confetti(),
      isLarge: isLarge,
      colorType: FABColorType.accent,
    );
  }
  
  static Widget featured({
    required VoidCallback? onPressed,
    String? heroTag,
    bool isLarge = false,
    IconData? customIcon,
  }) {
    return StandardizedFAB(
      onPressed: onPressed,
      tooltip: 'Featured action',
      heroTag: heroTag ?? 'featuredFAB',
      icon: customIcon ?? PhosphorIcons.star(),
      isLarge: isLarge,
      colorType: FABColorType.accent,
    );
  }

  // Additional tertiary-focused variants
  static Widget analytics({
    required VoidCallback? onPressed,
    String? heroTag,
    bool isLarge = false,
  }) {
    return StandardizedFAB(
      onPressed: onPressed,
      tooltip: 'View analytics',
      heroTag: heroTag ?? 'analyticsFAB',
      icon: PhosphorIcons.chartBar(),
      isLarge: isLarge,
      colorType: FABColorType.tertiary, // Tertiary for data visualization
    );
  }

  static Widget progress({
    required VoidCallback? onPressed,
    String? heroTag,
    bool isLarge = false,
  }) {
    return StandardizedFAB(
      onPressed: onPressed,
      tooltip: 'View progress',
      heroTag: heroTag ?? 'progressFAB',
      icon: PhosphorIcons.trendUp(),
      isLarge: isLarge,
      colorType: FABColorType.tertiary, // Tertiary for progress indicators
    );
  }

  static Widget success({
    required VoidCallback? onPressed,
    String? heroTag,
    bool isLarge = false,
  }) {
    return StandardizedFAB(
      onPressed: onPressed,
      tooltip: 'Mark complete',
      heroTag: heroTag ?? 'successFAB',
      icon: PhosphorIcons.check(),
      isLarge: isLarge,
      colorType: FABColorType.tertiary, // Tertiary for success states
    );
  }
}