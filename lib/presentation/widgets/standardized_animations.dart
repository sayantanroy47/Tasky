import 'package:flutter/material.dart';

import '../../core/design_system/design_tokens.dart';
import '../../core/theme/material3/motion_system.dart';

/// Standardized animation system that eliminates animation chaos
/// 
/// Eliminates Animation Duration Inconsistency by:
/// - Enforcing consistent animation timings based on MotionTokens
/// - Providing semantic animation patterns for different interaction types
/// - Preventing hardcoded Duration() throughout the app
/// - Using ExpressiveMotionSystem for consistent motion language
class StandardizedAnimations {
  // Core timing values from MotionTokens
  static Duration get instant => MotionTokens.instant; // 0ms
  static Duration get quick => const Duration(milliseconds: 100); // 100ms  
  static Duration get fast => MotionTokens.fast; // 150ms
  static Duration get normal => MotionTokens.normal; // 300ms
  static Duration get slow => MotionTokens.slow; // 500ms
  static Duration get slower => MotionTokens.slower; // 800ms
  static Duration get slowest => const Duration(milliseconds: 1000); // 1000ms

  // Semantic durations for different interaction types
  static Duration get tap => quick; // 100ms - Button taps, quick feedback
  static Duration get hover => const Duration(milliseconds: 50); // 50ms - Hover state changes
  static Duration get focus => fast; // 150ms - Focus ring transitions
  static Duration get pageTransition => const Duration(milliseconds: 200); // 200ms - Page navigation
  static Duration get modalTransition => normal; // 300ms - Modal/dialog appearance  
  static Duration get drawerTransition => const Duration(milliseconds: 400); // 400ms - Side drawer sliding
  static Duration get loadingState => slow; // 500ms - Loading state changes
  static Duration get dataUpdate => fast; // 150ms - Data refresh animations

  // Standard curves from ExpressiveMotionSystem
  static Curve get standardCurve => ExpressiveMotionSystem.standard; // Ease-in-out
  static Curve get accelerateCurve => ExpressiveMotionSystem.standardAccelerate; // Ease-in
  static Curve get decelerateCurve => ExpressiveMotionSystem.standardDecelerate; // Ease-out
  static Curve get emphasizedCurve => ExpressiveMotionSystem.emphasizedEasing; // Custom emphasized

  /// Create a standardized AnimationController with semantic timing
  static AnimationController createController({
    required TickerProvider vsync,
    Duration? duration,
    AnimationBehavior behavior = AnimationBehavior.normal,
  }) {
    return AnimationController(
      duration: duration ?? normal,
      vsync: vsync,
      animationBehavior: behavior,
    );
  }

  /// Create semantic animation controllers
  static AnimationController tapController({required TickerProvider vsync}) =>
      createController(vsync: vsync, duration: tap);

  static AnimationController hoverController({required TickerProvider vsync}) =>
      createController(vsync: vsync, duration: hover);

  static AnimationController pageController({required TickerProvider vsync}) =>
      createController(vsync: vsync, duration: pageTransition);

  static AnimationController modalController({required TickerProvider vsync}) =>
      createController(vsync: vsync, duration: modalTransition);

  /// Create standardized Tween animations
  static Animation<double> createFadeAnimation({
    required AnimationController controller,
    Curve curve = Curves.easeInOut,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return Tween<double>(begin: begin, end: end)
        .animate(CurvedAnimation(parent: controller, curve: curve));
  }

  static Animation<Offset> createSlideAnimation({
    required AnimationController controller,
    Curve curve = Curves.easeInOut,
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
  }) {
    return Tween<Offset>(begin: begin, end: end)
        .animate(CurvedAnimation(parent: controller, curve: curve));
  }

  static Animation<double> createScaleAnimation({
    required AnimationController controller,
    Curve curve = Curves.easeInOut,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return Tween<double>(begin: begin, end: end)
        .animate(CurvedAnimation(parent: controller, curve: curve));
  }

  /// Semantic animation presets
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 200),
    Curve curve = Curves.easeInOut,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: child,
      ),
      child: child,
    );
  }

  static Widget slideIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 200),
    Curve curve = Curves.easeInOut,
    Offset begin = const Offset(1.0, 0.0),
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      tween: Tween(begin: begin, end: Offset.zero),
      curve: curve,
      builder: (context, value, child) => SlideTransition(
        position: AlwaysStoppedAnimation(value),
        child: child!,
      ),
      child: child,
    );
  }

  static Widget scaleIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 200),
    Curve curve = Curves.easeInOut,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: child,
      ),
      child: child,
    );
  }

  /// List animation helpers
  static Widget staggeredListItem({
    required Widget child,
    required int index,
    Duration baseDelay = const Duration(milliseconds: 50),
    Duration animationDuration = const Duration(milliseconds: 200),
  }) {
    return TweenAnimationBuilder<double>(
      duration: animationDuration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: standardCurve,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, 20 * (1 - value)),
        child: Opacity(
          opacity: value,
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Mixin for easy animation management in StatefulWidgets
mixin StandardizedAnimationMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {
  late final AnimationController _primaryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _primaryController = StandardizedAnimations.createController(vsync: this);
    _fadeAnimation = StandardizedAnimations.createFadeAnimation(controller: _primaryController);
    _slideAnimation = StandardizedAnimations.createSlideAnimation(controller: _primaryController);
    _scaleAnimation = StandardizedAnimations.createScaleAnimation(controller: _primaryController);
  }

  @override
  void dispose() {
    _primaryController.dispose();
    super.dispose();
  }

  // Easy access to common animations
  AnimationController get primaryController => _primaryController;
  Animation<double> get fadeAnimation => _fadeAnimation;
  Animation<Offset> get slideAnimation => _slideAnimation;
  Animation<double> get scaleAnimation => _scaleAnimation;

  // Semantic animation triggers
  Future<void> animateIn() => _primaryController.forward();
  Future<void> animateOut() => _primaryController.reverse();
  Future<void> animateReset() async {
    _primaryController.reset();
  }
}

/// Widget builder for easy standardized animations
class StandardizedAnimatedWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final AnimationType type;
  final bool autoStart;

  const StandardizedAnimatedWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.type = AnimationType.fadeIn,
    this.autoStart = true,
  });

  @override
  State<StandardizedAnimatedWidget> createState() => _StandardizedAnimatedWidgetState();
}

class _StandardizedAnimatedWidgetState extends State<StandardizedAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.autoStart) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case AnimationType.fadeIn:
        return FadeTransition(opacity: _animation, child: widget.child);
      case AnimationType.slideIn:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(_animation),
          child: widget.child,
        );
      case AnimationType.scaleIn:
        return ScaleTransition(scale: _animation, child: widget.child);
    }
  }
}

enum AnimationType { fadeIn, slideIn, scaleIn }