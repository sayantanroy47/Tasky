import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/task_model.dart';
import '../../domain/entities/project.dart';
import '../../domain/models/enums.dart' as enums;
import '../../domain/repositories/task_repository.dart';

import '../data_export/data_export_service.dart';
import '../data_export/data_export_models.dart' as export_models;

/// Service for email integration and task sharing
class EmailIntegrationService {
  final TaskRepository _taskRepository;
  // final ProjectRepository _projectRepository;
  final DataExportService _exportService;
  
  // Email configuration
  EmailConfiguration? _emailConfig;
  
  // Shared task tracking
  final Map<String, SharedTask> _sharedTasks = {};
  final StreamController<EmailEvent> _emailEventController = 
      StreamController<EmailEvent>.broadcast();

  EmailIntegrationService({
    required TaskRepository taskRepository,
    required DataExportService exportService,
  }) : _taskRepository = taskRepository,
       _exportService = exportService;

  /// Stream of email events
  Stream<EmailEvent> get emailEvents => _emailEventController.stream;

  /// Initialize email service
  Future<bool> initialize() async {
    try {
      await _loadEmailConfiguration();
      await _loadSharedTasks();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing email service: $e');
      }
      return false;
    }
  }

  /// Configure email settings
  Future<void> configureEmail(EmailConfiguration config) async {
    _emailConfig = config;
    await _saveEmailConfiguration(config);
    
    _emailEventController.add(const EmailEvent(
      type: EmailEventType.configurationUpdated,
      message: 'Email configuration updated successfully',
    ));
  }

  /// Share task via email
  Future<EmailResult> shareTask(
    TaskModel task, {
    required List<String> recipients,
    EmailShareOptions? options,
  }) async {
    try {
      options ??= const EmailShareOptions();
      
      // Generate email content
      final emailContent = await _generateTaskEmailContent(task, options);
      
      // Create email message
      final message = Message()
        ..from = Address(_emailConfig?.fromEmail ?? 'noreply@tasky.app', 
                        _emailConfig?.fromName ?? 'Tasky App')
        ..recipients.addAll(recipients.map((email) => Address(email)))
        ..subject = emailContent.subject
        ..html = emailContent.htmlBody
        ..text = emailContent.textBody;

      // Add attachments if requested
      if (options.includeAttachments) {
        await _addTaskAttachments(message, task, options);
      }

      // Send email
      final result = await _sendEmail(message);
      
      if (result.success) {
        // Track shared task
        final sharedTask = SharedTask(
          taskId: task.id,
          recipients: recipients,
          sharedAt: DateTime.now(),
          shareType: ShareType.email,
          options: options,
        );
        
        _sharedTasks[task.id] = sharedTask;
        await _saveSharedTasks();

        _emailEventController.add(EmailEvent(
          type: EmailEventType.taskShared,
          message: 'Task shared successfully with ${recipients.length} recipients',
          taskId: task.id,
          recipients: recipients,
        ));
      }
      
      return result;
    } catch (e) {
      _emailEventController.add(EmailEvent(
        type: EmailEventType.shareError,
        message: 'Failed to share task: $e',
        error: e.toString(),
        taskId: task.id,
      ));
      
      return EmailResult(
        success: false,
        error: 'Failed to share task: $e',
      );
    }
  }

  /// Share multiple tasks
  Future<EmailResult> shareTasks(
    List<TaskModel> tasks, {
    required List<String> recipients,
    EmailShareOptions? options,
  }) async {
    try {
      options ??= const EmailShareOptions();
      
      // Generate email content for multiple tasks
      final emailContent = await _generateTasksEmailContent(tasks, options);
      
      final message = Message()
        ..from = Address(_emailConfig?.fromEmail ?? 'noreply@tasky.app',
                        _emailConfig?.fromName ?? 'Tasky App')
        ..recipients.addAll(recipients.map((email) => Address(email)))
        ..subject = emailContent.subject
        ..html = emailContent.htmlBody
        ..text = emailContent.textBody;

      // Add data export attachment
      if (options.includeDataExport) {
        await _addDataExportAttachment(message, tasks, options);
      }

      final result = await _sendEmail(message);
      
      if (result.success) {
        // Track all shared tasks
        for (final task in tasks) {
          final sharedTask = SharedTask(
            taskId: task.id,
            recipients: recipients,
            sharedAt: DateTime.now(),
            shareType: ShareType.email,
            options: options,
          );
          
          _sharedTasks[task.id] = sharedTask;
        }
        
        await _saveSharedTasks();

        _emailEventController.add(EmailEvent(
          type: EmailEventType.multipleTasksShared,
          message: 'Shared ${tasks.length} tasks successfully',
          recipients: recipients,
        ));
      }
      
      return result;
    } catch (e) {
      return EmailResult(
        success: false,
        error: 'Failed to share tasks: $e',
      );
    }
  }

  /// Share project with all its tasks
  Future<EmailResult> shareProject(
    Project project, {
    required List<String> recipients,
    EmailShareOptions? options,
  }) async {
    try {
      options ??= const EmailShareOptions();
      
      // Get project tasks
      final tasks = await _getProjectTasks(project);
      
      // Generate project email content
      final emailContent = await _generateProjectEmailContent(project, tasks, options);
      
      final message = Message()
        ..from = Address(_emailConfig?.fromEmail ?? 'noreply@tasky.app',
                        _emailConfig?.fromName ?? 'Tasky App')
        ..recipients.addAll(recipients.map((email) => Address(email)))
        ..subject = emailContent.subject
        ..html = emailContent.htmlBody
        ..text = emailContent.textBody;

      // Add project data export
      if (options.includeDataExport) {
        await _addProjectExportAttachment(message, project, tasks, options);
      }

      final result = await _sendEmail(message);
      
      if (result.success) {
        _emailEventController.add(EmailEvent(
          type: EmailEventType.projectShared,
          message: 'Project shared successfully',
          projectId: project.id,
          recipients: recipients,
        ));
      }
      
      return result;
    } catch (e) {
      return EmailResult(
        success: false,
        error: 'Failed to share project: $e',
      );
    }
  }

  /// Send task update notification
  Future<EmailResult> sendTaskUpdateNotification(
    TaskModel task,
    TaskUpdateType updateType, {
    String? customMessage,
  }) async {
    final sharedTask = _sharedTasks[task.id];
    if (sharedTask == null || sharedTask.recipients.isEmpty) {
      return const EmailResult(
        success: false,
        error: 'Task not shared with anyone',
      );
    }

    try {
      final emailContent = await _generateTaskUpdateEmailContent(
        task, updateType, customMessage);
      
      final message = Message()
        ..from = Address(_emailConfig?.fromEmail ?? 'noreply@tasky.app',
                        _emailConfig?.fromName ?? 'Tasky App')
        ..recipients.addAll(sharedTask.recipients.map((email) => Address(email)))
        ..subject = emailContent.subject
        ..html = emailContent.htmlBody
        ..text = emailContent.textBody;

      final result = await _sendEmail(message);
      
      if (result.success) {
        _emailEventController.add(EmailEvent(
          type: EmailEventType.updateNotificationSent,
          message: 'Task update notification sent',
          taskId: task.id,
          recipients: sharedTask.recipients,
        ));
      }
      
      return result;
    } catch (e) {
      return EmailResult(
        success: false,
        error: 'Failed to send update notification: $e',
      );
    }
  }

  /// Send task reminder email
  Future<EmailResult> sendTaskReminder(
    TaskModel task,
    List<String> recipients, {
    String? customMessage,
  }) async {
    try {
      final emailContent = await _generateTaskReminderEmailContent(task, customMessage);
      
      final message = Message()
        ..from = Address(_emailConfig?.fromEmail ?? 'noreply@tasky.app',
                        _emailConfig?.fromName ?? 'Tasky App')
        ..recipients.addAll(recipients.map((email) => Address(email)))
        ..subject = emailContent.subject
        ..html = emailContent.htmlBody
        ..text = emailContent.textBody;

      final result = await _sendEmail(message);
      
      if (result.success) {
        _emailEventController.add(EmailEvent(
          type: EmailEventType.reminderSent,
          message: 'Task reminder sent',
          taskId: task.id,
          recipients: recipients,
        ));
      }
      
      return result;
    } catch (e) {
      return EmailResult(
        success: false,
        error: 'Failed to send reminder: $e',
      );
    }
  }

  /// Send email via device's default email app
  Future<EmailResult> shareViaDeviceEmail(
    TaskModel task, {
    List<String>? recipients,
  }) async {
    try {
      final subject = Uri.encodeComponent('Task: ${task.title}');
      final body = Uri.encodeComponent(_generatePlainTextTaskDescription(task));
      
      String emailUrl = 'mailto:';
      if (recipients != null && recipients.isNotEmpty) {
        emailUrl += recipients.join(',');
      }
      emailUrl += '?subject=$subject&body=$body';
      
      final uri = Uri.parse(emailUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return const EmailResult(success: true);
      } else {
        return const EmailResult(
          success: false,
          error: 'No email app available',
        );
      }
    } catch (e) {
      return EmailResult(
        success: false,
        error: 'Failed to launch email app: $e',
      );
    }
  }

  /// Generate task email content
  Future<EmailContent> _generateTaskEmailContent(
    TaskModel task,
    EmailShareOptions options,
  ) async {
    final subject = 'Task Shared: ${task.title}';
    
    // Generate HTML content
    final htmlBody = _buildTaskEmailHTML(task, options);
    
    // Generate plain text content
    final textBody = _generatePlainTextTaskDescription(task);
    
    return EmailContent(
      subject: subject,
      htmlBody: htmlBody,
      textBody: textBody,
    );
  }

  /// Generate multiple tasks email content
  Future<EmailContent> _generateTasksEmailContent(
    List<TaskModel> tasks,
    EmailShareOptions options,
  ) async {
    final subject = 'Tasks Shared: ${tasks.length} tasks from Tasky';
    
    final htmlBody = _buildTasksEmailHTML(tasks, options);
    final textBody = _generatePlainTextTasksDescription(tasks);
    
    return EmailContent(
      subject: subject,
      htmlBody: htmlBody,
      textBody: textBody,
    );
  }

  /// Generate project email content
  Future<EmailContent> _generateProjectEmailContent(
    Project project,
    List<TaskModel> tasks,
    EmailShareOptions options,
  ) async {
    final subject = 'Project Shared: ${project.name}';
    
    final htmlBody = _buildProjectEmailHTML(project, tasks, options);
    final textBody = _generatePlainTextProjectDescription(project, tasks);
    
    return EmailContent(
      subject: subject,
      htmlBody: htmlBody,
      textBody: textBody,
    );
  }

  /// Generate task update email content
  Future<EmailContent> _generateTaskUpdateEmailContent(
    TaskModel task,
    TaskUpdateType updateType,
    String? customMessage,
  ) async {
    final updateText = _getUpdateTypeText(updateType);
    final subject = 'Task Update: ${task.title} - $updateText';
    
    final htmlBody = _buildTaskUpdateEmailHTML(task, updateType, customMessage);
    final textBody = _generatePlainTextTaskUpdateDescription(task, updateType, customMessage);
    
    return EmailContent(
      subject: subject,
      htmlBody: htmlBody,
      textBody: textBody,
    );
  }

  /// Generate task reminder email content
  Future<EmailContent> _generateTaskReminderEmailContent(
    TaskModel task,
    String? customMessage,
  ) async {
    final subject = 'Task Reminder: ${task.title}';
    
    final htmlBody = _buildTaskReminderEmailHTML(task, customMessage);
    final textBody = _generatePlainTextTaskReminderDescription(task, customMessage);
    
    return EmailContent(
      subject: subject,
      htmlBody: htmlBody,
      textBody: textBody,
    );
  }

  /// Build HTML email for single task
  String _buildTaskEmailHTML(TaskModel task, EmailShareOptions options) {
    final priorityColor = _getPriorityColor(task.priority);
    final statusColor = _getStatusColor(task.status);
    
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
            .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .header { background: #2196F3; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; }
            .task-title { font-size: 24px; font-weight: bold; margin-bottom: 10px; color: #333; }
            .task-meta { display: flex; gap: 10px; margin-bottom: 15px; }
            .badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; }
            .priority { background-color: $priorityColor; color: white; }
            .status { background-color: $statusColor; color: white; }
            .description { margin: 15px 0; line-height: 1.6; }
            .details { background: #f8f9fa; padding: 15px; border-radius: 4px; margin: 15px 0; }
            .footer { background: #f8f9fa; padding: 15px; text-align: center; font-size: 12px; color: #666; }
            .tags { margin: 10px 0; }
            .tag { background: #e3f2fd; color: #1976d2; padding: 2px 6px; border-radius: 3px; font-size: 11px; margin-right: 5px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Task Shared from Tasky</h1>
            </div>
            <div class="content">
                <div class="task-title">${task.title}</div>
                <div class="task-meta">
                    <span class="badge priority">${task.priority.name.toUpperCase()}</span>
                    <span class="badge status">${task.status.name.toUpperCase()}</span>
                </div>
                ${task.description != null ? '<div class="description">${task.description}</div>' : ''}
                <div class="details">
                    <div><strong>Created:</strong> ${task.createdAt.toString().split('.')[0]}</div>
                    ${task.dueDate != null ? '<div><strong>Due:</strong> ${task.dueDate.toString().split('.')[0]}</div>' : ''}
                    ${task.estimatedDuration != null ? '<div><strong>Estimated Duration:</strong> ${task.estimatedDuration} minutes</div>' : ''}
                </div>
                ${task.tags.isNotEmpty ? '<div class="tags">${task.tags.map((tag) => '<span class="tag">$tag</span>').join('')}</div>' : ''}
            </div>
            <div class="footer">
                Shared from Tasky Task Management App
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Build HTML email for multiple tasks
  String _buildTasksEmailHTML(List<TaskModel> tasks, EmailShareOptions options) {
    final taskRows = tasks.map((task) => '''
      <tr>
          <td style="padding: 8px; border-bottom: 1px solid #eee;">${task.title}</td>
          <td style="padding: 8px; border-bottom: 1px solid #eee;">
              <span style="background: ${_getPriorityColor(task.priority)}; color: white; padding: 2px 6px; border-radius: 3px; font-size: 11px;">
                  ${task.priority.name.toUpperCase()}
              </span>
          </td>
          <td style="padding: 8px; border-bottom: 1px solid #eee;">
              <span style="background: ${_getStatusColor(task.status)}; color: white; padding: 2px 6px; border-radius: 3px; font-size: 11px;">
                  ${task.status.name.toUpperCase()}
              </span>
          </td>
          <td style="padding: 8px; border-bottom: 1px solid #eee;">${task.dueDate?.toString().split(' ')[0] ?? 'No due date'}</td>
      </tr>
    ''').join('');

    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
            .container { max-width: 800px; margin: 0 auto; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .header { background: #2196F3; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; }
            .summary { background: #f8f9fa; padding: 15px; border-radius: 4px; margin-bottom: 20px; }
            table { width: 100%; border-collapse: collapse; }
            th { background: #e3f2fd; padding: 10px; text-align: left; border-bottom: 1px solid #ccc; }
            .footer { background: #f8f9fa; padding: 15px; text-align: center; font-size: 12px; color: #666; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>${tasks.length} Tasks Shared from Tasky</h1>
            </div>
            <div class="content">
                <div class="summary">
                    <strong>Summary:</strong>
                    <ul>
                        <li>Total Tasks: ${tasks.length}</li>
                        <li>Completed: ${tasks.where((t) => t.status == enums.TaskStatus.completed).length}</li>
                        <li>In Progress: ${tasks.where((t) => t.status == enums.TaskStatus.inProgress).length}</li>
                        <li>Pending: ${tasks.where((t) => t.status == enums.TaskStatus.pending).length}</li>
                    </ul>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Task</th>
                            <th>Priority</th>
                            <th>Status</th>
                            <th>Due Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        $taskRows
                    </tbody>
                </table>
            </div>
            <div class="footer">
                Shared from Tasky Task Management App
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Build HTML email for project
  String _buildProjectEmailHTML(Project project, List<TaskModel> tasks, EmailShareOptions options) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
            .container { max-width: 800px; margin: 0 auto; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .header { background: #4CAF50; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; }
            .project-info { background: #f8f9fa; padding: 15px; border-radius: 4px; margin-bottom: 20px; }
            .stats { display: flex; justify-content: space-around; margin: 15px 0; }
            .stat { text-align: center; }
            .stat-number { font-size: 24px; font-weight: bold; color: #4CAF50; }
            .footer { background: #f8f9fa; padding: 15px; text-align: center; font-size: 12px; color: #666; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>[EMOJI] Project Shared: ${project.name}</h1>
            </div>
            <div class="content">
                <div class="project-info">
                    <h3>Project Information</h3>
                    ${project.description != null ? '<p>${project.description}</p>' : ''}
                    <p><strong>Created:</strong> ${project.createdAt.toString().split('.')[0]}</p>
                    ${project.deadline != null ? '<p><strong>Deadline:</strong> ${project.deadline.toString().split('.')[0]}</p>' : ''}
                </div>
                <div class="stats">
                    <div class="stat">
                        <div class="stat-number">${tasks.length}</div>
                        <div>Total Tasks</div>
                    </div>
                    <div class="stat">
                        <div class="stat-number">${tasks.where((t) => t.status == enums.TaskStatus.completed).length}</div>
                        <div>Completed</div>
                    </div>
                    <div class="stat">
                        <div class="stat-number">${tasks.where((t) => t.status == enums.TaskStatus.inProgress).length}</div>
                        <div>In Progress</div>
                    </div>
                    <div class="stat">
                        <div class="stat-number">${tasks.where((t) => t.status == enums.TaskStatus.pending).length}</div>
                        <div>Pending</div>
                    </div>
                </div>
            </div>
            <div class="footer">
                Shared from Tasky Task Management App
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Build HTML email for task update
  String _buildTaskUpdateEmailHTML(TaskModel task, TaskUpdateType updateType, String? customMessage) {
    final updateIcon = _getUpdateTypeIcon(updateType);
    final updateColor = _getUpdateTypeColor(updateType);
    
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
            .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .header { background: $updateColor; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; }
            .update-info { background: #f8f9fa; padding: 15px; border-radius: 4px; margin: 15px 0; }
            .footer { background: #f8f9fa; padding: 15px; text-align: center; font-size: 12px; color: #666; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>$updateIcon Task Update</h1>
            </div>
            <div class="content">
                <h2>${task.title}</h2>
                <div class="update-info">
                    <p><strong>Update:</strong> ${_getUpdateTypeText(updateType)}</p>
                    <p><strong>Time:</strong> ${DateTime.now().toString().split('.')[0]}</p>
                    ${customMessage != null ? '<p><strong>Message:</strong> $customMessage</p>' : ''}
                </div>
                <p><strong>Current Status:</strong> ${task.status.name.toUpperCase()}</p>
                <p><strong>Priority:</strong> ${task.priority.name.toUpperCase()}</p>
            </div>
            <div class="footer">
                Update from Tasky Task Management App
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Build HTML email for task reminder
  String _buildTaskReminderEmailHTML(TaskModel task, String? customMessage) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f5f5f5; }
            .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .header { background: #FF9800; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; }
            .reminder-info { background: #fff3e0; padding: 15px; border-radius: 4px; margin: 15px 0; border-left: 4px solid #FF9800; }
            .footer { background: #f8f9fa; padding: 15px; text-align: center; font-size: 12px; color: #666; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>Task Reminder</h1>
            </div>
            <div class="content">
                <h2>${task.title}</h2>
                <div class="reminder-info">
                    <p><strong>This is a friendly reminder about your task.</strong></p>
                    ${task.dueDate != null ? '<p><strong>Due:</strong> ${task.dueDate.toString().split('.')[0]}</p>' : ''}
                    ${customMessage != null ? '<p><strong>Note:</strong> $customMessage</p>' : ''}
                </div>
                ${task.description != null ? '<p><strong>Description:</strong> ${task.description}</p>' : ''}
                <p><strong>Priority:</strong> ${task.priority.name.toUpperCase()}</p>
                <p><strong>Status:</strong> ${task.status.name.toUpperCase()}</p>
            </div>
            <div class="footer">
                Reminder from Tasky Task Management App
            </div>
        </div>
    </body>
    </html>
    ''';
  }

  /// Generate plain text task description
  String _generatePlainTextTaskDescription(TaskModel task) {
    final buffer = StringBuffer();
    buffer.writeln('TASK: ${task.title}');
    buffer.writeln('');
    
    if (task.description != null) {
      buffer.writeln('DESCRIPTION:');
      buffer.writeln(task.description);
      buffer.writeln('');
    }
    
    buffer.writeln('DETAILS:');
    buffer.writeln('Priority: ${task.priority.name.toUpperCase()}');
    buffer.writeln('Status: ${task.status.name.toUpperCase()}');
    buffer.writeln('Created: ${task.createdAt.toString().split('.')[0]}');
    
    if (task.dueDate != null) {
      buffer.writeln('Due: ${task.dueDate.toString().split('.')[0]}');
    }
    
    if (task.estimatedDuration != null) {
      buffer.writeln('Estimated Duration: ${task.estimatedDuration} minutes');
    }
    
    if (task.tags.isNotEmpty) {
      buffer.writeln('Tags: ${task.tags.join(', ')}');
    }
    
    buffer.writeln('');
    buffer.writeln('Shared from Tasky Task Management App');
    
    return buffer.toString();
  }

  /// Generate plain text tasks description
  String _generatePlainTextTasksDescription(List<TaskModel> tasks) {
    final buffer = StringBuffer();
    buffer.writeln('TASKS SHARED FROM TASKY');
    buffer.writeln('');
    buffer.writeln('Total: ${tasks.length} tasks');
    buffer.writeln('');
    
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      buffer.writeln('${i + 1}. ${task.title}');
      buffer.writeln('   Priority: ${task.priority.name.toUpperCase()}');
      buffer.writeln('   Status: ${task.status.name.toUpperCase()}');
      if (task.dueDate != null) {
        buffer.writeln('   Due: ${task.dueDate.toString().split(' ')[0]}');
      }
      buffer.writeln('');
    }
    
    return buffer.toString();
  }

  /// Generate plain text project description
  String _generatePlainTextProjectDescription(Project project, List<TaskModel> tasks) {
    final buffer = StringBuffer();
    buffer.writeln('PROJECT: ${project.name}');
    buffer.writeln('');
    
    if (project.description != null) {
      buffer.writeln('DESCRIPTION:');
      buffer.writeln(project.description);
      buffer.writeln('');
    }
    
    buffer.writeln('PROJECT DETAILS:');
    buffer.writeln('Created: ${project.createdAt.toString().split('.')[0]}');
    if (project.deadline != null) {
      buffer.writeln('Deadline: ${project.deadline.toString().split('.')[0]}');
    }
    buffer.writeln('Total Tasks: ${tasks.length}');
    buffer.writeln('');
    
    return buffer.toString();
  }

  /// Generate plain text task update description
  String _generatePlainTextTaskUpdateDescription(
    TaskModel task,
    TaskUpdateType updateType,
    String? customMessage,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('TASK UPDATE: ${task.title}');
    buffer.writeln('');
    buffer.writeln('Update: ${_getUpdateTypeText(updateType)}');
    buffer.writeln('Time: ${DateTime.now().toString().split('.')[0]}');
    
    if (customMessage != null) {
      buffer.writeln('Message: $customMessage');
    }
    
    buffer.writeln('');
    buffer.writeln('Current Status: ${task.status.name.toUpperCase()}');
    buffer.writeln('Priority: ${task.priority.name.toUpperCase()}');
    
    return buffer.toString();
  }

  /// Generate plain text task reminder description
  String _generatePlainTextTaskReminderDescription(TaskModel task, String? customMessage) {
    final buffer = StringBuffer();
    buffer.writeln('TASK REMINDER: ${task.title}');
    buffer.writeln('');
    
    if (task.dueDate != null) {
      buffer.writeln('Due: ${task.dueDate.toString().split('.')[0]}');
    }
    
    if (customMessage != null) {
      buffer.writeln('Note: $customMessage');
    }
    
    buffer.writeln('');
    buffer.writeln('Priority: ${task.priority.name.toUpperCase()}');
    buffer.writeln('Status: ${task.status.name.toUpperCase()}');
    
    return buffer.toString();
  }

  /// Add task attachments to email
  Future<void> _addTaskAttachments(Message message, TaskModel task, EmailShareOptions options) async {
    // Add task as JSON attachment
    if (options.includeTaskData) {
      final taskJson = jsonEncode(task.toJson());
      message.attachments.add(FileAttachment(
        File.fromRawPath(Uint8List.fromList(taskJson.codeUnits)),
        fileName: '${task.title}_task_data.json',
      ));
    }
  }

  /// Add data export attachment
  Future<void> _addDataExportAttachment(Message message, List<TaskModel> tasks, EmailShareOptions options) async {
    try {
      final exportFormat = options.exportFormat ?? export_models.ExportFormat.csv;
      final result = await _exportService.exportTasks(tasks, format: exportFormat);
      
      if (result.success && result.filePath != null) {
        final file = File(result.filePath!);
        if (await file.exists()) {
          message.attachments.add(FileAttachment(
            file,
            fileName: 'tasks_export.${exportFormat.name}',
          ));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding data export attachment: $e');
      }
    }
  }

  /// Add project export attachment
  Future<void> _addProjectExportAttachment(
    Message message,
    Project project,
    List<TaskModel> tasks,
    EmailShareOptions options,
  ) async {
    try {
      final exportFormat = options.exportFormat ?? export_models.ExportFormat.json;
      
      // Export both project and its tasks
      final taskResult = await _exportService.exportTasks(tasks, format: exportFormat);
      final projectResult = await _exportService.exportProjects([project], format: exportFormat);
      
      if (taskResult.success && taskResult.filePath != null) {
        final file = File(taskResult.filePath!);
        if (await file.exists()) {
          message.attachments.add(FileAttachment(
            file,
            fileName: 'project_tasks.${exportFormat.name}',
          ));
        }
      }
      
      if (projectResult.success && projectResult.filePath != null) {
        final file = File(projectResult.filePath!);
        if (await file.exists()) {
          message.attachments.add(FileAttachment(
            file,
            fileName: 'project_info.${exportFormat.name}',
          ));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding project export attachment: $e');
      }
    }
  }

  /// Send email using configured SMTP settings
  Future<EmailResult> _sendEmail(Message message) async {
    if (_emailConfig == null) {
      return const EmailResult(
        success: false,
        error: 'Email not configured',
      );
    }

    try {
      SmtpServer smtpServer;
      
      switch (_emailConfig!.provider) {
        case EmailProvider.gmail:
          smtpServer = gmail(_emailConfig!.username, _emailConfig!.password);
          break;
        case EmailProvider.outlook:
          smtpServer = hotmail(_emailConfig!.username, _emailConfig!.password);
          break;
        case EmailProvider.yahoo:
          smtpServer = yahoo(_emailConfig!.username, _emailConfig!.password);
          break;
        case EmailProvider.custom:
          smtpServer = SmtpServer(
            _emailConfig!.smtpServer!,
            port: _emailConfig!.smtpPort,
            ssl: _emailConfig!.useSsl,
            username: _emailConfig!.username,
            password: _emailConfig!.password,
          );
          break;
      }
      
      final sendResult = await send(message, smtpServer);
      
      return EmailResult(
        success: true,
        messageId: sendResult.toString(),
      );
    } catch (e) {
      return EmailResult(
        success: false,
        error: 'Failed to send email: $e',
      );
    }
  }

  /// Get project tasks
  Future<List<TaskModel>> _getProjectTasks(Project project) async {
    final allTasks = await _taskRepository.getAllTasks();
    return allTasks.where((task) => task.projectId == project.id).toList();
  }

  /// Get priority color
  String _getPriorityColor(enums.TaskPriority priority) {
    switch (priority) {
      case enums.TaskPriority.urgent:
        return '#F44336';
      case enums.TaskPriority.high:
        return '#FF9800';
      case enums.TaskPriority.medium:
        return '#2196F3';
      case enums.TaskPriority.low:
        return '#4CAF50';
    }
  }

  /// Get status color
  String _getStatusColor(enums.TaskStatus status) {
    switch (status) {
      case enums.TaskStatus.pending:
        return '#757575';
      case enums.TaskStatus.inProgress:
        return '#2196F3';
      case enums.TaskStatus.completed:
        return '#4CAF50';
      case enums.TaskStatus.cancelled:
        return '#F44336';
    }
  }

  /// Get update type text
  String _getUpdateTypeText(TaskUpdateType updateType) {
    switch (updateType) {
      case TaskUpdateType.completed:
        return 'Task Completed';
      case TaskUpdateType.statusChanged:
        return 'Status Changed';
      case TaskUpdateType.priorityChanged:
        return 'Priority Changed';
      case TaskUpdateType.dueDateChanged:
        return 'Due Date Changed';
      case TaskUpdateType.assigned:
        return 'Task Assigned';
      case TaskUpdateType.commented:
        return 'Comment Added';
    }
  }

  /// Get update type icon
  String _getUpdateTypeIcon(TaskUpdateType updateType) {
    switch (updateType) {
      case TaskUpdateType.completed:
        return '[SUCCESS]';
      case TaskUpdateType.statusChanged:
        return '[TASK]';
      case TaskUpdateType.priorityChanged:
        return '[URGENT]';
      case TaskUpdateType.dueDateChanged:
        return '[DATE]';
      case TaskUpdateType.assigned:
        return '[USER]';
      case TaskUpdateType.commented:
        return '[EMOJI]';
    }
  }

  /// Get update type color
  String _getUpdateTypeColor(TaskUpdateType updateType) {
    switch (updateType) {
      case TaskUpdateType.completed:
        return '#4CAF50';
      case TaskUpdateType.statusChanged:
        return '#2196F3';
      case TaskUpdateType.priorityChanged:
        return '#FF9800';
      case TaskUpdateType.dueDateChanged:
        return '#9C27B0';
      case TaskUpdateType.assigned:
        return '#607D8B';
      case TaskUpdateType.commented:
        return '#795548';
    }
  }

  /// Load email configuration from storage
  Future<void> _loadEmailConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('email_configuration');
      
      if (configJson != null) {
        final configMap = jsonDecode(configJson) as Map<String, dynamic>;
        _emailConfig = EmailConfiguration.fromJson(configMap);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading email configuration: $e');
      }
    }
  }

  /// Save email configuration to storage
  Future<void> _saveEmailConfiguration(EmailConfiguration config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = jsonEncode(config.toJson());
      await prefs.setString('email_configuration', configJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving email configuration: $e');
      }
    }
  }

  /// Load shared tasks from storage
  Future<void> _loadSharedTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sharedTasksJson = prefs.getString('shared_tasks');
      
      if (sharedTasksJson != null) {
        final sharedTasksMap = jsonDecode(sharedTasksJson) as Map<String, dynamic>;
        _sharedTasks.clear();
        
        sharedTasksMap.forEach((taskId, data) {
          _sharedTasks[taskId] = SharedTask.fromJson(data as Map<String, dynamic>);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading shared tasks: $e');
      }
    }
  }

  /// Save shared tasks to storage
  Future<void> _saveSharedTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sharedTasksMap = _sharedTasks.map((taskId, sharedTask) =>
          MapEntry(taskId, sharedTask.toJson()));
      
      final sharedTasksJson = jsonEncode(sharedTasksMap);
      await prefs.setString('shared_tasks', sharedTasksJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving shared tasks: $e');
      }
    }
  }

  /// Get shared task info
  SharedTask? getSharedTaskInfo(String taskId) {
    return _sharedTasks[taskId];
  }

  /// Get all shared tasks
  List<SharedTask> getAllSharedTasks() {
    return _sharedTasks.values.toList();
  }

  /// Remove task from shared list
  Future<void> removeFromShared(String taskId) async {
    _sharedTasks.remove(taskId);
    await _saveSharedTasks();
    
    _emailEventController.add(EmailEvent(
      type: EmailEventType.taskUnshared,
      message: 'Task removed from shared list',
      taskId: taskId,
    ));
  }

  /// Dispose resources
  void dispose() {
    _emailEventController.close();
  }
}

/// Email configuration
class EmailConfiguration {
  final EmailProvider provider;
  final String username;
  final String password;
  final String? fromName;
  final String? fromEmail;
  final String? smtpServer;
  final int smtpPort;
  final bool useSsl;

  const EmailConfiguration({
    required this.provider,
    required this.username,
    required this.password,
    this.fromName,
    this.fromEmail,
    this.smtpServer,
    this.smtpPort = 587,
    this.useSsl = true,
  });

  factory EmailConfiguration.fromJson(Map<String, dynamic> json) {
    return EmailConfiguration(
      provider: EmailProvider.values.firstWhere(
        (p) => p.name == json['provider'],
        orElse: () => EmailProvider.custom,
      ),
      username: json['username'] as String,
      password: json['password'] as String,
      fromName: json['fromName'] as String?,
      fromEmail: json['fromEmail'] as String?,
      smtpServer: json['smtpServer'] as String?,
      smtpPort: json['smtpPort'] as int? ?? 587,
      useSsl: json['useSsl'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.name,
      'username': username,
      'password': password,
      'fromName': fromName,
      'fromEmail': fromEmail,
      'smtpServer': smtpServer,
      'smtpPort': smtpPort,
      'useSsl': useSsl,
    };
  }
}

/// Email providers
enum EmailProvider {
  gmail,
  outlook,
  yahoo,
  custom,
}

/// Email share options
class EmailShareOptions {
  final bool includeAttachments;
  final bool includeTaskData;
  final bool includeDataExport;
  final export_models.ExportFormat? exportFormat;
  final bool sendAsHtml;
  final String? customMessage;

  const EmailShareOptions({
    this.includeAttachments = false,
    this.includeTaskData = false,
    this.includeDataExport = false,
    this.exportFormat,
    this.sendAsHtml = true,
    this.customMessage,
  });
}

/// Email content
class EmailContent {
  final String subject;
  final String htmlBody;
  final String textBody;

  const EmailContent({
    required this.subject,
    required this.htmlBody,
    required this.textBody,
  });
}

/// Email result
class EmailResult {
  final bool success;
  final String? messageId;
  final String? error;

  const EmailResult({
    required this.success,
    this.messageId,
    this.error,
  });
}

/// Shared task information
class SharedTask {
  final String taskId;
  final List<String> recipients;
  final DateTime sharedAt;
  final ShareType shareType;
  final EmailShareOptions options;

  const SharedTask({
    required this.taskId,
    required this.recipients,
    required this.sharedAt,
    required this.shareType,
    required this.options,
  });

  factory SharedTask.fromJson(Map<String, dynamic> json) {
    return SharedTask(
      taskId: json['taskId'] as String,
      recipients: (json['recipients'] as List).cast<String>(),
      sharedAt: DateTime.parse(json['sharedAt'] as String),
      shareType: ShareType.values.firstWhere(
        (t) => t.name == json['shareType'],
        orElse: () => ShareType.email,
      ),
      options: const EmailShareOptions(), // Simplified for now
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'recipients': recipients,
      'sharedAt': sharedAt.toIso8601String(),
      'shareType': shareType.name,
    };
  }
}

/// Share types
enum ShareType {
  email,
  link,
  export,
}

/// Task update types for notifications
enum TaskUpdateType {
  completed,
  statusChanged,
  priorityChanged,
  dueDateChanged,
  assigned,
  commented,
}

/// Email events
class EmailEvent {
  final EmailEventType type;
  final String message;
  final String? taskId;
  final String? projectId;
  final List<String>? recipients;
  final String? error;
  final Map<String, dynamic>? details;

  const EmailEvent({
    required this.type,
    required this.message,
    this.taskId,
    this.projectId,
    this.recipients,
    this.error,
    this.details,
  });
}

/// Email event types
enum EmailEventType {
  configurationUpdated,
  taskShared,
  multipleTasksShared,
  projectShared,
  updateNotificationSent,
  reminderSent,
  shareError,
  taskUnshared,
}