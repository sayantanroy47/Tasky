import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/standardized_spacing.dart';
import '../widgets/standardized_text.dart';
import '../widgets/standardized_colors.dart';
import '../widgets/universal_profile_picture.dart';
import '../providers/profile_providers.dart';
import '../../core/theme/typography_constants.dart';
import '../../domain/entities/user_profile.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/enhanced_glass_button.dart';
import '../widgets/theme_background_widget.dart';
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
    final theme = Theme.of(context);
    final profileAsync = ref.watch(currentProfileProvider);
    
    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: context.colors.backgroundTransparent,
        extendBodyBehindAppBar: true,
        appBar: const StandardizedAppBar(
          title: 'Profile',
          centerTitle: true,
        ),
        body: SafeArea(
          child: profileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => _buildErrorState(theme),
            data: (profile) => _buildProfileForm(theme, profile),
          ),
        ),
      ),
    );
  }
  
  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.lg),
        child: GlassmorphismContainer(
          level: GlassLevel.floating,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
          padding: StandardizedSpacing.padding(SpacingSize.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIcons.warningCircle(),
                size: 64,
                color: theme.colorScheme.error,
              ),
              StandardizedGaps.vertical(SpacingSize.md),
              StandardizedText(
                'Failed to load profile',
                style: StandardizedTextStyle.titleLarge,
                color: theme.colorScheme.error,
              ),
              StandardizedGaps.vertical(SpacingSize.xs),
              StandardizedText(
                'Please try again',
                style: StandardizedTextStyle.bodyMedium,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              StandardizedGaps.vertical(SpacingSize.md),
              EnhancedGlassButton(
                onPressed: () => ref.invalidate(currentProfileProvider),
                child: const StandardizedText('Retry', style: StandardizedTextStyle.buttonText),
              ),
            ],
          ),
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
    
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: kToolbarHeight + 32, // App bar height + elegant spacing
        left: 24,
        right: 24,
        bottom: 32,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroProfileSection(theme, profile),
            StandardizedGaps.vertical(SpacingSize.xxl),
            _buildPersonalInfoSection(theme),
            StandardizedGaps.vertical(SpacingSize.lg),
            _buildLocationSection(theme),
            StandardizedGaps.vertical(SpacingSize.xxl),
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeroProfileSection(ThemeData theme, UserProfile? profile) {
    return GlassmorphismContainer(
      level: GlassLevel.floating,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusXLarge),
      padding: StandardizedSpacing.padding(SpacingSize.xl),
      child: Column(
        children: [
          // Profile picture with elegant backdrop
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: const UniversalProfilePictureLarge(),
          ),
          StandardizedGaps.vertical(SpacingSize.md),
          
          // Welcome message or name display
          if (profile?.firstName != null) ...[
            StandardizedText(
              'Welcome, ${profile!.firstName}!',
              style: StandardizedTextStyle.headlineSmall,
              color: theme.colorScheme.onSurface,
            ),
            if (profile.lastName?.isNotEmpty == true) 
              StandardizedText(
                profile.lastName!,
                style: StandardizedTextStyle.titleMedium,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ] else ...[
            StandardizedText(
              'Welcome!',
              style: StandardizedTextStyle.headlineSmall,
              color: theme.colorScheme.onSurface,
            ),
            StandardizedText(
              'Set up your profile',
              style: StandardizedTextStyle.bodyMedium,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
          
          StandardizedGaps.vertical(SpacingSize.md),
          
          // Photo actions with elegant glass buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              EnhancedGlassButton.secondary(
                onPressed: _changeProfilePicture,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIcons.camera(), size: 16),
                    const SizedBox(width: 8),
                    const StandardizedText('Change Photo', style: StandardizedTextStyle.labelMedium),
                  ],
                ),
              ),
              StandardizedGaps.horizontal(SpacingSize.md),
              EnhancedGlassButton.secondary(
                onPressed: _removeProfilePicture,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIcons.trash(), size: 16, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    StandardizedText('Remove', style: StandardizedTextStyle.labelMedium, color: theme.colorScheme.error),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPersonalInfoSection(ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      padding: StandardizedSpacing.padding(SpacingSize.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with elegant styling
          Row(
            children: [
              GlassmorphismContainer(
                level: GlassLevel.interactive,
                width: 32,
                height: 32,
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                glassTint: theme.colorScheme.primary.withValues(alpha: 0.15),
                child: Icon(
                  PhosphorIcons.user(),
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
              StandardizedGaps.horizontal(SpacingSize.sm),
              StandardizedText(
                'Personal Information',
                style: StandardizedTextStyle.titleMedium,
                color: theme.colorScheme.onSurface,
              ),
            ],
          ),
          StandardizedGaps.vertical(SpacingSize.lg),
          
          // Form fields with glassmorphism styling
          GlassmorphismContainer(
            level: GlassLevel.interactive,
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            child: TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name *',
                hintText: 'Enter your first name',
                prefixIcon: Icon(PhosphorIcons.user()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
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
          ),
          
          StandardizedGaps.vertical(SpacingSize.md),
          
          GlassmorphismContainer(
            level: GlassLevel.interactive,
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            child: TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                hintText: 'Enter your last name',
                prefixIcon: Icon(PhosphorIcons.userCheck()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
                  return 'Last name must be at least 2 characters';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLocationSection(ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      padding: StandardizedSpacing.padding(SpacingSize.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with elegant styling
          Row(
            children: [
              GlassmorphismContainer(
                level: GlassLevel.interactive,
                width: 32,
                height: 32,
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                glassTint: theme.colorScheme.secondary.withValues(alpha: 0.15),
                child: Icon(
                  PhosphorIcons.mapPin(),
                  size: 16,
                  color: theme.colorScheme.secondary,
                ),
              ),
              StandardizedGaps.horizontal(SpacingSize.sm),
              StandardizedText(
                'Location',
                style: StandardizedTextStyle.titleMedium,
                color: theme.colorScheme.onSurface,
              ),
            ],
          ),
          StandardizedGaps.vertical(SpacingSize.lg),
          
          // Location field with glassmorphism styling
          GlassmorphismContainer(
            level: GlassLevel.interactive,
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            child: TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location (Optional)',
                hintText: 'Enter your location',
                prefixIcon: Icon(PhosphorIcons.mapPin()),
                suffixIcon: IconButton(
                  onPressed: _useCurrentLocation,
                  icon: Icon(
                    PhosphorIcons.crosshair(),
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  tooltip: 'Use current location',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        // Primary save button
        SizedBox(
          width: double.infinity,
          child: EnhancedGlassButton(
            onPressed: _isLoading ? null : _saveProfile,
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  StandardizedGaps.horizontal(SpacingSize.sm),
                ] else ...[
                  Icon(PhosphorIcons.check(), size: 20, color: Colors.white),
                  StandardizedGaps.horizontal(SpacingSize.sm),
                ],
                StandardizedText(
                  _isLoading ? 'Saving Profile...' : 'Save Profile',
                  style: StandardizedTextStyle.buttonText,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        
        StandardizedGaps.vertical(SpacingSize.sm),
        
        // Secondary cancel button
        SizedBox(
          width: double.infinity,
          child: EnhancedGlassButton.secondary(
            onPressed: () => Navigator.of(context).pop(),
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIcons.x(), size: 16, color: theme.colorScheme.onSurface),
                StandardizedGaps.horizontal(SpacingSize.sm),
                StandardizedText(
                  'Cancel',
                  style: StandardizedTextStyle.labelLarge,
                  color: theme.colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
      ],
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