import 'package:drift/drift.dart';
import 'dart:convert';

import '../database.dart';
import '../tables.dart';
import '../../../domain/entities/project_category.dart' as domain;
import '../../../domain/entities/category_with_usage_count.dart';

part 'project_category_dao.g.dart';

/// Data Access Object for ProjectCategory operations
/// 
/// Provides CRUD operations and queries for project categories in the database,
/// supporting both system-defined and user-defined categories.
@DriftAccessor(tables: [ProjectCategories, Projects])
class ProjectCategoryDao extends DatabaseAccessor<AppDatabase> with _$ProjectCategoryDaoMixin {
  ProjectCategoryDao(super.db);

  /// Gets all project categories from the database
  Future<List<domain.ProjectCategory>> getAllCategories() async {
    final categoryRows = await select(projectCategories).get();
    return categoryRows.map(_categoryRowToModel).toList();
  }

  /// Gets only active (non-deleted) project categories
  Future<List<domain.ProjectCategory>> getActiveCategories() async {
    final categoryRows = await (select(projectCategories)
      ..where((c) => c.isActive.equals(true))
      ..orderBy([(c) => OrderingTerm(expression: c.sortOrder, mode: OrderingMode.asc)])
    ).get();
    
    return categoryRows.map(_categoryRowToModel).toList();
  }

  /// Gets system-defined categories only
  Future<List<domain.ProjectCategory>> getSystemCategories() async {
    final categoryRows = await (select(projectCategories)
      ..where((c) => c.isSystemDefined.equals(true) & c.isActive.equals(true))
      ..orderBy([(c) => OrderingTerm(expression: c.sortOrder, mode: OrderingMode.asc)])
    ).get();
    
    return categoryRows.map(_categoryRowToModel).toList();
  }

  /// Gets user-defined categories only
  Future<List<domain.ProjectCategory>> getUserCategories() async {
    final categoryRows = await (select(projectCategories)
      ..where((c) => c.isSystemDefined.equals(false) & c.isActive.equals(true))
      ..orderBy([(c) => OrderingTerm(expression: c.sortOrder, mode: OrderingMode.asc)])
    ).get();
    
    return categoryRows.map(_categoryRowToModel).toList();
  }

  /// Gets root categories (no parent) only
  Future<List<domain.ProjectCategory>> getRootCategories() async {
    final categoryRows = await (select(projectCategories)
      ..where((c) => c.parentId.isNull() & c.isActive.equals(true))
      ..orderBy([(c) => OrderingTerm(expression: c.sortOrder, mode: OrderingMode.asc)])
    ).get();
    
    return categoryRows.map(_categoryRowToModel).toList();
  }

  /// Gets child categories for a parent category
  Future<List<domain.ProjectCategory>> getChildCategories(String parentId) async {
    final categoryRows = await (select(projectCategories)
      ..where((c) => c.parentId.equals(parentId) & c.isActive.equals(true))
      ..orderBy([(c) => OrderingTerm(expression: c.sortOrder, mode: OrderingMode.asc)])
    ).get();
    
    return categoryRows.map(_categoryRowToModel).toList();
  }

  /// Gets a category by its ID
  Future<domain.ProjectCategory?> getCategoryById(String id) async {
    final categoryRow = await (select(projectCategories)
      ..where((c) => c.id.equals(id))
    ).getSingleOrNull();
    
    if (categoryRow == null) return null;
    return _categoryRowToModel(categoryRow);
  }

  /// Gets a category by its name (case-insensitive)
  Future<domain.ProjectCategory?> getCategoryByName(String name) async {
    final categoryRow = await (select(projectCategories)
      ..where((c) => c.name.upper().equals(name.toUpperCase()) & c.isActive.equals(true))
    ).getSingleOrNull();
    
    if (categoryRow == null) return null;
    return _categoryRowToModel(categoryRow);
  }

  /// Creates a new category in the database
  Future<void> createCategory(domain.ProjectCategory category) async {
    await into(projectCategories).insert(_categoryModelToRow(category));
  }

  /// Updates an existing category in the database
  Future<void> updateCategory(domain.ProjectCategory category) async {
    await (update(projectCategories)..where((c) => c.id.equals(category.id)))
        .write(_categoryModelToRow(category));
  }

  /// Soft deletes a category (marks as inactive)
  /// Note: This will set category_id to NULL for all projects using this category
  Future<void> deleteCategory(String id) async {
    await db.transaction(() async {
      // First, update all projects to remove the category reference
      await (update(projects)..where((p) => p.categoryId.equals(id)))
          .write(const ProjectsCompanion(categoryId: Value(null)));
      
      // Then soft delete the category
      await (update(projectCategories)..where((c) => c.id.equals(id)))
          .write(ProjectCategoriesCompanion(
            isActive: const Value(false),
            updatedAt: Value(DateTime.now()),
          ));
    });
  }

  /// Hard deletes a category permanently (use with caution!)
  /// Note: This will cascade delete to all projects using this category
  Future<void> hardDeleteCategory(String id) async {
    await db.transaction(() async {
      // First, update all projects to remove the category reference
      await (update(projects)..where((p) => p.categoryId.equals(id)))
          .write(const ProjectsCompanion(categoryId: Value(null)));
      
      // Then permanently delete the category
      await (delete(projectCategories)..where((c) => c.id.equals(id))).go();
    });
  }

  /// Restores a soft-deleted category
  Future<void> restoreCategory(String id) async {
    await (update(projectCategories)..where((c) => c.id.equals(id)))
        .write(ProjectCategoriesCompanion(
          isActive: const Value(true),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Searches categories by name or metadata (case-insensitive)
  Future<List<domain.ProjectCategory>> searchCategories(String query) async {
    final categoryRows = await (select(projectCategories)
      ..where((c) => 
          (c.name.upper().contains(query.toUpperCase()) | 
           c.metadata.upper().contains(query.toUpperCase())) &
          c.isActive.equals(true))
      ..orderBy([(c) => OrderingTerm(expression: c.sortOrder, mode: OrderingMode.asc)])
    ).get();
    
    return categoryRows.map(_categoryRowToModel).toList();
  }

  /// Gets categories with usage count (how many projects use each category)
  Future<List<CategoryWithUsageCount>> getCategoriesWithUsage() async {
    final query = select(projectCategories).join([
      leftOuterJoin(projects, projects.categoryId.equalsExp(projectCategories.id))
    ]);

    final results = await query.get();
    final categoryMap = <String, CategoryWithUsageCount>{};

    for (final row in results) {
      final category = row.readTable(projectCategories);
      final project = row.readTableOrNull(projects);

      if (!categoryMap.containsKey(category.id)) {
        categoryMap[category.id] = CategoryWithUsageCount(
          category: _categoryRowToModel(category),
          usageCount: project != null ? 1 : 0,
        );
      } else if (project != null) {
        final existing = categoryMap[category.id]!;
        categoryMap[category.id] = CategoryWithUsageCount(
          category: existing.category,
          usageCount: existing.usageCount + 1,
        );
      }
    }

    return categoryMap.values.toList()
      ..sort((a, b) => a.category.sortOrder.compareTo(b.category.sortOrder));
  }

  /// Updates the sort order of multiple categories atomically
  Future<void> updateCategorySortOrder(List<({String id, int sortOrder})> updates) async {
    await db.transaction(() async {
      for (final update in updates) {
        await (this.update(projectCategories)..where((c) => c.id.equals(update.id)))
            .write(ProjectCategoriesCompanion(
              sortOrder: Value(update.sortOrder),
              updatedAt: Value(DateTime.now()),
            ));
      }
    });
  }

  /// Reorders categories by inserting a category at a specific position
  Future<void> reorderCategory(String categoryId, int newPosition) async {
    await db.transaction(() async {
      // Get the current category to determine if it's a root or child category
      final currentCategory = await getCategoryById(categoryId);
      if (currentCategory == null) return;

      // Get all categories at the same level
      final siblings = currentCategory.hasParent
          ? await getChildCategories(currentCategory.parentId!)
          : await getRootCategories();

      // Remove the category from its current position
      final filteredSiblings = siblings.where((c) => c.id != categoryId).toList();
      
      // Insert at new position
      final reorderedSiblings = <domain.ProjectCategory>[];
      for (int i = 0; i <= filteredSiblings.length; i++) {
        if (i == newPosition) {
          reorderedSiblings.add(currentCategory);
        }
        if (i < filteredSiblings.length) {
          reorderedSiblings.add(filteredSiblings[i]);
        }
      }

      // Update sort orders
      final updates = reorderedSiblings
          .asMap()
          .entries
          .map((entry) => (id: entry.value.id, sortOrder: entry.key))
          .toList();

      await updateCategorySortOrder(updates);
    });
  }

  /// Checks if a category name is unique among active categories
  Future<bool> isCategoryNameUnique(String name, {String? excludeId}) async {
    var query = select(projectCategories)
      ..where((c) => c.name.upper().equals(name.toUpperCase()) & c.isActive.equals(true));
    
    if (excludeId != null) {
      query = query..where((c) => c.id.isNotValue(excludeId));
    }

    final existing = await query.getSingleOrNull();
    return existing == null;
  }

  /// Gets all categories including inactive ones (for admin purposes)
  Future<List<domain.ProjectCategory>> getAllCategoriesIncludingInactive() async {
    final categoryRows = await (select(projectCategories)
      ..orderBy([(c) => OrderingTerm(expression: c.isActive, mode: OrderingMode.desc),
                (c) => OrderingTerm(expression: c.sortOrder, mode: OrderingMode.asc)])
    ).get();
    
    return categoryRows.map(_categoryRowToModel).toList();
  }

  /// Watches all active categories (returns a stream)
  Stream<List<domain.ProjectCategory>> watchActiveCategories() {
    return (select(projectCategories)
      ..where((c) => c.isActive.equals(true))
      ..orderBy([(c) => OrderingTerm(expression: c.sortOrder, mode: OrderingMode.asc)])
    ).watch().map((categoryRows) => categoryRows.map(_categoryRowToModel).toList());
  }

  /// Watches categories with usage counts (returns a stream)
  Stream<List<CategoryWithUsageCount>> watchCategoriesWithUsage() {
    return Stream.periodic(const Duration(seconds: 1))
        .asyncMap((_) => getCategoriesWithUsage())
        .distinct();
  }

  /// Converts a category database row to a ProjectCategory model
  domain.ProjectCategory _categoryRowToModel(ProjectCategory categoryRow) {
    Map<String, dynamic> metadata = <String, dynamic>{};
    try {
      metadata = json.decode(categoryRow.metadata) as Map<String, dynamic>;
    } catch (e) {
      // If JSON parsing fails, use empty map
      metadata = <String, dynamic>{};
    }

    return domain.ProjectCategory(
      id: categoryRow.id,
      name: categoryRow.name,
      iconName: categoryRow.iconName,
      color: categoryRow.color,
      parentId: categoryRow.parentId,
      isSystemDefined: categoryRow.isSystemDefined,
      isActive: categoryRow.isActive,
      sortOrder: categoryRow.sortOrder,
      createdAt: categoryRow.createdAt,
      updatedAt: categoryRow.updatedAt,
      metadata: metadata,
    );
  }

  /// Converts a ProjectCategory model to a database row
  ProjectCategoriesCompanion _categoryModelToRow(domain.ProjectCategory category) {
    return ProjectCategoriesCompanion.insert(
      id: category.id,
      name: category.name,
      iconName: category.iconName,
      color: category.color,
      parentId: Value(category.parentId),
      isSystemDefined: Value(category.isSystemDefined),
      isActive: Value(category.isActive),
      sortOrder: Value(category.sortOrder),
      createdAt: category.createdAt,
      updatedAt: Value(category.updatedAt),
      metadata: Value(json.encode(category.metadata)),
    );
  }
}

