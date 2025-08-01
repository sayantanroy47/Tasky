/// Simple Tag model for repository operations
class Tag {
  final String id;
  final String name;
  final String? color;
  final DateTime createdAt;

  const Tag({
    required this.id,
    required this.name,
    this.color,
    required this.createdAt,
  });

  Tag copyWith({
    String? id,
    String? name,
    String? color,
    DateTime? createdAt,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tag &&
        other.id == id &&
        other.name == name &&
        other.color == color &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ color.hashCode ^ createdAt.hashCode;
  }

  @override
  String toString() {
    return 'Tag(id: $id, name: $name, color: $color, createdAt: $createdAt)';
  }
}

/// Abstract repository interface for tag operations
/// 
/// This interface defines all the operations that can be performed on tags.
/// It follows the repository pattern to abstract data access logic from
/// business logic.
abstract class TagRepository {
  /// Gets all tags from the repository
  Future<List<Tag>> getAllTags();

  /// Gets a tag by its unique identifier
  Future<Tag?> getTagById(String id);

  /// Gets a tag by its name
  Future<Tag?> getTagByName(String name);

  /// Creates a new tag in the repository
  Future<void> createTag(Tag tag);

  /// Updates an existing tag in the repository
  Future<void> updateTag(Tag tag);

  /// Deletes a tag from the repository
  Future<void> deleteTag(String id);

  /// Gets tags used by a specific task
  Future<List<Tag>> getTagsForTask(String taskId);

  /// Gets tags with their usage counts
  Future<List<TagWithUsage>> getTagsWithUsage();

  /// Gets the most frequently used tags
  Future<List<TagWithUsage>> getMostUsedTags({int limit = 10});

  /// Gets unused tags (tags not associated with any tasks)
  Future<List<Tag>> getUnusedTags();

  /// Searches tags by name
  Future<List<Tag>> searchTags(String query);

  /// Gets tags with advanced filtering options
  Future<List<Tag>> getTagsWithFilter(TagFilter filter);

  /// Adds a tag to a task
  Future<void> addTagToTask(String taskId, String tagId);

  /// Removes a tag from a task
  Future<void> removeTagFromTask(String taskId, String tagId);

  /// Watches all tags (returns a stream for real-time updates)
  Stream<List<Tag>> watchAllTags();

  /// Watches tags for a specific task (returns a stream)
  Stream<List<Tag>> watchTagsForTask(String taskId);

  /// Watches a specific tag (returns a stream)
  Stream<Tag?> watchTagById(String id);
}

/// Tag with usage statistics
class TagWithUsage {
  final Tag tag;
  final int usageCount;

  const TagWithUsage({
    required this.tag,
    required this.usageCount,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TagWithUsage &&
        other.tag == tag &&
        other.usageCount == usageCount;
  }

  @override
  int get hashCode => tag.hashCode ^ usageCount.hashCode;

  @override
  String toString() {
    return 'TagWithUsage(tag: $tag, usageCount: $usageCount)';
  }
}

/// Filter options for advanced tag querying
class TagFilter {
  final int? minUsageCount;
  final int? maxUsageCount;
  final bool? hasColor;
  final String? searchQuery;
  final TagSortBy sortBy;
  final bool sortAscending;

  const TagFilter({
    this.minUsageCount,
    this.maxUsageCount,
    this.hasColor,
    this.searchQuery,
    this.sortBy = TagSortBy.name,
    this.sortAscending = true,
  });

  /// Creates a copy of this filter with updated fields
  TagFilter copyWith({
    int? minUsageCount,
    int? maxUsageCount,
    bool? hasColor,
    String? searchQuery,
    TagSortBy? sortBy,
    bool? sortAscending,
  }) {
    return TagFilter(
      minUsageCount: minUsageCount ?? this.minUsageCount,
      maxUsageCount: maxUsageCount ?? this.maxUsageCount,
      hasColor: hasColor ?? this.hasColor,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  /// Returns true if any filter is applied
  bool get hasFilters {
    return minUsageCount != null ||
        maxUsageCount != null ||
        hasColor != null ||
        (searchQuery != null && searchQuery!.isNotEmpty);
  }
}

/// Sorting options for tags
enum TagSortBy {
  name,
  createdAt,
  usageCount,
}

/// Extension to get display names for sort options
extension TagSortByExtension on TagSortBy {
  String get displayName {
    switch (this) {
      case TagSortBy.name:
        return 'Name';
      case TagSortBy.createdAt:
        return 'Created Date';
      case TagSortBy.usageCount:
        return 'Usage Count';
    }
  }
}
