import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';


/// Standardized Floating Action Button with consistent glassmorphism design
/// Eliminates FAB implementation anarchy across the app
class StandardizedFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? tooltip;
  final String? heroTag;
  final IconData? icon;
  final bool isLarge;
  
  const StandardizedFAB({
    super.key,
    required this.onPressed,
    this.tooltip,
    this.heroTag,
    this.icon,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = isLarge ? 72.0 : 56.0;
    final iconSize = isLarge ? 28.0 : 24.0;
    
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Standardized multi-layer glow effects for premium feel
        boxShadow: [
          // Outer glow - primary branding
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 4,
          ),
          // Middle glow - depth
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            spreadRadius: 2,
          ),
          // Inner glow - subtle highlight
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
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
                  // Sophisticated glassmorphism gradient
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.95),
                      theme.colorScheme.primary.withValues(alpha: 0.85),
                      theme.colorScheme.secondary.withValues(alpha: 0.1),
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
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
                        color: theme.colorScheme.onPrimary,
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
}

/// FAB variants for different contexts
class StandardizedFABVariants {
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
    );
  }
}