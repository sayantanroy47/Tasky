import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/task_audio_extensions.dart';
import '../../domain/models/enums.dart';
import '../../core/theme/material3/motion_system.dart';
import '../providers/task_providers.dart';
import '../../core/providers/enhanced_theme_provider.dart';
import '../../core/design_system/responsive_builder.dart';
import '../../services/gesture_customization_service.dart';
import 'animated_priority_chip.dart';
import '../../core/theme/typography_constants.dart';
import 'smart_text_widgets.dart';
import 'enhanced_list_animations.dart';
import 'glassmorphism_container.dart';
import 'gesture_enhancements.dart';
import 'status_badge_widget.dart';
import 'audio_widgets.dart';
import '../../core/accessibility/accessibility_constants.dart';
import '../../core/accessibility/touch_target_validator.dart';
import '../../core/design_system/design_tokens.dart' hide BorderRadius;
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
  // OPTIMIZED: Reduced from 6 to 2 animation controllers for better performance
  late AnimationController _interactionController; // Combined hover/press/complete
  late AnimationController _progressController; // Progress and priority pulse

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
    // OPTIMIZED: Combined interaction controller for hover/press/complete
    _interactionController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium2,
      vsync: this,
    );

    // OPTIMIZED: Single controller for progress and priority pulse
    _progressController = AnimationController(
      duration: ExpressiveMotionSystem.durationLong3,
      vsync: this,
    );

    // Animation definitions - all based on the 2 controllers
    _hoverAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _interactionController, 
        curve: const Interval(0.0, 0.3, curve: ExpressiveMotionSystem.standard),
      ),
    );

    _pressAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _interactionController, 
        curve: const Interval(0.3, 0.6, curve: ExpressiveMotionSystem.emphasizedDecelerate),
      ),
    );

    _completeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _interactionController, 
        curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
      ),
    );

    _swipeAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0.3, 0)).animate(
      CurvedAnimation(
        parent: _interactionController, 
        curve: ExpressiveMotionSystem.emphasizedEasing,
      ),
    );

    _priorityPulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController, 
        curve: Curves.easeInOut,
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: _completionProgress).animate(
      CurvedAnimation(
        parent: _progressController, 
        curve: ExpressiveMotionSystem.emphasizedDecelerate,
      ),
    );
  }

  void _setupInitialState() {
    _completionProgress = _calculateCompletionProgress();
    _progressController.animateTo(_completionProgress);
    
    if (widget.task.priority == TaskPriority.urgent || widget.task.priority == TaskPriority.high) {
      _progressController.repeat(reverse: true); // Use progress controller for pulse
    }

    if (widget.task.status == TaskStatus.completed) {
      _interactionController.value = 1.0; // Use interaction controller for completion
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
    
    // Get accessibility-aware animation duration
    final animationDuration = AccessibilityUtils.getAnimationDuration(
      context, 
      ExpressiveMotionSystem.durationMedium2,
    );
    
    // Create semantic label
    final semanticLabel = _buildSemanticLabel();
    final semanticHint = _buildSemanticHint();
    
    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Semantics(
        label: semanticLabel,
        hint: semanticHint,
        button: true,
        enabled: true,
        selected: widget.task.isCompleted,
        onTap: () {
          _onTap();
          AccessibilityUtils.announceToScreenReader(
            context,
            widget.task.isCompleted 
                ? AccessibilityConstants.taskCompletedAnnouncement
                : AccessibilityConstants.taskUncompletedAnnouncement,
          );
        },
        onLongPress: () {
          if (widget.onEdit != null) {
            widget.onEdit!();
            AccessibilityUtils.announceToScreenReader(
              context,
              'Opening task editor',
            );
          }
        },
        child: Focus(
          child: Builder(
            builder: (context) {
              final hasFocus = Focus.of(context).hasFocus;
              return Container(
                decoration: hasFocus
                    ? BoxDecoration(
                        border: Border.all(
                          color: AccessibilityConstants.focusIndicatorColor,
                          width: AccessibilityConstants.focusIndicatorWidth,
                        ),
                        borderRadius: BorderRadius.circular(TypographyConstants.taskCardRadius),
                      )
                    : null,
                child: MouseRegion(
                  onEnter: (_) => _setHovered(true),
                  onExit: (_) => _setHovered(false),
                  child: GestureDetector(
                    onTapDown: _onTapDown,
                    onTapUp: _onTapUp,
                    onTapCancel: _onTapCancel,
                    onTap: _onTap,
                    onLongPress: widget.onEdit,
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _interactionController,
                        _progressController,
                      ]),
                      builder: (context, child) {
                        // Reduce or disable animations for accessibility
                        final shouldReduceMotion = AccessibilityUtils.shouldReduceMotion(context);
                        final scaleValue = shouldReduceMotion ? 1.0 : _hoverAnimation.value * _pressAnimation.value;
                        final translateValue = shouldReduceMotion 
                            ? Offset.zero 
                            : _swipeAnimation.value * MediaQuery.of(context).size.width;
                        
                        return Transform.scale(
                          scale: scaleValue,
                          child: Transform.translate(
                            offset: translateValue,
                            child: _buildAccessibleCard(theme),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Build semantic label for screen readers
  String _buildSemanticLabel() {
    final priority = widget.task.priority?.toString().split('.').last ?? 'normal';
    final status = widget.task.isCompleted ? 'completed' : 'incomplete';
    final dueInfo = widget.task.dueDate != null 
        ? 'due ${_formatDueDate(widget.task.dueDate!)}'
        : 'no due date';
    
    return 'Task: ${widget.task.title}. Priority: $priority. Status: $status. $dueInfo';
  }
  
  /// Build semantic hint for screen readers
  String _buildSemanticHint() {
    if (widget.task.isCompleted) {
      return AccessibilityConstants.completedTaskSemanticHint;
    } else {
      return AccessibilityConstants.incompleteTaskSemanticHint + '. ' + 
             AccessibilityConstants.deleteTaskSemanticHint;
    }
  }
  
  /// Format due date for accessibility
  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference == 0) return 'today';
    if (difference == 1) return 'tomorrow';
    if (difference == -1) return 'yesterday';
    if (difference > 0) return 'in $difference days';
    return '${difference.abs()} days ago';
  }
  
  /// Build accessible card with minimum touch targets
  Widget _buildAccessibleCard(ThemeData theme) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: AccessibilityConstants.minTouchTarget,
      ),
      child: _buildCard(theme),
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
      level: GlassLevel.content, // Use content level for task cards
      borderRadius: BorderRadius.circular(TypographyConstants.taskCardRadius),
      // Let glassmorphism auto-determine tint, keep priority indication via border
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
        // Creation method icon
        _buildCreationMethodIcon(theme),
        
        // Due date with improved hierarchy
        if (widget.task.dueDate != null) ...[
          const SizedBox(width: 8),
          _buildDueDateChip(theme),
          const SizedBox(width: 8),
        ] else if (_getCreationMethodIcon() != null) ...[
          const SizedBox(width: 8),
        ],
        
        const Spacer(),
        
        // Enhanced priority indicator with prominent glow
        PriorityBadgeWidget(
          priority: widget.task.priority,
          showText: true,
          compact: false,
        ),
        
        // 5px gap between priority and status badges
        const SizedBox(width: 5),
        
        // Status badge on the right side
        StatusBadgeWidget(
          status: widget.task.status,
          showText: true,
          compact: false,
        ),
      ],
    );
  }

  /// Build creation method icon based on task metadata
  Widget _buildCreationMethodIcon(ThemeData theme) {
    final icon = _getCreationMethodIcon();
    final color = _getCreationMethodColor(theme);
    final tooltip = _getCreationMethodTooltip();
    
    if (icon == null) return const SizedBox.shrink();
    
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: color,
        ),
      ),
    );
  }

  /// Get the appropriate icon for the creation method
  IconData? _getCreationMethodIcon() {
    final source = widget.task.metadata['source'] as String?;
    
    switch (source) {
      case 'voice':
        return Icons.mic;
      case 'voice_to_text':
        return Icons.mic_none;
      case 'voice_only':
        return Icons.record_voice_over;
      case 'manual':
        return Icons.edit;
      default:
        // If no source is specified, assume manual
        return Icons.edit;
    }
  }

  /// Get the appropriate color for the creation method
  Color _getCreationMethodColor(ThemeData theme) {
    final source = widget.task.metadata['source'] as String?;
    
    switch (source) {
      case 'voice':
      case 'voice_to_text':
      case 'voice_only':
        return theme.colorScheme.secondary;
      case 'manual':
      default:
        return theme.colorScheme.primary;
    }
  }

  /// Get the tooltip text for the creation method
  String _getCreationMethodTooltip() {
    final source = widget.task.metadata['source'] as String?;
    
    switch (source) {
      case 'voice':
        return 'Created with voice input';
      case 'voice_to_text':
        return 'Created with voice-to-text';
      case 'voice_only':
        return 'Created with voice recording';
      case 'manual':
        return 'Created manually';
      default:
        return 'Created manually';
    }
  }

  Widget _buildStatusIndicator(ThemeData theme) {
    final statusColor = _getThemedStatusColor();
    final statusText = _getStatusText();
    
    return AnimatedContainer(
      duration: ExpressiveMotionSystem.durationMedium2,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
        border: Border.all(color: statusColor, width: 2),
        // Enhanced glow effects for better visibility
        boxShadow: [
          // Outer glow
          BoxShadow(
            color: statusColor.withOpacity(0.4),
            blurRadius: widget.task.status == TaskStatus.inProgress ? 12 : 8,
            spreadRadius: widget.task.status == TaskStatus.inProgress ? 2 : 1,
          ),
          // Inner highlight for Material 3
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 2,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Much larger, more prominent status dot with enhanced glow
          AnimatedContainer(
            duration: ExpressiveMotionSystem.durationShort2,
            width: _getStatusDotSize(),
            height: _getStatusDotSize(),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: statusColor.withOpacity(0.8),
                width: 2.5,
              ),
              // Enhanced multi-layer glow effects
              boxShadow: [
                // Outer glow - largest
                BoxShadow(
                  color: statusColor.withOpacity(0.4),
                  blurRadius: widget.task.status == TaskStatus.inProgress ? 16 : 12,
                  spreadRadius: widget.task.status == TaskStatus.inProgress ? 4 : 2,
                ),
                // Middle glow
                BoxShadow(
                  color: statusColor.withOpacity(0.6),
                  blurRadius: widget.task.status == TaskStatus.inProgress ? 8 : 6,
                  spreadRadius: widget.task.status == TaskStatus.inProgress ? 2 : 1,
                ),
                // Inner highlight
                BoxShadow(
                  color: statusColor.withOpacity(0.8),
                  blurRadius: 3,
                  spreadRadius: 0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12, // Increased from 10
              fontWeight: FontWeight.w700, // Bolder text
              color: statusColor,
              letterSpacing: 0.5, // Better readability
            ),
          ),
        ],
      ),
    );
  }
  
  String _getStatusText() {
    switch (widget.task.status) {
      case TaskStatus.pending:
        return 'PENDING';
      case TaskStatus.inProgress:
        return 'DOING';
      case TaskStatus.completed:
        return 'DONE';
      case TaskStatus.cancelled:
        return 'CANCELLED';
    }
  }
  
  Color _getThemedStatusColor() {
    final theme = Theme.of(context);
    final themeState = ref.watch(enhancedThemeProvider);
    final themeId = themeState.currentTheme?.metadata.id ?? '';
    
    if (themeId.contains('matrix')) {
      // Matrix themed status colors
      switch (widget.task.status) {
        case TaskStatus.pending:
          return const Color(0xFF006600);
        case TaskStatus.inProgress:
          return const Color(0xFF00FF00);
        case TaskStatus.completed:
          return const Color(0xFF00CC00);
        case TaskStatus.cancelled:
          return const Color(0xFF990000);
      }
    } else if (themeId.contains('vegeta')) {
      // Vegeta themed status colors
      switch (widget.task.status) {
        case TaskStatus.pending:
          return const Color(0xFF1e3a8a);
        case TaskStatus.inProgress:
          return const Color(0xFF60a5fa);
        case TaskStatus.completed:
          return const Color(0xFF93c5fd);
        case TaskStatus.cancelled:
          return const Color(0xFFdc2626);
      }
    } else if (themeId.contains('dracula')) {
      // Dracula themed status colors
      switch (widget.task.status) {
        case TaskStatus.pending:
          return const Color(0xFF8be9fd); // Cyan
        case TaskStatus.inProgress:
          return const Color(0xFFffb86c); // Orange
        case TaskStatus.completed:
          return const Color(0xFF50fa7b); // Green
        case TaskStatus.cancelled:
          return const Color(0xFFff5555); // Red
      }
    }
    
    // Default Material 3 colors for expressive and other themes
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
        // Task title with improved typography and audio indicator
        Row(
          children: [
            Expanded(
              child: Text(
                widget.task.title,
                style: TextStyle(
                  fontSize: TypographyConstants.textLG, // 18px for better hierarchy
                  fontWeight: TypographyConstants.semiBold,
                  color: theme.colorScheme.onSurface,
                  decoration: widget.task.status == TaskStatus.completed 
                    ? TextDecoration.lineThrough 
                    : null,
                  height: 1.3,
                ),
                maxLines: 2, // Allow 2 lines for better readability
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Audio indicator for voice tasks
            if (widget.task.hasAudio) ...[
              const SizedBox(width: 8),
              AudioIndicatorWidget(
                taskId: widget.task.id,
                audioFilePath: widget.task.audioFilePath,
                duration: widget.task.audioDuration,
                size: 22, // Increased from 16 to make it more visible
                // Remove onTap override - let it use default audio play behavior
              ),
            ],
          ],
        ),
        
        if (widget.task.description != null && widget.task.description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.task.description!,
            style: TextStyle(
              fontSize: TypographyConstants.textSM, // 14px for description
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            maxLines: 2, // Allow 2 lines for descriptions
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildMetadataRow(ThemeData theme) {
    // Only show tags, no status badges since they're already shown at the top
    if (widget.task.tags.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        // Show first 2 tags
        ...widget.task.tags.take(2).map((tag) => _buildTag(tag, theme)),
        
        // Show "more" indicator if there are more than 2 tags
        if (widget.task.tags.length > 2)
          _buildMoreTagsIndicator(theme),
      ],
    );
  }

  Widget _buildTag(String tag, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.interactive, // Use interactive level for tags
      borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      // Let glassmorphism auto-determine tint based on theme
      child: Text(
        '#$tag',
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: TypographyConstants.textXS, // 12px for tags
          fontWeight: TypographyConstants.medium,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMoreTagsIndicator(ThemeData theme) {
    return Semantics(
      label: '${widget.task.tags.length - 3} more tags',
      hint: 'Tap to view all tags',
      button: true,
      child: GestureDetector(
        onTap: () {
          _showAllTagsDialog();
        },
        child: GlassmorphismContainer(
          level: GlassLevel.interactive,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          glassTint: theme.colorScheme.outline.withOpacity(0.2),
          child: Text(
            '+${widget.task.tags.length - 3}',
            style: TextStyle(
              fontSize: TypographyConstants.textXS,
              fontWeight: TypographyConstants.medium,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
    return AccessibleIconButton(
      icon: icon,
      onPressed: () {
        HapticFeedback.selectionClick();
        onPressed();
      },
      iconColor: color,
      iconSize: 20, // Improved icon size for better visibility
      minTouchTarget: AccessibilityConstants.minTouchTarget,
      padding: const EdgeInsets.all(2),
      tooltip: _getActionTooltip(icon),
    );
  }

  String _getActionTooltip(IconData icon) {
    if (icon == Icons.check_circle || icon == Icons.radio_button_unchecked) {
      return widget.task.status == TaskStatus.completed ? 'Mark as incomplete' : 'Mark as complete';
    } else if (icon == Icons.edit) {
      return 'Edit task';
    } else if (icon == Icons.share) {
      return 'Share task';
    }
    return 'Task action';
  }

  Widget _buildActionsPanel(ThemeData theme) {
    return Positioned.fill(
      child: GlassmorphismContainer(
        level: GlassLevel.floating, // Use floating level for swipe actions
        borderRadius: BorderRadius.circular(TypographyConstants.taskCardRadius),
        glassTint: _swipeDirection == SwipeDirection.left
          ? theme.colorScheme.error.withOpacity(0.2)
          : theme.colorScheme.primary.withOpacity(0.2),
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
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        borderRadius: BorderRadius.circular(TypographyConstants.taskCardRadius),
        glassTint: theme.colorScheme.tertiary.withOpacity(0.2 * _completeAnimation.value),
        child: Center(
          child: Transform.scale(
            scale: _completeAnimation.value,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.tertiary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.check,
                color: theme.colorScheme.onTertiary,
                size: 32,
              ),
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


  String _formatCreatedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return '${difference}d ago';
  }

  // New helper methods for enhanced status indicators
  double _getStatusDotSize() {
    switch (widget.task.priority) {
      case TaskPriority.urgent:
        return widget.task.status == TaskStatus.inProgress ? 20 : 18; // Much larger for urgent
      case TaskPriority.high:
        return widget.task.status == TaskStatus.inProgress ? 18 : 16;
      case TaskPriority.medium:
        return widget.task.status == TaskStatus.inProgress ? 16 : 14;
      case TaskPriority.low:
        return widget.task.status == TaskStatus.inProgress ? 14 : 12;
    }
  }

  double _getPriorityDotSize() {
    switch (widget.task.priority) {
      case TaskPriority.urgent:
        return 10;
      case TaskPriority.high:
        return 8;
      case TaskPriority.medium:
        return 7;
      case TaskPriority.low:
        return 6;
    }
  }

  // Event handlers
  void _setHovered(bool hovered) {
    if (_isHovered != hovered) {
      setState(() => _isHovered = hovered);
      if (hovered) {
        _interactionController.animateTo(0.3); // Hover to 30% of the interaction
      } else {
        _interactionController.animateTo(0.0);
      }
    }
  }

  void _onTapDown(TapDownDetails details) {
    _interactionController.animateTo(0.6); // Press to 60% of the interaction
  }

  void _onTapUp(TapUpDetails details) {
    _interactionController.animateTo(_isHovered ? 0.3 : 0.0); // Return to hover or idle
  }

  void _onTapCancel() {
    _interactionController.animateTo(_isHovered ? 0.3 : 0.0); // Return to hover or idle
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
    _interactionController.value = progress; // Use interaction controller for swipe
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
    _interactionController.animateTo(0.0);
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
      _interactionController.animateTo(1.0); // Complete animation to 100%
      HapticFeedback.heavyImpact();
    } else {
      _interactionController.animateTo(0.0);
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
    // OPTIMIZED: Only 2 controllers to dispose now
    _interactionController.dispose();
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