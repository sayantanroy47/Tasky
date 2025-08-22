import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/project.dart';
import 'data_export_models.dart';
import 'real_data_export_service.dart';

/// Service interface for data export functionality
abstract class DataExportService {
  Future<ExportResult> exportTasks(
    List<TaskModel> tasks, {
    ExportFormat format = ExportFormat.csv,
    ExportOptions? options,
  });

  Future<ExportResult> exportProjects(
    List<Project> projects, {
    ExportFormat format = ExportFormat.csv,
    ExportOptions? options,
  });

  Future<ExportResult> exportFullBackup({
    ExportOptions? options,
  });

  Future<ImportResultData> importTasks(
    String filePath, {
    ImportOptions? options,
  });

  Future<ImportResultData> importProjects(
    String filePath, {
    ImportOptions? options,
  });

  Future<ImportResultData> importFullBackup(
    String filePath, {
    ImportOptions? options,
  });

  Future<bool> shareFile(String filePath, {String? subject});

  Future<String?> pickImportFile({
    List<String>? allowedExtensions,
  });

  Future<List<ExportFormat>> getSupportedFormats();

  Future<bool> hasStoragePermission();

  Future<bool> requestStoragePermission();

  Future<String> getExportDirectory();

  Future<void> cleanupOldExports({int maxAgeInDays = 30});

  // Additional methods called by providers
  Future<bool> requestStoragePermissions();
  Stream<ExportProgress> exportData({
    required ExportFormat format,
    String? filePath,
    List<String>? taskIds,
    List<String>? projectIds,
  });
  Future<void> shareData({
    required ExportFormat format,
    List<String>? taskIds,
    List<String>? projectIds,
  });
  Future<ImportValidationResult> validateImportFile(String filePath);
  Stream<ImportProgress> importData({
    required String filePath,
    ImportOptions? options,
  });
  Future<List<BackupMetadata>> getAvailableBackups();
  Future<String> createBackup();
  Future<void> restoreBackup(String backupPath);
  Future<void> deleteBackup(String backupId);
}

/// Factory implementation that delegates to real or stub based on availability
class DataExportServiceImpl implements DataExportService {
  late final DataExportService _delegate;

  DataExportServiceImpl({
    dynamic taskRepository,
    dynamic projectRepository,
    dynamic tagRepository,
  }) {
    try {
      // Try to use real data export service
      _delegate = RealDataExportService(
        taskRepository: taskRepository,
        projectRepository: projectRepository,
        tagRepository: tagRepository,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Real data export service not available, using stub: $e');
      }
      _delegate = _StubDataExportService();
    }
  }

  @override
  Future<ExportResult> exportTasks(
    List<TaskModel> tasks, {
    ExportFormat format = ExportFormat.csv,
    ExportOptions? options,
  }) => _delegate.exportTasks(tasks, format: format, options: options);

  @override
  Future<ExportResult> exportProjects(
    List<Project> projects, {
    ExportFormat format = ExportFormat.csv,
    ExportOptions? options,
  }) => _delegate.exportProjects(projects, format: format, options: options);

  @override
  Future<ExportResult> exportFullBackup({
    ExportOptions? options,
  }) => _delegate.exportFullBackup(options: options);

  @override
  Future<ImportResultData> importTasks(
    String filePath, {
    ImportOptions? options,
  }) => _delegate.importTasks(filePath, options: options);

  @override
  Future<ImportResultData> importProjects(
    String filePath, {
    ImportOptions? options,
  }) => _delegate.importProjects(filePath, options: options);

  @override
  Future<ImportResultData> importFullBackup(
    String filePath, {
    ImportOptions? options,
  }) => _delegate.importFullBackup(filePath, options: options);

  @override
  Future<bool> shareFile(String filePath, {String? subject}) =>
      _delegate.shareFile(filePath, subject: subject);

  @override
  Future<String?> pickImportFile({
    List<String>? allowedExtensions,
  }) => _delegate.pickImportFile(allowedExtensions: allowedExtensions);

  @override
  Future<List<ExportFormat>> getSupportedFormats() =>
      _delegate.getSupportedFormats();

  @override
  Future<bool> hasStoragePermission() => _delegate.hasStoragePermission();

  @override
  Future<bool> requestStoragePermission() => _delegate.requestStoragePermission();

  @override
  Future<String> getExportDirectory() => _delegate.getExportDirectory();

  @override
  Future<void> cleanupOldExports({int maxAgeInDays = 30}) =>
      _delegate.cleanupOldExports(maxAgeInDays: maxAgeInDays);

  @override
  Future<bool> requestStoragePermissions() =>
      _delegate.requestStoragePermissions();

  @override
  Stream<ExportProgress> exportData({
    required ExportFormat format,
    String? filePath,
    List<String>? taskIds,
    List<String>? projectIds,
  }) => _delegate.exportData(
        format: format,
        filePath: filePath,
        taskIds: taskIds,
        projectIds: projectIds,
      );

  @override
  Future<void> shareData({
    required ExportFormat format,
    List<String>? taskIds,
    List<String>? projectIds,
  }) => _delegate.shareData(
        format: format,
        taskIds: taskIds,
        projectIds: projectIds,
      );

  @override
  Future<ImportValidationResult> validateImportFile(String filePath) =>
      _delegate.validateImportFile(filePath);

  @override
  Stream<ImportProgress> importData({
    required String filePath,
    ImportOptions? options,
  }) => _delegate.importData(
        filePath: filePath,
        options: options,
      );

  @override
  Future<List<BackupMetadata>> getAvailableBackups() =>
      _delegate.getAvailableBackups();

  @override
  Future<String> createBackup() => _delegate.createBackup();

  @override
  Future<void> restoreBackup(String backupPath) =>
      _delegate.restoreBackup(backupPath);

  @override
  Future<void> deleteBackup(String backupId) =>
      _delegate.deleteBackup(backupId);
}

/// Stub implementation fallback when export packages are not available
class _StubDataExportService implements DataExportService {
  @override
  Future<ExportResult> exportTasks(
    List<TaskModel> tasks, {
    ExportFormat format = ExportFormat.csv,
    ExportOptions? options,
  }) async {
    if (kDebugMode) {
      // print('Stub: Would export ${tasks.length} tasks in $format format');
    }
    
    return const ExportResult(
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
      // print('Stub: Would export ${projects.length} projects in $format format');
    }
    
    return const ExportResult(
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
      // print('Stub: Would export full backup');
    }
    
    return const ExportResult(
      success: false,
      message: 'Export not available in stub mode',
      filePath: null,
      fileSize: 0,
    );
  }
  @override
  Future<ImportResultData> importTasks(
    String filePath, {
    ImportOptions? options,
  }) async {
    if (kDebugMode) {
      // print('Stub: Would import tasks from $filePath');
    }
    
    return const ImportResultData(
      success: false,
      message: 'Import not available in stub mode',
      importedCount: 0,
      skippedCount: 0,
      errors: ['Import not available in stub mode'],
    );
  }
  @override
  Future<ImportResultData> importProjects(
    String filePath, {
    ImportOptions? options,
  }) async {
    if (kDebugMode) {
      // print('Stub: Would import projects from $filePath');
    }
    
    return const ImportResultData(
      success: false,
      message: 'Import not available in stub mode',
      importedCount: 0,
      skippedCount: 0,
      errors: ['Import not available in stub mode'],
    );
  }
  @override
  Future<ImportResultData> importFullBackup(
    String filePath, {
    ImportOptions? options,
  }) async {
    if (kDebugMode) {
      // print('Stub: Would import full backup from $filePath');
    }
    
    return const ImportResultData(
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
      // print('Stub: Would share file $filePath');
    }
    return false;
  }
  @override
  Future<String?> pickImportFile({
    List<String>? allowedExtensions,
  }) async {
    if (kDebugMode) {
      // print('Stub: Would pick import file');
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
      // print('Stub: Would cleanup exports older than $maxAgeInDays days');
    }
  }

  // Additional methods called by providers
  @override
  Future<bool> requestStoragePermissions() async {
    if (kDebugMode) {
      // print('Stub: Would request storage permissions');
    }
    return false;
  }
  @override
  Stream<ExportProgress> exportData({
    required ExportFormat format,
    String? filePath,
    List<String>? taskIds,
    List<String>? projectIds,
  }) async* {
    if (kDebugMode) {
      // print('Stub: Would export data to ${filePath ?? 'default path'} in $format format');
    }
    yield const ExportProgress(
      totalItems: 0,
      processedItems: 0,
      currentOperation: 'Export not available',
      progress: 0.0,
    );
  }
  @override
  Future<void> shareData({
    required ExportFormat format,
    List<String>? taskIds,
    List<String>? projectIds,
  }) async {
    if (kDebugMode) {
      // print('Stub: Would share data in $format format');
    }
  }
  @override
  Future<ImportValidationResult> validateImportFile(String filePath) async {
    if (kDebugMode) {
      // print('Stub: Would validate import file $filePath');
    }
    return const ImportValidationResult(
      isValid: false,
      errors: ['Import validation not available in stub mode'],
      warnings: [],
      taskCount: 0,
      projectCount: 0,
      tagCount: 0,
    );
  }
  @override
  Stream<ImportProgress> importData({
    required String filePath,
    ImportOptions? options,
  }) async* {
    if (kDebugMode) {
      // print('Stub: Would import data from $filePath');
    }
    yield const ImportProgress(
      totalItems: 0,
      processedItems: 0,
      currentOperation: 'Import not available',
      progress: 0.0,
    );
  }
  @override
  Future<List<BackupMetadata>> getAvailableBackups() async {
    if (kDebugMode) {
      // print('Stub: Would get available backups');
    }
    return [];
  }
  @override
  Future<String> createBackup() async {
    if (kDebugMode) {
      // print('Stub: Would create backup');
    }
    return '';
  }
  @override
  Future<void> restoreBackup(String backupPath) async {
    if (kDebugMode) {
      // print('Stub: Would restore backup from $backupPath');
    }
  }
  @override
  Future<void> deleteBackup(String backupId) async {
    if (kDebugMode) {
      // print('Stub: Would delete backup $backupId');
    }
  }
}