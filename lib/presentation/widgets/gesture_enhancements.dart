import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/accessibility/accessibility_constants.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';
import 'glassmorphism_container.dart';

/// Enhanced gesture detector with accessibility and haptic feedback
class EnhancedGestureDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final Function(DragStartDetails)? onPanStart;
  final Function(DragUpdateDetails)? onPanUpdate;
  final Function(DragEndDetails)? onPanEnd;
  final bool enableHapticFeedback;
  final bool enableScaleGestures;
  final String? semanticLabel;
  final String? semanticHint;
  final Duration longPressDuration;
  final double scaleFactor;

  const EnhancedGestureDetector({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.enableHapticFeedback = true,
    this.enableScaleGestures = false,
    this.semanticLabel,
    this.semanticHint,
    this.longPressDuration = const Duration(milliseconds: 500),
    this.scaleFactor = 0.95,
  });

  @override
  State<EnhancedGestureDetector> createState() => _EnhancedGestureDetectorState();
}

class _EnhancedGestureDetectorState extends State<EnhancedGestureDetector>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  bool _isPressed = false;
  // bool _isLongPressing = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shouldReduceMotion = AccessibilityUtils.shouldReduceMotion(context);
    
    Widget child = AnimatedBuilder(
      animation: shouldReduceMotion ? kAlwaysCompleteAnimation : _scaleAnimation,
      builder: (context, child) {
        final scale = shouldReduceMotion ? 1.0 : _scaleAnimation.value;
        return Transform.scale(
          scale: _isPressed ? scale : 1.0,
          child: widget.child,
        );
      },
    );

    child = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      onLongPressCancel: _onLongPressCancel,
      onDoubleTap: widget.onDoubleTap,
      onPanStart: widget.onPanStart,
      onPanUpdate: widget.onPanUpdate,
      onPanEnd: widget.onPanEnd,
      child: child,
    );

    if (widget.semanticLabel != null || widget.semanticHint != null) {
      child = Semantics(
        label: widget.semanticLabel,
        hint: widget.semanticHint,
        button: widget.onTap != null,
        child: child,
      );
    }

    return child;
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    if (!AccessibilityUtils.shouldReduceMotion(context)) {
      _scaleController.forward();
    }
    
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    if (!AccessibilityUtils.shouldReduceMotion(context)) {
      _scaleController.reverse();
    }
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    if (!AccessibilityUtils.shouldReduceMotion(context)) {
      _scaleController.reverse();
    }
  }

  void _onLongPressStart(LongPressStartDetails details) {
    // setState(() => _isLongPressing = true);
    
    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    
    AccessibilityUtils.announceToScreenReader(
      context,
      'Long press activated',
    );
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    // setState(() => _isLongPressing = false);
    widget.onLongPress?.call();
  }

  void _onLongPressCancel() {
    // setState(() => _isLongPressing = false);
  }
}

/// Multi-touch gesture handler with glassmorphism feedback
class MultiTouchGestureArea extends StatefulWidget {
  final Widget child;
  final Function(ScaleStartDetails)? onScaleStart;
  final Function(ScaleUpdateDetails)? onScaleUpdate;
  final Function(ScaleEndDetails)? onScaleEnd;
  final Function(int)? onPointerCountChanged;
  final bool enableHapticFeedback;
  final double minScale;
  final double maxScale;

  const MultiTouchGestureArea({
    super.key,
    required this.child,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.onPointerCountChanged,
    this.enableHapticFeedback = true,
    this.minScale = 0.8,
    this.maxScale = 3.0,
  });

  @override
  State<MultiTouchGestureArea> createState() => _MultiTouchGestureAreaState();
}

class _MultiTouchGestureAreaState extends State<MultiTouchGestureArea> {
  int _pointerCount = 0;
  double _currentScale = 1.0;
  bool _isScaling = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: GestureDetector(
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
        child: Stack(
          children: [
            widget.child,
            if (_pointerCount > 1)
              _buildMultiTouchIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiTouchIndicator() {
    final theme = Theme.of(context);
    
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Center(
            child: GlassmorphismContainer(
              level: GlassLevel.floating,
              width: 100,
              height: 40,
              child: Center(
                child: Text(
                  '${(_currentScale * 100).round()}%',
                  style: TextStyle(
                    fontSize: TypographyConstants.textSM,
                    fontWeight: TypographyConstants.medium,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    setState(() => _pointerCount++);
    widget.onPointerCountChanged?.call(_pointerCount);
    
    if (_pointerCount == 2 && widget.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() => _pointerCount--);
    widget.onPointerCountChanged?.call(_pointerCount);
  }

  void _onPointerCancel(PointerCancelEvent event) {
    setState(() => _pointerCount--);
    widget.onPointerCountChanged?.call(_pointerCount);
  }

  void _onScaleStart(ScaleStartDetails details) {
    _isScaling = true;
    widget.onScaleStart?.call(details);
    
    AccessibilityUtils.announceToScreenReader(
      context,
      'Scaling started',
    );
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (!_isScaling) return;
    
    final newScale = (details.scale * _currentScale).clamp(widget.minScale, widget.maxScale);
    
    if (newScale != _currentScale) {
      setState(() => _currentScale = newScale);
      widget.onScaleUpdate?.call(details);
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _isScaling = false;
    widget.onScaleEnd?.call(details);
    
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    
    AccessibilityUtils.announceToScreenReader(
      context,
      'Scaling ended at ${(_currentScale * 100).round()} percent',
    );
  }
}

/// Drag and drop handler with glassmorphism feedback
class DragDropArea extends StatefulWidget {
  final Widget child;
  final bool canDrag;
  final bool canReceive;
  final String? dragData;
  final Function(String)? onDataReceived;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragCompleted;
  final VoidCallback? onDragCanceled;
  final Widget? dragFeedback;
  final Widget? childWhenDragging;

  const DragDropArea({
    super.key,
    required this.child,
    this.canDrag = false,
    this.canReceive = false,
    this.dragData,
    this.onDataReceived,
    this.onDragStarted,
    this.onDragCompleted,
    this.onDragCanceled,
    this.dragFeedback,
    this.childWhenDragging,
  });

  @override
  State<DragDropArea> createState() => _DragDropAreaState();
}

class _DragDropAreaState extends State<DragDropArea>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  
  bool _isHovering = false;
  // bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shouldReduceMotion = AccessibilityUtils.shouldReduceMotion(context);
    
    Widget child = widget.child;
    
    // Wrap with drag source if draggable
    if (widget.canDrag && widget.dragData != null) {
      child = Draggable<String>(
        data: widget.dragData!,
        feedback: widget.dragFeedback ?? _buildDragFeedback(),
        childWhenDragging: widget.childWhenDragging ?? _buildChildWhenDragging(),
        onDragStarted: () {
          // setState(() => _isDragging = true);
          widget.onDragStarted?.call();
          HapticFeedback.mediumImpact();
          
          AccessibilityUtils.announceToScreenReader(
            context,
            'Drag started',
          );
        },
        onDragCompleted: () {
          // setState(() => _isDragging = false);
          widget.onDragCompleted?.call();
          HapticFeedback.lightImpact();
          
          AccessibilityUtils.announceToScreenReader(
            context,
            'Drag completed',
          );
        },
        onDraggableCanceled: (velocity, offset) {
          // setState(() => _isDragging = false);
          widget.onDragCanceled?.call();
          HapticFeedback.lightImpact();
          
          AccessibilityUtils.announceToScreenReader(
            context,
            'Drag canceled',
          );
        },
        child: child,
      );
    }
    
    // Wrap with drop target if can receive
    if (widget.canReceive) {
      child = DragTarget<String>(
        onWillAcceptWithDetails: (details) => true,
        onAcceptWithDetails: (details) {
          final data = details.data;
          setState(() => _isHovering = false);
          if (!shouldReduceMotion) {
            _hoverController.reverse();
          }
          widget.onDataReceived?.call(data);
          HapticFeedback.mediumImpact();
          
          AccessibilityUtils.announceToScreenReader(
            context,
            'Item received',
          );
        },
        onMove: (details) {
          if (!_isHovering) {
            setState(() => _isHovering = true);
            if (!shouldReduceMotion) {
              _hoverController.forward();
            }
            HapticFeedback.selectionClick();
          }
        },
        onLeave: (data) {
          setState(() => _isHovering = false);
          if (!shouldReduceMotion) {
            _hoverController.reverse();
          }
        },
        builder: (context, candidateData, rejectedData) {
          return AnimatedBuilder(
            animation: shouldReduceMotion ? kAlwaysCompleteAnimation : _hoverAnimation,
            builder: (context, child) {
              final scale = shouldReduceMotion ? 1.0 : _hoverAnimation.value;
              return Transform.scale(
                scale: _isHovering ? scale : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    border: _isHovering
                        ? Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(
                      TypographyConstants.radiusStandard,
                    ),
                  ),
                  child: child,
                ),
              );
            },
            child: child,
          );
        },
      );
    }
    
    return Semantics(
      button: widget.canDrag,
      label: widget.canDrag ? 'Draggable item' : null,
      hint: widget.canReceive ? 'Drop zone' : null,
      child: child,
    );
  }

  Widget _buildDragFeedback() {
    return Material(
      color: Colors.transparent,
      child: Opacity(
        opacity: 0.8,
        child: Transform.scale(
          scale: 1.1,
          child: GlassmorphismContainer(
            level: GlassLevel.floating,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  Widget _buildChildWhenDragging() {
    return Opacity(
      opacity: 0.5,
      child: widget.child,
    );
  }
}

/// Swipe gesture detector with directional feedback
class SwipeGestureDetector extends StatefulWidget {
  final Widget child;
  final Function(SwipeDirection)? onSwipe;
  final double sensitivity;
  final bool enableHapticFeedback;
  final Set<SwipeDirection> enabledDirections;

  const SwipeGestureDetector({
    super.key,
    required this.child,
    this.onSwipe,
    this.sensitivity = 50.0,
    this.enableHapticFeedback = true,
    this.enabledDirections = const {
      SwipeDirection.up,
      SwipeDirection.down,
      SwipeDirection.left,
      SwipeDirection.right,
    },
  });

  @override
  State<SwipeGestureDetector> createState() => _SwipeGestureDetectorState();
}

class _SwipeGestureDetectorState extends State<SwipeGestureDetector>
    with SingleTickerProviderStateMixin {
  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnimation;
  
  Offset? _startPosition;
  SwipeDirection? _currentDirection;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _feedbackAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: AnimatedBuilder(
        animation: _feedbackAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: _getSwipeOffset(),
            child: widget.child,
          );
        },
      ),
    );
  }

  Offset _getSwipeOffset() {
    if (_currentDirection == null || AccessibilityUtils.shouldReduceMotion(context)) {
      return Offset.zero;
    }
    
    final progress = _feedbackAnimation.value;
    const maxOffset = 5.0;
    
    switch (_currentDirection!) {
      case SwipeDirection.left:
        return Offset(-maxOffset * progress, 0);
      case SwipeDirection.right:
        return Offset(maxOffset * progress, 0);
      case SwipeDirection.up:
        return Offset(0, -maxOffset * progress);
      case SwipeDirection.down:
        return Offset(0, maxOffset * progress);
    }
  }

  void _onPanStart(DragStartDetails details) {
    _startPosition = details.localPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_startPosition == null) return;
    
    final delta = details.localPosition - _startPosition!;
    final direction = _getSwipeDirection(delta);
    
    if (direction != _currentDirection && direction != null) {
      setState(() => _currentDirection = direction);
      
      if (widget.enabledDirections.contains(direction)) {
        _feedbackController.forward().then((_) {
          _feedbackController.reverse();
        });
        
        if (widget.enableHapticFeedback) {
          HapticFeedback.selectionClick();
        }
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_startPosition == null || _currentDirection == null) return;
    
    if (widget.enabledDirections.contains(_currentDirection!)) {
      widget.onSwipe?.call(_currentDirection!);
      
      if (widget.enableHapticFeedback) {
        HapticFeedback.mediumImpact();
      }
      
      AccessibilityUtils.announceToScreenReader(
        context,
        'Swiped ${_currentDirection!.name}',
      );
    }
    
    _startPosition = null;
    _currentDirection = null;
  }

  SwipeDirection? _getSwipeDirection(Offset delta) {
    if (delta.dx.abs() > delta.dy.abs()) {
      if (delta.dx.abs() > widget.sensitivity) {
        return delta.dx > 0 ? SwipeDirection.right : SwipeDirection.left;
      }
    } else {
      if (delta.dy.abs() > widget.sensitivity) {
        return delta.dy > 0 ? SwipeDirection.down : SwipeDirection.up;
      }
    }
    return null;
  }
}

/// Swipe direction enumeration
enum SwipeDirection {
  up,
  down,
  left,
  right,
}

/// Rotation gesture detector
class RotationGestureDetector extends StatefulWidget {
  final Widget child;
  final Function(double)? onRotationUpdate;
  final Function(double)? onRotationEnd;
  final bool enableHapticFeedback;
  final double sensitivity;

  const RotationGestureDetector({
    super.key,
    required this.child,
    this.onRotationUpdate,
    this.onRotationEnd,
    this.enableHapticFeedback = true,
    this.sensitivity = 0.1,
  });

  @override
  State<RotationGestureDetector> createState() => _RotationGestureDetectorState();
}

class _RotationGestureDetectorState extends State<RotationGestureDetector> {
  double _rotation = 0.0;
  double _lastRotation = 0.0;
  bool _isRotating = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      child: Transform.rotate(
        angle: _rotation,
        child: widget.child,
      ),
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _isRotating = false;
    _lastRotation = 0.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.rotation.abs() > widget.sensitivity) {
      if (!_isRotating) {
        _isRotating = true;
        if (widget.enableHapticFeedback) {
          HapticFeedback.selectionClick();
        }
        
        AccessibilityUtils.announceToScreenReader(
          context,
          'Rotation started',
        );
      }
      
      final rotationDelta = details.rotation - _lastRotation;
      setState(() => _rotation += rotationDelta);
      _lastRotation = details.rotation;
      
      widget.onRotationUpdate?.call(_rotation);
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (_isRotating) {
      widget.onRotationEnd?.call(_rotation);
      
      if (widget.enableHapticFeedback) {
        HapticFeedback.lightImpact();
      }
      
      AccessibilityUtils.announceToScreenReader(
        context,
        'Rotation ended',
      );
    }
    
    _isRotating = false;
    _lastRotation = 0.0;
  }
}