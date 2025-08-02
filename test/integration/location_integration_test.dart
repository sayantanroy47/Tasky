import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:task_tracker_app/main.dart' as app;
import 'package:task_tracker_app/services/location/location_models.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Location Integration Tests', () {
    testWidgets('should handle location permission flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Look for location settings option
      expect(find.text('Location'), findsOneWidget);
      
      // Tap on location settings
      await tester.tap(find.text('Location'));
      await tester.pumpAndSettle();

      // Verify location settings page is displayed
      expect(find.text('Location Settings'), findsOneWidget);
      expect(find.text('Location Service Status'), findsOneWidget);
      expect(find.text('Location Features'), findsOneWidget);
    });

    testWidgets('should display location permission status', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to location settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Location'));
      await tester.pumpAndSettle();

      // Check for permission status indicators
      expect(find.text('Location Services'), findsOneWidget);
      expect(find.text('Location Permission'), findsOneWidget);
    });

    testWidgets('should allow toggling location features', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to location settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Location'));
      await tester.pumpAndSettle();

      // Find location features toggle
      final locationToggle = find.byType(Switch).first;
      expect(locationToggle, findsOneWidget);

      // Toggle location features
      await tester.tap(locationToggle);
      await tester.pumpAndSettle();

      // Verify the toggle state changed
      // Note: In a real test, you'd verify the actual state change
      expect(locationToggle, findsOneWidget);
    });

    testWidgets('should show geofence configuration dialog', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to location settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Location'));
      await tester.pumpAndSettle();

      // Enable location features first
      final locationToggle = find.byType(Switch).first;
      await tester.tap(locationToggle);
      await tester.pumpAndSettle();

      // Enable geofencing
      final geofenceToggle = find.byType(Switch).at(1);
      await tester.tap(geofenceToggle);
      await tester.pumpAndSettle();

      // Tap add trigger button
      await tester.tap(find.text('Add Trigger'));
      await tester.pumpAndSettle();

      // Verify geofence configuration dialog is shown
      expect(find.text('Geofence Configuration'), findsOneWidget);
      expect(find.text('Geofence Name'), findsOneWidget);
      expect(find.text('Address or Location'), findsOneWidget);
      expect(find.text('Radius (meters)'), findsOneWidget);
      expect(find.text('Trigger Type'), findsOneWidget);
    });

    testWidgets('should handle location accuracy settings', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to location settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Location'));
      await tester.pumpAndSettle();

      // Enable location features
      final locationToggle = find.byType(Switch).first;
      await tester.tap(locationToggle);
      await tester.pumpAndSettle();

      // Find accuracy dropdown
      final accuracyDropdown = find.byType(DropdownButtonFormField).first;
      expect(accuracyDropdown, findsOneWidget);

      // Tap dropdown to open options
      await tester.tap(accuracyDropdown);
      await tester.pumpAndSettle();

      // Verify accuracy options are available
      expect(find.text('Low (Battery Saving)'), findsOneWidget);
      expect(find.text('Medium (Balanced)'), findsOneWidget);
      expect(find.text('High (GPS)'), findsOneWidget);
      expect(find.text('Best (High Accuracy)'), findsOneWidget);
    });

    testWidgets('should request location permission when button is tapped', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to location settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Location'));
      await tester.pumpAndSettle();

      // Find and tap request permission button
      final permissionButton = find.text('Request Location Permission');
      expect(permissionButton, findsOneWidget);

      await tester.tap(permissionButton);
      await tester.pumpAndSettle();

      // Note: In a real integration test, you'd need to handle the system permission dialog
      // This would require platform-specific testing or mocking
    });

    testWidgets('should refresh location status when refresh button is tapped', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to location settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Location'));
      await tester.pumpAndSettle();

      // Find and tap refresh button
      final refreshButton = find.text('Refresh Location Status');
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pumpAndSettle();

      // Verify the page is still displayed (refresh completed)
      expect(find.text('Location Settings'), findsOneWidget);
    });
  });

  group('Location Models Tests', () {
    test('LocationData should serialize to/from JSON', () {
      final timestamp = DateTime.now();
      final location = LocationData(
        latitude: 37.7749,
        longitude: -122.4194,
        accuracy: 5.0,
        altitude: 10.0,
        address: 'San Francisco, CA',
        timestamp: timestamp,
      );

      final json = location.toJson();
      final deserializedLocation = LocationData.fromJson(json);

      expect(deserializedLocation.latitude, equals(location.latitude));
      expect(deserializedLocation.longitude, equals(location.longitude));
      expect(deserializedLocation.accuracy, equals(location.accuracy));
      expect(deserializedLocation.altitude, equals(location.altitude));
      expect(deserializedLocation.address, equals(location.address));
    });

    test('GeofenceData should serialize to/from JSON', () {
      final createdAt = DateTime.now();
      final geofence = GeofenceData(
        id: 'test-id',
        name: 'Test Geofence',
        latitude: 37.7749,
        longitude: -122.4194,
        radius: 100.0,
        isActive: true,
        type: GeofenceType.enter,
        createdAt: createdAt,
      );

      final json = geofence.toJson();
      final deserializedGeofence = GeofenceData.fromJson(json);

      expect(deserializedGeofence.id, equals(geofence.id));
      expect(deserializedGeofence.name, equals(geofence.name));
      expect(deserializedGeofence.latitude, equals(geofence.latitude));
      expect(deserializedGeofence.longitude, equals(geofence.longitude));
      expect(deserializedGeofence.radius, equals(geofence.radius));
      expect(deserializedGeofence.isActive, equals(geofence.isActive));
      expect(deserializedGeofence.type, equals(geofence.type));
    });

    test('LocationTrigger should serialize to/from JSON', () {
      final createdAt = DateTime.now();
      final geofence = GeofenceData(
        id: 'geofence-id',
        name: 'Test Geofence',
        latitude: 37.7749,
        longitude: -122.4194,
        radius: 100.0,
        isActive: true,
        type: GeofenceType.enter,
        createdAt: createdAt,
      );

      final trigger = LocationTrigger(
        id: 'trigger-id',
        taskId: 'task-id',
        geofence: geofence,
        isEnabled: true,
        createdAt: createdAt,
      );

      final json = trigger.toJson();
      final deserializedTrigger = LocationTrigger.fromJson(json);

      expect(deserializedTrigger.id, equals(trigger.id));
      expect(deserializedTrigger.taskId, equals(trigger.taskId));
      expect(deserializedTrigger.geofence.id, equals(trigger.geofence.id));
      expect(deserializedTrigger.isEnabled, equals(trigger.isEnabled));
    });
  });
}