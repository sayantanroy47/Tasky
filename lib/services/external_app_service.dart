import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import '../domain/entities/task_model.dart';
import '../domain/models/enums.dart';

/// Service for integrating with external apps and creating shortcuts
class ExternalAppService {
  static final ExternalAppService _instance = ExternalAppService._internal();
  factory ExternalAppService() => _instance;
  ExternalAppService._internal();

  static const MethodChannel _channel = MethodChannel('task_tracker/external_apps');

  /// Initialize external app integration
  Future<void> initialize() async {
    try {
      if (Platform.isAndroid) {
        await _setupAndroidIntegration();
      } else if (Platform.isIOS) {
        await _setupIOSIntegration();
      }
    } catch (e) {
      debugPrint('Error initializing ExternalAppService: $e');
    }
  }

  /// Setup Android-specific integrations
  Future<void> _setupAndroidIntegration() async {
    try {
      // Setup quick tile for Android
      await _channel.invokeMethod('setupQuickTile');
      
      // Setup app shortcuts
      await _setupAndroidShortcuts();
    } catch (e) {
      debugPrint('Error setting up Android integration: $e');
    }
  }

  /// Setup iOS-specific integrations
  Future<void> _setupIOSIntegration() async {
    try {
      // Setup Siri shortcuts
      await _channel.invokeMethod('setupSiriShortcuts');
      
      // Setup iOS shortcuts
      await _setupIOSShortcuts();
    } catch (e) {
      debugPrint('Error setting up iOS integration: $e');
    }
  }

  /// Setup Android app shortcuts
  Future<void> _setupAndroidShortcuts() async {
    try {
      final shortcuts = [
        {
          'id': 'quick_task',
          'shortLabel': 'Quick Task',
          'longLabel': 'Create Quick Task',
          'icon': 'ic_add_task',
          'intent': 'CREATE_QUICK_TASK',
        },
        {
          'id': 'voice_task',
          'shortLabel': 'Voice Task',
          'longLabel': 'Create Task with Voice',
          'icon': 'ic_mic',
          'intent': 'CREATE_VOICE_TASK',
        },
        {
          'id': 'today_tasks',
          'shortLabel': 'Today',
          'longLabel': 'View Today\'s Tasks',
          'icon': 'ic_today',
          'intent': 'VIEW_TODAY_TASKS',
        },
      ];

      await _channel.invokeMethod('setupShortcuts', {'shortcuts': shortcuts});
    } catch (e) {
      debugPrint('Error setting up Android shortcuts: $e');
    }
  }

  /// Setup iOS shortcuts
  Future<void> _setupIOSShortcuts() async {
    try {
      final shortcuts = [
        {
          'identifier': 'quick_task',
          'title': 'Create Quick Task',
          'subtitle': 'Add a new task quickly',
          'userInfo': {'action': 'CREATE_QUICK_TASK'},
        },
        {
          'identifier': 'voice_task',
          'title': 'Create Voice Task',
          'subtitle': 'Add a task using voice',
          'userInfo': {'action': 'CREATE_VOICE_TASK'},
        },
      ];

      await _channel.invokeMethod('setupIOSShortcuts', {'shortcuts': shortcuts});
    } catch (e) {
      debugPrint('Error setting up iOS shortcuts: $e');
    }
  }

  /// Share a task to external apps
  Future<void> shareTask(TaskModel task, {String? specificApp}) async {
    try {
      final shareText = _formatTaskForSharing(task);
      
      if (specificApp != null) {
        await _shareToSpecificApp(shareText, specificApp);
      } else {
        // Use system share sheet
        await _shareToSystemSheet(shareText);
      }
    } catch (e) {
      debugPrint('Error sharing task: $e');
    }
  }

  /// Share to WhatsApp specifically
  Future<void> shareToWhatsApp(String text, {String? phoneNumber}) async {
    try {
      if (Platform.isAndroid) {
        final intent = AndroidIntent(
          action: 'android.intent.action.SEND',
          package: 'com.whatsapp',
          type: 'text/plain',
          arguments: {
            'android.intent.extra.TEXT': text,
            if (phoneNumber != null) 'jid': '$phoneNumber@s.whatsapp.net',
          },
        );
        await intent.launch();
      } else if (Platform.isIOS) {
        const url = 'whatsapp://send?text=${Uri.encodeComponent(text)}';
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          throw Exception('WhatsApp not installed');
        }
      }
    } catch (e) {
      debugPrint('Error sharing to WhatsApp: $e');
      rethrow;
    }
  }

  /// Share to Facebook Messenger
  Future<void> shareToMessenger(String text) async {
    try {
      if (Platform.isAndroid) {
        final intent = AndroidIntent(
          action: 'android.intent.action.SEND',
          package: 'com.facebook.orca',
          type: 'text/plain',
          arguments: {
            'android.intent.extra.TEXT': text,
          },
        );
        await intent.launch();
      } else if (Platform.isIOS) {
        // Facebook Messenger doesn't have a direct URL scheme for sharing text
        // Fall back to system share sheet
        await _shareToSystemSheet(text);
      }
    } catch (e) {
      debugPrint('Error sharing to Messenger: $e');
      rethrow;
    }
  }

  /// Share to a specific app
  Future<void> _shareToSpecificApp(String text, String appPackage) async {
    try {
      switch (appPackage.toLowerCase()) {
        case 'whatsapp':
          await shareToWhatsApp(text);
          break;
        case 'messenger':
          await shareToMessenger(text);
          break;
        default:
          if (Platform.isAndroid) {
            final intent = AndroidIntent(
              action: 'android.intent.action.SEND',
              package: appPackage,
              type: 'text/plain',
              arguments: {
                'android.intent.extra.TEXT': text,
              },
            );
            await intent.launch();
          } else {
            await _shareToSystemSheet(text);
          }
      }
    } catch (e) {
      debugPrint('Error sharing to specific app: $e');
      // Fallback to system share sheet
      await _shareToSystemSheet(text);
    }
  }

  /// Share using system share sheet
  Future<void> _shareToSystemSheet(String text) async {
    try {
      await _channel.invokeMethod('shareText', {'text': text});
    } catch (e) {
      debugPrint('Error using system share sheet: $e');
    }
  }

  /// Format a task for sharing
  String _formatTaskForSharing(TaskModel task) {
    const buffer = StringBuffer();
    
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
    
    if (task.subTasks.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('✅ Subtasks:');
      for (final subtask in task.subTasks) {
        final checkbox = subtask.isCompleted ? '☑️' : '☐';
        buffer.writeln('  $checkbox ${subtask.title}');
      }
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
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Create a task from external app shortcut
  Future<TaskModel?> createTaskFromShortcut(String action, Map<String, dynamic>? data) async {
    try {
      switch (action) {
        case 'CREATE_QUICK_TASK':
          return _createQuickTask(data);
        case 'CREATE_VOICE_TASK':
          return _createVoiceTask(data);
        default:
          debugPrint('Unknown shortcut action: $action');
          return null;
      }
    } catch (e) {
      debugPrint('Error creating task from shortcut: $e');
      return null;
    }
  }

  /// Create a quick task from shortcut
  TaskModel _createQuickTask(Map<String, dynamic>? data) {
    final title = data?['title'] ?? 'Quick Task';
    final description = data?['description'];
    
    return TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      tags: const ['quick'],
      subTasks: const [],
      projectId: null,
      dependencies: const [],
      metadata: const {
        'source': 'shortcut',
        'shortcut_type': 'quick_task',
      },
    );
  }

  /// Create a voice task from shortcut
  TaskModel _createVoiceTask(Map<String, dynamic>? data) {
    final title = data?['title'] ?? 'Voice Task';
    final description = data?['description'];
    
    return TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      tags: const ['voice'],
      subTasks: const [],
      projectId: null,
      dependencies: const [],
      metadata: const {
        'source': 'shortcut',
        'shortcut_type': 'voice_task',
      },
    );
  }

  /// Check if an app is installed
  Future<bool> isAppInstalled(String packageName) async {
    try {
      if (Platform.isAndroid) {
        return await _channel.invokeMethod('isAppInstalled', {'package': packageName});
      } else if (Platform.isIOS) {
        // For iOS, we can check if we can launch the app's URL scheme
        final schemes = {
          'com.whatsapp': 'whatsapp://',
          'com.facebook.orca': 'fb-messenger://',
          'com.telegram.messenger': 'tg://',
        };
        
        final scheme = schemes[packageName];
        if (scheme != null) {
          return await canLaunchUrl(Uri.parse(scheme));
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error checking if app is installed: $e');
      return false;
    }
  }

  /// Get list of installed messaging apps
  Future<List<String>> getInstalledMessagingApps() async {
    final messagingApps = [
      'com.whatsapp',
      'com.facebook.orca',
      'com.telegram.messenger',
      'com.discord',
      'com.slack',
      'com.microsoft.teams',
    ];
    
    final installedApps = <String>[];
    
    for (final app in messagingApps) {
      if (await isAppInstalled(app)) {
        installedApps.add(app);
      }
    }
    
    return installedApps;
  }
}