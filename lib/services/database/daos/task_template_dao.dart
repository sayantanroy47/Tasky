import 'dart:convert';

import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';
import '../../../domain/entities/task_template.dart' as domain;
import '../../../domain/entities/task_enums.dart';
import '../../../domain/entities/subtask.dart' as domain_subtask;
import '../../../domain/entities/recurrence_pattern.dart';

part 'task_template_dao.g.dart';

/// Data Access Object for TaskTemplate operations
@DriftAccessor(tables: [TaskTemplates])
class TaskTemplateDao extends DatabaseAccessor<AppDatabase> with _$TaskTemplateDaoMixin {
  TaskTemplateDao(super.db);

  /// Gets all task templates
  Future<List<domain.TaskTemplate>> getAllTemplates() async {
    final rows = await select(taskTemplates).get();
    return rows.map(_mapRowToTaskTemplate).toList();
  }

  /// Gets a task template by ID
  Future<domain.TaskTemplate?> getTemplateById(String id) async {
    final query = select(taskTemplates)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _mapRowToTaskTemplate(row) : null;
  }

  /// Creates a new task template
  Future<void> createTemplate(domain.TaskTemplate template) async {
    await into(taskTemplates).insert(_mapTaskTemplateToRow(template));
  }

  /// Updates an existing task template
  Future<void> updateTemplate(domain.TaskTemplate template) async {
    await (update(taskTemplates)..where((t) => t.id.equals(template.id)))
        .write(_mapTaskTemplateToRow(template));
  }

  /// Deletes a task template
  Future<void> deleteTemplate(String id) async {
    await (delete(taskTemplates)..where((t) => t.id.equals(id))).go();
  }

  /// Gets templates by category
  Future<List<domain.TaskTemplate>> getTemplatesByCategory(String category) async {
    final query = select(taskTemplates)..where((t) => t.category.equals(category));
    final rows = await query.get();
    return rows.map(_mapRowToTaskTemplate).toList();
  }

  /// Gets favorite templates
  Future<List<domain.TaskTemplate>> getFavoriteTemplates() async {
    final query = select(taskTemplates)
      ..where((t) => t.isFavorite.equals(true))
      ..orderBy([(t) => OrderingTerm(expression: t.usageCount, mode: OrderingMode.desc)]);
    final rows = await query.get();
    return rows.map(_mapRowToTaskTemplate).toList();
  }

  /// Gets most used templates
  Future<List<domain.TaskTemplate>> getMostUsedTemplates({int limit = 10}) async {
    final query = select(taskTemplates)
      ..orderBy([(t) => OrderingTerm(expression: t.usageCount, mode: OrderingMode.desc)])
      ..limit(limit);
    final rows = await query.get();
    return rows.map(_mapRowToTaskTemplate).toList();
  }

  /// Searches templates by name or description
  Future<List<domain.TaskTemplate>> searchTemplates(String searchQuery) async {
    final query = select(taskTemplates)
      ..where((t) => 
          t.name.like('%$searchQuery%') |
          t.description.like('%$searchQuery%') |
          t.titleTemplate.like('%$searchQuery%'))
      ..orderBy([(t) => OrderingTerm(expression: t.usageCount, mode: OrderingMode.desc)]);
    final rows = await query.get();
    return rows.map(_mapRowToTaskTemplate).toList();
  }

  /// Gets all unique categories
  Future<List<String>> getAllCategories() async {
    final query = selectOnly(taskTemplates)
      ..addColumns([taskTemplates.category])
      ..where(taskTemplates.category.isNotNull() & taskTemplates.category.isNotValue(''))
      ..groupBy([taskTemplates.category])
      ..orderBy([OrderingTerm(expression: taskTemplates.category)]);
    
    final rows = await query.get();
    return rows.map((row) => row.read(taskTemplates.category)!).toList();
  }

  /// Watches all templates (returns a stream)
  Stream<List<domain.TaskTemplate>> watchAllTemplates() {
    return select(taskTemplates).watch().map((rows) => 
        rows.map(_mapRowToTaskTemplate).toList());
  }

  /// Watches favorite templates
  Stream<List<domain.TaskTemplate>> watchFavoriteTemplates() {
    final query = select(taskTemplates)
      ..where((t) => t.isFavorite.equals(true))
      ..orderBy([(t) => OrderingTerm(expression: t.usageCount, mode: OrderingMode.desc)]);
    return query.watch().map((rows) => rows.map(_mapRowToTaskTemplate).toList());
  }

  /// Watches templates by category
  Stream<List<domain.TaskTemplate>> watchTemplatesByCategory(String category) {
    final query = select(taskTemplates)..where((t) => t.category.equals(category));
    return query.watch().map((rows) => rows.map(_mapRowToTaskTemplate).toList());
  }

  /// Maps a database row to a TaskTemplate
  domain.TaskTemplate _mapRowToTaskTemplate(TaskTemplate row) {
    // Parse recurrence pattern if present
    RecurrencePattern? recurrence;
    if (row.recurrenceType != null && row.recurrenceType != 0) {
      recurrence = RecurrencePattern(
        type: RecurrenceType.values[row.recurrenceType!],
        interval: row.recurrenceInterval ?? 1,
        daysOfWeek: row.recurrenceDaysOfWeek != null && row.recurrenceDaysOfWeek!.isNotEmpty
            ? List<int>.from(jsonDecode(row.recurrenceDaysOfWeek!))
            : null,
        endDate: row.recurrenceEndDate,
        maxOccurrences: row.recurrenceMaxOccurrences,
      );
    }

    return domain.TaskTemplate(
      id: row.id,
      name: row.name,
      description: row.description?.isEmpty == true ? null : row.description,
      titleTemplate: row.titleTemplate,
      descriptionTemplate: row.descriptionTemplate?.isEmpty == true ? null : row.descriptionTemplate,
      priority: TaskPriority.values[row.priority],
      tags: List<String>.from(jsonDecode(row.tags)),
      subTaskTemplates: (jsonDecode(row.subTaskTemplates) as List)
          .map((json) => domain_subtask.SubTask.fromJson(json))
          .toList(),
      locationTrigger: row.locationTrigger?.isEmpty == true ? null : row.locationTrigger,
      recurrence: recurrence,
      projectId: row.projectId?.isEmpty == true ? null : row.projectId,
      estimatedDuration: row.estimatedDuration,
      metadata: Map<String, dynamic>.from(jsonDecode(row.metadata)),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      usageCount: row.usageCount,
      isFavorite: row.isFavorite,
      category: row.category?.isEmpty == true ? null : row.category,
    );
  }

  /// Maps a TaskTemplate to a database row
  TaskTemplatesCompanion _mapTaskTemplateToRow(domain.TaskTemplate template) {
    return TaskTemplatesCompanion(
      id: Value(template.id),
      name: Value(template.name),
      description: Value(template.description ?? ''),
      titleTemplate: Value(template.titleTemplate),
      descriptionTemplate: Value(template.descriptionTemplate ?? ''),
      priority: Value(template.priority.index),
      tags: Value(jsonEncode(template.tags)),
      subTaskTemplates: Value(jsonEncode(template.subTaskTemplates.map((st) => st.toJson()).toList())),
      locationTrigger: Value(template.locationTrigger ?? ''),
      projectId: Value(template.projectId ?? ''),
      estimatedDuration: Value(template.estimatedDuration),
      metadata: Value(jsonEncode(template.metadata)),
      createdAt: Value(template.createdAt),
      updatedAt: Value(template.updatedAt),
      usageCount: Value(template.usageCount),
      isFavorite: Value(template.isFavorite),
      category: Value(template.category ?? ''),
      recurrenceType: Value(template.recurrence?.type.index),
      recurrenceInterval: Value(template.recurrence?.interval),
      recurrenceDaysOfWeek: Value(template.recurrence?.daysOfWeek != null 
          ? jsonEncode(template.recurrence!.daysOfWeek!) 
          : null),
      recurrenceEndDate: Value(template.recurrence?.endDate),
      recurrenceMaxOccurrences: Value(template.recurrence?.maxOccurrences),
    );
  }
}