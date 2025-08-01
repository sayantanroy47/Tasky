import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import 'daos/task_dao.dart';
import 'daos/project_dao.dart';
import 'daos/tag_dao.dart';
import 'daos/task_template_dao.dart';

part 'database.g.dart';

/// Main database class for the Task Tracker app
/// 
/// This class defines the database schema and provides access to all
/// Data Access Objects (DAOs) for database operations.
@DriftDatabase(tables: [
  Tasks,
  SubTasks,
  Tags,
  TaskTags,
  Projects,
  TaskDependencies,
  TaskTemplates,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  // Constructor for testing with custom executor
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  // DAOs
  late final TaskDao taskDao = TaskDao(this);
  late final ProjectDao projectDao = ProjectDao(this);
  late final TagDao tagDao = TagDao(this);
  late final TaskTemplateDao taskTemplateDao = TaskTemplateDao(this);

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle database migrations here when schema version changes
        if (from == 1 && to == 2) {
          // Add TaskTemplates table in version 2
          await m.createTable(taskTemplates);
        }
      },
      beforeOpen: (details) async {
        // Enable foreign key constraints
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Closes the database connection
  @override
  Future<void> close() async {
    await super.close();
  }

  /// Clears all data from the database (useful for testing)
  Future<void> clearAllData() async {
    await transaction(() async {
      // Delete in order to respect foreign key constraints
      await delete(taskTags).go();
      await delete(taskDependencies).go();
      await delete(subTasks).go();
      await delete(tasks).go();
      await delete(projects).go();
      await delete(tags).go();
    });
  }

  /// Gets database statistics
  Future<Map<String, int>> getDatabaseStats() async {
    final taskCount = await (select(tasks)..limit(1)).get().then((rows) => rows.length);
    final projectCount = await (select(projects)..limit(1)).get().then((rows) => rows.length);
    final tagCount = await (select(tags)..limit(1)).get().then((rows) => rows.length);
    
    return {
      'tasks': taskCount,
      'projects': projectCount,
      'tags': tagCount,
    };
  }
}

/// Opens a connection to the database
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'task_tracker.db'));
    
    return NativeDatabase.createInBackground(file);
  });
}
