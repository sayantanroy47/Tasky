import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../domain/repositories/task_template_repository.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/repositories/cached_task_repository_impl.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../data/repositories/tag_repository_impl.dart';
import '../../data/repositories/task_template_repository_impl.dart';
import '../../data/datasources/local/task_template_local_datasource.dart';
import '../../services/database/database.dart';

/// Centralized core providers for database and repositories
/// 
/// This file consolidates all database and repository providers to prevent
/// duplication and ensure consistent behavior across the app.

/// Singleton database provider with proper resource management
/// 
/// This is the single source of truth for the app database.
/// It implements proper cleanup to prevent memory leaks.
final databaseProvider = Provider<AppDatabase>((ref) {
  // Keep alive to ensure singleton behavior across the app
  ref.keepAlive();
  
  final database = AppDatabase();
  
  // Proper cleanup on disposal to prevent memory leaks
  ref.onDispose(() async {
    await database.close();
  });
  
  return database;
});

/// Primary task repository provider with caching
/// 
/// Uses CachedTaskRepositoryImpl for better performance with automatic caching.
/// This should be the primary repository used throughout the app.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return CachedTaskRepositoryImpl(database);
});

/// Base task repository provider without caching
/// 
/// Provides direct database access without caching layer.
/// Use this only when you need to bypass caching (e.g., for testing or direct operations).
final baseTaskRepositoryProvider = Provider<TaskRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return TaskRepositoryImpl(database);
});

/// Project repository provider
/// 
/// Handles all project-related database operations.
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return ProjectRepositoryImpl(database);
});

/// Tag repository provider
/// 
/// Handles all tag-related database operations.
final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return TagRepositoryImpl(database);
});

/// Task template local datasource provider
/// 
/// Provides local data source for task templates.
final taskTemplateLocalDataSourceProvider = Provider<TaskTemplateLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return TaskTemplateLocalDataSource(database);
});

/// Task template repository provider
/// 
/// Handles all task template-related database operations.
final taskTemplateRepositoryProvider = Provider<TaskTemplateRepository>((ref) {
  final datasource = ref.watch(taskTemplateLocalDataSourceProvider);
  return TaskTemplateRepositoryImpl(datasource);
});