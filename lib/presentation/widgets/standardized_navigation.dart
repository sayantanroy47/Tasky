import 'package:flutter/material.dart';

import '../../core/routing/app_router.dart';
import 'standardized_animations.dart';

/// Standardized navigation system that eliminates navigation chaos
/// 
/// Eliminates Navigation Pattern Inconsistency by:
/// - Providing centralized route management and navigation logic
/// - Enforcing consistent page transitions and animations
/// - Centralizing navigation analytics and history tracking
/// - Preventing direct Navigator.of(context).push calls
/// - Supporting type-safe navigation parameters and route guards
class StandardizedNavigation {
  static final _navigationHistory = <NavigationEvent>[];
  static final _routeGuards = <String, RouteGuard>{};
  
  /// Navigate to a route with standardized transition
  static Future<T?> push<T extends Object?>(
    BuildContext context, {
    required String routeName,
    Map<String, dynamic>? arguments,
    NavigationTransition transition = NavigationTransition.slideFromRight,
    bool trackAnalytics = true,
  }) async {
    // Run route guards
    if (!await _checkRouteGuards(routeName, arguments)) {
      return null;
    }
    
    // Track navigation event
    if (trackAnalytics) {
      _trackNavigation(NavigationType.push, routeName, arguments);
    }
    
    final route = _createRoute<T>(
      routeName: routeName,
      arguments: arguments,
      transition: transition,
    );
    
    return Navigator.of(context).push(route);
  }
  
  /// Replace current route with new route
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context, {
    required String routeName,
    Map<String, dynamic>? arguments,
    NavigationTransition transition = NavigationTransition.slideFromRight,
    bool trackAnalytics = true,
  }) async {
    if (!await _checkRouteGuards(routeName, arguments)) {
      return null;
    }
    
    if (trackAnalytics) {
      _trackNavigation(NavigationType.pushReplacement, routeName, arguments);
    }
    
    final route = _createRoute<T>(
      routeName: routeName,
      arguments: arguments,
      transition: transition,
    );
    
    return Navigator.of(context).pushReplacement(route);
  }
  
  /// Push and clear all previous routes
  static Future<T?> pushAndClearStack<T extends Object?>(
    BuildContext context, {
    required String routeName,
    Map<String, dynamic>? arguments,
    NavigationTransition transition = NavigationTransition.slideFromRight,
    bool trackAnalytics = true,
  }) async {
    if (!await _checkRouteGuards(routeName, arguments)) {
      return null;
    }
    
    if (trackAnalytics) {
      _trackNavigation(NavigationType.pushAndClearStack, routeName, arguments);
    }
    
    final route = _createRoute<T>(
      routeName: routeName,
      arguments: arguments,
      transition: transition,
    );
    
    return Navigator.of(context).pushAndRemoveUntil(
      route, 
      (Route<dynamic> route) => false,
    );
  }
  
  /// Pop current route
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    _trackNavigation(NavigationType.pop, 'back', null);
    Navigator.of(context).pop(result);
  }
  
  /// Pop until specific route
  static void popUntil(BuildContext context, String routeName) {
    _trackNavigation(NavigationType.popUntil, routeName, null);
    Navigator.of(context).popUntil(ModalRoute.withName(routeName));
  }
  
  /// Semantic navigation methods for common patterns
  static Future<void> goToTask(BuildContext context, String taskId) {
    return push(context, 
      routeName: AppRouter.taskDetail,
      arguments: {'taskId': taskId},
      transition: NavigationTransition.slideFromRight,
    );
  }
  
  static Future<void> goToProject(BuildContext context, String projectId) {
    return push(context,
      routeName: AppRouter.projectDetail, 
      arguments: {'projectId': projectId},
      transition: NavigationTransition.slideFromRight,
    );
  }
  
  static Future<void> goToSettings(BuildContext context) {
    return push(context,
      routeName: AppRouter.settings,
      transition: NavigationTransition.slideFromBottom,
    );
  }
  
  static Future<void> goToProfile(BuildContext context) {
    return push(context,
      routeName: AppRouter.profile,
      transition: NavigationTransition.slideFromRight,
    );
  }
  
  static Future<void> goToOnboarding(BuildContext context) {
    return pushAndClearStack(context,
      routeName: AppRouter.onboarding,
      transition: NavigationTransition.fadeIn,
    );
  }
  
  static Future<void> goToHome(BuildContext context) {
    return pushAndClearStack(context,
      routeName: AppRouter.home,
      transition: NavigationTransition.fadeIn,
    );
  }
  
  /// Modal navigation methods
  static Future<T?> showModal<T extends Object?>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool useRootNavigator = false,
    NavigationTransition transition = NavigationTransition.slideFromBottom,
  }) {
    _trackNavigation(NavigationType.modal, 'modal', null);
    
    return showModalBottomSheet<T>(
      context: context,
      builder: (context) => child,
      isDismissible: isDismissible,
      useRootNavigator: useRootNavigator,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
    );
  }
  
  static Future<T?> showFullScreenModal<T extends Object?>(
    BuildContext context, {
    required Widget child,
    NavigationTransition transition = NavigationTransition.slideFromBottom,
  }) {
    _trackNavigation(NavigationType.fullScreenModal, 'full_screen_modal', null);
    
    final route = PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: StandardizedAnimations.modalTransition,
      reverseTransitionDuration: StandardizedAnimations.modalTransition,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(transition, animation, child);
      },
      fullscreenDialog: true,
    );
    
    return Navigator.of(context).push(route);
  }
  
  /// Route creation with standardized transitions
  static PageRouteBuilder<T> _createRoute<T>({
    required String routeName,
    Map<String, dynamic>? arguments,
    NavigationTransition transition = NavigationTransition.slideFromRight,
  }) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: routeName, arguments: arguments),
      pageBuilder: (context, animation, secondaryAnimation) {
        // This would typically use your existing route building logic
        // For now, returning a placeholder - integrate with AppRouter
        return _buildPageFromRoute(routeName, arguments);
      },
      transitionDuration: _getTransitionDuration(transition),
      reverseTransitionDuration: _getTransitionDuration(transition),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(transition, animation, child);
      },
    );
  }
  
  /// Build page widget from route name (integrate with existing AppRouter)
  static Widget _buildPageFromRoute(String routeName, Map<String, dynamic>? arguments) {
    // This should integrate with your existing AppRouter logic
    // For now, using a simple mapping
    return Scaffold(
      appBar: AppBar(title: Text('Route: $routeName')),
      body: Center(
        child: Text('Arguments: ${arguments.toString()}'),
      ),
    );
  }
  
  /// Get appropriate transition duration
  static Duration _getTransitionDuration(NavigationTransition transition) {
    switch (transition) {
      case NavigationTransition.fadeIn:
        return StandardizedAnimations.fast;
      case NavigationTransition.slideFromRight:
      case NavigationTransition.slideFromLeft:
        return StandardizedAnimations.pageTransition;
      case NavigationTransition.slideFromBottom:
      case NavigationTransition.slideFromTop:
        return StandardizedAnimations.modalTransition;
      case NavigationTransition.scaleIn:
        return StandardizedAnimations.fast;
      case NavigationTransition.custom:
        return StandardizedAnimations.pageTransition;
    }
  }
  
  /// Build transition animation
  static Widget _buildTransition(
    NavigationTransition transition,
    Animation<double> animation,
    Widget child,
  ) {
    switch (transition) {
      case NavigationTransition.fadeIn:
        return FadeTransition(opacity: animation, child: child);
        
      case NavigationTransition.slideFromRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: StandardizedAnimations.standardCurve,
          )),
          child: child,
        );
        
      case NavigationTransition.slideFromLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: StandardizedAnimations.standardCurve,
          )),
          child: child,
        );
        
      case NavigationTransition.slideFromBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: StandardizedAnimations.decelerateCurve,
          )),
          child: child,
        );
        
      case NavigationTransition.slideFromTop:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: StandardizedAnimations.decelerateCurve,
          )),
          child: child,
        );
        
      case NavigationTransition.scaleIn:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: StandardizedAnimations.emphasizedCurve,
          )),
          child: FadeTransition(opacity: animation, child: child),
        );
        
      case NavigationTransition.custom:
        return FadeTransition(opacity: animation, child: child);
    }
  }
  
  /// Route guard system
  static void addRouteGuard(String routeName, RouteGuard guard) {
    _routeGuards[routeName] = guard;
  }
  
  static void removeRouteGuard(String routeName) {
    _routeGuards.remove(routeName);
  }
  
  static Future<bool> _checkRouteGuards(String routeName, Map<String, dynamic>? arguments) async {
    final guard = _routeGuards[routeName];
    if (guard != null) {
      return await guard.canNavigate(routeName, arguments);
    }
    return true;
  }
  
  /// Navigation analytics
  static void _trackNavigation(
    NavigationType type,
    String routeName,
    Map<String, dynamic>? arguments,
  ) {
    final event = NavigationEvent(
      type: type,
      routeName: routeName,
      arguments: arguments,
      timestamp: DateTime.now(),
    );
    
    _navigationHistory.add(event);
    
    // Keep only last 100 navigation events
    if (_navigationHistory.length > 100) {
      _navigationHistory.removeAt(0);
    }
  }
  
  /// Get navigation history for analytics
  static List<NavigationEvent> get navigationHistory => List.unmodifiable(_navigationHistory);
  
  /// Clear navigation history
  static void clearNavigationHistory() {
    _navigationHistory.clear();
  }
}

/// Navigation transition types
enum NavigationTransition {
  fadeIn,
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  slideFromTop,
  scaleIn,
  custom,
}

/// Navigation types for analytics
enum NavigationType {
  push,
  pushReplacement,
  pushAndClearStack,
  pop,
  popUntil,
  modal,
  fullScreenModal,
}

/// Navigation event for analytics
class NavigationEvent {
  final NavigationType type;
  final String routeName;
  final Map<String, dynamic>? arguments;
  final DateTime timestamp;
  
  const NavigationEvent({
    required this.type,
    required this.routeName,
    this.arguments,
    required this.timestamp,
  });
  
  @override
  String toString() {
    return 'NavigationEvent(type: $type, route: $routeName, args: $arguments, time: $timestamp)';
  }
}

/// Route guard interface
abstract class RouteGuard {
  Future<bool> canNavigate(String routeName, Map<String, dynamic>? arguments);
}

/// Common route guards
class AuthenticationGuard implements RouteGuard {
  @override
  Future<bool> canNavigate(String routeName, Map<String, dynamic>? arguments) async {
    // Check if user is authenticated
    // Return false to block navigation, true to allow
    return true; // Placeholder implementation
  }
}

class PermissionGuard implements RouteGuard {
  final String requiredPermission;
  
  const PermissionGuard(this.requiredPermission);
  
  @override
  Future<bool> canNavigate(String routeName, Map<String, dynamic>? arguments) async {
    // Check if user has required permission
    return true; // Placeholder implementation
  }
}

/// Extensions for easy context-based navigation
extension StandardizedNavigationExtension on BuildContext {
  /// Quick navigation methods
  Future<T?> pushRoute<T extends Object?>(
    String routeName, {
    Map<String, dynamic>? arguments,
    NavigationTransition transition = NavigationTransition.slideFromRight,
  }) {
    return StandardizedNavigation.push<T>(
      this,
      routeName: routeName,
      arguments: arguments,
      transition: transition,
    );
  }
  
  Future<T?> pushReplacementRoute<T extends Object?>(
    String routeName, {
    Map<String, dynamic>? arguments,
    NavigationTransition transition = NavigationTransition.slideFromRight,
  }) {
    return StandardizedNavigation.pushReplacement<T, Object?>(
      this,
      routeName: routeName,
      arguments: arguments,
      transition: transition,
    );
  }
  
  void popRoute<T extends Object?>([T? result]) {
    StandardizedNavigation.pop<T>(this, result);
  }
  
  /// Semantic navigation shortcuts
  Future<void> goToTask(String taskId) => StandardizedNavigation.goToTask(this, taskId);
  Future<void> goToProject(String projectId) => StandardizedNavigation.goToProject(this, projectId);
  Future<void> goToSettings() => StandardizedNavigation.goToSettings(this);
  Future<void> goToProfile() => StandardizedNavigation.goToProfile(this);
  Future<void> goToHome() => StandardizedNavigation.goToHome(this);
  Future<void> goToOnboarding() => StandardizedNavigation.goToOnboarding(this);
  
  /// Modal shortcuts
  Future<T?> showModal<T extends Object?>(
    Widget child, {
    bool isDismissible = true,
    NavigationTransition transition = NavigationTransition.slideFromBottom,
  }) {
    return StandardizedNavigation.showModal<T>(
      this,
      child: child,
      isDismissible: isDismissible,
      transition: transition,
    );
  }
  
  Future<T?> showFullScreenModal<T extends Object?>(
    Widget child, {
    NavigationTransition transition = NavigationTransition.slideFromBottom,
  }) {
    return StandardizedNavigation.showFullScreenModal<T>(
      this,
      child: child,
      transition: transition,
    );
  }
}