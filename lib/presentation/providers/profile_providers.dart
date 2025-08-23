import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../services/profile/profile_image_service.dart';
import '../../core/providers/core_providers.dart';

// Core service providers

/// Profile image service provider
final profileImageServiceProvider = Provider<ProfileImageService>((ref) {
  return ProfileImageService();
});

/// User profile repository provider
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final database = ref.read(databaseProvider);
  return UserProfileRepositoryImpl(database);
});

// Profile data providers

/// Current user profile provider
/// 
/// Provides the current user profile, or null if none exists.
/// This is a FutureProvider that loads the profile from the repository.
final currentProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final repository = ref.read(userProfileRepositoryProvider);
  return await repository.getCurrentProfile();
});

/// Profile existence provider
/// 
/// Checks if a user profile exists in the system.
final profileExistsProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(userProfileRepositoryProvider);
  return await repository.profileExists();
});

/// Profile setup needed provider
/// 
/// Determines if the app needs to show the first-time profile setup.
final profileSetupNeededProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(userProfileRepositoryProvider);
  return await repository.needsSetup();
});

/// User display name provider
/// 
/// Provides the user's display name quickly without loading the full profile.
final userDisplayNameProvider = FutureProvider<String?>((ref) async {
  final repository = ref.read(userProfileRepositoryProvider);
  return await repository.getDisplayName();
});

/// User initials provider
/// 
/// Provides the user's initials for avatar generation.
final userInitialsProvider = FutureProvider<String?>((ref) async {
  final repository = ref.read(userProfileRepositoryProvider);
  return await repository.getInitials();
});

// Reactive profile providers

/// Profile stream provider
/// 
/// Provides a stream of the current user profile for reactive UI updates.
final profileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final repository = ref.read(userProfileRepositoryProvider);
  return repository.watchCurrentProfile();
});

/// Profile avatar color provider
/// 
/// Provides the color for the user's generated avatar based on initials.
final profileAvatarColorProvider = Provider<String>((ref) {
  final profileAsync = ref.watch(currentProfileProvider);
  final imageService = ref.read(profileImageServiceProvider);

  return profileAsync.when(
    data: (profile) {
      if (profile != null) {
        final color = imageService.selectAvatarColor(profile.initials);
        return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
      }
      return '#2196F3'; // Default blue
    },
    loading: () => '#2196F3',
    error: (_, __) => '#2196F3',
  );
});

// Profile operations providers

/// Profile operations provider
/// 
/// Provides methods for creating, updating, and managing profiles.
final profileOperationsProvider = Provider<ProfileOperations>((ref) {
  final repository = ref.read(userProfileRepositoryProvider);
  final imageService = ref.read(profileImageServiceProvider);
  return ProfileOperations(repository, imageService, ref);
});

/// Profile operations class
/// 
/// Contains all the business logic for profile operations.
class ProfileOperations {
  final UserProfileRepository _repository;
  final ProfileImageService _imageService;
  final Ref _ref;

  ProfileOperations(this._repository, this._imageService, this._ref);

  /// Creates a new user profile
  Future<UserProfile> createProfile({
    required String firstName,
    String? lastName,
    String? imagePath,
    String? location,
  }) async {
    final profile = await _repository.setupProfile(
      firstName: firstName,
      lastName: lastName,
      imagePath: imagePath,
      location: location,
    );

    // Invalidate relevant providers to trigger UI updates
    _ref.invalidate(currentProfileProvider);
    _ref.invalidate(profileExistsProvider);
    _ref.invalidate(profileSetupNeededProvider);
    _ref.invalidate(userDisplayNameProvider);
    _ref.invalidate(userInitialsProvider);

    return profile;
  }

  /// Updates the current user profile
  Future<void> updateProfile(UserProfile profile) async {
    await _repository.updateProfile(profile);

    // Invalidate relevant providers
    _ref.invalidate(currentProfileProvider);
    _ref.invalidate(userDisplayNameProvider);
    _ref.invalidate(userInitialsProvider);
  }

  /// Updates specific profile fields
  Future<void> updateProfileFields({
    String? firstName,
    String? lastName,
    String? profilePicturePath,
    String? location,
  }) async {
    await _repository.updateProfileFields(
      firstName: firstName,
      lastName: lastName,
      profilePicturePath: profilePicturePath,
      location: location,
    );

    // Invalidate relevant providers
    _ref.invalidate(currentProfileProvider);
    _ref.invalidate(userDisplayNameProvider);
    _ref.invalidate(userInitialsProvider);
  }

  /// Updates the profile picture from gallery
  Future<String?> updateProfilePictureFromGallery() async {
    try {
      // Pick image from gallery
      final imagePath = await _imageService.pickImageFromGallery();
      if (imagePath == null) return null;

      // Save the image to app directory
      final savedPath = await _repository.saveProfileImage(imagePath);

      // Update the profile picture path
      await _repository.updateProfilePicture(savedPath);

      // Invalidate profile provider to trigger UI updates
      _ref.invalidate(currentProfileProvider);

      return savedPath;
    } catch (e) {
      throw ProfileOperationException('Failed to update profile picture: $e');
    }
  }

  /// Removes the current profile picture
  Future<void> removeProfilePicture() async {
    await _repository.removeProfilePicture();
    _ref.invalidate(currentProfileProvider);
  }

  /// Generates and saves an avatar from initials
  Future<String> generateAndSaveAvatar({
    required String firstName,
    String? lastName,
  }) async {
    try {
      // Generate avatar image
      final avatarBytes = await _imageService.generateAvatarFromName(
        firstName: firstName,
        lastName: lastName,
      );

      // Save to temporary file
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}';
      final tempPath = await _imageService.saveAvatarToTemp(avatarBytes, fileName);

      // Save as profile image
      final savedPath = await _repository.saveProfileImage(tempPath);

      // Clean up temporary file
      await _imageService.cleanupTempFiles([tempPath]);

      return savedPath;
    } catch (e) {
      throw ProfileOperationException('Failed to generate avatar: $e');
    }
  }

  /// Deletes the current profile
  Future<void> deleteProfile() async {
    await _repository.deleteProfile();

    // Invalidate all profile providers
    _ref.invalidate(currentProfileProvider);
    _ref.invalidate(profileExistsProvider);
    _ref.invalidate(profileSetupNeededProvider);
    _ref.invalidate(userDisplayNameProvider);
    _ref.invalidate(userInitialsProvider);
  }
}

// Profile UI state providers

/// Profile editing state provider
/// 
/// Manages the state of profile editing operations.
final profileEditingStateProvider = StateNotifierProvider<ProfileEditingStateNotifier, ProfileEditingState>((ref) {
  return ProfileEditingStateNotifier();
});

/// Profile editing state
enum ProfileEditingStatus { idle, loading, saving, error }

class ProfileEditingState {
  final ProfileEditingStatus status;
  final String? errorMessage;
  final bool hasUnsavedChanges;

  const ProfileEditingState({
    this.status = ProfileEditingStatus.idle,
    this.errorMessage,
    this.hasUnsavedChanges = false,
  });

  ProfileEditingState copyWith({
    ProfileEditingStatus? status,
    String? errorMessage,
    bool? hasUnsavedChanges,
  }) {
    return ProfileEditingState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

/// Profile editing state notifier
class ProfileEditingStateNotifier extends StateNotifier<ProfileEditingState> {
  ProfileEditingStateNotifier() : super(const ProfileEditingState());

  void setLoading() {
    state = state.copyWith(status: ProfileEditingStatus.loading);
  }

  void setSaving() {
    state = state.copyWith(status: ProfileEditingStatus.saving);
  }

  void setError(String message) {
    state = state.copyWith(
      status: ProfileEditingStatus.error,
      errorMessage: message,
    );
  }

  void setSuccess() {
    state = state.copyWith(
      status: ProfileEditingStatus.idle,
      errorMessage: null,
      hasUnsavedChanges: false,
    );
  }

  void setUnsavedChanges(bool hasChanges) {
    state = state.copyWith(hasUnsavedChanges: hasChanges);
  }

  void reset() {
    state = const ProfileEditingState();
  }
}

/// Profile setup flow state provider
/// 
/// Manages the state of the first-time profile setup flow.
final profileSetupStateProvider = StateNotifierProvider<ProfileSetupStateNotifier, ProfileSetupState>((ref) {
  return ProfileSetupStateNotifier();
});

/// Profile setup state
class ProfileSetupState {
  final int currentStep;
  final Map<String, dynamic> setupData;
  final bool isCompleting;
  final String? errorMessage;

  const ProfileSetupState({
    this.currentStep = 0,
    this.setupData = const {},
    this.isCompleting = false,
    this.errorMessage,
  });

  ProfileSetupState copyWith({
    int? currentStep,
    Map<String, dynamic>? setupData,
    bool? isCompleting,
    String? errorMessage,
  }) {
    return ProfileSetupState(
      currentStep: currentStep ?? this.currentStep,
      setupData: setupData ?? this.setupData,
      isCompleting: isCompleting ?? this.isCompleting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Profile setup state notifier
class ProfileSetupStateNotifier extends StateNotifier<ProfileSetupState> {
  ProfileSetupStateNotifier() : super(const ProfileSetupState());

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void updateData(Map<String, dynamic> data) {
    final newData = Map<String, dynamic>.from(state.setupData);
    newData.addAll(data);
    state = state.copyWith(setupData: newData);
  }

  void setCompleting(bool isCompleting) {
    state = state.copyWith(isCompleting: isCompleting);
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  void reset() {
    state = const ProfileSetupState();
  }
}

/// Exception thrown during profile operations
class ProfileOperationException implements Exception {
  final String message;

  const ProfileOperationException(this.message);

  @override
  String toString() => 'ProfileOperationException: $message';
}