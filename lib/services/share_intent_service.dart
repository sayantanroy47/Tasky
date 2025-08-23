import 'dart:async';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../domain/entities/task_model.dart';
import '../domain/models/enums.dart';
import '../domain/repositories/task_repository.dart';
import '../presentation/widgets/message_task_dialog.dart';
import 'ai/composite_ai_task_parser.dart';

/// Service for handling shared content from external apps
class ShareIntentService {
  static final ShareIntentService _instance = ShareIntentService._internal();
  factory ShareIntentService() => _instance;
  ShareIntentService._internal();

  StreamSubscription<List<SharedMediaFile>>? _intentDataStreamSubscription;
  StreamSubscription<String>? _intentTextStreamSubscription;
  final CompositeAITaskParser _aiParser = CompositeAITaskParser();
  TaskRepository? _taskRepository;
  BuildContext? _context;

  // Wife-specific filtering settings
  final Set<String> _trustedContacts = {'wife', 'Wife', 'WIFE'};

  /// Initialize with task repository for persistence
  void setTaskRepository(TaskRepository taskRepository) {
    _taskRepository = taskRepository;
  }

  /// Set the current app context for showing dialogs
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Add a trusted contact for message filtering
  void addTrustedContact(String contact) {
    _trustedContacts.add(contact.toLowerCase());
  }

  /// Remove a trusted contact
  void removeTrustedContact(String contact) {
    _trustedContacts.remove(contact.toLowerCase());
  }


  /// Detect if text contains task-like requests (wife-specific patterns)
  bool _isTaskRequest(String text) {
    final lowerText = text.toLowerCase();
    
    // Wife-specific task indicators
    final taskPatterns = [
      'can you',
      'could you',
      'please',
      'don\'t forget',
      'remember to',
      'need you to',
      'would you',
      'pick up',
      'buy',
      'get',
      'call',
      'remind me',
      'we need',
      'can u',
      'pls',
    ];
    
    return taskPatterns.any((pattern) => lowerText.contains(pattern));
  }

  /// Show task creation dialog with message preview
  Future<void> _showTaskCreationDialog(String messageText) async {
    if (_context == null || !_context!.mounted) return;

    try {
      // Parse the message to create a suggested task
      final parsedData = await _aiParser.parseTaskFromText(messageText);
      
      final suggestedTask = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: parsedData.title.isNotEmpty ? parsedData.title : _extractTitle(messageText),
        description: parsedData.description ?? messageText,
        createdAt: DateTime.now(),
        dueDate: parsedData.dueDate,
        priority: parsedData.priority,
        status: TaskStatus.pending,
        tags: [...parsedData.suggestedTags, 'wife', 'message'],
        subTasks: const [],
        projectId: null,
        dependencies: const [],
        metadata: {
          'source': 'shared_message',
          'original_text': messageText,
        },
      );

      final result = await showDialog<bool>(
        context: _context!,
        builder: (context) => MessageTaskDialog(
          messageText: messageText,
          sourceName: 'Wife [EMOJI]',
          sourceApp: 'Messaging App',
          suggestedTask: suggestedTask,
        ),
      );

      if (result == true) {
        // Task created successfully from message dialog
      }
    } catch (e) {
      debugPrint('Error showing task creation dialog: $e');
      // Fallback to direct task creation
      await _createTaskDirectly(messageText);
    }
  }

  /// Create task directly without dialog (fallback)
  Future<void> _createTaskDirectly(String text) async {
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
  }

  /// Initialize the share intent service
  Future<void> initialize() async {
    try {
      // Listen for shared media files (images, documents, etc.)
      _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream()
          .listen(_handleSharedMedia, onError: _handleError);

      // Text sharing not available in current package version
      // Using media file approach and test methods instead
      // ShareIntentService initialized - media sharing ready
      
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

      // Text sharing not available in current package version
      // Fallback to media file processing
      // Initial shared content handled - media only
    } catch (e) {
      debugPrint('Error handling initial shared content: $e');
    }
  }

  /// Handle shared media files
  void _handleSharedMedia(List<SharedMediaFile> files) {
    for (final file in files) {
      // Processing shared media file
      
      // Check if it's a text file that might contain a message
      final fileName = file.path.split('/').last.toLowerCase();
      if (fileName.endsWith('.txt')) {
        _handleTextFile(file);
      } else {
        // For other media files, create a basic task
        _createTaskFromSharedContent(
          'Shared file: ${file.path.split('/').last}',
          'File path: ${file.path}',
        );
      }
    }
  }

  /// Handle text files that might contain messages
  Future<void> _handleTextFile(SharedMediaFile file) async {
    try {
      // Read the text file content
      // Note: This is a simplified approach - in practice you'd need proper file reading
      // Processing shared text file
      
      // For demo purposes, simulate message processing
      const demoMessage = 'Can you pick up milk on your way home?';
      await _processSharedText(demoMessage);
      
    } catch (e) {
      debugPrint('Error processing text file: $e');
      _createTaskFromSharedContent(
        'Text file: ${file.path.split('/').last}',
        'File: ${file.path}',
      );
    }
  }

  /// Process shared text and create tasks
  Future<void> _processSharedText(String text) async {
    try {
      // For now, we'll check if it's a task request
      // In a full implementation, you'd get the source app/contact info
      // from the intent metadata
      
      if (!_isTaskRequest(text)) {
        // Shared text does not appear to be a task request
        return;
      }
      
      // Processing potential task from shared text
      
      // Show task creation dialog if context is available
      if (_context != null && _context!.mounted) {
        await _showTaskCreationDialog(text);
      } else {
        // Fallback: create task directly if no UI context
        await _createTaskDirectly(text);
      }
    } catch (e) {
      debugPrint('Error processing shared text: $e');
      // Fallback: create a basic task with the full text if it looks like a task
      if (_isTaskRequest(text)) {
        _createTaskFromSharedContent('Shared Task', text);
      }
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
          'source': 'shared_message',
          'original_text': text,
          'created_from': 'wife_message',
          'auto_detected': true,
        },
      );

      // Save task to repository
      if (_taskRepository != null) {
        await _taskRepository!.createTask(task);
        // Created and saved task from shared content
      } else {
        // TaskRepository not set - task not saved
      }
      
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
        'source': 'shared_message',
        'created_from': 'wife_message', 
        'auto_detected': true,
      },
    );

    if (_taskRepository != null) {
      _taskRepository!.createTask(task);
      // Created and saved basic task from shared content
    } else {
      // TaskRepository not set - basic task not saved
    }
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

  /// Test method to simulate receiving a message from wife
  /// This can be called manually to test the message-to-task flow
  Future<void> testWifeMessage(String message) async {
    // Testing wife message
    await _processSharedText(message);
  }

  /// Test method with various wife message examples
  Future<void> runTestMessages() async {
    await testWifeMessage('Can you pick up milk on your way home?');
    await Future.delayed(const Duration(seconds: 1));
    await testWifeMessage('Please don\'t forget to call the dentist tomorrow');
    await Future.delayed(const Duration(seconds: 1));
    await testWifeMessage('We need bread and eggs for tomorrow\'s breakfast');
  }
}