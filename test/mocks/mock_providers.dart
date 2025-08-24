import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import '../test_helpers/test_data_helper.dart';

/// Mock providers for golden tests
class MockProviders {
  /// Mock project-related providers
  static List<Override> get projectProviders {
    return [
      // Mock project stats provider
      projectStatsProvider.overrideWith((ref, projectId) async {
        return TestDataHelper.createProjectStats(projectId);
      }),
      
      // Mock projects list provider
      projectsProvider.overrideWith((ref) async {
        return TestDataHelper.createTestProjects();
      }),
      
      // Mock project provider
      projectProvider.overrideWith((ref, projectId) async {
        final projects = TestDataHelper.createTestProjects();
        return projects.firstWhere((p) => p.id == projectId);
      }),
    ];
  }

  /// Mock task-related providers
  static List<Override> get taskProviders {
    return [
      // Mock tasks provider
      tasksProvider.overrideWith((ref) async {
        return TestDataHelper.createTestTasks();
      }),
      
      // Mock task provider
      taskProvider.overrideWith((ref, taskId) async {
        final tasks = TestDataHelper.createTestTasks();
        return tasks.firstWhere((t) => t.id == taskId);
      }),
      
      // Mock project tasks provider
      projectTasksProvider.overrideWith((ref, projectId) async {
        final tasks = TestDataHelper.createTestTasks();
        return tasks.where((t) => t.projectId == projectId).toList();
      }),
    ];
  }

  /// Mock analytics-related providers
  static List<Override> get analyticsProviders {
    return [
      // Mock analytics data provider
      analyticsDataProvider.overrideWith((ref) async {
        return TestDataHelper.createAnalyticsData();
      }),
      
      // Mock productivity metrics provider
      productivityMetricsProvider.overrideWith((ref, dateRange) async {
        return ProductivityMetrics(
          totalTasks: 127,
          completedTasks: 89,
          completionRate: 0.7,
          averageTaskTime: const Duration(hours: 2),
          productivityScore: 85.5,
          dailyMetrics: List.generate(7, (index) => DailyMetrics(
            date: DateTime.now().subtract(Duration(days: 6 - index)),
            tasksCompleted: 8 + (index % 5),
            timeSpent: Duration(hours: 4 + (index % 3)),
            productivityScore: 75.0 + (index * 2.5),
          )),
        );
      }),
      
      // Mock task completion trends provider
      taskCompletionTrendsProvider.overrideWith((ref, period) async {
        return List.generate(30, (index) => TaskCompletionTrend(
          date: DateTime.now().subtract(Duration(days: 29 - index)),
          completed: 5 + (index % 8),
          created: 6 + (index % 10),
        ));
      }),
      
      // Mock project analytics provider
      projectAnalyticsProvider.overrideWith((ref, projectId) async {
        return ProjectAnalytics(
          projectId: projectId,
          totalTasks: 45,
          completedTasks: 32,
          averageTaskDuration: const Duration(hours: 3),
          completionVelocity: 2.5,
          burndownData: List.generate(14, (index) => BurndownPoint(
            date: DateTime.now().subtract(Duration(days: 13 - index)),
            remaining: 45 - (index * 3),
            completed: index * 3,
          )),
        );
      }),
      
      // Mock heatmap data provider
      taskHeatmapProvider.overrideWith((ref, dateRange) async {
        final data = TestDataHelper.createAnalyticsData();
        return (data['heatmapData'] as List<Map<String, dynamic>>)
            .map((item) => TaskHeatmapEntry(
                  date: item['date'] as DateTime,
                  taskCount: item['count'] as int,
                  intensity: (item['count'] as int) / 4.0,
                ))
            .toList();
      }),
    ];
  }

  /// Mock theme-related providers
  static List<Override> get themeProviders {
    return [
      // Mock current theme provider
      currentThemeProvider.overrideWith((ref) {
        return 'dracula_ide_dark'; // Default theme for tests
      }),
      
      // Mock available themes provider
      availableThemesProvider.overrideWith((ref) {
        return [
          'dracula_ide_dark',
          'dracula_ide',
          'matrix_dark',
          'matrix',
          'vegeta_blue_dark',
          'vegeta_blue',
        ];
      }),
    ];
  }

  /// Mock user preferences providers
  static List<Override> get userPreferencesProviders {
    return [
      // Mock user settings provider
      userSettingsProvider.overrideWith((ref) async {
        return UserSettings(
          themeId: 'dracula_ide_dark',
          language: 'en',
          dateFormat: 'MM/dd/yyyy',
          timeFormat: '12h',
          notifications: true,
          soundEnabled: true,
          vibrationEnabled: true,
          autoBackup: true,
          syncEnabled: false,
        );
      }),
      
      // Mock accessibility settings provider
      accessibilitySettingsProvider.overrideWith((ref) async {
        return AccessibilitySettings(
          textScaling: 1.0,
          highContrast: false,
          reduceMotion: false,
          screenReader: false,
          largeText: false,
        );
      }),
    ];
  }

  /// All mock providers combined
  static List<Override> get allProviders {
    return [
      ...projectProviders,
      ...taskProviders,
      ...analyticsProviders,
      ...themeProviders,
      ...userPreferencesProviders,
    ];
  }
}

// Provider declarations (these would normally be in your actual provider files)

// Project providers
final projectsProvider = FutureProvider<List<Project>>((ref) async {
  throw UnimplementedError('Use mock in tests');
});

final projectProvider = FutureProvider.family<Project, String>((ref, id) async {
  throw UnimplementedError('Use mock in tests');
});

final projectStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  throw UnimplementedError('Use mock in tests');
});

// Task providers
final tasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  throw UnimplementedError('Use mock in tests');
});

final taskProvider = FutureProvider.family<TaskModel, String>((ref, id) async {
  throw UnimplementedError('Use mock in tests');
});

final projectTasksProvider = FutureProvider.family<List<TaskModel>, String>((ref, projectId) async {
  throw UnimplementedError('Use mock in tests');
});

// Analytics providers
final analyticsDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  throw UnimplementedError('Use mock in tests');
});

final productivityMetricsProvider = FutureProvider.family<ProductivityMetrics, DateRange>((ref, range) async {
  throw UnimplementedError('Use mock in tests');
});

final taskCompletionTrendsProvider = FutureProvider.family<List<TaskCompletionTrend>, String>((ref, period) async {
  throw UnimplementedError('Use mock in tests');
});

final projectAnalyticsProvider = FutureProvider.family<ProjectAnalytics, String>((ref, projectId) async {
  throw UnimplementedError('Use mock in tests');
});

final taskHeatmapProvider = FutureProvider.family<List<TaskHeatmapEntry>, DateRange>((ref, range) async {
  throw UnimplementedError('Use mock in tests');
});

// Theme providers
final currentThemeProvider = StateProvider<String>((ref) {
  throw UnimplementedError('Use mock in tests');
});

final availableThemesProvider = Provider<List<String>>((ref) {
  throw UnimplementedError('Use mock in tests');
});

// User preferences providers
final userSettingsProvider = FutureProvider<UserSettings>((ref) async {
  throw UnimplementedError('Use mock in tests');
});

final accessibilitySettingsProvider = FutureProvider<AccessibilitySettings>((ref) async {
  throw UnimplementedError('Use mock in tests');
});

// Mock data classes
class ProductivityMetrics {
  final int totalTasks;
  final int completedTasks;
  final double completionRate;
  final Duration averageTaskTime;
  final double productivityScore;
  final List<DailyMetrics> dailyMetrics;

  ProductivityMetrics({
    required this.totalTasks,
    required this.completedTasks,
    required this.completionRate,
    required this.averageTaskTime,
    required this.productivityScore,
    required this.dailyMetrics,
  });
}

class DailyMetrics {
  final DateTime date;
  final int tasksCompleted;
  final Duration timeSpent;
  final double productivityScore;

  DailyMetrics({
    required this.date,
    required this.tasksCompleted,
    required this.timeSpent,
    required this.productivityScore,
  });
}

class TaskCompletionTrend {
  final DateTime date;
  final int completed;
  final int created;

  TaskCompletionTrend({
    required this.date,
    required this.completed,
    required this.created,
  });
}

class ProjectAnalytics {
  final String projectId;
  final int totalTasks;
  final int completedTasks;
  final Duration averageTaskDuration;
  final double completionVelocity;
  final List<BurndownPoint> burndownData;

  ProjectAnalytics({
    required this.projectId,
    required this.totalTasks,
    required this.completedTasks,
    required this.averageTaskDuration,
    required this.completionVelocity,
    required this.burndownData,
  });
}

class BurndownPoint {
  final DateTime date;
  final int remaining;
  final int completed;

  BurndownPoint({
    required this.date,
    required this.remaining,
    required this.completed,
  });
}

class TaskHeatmapEntry {
  final DateTime date;
  final int taskCount;
  final double intensity;

  TaskHeatmapEntry({
    required this.date,
    required this.taskCount,
    required this.intensity,
  });
}

class UserSettings {
  final String themeId;
  final String language;
  final String dateFormat;
  final String timeFormat;
  final bool notifications;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool autoBackup;
  final bool syncEnabled;

  UserSettings({
    required this.themeId,
    required this.language,
    required this.dateFormat,
    required this.timeFormat,
    required this.notifications,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.autoBackup,
    required this.syncEnabled,
  });
}

class AccessibilitySettings {
  final double textScaling;
  final bool highContrast;
  final bool reduceMotion;
  final bool screenReader;
  final bool largeText;

  AccessibilitySettings({
    required this.textScaling,
    required this.highContrast,
    required this.reduceMotion,
    required this.screenReader,
    required this.largeText,
  });
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({
    required this.start,
    required this.end,
  });
}