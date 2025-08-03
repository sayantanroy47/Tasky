import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/core/services/app_initialization_service.dart';

void main() {
  group('AppInitializationService', () {
    test('should have proper provider defined', () {
      // This is a basic test to ensure the provider is properly defined
      expect(appInitializationProvider, isNotNull);
    });

    test('should be a FutureProvider', () {
      // Test that the provider is of the correct type
      expect(appInitializationProvider.runtimeType.toString(), contains('FutureProvider'));
    });
  });
}