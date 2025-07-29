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
        taskIds: ['task-1', 'task-2'],
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
  });
}