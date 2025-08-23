import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/theme_background_widget.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/universal_profile_picture.dart';
import '../providers/profile_providers.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';
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
    _loadProfileData();
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }
  
  /// Load existing profile data
  void _loadProfileData() {
    // Load profile data from providers
    final profileAsync = ref.read(currentProfileProvider);
    profileAsync.when(
      data: (profile) {
        if (profile != null) {
          _firstNameController.text = profile.firstName;
          _lastNameController.text = profile.lastName ?? '';
          _locationController.text = profile.location ?? '';
        } else {
          // No profile exists, use empty fields
          _firstNameController.text = '';
          _lastNameController.text = '';
          _locationController.text = '';
        }
      },
      loading: () {
        // Keep current values while loading
      },
      error: (error, stackTrace) {
        // Show error but keep current values
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $error')),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const StandardizedAppBar(
          title: 'Profile Settings',
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
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
      ),
    );
  }
  
  /// Build profile picture section
  Widget _buildProfilePictureSection(ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        children: [
          const UniversalProfilePictureLarge(),
          const SizedBox(height: 16),
          Text(
            'Profile Picture',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: TypographyConstants.medium,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _changeProfilePicture,
                icon: Icon(PhosphorIcons.camera(), size: 18),
                label: const Text('Change'),
              ),
              const SizedBox(width: 16),
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
    );
  }
  
  /// Build personal information section
  Widget _buildPersonalInfoSection(ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
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
                style: theme.textTheme.titleMedium?.copyWith(
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
    );
  }
  
  /// Build location section
  Widget _buildLocationSection(ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
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
                style: theme.textTheme.titleMedium?.copyWith(
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
    );
  }
  
  /// Build save button
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
          ),
        ),
      ),
    );
  }
  
  /// Handle profile picture change
  void _changeProfilePicture() async {
    try {
      final profileOperations = ref.read(profileOperationsProvider);
      final imagePath = await profileOperations.updateProfilePictureFromGallery();
      
      if (imagePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
        // The UI will automatically update due to provider invalidation
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile picture: $e')),
        );
      }
    }
  }
  
  /// Handle profile picture removal
  void _removeProfilePicture() async {
    try {
      final profileOperations = ref.read(profileOperationsProvider);
      await profileOperations.removeProfilePicture();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture removed successfully!')),
        );
        // The UI will automatically update due to provider invalidation
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove profile picture: $e')),
        );
      }
    }
  }
  
  /// Use current location
  void _useCurrentLocation() {
    // TODO: Implement current location detection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Current location detection coming soon!')),
    );
  }
  
  /// Save profile data
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