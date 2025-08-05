import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/core/providers/navigation_provider.dart';

void main() {
  group('AppNavigationDestination Tests', () {
    test('should have correct predefined destinations', () {
      expect(AppNavigationDestination.values.length, 4);
      expect(AppNavigationDestination.values[0].label, 'Home');
      expect(AppNavigationDestination.values[0].route, '/');
      expect(AppNavigationDestination.values[1].label, 'Tasks');
      expect(AppNavigationDestination.values[1].route, '/tasks');
      expect(AppNavigationDestination.values[2].label, 'Settings');
      expect(AppNavigationDestination.values[2].route, '/settings');
      expect(AppNavigationDestination.values[3].label, 'Performance');
      expect(AppNavigationDestination.values[3].route, '/performance');
    });

    test('should return correct destination by index', () {
      expect(AppNavigationDestination.fromIndex(0), AppNavigationDestination.home);
      expect(AppNavigationDestination.fromIndex(1), AppNavigationDestination.tasks);
      expect(AppNavigationDestination.fromIndex(2), AppNavigationDestination.settings);
      expect(AppNavigationDestination.fromIndex(3), AppNavigationDestination.performance);
    });

    test('should return home for invalid index', () {
      expect(AppNavigationDestination.fromIndex(-1), AppNavigationDestination.home);
      expect(AppNavigationDestination.fromIndex(999), AppNavigationDestination.home);
    });

    test('should return correct destination by route', () {
      expect(AppNavigationDestination.fromRoute('/'), AppNavigationDestination.home);
      expect(AppNavigationDestination.fromRoute('/tasks'), AppNavigationDestination.tasks);
      expect(AppNavigationDestination.fromRoute('/settings'), AppNavigationDestination.settings);
      expect(AppNavigationDestination.fromRoute('/performance'), AppNavigationDestination.performance);
    });

    test('should return home for invalid route', () {
      expect(AppNavigationDestination.fromRoute('/invalid'), AppNavigationDestination.home);
      expect(AppNavigationDestination.fromRoute(''), AppNavigationDestination.home);
    });

    test('should have correct index property', () {
      expect(AppNavigationDestination.home.index, 0);
      expect(AppNavigationDestination.tasks.index, 1);
      expect(AppNavigationDestination.settings.index, 2);
      expect(AppNavigationDestination.performance.index, 3);
    });

    test('should have correct values list', () {
      expect(AppNavigationDestination.values.length, 4);
      expect(AppNavigationDestination.values[0], AppNavigationDestination.home);
      expect(AppNavigationDestination.values[1], AppNavigationDestination.tasks);
      expect(AppNavigationDestination.values[2], AppNavigationDestination.settings);
      expect(AppNavigationDestination.values[3], AppNavigationDestination.performance);
    });
  });

  group('NavigationState Tests', () {
    test('should create default navigation state', () {
      const state = NavigationState();
      
      expect(state.currentDestination, AppNavigationDestination.home);
      expect(state.selectedIndex, 0);
      expect(state.canPop, false);
    });

    test('should create navigation state with custom values', () {
      const state = NavigationState(
        currentDestination: AppNavigationDestination.tasks,
        selectedIndex: 1,
        canPop: true,
      );
      
      expect(state.currentDestination, AppNavigationDestination.tasks);
      expect(state.selectedIndex, 1);
      expect(state.canPop, true);
    });

    test('should copy with new values', () {
      const originalState = NavigationState();
      final newState = originalState.copyWith(
        currentDestination: AppNavigationDestination.settings,
        selectedIndex: 2,
        canPop: true,
      );
      
      expect(newState.currentDestination, AppNavigationDestination.settings);
      expect(newState.selectedIndex, 2);
      expect(newState.canPop, true);
      
      // Original should remain unchanged
      expect(originalState.currentDestination, AppNavigationDestination.home);
      expect(originalState.selectedIndex, 0);
      expect(originalState.canPop, false);
    });

    test('should have correct equality', () {
      const state1 = NavigationState(
        currentDestination: AppNavigationDestination.tasks,
        selectedIndex: 1,
        canPop: true,
      );
      
      const state2 = NavigationState(
        currentDestination: AppNavigationDestination.tasks,
        selectedIndex: 1,
        canPop: true,
      );
      
      const state3 = NavigationState(
        currentDestination: AppNavigationDestination.home,
        selectedIndex: 0,
        canPop: false,
      );
      
      expect(state1, state2);
      expect(state1, isNot(state3));
    });
  });
}