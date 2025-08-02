import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import '../domain/entities/calendar_event.dart';
import '../domain/entities/task_model.dart';
import '../domain/models/enums.dart';

// Create a local timezone reference
final local = tz.local;

/// Service for integrating with system calendar
class SystemCalendarService {
  final DeviceCalendarPlugin _deviceCalendarPlugin = const DeviceCalendarPlugin();
  List<Calendar>? _availableCalendars;
  String? _selectedCalendarId;

  /// Initialize the service and request permissions
  Future<bool> initialize() async {
    try {
      final permissionStatus = await Permission.calendar.request();
      if (permissionStatus.isGranted) {
        await _loadAvailableCalendars();
        return true;
      }
      return false;
    } catch (e) {
      // print('Error initializing system calendar service: $e');
      return false;
    }
  }

  /// Load available calendars from the device
  Future<void> _loadAvailableCalendars() async {
    try {
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (calendarsResult.isSuccess && calendarsResult.data != null) {
        _availableCalendars = calendarsResult.data!;
        
        // Select the first writable calendar as default
        _selectedCalendarId = _availableCalendars
            ?.firstWhere(
              (calendar) => !calendar.isReadOnly,
              orElse: () => _availableCalendars!.first,
            )
            .id;
      }
    } catch (e) {
      // print('Error loading calendars: $e');
    }
  }

  /// Get available calendars
  List<Calendar> get availableCalendars => _availableCalendars ?? [];

  /// Get selected calendar ID
  String? get selectedCalendarId => _selectedCalendarId;

  /// Set selected calendar
  void setSelectedCalendar(String calendarId) {
    if (_availableCalendars?.any((cal) => cal.id == calendarId) == true) {
      _selectedCalendarId = calendarId;
    }
  }

  /// Check if calendar permissions are granted
  Future<bool> hasCalendarPermission() async {
    final status = await Permission.calendar.status;
    return status.isGranted;
  }

  /// Request calendar permissions
  Future<bool> requestCalendarPermission() async {
    final status = await Permission.calendar.request();
    return status.isGranted;
  }

  /// Sync task to system calendar
  Future<SystemCalendarResult> syncTaskToCalendar(
    TaskModel task,
    DateTime startTime,
    DateTime endTime, {
    bool isAllDay = false,
    String? location,
    List<String> attendees = const [],
  }) async {
    if (_selectedCalendarId == null) {
      return const SystemCalendarResult(
        success: false,
        error: 'No calendar selected',
      );
    }

    try {
      final event = Event(_selectedCalendarId)
        ..title = task.title
        ..description = task.description
        ..start = TZDateTime.from(startTime, local)
        ..end = TZDateTime.from(endTime, local)
        ..allDay = isAllDay
        ..location = location;

      // Add attendees if provided
      if (attendees.isNotEmpty) {
        event.attendees = attendees.map((email) => Attendee(
          name: email,
          emailAddress: email,
        )).toList();
      }

      // Set reminder based on task priority
      event.reminders = _getRemindersForTask(task);

      final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
      
      if (result?.isSuccess == true) {
        return SystemCalendarResult(
          success: true,
          eventId: result!.data,
          message: 'Task synced to calendar successfully',
        );
      } else {
        return SystemCalendarResult(
          success: false,
          error: result?.errors.join(', ') ?? 'Unknown error',
        );
      }
    } catch (e) {
      return SystemCalendarResult(
        success: false,
        error: 'Failed to sync task: $e',
      );
    }
  }

  /// Create calendar event from CalendarEvent
  Future<SystemCalendarResult> createCalendarEvent(CalendarEvent calendarEvent) async {
    if (_selectedCalendarId == null) {
      return const SystemCalendarResult(
        success: false,
        error: 'No calendar selected',
      );
    }

    try {
      final event = Event(_selectedCalendarId)
        ..title = calendarEvent.title
        ..description = calendarEvent.description
        ..start = TZDateTime.from(calendarEvent.startTime, local)
        ..end = TZDateTime.from(calendarEvent.endTime, local)
        ..allDay = calendarEvent.isAllDay
        ..location = calendarEvent.location;

      // Add reminders
      if (calendarEvent.reminders.isNotEmpty) {
        event.reminders = calendarEvent.reminders.map((minutes) => Reminder(
          minutes: minutes,
        )).toList();
      }

      final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
      
      if (result?.isSuccess == true) {
        return SystemCalendarResult(
          success: true,
          eventId: result!.data,
          message: 'Event created in calendar successfully',
        );
      } else {
        return SystemCalendarResult(
          success: false,
          error: result?.errors.join(', ') ?? 'Unknown error',
        );
      }
    } catch (e) {
      return SystemCalendarResult(
        success: false,
        error: 'Failed to create event: $e',
      );
    }
  }

  /// Update calendar event
  Future<SystemCalendarResult> updateCalendarEvent(
    String eventId,
    CalendarEvent calendarEvent,
  ) async {
    if (_selectedCalendarId == null) {
      return const SystemCalendarResult(
        success: false,
        error: 'No calendar selected',
      );
    }

    try {
      final event = Event(_selectedCalendarId, eventId: eventId)
        ..title = calendarEvent.title
        ..description = calendarEvent.description
        ..start = TZDateTime.from(calendarEvent.startTime, local)
        ..end = TZDateTime.from(calendarEvent.endTime, local)
        ..allDay = calendarEvent.isAllDay
        ..location = calendarEvent.location;

      // Add reminders
      if (calendarEvent.reminders.isNotEmpty) {
        event.reminders = calendarEvent.reminders.map((minutes) => Reminder(
          minutes: minutes,
        )).toList();
      }

      final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
      
      if (result?.isSuccess == true) {
        return SystemCalendarResult(
          success: true,
          eventId: result!.data,
          message: 'Event updated in calendar successfully',
        );
      } else {
        return SystemCalendarResult(
          success: false,
          error: result?.errors.join(', ') ?? 'Unknown error',
        );
      }
    } catch (e) {
      return SystemCalendarResult(
        success: false,
        error: 'Failed to update event: $e',
      );
    }
  }

  /// Delete calendar event
  Future<SystemCalendarResult> deleteCalendarEvent(String eventId) async {
    if (_selectedCalendarId == null) {
      return const SystemCalendarResult(
        success: false,
        error: 'No calendar selected',
      );
    }

    try {
      final result = await _deviceCalendarPlugin.deleteEvent(_selectedCalendarId!, eventId);
      
      if (result.isSuccess == true) {
        return const SystemCalendarResult(
          success: true,
          message: 'Event deleted from calendar successfully',
        );
      } else {
        return SystemCalendarResult(
          success: false,
          error: result.errors.join(', ') ?? 'Unknown error',
        );
      }
    } catch (e) {
      return SystemCalendarResult(
        success: false,
        error: 'Failed to delete event: $e',
      );
    }
  }

  /// Import events from system calendar
  Future<List<CalendarEvent>> importEventsFromCalendar({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_selectedCalendarId == null) {
      return [];
    }

    try {
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now().add(const Duration(days: 365));

      final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
        _selectedCalendarId!,
        RetrieveEventsParams(
          startDate: start,
          endDate: end,
        ),
      );

      if (eventsResult.isSuccess && eventsResult.data != null) {
        return eventsResult.data!.map((event) => _convertToCalendarEvent(event)).toList();
      }
    } catch (e) {
      // print('Error importing events: $e');
    }

    return [];
  }

  /// Convert system Event to CalendarEvent
  CalendarEvent _convertToCalendarEvent(Event systemEvent) {
    return CalendarEvent.create(
      title: systemEvent.title ?? 'Untitled Event',
      description: systemEvent.description,
      startTime: systemEvent.start?.toLocal() ?? DateTime.now(),
      endTime: systemEvent.end?.toLocal() ?? DateTime.now().add(const Duration(hours: 1)),
      isAllDay: systemEvent.allDay ?? false,
      location: systemEvent.location,
      reminders: systemEvent.reminders?.map((r) => r.minutes ?? 15).toList() ?? [],
      metadata: {
        'systemEventId': systemEvent.eventId,
        'calendarId': systemEvent.calendarId,
        'imported': true,
      },
    );
  }

  /// Get reminders based on task priority
  List<Reminder> _getRemindersForTask(TaskModel task) {
    switch (task.priority) {
      case TaskPriority.urgent:
        return [
          Reminder(minutes: 60), // 1 hour before
          Reminder(minutes: 15), // 15 minutes before
        ];
      case TaskPriority.high:
        return [
          Reminder(minutes: 30), // 30 minutes before
        ];
      case TaskPriority.medium:
        return [
          Reminder(minutes: 15), // 15 minutes before
        ];
      case TaskPriority.low:
        return [
          Reminder(minutes: 5), // 5 minutes before
        ];
    }
  }

  /// Enable two-way sync
  Future<void> enableTwoWaySync() async {
    // This would set up listeners for calendar changes
    // Implementation depends on platform capabilities
    // For now, we'll implement periodic sync
  }

  /// Perform periodic sync
  Future<SyncResult> performSync() async {
    try {
      final importedEvents = await importEventsFromCalendar();
      
      // Here you would compare with local events and sync changes
      // This is a simplified implementation
      
      return SyncResult(
        success: true,
        importedCount: importedEvents.length,
        exportedCount: 0, // Would track exported events
        conflictsCount: 0, // Would track conflicts
      );
    } catch (e) {
      return SyncResult(
        success: false,
        error: 'Sync failed: $e',
      );
    }
  }

  /// Get sync status
  Future<CalendarSyncStatus> getSyncStatus() async {
    final hasPermission = await hasCalendarPermission();
    final hasSelectedCalendar = _selectedCalendarId != null;
    
    return CalendarSyncStatus(
      isEnabled: hasPermission && hasSelectedCalendar,
      hasPermission: hasPermission,
      selectedCalendarName: _availableCalendars
          ?.firstWhere((cal) => cal.id == _selectedCalendarId, orElse: () => Calendar())
          .name,
      lastSyncTime: null, // Would track last sync time
    );
  }
}

/// Result of system calendar operations
class SystemCalendarResult {
  final bool success;
  final String? eventId;
  final String? message;
  final String? error;

  const SystemCalendarResult({
    required this.success,
    this.eventId,
    this.message,
    this.error,
  });
}

/// Result of sync operations
class SyncResult {
  final bool success;
  final int importedCount;
  final int exportedCount;
  final int conflictsCount;
  final String? error;

  const SyncResult({
    required this.success,
    this.importedCount = 0,
    this.exportedCount = 0,
    this.conflictsCount = 0,
    this.error,
  });
}

/// Calendar sync status
class CalendarSyncStatus {
  final bool isEnabled;
  final bool hasPermission;
  final String? selectedCalendarName;
  final DateTime? lastSyncTime;

  const CalendarSyncStatus({
    required this.isEnabled,
    required this.hasPermission,
    this.selectedCalendarName,
    this.lastSyncTime,
  });
}

/// Provider for system calendar service
final systemCalendarServiceProvider = Provider<SystemCalendarService>((ref) {
  return const SystemCalendarService();
});

/// Provider for calendar sync status
final calendarSyncStatusProvider = FutureProvider<CalendarSyncStatus>((ref) async {
  final service = ref.read(systemCalendarServiceProvider);
  return await service.getSyncStatus();
});

/// Provider for available calendars
final availableCalendarsProvider = Provider<List<Calendar>>((ref) {
  final service = ref.read(systemCalendarServiceProvider);
  return service.availableCalendars;
});