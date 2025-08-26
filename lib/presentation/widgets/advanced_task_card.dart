import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';
import '../../core/theme/material3/motion_system.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/utils/category_utils.dart';
import '../../core/utils/text_utils.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/task_audio_extensions.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../services/ui/slidable_action_service.dart';
import '../../services/ui/slidable_feedback_service.dart';
import '../../services/ui/slidable_theme_service.dart';
import '../providers/project_providers.dart';
import 'audio_indicator_widget.dart';
import 'glassmorphism_container.dart';
import 'standardized_card.dart';
import 'standardized_text.dart';
import 'standardized_spacing.dart';
import 'status_badge_widget.dart';
import 'subtask_progress_indicator.dart';
import 'task_dependency_status.dart';
import 'tag_chip.dart';
import '../providers/tag_providers.dart';

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
  final Function(Project)? onProjectTap;
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
    this.onProjectTap,
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

class _AdvancedTaskCardState extends ConsumerState<AdvancedTaskCard> with TickerProviderStateMixin {
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
      duration: MotionTokens.slower, // 800ms instead of hardcoded 2000ms
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
      cardWidget = _buildSlidableCard(cardWidget);
    }

    if (widget.enableAnimations) {
      cardWidget = _buildAnimatedCard(cardWidget);
    }

    return Container(
      margin: widget.margin ?? StandardizedSpacing.marginSymmetric(horizontal: SpacingSize.md, vertical: SpacingSize.xs),
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
                if (widget.task.priority.isHighPriority && !widget.task.isCompleted) _buildPriorityGlow(),
                if (_completionAnimation.value > 0) _buildCompletionOverlay(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlidableCard(Widget child) {
    final theme = Theme.of(context);
    final startActions = SlidableActionService.getTaskActions(
      widget.task,
      colorScheme: theme.colorScheme,
      onComplete: widget.onToggleComplete,
      onEdit: widget.onEdit,
      onPin: () => _togglePin(),
      onDelete: () => _confirmDelete(),
      onArchive: () => _archiveTask(),
      onReschedule: () => _rescheduleTask(),
      onStopRecurring: () => _stopRecurring(),
      onSkipInstance: () => _skipInstance(),
      onDuplicate: widget.onDuplicate,
    );

    // Split actions for start and end panes based on context
    final primaryActions = startActions.take(2).toList();
    final secondaryActions = startActions.skip(2).toList();

    return SlidableThemeService.createTaskCardSlidable(
      key: ValueKey('task-${widget.task.id}'),
      groupTag: 'task-cards',
      isOverdue: widget.task.isOverdue,
      isCompleted: widget.task.status == TaskStatus.completed,
      useAdvancedMotion: widget.enableAnimations,
      startActions: primaryActions,
      endActions: secondaryActions,
      child: child,
    );
  }

  Widget _buildCardContent(ThemeData theme) {
    // Map legacy TaskCardStyle to StandardizedCardStyle
    final standardizedStyle = _mapToStandardizedStyle(widget.style);
    
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: StandardizedCard(
        style: standardizedStyle,
        onTap: widget.enableAnimations ? null : widget.onTap, // Handle tap in GestureDetector if animations enabled
        onLongPress: widget.enableContextMenu ? _showContextMenu : null,
        margin: EdgeInsets.zero, // Container already handles margin
        elevation: widget.elevation,
        accentColor: widget.accentColor,
        enableFeedback: widget.enableAnimations,
        child: widget.enableAnimations
          ? GestureDetector(
              onTap: widget.onTap,
              onTapDown: (_) => _handleTapDown(),
              onTapUp: (_) => _handleTapUp(),
              onTapCancel: () => _handleTapUp(),
              child: _buildCardContentByStyle(theme),
            )
          : _buildCardContentByStyle(theme),
      ),
    );
  }

  Widget _buildCardContentByStyle(ThemeData theme) {
    switch (widget.style) {
      case TaskCardStyle.compact:
        return _buildCompactContent(theme);
      case TaskCardStyle.minimal:
        return _buildMinimalContent(theme);
      default:
        return _buildMainContent(theme);
    }
  }

  /// Map legacy TaskCardStyle to StandardizedCardStyle
  StandardizedCardStyle _mapToStandardizedStyle(TaskCardStyle style) {
    switch (style) {
      case TaskCardStyle.elevated:
        return StandardizedCardStyle.elevated;
      case TaskCardStyle.filled:
        return StandardizedCardStyle.filled;
      case TaskCardStyle.outlined:
        return StandardizedCardStyle.outlined;
      case TaskCardStyle.compact:
        return StandardizedCardStyle.compact;
      case TaskCardStyle.glass:
        return StandardizedCardStyle.glass;
      case TaskCardStyle.minimal:
        return StandardizedCardStyle.minimal;
    }
  }


  Widget _buildMainContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(theme),
        if (widget.task.description?.isNotEmpty == true) ...[
          StandardizedGaps.vertical(SpacingSize.xs),
          _buildDescription(theme),
        ],
        // Display tags in main content area for better visibility
        if (widget.task.tagIds.isNotEmpty && widget.style != TaskCardStyle.compact) ...[
          StandardizedGaps.vertical(SpacingSize.sm),
          _buildTagsPreview(theme),
        ],
        if (widget.customContent != null) ...[
          StandardizedGaps.vertical(SpacingSize.sm),
          widget.customContent!,
        ],
        if (widget.showSubtasks) ...[
          StandardizedGaps.vertical(SpacingSize.sm),
          SubtaskLinearProgressIndicator(
            taskId: widget.task.id,
            height: 4,
            showPercentage: true,
          ),
        ],
        if (widget.showProgress) ...[
          StandardizedGaps.vertical(SpacingSize.sm),
          _buildProgress(theme),
        ],
        StandardizedGaps.vertical(SpacingSize.sm),
        _buildFooter(theme),
      ],
    );
  }

  Widget _buildCompactContent(ThemeData theme) {
    return Row(
      children: [
        // Priority indicator first (always show)
        _buildPriorityIndicator(theme, size: 20),
        StandardizedGaps.horizontal(SpacingSize.xs),
        // Category icon container (from legacy tags system)
        if (widget.task.tagIds.isNotEmpty) ...[
          CategoryUtils.buildCategoryIconContainer(
            category: widget.task.tagIds.first,
            size: 24,
            theme: theme,
            iconSizeRatio: 0.5,
          ),
          StandardizedGaps.horizontal(SpacingSize.xs),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StandardizedTextVariants.taskTitle(
                TextUtils.autoCapitalize(widget.task.title),
                isCompleted: widget.task.isCompleted,
                maxLines: 1,
              ),
              // Add tags and due date in the same row for compact display
              Row(
                children: [
                  // Show compact tag chips if there are tags
                  if (widget.task.tagIds.isNotEmpty) ...[
                    Flexible(
                      child: _buildCompactTagsPreview(theme),
                    ),
                    if (widget.task.dueDate != null) ...[
                      const SizedBox(width: 4),
                      const Text('•', style: TextStyle(fontSize: 10)),
                      const SizedBox(width: 4),
                    ],
                  ],
                  // Show due date if available
                  if (widget.task.dueDate != null)
                    Flexible(
                      child: StandardizedText(
                        _formatDueDate(widget.task.dueDate!),
                        style: StandardizedTextStyle.taskMeta,
                        color: _getDueDateColor(theme),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (widget.showAudioIndicator && widget.task.hasVoiceMetadata) ...[
          StandardizedGaps.horizontal(SpacingSize.xs),
          AudioIndicatorWidget(
            task: widget.task,
            size: 16,
            mode: AudioIndicatorMode.playButton,
          ),
        ],
        if (widget.showSubtasks) ...[
          StandardizedGaps.horizontal(SpacingSize.xs),
          SubtaskProgressIndicator(
            taskId: widget.task.id,
            size: 16,
            showCount: true,
          ),
        ],
        StandardizedGaps.horizontal(SpacingSize.xs),
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
          child: StandardizedTextVariants.taskTitle(
            TextUtils.autoCapitalize(widget.task.title),
            isCompleted: widget.task.isCompleted,
          ),
        ),
        if (widget.task.dueDate != null) ...[
          StandardizedGaps.horizontal(SpacingSize.sm),
          StandardizedText(
            _formatDueDate(widget.task.dueDate!),
            style: StandardizedTextStyle.taskMeta,
            color: _getDueDateColor(theme),
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
          StandardizedGaps.horizontal(SpacingSize.xs),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: StandardizedTextVariants.taskTitle(
                      TextUtils.autoCapitalize(widget.task.title),
                      isCompleted: widget.task.isCompleted,
                      color: widget.task.isCompleted ? theme.colorScheme.onSurfaceVariant : null,
                      maxLines: 2,
                    ),
                  ),
                  if (widget.task.isPinned) ...[
                    StandardizedGaps.horizontal(SpacingSize.xs),
                    Icon(
                      PhosphorIcons.pushPin(),
                      size: 16,
                      color: widget.accentColor ?? theme.colorScheme.primary,
                    ),
                  ],
                ],
              ),
              if (widget.showProjectInfo && widget.task.projectId != null) _buildProjectInfo(theme),
            ],
          ),
        ),
        if (widget.showAudioIndicator && widget.task.hasVoiceMetadata) ...[
          StandardizedGaps.horizontal(SpacingSize.xs),
          AudioIndicatorWidget(
            task: widget.task,
            size: 20,
            mode: AudioIndicatorMode.playButton,
          ),
        ],
        if (widget.showDependencyStatus) ...[
          StandardizedGaps.horizontal(SpacingSize.xs),
          TaskDependencyStatus(
            task: widget.task,
            showDetails: true,
            onTap: () => _showDependencyDetails(context),
          ),
        ],
        StandardizedGaps.horizontal(SpacingSize.xs),
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
    // Return empty container if task doesn't have a project
    if (widget.task.projectId == null || widget.task.projectId!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: StandardizedSpacing.paddingOnly(top: SpacingSize.xs),
      child: Consumer(
        builder: (context, ref, child) {
          final projectAsync = ref.watch(projectProvider(widget.task.projectId!));

          return projectAsync.when(
            data: (project) {
              if (project == null) {
                return const SizedBox.shrink(); // Project was deleted
              }
              return _buildProjectBadge(project, theme);
            },
            loading: () => _buildLoadingProjectBadge(theme),
            error: (error, stackTrace) => _buildErrorProjectBadge(theme),
          );
        },
      ),
    );
  }

  Widget _buildProjectBadge(Project project, ThemeData theme) {
    final projectColor = _parseColor(project.color);

    return GestureDetector(
      onTap: widget.onProjectTap != null ? () => widget.onProjectTap!(project) : null,
      child: GlassmorphismContainer(
        level: GlassLevel.interactive,
        borderRadius: BorderRadius.circular(TypographyConstants.chipRadius),
        glassTint: projectColor.withValues(alpha: 0.1),
        padding: StandardizedSpacing.paddingSymmetric(
          horizontal: SpacingSize.xs,
          vertical: SpacingSize.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getProjectIcon(project),
              size: 12,
              color: projectColor,
            ),
            StandardizedGaps.horizontal(SpacingSize.xs),
            StandardizedText(
              project.name,
              style: StandardizedTextStyle.labelSmall,
              color: projectColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingProjectBadge(ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.interactive,
      borderRadius: BorderRadius.circular(TypographyConstants.chipRadius),
      glassTint: theme.colorScheme.primary.withValues(alpha: 0.1),
      padding: StandardizedSpacing.paddingSymmetric(
        horizontal: SpacingSize.xs,
        vertical: SpacingSize.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          StandardizedGaps.horizontal(SpacingSize.xs),
          StandardizedText(
            'Loading...',
            style: StandardizedTextStyle.labelSmall,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorProjectBadge(ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.interactive,
      borderRadius: BorderRadius.circular(TypographyConstants.chipRadius),
      glassTint: theme.colorScheme.error.withValues(alpha: 0.1),
      padding: StandardizedSpacing.paddingSymmetric(
        horizontal: SpacingSize.xs,
        vertical: SpacingSize.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIcons.warning(),
            size: 12,
            color: theme.colorScheme.error,
          ),
          StandardizedGaps.horizontal(SpacingSize.xs),
          StandardizedText(
            'Project Error',
            style: StandardizedTextStyle.labelSmall,
            color: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  IconData _getProjectIcon(Project project) {
    // Since Project doesn't have category field, use folder icon
    // You can extend this to use project-specific icons or categories in the future
    return PhosphorIcons.folder();
  }

  Color _parseColor(String colorString) {
    try {
      final String cleanColor = colorString.replaceAll('#', '');
      if (cleanColor.length == 6) {
        return Color(int.parse('FF$cleanColor', radix: 16));
      }
      if (cleanColor.length == 8) {
        return Color(int.parse(cleanColor, radix: 16));
      }
    } catch (e) {
      // Fallback to default color
    }
    return const Color(0xFF6200EE); // Default material primary color
  }

  Widget _buildDescription(ThemeData theme) {
    return StandardizedTextVariants.taskDescription(
      widget.task.description!,
      color: theme.colorScheme.onSurfaceVariant,
      maxLines: 3,
    );
  }

  Widget _buildProgress(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const StandardizedText(
              'Progress',
              style: StandardizedTextStyle.labelMedium,
            ),
            SubtaskProgressIndicator(
              taskId: widget.task.id,
              size: 14,
              showCount: true,
            ),
          ],
        ),
        StandardizedGaps.vertical(SpacingSize.xs),
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
          StandardizedGaps.horizontal(SpacingSize.xs),
          Expanded(
            child: StandardizedText(
              widget.showDetailedDate
                  ? _formatDetailedDate(widget.task.dueDate!)
                  : _formatDueDate(widget.task.dueDate!),
              style: _isOverdue() ? StandardizedTextStyle.labelMedium : StandardizedTextStyle.taskMeta,
              color: _getDueDateColor(theme),
            ),
          ),
        ] else
          const Spacer(),
        if (widget.task.tagIds.isNotEmpty) ...[
          StandardizedGaps.horizontal(SpacingSize.xs),
          _buildTagsPreview(theme),
        ],
        if (widget.additionalActions?.isNotEmpty == true) ...[
          StandardizedGaps.horizontal(SpacingSize.xs),
          ...widget.additionalActions!,
        ],
        if (widget.enableContextMenu) ...[
          StandardizedGaps.horizontal(SpacingSize.xs),
          _buildActionsButton(theme),
        ],
      ],
    );
  }

  Widget _buildTagsPreview(ThemeData theme) {
    final tagIds = widget.task.tagIds;
    if (tagIds.isEmpty) return const SizedBox.shrink();
    
    // Use the proper tag provider to get real tag entities
    final tagsProvider = ref.watch(tagsByIdsProvider(tagIds));
    
    return tagsProvider.when(
      data: (tags) => TagChipList(
        tags: tags,
        chipSize: TagChipSize.small,
        maxChips: 3,
        spacing: 3.0, // 3px spacing as requested
        onTagTap: widget.onTap != null ? (_) => widget.onTap!() : null,
      ),
      loading: () => const SizedBox(
        height: 20,
        width: 60,
        child: Center(child: CircularProgressIndicator(strokeWidth: 1)),
      ),
      error: (error, __) {
        debugPrint('[TAG ERROR] Failed to load tags for task "${widget.task.title}": $error');
        return const SizedBox.shrink(); // Hide on error
      },
    );
  }

  /// Build compact tag preview for compact cards with minimal space
  Widget _buildCompactTagsPreview(ThemeData theme) {
    final tagIds = widget.task.tagIds;
    if (tagIds.isEmpty) return const SizedBox.shrink();
    
    // Use the proper tag provider to get real tag entities
    final tagsProvider = ref.watch(tagsByIdsProvider(tagIds));
    
    return tagsProvider.when(
      data: (tags) => TagChipList(
        tags: tags,
        chipSize: TagChipSize.small,
        maxChips: 2, // Show only 2 tags in compact mode
        spacing: 2.0, // Tighter spacing for compact cards
        onTagTap: widget.onTap != null ? (_) => widget.onTap!() : null,
      ),
      loading: () => const SizedBox(
        height: 16,
        width: 40,
        child: Center(child: CircularProgressIndicator(strokeWidth: 1)),
      ),
      error: (_, __) => const SizedBox.shrink(), // Hide on error
    );
  }

  Widget _buildActionsButton(ThemeData theme) {
    return InkWell(
      onTap: _showContextMenu,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.xs),
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
                  color: widget.task.priority.color.withValues(
                    alpha: 0.3 * _glowAnimation.value,
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
              color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1 * _completionAnimation.value), // Fixed hardcoded green color
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            ),
            child: Center(
              child: Transform.scale(
                scale: _completionAnimation.value,
                child: Icon(
                  PhosphorIcons.checkCircle(),
                  color: Theme.of(context).colorScheme.tertiary, // Fixed hardcoded green color
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
      padding: StandardizedSpacing.paddingSymmetric(vertical: SpacingSize.md),
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
          StandardizedGaps.vertical(SpacingSize.md),
          Padding(
            padding: StandardizedSpacing.paddingSymmetric(horizontal: SpacingSize.md),
            child: StandardizedTextVariants.cardTitle(
              TextUtils.autoCapitalize(widget.task.title),
              maxLines: 2,
            ),
          ),
          StandardizedGaps.vertical(SpacingSize.md),
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

  void _togglePin() {
    // Toggle pin status with feedback
    SlidableFeedbackService.provideFeedback(SlidableActionType.neutral);
    // Implementation would call the pin callback or service
  }

  void _confirmDelete() {
    // Show confirmation dialog for destructive delete action
    SlidableFeedbackService.provideFeedback(SlidableActionType.destructive);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete?.call();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _archiveTask() {
    // Archive task with feedback
    SlidableFeedbackService.provideFeedback(SlidableActionType.archive);
    // Implementation would call archive service
  }

  void _rescheduleTask() {
    // Show reschedule dialog
    SlidableFeedbackService.provideFeedback(SlidableActionType.edit);
    // Implementation would show date picker or reschedule dialog
  }

  void _stopRecurring() {
    // Stop recurring task series with confirmation
    SlidableFeedbackService.provideFeedback(SlidableActionType.destructive);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Recurring Task'),
        content: const Text('This will stop all future instances of this recurring task.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementation would call stop recurring service
            },
            child: const Text('Stop Series'),
          ),
        ],
      ),
    );
  }

  void _skipInstance() {
    // Skip current instance of recurring task
    SlidableFeedbackService.provideFeedback(SlidableActionType.neutral);
    // Implementation would skip to next instance
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
      return Theme.of(context).colorScheme.secondary; // Fixed hardcoded orange for due today
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
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

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

/// Quick task card for minimal displays using StandardizedCard
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
    return StandardizedCardVariants.quickTask(
      onTap: onTap,
      accentColor: task.priority.color,
      child: ListTile(
        leading: IconButton(
          onPressed: onToggleComplete,
          icon: Icon(
            task.isCompleted ? PhosphorIcons.checkCircle() : PhosphorIcons.circle(),
            color: task.isCompleted ? Theme.of(context).colorScheme.tertiary : null, // Fixed hardcoded green for completion
          ),
        ),
        title: StandardizedTextVariants.taskTitle(
          TextUtils.autoCapitalize(task.title),
          isCompleted: task.isCompleted,
        ),
        subtitle: task.dueDate != null ? Text('Due ${_formatQuickDate(task.dueDate!)}') : null,
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
