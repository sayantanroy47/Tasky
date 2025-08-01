import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../task/task_models.dart';
import '../project/project_models.dart';
import 'data_export_service.dart';
import 'data_export_models.dart';

/// Stub implementation of DataExportService when export packages are not available
class DataExportServiceStub implements DataExportService {
  @override
  Future<ExportResult> exportTasks(
    List<Task> tasks, {
    ExportFormat format = ExportFormat.csv,
    ExportOptions? options,
  }) async {
    if (kDebugMode) {
      print('Stub: Would export ${tasks.length} tasks in $format format');
    }
    
    return ExportResult(
      success: false,
      message: 'Export not available in stub mode',
      filePath: null,
      fileSize: 0,
    );
  }

  @override
  Future<ExportResult> exportProjects(
    List<Project> projects, {
    ExportFormat format = ExportFormat.csv,
    ExportOptions? options,
  }) async {
    if (kDebugMode) {
      print('Stub: Would export ${projects.length} projects in $format format');
    }
    
    return ExportResult(
      success: false,
      message: 'Export not available in stub mode',
      filePath: null,
      fileSize: 0,
    );
  }

  @override
  Future<ExportResult> exportFullBackup({
    ExportOptions? options,
  }) async {
    if (kDebugMode) {
      print('Stub: Would export full backup');
    }
    
    return ExportResult(
      success: false,
      message: 'Export not available in stub mode',
      filePath: null,
      fileSize: 0,
    );
  }

  @override
  Future<ImportResult> importTasks(
    String filePath, {
    ImportOptions? options,
  }) async {
    if (kDebugMode) {
      print('Stub: Would import tasks from $filePath');
    }
    
    return ImportResult(
      success: false,
      message: 'Import not available in stub mode',
      importedCount: 0,
      skippedCount: 0,
      errors: ['Import not available in stub mode'],
    );
  }

  @override
  Future<ImportResult> importProjects(
    String filePath, {
    ImportOptions? options,
  }) async {
    if (kDebugMode) {
      print('Stub: Would import projects from $filePath');
    }
    
    return ImportResult(
      success: false,
      message: 'Import not available in stub mode',
      importedCount: 0,
      skippedCount: 0,
      errors: ['Import not available in stub mode'],
    );
  }

  @override
  Future<ImportResult> importFullBackup(
    String filePath, {
    ImportOptions? options,
  }) async {
    if (kDebugMode) {
      print('Stub: Would import full backup from $filePath');
    }
    
    return ImportResult(
      success: false,
      message: 'Import not available in stub mode',
      importedCount: 0,
      skippedCount: 0,
      errors: ['Import not available in stub mode'],
    );
  }

  @override
  Future<bool> shareFile(String filePath, {String? subject}) async {
    if (kDebugMode) {
      print('Stub: Would share file $filePath');
    }
    return false;
  }

  @override
  Future<String?> pickImportFile({
    List<String>? allowedExtensions,
  }) async {
    if (kDebugMode) {
      print('Stub: Would pick import file');
    }
    return null;
  }

  @override
  Future<List<ExportFormat>> getSupportedFormats() async {
    return [ExportFormat.csv, ExportFormat.json]; // Return basic formats
  }

  @override
  Future<bool> hasStoragePermission() async {
    return false; // Always false for stub
  }

  @override
  Future<bool> requestStoragePermission() async {
    return false; // Always false for stub
  }

  @override
  Future<String> getExportDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, 'exports');
  }

  @override
  Future<void> cleanupOldExports({int maxAgeInDays = 30}) async {
    if (kDebugMode) {
      print('Stub: Would cleanup exports older than $maxAgeInDays days');
    }
  }
}
