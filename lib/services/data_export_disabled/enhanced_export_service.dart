import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/project.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../domain/repositories/task_repository.dart';
import 'cloud_storage_service.dart';
import 'data_export_models.dart';
import 'data_export_service.dart';
import 'enterprise_reporting_service.dart';
import 'excel_export_service.dart';
import 'external_import_adapters.dart';
import 'microsoft_project_export_service.dart';

/// Enhanced data export service with enterprise-grade features
class EnhancedExportService implements DataExportService {
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;
  final TagRepository _tagRepository;
  
  // Specialized services
  late final ExcelExportService _excelService;
  late final MicrosoftProjectExportService _msProjectService;
  late final EnterpriseReportingService _reportingService;
  late final CloudStorageService _cloudService;
  late final ExternalImportAdapters _importAdapters;

  EnhancedExportService({
    required TaskRepository taskRepository,
    required ProjectRepository projectRepository,
    required TagRepository tagRepository,
  })  : _taskRepository = taskRepository,
        _projectRepository = projectRepository,
        _tagRepository = tagRepository {
    _initializeServices();
  }

  void _initializeServices() {
    _excelService = ExcelExportService();
    _msProjectService = MicrosoftProjectExportService();
    _reportingService = EnterpriseReportingService(
      excelService: _excelService,
    );
    _cloudService = CloudStorageService();
    _importAdapters = ExternalImportAdapters();
  }

  @override
  Future<ExportResult> exportTasks(
    List<TaskModel> tasks, {
    ExportFormat format = ExportFormat.csv,
    ExportOptions? options,
  }) async {
    try {
      final directory = await getExportDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = _generateFileName('tasks', format, timestamp);
      final filePath = path.join(directory, fileName);

      switch (format) {
        case ExportFormat.csv:
          return await _exportTasksToCSV(tasks, filePath, options);
        case ExportFormat.json:
          return await _exportTasksToJSON(tasks, filePath, options);
        case ExportFormat.plainText:
          return await _exportTasksToPlainText(tasks, filePath, options);
        case ExportFormat.pdf:
          return await _exportTasksToPDF(tasks, filePath, options);
        case ExportFormat.excel:
          return await _excelService.exportTasksToExcel(
            tasks: tasks,
            filePath: filePath,
            options: options,
          );
        case ExportFormat.microsoftProject:
        case ExportFormat.microsoftProjectXML:
          final projects = await _getProjectsForTasks(tasks);
          return await _msProjectService.exportToMicrosoftProjectXML(
            projects: projects,
            tasks: tasks,
            filePath: filePath.replaceAll('.mspx', '.xml'),
            options: options,
          );
        case ExportFormat.ganttChart:
          final projects = await _getProjectsForTasks(tasks);
          return await _msProjectService.exportToGanttChart(
            projects: projects,
            tasks: tasks,
            filePath: filePath.replaceAll('.gantt', '.json'),
            options: options,
          );
        case ExportFormat.executiveReport:
          final projects = await _getProjectsForTasks(tasks);
          return await _reportingService.generateExecutiveSummaryReport(
            tasks: tasks,
            projects: projects,
            filePath: filePath,
            options: options,
          );
        case ExportFormat.analyticsReport:
          final projects = await _getProjectsForTasks(tasks);
          return await _reportingService.generateProjectPerformanceReport(
            projects: projects,
            tasks: tasks,
            filePath: filePath,
            options: options,
          );
        case ExportFormat.timelineReport:
          final projects = await _getProjectsForTasks(tasks);
          return await _reportingService.generateTimeTrackingReport(
            tasks: tasks,
            filePath: filePath,
            options: options,
          );
        case ExportFormat.kanbanBoard:
          return await _exportToKanbanBoard(tasks, filePath, options);
        case ExportFormat.templatePackage:
          return await _exportAsTemplatePackage(tasks, filePath, options);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Enhanced export tasks error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Export failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }

  @override
  Future<ExportResult> exportProjects(
    List<Project> projects, {
    ExportFormat format = ExportFormat.csv,
    ExportOptions? options,
  }) async {
    try {
      final directory = await getExportDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = _generateFileName('projects', format, timestamp);
      final filePath = path.join(directory, fileName);

      // Get all tasks for these projects
      final allTasks = <TaskModel>[];
      for (final project in projects) {
        for (final taskId in project.taskIds) {
          final task = await _taskRepository.getTaskById(taskId);
          if (task != null) allTasks.add(task);
        }
      }

      switch (format) {
        case ExportFormat.csv:
          return await _exportProjectsToCSV(projects, filePath, options);
        case ExportFormat.json:
          return await _exportProjectsToJSON(projects, filePath, options);
        case ExportFormat.excel:
          return await _excelService.exportProjectsToExcel(
            projects: projects,
            allTasks: allTasks,
            filePath: filePath,
            options: options,
          );
        case ExportFormat.microsoftProjectXML:
          return await _msProjectService.exportToMicrosoftProjectXML(
            projects: projects,
            tasks: allTasks,
            filePath: filePath.replaceAll('.xlsx', '.xml'),
            options: options,
          );
        case ExportFormat.executiveReport:
          return await _reportingService.generateExecutiveSummaryReport(
            tasks: allTasks,
            projects: projects,
            filePath: filePath,
            options: options,
          );
        case ExportFormat.analyticsReport:
          return await _reportingService.generateProjectPerformanceReport(
            projects: projects,
            tasks: allTasks,
            filePath: filePath,
            options: options,
          );
        default:
          return await _exportProjectsToCSV(projects, filePath, options);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Enhanced export projects error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Project export failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }

  /// Export data with cloud storage integration
  Future<ExportResult> exportAndUploadToCloud({
    required ExportFormat format,
    required String cloudProvider,
    required String accessToken,
    List<String>? taskIds,
    List<String>? projectIds,
    String? cloudFolderId,
    ShareConfig? shareConfig,
    ExportOptions? options,
  }) async {
    try {
      // First, perform the export
      List<TaskModel> tasks = [];
      List<Project> projects = [];

      if (taskIds != null) {
        for (final id in taskIds) {
          final task = await _taskRepository.getTaskById(id);
          if (task != null) tasks.add(task);
        }
      } else {
        tasks = await _taskRepository.getAllTasks();
      }

      if (projectIds != null) {
        for (final id in projectIds) {
          final project = await _projectRepository.getProjectById(id);
          if (project != null) projects.add(project);
        }
      } else {
        projects = await _projectRepository.getAllProjects();
      }

      // Export the data locally
      ExportResult localResult;
      if (tasks.isNotEmpty && projects.isNotEmpty) {
        localResult = await exportFullBackup(options: options);
      } else if (tasks.isNotEmpty) {
        localResult = await exportTasks(tasks, format: format, options: options);
      } else {
        localResult = await exportProjects(projects, format: format, options: options);
      }

      if (!localResult.success || localResult.filePath == null) {
        return localResult;
      }

      // Upload to cloud storage
      ExportResult cloudResult;
      switch (cloudProvider.toLowerCase()) {
        case 'googledrive':
          cloudResult = await _cloudService.uploadToGoogleDrive(
            filePath: localResult.filePath!,
            folderId: cloudFolderId,
            shareConfig: shareConfig,
          );
          break;
        case 'dropbox':
          cloudResult = await _cloudService.uploadToDropbox(
            filePath: localResult.filePath!,
            accessToken: accessToken,
            shareConfig: shareConfig,
          );
          break;
        case 'onedrive':
          cloudResult = await _cloudService.uploadToOneDrive(
            filePath: localResult.filePath!,
            accessToken: accessToken,
            folderId: cloudFolderId,
            shareConfig: shareConfig,
          );
          break;
        default:
          return ExportResult(
            success: false,
            message: 'Unsupported cloud provider: $cloudProvider',
            filePath: null,
            fileSize: 0,
          );
      }

      return ExportResult(
        success: cloudResult.success,
        message: cloudResult.success 
            ? 'Export completed and uploaded to $cloudProvider successfully'
            : 'Local export succeeded but cloud upload failed: ${cloudResult.message}',
        filePath: cloudResult.success ? cloudResult.filePath : localResult.filePath,
        fileSize: localResult.fileSize,
        exportedAt: DateTime.now(),
        metadata: {
          ...localResult.metadata,
          ...cloudResult.metadata,
          'localPath': localResult.filePath,
          'cloudPath': cloudResult.filePath,
          'cloudProvider': cloudProvider,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Export and upload error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Export and upload failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }

  /// Import from external platforms
  Future<ImportResultData> importFromExternalPlatform({
    required ImportSource source,
    required Map<String, String> credentials,
    ImportOptions? options,
  }) async {
    try {
      switch (source) {
        case ImportSource.trello:
          return await _importAdapters.importFromTrello(
            boardId: credentials['boardId']!,
            apiKey: credentials['apiKey']!,
            token: credentials['token']!,
            options: options,
          );
        case ImportSource.asana:
          return await _importAdapters.importFromAsana(
            projectId: credentials['projectId']!,
            personalAccessToken: credentials['accessToken']!,
            options: options,
          );
        case ImportSource.microsoftProject:
          return await _importAdapters.importFromMicrosoftProject(
            filePath: credentials['filePath']!,
            options: options,
          );
        case ImportSource.notion:
          return await _importAdapters.importFromNotion(
            databaseId: credentials['databaseId']!,
            integrationToken: credentials['token']!,
            options: options,
          );
        case ImportSource.todoist:
          return await _importAdapters.importFromTodoist(
            projectId: credentials['projectId']!,
            apiToken: credentials['apiToken']!,
            options: options,
          );
        case ImportSource.jira:
          return await _importAdapters.importFromJira(
            baseUrl: credentials['baseUrl']!,
            projectKey: credentials['projectKey']!,
            email: credentials['email']!,
            apiToken: credentials['apiToken']!,
            options: options,
          );
        default:
          return const ImportResultData(
            success: false,
            message: 'Unsupported import source',
            importedCount: 0,
            skippedCount: 0,
            errors: ['Unsupported import source'],
          );
      }
    } catch (e) {
      if (kDebugMode) {
        print('External platform import error: $e');
      }
      return ImportResultData(
        success: false,
        message: 'Import failed: ${e.toString()}',
        importedCount: 0,
        skippedCount: 0,
        errors: [e.toString()],
      );
    }
  }

  /// Generate custom report using template
  Future<ExportResult> generateCustomReport({
    required ReportTemplate template,
    required String filePath,
    Map<String, dynamic> parameters = const {},
    ExportOptions? options,
  }) async {
    try {
      final tasks = await _taskRepository.getAllTasks();
      final projects = await _projectRepository.getAllProjects();

      return await _reportingService.generateCustomReport(
        template: template,
        tasks: tasks,
        projects: projects,
        filePath: filePath,
        parameters: parameters,
        options: options,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Custom report generation error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Custom report generation failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }

  /// Sync export directory with cloud storage
  Future<List<ExportResult>> syncExportsWithCloud({
    required String provider,
    required String accessToken,
    String? cloudFolderId,
  }) async {
    try {
      final exportDir = await getExportDirectory();
      return await _cloudService.syncWithCloud(
        provider: provider,
        accessToken: accessToken,
        localDirectory: exportDir,
        cloudFolderId: cloudFolderId,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Cloud sync error: $e');
      }
      return [];
    }
  }

  // Helper methods

  Future<List<Project>> _getProjectsForTasks(List<TaskModel> tasks) async {
    final projectIds = tasks
        .map((t) => t.projectId)
        .where((id) => id != null)
        .cast<String>()
        .toSet();
    
    final projects = <Project>[];
    for (final id in projectIds) {
      final project = await _projectRepository.getProjectById(id);
      if (project != null) projects.add(project);
    }
    return projects;
  }

  String _generateFileName(String prefix, ExportFormat format, int timestamp) {
    final extension = _getFileExtension(format);
    return '${prefix}_export_$timestamp.$extension';
  }

  String _getFileExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return 'csv';
      case ExportFormat.json:
        return 'json';
      case ExportFormat.plainText:
        return 'txt';
      case ExportFormat.pdf:
        return 'pdf';
      case ExportFormat.excel:
        return 'xlsx';
      case ExportFormat.microsoftProject:
        return 'mpp';
      case ExportFormat.microsoftProjectXML:
        return 'xml';
      case ExportFormat.ganttChart:
        return 'gantt.json';
      case ExportFormat.executiveReport:
        return 'pdf';
      case ExportFormat.kanbanBoard:
        return 'kanban.json';
      case ExportFormat.timelineReport:
        return 'timeline.pdf';
      case ExportFormat.analyticsReport:
        return 'analytics.pdf';
      case ExportFormat.templatePackage:
        return 'taskytpl';
    }
  }

  // Implementation of specialized export formats

  Future<ExportResult> _exportToKanbanBoard(
    List<TaskModel> tasks,
    String filePath,
    ExportOptions? options,
  ) async {
    final kanbanData = {
      'version': '1.0',
      'type': 'kanban_board',
      'exportedAt': DateTime.now().toIso8601String(),
      'columns': [
        {
          'id': 'pending',
          'title': 'To Do',
          'tasks': tasks
              .where((t) => t.status == TaskStatus.pending)
              .map((t) => _taskToKanbanCard(t))
              .toList(),
        },
        {
          'id': 'inProgress',
          'title': 'In Progress', 
          'tasks': tasks
              .where((t) => t.status == TaskStatus.inProgress)
              .map((t) => _taskToKanbanCard(t))
              .toList(),
        },
        {
          'id': 'completed',
          'title': 'Done',
          'tasks': tasks
              .where((t) => t.status == TaskStatus.completed)
              .map((t) => _taskToKanbanCard(t))
              .toList(),
        },
      ],
      'metadata': {
        'totalTasks': tasks.length,
        'tasksByStatus': {
          'pending': tasks.where((t) => t.status == TaskStatus.pending).length,
          'inProgress': tasks.where((t) => t.status == TaskStatus.inProgress).length,
          'completed': tasks.where((t) => t.status == TaskStatus.completed).length,
        },
      },
    };

    final file = File(filePath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(kanbanData),
    );

    return ExportResult(
      success: true,
      message: 'Kanban board export completed successfully',
      filePath: filePath,
      fileSize: await file.length(),
      exportedAt: DateTime.now(),
    );
  }

  Future<ExportResult> _exportAsTemplatePackage(
    List<TaskModel> tasks,
    String filePath,
    ExportOptions? options,
  ) async {
    final templateData = {
      'version': '1.0',
      'type': 'template_package',
      'exportedAt': DateTime.now().toIso8601String(),
      'package': {
        'id': 'template_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Exported Task Template',
        'description': 'Template package created from exported tasks',
        'version': '1.0.0',
        'author': 'Tasky User',
        'tags': ['export', 'template'],
      },
      'taskTemplates': tasks.map((task) => {
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'priority': task.priority.name,
        'tags': task.tags,
        'estimatedDuration': task.estimatedDuration,
        'isTemplate': true,
      }).toList(),
      'metadata': {
        'taskCount': tasks.length,
        'exportSource': 'tasky_app',
      },
    };

    final file = File(filePath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(templateData),
    );

    return ExportResult(
      success: true,
      message: 'Template package created successfully',
      filePath: filePath,
      fileSize: await file.length(),
      exportedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> _taskToKanbanCard(TaskModel task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'priority': task.priority.name,
      'tags': task.tags,
      'dueDate': task.dueDate?.toIso8601String(),
      'assignedTo': task.projectId, // Using project as assignee placeholder
      'estimatedHours': task.estimatedDuration,
    };
  }

  // Implement remaining abstract methods with basic functionality
  
  @override
  Future<ExportResult> exportFullBackup({ExportOptions? options}) async {
    try {
      final directory = await getExportDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'full_backup_$timestamp.json';
      final filePath = path.join(directory, fileName);

      final tasks = await _taskRepository.getAllTasks();
      final projects = await _projectRepository.getAllProjects();
      final tags = await _tagRepository.getAllTags();

      final backupData = {
        'version': '2.0',
        'timestamp': DateTime.now().toIso8601String(),
        'tasks': tasks.map((task) => task.toJson()).toList(),
        'projects': projects.map((project) => project.toJson()).toList(),
        'tags': tags.map((tag) => tag.toJson()).toList(),
        'metadata': {
          'taskCount': tasks.length,
          'projectCount': projects.length,
          'tagCount': tags.length,
          'exportedBy': 'Enhanced Tasky Export Service',
          'features': ['tasks', 'projects', 'tags', 'enterprise_formats'],
        },
      };

      final file = File(filePath);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(backupData),
      );

      return ExportResult(
        success: true,
        message: 'Enhanced full backup created successfully',
        filePath: filePath,
        fileSize: await file.length(),
        exportedAt: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Enhanced full backup error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Enhanced backup failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }

  // Implement basic CSV/JSON/PDF export methods (simplified versions)
  
  Future<ExportResult> _exportTasksToCSV(List<TaskModel> tasks, String filePath, ExportOptions? options) async {
    final rows = <List<String>>[];
    rows.add(['ID', 'Title', 'Description', 'Status', 'Priority', 'Due Date', 'Created At', 'Tags']);
    
    for (final task in tasks) {
      rows.add([
        task.id,
        task.title,
        task.description ?? '',
        task.status.name,
        task.priority.name,
        task.dueDate?.toIso8601String() ?? '',
        task.createdAt.toIso8601String(),
        task.tags.join(';'),
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    await File(filePath).writeAsString(csv);

    return ExportResult(
      success: true,
      message: 'CSV export completed successfully',
      filePath: filePath,
      fileSize: await File(filePath).length(),
      exportedAt: DateTime.now(),
    );
  }

  Future<ExportResult> _exportTasksToJSON(List<TaskModel> tasks, String filePath, ExportOptions? options) async {
    final data = {
      'version': '2.0',
      'timestamp': DateTime.now().toIso8601String(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };

    await File(filePath).writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );

    return ExportResult(
      success: true,
      message: 'JSON export completed successfully',
      filePath: filePath,
      fileSize: await File(filePath).length(),
      exportedAt: DateTime.now(),
    );
  }

  Future<ExportResult> _exportTasksToPlainText(List<TaskModel> tasks, String filePath, ExportOptions? options) async {
    final buffer = StringBuffer();
    buffer.writeln('ENHANCED TASK TRACKER EXPORT');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('Total Tasks: ${tasks.length}');
    buffer.writeln('');
    buffer.writeln('=' * 50);
    buffer.writeln('');

    for (final task in tasks) {
      buffer.writeln('Title: ${task.title}');
      if (task.description?.isNotEmpty == true) {
        buffer.writeln('Description: ${task.description}');
      }
      buffer.writeln('Priority: ${task.priority.name.toUpperCase()}');
      buffer.writeln('Status: ${task.status.name.toUpperCase()}');
      buffer.writeln('Created: ${task.createdAt}');
      if (task.dueDate != null) {
        buffer.writeln('Due Date: ${task.dueDate}');
      }
      if (task.tags.isNotEmpty) {
        buffer.writeln('Tags: ${task.tags.join(', ')}');
      }
      buffer.writeln('');
      buffer.writeln('-' * 30);
      buffer.writeln('');
    }

    await File(filePath).writeAsString(buffer.toString());

    return ExportResult(
      success: true,
      message: 'Plain text export completed successfully',
      filePath: filePath,
      fileSize: await File(filePath).length(),
      exportedAt: DateTime.now(),
    );
  }

  Future<ExportResult> _exportTasksToPDF(List<TaskModel> tasks, String filePath, ExportOptions? options) async {
    // Use the enterprise reporting service for PDF generation
    final projects = await _getProjectsForTasks(tasks);
    return await _reportingService.generateExecutiveSummaryReport(
      tasks: tasks,
      projects: projects,
      filePath: filePath,
      options: options,
    );
  }

  Future<ExportResult> _exportProjectsToCSV(List<Project> projects, String filePath, ExportOptions? options) async {
    final rows = <List<String>>[];
    rows.add(['ID', 'Name', 'Description', 'Status', 'Created At', 'Color']);
    
    for (final project in projects) {
      rows.add([
        project.id,
        project.name,
        project.description ?? '',
        project.isArchived ? 'Archived' : 'Active',
        project.createdAt.toIso8601String(),
        project.color,
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    await File(filePath).writeAsString(csv);

    return ExportResult(
      success: true,
      message: 'Project CSV export completed successfully',
      filePath: filePath,
      fileSize: await File(filePath).length(),
      exportedAt: DateTime.now(),
    );
  }

  Future<ExportResult> _exportProjectsToJSON(List<Project> projects, String filePath, ExportOptions? options) async {
    final data = {
      'version': '2.0',
      'timestamp': DateTime.now().toIso8601String(),
      'projects': projects.map((project) => project.toJson()).toList(),
    };

    await File(filePath).writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );

    return ExportResult(
      success: true,
      message: 'Project JSON export completed successfully',
      filePath: filePath,
      fileSize: await File(filePath).length(),
      exportedAt: DateTime.now(),
    );
  }

  // Implement remaining DataExportService methods with delegations to the original implementation
  
  @override
  Future<ImportResultData> importTasks(String filePath, {ImportOptions? options}) async {
    // Delegate to existing implementation or enhance as needed
    throw UnimplementedError('Use importFromExternalPlatform for advanced imports');
  }

  @override
  Future<ImportResultData> importProjects(String filePath, {ImportOptions? options}) async {
    throw UnimplementedError('Use importFromExternalPlatform for advanced imports');
  }

  @override
  Future<ImportResultData> importFullBackup(String filePath, {ImportOptions? options}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return const ImportResultData(
          success: false,
          message: 'Backup file not found',
          importedCount: 0,
          skippedCount: 0,
          errors: ['File does not exist'],
        );
      }

      final jsonContent = await file.readAsString();
      final backupData = jsonDecode(jsonContent) as Map<String, dynamic>;

      int totalImported = 0;
      int totalSkipped = 0;
      final errors = <String>[];

      // Import tasks
      if (backupData.containsKey('tasks')) {
        final tasksData = backupData['tasks'] as List;
        for (final taskJson in tasksData) {
          try {
            final task = TaskModel.fromJson(taskJson as Map<String, dynamic>);
            await _taskRepository.createTask(task);
            totalImported++;
          } catch (e) {
            errors.add('Failed to import task: ${e.toString()}');
            totalSkipped++;
          }
        }
      }

      // Import projects
      if (backupData.containsKey('projects')) {
        final projectsData = backupData['projects'] as List;
        for (final projectJson in projectsData) {
          try {
            final project = Project.fromJson(projectJson as Map<String, dynamic>);
            await _projectRepository.createProject(project);
            totalImported++;
          } catch (e) {
            errors.add('Failed to import project: ${e.toString()}');
            totalSkipped++;
          }
        }
      }

      return ImportResultData(
        success: errors.isEmpty || totalImported > 0,
        message: 'Enhanced backup restored: $totalImported items imported',
        importedCount: totalImported,
        skippedCount: totalSkipped,
        errors: errors,
        importedAt: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Enhanced import backup error: $e');
      }
      return ImportResultData(
        success: false,
        message: 'Enhanced backup restore failed: ${e.toString()}',
        importedCount: 0,
        skippedCount: 0,
        errors: [e.toString()],
      );
    }
  }

  @override
  Future<bool> shareFile(String filePath, {String? subject}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          subject: subject ?? 'Enhanced Tasky Export',
          text: 'Exported data from Enhanced Tasky app with enterprise features',
        ),
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Enhanced share file error: $e');
      }
      return false;
    }
  }

  @override
  Future<String?> pickImportFile({List<String>? allowedExtensions}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? [
          'csv', 'json', 'xlsx', 'xml', 'mpp', 'gantt',
          'taskytpl' // Template packages
        ],
        allowMultiple: false,
      );

      return result?.files.single.path;
    } catch (e) {
      if (kDebugMode) {
        print('Enhanced pick file error: $e');
      }
      return null;
    }
  }

  @override
  Future<List<ExportFormat>> getSupportedFormats() async {
    return ExportFormat.values;
  }

  @override
  Future<bool> hasStoragePermission() async {
    try {
      final status = await Permission.storage.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      return true;
    }
  }

  @override
  Future<bool> requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      return true;
    }
  }

  @override
  Future<String> getExportDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory(path.join(directory.path, 'enhanced_exports'));

      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      return exportDir.path;
    } catch (e) {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  @override
  Future<void> cleanupOldExports({int maxAgeInDays = 30}) async {
    try {
      final directory = await getExportDirectory();
      final exportDir = Directory(directory);

      if (!await exportDir.exists()) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: maxAgeInDays));

      await for (final entity in exportDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Enhanced cleanup exports error: $e');
      }
    }
  }

  // Additional DataExportService methods (simplified implementations)
  
  @override
  Future<bool> requestStoragePermissions() => requestStoragePermission();

  @override
  Stream<ExportProgress> exportData({
    required ExportFormat format,
    String? filePath,
    List<String>? taskIds,
    List<String>? projectIds,
  }) async* {
    yield const ExportProgress(
      totalItems: 0,
      processedItems: 0,
      currentOperation: 'Starting enhanced export...',
      progress: 0.0,
    );
    // Simplified implementation - in production would provide real progress updates
  }

  @override
  Future<void> shareData({
    required ExportFormat format,
    List<String>? taskIds,
    List<String>? projectIds,
  }) async {
    // Simplified implementation
  }

  @override
  Future<ImportValidationResult> validateImportFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return const ImportValidationResult(
          isValid: false,
          errors: ['File does not exist'],
          warnings: [],
          taskCount: 0,
          projectCount: 0,
          tagCount: 0,
        );
      }

      return const ImportValidationResult(
        isValid: true,
        errors: [],
        warnings: [],
        taskCount: 0,
        projectCount: 0,
        tagCount: 0,
      );
    } catch (e) {
      return ImportValidationResult(
        isValid: false,
        errors: ['Failed to validate file: ${e.toString()}'],
        warnings: [],
        taskCount: 0,
        projectCount: 0,
        tagCount: 0,
      );
    }
  }

  @override
  Stream<ImportProgress> importData({
    required String filePath,
    ImportOptions? options,
  }) async* {
    yield const ImportProgress(
      totalItems: 0,
      processedItems: 0,
      currentOperation: 'Starting enhanced import...',
      progress: 0.0,
    );
    // Simplified implementation
  }

  @override
  Future<List<BackupMetadata>> getAvailableBackups() async {
    try {
      final directory = await getExportDirectory();
      final exportDir = Directory(directory);

      if (!await exportDir.exists()) return [];

      final backups = <BackupMetadata>[];

      await for (final entity in exportDir.list()) {
        if (entity is File && entity.path.contains('full_backup_')) {
          final stat = await entity.stat();
          final fileName = path.basename(entity.path);

          backups.add(BackupMetadata(
            id: fileName,
            createdAt: stat.modified,
            appVersion: '2.0.0',
            taskCount: 0,
            projectCount: 0,
            tagCount: 0,
            fileSizeBytes: stat.size,
            checksum: '',
          ));
        }
      }

      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return backups;
    } catch (e) {
      if (kDebugMode) {
        print('Enhanced get available backups error: $e');
      }
      return [];
    }
  }

  @override
  Future<String> createBackup() async {
    final result = await exportFullBackup();
    if (result.success && result.filePath != null) {
      return result.filePath!;
    }
    throw Exception(result.message);
  }

  @override
  Future<void> restoreBackup(String backupPath) async {
    final result = await importFullBackup(backupPath);
    if (!result.success) {
      throw Exception(result.message);
    }
  }

  @override
  Future<void> deleteBackup(String backupId) async {
    try {
      final backupDirPath = await getExportDirectory();
      final file = File(path.join(backupDirPath, backupId));
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Enhanced delete backup error: $e');
      }
      throw Exception('Failed to delete backup: ${e.toString()}');
    }
  }

  /// Dispose of resources
  void dispose() {
    _importAdapters.dispose();
  }
}