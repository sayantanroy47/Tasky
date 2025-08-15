import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/glassmorphism_container.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/theme_background_widget.dart';
import '../../core/theme/typography_constants.dart';
import '../../services/data_export/data_export_models.dart';
import '../providers/data_export_providers.dart';
import '../widgets/data_export_widgets.dart';

class DataExportPage extends ConsumerStatefulWidget {
  const DataExportPage({super.key});
  @override
  ConsumerState<DataExportPage> createState() => _DataExportPageState();
}

class _DataExportPageState extends ConsumerState<DataExportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ImportValidationResult? _validationResult;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // Listen to export/import states for showing snackbars
    ref.listen<AsyncValue<String?>>(dataExportNotifierProvider, (previous, next) {
      next.whenOrNull(
        data: (result) {
          if (result != null && result != 'shared') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Export completed: $result')),
            );
          } else if (result == 'shared') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data shared successfully')),
            );
          }
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Export failed: $error'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
      );
    });

    ref.listen<AsyncValue<ImportResult?>>(dataImportNotifierProvider, (previous, next) {
      next.whenOrNull(
        data: (result) {
          if (result == ImportResult.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Import completed successfully')),
            );
          } else if (result == ImportResult.partialSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Import completed with some errors')),
            );
          }
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Import failed: $error'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
      );
    });

    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: StandardizedAppBar(
          title: 'Data Management',
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.upload), text: 'Export'),
              Tab(icon: Icon(Icons.download), text: 'Import'),
              Tab(icon: Icon(Icons.backup), text: 'Backup'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight + 48), // Account for TabBar
          child: TabBarView(
        controller: _tabController,
        children: [
          _buildExportTab(),
          _buildImportTab(),
          _buildBackupTab(),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportTab() {
    final isExporting = ref.watch(isExportingProvider);
    ref.watch(selectedExportFormatProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ExportFormatSelector(),
          const SizedBox(height: 16),
          const ExportProgressIndicator(),
          const SizedBox(height: 16),
          
          // Export actions
          GlassmorphismContainer(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Actions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  // Export to file
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isExporting ? null : () => _exportToFile(),
                      icon: const Icon(Icons.save),
                      label: const Text('Export to File'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Share data
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isExporting ? null : () => _shareData(),
                      icon: const Icon(Icons.share),
                      label: const Text('Share Data'),
                    ),
                  ),
                ],
              ),
          ),
          
          const SizedBox(height: 16),
          
          // Export options (future enhancement)
          GlassmorphismContainer(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Options',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Currently exporting all tasks, projects, and tags. '
                    'Selective export options will be available in a future update.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportTab() {
    final isImporting = ref.watch(isImportingProvider);
    final selectedFile = ref.watch(selectedImportFileProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilePickerWidget(
            title: 'Select Import File',
            subtitle: 'Choose a JSON file exported from Task Tracker',
            allowedExtensions: const ['json'],
            onFileSelected: (filePath) async {
              if (filePath != null) {
                await _validateImportFile(filePath);
              } else {
                setState(() {
                  _validationResult = null;
                });
              }
            },
          ),
          
          const SizedBox(height: 16),
          
          // Validation result
          if (_validationResult != null) ...[
            ImportValidationWidget(validationResult: _validationResult!),
            const SizedBox(height: 16),
          ],
          
          // Import options
          if (selectedFile != null && _validationResult?.isValid == true) ...[
            const ImportOptionsWidget(),
            const SizedBox(height: 16),
          ],
          
          const ImportProgressIndicator(),
          const SizedBox(height: 16),
          
          // Import action
          if (selectedFile != null && _validationResult?.isValid == true)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isImporting ? null : () => _importData(),
                icon: const Icon(Icons.download),
                label: const Text('Import Data'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackupTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Create backup section
          GlassmorphismContainer(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Backup',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a complete backup of all your tasks, projects, and settings.',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _createBackup(),
                      icon: const Icon(Icons.backup),
                      label: const Text('Create Backup'),
                    ),
                  ),
                ],
              ),
          ),
          
          const SizedBox(height: 16),
          
          // Backup list
          GlassmorphismContainer(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Backups',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        onPressed: () => ref.read(backupNotifierProvider.notifier).loadBackups(),
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const BackupListWidget(),
                ],
              ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToFile() async {
    final format = ref.read(selectedExportFormatProvider);
    await ref.read(dataExportNotifierProvider.notifier).exportData(format: format);
  }

  Future<void> _shareData() async {
    final format = ref.read(selectedExportFormatProvider);
    await ref.read(dataExportNotifierProvider.notifier).shareData(format: format);
  }

  Future<void> _validateImportFile(String filePath) async {
    try {
      final result = await ref.read(dataImportNotifierProvider.notifier).validateImportFile(filePath);
      setState(() {
        _validationResult = result;
      });
    } catch (e) {
      setState(() {
        _validationResult = ImportValidationResult(
          isValid: false,
          errors: ['Validation failed: $e'],
          warnings: [],
          taskCount: 0,
          projectCount: 0,
          tagCount: 0,
        );
      });
    }
  }

  Future<void> _importData() async {
    final filePath = ref.read(selectedImportFileProvider);
    final options = ref.read(importOptionsProvider);
    
    if (filePath != null) {
      await ref.read(dataImportNotifierProvider.notifier).importData(
        filePath: filePath,
        options: options,
      );
      
      // Clear the selected file after successful import
      ref.read(selectedImportFileProvider.notifier).state = null;
      setState(() {
        _validationResult = null;
      });
    }
  }

  Future<void> _createBackup() async {
    try {
      final backupPath = await ref.read(backupNotifierProvider.notifier).createBackup();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup created: ${backupPath.split('/').last}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create backup: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
