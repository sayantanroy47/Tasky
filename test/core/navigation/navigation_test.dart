import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_tracker_app/core/providers/navigation_provider.dart';

void main() {
  group('AppNavigationDestination Tests', () {
    test('should have correct predefined destinations', () {
      expect(AppNavigationDestination.values.length, 4);
      expect(AppNavigationDestination.values[0].label, 'Home');
      expect(AppNavigationDestination.values[0].route, '/');
      expect(AppNavigationDestination.values[1].label, 'Calendar');
      expect(AppNavigationDestination.values[1].route, '/calendar');
      expect(AppNavigationDestination.values[2].label, 'Analytics');
      expect(AppNavigationDestination.values[2].route, '/analytics');
      expect(AppNavigationDestination.values[3].label, 'Settings');
      expect(AppNavigationDestination.values[3].route, '/settings');
    });

    test('should return correct destination by index', () {
      expect(AppNavigationDestination.fromIndex(0), AppNavigationDestination.home);
      expect(AppNavigationDestination.fromIndex(1), AppNavigationDestination.calendar);
      expect(AppNavigationDestination.fromIndex(2), AppNavigationDestination.analytics);
      expect(AppNavigationDestination.fromIndex(3), AppNavigationDestination.settings);
    });

    test('should return home for invalid index', () {
      expect(AppNavigationDestination.fromIndex(-1), AppNavigationDestination.home);
      expect(AppNavigationDestination.fromIndex(999), AppNavigationDestination.home);
    });

    test('should return correct destination by route', () {
      expect(AppNavigationDestination.fromRoute('/'), AppNavigationDestination.home);
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
      expect(AppNavigationDestination.calendar.index, 1);
      expect(AppNavigationDestination.analytics.index, 2);
      expect(AppNavigationDestination.settings.index, 3);
    });

    test('should have correct values list', () {
      expect(AppNavigationDestination.values.length, 4);
      expect(AppNavigationDestination.values[0], AppNavigationDestination.home);
      expect(AppNavigationDestination.values[1], AppNavigationDestination.calendar);
      expect(AppNavigationDestination.values[2], AppNavigationDestination.analytics);
      expect(AppNavigationDestination.values[3], AppNavigationDestination.settings);
    });
  });

  group('NavigationState Tests', () {
    test('should create default navigation state', () {
      final state = NavigationState();
      
      expect(state.currentDestination, AppNavigationDestination.home);
      expect(state.selectedIndex, 0);
      expect(state.canPop, false);
    });

    test('should create navigation state with custom values', () {
      final state = NavigationState(
        currentDestination: AppNavigationDestination.calendar,
        selectedIndex: 1,
        canPop: true,
      );
      
      expect(state.currentDestination, AppNavigationDestination.calendar);
      expect(state.selectedIndex, 1);
      expect(state.canPop, true);
    });

    test('should copy with new values', () {
      final originalState = NavigationState();
      final newState = originalState.copyWith(
        currentDestination: AppNavigationDestination.analytics,
        selectedIndex: 2,
        canPop: true,
      );
      
      expect(newState.currentDestination, AppNavigationDestination.analytics);
      expect(newState.selectedIndex, 2);
      expect(newState.canPop, true);
      
      // Original should remain unchanged
      expect(originalState.currentDestination, AppNavigationDestination.home);
      expect(originalState.selectedIndex, 0);
      expect(originalState.canPop, false);
    });

    test('should have correct equality', () {
      final state1 = NavigationState(
        currentDestination: AppNavigationDestination.calendar,
        selectedIndex: 1,
        canPop: true,
      );
      
      final state2 = NavigationState(
        currentDestination: AppNavigationDestination.calendar,
        selectedIndex: 1,
        canPop: true,
      );
      
      final state3 = NavigationState(
        currentDestination: AppNavigationDestination.home,
        selectedIndex: 0,
        canPop: false,
      );
      
      expect(state1, state2);
      expect(state1, isNot(state3));
    });
  });

  group('Navigation Provider Tests', () {
    test('selectedIndexProvider should clamp invalid indices', () {
      final container = ProviderContainer();
      
      // Set navigation state with invalid index
      container.read(navigationProvider.notifier).state = NavigationState(
        currentDestination: AppNavigationDestination.home,
        selectedIndex: 5, // Invalid index - out of bounds
        canPop: false,
      );
      
      // selectedIndexProvider should clamp it to valid range
      final selectedIndex = container.read(selectedIndexProvider);
      expect(selectedIndex, 3); // Should be clamped to max valid index (3)
      
      container.dispose();
    });

    test('selectedIndexProvider should handle negative indices', () {
      final container = ProviderContainer();
      
      // Set navigation state with negative index
      container.read(navigationProvider.notifier).state = NavigationState(
        currentDestination: AppNavigationDestination.home,
        selectedIndex: -1, // Invalid negative index
        canPop: false,
      );
      
      // selectedIndexProvider should clamp it to valid range
      final selectedIndex = container.read(selectedIndexProvider);
      expect(selectedIndex, 0); // Should be clamped to min valid index (0)
      
      container.dispose();
    });
  });
}
