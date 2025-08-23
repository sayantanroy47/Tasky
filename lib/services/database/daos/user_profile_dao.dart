import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';
import '../../../domain/entities/user_profile.dart' as domain;

part 'user_profile_dao.g.dart';

/// Data Access Object for UserProfile operations
/// 
/// Provides CRUD operations for user profiles in the database.
/// Since this is a singleton pattern (one profile per app), most operations
/// focus on getting the single profile and updating it.
@DriftAccessor(tables: [UserProfiles])
class UserProfileDao extends DatabaseAccessor<AppDatabase> with _$UserProfileDaoMixin {
  UserProfileDao(super.db);

  /// Gets the current user profile (singleton pattern)
  /// Returns null if no profile exists yet
  Future<domain.UserProfile?> getCurrentProfile() async {
    final profileRow = await select(userProfiles).getSingleOrNull();
    if (profileRow == null) return null;
    
    return _profileRowToModel(profileRow);
  }

  /// Checks if a user profile exists
  Future<bool> profileExists() async {
    final count = await (selectOnly(userProfiles)..addColumns([userProfiles.id.count()]))
        .map((row) => row.read(userProfiles.id.count()) ?? 0)
        .getSingle();
    return count > 0;
  }

  /// Creates a new user profile
  /// This should only be called once during app setup
  Future<void> createProfile(domain.UserProfile profile) async {
    await into(userProfiles).insert(_profileModelToRow(profile));
  }

  /// Updates the existing user profile
  Future<void> updateProfile(domain.UserProfile profile) async {
    await (update(userProfiles)..where((p) => p.id.equals(profile.id)))
        .write(_profileModelToRow(profile));
  }

  /// Updates only specific fields of the profile
  Future<void> updateProfileFields({
    String? firstName,
    String? lastName,
    String? profilePicturePath,
    String? location,
  }) async {
    final companion = UserProfilesCompanion(
      firstName: firstName != null ? Value(firstName) : const Value.absent(),
      lastName: lastName != null ? Value(lastName) : const Value.absent(),
      profilePicturePath: profilePicturePath != null ? Value(profilePicturePath) : const Value.absent(),
      location: location != null ? Value(location) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    await update(userProfiles).write(companion);
  }

  /// Updates the profile picture path
  Future<void> updateProfilePicture(String? profilePicturePath) async {
    await update(userProfiles).write(UserProfilesCompanion(
      profilePicturePath: Value(profilePicturePath),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Removes the profile picture (sets to null)
  Future<void> removeProfilePicture() async {
    await update(userProfiles).write(const UserProfilesCompanion(
      profilePicturePath: Value(null),
      updatedAt: Value.absent(), // Will be set automatically
    ));
  }

  /// Deletes the user profile
  /// This should only be used in rare cases like app reset
  Future<void> deleteProfile(String id) async {
    await (delete(userProfiles)..where((p) => p.id.equals(id))).go();
  }

  /// Deletes all user profiles (for app reset scenarios)
  Future<void> deleteAllProfiles() async {
    await delete(userProfiles).go();
  }

  /// Watches the current user profile (returns a stream)
  /// This is useful for reactive UI updates
  Stream<domain.UserProfile?> watchCurrentProfile() {
    return select(userProfiles).watchSingleOrNull().map((profileRow) {
      if (profileRow == null) return null;
      return _profileRowToModel(profileRow);
    });
  }

  /// Gets the user's display name quickly without loading full profile
  Future<String?> getDisplayName() async {
    final row = await (selectOnly(userProfiles)
          ..addColumns([userProfiles.firstName, userProfiles.lastName]))
        .getSingleOrNull();

    if (row == null) return null;

    final firstName = row.read(userProfiles.firstName) ?? '';
    final lastName = row.read(userProfiles.lastName);

    if (lastName != null && lastName.isNotEmpty) {
      return '$firstName $lastName';
    }
    return firstName;
  }

  /// Gets the user's initials quickly without loading full profile
  Future<String?> getInitials() async {
    final row = await (selectOnly(userProfiles)
          ..addColumns([userProfiles.firstName, userProfiles.lastName]))
        .getSingleOrNull();

    if (row == null) return null;

    final firstName = row.read(userProfiles.firstName) ?? '';
    final lastName = row.read(userProfiles.lastName);

    String initials = '';
    if (firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }
    if (lastName != null && lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }

    return initials.isEmpty ? 'U' : initials;
  }

  /// Converts a user profile database row to a UserProfile model
  domain.UserProfile _profileRowToModel(UserProfile profileRow) {
    return domain.UserProfile(
      id: profileRow.id,
      firstName: profileRow.firstName,
      lastName: profileRow.lastName,
      profilePicturePath: profileRow.profilePicturePath,
      location: profileRow.location,
      createdAt: profileRow.createdAt,
      updatedAt: profileRow.updatedAt,
    );
  }

  /// Converts a UserProfile model to a database row
  UserProfilesCompanion _profileModelToRow(domain.UserProfile profile) {
    return UserProfilesCompanion.insert(
      id: profile.id,
      firstName: profile.firstName,
      lastName: Value(profile.lastName),
      profilePicturePath: Value(profile.profilePicturePath),
      location: Value(profile.location),
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }
}