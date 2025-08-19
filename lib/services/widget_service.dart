import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../domain/entities/task_model.dart';
import '../domain/models/enums.dart';
import '../domain/repositories/task_repository.dart';

/// Service for managing home screen widgets
class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  static const MethodChannel _channel = MethodChannel('task_tracker/widgets');
  
  // Reference to the repository for task operations
  TaskRepository? _taskRepository;
  
  /// Initialize with task repository
  void setTaskRepository(TaskRepository repository) {
    _taskRepository = repository;
  }

  /// Initialize widget service
  Future<void> initialize() async {
    try {
      // Skip platform channel initialization for now - requires native implementation
      if (kDebugMode) {
        debugPrint('WidgetService: Skipping platform channel initialization (requires native implementation)');
      }
      // await _channel.invokeMethod('initialize');
      // _setupMethodCallHandler();
    } catch (e) {
      debugPrint('Error initializing WidgetService: $e');
    }
  }

  /// Get today's tasks data for widget
  Future<Map<String, dynamic>> _getTodayTasksData() async {
    try {
      // Get tasks from repository
      final todayTasks = _taskRepository != null 
        ? await _taskRepository!.getTasksDueToday()
        : <TaskModel>[];
      
      final taskData = todayTasks.map((task) => {
        'id': task.id,
        'title': task.title,
        'isCompleted': task.status == TaskStatus.completed,
        'priority': task.priority.name,
        'dueTime': task.dueDate?.toIso8601String(),
      }).toList();

      return {
        'tasks': taskData,
        'totalCount': todayTasks.length,
        'completedCount': todayTasks.where((t) => t.status == TaskStatus.completed).length,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error getting today tasks data: $e');
      return {'error': e.toString()};
    }
  }

  /// Get quick stats data for widget
  Future<Map<String, dynamic>> _getQuickStatsData() async {
    try {
      // Get stats from repository
      if (_taskRepository != null) {
        final todayTasks = await _taskRepository!.getTasksDueToday();
        final completedToday = todayTasks.where((task) => task.status == TaskStatus.completed).length;
        
        final allTasks = await _taskRepository!.getAllTasks();
        final completedWeek = allTasks.where((task) => 
          task.status == TaskStatus.completed && 
          task.completedAt != null &&
          task.completedAt!.isAfter(DateTime.now().subtract(const Duration(days: 7)))
        ).length;
        
        return {
          'todayCompleted': completedToday,
          'todayTotal': todayTasks.length,
          'weekCompleted': completedWeek,
          'weekTotal': allTasks.length,
          'currentStreak': await _calculateCompletionStreak(),
          'lastUpdated': DateTime.now().toIso8601String(),
        };
      }
      
      // Fallback data
      return {
        'todayCompleted': 0,
        'todayTotal': 0,
        'weekCompleted': 0,
        'weekTotal': 0,
        'currentStreak': 0,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error getting quick stats data: $e');
      return {'error': e.toString()};
    }
  }

  /// Get upcoming tasks data for widget
  Future<Map<String, dynamic>> _getUpcomingTasksData() async {
    try {
      // Get upcoming tasks from repository (next 7 days)
      final now = DateTime.now();
      final nextWeek = now.add(const Duration(days: 7));
      final upcomingTasks = _taskRepository != null 
        ? await _taskRepository!.getTasksByDateRange(now, nextWeek)
        : <TaskModel>[];
      
      final taskData = upcomingTasks.map((task) => {
        'id': task.id,
        'title': task.title,
        'dueDate': task.dueDate?.toIso8601String(),
        'priority': task.priority.name,
        'isOverdue': task.dueDate != null && task.dueDate!.isBefore(DateTime.now()),
      }).toList();

      return {
        'tasks': taskData,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error getting upcoming tasks data: $e');
      return {'error': e.toString()};
    }
  }

  /// Update widget data
  Future<void> updateWidgetData(String widgetType, {Map<String, dynamic>? data}) async {
    try {
      await _channel.invokeMethod('updateWidget', {
        'widgetType': widgetType,
        'data': data ?? await _getWidgetDataByType(widgetType),
      });
    } catch (e) {
      debugPrint('Error updating widget data: $e');
    }
  }

  /// Update all widgets
  Future<void> updateAllWidgets() async {
    try {
      final widgetTypes = ['today_tasks', 'quick_stats', 'upcoming_tasks'];
      
      for (final widgetType in widgetTypes) {
        await updateWidgetData(widgetType);
      }
    } catch (e) {
      debugPrint('Error updating all widgets: $e');
    }
  }

  /// Get widget data by type
  Future<Map<String, dynamic>> _getWidgetDataByType(String widgetType) async {
    switch (widgetType) {
      case 'today_tasks':
        return await _getTodayTasksData();
      case 'quick_stats':
        return await _getQuickStatsData();
      case 'upcoming_tasks':
        return await _getUpcomingTasksData();
      default:
        return {};
    }
  }


  /// Configure widget settings
  Future<void> configureWidget(String widgetType, Map<String, dynamic> settings) async {
    try {
      await _channel.invokeMethod('configureWidget', {
        'widgetType': widgetType,
        'settings': settings,
      });
    } catch (e) {
      debugPrint('Error configuring widget: $e');
    }
  }

  /// Remove widget
  Future<void> removeWidget(String widgetId) async {
    try {
      await _channel.invokeMethod('removeWidget', {'widgetId': widgetId});
    } catch (e) {
      debugPrint('Error removing widget: $e');
    }
  }

  /// Get available widget types
  List<Map<String, dynamic>> getAvailableWidgetTypes() {
    return [
      {
        'type': 'today_tasks',
        'name': 'Today\'s Tasks',
        'description': 'Shows tasks due today with quick completion',
        'sizes': ['small', 'medium', 'large'],
      },
      {
        'type': 'quick_stats',
        'name': 'Quick Stats',
        'description': 'Shows completion statistics and streaks',
        'sizes': ['small', 'medium'],
      },
      {
        'type': 'upcoming_tasks',
        'name': 'Upcoming Tasks',
        'description': 'Shows next few upcoming tasks',
        'sizes': ['medium', 'large'],
      },
      {
        'type': 'quick_add',
        'name': 'Quick Add',
        'description': 'Quick task creation button',
        'sizes': ['small'],
      },
    ];
  }

  /// Calculate the user's current completion streak in days
  Future<int> _calculateCompletionStreak() async {
    if (_taskRepository == null) return 0;
    
    try {
      final allTasks = await _taskRepository!.getAllTasks();
      final completedTasks = allTasks
          .where((task) => task.status == TaskStatus.completed && task.completedAt != null)
          .toList();
      
      if (completedTasks.isEmpty) return 0;
      
      // Sort by completion date (most recent first)
      completedTasks.sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      int streakDays = 0;
      
      // Check each day going backwards from today
      for (int dayOffset = 0; dayOffset < 365; dayOffset++) {
        final checkDate = today.subtract(Duration(days: dayOffset));
        final endOfCheckDate = checkDate.add(const Duration(days: 1));
        
        // Check if there are any completed tasks on this day
        final tasksCompletedOnDay = completedTasks.where((task) {
          final completionDate = task.completedAt!;
          return completionDate.isAfter(checkDate.subtract(const Duration(milliseconds: 1))) &&
                 completionDate.isBefore(endOfCheckDate);
        }).length;
        
        if (tasksCompletedOnDay > 0) {
          streakDays++;
        } else {
          // Streak is broken if no tasks completed on this day
          // Exception: if this is today and we're just starting, don't break streak yet
          if (dayOffset == 0 && streakDays == 0) {
            // Check if there are tasks completed yesterday to continue counting
            continue;
          } else {
            break;
          }
        }
      }
      
      return streakDays;
    } catch (e) {
      debugPrint('Error calculating completion streak: $e');
      return 0;
    }
  }
}