import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/theme/typography_constants.dart';
import 'universal_profile_picture.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
  final bool forceBackButton;
  final bool showProfilePicture;
  
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
    this.forceBackButton = true, // Always show back button by default
    this.showProfilePicture = true, // Show profile picture by default
  });
  
  /// Build the combined actions list with profile picture
  List<Widget> _buildActions() {
    final combinedActions = <Widget>[];
    
    // Add user-provided actions first
    if (actions != null) {
      combinedActions.addAll(actions!);
    }
    
    // Add profile picture as the rightmost action
    if (showProfilePicture) {
      combinedActions.add(const UniversalProfilePicture());
    }
    
    return combinedActions;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      // Transparent background for glassmorphism effect
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation ?? 0,
      centerTitle: centerTitle,
      foregroundColor: theme.colorScheme.onSurface, // Use theme-aware text color
      iconTheme: IconThemeData(color: theme.colorScheme.onSurface), // Fix icon colors
      actionsIconTheme: IconThemeData(color: theme.colorScheme.onSurface), // Fix action icon colors
      
      // Force back button or use provided leading widget
      leading: leading ?? (forceBackButton && Navigator.of(context).canPop() 
          ? IconButton(
              icon: Icon(PhosphorIcons.arrowLeft()),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
            )
          : null),
      automaticallyImplyLeading: automaticallyImplyLeading,
      
      title: Text(
        title,
        style: TextStyle(
          fontSize: TypographyConstants.titleLarge,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.5,
          color: theme.colorScheme.onSurface,
        ),
      ),
      actions: _buildActions(),
      bottom: bottom,
      
      // Enhanced glassmorphism background effect for better transparency
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface.withValues(alpha: 0.6),
              theme.colorScheme.surface.withValues(alpha: 0.4),
            ],
          ),
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: theme.colorScheme.surface.withValues(alpha: 0.05),
            ),
          ),
        ),
      ),
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
  );
}

