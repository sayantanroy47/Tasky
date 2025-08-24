import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/phosphor_icons.dart';
import '../../../core/theme/typography_constants.dart';
import '../../../core/design_system/design_tokens.dart';
import '../../../domain/entities/task_model.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/models/enums.dart';
import '../../../services/bulk_operations/task_selection_manager.dart';
import '../../../services/bulk_operations/bulk_operation_service.dart';
import '../glassmorphism_container.dart';
import 'bulk_operation_dialogs.dart';

/// Glassmorphism-styled toolbar for bulk task operations
/// 
/// This widget provides an elegant floating toolbar that appears when tasks
/// are selected, offering quick access to common bulk operations with
/// beautiful glassmorphism design and smooth animations.
class BulkActionToolbar extends ConsumerStatefulWidget {
  final List<TaskModel> selectedTasks;
  final List<Project> availableProjects;
  final VoidCallback? onClearSelection;
  final Function(BulkOperationResult)? onOperationComplete;
  final bool isFloating;
  final EdgeInsets? padding;
  final BorderRadiusGeometry? borderRadius;
  
  const BulkActionToolbar({
    super.key,
    required this.selectedTasks,
    this.availableProjects = const [],
    this.onClearSelection,
    this.onOperationComplete,
    this.isFloating = true,
    this.padding,
    this.borderRadius,
  });

  @override
  ConsumerState<BulkActionToolbar> createState() => _BulkActionToolbarState();
}

class _BulkActionToolbarState extends ConsumerState<BulkActionToolbar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    
    // Start animations
    _slideController.forward();
    _scaleController.forward();
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(BulkActionToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate when selection changes
    if (oldWidget.selectedTasks.length != widget.selectedTasks.length) {
      _scaleController.reset();
      _scaleController.forward();
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedTasks.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final theme = Theme.of(context);
    final statistics = _getSelectionStatistics();
    
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: AnimatedBuilder(
              animation: _scaleController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: _buildToolbarContent(context, theme, statistics),
                );
              },
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildToolbarContent(
    BuildContext context,
    ThemeData theme,
    SelectionStatistics statistics,
  ) {
    if (widget.isFloating) {
      return _buildFloatingToolbar(context, theme, statistics);
    } else {
      return _buildInlineToolbar(context, theme, statistics);
    }
  }
  
  Widget _buildFloatingToolbar(
    BuildContext context,
    ThemeData theme,
    SelectionStatistics statistics,
  ) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: SafeArea(
        child: GlassmorphismContainer(
          level: GlassLevel.floating,
          padding: widget.padding ?? const EdgeInsets.all(SpacingTokens.md),
          borderRadius: widget.borderRadius ?? 
              BorderRadius.circular(TypographyConstants.radiusStandard),
          child: _buildToolbarActions(context, theme, statistics),
        ),
      ),
    );
  }
  
  Widget _buildInlineToolbar(
    BuildContext context,
    ThemeData theme,
    SelectionStatistics statistics,
  ) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: widget.padding ?? const EdgeInsets.all(SpacingTokens.sm),
      borderRadius: widget.borderRadius ?? 
          BorderRadius.circular(TypographyConstants.radiusStandard),
      child: _buildToolbarActions(context, theme, statistics),
    );
  }
  
  Widget _buildToolbarActions(
    BuildContext context,
    ThemeData theme,
    SelectionStatistics statistics,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Selection info header
        _buildSelectionHeader(context, theme, statistics),
        
        const SizedBox(height: SpacingTokens.sm),
        
        // Action buttons
        _buildActionButtons(context, theme, statistics),
        
        // Suggested actions
        if (statistics.suggestedActions.isNotEmpty) ...[
          const SizedBox(height: SpacingTokens.xs),
          _buildSuggestedActions(context, theme, statistics),
        ],
      ],
    );
  }
  
  Widget _buildSelectionHeader(
    BuildContext context,
    ThemeData theme,
    SelectionStatistics statistics,
  ) {
    return Row(
      children: [
        // Selection count
        GlassmorphismContainer(
          level: GlassLevel.whisper,
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm,
            vertical: SpacingTokens.xs,
          ),
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          child: Text(
            '${statistics.totalSelected} selected',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        
        const SizedBox(width: SpacingTokens.sm),
        
        // Quick stats
        if (statistics.overdueCount > 0) ...[
          _buildQuickStat(
            context,
            theme,
            '${statistics.overdueCount} overdue',
            PhosphorIconConstants.allIcons['clock']!,
            theme.colorScheme.error,
          ),
          const SizedBox(width: SpacingTokens.xs),
        ],
        
        if (statistics.dueTodayCount > 0) ...[
          _buildQuickStat(
            context,
            theme,
            '${statistics.dueTodayCount} today',
            PhosphorIconConstants.allIcons['calendar']!,
            theme.colorScheme.tertiary,
          ),
          const SizedBox(width: SpacingTokens.xs),
        ],
        
        const Spacer(),
        
        // Clear selection
        GlassButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            widget.onClearSelection?.call();
          },
          type: ButtonType.secondary,
          padding: const EdgeInsets.all(SpacingTokens.xs),
          child: Icon(
            PhosphorIconConstants.allIcons['x']!,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickStat(
    BuildContext context,
    ThemeData theme,
    String text,
    IconData icon,
    Color color,
  ) {
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              // Using labelSmall size from theme
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
    SelectionStatistics statistics,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Delete
          _buildActionButton(
            context,
            'Delete',
            PhosphorIconConstants.allIcons['trash']!,
            theme.colorScheme.error,
            () => _showDeleteConfirmation(context),
          ),
          
          const SizedBox(width: SpacingTokens.sm),
          
          // Status
          _buildActionButton(
            context,
            'Status',
            PhosphorIconConstants.allIcons['check-circle']!,
            theme.colorScheme.primary,
            () => _showStatusDialog(context, statistics),
          ),
          
          const SizedBox(width: SpacingTokens.sm),
          
          // Priority
          _buildActionButton(
            context,
            'Priority',
            PhosphorIconConstants.allIcons['target']!,
            theme.colorScheme.secondary,
            () => _showPriorityDialog(context, statistics),
          ),
          
          const SizedBox(width: SpacingTokens.sm),
          
          // Project
          if (widget.availableProjects.isNotEmpty) ...[
            _buildActionButton(
              context,
              'Project',
              PhosphorIconConstants.allIcons['folder']!,
              theme.colorScheme.tertiary,
              () => _showProjectDialog(context, statistics),
            ),
            const SizedBox(width: SpacingTokens.sm),
          ],
          
          // Tags
          _buildActionButton(
            context,
            'Tags',
            PhosphorIconConstants.allIcons['tag']!,
            theme.colorScheme.primary,
            () => _showTagsDialog(context, statistics),
          ),
          
          const SizedBox(width: SpacingTokens.sm),
          
          // More actions
          _buildActionButton(
            context,
            'More',
            PhosphorIconConstants.allIcons['dots-three']!,
            theme.colorScheme.onSurface,
            () => _showMoreActionsDialog(context, statistics),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);
    
    return GlassButton(
      onPressed: onPressed,
      type: ButtonType.secondary,
      color: color,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              // Using labelSmall size from theme
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuggestedActions(
    BuildContext context,
    ThemeData theme,
    SelectionStatistics statistics,
  ) {
    final highPrioritySuggestions = statistics.suggestedActions
        .where((s) => s.priority == BulkActionPriority.high)
        .take(2)
        .toList();
    
    if (highPrioritySuggestions.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
      child: Row(
        children: [
          Icon(
            PhosphorIconConstants.allIcons['lightbulb']!,
            size: 12,
            color: theme.colorScheme.tertiary.withValues(alpha: 0.8),
          ),
          const SizedBox(width: SpacingTokens.xs),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: highPrioritySuggestions.map((suggestion) {
                  return Padding(
                    padding: const EdgeInsets.only(right: SpacingTokens.xs),
                    child: GestureDetector(
                      onTap: () => _executeSuggestedAction(context, suggestion),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                              TypographyConstants.radiusStandard),
                          border: Border.all(
                            color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              suggestion.icon,
                              size: 10,
                              color: theme.colorScheme.tertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              suggestion.title,
                              style: theme.textTheme.bodySmall?.copyWith(
                                // Using labelSmall size from theme
                                color: theme.colorScheme.tertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Dialog handlers
  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => BulkDeleteConfirmationDialog(
        taskCount: widget.selectedTasks.length,
        tasks: widget.selectedTasks,
      ),
    );
    
    if (result == true && mounted) {
      await _executeDelete();
    }
  }
  
  Future<void> _showStatusDialog(
    BuildContext context,
    SelectionStatistics statistics,
  ) async {
    final result = await showDialog<TaskStatus>(
      context: context,
      builder: (context) => BulkStatusUpdateDialog(
        currentStatistics: statistics,
        selectedTasks: widget.selectedTasks,
      ),
    );
    
    if (result != null && mounted) {
      await _executeStatusUpdate(result);
    }
  }
  
  Future<void> _showPriorityDialog(
    BuildContext context,
    SelectionStatistics statistics,
  ) async {
    final result = await showDialog<TaskPriority>(
      context: context,
      builder: (context) => BulkPriorityUpdateDialog(
        currentStatistics: statistics,
        selectedTasks: widget.selectedTasks,
      ),
    );
    
    if (result != null && mounted) {
      await _executePriorityUpdate(result);
    }
  }
  
  Future<void> _showProjectDialog(
    BuildContext context,
    SelectionStatistics statistics,
  ) async {
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => BulkProjectMoveDialog(
        currentStatistics: statistics,
        selectedTasks: widget.selectedTasks,
        availableProjects: widget.availableProjects,
      ),
    );
    
    if (result != null && mounted) {
      await _executeProjectMove(result);
    }
  }
  
  Future<void> _showTagsDialog(
    BuildContext context,
    SelectionStatistics statistics,
  ) async {
    final result = await showDialog<BulkTagsResult>(
      context: context,
      builder: (context) => BulkTagsDialog(
        currentStatistics: statistics,
        selectedTasks: widget.selectedTasks,
      ),
    );
    
    if (result != null && mounted) {
      await _executeTagsUpdate(result);
    }
  }
  
  Future<void> _showMoreActionsDialog(
    BuildContext context,
    SelectionStatistics statistics,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => BulkMoreActionsDialog(
        currentStatistics: statistics,
        selectedTasks: widget.selectedTasks,
        onActionSelected: (action, data) => 
            _executeMoreAction(action, data),
      ),
    );
  }
  
  // Action executors
  Future<void> _executeDelete() async {
    try {
      final bulkService = ref.read(bulkOperationServiceProvider);
      final result = await bulkService.bulkDeleteTasks(widget.selectedTasks);
      
      HapticFeedback.mediumImpact();
      widget.onOperationComplete?.call(result);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.successfulTasks} tasks deleted'),
            action: result.canUndo
                ? SnackBarAction(
                    label: 'Undo',
                    onPressed: () => _undoOperation(result.operationId),
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete tasks: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  
  Future<void> _executeStatusUpdate(TaskStatus newStatus) async {
    try {
      final bulkService = ref.read(bulkOperationServiceProvider);
      final result = await bulkService.bulkUpdateStatus(
        widget.selectedTasks,
        newStatus,
      );
      
      HapticFeedback.lightImpact();
      widget.onOperationComplete?.call(result);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.successfulTasks} tasks updated'),
            action: result.canUndo
                ? SnackBarAction(
                    label: 'Undo',
                    onPressed: () => _undoOperation(result.operationId),
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  
  Future<void> _executePriorityUpdate(TaskPriority newPriority) async {
    try {
      final bulkService = ref.read(bulkOperationServiceProvider);
      final result = await bulkService.bulkUpdatePriority(
        widget.selectedTasks,
        newPriority,
      );
      
      HapticFeedback.lightImpact();
      widget.onOperationComplete?.call(result);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.successfulTasks} tasks updated'),
            action: result.canUndo
                ? SnackBarAction(
                    label: 'Undo',
                    onPressed: () => _undoOperation(result.operationId),
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update priority: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  
  Future<void> _executeProjectMove(String? projectId) async {
    try {
      final bulkService = ref.read(bulkOperationServiceProvider);
      final result = await bulkService.bulkMoveToProject(
        widget.selectedTasks,
        projectId,
      );
      
      HapticFeedback.lightImpact();
      widget.onOperationComplete?.call(result);
      
      if (mounted) {
        final projectName = projectId != null
            ? widget.availableProjects
                .firstWhere((p) => p.id == projectId, 
                           orElse: () => Project.create(name: 'Unknown'))
                .name
            : 'No Project';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.successfulTasks} tasks moved to $projectName'),
            action: result.canUndo
                ? SnackBarAction(
                    label: 'Undo',
                    onPressed: () => _undoOperation(result.operationId),
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to move tasks: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  
  Future<void> _executeTagsUpdate(BulkTagsResult tagsResult) async {
    try {
      final bulkService = ref.read(bulkOperationServiceProvider);
      BulkOperationResult result;
      
      if (tagsResult.tagsToAdd.isNotEmpty) {
        result = await bulkService.bulkAddTags(
          widget.selectedTasks,
          tagsResult.tagsToAdd,
        );
      } else {
        result = await bulkService.bulkRemoveTags(
          widget.selectedTasks,
          tagsResult.tagsToRemove,
        );
      }
      
      HapticFeedback.lightImpact();
      widget.onOperationComplete?.call(result);
      
      if (mounted) {
        final actionText = tagsResult.tagsToAdd.isNotEmpty ? 'tagged' : 'untagged';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.successfulTasks} tasks $actionText'),
            action: result.canUndo
                ? SnackBarAction(
                    label: 'Undo',
                    onPressed: () => _undoOperation(result.operationId),
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update tags: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
  
  Future<void> _executeMoreAction(String action, dynamic data) async {
    // Handle additional actions like duplicate, reschedule, etc.
    // Implementation depends on the specific action
  }
  
  Future<void> _executeSuggestedAction(
    BuildContext context,
    BulkActionSuggestion suggestion,
  ) async {
    switch (suggestion.type) {
      case BulkActionType.reschedule:
        // Show reschedule dialog
        break;
      case BulkActionType.changeStatus:
        await _executeStatusUpdate(TaskStatus.inProgress);
        break;
      case BulkActionType.changePriority:
        // Show priority dialog
        break;
      case BulkActionType.moveToProject:
        await _showProjectDialog(context, _getSelectionStatistics());
        break;
      case BulkActionType.addTags:
        await _showTagsDialog(context, _getSelectionStatistics());
        break;
      default:
        break;
    }
  }
  
  Future<void> _undoOperation(String operationId) async {
    try {
      final bulkService = ref.read(bulkOperationServiceProvider);
      await bulkService.undoOperation(operationId);
      
      HapticFeedback.mediumImpact();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Operation undone')),
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
  
  SelectionStatistics _getSelectionStatistics() {
    // Create a temporary selection manager to get statistics
    final selectionManager = TaskSelectionManager();
    for (final task in widget.selectedTasks) {
      selectionManager.toggleTask(task);
    }
    return selectionManager.getStatistics();
  }
}

/// Result for bulk tags operations
class BulkTagsResult {
  final List<String> tagsToAdd;
  final List<String> tagsToRemove;
  
  const BulkTagsResult({
    this.tagsToAdd = const [],
    this.tagsToRemove = const [],
  });
}

/// Import missing enums and classes

/// Placeholder providers (will be implemented in providers file)
final bulkOperationServiceProvider = Provider<BulkOperationService>((ref) {
  throw UnimplementedError('Provider not implemented');
});