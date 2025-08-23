import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/services/location/location_service_impl.dart';
import 'package:task_tracker_app/services/location/location_service.dart';
import 'package:task_tracker_app/services/location/location_models.dart';

void main() {
  group('LocationServiceImpl (Stub)', () {
    late LocationService locationService;

    setUp(() {
      locationService = LocationServiceImpl();
    });

    tearDown(() {
      locationService.dispose();
    });

    group('Basic Service Methods', () {
      test('should return false for location service enabled', () async {
        final result = await locationService.isLocationServiceEnabled();
        expect(result, isFalse);
      });

      test('should return denied for permission check', () async {
        final result = await locationService.checkPermission();
        expect(result, LocationPermissionStatus.denied);
      });

      test('should return denied for permission request', () async {
        final result = await locationService.requestPermission();
        expect(result, LocationPermissionStatus.denied);
      });

      test('should throw exception for getCurrentLocation', () async {
        expect(
          () => locationService.getCurrentLocation(),
          throwsA(isA<Exception>()),
        );
      });

      test('should return empty stream for location stream', () async {
        final stream = locationService.getLocationStream();
        expect(stream, isA<Stream<LocationData>>());
        
        final events = <LocationData>[];
        final subscription = stream.listen(events.add);
        
        await Future.delayed(const Duration(milliseconds: 100));
        subscription.cancel();
        
        expect(events, isEmpty);
      });

      test('should return null for address from coordinates', () async {
        final result = await locationService.getAddressFromCoordinates(37.7749, -122.4194);
        expect(result, isNull);
      });
    });

    group('Stub Behavior', () {
      test('should handle missing methods gracefully', () {
        // Test that the stub handles unknown method calls without crashing
        expect(() => locationService.dispose(), returnsNormally);
      });
    });
  });
}
