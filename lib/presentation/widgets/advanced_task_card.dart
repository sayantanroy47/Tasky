import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../core/theme/material3/motion_system.dart';
import '../providers/task_providers.dart';
import 'animated_priority_chip.dart';
import '../../core/theme/typography_constants.dart';
import 'smart_text_widgets.dart';
import 'enhanced_list_animations.dart';
import 'glassmorphism_container.dart';
import 'dart:math' as math;

/// Advanced task card with all Material 3 expressive features
class AdvancedTaskCard extends ConsumerStatefulWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final bool showActions;
  final bool showProgress;
  final bool showSubtasks;
  final double? elevation;
  final EdgeInsets? margin;
  final TaskCardStyle style;

  const AdvancedTaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onShare,
    this.showActions = true,
    this.showProgress = true,
    this.showSubtasks = false,
    this.elevation,
    this.margin,
    this.style = TaskCardStyle.elevated,
  });

  @override
  ConsumerState<AdvancedTaskCard> createState() => _AdvancedTaskCardState();
}

class _AdvancedTaskCardState extends ConsumerState<AdvancedTaskCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _pressController;
  late AnimationController _completeController;
  late AnimationController _swipeController;
  late AnimationController _priorityPulseController;
  late AnimationController _progressController;

  late Animation<double> _hoverAnimation;
  late Animation<double> _pressAnimation;
  late Animation<double> _completeAnimation;
  late Animation<Offset> _swipeAnimation;
  late Animation<double> _priorityPulseAnimation;
  late Animation<double> _progressAnimation;

  bool _isHovered = false;
  double _swipeOffset = 0.0;
  SwipeDirection? _swipeDirection;
  bool _showActionsPanel = false;
  double _completionProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupInitialState();
  }

  void _setupAnimations() {
    _hoverController = AnimationController(
      duration: ExpressiveMotionSystem.durationShort3,
      vsync: this,
    );

    _pressController = AnimationController(
      duration: ExpressiveMotionSystem.durationShort2,
      vsync: this,
    );

    _completeController = AnimationController(
      duration: ExpressiveMotionSystem.durationLong2,
      vsync: this,
    );

    _swipeController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium2,
      vsync: this,
    );

    _priorityPulseController = AnimationController(
      duration: _getPriorityPulseDuration(),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: ExpressiveMotionSystem.durationLong3,
      vsync: this,
    );

    // Animation definitions
    _hoverAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: ExpressiveMotionSystem.standard),
    );

    _pressAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _pressController, curve: ExpressiveMotionSystem.emphasizedDecelerate),
    );

    _completeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _completeController, curve: Curves.elasticOut),
    );

    _swipeAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0.3, 0)).animate(
      CurvedAnimation(parent: _swipeController, curve: ExpressiveMotionSystem.emphasizedEasing),
    );

    _priorityPulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _priorityPulseController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: _completionProgress).animate(
      CurvedAnimation(parent: _progressController, curve: ExpressiveMotionSystem.emphasizedDecelerate),
    );
  }

  void _setupInitialState() {
    _completionProgress = _calculateCompletionProgress();
    _progressController.animateTo(_completionProgress);
    
    if (widget.task.priority == TaskPriority.urgent || widget.task.priority == TaskPriority.high) {
      _priorityPulseController.repeat(reverse: true);
    }

    if (widget.task.status == TaskStatus.completed) {
      _completeController.value = 1.0;
    }
  }

  Duration _getPriorityPulseDuration() {
    switch (widget.task.priority) {
      case TaskPriority.urgent:
        return const Duration(milliseconds: 800);
      case TaskPriority.high:
        return const Duration(milliseconds: 1200);
      case TaskPriority.medium:
        return const Duration(milliseconds: 1800);
      case TaskPriority.low:
        return const Duration(milliseconds: 2500);
    }
  }

  double _calculateCompletionProgress() {
    if (widget.task.status == TaskStatus.completed) return 1.0;
    if (widget.task.subTasks.isEmpty) return 0.0;
    
    final completedSubtasks = widget.task.subTasks.where((s) => s.isCompleted).length;
    return completedSubtasks / widget.task.subTasks.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: MouseRegion(
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: _onTap,
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _hoverAnimation,
              _pressAnimation,
              _completeAnimation,
              _swipeAnimation,
              _progressAnimation,
            ]),
            builder: (context, child) {
              return Transform.scale(
                scale: _hoverAnimation.value * _pressAnimation.value,
                child: Transform.translate(
                  offset: _swipeAnimation.value * MediaQuery.of(context).size.width,
                  child: _buildCard(theme),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(ThemeData theme) {
    return Stack(
      children: [
        // Actions panel (revealed on swipe)
        if (_showActionsPanel) _buildActionsPanel(theme),
        
        // Main card
        _buildMainCard(theme),
        
        // Completion overlay
        if (_completeAnimation.value > 0)
          _buildCompletionOverlay(theme),
      ],
    );
  }

  Widget _buildMainCard(ThemeData theme) {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.taskCardRadius),
      blur: 15.0,
      opacity: 0.15,
      glassTint: _getPriorityColor().withOpacity(0.1),
      borderColor: _getPriorityColor().withOpacity(0.3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TypographyConstants.taskCardRadius),
          gradient: _getCardGradient(theme),
          boxShadow: _isHovered ? [
            BoxShadow(
              color: _getPriorityColor().withOpacity(0.3),
              blurRadius: 16,
              spreadRadius: 3,
            ),
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            if (widget.showProgress && _completionProgress > 0)
              _buildProgressIndicator(theme),
            
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  _buildHeaderRow(theme),
                  
                  const SizedBox(height: 12),
                  
                  // Title and description
                  _buildTitleSection(theme),
                  
                  const SizedBox(height: 12),
                  
                  // Tags and metadata
                  _buildMetadataRow(theme),
                  
                  // Subtasks preview
                  if (widget.showSubtasks && widget.task.subTasks.isNotEmpty)
                    _buildSubtasksPreview(theme),
                  
                  // Actions row
                  if (widget.showActions)
                    _buildActionsRow(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Container(
      height: 4,
      child: LinearProgressIndicator(
        value: _progressAnimation.value,
        backgroundColor: theme.colorScheme.surfaceVariant,
        valueColor: AlwaysStoppedAnimation<Color>(_getPriorityColor()),
      ),
    );
  }

  Widget _buildHeaderRow(ThemeData theme) {
    return Row(
      children: [
        // Status indicator
        _buildStatusIndicator(theme),
        
        const SizedBox(width: 8),
        
        // Due date
        if (widget.task.dueDate != null)
          _buildDueDateChip(theme),
        
        const Spacer(),
        
        // Priority chip
        PulsingPriorityChip(
          priority: widget.task.priority,
          showPulse: widget.task.status != TaskStatus.completed,
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(ThemeData theme) {
    return AnimatedContainer(
      duration: ExpressiveMotionSystem.durationMedium2,
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        shape: BoxShape.circle,
        boxShadow: widget.task.status == TaskStatus.inProgress ? [
          BoxShadow(
            color: _getStatusColor(),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ] : null,
      ),
    );
  }

  Widget _buildDueDateChip(ThemeData theme) {
    final isOverdue = widget.task.dueDate!.isBefore(DateTime.now());
    final isToday = _isToday(widget.task.dueDate!);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOverdue 
          ? theme.colorScheme.errorContainer 
          : isToday 
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
      ),
      child: Text(
        _formatDueDate(widget.task.dueDate!),
        style: theme.textTheme.bodySmall?.copyWith(
          color: isOverdue 
            ? theme.colorScheme.onErrorContainer 
            : isToday 
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTitleSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.task.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: widget.task.status == TaskStatus.completed 
              ? TextDecoration.lineThrough 
              : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        if (widget.task.description != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.task.description!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildMetadataRow(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        // Tags
        ...widget.task.tags.take(3).map((tag) => 
          _buildTag(tag, theme),
        ),
        
        // More tags indicator
        if (widget.task.tags.length > 3)
          _buildMoreTagsIndicator(theme),
      ],
    );
  }

  Widget _buildTag(String tag, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
      ),
      child: Text(
        '#$tag',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMoreTagsIndicator(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        // Show all tags dialog
        _showAllTagsDialog();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
        ),
        child: Text(
          '+${widget.task.tags.length - 3}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildSubtasksPreview(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.checklist,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.task.subTasks.where((s) => s.isCompleted).length}/${widget.task.subTasks.length}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsRow(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          // Complete/Uncomplete button
          _buildActionButton(
            icon: widget.task.status == TaskStatus.completed
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
            onPressed: _toggleCompletion,
            color: widget.task.status == TaskStatus.completed
              ? _getStatusColor()
              : theme.colorScheme.onSurfaceVariant,
          ),
          
          const SizedBox(width: 8),
          
          // Edit button
          if (widget.onEdit != null)
            _buildActionButton(
              icon: Icons.edit,
              onPressed: widget.onEdit!,
              color: theme.colorScheme.primary,
            ),
          
          const SizedBox(width: 8),
          
          // Share button
          if (widget.onShare != null)
            _buildActionButton(
              icon: Icons.share,
              onPressed: widget.onShare!,
              color: theme.colorScheme.secondary,
            ),
          
          const Spacer(),
          
          // Created date
          Text(
            _formatCreatedDate(widget.task.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onPressed();
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
        ),
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionsPanel(ThemeData theme) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: _swipeDirection == SwipeDirection.left
            ? theme.colorScheme.error.withOpacity(0.1)
            : theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(TypographyConstants.taskCardRadius),
        ),
        child: Row(
          mainAxisAlignment: _swipeDirection == SwipeDirection.left
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
          children: [
            if (_swipeDirection == SwipeDirection.right) ...[
              const SizedBox(width: 16),
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.tertiary,
                size: 24,
              ),
            ],
            if (_swipeDirection == SwipeDirection.left) ...[
              Icon(
                Icons.delete,
                color: theme.colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionOverlay(ThemeData theme) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.tertiary.withOpacity(0.1 * _completeAnimation.value),
          borderRadius: BorderRadius.circular(TypographyConstants.taskCardRadius),
        ),
        child: Center(
          child: Transform.scale(
            scale: _completeAnimation.value,
            child: Icon(
              Icons.check_circle,
              color: theme.colorScheme.tertiary,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods
  Color _getPriorityColor() {
    final theme = Theme.of(context);
    switch (widget.task.priority) {
      case TaskPriority.urgent:
        return theme.colorScheme.error;
      case TaskPriority.high:
        return theme.colorScheme.errorContainer;
      case TaskPriority.medium:
        return theme.colorScheme.primary;
      case TaskPriority.low:
        return theme.colorScheme.secondary;
    }
  }

  Color _getStatusColor() {
    final theme = Theme.of(context);
    switch (widget.task.status) {
      case TaskStatus.pending:
        return theme.colorScheme.outline;
      case TaskStatus.inProgress:
        return theme.colorScheme.primary;
      case TaskStatus.completed:
        return theme.colorScheme.tertiary;
      case TaskStatus.cancelled:
        return theme.colorScheme.error;
    }
  }

  double _getCardElevation() {
    if (widget.elevation != null) return widget.elevation!;
    if (_isHovered) return 8;
    return 4;
  }

  BorderSide _getCardBorder(ThemeData theme) {
    if (widget.task.status == TaskStatus.completed) {
      return BorderSide(color: theme.colorScheme.tertiary.withOpacity(0.3), width: 2);
    }
    if (_isHovered) {
      return BorderSide(color: _getPriorityColor().withOpacity(0.3), width: 2);
    }
    return BorderSide(color: theme.colorScheme.outline.withOpacity(0.1));
  }

  Gradient? _getCardGradient(ThemeData theme) {
    if (widget.style == TaskCardStyle.gradient) {
      return LinearGradient(
        colors: [
          theme.colorScheme.surface,
          _getPriorityColor().withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return null;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference > 0) return '${difference}d left';
    return '${difference.abs()}d ago';
  }

  String _formatCreatedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return '${difference}d ago';
  }

  // Event handlers
  void _setHovered(bool hovered) {
    if (_isHovered != hovered) {
      setState(() => _isHovered = hovered);
      if (hovered) {
        _hoverController.forward();
      } else {
        _hoverController.reverse();
      }
    }
  }

  void _onTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _pressController.reverse();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  void _onTap() {
    HapticFeedback.mediumImpact();
    widget.onTap?.call();
  }

  void _onPanStart(DragStartDetails details) {
    _swipeOffset = 0.0;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _swipeOffset += details.delta.dx;
      _swipeDirection = _swipeOffset > 0 ? SwipeDirection.right : SwipeDirection.left;
      _showActionsPanel = _swipeOffset.abs() > 50;
    });

    final progress = (_swipeOffset.abs() / 200).clamp(0.0, 1.0);
    _swipeController.value = progress;
  }

  void _onPanEnd(DragEndDetails details) {
    if (_swipeOffset.abs() > 100) {
      if (_swipeDirection == SwipeDirection.right) {
        _toggleCompletion();
      } else if (_swipeDirection == SwipeDirection.left) {
        widget.onDelete?.call();
      }
    }

    // Reset swipe
    _swipeController.reverse();
    setState(() {
      _showActionsPanel = false;
      _swipeOffset = 0.0;
      _swipeDirection = null;
    });
  }

  void _toggleCompletion() {
    final newStatus = widget.task.status == TaskStatus.completed
        ? TaskStatus.pending
        : TaskStatus.completed;
    
    if (newStatus == TaskStatus.completed) {
      _completeController.forward();
      HapticFeedback.heavyImpact();
    } else {
      _completeController.reverse();
    }

    // Update task status through provider
    // ref.read(taskOperationsProvider).updateTaskStatus(widget.task.id, newStatus);
  }

  void _showAllTagsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Tags'),
        content: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: widget.task.tags.map((tag) => 
            _buildTag(tag, Theme.of(context)),
          ).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    _completeController.dispose();
    _swipeController.dispose();
    _priorityPulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }
}

enum TaskCardStyle {
  elevated,
  outlined,
  gradient,
  minimal,
}

enum SwipeDirection {
  left,
  right,
}