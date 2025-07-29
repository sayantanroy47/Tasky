import '../entities/project.dart';

/// Abstract repository interface for project operations
/// 
/// This interface defines all the operations that can be performed on projects.
/// It follows the repository pattern to abstract data access logic from
/// business logic.
abstract class ProjectRepository {
  /// Gets all projects from the repository
  Future<List<Project>> getAllProjects();

  /// Gets only active (non-archived) projects
  Future<List<Project>> getActiveProjects();

  /// Gets a project by its unique identifier
  Future<Project?> getProjectById(String id);

  /// Creates a new project in the repository
  Future<void> createProject(Project project);

  /// Updates an existing project in the repository
  Future<void> updateProject(Project project);

  /// Deletes a project from the repository
  Future<void> deleteProject(String id);

  /// Archives a project (soft delete)
  Future<void> archiveProject(String id);

  /// Unarchives a project
  Future<void> unarchiveProject(String id);

  /// Gets projects with their task counts
  Future<List<ProjectWithStats>> getProjectsWithStats();

  /// Searches projects by name or description
  Future<List<Project>> searchProjects(String query);

  /// Gets projects with advanced filtering options
  Future<List<Project>> getProjectsWithFilter(ProjectFilter filter);

  /// Watches all projects (returns a stream for real-time updates)
  Stream<List<Project>> watchAllProjects();

  /// Watches active projects (returns a stream)
  Stream<List<Project>> watchActiveProjects();

  /// Watches a specific project (returns a stream)
  Stream<Project?> watchProjectById(String id);
}

/// Project with additional statistics
class ProjectWithStats {
  final Project project;
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;

  const ProjectWithStats({
    required this.project,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
  });

  /// Completion percentage (0.0 to 1.0)
  double get completionPercentage {
    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }

  /// Returns true if the project has overdue tasks
  bool get hasOverdueTasks => overdueTasks > 0;

  /// Returns true if the project is completed (all tasks done)
  bool get isCompleted => totalTasks > 0 && completedTasks == totalTasks;
}

/// Filter options for advanced project querying
class ProjectFilter {
  final bool? isArchived;
  final bool? hasDeadline;
  final bool? isOverdue;
  final DateTime? deadlineFrom;
  final DateTime? deadlineTo;
  final String? searchQuery;
  final ProjectSortBy sortBy;
  final bool sortAscending;

  const ProjectFilter({
    this.isArchived,
    this.hasDeadline,
    this.isOverdue,
    this.deadlineFrom,
    this.deadlineTo,
    this.searchQuery,
    this.sortBy = ProjectSortBy.createdAt,
    this.sortAscending = false,
  });

  /// Creates a copy of this filter with updated fields
  ProjectFilter copyWith({
    bool? isArchived,
    bool? hasDeadline,
    bool? isOverdue,
    DateTime? deadlineFrom,
    DateTime? deadlineTo,
    String? searchQuery,
    ProjectSortBy? sortBy,
    bool? sortAscending,
  }) {
    return ProjectFilter(
      isArchived: isArchived ?? this.isArchived,
      hasDeadline: hasDeadline ?? this.hasDeadline,
      isOverdue: isOverdue ?? this.isOverdue,
      deadlineFrom: deadlineFrom ?? this.deadlineFrom,
      deadlineTo: deadlineTo ?? this.deadlineTo,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  /// Returns true if any filter is applied
  bool get hasFilters {
    return isArchived != null ||
        hasDeadline != null ||
        isOverdue != null ||
        deadlineFrom != null ||
        deadlineTo != null ||
        (searchQuery != null && searchQuery!.isNotEmpty);
  }
}

/// Sorting options for projects
enum ProjectSortBy {
  createdAt,
  updatedAt,
  name,
  deadline,
  taskCount,
}

/// Extension to get display names for sort options
extension ProjectSortByExtension on ProjectSortBy {
  String get displayName {
    switch (this) {
      case ProjectSortBy.createdAt:
        return 'Created Date';
      case ProjectSortBy.updatedAt:
        return 'Updated Date';
      case ProjectSortBy.name:
        return 'Name';
      case ProjectSortBy.deadline:
        return 'Deadline';
      case ProjectSortBy.taskCount:
        return 'Task Count';
    }
  }
}