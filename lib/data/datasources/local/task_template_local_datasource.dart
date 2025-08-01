import '../../../domain/entities/task_template.dart' as domain;
import '../../../domain/repositories/task_template_repository.dart';
import '../../../services/database/database.dart';

/// Local data source for task templates using SQLite/Drift
class TaskTemplateLocalDataSource {
  final AppDatabase _database;

  TaskTemplateLocalDataSource(this._database);

  /// Gets all task templates from the database
  Future<List<domain.TaskTemplate>> getAllTemplates() async {
    try {
      return await _database.taskTemplateDao.getAllTemplates();
    } catch (e) {
      throw Exception('Failed to get all templates from database: $e');
    }
  }

  /// Gets a task template by its unique identifier
  Future<domain.TaskTemplate?> getTemplateById(String id) async {
    try {
      return await _database.taskTemplateDao.getTemplateById(id);
    } catch (e) {
      throw Exception('Failed to get template by id from database: $e');
    }
  }

  /// Creates a new task template in the database
  Future<void> createTemplate(domain.TaskTemplate template) async {
    try {
      await _database.taskTemplateDao.createTemplate(template);
    } catch (e) {
      throw Exception('Failed to create template in database: $e');
    }
  }

  /// Updates an existing task template in the database
  Future<void> updateTemplate(domain.TaskTemplate template) async {
    try {
      await _database.taskTemplateDao.updateTemplate(template);
    } catch (e) {
      throw Exception('Failed to update template in database: $e');
    }
  }

  /// Deletes a task template from the database
  Future<void> deleteTemplate(String id) async {
    try {
      await _database.taskTemplateDao.deleteTemplate(id);
    } catch (e) {
      throw Exception('Failed to delete template from database: $e');
    }
  }

  /// Gets templates filtered by category
  Future<List<domain.TaskTemplate>> getTemplatesByCategory(String category) async {
    try {
      return await _database.taskTemplateDao.getTemplatesByCategory(category);
    } catch (e) {
      throw Exception('Failed to get templates by category from database: $e');
    }
  }

  /// Gets favorite templates
  Future<List<domain.TaskTemplate>> getFavoriteTemplates() async {
    try {
      return await _database.taskTemplateDao.getFavoriteTemplates();
    } catch (e) {
      throw Exception('Failed to get favorite templates from database: $e');
    }
  }

  /// Gets most used templates (sorted by usage count)
  Future<List<domain.TaskTemplate>> getMostUsedTemplates({int limit = 10}) async {
    try {
      return await _database.taskTemplateDao.getMostUsedTemplates(limit: limit);
    } catch (e) {
      throw Exception('Failed to get most used templates from database: $e');
    }
  }

  /// Searches templates by name or description
  Future<List<domain.TaskTemplate>> searchTemplates(String query) async {
    try {
      return await _database.taskTemplateDao.searchTemplates(query);
    } catch (e) {
      throw Exception('Failed to search templates in database: $e');
    }
  }

  /// Gets templates with advanced filtering options
  Future<List<domain.TaskTemplate>> getTemplatesWithFilter(TemplateFilter filter) async {
    try {
      // For now, we'll implement basic filtering
      // This could be enhanced in the DAO to support more complex filtering
      if (filter.category != null) {
        return await getTemplatesByCategory(filter.category!);
      } else if (filter.isFavorite == true) {
        return await getFavoriteTemplates();
      } else if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        return await searchTemplates(filter.searchQuery!);
      } else {
        return await getAllTemplates();
      }
    } catch (e) {
      throw Exception('Failed to get templates with filter from database: $e');
    }
  }

  /// Watches all templates (returns a stream for real-time updates)
  Stream<List<domain.TaskTemplate>> watchAllTemplates() {
    try {
      return _database.taskTemplateDao.watchAllTemplates();
    } catch (e) {
      throw Exception('Failed to watch all templates: $e');
    }
  }

  /// Watches favorite templates (returns a stream)
  Stream<List<domain.TaskTemplate>> watchFavoriteTemplates() {
    try {
      return _database.taskTemplateDao.watchFavoriteTemplates();
    } catch (e) {
      throw Exception('Failed to watch favorite templates: $e');
    }
  }

  /// Watches templates for a specific category (returns a stream)
  Stream<List<domain.TaskTemplate>> watchTemplatesByCategory(String category) {
    try {
      return _database.taskTemplateDao.watchTemplatesByCategory(category);
    } catch (e) {
      throw Exception('Failed to watch templates by category: $e');
    }
  }

  /// Gets all unique categories
  Future<List<String>> getAllCategories() async {
    try {
      return await _database.taskTemplateDao.getAllCategories();
    } catch (e) {
      throw Exception('Failed to get all categories from database: $e');
    }
  }
}
