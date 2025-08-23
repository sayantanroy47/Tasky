import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../core/design_system/design_tokens.dart';
import '../../presentation/widgets/glassmorphism_container.dart';

/// Service for providing consistent slidable theming across the app
/// Integrates Material 3 design with glassmorphism effects and golden ratio spacing
class SlidableThemeService {
  
  /// Creates a comprehensive Slidable wrapper for the entire app
  static Widget createAppWrapper({required Widget child}) {
    return child; // SlidableConfiguration is not available in flutter_slidable 4.0.1
  }

  /// Creates Material 3 + glassmorphism themed action panes
  static ActionPane createStartActionPane({
    required List<SlidableAction> actions,
    required Widget motion,
    double extentRatio = 0.25,
    bool useGlassmorphism = false,
    bool dragDismissible = true,
    double? openThreshold,
    double? closeThreshold,
  }) {
    return ActionPane(
      motion: motion,
      extentRatio: extentRatio,
      dragDismissible: dragDismissible,
      openThreshold: openThreshold,
      closeThreshold: closeThreshold,
      children: useGlassmorphism 
          ? actions.map((action) => _wrapWithGlass(action)).toList()
          : actions,
    );
  }

  /// Creates Material 3 + glassmorphism themed end action panes
  static ActionPane createEndActionPane({
    required List<SlidableAction> actions,
    required Widget motion,
    double extentRatio = 0.25,
    bool useGlassmorphism = false,
    bool dragDismissible = true,
    double? openThreshold,
    double? closeThreshold,
  }) {
    return ActionPane(
      motion: motion,
      extentRatio: extentRatio,
      dragDismissible: dragDismissible,
      openThreshold: openThreshold,
      closeThreshold: closeThreshold,
      children: useGlassmorphism 
          ? actions.map((action) => _wrapWithGlass(action)).toList()
          : actions,
    );
  }

  /// Creates a sophisticated slidable container with enhanced theming
  static Widget createThemedSlidable({
    required Widget child,
    ActionPane? startActionPane,
    ActionPane? endActionPane,
    bool useGlassmorphism = true,
    bool enableRTLSupport = true,
    String? groupTag,
    SlidableController? controller,
    Key? key,
  }) {
    // Apply glassmorphism/styling to the child content, not the Slidable wrapper
    final styledChild = useGlassmorphism
        ? GlassmorphismContainer(
            borderRadius: BorderRadius.circular(SpacingTokens.phi2),
            child: child,
          )
        : Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.phi2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: SpacingTokens.phi1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: child,
          );

    // Slidable wrapper with improved gesture handling
    return Slidable(
      key: key,
      groupTag: groupTag,
      controller: controller,
      direction: enableRTLSupport 
          ? Axis.horizontal 
          : Axis.horizontal, // Future: RTL direction detection
      dragStartBehavior: DragStartBehavior.start, // Wait for drag to start, allow taps to pass through
      startActionPane: startActionPane,
      endActionPane: endActionPane,
      child: styledChild,
    );
  }

  /// Creates a premium task card slidable with advanced theming
  static Widget createTaskCardSlidable({
    required Widget child,
    required List<SlidableAction> startActions,
    required List<SlidableAction> endActions,
    bool isOverdue = false,
    bool isCompleted = false,
    bool useAdvancedMotion = true,
    String? groupTag,
    Key? key,
  }) {
    // Use performance-optimized motion selection
    final startMotion = useAdvancedMotion 
        ? getContextualMotion(
            SlidableContext.taskCard,
            isCompleted: isCompleted,
            isOverdue: false, // Start actions not affected by overdue status
          )
        : getOptimizedMotion(MotionType.drawer);
        
    final endMotion = useAdvancedMotion
        ? getContextualMotion(
            SlidableContext.taskCard,
            isCompleted: isCompleted,
            isOverdue: isOverdue,
          )
        : getOptimizedMotion(MotionType.stretch);

    return createThemedSlidable(
      key: key,
      groupTag: groupTag,
      startActionPane: createStartActionPane(
        actions: startActions,
        motion: startMotion,
        extentRatio: 0.3,
        useGlassmorphism: true,
      ),
      endActionPane: createEndActionPane(
        actions: endActions,
        motion: endMotion,
        extentRatio: 0.3,
        useGlassmorphism: true,
      ),
      child: child,
    );
  }

  /// Creates a compact card slidable for HomePage with optimized performance
  static Widget createCompactCardSlidable({
    required Widget child,
    required List<SlidableAction> actions,
    String? groupTag,
    Key? key,
    bool enableFastSwipe = true,
    BuildContext? context,
  }) {
    // Optimize action list for ListView performance - limit to 3 actions max
    final optimizedActions = actions.take(3).toList();
    
    // Calculate responsive extent ratio based on screen width
    double extentRatio = enableFastSwipe ? 0.45 : 0.5;
    if (context != null) {
      final screenWidth = MediaQuery.of(context).size.width;
      const minButtonWidth = 60.0;
      final requiredWidth = minButtonWidth * optimizedActions.length;
      final calculatedRatio = requiredWidth / screenWidth;
      
      // Use the larger of calculated minimum or default ratios
      if (calculatedRatio > extentRatio) {
        extentRatio = (calculatedRatio * 1.1).clamp(0.3, 0.8); // 10% buffer, clamped to reasonable bounds
      }
    }
    
    return createThemedSlidable(
      key: key,
      groupTag: groupTag,
      endActionPane: createEndActionPane(
        actions: optimizedActions,
        motion: getContextualMotion(SlidableContext.compactList, highPerformance: enableFastSwipe),
        extentRatio: extentRatio, // Responsive size for proper button accessibility
        dragDismissible: false, // Reduce gesture overhead
        openThreshold: 0.2, // Balanced threshold to prevent accidental activation
        closeThreshold: 0.7, // Reasonable threshold for natural closing gesture
        useGlassmorphism: false, // Better performance for many items
      ),
      useGlassmorphism: false,
      child: child,
    );
  }

  /// Creates a balanced dual-sided compact slidable with proper 2-2 action distribution
  static Widget createBalancedCompactCardSlidable({
    required Widget child,
    required List<SlidableAction> startActions,
    required List<SlidableAction> endActions,
    String? groupTag,
    Key? key,
    bool enableFastSwipe = true,
    BuildContext? context,
  }) {
    // Calculate responsive extent ratios for different action counts
    double startExtentRatio = 0.4; // For 2 actions (Complete + Edit)
    double endExtentRatio = 0.4;   // For 2 actions (Delete + More)
    
    if (context != null) {
      final screenWidth = MediaQuery.of(context).size.width;
      const minButtonWidth = 70.0; // Slightly larger for better touch targets
      
      // Calculate start ratio for 2 actions
      if (startActions.isNotEmpty) {
        final startRequiredWidth = minButtonWidth * startActions.length;
        final startCalculatedRatio = startRequiredWidth / screenWidth;
        if (startCalculatedRatio > startExtentRatio) {
          startExtentRatio = (startCalculatedRatio * 1.1).clamp(0.3, 0.6);
        }
      }
      
      // Calculate end ratio for 1 action
      if (endActions.isNotEmpty) {
        final endRequiredWidth = minButtonWidth * endActions.length;
        final endCalculatedRatio = endRequiredWidth / screenWidth;
        if (endCalculatedRatio > endExtentRatio) {
          endExtentRatio = (endCalculatedRatio * 1.1).clamp(0.2, 0.4);
        }
      }
    }
    
    return createThemedSlidable(
      key: key,
      groupTag: groupTag,
      // Left side: Primary actions (Complete + Edit)
      startActionPane: startActions.isNotEmpty ? createStartActionPane(
        actions: startActions,
        motion: getContextualMotion(SlidableContext.compactList, highPerformance: enableFastSwipe),
        extentRatio: startExtentRatio,
        dragDismissible: false,
        openThreshold: 0.15, // Easier to trigger primary actions
        closeThreshold: 0.7,
        useGlassmorphism: false,
      ) : null,
      // Right side: Secondary actions (Delete + More)
      endActionPane: endActions.isNotEmpty ? createEndActionPane(
        actions: endActions,
        motion: getContextualMotion(SlidableContext.compactList, highPerformance: enableFastSwipe),
        extentRatio: endExtentRatio,
        dragDismissible: false,
        openThreshold: 0.2, // Standard threshold for secondary actions
        closeThreshold: 0.7,
        useGlassmorphism: false,
      ) : null,
      useGlassmorphism: false,
      child: child,
    );
  }

  /// Creates an ultra-optimized slidable for very large lists (1000+ items)
  static Widget createUltraCompactSlidable({
    required Widget child,
    required SlidableAction primaryAction,
    String? groupTag,
    Key? key,
  }) {
    return Slidable(
      key: key,
      groupTag: groupTag,
      dragStartBehavior: DragStartBehavior.start, // Prevent tap interference
      endActionPane: ActionPane(
        motion: getOptimizedMotion(MotionType.scroll, highPerformance: true), // Minimal motion overhead
        extentRatio: 0.35, // Balanced for single-action usability
        dragDismissible: false,
        openThreshold: 0.15, // Low threshold for single action
        closeThreshold: 0.8, // Higher threshold for single action
        children: [primaryAction], // Single action only for maximum performance
      ),
      child: child,
    );
  }

  /// Test action button responsiveness across different screen sizes
  static bool testActionButtonResponsiveness() {
    // Test different screen width scenarios
    const testScreenWidths = [
      320.0, // Small phone (iPhone SE)
      375.0, // Medium phone (iPhone 12/13 Mini)
      414.0, // Large phone (iPhone 12/13 Pro Max)
      768.0, // Tablet portrait
    ];

    const testExtentRatios = [0.45, 0.5]; // Current compact and regular ratios

    for (final screenWidth in testScreenWidths) {
      for (final extentRatio in testExtentRatios) {
        final actionPaneWidth = screenWidth * extentRatio;
        const minButtonWidth = 60.0; // Minimum touchable button width
        const actionCount = 3; // Standard compact actions

        final buttonWidth = actionPaneWidth / actionCount;

        // Verify buttons are large enough to be touchable
        if (buttonWidth < minButtonWidth) {
          debugPrint('[ERROR] Action buttons too small: ${buttonWidth}px on ${screenWidth}px screen');
          return false;
        }
      }
    }

    debugPrint('[SUCCESS] Action button responsiveness test passed');
    return true;
  }

  /// Creates a project card slidable with project-specific theming
  static Widget createProjectCardSlidable({
    required Widget child,
    required List<SlidableAction> leftActions,
    required List<SlidableAction> rightActions,
    Color? accentColor,
    String? groupTag,
    Key? key,
  }) {
    return createThemedSlidable(
      key: key,
      groupTag: groupTag,
      startActionPane: createStartActionPane(
        actions: leftActions,
        motion: getContextualMotion(SlidableContext.projectCard),
        extentRatio: 0.25,
        useGlassmorphism: true,
      ),
      endActionPane: createEndActionPane(
        actions: rightActions,
        motion: getOptimizedMotion(MotionType.stretch),
        extentRatio: 0.25,
        useGlassmorphism: true,
      ),
      child: child,
    );
  }

  /// Creates settings list item slidable with minimal theming
  static Widget createSettingsItemSlidable({
    required Widget child,
    required List<SlidableAction> actions,
    String? groupTag,
  }) {
    return Slidable(
      groupTag: groupTag,
      dragStartBehavior: DragStartBehavior.start, // Allow child taps to work
      endActionPane: ActionPane(
        motion: getContextualMotion(SlidableContext.settingsItem),
        extentRatio: 0.2,
        children: actions,
      ),
      child: child,
    );
  }

  // Private helper methods

  /// Applies glassmorphism styling to action background (deprecated for gesture optimization)
  /// Actions now use native styling for better gesture responsiveness
  static Widget _wrapWithGlass(SlidableAction action) {
    // Return the action directly to avoid gesture interference
    // Glassmorphism effects are now handled at the container level
    return action;
  }

  /// Gets appropriate dismiss thresholds based on action type
  static double getDismissThreshold(bool isDestructive) {
    return isDestructive ? 0.6 : 0.4; // Require more effort for destructive actions
  }

  /// Gets appropriate duration for slidable animations
  static Duration getAnimationDuration(bool isQuickAction) {
    return Duration(milliseconds: isQuickAction ? 200 : 350);
  }

  /// Motion type optimization for 60fps performance across different contexts
  static Widget getOptimizedMotion(MotionType motionType, {bool highPerformance = false}) {
    if (highPerformance) {
      // For high-performance contexts (large lists, low-end devices)
      switch (motionType) {
        case MotionType.scroll:
          return const ScrollMotion(); // Best for ListView scrolling
        case MotionType.drawer:
        case MotionType.behind:
        case MotionType.stretch:
          return const ScrollMotion(); // Fallback to most performant
      }
    } else {
      // For normal contexts with full animation fidelity
      switch (motionType) {
        case MotionType.scroll:
          return const ScrollMotion();
        case MotionType.drawer:
          return const DrawerMotion();
        case MotionType.behind:
          return const BehindMotion();
        case MotionType.stretch:
          return const StretchMotion();
      }
    }
  }

  /// Context-aware motion selection for different UI patterns
  static Widget getContextualMotion(SlidableContext context, {
    bool isCompleted = false,
    bool isOverdue = false,
    bool highPerformance = false,
  }) {
    if (highPerformance) {
      return const ScrollMotion(); // Always use most performant
    }

    switch (context) {
      case SlidableContext.compactList:
        return const ScrollMotion(); // Optimal for ListView
      case SlidableContext.taskCard:
        if (isCompleted) return const ScrollMotion();
        if (isOverdue) return const StretchMotion();
        return const BehindMotion();
      case SlidableContext.projectCard:
        return const DrawerMotion(); // Smooth reveal for projects
      case SlidableContext.settingsItem:
        return const ScrollMotion(); // Minimal for settings
    }
  }

  /// Creates a dismissible slidable for destructive actions
  static Widget createDismissibleSlidable({
    required Widget child,
    required VoidCallback onDismissed,
    required List<SlidableAction> confirmActions,
    String? groupTag,
    bool requireConfirmation = true,
  }) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      confirmDismiss: requireConfirmation 
          ? (direction) async {
              // Show confirmation dialog or action sheet
              return false; // Prevent automatic dismissal
            }
          : null,
      onDismissed: (direction) => onDismissed(),
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.withValues(alpha: 0.1),
              Colors.red,
            ],
          ),
          borderRadius: BorderRadius.circular(SpacingTokens.phi2),
        ),
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 32.0),
            child: Icon(
              Icons.delete_forever,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
      child: createThemedSlidable(
        groupTag: groupTag,
        endActionPane: createEndActionPane(
          actions: confirmActions,
          motion: const StretchMotion(),
        ),
        child: child,
      ),
    );
  }

  /// Wraps a slidable widget with proper accessibility semantics and visual hints
  static Widget wrapWithAccessibility(
    Widget slidable, {
    required String label,
    required String hint,
    List<String>? availableActions,
    bool showSwipeHint = false,
    Color? hintColor,
  }) {
    final actionsHint = availableActions?.isNotEmpty == true
        ? ' Available actions: ${availableActions!.join(', ')}'
        : '';
        
    Widget wrappedSlidable = Semantics(
      label: label,
      hint: 'Swipeable item. $hint$actionsHint',
      enabled: true,
      focusable: true,
      child: slidable,
    );

    // Add visual swipe hint if requested
    if (showSwipeHint) {
      wrappedSlidable = Stack(
        children: [
          wrappedSlidable,
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: _buildSwipeHintIndicator(hintColor),
          ),
        ],
      );
    }

    return wrappedSlidable;
  }

  /// Creates a subtle swipe hint indicator
  static Widget _buildSwipeHintIndicator(Color? color) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: (color ?? Colors.grey.shade500).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.swipe_left_rounded,
              size: 16,
              color: (color ?? Colors.grey.shade600).withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            Text(
              'Swipe',
              style: TextStyle(
                fontSize: 12,
                color: (color ?? Colors.grey.shade600).withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates action pane with custom background gradient
  static ActionPane createGradientActionPane({
    required List<SlidableAction> actions,
    required List<Color> gradientColors,
    Widget? motion,
  }) {
    return ActionPane(
      motion: motion ?? const DrawerMotion(),
      children: actions,
      // Note: Custom backgrounds would need to be implemented
      // in the individual SlidableAction widgets
    );
  }
}

/// Performance-oriented motion type categorization
enum MotionType {
  scroll,   // Most performant - best for ListView
  drawer,   // Balanced performance and visual appeal
  behind,   // Good for task completion actions
  stretch,  // Visual emphasis, slightly heavier
}

/// Context categories for motion selection
enum SlidableContext {
  compactList,   // HomePage compact cards in ListView
  taskCard,      // Full task cards with multiple actions
  projectCard,   // Project cards with complex layouts
  settingsItem,  // Settings list items
}

/// Extension methods for enhanced slidable functionality
extension SlidableEnhancements on Widget {
  /// Wraps any widget with a themed slidable
  Widget wrapWithSlidable({
    List<SlidableAction>? startActions,
    List<SlidableAction>? endActions,
    bool useGlassmorphism = true,
    String? groupTag,
  }) {
    return SlidableThemeService.createThemedSlidable(
      startActionPane: startActions != null
          ? SlidableThemeService.createStartActionPane(
              actions: startActions,
              motion: const DrawerMotion(),
            )
          : null,
      endActionPane: endActions != null
          ? SlidableThemeService.createEndActionPane(
              actions: endActions,
              motion: const StretchMotion(),
            )
          : null,
      useGlassmorphism: useGlassmorphism,
      groupTag: groupTag,
      child: this,
    );
  }
}