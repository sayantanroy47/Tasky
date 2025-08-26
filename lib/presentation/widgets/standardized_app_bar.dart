import 'package:flutter/material.dart';
import 'dart:ui';
import 'universal_profile_picture.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'standardized_colors.dart';
import 'standardized_text.dart';

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
  final bool useTertiaryAccent; // NEW: Enable tertiary color accents
  
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
    this.useTertiaryAccent = false, // Enable tertiary accents for special screens
  });

  /// Convenience constructor for app bars with tertiary accents
  /// Use this for special screens like analytics, settings, or featured content
  const StandardizedAppBar.withTertiaryAccent({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.elevation,
    this.centerTitle = false,
    this.backgroundColor,
    this.forceBackButton = true,
    this.showProfilePicture = true,
  }) : useTertiaryAccent = true;
  
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
      
      title: StandardizedText(
        title,
        style: StandardizedTextStyle.titleLarge,
      ),
      actions: _buildActions(),
      bottom: bottom,
      
      // Enhanced glassmorphism background effect with theme-aware colors
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: useTertiaryAccent ? [
              // Tertiary-enhanced gradient for special screens
              theme.colorScheme.primary.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.4),
              theme.colorScheme.secondary.withValues(alpha: theme.brightness == Brightness.dark ? 0.15 : 0.3),
              context.appBarTertiaryColor.withValues(alpha: 0.1), // More visible tertiary tint
            ] : [
              // Theme-specific primary/secondary gradient
              theme.colorScheme.primary.withValues(alpha: theme.brightness == Brightness.dark ? 0.15 : 0.35),
              theme.colorScheme.secondary.withValues(alpha: theme.brightness == Brightness.dark ? 0.1 : 0.25),
            ],
            stops: useTertiaryAccent ? [0.0, 0.7, 1.0] : [0.0, 1.0],
          ),
          border: Border(
            bottom: BorderSide(
              color: useTertiaryAccent 
                ? context.appBarTertiaryColor.withValues(alpha: 0.4) // Stronger tertiary accent border
                : theme.colorScheme.primary.withValues(alpha: 0.3), // Theme primary border
              width: useTertiaryAccent ? 1.0 : 0.8, // Slightly stronger border for visibility
            ),
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: useTertiaryAccent 
                ? context.appBarTertiaryColor.withValues(alpha: 0.05) // More visible tertiary tint
                : theme.colorScheme.primaryContainer.withValues(alpha: theme.brightness == Brightness.dark ? 0.08 : 0.12),
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

