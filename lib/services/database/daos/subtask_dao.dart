import 'package:drift/drift.dart';
import '../../../domain/entities/subtask.dart' as domain;
import '../database.dart';
import '../tables.dart';

part 'subtask_dao.g.dart';

/// Data Access Object for subtasks
@DriftAccessor(tables: [SubTasks])
class SubtaskDao extends DatabaseAccessor<AppDatabase> with _$SubtaskDaoMixin {
  SubtaskDao(super.database);

  /// Get all subtasks for a specific task, ordered by sort order
  Future<List<domain.SubTask>> getSubtasksForTask(String taskId) async {
    final query = select(subTasks)
      ..where((tbl) => tbl.taskId.equals(taskId))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]);

    final rows = await query.get();
    return rows.map(_convertToSubTask).toList().cast<domain.SubTask>();
  }

  /// Get a subtask by ID
  Future<domain.SubTask?> getSubtaskById(String subtaskId) async {
    final query = select(subTasks)
      ..where((tbl) => tbl.id.equals(subtaskId));

    final row = await query.getSingleOrNull();
    return row != null ? _convertToSubTask(row) : null;
  }

  /// Get all subtasks
  Future<List<domain.SubTask>> getAllSubtasks() async {
    final query = select(subTasks)
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]);

    final rows = await query.get();
    return rows.map(_convertToSubTask).toList().cast<domain.SubTask>();
  }

  /// Insert a new subtask
  Future<void> insertSubtask(domain.SubTask subtask) async {
    await into(subTasks).insert(_convertFromSubTask(subtask));
  }

  /// Update an existing subtask
  Future<void> updateSubtask(domain.SubTask subtask) async {
    await (update(subTasks)..where((tbl) => tbl.id.equals(subtask.id)))
        .write(_convertFromSubTask(subtask));
  }

  /// Delete a subtask
  Future<void> deleteSubtask(String subtaskId) async {
    await (delete(subTasks)..where((tbl) => tbl.id.equals(subtaskId))).go();
  }

  /// Delete all subtasks for a task
  Future<void> deleteSubtasksForTask(String taskId) async {
    await (delete(subTasks)..where((tbl) => tbl.taskId.equals(taskId))).go();
  }

  /// Reorder subtasks for a task
  Future<void> reorderSubtasks(String taskId, List<String> subtaskIds) async {
    await attachedDatabase.transaction(() async {
      for (int i = 0; i < subtaskIds.length; i++) {
        await (update(subTasks)
              ..where((tbl) => 
                  tbl.id.equals(subtaskIds[i]) & 
                  tbl.taskId.equals(taskId)))
            .write(SubTasksCompanion(sortOrder: Value(i)));
      }
    });
  }

  /// Get subtask count for a task
  Future<int> getSubtaskCount(String taskId) async {
    final countQuery = selectOnly(subTasks)
      ..addColumns([subTasks.id.count()])
      ..where(subTasks.taskId.equals(taskId));

    final result = await countQuery.getSingle();
    return result.read(subTasks.id.count()) ?? 0;
  }

  /// Get completed subtask count for a task
  Future<int> getCompletedSubtaskCount(String taskId) async {
    final countQuery = selectOnly(subTasks)
      ..addColumns([subTasks.id.count()])
      ..where(subTasks.taskId.equals(taskId) & subTasks.isCompleted.equals(true));

    final result = await countQuery.getSingle();
    return result.read(subTasks.id.count()) ?? 0;
  }

  /// Get subtask completion percentage for a task
  Future<double> getSubtaskCompletionPercentage(String taskId) async {
    final totalCount = await getSubtaskCount(taskId);
    if (totalCount == 0) return 0.0;

    final completedCount = await getCompletedSubtaskCount(taskId);
    return (completedCount / totalCount) * 100.0;
  }

  /// Mark all subtasks as completed for a task
  Future<void> markAllSubtasksCompleted(String taskId) async {
    await (update(subTasks)..where((tbl) => tbl.taskId.equals(taskId)))
        .write(SubTasksCompanion(
          isCompleted: const Value(true),
          completedAt: Value(DateTime.now()),
        ));
  }

  /// Mark all subtasks as incomplete for a task
  Future<void> markAllSubtasksIncomplete(String taskId) async {
    await (update(subTasks)..where((tbl) => tbl.taskId.equals(taskId)))
        .write(const SubTasksCompanion(
          isCompleted: Value(false),
          completedAt: Value(null),
        ));
  }

  /// Get the next sort order for a new subtask
  Future<int> getNextSortOrder(String taskId) async {
    final maxOrderQuery = selectOnly(subTasks)
      ..addColumns([subTasks.sortOrder.max()])
      ..where(subTasks.taskId.equals(taskId));

    final result = await maxOrderQuery.getSingleOrNull();
    final maxOrder = result?.read(subTasks.sortOrder.max());
    return (maxOrder ?? -1) + 1;
  }

  /// Convert database row to SubTask entity
  domain.SubTask _convertToSubTask(SubTask row) {
    return domain.SubTask(
      id: row.id,
      taskId: row.taskId,
      title: row.title,
      isCompleted: row.isCompleted,
      completedAt: row.completedAt,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
    );
  }

  /// Convert SubTask entity to database companion
  SubTasksCompanion _convertFromSubTask(domain.SubTask subtask) {
    return SubTasksCompanion(
      id: Value(subtask.id),
      taskId: Value(subtask.taskId),
      title: Value(subtask.title),
      isCompleted: Value(subtask.isCompleted),
      completedAt: Value(subtask.completedAt),
      sortOrder: Value(subtask.sortOrder),
      createdAt: Value(subtask.createdAt),
    );
  }

  /// Watch subtasks for a task (real-time updates)
  Stream<List<domain.SubTask>> watchSubtasksForTask(String taskId) {
    final query = select(subTasks)
      ..where((tbl) => tbl.taskId.equals(taskId))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]);

    return query.watch().map((rows) => rows.map(_convertToSubTask).toList().cast<domain.SubTask>());
  }

  /// Watch subtask completion percentage for a task
  Stream<double> watchSubtaskCompletionPercentage(String taskId) {
    return watchSubtasksForTask(taskId).map((subtasks) {
      if (subtasks.isEmpty) return 0.0;
      final completedCount = subtasks.where((s) => s.isCompleted).length;
      return (completedCount / subtasks.length) * 100.0;
    });
  }
}