import '../entities/user_profile.dart';

/// Abstract repository interface for user profile operations
/// 
/// This interface defines all the operations that can be performed on user profiles.
/// Since user profiles follow a singleton pattern (one profile per app installation),
/// most operations focus on the current profile rather than collections.
abstract class UserProfileRepository {
  /// Gets the current user profile
  /// Returns null if no profile has been created yet
  Future<UserProfile?> getCurrentProfile();

  /// Checks if a user profile exists
  Future<bool> profileExists();

  /// Creates a new user profile
  /// This should only be called once during app setup
  Future<void> createProfile(UserProfile profile);

  /// Updates the existing user profile
  Future<void> updateProfile(UserProfile profile);

  /// Updates only specific fields of the profile
  Future<void> updateProfileFields({
    String? firstName,
    String? lastName,
    String? profilePicturePath,
    String? location,
  });

  /// Updates the profile picture path
  Future<void> updateProfilePicture(String? profilePicturePath);

  /// Removes the profile picture (sets to null)
  Future<void> removeProfilePicture();

  /// Deletes the user profile
  /// This should only be used in rare cases like app reset
  Future<void> deleteProfile();

  /// Gets the user's display name quickly without loading full profile
  Future<String?> getDisplayName();

  /// Gets the user's initials quickly without loading full profile
  Future<String?> getInitials();

  /// Watches the current user profile (returns a stream for reactive UI)
  Stream<UserProfile?> watchCurrentProfile();

  // Image file management methods
  
  /// Saves an image file and returns the local path
  Future<String> saveProfileImage(String sourcePath);

  /// Deletes the profile image file from local storage
  Future<void> deleteProfileImageFile(String? imagePath);

  // First-time setup helpers
  
  /// Creates a new profile with validation
  Future<UserProfile> setupProfile({
    required String firstName,
    String? lastName,
    String? imagePath,
    String? location,
  });

  /// Checks if the app needs first-time profile setup
  Future<bool> needsSetup();
}