import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/project.dart' as domain;
import '../../services/project_service.dart';
import '../../core/providers/core_providers.dart';
import '../../core/providers/error_state_manager.dart';

// Service provider
final projectServiceProvider = Provider<ProjectService>((ref) {
  final projectRepository = ref.read(projectRepositoryProvider);
  final taskRepository = ref.read(taskRepositoryProvider);
  return ProjectService(projectRepository, taskRepository);
});

// State providers
final projectsProvider = StateNotifierProvider<ProjectsNotifier, AsyncValue<List<domain.Project>>>(
  (ref) => ProjectsNotifier(ref.read(projectServiceProvider), ref),
);

final activeProjectsProvider = StateNotifierProvider<ActiveProjectsNotifier, AsyncValue<List<domain.Project>>>(
  (ref) => ActiveProjectsNotifier(ref.read(projectServiceProvider), ref),
);

final selectedProjectProvider = StateProvider<domain.Project?>((ref) => null);

// Single project provider by ID
final projectProvider = FutureProvider.family<domain.Project?, String>((ref, projectId) async {
  final projectService = ref.read(projectServiceProvider);
  return await projectService.getProjectById(projectId);
});

final projectStatsProvider = FutureProvider.family<ProjectStats, String>((ref, projectId) async {
  final projectService = ref.read(projectServiceProvider);
  return await projectService.getProjectStats(projectId);
});

final projectsWithStatsProvider = FutureProvider<List<ProjectWithDetailedStats>>((ref) async {
  final projectService = ref.read(projectServiceProvider);
  return await projectService.getProjectsWithDetailedStats();
});

final projectsAtRiskProvider = FutureProvider<List<domain.Project>>((ref) async {
  final projectService = ref.read(projectServiceProvider);
  return await projectService.getProjectsAtRisk();
});

// Project form state
final projectFormProvider = StateNotifierProvider<ProjectFormNotifier, ProjectFormState>(
  (ref) => ProjectFormNotifier(),
);

/// Notifier for managing all projects
class ProjectsNotifier extends StateNotifier<AsyncValue<List<domain.Project>>> {
  final ProjectService _projectService;
  final Ref _ref;

  ProjectsNotifier(this._projectService, this._ref) : super(const AsyncValue.loading()) {
    loadProjects();
  }

  Future<void> loadProjects() async {
    try {
      state = const AsyncValue.loading();
      final projects = await _projectService.getAllProjects();
      state = AsyncValue.data(projects);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      
      // Report to global error state with appropriate context
      _ref.reportError(
        error,
        code: 'project_operation_failed',
        severity: ErrorSeverity.error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> createProject({
    required String name,
    String? description,
    String color = '#2196F3',
    DateTime? deadline,
  }) async {
    try {
      await _projectService.createProject(
        name: name,
        description: description,
        color: color,
        deadline: deadline,
      );
      await loadProjects();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      
      // Report to global error state with appropriate context
      _ref.reportError(
        error,
        code: 'project_operation_failed',
        severity: ErrorSeverity.error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> updateProject(domain.Project project) async {
    try {
      await _projectService.updateProject(project);
      await loadProjects();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      
      // Report to global error state with appropriate context
      _ref.reportError(
        error,
        code: 'project_operation_failed',
        severity: ErrorSeverity.error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _projectService.deleteProject(projectId);
      await loadProjects();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      
      // Report to global error state with appropriate context
      _ref.reportError(
        error,
        code: 'project_operation_failed',
        severity: ErrorSeverity.error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> archiveProject(String projectId) async {
    try {
      await _projectService.archiveProject(projectId);
      await loadProjects();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      
      // Report to global error state with appropriate context
      _ref.reportError(
        error,
        code: 'project_operation_failed',
        severity: ErrorSeverity.error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> unarchiveProject(String projectId) async {
    try {
      await _projectService.unarchiveProject(projectId);
      await loadProjects();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      
      // Report to global error state with appropriate context
      _ref.reportError(
        error,
        code: 'project_operation_failed',
        severity: ErrorSeverity.error,
        stackTrace: stackTrace,
      );
    }
  }
}

/// Notifier for managing active projects
class ActiveProjectsNotifier extends StateNotifier<AsyncValue<List<domain.Project>>> {
  final ProjectService _projectService;
  final Ref _ref;

  ActiveProjectsNotifier(this._projectService, this._ref) : super(const AsyncValue.loading()) {
    loadActiveProjects();
  }

  Future<void> loadActiveProjects() async {
    try {
      state = const AsyncValue.loading();
      final projects = await _projectService.getActiveProjects();
      state = AsyncValue.data(projects);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      
      // Report to global error state with appropriate context
      _ref.reportError(
        error,
        code: 'project_operation_failed',
        severity: ErrorSeverity.error,
        stackTrace: stackTrace,
      );
    }
  }

  void refresh() {
    loadActiveProjects();
  }
}

/// State for project form
class ProjectFormState {
  final String name;
  final String description;
  final String color;
  final DateTime? deadline;
  final bool isLoading;
  final String? error;

  const ProjectFormState({
    this.name = '',
    this.description = '',
    this.color = '#2196F3',
    this.deadline,
    this.isLoading = false,
    this.error,
  });

  ProjectFormState copyWith({
    String? name,
    String? description,
    String? color,
    DateTime? deadline,
    bool? isLoading,
    String? error,
  }) {
    return ProjectFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      deadline: deadline ?? this.deadline,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isValid => name.trim().isNotEmpty;
}

/// Notifier for project form state
class ProjectFormNotifier extends StateNotifier<ProjectFormState> {
  ProjectFormNotifier() : super(const ProjectFormState());

  void updateName(String name) {
    state = state.copyWith(name: name, error: null);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateColor(String color) {
    state = state.copyWith(color: color);
  }

  void updateDeadline(DateTime? deadline) {
    state = state.copyWith(deadline: deadline);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void reset() {
    state = const ProjectFormState();
  }

  void loadProject(domain.Project project) {
    state = ProjectFormState(
      name: project.name,
      description: project.description ?? '',
      color: project.color,
      deadline: project.deadline,
    );
  }
}
