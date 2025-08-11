import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/task_model.dart';
import '../domain/models/enums.dart';
import '../domain/repositories/task_repository.dart';
import '../core/providers/core_providers.dart';
import 'share_intent_service.dart';
import 'external_app_service.dart';
import 'widget_service.dart';

/// Unified service for managing all external app integrations
class IntegrationService {
  static final IntegrationService _instance = IntegrationService._internal();
  factory IntegrationService() => _instance;
  IntegrationService._internal();

  final ShareIntentService _shareIntentService = ShareIntentService();
  final ExternalAppService _externalAppService = ExternalAppService();
  final WidgetService _widgetService = WidgetService();

  TaskRepository? _taskRepository;
  bool _isInitialized = false;

  /// Initialize all integration services
  Future<void> initialize(TaskRepository taskRepository) async {
    if (_isInitialized) return;

    try {
      _taskRepository = taskRepository;

      // Initialize all services
      await Future.wait([
        _shareIntentService.initialize(),
        _externalAppService.initialize(),
        _widgetService.initialize(),
      ]);

      _isInitialized = true;
      debugPrint('IntegrationService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing IntegrationService: $e');
      rethrow;
    }
  }

  /// Handle shared content from external apps
  Future<TaskModel?> handleSharedContent(String content, {String? sourceApp}) async {
    try {
      if (_taskRepository == null) {
        throw Exception('IntegrationService not initialized');
      }

      // Create task from shared content
      final task = await _createTaskFromSharedContent(content, sourceApp);
      
      if (task != null) {
        // Save to repository
        await _taskRepository!.createTask(task);
        
        // Update widgets
        await _widgetService.updateAllWidgets();
        
        debugPrint('Created task from shared content: ${task.title}');
        return task;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error handling shared content: $e');
      return null;
    }
  }

  /// Create task from shared content
  Future<TaskModel?> _createTaskFromSharedContent(String content, String? sourceApp) async {
    try {
      // Determine if content is from a messaging app
      final isFromMessaging = _isFromMessagingApp(sourceApp);
      
      // Extract title from content
      final title = _extractTitle(content);
      
      // Create task with appropriate metadata
      final task = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: content.length > title.length ? content : null,
        createdAt: DateTime.now(),
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        tags: [
          'shared',
          if (isFromMessaging) 'message',
          if (sourceApp != null) _getAppTag(sourceApp),
        ].where((tag) => tag.isNotEmpty).toList(),
        subTasks: const [],
        projectId: null,
        dependencies: const [],
        metadata: {
          'source': 'shared_content',
          'source_app': sourceApp,
          'is_from_messaging': isFromMessaging,
          'original_content': content,
        },
      );

      return task;
    } catch (e) {
      debugPrint('Error creating task from shared content: $e');
      return null;
    }
  }

  /// Share task to external app
  Future<bool> shareTask(TaskModel task, {String? targetApp}) async {
    try {
      await _externalAppService.shareTask(task, specificApp: targetApp);
      return true;
    } catch (e) {
      debugPrint('Error sharing task: $e');
      return false;
    }
  }

  /// Share task to WhatsApp
  Future<bool> shareTaskToWhatsApp(TaskModel task, {String? phoneNumber}) async {
    try {
      final shareText = _formatTaskForSharing(task);
      await _externalAppService.shareToWhatsApp(shareText, phoneNumber: phoneNumber);
      return true;
    } catch (e) {
      debugPrint('Error sharing task to WhatsApp: $e');
      return false;
    }
  }

  /// Share task to Facebook Messenger
  Future<bool> shareTaskToMessenger(TaskModel task) async {
    try {
      final shareText = _formatTaskForSharing(task);
      await _externalAppService.shareToMessenger(shareText);
      return true;
    } catch (e) {
      debugPrint('Error sharing task to Messenger: $e');
      return false;
    }
  }

  /// Handle shortcut action
  Future<TaskModel?> handleShortcutAction(String action, Map<String, dynamic>? data) async {
    try {
      if (_taskRepository == null) {
        throw Exception('IntegrationService not initialized');
      }

      final task = await _externalAppService.createTaskFromShortcut(action, data);
      
      if (task != null) {
        await _taskRepository!.createTask(task);
        await _widgetService.updateAllWidgets();
        debugPrint('Created task from shortcut: ${task.title}');
        return task;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error handling shortcut action: $e');
      return null;
    }
  }

  /// Update widgets with latest task data
  Future<void> updateWidgets() async {
    try {
      await _widgetService.updateAllWidgets();
    } catch (e) {
      debugPrint('Error updating widgets: $e');
    }
  }

  /// Get installed messaging apps
  Future<List<String>> getInstalledMessagingApps() async {
    try {
      return await _externalAppService.getInstalledMessagingApps();
    } catch (e) {
      debugPrint('Error getting installed messaging apps: $e');
      return [];
    }
  }

  /// Check if app is installed
  Future<bool> isAppInstalled(String packageName) async {
    try {
      return await _externalAppService.isAppInstalled(packageName);
    } catch (e) {
      debugPrint('Error checking if app is installed: $e');
      return false;
    }
  }

  /// Get available widget types
  List<Map<String, dynamic>> getAvailableWidgetTypes() {
    return _widgetService.getAvailableWidgetTypes();
  }

  /// Configure widget
  Future<void> configureWidget(String widgetType, Map<String, dynamic> settings) async {
    try {
      await _widgetService.configureWidget(widgetType, settings);
    } catch (e) {
      debugPrint('Error configuring widget: $e');
    }
  }

  /// Format task for sharing
  String _formatTaskForSharing(TaskModel task) {
    final buffer = StringBuffer();
    
    buffer.writeln('📋 ${task.title}');
    
    if (task.description != null && task.description!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(task.description);
    }
    
    if (task.dueDate != null) {
      buffer.writeln();
      buffer.writeln('📅 Due: ${_formatDate(task.dueDate!)}');
    }
    
    if (task.priority != TaskPriority.medium) {
      buffer.writeln();
      buffer.writeln('⚡ Priority: ${task.priority.name.toUpperCase()}');
    }
    
    if (task.tags.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('🏷️ Tags: ${task.tags.join(', ')}');
    }
    
    buffer.writeln();
    buffer.writeln('Shared from Task Tracker App');
    
    return buffer.toString();
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    
    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Extract title from content
  String _extractTitle(String content) {
    final lines = content.split('\n');
    final firstLine = lines.first.trim();
    
    if (firstLine.length <= 50) {
      return firstLine;
    }
    
    return '${firstLine.substring(0, 47)}...';
  }

  /// Check if source app is a messaging app
  bool _isFromMessagingApp(String? sourceApp) {
    if (sourceApp == null) return false;
    
    final messagingApps = [
      'whatsapp', 'messenger', 'telegram', 'discord', 
      'slack', 'teams', 'messages', 'sms'
    ];
    
    return messagingApps.any((app) => sourceApp.toLowerCase().contains(app));
  }

  /// Get app tag from package name
  String _getAppTag(String sourceApp) {
    final appTags = {
      'whatsapp': 'whatsapp',
      'messenger': 'messenger',
      'telegram': 'telegram',
      'discord': 'discord',
      'slack': 'slack',
      'teams': 'teams',
      'messages': 'sms',
    };
    
    for (final entry in appTags.entries) {
      if (sourceApp.toLowerCase().contains(entry.key)) {
        return entry.value;
      }
    }
    
    return 'external';
  }

  /// Dispose of resources
  void dispose() {
    _shareIntentService.dispose();
  }
}

/// Provider for IntegrationService
final integrationServiceProvider = Provider<IntegrationService>((ref) {
  return IntegrationService();
});

/// Provider for handling shared content
final sharedContentHandlerProvider = Provider<SharedContentHandler>((ref) {
  final integrationService = ref.read(integrationServiceProvider);
  final taskRepository = ref.read(taskRepositoryProvider);
  
  return SharedContentHandler(integrationService, taskRepository);
});

/// Handler for shared content
class SharedContentHandler {
  final IntegrationService _integrationService;
  final TaskRepository _taskRepository;

  SharedContentHandler(this._integrationService, this._taskRepository);

  /// Initialize the handler
  Future<void> initialize() async {
    await _integrationService.initialize(_taskRepository);
  }

  /// Handle shared text content
  Future<TaskModel?> handleSharedText(String text, {String? sourceApp}) async {
    return await _integrationService.handleSharedContent(text, sourceApp: sourceApp);
  }

  /// Handle shortcut actions
  Future<TaskModel?> handleShortcut(String action, Map<String, dynamic>? data) async {
    return await _integrationService.handleShortcutAction(action, data);
  }
}