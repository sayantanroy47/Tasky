import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'project.g.dart';

/// Represents a project that can contain multiple tasks
/// 
/// Projects are used to organize related tasks together and track
/// overall progress across multiple tasks.
@JsonSerializable()
class Project extends Equatable {
  /// Unique identifier for the project
  final String id;
  
  /// Name of the project
  final String name;
  
  /// Optional description of the project
  final String? description;
  
  /// Color associated with the project (hex color code)
  final String color;

  /// Category ID reference to ProjectCategory (replaces legacy category string)
  final String? categoryId;

  /// Legacy category string (for backward compatibility during migration)
  /// @deprecated Use categoryId instead. Will be removed in future version.
  final String? category;
  
  /// When this project was created
  final DateTime createdAt;
  
  /// When this project was last updated
  final DateTime? updatedAt;
  
  /// List of task IDs that belong to this project
  final List<String> taskIds;
  
  /// List of tag IDs associated with this project
  final List<String> tagIds;
  
  /// Whether this project is archived
  final bool isArchived;
  
  /// Optional deadline for the project
  final DateTime? deadline;

  const Project({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    this.categoryId,
    this.category,
    required this.createdAt,
    this.updatedAt,
    this.taskIds = const [],
    this.tagIds = const [],
    this.isArchived = false,
    this.deadline,
  });

  /// Creates a new project with generated ID and current timestamp
  factory Project.create({
    required String name,
    String? description,
    String color = '#2196F3', // Default blue color
    String? categoryId,
    String? category, // @deprecated - for backward compatibility
    List<String> tagIds = const [],
    DateTime? deadline,
  }) {
    return Project(
      id: const Uuid().v4(),
      name: name,
      description: description,
      color: color,
      categoryId: categoryId,
      category: category,
      tagIds: tagIds,
      createdAt: DateTime.now(),
      deadline: deadline,
    );
  }

  /// Creates a Project from JSON
  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

  /// Converts this Project to JSON
  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  /// Creates a copy of this project with updated fields
  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? categoryId,
    String? category, // @deprecated - for backward compatibility
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? taskIds,
    List<String>? tagIds,
    bool? isArchived,
    DateTime? deadline,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      taskIds: taskIds ?? this.taskIds,
      tagIds: tagIds ?? this.tagIds,
      isArchived: isArchived ?? this.isArchived,
      deadline: deadline ?? this.deadline,
    );
  }

  /// Adds a task ID to this project
  Project addTask(String taskId) {
    if (taskIds.contains(taskId)) return this;
    
    return copyWith(
      taskIds: [...taskIds, taskId],
      updatedAt: DateTime.now(),
    );
  }

  /// Removes a task ID from this project
  Project removeTask(String taskId) {
    if (!taskIds.contains(taskId)) return this;
    
    final newTaskIds = List<String>.from(taskIds)..remove(taskId);
    return copyWith(
      taskIds: newTaskIds,
      updatedAt: DateTime.now(),
    );
  }

  /// Adds a tag ID to this project
  Project addTag(String tagId) {
    if (tagIds.contains(tagId)) return this;
    
    return copyWith(
      tagIds: [...tagIds, tagId],
      updatedAt: DateTime.now(),
    );
  }

  /// Removes a tag ID from this project
  Project removeTag(String tagId) {
    if (!tagIds.contains(tagId)) return this;
    
    final newTagIds = List<String>.from(tagIds)..remove(tagId);
    return copyWith(
      tagIds: newTagIds,
      updatedAt: DateTime.now(),
    );
  }

  /// Archives this project
  Project archive() {
    return copyWith(
      isArchived: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Unarchives this project
  Project unarchive() {
    return copyWith(
      isArchived: false,
      updatedAt: DateTime.now(),
    );
  }

  /// Updates the project with new information
  Project update({
    String? name,
    String? description,
    String? color,
    String? categoryId,
    String? category, // @deprecated - for backward compatibility
    List<String>? tagIds,
    DateTime? deadline,
  }) {
    return copyWith(
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      tagIds: tagIds ?? this.tagIds,
      deadline: deadline ?? this.deadline,
      updatedAt: DateTime.now(),
    );
  }

  /// Validates the project data
  bool isValid() {
    if (id.isEmpty || name.trim().isEmpty) {
      return false;
    }
    
    // Validate color format (should be hex color)
    if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(color)) {
      return false;
    }
    
    // Validate deadline is in the future if set
    if (deadline != null && deadline!.isBefore(DateTime.now())) {
      return false;
    }
    
    return true;
  }

  /// Returns true if the project has a deadline
  bool get hasDeadline => deadline != null;
  
  /// Returns true if the project deadline is overdue
  bool get isOverdue => deadline != null && deadline!.isBefore(DateTime.now());
  
  /// Returns the number of tasks in this project
  int get taskCount => taskIds.length;
  
  /// Returns the number of tags in this project
  int get tagCount => tagIds.length;
  
  /// Returns true if the project is empty (no tasks)
  bool get isEmpty => taskIds.isEmpty;
  
  /// Returns true if the project has tags
  bool get hasTags => tagIds.isNotEmpty;
  
  /// Returns true if the project is active (not archived)
  bool get isActive => !isArchived;

  // ============================================================================
  // MIGRATION HELPERS - Support both legacy and new category systems
  // ============================================================================

  /// Returns true if this project has a category assigned
  bool get hasCategory => categoryId != null || (category != null && category!.isNotEmpty);

  /// Returns true if this project uses the new category system
  bool get usesNewCategorySystem => categoryId != null;

  /// Returns true if this project uses the legacy category system
  bool get usesLegacyCategorySystem => category != null && category!.isNotEmpty && categoryId == null;

  /// Gets the effective category for display (prioritizes new system)
  String? get effectiveCategory {
    if (usesNewCategorySystem) return categoryId;
    if (usesLegacyCategorySystem) return category;
    return null;
  }

  /// Migrates from legacy category to new category system
  Project migrateToNewCategorySystem(String newCategoryId) {
    return copyWith(
      categoryId: newCategoryId,
      category: null, // Clear legacy category
      updatedAt: DateTime.now(),
    );
  }

  /// Migrates from new category system back to legacy (for rollback)
  Project migrateToLegacyCategorySystem(String legacyCategoryName) {
    return copyWith(
      categoryId: null, // Clear new category
      category: legacyCategoryName,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        color,
        categoryId,
        category,
        createdAt,
        updatedAt,
        taskIds,
        tagIds,
        isArchived,
        deadline,
      ];

  @override
  String toString() {
    return 'Project(id: $id, name: $name, taskCount: ${taskIds.length}, '
           'tagCount: ${tagIds.length}, categoryId: $categoryId, category: $category, '
           'isArchived: $isArchived, deadline: $deadline)';
  }
}