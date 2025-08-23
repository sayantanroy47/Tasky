import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../domain/entities/user_profile.dart' as domain;
import '../../domain/repositories/user_profile_repository.dart';
import '../../services/database/database.dart';

/// Concrete implementation of UserProfileRepository using local database
/// 
/// This implementation uses the Drift/SQLite database through the UserProfileDao
/// to provide all user profile-related operations. It also handles local file
/// management for profile pictures.
class UserProfileRepositoryImpl implements UserProfileRepository {
  final AppDatabase _database;

  const UserProfileRepositoryImpl(this._database);

  @override
  Future<domain.UserProfile?> getCurrentProfile() async {
    return await _database.userProfileDao.getCurrentProfile();
  }

  @override
  Future<bool> profileExists() async {
    return await _database.userProfileDao.profileExists();
  }

  @override
  Future<void> createProfile(domain.UserProfile profile) async {
    await _database.userProfileDao.createProfile(profile);
  }

  @override
  Future<void> updateProfile(domain.UserProfile profile) async {
    await _database.userProfileDao.updateProfile(profile);
  }

  @override
  Future<void> updateProfileFields({
    String? firstName,
    String? lastName,
    String? profilePicturePath,
    String? location,
  }) async {
    await _database.userProfileDao.updateProfileFields(
      firstName: firstName,
      lastName: lastName,
      profilePicturePath: profilePicturePath,
      location: location,
    );
  }

  @override
  Future<void> updateProfilePicture(String? profilePicturePath) async {
    await _database.userProfileDao.updateProfilePicture(profilePicturePath);
  }

  @override
  Future<void> removeProfilePicture() async {
    // Get current profile to get the image path for deletion
    final currentProfile = await getCurrentProfile();
    if (currentProfile?.profilePicturePath != null) {
      await deleteProfileImageFile(currentProfile!.profilePicturePath);
    }
    
    await _database.userProfileDao.removeProfilePicture();
  }

  @override
  Future<void> deleteProfile() async {
    // Get current profile to clean up image file
    final currentProfile = await getCurrentProfile();
    if (currentProfile != null) {
      if (currentProfile.profilePicturePath != null) {
        await deleteProfileImageFile(currentProfile.profilePicturePath);
      }
      await _database.userProfileDao.deleteProfile(currentProfile.id);
    }
  }

  @override
  Future<String?> getDisplayName() async {
    return await _database.userProfileDao.getDisplayName();
  }

  @override
  Future<String?> getInitials() async {
    return await _database.userProfileDao.getInitials();
  }

  @override
  Stream<domain.UserProfile?> watchCurrentProfile() {
    return _database.userProfileDao.watchCurrentProfile();
  }

  // Image file management methods

  @override
  Future<String> saveProfileImage(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source image file does not exist');
      }

      // Get app documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final profileImagesDir = Directory(path.join(appDocDir.path, 'profile_images'));
      
      // Create profile images directory if it doesn't exist
      if (!await profileImagesDir.exists()) {
        await profileImagesDir.create(recursive: true);
      }

      // Generate unique filename based on timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = path.extension(sourcePath);
      final newFileName = 'profile_$timestamp$fileExtension';
      final destinationPath = path.join(profileImagesDir.path, newFileName);

      // Copy the file to the app directory
      final destinationFile = await sourceFile.copy(destinationPath);

      return destinationFile.path;
    } catch (e) {
      throw Exception('Failed to save profile image: $e');
    }
  }

  @override
  Future<void> deleteProfileImageFile(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;

    try {
      final imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    } catch (e) {
      // Log the error but don't throw - image deletion failure shouldn't break the app
      // Consider using a proper logging solution in production
    }
  }

  // First-time setup helpers

  @override
  Future<domain.UserProfile> setupProfile({
    required String firstName,
    String? lastName,
    String? imagePath,
    String? location,
  }) async {
    // Validate required fields
    if (firstName.trim().isEmpty) {
      throw ArgumentError('First name cannot be empty');
    }

    // Handle profile image if provided
    String? profilePicturePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        profilePicturePath = await saveProfileImage(imagePath);
      } catch (e) {
        // Continue without profile picture if image saving fails
        // Consider using a proper logging solution in production
      }
    }

    // Create the profile
    final profile = domain.UserProfile.create(
      firstName: firstName.trim(),
      lastName: lastName?.trim(),
      profilePicturePath: profilePicturePath,
      location: location?.trim(),
    );

    await createProfile(profile);
    return profile;
  }

  @override
  Future<bool> needsSetup() async {
    return !(await profileExists());
  }

  // Utility methods for maintenance

  /// Cleans up orphaned profile image files
  Future<void> cleanupOrphanedImages() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final profileImagesDir = Directory(path.join(appDocDir.path, 'profile_images'));
      
      if (!await profileImagesDir.exists()) return;

      // Get current profile image path
      final currentProfile = await getCurrentProfile();
      final currentImagePath = currentProfile?.profilePicturePath;

      // List all files in profile images directory
      final imageFiles = await profileImagesDir.list().toList();
      
      for (final file in imageFiles) {
        if (file is File) {
          // Delete files that are not the current profile image
          if (currentImagePath == null || file.path != currentImagePath) {
            try {
              await file.delete();
            } catch (e) {
              // Failed to delete orphaned image - consider logging in production
            }
          }
        }
      }
    } catch (e) {
      // Failed to cleanup orphaned images - consider logging in production
    }
  }

  /// Gets the size of all profile image files
  Future<int> getProfileImagesSize() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final profileImagesDir = Directory(path.join(appDocDir.path, 'profile_images'));
      
      if (!await profileImagesDir.exists()) return 0;

      int totalSize = 0;
      final files = await profileImagesDir.list().toList();
      
      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          totalSize += stat.size;
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}