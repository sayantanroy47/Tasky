import 'dart:convert';
import 'dart:io';
import '../../domain/entities/task_model.dart';

import '../../domain/repositories/task_repository.dart';

import '../../domain/models/enums.dart';

/// Comprehensive import/export service for tasks and projects
/// 
/// Supports multiple formats:
/// - JSON (full data preservation)
/// - CSV (tabular format)
/// - Plain text (readable format)
/// - Custom format validation and error handling
class ImportExportService {
  final TaskRepository _taskRepository;
  // final ProjectRepository? _projectRepository;
  
  const ImportExportService(this._taskRepository);
  
  /// Exports tasks to specified format
  Future<ExportResult> exportTasks({
    required ExportFormat format,
    required String filePath,
    List<String>? taskIds,
    ExportOptions options = const ExportOptions(),
  }) async {
    try {
      final tasks = taskIds != null 
        ? await _taskRepository.getTasksByIds(taskIds)
        : await _taskRepository.getAllTasks();
      
      // Apply filters if specified
      final filteredTasks = _applyExportFilters(tasks, options);
      
      final content = await _generateExportContent(filteredTasks, format, options);
      
      final file = File(filePath);
      await file.writeAsString(content);
      
      return ExportResult.success(
        format: format,
        filePath: filePath,
        taskCount: filteredTasks.length,
        fileSize: await file.length(),
      );
    } catch (e) {
      return ExportResult.failed('Export failed: $e');
    }
  }
  
  /// Imports tasks from file
  Future<ImportResult> importTasks({
    required String filePath,
    required ImportFormat format,
    ImportOptions options = const ImportOptions(),
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return ImportResult.failed('File not found');
      }
      
      final content = await file.readAsString();
      final parseResult = await _parseImportContent(content, format, options);
      
      if (!parseResult.success) {
        return ImportResult.failed('Parse error: ${parseResult.error}');
      }
      
      final validationResult = await _validateImportData(parseResult.tasks!, options);
      
      int imported = 0;
      int updated = 0;
      int skipped = 0;
      final errors = <String>[];
      
      for (final taskData in parseResult.tasks!) {
        try {
          final result = await _importSingleTask(taskData, options);
          switch (result.action) {
            case ImportAction.created:
              imported++;
              break;
            case ImportAction.updated:
              updated++;
              break;
            case ImportAction.skipped:
              skipped++;
              break;
          }
        } catch (e) {
          errors.add('Task "${taskData.title}": $e');
          skipped++;
        }
      }
      
      return ImportResult.success(
        imported: imported,
        updated: updated,
        skipped: skipped,
        errors: errors,
        validationWarnings: validationResult.warnings,
      );
    } catch (e) {
      return ImportResult.failed('Import failed: $e');
    }
  }
  
  /// Applies export filters to tasks
  List<TaskModel> _applyExportFilters(List<TaskModel> tasks, ExportOptions options) {
    var filtered = tasks;
    
    if (!options.includeCompleted) {
      filtered = filtered.where((task) => !task.isCompleted).toList();
    }
    
    return filtered;
  }
  
  /// Generates export content based on format
  Future<String> _generateExportContent(
    List<TaskModel> tasks,
    ExportFormat format,
    ExportOptions options,
  ) async {
    switch (format) {
      case ExportFormat.json:
        return _generateJsonExport(tasks, options);
      case ExportFormat.csv:
        return _generateCsvExport(tasks, options);
      case ExportFormat.txt:
        return _generateTextExport(tasks, options);
      case ExportFormat.pdf:
        throw UnsupportedError('PDF export not yet implemented');
    }
  }
  
  /// Generates JSON export
  String _generateJsonExport(List<TaskModel> tasks, ExportOptions options) {
    final data = {
      'metadata': {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'taskCount': tasks.length,
        'exportOptions': {
          'includeCompleted': options.includeCompleted,
          'includeArchived': options.includeArchived,
          'dateFormat': options.dateFormat,
        },
      },
      'tasks': tasks.map((task) => {
        'id': task.id,
        'title': task.title,
        'description': task.description,
        'status': task.status.name,
        'priority': task.priority.name,
        'dueDate': task.dueDate?.toIso8601String(),
        'createdAt': task.createdAt.toIso8601String(),
        'updatedAt': task.updatedAt?.toIso8601String(),
        'completedAt': task.completedAt?.toIso8601String(),
        'tags': task.tags,
        'projectId': task.projectId,
        'dependencies': task.dependencies,
        'subTasks': task.subTasks.map((st) => {
          'id': st.id,
          'title': st.title,
          'isCompleted': st.isCompleted,
          'completedAt': st.completedAt?.toIso8601String(),
        }).toList(),
        'recurrence': task.recurrence?.toJson(),
        'locationTrigger': task.locationTrigger,
        'estimatedDuration': task.estimatedDuration,
        'isPinned': task.isPinned,
        'metadata': task.metadata,
      }).toList(),
    };
    
    return const JsonEncoder.withIndent('  ').convert(data);
  }
  
  /// Generates CSV export
  String _generateCsvExport(List<TaskModel> tasks, ExportOptions options) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('ID,Title,Description,Status,Priority,Due Date,Created,Completed,Tags,Project ID');
    
    // Data rows
    for (final task in tasks) {
      final row = [
        _escapeCsvField(task.id),
        _escapeCsvField(task.title),
        _escapeCsvField(task.description ?? ''),
        _escapeCsvField(task.status.displayName),
        _escapeCsvField(task.priority.displayName),
        _escapeCsvField(task.dueDate?.toString() ?? ''),
        _escapeCsvField(task.createdAt.toString()),
        _escapeCsvField(task.completedAt?.toString() ?? ''),
        _escapeCsvField(task.tags.join(';')),
        _escapeCsvField(task.projectId ?? ''),
      ];
      buffer.writeln(row.join(','));
    }
    
    return buffer.toString();
  }
  
  /// Generates plain text export
  String _generateTextExport(List<TaskModel> tasks, ExportOptions options) {
    final buffer = StringBuffer();
    
    buffer.writeln('TASK EXPORT');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('Total Tasks: ${tasks.length}');
    buffer.writeln('');
    
    for (final task in tasks) {
      buffer.writeln('━' * 60);
      buffer.writeln('TASK: ${task.title}');
      buffer.writeln('ID: ${task.id}');
      buffer.writeln('Status: ${task.status.displayName}');
      buffer.writeln('Priority: ${task.priority.displayName}');
      
      if (task.description != null && task.description!.isNotEmpty) {
        buffer.writeln('Description: ${task.description}');
      }
      
      if (task.dueDate != null) {
        buffer.writeln('Due: ${task.dueDate}');
      }
      
      if (task.tags.isNotEmpty) {
        buffer.writeln('Tags: ${task.tags.join(', ')}');
      }
      
      if (task.subTasks.isNotEmpty) {
        buffer.writeln('Subtasks:');
        for (final subtask in task.subTasks) {
          final status = subtask.isCompleted ? '[EMOJI]' : '○';
          buffer.writeln('  $status ${subtask.title}');
        }
      }
      
      buffer.writeln('Created: ${task.createdAt}');
      if (task.completedAt != null) {
        buffer.writeln('Completed: ${task.completedAt}');
      }
      buffer.writeln('');
    }
    
    return buffer.toString();
  }
  
  /// Parses import content based on format
  Future<ParseResult> _parseImportContent(
    String content,
    ImportFormat format,
    ImportOptions options,
  ) async {
    try {
      switch (format) {
        case ImportFormat.json:
          return _parseJsonImport(content, options);
        case ImportFormat.csv:
          return _parseCsvImport(content, options);
      }
    } catch (e) {
      return ParseResult.failed('Parse error: $e');
    }
  }
  
  /// Validates import data
  Future<ValidationResult> _validateImportData(List<ImportTaskData> tasks, ImportOptions options) async {
    final warnings = <String>[];
    
    for (final task in tasks) {
      if (task.title.trim().isEmpty) {
        warnings.add('Task has empty title');
      }
    }
    
    return ValidationResult(warnings: warnings);
  }
  
  /// Imports a single task
  Future<ImportTaskResult> _importSingleTask(ImportTaskData taskData, ImportOptions options) async {
    // Check if task already exists
    if (taskData.id != null) {
      final existing = await _taskRepository.getTaskById(taskData.id!);
      if (existing != null) {
        if (options.skipDuplicates) {
          return const ImportTaskResult(action: ImportAction.skipped);
        }
        if (options.updateExisting) {
          // Update existing task
          final updated = existing.copyWith(
            title: taskData.title,
            description: taskData.description,
            status: taskData.status,
            priority: taskData.priority,
            dueDate: taskData.dueDate,
            tags: taskData.tags,
          );
          await _taskRepository.updateTask(updated);
          return const ImportTaskResult(action: ImportAction.updated);
        }
      }
    }
    
    // Create new task
    final newTask = TaskModel.create(
      title: taskData.title,
      description: taskData.description,
      priority: taskData.priority ?? TaskPriority.medium,
      tags: taskData.tags ?? [],
      dueDate: taskData.dueDate,
    );
    
    await _taskRepository.createTask(newTask);
    return const ImportTaskResult(action: ImportAction.created);
  }
  
  /// Parses JSON import
  ParseResult _parseJsonImport(String content, ImportOptions options) {
    final data = jsonDecode(content) as Map<String, dynamic>;
    
    if (!data.containsKey('tasks')) {
      return ParseResult.failed('Invalid JSON format: missing tasks array');
    }
    
    final tasksData = data['tasks'] as List<dynamic>;
    final tasks = <ImportTaskData>[];
    
    for (final taskData in tasksData) {
      if (taskData is! Map<String, dynamic>) {
        continue;
      }
      
      tasks.add(ImportTaskData(
        id: taskData['id'] as String?,
        title: taskData['title'] as String,
        description: taskData['description'] as String?,
        status: _parseTaskStatus(taskData['status']),
        priority: _parseTaskPriority(taskData['priority']),
        dueDate: _parseDateTime(taskData['dueDate']),
        tags: _parseStringList(taskData['tags']),
        projectId: taskData['projectId'] as String?,
        dependencies: _parseStringList(taskData['dependencies']),
        subtasks: _parseSubtasks(taskData['subTasks']),
      ));
    }
    
    return ParseResult.success(tasks);
  }
  
  /// Parses CSV import
  ParseResult _parseCsvImport(String content, ImportOptions options) {
    final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    if (lines.isEmpty) {
      return ParseResult.failed('Empty CSV file');
    }
    
    // Parse header
    final headers = _parseCsvRow(lines[0]);
    final tasks = <ImportTaskData>[];
    
    for (int i = 1; i < lines.length; i++) {
      final values = _parseCsvRow(lines[i]);
      if (values.length != headers.length) continue;
      
      final rowData = <String, String>{};
      for (int j = 0; j < headers.length; j++) {
        rowData[headers[j].toLowerCase().trim()] = values[j];
      }
      
      tasks.add(ImportTaskData(
        title: rowData['title'] ?? 'Imported Task',
        description: rowData['description'],
        status: _parseTaskStatus(rowData['status']),
        priority: _parseTaskPriority(rowData['priority']),
        dueDate: _parseDateTime(rowData['due date'] ?? rowData['duedate']),
        tags: rowData['tags']?.split(';').map((t) => t.trim()).toList() ?? [],
        projectId: rowData['project id']?.isNotEmpty == true ? rowData['project id'] : null,
      ));
    }
    
    return ParseResult.success(tasks);
  }
  
  /// Utility methods for parsing
  TaskStatus _parseTaskStatus(dynamic value) {
    if (value == null) return TaskStatus.pending;
    final str = value.toString().toLowerCase();
    for (final status in TaskStatus.values) {
      if (status.name.toLowerCase() == str || status.displayName.toLowerCase() == str) {
        return status;
      }
    }
    return TaskStatus.pending;
  }
  
  TaskPriority _parseTaskPriority(dynamic value) {
    if (value == null) return TaskPriority.medium;
    final str = value.toString().toLowerCase();
    for (final priority in TaskPriority.values) {
      if (priority.name.toLowerCase() == str || priority.displayName.toLowerCase() == str) {
        return priority;
      }
    }
    return TaskPriority.medium;
  }
  
  DateTime? _parseDateTime(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }
  
  List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String && value.isNotEmpty) {
      return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }
  
  List<ImportSubtaskData> _parseSubtasks(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];
    
    return value.map((item) {
      if (item is! Map<String, dynamic>) return null;
      return ImportSubtaskData(
        title: item['title'] as String? ?? '',
        isCompleted: item['isCompleted'] as bool? ?? false,
      );
    }).where((item) => item != null).cast<ImportSubtaskData>().toList();
  }
  
  List<String> _parseCsvRow(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        values.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    
    values.add(buffer.toString().trim());
    return values;
  }
  
  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}

// Supporting classes and enums
class ExportOptions {
  final bool includeCompleted;
  final bool includeArchived;
  final String dateFormat;
  
  const ExportOptions({
    this.includeCompleted = true,
    this.includeArchived = false,
    this.dateFormat = 'iso8601',
  });
}

class ImportOptions {
  final bool skipDuplicates;
  final bool updateExisting;
  final bool validateData;
  
  const ImportOptions({
    this.skipDuplicates = true,
    this.updateExisting = false,
    this.validateData = true,
  });
}

enum ImportFormat { json, csv }
enum ImportAction { created, updated, skipped }

// Result classes
class ExportResult {
  final bool success;
  final ExportFormat? format;
  final String? filePath;
  final int? taskCount;
  final int? fileSize;
  final String? error;
  
  const ExportResult._(
    this.success,
    this.format,
    this.filePath,
    this.taskCount,
    this.fileSize,
    this.error,
  );
  
  factory ExportResult.success({
    required ExportFormat format,
    required String filePath,
    required int taskCount,
    required int fileSize,
  }) => ExportResult._(true, format, filePath, taskCount, fileSize, null);
  
  factory ExportResult.failed(String error) => 
    ExportResult._(false, null, null, null, null, error);
}

class ImportResult {
  final bool success;
  final int imported;
  final int updated;
  final int skipped;
  final List<String> errors;
  final List<String> validationWarnings;
  final String? error;
  
  const ImportResult._(
    this.success,
    this.imported,
    this.updated,
    this.skipped,
    this.errors,
    this.validationWarnings,
    this.error,
  );
  
  factory ImportResult.success({
    required int imported,
    required int updated,
    required int skipped,
    required List<String> errors,
    required List<String> validationWarnings,
  }) => ImportResult._(true, imported, updated, skipped, errors, validationWarnings, null);
  
  factory ImportResult.failed(String error) => 
    ImportResult._(false, 0, 0, 0, [], [], error);
}

class ParseResult {
  final bool success;
  final List<ImportTaskData>? tasks;
  final String? error;
  
  const ParseResult._(this.success, this.tasks, this.error);
  
  factory ParseResult.success(List<ImportTaskData> tasks) => 
    ParseResult._(true, tasks, null);
  
  factory ParseResult.failed(String error) => 
    ParseResult._(false, null, error);
}

class ValidationResult {
  final List<String> warnings;
  
  const ValidationResult({required this.warnings});
}

class ImportTaskResult {
  final ImportAction action;
  
  const ImportTaskResult({required this.action});
}

class ImportTaskData {
  final String? id;
  final String title;
  final String? description;
  final TaskStatus? status;
  final TaskPriority? priority;
  final DateTime? dueDate;
  final List<String>? tags;
  final String? projectId;
  final List<String>? dependencies;
  final List<ImportSubtaskData>? subtasks;
  
  const ImportTaskData({
    this.id,
    required this.title,
    this.description,
    this.status,
    this.priority,
    this.dueDate,
    this.tags,
    this.projectId,
    this.dependencies,
    this.subtasks,
  });
}

class ImportSubtaskData {
  final String title;
  final bool isCompleted;
  
  const ImportSubtaskData({
    required this.title,
    required this.isCompleted,
  });
}