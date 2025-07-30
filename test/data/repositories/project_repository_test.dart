import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/data/repositories/project_repository_impl.dart';
import 'package:task_tracker_app/domain/entities/project.dart' as domain;
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/domain/repositories/project_repository.dart';

void main() {
  group('ProjectRepositoryImpl', () {
    late AppDatabase database;
    late ProjectRepository repository;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = ProjectRepositoryImpl(database);
    });

    tearDown(() async {
      await database.close();
    });

    group('Basic CRUD Operations', () {
      test('should create and retrieve a project', () async {
        final project = domain.Project.create(
          name: 'Test Project',
          description: 'A test project',
          color: '#FF0000',
        );

        await repository.createProject(project);
        final retrievedProject = await repository.getProjectById(project.id);

        expect(retrievedProject, isNotNull);
        expect(retrievedProject!.id, project.id);
        expect(retrievedProject.name, project.name);
        expect(retrievedProject.description, project.description);
        expect(retrievedProject.color, '#FF0000');
      });

      test('should update a project', () async {
        final project = domain.Project.create(name: 'Original Name');
        await repository.createProject(project);

        final updatedProject = project.update(
          name: 'Updated Name',
          description: 'Updated description',
        );
        await repository.updateProject(updatedProject);

        final retrievedProject = await repository.getProjectById(project.id);
        expect(retrievedProject!.name, 'Updated Name');
        expect(retrievedProject.description, 'Updated description');
      });

      test('should delete a project', () async {
        final project = domain.Project.create(name: 'Project to Delete');
        await repository.createProject(project);

        await repository.deleteProject(project.id);
        final retrievedProject = await repository.getProjectById(project.id);

        expect(retrievedProject, isNull);
      });

      test('should get all projects', () async {
        final project1 = domain.Project.create(name: 'Project 1');
        final project2 = domain.Project.create(name: 'Project 2');

        await repository.createProject(project1);
        await repository.createProject(project2);

        final allProjects = await repository.getAllProjects();

        expect(allProjects.length, 2);
        expect(allProjects.any((p) => p.name == 'Project 1'), true);
        expect(allProjects.any((p) => p.name == 'Project 2'), true);
      });
    });

    group('Archive Operations', () {
      test('should archive and unarchive a project', () async {
        final project = domain.Project.create(name: 'Test Project');
        await repository.createProject(project);

        await repository.archiveProject(project.id);
        var retrievedProject = await repository.getProjectById(project.id);
        expect(retrievedProject!.isArchived, true);

        await repository.unarchiveProject(project.id);
        retrievedProject = await repository.getProjectById(project.id);
        expect(retrievedProject!.isArchived, false);
      });

      test('should get only active projects', () async {
        final activeProject = domain.Project.create(name: 'Active Project');
        final archivedProject = domain.Project.create(name: 'Archived Project');

        await repository.createProject(activeProject);
        await repository.createProject(archivedProject);
        await repository.archiveProject(archivedProject.id);

        final activeProjects = await repository.getActiveProjects();

        expect(activeProjects.length, 1);
        expect(activeProjects.first.name, 'Active Project');
      });
    });

    group('Project Statistics', () {
      test('should get projects with statistics', () async {
        final project = domain.Project.create(name: 'Test Project');
        await repository.createProject(project);

        // Create tasks for the project
        final task1 = TaskModel.create(
          title: 'Completed Task',
          projectId: project.id,
        ).markCompleted();
        final task2 = TaskModel.create(
          title: 'Pending Task',
          projectId: project.id,
        );
        final task3 = TaskModel.create(
          title: 'Overdue Task',
          projectId: project.id,
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
        );

        await database.taskDao.createTask(task1);
        await database.taskDao.createTask(task2);
        await database.taskDao.createTask(task3);

        final projectsWithStats = await repository.getProjectsWithStats();

        expect(projectsWithStats.length, 1);
        final stats = projectsWithStats.first;
        expect(stats.project.name, 'Test Project');
        expect(stats.totalTasks, 3);
        expect(stats.completedTasks, 1);
        expect(stats.pendingTasks, 2); // task2 and task3 are both pending
        expect(stats.overdueTasks, 1);
        expect(stats.completionPercentage, closeTo(0.33, 0.01));
        expect(stats.hasOverdueTasks, true);
        expect(stats.isCompleted, false);
      });

      test('should calculate completion percentage correctly', () async {
        final project = domain.Project.create(name: 'Test Project');
        await repository.createProject(project);

        // Create 2 completed tasks and 1 pending task
        final task1 = TaskModel.create(title: 'Task 1', projectId: project.id).markCompleted();
        final task2 = TaskModel.create(title: 'Task 2', projectId: project.id).markCompleted();
        final task3 = TaskModel.create(title: 'Task 3', projectId: project.id);

        await database.taskDao.createTask(task1);
        await database.taskDao.createTask(task2);
        await database.taskDao.createTask(task3);

        final projectsWithStats = await repository.getProjectsWithStats();
        final stats = projectsWithStats.first;

        expect(stats.completionPercentage, closeTo(0.67, 0.01));
        expect(stats.isCompleted, false);
      });

      test('should handle project with no tasks', () async {
        final project = domain.Project.create(name: 'Empty Project');
        await repository.createProject(project);

        final projectsWithStats = await repository.getProjectsWithStats();
        final stats = projectsWithStats.first;

        expect(stats.totalTasks, 0);
        expect(stats.completedTasks, 0);
        expect(stats.pendingTasks, 0);
        expect(stats.overdueTasks, 0);
        expect(stats.completionPercentage, 0.0);
        expect(stats.hasOverdueTasks, false);
        expect(stats.isCompleted, false);
      });
    });

    group('Search and Filter Operations', () {
      test('should search projects', () async {
        final project1 = domain.Project.create(name: 'Mobile App', description: 'iOS and Android');
        final project2 = domain.Project.create(name: 'Web Portal', description: 'Customer portal');
        final project3 = domain.Project.create(name: 'API Development', description: 'REST API');

        await repository.createProject(project1);
        await repository.createProject(project2);
        await repository.createProject(project3);

        final appProjects = await repository.searchProjects('App');
        expect(appProjects.length, 1);
        expect(appProjects.first.name, 'Mobile App');

        final portalProjects = await repository.searchProjects('portal');
        expect(portalProjects.length, 1);
        expect(portalProjects.first.name, 'Web Portal');
      });

      test('should filter projects with ProjectFilter', () async {
        final activeProject = domain.Project.create(name: 'Active Project');
        final archivedProject = domain.Project.create(name: 'Archived Project');
        final projectWithDeadline = domain.Project.create(
          name: 'Project with Deadline',
          deadline: DateTime.now().add(const Duration(days: 7)),
        );

        await repository.createProject(activeProject);
        await repository.createProject(archivedProject);
        await repository.createProject(projectWithDeadline);
        await repository.archiveProject(archivedProject.id);

        // Filter by archived status
        final filter1 = ProjectFilter(isArchived: false);
        final activeProjects = await repository.getProjectsWithFilter(filter1);
        expect(activeProjects.length, 2);
        expect(activeProjects.any((p) => p.name == 'Active Project'), true);
        expect(activeProjects.any((p) => p.name == 'Project with Deadline'), true);

        // Filter by deadline presence
        final filter2 = ProjectFilter(hasDeadline: true);
        final projectsWithDeadline = await repository.getProjectsWithFilter(filter2);
        expect(projectsWithDeadline.length, 1);
        expect(projectsWithDeadline.first.name, 'Project with Deadline');

        // Search filter
        final filter3 = ProjectFilter(searchQuery: 'Active');
        final searchResults = await repository.getProjectsWithFilter(filter3);
        expect(searchResults.length, 1);
        expect(searchResults.first.name, 'Active Project');
      });

      test('should sort projects with ProjectFilter', () async {
        final projectB = domain.Project.create(name: 'B Project');
        final projectA = domain.Project.create(name: 'A Project');

        await repository.createProject(projectB);
        await repository.createProject(projectA);

        // Sort by name ascending
        final filter = ProjectFilter(
          sortBy: ProjectSortBy.name,
          sortAscending: true,
        );
        final sortedProjects = await repository.getProjectsWithFilter(filter);

        expect(sortedProjects.first.name, 'A Project');
        expect(sortedProjects.last.name, 'B Project');
      });

      test('should filter by deadline range', () async {
        final now = DateTime.now();
        final nextWeek = now.add(const Duration(days: 7));
        final nextMonth = now.add(const Duration(days: 30));

        final project1 = domain.Project.create(name: 'Project 1', deadline: nextWeek);
        final project2 = domain.Project.create(name: 'Project 2', deadline: nextMonth);

        await repository.createProject(project1);
        await repository.createProject(project2);

        // Filter projects with deadline within 2 weeks
        final filter = ProjectFilter(
          deadlineFrom: now,
          deadlineTo: now.add(const Duration(days: 14)),
        );
        final filteredProjects = await repository.getProjectsWithFilter(filter);

        expect(filteredProjects.length, 1);
        expect(filteredProjects.first.name, 'Project 1');
      });
    });

    group('Stream Operations', () {
      test('should watch all projects', () async {
        final project = domain.Project.create(name: 'Watched Project');
        
        // Start watching
        final stream = repository.watchAllProjects();
        final future = stream.first;

        // Create project
        await repository.createProject(project);

        // Verify stream emits the project
        final projects = await future;
        expect(projects.any((p) => p.name == 'Watched Project'), true);
      });

      test('should watch active projects', () async {
        final activeProject = domain.Project.create(name: 'Active Project');
        final archivedProject = domain.Project.create(name: 'Archived Project');
        
        // Start watching active projects
        final stream = repository.watchActiveProjects();
        
        // Create projects
        await repository.createProject(activeProject);
        await repository.createProject(archivedProject);
        await repository.archiveProject(archivedProject.id);

        // Get the first emission
        final projects = await stream.first;
        
        // Verify stream only emits active projects
        expect(projects.length, 1);
        expect(projects.first.name, 'Active Project');
      });

      test('should watch project by id', () async {
        final project = domain.Project.create(name: 'Specific Project');
        await repository.createProject(project);
        
        // Start watching specific project
        final stream = repository.watchProjectById(project.id);
        final watchedProject = await stream.first;

        expect(watchedProject, isNotNull);
        expect(watchedProject!.name, 'Specific Project');
      });

      test('should return null when watching non-existent project', () async {
        final stream = repository.watchProjectById('non-existent-id');
        final watchedProject = await stream.first;

        expect(watchedProject, isNull);
      });
    });

    group('Integration with Tasks', () {
      test('should delete project and update task references', () async {
        final project = domain.Project.create(name: 'Project to Delete');
        await repository.createProject(project);

        final task = TaskModel.create(title: 'Task in Project', projectId: project.id);
        await database.taskDao.createTask(task);

        await repository.deleteProject(project.id);

        final retrievedProject = await repository.getProjectById(project.id);
        expect(retrievedProject, isNull);

        final retrievedTask = await database.taskDao.getTaskById(task.id);
        expect(retrievedTask!.projectId, isNull);
      });
    });
  });
}
