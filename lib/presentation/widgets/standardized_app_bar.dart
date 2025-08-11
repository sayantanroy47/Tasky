import 'package:flutter/material.dart';
import '../../core/theme/typography_constants.dart';

/// Standardized AppBar widget for consistent design across all screens
class StandardizedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final double? elevation;
  final bool centerTitle;
  final Color? backgroundColor;
  final bool transparent;
  
  const StandardizedAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.elevation,
    this.centerTitle = false,
    this.backgroundColor,
    this.transparent = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      backgroundColor: transparent 
          ? Colors.transparent 
          : backgroundColor ?? theme.colorScheme.surface.withOpacity(0.95),
      elevation: elevation ?? 0,
      centerTitle: centerTitle,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: Text(
        title,
        style: TextStyle(
          fontSize: TypographyConstants.titleLarge,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      actions: actions,
      bottom: bottom,
      flexibleSpace: transparent ? Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface.withOpacity(0.1),
              theme.colorScheme.surface.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
      ) : null,
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
  );
}