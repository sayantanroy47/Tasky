import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/calendar_event.dart';
import '../domain/entities/task_model.dart';
import '../domain/models/enums.dart';
import 'conflict_detection_service.dart';

/// Service for managing calendar events and scheduling
class CalendarService {
  final List<CalendarEvent> _events = [];
  final ConflictDetectionService _conflictDetectionService = const ConflictDetectionService();

  /// Get all calendar events
  List<CalendarEvent> getAllEvents() {
    return List.unmodifiable(_events);
  }

  /// Get events for a specific date
  List<CalendarEvent> getEventsForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _events.where((event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      return eventDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  /// Get events for a date range
  List<CalendarEvent> getEventsForRange(DateTime start, DateTime end) {
    return _events.where((event) {
      return event.startTime.isBefore(end) && event.endTime.isAfter(start);
    }).toList();
  }

  /// Add a new calendar event
  Future<void> addEvent(CalendarEvent event) async {
    _events.add(event);
    _events.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Update an existing calendar event
  Future<void> updateEvent(CalendarEvent event) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      _events.sort((a, b) => a.startTime.compareTo(b.startTime));
    }
  }

  /// Delete a calendar event
  Future<void> deleteEvent(String eventId) async {
    _events.removeWhere((event) => event.id == eventId);
  }

  /// Create a calendar event from a task
  CalendarEvent createEventFromTask(TaskModel task, DateTime startTime, DateTime endTime) {
    return CalendarEvent.create(
      taskId: task.id,
      title: task.title,
      description: task.description,
      startTime: startTime,
      endTime: endTime,
      color: _getColorForPriority(task.priority),
      metadata: {
        'taskPriority': task.priority.name,
        'taskStatus': task.status.name,
        'taskTags': task.tags,
      },
    );
  }

  /// Get suggested time slots for a task
  List<TimeSlot> getSuggestedTimeSlots(
    TaskModel task,
    DateTime date, {
    Duration duration = const Duration(hours: 1),
    Duration workingHoursStart = const Duration(hours: 9),
    Duration workingHoursEnd = const Duration(hours: 17),
  }) {
    final suggestions = <TimeSlot>[];
    final dayStart = DateTime(date.year, date.month, date.day)
        .add(workingHoursStart);
    final dayEnd = DateTime(date.year, date.month, date.day)
        .add(workingHoursEnd);
    
    final existingEvents = getEventsForDate(date);
    
    // Find available time slots
    DateTime currentTime = dayStart;
    while (currentTime.add(duration).isBefore(dayEnd)) {
      final proposedSlot = TimeSlot(currentTime, currentTime.add(duration));
      
      // Check if this slot conflicts with existing events
      final hasConflict = existingEvents.any((event) =>
          proposedSlot.startTime.isBefore(event.endTime) &&
          proposedSlot.endTime.isAfter(event.startTime));
      
      if (!hasConflict) {
        suggestions.add(proposedSlot);
      }
      
      currentTime = currentTime.add(const Duration(minutes: 30));
    }
    
    return suggestions;
  }

  /// Check for scheduling conflicts
  List<CalendarEvent> getConflictingEvents(DateTime startTime, DateTime endTime) {
    return _events.where((event) =>
        startTime.isBefore(event.endTime) && endTime.isAfter(event.startTime)
    ).toList();
  }

  /// Reschedule an event to a new time
  Future<bool> rescheduleEvent(String eventId, DateTime newStartTime, DateTime newEndTime) async {
    final event = _events.firstWhere((e) => e.id == eventId);
    
    // Check for conflicts (excluding the current event)
    final conflicts = _events.where((e) =>
        e.id != eventId &&
        newStartTime.isBefore(e.endTime) &&
        newEndTime.isAfter(e.startTime)
    ).toList();
    
    if (conflicts.isNotEmpty) {
      return false; // Cannot reschedule due to conflicts
    }
    
    final updatedEvent = event.copyWith(
      startTime: newStartTime,
      endTime: newEndTime,
    );
    
    await updateEvent(updatedEvent);
    return true;
  }

  /// Get color for task priority
  String _getColorForPriority(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return '#F44336'; // Red
      case TaskPriority.high:
        return '#FF9800'; // Orange
      case TaskPriority.medium:
        return '#2196F3'; // Blue
      case TaskPriority.low:
        return '#4CAF50'; // Green
    }
  }

  /// Get events grouped by date
  Map<DateTime, List<CalendarEvent>> getEventsGroupedByDate() {
    final grouped = <DateTime, List<CalendarEvent>>{};
    
    for (final event in _events) {
      final date = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      
      grouped.putIfAbsent(date, () => []).add(event);
    }
    
    return grouped;
  }

  /// Get today's events
  List<CalendarEvent> getTodaysEvents() {
    return getEventsForDate(DateTime.now());
  }

  /// Get upcoming events (next 7 days)
  List<CalendarEvent> getUpcomingEvents() {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return getEventsForRange(now, nextWeek);
  }

  /// Detect conflicts between all events
  List<ConflictGroup> detectAllConflicts() {
    return _conflictDetectionService.detectConflicts(_events);
  }

  /// Check for conflicts when adding/updating an event
  ConflictCheckResult checkEventConflicts(
    CalendarEvent event, {
    String? excludeEventId,
  }) {
    return _conflictDetectionService.checkForConflicts(
      event,
      _events,
      excludeEventId: excludeEventId,
    );
  }

  /// Get scheduling suggestions for a task
  List<SchedulingSuggestion> getSchedulingSuggestions(
    TaskModel task,
    DateTime preferredDate, {
    Duration preferredDuration = const Duration(hours: 1),
  }) {
    return _conflictDetectionService.getSchedulingSuggestions(
      task,
      preferredDate,
      _events,
      preferredDuration: preferredDuration,
    );
  }

  /// Add event with conflict checking
  Future<ConflictCheckResult> addEventWithConflictCheck(CalendarEvent event) async {
    final conflictResult = checkEventConflicts(event);
    
    if (!conflictResult.hasConflicts) {
      await addEvent(event);
    }
    
    return conflictResult;
  }

  /// Update event with conflict checking
  Future<ConflictCheckResult> updateEventWithConflictCheck(CalendarEvent event) async {
    final conflictResult = checkEventConflicts(event, excludeEventId: event.id);
    
    if (!conflictResult.hasConflicts) {
      await updateEvent(event);
    }
    
    return conflictResult;
  }
}

/// Represents a time slot for scheduling
class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;

  const TimeSlot(this.startTime, this.endTime);

  Duration get duration => endTime.difference(startTime);
  @override
  String toString() => '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';
}

/// Provider for calendar service
final calendarServiceProvider = Provider<CalendarService>((ref) {
  return const CalendarService();
});