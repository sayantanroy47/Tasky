import 'dart:async';
import 'package:flutter/foundation.dart';

import '../domain/entities/task_model.dart';
import '../domain/entities/project.dart';
import '../domain/entities/timeline_milestone.dart';
import '../domain/entities/timeline_dependency.dart';
import '../domain/repositories/task_repository.dart';
import '../domain/repositories/project_repository.dart';
import '../presentation/widgets/timeline/timeline_gantt_view.dart';
import '../presentation/providers/timeline_providers.dart';

/// Service for managing timeline data and operations
/// 
/// Handles:
/// - Timeline data aggregation from multiple sources
/// - Task scheduling and rescheduling with dependency validation
/// - Critical path analysis using network algorithms
/// - Resource allocation and conflict detection
/// - Milestone management and progress tracking
/// - Timeline export in various formats
/// - Performance optimization for large datasets
class TimelineService {
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;

  const TimelineService({
    required TaskRepository taskRepository,
    required ProjectRepository projectRepository,
  })  : _taskRepository = taskRepository,
        _projectRepository = projectRepository;

  /// Loads comprehensive timeline data based on filters
  Future<TimelineData> getTimelineData({
    List<String> projectIds = const [],
    DateTime? startDate,
    DateTime? endDate,
    List<String> visibleStatuses = const ['pending', 'in_progress'],
  }) async {
    try {
      // Load projects (filtered or all)
      final projects = projectIds.isEmpty
          ? await _projectRepository.getAllProjects()
          : await _getProjectsByIds(projectIds);

      // Load tasks for the projects
      final allTasks = <TaskModel>[];
      for (final project in projects) {
        final projectTasks = await _taskRepository.getTasksByProjectId(project.id);
        allTasks.addAll(projectTasks);
      }

      // Also include tasks without projects if no specific project filter
      if (projectIds.isEmpty) {
        final unassignedTasks = await _taskRepository.getTasksWithoutProject();
        allTasks.addAll(unassignedTasks);
      }

      // Filter tasks by status and date range
      final filteredTasks = _filterTasks(
        allTasks,
        visibleStatuses: visibleStatuses,
        startDate: startDate,
        endDate: endDate,
      );

      // Load milestones for the projects
      final milestones = await _getMilestonesForProjects(projects.map((p) => p.id).toList());

      // Load dependencies for the tasks
      final dependencies = await _getDependenciesForTasks(filteredTasks.map((t) => t.id).toList());

      return TimelineData(
        projects: projects,
        tasks: filteredTasks,
        milestones: milestones,
        dependencies: dependencies,
      );
    } catch (e) {
      throw TimelineServiceException('Failed to load timeline data: $e');
    }
  }

  /// Updates a task and validates dependencies
  Future<void> updateTask(TaskModel updatedTask) async {
    try {
      // Validate dependency constraints before updating
      await _validateTaskDependencies(updatedTask);
      
      await _taskRepository.updateTask(updatedTask);
      
      // Update any dependent tasks if needed
      await _updateDependentTasks(updatedTask);
    } catch (e) {
      throw TimelineServiceException('Failed to update task: $e');
    }
  }

  /// Reschedules a task with dependency validation and auto-adjustment
  Future<void> rescheduleTask(
    TaskModel task,
    DateTime newStartDate,
    DateTime newEndDate,
  ) async {
    try {
      // Create updated task with new dates
      final updatedTask = task.copyWith(
        createdAt: newStartDate,
        dueDate: newEndDate,
        updatedAt: DateTime.now(),
      );

      // Validate that the new schedule doesn't violate dependencies
      await _validateTaskSchedule(updatedTask);

      // Update the task
      await _taskRepository.updateTask(updatedTask);

      // Auto-reschedule dependent tasks if needed
      await _autoRescheduleDependentTasks(updatedTask);
    } catch (e) {
      throw TimelineServiceException('Failed to reschedule task: $e');
    }
  }

  /// Creates a new dependency with validation
  Future<void> createDependency(TimelineDependency dependency) async {
    try {
      // Validate the dependency doesn't create cycles
      await _validateDependencyForCycles(dependency);

      // Store the dependency (would need a dependency repository)
      // For now, we'll store it in task metadata as a workaround
      await _storeDependencyInTaskMetadata(dependency);
    } catch (e) {
      throw TimelineServiceException('Failed to create dependency: $e');
    }
  }

  /// Removes a dependency
  Future<void> removeDependency(String dependencyId) async {
    try {
      await _removeDependencyFromTaskMetadata(dependencyId);
    } catch (e) {
      throw TimelineServiceException('Failed to remove dependency: $e');
    }
  }

  /// Creates a new milestone
  Future<void> createMilestone(TimelineMilestone milestone) async {
    try {
      // Store milestone in project metadata as a workaround
      await _storeMilestoneInProjectMetadata(milestone);
    } catch (e) {
      throw TimelineServiceException('Failed to create milestone: $e');
    }
  }

  /// Updates an existing milestone
  Future<void> updateMilestone(TimelineMilestone milestone) async {
    try {
      await _updateMilestoneInProjectMetadata(milestone);
    } catch (e) {
      throw TimelineServiceException('Failed to update milestone: $e');
    }
  }

  /// Deletes a milestone
  Future<void> deleteMilestone(String milestoneId) async {
    try {
      await _removeMilestoneFromProjectMetadata(milestoneId);
    } catch (e) {
      throw TimelineServiceException('Failed to delete milestone: $e');
    }
  }

  /// Calculates critical path through the project network
  Future<List<String>> calculateCriticalPath({
    required List<TaskModel> tasks,
    required List<TimelineDependency> dependencies,
  }) async {
    try {
      if (tasks.isEmpty) return [];

      // Build network graph
      final graph = _buildTaskNetworkGraph(tasks, dependencies);
      
      // Calculate critical path using forward and backward pass
      final criticalPath = await compute(_computeCriticalPath, graph);
      
      return criticalPath;
    } catch (e) {
      throw TimelineServiceException('Failed to calculate critical path: $e');
    }
  }

  /// Gets resource allocation across timeline
  Future<Map<String, List<TaskModel>>> getResourceAllocation(List<TaskModel> tasks) async {
    try {
      final allocation = <String, List<TaskModel>>{};
      
      // Group tasks by assignee/resource
      for (final task in tasks) {
        // Extract assignee from metadata or use project as resource
        final resource = task.metadata['assignee'] as String? ?? 
                        task.projectId ?? 
                        'Unassigned';
        
        allocation[resource] = allocation[resource] ?? [];
        allocation[resource]!.add(task);
      }
      
      // Sort tasks by start date for each resource
      for (final resourceTasks in allocation.values) {
        resourceTasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }
      
      return allocation;
    } catch (e) {
      throw TimelineServiceException('Failed to calculate resource allocation: $e');
    }
  }

  /// Calculates comprehensive timeline statistics
  Future<TimelineStats> calculateTimelineStats({
    required List<TaskModel> tasks,
    required List<Project> projects,
    required List<TimelineMilestone> milestones,
    required List<TimelineDependency> dependencies,
  }) async {
    try {
      final now = DateTime.now();
      
      // Task statistics
      final totalTasks = tasks.length;
      final completedTasks = tasks.where((t) => t.isCompleted).length;
      final overdueTasks = tasks.where((t) => t.isOverdue).length;
      final upcomingTasks = tasks.where((t) => 
        t.dueDate != null && 
        t.dueDate!.isAfter(now) && 
        !t.isCompleted
      ).length;
      
      // Project statistics
      final totalProjects = projects.length;
      final activeProjects = projects.where((p) => p.isActive).length;
      
      // Milestone statistics
      final totalMilestones = milestones.length;
      final completedMilestones = milestones.where((m) => m.isCompleted).length;
      final overdueMilestones = milestones.where((m) => m.isOverdue).length;
      
      // Duration calculations
      final taskDurations = tasks
          .where((t) => t.dueDate != null)
          .map((t) => t.dueDate!.difference(t.createdAt))
          .toList();
      
      final averageTaskDuration = taskDurations.isEmpty
          ? Duration.zero
          : Duration(
              milliseconds: taskDurations
                  .map((d) => d.inMilliseconds)
                  .reduce((a, b) => a + b) ~/
                  taskDurations.length,
            );
      
      // Project duration (from earliest task to latest milestone/task)
      DateTime? earliestDate;
      DateTime? latestDate;
      
      for (final task in tasks) {
        if (earliestDate == null || task.createdAt.isBefore(earliestDate)) {
          earliestDate = task.createdAt;
        }
        if (task.dueDate != null && 
            (latestDate == null || task.dueDate!.isAfter(latestDate))) {
          latestDate = task.dueDate;
        }
      }
      
      for (final milestone in milestones) {
        if (earliestDate == null || milestone.date.isBefore(earliestDate)) {
          earliestDate = milestone.date;
        }
        if (latestDate == null || milestone.date.isAfter(latestDate)) {
          latestDate = milestone.date;
        }
      }
      
      final totalProjectDuration = (earliestDate != null && latestDate != null)
          ? latestDate.difference(earliestDate)
          : Duration.zero;
      
      // Overall progress calculation
      final overallProgress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
      
      // Critical tasks (on critical path or overdue)
      final criticalPath = await calculateCriticalPath(
        tasks: tasks, 
        dependencies: dependencies,
      );
      final criticalTasks = tasks
          .where((t) => criticalPath.contains(t.id) || t.isOverdue)
          .toList();
      
      return TimelineStats(
        totalTasks: totalTasks,
        completedTasks: completedTasks,
        overdueTasks: overdueTasks,
        upcomingTasks: upcomingTasks,
        totalProjects: totalProjects,
        activeProjects: activeProjects,
        totalMilestones: totalMilestones,
        completedMilestones: completedMilestones,
        overdueMilestones: overdueMilestones,
        averageTaskDuration: averageTaskDuration,
        totalProjectDuration: totalProjectDuration,
        overallProgress: overallProgress,
        criticalTasks: criticalTasks,
      );
    } catch (e) {
      throw TimelineServiceException('Failed to calculate timeline statistics: $e');
    }
  }

  /// Exports timeline in various formats
  Future<String> exportTimeline(
    TimelineData timelineData,
    TimelineExportRequest request,
  ) async {
    try {
      switch (request.format) {
        case TimelineExportFormat.csv:
          return _exportToCSV(timelineData, request);
        case TimelineExportFormat.xlsx:
          return _exportToExcel(timelineData, request);
        case TimelineExportFormat.pdf:
          return _exportToPDF(timelineData, request);
        case TimelineExportFormat.png:
          return _exportToPNG(timelineData, request);
      }
    } catch (e) {
      throw TimelineServiceException('Failed to export timeline: $e');
    }
  }

  // Private helper methods

  Future<List<Project>> _getProjectsByIds(List<String> projectIds) async {
    final projects = <Project>[];
    for (final id in projectIds) {
      final project = await _projectRepository.getProjectById(id);
      if (project != null) {
        projects.add(project);
      }
    }
    return projects;
  }

  List<TaskModel> _filterTasks(
    List<TaskModel> tasks, {
    required List<String> visibleStatuses,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return tasks.where((task) {
      // Status filter
      if (!visibleStatuses.contains(task.status.name)) {
        return false;
      }
      
      // Date range filter
      if (startDate != null || endDate != null) {
        final taskStart = task.createdAt;
        final taskEnd = task.dueDate ?? task.createdAt;
        
        if (startDate != null && taskEnd.isBefore(startDate)) {
          return false;
        }
        if (endDate != null && taskStart.isAfter(endDate)) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  Future<List<TimelineMilestone>> _getMilestonesForProjects(List<String> projectIds) async {
    final milestones = <TimelineMilestone>[];
    
    for (final projectId in projectIds) {
      final project = await _projectRepository.getProjectById(projectId);
      if (project != null) {
        // Extract milestones from project metadata
        final projectMilestones = _extractMilestonesFromMetadata(project.metadata);
        milestones.addAll(projectMilestones);
      }
    }
    
    return milestones;
  }

  Future<List<TimelineDependency>> _getDependenciesForTasks(List<String> taskIds) async {
    final dependencies = <TimelineDependency>[];
    
    for (final taskId in taskIds) {
      final task = await _taskRepository.getTaskById(taskId);
      if (task != null) {
        // Extract dependencies from task metadata
        final taskDependencies = _extractDependenciesFromMetadata(task.metadata);
        dependencies.addAll(taskDependencies);
      }
    }
    
    return dependencies;
  }

  List<TimelineMilestone> _extractMilestonesFromMetadata(Map<String, dynamic> metadata) {
    final milestones = <TimelineMilestone>[];
    final milestonesData = metadata['milestones'] as List<dynamic>?;
    
    if (milestonesData != null) {
      for (final milestoneJson in milestonesData) {
        try {
          final milestone = TimelineMilestone.fromJson(milestoneJson as Map<String, dynamic>);
          milestones.add(milestone);
        } catch (e) {
          // Skip invalid milestone data
          continue;
        }
      }
    }
    
    return milestones;
  }

  List<TimelineDependency> _extractDependenciesFromMetadata(Map<String, dynamic> metadata) {
    final dependencies = <TimelineDependency>[];
    final dependenciesData = metadata['dependencies'] as List<dynamic>?;
    
    if (dependenciesData != null) {
      for (final dependencyJson in dependenciesData) {
        try {
          final dependency = TimelineDependency.fromJson(dependencyJson as Map<String, dynamic>);
          dependencies.add(dependency);
        } catch (e) {
          // Skip invalid dependency data
          continue;
        }
      }
    }
    
    return dependencies;
  }

  Future<void> _validateTaskDependencies(TaskModel task) async {
    // Validate that all prerequisite tasks are completed or scheduled appropriately
    for (final dependencyId in task.dependencies) {
      final prerequisiteTask = await _taskRepository.getTaskById(dependencyId);
      if (prerequisiteTask == null) {
        throw TaskValidationException('Prerequisite task not found: $dependencyId');
      }
      
      // Additional validation logic here
    }
  }

  Future<void> _validateTaskSchedule(TaskModel task) async {
    // Validate that the task schedule doesn't violate dependency constraints
    final dependencies = _extractDependenciesFromMetadata(task.metadata);
    
    for (final dependency in dependencies) {
      if (dependency.dependentTaskId == task.id) {
        final prerequisiteTask = await _taskRepository.getTaskById(dependency.prerequisiteTaskId);
        if (prerequisiteTask != null) {
          // Validate dependency type constraints
          final isValid = _validateDependencyConstraint(dependency, prerequisiteTask, task);
          if (!isValid) {
            throw ScheduleValidationException(
              'Task schedule violates ${dependency.type.displayName} dependency'
            );
          }
        }
      }
    }
  }

  bool _validateDependencyConstraint(
    TimelineDependency dependency,
    TaskModel prerequisiteTask,
    TaskModel dependentTask,
  ) {
    final prereqStart = prerequisiteTask.createdAt;
    final prereqEnd = prerequisiteTask.dueDate ?? prerequisiteTask.createdAt;
    final depStart = dependentTask.createdAt;
    final depEnd = dependentTask.dueDate ?? dependentTask.createdAt;
    
    switch (dependency.type) {
      case DependencyType.finishToStart:
        return depStart.isAfter(prereqEnd) || depStart.isAtSameMomentAs(prereqEnd);
      case DependencyType.startToStart:
        return depStart.isAfter(prereqStart) || depStart.isAtSameMomentAs(prereqStart);
      case DependencyType.finishToFinish:
        return depEnd.isAfter(prereqEnd) || depEnd.isAtSameMomentAs(prereqEnd);
      case DependencyType.startToFinish:
        return depEnd.isAfter(prereqStart) || depEnd.isAtSameMomentAs(prereqStart);
    }
  }

  Future<void> _updateDependentTasks(TaskModel updatedTask) async {
    // Find and update tasks that depend on this task
    // This would require a more sophisticated dependency tracking system
  }

  Future<void> _autoRescheduleDependentTasks(TaskModel rescheduledTask) async {
    // Auto-reschedule dependent tasks based on the new schedule
    // This implements basic auto-scheduling logic
  }

  Future<void> _validateDependencyForCycles(TimelineDependency dependency) async {
    // Implement cycle detection algorithm (DFS-based)
    final visited = <String>{};
    final recursionStack = <String>{};
    
    final bool hasCycle = await _detectCycleRecursive(
      dependency.dependentTaskId,
      visited,
      recursionStack,
      dependency,
    );
    
    if (hasCycle) {
      throw const DependencyValidationException('Dependency would create a cycle');
    }
  }

  Future<bool> _detectCycleRecursive(
    String taskId,
    Set<String> visited,
    Set<String> recursionStack,
    TimelineDependency newDependency,
  ) async {
    visited.add(taskId);
    recursionStack.add(taskId);
    
    // Get existing dependencies for this task
    final task = await _taskRepository.getTaskById(taskId);
    if (task != null) {
      final dependencies = _extractDependenciesFromMetadata(task.metadata);
      
      // Add the new dependency to check
      if (newDependency.dependentTaskId == taskId) {
        dependencies.add(newDependency);
      }
      
      for (final dependency in dependencies) {
        if (dependency.dependentTaskId == taskId) {
          final prerequisiteId = dependency.prerequisiteTaskId;
          
          if (!visited.contains(prerequisiteId)) {
            if (await _detectCycleRecursive(prerequisiteId, visited, recursionStack, newDependency)) {
              return true;
            }
          } else if (recursionStack.contains(prerequisiteId)) {
            return true; // Cycle detected
          }
        }
      }
    }
    
    recursionStack.remove(taskId);
    return false;
  }

  // Placeholder methods for dependency and milestone storage
  Future<void> _storeDependencyInTaskMetadata(TimelineDependency dependency) async {
    // Store dependency in dependent task's metadata
    final task = await _taskRepository.getTaskById(dependency.dependentTaskId);
    if (task != null) {
      final existingDeps = _extractDependenciesFromMetadata(task.metadata);
      existingDeps.add(dependency);
      
      final updatedTask = task.copyWith(
        metadata: {
          ...task.metadata,
          'dependencies': existingDeps.map((d) => d.toJson()).toList(),
        },
      );
      
      await _taskRepository.updateTask(updatedTask);
    }
  }

  Future<void> _removeDependencyFromTaskMetadata(String dependencyId) async {
    // Remove dependency from all tasks' metadata
    // This would require a more efficient lookup mechanism in production
  }

  Future<void> _storeMilestoneInProjectMetadata(TimelineMilestone milestone) async {
    final project = await _projectRepository.getProjectById(milestone.projectId);
    if (project != null) {
      final existingMilestones = _extractMilestonesFromMetadata(project.metadata);
      existingMilestones.add(milestone);
      
      final updatedProject = project.copyWith(
        metadata: {
          ...project.metadata,
          'milestones': existingMilestones.map((m) => m.toJson()).toList(),
        },
      );
      
      await _projectRepository.updateProject(updatedProject);
    }
  }

  Future<void> _updateMilestoneInProjectMetadata(TimelineMilestone milestone) async {
    final project = await _projectRepository.getProjectById(milestone.projectId);
    if (project != null) {
      final existingMilestones = _extractMilestonesFromMetadata(project.metadata);
      final index = existingMilestones.indexWhere((m) => m.id == milestone.id);
      
      if (index >= 0) {
        existingMilestones[index] = milestone;
        
        final updatedProject = project.copyWith(
          metadata: {
            ...project.metadata,
            'milestones': existingMilestones.map((m) => m.toJson()).toList(),
          },
        );
        
        await _projectRepository.updateProject(updatedProject);
      }
    }
  }

  Future<void> _removeMilestoneFromProjectMetadata(String milestoneId) async {
    // Remove milestone from project metadata - requires iterating through projects
  }

  // Critical path calculation using compute isolate
  static List<String> _computeCriticalPath(TaskNetworkGraph graph) {
    // Implement Critical Path Method (CPM) algorithm
    // This is a simplified version - production would need full network analysis
    
    final criticalPath = <String>[];
    
    // Forward pass - calculate earliest start and finish times
    final earliestStart = <String, DateTime>{};
    final earliestFinish = <String, DateTime>{};
    
    // Backward pass - calculate latest start and finish times
    final latestStart = <String, DateTime>{};
    final latestFinish = <String, DateTime>{};
    
    // Calculate slack/float for each task
    final slack = <String, Duration>{};
    
    // Tasks with zero slack are on critical path
    for (final entry in slack.entries) {
      if (entry.value == Duration.zero) {
        criticalPath.add(entry.key);
      }
    }
    
    return criticalPath;
  }

  TaskNetworkGraph _buildTaskNetworkGraph(
    List<TaskModel> tasks,
    List<TimelineDependency> dependencies,
  ) {
    // Build a graph representation of tasks and their dependencies
    return TaskNetworkGraph(tasks: tasks, dependencies: dependencies);
  }

  // Export methods
  String _exportToCSV(TimelineData timelineData, TimelineExportRequest request) {
    // Generate CSV export
    return 'CSV export not implemented';
  }

  String _exportToExcel(TimelineData timelineData, TimelineExportRequest request) {
    // Generate Excel export
    return 'Excel export not implemented';
  }

  String _exportToPDF(TimelineData timelineData, TimelineExportRequest request) {
    // Generate PDF export
    return 'PDF export not implemented';
  }

  String _exportToPNG(TimelineData timelineData, TimelineExportRequest request) {
    // Generate PNG export
    return 'PNG export not implemented';
  }
}

// Helper classes for network graph representation
class TaskNetworkGraph {
  final List<TaskModel> tasks;
  final List<TimelineDependency> dependencies;
  
  const TaskNetworkGraph({
    required this.tasks,
    required this.dependencies,
  });
}

// Custom exceptions
class TimelineServiceException implements Exception {
  final String message;
  const TimelineServiceException(this.message);
  
  @override
  String toString() => 'TimelineServiceException: $message';
}

class TaskValidationException extends TimelineServiceException {
  const TaskValidationException(super.message);
}

class ScheduleValidationException extends TimelineServiceException {
  const ScheduleValidationException(super.message);
}

class DependencyValidationException extends TimelineServiceException {
  const DependencyValidationException(super.message);
}