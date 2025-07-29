import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/core/providers/navigation_provider.dart';

void main() {
  group('AppNavigationDestination Tests', () {
    test('should have correct predefined destinations', () {
      expect(AppNavigationDestination.home.label, 'Home');
      expect(AppNavigationDestination.home.route, '/home');
      expect(AppNavigationDestination.tasks.label, 'Tasks');
      expect(AppNavigationDestination.tasks.route, '/tasks');
      expect(AppNavigationDestination.calendar.label, 'Calendar');
      expect(AppNavigationDestination.calendar.route, '/calendar');
      expect(AppNavigationDestination.analytics.label, 'Analytics');
      expect(AppNavigationDestination.analytics.route, '/analytics');
      expect(AppNavigationDestination.settings.label, 'Settings');
      expect(AppNavigationDestination.settings.route, '/settings');
    });

    test('should return correct destination by index', () {
      expect(AppNavigationDestination.fromIndex(0), AppNavigationDestination.home);
      expect(AppNavigationDestination.fromIndex(1), AppNavigationDestination.tasks);
      expect(AppNavigationDestination.fromIndex(2), AppNavigationDestination.calendar);
      expect(AppNavigationDestination.fromIndex(3), AppNavigationDestination.analytics);
      expect(AppNavigationDestination.fromIndex(4), AppNavigationDestination.settings);
    });

    test('should return home for invalid index', () {
      expect(AppNavigationDestination.fromIndex(-1), AppNavigationDestination.home);
      expect(AppNavigationDestination.fromIndex(999), AppNavigationDestination.home);
    });

    test('should return correct destination by route', () {
      expect(AppNavigationDestination.fromRoute('/home'), AppNavigationDestination.home);
      expect(AppNavigationDestination.fromRoute('/tasks'), AppNavigationDestination.tasks);
      expect(AppNavigationDestination.fromRoute('/calendar'), AppNavigationDestination.calendar);
      expect(AppNavigationDestination.fromRoute('/analytics'), AppNavigationDestination.analytics);
      expect(AppNavigationDestination.fromRoute('/settings'), AppNavigationDestination.settings);
    });

    test('should return home for invalid route', () {
      expect(AppNavigationDestination.fromRoute('/invalid'), AppNavigationDestination.home);
      expect(AppNavigationDestination.fromRoute(''), AppNavigationDestination.home);
    });

    test('should have correct index property', () {
      expect(AppNavigationDestination.home.index, 0);
      expect(AppNavigationDestination.tasks.index, 1);
      expect(AppNavigationDestination.calendar.index, 2);
      expect(AppNavigationDestination.analytics.index, 3);
      expect(AppNavigationDestination.settings.index, 4);
    });

    test('should have correct values list', () {
      expect(AppNavigationDestination.values.length, 5);
      expect(AppNavigationDestination.values[0], AppNavigationDestination.home);
      expect(AppNavigationDestination.values[1], AppNavigationDestination.tasks);
      expect(AppNavigationDestination.values[2], AppNavigationDestination.calendar);
      expect(AppNavigationDestination.values[3], AppNavigationDestination.analytics);
      expect(AppNavigationDestination.values[4], AppNavigationDestination.settings);
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
        currentDestination: AppNavigationDestination.calendar,
        selectedIndex: 2,
        canPop: true,
      );
      
      expect(newState.currentDestination, AppNavigationDestination.calendar);
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