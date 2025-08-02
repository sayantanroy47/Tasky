import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../domain/entities/task_model.dart';
import '../domain/models/enums.dart';

/// Service for managing home screen widgets
class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  static const MethodChannel _channel = MethodChannel('task_tracker/widgets');

  /// Initialize widget service
  Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
      _setupMethodCallHandler();
    } catch (e) {
      debugPrint('Error initializing WidgetService: $e');
    }
  }

  /// Setup method call handler for widget interactions
  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'createTaskFromWidget':
          return await _handleCreateTaskFromWidget(call.arguments);
        case 'completeTaskFromWidget':
          return await _handleCompleteTaskFromWidget(call.arguments);
        case 'getWidgetData':
          return await _handleGetWidgetData(call.arguments);
        default:
          throw PlatformException(
            code: 'UNIMPLEMENTED',
            message: 'Method ${call.method} not implemented',
          );
      }
    });
  }

  /// Handle task creation from widget
  Future<Map<String, dynamic>> _handleCreateTaskFromWidget(dynamic arguments) async {
    try {
      final args = arguments as Map<String, dynamic>;
      final title = args['title'] as String? ?? 'New Task';
      final description = args['description'] as String?;
      final priority = _parsePriority(args['priority'] as String?);

      final task = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        createdAt: DateTime.now(),
        priority: priority,
        status: TaskStatus.pending,
        tags: const ['widget'],
        subTasks: const [],
        projectId: null,
        dependencies: const [],
        metadata: {
          'source': 'widget',
          'widget_type': args['widgetType'] ?? 'quick_add',
        },
      );

      // TODO: Save task to repository
      // await _taskRepository.createTask(task);

      debugPrint('Created task from widget: ${task.title}');

      return {
        'success': true,
        'taskId': task.id,
        'message': 'Task created successfully',
      };
    } catch (e) {
      debugPrint('Error creating task from widget: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Handle task completion from widget
  Future<Map<String, dynamic>> _handleCompleteTaskFromWidget(dynamic arguments) async {
    try {
      final args = arguments as Map<String, dynamic>;
      final taskId = args['taskId'] as String;

      // TODO: Update task status in repository
      // await _taskRepository.updateTaskStatus(taskId, TaskStatus.completed);

      debugPrint('Completed task from widget: $taskId');

      return {
        'success': true,
        'message': 'Task completed successfully',
      };
    } catch (e) {
      debugPrint('Error completing task from widget: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Handle widget data request
  Future<Map<String, dynamic>> _handleGetWidgetData(dynamic arguments) async {
    try {
      final args = arguments as Map<String, dynamic>;
      final widgetType = args['widgetType'] as String;

      switch (widgetType) {
        case 'today_tasks':
          return await _getTodayTasksData();
        case 'quick_stats':
          return await _getQuickStatsData();
        case 'upcoming_tasks':
          return await _getUpcomingTasksData();
        default:
          return {'error': 'Unknown widget type: $widgetType'};
      }
    } catch (e) {
      debugPrint('Error getting widget data: $e');
      return {'error': e.toString()};
    }
  }

  /// Get today's tasks data for widget
  Future<Map<String, dynamic>> _getTodayTasksData() async {
    try {
      // TODO: Get tasks from repository
      // final todayTasks = await _taskRepository.getTodayTasks();
      
      // Mock data for now
      final todayTasks = <TaskModel>[];
      
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
      // TODO: Get stats from repository
      // final stats = await _analyticsService.getQuickStats();
      
      // Mock data for now
      return {
        'todayCompleted': 5,
        'todayTotal': 8,
        'weekCompleted': 23,
        'weekTotal': 35,
        'currentStreak': 3,
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
      // TODO: Get upcoming tasks from repository
      // final upcomingTasks = await _taskRepository.getUpcomingTasks(limit: 5);
      
      // Mock data for now
      final upcomingTasks = <TaskModel>[];
      
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

  /// Parse priority from string
  TaskPriority _parsePriority(String? priorityString) {
    switch (priorityString?.toLowerCase()) {
      case 'low':
        return TaskPriority.low;
      case 'high':
        return TaskPriority.high;
      case 'urgent':
        return TaskPriority.urgent;
      default:
        return TaskPriority.medium;
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
}