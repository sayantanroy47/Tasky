import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/phosphor_icons.dart';
import '../../../core/theme/typography_constants.dart';
import '../../../core/design_system/design_tokens.dart';
import '../../../domain/entities/task_model.dart';
import '../../../domain/models/enums.dart';
import '../../../services/bulk_operations/task_selection_manager.dart';
import '../glassmorphism_container.dart';
import '../advanced_task_card.dart';

/// Enhanced task card with multi-select capabilities
/// 
/// This widget wraps existing task cards with multi-select functionality,
/// including selection indicators, keyboard shortcuts, and smooth animations.
class MultiSelectTaskCard extends ConsumerStatefulWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final Widget? child;
  final bool enableMultiSelect;
  final bool showSelectionIndicator;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  
  const MultiSelectTaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.child,
    this.enableMultiSelect = true,
    this.showSelectionIndicator = true,
    this.padding,
    this.margin,
  });

  @override
  ConsumerState<MultiSelectTaskCard> createState() => _MultiSelectTaskCardState();
}

class _MultiSelectTaskCardState extends ConsumerState<MultiSelectTaskCard>
    with TickerProviderStateMixin {
  late AnimationController _selectionController;
  late AnimationController _highlightController;
  late Animation<double> _selectionAnimation;
  late Animation<double> _highlightAnimation;
  late Animation<Color?> _backgroundAnimation;
  
  bool _isHovering = false;
  
  @override
  void initState() {
    super.initState();
    
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _selectionAnimation = CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeOutCubic,
    );
    
    _highlightAnimation = CurvedAnimation(
      parent: _highlightController,
      curve: Curves.easeInOut,
    );
    
    _backgroundAnimation = ColorTween(
      begin: Colors.transparent,
      end: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
    ).animate(_highlightController);
  }
  
  @override
  void dispose() {
    _selectionController.dispose();
    _highlightController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectionState = ref.watch(taskSelectionProvider);
    final isSelected = selectionState.isSelected(widget.task.id);
    final isMultiSelectMode = selectionState.isMultiSelectMode;
    
    // Update selection animation
    if (isSelected) {
      _selectionController.forward();
    } else {
      _selectionController.reverse();
    }
    
    return AnimatedBuilder(
      animation: Listenable.merge([_selectionAnimation, _backgroundAnimation]),
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: GestureDetector(
            onTap: () => _handleTap(context),
            onLongPress: widget.enableMultiSelect 
                ? () => _handleLongPress(context) 
                : null,
            child: Stack(
              children: [
                // Main card
                Transform.scale(
                  scale: 1.0 - (_selectionAnimation.value * 0.02),
                  child: Container(
                    margin: widget.margin ?? const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                      color: _backgroundAnimation.value,
                      border: isSelected
                          ? Border.all(
                              color: theme.colorScheme.primary,
                              width: 2.0,
                            )
                          : null,
                    ),
                    child: widget.child ?? Padding(
                      padding: widget.padding ?? EdgeInsets.zero,
                      child: AdvancedTaskCard(
                        task: widget.task,
                        onTap: null, // Handled by parent
                      ),
                    ),
                  ),
                ),
                
                // Selection overlay
                if (isMultiSelectMode && widget.showSelectionIndicator)
                  _buildSelectionOverlay(theme, isSelected),
                
                // Hover effects
                if (_isHovering && !isSelected)
                  _buildHoverOverlay(theme),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildSelectionOverlay(ThemeData theme, bool isSelected) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _selectionAnimation,
        builder: (context, child) {
          return Container(
            margin: widget.margin ?? const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              color: theme.colorScheme.primary.withValues(
                alpha: _selectionAnimation.value * 0.1,
              ),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(
                  alpha: _selectionAnimation.value,
                ),
                width: 2.0 * _selectionAnimation.value,
              ),
            ),
            child: Stack(
              children: [
                // Selection indicator
                Positioned(
                  top: 12,
                  right: 12,
                  child: Transform.scale(
                    scale: _selectionAnimation.value,
                    child: GlassmorphismContainer(
                      level: GlassLevel.floating,
                      width: 24,
                      height: 24,
                      borderRadius: BorderRadius.circular(12),
                      child: Icon(
                        isSelected
                            ? PhosphorIconConstants.allIcons['check-circle']!
                            : PhosphorIconConstants.allIcons['circle']!,
                        size: 16,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
                
                // Ripple effect on selection
                if (isSelected)
                  Positioned.fill(
                    child: _buildRippleEffect(theme),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildHoverOverlay(ThemeData theme) {
    return Positioned.fill(
      child: Container(
        margin: widget.margin ?? const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            width: 1.0,
          ),
        ),
      ),
    );
  }
  
  Widget _buildRippleEffect(ThemeData theme) {
    return AnimatedBuilder(
      animation: _highlightAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            gradient: RadialGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.2 * _highlightAnimation.value),
                Colors.transparent,
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        );
      },
    );
  }
  
  void _handleTap(BuildContext context) {
    final selectionNotifier = ref.read(taskSelectionProvider.notifier);
    
    final currentState = selectionNotifier.state;
    if (currentState.isMultiSelectMode) {
      // In multi-select mode, toggle selection
      selectionNotifier.toggleTask(widget.task);
      _triggerRipple();
    } else {
      // Normal tap behavior
      widget.onTap?.call();
    }
  }
  
  void _handleLongPress(BuildContext context) {
    if (!widget.enableMultiSelect) return;
    
    final selectionNotifier = ref.read(taskSelectionProvider.notifier);
    
    // Enable multi-select mode and select this task
    final currentState = selectionNotifier.state;
    if (!currentState.isMultiSelectMode) {
      selectionNotifier.enableMultiSelect();
    }
    
    selectionNotifier.toggleTask(widget.task);
    _triggerRipple();
    
    // Haptic feedback for long press
    HapticFeedback.mediumImpact();
  }
  
  void _triggerRipple() {
    _highlightController.forward().then((_) {
      _highlightController.reverse();
    });
  }
}

/// Multi-select enhanced version of the list view for tasks
class MultiSelectTaskList extends ConsumerStatefulWidget {
  final List<TaskModel> tasks;
  final Widget Function(BuildContext context, TaskModel task, int index)? itemBuilder;
  final bool enableMultiSelect;
  final Function(TaskModel task)? onTaskTap;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;
  
  const MultiSelectTaskList({
    super.key,
    required this.tasks,
    this.itemBuilder,
    this.enableMultiSelect = true,
    this.onTaskTap,
    this.scrollController,
    this.padding,
  });

  @override
  ConsumerState<MultiSelectTaskList> createState() => _MultiSelectTaskListState();
}

class _MultiSelectTaskListState extends ConsumerState<MultiSelectTaskList> {
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }
  
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: ListView.builder(
        controller: widget.scrollController,
        padding: widget.padding,
        itemCount: widget.tasks.length,
        itemBuilder: (context, index) {
          final task = widget.tasks[index];
          
          return widget.itemBuilder?.call(context, task, index) ?? 
              MultiSelectTaskCard(
                task: task,
                enableMultiSelect: widget.enableMultiSelect,
                onTap: () => widget.onTaskTap?.call(task),
              );
        },
      ),
    );
  }
  
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    
    final selectionNotifier = ref.read(taskSelectionProvider.notifier);
    final currentSelection = selectionNotifier.state;
    
    // Check for modifier keys using HardwareKeyboard
    final isCtrlOrCmd = HardwareKeyboard.instance.isControlPressed ||
                      HardwareKeyboard.instance.isMetaPressed;
    
    // Handle keyboard shortcuts
    if (event.logicalKey == LogicalKeyboardKey.keyA && isCtrlOrCmd) {
      // Ctrl+A / Cmd+A - Select all
      if (currentSelection.isMultiSelectMode) {
        selectionNotifier.selectAll(widget.tasks);
        HapticFeedback.mediumImpact();
        return KeyEventResult.handled;
      }
    }
    
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      // Escape - Clear selection or exit multi-select mode
      if (currentSelection.hasSelection) {
        selectionNotifier.deselectAll();
        HapticFeedback.selectionClick();
        return KeyEventResult.handled;
      } else if (currentSelection.isMultiSelectMode) {
        selectionNotifier.disableMultiSelect();
        HapticFeedback.selectionClick();
        return KeyEventResult.handled;
      }
    }
    
    if (event.logicalKey == LogicalKeyboardKey.keyI && isCtrlOrCmd) {
      // Ctrl+I / Cmd+I - Invert selection
      if (currentSelection.isMultiSelectMode) {
        selectionNotifier.invertSelection(widget.tasks);
        HapticFeedback.mediumImpact();
        return KeyEventResult.handled;
      }
    }
    
    // Quick selection by status
    if (event.logicalKey == LogicalKeyboardKey.digit1 && isCtrlOrCmd) {
      if (currentSelection.isMultiSelectMode) {
        selectionNotifier.selectByStatus(widget.tasks, TaskStatus.pending);
        HapticFeedback.lightImpact();
        return KeyEventResult.handled;
      }
    }
    
    if (event.logicalKey == LogicalKeyboardKey.digit2 && isCtrlOrCmd) {
      if (currentSelection.isMultiSelectMode) {
        selectionNotifier.selectByStatus(widget.tasks, TaskStatus.inProgress);
        HapticFeedback.lightImpact();
        return KeyEventResult.handled;
      }
    }
    
    if (event.logicalKey == LogicalKeyboardKey.digit3 && isCtrlOrCmd) {
      if (currentSelection.isMultiSelectMode) {
        selectionNotifier.selectByStatus(widget.tasks, TaskStatus.completed);
        HapticFeedback.lightImpact();
        return KeyEventResult.handled;
      }
    }
    
    return KeyEventResult.ignored;
  }
}

/// Selection toolbar that appears at the bottom of multi-select lists
class MultiSelectToolbar extends ConsumerWidget {
  final List<TaskModel> allTasks;
  final VoidCallback? onClearSelection;
  final Function(List<TaskModel>)? onBulkAction;
  
  const MultiSelectToolbar({
    super.key,
    required this.allTasks,
    this.onClearSelection,
    this.onBulkAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectionState = ref.watch(taskSelectionProvider);
    
    if (!selectionState.hasSelection || !selectionState.isMultiSelectMode) {
      return const SizedBox.shrink();
    }
    
    return AnimatedSlide(
      offset: selectionState.hasSelection ? Offset.zero : const Offset(0.0, 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        padding: const EdgeInsets.all(SpacingTokens.md),
        margin: const EdgeInsets.all(SpacingTokens.md),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        child: Row(
          children: [
            // Selection count
            Expanded(
              child: Row(
                children: [
                  Icon(
                    PhosphorIconConstants.allIcons['check-circle']!,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Text(
                    '${selectionState.selectionCount} selected',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Quick actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Select all
                IconButton(
                  onPressed: () {
                    final notifier = ref.read(taskSelectionProvider.notifier);
                    if (selectionState.selectionCount == allTasks.length) {
                      notifier.deselectAll();
                    } else {
                      notifier.selectAll(allTasks);
                    }
                    HapticFeedback.mediumImpact();
                  },
                  icon: Icon(
                    selectionState.selectionCount == allTasks.length
                        ? PhosphorIconConstants.allIcons['minus-circle']!
                        : PhosphorIconConstants.allIcons['plus-circle']!,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  tooltip: selectionState.selectionCount == allTasks.length
                      ? 'Deselect all'
                      : 'Select all',
                ),
                
                // Bulk actions
                IconButton(
                  onPressed: () {
                    onBulkAction?.call(selectionState.selectedTasksList);
                  },
                  icon: Icon(
                    PhosphorIconConstants.allIcons['dots-three']!,
                    color: theme.colorScheme.primary,
                  ),
                  tooltip: 'Bulk actions',
                ),
                
                // Clear selection
                IconButton(
                  onPressed: () {
                    ref.read(taskSelectionProvider.notifier).deselectAll();
                    onClearSelection?.call();
                    HapticFeedback.selectionClick();
                  },
                  icon: Icon(
                    PhosphorIconConstants.allIcons['x']!,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  tooltip: 'Clear selection',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Keyboard shortcuts help overlay
class MultiSelectKeyboardHelp extends StatelessWidget {
  const MultiSelectKeyboardHelp({super.key});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  PhosphorIconConstants.allIcons['keyboard']!,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: SpacingTokens.sm),
                Text(
                  'Keyboard Shortcuts',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: SpacingTokens.lg),
            
            // Shortcuts list
            ..._shortcuts.map((shortcut) => _buildShortcutItem(
              theme,
              shortcut.keys,
              shortcut.description,
            )),
            
            const SizedBox(height: SpacingTokens.lg),
            
            // Close button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildShortcutItem(ThemeData theme, String keys, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.sm,
              vertical: SpacingTokens.xs,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Text(
              keys,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Text(
              description,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
  
  static const List<KeyboardShortcut> _shortcuts = [
    KeyboardShortcut('Ctrl+A', 'Select all tasks'),
    KeyboardShortcut('Ctrl+I', 'Invert selection'),
    KeyboardShortcut('Esc', 'Clear selection / Exit multi-select'),
    KeyboardShortcut('Ctrl+1', 'Select pending tasks'),
    KeyboardShortcut('Ctrl+2', 'Select in-progress tasks'),
    KeyboardShortcut('Ctrl+3', 'Select completed tasks'),
    KeyboardShortcut('Long press', 'Enter multi-select mode'),
  ];
}

class KeyboardShortcut {
  final String keys;
  final String description;
  
  const KeyboardShortcut(this.keys, this.description);
}

/// Import missing enums and providers

/// Placeholder provider (will be implemented in providers file)
final taskSelectionProvider = StateNotifierProvider<TaskSelectionManager, TaskSelectionState>((ref) {
  return TaskSelectionManager();
});