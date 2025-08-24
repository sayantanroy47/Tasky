import '../entities/project_category.dart';
import '../entities/category_with_usage_count.dart';

/// Repository interface for ProjectCategory operations
/// 
/// Defines the contract for project category data access operations,
/// supporting both system-defined and user-defined categories with 
/// hierarchical organization and usage tracking.
abstract class ProjectCategoryRepository {
  /// Gets all project categories
  Future<List<ProjectCategory>> getAllCategories();

  /// Gets only active (non-deleted) project categories
  Future<List<ProjectCategory>> getActiveCategories();

  /// Gets system-defined categories only
  Future<List<ProjectCategory>> getSystemCategories();

  /// Gets user-defined categories only  
  Future<List<ProjectCategory>> getUserCategories();

  /// Gets root categories (no parent) only
  Future<List<ProjectCategory>> getRootCategories();

  /// Gets child categories for a parent category
  Future<List<ProjectCategory>> getChildCategories(String parentId);

  /// Gets a category by its ID
  Future<ProjectCategory?> getCategoryById(String id);

  /// Gets a category by its name (case-insensitive)
  Future<ProjectCategory?> getCategoryByName(String name);

  /// Creates a new category
  Future<void> createCategory(ProjectCategory category);

  /// Updates an existing category
  Future<void> updateCategory(ProjectCategory category);

  /// Soft deletes a category (marks as inactive)
  Future<void> deleteCategory(String id);

  /// Hard deletes a category permanently (use with caution!)
  Future<void> hardDeleteCategory(String id);

  /// Restores a soft-deleted category
  Future<void> restoreCategory(String id);

  /// Searches categories by name or metadata
  Future<List<ProjectCategory>> searchCategories(String query);

  /// Gets categories with usage count (how many projects use each category)
  Future<List<CategoryWithUsageCount>> getCategoriesWithUsage();

  /// Updates the sort order of multiple categories atomically
  Future<void> updateCategorySortOrder(List<({String id, int sortOrder})> updates);

  /// Reorders categories by inserting a category at a specific position
  Future<void> reorderCategory(String categoryId, int newPosition);

  /// Checks if a category name is unique among active categories
  Future<bool> isCategoryNameUnique(String name, {String? excludeId});

  /// Gets all categories including inactive ones (for admin purposes)
  Future<List<ProjectCategory>> getAllCategoriesIncludingInactive();

  /// Watches all active categories (returns a stream)
  Stream<List<ProjectCategory>> watchActiveCategories();

  /// Watches categories with usage counts (returns a stream)
  Stream<List<CategoryWithUsageCount>> watchCategoriesWithUsage();
}