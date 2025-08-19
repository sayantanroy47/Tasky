import 'package:flutter/material.dart';
import '../../core/theme/material3/motion_system.dart';

/// Enhanced staggered animations for lists with multiple entrance patterns
class EnhancedStaggeredListView extends StatefulWidget {
  final List<Widget> children;
  final Duration itemDelay;
  final Curve curve;
  final AnimationPattern pattern;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool reverse;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool autoStart;
  
  const EnhancedStaggeredListView({
    super.key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 80),
    this.curve = ExpressiveMotionSystem.emphasizedDecelerate,
    this.pattern = AnimationPattern.slideUp,
    this.controller,
    this.padding,
    this.reverse = false,
    this.shrinkWrap = false,
    this.physics,
    this.autoStart = true,
  });
  
  @override
  State<EnhancedStaggeredListView> createState() => _EnhancedStaggeredListViewState();
}

class _EnhancedStaggeredListViewState extends State<EnhancedStaggeredListView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.autoStart) {
      _controller.forward();
    }
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: Duration(
        milliseconds: widget.itemDelay.inMilliseconds * widget.children.length + 500,
      ),
      vsync: this,
    );
    
    _animations = List.generate(
      widget.children.length,
      (index) => _createStaggeredAnimation(index),
    );
  }

  Animation<double> _createStaggeredAnimation(int index) {
    final actualIndex = widget.reverse ? (widget.children.length - 1 - index) : index;
    final start = actualIndex / widget.children.length * 0.6;
    final end = start + 0.4;
    
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(
        start.clamp(0.0, 1.0),
        end.clamp(0.0, 1.0),
        curve: widget.curve,
      ),
    );
  }

  @override
  void didUpdateWidget(EnhancedStaggeredListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _setupAnimations();
      if (widget.autoStart) {
        _controller.forward();
      }
    }
  }

  /// Start the animation manually
  void startAnimation() {
    _controller.forward();
  }

  /// Reverse the animation
  void reverseAnimation() {
    _controller.reverse();
  }

  /// Reset and restart animation
  void restartAnimation() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.controller,
      padding: widget.padding,
      reverse: widget.reverse,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return _buildAnimatedItem(index, widget.children[index]);
          },
        );
      },
    );
  }

  Widget _buildAnimatedItem(int index, Widget child) {
    final animation = _animations[index];
    
    switch (widget.pattern) {
      case AnimationPattern.slideUp:
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
        
      case AnimationPattern.slideDown:
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.5),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
        
      case AnimationPattern.slideLeft:
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
        
      case AnimationPattern.slideRight:
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
        
      case AnimationPattern.scale:
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.8,
              end: 1.0,
            ).animate(animation),
            child: child,
          ),
        );
        
      case AnimationPattern.fadeOnly:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
        
      case AnimationPattern.bounceIn:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.5,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
        
      case AnimationPattern.flipIn:
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final isShowingFront = animation.value > 0.5;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(isShowingFront ? 0.0 : 3.14159),
              child: isShowingFront ? child : Container(),
            );
          },
          child: child,
        );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Animation patterns for list entrance
enum AnimationPattern {
  slideUp,
  slideDown,
  slideLeft,
  slideRight,
  scale,
  fadeOnly,
  bounceIn,
  flipIn,
}

/// Animated list item that can be added or removed with animation
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final AnimationPattern pattern;
  final bool isVisible;
  final VoidCallback? onAnimationComplete;
  
  const AnimatedListItem({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = ExpressiveMotionSystem.emphasizedDecelerate,
    this.pattern = AnimationPattern.slideUp,
    this.isVisible = true,
    this.onAnimationComplete,
  });
  
  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || 
          status == AnimationStatus.dismissed) {
        widget.onAnimationComplete?.call();
      }
    });
    
    if (widget.isVisible) {
      _controller.forward();
    }
  }
  
  @override
  void didUpdateWidget(AnimatedListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        switch (widget.pattern) {
          case AnimationPattern.slideUp:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(_animation),
              child: FadeTransition(
                opacity: _animation,
                child: widget.child,
              ),
            );
            
          case AnimationPattern.scale:
            return ScaleTransition(
              scale: _animation,
              child: FadeTransition(
                opacity: _animation,
                child: widget.child,
              ),
            );
            
          case AnimationPattern.fadeOnly:
            return FadeTransition(
              opacity: _animation,
              child: widget.child,
            );
            
          default:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(_animation),
              child: FadeTransition(
                opacity: _animation,
                child: widget.child,
              ),
            );
        }
      },
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Grid version of staggered animations
class EnhancedStaggeredGridView extends StatefulWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final Duration itemDelay;
  final Curve curve;
  final AnimationPattern pattern;
  final EdgeInsets? padding;
  final bool autoStart;
  
  const EnhancedStaggeredGridView({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 8,
    this.mainAxisSpacing = 8,
    this.childAspectRatio = 1.0,
    this.itemDelay = const Duration(milliseconds: 50),
    this.curve = ExpressiveMotionSystem.emphasizedDecelerate,
    this.pattern = AnimationPattern.scale,
    this.padding,
    this.autoStart = true,
  });
  
  @override
  State<EnhancedStaggeredGridView> createState() => _EnhancedStaggeredGridViewState();
}

class _EnhancedStaggeredGridViewState extends State<EnhancedStaggeredGridView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.autoStart) {
      _controller.forward();
    }
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: Duration(
        milliseconds: widget.itemDelay.inMilliseconds * widget.children.length + 300,
      ),
      vsync: this,
    );
    
    _animations = List.generate(
      widget.children.length,
      (index) => _createGridAnimation(index),
    );
  }

  Animation<double> _createGridAnimation(int index) {
    // Animate by rows for grid layout
    final row = index ~/ widget.crossAxisCount;
    final totalRows = (widget.children.length / widget.crossAxisCount).ceil();
    
    final start = row / totalRows * 0.7;
    final end = start + 0.3;
    
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(
        start.clamp(0.0, 1.0),
        end.clamp(0.0, 1.0),
        curve: widget.curve,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: widget.padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: widget.crossAxisSpacing,
        mainAxisSpacing: widget.mainAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return _buildAnimatedGridItem(index, widget.children[index]);
          },
        );
      },
    );
  }

  Widget _buildAnimatedGridItem(int index, Widget child) {
    final animation = _animations[index];
    
    switch (widget.pattern) {
      case AnimationPattern.scale:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
        
      case AnimationPattern.bounceIn:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.5,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          )),
          child: child,
        );
        
      default:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Utility class for creating common list animations
class ListAnimationUtils {
  /// Create a staggered entrance animation for any list
  static Widget createStaggeredList({
    required List<Widget> children,
    Duration itemDelay = const Duration(milliseconds: 80),
    AnimationPattern pattern = AnimationPattern.slideUp,
    bool autoStart = true,
  }) {
    return EnhancedStaggeredListView(
      itemDelay: itemDelay,
      pattern: pattern,
      autoStart: autoStart,
      children: children,
    );
  }

  /// Create a staggered entrance animation for a grid
  static Widget createStaggeredGrid({
    required List<Widget> children,
    int crossAxisCount = 2,
    Duration itemDelay = const Duration(milliseconds: 50),
    AnimationPattern pattern = AnimationPattern.scale,
  }) {
    return EnhancedStaggeredGridView(
      crossAxisCount: crossAxisCount,
      itemDelay: itemDelay,
      pattern: pattern,
      children: children,
    );
  }
}