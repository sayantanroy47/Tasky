import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/profile_providers.dart';
import 'glassmorphism_container.dart';
import '../../core/design_system/design_tokens.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// First-time profile setup flow with step-by-step wizard
class ProfileSetupFlow extends ConsumerStatefulWidget {
  final VoidCallback onCompleted;

  const ProfileSetupFlow({
    super.key,
    required this.onCompleted,
  });

  @override
  ConsumerState<ProfileSetupFlow> createState() => _ProfileSetupFlowState();
}

class _ProfileSetupFlowState extends ConsumerState<ProfileSetupFlow> {
  final PageController _pageController = PageController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedImagePath;
  int _currentStep = 0;
  bool _isCompleting = false;

  static const int _totalSteps = 4;

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeSetup() async {
    if (_firstNameController.text.trim().isEmpty) {
      _showError('Please enter your first name');
      return;
    }

    setState(() {
      _isCompleting = true;
    });

    try {
      final profileOperations = ref.read(profileOperationsProvider);
      
      await profileOperations.createProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim().isEmpty 
          ? null 
          : _lastNameController.text.trim(),
        imagePath: _selectedImagePath,
        location: _locationController.text.trim().isEmpty 
          ? null 
          : _locationController.text.trim(),
      );

      if (mounted) {
        widget.onCompleted();
      }
    } catch (error) {
      if (mounted) {
        _showError('Failed to create profile: $error');
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImagePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(theme),
            
            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomeStep(theme),
                  _buildNameStep(theme),
                  _buildProfilePictureStep(theme),
                  _buildLocationStep(theme),
                ],
              ),
            ),
            
            // Navigation buttons
            _buildNavigationButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Step ${_currentStep + 1} of $_totalSteps',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '${((_currentStep + 1) / _totalSteps * 100).round()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.smiley(),
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            'Welcome to Tasky!',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Let\'s set up your profile so we can personalize your experience.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GlassmorphismContainer(
            level: GlassLevel.content,
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                Icon(
                  PhosphorIcons.checkCircle(),
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'Quick & Easy Setup',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Takes less than 2 minutes',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: _skipSetup,
            child: Text(
              'Skip setup for now',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Icon(
            PhosphorIcons.user(),
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'What\'s your name?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll use this to personalize your experience and welcome messages.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _firstNameController,
            decoration: InputDecoration(
              labelText: 'First Name',
              hintText: 'Enter your first name',
              prefixIcon: Icon(PhosphorIcons.user()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textCapitalization: TextCapitalization.words,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _lastNameController,
            decoration: InputDecoration(
              labelText: 'Last Name (Optional)',
              hintText: 'Enter your last name',
              prefixIcon: Icon(PhosphorIcons.users()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePictureStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Icon(
            PhosphorIcons.camera(),
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Add a profile picture?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Optional - you can always add or change this later in settings.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: _selectedImagePath != null
                      ? ClipOval(
                          child: Image.file(
                            File(_selectedImagePath!),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar(theme);
                            },
                          ),
                        )
                      : _buildDefaultAvatar(theme),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_selectedImagePath == null)
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(PhosphorIcons.camera()),
                        label: const Text('Add Photo'),
                      )
                    else ...[
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(PhosphorIcons.camera()),
                        label: const Text('Change'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _removeImage,
                        icon: Icon(PhosphorIcons.trash()),
                        label: const Text('Remove'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(ThemeData theme) {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final initials = '${firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U'}'
        '${lastName.isNotEmpty ? lastName[0].toUpperCase() : ''}';

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
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
            fontSize: 36,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Icon(
            PhosphorIcons.mapPin(),
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Where are you located?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Optional - helps with location-based reminders and suggestions.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Location (Optional)',
              hintText: 'e.g., San Francisco, CA',
              prefixIcon: Icon(PhosphorIcons.mapPin()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 24),
          GlassmorphismContainer(
            level: GlassLevel.content,
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(12),
            glassTint: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.shield(),
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your location is stored locally and never shared.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Main navigation row
          Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _previousStep,
                    icon: Icon(PhosphorIcons.arrowLeft()),
                    label: const Text('Back'),
                  ),
                ),
              
              if (_currentStep > 0) const SizedBox(width: 16),
              
              Expanded(
                child: _currentStep == _totalSteps - 1
                    ? ElevatedButton.icon(
                        onPressed: _isCompleting ? null : _completeSetup,
                        icon: _isCompleting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(PhosphorIcons.checkCircle()),
                        label: const Text('Complete Setup'),
                      )
                    : ElevatedButton.icon(
                        onPressed: _canProceed() ? _nextStep : null,
                        icon: Icon(PhosphorIcons.arrowRight()),
                        label: const Text('Continue'),
                      ),
              ),
            ],
          ),
          
          // Skip option (only show on non-final steps)
          if (_currentStep < _totalSteps - 1) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: _skipSetup,
              child: Text(
                'Skip setup completely',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0: // Welcome step
        return true;
      case 1: // Name step
        final canProceed = _firstNameController.text.trim().isNotEmpty;
        debugPrint('Step 1 - Can proceed: $canProceed, firstName: "${_firstNameController.text.trim()}"');
        return canProceed;
      case 2: // Profile picture step
        return true; // Optional step
      case 3: // Location step
        return true; // Optional step
      default:
        return false;
    }
  }

  void _skipSetup() {
    // Create a minimal profile with default values
    _completeSetupWithDefaults();
  }

  Future<void> _completeSetupWithDefaults() async {
    setState(() {
      _isCompleting = true;
    });

    try {
      final profileOperations = ref.read(profileOperationsProvider);
      
      await profileOperations.createProfile(
        firstName: 'User', // Default first name
        lastName: null,
        imagePath: null,
        location: null,
      );

      if (mounted) {
        widget.onCompleted();
      }
    } catch (error) {
      if (mounted) {
        _showError('Failed to skip setup: $error');
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }
}