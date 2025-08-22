import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task_model.dart';
import '../../domain/entities/task_audio_extensions.dart';
import '../../domain/models/enums.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/theme/material3/motion_system.dart';
import 'glassmorphism_container.dart';
import 'status_badge_widget.dart';
import 'audio_indicator_widget.dart';
import 'task_dependency_status.dart';
import 'subtask_progress_indicator.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Advanced task card widget with comprehensive features and animations
/// 
/// Features:
/// - Multiple card styles (elevated, filled, outlined, compact, glass, minimal)
/// - Glassmorphism effects with proper theming
/// - Audio indicator widgets and playback controls
/// - Subtask display with progress indicators
/// - Advanced animations and gesture handling
/// - Priority indicators and status badges
/// - Due date formatting and overdue indicators
/// - Context menu with actions
/// - Drag handles for reordering
/// - Swipe actions for quick operations
/// - Dependency status indicators
/// - Progress tracking and completion animations
class AdvancedTaskCard extends ConsumerStatefulWidget {
  final TaskModel task;
  final TaskCardStyle style;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDuplicate;
  final Function(TaskPriority)? onPriorityChanged;
  final Function(TaskStatus)? onStatusChanged;
  final bool showProgress;
  final bool showSubtasks;
  final bool showAudioIndicator;
  final bool showDependencyStatus;
  final bool showDragHandle;
  final bool enableSwipeActions;
  final bool enableContextMenu;
  final bool enableAnimations;
  final bool showDetailedDate;
  final bool showProjectInfo;
  final double? elevation;
  final Color? accentColor;
  final Widget? customContent;
  final List<Widget>? additionalActions;

  const AdvancedTaskCard({
    super.key,
    required this.task,
    this.style = TaskCardStyle.elevated,
    this.margin,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onShare,
    this.onToggleComplete,
    this.onDuplicate,
    this.onPriorityChanged,
    this.onStatusChanged,
    this.showProgress = false,
    this.showSubtasks = false,
    this.showAudioIndicator = true,
    this.showDependencyStatus = false,
    this.showDragHandle = false,
    this.enableSwipeActions = true,
    this.enableContextMenu = true,
    this.enableAnimations = true,
    this.showDetailedDate = false,
    this.showProjectInfo = false,
    this.elevation,
    this.accentColor,
    this.customContent,
    this.additionalActions,
  });

  @override
  ConsumerState<AdvancedTaskCard> createState() => _AdvancedTaskCardState();
}

class _AdvancedTaskCardState extends ConsumerState<AdvancedTaskCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _completionController;
  late AnimationController _glowController;
  
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _completionAnimation;
  late Animation<double> _glowAnimation;


  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: ExpressiveMotionSystem.durationShort2,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium2,
      vsync: this,
    );

    _completionController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium3,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: ExpressiveMotionSystem.emphasizedAccelerate,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: ExpressiveMotionSystem.emphasizedDecelerate,
    ));

    _completionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _completionController,
      curve: ExpressiveMotionSystem.emphasizedDecelerate,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    if (widget.task.isCompleted) {
      _completionController.value = 1.0;
    }

    if (widget.enableAnimations) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _completionController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AdvancedTaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.task.isCompleted != widget.task.isCompleted) {
      if (widget.task.isCompleted) {
        _completionController.forward();
      } else {
        _completionController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget cardWidget = _buildCardContent(theme);

    if (widget.enableSwipeActions) {
      cardWidget = _buildSwipeableCard(cardWidget);
    }

    if (widget.enableAnimations) {
      cardWidget = _buildAnimatedCard(cardWidget);
    }

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: cardWidget,
    );
  }

  Widget _buildAnimatedCard(Widget child) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _slideAnimation,
        _completionAnimation,
        _glowAnimation,
      ]),
      builder: (context, _) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: Stack(
              children: [
                child,
                if (widget.task.priority.isHighPriority && !widget.task.isCompleted)
                  _buildPriorityGlow(),
                if (_completionAnimation.value > 0)
                  _buildCompletionOverlay(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwipeableCard(Widget child) {
    return Dismissible(
      key: ValueKey(widget.task.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Left to right swipe - complete task
          widget.onToggleComplete?.call();
          return false;
        } else {
          // Right to left swipe - show more actions
          _showQuickActions();
          return false;
        }
      },
      background: _buildSwipeBackground(isLeft: true),
      secondaryBackground: _buildSwipeBackground(isLeft: false),
      child: child,
    );
  }

  Widget _buildSwipeBackground({required bool isLeft}) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: isLeft ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLeft ? PhosphorIcons.checkCircle() : PhosphorIcons.dotsThree(),
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 4),
              Text(
                isLeft ? 'Complete' : 'Actions',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(ThemeData theme) {
    switch (widget.style) {
      case TaskCardStyle.elevated:
        return _buildElevatedCard(theme);
      case TaskCardStyle.filled:
        return _buildFilledCard(theme);
      case TaskCardStyle.outlined:
        return _buildOutlinedCard(theme);
      case TaskCardStyle.compact:
        return _buildCompactCard(theme);
      case TaskCardStyle.glass:
        return _buildGlassCard(theme);
      case TaskCardStyle.minimal:
        return _buildMinimalCard(theme);
    }
  }

  Widget _buildElevatedCard(ThemeData theme) {
    return Card(
      elevation: widget.elevation ?? 4,
      shadowColor: widget.accentColor?.withValues(alpha: 0.3),
      child: _buildCardInner(theme),
    );
  }

  Widget _buildFilledCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: widget.accentColor?.withValues(alpha: 0.1) ?? theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        border: widget.accentColor != null 
            ? Border.all(color: widget.accentColor!.withValues(alpha: 0.3))
            : null,
      ),
      child: _buildCardInner(theme),
    );
  }

  Widget _buildOutlinedCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(
          color: widget.accentColor ?? theme.colorScheme.outline.withValues(alpha: 0.3),
          width: widget.accentColor != null ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      ),
      child: _buildCardInner(theme),
    );
  }

  Widget _buildCompactCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
      ),
      child: _buildCompactContent(theme),
    );
  }

  Widget _buildGlassCard(ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      padding: EdgeInsets.zero,
      borderColor: widget.accentColor?.withValues(alpha: 0.3),
      child: _buildCardInner(theme),
    );
  }

  Widget _buildMinimalCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      ),
      child: _buildMinimalContent(theme),
    );
  }

  Widget _buildCardInner(ThemeData theme) {
    return InkWell(
      onTap: widget.onTap,
      onTapDown: (_) => _handleTapDown(),
      onTapUp: (_) => _handleTapUp(),
      onTapCancel: () => _handleTapUp(),
      onLongPress: widget.enableContextMenu ? _showContextMenu : null,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: MouseRegion(
        onEnter: (_) => _handleHover(true),
        onExit: (_) => _handleHover(false),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildMainContent(theme),
        ),
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(theme),
        if (widget.task.description?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          _buildDescription(theme),
        ],
        if (widget.customContent != null) ...[
          const SizedBox(height: 12),
          widget.customContent!,
        ],
        if (widget.showSubtasks) ...[
          const SizedBox(height: 12),
          SubtaskLinearProgressIndicator(
            taskId: widget.task.id,
            height: 4,
            showPercentage: true,
          ),
        ],
        if (widget.showProgress) ...[
          const SizedBox(height: 12),
          _buildProgress(theme),
        ],
        const SizedBox(height: 12),
        _buildFooter(theme),
      ],
    );
  }

  Widget _buildCompactContent(ThemeData theme) {
    return Row(
      children: [
        _buildPriorityIndicator(theme, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.task.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  decoration: widget.task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.task.dueDate != null)
                Text(
                  _formatDueDate(widget.task.dueDate!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getDueDateColor(theme),
                  ),
                ),
            ],
          ),
        ),
        if (widget.showAudioIndicator && widget.task.hasVoiceMetadata) ...[
          const SizedBox(width: 8),
          AudioIndicatorWidget(
            task: widget.task,
            size: 16,
          ),
        ],
        if (widget.showSubtasks) ...[
          const SizedBox(width: 8),
          SubtaskProgressIndicator(
            taskId: widget.task.id,
            size: 16,
            showCount: true,
          ),
        ],
        const SizedBox(width: 8),
        StatusBadgeWidget(
          status: widget.task.status,
          compact: true,
        ),
      ],
    );
  }

  Widget _buildMinimalContent(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.task.title,
            style: theme.textTheme.bodyLarge?.copyWith(
              decoration: widget.task.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
        ),
        if (widget.task.dueDate != null) ...[
          const SizedBox(width: 12),
          Text(
            _formatDueDate(widget.task.dueDate!),
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getDueDateColor(theme),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        if (widget.showDragHandle) ...[
          Icon(
            PhosphorIcons.dotsSixVertical(),
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 8),
        ],
        _buildPriorityIndicator(theme),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: widget.task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: widget.task.isCompleted
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.task.isPinned) ...[
                    const SizedBox(width: 8),
                    Icon(
                      PhosphorIcons.pushPin(),
                      size: 16,
                      color: widget.accentColor ?? theme.colorScheme.primary,
                    ),
                  ],
                ],
              ),
              if (widget.showProjectInfo && widget.task.projectId != null)
                _buildProjectInfo(theme),
            ],
          ),
        ),
        if (widget.showAudioIndicator && widget.task.hasVoiceMetadata) ...[
          const SizedBox(width: 8),
          AudioIndicatorWidget(
            task: widget.task,
          ),
        ],
        if (widget.showDependencyStatus) ...[
          const SizedBox(width: 8),
          TaskDependencyStatus(
            task: widget.task,
            showDetails: true,
            onTap: () => _showDependencyDetails(context),
          ),
        ],
        const SizedBox(width: 8),
        StatusBadgeWidget(
          status: widget.task.status,
          compact: true,
        ),
      ],
    );
  }

  Widget _buildPriorityIndicator(ThemeData theme, {double size = 24}) {
    final priorityColor = widget.task.priority.color;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: priorityColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: priorityColor,
          width: 2,
        ),
      ),
      child: Icon(
        _getPriorityIcon(widget.task.priority),
        color: priorityColor,
        size: size * 0.6,
      ),
    );
  }

  Widget _buildProjectInfo(ThemeData theme) {
    // This would need to be connected to a project provider
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            PhosphorIcons.folder(),
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            'Project', // Replace with actual project name
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      widget.task.description!,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }


  Widget _buildProgress(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SubtaskProgressIndicator(
              taskId: widget.task.id,
              size: 14,
              showCount: true,
            ),
          ],
        ),
        const SizedBox(height: 4),
        SubtaskLinearProgressIndicator(
          taskId: widget.task.id,
          height: 6,
          showPercentage: false,
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      children: [
        if (widget.task.dueDate != null) ...[
          Icon(
            _getDueDateIcon(),
            size: 16,
            color: _getDueDateColor(theme),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              widget.showDetailedDate 
                  ? _formatDetailedDate(widget.task.dueDate!)
                  : _formatDueDate(widget.task.dueDate!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getDueDateColor(theme),
                fontWeight: _isOverdue() ? FontWeight.w600 : null,
              ),
            ),
          ),
        ] else
          const Spacer(),
        if (widget.task.tags.isNotEmpty) ...[
          const SizedBox(width: 8),
          _buildTagsPreview(theme),
        ],
        if (widget.additionalActions?.isNotEmpty == true) ...[
          const SizedBox(width: 8),
          ...widget.additionalActions!,
        ],
        if (widget.enableContextMenu) ...[
          const SizedBox(width: 8),
          _buildActionsButton(theme),
        ],
      ],
    );
  }

  Widget _buildTagsPreview(ThemeData theme) {
    final tags = widget.task.tags;
    const maxTags = 2;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...tags.take(maxTags).map((tag) => Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tag,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        )),
        if (tags.length > maxTags)
          Text(
            '+${tags.length - maxTags}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildActionsButton(ThemeData theme) {
    return InkWell(
      onTap: _showContextMenu,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          PhosphorIcons.dotsThreeVertical(),
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildPriorityGlow() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              boxShadow: [
                BoxShadow(
                  color: widget.task.priority.color.withValues(alpha: 
                    0.3 * _glowAnimation.value,
                  ),
                  blurRadius: 12 * _glowAnimation.value,
                  spreadRadius: 2 * _glowAnimation.value,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompletionOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _completionAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1 * _completionAnimation.value),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            ),
            child: Center(
              child: Transform.scale(
                scale: _completionAnimation.value,
                child: Icon(
                  PhosphorIcons.checkCircle(),
                  color: Colors.green,
                  size: 48,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper methods
  void _handleTapDown() {
    if (widget.enableAnimations) {
      _scaleController.forward();
    }
  }

  void _handleTapUp() {
    if (widget.enableAnimations) {
      _scaleController.reverse();
    }
  }

  void _handleHover(bool isHovered) {
    if (widget.enableAnimations) {
      if (isHovered) {
        _slideController.forward();
      } else {
        _slideController.reverse();
      }
    }
  }

  void _showContextMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildContextMenuSheet(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  Widget _buildContextMenuSheet() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.task.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          _buildMenuTile(
            icon: widget.task.isCompleted ? PhosphorIcons.arrowClockwise() : PhosphorIcons.checkCircle(),
            title: widget.task.isCompleted ? 'Mark Incomplete' : 'Mark Complete',
            onTap: () {
              Navigator.pop(context);
              widget.onToggleComplete?.call();
            },
          ),
          if (widget.onEdit != null)
            _buildMenuTile(
              icon: PhosphorIcons.pencil(),
              title: 'Edit',
              onTap: () {
                Navigator.pop(context);
                widget.onEdit?.call();
              },
            ),
          if (widget.onDuplicate != null)
            _buildMenuTile(
              icon: PhosphorIcons.copy(),
              title: 'Duplicate',
              onTap: () {
                Navigator.pop(context);
                widget.onDuplicate?.call();
              },
            ),
          if (widget.onShare != null)
            _buildMenuTile(
              icon: PhosphorIcons.share(),
              title: 'Share',
              onTap: () {
                Navigator.pop(context);
                widget.onShare?.call();
              },
            ),
          if (widget.onDelete != null) ...[
            const Divider(),
            _buildMenuTile(
              icon: PhosphorIcons.trash(),
              title: 'Delete',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                widget.onDelete?.call();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? theme.colorScheme.error : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? theme.colorScheme.error : null,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showQuickActions() {
    // Implementation for quick actions panel
    // This could be a custom overlay or another bottom sheet
  }

  void _showDependencyDetails(BuildContext context) {
    Navigator.of(context).pushNamed('/task-dependencies');
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return PhosphorIcons.caretDown();
      case TaskPriority.medium:
        return PhosphorIcons.minus();
      case TaskPriority.high:
        return PhosphorIcons.caretUp();
      case TaskPriority.urgent:
        return PhosphorIcons.arrowUp();
    }
  }

  IconData _getDueDateIcon() {
    if (_isOverdue()) {
      return PhosphorIcons.warning();
    } else if (_isDueToday()) {
      return PhosphorIcons.calendar();
    } else if (_isDueTomorrow()) {
      return PhosphorIcons.clock();
    } else {
      return PhosphorIcons.calendar();
    }
  }

  Color _getDueDateColor(ThemeData theme) {
    if (_isOverdue()) {
      return theme.colorScheme.error;
    } else if (_isDueToday()) {
      return Colors.orange;
    } else if (_isDueTomorrow()) {
      return theme.colorScheme.primary;
    } else {
      return theme.colorScheme.onSurfaceVariant;
    }
  }

  bool _isOverdue() {
    if (widget.task.dueDate == null || widget.task.isCompleted) return false;
    return widget.task.dueDate!.isBefore(DateTime.now());
  }

  bool _isDueToday() {
    if (widget.task.dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      widget.task.dueDate!.year,
      widget.task.dueDate!.month,
      widget.task.dueDate!.day,
    );
    return dueDate == today;
  }

  bool _isDueTomorrow() {
    if (widget.task.dueDate == null) return false;
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dueDate = DateTime(
      widget.task.dueDate!.year,
      widget.task.dueDate!.month,
      widget.task.dueDate!.day,
    );
    return dueDate == tomorrow;
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    final difference = taskDate.difference(today).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1 && difference <= 7) {
      return 'In $difference days';
    } else if (difference < -1 && difference >= -7) {
      return '${-difference} days ago';
    } else {
      return '${dueDate.day}/${dueDate.month}';
    }
  }

  String _formatDetailedDate(DateTime dueDate) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final weekday = weekdays[dueDate.weekday - 1];
    final month = months[dueDate.month - 1];
    final day = dueDate.day;
    final hour = dueDate.hour;
    final minute = dueDate.minute.toString().padLeft(2, '0');
    
    return '$weekday, $month $day at $hour:$minute';
  }
}

/// Task card size variants
enum TaskCardSize {
  small,
  medium,
  large;
  
  double get height {
    switch (this) {
      case TaskCardSize.small:
        return 80;
      case TaskCardSize.medium:
        return 120;
      case TaskCardSize.large:
        return 160;
    }
  }
}

/// Quick task card for minimal displays
class QuickTaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;

  const QuickTaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: IconButton(
          onPressed: onToggleComplete,
          icon: Icon(
            task.isCompleted ? PhosphorIcons.checkCircle() : PhosphorIcons.circle(),
            color: task.isCompleted ? Colors.green : null,
          ),
        ),
        title: Text(
          task.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: task.dueDate != null
            ? Text('Due ${_formatQuickDate(task.dueDate!)}')
            : null,
        trailing: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: task.priority.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  String _formatQuickDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    
    final difference = taskDate.difference(today).inDays;
    
    if (difference == 0) return 'today';
    if (difference == 1) return 'tomorrow';
    if (difference == -1) return 'yesterday';
    return '${date.day}/${date.month}';
  }
}


