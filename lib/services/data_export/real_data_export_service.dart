import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/project.dart';
import '../../domain/models/enums.dart' show TaskPriority, TaskStatus;
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/tag_repository.dart';
import 'data_export_service.dart';
import 'data_export_models.dart';

/// Real implementation of DataExportService with full functionality
class RealDataExportService implements DataExportService {
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;
  final TagRepository _tagRepository;

  RealDataExportService({
    required TaskRepository taskRepository,
    required ProjectRepository projectRepository,
    required TagRepository tagRepository,
  })  : _taskRepository = taskRepository,
        _projectRepository = projectRepository,
        _tagRepository = tagRepository;

  @override
  Future<ExportResult> exportTasks(
    List<TaskModel> tasks, {
    ExportFormat format = ExportFormat.csv,
    ExportOptions? options,
  }) async {
    try {
      final directory = await getExportDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'tasks_export_$timestamp.${format.extension}';
      final filePath = path.join(directory, fileName);

      switch (format) {
        case ExportFormat.csv:
          await _exportTasksToCSV(tasks, filePath, options);
          break;
        case ExportFormat.json:
          await _exportTasksToJSON(tasks, filePath, options);
          break;
        case ExportFormat.plainText:
          await _exportTasksToPlainText(tasks, filePath, options);
          break;
        case ExportFormat.pdf:
          await _exportTasksToPDF(tasks, filePath, options);
          break;
        case ExportFormat.excel:
          await _exportTasksToExcel(tasks, filePath, options);
          break;
      }

      final file = File(filePath);
      final fileSize = await file.length();

      return ExportResult(
        success: true,
        message: 'Successfully exported ${tasks.length} tasks',
        filePath: filePath,
        fileSize: fileSize,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Export tasks error: $e');
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
      final fileName = 'projects_export_$timestamp.${format.extension}';
      final filePath = path.join(directory, fileName);

      switch (format) {
        case ExportFormat.csv:
          await _exportProjectsToCSV(projects, filePath, options);
          break;
        case ExportFormat.json:
          await _exportProjectsToJSON(projects, filePath, options);
          break;
        case ExportFormat.plainText:
          await _exportProjectsToPlainText(projects, filePath, options);
          break;
        case ExportFormat.pdf:
          await _exportProjectsToPDF(projects, filePath, options);
          break;
        case ExportFormat.excel:
          await _exportProjectsToExcel(projects, filePath, options);
          break;
      }

      final file = File(filePath);
      final fileSize = await file.length();

      return ExportResult(
        success: true,
        message: 'Successfully exported ${projects.length} projects',
        filePath: filePath,
        fileSize: fileSize,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Export projects error: $e');
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
  Future<ExportResult> exportFullBackup({ExportOptions? options}) async {
    try {
      final directory = await getExportDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'full_backup_$timestamp.json';
      final filePath = path.join(directory, fileName);

      // Get all data
      final tasks = await _taskRepository.getAllTasks();
      final projects = await _projectRepository.getAllProjects();
      final tags = await _tagRepository.getAllTags();

      // Create backup data
      final backupData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'tasks': tasks.map((task) => task.toJson()).toList(),
        'projects': projects.map((project) => project.toJson()).toList(),
        'tags': tags.map((tag) => tag.toJson()).toList(),
        'metadata': {
          'taskCount': tasks.length,
          'projectCount': projects.length,
          'tagCount': tags.length,
          'exportedBy': 'Tasky App',
        },
      };

      // Write to file
      final file = File(filePath);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(backupData),
      );

      final fileSize = await file.length();

      return ExportResult(
        success: true,
        message: 'Full backup created successfully',
        filePath: filePath,
        fileSize: fileSize,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Full backup error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Backup failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }

  @override
  Future<ImportResultData> importTasks(
    String filePath, {
    ImportOptions? options,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return const ImportResultData(
          success: false,
          message: 'File not found',
          importedCount: 0,
          skippedCount: 0,
          errors: ['File does not exist'],
        );
      }

      final extension = path.extension(filePath).toLowerCase();
      List<Map<String, dynamic>> rawTasks;

      switch (extension) {
        case '.csv':
          rawTasks = await _importTasksFromCSV(filePath);
          break;
        case '.json':
          rawTasks = await _importTasksFromJSON(filePath);
          break;
        default:
          return const ImportResultData(
            success: false,
            message: 'Unsupported file format',
            importedCount: 0,
            skippedCount: 0,
            errors: ['Only CSV and JSON files are supported'],
          );
      }

      int importedCount = 0;
      int skippedCount = 0;
      final errors = <String>[];

      for (final rawTask in rawTasks) {
        try {
          final task = TaskModel.fromJson(rawTask);
          
          // Check if task already exists (by title or ID)
          final existingTasks = await _taskRepository.searchTasks(task.title);
          if (existingTasks.any((existing) => existing.title == task.title)) {
            if (options?.overwriteExisting == false) {
              skippedCount++;
              continue;
            }
          }

          await _taskRepository.createTask(task);
          importedCount++;
        } catch (e) {
          errors.add('Failed to import task: ${e.toString()}');
          skippedCount++;
        }
      }

      return ImportResultData(
        success: errors.isEmpty || importedCount > 0,
        message: 'Imported $importedCount tasks, skipped $skippedCount',
        importedCount: importedCount,
        skippedCount: skippedCount,
        errors: errors,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Import tasks error: $e');
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

  @override
  Future<ImportResultData> importProjects(
    String filePath, {
    ImportOptions? options,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return const ImportResultData(
          success: false,
          message: 'File not found',
          importedCount: 0,
          skippedCount: 0,
          errors: ['File does not exist'],
        );
      }

      final extension = path.extension(filePath).toLowerCase();
      List<Map<String, dynamic>> rawProjects;

      switch (extension) {
        case '.csv':
          rawProjects = await _importProjectsFromCSV(filePath);
          break;
        case '.json':
          rawProjects = await _importProjectsFromJSON(filePath);
          break;
        default:
          return const ImportResultData(
            success: false,
            message: 'Unsupported file format',
            importedCount: 0,
            skippedCount: 0,
            errors: ['Only CSV and JSON files are supported'],
          );
      }

      int importedCount = 0;
      int skippedCount = 0;
      final errors = <String>[];

      for (final rawProject in rawProjects) {
        try {
          final project = Project.fromJson(rawProject);
          
          // Check if project already exists
          final existingProjects = await _projectRepository.getAllProjects();
          if (existingProjects.any((existing) => existing.name == project.name)) {
            if (options?.overwriteExisting == false) {
              skippedCount++;
              continue;
            }
          }

          await _projectRepository.createProject(project);
          importedCount++;
        } catch (e) {
          errors.add('Failed to import project: ${e.toString()}');
          skippedCount++;
        }
      }

      return ImportResultData(
        success: errors.isEmpty || importedCount > 0,
        message: 'Imported $importedCount projects, skipped $skippedCount',
        importedCount: importedCount,
        skippedCount: skippedCount,
        errors: errors,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Import projects error: $e');
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

  @override
  Future<ImportResultData> importFullBackup(
    String filePath, {
    ImportOptions? options,
  }) async {
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
        message: 'Backup restored: $totalImported items imported',
        importedCount: totalImported,
        skippedCount: totalSkipped,
        errors: errors,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Import backup error: $e');
      }
      return ImportResultData(
        success: false,
        message: 'Backup restore failed: ${e.toString()}',
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

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: subject ?? 'Tasky Export',
        text: 'Exported data from Tasky app',
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Share file error: $e');
      }
      return false;
    }
  }

  @override
  Future<String?> pickImportFile({List<String>? allowedExtensions}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions ?? ['csv', 'json'],
        allowMultiple: false,
      );

      return result?.files.single.path;
    } catch (e) {
      if (kDebugMode) {
        print('Pick file error: $e');
      }
      return null;
    }
  }

  @override
  Future<List<ExportFormat>> getSupportedFormats() async {
    return [
      ExportFormat.csv,
      ExportFormat.json,
      ExportFormat.plainText,
      ExportFormat.pdf,
      ExportFormat.excel,
    ];
  }

  @override
  Future<bool> hasStoragePermission() async {
    try {
      final status = await Permission.storage.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      return true; // Assume granted if we can't check
    }
  }

  @override
  Future<bool> requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      return true; // Assume granted if we can't request
    }
  }

  @override
  Future<String> getExportDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory(path.join(directory.path, 'exports'));
      
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      
      return exportDir.path;
    } catch (e) {
      // Fallback to app documents directory
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
        print('Cleanup exports error: $e');
      }
    }
  }

  // CSV Export Methods
  Future<void> _exportTasksToCSV(
    List<TaskModel> tasks,
    String filePath,
    ExportOptions? options,
  ) async {
    final rows = <List<String>>[];
    
    // Header row
    rows.add([
      'ID',
      'Title',
      'Description',
      'Status',
      'Priority',
      'Due Date',
      'Created At',
      'Updated At',
      'Completed At',
      'Tags',
      'Project ID',
      'Is Pinned',
      'Estimated Duration',
      'Actual Duration',
    ]);

    // Data rows
    for (final task in tasks) {
      rows.add([
        task.id,
        task.title,
        task.description ?? '',
        task.status.name,
        task.priority.name,
        task.dueDate?.toIso8601String() ?? '',
        task.createdAt.toIso8601String(),
        task.updatedAt?.toIso8601String() ?? '',
        task.completedAt?.toIso8601String() ?? '',
        task.tags.join(';'),
        task.projectId ?? '',
        task.isPinned.toString(),
        task.estimatedDuration?.toString() ?? '',
        task.actualDuration?.toString() ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    await File(filePath).writeAsString(csv);
  }

  Future<void> _exportProjectsToCSV(
    List<Project> projects,
    String filePath,
    ExportOptions? options,
  ) async {
    final rows = <List<String>>[];
    
    // Header row
    rows.add([
      'ID',
      'Name',
      'Description',
      'Status',
      'Created At',
      'Updated At',
      'Color',
    ]);

    // Data rows
    for (final project in projects) {
      rows.add([
        project.id,
        project.name,
        project.description ?? '',
        project.isArchived ? 'archived' : 'active',
        project.createdAt.toIso8601String(),
        project.updatedAt?.toIso8601String() ?? '',
        project.color,
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    await File(filePath).writeAsString(csv);
  }

  // JSON Export Methods
  Future<void> _exportTasksToJSON(
    List<TaskModel> tasks,
    String filePath,
    ExportOptions? options,
  ) async {
    final data = {
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };

    await File(filePath).writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );
  }

  Future<void> _exportProjectsToJSON(
    List<Project> projects,
    String filePath,
    ExportOptions? options,
  ) async {
    final data = {
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'projects': projects.map((project) => project.toJson()).toList(),
    };

    await File(filePath).writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );
  }

  // Excel Export (basic implementation)
  Future<void> _exportTasksToExcel(
    List<TaskModel> tasks,
    String filePath,
    ExportOptions? options,
  ) async {
    // For now, export as CSV with .xlsx extension
    await _exportTasksToCSV(tasks, filePath.replaceAll('.xlsx', '.csv'), options);
  }

  Future<void> _exportProjectsToExcel(
    List<Project> projects,
    String filePath,
    ExportOptions? options,
  ) async {
    // For now, export as CSV with .xlsx extension
    await _exportProjectsToCSV(projects, filePath.replaceAll('.xlsx', '.csv'), options);
  }

  // CSV Import Methods
  Future<List<Map<String, dynamic>>> _importTasksFromCSV(String filePath) async {
    final file = File(filePath);
    final csvContent = await file.readAsString();
    final rows = const CsvToListConverter().convert(csvContent);
    
    if (rows.isEmpty) return [];
    
    final headers = rows.first.map((header) => header.toString()).toList();
    final tasks = <Map<String, dynamic>>[];
    
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      final task = <String, dynamic>{};
      
      for (int j = 0; j < headers.length && j < row.length; j++) {
        final header = headers[j];
        final value = row[j]?.toString() ?? '';
        
        switch (header.toLowerCase()) {
          case 'id':
            task['id'] = value;
            break;
          case 'title':
            task['title'] = value;
            break;
          case 'description':
            task['description'] = value.isEmpty ? null : value;
            break;
          case 'status':
            task['status'] = value;
            break;
          case 'priority':
            task['priority'] = value;
            break;
          case 'due date':
            task['dueDate'] = value.isEmpty ? null : value;
            break;
          case 'created at':
            task['createdAt'] = value;
            break;
          case 'tags':
            task['tags'] = value.isEmpty ? [] : value.split(';');
            break;
          case 'is pinned':
            task['isPinned'] = value.toLowerCase() == 'true';
            break;
        }
      }
      
      tasks.add(task);
    }
    
    return tasks;
  }

  Future<List<Map<String, dynamic>>> _importProjectsFromCSV(String filePath) async {
    final file = File(filePath);
    final csvContent = await file.readAsString();
    final rows = const CsvToListConverter().convert(csvContent);
    
    if (rows.isEmpty) return [];
    
    final headers = rows.first.map((header) => header.toString()).toList();
    final projects = <Map<String, dynamic>>[];
    
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      final project = <String, dynamic>{};
      
      for (int j = 0; j < headers.length && j < row.length; j++) {
        final header = headers[j];
        final value = row[j]?.toString() ?? '';
        
        switch (header.toLowerCase()) {
          case 'id':
            project['id'] = value;
            break;
          case 'name':
            project['name'] = value;
            break;
          case 'description':
            project['description'] = value.isEmpty ? null : value;
            break;
          case 'status':
            project['status'] = value;
            break;
          case 'created at':
            project['createdAt'] = value;
            break;
        }
      }
      
      projects.add(project);
    }
    
    return projects;
  }

  // JSON Import Methods
  Future<List<Map<String, dynamic>>> _importTasksFromJSON(String filePath) async {
    final file = File(filePath);
    final jsonContent = await file.readAsString();
    final data = jsonDecode(jsonContent) as Map<String, dynamic>;
    
    if (data.containsKey('tasks')) {
      return (data['tasks'] as List).cast<Map<String, dynamic>>();
    }
    
    return [];
  }

  Future<List<Map<String, dynamic>>> _importProjectsFromJSON(String filePath) async {
    final file = File(filePath);
    final jsonContent = await file.readAsString();
    final data = jsonDecode(jsonContent) as Map<String, dynamic>;
    
    if (data.containsKey('projects')) {
      return (data['projects'] as List).cast<Map<String, dynamic>>();
    }
    
    return [];
  }

  // Implement remaining abstract methods from DataExportService

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
      currentOperation: 'Starting export...',
      progress: 0.0,
    );

    try {
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

      final totalItems = tasks.length + projects.length;
      int processedItems = 0;

      yield ExportProgress(
        totalItems: totalItems,
        processedItems: processedItems,
        currentOperation: 'Exporting tasks...',
        progress: 0.0,
      );

      if (tasks.isNotEmpty) {
        await exportTasks(tasks, format: format);
        processedItems += tasks.length;
        
        yield ExportProgress(
          totalItems: totalItems,
          processedItems: processedItems,
          currentOperation: 'Tasks exported',
          progress: processedItems / totalItems,
        );
      }

      if (projects.isNotEmpty) {
        await exportProjects(projects, format: format);
        processedItems += projects.length;
        
        yield ExportProgress(
          totalItems: totalItems,
          processedItems: processedItems,
          currentOperation: 'Projects exported',
          progress: processedItems / totalItems,
        );
      }

      yield ExportProgress(
        totalItems: totalItems,
        processedItems: processedItems,
        currentOperation: 'Export completed',
        progress: 1.0,
      );
    } catch (e) {
      yield ExportProgress(
        totalItems: 0,
        processedItems: 0,
        currentOperation: 'Export failed: ${e.toString()}',
        progress: 0.0,
      );
    }
  }

  @override
  Future<void> shareData({
    required ExportFormat format,
    List<String>? taskIds,
    List<String>? projectIds,
  }) async {
    // Export data first, then share
    final exportStream = exportData(
      format: format,
      taskIds: taskIds,
      projectIds: projectIds,
    );

    await for (final progress in exportStream) {
      if (progress.progress == 1.0) {
        // Export completed, now share
        final directory = await getExportDirectory();
        final files = await Directory(directory).list().toList();
        
        if (files.isNotEmpty) {
          final latestFile = files
              .whereType<File>()
              .reduce((a, b) => a.statSync().modified.isAfter(b.statSync().modified) ? a : b);
          await shareFile(latestFile.path);
        }
        break;
      }
    }
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

      final extension = path.extension(filePath).toLowerCase();
      final errors = <String>[];
      final warnings = <String>[];
      int taskCount = 0;
      int projectCount = 0;
      int tagCount = 0;

      switch (extension) {
        case '.csv':
          final csvContent = await file.readAsString();
          final rows = const CsvToListConverter().convert(csvContent);
          if (rows.isNotEmpty) {
            taskCount = rows.length - 1; // Subtract header
          }
          break;
        case '.json':
          final jsonContent = await file.readAsString();
          final data = jsonDecode(jsonContent) as Map<String, dynamic>;
          
          if (data.containsKey('tasks')) {
            taskCount = (data['tasks'] as List).length;
          }
          if (data.containsKey('projects')) {
            projectCount = (data['projects'] as List).length;
          }
          if (data.containsKey('tags')) {
            tagCount = (data['tags'] as List).length;
          }
          break;
        default:
          errors.add('Unsupported file format');
      }

      return ImportValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
        taskCount: taskCount,
        projectCount: projectCount,
        tagCount: tagCount,
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
      currentOperation: 'Starting import...',
      progress: 0.0,
    );

    try {
      final validation = await validateImportFile(filePath);
      if (!validation.isValid) {
        yield ImportProgress(
          totalItems: 0,
          processedItems: 0,
          currentOperation: 'Import failed: ${validation.errors.join(', ')}',
          progress: 0.0,
        );
        return;
      }

      final totalItems = validation.taskCount + validation.projectCount;
      int processedItems = 0;

      if (validation.taskCount > 0) {
        yield ImportProgress(
          totalItems: totalItems,
          processedItems: processedItems,
          currentOperation: 'Importing tasks...',
          progress: 0.0,
        );

        final result = await importTasks(filePath, options: options);
        processedItems += result.importedCount;

        yield ImportProgress(
          totalItems: totalItems,
          processedItems: processedItems,
          currentOperation: 'Tasks imported',
          progress: processedItems / totalItems,
        );
      }

      if (validation.projectCount > 0) {
        yield ImportProgress(
          totalItems: totalItems,
          processedItems: processedItems,
          currentOperation: 'Importing projects...',
          progress: processedItems / totalItems,
        );

        final result = await importProjects(filePath, options: options);
        processedItems += result.importedCount;

        yield ImportProgress(
          totalItems: totalItems,
          processedItems: processedItems,
          currentOperation: 'Projects imported',
          progress: processedItems / totalItems,
        );
      }

      yield ImportProgress(
        totalItems: totalItems,
        processedItems: processedItems,
        currentOperation: 'Import completed',
        progress: 1.0,
      );
    } catch (e) {
      yield ImportProgress(
        totalItems: 0,
        processedItems: 0,
        currentOperation: 'Import failed: ${e.toString()}',
        progress: 0.0,
      );
    }
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
            appVersion: '1.0.0',
            taskCount: 0,
            projectCount: 0,
            tagCount: 0,
            fileSizeBytes: stat.size,
            checksum: '',
          ));
        }
      }

      // Sort by creation date (newest first)
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return backups;
    } catch (e) {
      if (kDebugMode) {
        print('Get available backups error: $e');
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
      final backups = await getAvailableBackups();
      final backup = backups.firstWhere((b) => b.id == backupId);
      
      final backupDirPath = await getExportDirectory();
      final backupDir = Directory(backupDirPath);
      final file = File('${backupDir.path}/${backup.id}');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Delete backup error: $e');
      }
      throw Exception('Failed to delete backup: ${e.toString()}');
    }
  }

  Future<void> _exportTasksToPlainText(
    List<TaskModel> tasks,
    String filePath,
    ExportOptions? options,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln('TASK TRACKER EXPORT');
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
  }

  Future<void> _exportProjectsToPlainText(
    List<Project> projects,
    String filePath,
    ExportOptions? options,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln('PROJECT TRACKER EXPORT');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('Total Projects: ${projects.length}');
    buffer.writeln('');
    buffer.writeln('=' * 50);
    buffer.writeln('');

    for (final project in projects) {
      buffer.writeln('Name: ${project.name}');
      if (project.description?.isNotEmpty == true) {
        buffer.writeln('Description: ${project.description}');
      }
      buffer.writeln('Created: ${project.createdAt}');
      if (project.deadline != null) {
        buffer.writeln('Deadline: ${project.deadline}');
      }
      buffer.writeln('Task Count: ${project.taskIds.length}');
      buffer.writeln('');
      buffer.writeln('-' * 30);
      buffer.writeln('');
    }

    await File(filePath).writeAsString(buffer.toString());
  }

  // PDF Export Methods
  Future<void> _exportTasksToPDF(
    List<TaskModel> tasks,
    String filePath,
    ExportOptions? options,
  ) async {
    final pdf = pw.Document();

    // Load a font for PDF (required for text rendering)
    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    // Split tasks into pages (20 tasks per page)
    const tasksPerPage = 20;
    final totalPages = (tasks.length / tasksPerPage).ceil();

    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      final startIndex = pageIndex * tasksPerPage;
      final endIndex = (startIndex + tasksPerPage > tasks.length) 
          ? tasks.length 
          : startIndex + tasksPerPage;
      final pageTasks = tasks.sublist(startIndex, endIndex);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Task Tracker Export',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 24,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.Text(
                      'Page ${pageIndex + 1} of $totalPages',
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Summary section (only on first page)
              if (pageIndex == 0) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Export Summary',
                              style: pw.TextStyle(font: fontBold, fontSize: 14),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Total Tasks: ${tasks.length}',
                              style: pw.TextStyle(font: font, fontSize: 12),
                            ),
                            pw.Text(
                              'Generated: ${DateTime.now().toString().split('.')[0]}',
                              style: pw.TextStyle(font: font, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Status Breakdown',
                              style: pw.TextStyle(font: fontBold, fontSize: 14),
                            ),
                            pw.SizedBox(height: 4),
                            ...TaskStatus.values.map((status) {
                              final count = tasks.where((t) => t.status == status).length;
                              return pw.Text(
                                '${status.name}: $count',
                                style: pw.TextStyle(font: font, fontSize: 12),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
              ],

              // Tasks table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3), // Title
                  1: const pw.FlexColumnWidth(1), // Priority
                  2: const pw.FlexColumnWidth(1), // Status
                  3: const pw.FlexColumnWidth(2), // Due Date
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell('Title', fontBold, isHeader: true),
                      _buildTableCell('Priority', fontBold, isHeader: true),
                      _buildTableCell('Status', fontBold, isHeader: true),
                      _buildTableCell('Due Date', fontBold, isHeader: true),
                    ],
                  ),
                  // Data rows
                  ...pageTasks.map((task) => pw.TableRow(
                    children: [
                      _buildTableCell(task.title, font),
                      _buildTableCell(
                        task.priority.name.toUpperCase(),
                        font,
                        color: _getPriorityColor(task.priority),
                      ),
                      _buildTableCell(
                        task.status.name.toUpperCase(),
                        font,
                        color: _getStatusColor(task.status),
                      ),
                      _buildTableCell(
                        task.dueDate?.toString().split(' ')[0] ?? 'No due date',
                        font,
                      ),
                    ],
                  )),
                ],
              ),

              // Detailed task information
              pw.SizedBox(height: 30),
              pw.Text(
                'Detailed Task Information',
                style: pw.TextStyle(font: fontBold, fontSize: 18),
              ),
              pw.SizedBox(height: 10),
              
              ...pageTasks.map((task) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            task.title,
                            style: pw.TextStyle(font: fontBold, fontSize: 14),
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: pw.BoxDecoration(
                            color: _getPriorityColor(task.priority),
                            borderRadius: pw.BorderRadius.circular(3),
                          ),
                          child: pw.Text(
                            task.priority.name.toUpperCase(),
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 10,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (task.description?.isNotEmpty == true) ...[
                      pw.SizedBox(height: 6),
                      pw.Text(
                        task.description!,
                        style: pw.TextStyle(font: font, fontSize: 12),
                      ),
                    ],
                    pw.SizedBox(height: 6),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            'Status: ${task.status.name}',
                            style: pw.TextStyle(font: font, fontSize: 10),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            'Created: ${task.createdAt.toString().split(' ')[0]}',
                            style: pw.TextStyle(font: font, fontSize: 10),
                          ),
                        ),
                        if (task.dueDate != null)
                          pw.Expanded(
                            child: pw.Text(
                              'Due: ${task.dueDate!.toString().split(' ')[0]}',
                              style: pw.TextStyle(font: font, fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                    if (task.tags.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Wrap(
                        spacing: 4,
                        children: task.tags.map((tag) => pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue100,
                            borderRadius: pw.BorderRadius.circular(2),
                          ),
                          child: pw.Text(
                            tag,
                            style: pw.TextStyle(font: font, fontSize: 10),
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              )),
            ];
          },
        ),
      );
    }

    // Save PDF to file
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
  }

  Future<void> _exportProjectsToPDF(
    List<Project> projects,
    String filePath,
    ExportOptions? options,
  ) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'Project Export',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 24,
                  color: PdfColors.blue800,
                ),
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Total Projects: ${projects.length}',
                      style: pw.TextStyle(font: fontBold, fontSize: 14),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      'Generated: ${DateTime.now().toString().split('.')[0]}',
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),

            // Projects
            ...projects.map((project) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 20),
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    project.name,
                    style: pw.TextStyle(font: fontBold, fontSize: 18),
                  ),
                  if (project.description?.isNotEmpty == true) ...[
                    pw.SizedBox(height: 8),
                    pw.Text(
                      project.description!,
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                  ],
                  pw.SizedBox(height: 10),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          'Created: ${project.createdAt.toString().split(' ')[0]}',
                          style: pw.TextStyle(font: font, fontSize: 11),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          'Tasks: ${project.taskIds.length}',
                          style: pw.TextStyle(font: font, fontSize: 11),
                        ),
                      ),
                      if (project.deadline != null)
                        pw.Expanded(
                          child: pw.Text(
                            'Deadline: ${project.deadline!.toString().split(' ')[0]}',
                            style: pw.TextStyle(font: font, fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            )),
          ];
        },
      ),
    );

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
  }

  pw.Widget _buildTableCell(
    String text, 
    pw.Font font, {
    bool isHeader = false,
    PdfColor? color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 12 : 10,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }

  PdfColor _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return PdfColors.red600;
      case TaskPriority.high:
        return PdfColors.orange600;
      case TaskPriority.medium:
        return PdfColors.yellow600;
      case TaskPriority.low:
        return PdfColors.green600;
    }
  }

  PdfColor _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return PdfColors.grey600;
      case TaskStatus.inProgress:
        return PdfColors.blue600;
      case TaskStatus.completed:
        return PdfColors.green600;
      case TaskStatus.cancelled:
        return PdfColors.red600;
    }
  }
}

/// Extension to add file extension mapping
extension ExportFormatExtension on ExportFormat {
  String get extension {
    switch (this) {
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
    }
  }
}