import 'package:flutter/material.dart';
import '../models/theme_animations.dart';

/// Material 3 Expressive Motion System
/// Fluid, physics-based animations with choreographed sequences
class ExpressiveMotionSystem {
  /// Standard easing curves for Material 3
  static const Curve emphasizedEasing = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);
  static const Curve standard = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve standardAccelerate = Cubic(0.3, 0.0, 1.0, 1.0);
  static const Curve standardDecelerate = Cubic(0.0, 0.0, 0.0, 1.0);
  
  /// Duration tokens for Material 3
  static const Duration durationShort1 = Duration(milliseconds: 50);
  static const Duration durationShort2 = Duration(milliseconds: 100);
  static const Duration durationShort3 = Duration(milliseconds: 150);
  static const Duration durationShort4 = Duration(milliseconds: 200);
  static const Duration durationMedium1 = Duration(milliseconds: 250);
  static const Duration durationMedium2 = Duration(milliseconds: 300);
  static const Duration durationMedium3 = Duration(milliseconds: 350);
  static const Duration durationMedium4 = Duration(milliseconds: 400);
  static const Duration durationLong1 = Duration(milliseconds: 450);
  static const Duration durationLong2 = Duration(milliseconds: 500);
  static const Duration durationLong3 = Duration(milliseconds: 550);
  static const Duration durationLong4 = Duration(milliseconds: 600);
  static const Duration durationExtraLong1 = Duration(milliseconds: 700);
  static const Duration durationExtraLong2 = Duration(milliseconds: 800);
  static const Duration durationExtraLong3 = Duration(milliseconds: 900);
  static const Duration durationExtraLong4 = Duration(milliseconds: 1000);
  
  /// Create theme animations with expressive motion
  static ThemeAnimations createAnimations() {
    return const ThemeAnimations(
      fast: durationShort2,
      medium: durationMedium2,
      slow: durationLong2,
      verySlow: durationExtraLong2,
      
      primaryCurve: emphasizedEasing,
      secondaryCurve: standard,
      entranceCurve: emphasizedDecelerate,
      exitCurve: emphasizedAccelerate,
      
      // Particles
      enableParticles: true,
      particleConfig: ParticleConfig(
        density: ParticleDensity.medium,
        speed: ParticleSpeed.medium,
        style: ParticleStyle.organic,
        enableGlow: true,
        opacity: 0.6,
        size: 1.0,
      ),
    );
  }
  
  /// Create a spring animation with custom physics
  static SpringDescription createSpring({
    double mass = 1.0,
    double stiffness = 300.0,
    double damping = 20.0,
  }) {
    return SpringDescription(
      mass: mass,
      stiffness: stiffness,
      damping: damping,
    );
  }
  
  /// Create a choreographed stagger animation controller
  static AnimationController createStaggerController({
    required TickerProvider vsync,
    required int itemCount,
    Duration itemDelay = const Duration(milliseconds: 50),
    Duration totalDuration = const Duration(milliseconds: 800),
  }) {
    return AnimationController(
      duration: totalDuration,
      vsync: vsync,
    );
  }
  
  /// Get staggered animation for a specific index
  static Animation<double> getStaggerAnimation({
    required AnimationController controller,
    required int index,
    required int totalItems,
    Curve curve = emphasizedEasing,
  }) {
    final double start = index / totalItems * 0.5;
    final double end = start + 0.5;
    
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          start.clamp(0.0, 1.0),
          end.clamp(0.0, 1.0),
          curve: curve,
        ),
      ),
    );
  }
}

/// Hero animation wrapper with Material 3 motion
class ExpressiveHero extends StatelessWidget {
  final String tag;
  final Widget child;
  final CreateRectTween? createRectTween;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;
  
  const ExpressiveHero({
    super.key,
    required this.tag,
    required this.child,
    this.createRectTween,
    this.flightShuttleBuilder,
  });
  
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      createRectTween: createRectTween ?? _createExpressiveRectTween,
      flightShuttleBuilder: flightShuttleBuilder ?? _defaultFlightShuttleBuilder,
      child: child,
    );
  }
  
  static CreateRectTween _createExpressiveRectTween = (begin, end) {
    return MaterialRectArcTween(begin: begin, end: end);
  };
  
  static Widget _defaultFlightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(toHeroContext).style,
      child: toHeroContext.widget,
    );
  }
}

/// Animated container with spring physics
class SpringAnimatedContainer extends StatefulWidget {
  final Duration duration;
  final Curve curve;
  final double? width;
  final double? height;
  final Color? color;
  final Decoration? decoration;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? child;
  final AlignmentGeometry? alignment;
  final BorderRadiusGeometry? borderRadius;
  
  const SpringAnimatedContainer({
    super.key,
    this.duration = ExpressiveMotionSystem.durationMedium2,
    this.curve = ExpressiveMotionSystem.emphasizedEasing,
    this.width,
    this.height,
    this.color,
    this.decoration,
    this.padding,
    this.margin,
    this.child,
    this.alignment,
    this.borderRadius,
  });
  
  @override
  State<SpringAnimatedContainer> createState() => _SpringAnimatedContainerState();
}

class _SpringAnimatedContainerState extends State<SpringAnimatedContainer>
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
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return AnimatedContainer(
          duration: widget.duration,
          curve: widget.curve,
          width: widget.width,
          height: widget.height,
          decoration: widget.decoration ?? (widget.color != null
            ? BoxDecoration(
                color: widget.color,
                borderRadius: widget.borderRadius,
              )
            : null),
          padding: widget.padding,
          margin: widget.margin,
          alignment: widget.alignment,
          child: widget.child,
        );
      },
    );
  }
}

/// Parallax scroll effect widget
class ParallaxContainer extends StatelessWidget {
  final Widget child;
  final double offset;
  final double depth;
  
  const ParallaxContainer({
    super.key,
    required this.child,
    this.offset = 0.0,
    this.depth = 0.02,
  });
  
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, offset * depth * 100),
      child: child,
    );
  }
}

/// Staggered list animation
class StaggeredListAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration itemDelay;
  final Curve curve;
  final Axis direction;
  
  const StaggeredListAnimation({
    super.key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 50),
    this.curve = ExpressiveMotionSystem.emphasizedEasing,
    this.direction = Axis.vertical,
  });
  
  @override
  State<StaggeredListAnimation> createState() => _StaggeredListAnimationState();
}

class _StaggeredListAnimationState extends State<StaggeredListAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(
        milliseconds: widget.itemDelay.inMilliseconds * widget.children.length + 300,
      ),
      vsync: this,
    );
    
    _animations = List.generate(
      widget.children.length,
      (index) => ExpressiveMotionSystem.getStaggerAnimation(
        controller: _controller,
        index: index,
        totalItems: widget.children.length,
        curve: widget.curve,
      ),
    );
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.direction == Axis.vertical
      ? Column(
          children: List.generate(
            widget.children.length,
            (index) => AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return FadeTransition(
                  opacity: _animations[index],
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(_animations[index]),
                    child: widget.children[index],
                  ),
                );
              },
            ),
          ),
        )
      : Row(
          children: List.generate(
            widget.children.length,
            (index) => AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return FadeTransition(
                  opacity: _animations[index],
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.3, 0),
                      end: Offset.zero,
                    ).animate(_animations[index]),
                    child: widget.children[index],
                  ),
                );
              },
            ),
          ),
        );
  }
}