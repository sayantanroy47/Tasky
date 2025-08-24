import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import '../domain/entities/task_model.dart';
import '../domain/models/enums.dart';
import '../domain/repositories/task_repository.dart';

/// Service for importing and exporting task data
class ImportExportService {
  final TaskRepository _taskRepository;

  ImportExportService(this._taskRepository);

  /// Export tasks to JSON format
  Future<String> exportToJSON() async {
    try {
      final tasks = await _taskRepository.getAllTasks();
      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'totalTasks': tasks.length,
        'tasks': tasks.map((task) => task.toJson()).toList(),
      };
      
      return const JsonEncoder.withIndent('  ').convert(exportData);
    } catch (e) {
      throw Exception('Failed to export to JSON: $e');
    }
  }

  /// Export tasks to CSV format
  Future<String> exportToCSV() async {
    try {
      final tasks = await _taskRepository.getAllTasks();
      
      // Define CSV headers
      final headers = [
        'ID',
        'Title', 
        'Description',
        'Priority',
        'Status',
        'Created At',
        'Updated At',
        'Due Date',
        'Tags',
        'Project ID',
        'Completion Date',
        'Estimated Duration',
        'Actual Duration'
      ];
      
      // Convert tasks to rows
      final rows = <List<String>>[headers];
      
      for (final task in tasks) {
        rows.add([
          task.id,
          task.title,
          task.description ?? '',
          task.priority.name,
          task.status.name,
          task.createdAt.toIso8601String(),
          task.updatedAt?.toIso8601String() ?? '',
          task.dueDate?.toIso8601String() ?? '',
          task.tags.join('; '),
          task.projectId ?? '',
          task.completedAt?.toIso8601String() ?? '',
          task.estimatedDuration?.toString() ?? '',
          task.actualDuration?.toString() ?? '',
        ]);
      }
      
      return const ListToCsvConverter().convert(rows);
    } catch (e) {
      throw Exception('Failed to export to CSV: $e');
    }
  }

  /// Save exported data to file
  Future<String?> saveExportToFile(String data, String fileName) async {
    try {
      // Request storage permission
      if (!kIsWeb && Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Storage permission denied');
        }
      }

      String? outputFile;
      
      if (kIsWeb) {
        // For web, use file_picker to save
        // This would trigger a download in the browser
        throw Exception('Web export not implemented yet');
      } else {
        // For mobile, save to Downloads folder
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(data);
        outputFile = file.path;
      }
      
      return outputFile;
    } catch (e) {
      throw Exception('Failed to save export file: $e');
    }
  }

  /// Export and save tasks in specified format
  Future<String?> exportTasks(ExportFormat format) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String data;
      String fileName;
      
      switch (format) {
        case ExportFormat.json:
          data = await exportToJSON();
          fileName = 'tasky_export_$timestamp.json';
          break;
        case ExportFormat.csv:
          data = await exportToCSV();
          fileName = 'tasky_export_$timestamp.csv';
          break;
        case ExportFormat.txt:
          data = await exportToJSON(); // Use JSON for now
          fileName = 'tasky_export_$timestamp.txt';
          break;
        case ExportFormat.pdf:
          data = await exportToJSON(); // Use JSON for now
          fileName = 'tasky_export_$timestamp.pdf';
          break;
        case ExportFormat.excel:
          data = await exportToCSV(); // Use CSV for now
          fileName = 'tasky_export_$timestamp.xlsx';
          break;
      }
      
      return await saveExportToFile(data, fileName);
    } catch (e) {
      throw Exception('Export failed: $e');
    }
  }

  /// Import tasks from JSON format
  Future<ImportResult> importFromJSON(String jsonData) async {
    try {
      final data = json.decode(jsonData) as Map<String, dynamic>;
      
      // Validate format
      if (!data.containsKey('tasks')) {
        throw Exception('Invalid JSON format: missing tasks array');
      }
      
      final tasksJson = data['tasks'] as List<dynamic>;
      final importedTasks = <TaskModel>[];
      final errors = <String>[];
      
      for (int i = 0; i < tasksJson.length; i++) {
        try {
          final taskJson = tasksJson[i] as Map<String, dynamic>;
          
          // Generate new ID to avoid conflicts
          taskJson['id'] = '${DateTime.now().millisecondsSinceEpoch}_$i';
          
          final task = TaskModel.fromJson(taskJson);
          importedTasks.add(task);
        } catch (e) {
          errors.add('Task ${i + 1}: $e');
        }
      }
      
      // Save imported tasks
      int successCount = 0;
      for (final task in importedTasks) {
        try {
          await _taskRepository.createTask(task);
          successCount++;
        } catch (e) {
          errors.add('Failed to save task "${task.title}": $e');
        }
      }
      
      return ImportResult(
        totalTasks: tasksJson.length,
        successfulImports: successCount,
        errors: errors,
      );
      
    } catch (e) {
      throw Exception('Failed to import JSON: $e');
    }
  }

  /// Import tasks from CSV format
  Future<ImportResult> importFromCSV(String csvData) async {
    try {
      final rows = const CsvToListConverter().convert(csvData);
      
      if (rows.isEmpty) {
        throw Exception('CSV file is empty');
      }
      
      final headers = rows[0].map((e) => e.toString()).toList();
      final dataRows = rows.skip(1).toList();
      
      // Validate required headers
      final requiredHeaders = ['Title', 'Priority', 'Status'];
      for (final header in requiredHeaders) {
        if (!headers.contains(header)) {
          throw Exception('CSV missing required header: $header');
        }
      }
      
      final importedTasks = <TaskModel>[];
      final errors = <String>[];
      
      for (int i = 0; i < dataRows.length; i++) {
        try {
          final row = dataRows[i];
          final rowData = <String, dynamic>{};
          
          // Map row data to headers
          for (int j = 0; j < headers.length && j < row.length; j++) {
            rowData[headers[j]] = row[j]?.toString() ?? '';
          }
          
          // Create task from row data
          final task = _createTaskFromCSVRow(rowData, i);
          importedTasks.add(task);
        } catch (e) {
          errors.add('Row ${i + 2}: $e');
        }
      }
      
      // Save imported tasks
      int successCount = 0;
      for (final task in importedTasks) {
        try {
          await _taskRepository.createTask(task);
          successCount++;
        } catch (e) {
          errors.add('Failed to save task "${task.title}": $e');
        }
      }
      
      return ImportResult(
        totalTasks: dataRows.length,
        successfulImports: successCount,
        errors: errors,
      );
      
    } catch (e) {
      throw Exception('Failed to import CSV: $e');
    }
  }

  /// Create task from CSV row data
  TaskModel _createTaskFromCSVRow(Map<String, dynamic> rowData, int index) {
    final now = DateTime.now();
    
    return TaskModel(
      id: '${now.millisecondsSinceEpoch}_import_$index',
      title: rowData['Title']?.toString().trim() ?? 'Imported Task',
      description: rowData['Description']?.toString().trim().isNotEmpty == true
          ? rowData['Description'].toString().trim()
          : null,
      priority: _parseTaskPriority(rowData['Priority']?.toString()),
      status: _parseTaskStatus(rowData['Status']?.toString()),
      createdAt: _parseDateTime(rowData['Created At']) ?? now,
      updatedAt: _parseDateTime(rowData['Updated At']) ?? now,
      dueDate: _parseDateTime(rowData['Due Date']),
      tags: _parseTags(rowData['Tags']?.toString()),
      projectId: rowData['Project ID']?.toString().trim().isNotEmpty == true
          ? rowData['Project ID'].toString().trim()
          : null,
      completedAt: _parseDateTime(rowData['Completion Date']),
      estimatedDuration: _parseDurationAsInt(rowData['Estimated Duration']?.toString()),
      actualDuration: _parseDurationAsInt(rowData['Actual Duration']?.toString()),
      subTasks: const [],
      dependencies: const [],
      metadata: {
        'source': 'csv_import',
        'import_date': now.toIso8601String(),
      },
    );
  }

  /// Import tasks from file
  Future<ImportResult> importTasksFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'csv'],
      );
      
      if (result == null || result.files.single.path == null) {
        throw Exception('No file selected');
      }
      
      final file = File(result.files.single.path!);
      final fileContent = await file.readAsString();
      final extension = result.files.single.extension?.toLowerCase();
      
      switch (extension) {
        case 'json':
          return await importFromJSON(fileContent);
        case 'csv':
          return await importFromCSV(fileContent);
        default:
          throw Exception('Unsupported file format: $extension');
      }
    } catch (e) {
      throw Exception('Import failed: $e');
    }
  }

  /// Parse task priority from string
  TaskPriority _parseTaskPriority(String? value) {
    if (value == null) return TaskPriority.medium;
    
    switch (value.toLowerCase()) {
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

  /// Parse task status from string
  TaskStatus _parseTaskStatus(String? value) {
    if (value == null) return TaskStatus.pending;
    
    switch (value.toLowerCase()) {
      case 'completed':
        return TaskStatus.completed;
      case 'in_progress':
      case 'inprogress':
        return TaskStatus.inProgress;
      case 'cancelled':
        return TaskStatus.cancelled;
      default:
        return TaskStatus.pending;
    }
  }

  /// Parse DateTime from string
  DateTime? _parseDateTime(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    
    try {
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }

  /// Parse tags from string
  List<String> _parseTags(String? value) {
    if (value == null || value.trim().isEmpty) return [];
    
    return value
        .split(';')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  /// Parse duration from string as minutes
  int? _parseDurationAsInt(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    
    try {
      return int.parse(value);
    } catch (e) {
      return null;
    }
  }
}


/// Result of import operation
class ImportResult {
  final int totalTasks;
  final int successfulImports;
  final List<String> errors;

  ImportResult({
    required this.totalTasks,
    required this.successfulImports,
    required this.errors,
  });

  int get failedImports => totalTasks - successfulImports;
  bool get hasErrors => errors.isNotEmpty;
  bool get isSuccessful => successfulImports > 0;
}