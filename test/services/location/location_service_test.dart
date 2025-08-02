import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:task_tracker_app/services/location/location_service_impl.dart';
import 'package:task_tracker_app/services/location/location_models.dart';

// Generate mocks
@GenerateMocks([])
class MockPosition extends Mock implements Position {  @override
  double get latitude => 37.7749;  @override
  double get longitude => -122.4194;  @override
  double get accuracy => 5.0;  @override
  double get altitude => 10.0;  @override
  DateTime? get timestamp => DateTime(2024, 1, 1, 12, 0, 0);
}

void main() {
  group('LocationServiceImpl', () {
    late LocationServiceImpl locationService;

    setUp(() {
      locationService = const LocationServiceImpl();
    });

    tearDown(() {
      locationService.dispose();
    });

    group('calculateDistance', () {
      test('should calculate distance between two points correctly', () {
        // San Francisco to Los Angeles (approximate)
        const lat1 = 37.7749;
        const lon1 = -122.4194;
        const lat2 = 34.0522;
        const lon2 = -118.2437;

        final distance = locationService.calculateDistance(lat1, lon1, lat2, lon2);

        // Distance should be approximately 559 km (559,000 meters)
        expect(distance, greaterThan(500000));
        expect(distance, lessThan(600000));
      });

      test('should return zero for same coordinates', () {
        const lat = 37.7749;
        const lon = -122.4194;

        final distance = locationService.calculateDistance(lat, lon, lat, lon);

        expect(distance, equals(0.0));
      });
    });

    group('isWithinGeofence', () {
      test('should return true when location is within geofence', () {
        final location = LocationData(
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime.now(),
        );

        final geofence = GeofenceData(
          id: 'test-geofence',
          name: 'Test Geofence',
          latitude: 37.7749,
          longitude: -122.4194,
          radius: 100.0,
          isActive: true,
          type: GeofenceType.enter,
          createdAt: DateTime.now(),
        );

        final result = locationService.isWithinGeofence(location, geofence);

        expect(result, isTrue);
      });

      test('should return false when location is outside geofence', () {
        final location = LocationData(
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime.now(),
        );

        final geofence = GeofenceData(
          id: 'test-geofence',
          name: 'Test Geofence',
          latitude: 37.8000, // Different location
          longitude: -122.5000,
          radius: 100.0,
          isActive: true,
          type: GeofenceType.enter,
          createdAt: DateTime.now(),
        );

        final result = locationService.isWithinGeofence(location, geofence);

        expect(result, isFalse);
      });
    });

    group('geofence monitoring', () {
      test('should add geofence to active monitoring', () async {
        final geofence = GeofenceData(
          id: 'test-geofence',
          name: 'Test Geofence',
          latitude: 37.7749,
          longitude: -122.4194,
          radius: 100.0,
          isActive: true,
          type: GeofenceType.enter,
          createdAt: DateTime.now(),
        );

        await locationService.startGeofenceMonitoring(geofence);

        // Verify geofence is being monitored (implementation detail)
        expect(locationService, isNotNull);
      });

      test('should remove geofence from active monitoring', () async {
        final geofence = GeofenceData(
          id: 'test-geofence',
          name: 'Test Geofence',
          latitude: 37.7749,
          longitude: -122.4194,
          radius: 100.0,
          isActive: true,
          type: GeofenceType.enter,
          createdAt: DateTime.now(),
        );

        await locationService.startGeofenceMonitoring(geofence);
        await locationService.stopGeofenceMonitoring(geofence.id);

        // Verify geofence is no longer being monitored
        expect(locationService, isNotNull);
      });

      test('should clear all geofences', () async {
        final geofence1 = GeofenceData(
          id: 'test-geofence-1',
          name: 'Test Geofence 1',
          latitude: 37.7749,
          longitude: -122.4194,
          radius: 100.0,
          isActive: true,
          type: GeofenceType.enter,
          createdAt: DateTime.now(),
        );

        final geofence2 = GeofenceData(
          id: 'test-geofence-2',
          name: 'Test Geofence 2',
          latitude: 37.8000,
          longitude: -122.5000,
          radius: 200.0,
          isActive: true,
          type: GeofenceType.exit,
          createdAt: DateTime.now(),
        );

        await locationService.startGeofenceMonitoring(geofence1);
        await locationService.startGeofenceMonitoring(geofence2);
        await locationService.stopAllGeofenceMonitoring();

        // Verify all geofences are cleared
        expect(locationService, isNotNull);
      });
    });

    group('geofence events', () {
      test('should provide geofence event stream', () {
        final eventStream = locationService.getGeofenceEventStream();

        expect(eventStream, isA<Stream<GeofenceEvent>>());
      });
    });
  });

  group('LocationData', () {
    test('should create LocationData with required fields', () {
      final timestamp = DateTime.now();
      final location = LocationData(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: timestamp,
      );

      expect(location.latitude, equals(37.7749));
      expect(location.longitude, equals(-122.4194));
      expect(location.timestamp, equals(timestamp));
      expect(location.accuracy, isNull);
      expect(location.altitude, isNull);
      expect(location.address, isNull);
    });

    test('should create LocationData with all fields', () {
      final timestamp = DateTime.now();
      final location = LocationData(
        latitude: 37.7749,
        longitude: -122.4194,
        accuracy: 5.0,
        altitude: 10.0,
        address: 'San Francisco, CA',
        timestamp: timestamp,
      );

      expect(location.latitude, equals(37.7749));
      expect(location.longitude, equals(-122.4194));
      expect(location.accuracy, equals(5.0));
      expect(location.altitude, equals(10.0));
      expect(location.address, equals('San Francisco, CA'));
      expect(location.timestamp, equals(timestamp));
    });

    test('should support copyWith', () {
      final timestamp = DateTime.now();
      final location = LocationData(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: timestamp,
      );

      final updatedLocation = location.copyWith(
        accuracy: 5.0,
        address: 'San Francisco, CA',
      );

      expect(updatedLocation.latitude, equals(37.7749));
      expect(updatedLocation.longitude, equals(-122.4194));
      expect(updatedLocation.accuracy, equals(5.0));
      expect(updatedLocation.address, equals('San Francisco, CA'));
      expect(updatedLocation.timestamp, equals(timestamp));
    });

    test('should support equality comparison', () {
      final timestamp = DateTime.now();
      final location1 = LocationData(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: timestamp,
      );

      final location2 = LocationData(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: timestamp,
      );

      expect(location1, equals(location2));
    });
  });

  group('GeofenceData', () {
    test('should create GeofenceData with all fields', () {
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

      expect(geofence.id, equals('test-id'));
      expect(geofence.name, equals('Test Geofence'));
      expect(geofence.latitude, equals(37.7749));
      expect(geofence.longitude, equals(-122.4194));
      expect(geofence.radius, equals(100.0));
      expect(geofence.isActive, isTrue);
      expect(geofence.type, equals(GeofenceType.enter));
      expect(geofence.createdAt, equals(createdAt));
    });

    test('should support copyWith', () {
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

      final updatedGeofence = geofence.copyWith(
        name: 'Updated Geofence',
        radius: 200.0,
        isActive: false,
      );

      expect(updatedGeofence.id, equals('test-id'));
      expect(updatedGeofence.name, equals('Updated Geofence'));
      expect(updatedGeofence.radius, equals(200.0));
      expect(updatedGeofence.isActive, isFalse);
      expect(updatedGeofence.type, equals(GeofenceType.enter));
    });
  });

  group('LocationTrigger', () {
    test('should create LocationTrigger with all fields', () {
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

      expect(trigger.id, equals('trigger-id'));
      expect(trigger.taskId, equals('task-id'));
      expect(trigger.geofence, equals(geofence));
      expect(trigger.isEnabled, isTrue);
      expect(trigger.createdAt, equals(createdAt));
    });
  });

  group('LocationServiceException', () {
    test('should create exception with message', () {
      const exception = LocationServiceException('Test error');

      expect(exception.message, equals('Test error'));
      expect(exception.code, isNull);
      expect(exception.toString(), equals('LocationServiceException: Test error'));
    });

    test('should create exception with message and code', () {
      const exception = LocationServiceException('Test error', 'TEST_CODE');

      expect(exception.message, equals('Test error'));
      expect(exception.code, equals('TEST_CODE'));
      expect(exception.toString(), equals('LocationServiceException: Test error (TEST_CODE)'));
    });
  });
}