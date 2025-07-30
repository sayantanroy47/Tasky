import '../entities/task_template.dart';

/// Abstract repository interface for task template operations
/// 
/// This interface defines all the operations that can be performed on task templates.
/// It follows the repository pattern to abstract data access logic from
/// business logic.
abstract class TaskTemplateRepository {
  /// Gets all task templates from the repository
  Future<List<TaskTemplate>> getAllTemplates();

  /// Gets a task template by its unique identifier
  Future<TaskTemplate?> getTemplateById(String id);

  /// Creates a new task template in the repository
  Future<void> createTemplate(TaskTemplate template);

  /// Updates an existing task template in the repository
  Future<void> updateTemplate(TaskTemplate template);

  /// Deletes a task template from the repository
  Future<void> deleteTemplate(String id);

  /// Gets templates filtered by category
  Future<List<TaskTemplate>> getTemplatesByCategory(String category);

  /// Gets favorite templates
  Future<List<TaskTemplate>> getFavoriteTemplates();

  /// Gets most used templates (sorted by usage count)
  Future<List<TaskTemplate>> getMostUsedTemplates({int limit = 10});

  /// Searches templates by name or description
  Future<List<TaskTemplate>> searchTemplates(String query);

  /// Gets templates with advanced filtering options
  Future<List<TaskTemplate>> getTemplatesWithFilter(TemplateFilter filter);

  /// Watches all templates (returns a stream for real-time updates)
  Stream<List<TaskTemplate>> watchAllTemplates();

  /// Watches favorite templates (returns a stream)
  Stream<List<TaskTemplate>> watchFavoriteTemplates();

  /// Watches templates for a specific category (returns a stream)
  Stream<List<TaskTemplate>> watchTemplatesByCategory(String category);

  /// Gets all unique categories
  Future<List<String>> getAllCategories();
}

/// Filter options for advanced template querying
class TemplateFilter {
  final String? category;
  final bool? isFavorite;
  final String? searchQuery;
  final TemplateSortBy sortBy;
  final bool sortAscending;
  final int? minUsageCount;
  final int? maxUsageCount;

  const TemplateFilter({
    this.category,
    this.isFavorite,
    this.searchQuery,
    this.sortBy = TemplateSortBy.createdAt,
    this.sortAscending = false,
    this.minUsageCount,
    this.maxUsageCount,
  });

  /// Creates a copy of this filter with updated fields
  TemplateFilter copyWith({
    String? category,
    bool? isFavorite,
    String? searchQuery,
    TemplateSortBy? sortBy,
    bool? sortAscending,
    int? minUsageCount,
    int? maxUsageCount,
  }) {
    return TemplateFilter(
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      minUsageCount: minUsageCount ?? this.minUsageCount,
      maxUsageCount: maxUsageCount ?? this.maxUsageCount,
    );
  }

  /// Returns true if any filter is applied
  bool get hasFilters {
    return category != null ||
        isFavorite != null ||
        (searchQuery != null && searchQuery!.isNotEmpty) ||
        minUsageCount != null ||
        maxUsageCount != null;
  }
}

/// Sorting options for templates
enum TemplateSortBy {
  createdAt,
  updatedAt,
  name,
  usageCount,
  category,
}

/// Extension to get display names for sort options
extension TemplateSortByExtension on TemplateSortBy {
  String get displayName {
    switch (this) {
      case TemplateSortBy.createdAt:
        return 'Created Date';
      case TemplateSortBy.updatedAt:
        return 'Updated Date';
      case TemplateSortBy.name:
        return 'Name';
      case TemplateSortBy.usageCount:
        return 'Usage Count';
      case TemplateSortBy.category:
        return 'Category';
    }
  }
}