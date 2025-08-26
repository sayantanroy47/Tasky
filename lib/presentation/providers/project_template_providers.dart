import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/project_template_repository_impl.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_template.dart' as entities;
import '../../domain/entities/project_template.dart' show ProjectTemplateType;
import '../../domain/repositories/project_template_repository.dart';
import '../../services/project_template_service.dart';
import '../../core/providers/core_providers.dart';

part 'project_template_providers.g.dart';

// ============================================================================
// REPOSITORY PROVIDERS
// ============================================================================

/// Provides ProjectTemplateRepository implementation
@Riverpod(keepAlive: true)
ProjectTemplateRepository projectTemplateRepository(Ref ref) {
  final database = ref.watch(databaseProvider);
  return ProjectTemplateRepositoryImpl(dao: database.projectTemplateDao);
}

/// Provides ProjectTemplateService for business logic
@Riverpod(keepAlive: true)
ProjectTemplateService projectTemplateService(Ref ref) {
  final templateRepository = ref.watch(projectTemplateRepositoryProvider);
  final projectRepository = ref.watch(projectRepositoryProvider);
  final taskRepository = ref.watch(taskRepositoryProvider);
  final taskTemplateRepository = ref.watch(taskTemplateRepositoryProvider);
  
  return ProjectTemplateService(
    templateRepository: templateRepository,
    projectRepository: projectRepository,
    taskRepository: taskRepository,
    taskTemplateRepository: taskTemplateRepository,
  );
}

// ============================================================================
// DATA PROVIDERS
// ============================================================================

/// Provides all project templates
@riverpod
Future<List<entities.ProjectTemplate>> allProjectTemplates(Ref ref) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.getAll();
}

/// Provides published project templates
@riverpod
Future<List<entities.ProjectTemplate>> publishedProjectTemplates(Ref ref) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.findAll(isPublished: true);
}

/// Provides system project templates
@riverpod
Future<List<entities.ProjectTemplate>> systemProjectTemplates(Ref ref) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.getSystemTemplates();
}

/// Provides user project templates
@riverpod
Future<List<entities.ProjectTemplate>> userProjectTemplates(Ref ref) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.getUserTemplates();
}

/// Provides popular project templates
@riverpod
Future<List<entities.ProjectTemplate>> popularProjectTemplates(
  Ref ref, {
  int limit = 10,
}) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.getPopular(limit: limit);
}

/// Provides featured project templates
@riverpod
Future<List<entities.ProjectTemplate>> featuredProjectTemplates(
  Ref ref, {
  int limit = 5,
}) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.getFeatured(limit: limit);
}

/// Provides new project templates
@riverpod
Future<List<entities.ProjectTemplate>> newProjectTemplates(
  Ref ref, {
  int limit = 10,
}) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.getNew(limit: limit);
}

/// Provides trending project templates
@riverpod
Future<List<entities.ProjectTemplate>> trendingProjectTemplates(
  Ref ref, {
  DateTime? since,
  int limit = 10,
}) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.getTrending(since: since, limit: limit);
}

// ============================================================================
// FILTERED DATA PROVIDERS
// ============================================================================

/// Provides templates filtered by category
@riverpod
Future<List<entities.ProjectTemplate>> templatesByCategory(
  Ref ref,
  String categoryId,
) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.getByCategory(categoryId);
}

/// Provides templates filtered by type
@riverpod
Future<List<entities.ProjectTemplate>> templatesByType(
  Ref ref,
  entities.ProjectTemplateType type,
) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.getByType(type);
}

/// Provides templates filtered by difficulty level
@riverpod
Future<List<entities.ProjectTemplate>> templatesByDifficulty(
  Ref ref,
  int maxLevel,
) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.getByDifficulty(maxLevel);
}

/// Provides templates filtered by industry tags
@riverpod
Future<List<entities.ProjectTemplate>> templatesByIndustryTags(
  Ref ref,
  List<String> tags,
) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.getByIndustryTags(tags);
}

/// Provides search results for project templates
@riverpod
Future<List<entities.ProjectTemplate>> searchProjectTemplates(
  Ref ref,
  String query,
) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.search(query);
}

/// Provides filtered project templates with complex criteria
@riverpod
Future<List<entities.ProjectTemplate>> filteredProjectTemplates(
  Ref ref,
  ProjectTemplateFilter filter,
) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.findAll(
    categoryId: filter.categoryId,
    tags: filter.tags.isNotEmpty ? filter.tags : null,
    type: filter.type,
    maxDifficultyLevel: filter.maxDifficulty,
    isPublished: true,
    isPremium: filter.showOnlyFree ? false : null,
    searchQuery: filter.searchQuery.isNotEmpty ? filter.searchQuery : null,
  );
}

// ============================================================================
// SINGLE TEMPLATE PROVIDERS
// ============================================================================

/// Provides a single project template by ID
@riverpod
Future<entities.ProjectTemplate?> projectTemplate(
  Ref ref,
  String templateId,
) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.findById(templateId);
}

/// Provides template versions for a template
@riverpod
Future<List<entities.ProjectTemplate>> templateVersions(
  Ref ref,
  String templateId,
) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.getTemplateVersions(templateId);
}

/// Provides the latest version of a template
@riverpod
Future<entities.ProjectTemplate?> latestTemplateVersion(
  Ref ref,
  String templateId,
) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.getLatestVersion(templateId);
}

// ============================================================================
// STATISTICS PROVIDERS
// ============================================================================

/// Provides template usage statistics
@riverpod
Future<Map<String, int>> templateUsageStatistics(Ref ref) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.getUsageStatistics();
}

/// Provides template count by category
@riverpod
Future<Map<String, int>> templateCountByCategory(Ref ref) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.getCountByCategory();
}

/// Provides template count by type
@riverpod
Future<Map<entities.ProjectTemplateType, int>> templateCountByType(Ref ref) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.getCountByType();
}

/// Provides template count by difficulty
@riverpod
Future<Map<int, int>> templateCountByDifficulty(Ref ref) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.getCountByDifficulty();
}

// ============================================================================
// UTILITY PROVIDERS
// ============================================================================

/// Provides unique categories from templates
@riverpod
Future<List<String>> uniqueTemplateCategories(Ref ref) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.getUniqueCategories();
}

/// Provides unique tags from templates
@riverpod
Future<List<String>> uniqueTemplateTags(Ref ref) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.getUniqueTags();
}

/// Provides unique industry tags from templates
@riverpod
Future<List<String>> uniqueIndustryTags(Ref ref) async {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return await repository.getUniqueIndustryTags();
}

// ============================================================================
// STREAMING PROVIDERS
// ============================================================================

/// Streams all project templates
@riverpod
Stream<List<entities.ProjectTemplate>> watchAllProjectTemplates(Ref ref) {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return repository.watchAll();
}

/// Streams published project templates
@riverpod
Stream<List<entities.ProjectTemplate>> watchPublishedProjectTemplates(Ref ref) {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return repository.watchPublished();
}

/// Streams system project templates
@riverpod
Stream<List<entities.ProjectTemplate>> watchSystemProjectTemplates(Ref ref) {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return repository.watchSystem();
}

/// Streams user project templates
@riverpod
Stream<List<entities.ProjectTemplate>> watchUserProjectTemplates(Ref ref) {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return repository.watchUser();
}

/// Streams templates by category
@riverpod
Stream<List<entities.ProjectTemplate>> watchTemplatesByCategory(
  Ref ref,
  String categoryId,
) {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return repository.watchByCategory(categoryId);
}

/// Streams templates by type
@riverpod
Stream<List<entities.ProjectTemplate>> watchTemplatesByType(
  Ref ref,
  entities.ProjectTemplateType type,
) {
  final repository = ref.watch(projectTemplateRepositoryProvider);
  return repository.watchByType(type);
}

// ============================================================================
// ACTION PROVIDERS
// ============================================================================

/// Provides template creation functionality
@riverpod
class ProjectTemplateActions extends _$ProjectTemplateActions {
  @override
  void build() {
    // No initial state needed
  }

  /// Creates a new project template
  Future<entities.ProjectTemplate> createTemplate(entities.ProjectTemplate template) async {
    final service = ref.read(projectTemplateServiceProvider);
    final createdTemplate = await service.createTemplate(template);
    
    // Invalidate relevant providers
    ref.invalidate(allProjectTemplatesProvider);
    ref.invalidate(userProjectTemplatesProvider);
    ref.invalidate(templateUsageStatisticsProvider);
    
    return createdTemplate;
  }

  /// Updates an existing project template
  Future<entities.ProjectTemplate> updateTemplate(entities.ProjectTemplate template) async {
    final service = ref.read(projectTemplateServiceProvider);
    final updatedTemplate = await service.updateTemplate(template);
    
    // Invalidate relevant providers
    ref.invalidate(allProjectTemplatesProvider);
    ref.invalidate(userProjectTemplatesProvider);
    ref.invalidate(projectTemplateProvider(template.id));
    
    return updatedTemplate;
  }

  /// Deletes a project template
  Future<void> deleteTemplate(String templateId) async {
    final service = ref.read(projectTemplateServiceProvider);
    await service.deleteTemplate(templateId);
    
    // Invalidate relevant providers
    ref.invalidate(allProjectTemplatesProvider);
    ref.invalidate(userProjectTemplatesProvider);
    ref.invalidate(projectTemplateProvider(templateId));
    ref.invalidate(templateUsageStatisticsProvider);
  }

  /// Publishes a template to the marketplace
  Future<entities.ProjectTemplate> publishTemplate(String templateId) async {
    final repository = ref.read(projectTemplateRepositoryProvider);
    final publishedTemplate = await repository.publish(templateId);
    
    // Invalidate relevant providers
    ref.invalidate(publishedProjectTemplatesProvider);
    ref.invalidate(projectTemplateProvider(templateId));
    
    return publishedTemplate;
  }

  /// Unpublishes a template from the marketplace
  Future<entities.ProjectTemplate> unpublishTemplate(String templateId) async {
    final repository = ref.read(projectTemplateRepositoryProvider);
    final unpublishedTemplate = await repository.unpublish(templateId);
    
    // Invalidate relevant providers
    ref.invalidate(publishedProjectTemplatesProvider);
    ref.invalidate(projectTemplateProvider(templateId));
    
    return unpublishedTemplate;
  }

  /// Updates template rating
  Future<entities.ProjectTemplate> updateTemplateRating(
    String templateId,
    double rating,
    int reviewCount,
  ) async {
    final repository = ref.read(projectTemplateRepositoryProvider);
    final updatedTemplate = await repository.updateRating(templateId, rating, reviewCount);
    
    // Invalidate relevant providers
    ref.invalidate(projectTemplateProvider(templateId));
    ref.invalidate(popularProjectTemplatesProvider());
    ref.invalidate(featuredProjectTemplatesProvider());
    
    return updatedTemplate;
  }

  /// Increments template usage count
  Future<entities.ProjectTemplate> incrementTemplateUsage(String templateId) async {
    final repository = ref.read(projectTemplateRepositoryProvider);
    final updatedTemplate = await repository.incrementUsage(templateId);
    
    // Invalidate relevant providers
    ref.invalidate(projectTemplateProvider(templateId));
    ref.invalidate(popularProjectTemplatesProvider());
    ref.invalidate(trendingProjectTemplatesProvider());
    ref.invalidate(templateUsageStatisticsProvider);
    
    return updatedTemplate;
  }

  /// Creates a project from a template
  Future<Project> createProjectFromTemplate(
    entities.ProjectTemplate template,
    Map<String, dynamic> variableValues, {
    String? customProjectName,
    String? customDescription,
    DateTime? customDeadline,
  }) async {
    final service = ref.read(projectTemplateServiceProvider);
    final project = await service.createProjectFromTemplate(
      template,
      variableValues,
      customProjectName: customProjectName,
      customDescription: customDescription,
      customDeadline: customDeadline,
    );
    
    // Increment usage count
    await incrementTemplateUsage(template.id);
    
    // Note: Project providers would be invalidated through project providers
    
    return project;
  }

  /// Creates a template from an existing project
  Future<entities.ProjectTemplate> createTemplateFromProject(
    Project project,
    String templateName, {
    String? description,
    entities.ProjectTemplateType type = entities.ProjectTemplateType.simple,
    List<entities.TemplateVariable>? variables,
    Map<String, String>? variableMappings,
  }) async {
    final service = ref.read(projectTemplateServiceProvider);
    final template = await service.createTemplateFromProject(
      project,
      templateName,
      description: description,
      type: type,
      variables: variables,
      variableMappings: variableMappings,
    );
    
    // Invalidate relevant providers
    ref.invalidate(allProjectTemplatesProvider);
    ref.invalidate(userProjectTemplatesProvider);
    
    return template;
  }

  /// Seeds system templates
  Future<void> seedSystemTemplates() async {
    final service = ref.read(projectTemplateServiceProvider);
    await service.seedSystemTemplates();
    
    // Invalidate all template providers
    ref.invalidate(allProjectTemplatesProvider);
    ref.invalidate(systemProjectTemplatesProvider);
  }

  /// Validates template data
  Future<bool> validateTemplate(entities.ProjectTemplate template) async {
    final repository = ref.read(projectTemplateRepositoryProvider);
    return await repository.validateTemplate(template);
  }

  /// Checks if template name is unique
  Future<bool> isTemplateNameUnique(String name, {String? excludeId}) async {
    final repository = ref.read(projectTemplateRepositoryProvider);
    return await repository.isNameUnique(name, excludeId: excludeId);
  }

  /// Exports template to JSON
  Future<Map<String, dynamic>> exportTemplate(String templateId) async {
    final repository = ref.read(projectTemplateRepositoryProvider);
    return await repository.exportTemplate(templateId);
  }

  /// Imports template from JSON
  Future<entities.ProjectTemplate> importTemplate(Map<String, dynamic> json) async {
    final repository = ref.read(projectTemplateRepositoryProvider);
    final template = await repository.importTemplate(json);
    
    // Invalidate relevant providers
    ref.invalidate(allProjectTemplatesProvider);
    ref.invalidate(userProjectTemplatesProvider);
    
    return template;
  }

  /// Batch operations
  Future<List<entities.ProjectTemplate>> createMultipleTemplates(List<entities.ProjectTemplate> templates) async {
    final repository = ref.read(projectTemplateRepositoryProvider);
    final createdTemplates = await repository.createBatch(templates);
    
    // Invalidate relevant providers
    ref.invalidate(allProjectTemplatesProvider);
    ref.invalidate(userProjectTemplatesProvider);
    
    return createdTemplates;
  }

  Future<List<entities.ProjectTemplate>> updateMultipleTemplates(List<entities.ProjectTemplate> templates) async {
    final repository = ref.read(projectTemplateRepositoryProvider);
    final updatedTemplates = await repository.updateBatch(templates);
    
    // Invalidate relevant providers
    ref.invalidate(allProjectTemplatesProvider);
    ref.invalidate(userProjectTemplatesProvider);
    
    for (final template in templates) {
      ref.invalidate(projectTemplateProvider(template.id));
    }
    
    return updatedTemplates;
  }

  Future<void> deleteMultipleTemplates(List<String> templateIds) async {
    final repository = ref.read(projectTemplateRepositoryProvider);
    await repository.deleteBatch(templateIds);
    
    // Invalidate relevant providers
    ref.invalidate(allProjectTemplatesProvider);
    ref.invalidate(userProjectTemplatesProvider);
    
    for (final id in templateIds) {
      ref.invalidate(projectTemplateProvider(id));
    }
  }
}

// ============================================================================
// UI STATE PROVIDERS
// ============================================================================

/// Provides marketplace filter state
@riverpod
class TemplateMarketplaceFilter extends _$TemplateMarketplaceFilter {
  @override
  ProjectTemplateFilter build() {
    return const ProjectTemplateFilter();
  }

  void updateFilter(ProjectTemplateFilter filter) {
    state = filter;
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateType(entities.ProjectTemplateType? type) {
    state = state.copyWith(type: type);
  }

  void updateMaxDifficulty(int? maxDifficulty) {
    state = state.copyWith(maxDifficulty: maxDifficulty);
  }

  void updateCategory(String? categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void updateTags(List<String> tags) {
    state = state.copyWith(tags: tags);
  }

  void updateShowOnlyFree(bool showOnlyFree) {
    state = state.copyWith(showOnlyFree: showOnlyFree);
  }

  void updateSortBy(TemplateSortOption sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void clearFilter() {
    state = const ProjectTemplateFilter();
  }
}

/// Provides template editor state
@riverpod
class TemplateEditorState extends _$TemplateEditorState {
  @override
  entities.ProjectTemplate? build() {
    return null;
  }

  void setTemplate(entities.ProjectTemplate template) {
    state = template;
  }

  void clearTemplate() {
    state = null;
  }

  void updateTemplate(entities.ProjectTemplate template) {
    state = template;
  }
}

// ============================================================================
// SUPPORTING CLASSES (moved from marketplace widget)
// ============================================================================

/// Filter configuration for project templates
class ProjectTemplateFilter {
  final String searchQuery;
  final entities.ProjectTemplateType? type;
  final int? maxDifficulty;
  final String? categoryId;
  final List<String> tags;
  final bool showOnlyFree;
  final TemplateSortOption sortBy;

  const ProjectTemplateFilter({
    this.searchQuery = '',
    this.type,
    this.maxDifficulty,
    this.categoryId,
    this.tags = const [],
    this.showOnlyFree = false,
    this.sortBy = TemplateSortOption.popularity,
  });

  ProjectTemplateFilter copyWith({
    String? searchQuery,
    entities.ProjectTemplateType? type,
    int? maxDifficulty,
    String? categoryId,
    List<String>? tags,
    bool? showOnlyFree,
    TemplateSortOption? sortBy,
  }) {
    return ProjectTemplateFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      type: type ?? this.type,
      maxDifficulty: maxDifficulty ?? this.maxDifficulty,
      categoryId: categoryId ?? this.categoryId,
      tags: tags ?? this.tags,
      showOnlyFree: showOnlyFree ?? this.showOnlyFree,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ProjectTemplateFilter &&
      other.searchQuery == searchQuery &&
      other.type == type &&
      other.maxDifficulty == maxDifficulty &&
      other.categoryId == categoryId &&
      other.tags.length == tags.length &&
      other.tags.every((tag) => tags.contains(tag)) &&
      other.showOnlyFree == showOnlyFree &&
      other.sortBy == sortBy;
  }

  @override
  int get hashCode {
    return searchQuery.hashCode ^
      type.hashCode ^
      maxDifficulty.hashCode ^
      categoryId.hashCode ^
      tags.hashCode ^
      showOnlyFree.hashCode ^
      sortBy.hashCode;
  }
}

/// Sort options for templates
enum TemplateSortOption {
  name,
  popularity,
  rating,
  newest,
  difficulty;

  String get displayName {
    switch (this) {
      case TemplateSortOption.name:
        return 'Name';
      case TemplateSortOption.popularity:
        return 'Popularity';
      case TemplateSortOption.rating:
        return 'Rating';
      case TemplateSortOption.newest:
        return 'Newest';
      case TemplateSortOption.difficulty:
        return 'Difficulty';
    }
  }
}

