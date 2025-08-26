import '../domain/entities/project.dart';
import '../domain/entities/task_model.dart';
import '../domain/entities/task_enums.dart';
import '../domain/repositories/project_repository.dart';
import '../domain/repositories/task_repository.dart';

/// Service for managing projects and project-related operations
/// 
/// This service provides functionality to manage projects, track progress,
/// and handle project-task relationships.
class ProjectService {
  final ProjectRepository _projectRepository;
  final TaskRepository _taskRepository;

  const ProjectService(this._projectRepository, this._taskRepository);

  /// Creates a new project
  Future<Project> createProject({
    required String name,
    String? description,
    String color = '#2196F3',
    List<String> tagIds = const [],
    DateTime? deadline,
  }) async {
    final project = Project.create(
      name: name,
      description: description,
      color: color,
      tagIds: tagIds,
      deadline: deadline,
    );

    await _projectRepository.createProject(project);
    return project;
  }

  /// Updates an existing project
  Future<void> updateProject(Project project) async {
    await _projectRepository.updateProject(project);
  }

  /// Deletes a project and removes it from all associated tasks
  Future<void> deleteProject(String projectId) async {
    await _projectRepository.deleteProject(projectId);
  }

  /// Archives a project
  Future<void> archiveProject(String projectId) async {
    await _projectRepository.archiveProject(projectId);
  }

  /// Unarchives a project
  Future<void> unarchiveProject(String projectId) async {
    await _projectRepository.unarchiveProject(projectId);
  }

  /// Gets all projects
  Future<List<Project>> getAllProjects() async {
    return await _projectRepository.getAllProjects();
  }

  /// Gets only active (non-archived) projects
  Future<List<Project>> getActiveProjects() async {
    return await _projectRepository.getActiveProjects();
  }

  /// Gets a project by ID
  Future<Project?> getProjectById(String id) async {
    return await _projectRepository.getProjectById(id);
  }

  /// Gets projects with detailed statistics
  Future<List<ProjectWithDetailedStats>> getProjectsWithDetailedStats() async {
    final projects = await getAllProjects();
    final projectStats = <ProjectWithDetailedStats>[];

    for (final project in projects) {
      final stats = await getProjectStats(project.id);
      projectStats.add(ProjectWithDetailedStats(
        project: project,
        stats: stats,
      ));
    }

    return projectStats;
  }

  /// Gets detailed statistics for a specific project
  Future<ProjectStats> getProjectStats(String projectId) async {
    final tasks = await _taskRepository.getTasksByProject(projectId);
    
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((task) => task.status == TaskStatus.completed).length;
    final inProgressTasks = tasks.where((task) => task.status == TaskStatus.inProgress).length;
    final pendingTasks = tasks.where((task) => task.status == TaskStatus.pending).length;
    final cancelledTasks = tasks.where((task) => task.status == TaskStatus.cancelled).length;
    final overdueTasks = tasks.where((task) => task.isOverdue).length;
    final dueTodayTasks = tasks.where((task) => task.isDueToday).length;
    final dueSoonTasks = tasks.where((task) => task.isDueSoon).length;

    // Priority breakdown
    final highPriorityTasks = tasks.where((task) => task.priority == TaskPriority.urgent || task.priority == TaskPriority.high).length;
    final mediumPriorityTasks = tasks.where((task) => task.priority == TaskPriority.medium).length;
    final lowPriorityTasks = tasks.where((task) => task.priority == TaskPriority.low).length;

    // Time estimates
    final totalEstimatedTime = tasks
        .where((task) => task.estimatedDuration != null)
        .fold<int>(0, (sum, task) => sum + task.estimatedDuration!);
    
    final totalActualTime = tasks
        .where((task) => task.actualDuration != null)
        .fold<int>(0, (sum, task) => sum + task.actualDuration!);

    // Completion percentage
    final completionPercentage = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return ProjectStats(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      inProgressTasks: inProgressTasks,
      pendingTasks: pendingTasks,
      cancelledTasks: cancelledTasks,
      overdueTasks: overdueTasks,
      dueTodayTasks: dueTodayTasks,
      dueSoonTasks: dueSoonTasks,
      highPriorityTasks: highPriorityTasks,
      mediumPriorityTasks: mediumPriorityTasks,
      lowPriorityTasks: lowPriorityTasks,
      totalEstimatedTime: totalEstimatedTime,
      totalActualTime: totalActualTime,
      completionPercentage: completionPercentage,
    );
  }

  /// Adds a task to a project
  Future<void> addTaskToProject(String taskId, String projectId) async {
    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      throw TaskNotFoundException('Task not found: $taskId');
    }

    final project = await _projectRepository.getProjectById(projectId);
    if (project == null) {
      throw ProjectNotFoundException('Project not found: $projectId');
    }

    final updatedTask = task.copyWith(projectId: projectId);
    await _taskRepository.updateTask(updatedTask);
  }

  /// Removes a task from its project
  Future<void> removeTaskFromProject(String taskId) async {
    final task = await _taskRepository.getTaskById(taskId);
    if (task == null) {
      throw TaskNotFoundException('Task not found: $taskId');
    }

    final updatedTask = task.copyWith(projectId: null);
    await _taskRepository.updateTask(updatedTask);
  }

  /// Gets tasks for a specific project
  Future<List<TaskModel>> getProjectTasks(String projectId) async {
    return await _taskRepository.getTasksByProject(projectId);
  }

  /// Gets project progress over time (for charts/analytics)
  Future<List<ProjectProgressPoint>> getProjectProgress(String projectId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final tasks = await getProjectTasks(projectId);
    
    // Default to project creation date if no start date provided
    final project = await getProjectById(projectId);
    final start = startDate ?? project?.createdAt ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    final progressPoints = <ProjectProgressPoint>[];
    final current = DateTime(start.year, start.month, start.day);
    
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      final completedByDate = tasks.where((task) {
        return task.status == TaskStatus.completed && 
               task.completedAt != null && 
               task.completedAt!.isBefore(current.add(const Duration(days: 1)));
      }).length;

      final totalTasks = tasks.length;
      final completionPercentage = totalTasks > 0 ? completedByDate / totalTasks : 0.0;

      progressPoints.add(ProjectProgressPoint(
        date: DateTime(current.year, current.month, current.day),
        completedTasks: completedByDate,
        totalTasks: totalTasks,
        completionPercentage: completionPercentage,
      ));

      current.add(const Duration(days: 1));
    }

    return progressPoints;
  }

  /// Gets projects that are at risk (overdue or behind schedule)
  Future<List<Project>> getProjectsAtRisk() async {
    final projects = await getActiveProjects();
    final atRiskProjects = <Project>[];

    for (final project in projects) {
      final stats = await getProjectStats(project.id);
      
      // Project is at risk if:
      // 1. It has overdue tasks
      // 2. It's past its deadline with incomplete tasks
      // 3. It has a low completion rate close to deadline
      
      final isAtRisk = stats.overdueTasks > 0 ||
          (project.isOverdue && stats.completedTasks < stats.totalTasks) ||
          (project.deadline != null && 
           project.deadline!.difference(DateTime.now()).inDays <= 7 &&
           stats.completionPercentage < 0.8);

      if (isAtRisk) {
        atRiskProjects.add(project);
      }
    }

    return atRiskProjects;
  }

  /// Gets project milestones (tasks with high priority or specific due dates)
  Future<List<TaskModel>> getProjectMilestones(String projectId) async {
    final tasks = await getProjectTasks(projectId);
    
    // Consider milestones as:
    // 1. High or urgent priority tasks
    // 2. Tasks with specific due dates
    // 3. Tasks with dependencies (blocking other tasks)
    
    return tasks.where((task) {
      return task.priority == TaskPriority.high ||
             task.priority == TaskPriority.urgent ||
             task.dueDate != null ||
             task.hasDependencies;
    }).toList();
  }

  /// Duplicates a project with all its tasks
  Future<Project> duplicateProject(String projectId, {String? newName}) async {
    final originalProject = await getProjectById(projectId);
    if (originalProject == null) {
      throw ProjectNotFoundException('Project not found: $projectId');
    }

    final originalTasks = await getProjectTasks(projectId);

    // Create new project
    final newProject = await createProject(
      name: newName ?? '${originalProject.name} (Copy)',
      description: originalProject.description,
      color: originalProject.color,
      deadline: originalProject.deadline,
    );

    // Create mapping of old task IDs to new task IDs for dependencies
    final taskIdMapping = <String, String>{};

    // Create new tasks (without dependencies first)
    for (final originalTask in originalTasks) {
      final newTask = TaskModel.create(
        title: originalTask.title,
        description: originalTask.description,
        dueDate: originalTask.dueDate,
        priority: originalTask.priority,
        tags: originalTask.tags,
        locationTrigger: originalTask.locationTrigger,
        recurrence: originalTask.recurrence,
        projectId: newProject.id,
        metadata: originalTask.metadata,
        isPinned: originalTask.isPinned,
        estimatedDuration: originalTask.estimatedDuration,
      );

      await _taskRepository.createTask(newTask);
      taskIdMapping[originalTask.id] = newTask.id;
    }

    // Update tasks with mapped dependencies
    for (final originalTask in originalTasks) {
      if (originalTask.hasDependencies) {
        final newTaskId = taskIdMapping[originalTask.id]!;
        final newTask = await _taskRepository.getTaskById(newTaskId);
        
        if (newTask != null) {
          final mappedDependencies = originalTask.dependencies
              .map((depId) => taskIdMapping[depId])
              .where((id) => id != null)
              .cast<String>()
              .toList();

          final updatedTask = newTask.copyWith(dependencies: mappedDependencies);
          await _taskRepository.updateTask(updatedTask);
        }
      }
    }

    return newProject;
  }
}

/// Detailed project statistics
class ProjectStats {
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int pendingTasks;
  final int cancelledTasks;
  final int overdueTasks;
  final int dueTodayTasks;
  final int dueSoonTasks;
  final int highPriorityTasks;
  final int mediumPriorityTasks;
  final int lowPriorityTasks;
  final int totalEstimatedTime; // in minutes
  final int totalActualTime; // in minutes
  final double completionPercentage;

  const ProjectStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.pendingTasks,
    required this.cancelledTasks,
    required this.overdueTasks,
    required this.dueTodayTasks,
    required this.dueSoonTasks,
    required this.highPriorityTasks,
    required this.mediumPriorityTasks,
    required this.lowPriorityTasks,
    required this.totalEstimatedTime,
    required this.totalActualTime,
    required this.completionPercentage,
  });

  /// Returns true if the project has any overdue tasks
  bool get hasOverdueTasks => overdueTasks > 0;

  /// Returns true if the project is completed (all tasks done)
  bool get isCompleted => totalTasks > 0 && completedTasks == totalTasks;

  /// Returns the number of active tasks (pending + in progress)
  int get activeTasks => pendingTasks + inProgressTasks;

  /// Returns the estimated time remaining in minutes
  int get estimatedTimeRemaining {
    // This is a simplified calculation - in reality you'd want to track
    // estimated time per task and subtract actual time spent
    return totalEstimatedTime - totalActualTime;
  }
}

/// Project with detailed statistics
class ProjectWithDetailedStats {
  final Project project;
  final ProjectStats stats;

  const ProjectWithDetailedStats({
    required this.project,
    required this.stats,
  });
}

/// Point in time for project progress tracking
class ProjectProgressPoint {
  final DateTime date;
  final int completedTasks;
  final int totalTasks;
  final double completionPercentage;

  const ProjectProgressPoint({
    required this.date,
    required this.completedTasks,
    required this.totalTasks,
    required this.completionPercentage,
  });
}

/// Exception thrown when a project is not found
class ProjectNotFoundException implements Exception {
  final String message;
  const ProjectNotFoundException(this.message);  @override
  String toString() => 'ProjectNotFoundException: $message';
}

/// Exception thrown when a task is not found
class TaskNotFoundException implements Exception {
  final String message;
  const TaskNotFoundException(this.message);  @override
  String toString() => 'TaskNotFoundException: $message';
}
