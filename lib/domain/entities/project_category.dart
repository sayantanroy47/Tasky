import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'project_category.g.dart';

/// Represents a project category that can be system-defined or user-defined
/// 
/// Project categories provide visual organization and grouping for projects
/// with customizable icons from the Phosphor icon library and colors from
/// the design system.
@JsonSerializable()
class ProjectCategory extends Equatable {
  /// Unique identifier for the category
  final String id;
  
  /// Display name of the category
  final String name;
  
  /// Phosphor icon name as string (e.g., 'briefcase', 'user', 'heart')
  final String iconName;
  
  /// Hex color code from design system (e.g., '#1976D2')
  final String color;
  
  /// Optional parent category ID for hierarchical organization
  final String? parentId;
  
  /// Whether this is a system-defined category (immutable)
  final bool isSystemDefined;
  
  /// Whether this category is currently active (soft delete)
  final bool isActive;
  
  /// Sort order for display (lower numbers appear first)
  final int sortOrder;
  
  /// When this category was created
  final DateTime createdAt;
  
  /// When this category was last updated (null for system categories)
  final DateTime? updatedAt;
  
  /// Extensible metadata for future features (JSON serializable map)
  final Map<String, dynamic> metadata;

  const ProjectCategory({
    required this.id,
    required this.name,
    required this.iconName,
    required this.color,
    this.parentId,
    required this.isSystemDefined,
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
    this.updatedAt,
    this.metadata = const <String, dynamic>{},
  });

  /// Creates a new user-defined category with generated ID and current timestamp
  factory ProjectCategory.createUser({
    required String name,
    required String iconName,
    required String color,
    String? parentId,
    int sortOrder = 0,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    final now = DateTime.now();
    return ProjectCategory(
      id: const Uuid().v4(),
      name: name,
      iconName: iconName,
      color: color,
      parentId: parentId,
      isSystemDefined: false,
      isActive: true,
      sortOrder: sortOrder,
      createdAt: now,
      updatedAt: now,
      metadata: metadata,
    );
  }

  /// Creates a system-defined category (used for seeding)
  factory ProjectCategory.createSystem({
    required String id,
    required String name,
    required String iconName,
    required String color,
    String? parentId,
    int sortOrder = 0,
    Map<String, dynamic> metadata = const <String, dynamic>{},
  }) {
    return ProjectCategory(
      id: id,
      name: name,
      iconName: iconName,
      color: color,
      parentId: parentId,
      isSystemDefined: true,
      isActive: true,
      sortOrder: sortOrder,
      createdAt: DateTime.now(),
      updatedAt: null, // System categories don't have update timestamps
      metadata: metadata,
    );
  }

  /// Creates a ProjectCategory from JSON
  factory ProjectCategory.fromJson(Map<String, dynamic> json) => 
      _$ProjectCategoryFromJson(json);

  /// Converts this ProjectCategory to JSON
  Map<String, dynamic> toJson() => _$ProjectCategoryToJson(this);

  /// Creates a copy of this category with updated fields
  /// 
  /// Note: System categories cannot be modified except for activation status
  ProjectCategory copyWith({
    String? id,
    String? name,
    String? iconName,
    String? color,
    String? parentId,
    bool? isSystemDefined,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    // Prevent modification of system categories (except activation)
    if (this.isSystemDefined) {
      return ProjectCategory(
        id: this.id,
        name: this.name,
        iconName: this.iconName,
        color: this.color,
        parentId: this.parentId,
        isSystemDefined: this.isSystemDefined,
        isActive: isActive ?? this.isActive, // Only allow activation changes
        sortOrder: this.sortOrder,
        createdAt: this.createdAt,
        updatedAt: this.updatedAt,
        metadata: this.metadata,
      );
    }

    return ProjectCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      isSystemDefined: isSystemDefined ?? this.isSystemDefined,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      metadata: metadata ?? this.metadata,
    );
  }

  /// Updates this category with new information
  /// 
  /// System categories cannot be updated except for activation status
  ProjectCategory update({
    String? name,
    String? iconName,
    String? color,
    String? parentId,
    int? sortOrder,
    Map<String, dynamic>? metadata,
  }) {
    return copyWith(
      name: name,
      iconName: iconName,
      color: color,
      parentId: parentId,
      sortOrder: sortOrder,
      metadata: metadata,
      updatedAt: DateTime.now(),
    );
  }

  /// Activates this category (makes it visible)
  ProjectCategory activate() {
    return copyWith(
      isActive: true,
      updatedAt: isSystemDefined ? null : DateTime.now(),
    );
  }

  /// Deactivates this category (soft delete)
  ProjectCategory deactivate() {
    return copyWith(
      isActive: false,
      updatedAt: isSystemDefined ? null : DateTime.now(),
    );
  }

  /// Validates the category data
  bool isValid() {
    // ID and name are required
    if (id.isEmpty || name.trim().isEmpty) {
      return false;
    }
    
    // Icon name must be valid (non-empty)
    if (iconName.trim().isEmpty) {
      return false;
    }
    
    // Color must be valid hex format
    if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(color)) {
      return false;
    }
    
    // Parent ID cannot be self-referencing
    if (parentId == id) {
      return false;
    }
    
    // Sort order should be non-negative
    if (sortOrder < 0) {
      return false;
    }
    
    return true;
  }

  /// Returns true if this category has a parent category
  bool get hasParent => parentId != null && parentId!.isNotEmpty;
  
  /// Returns true if this category can be modified by users
  bool get isUserDefined => !isSystemDefined;
  
  /// Returns true if this category is visible to users
  bool get isVisible => isActive;
  
  /// Returns the display name with proper capitalization
  String get displayName => name.isEmpty 
      ? 'Unnamed Category' 
      : name[0].toUpperCase() + name.substring(1);

  /// Returns true if this category has custom metadata
  bool get hasMetadata => metadata.isNotEmpty;

  /// Gets a metadata value by key with optional default
  T? getMetadata<T>(String key, [T? defaultValue]) {
    final value = metadata[key];
    if (value is T) return value;
    return defaultValue;
  }

  /// Sets a metadata value (returns new instance for user categories only)
  ProjectCategory setMetadata(String key, dynamic value) {
    if (isSystemDefined) return this;
    
    final newMetadata = Map<String, dynamic>.from(metadata);
    newMetadata[key] = value;
    return copyWith(metadata: newMetadata);
  }

  /// Removes a metadata value (returns new instance for user categories only)
  ProjectCategory removeMetadata(String key) {
    if (isSystemDefined) return this;
    
    final newMetadata = Map<String, dynamic>.from(metadata);
    newMetadata.remove(key);
    return copyWith(metadata: newMetadata);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        iconName,
        color,
        parentId,
        isSystemDefined,
        isActive,
        sortOrder,
        createdAt,
        updatedAt,
        metadata,
      ];

  @override
  String toString() {
    return 'ProjectCategory(id: $id, name: $name, iconName: $iconName, '
           'isSystemDefined: $isSystemDefined, isActive: $isActive, '
           'sortOrder: $sortOrder, hasParent: $hasParent)';
  }
}

