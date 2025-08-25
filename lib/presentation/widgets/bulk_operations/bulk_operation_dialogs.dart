import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/phosphor_icons.dart';
import '../../../core/theme/typography_constants.dart';
import '../../../core/design_system/design_tokens.dart';
import '../standardized_text.dart';
import '../../../domain/entities/task_model.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/models/enums.dart';
import '../../../services/bulk_operations/bulk_operation_service.dart';
import '../../../services/bulk_operations/task_selection_manager.dart';
import '../glassmorphism_container.dart';
import 'bulk_action_toolbar.dart';

/// Progress dialog for bulk operations with real-time updates
/// 
/// This dialog shows progress, allows cancellation, and provides
/// detailed feedback during long-running bulk operations.
class BulkOperationProgressDialog extends ConsumerStatefulWidget {
  final String operationId;
  final String title;
  final String description;
  final bool allowCancel;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;
  
  const BulkOperationProgressDialog({
    super.key,
    required this.operationId,
    required this.title,
    required this.description,
    this.allowCancel = true,
    this.onComplete,
    this.onCancel,
  });

  @override
  ConsumerState<BulkOperationProgressDialog> createState() =>
      _BulkOperationProgressDialogState();
}

class _BulkOperationProgressDialogState
    extends ConsumerState<BulkOperationProgressDialog>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  
  BulkOperationProgress? _currentProgress;
  bool _isCompleted = false;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));
    
    _listenToProgress();
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }
  
  void _listenToProgress() {
    // Listen to progress stream from bulk operation service
    final bulkService = ref.read(bulkOperationServiceProvider);
    final progressStream = bulkService.getProgressStream(widget.operationId);
    
    progressStream?.listen(
      (progress) {
        if (mounted) {
          setState(() {
            _currentProgress = progress;
          });
          
          // Update progress animation
          _progressController.animateTo(progress.progressPercentage);
          
          // Check if completed
          if (progress.isCompleted && !_isCompleted) {
            _isCompleted = true;
            _onOperationComplete();
          }
        }
      },
      onError: (error) {
        if (mounted) {
          _onOperationError(error);
        }
      },
    );
  }
  
  void _onOperationComplete() {
    _pulseController.stop();
    HapticFeedback.mediumImpact();
    
    // Show completion for a moment, then close
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        widget.onComplete?.call();
        Navigator.of(context).pop();
      }
    });
  }
  
  void _onOperationError(dynamic error) {
    _pulseController.stop();
    HapticFeedback.heavyImpact();
    
    // Show error state
    setState(() {
      _currentProgress = _currentProgress?.copyWith(
        isCompleted: true,
        errors: {'operation_error': error.toString()},
      );
    });
  }
  
  void _cancelOperation() {
    final bulkService = ref.read(bulkOperationServiceProvider);
    bulkService.cancelOperation(widget.operationId);
    
    HapticFeedback.mediumImpact();
    widget.onCancel?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        padding: const EdgeInsets.all(SpacingTokens.lg),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme),
            const SizedBox(height: SpacingTokens.lg),
            _buildProgressSection(theme),
            const SizedBox(height: SpacingTokens.lg),
            _buildDetailsSection(theme),
            if (!_isCompleted && widget.allowCancel) ...[
              const SizedBox(height: SpacingTokens.lg),
              _buildCancelButton(theme),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        _buildOperationIcon(theme),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: SpacingTokens.xs),
              Text(
                widget.description,
                style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildOperationIcon(ThemeData theme) {
    final progress = _currentProgress;
    
    if (progress?.isCompleted == true && !progress!.hasErrors) {
      // Success state
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(TypographyConstants.radiusXXLarge), // 24.0 - Fixed border radius hierarchy
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          PhosphorIconConstants.allIcons['check-circle']!,
          color: theme.colorScheme.primary,
          size: 24,
        ),
      );
    }
    
    if (progress?.hasErrors == true) {
      // Error state
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(TypographyConstants.radiusXXLarge), // 24.0 - Fixed border radius hierarchy
          border: Border.all(
            color: theme.colorScheme.error.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          PhosphorIconConstants.allIcons['warning']!,
          color: theme.colorScheme.error,
          size: 24,
        ),
      );
    }
    
    // Progress state
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusXXLarge), // 24.0 - Fixed border radius hierarchy
              border: Border.all(
                color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              PhosphorIconConstants.allIcons['gear']!,
              color: theme.colorScheme.secondary,
              size: 24,
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildProgressSection(ThemeData theme) {
    final progress = _currentProgress;
    
    return Column(
      children: [
        // Progress bar
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return _buildProgressBar(theme, _progressAnimation.value);
          },
        ),
        
        const SizedBox(height: SpacingTokens.md),
        
        // Progress text
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              progress != null
                  ? '${progress.processedTasks}/${progress.totalTasks} tasks'
                  : 'Preparing...',
              style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              progress != null && progress.totalTasks > 0
                  ? '${(progress.progressPercentage * 100).toInt()}%'
                  : '0%',
              style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildProgressBar(ThemeData theme, double animatedProgress) {
    final progress = _currentProgress;
    final targetProgress = progress?.progressPercentage ?? 0.0;
    
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall), // 2.0 - Fixed border radius hierarchy (was 4px)
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall), // 2.0 - Fixed border radius hierarchy (was 4px)
        child: Stack(
          children: [
            // Background progress
            LinearProgressIndicator(
              value: targetProgress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            // Animated progress
            LinearProgressIndicator(
              value: animatedProgress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailsSection(ThemeData theme) {
    final progress = _currentProgress;
    
    if (progress == null) {
      return const SizedBox.shrink();
    }
    
    return GlassmorphismContainer(
      level: GlassLevel.whisper,
      padding: const EdgeInsets.all(SpacingTokens.md),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: Column(
        children: [
          // Stats row
          Row(
            children: [
              _buildStatItem(
                theme,
                'Success',
                '${progress.successfulTasks}',
                theme.colorScheme.primary,
                PhosphorIconConstants.allIcons['check']!,
              ),
              const SizedBox(width: SpacingTokens.md),
              _buildStatItem(
                theme,
                'Failed',
                '${progress.failedTasks}',
                theme.colorScheme.error,
                PhosphorIconConstants.allIcons['x']!,
              ),
              const Spacer(),
              _buildTimeInfo(theme, progress),
            ],
          ),
          
          // Errors section
          if (progress.hasErrors) ...[
            const SizedBox(height: SpacingTokens.md),
            _buildErrorSection(theme, progress),
          ],
        ],
      ),
    );
  }
  
  Widget _buildStatItem(
    ThemeData theme,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: SpacingTokens.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              label,
              style: StandardizedTextStyle.labelSmall.toTextStyle(context).copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTimeInfo(ThemeData theme, BulkOperationProgress progress) {
    final duration = progress.duration;
    final estimated = progress.estimatedTimeRemaining;
    
    String timeText;
    if (progress.isCompleted) {
      timeText = _formatDuration(duration);
    } else if (estimated != null) {
      timeText = '~${_formatDuration(estimated)} left';
    } else {
      timeText = _formatDuration(duration);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Icon(
              PhosphorIconConstants.allIcons['timer']!,
              size: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              timeText,
              style: StandardizedTextStyle.labelSmall.toTextStyle(context).copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildErrorSection(ThemeData theme, BulkOperationProgress progress) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconConstants.allIcons['warning']!,
                size: 16,
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: SpacingTokens.xs),
              Text(
                'Errors (${progress.errors.length})',
                style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          ...progress.errors.entries.take(3).map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${entry.value}',
                style: StandardizedTextStyle.labelSmall.toTextStyle(context).copyWith(
                  color: theme.colorScheme.error.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
          if (progress.errors.length > 3)
            Text(
              '... and ${progress.errors.length - 3} more',
              style: StandardizedTextStyle.labelSmall.toTextStyle(context).copyWith(
                color: theme.colorScheme.error.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildCancelButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: GlassButton(
        onPressed: _cancelOperation,
        type: ButtonType.secondary,
        color: theme.colorScheme.error,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIconConstants.allIcons['x']!,
              size: 16,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: SpacingTokens.xs),
            Text(
              'Cancel Operation',
              style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}

/// Confirmation dialog for bulk delete operations
class BulkDeleteConfirmationDialog extends StatelessWidget {
  final int taskCount;
  final List<TaskModel> tasks;
  
  const BulkDeleteConfirmationDialog({
    super.key,
    required this.taskCount,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusXXLarge), // 24.0 - Fixed border radius hierarchy
                    border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    PhosphorIconConstants.allIcons['trash']!,
                    color: theme.colorScheme.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delete $taskCount Tasks',
                        style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        'This action cannot be undone permanently.',
                        style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: SpacingTokens.lg),
            
            // Task list preview
            if (tasks.length <= 5)
              _buildTaskList(theme)
            else
              _buildTaskSummary(theme),
            
            const SizedBox(height: SpacingTokens.lg),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    type: ButtonType.secondary,
                    child: Text(
                      'Cancel',
                      style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: GlassButton(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      Navigator.of(context).pop(true);
                    },
                    type: ButtonType.primary,
                    color: theme.colorScheme.error,
                    child: Text(
                      'Delete',
                      style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTaskList(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: SingleChildScrollView(
        child: Column(
          children: tasks.map((task) {
            return Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconConstants.allIcons['dot']!,
                    size: 8,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Expanded(
                    child: StandardizedText(
                      task.title,
                      style: StandardizedTextStyle.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildTaskSummary(ThemeData theme) {
    final statusGroups = <TaskStatus, int>{};
    for (final task in tasks) {
      statusGroups[task.status] = (statusGroups[task.status] ?? 0) + 1;
    }
    
    return GlassmorphismContainer(
      level: GlassLevel.whisper,
      padding: const EdgeInsets.all(SpacingTokens.md),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Task Breakdown',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$taskCount total',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          ...statusGroups.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key.name.toUpperCase(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    '${entry.value}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Dialog for bulk status updates
class BulkStatusUpdateDialog extends StatefulWidget {
  final SelectionStatistics currentStatistics;
  final List<TaskModel> selectedTasks;
  
  const BulkStatusUpdateDialog({
    super.key,
    required this.currentStatistics,
    required this.selectedTasks,
  });

  @override
  State<BulkStatusUpdateDialog> createState() => _BulkStatusUpdateDialogState();
}

class _BulkStatusUpdateDialogState extends State<BulkStatusUpdateDialog> {
  TaskStatus? _selectedStatus;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
            Text(
              'Update Status',
              style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: SpacingTokens.md),
            
            Text(
              'Choose new status for ${widget.selectedTasks.length} tasks',
              style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            
            const SizedBox(height: SpacingTokens.lg),
            
            // Status options
            ...TaskStatus.values.map((status) {
              return Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                child: GlassmorphismContainer(
                  level: _selectedStatus == status ? GlassLevel.interactive : GlassLevel.whisper,
                  child: ListTile(
                    leading: Radio<TaskStatus>(
                      value: status,
                      groupValue: _selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                        HapticFeedback.selectionClick();
                      },
                    ),
                    title: Text(
                      status.name.toUpperCase(),
                      style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${widget.currentStatistics.statusBreakdown[status] ?? 0} currently',
                      style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedStatus = status;
                      });
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),
              );
            }),
            
            const SizedBox(height: SpacingTokens.lg),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    onPressed: () => Navigator.of(context).pop(),
                    type: ButtonType.secondary,
                    child: Text(
                      'Cancel',
                      style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: GlassButton(
                    onPressed: _selectedStatus != null
                        ? () => Navigator.of(context).pop(_selectedStatus)
                        : null,
                    type: ButtonType.primary,
                    child: Text(
                      'Update',
                      style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for bulk priority updates
class BulkPriorityUpdateDialog extends StatefulWidget {
  final SelectionStatistics currentStatistics;
  final List<TaskModel> selectedTasks;
  
  const BulkPriorityUpdateDialog({
    super.key,
    required this.currentStatistics,
    required this.selectedTasks,
  });

  @override
  State<BulkPriorityUpdateDialog> createState() => _BulkPriorityUpdateDialogState();
}

class _BulkPriorityUpdateDialogState extends State<BulkPriorityUpdateDialog> {
  TaskPriority? _selectedPriority;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
            Text(
              'Update Priority',
              style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: SpacingTokens.md),
            
            Text(
              'Choose new priority for ${widget.selectedTasks.length} tasks',
              style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            
            const SizedBox(height: SpacingTokens.lg),
            
            // Priority options
            ...TaskPriority.values.map((priority) {
              final color = _getPriorityColor(priority, theme);
              return Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                child: GlassmorphismContainer(
                  level: _selectedPriority == priority ? GlassLevel.interactive : GlassLevel.whisper,
                  child: ListTile(
                    leading: Radio<TaskPriority>(
                      value: priority,
                      groupValue: _selectedPriority,
                      onChanged: (value) {
                        setState(() {
                          _selectedPriority = value;
                        });
                        HapticFeedback.selectionClick();
                      },
                    ),
                    title: Row(
                      children: [
                        Icon(
                          PhosphorIconConstants.allIcons['target']!,
                          size: 16,
                          color: color,
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Text(
                          priority.name.toUpperCase(),
                          style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${widget.currentStatistics.priorityBreakdown[priority] ?? 0} currently',
                      style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedPriority = priority;
                      });
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),
              );
            }),
            
            const SizedBox(height: SpacingTokens.lg),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    onPressed: () => Navigator.of(context).pop(),
                    type: ButtonType.secondary,
                    child: Text(
                      'Cancel',
                      style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: GlassButton(
                    onPressed: _selectedPriority != null
                        ? () => Navigator.of(context).pop(_selectedPriority)
                        : null,
                    type: ButtonType.primary,
                    child: Text(
                      'Update',
                      style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getPriorityColor(TaskPriority priority, ThemeData theme) {
    switch (priority) {
      case TaskPriority.low:
        return theme.colorScheme.tertiary;
      case TaskPriority.medium:
        return theme.colorScheme.primary;
      case TaskPriority.high:
        return theme.colorScheme.secondary;
      case TaskPriority.urgent:
        return theme.colorScheme.error;
    }
  }
}

/// Dialog for bulk project moves
class BulkProjectMoveDialog extends StatefulWidget {
  final SelectionStatistics currentStatistics;
  final List<TaskModel> selectedTasks;
  final List<Project> availableProjects;
  
  const BulkProjectMoveDialog({
    super.key,
    required this.currentStatistics,
    required this.selectedTasks,
    required this.availableProjects,
  });

  @override
  State<BulkProjectMoveDialog> createState() => _BulkProjectMoveDialogState();
}

class _BulkProjectMoveDialogState extends State<BulkProjectMoveDialog> {
  String? _selectedProjectId;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
            Text(
              'Move to Project',
              style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: SpacingTokens.md),
            
            Text(
              'Choose project for ${widget.selectedTasks.length} tasks',
              style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            
            const SizedBox(height: SpacingTokens.lg),
            
            // No project option
            Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
              child: GlassmorphismContainer(
                level: _selectedProjectId == null ? GlassLevel.interactive : GlassLevel.whisper,
                child: ListTile(
                  leading: Radio<String?>(
                    value: null,
                    groupValue: _selectedProjectId,
                    onChanged: (value) {
                      setState(() {
                        _selectedProjectId = value;
                      });
                      HapticFeedback.selectionClick();
                    },
                  ),
                  title: Text(
                    'No Project',
                    style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedProjectId = null;
                    });
                    HapticFeedback.selectionClick();
                  },
                ),
              ),
            ),
            
            // Project options
            ...widget.availableProjects.map((project) {
              return Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                child: GlassmorphismContainer(
                  level: _selectedProjectId == project.id ? GlassLevel.interactive : GlassLevel.whisper,
                  child: ListTile(
                    leading: Radio<String>(
                      value: project.id,
                      groupValue: _selectedProjectId,
                      onChanged: (value) {
                        setState(() {
                          _selectedProjectId = value;
                        });
                        HapticFeedback.selectionClick();
                      },
                    ),
                    title: Text(
                      project.name,
                      style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${project.taskCount} tasks',
                      style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    trailing: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Color(int.parse('0xFF${project.color.substring(1)}')),
                        borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall), // 6.0 - Fixed border radius hierarchy (was 10px)
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedProjectId = project.id;
                      });
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),
              );
            }),
            
            const SizedBox(height: SpacingTokens.lg),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    onPressed: () => Navigator.of(context).pop(),
                    type: ButtonType.secondary,
                    child: Text(
                      'Cancel',
                      style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: GlassButton(
                    onPressed: () => Navigator.of(context).pop(_selectedProjectId),
                    type: ButtonType.primary,
                    child: Text(
                      'Move',
                      style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for bulk tag operations
class BulkTagsDialog extends StatefulWidget {
  final SelectionStatistics currentStatistics;
  final List<TaskModel> selectedTasks;
  
  const BulkTagsDialog({
    super.key,
    required this.currentStatistics,
    required this.selectedTasks,
  });

  @override
  State<BulkTagsDialog> createState() => _BulkTagsDialogState();
}

class _BulkTagsDialogState extends State<BulkTagsDialog> {
  final _textController = TextEditingController();
  final Set<String> _tagsToAdd = {};
  final Set<String> _tagsToRemove = {};
  bool _isAddMode = true;
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allTags = _getAllTags();
    
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
            Text(
              'Manage Tags',
              style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: SpacingTokens.md),
            
            Text(
              'Add or remove tags for ${widget.selectedTasks.length} tasks',
              style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            
            const SizedBox(height: SpacingTokens.lg),
            
            // Add/Remove toggle
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    onPressed: () {
                      setState(() {
                        _isAddMode = true;
                        _tagsToRemove.clear();
                      });
                    },
                    type: _isAddMode ? ButtonType.primary : ButtonType.secondary,
                    child: const Text('Add Tags'),
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: GlassButton(
                    onPressed: () {
                      setState(() {
                        _isAddMode = false;
                        _tagsToAdd.clear();
                      });
                    },
                    type: !_isAddMode ? ButtonType.primary : ButtonType.secondary,
                    child: const Text('Remove Tags'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: SpacingTokens.lg),
            
            // Tag input
            if (_isAddMode) ...[
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Enter new tag...',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: _addTag,
              ),
              const SizedBox(height: SpacingTokens.md),
            ],
            
            // Tags list
            if (allTags.isNotEmpty) ...[
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: SpacingTokens.xs,
                    runSpacing: SpacingTokens.xs,
                    children: allTags.map((tag) {
                      final isSelected = _isAddMode
                          ? _tagsToAdd.contains(tag)
                          : _tagsToRemove.contains(tag);
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_isAddMode) {
                              if (_tagsToAdd.contains(tag)) {
                                _tagsToAdd.remove(tag);
                              } else {
                                _tagsToAdd.add(tag);
                              }
                            } else {
                              if (_tagsToRemove.contains(tag)) {
                                _tagsToRemove.remove(tag);
                              } else {
                                _tagsToRemove.add(tag);
                              }
                            }
                          });
                          HapticFeedback.selectionClick();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SpacingTokens.sm,
                            vertical: SpacingTokens.xs,
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
                            tag,
                            style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),
            ],
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GlassButton(
                    onPressed: () => Navigator.of(context).pop(),
                    type: ButtonType.secondary,
                    child: Text(
                      'Cancel',
                      style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: GlassButton(
                    onPressed: (_tagsToAdd.isNotEmpty || _tagsToRemove.isNotEmpty)
                        ? () => Navigator.of(context).pop(BulkTagsResult(
                              tagsToAdd: _tagsToAdd.toList(),
                              tagsToRemove: _tagsToRemove.toList(),
                            ))
                        : null,
                    type: ButtonType.primary,
                    child: Text(
                      'Apply',
                      style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty) {
      setState(() {
        _tagsToAdd.add(trimmedTag);
        _textController.clear();
      });
      HapticFeedback.selectionClick();
    }
  }
  
  Set<String> _getAllTags() {
    final allTags = <String>{};
    for (final task in widget.selectedTasks) {
      allTags.addAll(task.tags);
    }
    return allTags;
  }
}

/// Dialog for additional bulk actions
class BulkMoreActionsDialog extends StatelessWidget {
  final SelectionStatistics currentStatistics;
  final List<TaskModel> selectedTasks;
  final Function(String action, dynamic data) onActionSelected;
  
  const BulkMoreActionsDialog({
    super.key,
    required this.currentStatistics,
    required this.selectedTasks,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
            Text(
              'More Actions',
              style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: SpacingTokens.lg),
            
            // Action options
            _buildActionTile(
              context,
              theme,
              'Duplicate Tasks',
              'Create copies of selected tasks',
              PhosphorIconConstants.allIcons['copy']!,
              () => onActionSelected('duplicate', null),
            ),
            
            _buildActionTile(
              context,
              theme,
              'Reschedule Tasks',
              'Set new due dates',
              PhosphorIconConstants.allIcons['calendar']!,
              () => onActionSelected('reschedule', null),
            ),
            
            _buildActionTile(
              context,
              theme,
              'Pin/Unpin Tasks',
              'Toggle pin status',
              PhosphorIconConstants.allIcons['pushpin']!,
              () => onActionSelected('pin', null),
            ),
            
            _buildActionTile(
              context,
              theme,
              'Export Tasks',
              'Export to file',
              PhosphorIconConstants.allIcons['download']!,
              () => onActionSelected('export', null),
            ),
            
            const SizedBox(height: SpacingTokens.lg),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                onPressed: () => Navigator.of(context).pop(),
                type: ButtonType.secondary,
                child: Text(
                  'Close',
                  style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionTile(
    BuildContext context,
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: GlassmorphismContainer(
        level: GlassLevel.whisper,
        child: ListTile(
          leading: Icon(
            icon,
            color: theme.colorScheme.primary,
          ),
          title: Text(
            title,
            style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          onTap: () {
            Navigator.of(context).pop();
            onTap();
          },
        ),
      ),
    );
  }
}

