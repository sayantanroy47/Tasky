import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../domain/entities/task_model.dart';
import '../../domain/entities/project.dart';
import '../../domain/models/enums.dart';

/// Comprehensive service for managing slidable actions across the app
/// Integrates PhosphorIcons, Material 3 theming, and context-aware actions
class SlidableActionService {
  
  /// Gets context-aware actions for task cards based on task state
  static List<SlidableAction> getTaskActions(
    TaskModel task, {
    required ColorScheme colorScheme,
    VoidCallback? onComplete,
    VoidCallback? onEdit,
    VoidCallback? onPin,
    VoidCallback? onDelete,
    VoidCallback? onArchive,
    VoidCallback? onReschedule,
    VoidCallback? onStopRecurring,
    VoidCallback? onSkipInstance,
    VoidCallback? onDuplicate,
  }) {
    final actions = <SlidableAction>[];
    
    // Context-aware action sets based on task state
    if (task.status == TaskStatus.completed) {
      actions.addAll(_getCompletedTaskActions(
        task,
        colorScheme: colorScheme,
        onComplete: onComplete,
        onArchive: onArchive,
        onDelete: onDelete,
      ));
    } else if (task.isOverdue) {
      actions.addAll(_getOverdueTaskActions(
        task,
        colorScheme: colorScheme,
        onComplete: onComplete,
        onEdit: onEdit,
        onReschedule: onReschedule,
        onDelete: onDelete,
      ));
    } else if (task.recurrence != null) {
      actions.addAll(_getRecurringTaskActions(
        task,
        colorScheme: colorScheme,
        onComplete: onComplete,
        onEdit: onEdit,
        onStopRecurring: onStopRecurring,
        onSkipInstance: onSkipInstance,
      ));
    } else {
      actions.addAll(_getStandardTaskActions(
        task,
        colorScheme: colorScheme,
        onComplete: onComplete,
        onEdit: onEdit,
        onPin: onPin,
        onDelete: onDelete,
        onDuplicate: onDuplicate,
      ));
    }
    
    return actions;
  }

  /// Gets balanced compact actions with proper 2-2 distribution for better UX
  static Map<String, List<SlidableAction>> getBalancedCompactTaskActions(
    TaskModel task, {
    required ColorScheme colorScheme,
    VoidCallback? onComplete,
    VoidCallback? onQuickEdit,
    VoidCallback? onDelete,
    VoidCallback? onMore,
  }) {
    return {
      'startActions': [
        _createStyledAction(
          onPressed: onComplete,
          actionType: SlidableActionType.complete,
          actionName: 'Complete',
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          icon: PhosphorIcons.check(),
          iconSize: 24, // Slightly smaller to balance with text
          label: 'Complete',
          spacing: 8, // Increased spacing for better text visibility
        ),
        _createStyledAction(
          onPressed: onQuickEdit,
          actionType: SlidableActionType.edit,
          actionName: 'QuickEdit',
          backgroundColor: colorScheme.secondary,
          foregroundColor: Colors.white,
          icon: PhosphorIcons.pencil(), // Changed from lightning to pencil for clarity
          iconSize: 24, // Slightly smaller to balance with text
          label: 'Edit',
          spacing: 8, // Increased spacing for better text visibility
        ),
      ],
      'endActions': [
        _createStyledAction(
          onPressed: onDelete,
          actionType: SlidableActionType.destructive,
          actionName: 'Delete',
          backgroundColor: colorScheme.error,
          foregroundColor: Colors.white,
          icon: PhosphorIcons.trash(),
          iconSize: 24, // Slightly smaller to balance with text
          label: 'Delete',
          spacing: 8, // Increased spacing for better text visibility
        ),
        _createStyledAction(
          onPressed: onMore,
          actionType: SlidableActionType.neutral,
          actionName: 'More',
          backgroundColor: colorScheme.surfaceContainerHigh,
          foregroundColor: colorScheme.onSurface,
          icon: PhosphorIcons.dotsThreeOutline(),
          iconSize: 24, // Slightly smaller to balance with text
          label: 'More',
          spacing: 8, // Increased spacing for better text visibility
        ),
      ],
    };
  }

  /// Gets simplified actions for compact task cards (HomePage) - Legacy method for backward compatibility
  @Deprecated('Use getBalancedCompactTaskActions for better UX')
  static List<SlidableAction> getCompactTaskActions(
    TaskModel task, {
    required ColorScheme colorScheme,
    VoidCallback? onComplete,
    VoidCallback? onQuickEdit,
    VoidCallback? onMore,
  }) {
    return [
      _createStyledAction(
        onPressed: onComplete,
        actionType: SlidableActionType.complete,
        actionName: 'Complete',
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        icon: PhosphorIcons.check(),
        label: 'Complete',
      ),
      _createStyledAction(
        onPressed: onQuickEdit,
        actionType: SlidableActionType.edit,
        actionName: 'QuickEdit',
        backgroundColor: colorScheme.secondary,
        foregroundColor: Colors.white,
        icon: PhosphorIcons.lightning(),
        label: 'Edit',
      ),
      _createStyledAction(
        onPressed: onMore,
        actionType: SlidableActionType.neutral,
        actionName: 'More',
        backgroundColor: colorScheme.surfaceContainerHigh,
        foregroundColor: colorScheme.onSurface,
        icon: PhosphorIcons.dotsThreeOutline(),
        label: 'More',
      ),
    ];
  }

  /// Gets project-specific slidable actions
  static List<SlidableAction> getProjectActions(
    Project project, {
    required ColorScheme colorScheme,
    VoidCallback? onEdit,
    VoidCallback? onViewTasks,
    VoidCallback? onArchive,
    VoidCallback? onDelete,
    VoidCallback? onShare,
  }) {
    return [
      // Left actions
      _createStyledAction(
        onPressed: onEdit,
        actionType: SlidableActionType.edit,
        actionName: 'ProjectEdit',
        backgroundColor: colorScheme.secondary,
        foregroundColor: Colors.white,
        icon: PhosphorIcons.pencil(),
        label: 'Edit',
      ),
      _createStyledAction(
        onPressed: onViewTasks,
        actionType: SlidableActionType.neutral,
        actionName: 'ProjectViewTasks',
        backgroundColor: colorScheme.tertiary,
        foregroundColor: Colors.white,
        icon: PhosphorIcons.eye(),
        label: 'Tasks',
      ),
      // Right actions
      _createStyledAction(
        onPressed: onShare,
        actionType: SlidableActionType.neutral,
        actionName: 'ProjectShare',
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        icon: PhosphorIcons.share(),
        label: 'Share',
      ),
      SlidableAction(
        onPressed: (_) async {
          await _safeExecuteCallback(onArchive, SlidableActionType.archive, 'ProjectArchive');
        },
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        icon: PhosphorIcons.archive(),
        // label: 'Archive', // Removed text
      ),
      SlidableAction(
        onPressed: (_) async {
          await _safeExecuteCallback(onDelete, SlidableActionType.destructive, 'TaskDelete');
        },
        backgroundColor: colorScheme.error,
        foregroundColor: Colors.white,
        icon: PhosphorIcons.trash(),
        // label: 'Delete', // Removed text
      ),
    ];
  }

  // Private helper methods for different task states
  
  static List<SlidableAction> _getStandardTaskActions(
    TaskModel task, {
    required ColorScheme colorScheme,
    VoidCallback? onComplete,
    VoidCallback? onEdit,
    VoidCallback? onPin,
    VoidCallback? onDelete,
    VoidCallback? onDuplicate,
  }) {
    return [
      SlidableAction(
        onPressed: (_) async {
          await _safeExecuteCallback(onComplete, SlidableActionType.complete, 'TaskComplete');
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        icon: PhosphorIcons.check(),
        // label: 'Complete', // Removed text
      ),
      SlidableAction(
        onPressed: (_) async {
          await _safeExecuteCallback(onEdit, SlidableActionType.edit, 'TaskEdit');
        },
        backgroundColor: colorScheme.secondary,
        foregroundColor: Colors.white,
        icon: PhosphorIcons.pencil(),
        // label: 'Edit', // Removed text
      ),
      SlidableAction(
        onPressed: (_) {
          _provideFeedback(SlidableActionType.neutral);
          onPin?.call();
        },
        backgroundColor: colorScheme.tertiary,
        foregroundColor: Colors.white,
        icon: task.isPinned ? PhosphorIcons.pushPinSlash() : PhosphorIcons.pushPin(),
        // label: task.isPinned ? 'Unpin' : 'Pin', // Removed text
      ),
      SlidableAction(
        onPressed: (_) async {
          await _safeExecuteCallback(onDelete, SlidableActionType.destructive, 'TaskDelete');
        },
        backgroundColor: colorScheme.error,
        foregroundColor: Colors.white,
        icon: PhosphorIcons.trash(),
        // label: 'Delete', // Removed text
      ),
    ];
  }

  static List<SlidableAction> _getCompletedTaskActions(
    TaskModel task, {
    required ColorScheme colorScheme,
    VoidCallback? onComplete,
    VoidCallback? onArchive,
    VoidCallback? onDelete,
  }) {
    return [
      SlidableAction(
        onPressed: (_) async {
          await _safeExecuteCallback(onComplete, SlidableActionType.complete, 'TaskComplete');
        },
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        icon: PhosphorIcons.arrowCounterClockwise(),
        // label: 'Uncomplete', // Removed text
      ),
      SlidableAction(
        onPressed: (_) async {
          await _safeExecuteCallback(onArchive, SlidableActionType.archive, 'TaskArchive');
        },
        backgroundColor: colorScheme.tertiary,
        foregroundColor: Colors.white,
        icon: PhosphorIcons.archive(),
        // label: 'Archive', // Removed text
      ),
      SlidableAction(
        onPressed: (_) async {
          await _safeExecuteCallback(onDelete, SlidableActionType.destructive, 'TaskDelete');
        },
        backgroundColor: colorScheme.error,
        foregroundColor: Colors.white,
        icon: PhosphorIcons.trash(),
        // label: 'Delete', // Removed text
      ),
    ];
  }

  static List<SlidableAction> _getOverdueTaskActions(
    TaskModel task, {
    required ColorScheme colorScheme,
    VoidCallback? onComplete,
    VoidCallback? onEdit,
    VoidCallback? onReschedule,
    VoidCallback? onDelete,
  }) {
    return [
      SlidableAction(
        onPressed: (_) async {
          await _safeExecuteCallback(onComplete, SlidableActionType.complete, 'TaskComplete');
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        icon: PhosphorIcons.checkCircle(),
        // label: 'Complete', // Removed text
      ),
      SlidableAction(
        onPressed: (_) {
          _provideFeedback(SlidableActionType.neutral);
          onReschedule?.call();
        },
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        icon: PhosphorIcons.calendar(),
        // label: 'Reschedule', // Removed text
      ),
      SlidableAction(
        onPressed: (_) async {
          await _safeExecuteCallback(onEdit, SlidableActionType.edit, 'TaskEdit');
        },
        backgroundColor: colorScheme.secondary,
        foregroundColor: Colors.white,
        icon: PhosphorIcons.pencil(),
        // label: 'Edit', // Removed text
      ),
      SlidableAction(
        onPressed: (_) async {
          await _safeExecuteCallback(onDelete, SlidableActionType.destructive, 'TaskDelete');
        },
        backgroundColor: colorScheme.error,
        foregroundColor: Colors.white,
        icon: PhosphorIcons.trash(),
        // label: 'Delete', // Removed text
      ),
    ];
  }

  static List<SlidableAction> _getRecurringTaskActions(
    TaskModel task, {
    required ColorScheme colorScheme,
    VoidCallback? onComplete,
    VoidCallback? onEdit,
    VoidCallback? onStopRecurring,
    VoidCallback? onSkipInstance,
  }) {
    return [
      SlidableAction(
        onPressed: (_) async {
          await _safeExecuteCallback(onComplete, SlidableActionType.complete, 'TaskComplete');
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        icon: PhosphorIcons.check(),
        // label: 'Complete', // Removed text
      ),
      SlidableAction(
        onPressed: (_) async {
          await _safeExecuteCallback(onEdit, SlidableActionType.edit, 'TaskEdit');
        },
        backgroundColor: colorScheme.secondary,
        foregroundColor: Colors.white,
        icon: PhosphorIcons.gear(),
        // label: 'Edit', // Removed text
      ),
      SlidableAction(
        onPressed: (_) {
          _provideFeedback(SlidableActionType.neutral);
          onSkipInstance?.call();
        },
        backgroundColor: colorScheme.tertiary,
        foregroundColor: Colors.white,
        icon: PhosphorIcons.skipForward(),
        // label: 'Skip', // Removed text
      ),
      SlidableAction(
        onPressed: (_) {
          _provideFeedback(SlidableActionType.destructive);
          onStopRecurring?.call();
        },
        backgroundColor: colorScheme.error,
        foregroundColor: Colors.white,
        icon: PhosphorIcons.stop(),
        // label: 'Stop Series', // Removed text
      ),
    ];
  }

  /// Safely executes action callbacks with comprehensive error handling and accessibility
  static Future<bool> _safeExecuteCallback(
    VoidCallback? callback,
    SlidableActionType actionType,
    String actionName,
  ) async {
    if (callback == null) return true;
    
    try {
      // Provide haptic feedback before action
      _provideFeedback(actionType);
      
      // Execute the callback
      callback();
      
      // Provide accessibility feedback for successful action
      // Import at top of file: import 'slidable_feedback_service.dart';
      // Uncomment when ready to integrate:
      // await SlidableFeedbackService.provideAccessibilityFeedback(actionType, actionName);
      
      return true;
    } catch (error, stackTrace) {
      // Log the error for debugging
      debugPrint('Slidable action error ($actionName): $error');
      debugPrint('Stack trace: $stackTrace');
      
      // Provide error feedback to user
      _provideFeedback(SlidableActionType.error);
      
      // Provide accessibility feedback for error
      // Uncomment when ready to integrate:
      // await SlidableFeedbackService.provideAccessibilityFeedback(SlidableActionType.error, actionName);
      
      // Could integrate with error reporting service here
      // ErrorReportingService.reportError(error, stackTrace, 'SlidableAction_$actionName');
      
      return false;
    }
  }
  
  /// Creates a properly styled SlidableAction with consistent theming and enhanced icons
  static SlidableAction _createStyledAction({
    required VoidCallback? onPressed,
    required SlidableActionType actionType,
    required String actionName,
    required Color backgroundColor,
    required Color foregroundColor,
    required IconData icon,
    required String label,
    int flex = 1,
    double spacing = 8, // Increased for better text visibility
    double iconSize = 40, // Much larger icon size for better visibility without text
    BorderRadius? borderRadius,
    bool autoClose = true,
  }) {
    return SlidableAction(
      onPressed: (_) async {
        await _safeExecuteCallback(onPressed, actionType, actionName);
      },
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      icon: icon,
      // No label to ensure center alignment
      flex: flex,
      borderRadius: borderRadius ?? BorderRadius.circular(10),
      autoClose: autoClose,
    );
  }
  
  /// Provides comprehensive feedback for slidable actions
  static void _provideFeedback(SlidableActionType actionType) {
    switch (actionType) {
      case SlidableActionType.complete:
        HapticFeedback.mediumImpact();
        break;
      case SlidableActionType.edit:
        HapticFeedback.lightImpact();
        break;
      case SlidableActionType.destructive:
        HapticFeedback.heavyImpact();
        break;
      case SlidableActionType.archive:
        HapticFeedback.mediumImpact();
        break;
      case SlidableActionType.neutral:
        HapticFeedback.selectionClick();
        break;
      case SlidableActionType.error:
        HapticFeedback.vibrate(); // Strong feedback for errors
        break;
    }
  }

  /// Gets appropriate motion type for different action contexts
  static Widget getMotionForActionType(SlidableActionType actionType) {
    switch (actionType) {
      case SlidableActionType.complete:
        return const BehindMotion();
      case SlidableActionType.edit:
        return const DrawerMotion();
      case SlidableActionType.destructive:
        return const StretchMotion();
      case SlidableActionType.archive:
        return const ScrollMotion();
      case SlidableActionType.neutral:
        return const DrawerMotion();
      case SlidableActionType.error:
        return const StretchMotion(); // Emphasize error state
    }
  }
}

/// Enum for different types of slidable actions
enum SlidableActionType {
  complete,
  edit,
  destructive,
  archive,
  neutral,
  error,
}