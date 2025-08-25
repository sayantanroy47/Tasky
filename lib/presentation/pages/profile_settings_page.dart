import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/standardized_spacing.dart';
import '../widgets/standardized_text.dart';
import '../widgets/universal_profile_picture.dart';
import '../providers/profile_providers.dart';
import '../../core/theme/typography_constants.dart';
import '../../domain/entities/user_profile.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Profile Settings Page for managing user profile information
class ProfileSettingsPage extends ConsumerStatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  ConsumerState<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends ConsumerState<ProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _locationController = TextEditingController();
  
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    debugPrint('ProfileSettingsPage build() called');
    
    final theme = Theme.of(context);
    final profileAsync = ref.watch(currentProfileProvider);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: const StandardizedAppBar(
        title: 'Profile Settings',
        centerTitle: true,
      ),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _buildErrorState(theme),
          data: (profile) => _buildProfileForm(theme, profile),
        ),
      ),
    );
  }
  
  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load profile',
              style: StandardizedTextStyle.titleLarge.toTextStyle(context).copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again',
              style: StandardizedTextStyle.bodyMedium.toTextStyle(context),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(currentProfileProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileForm(ThemeData theme, UserProfile? profile) {
    // Initialize controllers with profile data
    if (profile != null) {
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName ?? '';
      _locationController.text = profile.location ?? '';
    } else {
      _firstNameController.text = '';
      _lastNameController.text = '';
      _locationController.text = '';
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.only(
                top: kToolbarHeight + 28, // App bar height + spacing
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfilePictureSection(theme),
                    const SizedBox(height: 32),
                    _buildPersonalInfoSection(theme),
                    const SizedBox(height: 24),
                    _buildLocationSection(theme),
                    const SizedBox(height: 32),
                    _buildSaveButton(theme),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildProfilePictureSection(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const UniversalProfilePictureLarge(),
            const SizedBox(height: 16),
            Text(
              'Profile Picture',
              style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                fontWeight: TypographyConstants.medium,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              alignment: WrapAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _changeProfilePicture,
                  icon: Icon(PhosphorIcons.camera(), size: 18),
                  label: const Text('Change'),
                ),
                TextButton.icon(
                  onPressed: _removeProfilePicture,
                  icon: Icon(PhosphorIcons.trash(), size: 18),
                  label: const Text('Remove'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPersonalInfoSection(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  PhosphorIcons.user(),
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Personal Information',
                  style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                    fontWeight: TypographyConstants.medium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                hintText: 'Enter your first name',
                prefixIcon: Icon(PhosphorIcons.user()),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'First name is required';
                }
                if (value.trim().length < 2) {
                  return 'First name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                hintText: 'Enter your last name',
                prefixIcon: Icon(PhosphorIcons.userCheck()),
              ),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
                  return 'Last name must be at least 2 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLocationSection(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  PhosphorIcons.mapPin(),
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Location',
                  style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                    fontWeight: TypographyConstants.medium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location (Optional)',
                hintText: 'Enter your location',
                prefixIcon: Icon(PhosphorIcons.mapPin()),
                suffixIcon: IconButton(
                  onPressed: _useCurrentLocation,
                  icon: Icon(PhosphorIcons.crosshair()),
                  tooltip: 'Use current location',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSaveButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveProfile,
        icon: _isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(PhosphorIcons.check()),
        label: Text(_isLoading ? 'Saving...' : 'Save Profile'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
          ),
        ),
      ),
    );
  }
  
  void _changeProfilePicture() async {
    try {
      final profileOperations = ref.read(profileOperationsProvider);
      final imagePath = await profileOperations.updateProfilePictureFromGallery();
      
      if (imagePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile picture: $e')),
        );
      }
    }
  }
  
  void _removeProfilePicture() async {
    try {
      final profileOperations = ref.read(profileOperationsProvider);
      await profileOperations.removeProfilePicture();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture removed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove profile picture: $e')),
        );
      }
    }
  }
  
  void _useCurrentLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Current location detection coming soon!')),
    );
  }
  
  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final profileOperations = ref.read(profileOperationsProvider);
      
      await profileOperations.updateProfileFields(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty 
          ? null 
          : _lastNameController.text.trim(),
        location: _locationController.text.trim().isEmpty 
          ? null 
          : _locationController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}