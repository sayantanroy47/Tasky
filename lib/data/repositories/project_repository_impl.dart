import '../../domain/entities/project.dart' as domain;
import '../../domain/entities/task_enums.dart';
import '../../domain/repositories/project_repository.dart';
import '../../services/database/database.dart';

/// Concrete implementation of ProjectRepository using local database
/// 
/// This implementation uses the Drift/SQLite database through the ProjectDao
/// to provide all project-related operations.
class ProjectRepositoryImpl implements ProjectRepository {
  final AppDatabase _database;

  const ProjectRepositoryImpl(this._database);

  @override
  Future<List<domain.Project>> getAllProjects() async {
    return await _database.projectDao.getAllProjects();
  }

  @override
  Future<List<domain.Project>> getActiveProjects() async {
    return await _database.projectDao.getActiveProjects();
  }

  @override
  Future<domain.Project?> getProjectById(String id) async {
    return await _database.projectDao.getProjectById(id);
  }

  @override
  Future<void> createProject(domain.Project project) async {
    await _database.projectDao.createProject(project);
  }

  @override
  Future<void> updateProject(domain.Project project) async {
    await _database.projectDao.updateProject(project);
  }

  @override
  Future<void> deleteProject(String id) async {
    await _database.projectDao.deleteProject(id);
  }

  @override
  Future<void> archiveProject(String id) async {
    await _database.projectDao.archiveProject(id);
  }

  @override
  Future<void> unarchiveProject(String id) async {
    await _database.projectDao.unarchiveProject(id);
  }

  @override
  Future<List<ProjectWithStats>> getProjectsWithStats() async {
    final projects = await getAllProjects();
    final projectStats = <ProjectWithStats>[];

    for (final project in projects) {
      final tasks = await _database.taskDao.getTasksByProject(project.id);
      
      final totalTasks = tasks.length;
      final completedTasks = tasks.where((task) => task.status == TaskStatus.completed).length;
      final pendingTasks = tasks.where((task) => task.status.isActive).length;
      final overdueTasks = tasks.where((task) => task.isOverdue).length;

      projectStats.add(ProjectWithStats(
        project: project,
        totalTasks: totalTasks,
        completedTasks: completedTasks,
        pendingTasks: pendingTasks,
        overdueTasks: overdueTasks,
      ));
    }

    return projectStats;
  }

  @override
  Future<List<domain.Project>> searchProjects(String query) async {
    return await _database.projectDao.searchProjects(query);
  }

  @override
  Future<List<domain.Project>> getProjectsWithFilter(ProjectFilter filter) async {
    // Start with all projects
    var projects = await getAllProjects();

    // Apply filters
    if (filter.isArchived != null) {
      projects = projects.where((project) => project.isArchived == filter.isArchived).toList();
    }

    if (filter.hasDeadline == true) {
      projects = projects.where((project) => project.hasDeadline).toList();
    } else if (filter.hasDeadline == false) {
      projects = projects.where((project) => !project.hasDeadline).toList();
    }

    if (filter.isOverdue == true) {
      projects = projects.where((project) => project.isOverdue).toList();
    } else if (filter.isOverdue == false) {
      projects = projects.where((project) => !project.isOverdue).toList();
    }

    if (filter.deadlineFrom != null) {
      projects = projects.where((project) {
        return project.deadline != null && project.deadline!.isAfter(filter.deadlineFrom!);
      }).toList();
    }

    if (filter.deadlineTo != null) {
      projects = projects.where((project) {
        return project.deadline != null && project.deadline!.isBefore(filter.deadlineTo!);
      }).toList();
    }

    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      projects = projects.where((project) {
        return project.name.toLowerCase().contains(query) ||
            (project.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply sorting
    projects.sort((a, b) {
      int comparison = 0;
      
      switch (filter.sortBy) {
        case ProjectSortBy.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case ProjectSortBy.updatedAt:
          final aUpdated = a.updatedAt ?? a.createdAt;
          final bUpdated = b.updatedAt ?? b.createdAt;
          comparison = aUpdated.compareTo(bUpdated);
          break;
        case ProjectSortBy.name:
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case ProjectSortBy.deadline:
          if (a.deadline == null && b.deadline == null) {
            comparison = 0;
          } else if (a.deadline == null) {
            comparison = 1;
          } else if (b.deadline == null) {
            comparison = -1;
          } else {
            comparison = a.deadline!.compareTo(b.deadline!);
          }
          break;
        case ProjectSortBy.taskCount:
          comparison = a.taskCount.compareTo(b.taskCount);
          break;
      }

      return filter.sortAscending ? comparison : -comparison;
    });

    return projects;
  }

  @override
  Stream<List<domain.Project>> watchAllProjects() {
    return _database.projectDao.watchAllProjects();
  }

  @override
  Stream<List<domain.Project>> watchActiveProjects() {
    return _database.projectDao.watchActiveProjects();
  }

  @override
  Stream<domain.Project?> watchProjectById(String id) {
    return watchAllProjects().map((projects) {
      try {
        return projects.firstWhere((project) => project.id == id);
      } catch (e) {
        return null;
      }
    });
  }
}
