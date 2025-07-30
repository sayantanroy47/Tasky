import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_template.dart';
import '../../domain/repositories/task_template_repository.dart';
import '../../data/repositories/task_template_repository_impl.dart';
import '../../data/datasources/local/task_template_local_datasource.dart';
import 'task_providers.dart';

/// Provider for TaskTemplateRepository
final taskTemplateRepositoryProvider = Provider<TaskTemplateRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final localDataSource = TaskTemplateLocalDataSource(database);
  return TaskTemplateRepositoryImpl(localDataSource);
});

/// State notifier for managing task templates
class TaskTemplateNotifier extends StateNotifier<AsyncValue<List<TaskTemplate>>> {
  final TaskTemplateRepository _repository;

  TaskTemplateNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      final templates = await _repository.getAllTemplates();
      state = AsyncValue.data(templates);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createTemplate(TaskTemplate template) async {
    try {
      await _repository.createTemplate(template);
      await _loadTemplates();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTemplate(TaskTemplate template) async {
    try {
      await _repository.updateTemplate(template);
      await _loadTemplates();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTemplate(String id) async {
    try {
      await _repository.deleteTemplate(id);
      await _loadTemplates();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleTemplateFavorite(String id) async {
    try {
      final template = await _repository.getTemplateById(id);
      if (template != null) {
        final updatedTemplate = template.toggleFavorite();
        await _repository.updateTemplate(updatedTemplate);
        await _loadTemplates();
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> incrementTemplateUsage(String id) async {
    try {
      final template = await _repository.getTemplateById(id);
      if (template != null) {
        final updatedTemplate = template.incrementUsage();
        await _repository.updateTemplate(updatedTemplate);
        await _loadTemplates();
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<List<TaskTemplate>> searchTemplates(String query) async {
    try {
      return await _repository.searchTemplates(query);
    } catch (error) {
      return [];
    }
  }
}

/// Provider for TaskTemplateNotifier
final taskTemplateNotifierProvider = 
    StateNotifierProvider<TaskTemplateNotifier, AsyncValue<List<TaskTemplate>>>((ref) {
  final repository = ref.watch(taskTemplateRepositoryProvider);
  return TaskTemplateNotifier(repository);
});

/// Provider for all task templates
final taskTemplatesProvider = Provider<AsyncValue<List<TaskTemplate>>>((ref) {
  return ref.watch(taskTemplateNotifierProvider);
});

/// Provider for favorite task templates
final favoriteTaskTemplatesProvider = Provider<AsyncValue<List<TaskTemplate>>>((ref) {
  final templatesAsync = ref.watch(taskTemplatesProvider);
  return templatesAsync.when(
    data: (templates) {
      final favoriteTemplates = templates.where((template) => template.isFavorite).toList();
      return AsyncValue.data(favoriteTemplates);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider for most used task templates
final mostUsedTaskTemplatesProvider = Provider<AsyncValue<List<TaskTemplate>>>((ref) {
  final templatesAsync = ref.watch(taskTemplatesProvider);
  return templatesAsync.when(
    data: (templates) {
      final sortedTemplates = List<TaskTemplate>.from(templates)
        ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
      return AsyncValue.data(sortedTemplates.take(10).toList());
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider for templates by category
final templatesByCategoryProvider = 
    Provider.family<AsyncValue<List<TaskTemplate>>, String>((ref, category) {
  final templatesAsync = ref.watch(taskTemplatesProvider);
  return templatesAsync.when(
    data: (templates) {
      final categoryTemplates = templates
          .where((template) => template.category == category)
          .toList();
      return AsyncValue.data(categoryTemplates);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider for all template categories
final templateCategoriesProvider = Provider<AsyncValue<List<String>>>((ref) {
  final templatesAsync = ref.watch(taskTemplatesProvider);
  return templatesAsync.when(
    data: (templates) {
      final categories = templates
          .where((template) => template.hasCategory)
          .map((template) => template.category!)
          .toSet()
          .toList();
      categories.sort();
      return AsyncValue.data(categories);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider for template search results
final templateSearchProvider = 
    Provider.family<AsyncValue<List<TaskTemplate>>, String>((ref, query) {
  if (query.isEmpty) {
    return ref.watch(taskTemplatesProvider);
  }
  
  final templatesAsync = ref.watch(taskTemplatesProvider);
  return templatesAsync.when(
    data: (templates) {
      final searchResults = templates.where((template) {
        return template.name.toLowerCase().contains(query.toLowerCase()) ||
            (template.description?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            template.titleTemplate.toLowerCase().contains(query.toLowerCase()) ||
            (template.category?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
      return AsyncValue.data(searchResults);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

/// Provider for recurring task templates
final recurringTaskTemplatesProvider = Provider<AsyncValue<List<TaskTemplate>>>((ref) {
  final templatesAsync = ref.watch(taskTemplatesProvider);
  return templatesAsync.when(
    data: (templates) {
      final recurringTemplates = templates
          .where((template) => template.isRecurring)
          .toList();
      return AsyncValue.data(recurringTemplates);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});