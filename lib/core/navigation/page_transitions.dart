import 'package:flutter/material.dart';
import '../../core/accessibility/accessibility_constants.dart';
import '../../core/theme/material3/motion_system.dart';

/// Standardized page transitions with glassmorphism and accessibility support
class StandardPageTransitions {
  /// Slide transition (default for navigation)
  static PageRouteBuilder<T> slideTransition<T extends Object?>({
    required Widget child,
    required RouteSettings settings,
    SlideDirection direction = SlideDirection.right,
    Duration duration = ExpressiveMotionSystem.durationMedium3,
    bool maintainState = true,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      maintainState: maintainState,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildSlideTransition(
          context: context,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
          direction: direction,
        );
      },
    );
  }

  /// Fade transition (for modals and overlays)
  static PageRouteBuilder<T> fadeTransition<T extends Object?>({
    required Widget child,
    required RouteSettings settings,
    Duration duration = ExpressiveMotionSystem.durationMedium2,
    bool maintainState = true,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      maintainState: maintainState,
      opaque: false, // Allow transparency for glassmorphism
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildFadeTransition(
          context: context,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }

  /// Scale transition (for dialogs and important actions)
  static PageRouteBuilder<T> scaleTransition<T extends Object?>({
    required Widget child,
    required RouteSettings settings,
    Duration duration = ExpressiveMotionSystem.durationMedium2,
    bool maintainState = true,
    Alignment alignment = Alignment.center,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      maintainState: maintainState,
      opaque: false, // Allow transparency for glassmorphism
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildScaleTransition(
          context: context,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
          alignment: alignment,
        );
      },
    );
  }

  /// Glassmorphism transition (for special glassmorphism pages)
  static PageRouteBuilder<T> glassTransition<T extends Object?>({
    required Widget child,
    required RouteSettings settings,
    Duration duration = ExpressiveMotionSystem.durationLong1,
    bool maintainState = true,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      maintainState: maintainState,
      opaque: false, // Essential for glassmorphism effect
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildGlassTransition(
          context: context,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }

  /// No transition (for accessibility or performance)
  static PageRouteBuilder<T> noTransition<T extends Object?>({
    required Widget child,
    required RouteSettings settings,
    bool maintainState = true,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      maintainState: maintainState,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
    );
  }

  /// Build slide transition with accessibility awareness
  static Widget _buildSlideTransition({
    required BuildContext context,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
    required SlideDirection direction,
  }) {
    final shouldReduceMotion = AccessibilityUtils.shouldReduceMotion(context);
    
    if (shouldReduceMotion) {
      return FadeTransition(opacity: animation, child: child);
    }

    final offset = _getSlideOffset(direction);
    
    // Primary page slide animation
    final slideAnimation = Tween<Offset>(
      begin: offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: ExpressiveMotionSystem.emphasizedEasing,
    ));

    // Secondary page slide animation (exits in opposite direction)
    final secondarySlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: _getOppositeSlideOffset(direction),
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: ExpressiveMotionSystem.emphasizedDecelerate,
    ));

    return Stack(
      children: [
        SlideTransition(
          position: secondarySlideAnimation,
          child: Container(), // Represents the previous page
        ),
        SlideTransition(
          position: slideAnimation,
          child: child,
        ),
      ],
    );
  }

  /// Build fade transition with glassmorphism support
  static Widget _buildFadeTransition({
    required BuildContext context,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    final shouldReduceMotion = AccessibilityUtils.shouldReduceMotion(context);
    
    // Scale down animation for accessibility or immediate display
    final scaleAnimation = shouldReduceMotion
        ? Tween<double>(begin: 1.0, end: 1.0).animate(animation)
        : Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(
            parent: animation,
            curve: ExpressiveMotionSystem.standard,
          ));

    return FadeTransition(
      opacity: animation,
      child: Transform.scale(
        scale: scaleAnimation.value,
        child: child,
      ),
    );
  }

  /// Build scale transition with accessibility awareness
  static Widget _buildScaleTransition({
    required BuildContext context,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
    required Alignment alignment,
  }) {
    final shouldReduceMotion = AccessibilityUtils.shouldReduceMotion(context);
    
    if (shouldReduceMotion) {
      return FadeTransition(opacity: animation, child: child);
    }

    final scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: ExpressiveMotionSystem.emphasizedEasing,
    ));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeIn,
    ));

    return FadeTransition(
      opacity: fadeAnimation,
      child: Transform.scale(
        scale: scaleAnimation.value,
        alignment: alignment,
        child: child,
      ),
    );
  }

  /// Build glassmorphism transition with blur and opacity effects
  static Widget _buildGlassTransition({
    required BuildContext context,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    final shouldReduceMotion = AccessibilityUtils.shouldReduceMotion(context);
    
    if (shouldReduceMotion) {
      return FadeTransition(opacity: animation, child: child);
    }

    // Scale animation
    final scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: ExpressiveMotionSystem.emphasizedEasing,
    ));

    // Opacity animation
    final opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));

    return FadeTransition(
      opacity: opacityAnimation,
      child: Transform.scale(
        scale: scaleAnimation.value,
        child: child,
      ),
    );
  }

  /// Get slide offset for direction
  static Offset _getSlideOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.left:
        return const Offset(-1.0, 0.0);
      case SlideDirection.right:
        return const Offset(1.0, 0.0);
      case SlideDirection.up:
        return const Offset(0.0, -1.0);
      case SlideDirection.down:
        return const Offset(0.0, 1.0);
    }
  }

  /// Get opposite slide offset for secondary animation
  static Offset _getOppositeSlideOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.left:
        return const Offset(0.3, 0.0);
      case SlideDirection.right:
        return const Offset(-0.3, 0.0);
      case SlideDirection.up:
        return const Offset(0.0, 0.3);
      case SlideDirection.down:
        return const Offset(0.0, -0.3);
    }
  }
}

/// Slide direction enumeration
enum SlideDirection {
  left,
  right,
  up,
  down,
}

/// Custom route for accessibility-aware navigation
class AccessibleRoute<T extends Object?> extends MaterialPageRoute<T> {
  final String accessibilityLabel;
  final TransitionType transitionType;

  AccessibleRoute({
    required super.builder,
    required this.accessibilityLabel,
    this.transitionType = TransitionType.slide,
    super.settings,
    super.maintainState = true,
    super.fullscreenDialog = false,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Announce navigation for screen readers
    if (animation.status == AnimationStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AccessibilityUtils.announceToScreenReader(
          context,
          'Navigated to $accessibilityLabel',
        );
      });
    }

    // Choose transition based on type and accessibility settings
    switch (transitionType) {
      case TransitionType.slide:
        return StandardPageTransitions._buildSlideTransition(
          context: context,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
          direction: SlideDirection.right,
        );
      case TransitionType.fade:
        return StandardPageTransitions._buildFadeTransition(
          context: context,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      case TransitionType.scale:
        return StandardPageTransitions._buildScaleTransition(
          context: context,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
          alignment: Alignment.center,
        );
      case TransitionType.glass:
        return StandardPageTransitions._buildGlassTransition(
          context: context,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      case TransitionType.none:
        return child;
    }
  }

  @override
  Duration get transitionDuration {
    return ExpressiveMotionSystem.durationMedium3;
  }

  @override
  Duration get reverseTransitionDuration {
    return ExpressiveMotionSystem.durationMedium2;
  }
}

/// Transition type enumeration
enum TransitionType {
  slide,
  fade,
  scale,
  glass,
  none,
}

/// Navigation utilities for consistent routing
class NavigationUtils {
  /// Navigate with appropriate transition
  static Future<T?> navigateTo<T extends Object?>(
    BuildContext context,
    Widget destination, {
    String? accessibilityLabel,
    TransitionType transitionType = TransitionType.slide,
    bool replacement = false,
    bool clearStack = false,
  }) {
    final route = AccessibleRoute<T>(
      builder: (_) => destination,
      accessibilityLabel: accessibilityLabel ?? 'New screen',
      transitionType: transitionType,
    );

    if (clearStack) {
      return Navigator.of(context).pushAndRemoveUntil(
        route,
        (route) => false,
      );
    } else if (replacement) {
      return Navigator.of(context).pushReplacement(route);
    } else {
      return Navigator.of(context).push(route);
    }
  }

  /// Navigate back with accessibility announcement
  static void navigateBack(
    BuildContext context, {
    dynamic result,
    String? accessibilityLabel,
  }) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(result);
      
      if (accessibilityLabel != null) {
        AccessibilityUtils.announceToScreenReader(
          context,
          'Navigated back to $accessibilityLabel',
        );
      }
    }
  }

  /// Show accessible modal
  static Future<T?> showAccessibleModal<T extends Object?>(
    BuildContext context,
    Widget modal, {
    String? accessibilityLabel,
    TransitionType transitionType = TransitionType.fade,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black54,
      barrierLabel: accessibilityLabel ?? 'Modal dialog',
      pageBuilder: (context, animation, secondaryAnimation) => modal,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        switch (transitionType) {
          case TransitionType.fade:
            return StandardPageTransitions._buildFadeTransition(
              context: context,
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          case TransitionType.scale:
            return StandardPageTransitions._buildScaleTransition(
              context: context,
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
              alignment: Alignment.center,
            );
          case TransitionType.glass:
            return StandardPageTransitions._buildGlassTransition(
              context: context,
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          default:
            return StandardPageTransitions._buildFadeTransition(
              context: context,
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
        }
      },
      transitionDuration: ExpressiveMotionSystem.durationMedium2,
    );
  }
}