import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/domain/entities/project.dart';

void main() {
  group('Project', () {
    late DateTime testDate;
    late Project testProject;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      testProject = Project(
        id: 'project-1',
        name: 'Test Project',
        description: 'A test project',
        color: '#2196F3',
        createdAt: testDate,
        taskIds: const ['task-1', 'task-2'],
      );
    });

    group('constructor', () {
      test('should create Project with required fields', () {
        expect(testProject.id, 'project-1');
        expect(testProject.name, 'Test Project');
        expect(testProject.description, 'A test project');
        expect(testProject.color, '#2196F3');
        expect(testProject.createdAt, testDate);
        expect(testProject.taskIds, ['task-1', 'task-2']);
        expect(testProject.isArchived, false);
        expect(testProject.deadline, isNull);
      });

      test('should create Project with default values', () {
        final project = Project(
          id: 'id',
          name: 'name',
          color: '#FF0000',
          createdAt: testDate,
        );

        expect(project.description, isNull);
        expect(project.updatedAt, isNull);
        expect(project.taskIds, isEmpty);
        expect(project.isArchived, false);
        expect(project.deadline, isNull);
      });
    });

    group('factory create', () {
      test('should create Project with generated ID and current timestamp', () {
        final project = Project.create(
          name: 'New Project',
          description: 'Description',
          color: '#FF0000',
          deadline: testDate.add(const Duration(days: 30)),
        );

        expect(project.id, isNotEmpty);
        expect(project.name, 'New Project');
        expect(project.description, 'Description');
        expect(project.color, '#FF0000');
        expect(project.deadline, testDate.add(const Duration(days: 30)));
        expect(project.createdAt, isA<DateTime>());
        expect(project.taskIds, isEmpty);
        expect(project.isArchived, false);
      });

      test('should create Project with default color', () {
        final project = Project.create(name: 'Test');
        expect(project.color, '#2196F3');
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final json = testProject.toJson();

        expect(json['id'], 'project-1');
        expect(json['name'], 'Test Project');
        expect(json['description'], 'A test project');
        expect(json['color'], '#2196F3');
        expect(json['createdAt'], testDate.toIso8601String());
        expect(json['taskIds'], ['task-1', 'task-2']);
        expect(json['isArchived'], false);
        expect(json['deadline'], isNull);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'project-1',
          'name': 'Test Project',
          'description': 'A test project',
          'color': '#2196F3',
          'createdAt': testDate.toIso8601String(),
          'taskIds': ['task-1', 'task-2'],
          'isArchived': false,
          'deadline': null,
        };

        final project = Project.fromJson(json);

        expect(project.id, 'project-1');
        expect(project.name, 'Test Project');
        expect(project.description, 'A test project');
        expect(project.color, '#2196F3');
        expect(project.createdAt, testDate);
        expect(project.taskIds, ['task-1', 'task-2']);
        expect(project.isArchived, false);
        expect(project.deadline, isNull);
      });

      test('should handle project with deadline in JSON', () {
        final deadline = testDate.add(const Duration(days: 30));
        final projectWithDeadline = testProject.copyWith(deadline: deadline);

        final json = projectWithDeadline.toJson();
        expect(json['deadline'], deadline.toIso8601String());

        final deserialized = Project.fromJson(json);
        expect(deserialized.deadline, deadline);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final updatedProject = testProject.copyWith(
          name: 'Updated Project',
          color: '#FF0000',
          isArchived: true,
        );

        expect(updatedProject.id, testProject.id);
        expect(updatedProject.name, 'Updated Project');
        expect(updatedProject.color, '#FF0000');
        expect(updatedProject.isArchived, true);
        expect(updatedProject.description, testProject.description);
        expect(updatedProject.createdAt, testProject.createdAt);
      });

      test('should preserve original values when no updates provided', () {
        final copiedProject = testProject.copyWith();
        expect(copiedProject, equals(testProject));
      });
    });

    group('addTask', () {
      test('should add task ID to project', () {
        final updatedProject = testProject.addTask('task-3');

        expect(updatedProject.taskIds, contains('task-3'));
        expect(updatedProject.taskIds.length, 3);
        expect(updatedProject.updatedAt, isA<DateTime>());
      });

      test('should not add duplicate task ID', () {
        final updatedProject = testProject.addTask('task-1');

        expect(updatedProject.taskIds.length, 2);
        expect(updatedProject, equals(testProject));
      });
    });

    group('removeTask', () {
      test('should remove task ID from project', () {
        final updatedProject = testProject.removeTask('task-1');

        expect(updatedProject.taskIds, isNot(contains('task-1')));
        expect(updatedProject.taskIds.length, 1);
        expect(updatedProject.updatedAt, isA<DateTime>());
      });

      test('should not change project if task ID not found', () {
        final updatedProject = testProject.removeTask('non-existent');

        expect(updatedProject.taskIds.length, 2);
        expect(updatedProject, equals(testProject));
      });
    });

    group('archive and unarchive', () {
      test('should archive project', () {
        final archivedProject = testProject.archive();

        expect(archivedProject.isArchived, true);
        expect(archivedProject.updatedAt, isA<DateTime>());
      });

      test('should unarchive project', () {
        final archivedProject = testProject.archive();
        final unarchivedProject = archivedProject.unarchive();

        expect(unarchivedProject.isArchived, false);
        expect(unarchivedProject.updatedAt, isA<DateTime>());
      });
    });

    group('update', () {
      test('should update project fields', () {
        final deadline = testDate.add(const Duration(days: 30));
        final updatedProject = testProject.update(
          name: 'Updated Name',
          description: 'Updated Description',
          color: '#FF0000',
          deadline: deadline,
        );

        expect(updatedProject.name, 'Updated Name');
        expect(updatedProject.description, 'Updated Description');
        expect(updatedProject.color, '#FF0000');
        expect(updatedProject.deadline, deadline);
        expect(updatedProject.updatedAt, isA<DateTime>());
      });

      test('should preserve existing values when not updated', () {
        final updatedProject = testProject.update(name: 'New Name');

        expect(updatedProject.name, 'New Name');
        expect(updatedProject.description, testProject.description);
        expect(updatedProject.color, testProject.color);
        expect(updatedProject.deadline, testProject.deadline);
      });
    });

    group('isValid', () {
      test('should return true for valid project', () {
        expect(testProject.isValid(), true);
      });

      test('should return false for empty id', () {
        final invalidProject = testProject.copyWith(id: '');
        expect(invalidProject.isValid(), false);
      });

      test('should return false for empty name', () {
        final invalidProject = testProject.copyWith(name: '');
        expect(invalidProject.isValid(), false);
      });

      test('should return false for whitespace-only name', () {
        final invalidProject = testProject.copyWith(name: '   ');
        expect(invalidProject.isValid(), false);
      });

      test('should return false for invalid color format', () {
        final invalidProject = testProject.copyWith(color: 'invalid-color');
        expect(invalidProject.isValid(), false);
      });

      test('should return false for past deadline', () {
        final pastDeadline = testDate.subtract(const Duration(days: 1));
        final invalidProject = testProject.copyWith(deadline: pastDeadline);
        expect(invalidProject.isValid(), false);
      });

      test('should return true for future deadline', () {
        final futureDeadline = DateTime.now().add(const Duration(days: 1));
        final validProject = testProject.copyWith(deadline: futureDeadline);
        expect(validProject.isValid(), true);
      });
    });

    group('getters', () {
      test('hasDeadline should return correct value', () {
        expect(testProject.hasDeadline, false);

        final projectWithDeadline = testProject.copyWith(
          deadline: testDate.add(const Duration(days: 30)),
        );
        expect(projectWithDeadline.hasDeadline, true);
      });

      test('isOverdue should return correct value', () {
        expect(testProject.isOverdue, false);

        final overdueProject = testProject.copyWith(
          deadline: testDate.subtract(const Duration(days: 1)),
        );
        expect(overdueProject.isOverdue, true);

        final futureProject = testProject.copyWith(
          deadline: DateTime.now().add(const Duration(days: 1)),
        );
        expect(futureProject.isOverdue, false);
      });

      test('taskCount should return correct count', () {
        expect(testProject.taskCount, 2);

        final emptyProject = testProject.copyWith(taskIds: []);
        expect(emptyProject.taskCount, 0);
      });

      test('isEmpty should return correct value', () {
        expect(testProject.isEmpty, false);

        final emptyProject = testProject.copyWith(taskIds: []);
        expect(emptyProject.isEmpty, true);
      });

      test('isActive should return correct value', () {
        expect(testProject.isActive, true);

        final archivedProject = testProject.archive();
        expect(archivedProject.isActive, false);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final project1 = Project(
          id: 'id',
          name: 'name',
          color: '#FF0000',
          createdAt: testDate,
        );

        final project2 = Project(
          id: 'id',
          name: 'name',
          color: '#FF0000',
          createdAt: testDate,
        );

        expect(project1, equals(project2));
        expect(project1.hashCode, equals(project2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final project1 = testProject;
        final project2 = testProject.copyWith(name: 'Different Name');

        expect(project1, isNot(equals(project2)));
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        final string = testProject.toString();

        expect(string, contains('Project'));
        expect(string, contains('project-1'));
        expect(string, contains('Test Project'));
        expect(string, contains('2')); // task count
        expect(string, contains('false')); // isArchived
      });
    });

    // ============================================================================
    // NEW MIGRATION SYSTEM TESTS
    // ============================================================================

    group('Category Migration System', () {
      late Project legacyProject;
      late Project newSystemProject;
      late Project mixedProject;

      setUp(() {
        legacyProject = Project(
          id: 'legacy-1',
          name: 'Legacy Project',
          color: '#2196F3',
          category: 'Work Projects', // Legacy category string
          createdAt: testDate,
        );

        newSystemProject = Project(
          id: 'new-1',
          name: 'New System Project',
          color: '#4CAF50',
          categoryId: 'cat_work_001', // New category ID
          createdAt: testDate,
        );

        mixedProject = Project(
          id: 'mixed-1',
          name: 'Mixed Project',
          color: '#FF9800',
          category: 'Personal',
          categoryId: 'cat_personal_001',
          createdAt: testDate,
        );
      });

      group('Category System Detection', () {
        test('hasCategory returns true for legacy category', () {
          expect(legacyProject.hasCategory, isTrue);
        });

        test('hasCategory returns true for new category', () {
          expect(newSystemProject.hasCategory, isTrue);
        });

        test('hasCategory returns false for no category', () {
          expect(testProject.hasCategory, isFalse);
        });

        test('usesNewCategorySystem returns correct values', () {
          expect(legacyProject.usesNewCategorySystem, isFalse);
          expect(newSystemProject.usesNewCategorySystem, isTrue);
          expect(mixedProject.usesNewCategorySystem, isTrue); // Prioritizes new system
          expect(testProject.usesNewCategorySystem, isFalse);
        });

        test('usesLegacyCategorySystem returns correct values', () {
          expect(legacyProject.usesLegacyCategorySystem, isTrue);
          expect(newSystemProject.usesLegacyCategorySystem, isFalse);
          expect(mixedProject.usesLegacyCategorySystem, isFalse); // New system takes precedence
          expect(testProject.usesLegacyCategorySystem, isFalse);
        });

        test('effectiveCategory returns prioritized category', () {
          expect(legacyProject.effectiveCategory, equals('Work Projects'));
          expect(newSystemProject.effectiveCategory, equals('cat_work_001'));
          expect(mixedProject.effectiveCategory, equals('cat_personal_001')); // New system priority
          expect(testProject.effectiveCategory, isNull);
        });
      });

      group('Migration Operations', () {
        test('migrateToNewCategorySystem migrates correctly', () {
          final migratedProject = legacyProject.migrateToNewCategorySystem('cat_work_001');

          expect(migratedProject.categoryId, equals('cat_work_001'));
          expect(migratedProject.category, isNull);
          expect(migratedProject.usesNewCategorySystem, isTrue);
          expect(migratedProject.usesLegacyCategorySystem, isFalse);
          expect(migratedProject.updatedAt, isNotNull);
          expect(migratedProject.id, equals(legacyProject.id)); // Preserves other fields
          expect(migratedProject.name, equals(legacyProject.name));
        });

        test('migrateToLegacyCategorySystem rolls back correctly', () {
          final rolledBackProject = newSystemProject.migrateToLegacyCategorySystem('Work');

          expect(rolledBackProject.categoryId, isNull);
          expect(rolledBackProject.category, equals('Work'));
          expect(rolledBackProject.usesNewCategorySystem, isFalse);
          expect(rolledBackProject.usesLegacyCategorySystem, isTrue);
          expect(rolledBackProject.updatedAt, isNotNull);
          expect(rolledBackProject.id, equals(newSystemProject.id)); // Preserves other fields
          expect(rolledBackProject.name, equals(newSystemProject.name));
        });

        test('migration preserves all other project data', () {
          final complexProject = Project(
            id: 'complex-1',
            name: 'Complex Project',
            description: 'A complex project with many properties',
            color: '#9C27B0',
            category: 'Development',
            createdAt: testDate,
            updatedAt: testDate.add(const Duration(hours: 1)),
            taskIds: const ['task1', 'task2', 'task3'],
            isArchived: false,
            deadline: testDate.add(const Duration(days: 30)),
          );

          final migrated = complexProject.migrateToNewCategorySystem('cat_dev_001');

          expect(migrated.id, equals(complexProject.id));
          expect(migrated.name, equals(complexProject.name));
          expect(migrated.description, equals(complexProject.description));
          expect(migrated.color, equals(complexProject.color));
          expect(migrated.createdAt, equals(complexProject.createdAt));
          expect(migrated.taskIds, equals(complexProject.taskIds));
          expect(migrated.isArchived, equals(complexProject.isArchived));
          expect(migrated.deadline, equals(complexProject.deadline));
        });
      });

      group('Mixed Category State Handling', () {
        test('mixed project prioritizes new system in effectiveCategory', () {
          expect(mixedProject.effectiveCategory, equals('cat_personal_001'));
        });

        test('mixed project reports using new system', () {
          expect(mixedProject.usesNewCategorySystem, isTrue);
          expect(mixedProject.usesLegacyCategorySystem, isFalse);
        });

        test('migration from mixed state clears legacy category', () {
          final cleanProject = mixedProject.migrateToNewCategorySystem('cat_personal_002');

          expect(cleanProject.categoryId, equals('cat_personal_002'));
          expect(cleanProject.category, isNull);
          expect(cleanProject.usesLegacyCategorySystem, isFalse);
        });
      });
    });

    // ============================================================================
    // ENHANCED VALIDATION TESTS
    // ============================================================================

    group('Enhanced Validation', () {
      test('isValid passes for project with new category system', () {
        final validProject = Project(
          id: 'valid-1',
          name: 'Valid Project',
          color: '#2196F3',
          categoryId: 'cat_work_001',
          createdAt: testDate,
          deadline: DateTime.now().add(const Duration(days: 30)),
        );

        expect(validProject.isValid(), isTrue);
      });

      test('isValid passes for project with legacy category', () {
        final validProject = Project(
          id: 'valid-1',
          name: 'Valid Project',
          color: '#2196F3',
          category: 'Work',
          createdAt: testDate,
        );

        expect(validProject.isValid(), isTrue);
      });

      test('isValid handles edge case color formats', () {
        // Valid lowercase hex
        final lowercaseProject = testProject.copyWith(color: '#2196f3');
        expect(lowercaseProject.isValid(), isTrue);

        // Valid uppercase hex
        final uppercaseProject = testProject.copyWith(color: '#2196F3');
        expect(uppercaseProject.isValid(), isTrue);

        // Invalid short hex
        final shortHexProject = testProject.copyWith(color: '#21F');
        expect(shortHexProject.isValid(), isFalse);

        // Invalid long hex
        final longHexProject = testProject.copyWith(color: '#2196F3AA');
        expect(longHexProject.isValid(), isFalse);

        // Invalid characters
        final invalidCharsProject = testProject.copyWith(color: '#21G6F3');
        expect(invalidCharsProject.isValid(), isFalse);
      });

      test('isValid correctly validates deadline timing', () {
        final now = DateTime.now();
        
        // Deadline exactly now should be valid
        final nowProject = testProject.copyWith(deadline: now);
        expect(nowProject.isValid(), isTrue);

        // Deadline 1 second in future should be valid  
        final futureProject = testProject.copyWith(
          deadline: now.add(const Duration(seconds: 1))
        );
        expect(futureProject.isValid(), isTrue);

        // Deadline 1 second in past should be invalid
        final pastProject = testProject.copyWith(
          deadline: now.subtract(const Duration(seconds: 1))
        );
        expect(pastProject.isValid(), isFalse);
      });
    });

    // ============================================================================
    // COMPREHENSIVE PROPERTY TESTS
    // ============================================================================

    group('Comprehensive Property Tests', () {
      test('hasDeadline with various deadline states', () {
        expect(testProject.hasDeadline, isFalse);

        final withDeadline = testProject.copyWith(deadline: testDate);
        expect(withDeadline.hasDeadline, isTrue);

        final explicitNullDeadline = testProject.copyWith();
        expect(explicitNullDeadline.hasDeadline, isFalse);
      });

      test('isOverdue with complex deadline scenarios', () {
        final now = DateTime.now();

        // No deadline - not overdue
        expect(testProject.isOverdue, isFalse);

        // Future deadline - not overdue
        final futureProject = testProject.copyWith(
          deadline: now.add(const Duration(hours: 1))
        );
        expect(futureProject.isOverdue, isFalse);

        // Past deadline - overdue
        final pastProject = testProject.copyWith(
          deadline: now.subtract(const Duration(hours: 1))
        );
        expect(pastProject.isOverdue, isTrue);

        // Deadline exactly now should be overdue (isBefore returns false for equal times)
        final exactNowProject = testProject.copyWith(deadline: now);
        // This might be false due to timing precision, but that's expected behavior
        expect(exactNowProject.isOverdue, isFalse);
      });

      test('taskCount with various task list scenarios', () {
        expect(testProject.taskCount, equals(2));

        final emptyProject = testProject.copyWith(taskIds: []);
        expect(emptyProject.taskCount, equals(0));

        final largeProject = testProject.copyWith(taskIds: List.generate(100, (i) => 'task-$i'));
        expect(largeProject.taskCount, equals(100));
      });

      test('isEmpty correctly identifies empty projects', () {
        expect(testProject.isEmpty, isFalse);

        final emptyProject = testProject.copyWith(taskIds: []);
        expect(emptyProject.isEmpty, isTrue);

        final singleTaskProject = testProject.copyWith(taskIds: ['single-task']);
        expect(singleTaskProject.isEmpty, isFalse);
      });

      test('isActive correctly identifies archived projects', () {
        expect(testProject.isActive, isTrue);

        final archivedProject = testProject.copyWith(isArchived: true);
        expect(archivedProject.isActive, isFalse);

        final explicitActiveProject = testProject.copyWith(isArchived: false);
        expect(explicitActiveProject.isActive, isTrue);
      });
    });

    // ============================================================================
    // TASK MANAGEMENT EDGE CASES
    // ============================================================================

    group('Task Management Edge Cases', () {
      test('addTask with empty task ID should work', () {
        final updatedProject = testProject.addTask('');
        expect(updatedProject.taskIds, contains(''));
        expect(updatedProject.taskIds.length, equals(3));
      });

      test('addTask preserves order', () {
        final project = testProject.copyWith(taskIds: ['task-a', 'task-b']);
        final updated = project.addTask('task-c');
        
        expect(updated.taskIds, equals(['task-a', 'task-b', 'task-c']));
      });

      test('removeTask with empty string', () {
        final projectWithEmpty = testProject.addTask('');
        final updated = projectWithEmpty.removeTask('');
        
        expect(updated.taskIds, equals(testProject.taskIds));
      });

      test('removeTask preserves remaining order', () {
        final project = testProject.copyWith(taskIds: ['task-a', 'task-b', 'task-c', 'task-d']);
        final updated = project.removeTask('task-b');
        
        expect(updated.taskIds, equals(['task-a', 'task-c', 'task-d']));
      });

      test('multiple task operations', () {
        final project = testProject
            .addTask('task-3')
            .addTask('task-4')
            .removeTask('task-1')
            .addTask('task-5');

        expect(project.taskIds, equals(['task-2', 'task-3', 'task-4', 'task-5']));
        expect(project.taskCount, equals(4));
      });
    });

    // ============================================================================
    // JSON SERIALIZATION EDGE CASES
    // ============================================================================

    group('JSON Serialization Edge Cases', () {
      test('serialization includes new category fields', () {
        final projectWithNewCategory = testProject.copyWith(
          categoryId: 'cat_work_001',
          category: 'Legacy Work', // Mixed state
        );

        final json = projectWithNewCategory.toJson();
        expect(json['categoryId'], equals('cat_work_001'));
        expect(json['category'], equals('Legacy Work'));
      });

      test('deserialization handles missing category fields', () {
        final jsonWithoutCategories = {
          'id': 'test-id',
          'name': 'Test Project',
          'color': '#2196F3',
          'createdAt': testDate.toIso8601String(),
          'taskIds': <String>[],
          'isArchived': false,
        };

        final project = Project.fromJson(jsonWithoutCategories);
        expect(project.categoryId, isNull);
        expect(project.category, isNull);
        expect(project.hasCategory, isFalse);
      });

      test('deserialization handles only new category', () {
        final jsonWithNewCategory = {
          'id': 'test-id',
          'name': 'Test Project',
          'color': '#2196F3',
          'categoryId': 'cat_work_001',
          'createdAt': testDate.toIso8601String(),
          'taskIds': <String>[],
          'isArchived': false,
        };

        final project = Project.fromJson(jsonWithNewCategory);
        expect(project.categoryId, equals('cat_work_001'));
        expect(project.category, isNull);
        expect(project.usesNewCategorySystem, isTrue);
      });

      test('deserialization handles only legacy category', () {
        final jsonWithLegacyCategory = {
          'id': 'test-id',
          'name': 'Test Project',
          'color': '#2196F3',
          'category': 'Work Projects',
          'createdAt': testDate.toIso8601String(),
          'taskIds': <String>[],
          'isArchived': false,
        };

        final project = Project.fromJson(jsonWithLegacyCategory);
        expect(project.categoryId, isNull);
        expect(project.category, equals('Work Projects'));
        expect(project.usesLegacyCategorySystem, isTrue);
      });

      test('JSON roundtrip preserves all data including categories', () {
        final originalProject = Project(
          id: 'roundtrip-test',
          name: 'Roundtrip Project',
          description: 'Testing roundtrip serialization',
          color: '#9C27B0',
          categoryId: 'cat_dev_001',
          category: 'Legacy Development', // Mixed state
          createdAt: testDate,
          updatedAt: testDate.add(const Duration(hours: 2)),
          taskIds: const ['task-1', 'task-2', 'task-3'],
          isArchived: false,
          deadline: testDate.add(const Duration(days: 14)),
        );

        final json = originalProject.toJson();
        final recreatedProject = Project.fromJson(json);
        final secondJson = recreatedProject.toJson();

        expect(secondJson, equals(json));
        expect(recreatedProject, equals(originalProject));
      });
    });

    // ============================================================================
    // COPYWITH COMPREHENSIVE TESTS
    // ============================================================================

    group('CopyWith Comprehensive Tests', () {
      test('copyWith can clear category fields', () {
        final projectWithCategories = testProject.copyWith(
          categoryId: 'cat_work_001',
          category: 'Work',
        );

        // Clear new category but keep legacy
        final clearedNew = projectWithCategories.copyWith(categoryId: null);
        expect(clearedNew.categoryId, isNull);
        expect(clearedNew.category, equals('Work'));

        // Clear legacy category but keep new
        final projectWithNew = testProject.copyWith(categoryId: 'cat_work_001');
        final clearedLegacy = projectWithNew.copyWith(category: null);
        expect(clearedLegacy.categoryId, equals('cat_work_001'));
        expect(clearedLegacy.category, isNull);
      });

      test('copyWith handles deadline changes', () {
        final originalDeadline = testDate.add(const Duration(days: 30));
        final newDeadline = testDate.add(const Duration(days: 60));

        final projectWithDeadline = testProject.copyWith(deadline: originalDeadline);
        expect(projectWithDeadline.deadline, equals(originalDeadline));

        final updatedDeadline = projectWithDeadline.copyWith(deadline: newDeadline);
        expect(updatedDeadline.deadline, equals(newDeadline));

        final clearedDeadline = updatedDeadline.copyWith(deadline: null);
        expect(clearedDeadline.deadline, isNull);
      });

      test('copyWith preserves immutability', () {
        final originalTaskIds = ['task-1', 'task-2'];
        final project = testProject.copyWith(taskIds: originalTaskIds);

        // Modifying the original list shouldn't affect the project
        originalTaskIds.add('task-3');
        expect(project.taskIds, equals(['task-1', 'task-2']));

        // The project should return a copy of its task list
        final retrievedTaskIds = project.taskIds;
        retrievedTaskIds.add('task-4'); // This should not affect the original project
        expect(project.taskIds, equals(['task-1', 'task-2'])); // Should remain unchanged
      });
    });

    // ============================================================================
    // STRESS AND EDGE CASE TESTS
    // ============================================================================

    group('Stress and Edge Case Tests', () {
      test('handles very long names and descriptions', () {
        final longName = 'A' * 1000;
        final longDescription = 'B' * 5000;

        final project = testProject.copyWith(
          name: longName,
          description: longDescription,
        );

        expect(project.name, equals(longName));
        expect(project.description, equals(longDescription));
        expect(project.isValid(), isTrue); // Should still be valid

        // JSON serialization should handle long strings
        final json = project.toJson();
        final recreated = Project.fromJson(json);
        expect(recreated.name, equals(longName));
        expect(recreated.description, equals(longDescription));
      });

      test('handles large number of tasks', () {
        final manyTaskIds = List.generate(10000, (i) => 'task-$i');
        final project = testProject.copyWith(taskIds: manyTaskIds);

        expect(project.taskCount, equals(10000));
        expect(project.isEmpty, isFalse);

        // Test task operations with large list
        final withNewTask = project.addTask('new-task');
        expect(withNewTask.taskCount, equals(10001));

        final withoutFirstTask = project.removeTask('task-0');
        expect(withoutFirstTask.taskCount, equals(9999));
        expect(withoutFirstTask.taskIds, isNot(contains('task-0')));
      });

      test('handles extreme dates', () {
        final veryOldDate = DateTime(1900, 1, 1);
        final veryFutureDate = DateTime(3000, 12, 31);

        final oldProject = testProject.copyWith(
          createdAt: veryOldDate,
          updatedAt: veryOldDate,
          deadline: veryFutureDate,
        );

        expect(oldProject.isValid(), isTrue);
        expect(oldProject.hasDeadline, isTrue);
        expect(oldProject.isOverdue, isFalse);

        // JSON serialization should handle extreme dates
        final json = oldProject.toJson();
        final recreated = Project.fromJson(json);
        expect(recreated.createdAt, equals(veryOldDate));
        expect(recreated.deadline, equals(veryFutureDate));
      });

      test('handles special characters in strings', () {
        const specialChars = 'Special chars: 💼📋✅🎯 émojis and ñoñ-ASCII 中文 العربية';
        
        final project = testProject.copyWith(
          name: 'Project with $specialChars',
          description: 'Description with $specialChars',
          category: 'Category with $specialChars',
        );

        expect(project.name, contains(specialChars));
        expect(project.description, contains(specialChars));
        expect(project.category, contains(specialChars));

        // JSON serialization should handle special characters
        final json = project.toJson();
        final recreated = Project.fromJson(json);
        expect(recreated.name, equals(project.name));
        expect(recreated.description, equals(project.description));
        expect(recreated.category, equals(project.category));
      });
    });
  });
}
