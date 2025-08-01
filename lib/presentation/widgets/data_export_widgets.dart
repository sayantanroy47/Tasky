import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:file_picker/file_picker.dart';

import '../../services/data_export/data_export_models.dart';
import '../providers/data_export_providers.dart';

class ExportFormatSelector extends ConsumerWidget {
  const ExportFormatSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFormat = ref.watch(selectedExportFormatProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Format',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...ExportFormat.values.map((format) {
              return RadioListTile<ExportFormat>(
                title: Text(_getFormatDisplayName(format)),
                subtitle: Text(_getFormatDescription(format)),
                value: format,
                groupValue: selectedFormat,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(selectedExportFormatProvider.notifier).state = value;
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getFormatDisplayName(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return 'JSON';
      case ExportFormat.csv:
        return 'CSV (Spreadsheet)';
      case ExportFormat.plainText:
        return 'Plain Text';
    }
  }

  String _getFormatDescription(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return 'Structured data format, best for re-importing';
      case ExportFormat.csv:
        return 'Spreadsheet format, good for analysis';
      case ExportFormat.plainText:
        return 'Human-readable format, good for sharing';
    }
  }
}

class ExportProgressIndicator extends ConsumerWidget {
  const ExportProgressIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(exportProgressProvider);
    final isExporting = ref.watch(isExportingProvider);

    if (!isExporting || progress == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exporting Data...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.progress,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              progress.currentOperation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${progress.processedItems} of ${progress.totalItems} items',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class ImportProgressIndicator extends ConsumerWidget {
  const ImportProgressIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(importProgressProvider);
    final isImporting = ref.watch(isImportingProvider);

    if (!isImporting || progress == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Importing Data...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.progress,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              progress.currentOperation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${progress.processedItems} of ${progress.totalItems} items',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (progress.errors.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Errors: ${progress.errors.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ImportOptionsWidget extends ConsumerWidget {
  const ImportOptionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ref.watch(importOptionsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Overwrite Existing Items'),
              subtitle: const Text('Replace existing tasks and projects with imported ones'),
              value: options.overwriteExisting,
              onChanged: (value) {
                ref.read(importOptionsProvider.notifier).state = options.copyWith(
                  overwriteExisting: value,
                );
              },
            ),
            SwitchListTile(
              title: const Text('Create Missing Projects'),
              subtitle: const Text('Automatically create projects that don\'t exist'),
              value: options.createMissingProjects,
              onChanged: (value) {
                ref.read(importOptionsProvider.notifier).state = options.copyWith(
                  createMissingProjects: value,
                );
              },
            ),
            SwitchListTile(
              title: const Text('Create Missing Tags'),
              subtitle: const Text('Automatically create tags that don\'t exist'),
              value: options.createMissingTags,
              onChanged: (value) {
                ref.read(importOptionsProvider.notifier).state = options.copyWith(
                  createMissingTags: value,
                );
              },
            ),
            SwitchListTile(
              title: const Text('Preserve IDs'),
              subtitle: const Text('Keep original IDs from import file'),
              value: options.preserveIds,
              onChanged: (value) {
                ref.read(importOptionsProvider.notifier).state = options.copyWith(
                  preserveIds: value,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FilePickerWidget extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final List<String> allowedExtensions;
  final ValueChanged<String?> onFileSelected;

  const FilePickerWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.allowedExtensions,
    required this.onFileSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFile = ref.watch(selectedImportFileProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            if (selectedFile != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedFile.split('/').last,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        ref.read(selectedImportFileProvider.notifier).state = null;
                        onFileSelected(null);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // File picker not available in stub mode
                  // final result = await FilePicker.platform.pickFiles(
                  //   type: FileType.custom,
                  //   allowedExtensions: allowedExtensions,
                  //   allowMultiple: false,
                  // );
                  
                  // Show a message that file picker is not available
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('File picker not available in current build'),
                      ),
                    );
                  }
                  
                  // if (result != null && result.files.isNotEmpty) {
                  //   final filePath = result.files.first.path;
                  //   if (filePath != null) {
                  //     ref.read(selectedImportFileProvider.notifier).state = filePath;
                  //     onFileSelected(filePath);
                  //   }
                  // }
                },
                icon: const Icon(Icons.folder_open),
                label: Text(selectedFile == null ? 'Select File' : 'Change File'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImportValidationWidget extends ConsumerWidget {
  final ImportValidationResult validationResult;

  const ImportValidationWidget({
    super.key,
    required this.validationResult,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  validationResult.isValid ? Icons.check_circle : Icons.error,
                  color: validationResult.isValid
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  validationResult.isValid ? 'File Valid' : 'Validation Failed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: validationResult.isValid
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Import Summary',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tasks:'),
                      Text('${validationResult.taskCount}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Projects:'),
                      Text('${validationResult.projectCount}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tags:'),
                      Text('${validationResult.tagCount}'),
                    ],
                  ),
                ],
              ),
            ),

            // Errors
            if (validationResult.errors.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Errors',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 4),
              ...validationResult.errors.map((error) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],

            // Warnings
            if (validationResult.warnings.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Warnings',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: 4),
              ...validationResult.warnings.map((warning) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}

class BackupListWidget extends ConsumerWidget {
  const BackupListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupsAsync = ref.watch(backupNotifierProvider);

    return backupsAsync.when(
      data: (backups) {
        if (backups.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.backup, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No backups found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your first backup to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: backups.map((backup) => BackupListItem(backup: backup)).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.error,
                color: Theme.of(context).colorScheme.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load backups',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(backupNotifierProvider.notifier).loadBackups(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BackupListItem extends ConsumerWidget {
  final BackupMetadata backup;

  const BackupListItem({super.key, required this.backup});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.backup),
        title: Text('Backup ${backup.id}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Created: ${_formatDate(backup.createdAt)}'),
            Text('${backup.taskCount} tasks, ${backup.projectCount} projects, ${backup.tagCount} tags'),
            Text('Size: ${_formatFileSize(backup.fileSizeBytes)}'),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'restore':
                await _showRestoreConfirmation(context, ref, backup);
                break;
              case 'delete':
                await _showDeleteConfirmation(context, ref, backup);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'restore',
              child: ListTile(
                leading: Icon(Icons.restore),
                title: Text('Restore'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _showRestoreConfirmation(BuildContext context, WidgetRef ref, BackupMetadata backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: Text(
          'This will replace all current data with the backup from ${_formatDate(backup.createdAt)}. '
          'This action cannot be undone.\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final backupPath = 'backup_${backup.id}.json'; // This should be the full path
        await ref.read(backupNotifierProvider.notifier).restoreBackup(backupPath);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup restored successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to restore backup: $e')),
          );
        }
      }
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, WidgetRef ref, BackupMetadata backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup'),
        content: Text(
          'Are you sure you want to delete the backup from ${_formatDate(backup.createdAt)}? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(backupNotifierProvider.notifier).deleteBackup(backup.id);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete backup: $e')),
          );
        }
      }
    }
  }
}
