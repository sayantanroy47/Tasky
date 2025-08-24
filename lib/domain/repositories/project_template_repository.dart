import '../entities/project_template.dart';

/// Repository interface for ProjectTemplate operations
/// 
/// Defines the contract for project template data operations.
/// This interface follows the Repository pattern to abstract data access.
abstract class ProjectTemplateRepository {
  // ============================================================================
  // BASIC CRUD OPERATIONS
  // ============================================================================

  /// Creates a new project template
  Future<ProjectTemplate> create(ProjectTemplate template);

  /// Updates an existing project template
  Future<ProjectTemplate> update(ProjectTemplate template);

  /// Deletes a project template by ID
  Future<void> delete(String id);

  /// Finds a project template by ID
  Future<ProjectTemplate?> findById(String id);

  /// Checks if a template exists
  Future<bool> exists(String id);

  /// Gets all project templates
  Future<List<ProjectTemplate>> getAll();

  // ============================================================================
  // FILTERING AND SEARCH OPERATIONS
  // ============================================================================

  /// Gets templates with optional filtering
  Future<List<ProjectTemplate>> findAll({
    String? categoryId,
    List<String>? tags,
    ProjectTemplateType? type,
    int? maxDifficultyLevel,
    bool? isPublished,
    bool? isPremium,
    String? searchQuery,
  });

  /// Searches templates by query string
  Future<List<ProjectTemplate>> search(String query);

  /// Gets popular templates based on usage statistics
  Future<List<ProjectTemplate>> getPopular({int limit = 10});

  /// Gets system templates
  Future<List<ProjectTemplate>> getSystemTemplates();

  /// Gets user-created templates
  Future<List<ProjectTemplate>> getUserTemplates();

  /// Gets templates by category
  Future<List<ProjectTemplate>> getByCategory(String categoryId);

  /// Gets templates by type
  Future<List<ProjectTemplate>> getByType(ProjectTemplateType type);

  /// Gets templates by difficulty level (max level)
  Future<List<ProjectTemplate>> getByDifficulty(int maxLevel);

  /// Gets templates by industry tags
  Future<List<ProjectTemplate>> getByIndustryTags(List<String> tags);

  // ============================================================================
  // STREAMING OPERATIONS
  // ============================================================================

  /// Watches all templates (returns a stream)
  Stream<List<ProjectTemplate>> watchAll();

  /// Watches published templates
  Stream<List<ProjectTemplate>> watchPublished();

  /// Watches system templates
  Stream<List<ProjectTemplate>> watchSystem();

  /// Watches user templates
  Stream<List<ProjectTemplate>> watchUser();

  /// Watches templates by category
  Stream<List<ProjectTemplate>> watchByCategory(String categoryId);

  /// Watches templates by type
  Stream<List<ProjectTemplate>> watchByType(ProjectTemplateType type);

  // ============================================================================
  // STATISTICS AND ANALYTICS
  // ============================================================================

  /// Gets template usage statistics
  Future<Map<String, int>> getUsageStatistics();

  /// Gets template count by category
  Future<Map<String, int>> getCountByCategory();

  /// Gets template count by type
  Future<Map<ProjectTemplateType, int>> getCountByType();

  /// Gets template count by difficulty level
  Future<Map<int, int>> getCountByDifficulty();

  /// Gets most popular templates in a time period
  Future<List<ProjectTemplate>> getTrending({
    DateTime? since,
    int limit = 10,
  });

  // ============================================================================
  // BATCH OPERATIONS
  // ============================================================================

  /// Creates multiple templates in a batch
  Future<List<ProjectTemplate>> createBatch(List<ProjectTemplate> templates);

  /// Updates multiple templates in a batch
  Future<List<ProjectTemplate>> updateBatch(List<ProjectTemplate> templates);

  /// Deletes multiple templates in a batch
  Future<void> deleteBatch(List<String> ids);

  // ============================================================================
  // VALIDATION AND UTILITY
  // ============================================================================

  /// Validates template data integrity
  Future<bool> validateTemplate(ProjectTemplate template);

  /// Checks if template name is unique (for user templates)
  Future<bool> isNameUnique(String name, {String? excludeId});

  /// Gets all unique categories used in templates
  Future<List<String>> getUniqueCategories();

  /// Gets all unique tags used in templates
  Future<List<String>> getUniqueTags();

  /// Gets all unique industry tags
  Future<List<String>> getUniqueIndustryTags();

  // ============================================================================
  // TEMPLATE MARKETPLACE OPERATIONS
  // ============================================================================

  /// Publishes a template to the marketplace
  Future<ProjectTemplate> publish(String id);

  /// Unpublishes a template from the marketplace
  Future<ProjectTemplate> unpublish(String id);

  /// Updates template rating
  Future<ProjectTemplate> updateRating(String id, double rating, int reviewCount);

  /// Increments template usage count
  Future<ProjectTemplate> incrementUsage(String id);

  /// Gets featured templates
  Future<List<ProjectTemplate>> getFeatured({int limit = 5});

  /// Gets new templates (recently published)
  Future<List<ProjectTemplate>> getNew({int limit = 10});

  // ============================================================================
  // TEMPLATE VERSIONING
  // ============================================================================

  /// Gets all versions of a template
  Future<List<ProjectTemplate>> getTemplateVersions(String templateId);

  /// Gets the latest version of a template
  Future<ProjectTemplate?> getLatestVersion(String templateId);

  /// Creates a new version of a template
  Future<ProjectTemplate> createNewVersion(
    String templateId,
    ProjectTemplate newVersion,
  );

  // ============================================================================
  // IMPORT/EXPORT OPERATIONS
  // ============================================================================

  /// Exports template to JSON
  Future<Map<String, dynamic>> exportTemplate(String id);

  /// Imports template from JSON
  Future<ProjectTemplate> importTemplate(Map<String, dynamic> json);

  /// Exports multiple templates
  Future<List<Map<String, dynamic>>> exportTemplates(List<String> ids);

  /// Imports multiple templates
  Future<List<ProjectTemplate>> importTemplates(List<Map<String, dynamic>> templates);
}