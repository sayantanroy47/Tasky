import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/phosphor_icons.dart';
import '../../../core/theme/typography_constants.dart';
import '../../../core/design_system/design_tokens.dart';
import '../../../services/bulk_operations/bulk_operation_history.dart';
import '../../../services/bulk_operations/bulk_operation_service.dart';
import '../glassmorphism_container.dart';
import '../../providers/bulk_operation_providers.dart';

/// Widget for displaying and managing bulk operation history with undo functionality
/// 
/// This widget provides a comprehensive interface for viewing operation history,
/// undoing operations, and managing operation templates with beautiful glassmorphism design.
class OperationHistoryWidget extends ConsumerStatefulWidget {
  final bool showAsDialog;
  final bool enableUndo;
  final Function(BulkOperationRecord)? onUndoOperation;
  final VoidCallback? onClearHistory;
  
  const OperationHistoryWidget({
    super.key,
    this.showAsDialog = false,
    this.enableUndo = true,
    this.onUndoOperation,
    this.onClearHistory,
  });

  @override
  ConsumerState<OperationHistoryWidget> createState() => _OperationHistoryWidgetState();
}

class _OperationHistoryWidgetState extends ConsumerState<OperationHistoryWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  final ScrollController _scrollController = ScrollController();
  String _filterType = 'all';
  
  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _slideController.forward();
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showAsDialog) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: _buildHistoryContent(),
      );
    } else {
      return SlideTransition(
        position: _slideAnimation,
        child: _buildHistoryContent(),
      );
    }
  }
  
  Widget _buildHistoryContent() {
    final theme = Theme.of(context);
    
    return GlassmorphismContainer(
      level: GlassLevel.floating,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(theme),
          const SizedBox(height: SpacingTokens.lg),
          _buildFilterTabs(theme),
          const SizedBox(height: SpacingTokens.md),
          _buildHistoryList(theme),
          const SizedBox(height: SpacingTokens.lg),
          _buildActionButtons(theme),
        ],
      ),
    );
  }
  
  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Icon(
          PhosphorIconConstants.allIcons['clock-clockwise']!,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Operation History',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final metrics = ref.watch(bulkOperationMetricsProvider);
                  return metrics.when(
                    data: (metrics) => Text(
                      '${metrics.totalOperations} operations, ${(metrics.successRate * 100).toInt()}% success rate',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
              ),
            ],
          ),
        ),
        if (widget.showAsDialog)
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              PhosphorIconConstants.allIcons['x']!,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
      ],
    );
  }
  
  Widget _buildFilterTabs(ThemeData theme) {
    const filters = [
      ('all', 'All'),
      ('undoable', 'Undoable'),
      ('delete', 'Delete'),
      ('update', 'Update'),
      ('move', 'Move'),
    ];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _filterType == filter.$1;
          return Padding(
            padding: const EdgeInsets.only(right: SpacingTokens.sm),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _filterType = filter.$1;
                });
                HapticFeedback.selectionClick();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.2)
                      : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  filter.$2,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildHistoryList(ThemeData theme) {
    return Consumer(
      builder: (context, ref, child) {
        final historyAsyncValue = ref.watch(operationHistoryProvider);
        
        return historyAsyncValue.when(
          data: (history) {
            final filteredHistory = _filterHistory(history);
            
            if (filteredHistory.isEmpty) {
              return _buildEmptyState(theme);
            }
            
            return SizedBox(
              height: 300,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: filteredHistory.length,
                itemBuilder: (context, index) {
                  final record = filteredHistory[index];
                  return _buildHistoryItem(theme, record);
                },
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => _buildErrorState(theme, error),
        );
      },
    );
  }
  
  Widget _buildEmptyState(ThemeData theme) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconConstants.allIcons['archive']!,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(
              'No operations found',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Bulk operations will appear here',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorState(ThemeData theme, Object error) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconConstants.allIcons['warning']!,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(
              'Error loading history',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHistoryItem(ThemeData theme, BulkOperationRecord record) {
    final canUndo = record.canUndo && widget.enableUndo;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: GlassmorphismContainer(
        level: GlassLevel.whisper,
        padding: const EdgeInsets.all(SpacingTokens.md),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        child: Row(
          children: [
            // Operation icon
            _buildOperationIcon(theme, record),
            const SizedBox(width: SpacingTokens.md),
            
            // Operation details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          record.displayTitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildStatusBadge(theme, record),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    record.displayDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  _buildOperationStats(theme, record),
                ],
              ),
            ),
            
            // Actions
            if (canUndo) ...[
              const SizedBox(width: SpacingTokens.md),
              _buildUndoButton(theme, record),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildOperationIcon(ThemeData theme, BulkOperationRecord record) {
    IconData icon;
    Color color;
    
    switch (record.type) {
      case BulkOperationType.delete:
        icon = PhosphorIconConstants.allIcons['trash']!;
        color = theme.colorScheme.error;
        break;
      case BulkOperationType.updateStatus:
        icon = PhosphorIconConstants.allIcons['check-circle']!;
        color = theme.colorScheme.primary;
        break;
      case BulkOperationType.updatePriority:
        icon = PhosphorIconConstants.allIcons['target']!;
        color = theme.colorScheme.secondary;
        break;
      case BulkOperationType.moveToProject:
        icon = PhosphorIconConstants.allIcons['folder']!;
        color = theme.colorScheme.tertiary;
        break;
      case BulkOperationType.addTags:
      case BulkOperationType.removeTags:
        icon = PhosphorIconConstants.allIcons['tag']!;
        color = theme.colorScheme.primary;
        break;
      case BulkOperationType.reschedule:
        icon = PhosphorIconConstants.allIcons['calendar']!;
        color = theme.colorScheme.secondary;
        break;
      case BulkOperationType.duplicate:
        icon = PhosphorIconConstants.allIcons['copy']!;
        color = theme.colorScheme.tertiary;
        break;
      case BulkOperationType.restore:
        icon = PhosphorIconConstants.allIcons['arrow-counter-clockwise']!;
        color = theme.colorScheme.primary;
        break;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }
  
  Widget _buildStatusBadge(ThemeData theme, BulkOperationRecord record) {
    Color color;
    String text;
    
    if (record.isUndone) {
      color = theme.colorScheme.onSurface.withValues(alpha: 0.6);
      text = 'UNDONE';
    } else if (record.failedTasks > 0) {
      color = theme.colorScheme.error;
      text = 'PARTIAL';
    } else {
      color = theme.colorScheme.primary;
      text = 'SUCCESS';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildOperationStats(ThemeData theme, BulkOperationRecord record) {
    return Row(
      children: [
        _buildStatChip(
          theme,
          '${record.successfulTasks} success',
          theme.colorScheme.primary,
        ),
        if (record.failedTasks > 0) ...[
          const SizedBox(width: SpacingTokens.xs),
          _buildStatChip(
            theme,
            '${record.failedTasks} failed',
            theme.colorScheme.error,
          ),
        ],
        const SizedBox(width: SpacingTokens.xs),
        _buildStatChip(
          theme,
          _formatDuration(record.executionTime),
          theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const Spacer(),
        Text(
          DateFormat('HH:mm').format(record.timestamp),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatChip(ThemeData theme, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  Widget _buildUndoButton(ThemeData theme, BulkOperationRecord record) {
    return GlassButton(
      onPressed: () => _undoOperation(record),
      type: ButtonType.secondary,
      padding: const EdgeInsets.all(SpacingTokens.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIconConstants.allIcons['arrow-counter-clockwise']!,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            'Undo',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              // Using labelSmall size from theme
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: GlassButton(
            onPressed: _showClearHistoryConfirmation,
            type: ButtonType.secondary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIconConstants.allIcons['trash']!,
                  size: 16,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: SpacingTokens.xs),
                Text(
                  'Clear History',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: GlassButton(
            onPressed: _showOperationTemplates,
            type: ButtonType.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIconConstants.allIcons['bookmark']!,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: SpacingTokens.xs),
                Text(
                  'Templates',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  List<BulkOperationRecord> _filterHistory(List<BulkOperationRecord> history) {
    switch (_filterType) {
      case 'undoable':
        return history.where((record) => record.canUndo).toList();
      case 'delete':
        return history.where((record) => record.type == BulkOperationType.delete).toList();
      case 'update':
        return history
            .where((record) =>
                record.type == BulkOperationType.updateStatus ||
                record.type == BulkOperationType.updatePriority)
            .toList();
      case 'move':
        return history.where((record) => record.type == BulkOperationType.moveToProject).toList();
      default:
        return history;
    }
  }
  
  void _undoOperation(BulkOperationRecord record) async {
    try {
      final bulkService = ref.read(bulkOperationServiceProvider);
      await bulkService.undoOperation(record.id);
      
      HapticFeedback.mediumImpact();
      widget.onUndoOperation?.call(record);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Operation undone: ${record.displayTitle}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to undo operation: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  
  void _showClearHistoryConfirmation() async {
    final theme = Theme.of(context);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassmorphismContainer(
          level: GlassLevel.floating,
          padding: const EdgeInsets.all(SpacingTokens.lg),
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIconConstants.allIcons['warning']!,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: SpacingTokens.md),
              Text(
                'Clear Operation History',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'This will permanently delete all operation history. You will no longer be able to undo any operations.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.lg),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      type: ButtonType.secondary,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.md),
                  Expanded(
                    child: GlassButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      type: ButtonType.primary,
                      color: theme.colorScheme.error,
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    
    if (result == true) {
      try {
        final bulkService = ref.read(bulkOperationServiceProvider);
        await bulkService.clearHistory();
        
        HapticFeedback.mediumImpact();
        widget.onClearHistory?.call();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Operation history cleared')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear history: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
  
  void _showOperationTemplates() {
    showDialog(
      context: context,
      builder: (context) => const BulkOperationTemplatesDialog(),
    );
  }
  
  String _formatDuration(Duration duration) {
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}

/// Dialog for managing bulk operation templates
class BulkOperationTemplatesDialog extends ConsumerWidget {
  const BulkOperationTemplatesDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final templates = ref.watch(bulkOperationTemplatesProvider);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        padding: const EdgeInsets.all(SpacingTokens.lg),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  PhosphorIconConstants.allIcons['bookmark']!,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: Text(
                    'Operation Templates',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    PhosphorIconConstants.allIcons['x']!,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: SpacingTokens.lg),
            
            // Templates list
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];
                  return _buildTemplateItem(context, ref, theme, template);
                },
              ),
            ),
            
            const SizedBox(height: SpacingTokens.lg),
            
            // Action buttons
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                onPressed: () => Navigator.of(context).pop(),
                type: ButtonType.secondary,
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTemplateItem(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    BulkOperationTemplate template,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: GlassmorphismContainer(
        level: GlassLevel.whisper,
        padding: const EdgeInsets.all(SpacingTokens.md),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        child: Row(
          children: [
            Icon(
              PhosphorIconConstants.allIcons['bookmark-simple']!,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    template.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    '${template.actions.length} actions',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      // Using labelSmall size from theme
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _executeTemplate(context, ref, template),
              icon: Icon(
                PhosphorIconConstants.allIcons['play']!,
                color: theme.colorScheme.primary,
              ),
              tooltip: 'Execute template',
            ),
          ],
        ),
      ),
    );
  }
  
  void _executeTemplate(
    BuildContext context,
    WidgetRef ref,
    BulkOperationTemplate template,
  ) async {
    try {
      final executor = ref.read(bulkOperationTemplateExecutorProvider);
      final results = await executor.executeTemplate(template);
      
      final totalSuccess = results.fold<int>(0, (sum, r) => sum + r.successfulTasks);
      final totalFailed = results.fold<int>(0, (sum, r) => sum + r.failedTasks);
      
      HapticFeedback.mediumImpact();
      
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Template executed: $totalSuccess successful, $totalFailed failed',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to execute template: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

/// Floating action button for quick access to operation history
class OperationHistoryFab extends ConsumerWidget {
  final VoidCallback? onPressed;
  
  const OperationHistoryFab({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final undoableOperations = ref.watch(undoableOperationsProvider);
    
    return undoableOperations.when(
      data: (operations) {
        if (operations.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Stack(
          children: [
            FloatingActionButton(
              onPressed: onPressed ?? () => _showHistoryDialog(context),
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                PhosphorIconConstants.allIcons['clock-clockwise']!,
                color: Colors.white,
              ),
            ),
            if (operations.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    '${operations.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      // Using labelSmall size from theme
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
  
  void _showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const OperationHistoryWidget(
        showAsDialog: true,
      ),
    );
  }
}

/// Import missing enums and classes
