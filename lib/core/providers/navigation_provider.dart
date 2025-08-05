import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Navigation destination class
class AppNavigationDestination {
  final String label;
  final IconData icon;
  final String route;

  const AppNavigationDestination({
    required this.label,
    required this.icon,
    required this.route,
  });

  /// All available destinations - aligned with AppRouter and bottom navigation
  static const List<AppNavigationDestination> values = [
    AppNavigationDestination(
      label: 'Home',
      icon: Icons.home,
      route: '/',
    ),
    AppNavigationDestination(
      label: 'Tasks',
      icon: Icons.task_alt,
      route: '/tasks',
    ),
    AppNavigationDestination(
      label: 'Settings',
      icon: Icons.settings,
      route: '/settings',
    ),
    AppNavigationDestination(
      label: 'Performance',
      icon: Icons.speed,
      route: '/performance',
    ),
  ];

  /// Predefined destinations - aligned with AppRouter
  static const AppNavigationDestination home = AppNavigationDestination(
    label: 'Home',
    icon: Icons.home,
    route: '/',
  );

  static const AppNavigationDestination tasks = AppNavigationDestination(
    label: 'Tasks',
    icon: Icons.task_alt,
    route: '/tasks',
  );

  static const AppNavigationDestination settings = AppNavigationDestination(
    label: 'Settings',
    icon: Icons.settings,
    route: '/settings',
  );

  static const AppNavigationDestination performance = AppNavigationDestination(
    label: 'Performance',
    icon: Icons.speed,
    route: '/performance',
  );

  /// Get index of this destination
  int get index => values.indexOf(this);

  /// Get destination by index
  static AppNavigationDestination fromIndex(int index) {
    if (index < 0 || index >= values.length) {
      return home;
    }
    return values[index];
  }

  /// Get destination by route
  static AppNavigationDestination fromRoute(String route) {
    return values.firstWhere(
      (destination) => destination.route == route,
      orElse: () => home,
    );
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNavigationDestination &&
        other.label == label &&
        other.icon == icon &&
        other.route == route;
  }
  @override
  int get hashCode => Object.hash(label, icon, route);
  @override
  String toString() => 'AppNavigationDestination(label: $label, route: $route)';
}

/// Navigation state class
class NavigationState {
  final AppNavigationDestination currentDestination;
  final int selectedIndex;
  final bool canPop;

  const NavigationState({
    this.currentDestination = AppNavigationDestination.home,
    this.selectedIndex = 0,
    this.canPop = false,
  });

  NavigationState copyWith({
    AppNavigationDestination? currentDestination,
    int? selectedIndex,
    bool? canPop,
  }) {
    return NavigationState(
      currentDestination: currentDestination ?? this.currentDestination,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      canPop: canPop ?? this.canPop,
    );
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationState &&
        other.currentDestination == currentDestination &&
        other.selectedIndex == selectedIndex &&
        other.canPop == canPop;
  }
  @override
  int get hashCode => Object.hash(currentDestination, selectedIndex, canPop);
}

/// Navigation notifier for managing navigation state
class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState());

  /// Navigate to a destination by index
  void navigateToIndex(int index) {
    final destination = AppNavigationDestination.fromIndex(index);
    state = state.copyWith(
      currentDestination: destination,
      selectedIndex: index,
    );
  }

  /// Navigate to a destination
  void navigateToDestination(AppNavigationDestination destination) {
    state = state.copyWith(
      currentDestination: destination,
      selectedIndex: destination.index,
    );
  }

  /// Navigate to a route
  void navigateToRoute(String route) {
    final destination = AppNavigationDestination.fromRoute(route);
    state = state.copyWith(
      currentDestination: destination,
      selectedIndex: destination.index,
    );
  }

  /// Set can pop state
  void setCanPop(bool canPop) {
    state = state.copyWith(canPop: canPop);
  }

  /// Reset to home
  void resetToHome() {
    state = const NavigationState(
      currentDestination: AppNavigationDestination.home,
      selectedIndex: 0,
      canPop: false,
    );
  }
}

/// Navigation provider
final navigationProvider = StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});

/// Current destination provider
final currentDestinationProvider = Provider<AppNavigationDestination>((ref) {
  final navigationState = ref.watch(navigationProvider);
  return navigationState.currentDestination;
});

/// Selected index provider
final selectedIndexProvider = Provider<int>((ref) {
  final navigationState = ref.watch(navigationProvider);
  return navigationState.selectedIndex;
});

/// Can pop provider
final canPopProvider = Provider<bool>((ref) {
  final navigationState = ref.watch(navigationProvider);
  return navigationState.canPop;
});
