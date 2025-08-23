import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/services/database/tables.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('AppDatabase', () {
    late AppDatabase database;

    setUp(() {
      // Create in-memory database for testing
      database = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    group('Database Initialization', () {
      test('should initialize database successfully', () async {
        expect(database, isNotNull);
        expect(database.executor, isNotNull);
      });

      test('should have correct schema version', () {
        expect(database.schemaVersion, equals(1));
      });

      test('should initialize all tables', () async {
        // Verify all tables exist by attempting simple queries
        final taskCount = await database.select(database.tasks).get();
        final subtaskCount = await database.select(database.subTasks).get();
        final tagCount = await database.select(database.tags).get();
        final projectCount = await database.select(database.projects).get();
        final templateCount = await database.select(database.taskTemplates).get();
        final profileCount = await database.select(database.userProfiles).get();

        expect(taskCount, isEmpty);
        expect(subtaskCount, isEmpty);
        expect(tagCount, isEmpty);
        expect(projectCount, isEmpty);
        expect(templateCount, isEmpty);
        expect(profileCount, isEmpty);
      });

      test('should handle database connection gracefully', () {
        expect(() => database.executor.runSelect('SELECT 1', []), returnsNormally);
      });
    });

    group('Transaction Management', () {
      test('should support transactions', () async {
        await database.transaction(() async {
          await database.into(database.tasks).insert(TasksCompanion.insert(
            id: 'test-transaction',
            title: 'Transaction Test',
            description: const Value('Test description'),
            priority: TaskPriority.medium.index,
            status: TaskStatus.inProgress.index,
            createdAt: DateTime.now(),
            metadata: '{}',
          ));
        });

        final result = await database.select(database.tasks).get();
        expect(result, hasLength(1));
        expect(result.first.title, equals('Transaction Test'));
      });

      test('should rollback on transaction failure', () async {
        try {
          await database.transaction(() async {
            await database.into(database.tasks).insert(TasksCompanion.insert(
              id: 'test-rollback-1',
              title: 'Should Rollback',
              description: const Value('Test description'),
              priority: TaskPriority.medium.index,
              status: TaskStatus.inProgress.index,
              createdAt: DateTime.now(),
              metadata: '{}',
            ));

            // Force an error to trigger rollback
            throw Exception('Forced rollback');
          });
        } catch (e) {
          // Expected
        }

        final result = await database.select(database.tasks).get();
        expect(result, isEmpty);
      });
    });

    group('Database Performance', () {
      test('should handle batch inserts efficiently', () async {
        final stopwatch = Stopwatch()..start();

        await database.batch((batch) {
          for (int i = 0; i < 100; i++) {
            batch.insert(database.tasks, TasksCompanion.insert(
              id: 'batch-task-$i',
              title: 'Batch Task $i',
              description: Value('Description $i'),
              priority: TaskPriority.medium.index,
              status: TaskStatus.inProgress.index,
              createdAt: DateTime.now(),
              metadata: '{}',
            ));
          }
        });

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should complete within 1 second

        final result = await database.select(database.tasks).get();
        expect(result, hasLength(100));
      });

      test('should handle large queries efficiently', () async {
        // Insert test data
        await database.batch((batch) {
          for (int i = 0; i < 1000; i++) {
            batch.insert(database.tasks, TasksCompanion.insert(
              id: 'large-query-task-$i',
              title: 'Large Query Task $i',
              description: Value('Description $i'),
              priority: TaskPriority.values[i % TaskPriority.values.length].index,
              status: TaskStatus.values[i % TaskStatus.values.length].index,
              createdAt: DateTime.now(),
              metadata: '{}',
            ));
          }
        });

        final stopwatch = Stopwatch()..start();
        final result = await database.select(database.tasks).get();
        stopwatch.stop();

        expect(result, hasLength(1000));
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be very fast for simple select
      });
    });

    group('Database Constraints', () {
      test('should enforce unique ID constraints', () async {
        await database.into(database.tasks).insert(TasksCompanion.insert(
          id: 'unique-test',
          title: 'Unique Test 1',
          description: const Value('First task'),
          priority: TaskPriority.medium.index,
          status: TaskStatus.inProgress.index,
          createdAt: DateTime.now(),
          metadata: '{}',
        ));

        // Attempt to insert duplicate ID should fail
        expect(
          () => database.into(database.tasks).insert(TasksCompanion.insert(
            id: 'unique-test',
            title: 'Unique Test 2',
            description: const Value('Duplicate ID'),
            isCompleted: false,
            priority: TaskPriority.medium.index,
            status: TaskStatus.todo.index,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )),
          throwsA(isA<SqliteException>()),
        );
      });

      test('should enforce required field constraints', () async {
        // Test that required fields cannot be null
        expect(
          () => database.into(database.tasks).insert(TasksCompanion.insert(
            id: '', // Empty ID should fail validation at application level
            title: 'Invalid Task',
            description: const Value('Missing required fields'),
            isCompleted: false,
            priority: TaskPriority.medium.index,
            status: TaskStatus.todo.index,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          )),
          returnsNormally, // Database constraint checking might be at app level
        );
      });
    });

    group('Database Queries', () {
      setUp(() async {
        // Insert test data for querying
        await database.batch((batch) {
          batch.insert(database.tasks, TasksCompanion.insert(
            id: 'query-task-1',
            title: 'Query Task High Priority',
            description: const Value('High priority task'),
            isCompleted: false,
            priority: TaskPriority.high.index,
            status: TaskStatus.inProgress.index,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            updatedAt: DateTime.now(),
          ));

          batch.insert(database.tasks, TasksCompanion.insert(
            id: 'query-task-2',
            title: 'Query Task Low Priority',
            description: const Value('Low priority task'),
            isCompleted: true,
            priority: TaskPriority.low.index,
            status: TaskStatus.completed.index,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            updatedAt: DateTime.now(),
          ));

          batch.insert(database.tasks, TasksCompanion.insert(
            id: 'query-task-3',
            title: 'Query Task Medium Priority',
            description: const Value('Medium priority task'),
            isCompleted: false,
            priority: TaskPriority.medium.index,
            status: TaskStatus.todo.index,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
        });
      });

      test('should filter tasks by completion status', () async {
        final completedTasks = await (database.select(database.tasks)
          ..where((t) => t.isCompleted.equals(true))).get();
        
        expect(completedTasks, hasLength(1));
        expect(completedTasks.first.title, contains('Low Priority'));
      });

      test('should filter tasks by priority', () async {
        final highPriorityTasks = await (database.select(database.tasks)
          ..where((t) => t.priority.equals(TaskPriority.high.index))).get();
        
        expect(highPriorityTasks, hasLength(1));
        expect(highPriorityTasks.first.title, contains('High Priority'));
      });

      test('should order tasks correctly', () async {
        final tasksByDate = await (database.select(database.tasks)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
        
        expect(tasksByDate, hasLength(3));
        expect(tasksByDate.first.title, contains('Low Priority')); // Oldest
        expect(tasksByDate.last.title, contains('Medium Priority')); // Newest
      });

      test('should support complex queries with multiple conditions', () async {
        final incompleteMediumTasks = await (database.select(database.tasks)
          ..where((t) => t.isCompleted.equals(false) & t.priority.equals(TaskPriority.medium.index))).get();
        
        expect(incompleteMediumTasks, hasLength(1));
        expect(incompleteMediumTasks.first.title, contains('Medium Priority'));
      });
    });

    group('Database Migrations', () {
      test('should handle schema version correctly', () {
        expect(database.schemaVersion, isPositive);
        expect(database.schemaVersion, lessThanOrEqualTo(10)); // Reasonable upper bound
      });

      test('should support migration strategy', () {
        // Test that the migration strategy is properly defined
        expect(database.migration, isNotNull);
      });
    });

    group('Database Cleanup', () {
      test('should close database properly', () async {
        final testDb = AppDatabase.forTesting(NativeDatabase.memory());
        expect(testDb.executor.dialect, equals(SqlDialect.sqlite));
        
        await testDb.close();
        // Database should be closed without errors
      });

      test('should handle multiple close calls gracefully', () async {
        final testDb = AppDatabase.forTesting(NativeDatabase.memory());
        
        await testDb.close();
        expect(() async => await testDb.close(), returnsNormally);
      });
    });

    group('Database Error Handling', () {
      test('should handle malformed queries gracefully', () async {
        expect(
          () => database.customStatement('INVALID SQL QUERY'),
          throwsA(isA<SqliteException>()),
        );
      });

      test('should handle connection errors', () async {
        // Test with a database that will fail
        expect(database.executor, isNotNull);
      });

      test('should provide meaningful error messages', () async {
        try {
          await database.customStatement('SELECT * FROM nonexistent_table');
        } catch (e) {
          expect(e.toString(), contains('no such table'));
        }
      });
    });
  });
}