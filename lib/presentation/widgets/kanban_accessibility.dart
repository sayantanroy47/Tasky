import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/accessibility/accessibility_constants.dart';
import 'kanban_board_view.dart';

/// Accessibility enhancements for Kanban board
/// 
/// Provides:
/// - Screen reader support
/// - Keyboard navigation
/// - High contrast mode support
/// - Focus management
/// - Semantic labeling
/// - Voice announcements
class KanbanAccessibilityManager {
  static const Duration _announcementDelay = Duration(milliseconds: 100);

  /// Announce task movement to screen readers
  static void announceTaskMovement(
    BuildContext context,
    TaskModel task,
    TaskStatus fromStatus,
    TaskStatus toStatus,
  ) {
    Future.delayed(_announcementDelay, () {
      final message = 'Task "${task.title}" moved from ${fromStatus.displayName} to ${toStatus.displayName}';
      SemanticsService.announce(message, TextDirection.ltr);
    });
  }

  /// Announce batch operation completion
  static void announceBatchOperation(
    BuildContext context,
    String operation,
    int taskCount,
  ) {
    Future.delayed(_announcementDelay, () {
      final message = '$operation completed for $taskCount task${taskCount != 1 ? 's' : ''}';
      SemanticsService.announce(message, TextDirection.ltr);
    });
  }

  /// Announce filter changes
  static void announceFilterChange(
    BuildContext context,
    String filterDescription,
    int resultCount,
  ) {
    Future.delayed(_announcementDelay, () {
      final message = 'Filter applied: $filterDescription. Showing $resultCount result${resultCount != 1 ? 's' : ''}';
      SemanticsService.announce(message, TextDirection.ltr);
    });
  }

  /// Create accessible task card semantics
  static Widget wrapTaskCardWithSemantics({
    required Widget child,
    required TaskModel task,
    required VoidCallback? onTap,
    required VoidCallback? onLongPress,
    required Function(TaskStatus)? onStatusChanged,
    bool isSelected = false,
  }) {
    return Semantics(
      label: _buildTaskSemanticsLabel(task),
      hint: _buildTaskSemanticsHint(task, isSelected),
      button: true,
      enabled: true,
      focused: isSelected,
      selected: isSelected,
      onTap: onTap,
      onLongPress: onLongPress,
      customSemanticsActions: _buildTaskSemanticsActions(task, onStatusChanged),
      child: child,
    );
  }

  /// Create accessible column semantics
  static Widget wrapColumnWithSemantics({
    required Widget child,
    required KanbanColumnConfig config,
    required int taskCount,
    required VoidCallback? onAddTask,
    required VoidCallback? onToggleCollapse,
  }) {
    return Semantics(
      label: '${config.title} column',
      hint: 'Contains $taskCount task${taskCount != 1 ? 's' : ''}. Double tap to ${config.isCollapsible ? 'collapse' : 'add task'}',
      container: true,
      onTap: config.isCollapsible ? onToggleCollapse : onAddTask,
      customSemanticsActions: {
        if (onAddTask != null)
          const CustomSemanticsAction(label: 'Add task'): onAddTask,
        if (onToggleCollapse != null && config.isCollapsible)
          const CustomSemanticsAction(label: 'Toggle collapse'): onToggleCollapse,
      },
      child: child,
    );
  }

  /// Build task semantics label
  static String _buildTaskSemanticsLabel(TaskModel task) {
    final parts = <String>[];
    
    parts.add('Task: ${task.title}');
    
    if (task.description?.isNotEmpty == true) {
      parts.add('Description: ${task.description}');
    }
    
    parts.add('Priority: ${task.priority.displayName}');
    parts.add('Status: ${task.status.displayName}');
    
    if (task.dueDate != null) {
      parts.add('Due: ${_formatDateForAccessibility(task.dueDate!)}');
      if (task.isOverdue) {
        parts.add('Overdue');
      }
    }
    
    if (task.tags.isNotEmpty) {
      parts.add('Tags: ${task.tags.join(', ')}');
    }
    
    if (task.hasSubTasks) {
      final completedSubtasks = task.subTasks.where((st) => st.isCompleted).length;
      parts.add('Subtasks: $completedSubtasks of ${task.subTasks.length} completed');
    }
    
    return parts.join('. ');
  }

  /// Build task semantics hint
  static String _buildTaskSemanticsHint(TaskModel task, bool isSelected) {
    final parts = <String>[];
    
    if (isSelected) {
      parts.add('Selected');
    }
    
    parts.add('Double tap to open');
    parts.add('Long press for options');
    
    if (!task.isCompleted) {
      parts.add('Swipe to complete');
    }
    
    return parts.join('. ');
  }

  /// Build task custom semantics actions
  static Map<CustomSemanticsAction, VoidCallback> _buildTaskSemanticsActions(
    TaskModel task,
    Function(TaskStatus)? onStatusChanged,
  ) {
    final actions = <CustomSemanticsAction, VoidCallback>{};
    
    if (!task.isCompleted && onStatusChanged != null) {
      actions[const CustomSemanticsAction(label: 'Mark as completed')] = 
          () => onStatusChanged(TaskStatus.completed);
    }
    
    if (task.isCompleted && onStatusChanged != null) {
      actions[const CustomSemanticsAction(label: 'Mark as pending')] = 
          () => onStatusChanged(TaskStatus.pending);
    }
    
    if (task.status != TaskStatus.inProgress && onStatusChanged != null) {
      actions[const CustomSemanticsAction(label: 'Mark as in progress')] = 
          () => onStatusChanged(TaskStatus.inProgress);
    }
    
    return actions;
  }

  /// Format date for accessibility
  static String _formatDateForAccessibility(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'today';
    } else if (difference == 1) {
      return 'tomorrow';
    } else if (difference == -1) {
      return 'yesterday';
    } else if (difference > 1) {
      return 'in $difference days';
    } else {
      return '${difference.abs()} days ago';
    }
  }
}

/// Keyboard navigation support for Kanban board
class KanbanKeyboardHandler extends StatefulWidget {
  final Widget child;
  final List<KanbanColumnConfig> columns;
  final Map<TaskStatus, List<TaskModel>> tasks;
  final Function(TaskModel, TaskStatus)? onTaskMoved;
  final Function(TaskModel)? onTaskSelected;

  const KanbanKeyboardHandler({
    super.key,
    required this.child,
    required this.columns,
    required this.tasks,
    this.onTaskMoved,
    this.onTaskSelected,
  });

  @override
  State<KanbanKeyboardHandler> createState() => _KanbanKeyboardHandlerState();
}

class _KanbanKeyboardHandlerState extends State<KanbanKeyboardHandler> {
  int _selectedColumnIndex = 0;
  int _selectedTaskIndex = 0;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
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
      child: widget.child,
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final currentColumn = widget.columns[_selectedColumnIndex];
    final currentTasks = widget.tasks[currentColumn.status] ?? [];

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        _moveToColumn(_selectedColumnIndex - 1);
        return KeyEventResult.handled;
        
      case LogicalKeyboardKey.arrowRight:
        _moveToColumn(_selectedColumnIndex + 1);
        return KeyEventResult.handled;
        
      case LogicalKeyboardKey.arrowUp:
        _moveToTask(_selectedTaskIndex - 1);
        return KeyEventResult.handled;
        
      case LogicalKeyboardKey.arrowDown:
        _moveToTask(_selectedTaskIndex + 1);
        return KeyEventResult.handled;
        
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.space:
        _selectCurrentTask();
        return KeyEventResult.handled;
        
      case LogicalKeyboardKey.keyM:
        if (event.isControlPressed || event.isMetaPressed) {
          _moveTaskToNextColumn();
          return KeyEventResult.handled;
        }
        break;
        
      case LogicalKeyboardKey.keyC:
        if (event.isControlPressed || event.isMetaPressed) {
          _completeCurrentTask();
          return KeyEventResult.handled;
        }
        break;
        
      case LogicalKeyboardKey.escape:
        _clearSelection();
        return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _moveToColumn(int columnIndex) {
    if (columnIndex < 0 || columnIndex >= widget.columns.length) return;
    
    setState(() {
      _selectedColumnIndex = columnIndex;
      _selectedTaskIndex = 0; // Reset task selection
    });
    
    _announceCurrentSelection();
  }

  void _moveToTask(int taskIndex) {
    final currentColumn = widget.columns[_selectedColumnIndex];
    final currentTasks = widget.tasks[currentColumn.status] ?? [];
    
    if (taskIndex < 0 || taskIndex >= currentTasks.length) return;
    
    setState(() {
      _selectedTaskIndex = taskIndex;
    });
    
    _announceCurrentSelection();
  }

  void _selectCurrentTask() {
    final currentColumn = widget.columns[_selectedColumnIndex];
    final currentTasks = widget.tasks[currentColumn.status] ?? [];
    
    if (_selectedTaskIndex < currentTasks.length) {
      final task = currentTasks[_selectedTaskIndex];
      widget.onTaskSelected?.call(task);
      
      SemanticsService.announce(
        'Selected task: ${task.title}',
        TextDirection.ltr,
      );
    }
  }

  void _moveTaskToNextColumn() {
    final currentColumn = widget.columns[_selectedColumnIndex];
    final currentTasks = widget.tasks[currentColumn.status] ?? [];
    
    if (_selectedTaskIndex >= currentTasks.length) return;
    
    final task = currentTasks[_selectedTaskIndex];
    final nextColumnIndex = (_selectedColumnIndex + 1) % widget.columns.length;
    final nextColumn = widget.columns[nextColumnIndex];
    
    widget.onTaskMoved?.call(task, nextColumn.status);
    
    KanbanAccessibilityManager.announceTaskMovement(
      context,
      task,
      currentColumn.status,
      nextColumn.status,
    );
  }

  void _completeCurrentTask() {
    final currentColumn = widget.columns[_selectedColumnIndex];
    final currentTasks = widget.tasks[currentColumn.status] ?? [];
    
    if (_selectedTaskIndex >= currentTasks.length) return;
    
    final task = currentTasks[_selectedTaskIndex];
    widget.onTaskMoved?.call(task, TaskStatus.completed);
    
    SemanticsService.announce(
      'Task "${task.title}" marked as completed',
      TextDirection.ltr,
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedColumnIndex = 0;
      _selectedTaskIndex = 0;
    });
    
    SemanticsService.announce(
      'Selection cleared',
      TextDirection.ltr,
    );
  }

  void _announceCurrentSelection() {
    final currentColumn = widget.columns[_selectedColumnIndex];
    final currentTasks = widget.tasks[currentColumn.status] ?? [];
    
    String message = 'Column: ${currentColumn.title}';
    
    if (currentTasks.isNotEmpty && _selectedTaskIndex < currentTasks.length) {
      final task = currentTasks[_selectedTaskIndex];
      message += ', Task: ${task.title}';
    } else {
      message += ', Empty column';
    }
    
    SemanticsService.announce(message, TextDirection.ltr);
  }
}

/// High contrast mode support for Kanban board
class KanbanHighContrastSupport {
  /// Check if high contrast mode is enabled
  static bool isHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Get high contrast colors for task priority
  static Color getHighContrastPriorityColor(TaskPriority priority, bool isDark) {
    if (isDark) {
      switch (priority) {
        case TaskPriority.low:
          return AccessibilityConstants.highContrastSuccess;
        case TaskPriority.medium:
          return AccessibilityConstants.highContrastWarning;
        case TaskPriority.high:
          return AccessibilityConstants.highContrastError;
        case TaskPriority.urgent:
          return AccessibilityConstants.highContrastCritical;
      }
    } else {
      switch (priority) {
        case TaskPriority.low:
          return const Color(0xFF2E7D32); // Dark green
        case TaskPriority.medium:
          return const Color(0xFFE65100); // Dark orange
        case TaskPriority.high:
          return const Color(0xFFC62828); // Dark red
        case TaskPriority.urgent:
          return const Color(0xFF4A148C); // Dark purple
      }
    }
  }

  /// Get high contrast colors for task status
  static Color getHighContrastStatusColor(TaskStatus status, bool isDark) {
    if (isDark) {
      switch (status) {
        case TaskStatus.pending:
          return AccessibilityConstants.highContrastText;
        case TaskStatus.inProgress:
          return AccessibilityConstants.highContrastPrimary;
        case TaskStatus.completed:
          return AccessibilityConstants.highContrastSuccess;
        case TaskStatus.cancelled:
          return AccessibilityConstants.highContrastError;
      }
    } else {
      switch (status) {
        case TaskStatus.pending:
          return const Color(0xFF424242); // Dark grey
        case TaskStatus.inProgress:
          return const Color(0xFF1565C0); // Dark blue
        case TaskStatus.completed:
          return const Color(0xFF2E7D32); // Dark green
        case TaskStatus.cancelled:
          return const Color(0xFFC62828); // Dark red
      }
    }
  }

  /// Apply high contrast styles to widget
  static Widget applyHighContrastStyles({
    required Widget child,
    required BuildContext context,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
  }) {
    if (!isHighContrastEnabled(context)) return child;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBackgroundColor = isDark
        ? AccessibilityConstants.highContrastSurface
        : AccessibilityConstants.highContrastBackground;
    
    final defaultBorderColor = isDark
        ? AccessibilityConstants.highContrastText
        : const Color(0xFF000000);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBackgroundColor,
        border: Border.all(
          color: borderColor ?? defaultBorderColor,
          width: borderWidth ?? 2.0,
        ),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
      ),
      child: child,
    );
  }
}

/// Focus management for Kanban board
class KanbanFocusManager {
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  static FocusNode? _currentFocusNode;

  /// Set the current focus node
  static void setCurrentFocus(FocusNode? node) {
    _currentFocusNode = node;
  }

  /// Get the current focus node
  static FocusNode? get currentFocus => _currentFocusNode;

  /// Move focus to next focusable element
  static void focusNext(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// Move focus to previous focusable element
  static void focusPrevious(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// Clear current focus
  static void clearFocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Request focus for a specific widget
  static void requestFocus(BuildContext context, FocusNode node) {
    node.requestFocus();
    _currentFocusNode = node;
  }

  /// Create a focus trap for modal dialogs
  static Widget createFocusTrap({
    required Widget child,
    required bool enabled,
  }) {
    if (!enabled) return child;

    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: child,
    );
  }
}

/// Responsive breakpoints for Kanban board
class KanbanBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double large = 1600;

  /// Check if screen is mobile size
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  /// Check if screen is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  /// Check if screen is desktop size
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  /// Get column count based on screen size
  static int getColumnCount(BuildContext context, int totalColumns) {
    if (isMobile(context)) {
      return 1; // Single column on mobile
    } else if (isTablet(context)) {
      return (totalColumns / 2).ceil(); // Half columns on tablet
    } else {
      return totalColumns; // All columns on desktop
    }
  }

  /// Get column width based on screen size
  static double getColumnWidth(BuildContext context, int visibleColumns) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isMobile(context)) {
      return screenWidth - 32; // Full width minus padding
    } else if (isTablet(context)) {
      return (screenWidth - 48) / visibleColumns.clamp(1, 2); // Max 2 columns
    } else {
      return ((screenWidth - 64) / visibleColumns).clamp(280, 400);
    }
  }

  /// Check if drag and drop should be enabled based on screen size
  static bool shouldEnableDragAndDrop(BuildContext context) {
    return !isMobile(context); // Disable on mobile for better UX
  }
}

/// Voice command support for accessibility
class KanbanVoiceCommands {
  static final Map<String, VoidCallback> _commands = {};

  /// Register a voice command
  static void registerCommand(String command, VoidCallback callback) {
    _commands[command.toLowerCase()] = callback;
  }

  /// Unregister a voice command
  static void unregisterCommand(String command) {
    _commands.remove(command.toLowerCase());
  }

  /// Process voice input
  static bool processVoiceCommand(String input) {
    final normalizedInput = input.toLowerCase().trim();
    
    // Look for exact matches first
    if (_commands.containsKey(normalizedInput)) {
      _commands[normalizedInput]!();
      return true;
    }
    
    // Look for partial matches
    for (final entry in _commands.entries) {
      if (normalizedInput.contains(entry.key)) {
        entry.value();
        return true;
      }
    }
    
    return false;
  }

  /// Get available commands
  static List<String> getAvailableCommands() {
    return _commands.keys.toList();
  }

  /// Clear all commands
  static void clearCommands() {
    _commands.clear();
  }
}