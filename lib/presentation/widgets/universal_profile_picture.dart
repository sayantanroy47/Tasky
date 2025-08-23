import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../core/theme/typography_constants.dart';
import '../pages/profile_settings_page.dart';
import '../providers/profile_providers.dart';

/// Universal profile picture widget used across all app bars
/// Shows custom image or generated avatar, navigates to profile settings on tap
class UniversalProfilePicture extends ConsumerWidget {
  final double size;
  final bool showBorder;
  final VoidCallback? customOnTap;

  const UniversalProfilePicture({
    super.key,
    this.size = 36.0,
    this.showBorder = true,
    this.customOnTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Watch the current profile
    final profileAsync = ref.watch(currentProfileProvider);
    
    return profileAsync.when(
      data: (profile) => _buildProfilePicture(
        context,
        theme,
        profile?.hasProfilePicture ?? false,
        profile?.profilePicturePath,
        profile?.firstName ?? 'User',
        profile?.lastName,
      ),
      loading: () => _buildLoadingPicture(theme),
      error: (_, __) => _buildErrorPicture(theme),
    );
  }

  /// Build the profile picture widget with actual data
  Widget _buildProfilePicture(
    BuildContext context,
    ThemeData theme,
    bool hasProfilePicture,
    String? profilePicturePath,
    String firstName,
    String? lastName,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: customOnTap ?? () => _navigateToProfileSettings(context),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: showBorder
                ? Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 2.0,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: hasProfilePicture && profilePicturePath != null
                ? _buildCustomImage(profilePicturePath)
                : _buildAvatar(firstName, lastName, theme),
          ),
        ),
      ),
    );
  }

  /// Build custom profile image from file path
  Widget _buildCustomImage(String imagePath) {
    return Image.file(
      File(imagePath),
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to avatar if image fails to load
        final theme = Theme.of(context);
        return _buildAvatar('User', '', theme);
      },
    );
  }

  /// Build generated avatar from initials
  Widget _buildAvatar(String firstName, String? lastName, ThemeData theme) {
    final initials = _getInitials(firstName, lastName);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: size * 0.4, // Dynamic font size based on widget size
            fontWeight: TypographyConstants.medium,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  /// Generate initials from first and last name
  String _getInitials(String firstName, String? lastName) {
    String initials = '';
    
    if (firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }
    
    if (lastName != null && lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }
    
    // Default to 'U' if no names provided
    return initials.isEmpty ? 'U' : initials;
  }

  /// Build loading state picture
  Widget _buildLoadingPicture(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surfaceContainerHighest,
          border: showBorder
              ? Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  width: 1.0,
                )
              : null,
        ),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  /// Build error state picture (shows default avatar)
  Widget _buildErrorPicture(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: showBorder
              ? Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                  width: 2.0,
                )
              : null,
        ),
        child: ClipOval(
          child: _buildAvatar('?', null, theme),
        ),
      ),
    );
  }

  /// Navigate to profile settings page
  void _navigateToProfileSettings(BuildContext context) {
    try {
      debugPrint('PROFILE ICON CLICKED - Navigating to ProfileSettingsPage');
      
      if (!context.mounted) {
        debugPrint('Context not mounted - cannot navigate');
        return;
      }
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            debugPrint('Building ProfileSettingsPage');
            return const ProfileSettingsPage();
          },
        ),
      ).catchError((error) {
        debugPrint('Navigation error: $error');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to open profile settings: $error')),
          );
        }
      });
    } catch (e) {
      debugPrint('Profile navigation crash: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open profile settings right now')),
        );
      }
    }
  }
}

/// Smaller variant for compact spaces
class UniversalProfilePictureSmall extends UniversalProfilePicture {
  const UniversalProfilePictureSmall({
    super.key,
    super.customOnTap,
  }) : super(size: 28.0, showBorder: false);
}

/// Larger variant for profile pages
class UniversalProfilePictureLarge extends UniversalProfilePicture {
  const UniversalProfilePictureLarge({
    super.key,
    super.customOnTap,
  }) : super(size: 80.0, showBorder: true);
}