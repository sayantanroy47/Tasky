import 'dart:io';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import 'daos/task_dao.dart';
import 'daos/subtask_dao.dart';
import 'daos/project_dao.dart';
import 'daos/tag_dao.dart';
import 'daos/task_template_dao.dart';
import 'daos/user_profile_dao.dart';

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
  UserProfiles,
])
class AppDatabase extends _$AppDatabase {
  static AppDatabase? _instance;
  static bool _isInitializing = false;
  
  AppDatabase._internal() : super(_openConnection());
  
  // Constructor for testing with custom executor
  AppDatabase.forTesting(super.executor);
  
  /// Singleton instance getter
  static AppDatabase get instance {
    if (_instance == null && !_isInitializing) {
      _isInitializing = true;
      _instance = AppDatabase._internal();
      _isInitializing = false;
    }
    return _instance!;
  }
  
  /// Factory constructor for creating the database instance
  factory AppDatabase() => instance;  @override
  int get schemaVersion => 3;

  // DAOs
  late final TaskDao taskDao = TaskDao(this);
  late final SubtaskDao subtaskDao = SubtaskDao(this);
  late final ProjectDao projectDao = ProjectDao(this);
  late final TagDao tagDao = TagDao(this);
  late final TaskTemplateDao taskTemplateDao = TaskTemplateDao(this);
  late final UserProfileDao userProfileDao = UserProfileDao(this);  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        try {
          await m.createAll();
          developer.log('Database created successfully with schema version $schemaVersion', name: 'AppDatabase');
        } catch (e) {
          developer.log('Error creating database: $e', name: 'AppDatabase', level: 1000);
          rethrow;
        }
      },
      onUpgrade: (Migrator m, int from, int to) async {
        developer.log('Migrating database from version $from to $to', name: 'AppDatabase');
        
        try {
          // Create a transaction for all migrations to ensure atomicity
          await transaction(() async {
            // Migration from version 1 to 2
            if (from <= 1 && to >= 2) {
              developer.log('Adding TaskTemplates table (v1 -> v2)', name: 'AppDatabase');
              await m.createTable(taskTemplates);
            }

            // Migration from version 2 to 3
            if (from <= 2 && to >= 3) {
              developer.log('Adding UserProfiles table (v2 -> v3)', name: 'AppDatabase');
              await m.createTable(userProfiles);
            }
            
            // Add indexes for performance optimization
            await _createIndexes();
          });
          
          developer.log('Database migration completed successfully', name: 'AppDatabase');
        } catch (e) {
          developer.log('Error during database migration from $from to $to: $e', name: 'AppDatabase', level: 1000);
          rethrow;
        }
      },
      beforeOpen: (details) async {
        try {
          // Enable foreign key constraints
          await customStatement('PRAGMA foreign_keys = ON');
          
          // Set WAL mode for better concurrency
          await customStatement('PRAGMA journal_mode = WAL');
          
          // Optimize SQLite settings
          await customStatement('PRAGMA synchronous = NORMAL');
          await customStatement('PRAGMA cache_size = 10000');
          await customStatement('PRAGMA temp_store = MEMORY');
          
          developer.log('Database opened successfully with optimized settings', name: 'AppDatabase');
        } catch (e) {
          developer.log('Error configuring database: $e', name: 'AppDatabase', level: 1000);
          rethrow;
        }
      },
    );
  }

  /// Creates database indexes for better query performance
  Future<void> _createIndexes() async {
    try {
      // Indexes for tasks table
      await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_priority ON tasks(priority)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_project_id ON tasks(project_id)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON tasks(created_at)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_updated_at ON tasks(updated_at)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_is_pinned ON tasks(is_pinned)');
      
      // Composite indexes for common queries
      await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_status_priority ON tasks(status, priority)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_project_status ON tasks(project_id, status)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_due_date_status ON tasks(due_date, status)');

      // Indexes for subtasks table
      await customStatement('CREATE INDEX IF NOT EXISTS idx_subtasks_task_id ON sub_tasks(task_id)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_subtasks_is_completed ON sub_tasks(is_completed)');

      // Indexes for task_tags junction table
      await customStatement('CREATE INDEX IF NOT EXISTS idx_task_tags_task_id ON task_tags(task_id)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_task_tags_tag_id ON task_tags(tag_id)');

      // Indexes for task_dependencies table
      await customStatement('CREATE INDEX IF NOT EXISTS idx_task_deps_dependent ON task_dependencies(dependent_task_id)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_task_deps_prerequisite ON task_dependencies(prerequisite_task_id)');

      // Indexes for tags table
      await customStatement('CREATE INDEX IF NOT EXISTS idx_tags_name ON tags(name)');

      developer.log('Database indexes created successfully', name: 'AppDatabase');
    } catch (e) {
      developer.log('Error creating database indexes: $e', name: 'AppDatabase', level: 1000);
      // Don't rethrow - indexes are optional for functionality
    }
  }

  /// Closes the database connection  @override
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
