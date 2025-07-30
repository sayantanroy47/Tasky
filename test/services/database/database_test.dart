import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/services/database/daos/tag_dao.dart' as dao;
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/domain/entities/project.dart' as domain;
import 'package:task_tracker_app/domain/entities/subtask.dart' as domain;
import 'package:task_tracker_app/domain/entities/recurrence_pattern.dart';

void main() {
  group('Database Integration Tests', () {
    late AppDatabase database;

    setUp(() async {
      // Create an in-memory database for testing
      database = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    group('TaskDao', () {
      test('should create and retrieve a simple task', () async {
        final task = TaskModel.create(
          title: 'Test Task',
          description: 'A test task description',
          priority: TaskPriority.high,
        );

        await database.taskDao.createTask(task);
        final retrievedTask = await database.taskDao.getTaskById(task.id);

        expect(retrievedTask, isNotNull);
        expect(retrievedTask!.id, task.id);
        expect(retrievedTask.title, task.title);
        expect(retrievedTask.description, task.description);
        expect(retrievedTask.priority, task.priority);
        expect(retrievedTask.status, TaskStatus.pending);
      });

      test('should create and retrieve a task with subtasks', () async {
        final subTask1 = domain.SubTask.create(taskId: 'task-1', title: 'Subtask 1');
        final subTask2 = domain.SubTask.create(taskId: 'task-1', title: 'Subtask 2');
        
        final task = TaskModel(
          id: 'task-1',
          title: 'Task with Subtasks',
          createdAt: DateTime.now(),
          subTasks: [subTask1, subTask2],
        );

        await database.taskDao.createTask(task);
        final retrievedTask = await database.taskDao.getTaskById(task.id);

        expect(retrievedTask, isNotNull);
        expect(retrievedTask!.subTasks.length, 2);
        expect(retrievedTask.subTasks[0].title, 'Subtask 1');
        expect(retrievedTask.subTasks[1].title, 'Subtask 2');
      });

      test('should create and retrieve a task with recurrence pattern', () async {
        final recurrence = RecurrencePattern.daily(interval: 2);
        final task = TaskModel.create(
          title: 'Recurring Task',
          recurrence: recurrence,
        );

        await database.taskDao.createTask(task);
        final retrievedTask = await database.taskDao.getTaskById(task.id);

        expect(retrievedTask, isNotNull);
        expect(retrievedTask!.recurrence, isNotNull);
        expect(retrievedTask.recurrence!.type, RecurrenceType.daily);
        expect(retrievedTask.recurrence!.interval, 2);
      });

      test('should update a task', () async {
        final task = TaskModel.create(title: 'Original Title');
        await database.taskDao.createTask(task);

        final updatedTask = task.copyWith(
          title: 'Updated Title',
          status: TaskStatus.completed,
        );
        await database.taskDao.updateTask(updatedTask);

        final retrievedTask = await database.taskDao.getTaskById(task.id);
        expect(retrievedTask!.title, 'Updated Title');
        expect(retrievedTask.status, TaskStatus.completed);
      });

      test('should delete a task', () async {
        final task = TaskModel.create(title: 'Task to Delete');
        await database.taskDao.createTask(task);

        await database.taskDao.deleteTask(task.id);
        final retrievedTask = await database.taskDao.getTaskById(task.id);

        expect(retrievedTask, isNull);
      });

      test('should get tasks by status', () async {
        final task1 = TaskModel.create(title: 'Pending Task');
        final task2 = TaskModel.create(title: 'Completed Task').markCompleted();

        await database.taskDao.createTask(task1);
        await database.taskDao.createTask(task2);

        final pendingTasks = await database.taskDao.getTasksByStatus(TaskStatus.pending);
        final completedTasks = await database.taskDao.getTasksByStatus(TaskStatus.completed);

        expect(pendingTasks.length, 1);
        expect(pendingTasks.first.title, 'Pending Task');
        expect(completedTasks.length, 1);
        expect(completedTasks.first.title, 'Completed Task');
      });

      test('should get tasks by priority', () async {
        final highTask = TaskModel.create(title: 'High Priority', priority: TaskPriority.high);
        final lowTask = TaskModel.create(title: 'Low Priority', priority: TaskPriority.low);

        await database.taskDao.createTask(highTask);
        await database.taskDao.createTask(lowTask);

        final highPriorityTasks = await database.taskDao.getTasksByPriority(TaskPriority.high);
        final lowPriorityTasks = await database.taskDao.getTasksByPriority(TaskPriority.low);

        expect(highPriorityTasks.length, 1);
        expect(highPriorityTasks.first.title, 'High Priority');
        expect(lowPriorityTasks.length, 1);
        expect(lowPriorityTasks.first.title, 'Low Priority');
      });

      test('should get overdue tasks', () async {
        final overdueTask = TaskModel.create(
          title: 'Overdue Task',
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
        );
        final futureTask = TaskModel.create(
          title: 'Future Task',
          dueDate: DateTime.now().add(const Duration(days: 1)),
        );

        await database.taskDao.createTask(overdueTask);
        await database.taskDao.createTask(futureTask);

        final overdueTasks = await database.taskDao.getOverdueTasks();

        expect(overdueTasks.length, 1);
        expect(overdueTasks.first.title, 'Overdue Task');
      });

      test('should search tasks', () async {
        final task1 = TaskModel.create(title: 'Important Meeting', description: 'Discuss project');
        final task2 = TaskModel.create(title: 'Buy Groceries', description: 'Milk, bread, eggs');
        final task3 = TaskModel.create(title: 'Project Review', description: 'Review code');

        await database.taskDao.createTask(task1);
        await database.taskDao.createTask(task2);
        await database.taskDao.createTask(task3);

        final projectTasks = await database.taskDao.searchTasks('project');
        final meetingTasks = await database.taskDao.searchTasks('Meeting');

        expect(projectTasks.length, 2); // 'Important Meeting' and 'Project Review'
        expect(meetingTasks.length, 1);
        expect(meetingTasks.first.title, 'Important Meeting');
      });
    });

    group('ProjectDao', () {
      test('should create and retrieve a project', () async {
        final project = domain.Project.create(
          name: 'Test Project',
          description: 'A test project',
          color: '#FF0000',
        );

        await database.projectDao.createProject(project);
        final retrievedProject = await database.projectDao.getProjectById(project.id);

        expect(retrievedProject, isNotNull);
        expect(retrievedProject!.id, project.id);
        expect(retrievedProject.name, project.name);
        expect(retrievedProject.description, project.description);
        expect(retrievedProject.color, '#FF0000');
        expect(retrievedProject.isArchived, false);
      });

      test('should update a project', () async {
        final project = domain.Project.create(name: 'Original Name');
        await database.projectDao.createProject(project);

        final updatedProject = project.update(
          name: 'Updated Name',
          description: 'Updated description',
        );
        await database.projectDao.updateProject(updatedProject);

        final retrievedProject = await database.projectDao.getProjectById(project.id);
        expect(retrievedProject!.name, 'Updated Name');
        expect(retrievedProject.description, 'Updated description');
      });

      test('should archive and unarchive a project', () async {
        final project = domain.Project.create(name: 'Test Project');
        await database.projectDao.createProject(project);

        await database.projectDao.archiveProject(project.id);
        var retrievedProject = await database.projectDao.getProjectById(project.id);
        expect(retrievedProject!.isArchived, true);

        await database.projectDao.unarchiveProject(project.id);
        retrievedProject = await database.projectDao.getProjectById(project.id);
        expect(retrievedProject!.isArchived, false);
      });

      test('should delete a project and update task references', () async {
        final project = domain.Project.create(name: 'Project to Delete');
        await database.projectDao.createProject(project);

        final task = TaskModel.create(title: 'Task in Project', projectId: project.id);
        await database.taskDao.createTask(task);

        await database.projectDao.deleteProject(project.id);

        final retrievedProject = await database.projectDao.getProjectById(project.id);
        expect(retrievedProject, isNull);

        final retrievedTask = await database.taskDao.getTaskById(task.id);
        expect(retrievedTask!.projectId, isNull);
      });

      test('should get active projects only', () async {
        final activeProject = domain.Project.create(name: 'Active Project');
        final archivedProject = domain.Project.create(name: 'Archived Project').archive();

        await database.projectDao.createProject(activeProject);
        await database.projectDao.createProject(archivedProject);

        final activeProjects = await database.projectDao.getActiveProjects();

        expect(activeProjects.length, 1);
        expect(activeProjects.first.name, 'Active Project');
      });

      test('should search projects', () async {
        final project1 = domain.Project.create(name: 'Mobile App', description: 'iOS and Android');
        final project2 = domain.Project.create(name: 'Web Portal', description: 'Customer portal');
        final project3 = domain.Project.create(name: 'API Development', description: 'REST API');

        await database.projectDao.createProject(project1);
        await database.projectDao.createProject(project2);
        await database.projectDao.createProject(project3);

        final appProjects = await database.projectDao.searchProjects('App');
        final portalProjects = await database.projectDao.searchProjects('portal');

        expect(appProjects.length, 1);
        expect(appProjects.first.name, 'Mobile App');
        expect(portalProjects.length, 1);
        expect(portalProjects.first.name, 'Web Portal');
      });
    });

    group('TagDao', () {
      test('should create and retrieve a tag', () async {
        final tag = dao.Tag(
          id: 'tag-1',
          name: 'urgent',
          color: '#FF0000',
          createdAt: DateTime.now(),
        );

        await database.tagDao.createTag(tag);
        final retrievedTag = await database.tagDao.getTagById(tag.id);

        expect(retrievedTag, isNotNull);
        expect(retrievedTag!.id, tag.id);
        expect(retrievedTag.name, tag.name);
        expect(retrievedTag.color, tag.color);
      });

      test('should get tag by name', () async {
        final tag = dao.Tag(
          id: 'tag-1',
          name: 'work',
          createdAt: DateTime.now(),
        );

        await database.tagDao.createTag(tag);
        final retrievedTag = await database.tagDao.getTagByName('work');

        expect(retrievedTag, isNotNull);
        expect(retrievedTag!.name, 'work');
      });

      test('should update a tag', () async {
        final tag = dao.Tag(
          id: 'tag-1',
          name: 'original',
          createdAt: DateTime.now(),
        );

        await database.tagDao.createTag(tag);

        final updatedTag = tag.copyWith(
          name: 'updated',
          color: '#00FF00',
        );
        await database.tagDao.updateTag(updatedTag);

        final retrievedTag = await database.tagDao.getTagById(tag.id);
        expect(retrievedTag!.name, 'updated');
        expect(retrievedTag.color, '#00FF00');
      });

      test('should delete a tag', () async {
        final tag = dao.Tag(
          id: 'tag-1',
          name: 'to-delete',
          createdAt: DateTime.now(),
        );

        await database.tagDao.createTag(tag);
        await database.tagDao.deleteTag(tag.id);

        final retrievedTag = await database.tagDao.getTagById(tag.id);
        expect(retrievedTag, isNull);
      });

      test('should add and remove tags from tasks', () async {
        final tag = dao.Tag(
          id: 'tag-1',
          name: 'work',
          createdAt: DateTime.now(),
        );
        final task = TaskModel.create(title: 'Test Task');

        await database.tagDao.createTag(tag);
        await database.taskDao.createTask(task);

        await database.tagDao.addTagToTask(task.id, tag.id);
        var tagsForTask = await database.tagDao.getTagsForTask(task.id);
        expect(tagsForTask.length, 1);
        expect(tagsForTask.first.name, 'work');

        await database.tagDao.removeTagFromTask(task.id, tag.id);
        tagsForTask = await database.tagDao.getTagsForTask(task.id);
        expect(tagsForTask.length, 0);
      });

      test('should get tags with usage counts', () async {
        final tag1 = dao.Tag(id: 'tag-1', name: 'work', createdAt: DateTime.now());
        final tag2 = dao.Tag(id: 'tag-2', name: 'personal', createdAt: DateTime.now());
        final task1 = TaskModel.create(title: 'Task 1');
        final task2 = TaskModel.create(title: 'Task 2');

        await database.tagDao.createTag(tag1);
        await database.tagDao.createTag(tag2);
        await database.taskDao.createTask(task1);
        await database.taskDao.createTask(task2);

        // Add 'work' tag to both tasks, 'personal' tag to one task
        await database.tagDao.addTagToTask(task1.id, tag1.id);
        await database.tagDao.addTagToTask(task2.id, tag1.id);
        await database.tagDao.addTagToTask(task1.id, tag2.id);

        final tagsWithCounts = await database.tagDao.getTagsWithUsageCounts();
        final workTag = tagsWithCounts.firstWhere((t) => t.tag.name == 'work');
        final personalTag = tagsWithCounts.firstWhere((t) => t.tag.name == 'personal');

        expect(workTag.usageCount, 2);
        expect(personalTag.usageCount, 1);
      });

      test('should search tags', () async {
        final tag1 = dao.Tag(id: 'tag-1', name: 'work-related', createdAt: DateTime.now());
        final tag2 = dao.Tag(id: 'tag-2', name: 'personal', createdAt: DateTime.now());
        final tag3 = dao.Tag(id: 'tag-3', name: 'homework', createdAt: DateTime.now());

        await database.tagDao.createTag(tag1);
        await database.tagDao.createTag(tag2);
        await database.tagDao.createTag(tag3);

        final workTags = await database.tagDao.searchTags('work');

        expect(workTags.length, 2); // 'work-related' and 'homework'
        expect(workTags.any((t) => t.name == 'work-related'), true);
        expect(workTags.any((t) => t.name == 'homework'), true);
      });
    });

    group('Database Integration', () {
      test('should handle complex task with project and tags', () async {
        // Create project
        final project = domain.Project.create(name: 'Test Project');
        await database.projectDao.createProject(project);

        // Create tags
        final tag1 = dao.Tag(id: 'tag-1', name: 'urgent', createdAt: DateTime.now());
        final tag2 = dao.Tag(id: 'tag-2', name: 'work', createdAt: DateTime.now());
        await database.tagDao.createTag(tag1);
        await database.tagDao.createTag(tag2);

        // Create task with project and tags
        final task = TaskModel.create(
          title: 'Complex Task',
          projectId: project.id,
          tags: [tag1.id, tag2.id],
        );
        await database.taskDao.createTask(task);

        // Retrieve and verify
        final retrievedTask = await database.taskDao.getTaskById(task.id);
        expect(retrievedTask!.projectId, project.id);
        expect(retrievedTask.tags.length, 2);
        expect(retrievedTask.tags, containsAll([tag1.id, tag2.id]));

        // Verify project has the task
        final retrievedProject = await database.projectDao.getProjectById(project.id);
        expect(retrievedProject!.taskIds, contains(task.id));

        // Verify tags are associated with the task
        final tagsForTask = await database.tagDao.getTagsForTask(task.id);
        expect(tagsForTask.length, 2);
      });

      test('should handle task dependencies', () async {
        final task1 = TaskModel.create(title: 'Task 1');
        final task2 = TaskModel.create(title: 'Task 2', dependencies: [task1.id]);

        await database.taskDao.createTask(task1);
        await database.taskDao.createTask(task2);

        final retrievedTask2 = await database.taskDao.getTaskById(task2.id);
        expect(retrievedTask2!.dependencies, contains(task1.id));
      });

      test('should clear all data', () async {
        // Create some test data
        final project = domain.Project.create(name: 'Test Project');
        final tag = dao.Tag(id: 'tag-1', name: 'test', createdAt: DateTime.now());
        final task = TaskModel.create(title: 'Test Task');

        await database.projectDao.createProject(project);
        await database.tagDao.createTag(tag);
        await database.taskDao.createTask(task);

        // Clear all data
        await database.clearAllData();

        // Verify everything is deleted
        final projects = await database.projectDao.getAllProjects();
        final tags = await database.tagDao.getAllTags();
        final tasks = await database.taskDao.getAllTasks();

        expect(projects, isEmpty);
        expect(tags, isEmpty);
        expect(tasks, isEmpty);
      });
    });
  });
}

