import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';

/// Helper class to create consistent test data for golden tests
class TestDataHelper {
  /// Create a list of test projects with various states
  static List<Project> createTestProjects() {
    return [
      Project(
        id: 'project_1',
        name: 'Mobile App Development',
        description: 'Flutter task management app with advanced features',
        category: 'work', // Legacy field
        color: '#2196F3',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 15),
        isArchived: false,
      ),
      Project(
        id: 'project_2',
        name: 'Web Dashboard',
        description: 'Analytics dashboard for project management',
        category: 'work',
        color: '#4CAF50',
        createdAt: DateTime(2024, 1, 5),
        updatedAt: DateTime(2024, 1, 20),
        isArchived: false,
      ),
      Project(
        id: 'project_3',
        name: 'API Integration',
        description: 'RESTful API endpoints and documentation',
        category: 'technical',
        color: '#FF9800',
        createdAt: DateTime(2024, 1, 10),
        updatedAt: DateTime(2024, 1, 25),
        isArchived: false,
      ),
      Project(
        id: 'project_4',
        name: 'Personal Fitness',
        description: 'Health and fitness tracking goals',
        category: 'health',
        color: '#E91E63',
        createdAt: DateTime(2024, 1, 12),
        updatedAt: DateTime(2024, 1, 28),
        isArchived: false,
      ),
      Project(
        id: 'project_5',
        name: 'Learning Flutter',
        description: 'Advanced Flutter concepts and best practices',
        category: 'education',
        color: '#9C27B0',
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 30),
        isArchived: false,
      ),
      Project(
        id: 'project_6',
        name: 'Home Organization',
        description: 'Decluttering and organizing living spaces',
        category: 'personal',
        color: '#795548',
        createdAt: DateTime(2024, 1, 18),
        updatedAt: DateTime(2024, 2, 1),
        isArchived: true,
      ),
    ];
  }

  /// Create a list of test tasks with various states and priorities
  static List<TaskModel> createTestTasks() {
    return [
      // Pending tasks (formerly todo)
      TaskModel(
        id: 'task_1',
        title: 'Design user interface mockups',
        description: 'Create wireframes and high-fidelity mockups for the main screens',
        priority: TaskPriority.high,
        projectId: 'project_1',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        tags: const ['design', 'ui', 'mockups'],
        estimatedDuration: 480, // 8 hours in minutes
        dependencies: const [],
        subTasks: const [],
        metadata: const {},
      ),
      TaskModel(
        id: 'task_2',
        title: 'Implement authentication system',
        description: 'Set up user registration, login, and password reset functionality',
        priority: TaskPriority.urgent,
        projectId: 'project_1',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        tags: const ['backend', 'auth', 'security'],
        estimatedDuration: 720, // 12 hours in minutes
        dependencies: const [],
        subTasks: const [],
        metadata: const {},
      ),
      TaskModel(
        id: 'task_3',
        title: 'Write API documentation',
        description: 'Document all REST endpoints with examples and response formats',
        priority: TaskPriority.medium,
        projectId: 'project_3',
        dueDate: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
        tags: const ['documentation', 'api', 'rest'],
        estimatedDuration: 360, // 6 hours in minutes
        dependencies: const [],
        subTasks: const [],
        metadata: const {},
      ),
      // In Progress tasks
      TaskModel(
        id: 'task_4',
        title: 'Build dashboard components',
        description: 'Create reusable chart and metric components for the analytics dashboard',
        priority: TaskPriority.high,
        projectId: 'project_2',
        dueDate: DateTime.now().add(const Duration(days: 4)),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        tags: const ['frontend', 'components', 'charts'],
        estimatedDuration: 960, // 16 hours in minutes
        actualDuration: 480, // 8 hours in minutes
        dependencies: const [],
        subTasks: const [],
        metadata: const {},
      ),
      TaskModel(
        id: 'task_5',
        title: 'Set up database schema',
        description: 'Design and implement the database tables and relationships',
        priority: TaskPriority.medium,
        projectId: 'project_1',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
        tags: const ['database', 'schema', 'backend'],
        estimatedDuration: 600, // 10 hours in minutes
        actualDuration: 360, // 6 hours in minutes
        dependencies: const [],
        subTasks: const [],
        metadata: const {},
      ),
      // Completed tasks
      TaskModel(
        id: 'task_6',
        title: 'Research Flutter packages',
        description: 'Evaluate and select appropriate packages for the project',
        priority: TaskPriority.low,
        projectId: 'project_5',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        tags: const ['research', 'packages', 'flutter'],
        estimatedDuration: 240, // 4 hours in minutes
        actualDuration: 180, // 3 hours in minutes
        dependencies: const [],
        subTasks: const [],
        metadata: const {},
      ),
      TaskModel(
        id: 'task_7',
        title: 'Setup project structure',
        description: 'Create folder structure and initial configuration files',
        priority: TaskPriority.medium,
        projectId: 'project_1',
        dueDate: DateTime.now().subtract(const Duration(days: 3)),
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        completedAt: DateTime.now().subtract(const Duration(days: 3)),
        tags: const ['setup', 'structure', 'configuration'],
        estimatedDuration: 120, // 2 hours in minutes
        actualDuration: 120, // 2 hours in minutes
        dependencies: const [],
        subTasks: const [],
        metadata: const {},
      ),
      TaskModel(
        id: 'task_8',
        title: 'Morning workout routine',
        description: 'Complete 30-minute cardio and strength training session',
        priority: TaskPriority.medium,
        projectId: 'project_4',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
        tags: const ['fitness', 'cardio', 'strength'],
        estimatedDuration: 30, // 30 minutes
        actualDuration: 35, // 35 minutes
        dependencies: const [],
        subTasks: const [],
        metadata: const {},
      ),
    ];
  }

  /// Create mock analytics data
  static Map<String, dynamic> createAnalyticsData() {
    return {
      'totalTasks': 127,
      'completedTasks': 89,
      'inProgressTasks': 28,
      'todoTasks': 10,
      'productivity': [
        {'day': 'Mon', 'completed': 12},
        {'day': 'Tue', 'completed': 8},
        {'day': 'Wed', 'completed': 15},
        {'day': 'Thu', 'completed': 11},
        {'day': 'Fri', 'completed': 9},
        {'day': 'Sat', 'completed': 6},
        {'day': 'Sun', 'completed': 4},
      ],
      'projectProgress': [
        {'name': 'Mobile App', 'progress': 0.75, 'color': 0xFF2196F3},
        {'name': 'Web Dashboard', 'progress': 0.45, 'color': 0xFF4CAF50},
        {'name': 'API Integration', 'progress': 0.20, 'color': 0xFFFF9800},
      ],
      'heatmapData': List.generate(49, (index) => {
        'date': DateTime.now().subtract(Duration(days: 48 - index)),
        'count': (index % 5),
      }),
    };
  }

  /// Create mock project statistics
  static Map<String, dynamic> createProjectStats(String projectId) {
    final projects = createTestProjects();
    final project = projects.firstWhere((p) => p.id == projectId);
    final tasks = createTestTasks().where((t) => t.projectId == projectId).toList();
    
    return {
      'totalTasks': tasks.length,
      'completedTasks': tasks.where((t) => t.status == TaskStatus.completed).length,
      'inProgressTasks': tasks.where((t) => t.status == TaskStatus.inProgress).length,
      'pendingTasks': tasks.where((t) => t.status == TaskStatus.pending).length,
      'progress': tasks.isEmpty ? 0.0 : tasks.where((t) => t.status == TaskStatus.completed).length / tasks.length,
      'daysActive': DateTime.now().difference(project.createdAt).inDays,
    };
  }
}