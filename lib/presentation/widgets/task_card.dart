import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import 'highlighted_text.dart';

/// Enhanced task card widget with swipe gestures, haptic feedback, and animations
class TaskCard extends StatefulWidget {
  final String title;
  final String? description;
  final bool isCompleted;
  final int priority;
  final DateTime? dueDate;
  final List<String> tags;
  final int? subTasksTotal;
  final int? subTasksCompleted;
  final String? searchQuery;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const TaskCard({
    super.key,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = 1,
    this.dueDate,
    this.tags = const [],
    this.subTasksTotal,
    this.subTasksCompleted,
    this.searchQuery,
    this.onTap,
    this.onToggleComplete,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _completionController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _completionAnimation;
  
  bool _isDragging = false;
  double _dragExtent = 0.0;
  static const double _swipeThreshold = 0.4;
  static const double _maxSlideExtent = 100.0;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _completionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Initialize animations
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _completionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _completionController,
      curve: Curves.elasticOut,
    ));
    
    // Set initial completion state
    if (widget.isCompleted) {
      _completionController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Animate completion state changes
    if (widget.isCompleted != oldWidget.isCompleted) {
      if (widget.isCompleted) {
        _completionController.forward();
      } else {
        _completionController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = AppColors.getPriorityColor(widget.priority);
    
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _completionAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Stack(
              children: [
                // Background action indicators
                _buildSwipeBackground(theme),
                
                // Main card with gesture detection
                GestureDetector(
                  onTap: () {
                    _triggerHapticFeedback(HapticFeedback.lightImpact);
                    widget.onTap?.call();
                  },
                  onTapDown: (_) => _scaleController.forward(),
                  onTapUp: (_) => _scaleController.reverse(),
                  onTapCancel: () => _scaleController.reverse(),
                  onHorizontalDragStart: _handleDragStart,
                  onHorizontalDragUpdate: _handleDragUpdate,
                  onHorizontalDragEnd: _handleDragEnd,
                  child: Transform.translate(
                    offset: Offset(_dragExtent, 0),
                    child: _buildMainCard(theme, priorityColor),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build the swipe background with action indicators
  Widget _buildSwipeBackground(ThemeData theme) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: _dragExtent > 0
                ? [
                    theme.colorScheme.primary.withOpacity( 0.1),
                    theme.colorScheme.primary.withOpacity( 0.1),
                  ]
                : [
                    theme.colorScheme.error.withOpacity( 0.1),
                    theme.colorScheme.error.withOpacity( 0.1),
                  ],
          ),
        ),
        child: Row(
          children: [
            // Left action (complete)
            if (_dragExtent > 0) ...[
              const SizedBox(width: 16),
              AnimatedOpacity(
                opacity: (_dragExtent / _maxSlideExtent).clamp(0.0, 1.0),
                duration: const Duration(milliseconds: 100),
                child: Icon(
                  widget.isCompleted ? Icons.undo : Icons.check,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ],
            
            const Spacer(),
            
            // Right action (delete)
            if (_dragExtent < 0) ...[
              AnimatedOpacity(
                opacity: ((-_dragExtent) / _maxSlideExtent).clamp(0.0, 1.0),
                duration: const Duration(milliseconds: 100),
                child: Icon(
                  Icons.delete,
                  color: theme.colorScheme.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ],
        ),
      ),
    );
  }

  /// Build the main card content
  Widget _buildMainCard(ThemeData theme, Color priorityColor) {
    return AnimatedBuilder(
      animation: _completionAnimation,
      builder: (context, child) {
        return Card(
          elevation: _isDragging ? 8 : 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surface,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with checkbox and actions
                    Row(
                      children: [
                        // Animated completion checkbox
                        GestureDetector(
                          onTap: () {
                            _triggerHapticFeedback(HapticFeedback.mediumImpact);
                            widget.onToggleComplete?.call();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.isCompleted
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline,
                                width: 2,
                              ),
                              color: widget.isCompleted
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                            ),
                            child: widget.isCompleted
                                ? Transform.scale(
                                    scale: _completionAnimation.value,
                                    child: Icon(
                                      Icons.check,
                                      size: 16,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Animated priority indicator
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity( 0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Title and description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HighlightedText(
                                text: widget.title,
                                searchQuery: widget.searchQuery,
                                style: theme.textTheme.titleMedium!.copyWith(
                                  decoration: widget.isCompleted 
                                      ? TextDecoration.lineThrough 
                                      : null,
                                  color: widget.isCompleted 
                                      ? theme.colorScheme.onSurfaceVariant 
                                      : theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.description != null && widget.description!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                HighlightedText(
                                  text: widget.description!,
                                  searchQuery: widget.searchQuery,
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant.withOpacity( 0.1),
                                    decoration: widget.isCompleted 
                                        ? TextDecoration.lineThrough 
                                        : null,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              
                              // Subtask progress indicator
                              if (widget.subTasksTotal != null && widget.subTasksTotal! > 0) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.checklist,
                                      size: 14,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.subTasksCompleted ?? 0}/${widget.subTasksTotal}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: widget.subTasksTotal! > 0 
                                            ? (widget.subTasksCompleted ?? 0) / widget.subTasksTotal!
                                            : 0.0,
                                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          theme.colorScheme.primary.withOpacity( 0.1),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        // Actions menu
                        if (widget.showActions)
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              _triggerHapticFeedback(HapticFeedback.lightImpact);
                              switch (value) {
                                case 'edit':
                                  widget.onEdit?.call();
                                  break;
                                case 'delete':
                                  widget.onDelete?.call();
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Edit'),
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
                      ],
                    ),
                    
                    // Footer with due date and tags
                    if (widget.dueDate != null || widget.tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Due date
                          if (widget.dueDate != null) ...[
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: _getDueDateColor(theme),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDueDate(widget.dueDate!),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _getDueDateColor(theme),
                                fontWeight: _isOverdue(widget.dueDate!) 
                                    ? FontWeight.bold 
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          
                          // Tags
                          Expanded(
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: widget.tags.take(3).map((tag) => _TagChip(
                                label: tag,
                                color: AppColors.getTagColor(widget.tags.indexOf(tag)),
                              )).toList(),
                            ),
                          ),
                          
                          // More tags indicator
                          if (widget.tags.length > 3)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '+${widget.tags.length - 3}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Handle drag start
  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    _triggerHapticFeedback(HapticFeedback.lightImpact);
  }

  /// Handle drag update
  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent = (_dragExtent + details.delta.dx).clamp(-_maxSlideExtent, _maxSlideExtent);
    });
    
    // Provide haptic feedback at threshold
    if (_dragExtent.abs() >= _maxSlideExtent * _swipeThreshold && 
        _dragExtent.abs() < _maxSlideExtent * _swipeThreshold + 5) {
      _triggerHapticFeedback(HapticFeedback.mediumImpact);
    }
  }

  /// Handle drag end
  void _handleDragEnd(DragEndDetails details) {
    final shouldTriggerAction = _dragExtent.abs() >= _maxSlideExtent * _swipeThreshold;
    
    if (shouldTriggerAction) {
      _triggerHapticFeedback(HapticFeedback.heavyImpact);
      
      if (_dragExtent > 0) {
        // Swipe right - toggle completion
        widget.onToggleComplete?.call();
      } else {
        // Swipe left - delete
        widget.onDelete?.call();
      }
    }
    
    // Reset drag state
    setState(() {
      _isDragging = false;
      _dragExtent = 0.0;
    });
  }

  /// Trigger haptic feedback
  void _triggerHapticFeedback(void Function() feedback) {
    try {
      feedback();
    } catch (e) {
      // Haptic feedback might not be available on all devices
      debugPrint('Haptic feedback not available: $e');
    }
  }

  Color _getDueDateColor(ThemeData theme) {
    if (widget.dueDate == null) return theme.colorScheme.onSurfaceVariant;
    
    if (_isOverdue(widget.dueDate!)) {
      return theme.colorScheme.error;
    } else if (_isDueToday(widget.dueDate!)) {
      return Colors.orange;
    } else {
      return theme.colorScheme.onSurfaceVariant;
    }
  }

  bool _isOverdue(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(date.year, date.month, date.day);
    return dueDay.isBefore(today);
  }

  bool _isDueToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(date.year, date.month, date.day);
    return dueDay.isAtSameMomentAs(today);
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDay = DateTime(date.year, date.month, date.day);
    
    if (dueDay.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (dueDay.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else if (_isOverdue(date)) {
      final difference = today.difference(dueDay).inDays;
      return '$difference day${difference == 1 ? '' : 's'} overdue';
    } else {
      final difference = dueDay.difference(today).inDays;
      if (difference <= 7) {
        return 'In $difference day${difference == 1 ? '' : 's'}';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    }
  }
}

/// Tag chip widget
class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity( 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity( 0.1)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
