import '../entities/project.dart';
import '../repositories/project_repository.dart';
import '../repositories/task_repository.dart';

/// Custom exceptions for use cases
class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
  @override
  String toString() => 'ValidationException: $message';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);
  @override
  String toString() => 'NotFoundException: $message';
}

/// Use cases for project management operations
class ProjectUseCases {
  final ProjectRepository _projectRepository;
  final TaskRepository _taskRepository;

  const ProjectUseCases(this._projectRepository, this._taskRepository);

  /// Creates a new project with validation
  Future<Project> createProject({
    required String name,
    String? description,
    String color = '#2196F3',
    DateTime? deadline,
  }) async {
    // Validate input
    if (name.trim().isEmpty) {
      throw const ValidationException('Project name cannot be empty');
    }

    // Check for duplicate names
    final existingProjects = await _projectRepository.getAllProjects();
    final duplicateName = existingProjects.any(
      (p) => p.name.toLowerCase() == name.trim().toLowerCase() && !p.isArchived
    );
    
    if (duplicateName) {
      throw const ValidationException('A project with this name already exists');
    }

    // Create project
    final project = Project.create(
      name: name.trim(),
      description: description?.trim(),
      color: color,
      deadline: deadline,
    );

    // Validate project
    if (!project.isValid()) {
      throw const ValidationException('Invalid project data');
    }

    await _projectRepository.createProject(project);
    return project;
  }

  /// Updates an existing project
  Future<Project> updateProject(Project project) async {
    // Validate project
    if (!project.isValid()) {
      throw const ValidationException('Invalid project data');
    }

    // Check if project exists
    final existingProject = await _projectRepository.getProjectById(project.id);
    if (existingProject == null) {
      throw const NotFoundException('Project not found');
    }

    // Check for duplicate names (excluding current project)
    final allProjects = await _projectRepository.getAllProjects();
    final duplicateName = allProjects.any(
      (p) => p.id != project.id && 
             p.name.toLowerCase() == project.name.toLowerCase() && 
             !p.isArchived
    );
    
    if (duplicateName) {
      throw const ValidationException('A project with this name already exists');
    }

    final updatedProject = project.copyWith(updatedAt: DateTime.now());
    await _projectRepository.updateProject(updatedProject);
    return updatedProject;
  }

  /// Deletes a project and handles associated tasks
  Future<void> deleteProject(String projectId, {bool deleteAssociatedTasks = false}) async {
    final project = await _projectRepository.getProjectById(projectId);
    if (project == null) {
      throw const NotFoundException('Project not found');
    }

    // Get tasks associated with this project
    final associatedTasks = await _taskRepository.getTasksByProject(projectId);

    if (associatedTasks.isNotEmpty && !deleteAssociatedTasks) {
      throw ValidationException(
        'Cannot delete project: ${associatedTasks.length} tasks are associated with it. '
        'Either delete the tasks first or choose to delete them with the project.'
      );
    }

    // Delete associated tasks if requested
    if (deleteAssociatedTasks) {
      for (final task in associatedTasks) {
        await _taskRepository.deleteTask(task.id);
      }
    } else {
      // Remove project association from tasks
      for (final task in associatedTasks) {
        final updatedTask = task.copyWith(projectId: null);
        await _taskRepository.updateTask(updatedTask);
      }
    }

    await _projectRepository.deleteProject(projectId);
  }

  /// Archives a project
  Future<Project> archiveProject(String projectId) async {
    final project = await _projectRepository.getProjectById(projectId);
    if (project == null) {
      throw const NotFoundException('Project not found');
    }

    if (project.isArchived) {
      throw const ValidationException('Project is already archived');
    }

    final archivedProject = project.archive();
    await _projectRepository.updateProject(archivedProject);
    return archivedProject;
  }

  /// Unarchives a project
  Future<Project> unarchiveProject(String projectId) async {
    final project = await _projectRepository.getProjectById(projectId);
    if (project == null) {
      throw const NotFoundException('Project not found');
    }

    if (!project.isArchived) {
      throw const ValidationException('Project is not archived');
    }

    final unarchivedProject = project.unarchive();
    await _projectRepository.updateProject(unarchivedProject);
    return unarchivedProject;
  }

  /// Gets project statistics
  Future<ProjectStatistics> getProjectStatistics(String projectId) async {
    final project = await _projectRepository.getProjectById(projectId);
    if (project == null) {
      throw const NotFoundException('Project not found');
    }

    final tasks = await _taskRepository.getTasksByProject(projectId);
    
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final overdueTasks = tasks.where((t) => t.isOverdue).length;
    final todayTasks = tasks.where((t) => t.isDueToday).length;
    
    final completionPercentage = totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;
    
    return ProjectStatistics(
      projectId: projectId,
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      pendingTasks: totalTasks - completedTasks,
      overdueTasks: overdueTasks,
      todayTasks: todayTasks,
      completionPercentage: completionPercentage,
      isOverdue: project.isOverdue,
    );
  }

  /// Gets all active projects
  Future<List<Project>> getActiveProjects() async {
    final projects = await _projectRepository.getAllProjects();
    return projects.where((p) => !p.isArchived).toList();
  }

  /// Gets all archived projects
  Future<List<Project>> getArchivedProjects() async {
    final projects = await _projectRepository.getAllProjects();
    return projects.where((p) => p.isArchived).toList();
  }

  /// Adds a task to a project
  Future<Project> addTaskToProject(String projectId, String taskId) async {
    final project = await _projectRepository.getProjectById(projectId);
    if (project == null) {
      throw const NotFoundException('Project not found');
    }

    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      throw const NotFoundException('Task not found');
    }

    // Update task with project ID
    final updatedTask = task.copyWith(projectId: projectId);
    await _taskRepository.updateTask(updatedTask);

    // Update project with task ID
    final updatedProject = project.addTask(taskId);
    await _projectRepository.updateProject(updatedProject);

    return updatedProject;
  }

  /// Removes a task from a project
  Future<Project> removeTaskFromProject(String projectId, String taskId) async {
    final project = await _projectRepository.getProjectById(projectId);
    if (project == null) {
      throw const NotFoundException('Project not found');
    }

    final task = await _taskRepository.getTaskById(taskId);
    if (task != null && task.projectId == projectId) {
      // Remove project ID from task
      final updatedTask = task.copyWith(projectId: null);
      await _taskRepository.updateTask(updatedTask);
    }

    // Remove task ID from project
    final updatedProject = project.removeTask(taskId);
    await _projectRepository.updateProject(updatedProject);

    return updatedProject;
  }

  /// Gets projects with search and filtering
  Future<List<Project>> searchProjects({
    String? searchQuery,
    bool includeArchived = false,
    DateTime? createdAfter,
    DateTime? createdBefore,
  }) async {
    List<Project> projects = await _projectRepository.getAllProjects();

    // Filter by archived status
    if (!includeArchived) {
      projects = projects.where((p) => !p.isArchived).toList();
    }

    // Filter by creation date
    if (createdAfter != null) {
      projects = projects.where((p) => p.createdAt.isAfter(createdAfter)).toList();
    }

    if (createdBefore != null) {
      projects = projects.where((p) => p.createdAt.isBefore(createdBefore)).toList();
    }

    // Apply search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      projects = projects.where((p) => 
        p.name.toLowerCase().contains(query) ||
        (p.description?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    return projects;
  }
}

/// Statistics for a project
class ProjectStatistics {
  final String projectId;
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;
  final int todayTasks;
  final double completionPercentage;
  final bool isOverdue;

  const ProjectStatistics({
    required this.projectId,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.todayTasks,
    required this.completionPercentage,
    required this.isOverdue,
  });
}