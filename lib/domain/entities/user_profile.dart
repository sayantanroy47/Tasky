import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'user_profile.g.dart';

/// Represents a user profile with personal information and preferences
/// 
/// Stores user's name, profile picture path, location, and other profile data.
/// This follows a singleton pattern as there is only one user per app installation.
@JsonSerializable()
class UserProfile extends Equatable {
  /// Unique identifier for the user profile
  final String id;
  
  /// User's first name (required)
  final String firstName;
  
  /// User's last name (optional)
  final String? lastName;
  
  /// Local file path to the user's profile picture (optional)
  final String? profilePicturePath;
  
  /// User's location as entered by them (optional)
  final String? location;
  
  /// When this profile was created
  final DateTime createdAt;
  
  /// When this profile was last updated
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.firstName,
    this.lastName,
    this.profilePicturePath,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a new user profile with generated ID and current timestamp
  factory UserProfile.create({
    required String firstName,
    String? lastName,
    String? profilePicturePath,
    String? location,
  }) {
    final now = DateTime.now();
    return UserProfile(
      id: const Uuid().v4(),
      firstName: firstName,
      lastName: lastName,
      profilePicturePath: profilePicturePath,
      location: location,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a UserProfile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

  /// Converts this UserProfile to JSON
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  /// Creates a copy of this user profile with updated fields
  UserProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? profilePicturePath,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? (updatedAt == null ? DateTime.now() : this.updatedAt),
    );
  }

  /// Updates the profile with new information and sets updatedAt to now
  UserProfile update({
    String? firstName,
    String? lastName,
    String? profilePicturePath,
    String? location,
  }) {
    return copyWith(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      location: location ?? this.location,
      updatedAt: DateTime.now(),
    );
  }

  /// Updates the profile picture path and sets updatedAt to now
  UserProfile updateProfilePicture(String? profilePicturePath) {
    return copyWith(
      profilePicturePath: profilePicturePath,
      updatedAt: DateTime.now(),
    );
  }

  /// Removes the profile picture and sets updatedAt to now
  UserProfile removeProfilePicture() {
    return copyWith(
      profilePicturePath: null,
      updatedAt: DateTime.now(),
    );
  }

  /// Gets the user's full name
  String get fullName {
    if (lastName != null && lastName!.isNotEmpty) {
      return '$firstName $lastName';
    }
    return firstName;
  }

  /// Gets the user's display name (same as full name for now)
  String get displayName => fullName;

  /// Gets the user's initials for avatar generation
  String get initials {
    String result = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    if (lastName != null && lastName!.isNotEmpty) {
      result += lastName![0].toUpperCase();
    }
    return result.isEmpty ? 'U' : result;
  }

  /// Checks if the user has a custom profile picture
  bool get hasProfilePicture => 
      profilePicturePath != null && profilePicturePath!.isNotEmpty;

  /// Checks if the profile is complete (has all basic information)
  bool get isComplete => firstName.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    profilePicturePath,
    location,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() => 'UserProfile(id: $id, name: $fullName, hasProfilePicture: $hasProfilePicture)';
}