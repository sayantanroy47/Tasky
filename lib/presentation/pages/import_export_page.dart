import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/import_export_service.dart';
import '../../core/providers/core_providers.dart';
import '../providers/task_providers.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/theme_background_widget.dart';
import '../../core/theme/typography_constants.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Import/Export page for managing task data
class ImportExportPage extends ConsumerWidget {
  const ImportExportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: const StandardizedAppBar(title: 'Import & Export'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: kToolbarHeight + 8,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          child: Column(
            children: [
              // Export section
              _buildExportSection(context, ref, theme),
              
              const SizedBox(height: 24),
              
              // Import section
              _buildImportSection(context, ref, theme),
              
              const SizedBox(height: 24),
              
              // Info section
              _buildInfoSection(context, theme),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportSection(BuildContext context, WidgetRef ref, ThemeData theme) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  ),
                  child: Icon(
                    PhosphorIcons.upload(),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export Tasks',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Download your tasks and data',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Export options
            Row(
              children: [
                Expanded(
                  child: _buildExportButton(
                    context,
                    ref,
                    theme,
                    'JSON Format',
                    'Structured data format',
                    PhosphorIcons.code(),
                    ExportFormat.json,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildExportButton(
                    context,
                    ref,
                    theme,
                    'CSV Format',
                    'Spreadsheet compatible',
                    PhosphorIcons.table(),
                    ExportFormat.csv,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    ExportFormat format,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _handleExport(context, ref, format),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImportSection(BuildContext context, WidgetRef ref, ThemeData theme) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.secondary,
                        theme.colorScheme.tertiary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  ),
                  child: Icon(
                    PhosphorIcons.download(),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import Tasks',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Upload tasks from file',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Import button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _handleImport(context, ref),
                icon: Icon(PhosphorIcons.upload()),
                label: const Text('Select File to Import'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Supported formats
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.info(),
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Supported formats: JSON (.json), CSV (.csv)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  PhosphorIcons.question(),
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Important Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoItem(
              theme,
              'Export',
              'Creates a backup of all your tasks with complete data including subtasks, tags, and metadata.',
            ),
            
            const SizedBox(height: 12),
            
            _buildInfoItem(
              theme,
              'Import',
              'Imports tasks from supported file formats. Duplicate tasks will be created with new IDs.',
            ),
            
            const SizedBox(height: 12),
            
            _buildInfoItem(
              theme,
              'Privacy',
              'All import/export operations happen locally on your device. No data is sent to external servers.',
            ),
            
            const SizedBox(height: 12),
            
            _buildInfoItem(
              theme,
              'File Storage',
              'Exported files are saved to your device\'s Documents folder and can be shared or moved as needed.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(ThemeData theme, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleExport(BuildContext context, WidgetRef ref, ExportFormat format) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _LoadingDialog(message: 'Exporting tasks...'),
      );

      final taskRepository = ref.read(taskRepositoryProvider);
      final importExportService = ImportExportService(taskRepository);
      
      final filePath = await importExportService.exportTasks(format);
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        
        if (filePath != null) {
          _showSuccessDialog(
            context,
            'Export Successful',
            'Tasks exported successfully to:\n$filePath',
          );
        } else {
          _showErrorDialog(context, 'Export failed: File could not be saved');
        }
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        _showErrorDialog(context, 'Export failed: $e');
      }
    }
  }

  void _handleImport(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _LoadingDialog(message: 'Importing tasks...'),
      );

      final taskRepository = ref.read(taskRepositoryProvider);
      final importExportService = ImportExportService(taskRepository);
      
      final result = await importExportService.importTasksFromFile();
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Show result dialog
        _showImportResultDialog(context, result);
        
        // Refresh tasks if any were imported successfully
        if (result.isSuccessful) {
          ref.invalidate(tasksProvider);
        }
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        _showErrorDialog(context, 'Import failed: $e');
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              PhosphorIcons.checkCircle(),
              color: Colors.green,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              PhosphorIcons.warningCircle(),
              color: Colors.red,
              size: 28,
            ),
            SizedBox(width: 12),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showImportResultDialog(BuildContext context, ImportResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.isSuccessful ? PhosphorIcons.checkCircle() : PhosphorIcons.warning(),
              color: result.isSuccessful ? Colors.green : Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Import Complete'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total tasks in file: ${result.totalTasks}'),
              Text('Successfully imported: ${result.successfulImports}'),
              if (result.failedImports > 0)
                Text('Failed imports: ${result.failedImports}'),
              
              if (result.hasErrors) ...[
                const SizedBox(height: 16),
                const Text(
                  'Errors:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...result.errors.take(5).map((error) => 
                  Text('• $error', style: const TextStyle(fontSize: TypographyConstants.bodySmall))
                ),
                if (result.errors.length > 5)
                  Text('... and ${result.errors.length - 5} more errors'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Loading dialog widget
class _LoadingDialog extends StatelessWidget {
  final String message;

  const _LoadingDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
}

