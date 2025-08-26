import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../gesture_customization_service.dart';
import 'slidable_feedback_service.dart';
import 'slidable_action_service.dart';

/// Comprehensive mobile gesture service for project navigation
/// Provides touch-optimized interactions with haptic feedback and smooth animations
class MobileGestureService {
  static const double _swipeThreshold = 0.3; // 30% of screen width
  static const double _velocityThreshold = 300.0; // pixels per second
  static const double _longPressThreshold = 500.0; // milliseconds
  static const double _doubleTapThreshold = 300.0; // milliseconds
  static const double _pinchThreshold = 0.1; // 10% scale change

  final GestureCustomizationService _gestureService;
  final SlidableFeedbackService _feedbackService;

  MobileGestureService(this._gestureService, this._feedbackService);

  /// Creates a mobile-optimized gesture detector for project cards
  Widget createProjectCardGestureDetector({
    required Widget child,
    required String projectId,
    VoidCallback? onTap,
    VoidCallback? onEdit,
    VoidCallback? onArchive,
    VoidCallback? onDelete,
    VoidCallback? onViewTasks,
    String? semanticLabel,
  }) {
    return _MobileGestureDetectorWidget(
      gestureService: this,
      semanticLabel: semanticLabel,
      onTap: onTap,
      onLongPress: onEdit,
      onSwipeRight: () {
        SlidableFeedbackService.provideFeedback(SlidableActionType.complete);
        onArchive?.call();
      },
      onSwipeLeft: () {
        SlidableFeedbackService.provideFeedback(SlidableActionType.destructive);
        onDelete?.call();
      },
      onDoubleTap: onViewTasks,
      child: child,
    );
  }

  /// Creates a mobile-optimized navigation gesture detector for tab views
  Widget createTabNavigationGestureDetector({
    required Widget child,
    required int currentIndex,
    required int totalTabs,
    required ValueChanged<int> onTabChanged,
    bool enableSwipeNavigation = true,
    String? semanticLabel,
  }) {
    return _TabNavigationGestureDetector(
      gestureService: this,
      currentIndex: currentIndex,
      totalTabs: totalTabs,
      onTabChanged: onTabChanged,
      enableSwipeNavigation: enableSwipeNavigation,
      semanticLabel: semanticLabel,
      child: child,
    );
  }

  /// Creates a pinch-to-zoom gesture detector for timeline/gantt charts
  Widget createZoomableGestureDetector({
    required Widget child,
    double minScale = 0.5,
    double maxScale = 3.0,
    ValueChanged<double>? onScaleChanged,
    VoidCallback? onScaleStart,
    VoidCallback? onScaleEnd,
    String? semanticLabel,
  }) {
    return _ZoomableGestureDetector(
      gestureService: this,
      minScale: minScale,
      maxScale: maxScale,
      onScaleChanged: onScaleChanged,
      onScaleStart: onScaleStart,
      onScaleEnd: onScaleEnd,
      semanticLabel: semanticLabel,
      child: child,
    );
  }

  /// Creates a drag-and-drop gesture detector for Kanban boards
  Widget createDragDropGestureDetector({
    required Widget child,
    required String itemId,
    required String itemType,
    VoidCallback? onDragStart,
    ValueChanged<String>? onDragEnd,
    ValueChanged<DragTargetDetails>? onAccept,
    bool canDrag = true,
    bool canAccept = true,
    String? semanticLabel,
  }) {
    return _DragDropGestureDetector(
      gestureService: this,
      itemId: itemId,
      itemType: itemType,
      onDragStart: onDragStart,
      onDragEnd: onDragEnd,
      onAccept: onAccept,
      canDrag: canDrag,
      canAccept: canAccept,
      semanticLabel: semanticLabel,
      child: child,
    );
  }

  /// Creates a pull-to-refresh gesture detector
  Widget createPullToRefreshGestureDetector({
    required Widget child,
    required Future<void> Function() onRefresh,
    double refreshThreshold = 100.0,
    String? semanticLabel,
  }) {
    return _PullToRefreshGestureDetector(
      gestureService: this,
      onRefresh: onRefresh,
      refreshThreshold: refreshThreshold,
      semanticLabel: semanticLabel,
      child: child,
    );
  }

  /// Provides haptic feedback for gesture events
  Future<void> _provideHapticFeedback(GestureType gestureType) async {
    final settings = await _gestureService.getHapticSettings();
    if (!settings.enabled) return;

    switch (gestureType) {
      case GestureType.tap:
        await HapticFeedback.selectionClick();
        break;
      case GestureType.longPress:
        await HapticFeedback.heavyImpact();
        break;
      case GestureType.doubleTap:
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.lightImpact();
        break;
      case GestureType.swipe:
        await HapticFeedback.lightImpact();
        break;
      case GestureType.pinch:
        await HapticFeedback.selectionClick();
        break;
      case GestureType.drag:
        await HapticFeedback.mediumImpact();
        break;
    }
  }

  /// Checks if a gesture is enabled in settings
  Future<bool> _isGestureEnabled(GestureType gestureType) async {
    final settings = await _gestureService.getGestureSettings();
    
    switch (gestureType) {
      case GestureType.tap:
        return true; // Always enabled
      case GestureType.longPress:
        return settings.longPressMenu;
      case GestureType.doubleTap:
        return settings.doubleTapEdit;
      case GestureType.swipe:
        return settings.swipeToComplete || settings.swipeToDelete;
      case GestureType.pinch:
        return true; // Always enabled for accessibility
      case GestureType.drag:
        return true; // Always enabled
    }
  }
}

/// Custom gesture types for mobile interactions
enum GestureType {
  tap,
  longPress,
  doubleTap,
  swipe,
  pinch,
  drag,
}

/// Mobile-optimized gesture detector widget
class _MobileGestureDetectorWidget extends StatefulWidget {
  final MobileGestureService gestureService;
  final Widget child;
  final String? semanticLabel;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;

  const _MobileGestureDetectorWidget({
    required this.gestureService,
    required this.child,
    this.semanticLabel,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
  });

  @override
  State<_MobileGestureDetectorWidget> createState() => _MobileGestureDetectorWidgetState();
}

class _MobileGestureDetectorWidgetState extends State<_MobileGestureDetectorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  DateTime? _lastTapTime;
  bool _isPressed = false;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      child: GestureDetector(
        onTap: _handleTap,
        onLongPress: _handleLongPress,
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed ? _scaleAnimation.value : 1.0,
              child: widget.child,
            );
          },
        ),
      ),
    );
  }

  void _handleTap() async {
    if (!await widget.gestureService._isGestureEnabled(GestureType.tap)) return;

    await widget.gestureService._provideHapticFeedback(GestureType.tap);

    // Check for double tap
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inMilliseconds < MobileGestureService._doubleTapThreshold) {
      _handleDoubleTap();
      return;
    }
    
    _lastTapTime = now;
    
    // Delay single tap to allow for double tap detection
    await Future.delayed(Duration(milliseconds: MobileGestureService._doubleTapThreshold.round()));
    
    if (_lastTapTime == now) {
      widget.onTap?.call();
    }
  }

  void _handleDoubleTap() async {
    if (!await widget.gestureService._isGestureEnabled(GestureType.doubleTap)) return;

    _lastTapTime = null; // Prevent single tap
    await widget.gestureService._provideHapticFeedback(GestureType.doubleTap);
    widget.onDoubleTap?.call();
  }

  void _handleLongPress() async {
    if (!await widget.gestureService._isGestureEnabled(GestureType.longPress)) return;

    await widget.gestureService._provideHapticFeedback(GestureType.longPress);
    widget.onLongPress?.call();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() => _isDragging = true);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    // Track swipe direction and distance
  }

  void _handlePanEnd(DragEndDetails details) async {
    setState(() => _isDragging = false);
    
    if (!await widget.gestureService._isGestureEnabled(GestureType.swipe)) return;

    final velocity = details.velocity.pixelsPerSecond;
    if (velocity.distance < MobileGestureService._velocityThreshold) return;

    await widget.gestureService._provideHapticFeedback(GestureType.swipe);

    // Determine swipe direction
    final dx = velocity.dx;
    final dy = velocity.dy;

    if (dx.abs() > dy.abs()) {
      // Horizontal swipe
      if (dx > 0) {
        widget.onSwipeRight?.call();
      } else {
        widget.onSwipeLeft?.call();
      }
    } else {
      // Vertical swipe
      if (dy > 0) {
        widget.onSwipeDown?.call();
      } else {
        widget.onSwipeUp?.call();
      }
    }
  }
}

/// Tab navigation gesture detector for swipe between tabs
class _TabNavigationGestureDetector extends StatefulWidget {
  final MobileGestureService gestureService;
  final Widget child;
  final int currentIndex;
  final int totalTabs;
  final ValueChanged<int> onTabChanged;
  final bool enableSwipeNavigation;
  final String? semanticLabel;

  const _TabNavigationGestureDetector({
    required this.gestureService,
    required this.child,
    required this.currentIndex,
    required this.totalTabs,
    required this.onTabChanged,
    this.enableSwipeNavigation = true,
    this.semanticLabel,
  });

  @override
  State<_TabNavigationGestureDetector> createState() => _TabNavigationGestureDetectorState();
}

class _TabNavigationGestureDetectorState extends State<_TabNavigationGestureDetector> {
  double _dragDistance = 0.0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enableSwipeNavigation) {
      return widget.child;
    }

    return Semantics(
      label: widget.semanticLabel,
      child: GestureDetector(
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        child: widget.child,
      ),
    );
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragDistance = 0.0;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragDistance += details.delta.dx;
    });
  }

  void _handlePanEnd(DragEndDetails details) async {
    setState(() => _isDragging = false);

    final screenWidth = MediaQuery.of(context).size.width;

    if (!await widget.gestureService._isGestureEnabled(GestureType.swipe)) return;

    final swipeThreshold = screenWidth * MobileGestureService._swipeThreshold;

    if (_dragDistance.abs() < swipeThreshold) return;

    await widget.gestureService._provideHapticFeedback(GestureType.swipe);

    int newIndex = widget.currentIndex;
    
    if (_dragDistance > 0 && widget.currentIndex > 0) {
      // Swipe right - go to previous tab
      newIndex = widget.currentIndex - 1;
    } else if (_dragDistance < 0 && widget.currentIndex < widget.totalTabs - 1) {
      // Swipe left - go to next tab
      newIndex = widget.currentIndex + 1;
    }

    if (newIndex != widget.currentIndex) {
      widget.onTabChanged(newIndex);
    }
  }
}

/// Zoomable gesture detector for timeline/gantt charts
class _ZoomableGestureDetector extends StatefulWidget {
  final MobileGestureService gestureService;
  final Widget child;
  final double minScale;
  final double maxScale;
  final ValueChanged<double>? onScaleChanged;
  final VoidCallback? onScaleStart;
  final VoidCallback? onScaleEnd;
  final String? semanticLabel;

  const _ZoomableGestureDetector({
    required this.gestureService,
    required this.child,
    this.minScale = 0.5,
    this.maxScale = 3.0,
    this.onScaleChanged,
    this.onScaleStart,
    this.onScaleEnd,
    this.semanticLabel,
  });

  @override
  State<_ZoomableGestureDetector> createState() => _ZoomableGestureDetectorState();
}

class _ZoomableGestureDetectorState extends State<_ZoomableGestureDetector> {
  double _scale = 1.0;
  double _previousScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      child: GestureDetector(
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onScaleEnd: _handleScaleEnd,
        child: Transform.scale(
          scale: _scale,
          child: widget.child,
        ),
      ),
    );
  }

  void _handleScaleStart(ScaleStartDetails details) async {
    _previousScale = _scale;
    widget.onScaleStart?.call();
    
    if (await widget.gestureService._isGestureEnabled(GestureType.pinch)) {
      await widget.gestureService._provideHapticFeedback(GestureType.pinch);
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_previousScale * details.scale).clamp(widget.minScale, widget.maxScale);
    });
    
    widget.onScaleChanged?.call(_scale);
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    widget.onScaleEnd?.call();
  }
}

/// Drag and drop gesture detector for Kanban boards
class _DragDropGestureDetector extends StatefulWidget {
  final MobileGestureService gestureService;
  final Widget child;
  final String itemId;
  final String itemType;
  final VoidCallback? onDragStart;
  final ValueChanged<String>? onDragEnd;
  final ValueChanged<DragTargetDetails>? onAccept;
  final bool canDrag;
  final bool canAccept;
  final String? semanticLabel;

  const _DragDropGestureDetector({
    required this.gestureService,
    required this.child,
    required this.itemId,
    required this.itemType,
    this.onDragStart,
    this.onDragEnd,
    this.onAccept,
    this.canDrag = true,
    this.canAccept = true,
    this.semanticLabel,
  });

  @override
  State<_DragDropGestureDetector> createState() => _DragDropGestureDetectorState();
}

class _DragDropGestureDetectorState extends State<_DragDropGestureDetector> {
  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    if (widget.canDrag) {
      child = Draggable<String>(
        data: widget.itemId,
        feedback: Material(
          color: Colors.transparent,
          child: Transform.scale(
            scale: 1.1,
            child: Opacity(
              opacity: 0.8,
              child: widget.child,
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: widget.child,
        ),
        onDragStarted: () async {
          widget.onDragStart?.call();
          if (await widget.gestureService._isGestureEnabled(GestureType.drag)) {
            await widget.gestureService._provideHapticFeedback(GestureType.drag);
          }
        },
        onDragEnd: (details) {
          widget.onDragEnd?.call(widget.itemId);
        },
        child: child,
      );
    }

    if (widget.canAccept) {
      child = DragTarget<String>(
        onAcceptWithDetails: (data) {
          widget.onAccept?.call(DragTargetDetails(data: data, offset: Offset.zero));
        },
        builder: (context, candidateData, rejectedData) {
          return Semantics(
            label: widget.semanticLabel,
            child: child,
          );
        },
      );
    }

    return child;
  }
}

/// Pull-to-refresh gesture detector
class _PullToRefreshGestureDetector extends StatefulWidget {
  final MobileGestureService gestureService;
  final Widget child;
  final Future<void> Function() onRefresh;
  final double refreshThreshold;
  final String? semanticLabel;

  const _PullToRefreshGestureDetector({
    required this.gestureService,
    required this.child,
    required this.onRefresh,
    this.refreshThreshold = 100.0,
    this.semanticLabel,
  });

  @override
  State<_PullToRefreshGestureDetector> createState() => _PullToRefreshGestureDetectorState();
}

class _PullToRefreshGestureDetectorState extends State<_PullToRefreshGestureDetector> {
  final double _pullDistance = 0.0;
  final bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      child: RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: widget.child,
      ),
    );
  }
}

/// Provider for mobile gesture service
final mobileGestureServiceProvider = Provider<MobileGestureService>((ref) {
  final gestureService = ref.read(gestureCustomizationServiceProvider);
  final feedbackService = SlidableFeedbackService();
  
  return MobileGestureService(gestureService, feedbackService);
});