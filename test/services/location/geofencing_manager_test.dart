import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/services/location/geofencing_manager.dart';
import 'package:task_tracker_app/services/location/location_service.dart';
import 'package:task_tracker_app/services/location/location_models.dart';
import 'package:task_tracker_app/services/notification/notification_service.dart';
import 'package:task_tracker_app/domain/repositories/task_repository.dart';

@GenerateMocks([LocationService, NotificationService, TaskRepository])
import 'geofencing_manager_test.mocks.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  group('GeofencingManager', () {
    late GeofencingManager geofencingManager;
    late MockLocationService mockLocationService;
    late MockNotificationService mockNotificationService;
    late MockTaskRepository mockTaskRepository;

    setUp(() {
      mockLocationService = MockLocationService();
      mockNotificationService = MockNotificationService();
      mockTaskRepository = MockTaskRepository();

      geofencingManager = GeofencingManager(
        mockLocationService,
        mockNotificationService,
        mockTaskRepository,
      );

      // Setup default mock behaviors
      when(mockLocationService.getGeofenceEventStream())
          .thenAnswer((_) => const Stream.empty());
      when(mockLocationService.getLocationStream())
          .thenAnswer((_) => const Stream.empty());
    });

    tearDown(() {
      geofencingManager.dispose();
    });

    group('addLocationTrigger', () {
      test('should add active location trigger and start monitoring', () async {
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

        final trigger = LocationTrigger(
          id: 'test-trigger',
          taskId: 'test-task',
          geofence: geofence,
          isEnabled: true,
          createdAt: DateTime.now(),
        );

        when(mockLocationService.startGeofenceMonitoring(geofence))
            .thenAnswer((_) async {});

        await geofencingManager.addLocationTrigger(trigger);

        verify(mockLocationService.startGeofenceMonitoring(geofence)).called(1);
        
        final activeTriggers = geofencingManager.getActiveTriggers();
        expect(activeTriggers, contains(trigger));
      });

      test('should not add disabled location trigger', () async {
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

        final trigger = LocationTrigger(
          id: 'test-trigger',
          taskId: 'test-task',
          geofence: geofence,
          isEnabled: false, // Disabled
          createdAt: DateTime.now(),
        );

        await geofencingManager.addLocationTrigger(trigger);

        verifyNever(mockLocationService.startGeofenceMonitoring(any));
        
        final activeTriggers = geofencingManager.getActiveTriggers();
        expect(activeTriggers, isEmpty);
      });
    });

    group('removeLocationTrigger', () {
      test('should remove location trigger and stop monitoring', () async {
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

        final trigger = LocationTrigger(
          id: 'test-trigger',
          taskId: 'test-task',
          geofence: geofence,
          isEnabled: true,
          createdAt: DateTime.now(),
        );

        when(mockLocationService.startGeofenceMonitoring(geofence))
            .thenAnswer((_) async {});
        when(mockLocationService.stopGeofenceMonitoring(geofence.id))
            .thenAnswer((_) async {});

        // Add trigger first
        await geofencingManager.addLocationTrigger(trigger);
        expect(geofencingManager.getActiveTriggers(), contains(trigger));

        // Remove trigger
        await geofencingManager.removeLocationTrigger(trigger.id);

        verify(mockLocationService.stopGeofenceMonitoring(geofence.id)).called(1);
        
        final activeTriggers = geofencingManager.getActiveTriggers();
        expect(activeTriggers, isEmpty);
      });
    });

    group('updateLocationTrigger', () {
      test('should update location trigger by removing and re-adding', () async {
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

        final originalTrigger = LocationTrigger(
          id: 'test-trigger',
          taskId: 'test-task',
          geofence: geofence,
          isEnabled: true,
          createdAt: DateTime.now(),
        );

        final updatedTrigger = originalTrigger.copyWith(isEnabled: false);

        when(mockLocationService.startGeofenceMonitoring(geofence))
            .thenAnswer((_) async {});
        when(mockLocationService.stopGeofenceMonitoring(geofence.id))
            .thenAnswer((_) async {});

        // Add original trigger
        await geofencingManager.addLocationTrigger(originalTrigger);
        expect(geofencingManager.getActiveTriggers(), hasLength(1));

        // Update trigger (disabled, so should be removed)
        await geofencingManager.updateLocationTrigger(updatedTrigger);

        verify(mockLocationService.stopGeofenceMonitoring(geofence.id)).called(1);
        expect(geofencingManager.getActiveTriggers(), isEmpty);
      });
    });

    group('getTriggersForTask', () {
      test('should return triggers for specific task', () async {
        final geofence1 = GeofenceData(
          id: 'geofence-1',
          name: 'Geofence 1',
          latitude: 37.7749,
          longitude: -122.4194,
          radius: 100.0,
          isActive: true,
          type: GeofenceType.enter,
          createdAt: DateTime.now(),
        );

        final geofence2 = GeofenceData(
          id: 'geofence-2',
          name: 'Geofence 2',
          latitude: 37.8000,
          longitude: -122.5000,
          radius: 200.0,
          isActive: true,
          type: GeofenceType.exit,
          createdAt: DateTime.now(),
        );

        final trigger1 = LocationTrigger(
          id: 'trigger-1',
          taskId: 'task-1',
          geofence: geofence1,
          isEnabled: true,
          createdAt: DateTime.now(),
        );

        final trigger2 = LocationTrigger(
          id: 'trigger-2',
          taskId: 'task-2',
          geofence: geofence2,
          isEnabled: true,
          createdAt: DateTime.now(),
        );

        when(mockLocationService.startGeofenceMonitoring(any))
            .thenAnswer((_) async {});

        await geofencingManager.addLocationTrigger(trigger1);
        await geofencingManager.addLocationTrigger(trigger2);

        final task1Triggers = geofencingManager.getTriggersForTask('task-1');
        expect(task1Triggers, hasLength(1));
        expect(task1Triggers.first.id, equals('trigger-1'));

        final task2Triggers = geofencingManager.getTriggersForTask('task-2');
        expect(task2Triggers, hasLength(1));
        expect(task2Triggers.first.id, equals('trigger-2'));

        final nonExistentTaskTriggers = geofencingManager.getTriggersForTask('task-3');
        expect(nonExistentTaskTriggers, isEmpty);
      });
    });

    group('dispose', () {
      test('should clean up resources', () async {
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

        final trigger = LocationTrigger(
          id: 'test-trigger',
          taskId: 'test-task',
          geofence: geofence,
          isEnabled: true,
          createdAt: DateTime.now(),
        );

        when(mockLocationService.startGeofenceMonitoring(geofence))
            .thenAnswer((_) async {});
        when(mockLocationService.stopAllGeofenceMonitoring())
            .thenAnswer((_) async {});

        await geofencingManager.addLocationTrigger(trigger);
        expect(geofencingManager.getActiveTriggers(), hasLength(1));

        geofencingManager.dispose();

        verify(mockLocationService.stopAllGeofenceMonitoring()).called(1);
        expect(geofencingManager.getActiveTriggers(), isEmpty);
      });
    });
  });
}
