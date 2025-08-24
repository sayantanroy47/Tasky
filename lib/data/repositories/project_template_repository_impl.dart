import '../../domain/entities/project_template.dart';
import '../../domain/repositories/project_template_repository.dart';
import '../../services/database/daos/project_template_dao.dart';

/// Implementation of ProjectTemplateRepository using local database
class ProjectTemplateRepositoryImpl implements ProjectTemplateRepository {
  final ProjectTemplateDao _dao;

  ProjectTemplateRepositoryImpl({
    required ProjectTemplateDao dao,
  }) : _dao = dao;

  // ============================================================================
  // BASIC CRUD OPERATIONS
  // ============================================================================

  @override
  Future<ProjectTemplate> create(ProjectTemplate template) async {
    await _dao.createTemplate(template);
    return template;
  }

  @override
  Future<ProjectTemplate> update(ProjectTemplate template) async {
    await _dao.updateTemplate(template);
    return template;
  }

  @override
  Future<void> delete(String id) async {
    await _dao.deleteTemplate(id);
  }

  @override
  Future<ProjectTemplate?> findById(String id) async {
    return await _dao.getTemplateById(id);
  }

  @override
  Future<bool> exists(String id) async {
    return await _dao.exists(id);
  }

  @override
  Future<List<ProjectTemplate>> getAll() async {
    return await _dao.getAllTemplates();
  }

  // ============================================================================
  // FILTERING AND SEARCH OPERATIONS
  // ============================================================================

  @override
  Future<List<ProjectTemplate>> findAll({
    String? categoryId,
    List<String>? tags,
    ProjectTemplateType? type,
    int? maxDifficultyLevel,
    bool? isPublished,
    bool? isPremium,
    String? searchQuery,
  }) async {
    return await _dao.findAll(
      categoryId: categoryId,
      tags: tags,
      type: type,
      maxDifficultyLevel: maxDifficultyLevel,
      isPublished: isPublished,
      isPremium: isPremium,
      searchQuery: searchQuery,
    );
  }

  @override
  Future<List<ProjectTemplate>> search(String query) async {
    return await _dao.search(query);
  }

  @override
  Future<List<ProjectTemplate>> getPopular({int limit = 10}) async {
    return await _dao.getPopularTemplates(limit: limit);
  }

  @override
  Future<List<ProjectTemplate>> getSystemTemplates() async {
    return await _dao.getSystemTemplates();
  }

  @override
  Future<List<ProjectTemplate>> getUserTemplates() async {
    return await _dao.getUserTemplates();
  }

  @override
  Future<List<ProjectTemplate>> getByCategory(String categoryId) async {
    return await _dao.getTemplatesByCategory(categoryId);
  }

  @override
  Future<List<ProjectTemplate>> getByType(ProjectTemplateType type) async {
    return await _dao.getTemplatesByType(type);
  }

  @override
  Future<List<ProjectTemplate>> getByDifficulty(int maxLevel) async {
    return await findAll(maxDifficultyLevel: maxLevel, isPublished: true);
  }

  @override
  Future<List<ProjectTemplate>> getByIndustryTags(List<String> tags) async {
    return await findAll(tags: tags, isPublished: true);
  }

  // ============================================================================
  // STREAMING OPERATIONS
  // ============================================================================

  @override
  Stream<List<ProjectTemplate>> watchAll() {
    return _dao.watchAllTemplates();
  }

  @override
  Stream<List<ProjectTemplate>> watchPublished() {
    return _dao.watchPublishedTemplates();
  }

  @override
  Stream<List<ProjectTemplate>> watchSystem() {
    return _dao.watchSystemTemplates();
  }

  @override
  Stream<List<ProjectTemplate>> watchUser() {
    return _dao.watchUserTemplates();
  }

  @override
  Stream<List<ProjectTemplate>> watchByCategory(String categoryId) {
    // Filter the stream to only include templates of the specified category
    return watchAll().map((templates) =>
        templates.where((t) => t.categoryId == categoryId).toList());
  }

  @override
  Stream<List<ProjectTemplate>> watchByType(ProjectTemplateType type) {
    // Filter the stream to only include templates of the specified type
    return watchAll().map((templates) =>
        templates.where((t) => t.type == type).toList());
  }

  // ============================================================================
  // STATISTICS AND ANALYTICS
  // ============================================================================

  @override
  Future<Map<String, int>> getUsageStatistics() async {
    final templates = await getAll();
    
    final totalUsage = templates.fold<int>(0, (sum, t) => sum + t.usageStats.usageCount);
    final totalFavorites = templates.fold<int>(0, (sum, t) => sum + t.usageStats.favoriteCount);
    final publishedCount = templates.where((t) => t.isPublished).length;
    final systemCount = templates.where((t) => t.isSystemTemplate).length;
    final userCount = templates.where((t) => !t.isSystemTemplate).length;
    final premiumCount = templates.where((t) => t.isPremium).length;

    return {
      'total_templates': templates.length,
      'total_usage': totalUsage,
      'total_favorites': totalFavorites,
      'published_count': publishedCount,
      'system_count': systemCount,
      'user_count': userCount,
      'premium_count': premiumCount,
    };
  }

  @override
  Future<Map<String, int>> getCountByCategory() async {
    final templates = await getAll();
    final categoryCount = <String, int>{};

    for (final template in templates) {
      if (template.categoryId != null) {
        categoryCount[template.categoryId!] = 
            (categoryCount[template.categoryId!] ?? 0) + 1;
      }
    }

    return categoryCount;
  }

  @override
  Future<Map<ProjectTemplateType, int>> getCountByType() async {
    final templates = await getAll();
    final typeCount = <ProjectTemplateType, int>{};

    for (final template in templates) {
      typeCount[template.type] = (typeCount[template.type] ?? 0) + 1;
    }

    return typeCount;
  }

  @override
  Future<Map<int, int>> getCountByDifficulty() async {
    final templates = await getAll();
    final difficultyCount = <int, int>{};

    for (final template in templates) {
      difficultyCount[template.difficultyLevel] = 
          (difficultyCount[template.difficultyLevel] ?? 0) + 1;
    }

    return difficultyCount;
  }

  @override
  Future<List<ProjectTemplate>> getTrending({
    DateTime? since,
    int limit = 10,
  }) async {
    final templates = await findAll(isPublished: true);
    
    // Filter by date if provided
    List<ProjectTemplate> filteredTemplates = templates;
    if (since != null) {
      filteredTemplates = templates.where((template) {
        return template.usageStats.lastUsed != null && 
               template.usageStats.lastUsed!.isAfter(since);
      }).toList();
    }

    // Sort by trending score
    filteredTemplates.sort((a, b) => 
        b.usageStats.trendingScore.compareTo(a.usageStats.trendingScore));

    return filteredTemplates.take(limit).toList();
  }

  // ============================================================================
  // BATCH OPERATIONS
  // ============================================================================

  @override
  Future<List<ProjectTemplate>> createBatch(List<ProjectTemplate> templates) async {
    final createdTemplates = <ProjectTemplate>[];

    for (final template in templates) {
      final created = await create(template);
      createdTemplates.add(created);
    }

    return createdTemplates;
  }

  @override
  Future<List<ProjectTemplate>> updateBatch(List<ProjectTemplate> templates) async {
    final updatedTemplates = <ProjectTemplate>[];

    for (final template in templates) {
      final updated = await update(template);
      updatedTemplates.add(updated);
    }

    return updatedTemplates;
  }

  @override
  Future<void> deleteBatch(List<String> ids) async {
    for (final id in ids) {
      await delete(id);
    }
  }

  // ============================================================================
  // VALIDATION AND UTILITY
  // ============================================================================

  @override
  Future<bool> validateTemplate(ProjectTemplate template) async {
    // Basic validation
    if (!template.isValid()) {
      return false;
    }

    // Check name uniqueness for user templates
    if (!template.isSystemTemplate) {
      final isUnique = await isNameUnique(template.name, excludeId: template.id);
      if (!isUnique) {
        return false;
      }
    }

    return true;
  }

  @override
  Future<bool> isNameUnique(String name, {String? excludeId}) async {
    final templates = await getUserTemplates();
    
    return !templates.any((template) => 
        template.name.toLowerCase() == name.toLowerCase() && 
        template.id != excludeId);
  }

  @override
  Future<List<String>> getUniqueCategories() async {
    final templates = await getAll();
    final categories = templates
        .where((t) => t.categoryId != null)
        .map((t) => t.categoryId!)
        .toSet()
        .toList();
    
    categories.sort();
    return categories;
  }

  @override
  Future<List<String>> getUniqueTags() async {
    final templates = await getAll();
    final tags = <String>{};
    
    for (final template in templates) {
      tags.addAll(template.tags);
    }
    
    final tagList = tags.toList();
    tagList.sort();
    return tagList;
  }

  @override
  Future<List<String>> getUniqueIndustryTags() async {
    final templates = await getAll();
    final industryTags = <String>{};
    
    for (final template in templates) {
      industryTags.addAll(template.industryTags);
    }
    
    final tagList = industryTags.toList();
    tagList.sort();
    return tagList;
  }

  // ============================================================================
  // TEMPLATE MARKETPLACE OPERATIONS
  // ============================================================================

  @override
  Future<ProjectTemplate> publish(String id) async {
    final template = await findById(id);
    if (template == null) {
      throw ArgumentError('Template not found: $id');
    }

    final published = template.publish();
    return await update(published);
  }

  @override
  Future<ProjectTemplate> unpublish(String id) async {
    final template = await findById(id);
    if (template == null) {
      throw ArgumentError('Template not found: $id');
    }

    final unpublished = template.unpublish();
    return await update(unpublished);
  }

  @override
  Future<ProjectTemplate> updateRating(String id, double rating, int reviewCount) async {
    final template = await findById(id);
    if (template == null) {
      throw ArgumentError('Template not found: $id');
    }

    final updated = template.updateRating(rating, reviewCount);
    return await update(updated);
  }

  @override
  Future<ProjectTemplate> incrementUsage(String id) async {
    final template = await findById(id);
    if (template == null) {
      throw ArgumentError('Template not found: $id');
    }

    final updated = template.incrementUsage();
    return await update(updated);
  }

  @override
  Future<List<ProjectTemplate>> getFeatured({int limit = 5}) async {
    // Featured templates are high-rated, popular, system templates
    final templates = await findAll(isPublished: true);
    
    final featured = templates.where((template) {
      final hasGoodRating = template.rating?.averageRating != null && 
                           template.rating!.averageRating >= 4.0;
      final hasGoodUsage = template.usageStats.usageCount >= 10;
      return hasGoodRating || hasGoodUsage || template.isSystemTemplate;
    }).toList();

    // Sort by rating and usage
    featured.sort((a, b) {
      final scoreA = (a.rating?.averageRating ?? 0) * 10 + 
                     a.usageStats.usageCount * 0.1;
      final scoreB = (b.rating?.averageRating ?? 0) * 10 + 
                     b.usageStats.usageCount * 0.1;
      return scoreB.compareTo(scoreA);
    });

    return featured.take(limit).toList();
  }

  @override
  Future<List<ProjectTemplate>> getNew({int limit = 10}) async {
    final templates = await findAll(isPublished: true);
    
    // Sort by creation date (newest first)
    templates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return templates.take(limit).toList();
  }

  // ============================================================================
  // TEMPLATE VERSIONING
  // ============================================================================

  @override
  Future<List<ProjectTemplate>> getTemplateVersions(String templateId) async {
    // In a full implementation, this would track template versions
    // For now, return just the current template
    final template = await findById(templateId);
    return template != null ? [template] : [];
  }

  @override
  Future<ProjectTemplate?> getLatestVersion(String templateId) async {
    return await findById(templateId);
  }

  @override
  Future<ProjectTemplate> createNewVersion(
    String templateId,
    ProjectTemplate newVersion,
  ) async {
    // In a full implementation, this would handle version tracking
    // For now, just update the template
    return await update(newVersion);
  }

  // ============================================================================
  // IMPORT/EXPORT OPERATIONS
  // ============================================================================

  @override
  Future<Map<String, dynamic>> exportTemplate(String id) async {
    final template = await findById(id);
    if (template == null) {
      throw ArgumentError('Template not found: $id');
    }

    return template.toJson();
  }

  @override
  Future<ProjectTemplate> importTemplate(Map<String, dynamic> json) async {
    final template = ProjectTemplate.fromJson(json);
    
    // Validate before importing
    if (!await validateTemplate(template)) {
      throw ArgumentError('Invalid template data');
    }

    return await create(template);
  }

  @override
  Future<List<Map<String, dynamic>>> exportTemplates(List<String> ids) async {
    final exports = <Map<String, dynamic>>[];

    for (final id in ids) {
      final exported = await exportTemplate(id);
      exports.add(exported);
    }

    return exports;
  }

  @override
  Future<List<ProjectTemplate>> importTemplates(List<Map<String, dynamic>> templates) async {
    final imported = <ProjectTemplate>[];

    for (final templateJson in templates) {
      final template = await importTemplate(templateJson);
      imported.add(template);
    }

    return imported;
  }
}