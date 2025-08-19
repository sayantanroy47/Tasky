import 'package:flutter/material.dart';
import '../../core/design_system/design_tokens.dart';
import 'glassmorphism_container.dart';
import '../../core/theme/material3/motion_system.dart';

/// Beautiful glassmorphism-based page transition effects
class GlassPageTransitions {
  
  /// Glass slide transition with blur effect
  static PageRouteBuilder<T> glassSlideTransition<T>({
    required Widget page,
    required RouteSettings settings,
    SlideDirection direction = SlideDirection.leftToRight,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _GlassSlideTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          direction: direction,
          child: child,
        );
      },
    );
  }

  /// Glass fade transition with dynamic blur
  static PageRouteBuilder<T> glassFadeTransition<T>({
    required Widget page,
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _GlassFadeTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }

  /// Glass scale transition with depth effect
  static PageRouteBuilder<T> glassScaleTransition<T>({
    required Widget page,
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 350),
    Alignment alignment = Alignment.center,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _GlassScaleTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          alignment: alignment,
          child: child,
        );
      },
    );
  }

  /// Glass morph transition for modal dialogs
  static PageRouteBuilder<T> glassMorphTransition<T>({
    required Widget page,
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 400),
    Offset? startPosition,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      opaque: false,
      barrierColor: Colors.black54,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _GlassMorphTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          startPosition: startPosition,
          child: child,
        );
      },
    );
  }
}

/// Slide direction for glass slide transitions
enum SlideDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
}

/// Glass slide transition implementation
class _GlassSlideTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final SlideDirection direction;
  final Widget child;

  const _GlassSlideTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.direction,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final slideAnimation = Tween<Offset>(
      begin: _getBeginOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: ExpressiveMotionSystem.emphasizedEasing,
    ));

    final secondarySlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: _getSecondaryOffset(),
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: ExpressiveMotionSystem.emphasizedEasing,
    ));

    final blurAnimation = Tween<double>(
      begin: 10.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ));

    return Stack(
      children: [
        // Secondary page with blur effect
        if (secondaryAnimation.value > 0)
          SlideTransition(
            position: secondarySlideAnimation,
            child: _BlurredContainer(
              blur: secondaryAnimation.value * 8.0,
              opacity: 1.0 - secondaryAnimation.value * 0.5,
              child: child,
            ),
          ),
        
        // Primary page with glass container
        SlideTransition(
          position: slideAnimation,
          child: _BlurredContainer(
            blur: blurAnimation.value,
            opacity: animation.value,
            child: child,
          ),
        ),
      ],
    );
  }

  Offset _getBeginOffset() {
    switch (direction) {
      case SlideDirection.leftToRight:
        return const Offset(-1.0, 0.0);
      case SlideDirection.rightToLeft:
        return const Offset(1.0, 0.0);
      case SlideDirection.topToBottom:
        return const Offset(0.0, -1.0);
      case SlideDirection.bottomToTop:
        return const Offset(0.0, 1.0);
    }
  }

  Offset _getSecondaryOffset() {
    switch (direction) {
      case SlideDirection.leftToRight:
        return const Offset(-0.3, 0.0);
      case SlideDirection.rightToLeft:
        return const Offset(0.3, 0.0);
      case SlideDirection.topToBottom:
        return const Offset(0.0, -0.3);
      case SlideDirection.bottomToTop:
        return const Offset(0.0, 0.3);
    }
  }
}

/// Glass fade transition implementation
class _GlassFadeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const _GlassFadeTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: ExpressiveMotionSystem.standard,
    );

    final blurAnimation = Tween<double>(
      begin: 15.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ));

    final scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: ExpressiveMotionSystem.emphasizedEasing,
    ));

    return Stack(
      children: [
        // Secondary page with fade out
        if (secondaryAnimation.value > 0)
          FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.8).animate(secondaryAnimation),
            child: child,
          ),
        
        // Primary page with glass effect
        FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: _BlurredContainer(
              blur: blurAnimation.value,
              opacity: 1.0,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

/// Glass scale transition implementation
class _GlassScaleTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Alignment alignment;
  final Widget child;

  const _GlassScaleTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.alignment,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: ExpressiveMotionSystem.emphasizedEasing,
    ));

    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: ExpressiveMotionSystem.standard,
    );

    final blurAnimation = Tween<double>(
      begin: 20.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ));

    return Stack(
      children: [
        // Secondary page with scale out
        if (secondaryAnimation.value > 0)
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.1).animate(secondaryAnimation),
            child: FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.7).animate(secondaryAnimation),
              child: child,
            ),
          ),
        
        // Primary page with glass effect
        FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            alignment: alignment,
            child: _BlurredContainer(
              blur: blurAnimation.value,
              opacity: 1.0,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

/// Glass morph transition for modals
class _GlassMorphTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Offset? startPosition;
  final Widget child;

  const _GlassMorphTransition({
    required this.animation,
    required this.secondaryAnimation,
    this.startPosition,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: ExpressiveMotionSystem.emphasizedEasing,
    ));

    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: ExpressiveMotionSystem.standard,
    );

    final blurAnimation = Tween<double>(
      begin: 25.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ));

    final morphAnimation = startPosition != null
        ? Tween<Offset>(
            begin: startPosition!,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: ExpressiveMotionSystem.emphasizedEasing,
          ))
        : null;

    Widget content = FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: _BlurredContainer(
          blur: blurAnimation.value,
          opacity: 1.0,
          child: child,
        ),
      ),
    );

    if (morphAnimation != null) {
      content = AnimatedBuilder(
        animation: morphAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: morphAnimation.value,
            child: content,
          );
        },
      );
    }

    return Container(
      color: Colors.black.withOpacity(0.3 * animation.value),
      child: Center(child: content),
    );
  }
}

/// Helper widget for blur effects during transitions
class _BlurredContainer extends StatelessWidget {
  final double blur;
  final double opacity;
  final Widget child;

  const _BlurredContainer({
    required this.blur,
    required this.opacity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (blur <= 0) {
      return Opacity(
        opacity: opacity,
        child: child,
      );
    }

    return GlassmorphismContainer(
      level: GlassLevel.content,
      blur: blur,
      opacity: 0.1,
      child: Opacity(
        opacity: opacity,
        child: child,
      ),
    );
  }
}

/// Enhanced navigation helper for glass transitions
class GlassNavigator {
  
  /// Navigate with glass slide effect
  static Future<T?> slideToPage<T extends Object?>(
    BuildContext context,
    Widget page, {
    SlideDirection direction = SlideDirection.leftToRight,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return Navigator.of(context).push<T>(
      GlassPageTransitions.glassSlideTransition<T>(
        page: page,
        settings: RouteSettings(name: page.runtimeType.toString()),
        direction: direction,
        duration: duration,
      ),
    );
  }

  /// Navigate with glass fade effect
  static Future<T?> fadeToPage<T extends Object?>(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(context).push<T>(
      GlassPageTransitions.glassFadeTransition<T>(
        page: page,
        settings: RouteSettings(name: page.runtimeType.toString()),
        duration: duration,
      ),
    );
  }

  /// Navigate with glass scale effect
  static Future<T?> scaleToPage<T extends Object?>(
    BuildContext context,
    Widget page, {
    Alignment alignment = Alignment.center,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return Navigator.of(context).push<T>(
      GlassPageTransitions.glassScaleTransition<T>(
        page: page,
        settings: RouteSettings(name: page.runtimeType.toString()),
        alignment: alignment,
        duration: duration,
      ),
    );
  }

  /// Show modal with glass morph effect
  static Future<T?> showGlassModal<T extends Object?>(
    BuildContext context,
    Widget page, {
    Offset? startPosition,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return Navigator.of(context).push<T>(
      GlassPageTransitions.glassMorphTransition<T>(
        page: page,
        settings: RouteSettings(name: page.runtimeType.toString()),
        startPosition: startPosition,
        duration: duration,
      ),
    );
  }

  /// Replace current page with glass transition
  static Future<T?> replaceWithGlass<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget page, {
    SlideDirection direction = SlideDirection.leftToRight,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return Navigator.of(context).pushReplacement<T, TO>(
      GlassPageTransitions.glassSlideTransition<T>(
        page: page,
        settings: RouteSettings(name: page.runtimeType.toString()),
        direction: direction,
        duration: duration,
      ),
    );
  }
}