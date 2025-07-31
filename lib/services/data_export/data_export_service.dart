import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:csv/csv.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/project.dart';
import 'data_export_models.dart';

abstract class DataExportService {
  Stream<ExportProgress> exportData({
    required ExportFormat format,
    String? filePath,
    List<String>? taskIds,
    List<String>? projectIds,
  });

  Stream<ImportProgress> importData({
    required String filePath,
    required ImportOptions options,
  });

  Future<ImportValidationResult> validateImportFile(String filePath);

  Future<String> createBackup();
  Future<void> restoreBackup(String backupPath);
  Future<List<BackupMetadata>> getAvailableBackups();
  Future<void> deleteBackup(String backupId);

  Future<void> shareData({
    required ExportFormat format,
    List<String>? taskIds,
    List<String>? projectIds,
  });

  Future<bool> requestStoragePermissions();
}

class DataExportServiceImpl implements DataExportService {
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;
  final TagRepository _tagRepository;

  const DataExportServiceImpl({
    required TaskRepository taskRepository,
    required ProjectRepository projectRepository,
    required TagRepository tagRepository,
  })  : _taskRepository = taskRepository,
        _projectRepository = projectRepository,
        _tagRepository = tagRepository;

  @override
  Stream<ExportProgress> exportData({
    required ExportFormat format,
    String? filePath,
    List<String>? taskIds,
    List<String>? projectIds,
  }) async* {
    try {
      // Check permissions
      if (!await requestStoragePermissions()) {
        throw const DataExportException(
          'Storage permissions required for export',
          code: 'PERMISSION_DENIED',
        );
      }

      yield const ExportProgress(
        totalItems: 0,
        processedItems: 0,
        currentOperation: 'Preparing export...',
        progress: 0.0,
      );

      // Gather data
      final tasks = taskIds != null
          ? await _getTasksByIds(taskIds)
          : await _taskRepository.getAllTasks();

      final projects = projectIds != null
          ? await _getProjectsByIds(projectIds)
          : await _projectRepository.getAllProjects();

      final tags = await _tagRepository.getAllTags();

      final totalItems = tasks.length + projects.length + tags.length;

      yield ExportProgress(
        totalItems: totalItems,
        processedItems: 0,
        currentOperation: 'Collecting data...',
        progress: 0.1,
      );

      final exportData = ExportData(
        tasks: tasks.map((task) => task.toJson()).toList(),
        projects: projects.map((project) => project.toJson()).toList(),
        tags: tags.map((tag) => tag.name).toList(),
        exportedAt: DateTime.now(),
        appVersion: '1.0.0', // TODO: Get from package info
        metadata: {
          'exportFormat': format.name,
          'totalTasks': tasks.length,
          'totalProjects': projects.length,
          'totalTags': tags.length,
        },
      );

      yield ExportProgress(
        totalItems: totalItems,
        processedItems: totalItems ~/ 2,
        currentOperation: 'Formatting data...',
        progress: 0.5,
      );

      // Generate file content based on format
      final String content;
      final String fileExtension;

      switch (format) {
        case ExportFormat.json:
          content = _formatAsJson(exportData);
          fileExtension = 'json';
          break;
        case ExportFormat.csv:
          content = _formatAsCsv(exportData);
          fileExtension = 'csv';
          break;
        case ExportFormat.plainText:
          content = _formatAsPlainText(exportData);
          fileExtension = 'txt';
          break;
      }

      yield ExportProgress(
        totalItems: totalItems,
        processedItems: (totalItems * 0.8).round(),
        currentOperation: 'Writing file...',
        progress: 0.8,
      );

      // Write to file
      final outputPath = filePath ?? await _generateExportFilePath(fileExtension);
      final file = File(outputPath);
      await file.writeAsString(content);

      yield ExportProgress(
        totalItems: totalItems,
        processedItems: totalItems,
        currentOperation: 'Export completed',
        progress: 1.0,
      );
    } catch (e) {
      throw DataExportException(
        'Failed to export data: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Stream<ImportProgress> importData({
    required String filePath,
    required ImportOptions options,
  }) async* {
    try {
      yield const ImportProgress(
        totalItems: 0,
        processedItems: 0,
        currentOperation: 'Validating import file...',
        progress: 0.0,
      );

      final validationResult = await validateImportFile(filePath);
      if (!validationResult.isValid) {
        throw DataImportException(
          'Import file validation failed: ${validationResult.errors.join(', ')}',
          code: 'VALIDATION_FAILED',
        );
      }

      final totalItems = validationResult.taskCount +
          validationResult.projectCount +
          validationResult.tagCount;

      yield ImportProgress(
        totalItems: totalItems,
        processedItems: 0,
        currentOperation: 'Reading import file...',
        progress: 0.1,
      );

      final file = File(filePath);
      final content = await file.readAsString();
      final exportData = ExportData.fromJson(jsonDecode(content));

      // Import projects first
      var processedItems = 0;
      for (final projectData in exportData.projects) {
        final projectName = projectData['name'] as String? ?? 'Unknown Project';
        yield ImportProgress(
          totalItems: totalItems,
          processedItems: processedItems,
          currentOperation: 'Importing project: $projectName',
          progress: processedItems / totalItems,
        );

        await _importProjectFromMap(projectData, options);
        processedItems++;
      }

      // Import tags
      for (final tagName in exportData.tags) {
        yield ImportProgress(
          totalItems: totalItems,
          processedItems: processedItems,
          currentOperation: 'Importing tag: $tagName',
          progress: processedItems / totalItems,
        );

        await _importTag(tagName, options);
        processedItems++;
      }

      // Import tasks
      for (final taskData in exportData.tasks) {
        final taskTitle = taskData['title'] as String? ?? 'Unknown Task';
        yield ImportProgress(
          totalItems: totalItems,
          processedItems: processedItems,
          currentOperation: 'Importing task: $taskTitle',
          progress: processedItems / totalItems,
        );

        await _importTaskFromMap(taskData, options);
        processedItems++;
      }

      yield ImportProgress(
        totalItems: totalItems,
        processedItems: totalItems,
        currentOperation: 'Import completed',
        progress: 1.0,
      );
    } catch (e) {
      throw DataImportException(
        'Failed to import data: ${e.toString()}',
        originalError: e,
      );
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

      final content = await file.readAsString();
      final Map<String, dynamic> data;

      try {
        data = jsonDecode(content);
      } catch (e) {
        return ImportValidationResult(
          isValid: false,
          errors: ['Invalid JSON format: ${e.toString()}'],
          warnings: [],
          taskCount: 0,
          projectCount: 0,
          tagCount: 0,
        );
      }

      final errors = <String>[];
      final warnings = <String>[];

      // Validate required fields
      if (!data.containsKey('tasks')) {
        errors.add('Missing required field: tasks');
      }
      if (!data.containsKey('projects')) {
        errors.add('Missing required field: projects');
      }
      if (!data.containsKey('tags')) {
        errors.add('Missing required field: tags');
      }
      if (!data.containsKey('exportedAt')) {
        errors.add('Missing required field: exportedAt');
      }

      // Try to parse the export data
      ExportData exportData;
      try {
        exportData = ExportData.fromJson(data);
      } catch (e) {
        errors.add('Failed to parse export data: ${e.toString()}');
        return ImportValidationResult(
          isValid: false,
          errors: errors,
          warnings: warnings,
          taskCount: 0,
          projectCount: 0,
          tagCount: 0,
        );
      }

      // Validate individual tasks
      for (int i = 0; i < exportData.tasks.length; i++) {
        final task = exportData.tasks[i];
        final title = task['title'] as String?;
        final id = task['id'] as String?;
        if (title == null || title.isEmpty) {
          errors.add('Task at index $i has empty title');
        }
        if (id == null || id.isEmpty) {
          errors.add('Task at index $i has empty ID');
        }
      }

      // Validate projects
      for (int i = 0; i < exportData.projects.length; i++) {
        final project = exportData.projects[i];
        final name = project['name'] as String?;
        final id = project['id'] as String?;
        if (name == null || name.isEmpty) {
          errors.add('Project at index $i has empty name');
        }
        if (id == null || id.isEmpty) {
          errors.add('Project at index $i has empty ID');
        }
      }

      // Check for potential issues
      if (exportData.tasks.length > 10000) {
        warnings.add('Large number of tasks (${exportData.tasks.length}) may take time to import');
      }

      return ImportValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
        taskCount: exportData.tasks.length,
        projectCount: exportData.projects.length,
        tagCount: exportData.tags.length,
      );
    } catch (e) {
      return ImportValidationResult(
        isValid: false,
        errors: ['Validation failed: ${e.toString()}'],
        warnings: [],
        taskCount: 0,
        projectCount: 0,
        tagCount: 0,
      );
    }
  }

  @override
  Future<String> createBackup() async {
    try {
      if (!await requestStoragePermissions()) {
        throw const DataExportException(
          'Storage permissions required for backup',
          code: 'PERMISSION_DENIED',
        );
      }

      final backupId = DateTime.now().millisecondsSinceEpoch.toString();
      final backupDir = await _getBackupDirectory();
      final backupPath = path.join(backupDir.path, 'backup_$backupId.json');

      // Export all data
      final tasks = await _taskRepository.getAllTasks();
      final projects = await _projectRepository.getAllProjects();
      final tags = await _tagRepository.getAllTags();

      final exportData = ExportData(
        tasks: tasks.map((task) => task.toJson()).toList(),
        projects: projects.map((project) => project.toJson()).toList(),
        tags: tags.map((tag) => tag.name).toList(),
        exportedAt: DateTime.now(),
        appVersion: '1.0.0',
        metadata: {
          'backupId': backupId,
          'isBackup': true,
        },
      );

      final content = _formatAsJson(exportData);
      final file = File(backupPath);
      await file.writeAsString(content);

      // Create metadata
      final fileSize = await file.length();
      final checksum = _calculateChecksum(content);

      final metadata = BackupMetadata(
        id: backupId,
        createdAt: DateTime.now(),
        appVersion: '1.0.0',
        taskCount: tasks.length,
        projectCount: projects.length,
        tagCount: tags.length,
        fileSizeBytes: fileSize,
        checksum: checksum,
      );

      // Save metadata
      final metadataPath = path.join(backupDir.path, 'backup_${backupId}_metadata.json');
      final metadataFile = File(metadataPath);
      await metadataFile.writeAsString(jsonEncode(metadata.toJson()));

      return backupPath;
    } catch (e) {
      throw DataExportException(
        'Failed to create backup: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<void> restoreBackup(String backupPath) async {
    try {
      final validationResult = await validateImportFile(backupPath);
      if (!validationResult.isValid) {
        throw DataImportException(
          'Backup validation failed: ${validationResult.errors.join(', ')}',
          code: 'VALIDATION_FAILED',
        );
      }

      // Clear existing data
      // Note: These methods may not exist in the repository interfaces
      // For now, we'll skip clearing and just import with overwrite option
      // TODO: Implement bulk delete methods in repositories if needed

      // Import backup data
      final options = const ImportOptions(
        overwriteExisting: true,
        createMissingProjects: true,
        createMissingTags: true,
        preserveIds: true,
      );

      await for (final progress in importData(filePath: backupPath, options: options)) {
        // Progress is handled by the caller
      }
    } catch (e) {
      throw DataImportException(
        'Failed to restore backup: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<List<BackupMetadata>> getAvailableBackups() async {
    try {
      final backupDir = await _getBackupDirectory();
      if (!await backupDir.exists()) {
        return [];
      }

      final backups = <BackupMetadata>[];
      final files = await backupDir.list().toList();

      for (final file in files) {
        if (file is File && file.path.endsWith('_metadata.json')) {
          try {
            final content = await file.readAsString();
            final metadata = BackupMetadata.fromJson(jsonDecode(content));
            backups.add(metadata);
          } catch (e) {
            // Skip invalid metadata files
            continue;
          }
        }
      }

      // Sort by creation date (newest first)
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return backups;
    } catch (e) {
      throw DataExportException(
        'Failed to get available backups: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteBackup(String backupId) async {
    try {
      final backupDir = await _getBackupDirectory();
      final backupFile = File(path.join(backupDir.path, 'backup_$backupId.json'));
      final metadataFile = File(path.join(backupDir.path, 'backup_${backupId}_metadata.json'));

      if (await backupFile.exists()) {
        await backupFile.delete();
      }
      if (await metadataFile.exists()) {
        await metadataFile.delete();
      }
    } catch (e) {
      throw DataExportException(
        'Failed to delete backup: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<void> shareData({
    required ExportFormat format,
    List<String>? taskIds,
    List<String>? projectIds,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'tasks_export_${DateTime.now().millisecondsSinceEpoch}';
      final fileExtension = format == ExportFormat.json
          ? 'json'
          : format == ExportFormat.csv
              ? 'csv'
              : 'txt';
      final filePath = path.join(tempDir.path, '$fileName.$fileExtension');

      // Export data to temporary file
      await for (final progress in exportData(
        format: format,
        filePath: filePath,
        taskIds: taskIds,
        projectIds: projectIds,
      )) {
        // Progress is handled by the caller
      }

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Task Tracker Export',
        subject: 'My Tasks Export',
      );
    } catch (e) {
      throw DataExportException(
        'Failed to share data: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<bool> requestStoragePermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // iOS doesn't require explicit storage permissions for app documents
  }

  // Private helper methods

  Future<List<TaskModel>> _getTasksByIds(List<String> taskIds) async {
    final tasks = <TaskModel>[];
    for (final id in taskIds) {
      final task = await _taskRepository.getTaskById(id);
      if (task != null) {
        tasks.add(task);
      }
    }
    return tasks;
  }

  Future<List<Project>> _getProjectsByIds(List<String> projectIds) async {
    final projects = <Project>[];
    for (final id in projectIds) {
      final project = await _projectRepository.getProjectById(id);
      if (project != null) {
        projects.add(project);
      }
    }
    return projects;
  }

  String _formatAsJson(ExportData data) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data.toJson());
  }

  String _formatAsCsv(ExportData data) {
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
      'Completed At',
      'Tags',
      'Project',
      'Subtasks',
    ]);

    // Task rows
    for (final taskData in data.tasks) {
      final projectId = taskData['projectId'] as String?;
      final project = data.projects
          .where((p) => p['id'] == projectId)
          .firstOrNull;
      
      final tags = taskData['tags'] as List<dynamic>? ?? [];
      final subTasks = taskData['subTasks'] as List<dynamic>? ?? [];
      
      rows.add([
        taskData['id']?.toString() ?? '',
        taskData['title']?.toString() ?? '',
        taskData['description']?.toString() ?? '',
        taskData['status']?.toString() ?? '',
        taskData['priority']?.toString() ?? '',
        taskData['dueDate']?.toString() ?? '',
        taskData['createdAt']?.toString() ?? '',
        taskData['completedAt']?.toString() ?? '',
        tags.join('; '),
        project?['name']?.toString() ?? '',
        subTasks.map((st) => '${st['title']}:${st['isCompleted']}').join('; '),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  String _formatAsPlainText(ExportData data) {
    final buffer = StringBuffer();
    
    buffer.writeln('Task Tracker Export');
    buffer.writeln('Exported: ${data.exportedAt.toLocal()}');
    buffer.writeln('App Version: ${data.appVersion}');
    buffer.writeln('');
    
    if (data.projects.isNotEmpty) {
      buffer.writeln('PROJECTS (${data.projects.length}):');
      buffer.writeln('=' * 40);
      for (final projectData in data.projects) {
        final name = projectData['name']?.toString() ?? 'Unknown Project';
        final description = projectData['description']?.toString();
        buffer.writeln('• $name');
        if (description?.isNotEmpty == true) {
          buffer.writeln('  $description');
        }
        buffer.writeln('');
      }
    }

    if (data.tags.isNotEmpty) {
      buffer.writeln('TAGS (${data.tags.length}):');
      buffer.writeln('=' * 40);
      buffer.writeln(data.tags.join(', '));
      buffer.writeln('');
    }

    buffer.writeln('TASKS (${data.tasks.length}):');
    buffer.writeln('=' * 40);
    
    for (final taskData in data.tasks) {
      final title = taskData['title']?.toString() ?? 'Unknown Task';
      final description = taskData['description']?.toString();
      final status = taskData['status']?.toString() ?? 'unknown';
      final priority = taskData['priority']?.toString() ?? 'unknown';
      final dueDate = taskData['dueDate']?.toString();
      final tags = taskData['tags'] as List<dynamic>? ?? [];
      final subTasks = taskData['subTasks'] as List<dynamic>? ?? [];
      
      buffer.writeln('□ $title');
      
      if (description?.isNotEmpty == true) {
        buffer.writeln('  Description: $description');
      }
      
      buffer.writeln('  Status: $status');
      buffer.writeln('  Priority: $priority');
      
      if (dueDate != null && dueDate.isNotEmpty) {
        buffer.writeln('  Due: $dueDate');
      }
      
      if (tags.isNotEmpty) {
        buffer.writeln('  Tags: ${tags.join(', ')}');
      }
      
      if (subTasks.isNotEmpty) {
        buffer.writeln('  Subtasks:');
        for (final subtaskData in subTasks) {
          final subtaskTitle = subtaskData['title']?.toString() ?? 'Unknown Subtask';
          final isCompleted = subtaskData['isCompleted'] as bool? ?? false;
          final checkbox = isCompleted ? '☑' : '☐';
          buffer.writeln('    $checkbox $subtaskTitle');
        }
      }
      
      buffer.writeln('');
    }

    return buffer.toString();
  }

  Future<String> _generateExportFilePath(String extension) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final exportsDir = Directory(path.join(documentsDir.path, 'exports'));
    
    if (!await exportsDir.exists()) {
      await exportsDir.create(recursive: true);
    }
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return path.join(exportsDir.path, 'tasks_export_$timestamp.$extension');
  }

  Future<Directory> _getBackupDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(path.join(documentsDir.path, 'backups'));
    
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    
    return backupDir;
  }

  String _calculateChecksum(String content) {
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _importProject(Project project, ImportOptions options) async {
    try {
      final existingProject = await _projectRepository.getProjectById(project.id);
      
      if (existingProject != null && !options.overwriteExisting) {
        return; // Skip existing project
      }
      
      final projectToImport = options.preserveIds
          ? project
          : project.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
      
      if (existingProject != null) {
        await _projectRepository.updateProject(projectToImport);
      } else {
        await _projectRepository.createProject(projectToImport);
      }
    } catch (e) {
      throw DataImportException(
        'Failed to import project ${project.name}: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<void> _importTag(String tagName, ImportOptions options) async {
    try {
      if (options.createMissingTags) {
        final existingTags = await _tagRepository.getAllTags();
        final tagExists = existingTags.any((tag) => tag.name == tagName);
        
        if (!tagExists) {
          final newTag = Tag(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: tagName,
            color: '#2196F3', // Default blue color
            createdAt: DateTime.now(),
          );
          await _tagRepository.createTag(newTag);
        }
      }
    } catch (e) {
      throw DataImportException(
        'Failed to import tag $tagName: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<void> _importTask(TaskModel task, ImportOptions options) async {
    try {
      final existingTask = await _taskRepository.getTaskById(task.id);
      
      if (existingTask != null && !options.overwriteExisting) {
        return; // Skip existing task
      }
      
      final taskToImport = options.preserveIds
          ? task
          : task.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
      
      if (existingTask != null) {
        await _taskRepository.updateTask(taskToImport);
      } else {
        await _taskRepository.createTask(taskToImport);
      }
    } catch (e) {
      throw DataImportException(
        'Failed to import task ${task.title}: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<void> _importProjectFromMap(Map<String, dynamic> projectData, ImportOptions options) async {
    try {
      // Convert map to Project entity
      final project = Project.fromJson(projectData);
      
      final existingProject = await _projectRepository.getProjectById(project.id);
      
      if (existingProject != null && !options.overwriteExisting) {
        return; // Skip existing project
      }
      
      final projectToImport = options.preserveIds
          ? project
          : project.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
      
      if (existingProject != null) {
        await _projectRepository.updateProject(projectToImport);
      } else {
        await _projectRepository.createProject(projectToImport);
      }
    } catch (e) {
      final projectName = projectData['name']?.toString() ?? 'Unknown Project';
      throw DataImportException(
        'Failed to import project $projectName: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<void> _importTaskFromMap(Map<String, dynamic> taskData, ImportOptions options) async {
    try {
      // Convert map to TaskModel entity
      final task = TaskModel.fromJson(taskData);
      
      final existingTask = await _taskRepository.getTaskById(task.id);
      
      if (existingTask != null && !options.overwriteExisting) {
        return; // Skip existing task
      }
      
      final taskToImport = options.preserveIds
          ? task
          : task.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
      
      if (existingTask != null) {
        await _taskRepository.updateTask(taskToImport);
      } else {
        await _taskRepository.createTask(taskToImport);
      }
    } catch (e) {
      final taskTitle = taskData['title']?.toString() ?? 'Unknown Task';
      throw DataImportException(
        'Failed to import task $taskTitle: ${e.toString()}',
        originalError: e,
      );
    }
  }
}