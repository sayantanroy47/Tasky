import 'package:drift/drift.dart';

import '../database.dart';
import '../tables.dart';
import '../../../domain/entities/project.dart' as domain;

part 'project_dao.g.dart';

/// Data Access Object for Project operations
/// 
/// Provides CRUD operations and queries for projects in the database.
@DriftAccessor(tables: [Projects, Tasks])
class ProjectDao extends DatabaseAccessor<AppDatabase> with _$ProjectDaoMixin {
  ProjectDao(super.db);

  /// Gets all projects from the database
  Future<List<domain.Project>> getAllProjects() async {
    final projectRows = await select(projects).get();
    final projectModels = <domain.Project>[];

    for (final projectRow in projectRows) {
      final project = await _projectRowToModel(projectRow);
      projectModels.add(project);
    }

    return projectModels;
  }

  /// Gets active (non-archived) projects
  Future<List<domain.Project>> getActiveProjects() async {
    final projectRows = await (select(projects)
      ..where((p) => p.isArchived.equals(false))
    ).get();
    
    final projectModels = <domain.Project>[];
    for (final projectRow in projectRows) {
      final project = await _projectRowToModel(projectRow);
      projectModels.add(project);
    }

    return projectModels;
  }

  /// Gets a project by its ID
  Future<domain.Project?> getProjectById(String id) async {
    final projectRow = await (select(projects)..where((p) => p.id.equals(id))).getSingleOrNull();
    if (projectRow == null) return null;

    return await _projectRowToModel(projectRow);
  }

  /// Creates a new project in the database
  Future<void> createProject(domain.Project project) async {
    await into(projects).insert(_projectModelToRow(project));
  }

  /// Updates an existing project in the database
  Future<void> updateProject(domain.Project project) async {
    await (update(projects)..where((p) => p.id.equals(project.id)))
        .write(_projectModelToRow(project));
  }

  /// Deletes a project from the database
  /// Note: This will set project_id to NULL for all tasks in this project
  Future<void> deleteProject(String id) async {
    await db.transaction(() async {
      // First, update all tasks to remove the project reference
      await (update(tasks)..where((t) => t.projectId.equals(id)))
          .write(const TasksCompanion(projectId: Value(null)));
      
      // Then delete the project
      await (delete(projects)..where((p) => p.id.equals(id))).go();
    });
  }

  /// Archives a project
  Future<void> archiveProject(String id) async {
    await (update(projects)..where((p) => p.id.equals(id)))
        .write(ProjectsCompanion(
          isArchived: const Value(true),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Unarchives a project
  Future<void> unarchiveProject(String id) async {
    await (update(projects)..where((p) => p.id.equals(id)))
        .write(ProjectsCompanion(
          isArchived: const Value(false),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Gets projects with task counts
  Future<List<ProjectWithTaskCount>> getProjectsWithTaskCounts() async {
    final query = select(projects).join([
      leftOuterJoin(tasks, tasks.projectId.equalsExp(projects.id))
    ]);

    final results = await query.get();
    final projectMap = <String, ProjectWithTaskCount>{};

    for (final row in results) {
      final project = row.readTable(projects);
      final task = row.readTableOrNull(tasks);

      if (!projectMap.containsKey(project.id)) {
        final taskIds = <String>[];
        if (task != null) {
          taskIds.add(task.id);
        }

        projectMap[project.id] = ProjectWithTaskCount(
          project: domain.Project(
            id: project.id,
            name: project.name,
            description: project.description,
            color: project.color,
            createdAt: project.createdAt,
            updatedAt: project.updatedAt,
            taskIds: taskIds,
            isArchived: project.isArchived,
            deadline: project.deadline,
          ),
          taskCount: taskIds.length,
        );
      } else if (task != null) {
        final existing = projectMap[project.id]!;
        final updatedTaskIds = List<String>.from(existing.project.taskIds)..add(task.id);
        projectMap[project.id] = ProjectWithTaskCount(
          project: existing.project.copyWith(taskIds: updatedTaskIds),
          taskCount: updatedTaskIds.length,
        );
      }
    }

    return projectMap.values.toList();
  }

  /// Searches projects by name or description
  Future<List<domain.Project>> searchProjects(String query) async {
    final projectRows = await (select(projects)
      ..where((p) => p.name.contains(query) | p.description.contains(query))
    ).get();
    
    final projectModels = <domain.Project>[];
    for (final projectRow in projectRows) {
      final project = await _projectRowToModel(projectRow);
      projectModels.add(project);
    }

    return projectModels;
  }

  /// Watches all projects (returns a stream)
  Stream<List<domain.Project>> watchAllProjects() {
    return select(projects).watch().asyncMap((projectRows) async {
      final projectModels = <domain.Project>[];
      for (final projectRow in projectRows) {
        final project = await _projectRowToModel(projectRow);
        projectModels.add(project);
      }
      return projectModels;
    });
  }

  /// Watches active projects (returns a stream)
  Stream<List<domain.Project>> watchActiveProjects() {
    return (select(projects)..where((p) => p.isArchived.equals(false)))
        .watch().asyncMap((projectRows) async {
      final projectModels = <domain.Project>[];
      for (final projectRow in projectRows) {
        final project = await _projectRowToModel(projectRow);
        projectModels.add(project);
      }
      return projectModels;
    });
  }

  /// Converts a project database row to a Project model
  Future<domain.Project> _projectRowToModel(Project projectRow) async {
    // Get task IDs for this project
    final taskRows = await (select(tasks)..where((t) => t.projectId.equals(projectRow.id))).get();
    final taskIds = taskRows.map((task) => task.id).toList();

    return domain.Project(
      id: projectRow.id,
      name: projectRow.name,
      description: projectRow.description,
      color: projectRow.color,
      createdAt: projectRow.createdAt,
      updatedAt: projectRow.updatedAt,
      taskIds: taskIds,
      isArchived: projectRow.isArchived,
      deadline: projectRow.deadline,
    );
  }

  /// Converts a Project model to a database row
  ProjectsCompanion _projectModelToRow(domain.Project project) {
    return ProjectsCompanion.insert(
      id: project.id,
      name: project.name,
      description: Value(project.description),
      color: project.color,
      createdAt: project.createdAt,
      updatedAt: Value(project.updatedAt),
      isArchived: Value(project.isArchived),
      deadline: Value(project.deadline),
    );
  }
}

/// Helper class for projects with task counts
class ProjectWithTaskCount {
  final domain.Project project;
  final int taskCount;

  const ProjectWithTaskCount({
    required this.project,
    required this.taskCount,
  });
}