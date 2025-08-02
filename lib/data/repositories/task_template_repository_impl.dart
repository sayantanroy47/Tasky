import '../../domain/entities/task_template.dart';
import '../../domain/repositories/task_template_repository.dart';
import '../datasources/local/task_template_local_datasource.dart';

/// Implementation of TaskTemplateRepository using local data source
class TaskTemplateRepositoryImpl implements TaskTemplateRepository {
  final TaskTemplateLocalDataSource _localDataSource;

  TaskTemplateRepositoryImpl(this._localDataSource);  @override
  Future<List<TaskTemplate>> getAllTemplates() async {
    try {
      return await _localDataSource.getAllTemplates();
    } catch (e) {
      throw Exception('Failed to get all templates: $e');
    }
  }  @override
  Future<TaskTemplate?> getTemplateById(String id) async {
    try {
      return await _localDataSource.getTemplateById(id);
    } catch (e) {
      throw Exception('Failed to get template by id: $e');
    }
  }  @override
  Future<void> createTemplate(TaskTemplate template) async {
    try {
      if (!template.isValid()) {
        throw Exception('Invalid template data');
      }
      await _localDataSource.createTemplate(template);
    } catch (e) {
      throw Exception('Failed to create template: $e');
    }
  }  @override
  Future<void> updateTemplate(TaskTemplate template) async {
    try {
      if (!template.isValid()) {
        throw Exception('Invalid template data');
      }
      await _localDataSource.updateTemplate(template);
    } catch (e) {
      throw Exception('Failed to update template: $e');
    }
  }  @override
  Future<void> deleteTemplate(String id) async {
    try {
      await _localDataSource.deleteTemplate(id);
    } catch (e) {
      throw Exception('Failed to delete template: $e');
    }
  }  @override
  Future<List<TaskTemplate>> getTemplatesByCategory(String category) async {
    try {
      return await _localDataSource.getTemplatesByCategory(category);
    } catch (e) {
      throw Exception('Failed to get templates by category: $e');
    }
  }  @override
  Future<List<TaskTemplate>> getFavoriteTemplates() async {
    try {
      return await _localDataSource.getFavoriteTemplates();
    } catch (e) {
      throw Exception('Failed to get favorite templates: $e');
    }
  }  @override
  Future<List<TaskTemplate>> getMostUsedTemplates({int limit = 10}) async {
    try {
      return await _localDataSource.getMostUsedTemplates(limit: limit);
    } catch (e) {
      throw Exception('Failed to get most used templates: $e');
    }
  }  @override
  Future<List<TaskTemplate>> searchTemplates(String query) async {
    try {
      return await _localDataSource.searchTemplates(query);
    } catch (e) {
      throw Exception('Failed to search templates: $e');
    }
  }  @override
  Future<List<TaskTemplate>> getTemplatesWithFilter(TemplateFilter filter) async {
    try {
      return await _localDataSource.getTemplatesWithFilter(filter);
    } catch (e) {
      throw Exception('Failed to get templates with filter: $e');
    }
  }  @override
  Stream<List<TaskTemplate>> watchAllTemplates() {
    try {
      return _localDataSource.watchAllTemplates();
    } catch (e) {
      throw Exception('Failed to watch all templates: $e');
    }
  }  @override
  Stream<List<TaskTemplate>> watchFavoriteTemplates() {
    try {
      return _localDataSource.watchFavoriteTemplates();
    } catch (e) {
      throw Exception('Failed to watch favorite templates: $e');
    }
  }  @override
  Stream<List<TaskTemplate>> watchTemplatesByCategory(String category) {
    try {
      return _localDataSource.watchTemplatesByCategory(category);
    } catch (e) {
      throw Exception('Failed to watch templates by category: $e');
    }
  }  @override
  Future<List<String>> getAllCategories() async {
    try {
      return await _localDataSource.getAllCategories();
    } catch (e) {
      throw Exception('Failed to get all categories: $e');
    }
  }
}
