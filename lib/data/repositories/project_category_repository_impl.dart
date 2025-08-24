import '../../domain/entities/project_category.dart';
import '../../domain/entities/category_with_usage_count.dart' as domain;
import '../../domain/repositories/project_category_repository.dart';
import '../../services/database/daos/project_category_dao.dart';

/// Implementation of ProjectCategoryRepository using local database
/// 
/// Provides concrete implementation of project category operations using
/// Drift/SQLite database through ProjectCategoryDao. Handles both system-defined
/// and user-defined categories with full CRUD operations and usage tracking.
class ProjectCategoryRepositoryImpl implements ProjectCategoryRepository {
  final ProjectCategoryDao _dao;

  const ProjectCategoryRepositoryImpl(this._dao);

  @override
  Future<List<ProjectCategory>> getAllCategories() async {
    try {
      return await _dao.getAllCategories();
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to get all categories');
    }
  }

  @override
  Future<List<ProjectCategory>> getActiveCategories() async {
    try {
      return await _dao.getActiveCategories();
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to get active categories');
    }
  }

  @override
  Future<List<ProjectCategory>> getSystemCategories() async {
    try {
      return await _dao.getSystemCategories();
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to get system categories');
    }
  }

  @override
  Future<List<ProjectCategory>> getUserCategories() async {
    try {
      return await _dao.getUserCategories();
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to get user categories');
    }
  }

  @override
  Future<List<ProjectCategory>> getRootCategories() async {
    try {
      return await _dao.getRootCategories();
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to get root categories');
    }
  }

  @override
  Future<List<ProjectCategory>> getChildCategories(String parentId) async {
    try {
      if (parentId.isEmpty) {
        throw ArgumentError('Parent ID cannot be empty');
      }
      return await _dao.getChildCategories(parentId);
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to get child categories for parent: $parentId');
    }
  }

  @override
  Future<ProjectCategory?> getCategoryById(String id) async {
    try {
      if (id.isEmpty) {
        throw ArgumentError('Category ID cannot be empty');
      }
      return await _dao.getCategoryById(id);
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to get category by ID: $id');
    }
  }

  @override
  Future<ProjectCategory?> getCategoryByName(String name) async {
    try {
      if (name.trim().isEmpty) {
        throw ArgumentError('Category name cannot be empty');
      }
      return await _dao.getCategoryByName(name);
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to get category by name: $name');
    }
  }

  @override
  Future<void> createCategory(ProjectCategory category) async {
    try {
      // Validate category before creation
      if (!category.isValid()) {
        throw ArgumentError('Invalid category data: $category');
      }

      // Check for name uniqueness
      final isUnique = await _dao.isCategoryNameUnique(category.name);
      if (!isUnique) {
        throw ArgumentError('Category name "${category.name}" already exists');
      }

      // Validate parent exists if specified
      if (category.hasParent) {
        final parent = await _dao.getCategoryById(category.parentId!);
        if (parent == null) {
          throw ArgumentError('Parent category with ID "${category.parentId}" does not exist');
        }
        if (!parent.isActive) {
          throw ArgumentError('Parent category "${parent.name}" is not active');
        }
      }

      await _dao.createCategory(category);
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to create category: ${category.name}');
    }
  }

  @override
  Future<void> updateCategory(ProjectCategory category) async {
    try {
      // Validate category before update
      if (!category.isValid()) {
        throw ArgumentError('Invalid category data: $category');
      }

      // Check if category exists
      final existing = await _dao.getCategoryById(category.id);
      if (existing == null) {
        throw ArgumentError('Category with ID "${category.id}" does not exist');
      }

      // Prevent modification of system categories (except activation status)
      if (existing.isSystemDefined && category.name != existing.name) {
        throw ArgumentError('System category "${existing.name}" cannot be modified');
      }

      // Check for name uniqueness (excluding current category)
      final isUnique = await _dao.isCategoryNameUnique(category.name, excludeId: category.id);
      if (!isUnique) {
        throw ArgumentError('Category name "${category.name}" already exists');
      }

      // Validate parent exists if specified
      if (category.hasParent) {
        final parent = await _dao.getCategoryById(category.parentId!);
        if (parent == null) {
          throw ArgumentError('Parent category with ID "${category.parentId}" does not exist');
        }
        if (!parent.isActive) {
          throw ArgumentError('Parent category "${parent.name}" is not active');
        }
        // Prevent circular reference
        if (parent.parentId == category.id) {
          throw ArgumentError('Circular reference detected: parent cannot be a child of this category');
        }
      }

      await _dao.updateCategory(category);
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to update category: ${category.name}');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      if (id.isEmpty) {
        throw ArgumentError('Category ID cannot be empty');
      }

      final category = await _dao.getCategoryById(id);
      if (category == null) {
        throw ArgumentError('Category with ID "$id" does not exist');
      }

      // Prevent deletion of system categories
      if (category.isSystemDefined) {
        throw ArgumentError('System category "${category.name}" cannot be deleted');
      }

      // Check if category has child categories
      final children = await _dao.getChildCategories(id);
      if (children.isNotEmpty) {
        throw ArgumentError('Category "${category.name}" has child categories and cannot be deleted');
      }

      await _dao.deleteCategory(id);
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to delete category with ID: $id');
    }
  }

  @override
  Future<void> hardDeleteCategory(String id) async {
    try {
      if (id.isEmpty) {
        throw ArgumentError('Category ID cannot be empty');
      }

      final category = await _dao.getCategoryById(id);
      if (category == null) {
        throw ArgumentError('Category with ID "$id" does not exist');
      }

      // Prevent hard deletion of system categories
      if (category.isSystemDefined) {
        throw ArgumentError('System category "${category.name}" cannot be permanently deleted');
      }

      await _dao.hardDeleteCategory(id);
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to permanently delete category with ID: $id');
    }
  }

  @override
  Future<void> restoreCategory(String id) async {
    try {
      if (id.isEmpty) {
        throw ArgumentError('Category ID cannot be empty');
      }

      final category = await _dao.getCategoryById(id);
      if (category == null) {
        throw ArgumentError('Category with ID "$id" does not exist');
      }

      if (category.isActive) {
        throw ArgumentError('Category "${category.name}" is already active');
      }

      await _dao.restoreCategory(id);
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to restore category with ID: $id');
    }
  }

  @override
  Future<List<ProjectCategory>> searchCategories(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getActiveCategories();
      }
      return await _dao.searchCategories(query);
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to search categories with query: $query');
    }
  }

  @override
  Future<List<domain.CategoryWithUsageCount>> getCategoriesWithUsage() async {
    try {
      return await _dao.getCategoriesWithUsage();
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to get categories with usage counts');
    }
  }

  @override
  Future<void> updateCategorySortOrder(List<({String id, int sortOrder})> updates) async {
    try {
      if (updates.isEmpty) {
        throw ArgumentError('Updates list cannot be empty');
      }

      // Validate all category IDs exist
      for (final update in updates) {
        if (update.id.isEmpty) {
          throw ArgumentError('Category ID cannot be empty in sort order update');
        }
        if (update.sortOrder < 0) {
          throw ArgumentError('Sort order must be non-negative');
        }

        final category = await _dao.getCategoryById(update.id);
        if (category == null) {
          throw ArgumentError('Category with ID "${update.id}" does not exist');
        }
      }

      await _dao.updateCategorySortOrder(updates);
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to update category sort orders');
    }
  }

  @override
  Future<void> reorderCategory(String categoryId, int newPosition) async {
    try {
      if (categoryId.isEmpty) {
        throw ArgumentError('Category ID cannot be empty');
      }
      if (newPosition < 0) {
        throw ArgumentError('New position must be non-negative');
      }

      final category = await _dao.getCategoryById(categoryId);
      if (category == null) {
        throw ArgumentError('Category with ID "$categoryId" does not exist');
      }

      await _dao.reorderCategory(categoryId, newPosition);
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to reorder category: $categoryId to position $newPosition');
    }
  }

  @override
  Future<bool> isCategoryNameUnique(String name, {String? excludeId}) async {
    try {
      if (name.trim().isEmpty) {
        throw ArgumentError('Category name cannot be empty');
      }
      return await _dao.isCategoryNameUnique(name, excludeId: excludeId);
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to check category name uniqueness: $name');
    }
  }

  @override
  Future<List<ProjectCategory>> getAllCategoriesIncludingInactive() async {
    try {
      return await _dao.getAllCategoriesIncludingInactive();
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to get all categories including inactive');
    }
  }

  @override
  Stream<List<ProjectCategory>> watchActiveCategories() {
    try {
      return _dao.watchActiveCategories();
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to watch active categories');
    }
  }

  @override
  Stream<List<domain.CategoryWithUsageCount>> watchCategoriesWithUsage() {
    try {
      return _dao.watchCategoriesWithUsage();
    } catch (e) {
      throw _handleDatabaseError(e, 'Failed to watch categories with usage counts');
    }
  }

  /// Handles database errors and converts them to meaningful exceptions
  Exception _handleDatabaseError(dynamic error, String context) {
    if (error is ArgumentError) {
      return Exception(error.message); // Convert to Exception
    }
    
    // Log the original error for debugging
    // TODO: Replace with proper logging service
    // ignore: avoid_print
    print('Database error in ProjectCategoryRepository: $error');
    
    // Return a user-friendly error message
    return Exception('$context. Please try again later.');
  }
}