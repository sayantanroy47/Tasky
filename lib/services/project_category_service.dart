import '../domain/entities/project_category.dart';
import '../domain/entities/category_with_usage_count.dart';
import '../domain/repositories/project_category_repository.dart';
import '../core/constants/phosphor_icons.dart';

/// Service for managing project categories with business logic
/// 
/// Handles system category seeding, validation, hierarchical management,
/// and provides high-level operations for project category management.
/// Coordinates between repository layer and UI layer.
class ProjectCategoryService {
  final ProjectCategoryRepository _repository;

  const ProjectCategoryService(this._repository);

  // ============================================================================
  // SYSTEM CATEGORY DEFINITIONS - Predefined categories with design system colors
  // ============================================================================
  
  /// System-defined categories that are seeded on first app launch
  /// These match the existing CategoryUtils categories for backward compatibility
  static List<ProjectCategory> get systemCategories => [
    // Work & Business Categories
    ProjectCategory.createSystem(
      id: 'sys_work',
      name: 'Work',
      iconName: 'briefcase',
      color: '#1976D2', // Blue
      sortOrder: 0,
      metadata: const {'domain': 'work', 'isDefault': true},
    ),
    ProjectCategory.createSystem(
      id: 'sys_project',
      name: 'Project',
      iconName: 'folder',
      color: '#607D8B', // Blue Grey
      sortOrder: 1,
      metadata: const {'domain': 'work'},
    ),
    ProjectCategory.createSystem(
      id: 'sys_meeting',
      name: 'Meeting',
      iconName: 'presentation',
      color: '#673AB7', // Deep Purple
      sortOrder: 2,
      metadata: const {'domain': 'work'},
    ),

    // Personal & Lifestyle Categories
    ProjectCategory.createSystem(
      id: 'sys_personal',
      name: 'Personal',
      iconName: 'user',
      color: '#388E3C', // Green
      sortOrder: 10,
      metadata: const {'domain': 'personal', 'isDefault': true},
    ),
    ProjectCategory.createSystem(
      id: 'sys_family',
      name: 'Family',
      iconName: 'family',
      color: '#FF5722', // Deep Orange
      sortOrder: 11,
      metadata: const {'domain': 'personal'},
    ),
    ProjectCategory.createSystem(
      id: 'sys_home',
      name: 'Home',
      iconName: 'house',
      color: '#795548', // Brown
      sortOrder: 12,
      metadata: const {'domain': 'personal'},
    ),

    // Health & Fitness Categories
    ProjectCategory.createSystem(
      id: 'sys_health',
      name: 'Health',
      iconName: 'heartbeat',
      color: '#E91E63', // Pink
      sortOrder: 20,
      metadata: const {'domain': 'health'},
    ),
    ProjectCategory.createSystem(
      id: 'sys_fitness',
      name: 'Fitness',
      iconName: 'dumbbell',
      color: '#8BC34A', // Light Green
      sortOrder: 21,
      metadata: const {'domain': 'health'},
    ),

    // Finance Categories
    ProjectCategory.createSystem(
      id: 'sys_finance',
      name: 'Finance',
      iconName: 'wallet',
      color: '#4CAF50', // Green
      sortOrder: 30,
      metadata: const {'domain': 'finance'},
    ),

    // Education Categories
    ProjectCategory.createSystem(
      id: 'sys_education',
      name: 'Education',
      iconName: 'graduation-cap',
      color: '#3F51B5', // Indigo
      sortOrder: 40,
      metadata: const {'domain': 'education'},
    ),

    // Shopping Categories
    ProjectCategory.createSystem(
      id: 'sys_shopping',
      name: 'Shopping',
      iconName: 'shopping-cart',
      color: '#FF9800', // Orange
      sortOrder: 50,
      metadata: const {'domain': 'shopping'},
    ),

    // Food Categories
    ProjectCategory.createSystem(
      id: 'sys_food',
      name: 'Food',
      iconName: 'fork-knife',
      color: '#FF9800', // Orange
      sortOrder: 60,
      metadata: const {'domain': 'food'},
    ),

    // Travel Categories
    ProjectCategory.createSystem(
      id: 'sys_travel',
      name: 'Travel',
      iconName: 'airplane',
      color: '#00BCD4', // Cyan
      sortOrder: 70,
      metadata: const {'domain': 'travel'},
    ),

    // Technology Categories
    ProjectCategory.createSystem(
      id: 'sys_technology',
      name: 'Technology',
      iconName: 'laptop',
      color: '#607D8B', // Blue Grey
      sortOrder: 80,
      metadata: const {'domain': 'technology'},
    ),

    // Creative Categories
    ProjectCategory.createSystem(
      id: 'sys_creative',
      name: 'Creative',
      iconName: 'paint-brush',
      color: '#9C27B0', // Purple
      sortOrder: 90,
      metadata: const {'domain': 'creative'},
    ),

    // Entertainment Categories
    ProjectCategory.createSystem(
      id: 'sys_entertainment',
      name: 'Entertainment',
      iconName: 'game-controller',
      color: '#9C27B0', // Purple
      sortOrder: 100,
      metadata: const {'domain': 'entertainment'},
    ),

    // Communication Categories
    ProjectCategory.createSystem(
      id: 'sys_call',
      name: 'Call',
      iconName: 'phone',
      color: '#2196F3', // Blue
      sortOrder: 110,
      metadata: const {'domain': 'communication'},
    ),
    ProjectCategory.createSystem(
      id: 'sys_email',
      name: 'Email',
      iconName: 'envelope',
      color: '#009688', // Teal
      sortOrder: 111,
      metadata: const {'domain': 'communication'},
    ),

    // Priority Categories
    ProjectCategory.createSystem(
      id: 'sys_urgent',
      name: 'Urgent',
      iconName: 'warning',
      color: '#F44336', // Red
      sortOrder: 200,
      metadata: const {'domain': 'priority', 'priority': 'urgent'},
    ),
    ProjectCategory.createSystem(
      id: 'sys_important',
      name: 'Important',
      iconName: 'star',
      color: '#FFeb3B', // Yellow
      sortOrder: 201,
      metadata: const {'domain': 'priority', 'priority': 'important'},
    ),
  ];

  // ============================================================================
  // INITIALIZATION & SEEDING
  // ============================================================================

  /// Seeds system categories if they don't already exist
  /// This should be called during app initialization
  Future<void> seedSystemCategoriesIfNeeded() async {
    try {
      final existingSystemCategories = await _repository.getSystemCategories();
      
      // Only seed if no system categories exist
      if (existingSystemCategories.isEmpty) {
        await _seedAllSystemCategories();
      } else {
        // Check for new system categories and add them
        await _updateSystemCategories(existingSystemCategories);
      }
    } catch (e) {
      throw Exception('Failed to seed system categories: $e');
    }
  }

  /// Seeds all system categories
  Future<void> _seedAllSystemCategories() async {
    for (final category in systemCategories) {
      await _repository.createCategory(category);
    }
  }

  /// Updates system categories by adding new ones
  Future<void> _updateSystemCategories(List<ProjectCategory> existing) async {
    final existingIds = existing.map((c) => c.id).toSet();
    final newCategories = systemCategories.where((c) => !existingIds.contains(c.id));
    
    for (final category in newCategories) {
      await _repository.createCategory(category);
    }
  }

  // ============================================================================
  // CATEGORY MANAGEMENT
  // ============================================================================

  /// Gets all active categories organized by hierarchy
  Future<List<ProjectCategory>> getActiveCategories() async {
    return await _repository.getActiveCategories();
  }

  /// Gets categories organized by domain
  Future<Map<String, List<ProjectCategory>>> getCategoriesByDomain() async {
    final categories = await _repository.getActiveCategories();
    final Map<String, List<ProjectCategory>> categoriesByDomain = {};

    for (final category in categories) {
      final domain = category.getMetadata<String>('domain') ?? 'other';
      categoriesByDomain.putIfAbsent(domain, () => []).add(category);
    }

    // Sort categories within each domain by sortOrder
    for (final domainCategories in categoriesByDomain.values) {
      domainCategories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    return categoriesByDomain;
  }

  /// Gets root categories only (for hierarchical display)
  Future<List<ProjectCategory>> getRootCategories() async {
    return await _repository.getRootCategories();
  }

  /// Gets child categories for a parent
  Future<List<ProjectCategory>> getChildCategories(String parentId) async {
    return await _repository.getChildCategories(parentId);
  }

  /// Creates a new user-defined category with validation
  Future<ProjectCategory> createUserCategory({
    required String name,
    required String iconName,
    required String color,
    String? parentId,
    Map<String, dynamic> metadata = const {},
  }) async {
    // Validate inputs
    if (!_isValidCategoryName(name)) {
      throw ArgumentError('Invalid category name: $name');
    }
    
    if (!PhosphorIconConstants.hasIcon(iconName)) {
      throw ArgumentError('Invalid icon name: $iconName');
    }
    
    if (!_isValidHexColor(color)) {
      throw ArgumentError('Invalid color format: $color');
    }

    // Check name uniqueness
    final isUnique = await _repository.isCategoryNameUnique(name);
    if (!isUnique) {
      throw ArgumentError('Category name "$name" already exists');
    }

    // Get next sort order
    final userCategories = await _repository.getUserCategories();
    final nextSortOrder = userCategories.isEmpty 
        ? 1000 // Start user categories at 1000
        : userCategories.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

    // Create category
    final category = ProjectCategory.createUser(
      name: name,
      iconName: iconName,
      color: color,
      parentId: parentId,
      sortOrder: nextSortOrder,
      metadata: {
        'domain': PhosphorIconConstants.getDomainForIcon(iconName) ?? 'custom',
        ...metadata,
      },
    );

    await _repository.createCategory(category);
    return category;
  }

  /// Updates a user-defined category
  Future<void> updateUserCategory(
    String categoryId, {
    String? name,
    String? iconName,
    String? color,
    String? parentId,
    Map<String, dynamic>? metadata,
  }) async {
    final existing = await _repository.getCategoryById(categoryId);
    if (existing == null) {
      throw ArgumentError('Category not found: $categoryId');
    }

    if (existing.isSystemDefined) {
      throw ArgumentError('System categories cannot be modified');
    }

    // Validate new values
    if (name != null && !_isValidCategoryName(name)) {
      throw ArgumentError('Invalid category name: $name');
    }
    
    if (iconName != null && !PhosphorIconConstants.hasIcon(iconName)) {
      throw ArgumentError('Invalid icon name: $iconName');
    }
    
    if (color != null && !_isValidHexColor(color)) {
      throw ArgumentError('Invalid color format: $color');
    }

    // Check name uniqueness if name is being changed
    if (name != null && name != existing.name) {
      final isUnique = await _repository.isCategoryNameUnique(name, excludeId: categoryId);
      if (!isUnique) {
        throw ArgumentError('Category name "$name" already exists');
      }
    }

    // Update category
    final updated = existing.update(
      name: name,
      iconName: iconName,
      color: color,
      parentId: parentId,
      metadata: metadata,
    );

    await _repository.updateCategory(updated);
  }

  /// Deletes a user-defined category (soft delete)
  Future<void> deleteUserCategory(String categoryId) async {
    final category = await _repository.getCategoryById(categoryId);
    if (category == null) {
      throw ArgumentError('Category not found: $categoryId');
    }

    if (category.isSystemDefined) {
      throw ArgumentError('System categories cannot be deleted');
    }

    await _repository.deleteCategory(categoryId);
  }

  /// Reorders categories within the same hierarchical level
  Future<void> reorderCategories(List<String> categoryIds) async {
    final updates = categoryIds
        .asMap()
        .entries
        .map((entry) => (id: entry.value, sortOrder: entry.key))
        .toList();

    await _repository.updateCategorySortOrder(updates);
  }

  /// Moves a category to a different parent (or to root level)
  Future<void> moveCategoryToParent(String categoryId, String? newParentId) async {
    final category = await _repository.getCategoryById(categoryId);
    if (category == null) {
      throw ArgumentError('Category not found: $categoryId');
    }

    if (category.isSystemDefined) {
      throw ArgumentError('System categories cannot be moved');
    }

    // Validate new parent
    if (newParentId != null) {
      final parent = await _repository.getCategoryById(newParentId);
      if (parent == null) {
        throw ArgumentError('Parent category not found: $newParentId');
      }
      if (parent.parentId == categoryId) {
        throw ArgumentError('Cannot move category to its own child');
      }
    }

    // Update category
    final updated = category.copyWith(parentId: newParentId);
    await _repository.updateCategory(updated);
  }

  // ============================================================================
  // SEARCH & DISCOVERY
  // ============================================================================

  /// Searches categories by name
  Future<List<ProjectCategory>> searchCategories(String query) async {
    return await _repository.searchCategories(query);
  }

  /// Gets categories with usage statistics
  Future<List<CategoryWithUsageCount>> getCategoriesWithUsage() async {
    return await _repository.getCategoriesWithUsage();
  }

  /// Gets popular categories (most used)
  Future<List<ProjectCategory>> getPopularCategories({int limit = 10}) async {
    final categoriesWithUsage = await getCategoriesWithUsage();
    categoriesWithUsage.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    
    return categoriesWithUsage
        .take(limit)
        .map((item) => item.category)
        .toList();
  }

  /// Gets recommended icons for a category name (AI-like suggestion)
  List<String> getRecommendedIcons(String categoryName, {int limit = 6}) {
    final lowercaseName = categoryName.toLowerCase();
    final recommendations = <String>[];

    // Direct name matches
    if (PhosphorIconConstants.hasIcon(lowercaseName)) {
      recommendations.add(lowercaseName);
    }

    // Keyword-based suggestions
    final suggestions = _getIconSuggestions(lowercaseName);
    recommendations.addAll(suggestions.take(limit - recommendations.length));

    // Fill with popular icons if needed
    if (recommendations.length < limit) {
      final popular = PhosphorIconConstants.popularIconNames
          .where((icon) => !recommendations.contains(icon))
          .take(limit - recommendations.length);
      recommendations.addAll(popular);
    }

    return recommendations;
  }

  // ============================================================================
  // UTILITY & VALIDATION
  // ============================================================================

  /// Validates category name
  bool _isValidCategoryName(String name) {
    return name.trim().isNotEmpty && 
           name.length <= 50 && 
           name.trim() == name;
  }

  /// Validates hex color format
  bool _isValidHexColor(String color) {
    return RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(color);
  }

  /// Gets icon suggestions based on category name keywords
  List<String> _getIconSuggestions(String categoryName) {
    final suggestions = <String>[];
    
    // Business/Work related
    if (RegExp(r'work|business|office|meeting|project').hasMatch(categoryName)) {
      suggestions.addAll(['briefcase', 'presentation', 'building-office', 'folder', 'clipboard']);
    }
    
    // Personal related
    if (RegExp(r'personal|self|me|individual').hasMatch(categoryName)) {
      suggestions.addAll(['user', 'heart', 'star', 'bookmark']);
    }
    
    // Health related
    if (RegExp(r'health|medical|doctor|fitness|exercise').hasMatch(categoryName)) {
      suggestions.addAll(['heartbeat', 'medical-bag', 'dumbbell', 'activity']);
    }
    
    // Creative related
    if (RegExp(r'creative|art|design|paint|music|photo').hasMatch(categoryName)) {
      suggestions.addAll(['paint-brush', 'palette', 'camera', 'music-note']);
    }
    
    // Technology related
    if (RegExp(r'tech|computer|code|digital|software').hasMatch(categoryName)) {
      suggestions.addAll(['laptop', 'code', 'gear', 'database']);
    }
    
    // Travel related
    if (RegExp(r'travel|trip|vacation|flight|car').hasMatch(categoryName)) {
      suggestions.addAll(['airplane', 'car', 'suitcase', 'map-pin']);
    }
    
    // Finance related
    if (RegExp(r'money|finance|bank|budget|investment').hasMatch(categoryName)) {
      suggestions.addAll(['wallet', 'bank', 'coins', 'credit-card']);
    }
    
    // Food related
    if (RegExp(r'food|cook|recipe|restaurant|meal').hasMatch(categoryName)) {
      suggestions.addAll(['fork-knife', 'chef-hat', 'apple', 'cooking-pot']);
    }

    return suggestions;
  }

  /// Gets category statistics for analytics
  Future<Map<String, dynamic>> getCategoryStatistics() async {
    final allCategories = await _repository.getAllCategories();
    final activeCategories = await _repository.getActiveCategories();
    final systemCategories = await _repository.getSystemCategories();
    final userCategories = await _repository.getUserCategories();
    final categoriesWithUsage = await getCategoriesWithUsage();

    return {
      'total_categories': allCategories.length,
      'active_categories': activeCategories.length,
      'system_categories': systemCategories.length,
      'user_categories': userCategories.length,
      'categories_with_projects': categoriesWithUsage.where((c) => c.usageCount > 0).length,
      'total_projects_with_categories': categoriesWithUsage.fold<int>(0, (sum, c) => sum + c.usageCount),
      'domains': await _getDomainStatistics(),
    };
  }

  /// Gets domain statistics
  Future<Map<String, int>> _getDomainStatistics() async {
    final categories = await _repository.getActiveCategories();
    final domainCounts = <String, int>{};
    
    for (final category in categories) {
      final domain = category.getMetadata<String>('domain') ?? 'other';
      domainCounts[domain] = (domainCounts[domain] ?? 0) + 1;
    }
    
    return domainCounts;
  }
}