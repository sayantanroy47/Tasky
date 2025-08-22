import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../accessibility/accessibility_constants.dart';

/// Centralized navigation controller for consistent navigation patterns
class NavigationController extends ChangeNotifier {
  int _currentIndex = 0;
  final List<NavigationItem> _navigationItems = [];
  final List<String> _navigationHistory = [];
  String? _previousRoute;

  /// Current selected navigation index
  int get currentIndex => _currentIndex;

  /// List of navigation items
  List<NavigationItem> get navigationItems => List.unmodifiable(_navigationItems);

  /// Navigation history for back navigation
  List<String> get navigationHistory => List.unmodifiable(_navigationHistory);

  /// Previous route for smart back navigation
  String? get previousRoute => _previousRoute;

  /// Initialize navigation with items
  void initialize(List<NavigationItem> items) {
    _navigationItems.clear();
    _navigationItems.addAll(items);
    notifyListeners();
  }

  /// Navigate to specific index with validation
  bool navigateToIndex(int index, {BuildContext? context}) {
    if (index < 0 || index >= _navigationItems.length) {
      return false;
    }

    if (index == _currentIndex) {
      // Same index - trigger refresh or scroll to top
      _handleSameIndexTap(index, context);
      return true;
    }

    final previousIndex = _currentIndex;
    _currentIndex = index;

    // Add to history
    _addToHistory(_navigationItems[previousIndex].route);
    
    // Announce navigation for accessibility
    if (context != null) {
      AccessibilityUtils.announceToScreenReader(
        context,
        'Navigated to ${_navigationItems[index].label}',
      );
    }

    notifyListeners();
    return true;
  }

  /// Navigate to specific route
  bool navigateToRoute(String route, {BuildContext? context}) {
    final index = _navigationItems.indexWhere((item) => item.route == route);
    if (index != -1) {
      return navigateToIndex(index, context: context);
    }
    return false;
  }

  /// Navigate back using navigation history
  bool navigateBack({BuildContext? context}) {
    if (_navigationHistory.isEmpty) {
      return false;
    }

    final previousRoute = _navigationHistory.removeLast();
    final index = _navigationItems.indexWhere((item) => item.route == previousRoute);
    
    if (index != -1) {
      _currentIndex = index;
      
      // Announce back navigation for accessibility
      if (context != null) {
        AccessibilityUtils.announceToScreenReader(
          context,
          'Navigated back to ${_navigationItems[index].label}',
        );
      }

      notifyListeners();
      return true;
    }
    
    return false;
  }

  /// Check if can navigate back
  bool get canNavigateBack => _navigationHistory.isNotEmpty;

  /// Handle same index tap (refresh or scroll to top)
  void _handleSameIndexTap(int index, BuildContext? context) {
    final item = _navigationItems[index];
    item.onRefresh?.call();
    
    if (context != null) {
      AccessibilityUtils.announceToScreenReader(
        context,
        'Refreshing ${item.label}',
      );
    }
  }

  /// Add route to navigation history
  void _addToHistory(String route) {
    _navigationHistory.add(route);
    
    // Keep history size manageable
    if (_navigationHistory.length > 10) {
      _navigationHistory.removeAt(0);
    }
  }

  /// Get current navigation item
  NavigationItem? get currentItem {
    if (_currentIndex >= 0 && _currentIndex < _navigationItems.length) {
      return _navigationItems[_currentIndex];
    }
    return null;
  }

  /// Get badge count for specific index
  int getBadgeCount(int index) {
    if (index >= 0 && index < _navigationItems.length) {
      return _navigationItems[index].badgeCount;
    }
    return 0;
  }

  /// Update badge count for specific index
  void updateBadgeCount(int index, int count) {
    if (index >= 0 && index < _navigationItems.length) {
      _navigationItems[index] = _navigationItems[index].copyWith(badgeCount: count);
      notifyListeners();
    }
  }

  /// Update badge count by route
  void updateBadgeCountByRoute(String route, int count) {
    final index = _navigationItems.indexWhere((item) => item.route == route);
    if (index != -1) {
      updateBadgeCount(index, count);
    }
  }

  /// Clear navigation history
  void clearHistory() {
    _navigationHistory.clear();
    notifyListeners();
  }

  /// Reset to initial state
  void reset() {
    _currentIndex = 0;
    _navigationHistory.clear();
    _previousRoute = null;
    notifyListeners();
  }
}

/// Navigation item configuration
class NavigationItem {
  final String route;
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final String? semanticLabel;
  final String? semanticHint;
  final int badgeCount;
  final bool enabled;
  final VoidCallback? onRefresh;
  final Color? color;

  const NavigationItem({
    required this.route,
    required this.label,
    required this.icon,
    this.activeIcon,
    this.semanticLabel,
    this.semanticHint,
    this.badgeCount = 0,
    this.enabled = true,
    this.onRefresh,
    this.color,
  });

  NavigationItem copyWith({
    String? route,
    String? label,
    IconData? icon,
    IconData? activeIcon,
    String? semanticLabel,
    String? semanticHint,
    int? badgeCount,
    bool? enabled,
    VoidCallback? onRefresh,
    Color? color,
  }) {
    return NavigationItem(
      route: route ?? this.route,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      activeIcon: activeIcon ?? this.activeIcon,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      semanticHint: semanticHint ?? this.semanticHint,
      badgeCount: badgeCount ?? this.badgeCount,
      enabled: enabled ?? this.enabled,
      onRefresh: onRefresh ?? this.onRefresh,
      color: color ?? this.color,
    );
  }

  /// Get effective icon based on selection state
  IconData getEffectiveIcon(bool isSelected) {
    return (isSelected && activeIcon != null) ? activeIcon! : icon;
  }

  /// Get semantic label for accessibility
  String getSemanticLabel() {
    return semanticLabel ?? '$label navigation';
  }

  /// Get semantic hint for accessibility
  String getSemanticHint() {
    return semanticHint ?? 'Navigate to $label screen';
  }
}

/// Provider for navigation controller
final navigationControllerProvider = ChangeNotifierProvider<NavigationController>((ref) {
  return NavigationController();
});

/// Provider for current navigation index
final currentNavigationIndexProvider = Provider<int>((ref) {
  return ref.watch(navigationControllerProvider).currentIndex;
});

/// Provider for navigation items
final navigationItemsProvider = Provider<List<NavigationItem>>((ref) {
  return ref.watch(navigationControllerProvider).navigationItems;
});

/// Provider for navigation history
final navigationHistoryProvider = Provider<List<String>>((ref) {
  return ref.watch(navigationControllerProvider).navigationHistory;
});

/// Provider for back navigation availability
final canNavigateBackProvider = Provider<bool>((ref) {
  return ref.watch(navigationControllerProvider).canNavigateBack;
});

/// Navigation configuration for the app
class AppNavigationConfig {
  static List<NavigationItem> get items => [
    const NavigationItem(
      route: '/home',
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      semanticLabel: 'Home screen',
      semanticHint: 'View your tasks and quick overview',
    ),
    const NavigationItem(
      route: '/calendar',
      label: 'Calendar',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      semanticLabel: 'Calendar screen',
      semanticHint: 'View tasks in calendar format',
    ),
    const NavigationItem(
      route: '/analytics',
      label: 'Analytics',
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      semanticLabel: 'Analytics screen',
      semanticHint: 'View productivity insights and statistics',
    ),
    const NavigationItem(
      route: '/settings',
      label: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      semanticLabel: 'Settings screen',
      semanticHint: 'Configure app preferences and account',
    ),
  ];

  static void initialize(WidgetRef ref) {
    final controller = ref.read(navigationControllerProvider);
    controller.initialize(items);
  }
}