import '../domain/entities/project.dart';
import '../domain/entities/project_category.dart';
import '../domain/repositories/project_category_repository.dart';
import '../domain/repositories/project_repository.dart';
import '../core/utils/category_utils.dart';

/// Service for migrating projects from legacy category system to new ProjectCategory system
/// 
/// Handles the transition from string-based categories to ProjectCategory entities,
/// ensuring data integrity and providing rollback capabilities.
class ProjectCategoryMigrationService {
  final ProjectCategoryRepository _categoryRepository;
  final ProjectRepository _projectRepository;

  const ProjectCategoryMigrationService(
    this._categoryRepository,
    this._projectRepository,
  );

  // ============================================================================
  // MIGRATION STATUS & ANALYSIS
  // ============================================================================

  /// Analyzes the current migration status
  Future<MigrationStatus> analyzeMigrationStatus() async {
    try {
      final allProjects = await _projectRepository.getAllProjects();
      final systemCategories = await _categoryRepository.getSystemCategories();
      
      final legacyProjects = allProjects.where((p) => p.usesLegacyCategorySystem).toList();
      final newSystemProjects = allProjects.where((p) => p.usesNewCategorySystem).toList();
      final uncategorizedProjects = allProjects.where((p) => !p.hasCategory).toList();

      // Analyze legacy category usage
      final legacyCategoryUsage = <String, int>{};
      for (final project in legacyProjects) {
        if (project.category != null) {
          legacyCategoryUsage[project.category!] = 
              (legacyCategoryUsage[project.category!] ?? 0) + 1;
        }
      }

      return MigrationStatus(
        totalProjects: allProjects.length,
        legacyProjects: legacyProjects.length,
        newSystemProjects: newSystemProjects.length,
        uncategorizedProjects: uncategorizedProjects.length,
        systemCategoriesCount: systemCategories.length,
        legacyCategoryUsage: legacyCategoryUsage,
        isFullyMigrated: legacyProjects.isEmpty,
        migrationProgress: allProjects.isEmpty ? 1.0 : newSystemProjects.length / allProjects.length,
      );
    } catch (e) {
      throw Exception('Failed to analyze migration status: $e');
    }
  }

  /// Gets projects that need migration
  Future<List<Project>> getProjectsNeedingMigration() async {
    try {
      final allProjects = await _projectRepository.getAllProjects();
      return allProjects.where((p) => p.usesLegacyCategorySystem).toList();
    } catch (e) {
      throw Exception('Failed to get projects needing migration: $e');
    }
  }

  /// Gets orphaned projects (projects with categoryId that doesn't exist)
  Future<List<Project>> getOrphanedProjects() async {
    try {
      final allProjects = await _projectRepository.getAllProjects();
      final categorizedProjects = allProjects.where((p) => p.usesNewCategorySystem).toList();
      
      final orphanedProjects = <Project>[];
      for (final project in categorizedProjects) {
        final category = await _categoryRepository.getCategoryById(project.categoryId!);
        if (category == null) {
          orphanedProjects.add(project);
        }
      }
      
      return orphanedProjects;
    } catch (e) {
      throw Exception('Failed to get orphaned projects: $e');
    }
  }

  // ============================================================================
  // MIGRATION OPERATIONS
  // ============================================================================

  /// Performs complete migration from legacy to new category system
  Future<MigrationResult> performFullMigration() async {
    try {
      final migrationResults = <String, MigrationResult>{};
      final projectsToMigrate = await getProjectsNeedingMigration();
      
      for (final project in projectsToMigrate) {
        if (project.category != null) {
          final result = await migrateProjectCategory(project.id, project.category!);
          migrationResults[project.id] = result;
        }
      }

      final successCount = migrationResults.values.where((r) => r.success).length;
      final failureCount = migrationResults.length - successCount;

      return MigrationResult(
        success: failureCount == 0,
        projectId: 'bulk_migration',
        oldCategory: 'various',
        newCategoryId: 'various',
        message: 'Migrated $successCount projects, $failureCount failures',
        details: migrationResults,
      );
    } catch (e) {
      return MigrationResult(
        success: false,
        projectId: 'bulk_migration',
        oldCategory: 'various',
        message: 'Bulk migration failed: $e',
      );
    }
  }

  /// Migrates a single project's category
  Future<MigrationResult> migrateProjectCategory(String projectId, String legacyCategory) async {
    try {
      final project = await _projectRepository.getProjectById(projectId);
      if (project == null) {
        return MigrationResult(
          success: false,
          projectId: projectId,
          oldCategory: legacyCategory,
          message: 'Project not found',
        );
      }

      if (!project.usesLegacyCategorySystem) {
        return MigrationResult(
          success: true,
          projectId: projectId,
          oldCategory: legacyCategory,
          message: 'Project already uses new category system',
        );
      }

      // Find or create corresponding system category
      final newCategoryId = await _findOrCreateSystemCategory(legacyCategory);
      if (newCategoryId == null) {
        return MigrationResult(
          success: false,
          projectId: projectId,
          oldCategory: legacyCategory,
          message: 'Could not find or create system category for: $legacyCategory',
        );
      }

      // Migrate the project
      final migratedProject = project.migrateToNewCategorySystem(newCategoryId);
      await _projectRepository.updateProject(migratedProject);

      return MigrationResult(
        success: true,
        projectId: projectId,
        oldCategory: legacyCategory,
        newCategoryId: newCategoryId,
        message: 'Successfully migrated project category',
      );
    } catch (e) {
      return MigrationResult(
        success: false,
        projectId: projectId,
        oldCategory: legacyCategory,
        message: 'Migration failed: $e',
      );
    }
  }

  /// Batch migrates multiple projects
  Future<List<MigrationResult>> migrateProjectCategories(List<String> projectIds) async {
    final results = <MigrationResult>[];
    
    for (final projectId in projectIds) {
      final project = await _projectRepository.getProjectById(projectId);
      if (project?.category != null) {
        final result = await migrateProjectCategory(projectId, project!.category!);
        results.add(result);
      }
    }
    
    return results;
  }

  // ============================================================================
  // ROLLBACK OPERATIONS
  // ============================================================================

  /// Rolls back a project from new category system to legacy
  Future<MigrationResult> rollbackProjectCategory(String projectId) async {
    try {
      final project = await _projectRepository.getProjectById(projectId);
      if (project == null) {
        return MigrationResult(
          success: false,
          projectId: projectId,
          message: 'Project not found',
        );
      }

      if (!project.usesNewCategorySystem) {
        return MigrationResult(
          success: true,
          projectId: projectId,
          message: 'Project already uses legacy category system',
        );
      }

      // Get the category and determine legacy name
      final category = await _categoryRepository.getCategoryById(project.categoryId!);
      if (category == null) {
        return MigrationResult(
          success: false,
          projectId: projectId,
          newCategoryId: project.categoryId,
          message: 'Category not found for rollback',
        );
      }

      // Find corresponding legacy category name
      final legacyCategoryName = _getLegacyCategoryName(category);
      if (legacyCategoryName == null) {
        return MigrationResult(
          success: false,
          projectId: projectId,
          newCategoryId: project.categoryId,
          message: 'No corresponding legacy category found',
        );
      }

      // Rollback the project
      final rolledBackProject = project.migrateToLegacyCategorySystem(legacyCategoryName);
      await _projectRepository.updateProject(rolledBackProject);

      return MigrationResult(
        success: true,
        projectId: projectId,
        oldCategory: legacyCategoryName,
        newCategoryId: project.categoryId,
        message: 'Successfully rolled back project category',
      );
    } catch (e) {
      return MigrationResult(
        success: false,
        projectId: projectId,
        message: 'Rollback failed: $e',
      );
    }
  }

  /// Performs complete rollback from new to legacy category system
  Future<MigrationResult> performFullRollback() async {
    try {
      final allProjects = await _projectRepository.getAllProjects();
      final newSystemProjects = allProjects.where((p) => p.usesNewCategorySystem).toList();
      
      final rollbackResults = <String, MigrationResult>{};
      
      for (final project in newSystemProjects) {
        final result = await rollbackProjectCategory(project.id);
        rollbackResults[project.id] = result;
      }

      final successCount = rollbackResults.values.where((r) => r.success).length;
      final failureCount = rollbackResults.length - successCount;

      return MigrationResult(
        success: failureCount == 0,
        projectId: 'bulk_rollback',
        message: 'Rolled back $successCount projects, $failureCount failures',
        details: rollbackResults,
      );
    } catch (e) {
      return MigrationResult(
        success: false,
        projectId: 'bulk_rollback',
        message: 'Bulk rollback failed: $e',
      );
    }
  }

  // ============================================================================
  // CLEANUP OPERATIONS
  // ============================================================================

  /// Cleans up orphaned projects by assigning them to default categories
  Future<List<MigrationResult>> cleanupOrphanedProjects() async {
    try {
      final orphanedProjects = await getOrphanedProjects();
      final results = <MigrationResult>[];
      
      // Get or create a default "General" category
      final defaultCategory = await _findOrCreateSystemCategory('general') ?? 
                             await _findOrCreateSystemCategory('work');
      
      if (defaultCategory == null) {
        throw Exception('Could not find or create default category');
      }
      
      for (final project in orphanedProjects) {
        try {
          final fixedProject = project.copyWith(
            categoryId: defaultCategory,
            updatedAt: DateTime.now(),
          );
          await _projectRepository.updateProject(fixedProject);
          
          results.add(MigrationResult(
            success: true,
            projectId: project.id,
            newCategoryId: defaultCategory,
            message: 'Fixed orphaned project',
          ));
        } catch (e) {
          results.add(MigrationResult(
            success: false,
            projectId: project.id,
            message: 'Failed to fix orphaned project: $e',
          ));
        }
      }
      
      return results;
    } catch (e) {
      throw Exception('Failed to cleanup orphaned projects: $e');
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Finds existing system category or creates it from legacy category
  Future<String?> _findOrCreateSystemCategory(String legacyCategory) async {
    // First, try to find existing system category by name
    final existingCategory = await _categoryRepository.getCategoryByName(legacyCategory);
    if (existingCategory != null) {
      return existingCategory.id;
    }

    // Check if it's a known legacy category
    if (!CategoryUtils.isLegacyCategory(legacyCategory)) {
      return null;
    }

    // Create system category from legacy category
    final newCategory = CategoryUtils.legacyCategoryToEntity(legacyCategory);
    if (newCategory != null) {
      await _categoryRepository.createCategory(newCategory);
      return newCategory.id;
    }

    return null;
  }

  /// Gets corresponding legacy category name for a ProjectCategory
  String? _getLegacyCategoryName(ProjectCategory category) {
    // Check if it's a system category with legacy metadata
    final legacyName = category.getMetadata<String>('originalName');
    if (legacyName != null) {
      return legacyName;
    }

    // Map common category names back to legacy names
    switch (category.name.toLowerCase()) {
      case 'work': return 'work';
      case 'personal': return 'personal';
      case 'shopping': return 'shopping';
      case 'health': return 'health';
      case 'fitness': return 'fitness';
      case 'finance': return 'finance';
      case 'education': return 'education';
      case 'travel': return 'travel';
      case 'home': return 'home';
      case 'family': return 'family';
      case 'entertainment': return 'entertainment';
      case 'food': return 'food';
      case 'technology': return 'technology';
      case 'creative': return 'creative';
      case 'project': return 'project';
      case 'meeting': return 'meeting';
      case 'call': return 'call';
      case 'email': return 'email';
      case 'urgent': return 'urgent';
      case 'important': return 'important';
      default: return null;
    }
  }
}

// ============================================================================
// DATA CLASSES - Migration status and results
// ============================================================================

/// Migration status information
class MigrationStatus {
  final int totalProjects;
  final int legacyProjects;
  final int newSystemProjects;
  final int uncategorizedProjects;
  final int systemCategoriesCount;
  final Map<String, int> legacyCategoryUsage;
  final bool isFullyMigrated;
  final double migrationProgress;

  const MigrationStatus({
    required this.totalProjects,
    required this.legacyProjects,
    required this.newSystemProjects,
    required this.uncategorizedProjects,
    required this.systemCategoriesCount,
    required this.legacyCategoryUsage,
    required this.isFullyMigrated,
    required this.migrationProgress,
  });

  @override
  String toString() {
    return 'MigrationStatus(total: $totalProjects, legacy: $legacyProjects, '
           'newSystem: $newSystemProjects, progress: ${(migrationProgress * 100).toStringAsFixed(1)}%)';
  }
}

/// Migration result for individual operations
class MigrationResult {
  final bool success;
  final String projectId;
  final String? oldCategory;
  final String? newCategoryId;
  final String message;
  final Map<String, dynamic>? details;

  const MigrationResult({
    required this.success,
    required this.projectId,
    this.oldCategory,
    this.newCategoryId,
    required this.message,
    this.details,
  });

  @override
  String toString() {
    return 'MigrationResult(projectId: $projectId, success: $success, message: $message)';
  }
}