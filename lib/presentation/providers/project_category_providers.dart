import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/project_category.dart' as domain;
import '../../domain/entities/category_with_usage_count.dart';
import '../../domain/repositories/project_category_repository.dart';
import '../../data/repositories/project_category_repository_impl.dart';
import '../../services/database/daos/project_category_dao.dart';
import '../../services/project_category_service.dart';
import '../../core/providers/core_providers.dart';

/// Riverpod providers for project category management
/// 
/// Provides dependency injection and state management for the project category system,
/// supporting both system-defined and user-defined categories with Clean Architecture.

// ============================================================================
// REPOSITORY & SERVICE PROVIDERS - Dependency injection layer
// ============================================================================

/// Provider for ProjectCategoryDao
final projectCategoryDaoProvider = Provider<ProjectCategoryDao>((ref) {
  final database = ref.watch(databaseProvider);
  return ProjectCategoryDao(database);
});

/// Provider for ProjectCategoryRepository
final projectCategoryRepositoryProvider = Provider<ProjectCategoryRepository>((ref) {
  final dao = ref.watch(projectCategoryDaoProvider);
  return ProjectCategoryRepositoryImpl(dao);
});

/// Provider for ProjectCategoryService
final projectCategoryServiceProvider = Provider<ProjectCategoryService>((ref) {
  final repository = ref.watch(projectCategoryRepositoryProvider);
  return ProjectCategoryService(repository);
});

// ============================================================================
// CATEGORY DATA PROVIDERS - Core data management
// ============================================================================

/// Provider for all active categories
final activeCategoriesProvider = FutureProvider<List<domain.ProjectCategory>>((ref) async {
  final service = ref.watch(projectCategoryServiceProvider);
  return service.getActiveCategories();
});

/// Provider for system categories only
final systemCategoriesProvider = FutureProvider<List<domain.ProjectCategory>>((ref) async {
  final repository = ref.watch(projectCategoryRepositoryProvider);
  return repository.getSystemCategories();
});

/// Provider for user-defined categories only
final userCategoriesProvider = FutureProvider<List<domain.ProjectCategory>>((ref) async {
  final repository = ref.watch(projectCategoryRepositoryProvider);
  return repository.getUserCategories();
});

/// Provider for root categories (hierarchical display)
final rootCategoriesProvider = FutureProvider<List<domain.ProjectCategory>>((ref) async {
  final service = ref.watch(projectCategoryServiceProvider);
  return service.getRootCategories();
});

/// Provider for categories organized by domain
final categoriesByDomainProvider = FutureProvider<Map<String, List<domain.ProjectCategory>>>((ref) async {
  final service = ref.watch(projectCategoryServiceProvider);
  return service.getCategoriesByDomain();
});

/// Provider for categories with usage statistics
final categoriesWithUsageProvider = FutureProvider<List<CategoryWithUsageCount>>((ref) async {
  final service = ref.watch(projectCategoryServiceProvider);
  return service.getCategoriesWithUsage();
});

/// Provider for popular categories (most used)
final popularCategoriesProvider = FutureProvider<List<domain.ProjectCategory>>((ref) async {
  final service = ref.watch(projectCategoryServiceProvider);
  return service.getPopularCategories();
});

/// Provider for category statistics
final categoryStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(projectCategoryServiceProvider);
  return service.getCategoryStatistics();
});

// ============================================================================
// INDIVIDUAL CATEGORY PROVIDERS - Single category access
// ============================================================================

/// Provider for a specific category by ID
final categoryByIdProvider = FutureProvider.family<domain.ProjectCategory?, String>((ref, categoryId) async {
  final repository = ref.watch(projectCategoryRepositoryProvider);
  return repository.getCategoryById(categoryId);
});

/// Provider for child categories of a specific parent
final childCategoriesProvider = FutureProvider.family<List<domain.ProjectCategory>, String>((ref, parentId) async {
  final service = ref.watch(projectCategoryServiceProvider);
  return service.getChildCategories(parentId);
});

// ============================================================================
// SEARCH & DISCOVERY PROVIDERS - Search and recommendation features
// ============================================================================

/// Provider for category search results
final categorySearchProvider = FutureProvider.family<List<domain.ProjectCategory>, String>((ref, query) async {
  final service = ref.watch(projectCategoryServiceProvider);
  return service.searchCategories(query);
});

/// Provider for recommended icons based on category name
final recommendedIconsProvider = Provider.family<List<String>, String>((ref, categoryName) {
  final service = ref.watch(projectCategoryServiceProvider);
  return service.getRecommendedIcons(categoryName);
});

// ============================================================================
// STREAMING PROVIDERS - Real-time updates
// ============================================================================

/// Stream provider for watching active categories in real-time
final activeCategoriesStreamProvider = StreamProvider<List<domain.ProjectCategory>>((ref) {
  final repository = ref.watch(projectCategoryRepositoryProvider);
  return repository.watchActiveCategories();
});

/// Stream provider for watching categories with usage counts
final categoriesWithUsageStreamProvider = StreamProvider<List<CategoryWithUsageCount>>((ref) {
  final repository = ref.watch(projectCategoryRepositoryProvider);
  return repository.watchCategoriesWithUsage();
});

// ============================================================================
// STATE NOTIFIER PROVIDERS - Mutable state management
// ============================================================================

/// State notifier for managing category creation/editing
final categoryFormStateProvider = StateNotifierProvider<CategoryFormNotifier, CategoryFormState>((ref) {
  final service = ref.watch(projectCategoryServiceProvider);
  return CategoryFormNotifier(service);
});

/// State notifier for managing category selection
final categorySelectionProvider = StateNotifierProvider<CategorySelectionNotifier, CategorySelectionState>((ref) {
  return CategorySelectionNotifier();
});

/// State notifier for managing category reordering
final categoryReorderProvider = StateNotifierProvider<CategoryReorderNotifier, CategoryReorderState>((ref) {
  final service = ref.watch(projectCategoryServiceProvider);
  return CategoryReorderNotifier(service);
});

// ============================================================================
// INITIALIZATION PROVIDER - System category seeding
// ============================================================================

/// Provider for initializing the category system
final categorySystemInitializationProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(projectCategoryServiceProvider);
  await service.seedSystemCategoriesIfNeeded();
});

// ============================================================================
// STATE CLASSES - Data models for state management
// ============================================================================

/// State class for category form (create/edit)
class CategoryFormState {
  final String? id;
  final String name;
  final String iconName;
  final String color;
  final String? parentId;
  final Map<String, dynamic> metadata;
  final bool isLoading;
  final String? error;
  final bool isValid;

  const CategoryFormState({
    this.id,
    this.name = '',
    this.iconName = 'tag',
    this.color = '#6200EE',
    this.parentId,
    this.metadata = const {},
    this.isLoading = false,
    this.error,
    this.isValid = false,
  });

  CategoryFormState copyWith({
    String? id,
    String? name,
    String? iconName,
    String? color,
    String? parentId,
    Map<String, dynamic>? metadata,
    bool? isLoading,
    String? error,
    bool? isValid,
  }) {
    return CategoryFormState(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      metadata: metadata ?? this.metadata,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isValid: isValid ?? this.isValid,
    );
  }

  bool get isEditing => id != null;
  
  domain.ProjectCategory toDomainProjectCategory() {
    if (isEditing) {
      return domain.ProjectCategory(
        id: id!,
        name: name,
        iconName: iconName,
        color: color,
        parentId: parentId,
        isSystemDefined: false,
        isActive: true,
        sortOrder: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: metadata,
      );
    } else {
      return domain.ProjectCategory.createUser(
        name: name,
        iconName: iconName,
        color: color,
        parentId: parentId,
        metadata: metadata,
      );
    }
  }
}

/// State class for category selection
class CategorySelectionState {
  final domain.ProjectCategory? selectedCategory;
  final List<domain.ProjectCategory> recentlySelected;
  final String searchQuery;
  final String? selectedDomain;

  const CategorySelectionState({
    this.selectedCategory,
    this.recentlySelected = const [],
    this.searchQuery = '',
    this.selectedDomain,
  });

  CategorySelectionState copyWith({
    domain.ProjectCategory? selectedCategory,
    List<domain.ProjectCategory>? recentlySelected,
    String? searchQuery,
    String? selectedDomain,
  }) {
    return CategorySelectionState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      recentlySelected: recentlySelected ?? this.recentlySelected,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDomain: selectedDomain ?? this.selectedDomain,
    );
  }
}

/// State class for category reordering
class CategoryReorderState {
  final List<domain.ProjectCategory> categories;
  final bool isReordering;
  final String? error;

  const CategoryReorderState({
    this.categories = const [],
    this.isReordering = false,
    this.error,
  });

  CategoryReorderState copyWith({
    List<domain.ProjectCategory>? categories,
    bool? isReordering,
    String? error,
  }) {
    return CategoryReorderState(
      categories: categories ?? this.categories,
      isReordering: isReordering ?? this.isReordering,
      error: error ?? this.error,
    );
  }
}

// ============================================================================
// STATE NOTIFIERS - Business logic for state management
// ============================================================================

/// State notifier for category form management
class CategoryFormNotifier extends StateNotifier<CategoryFormState> {
  final ProjectCategoryService _service;

  CategoryFormNotifier(this._service) : super(const CategoryFormState());

  /// Initializes form for editing an existing category
  void initializeForEdit(domain.ProjectCategory category) {
    state = CategoryFormState(
      id: category.id,
      name: category.name,
      iconName: category.iconName,
      color: category.color,
      parentId: category.parentId,
      metadata: category.metadata,
      isValid: true,
    );
  }

  /// Updates category name and validates
  void updateName(String name) {
    state = state.copyWith(
      name: name,
      isValid: _validateForm(name: name),
    );
  }

  /// Updates icon name
  void updateIconName(String iconName) {
    state = state.copyWith(
      iconName: iconName,
      isValid: _validateForm(iconName: iconName),
    );
  }

  /// Updates color
  void updateColor(String color) {
    state = state.copyWith(
      color: color,
      isValid: _validateForm(color: color),
    );
  }

  /// Updates parent category
  void updateParentId(String? parentId) {
    state = state.copyWith(
      parentId: parentId,
      isValid: _validateForm(),
    );
  }

  /// Updates metadata
  void updateMetadata(Map<String, dynamic> metadata) {
    state = state.copyWith(
      metadata: metadata,
      isValid: _validateForm(),
    );
  }

  /// Saves the category (create or update)
  Future<bool> saveCategory() async {
    if (!state.isValid) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final category = state.toDomainProjectCategory();
      
      if (state.isEditing) {
        await _service.updateUserCategory(
          category.id,
          name: category.name,
          iconName: category.iconName,
          color: category.color,
          parentId: category.parentId,
          metadata: category.metadata,
        );
      } else {
        await _service.createUserCategory(
          name: category.name,
          iconName: category.iconName,
          color: category.color,
          parentId: category.parentId,
          metadata: category.metadata,
        );
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Resets the form
  void reset() {
    state = const CategoryFormState();
  }

  /// Validates the form
  bool _validateForm({String? name, String? iconName, String? color}) {
    final currentName = name ?? state.name;
    final currentIconName = iconName ?? state.iconName;
    final currentColor = color ?? state.color;

    return currentName.trim().isNotEmpty &&
           currentName.length <= 50 &&
           currentIconName.isNotEmpty &&
           RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(currentColor);
  }
}

/// State notifier for category selection management
class CategorySelectionNotifier extends StateNotifier<CategorySelectionState> {
  CategorySelectionNotifier() : super(const CategorySelectionState());

  /// Selects a category
  void selectCategory(domain.ProjectCategory category) {
    final updatedRecent = _updateRecentlySelected(category);
    state = state.copyWith(
      selectedCategory: category,
      recentlySelected: updatedRecent,
    );
  }

  /// Clears selection
  void clearSelection() {
    state = state.copyWith(selectedCategory: null);
  }

  /// Updates search query
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Selects a domain filter
  void selectDomain(String? domain) {
    state = state.copyWith(selectedDomain: domain);
  }

  /// Updates recently selected list
  List<domain.ProjectCategory> _updateRecentlySelected(domain.ProjectCategory category) {
    final recent = List<domain.ProjectCategory>.from(state.recentlySelected);
    recent.removeWhere((c) => c.id == category.id);
    recent.insert(0, category);
    return recent.take(5).toList(); // Keep only 5 recent selections
  }
}

/// State notifier for category reordering
class CategoryReorderNotifier extends StateNotifier<CategoryReorderState> {
  final ProjectCategoryService _service;

  CategoryReorderNotifier(this._service) : super(const CategoryReorderState());

  /// Initializes reordering with current categories
  Future<void> initializeReordering(List<domain.ProjectCategory> categories) async {
    state = state.copyWith(
      categories: categories,
      isReordering: false,
    );
  }

  /// Reorders categories locally (for preview)
  void reorderLocally(int oldIndex, int newIndex) {
    final categories = List<domain.ProjectCategory>.from(state.categories);
    final item = categories.removeAt(oldIndex);
    categories.insert(newIndex, item);
    
    state = state.copyWith(categories: categories);
  }

  /// Saves the reordered categories
  Future<bool> saveReorder() async {
    state = state.copyWith(isReordering: true, error: null);

    try {
      final categoryIds = state.categories.map((c) => c.id).toList();
      await _service.reorderCategories(categoryIds);
      
      state = state.copyWith(isReordering: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isReordering: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Cancels reordering and resets to original order
  void cancelReorder(List<domain.ProjectCategory> originalCategories) {
    state = state.copyWith(
      categories: originalCategories,
      isReordering: false,
      error: null,
    );
  }
}