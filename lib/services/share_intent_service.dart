import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../domain/entities/task_model.dart';
import '../domain/models/enums.dart';
import 'ai/composite_ai_task_parser.dart';

/// Service for handling shared content from external apps
class ShareIntentService {
  static final ShareIntentService _instance = ShareIntentService._internal();
  factory ShareIntentService() => _instance;
  ShareIntentService._internal();

  StreamSubscription<List<SharedMediaFile>>? _intentDataStreamSubscription;
  StreamSubscription<String>? _intentTextStreamSubscription;
  final CompositeAITaskParser _aiParser = CompositeAITaskParser();

  /// Initialize the share intent service
  Future<void> initialize() async {
    try {
      // Listen for shared media files (images, documents, etc.)
      _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream()
          .listen(_handleSharedMedia, onError: _handleError);

      // Listen for shared text content (stub implementation)
      // Note: getTextStream() doesn't exist in current package version
      // This is a placeholder for when the API is available
      
      // Handle initial shared content when app is launched
      await _handleInitialSharedContent();
    } catch (e) {
      debugPrint('Error initializing ShareIntentService: $e');
    }
  }

  /// Handle initial shared content when app is launched from share intent
  Future<void> _handleInitialSharedContent() async {
    try {
      // Get initial shared media files
      final initialMedia = await ReceiveSharingIntent.instance.getInitialMedia();
      if (initialMedia.isNotEmpty) {
        _handleSharedMedia(initialMedia);
      }

      // Note: getInitialText() doesn't exist in current package version
      // This is a placeholder for when the API is available
    } catch (e) {
      debugPrint('Error handling initial shared content: $e');
    }
  }

  /// Handle shared media files
  void _handleSharedMedia(List<SharedMediaFile> files) {
    for (final file in files) {
      debugPrint('Received shared media: ${file.path}');
      // For now, we'll create a task with the file path as description
      // In a full implementation, you might want to handle different file types
      _createTaskFromSharedContent(
        'Shared file: ${file.path.split('/').last}',
        'File path: ${file.path}',
      );
    }
  }

  /// Process shared text and create tasks
  /// This method is reserved for future use when text sharing is implemented
  // ignore: unused_element
  Future<void> _processSharedText(String text) async {
    try {
      // Check if the text looks like it contains multiple tasks
      final potentialTasks = _extractPotentialTasks(text);
      
      if (potentialTasks.length > 1) {
        // Multiple potential tasks found
        for (final taskText in potentialTasks) {
          await _createTaskFromText(taskText);
        }
      } else {
        // Single task
        await _createTaskFromText(text);
      }
    } catch (e) {
      debugPrint('Error processing shared text: $e');
      // Fallback: create a basic task with the full text
      _createTaskFromSharedContent('Shared content', text);
    }
  }

  /// Extract potential tasks from text (looking for line breaks, bullet points, etc.)
  List<String> _extractPotentialTasks(String text) {
    final lines = text.split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    // If we have multiple lines that look like tasks, return them
    if (lines.length > 1) {
      final taskLines = lines.where((line) {
        // Look for lines that start with task indicators
        return line.startsWith('- ') ||
               line.startsWith('• ') ||
               line.startsWith('* ') ||
               line.contains('todo') ||
               line.contains('task') ||
               line.contains('remind') ||
               line.contains('need to') ||
               line.contains('should') ||
               line.contains('must');
      }).toList();

      if (taskLines.isNotEmpty) {
        return taskLines;
      }
    }

    return [text]; // Return as single task
  }

  /// Create a task from processed text using AI parsing
  Future<void> _createTaskFromText(String text) async {
    try {
      final parsedData = await _aiParser.parseTaskFromText(text);
      
      final task = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: parsedData.title.isNotEmpty ? parsedData.title : _extractTitle(text),
        description: parsedData.description ?? text,
        createdAt: DateTime.now(),
        dueDate: parsedData.dueDate,
        priority: parsedData.priority,
        status: TaskStatus.pending,
        tags: parsedData.suggestedTags,
        subTasks: const [],
        projectId: null,
        dependencies: const [],
        metadata: {
          'source': 'shared_content',
          'original_text': text,
        },
      );

      // In a real implementation, you would save this to the repository
      // For now, we'll just log it
      debugPrint('Created task from shared content: ${task.title}');
      
      // TODO: Save task to repository
      // await _taskRepository.createTask(task);
      
    } catch (e) {
      debugPrint('Error creating task from text: $e');
      // Fallback to basic task creation
      _createTaskFromSharedContent(_extractTitle(text), text);
    }
  }

  /// Create a basic task from shared content (fallback method)
  void _createTaskFromSharedContent(String title, String description) {
    final task = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      tags: const ['shared'],
      subTasks: const [],
      projectId: null,
      dependencies: const [],
      metadata: const {
        'source': 'shared_content',
      },
    );

    debugPrint('Created basic task from shared content: ${task.title}');
    
    // TODO: Save task to repository
    // await _taskRepository.createTask(task);
  }

  /// Extract a title from text content
  String _extractTitle(String text) {
    // Take the first line or first 50 characters as title
    final lines = text.split('\n');
    final firstLine = lines.first.trim();
    
    if (firstLine.length <= 50) {
      return firstLine;
    }
    
    // If first line is too long, take first 50 characters and add ellipsis
    return '${firstLine.substring(0, 47)}...';
  }

  /// Handle errors in stream subscriptions
  void _handleError(dynamic error) {
    debugPrint('ShareIntentService error: $error');
  }

  /// Check if the shared content is from a messaging app


  /// Dispose of resources
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    _intentTextStreamSubscription?.cancel();
  }
}