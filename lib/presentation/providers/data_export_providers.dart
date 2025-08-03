import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/tag_repository.dart';
import '../../data/repositories/tag_repository_impl.dart';
import '../../services/data_export/data_export_service.dart';
import '../../services/data_export/data_export_models.dart';
import 'task_providers.dart' as task_providers;
import 'project_providers.dart' as project_providers;

// Tag repository provider
final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final database = ref.watch(task_providers.databaseProvider);
  return TagRepositoryImpl(database);
});

// Service provider
final dataExportServiceProvider = Provider<DataExportService>((ref) {
  return DataExportServiceImpl(
    taskRepository: ref.read(task_providers.taskRepositoryProvider),
    projectRepository: ref.read(project_providers.projectRepositoryProvider),
    tagRepository: ref.read(tagRepositoryProvider),
  );
});

// Export state providers
final exportProgressProvider = StateProvider<ExportProgress?>((ref) => null);
final importProgressProvider = StateProvider<ImportProgress?>((ref) => null);

// Export/Import state notifiers
class DataExportNotifier extends StateNotifier<AsyncValue<String?>> {
  final DataExportService _dataExportService;

  DataExportNotifier(this._dataExportService) : super(const AsyncValue.data(null));

  Future<void> exportData({
    required ExportFormat format,
    String? filePath,
    List<String>? taskIds,
    List<String>? projectIds,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      String? exportPath;
      
      await for (final progress in _dataExportService.exportData(
        format: format,
        filePath: filePath,
        taskIds: taskIds,
        projectIds: projectIds,
      )) {
        // Update progress through separate provider
        // Note: ref is not available in StateNotifier methods
        // Progress updates should be handled differently
        
        if (progress.progress == 1.0) {
          exportPath = filePath; // The service should provide the actual path
        }
      }
      
      state = AsyncValue.data(exportPath);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> shareData({
    required ExportFormat format,
    List<String>? taskIds,
    List<String>? projectIds,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _dataExportService.shareData(
        format: format,
        taskIds: taskIds,
        projectIds: projectIds,
      );
      
      state = const AsyncValue.data('shared');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearState() {
    state = const AsyncValue.data(null);
  }
}

final dataExportNotifierProvider = StateNotifierProvider<DataExportNotifier, AsyncValue<String?>>((ref) {
  return DataExportNotifier(ref.read(dataExportServiceProvider));
});

class DataImportNotifier extends StateNotifier<AsyncValue<ImportResult?>> {
  final DataExportService _dataExportService;

  DataImportNotifier(this._dataExportService) : super(const AsyncValue.data(null));

  Future<ImportValidationResult> validateImportFile(String filePath) async {
    return await _dataExportService.validateImportFile(filePath);
  }

  Future<void> importData({
    required String filePath,
    required ImportOptions options,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await for (final _ in _dataExportService.importData(
        filePath: filePath,
        options: options,
      )) {
        // Progress updates should be handled through a callback or separate mechanism
        // since ref is not available in StateNotifier methods
      }
      
      state = const AsyncValue.data(ImportResult.success);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearState() {
    state = const AsyncValue.data(null);
  }
}

final dataImportNotifierProvider = StateNotifierProvider<DataImportNotifier, AsyncValue<ImportResult?>>((ref) {
  return DataImportNotifier(ref.read(dataExportServiceProvider));
});

// Backup management
class BackupNotifier extends StateNotifier<AsyncValue<List<BackupMetadata>>> {
  final DataExportService _dataExportService;

  BackupNotifier(this._dataExportService) : super(const AsyncValue.loading()) {
    loadBackups();
  }

  Future<void> loadBackups() async {
    state = const AsyncValue.loading();
    
    try {
      final backups = await _dataExportService.getAvailableBackups();
      state = AsyncValue.data(backups);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<String> createBackup() async {
    try {
      final backupPath = await _dataExportService.createBackup();
      await loadBackups(); // Refresh the list
      return backupPath;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> restoreBackup(String backupPath) async {
    try {
      await _dataExportService.restoreBackup(backupPath);
      // Note: Provider invalidation should be handled at a higher level
      // since ref is not available in StateNotifier methods
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteBackup(String backupId) async {
    try {
      await _dataExportService.deleteBackup(backupId);
      await loadBackups(); // Refresh the list
    } catch (error) {
      rethrow;
    }
  }
}

final backupNotifierProvider = StateNotifierProvider<BackupNotifier, AsyncValue<List<BackupMetadata>>>((ref) {
  return BackupNotifier(ref.read(dataExportServiceProvider));
});

// Storage permissions
final storagePermissionsProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(dataExportServiceProvider);
  return await service.requestStoragePermissions();
});

// Export format selection
final selectedExportFormatProvider = StateProvider<ExportFormat>((ref) => ExportFormat.json);

// Import options
final importOptionsProvider = StateProvider<ImportOptions>((ref) => const ImportOptions());

// Selected items for export
final selectedTaskIdsProvider = StateProvider<List<String>?>((ref) => null);
final selectedProjectIdsProvider = StateProvider<List<String>?>((ref) => null);

// File picker result
final selectedImportFileProvider = StateProvider<String?>((ref) => null);

// Export/Import UI state
enum ExportImportTab { export, import, backup }

final exportImportTabProvider = StateProvider<ExportImportTab>((ref) => ExportImportTab.export);

// Helper providers for UI
final isExportingProvider = Provider<bool>((ref) {
  final exportState = ref.watch(dataExportNotifierProvider);
  return exportState.isLoading;
});

final isImportingProvider = Provider<bool>((ref) {
  final importState = ref.watch(dataImportNotifierProvider);
  return importState.isLoading;
});

final exportErrorProvider = Provider<String?>((ref) {
  final exportState = ref.watch(dataExportNotifierProvider);
  return exportState.hasError ? exportState.error.toString() : null;
});

final importErrorProvider = Provider<String?>((ref) {
  final importState = ref.watch(dataImportNotifierProvider);
  return importState.hasError ? importState.error.toString() : null;
});

// Export progress percentage
final exportProgressPercentageProvider = Provider<double>((ref) {
  final exportState = ref.watch(dataExportNotifierProvider);
  return exportState.isLoading ? 0.5 : (exportState.hasValue ? 1.0 : 0.0);
});

// Import progress percentage
final importProgressPercentageProvider = Provider<double>((ref) {
  final importState = ref.watch(dataImportNotifierProvider);
  return importState.isLoading ? 0.5 : (importState.hasValue ? 1.0 : 0.0);
});

// Current operation text
final currentExportOperationProvider = Provider<String>((ref) {
  final exportState = ref.watch(dataExportNotifierProvider);
  return exportState.isLoading ? 'Exporting...' : '';
});

final currentImportOperationProvider = Provider<String>((ref) {
  final importState = ref.watch(dataImportNotifierProvider);
  return importState.isLoading ? 'Importing...' : '';
});
