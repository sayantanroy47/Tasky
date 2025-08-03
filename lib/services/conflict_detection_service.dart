import '../domain/entities/calendar_event.dart';
import '../domain/entities/task_model.dart';
import '../domain/models/enums.dart';

/// Service for detecting and resolving scheduling conflicts
class ConflictDetectionService {
  /// Detect conflicts between events
  List<ConflictGroup> detectConflicts(List<CalendarEvent> events) {
    final conflicts = <ConflictGroup>[];
    
    for (int i = 0; i < events.length; i++) {
      final event = events[i];
      final conflictingEvents = <CalendarEvent>[];
      
      for (int j = i + 1; j < events.length; j++) {
        final otherEvent = events[j];
        if (event.conflictsWith(otherEvent)) {
          conflictingEvents.add(otherEvent);
        }
      }
      
      if (conflictingEvents.isNotEmpty) {
        // Check if this conflict group already exists
        final existingGroup = conflicts.firstWhere(
          (group) => group.events.any((e) => 
            e.id == event.id || conflictingEvents.any((ce) => ce.id == e.id)),
          orElse: () => ConflictGroup(events: []),
        );
        
        if (existingGroup.events.isEmpty) {
          // Create new conflict group
          conflicts.add(ConflictGroup(
            events: [event, ...conflictingEvents],
          ));
        } else {
          // Add to existing group
          existingGroup.events.addAll([event, ...conflictingEvents]);
          // Remove duplicates
          existingGroup.events = existingGroup.events.toSet().toList();
        }
      }
    }
    
    return conflicts;
  }

  /// Check if a new event would conflict with existing events
  ConflictCheckResult checkForConflicts(
    CalendarEvent newEvent,
    List<CalendarEvent> existingEvents, {
    String? excludeEventId,
  }) {
    final conflicts = existingEvents
        .where((event) => 
            event.id != excludeEventId && 
            newEvent.conflictsWith(event))
        .toList();
    
    if (conflicts.isEmpty) {
      return const ConflictCheckResult(
        hasConflicts: false,
        conflictingEvents: [],
        severity: ConflictSeverity.none,
      );
    }
    
    final severity = _calculateConflictSeverity(newEvent, conflicts);
    
    return ConflictCheckResult(
      hasConflicts: true,
      conflictingEvents: conflicts,
      severity: severity,
      suggestions: _generateResolutionSuggestions(newEvent, conflicts),
    );
  }

  /// Generate suggestions for resolving conflicts
  List<ConflictResolution> _generateResolutionSuggestions(
    CalendarEvent newEvent,
    List<CalendarEvent> conflicts,
  ) {
    final suggestions = <ConflictResolution>[];
    
    // Suggest moving to next available slot
    final nextSlot = _findNextAvailableSlot(newEvent, conflicts);
    if (nextSlot != null) {
      suggestions.add(ConflictResolution(
        type: ResolutionType.reschedule,
        description: 'Move to ${_formatTimeSlot(nextSlot.startTime, nextSlot.endTime)}',
        newStartTime: nextSlot.startTime,
        newEndTime: nextSlot.endTime,
        priority: ResolutionPriority.high,
      ));
    }
    
    // Suggest shortening the event
    final shortenedSlot = _findShortenedSlot(newEvent, conflicts);
    if (shortenedSlot != null) {
      suggestions.add(ConflictResolution(
        type: ResolutionType.shorten,
        description: 'Shorten to ${_formatTimeSlot(shortenedSlot.startTime, shortenedSlot.endTime)}',
        newStartTime: shortenedSlot.startTime,
        newEndTime: shortenedSlot.endTime,
        priority: ResolutionPriority.medium,
      ));
    }
    
    // Suggest moving conflicting events
    for (final conflict in conflicts) {
      final alternativeSlot = _findAlternativeSlot(conflict, [newEvent]);
      if (alternativeSlot != null) {
        suggestions.add(ConflictResolution(
          type: ResolutionType.moveConflicting,
          description: 'Move "${conflict.title}" to ${_formatTimeSlot(alternativeSlot.startTime, alternativeSlot.endTime)}',
          conflictingEventId: conflict.id,
          newStartTime: alternativeSlot.startTime,
          newEndTime: alternativeSlot.endTime,
          priority: ResolutionPriority.low,
        ));
      }
    }
    
    return suggestions..sort((a, b) => b.priority.index.compareTo(a.priority.index));
  }

  /// Calculate conflict severity
  ConflictSeverity _calculateConflictSeverity(
    CalendarEvent newEvent,
    List<CalendarEvent> conflicts,
  ) {
    // Check for complete overlap
    final hasCompleteOverlap = conflicts.any((conflict) =>
        newEvent.startTime.isAtSameMomentAs(conflict.startTime) &&
        newEvent.endTime.isAtSameMomentAs(conflict.endTime));
    
    if (hasCompleteOverlap) {
      return ConflictSeverity.critical;
    }
    
    // Check for high priority conflicts
    final hasHighPriorityConflict = conflicts.any((conflict) {
      final taskPriority = conflict.metadata['taskPriority'] as String?;
      return taskPriority == 'urgent' || taskPriority == 'high';
    });
    
    if (hasHighPriorityConflict) {
      return ConflictSeverity.high;
    }
    
    // Check overlap percentage
    final totalOverlapDuration = conflicts.fold<Duration>(
      Duration.zero,
      (total, conflict) => total + _calculateOverlapDuration(newEvent, conflict),
    );
    
    final overlapPercentage = totalOverlapDuration.inMinutes / newEvent.duration.inMinutes;
    
    if (overlapPercentage > 0.75) {
      return ConflictSeverity.high;
    } else if (overlapPercentage > 0.25) {
      return ConflictSeverity.medium;
    } else {
      return ConflictSeverity.low;
    }
  }

  /// Calculate overlap duration between two events
  Duration _calculateOverlapDuration(CalendarEvent event1, CalendarEvent event2) {
    final overlapStart = event1.startTime.isAfter(event2.startTime) 
        ? event1.startTime 
        : event2.startTime;
    final overlapEnd = event1.endTime.isBefore(event2.endTime) 
        ? event1.endTime 
        : event2.endTime;
    
    if (overlapStart.isBefore(overlapEnd)) {
      return overlapEnd.difference(overlapStart);
    }
    
    return Duration.zero;
  }

  /// Find next available time slot
  TimeSlot? _findNextAvailableSlot(
    CalendarEvent event,
    List<CalendarEvent> conflicts,
  ) {
    final duration = event.duration;
    final searchStart = event.endTime;
    final searchEnd = searchStart.add(const Duration(hours: 8)); // Search within 8 hours
    
    DateTime currentTime = searchStart;
    while (currentTime.add(duration).isBefore(searchEnd)) {
      final proposedSlot = TimeSlot(currentTime, currentTime.add(duration));
      
      final hasConflict = conflicts.any((conflict) =>
          proposedSlot.startTime.isBefore(conflict.endTime) &&
          proposedSlot.endTime.isAfter(conflict.startTime));
      
      if (!hasConflict) {
        return proposedSlot;
      }
      
      currentTime = currentTime.add(const Duration(minutes: 15));
    }
    
    return null;
  }

  /// Find shortened time slot that avoids conflicts
  TimeSlot? _findShortenedSlot(
    CalendarEvent event,
    List<CalendarEvent> conflicts,
  ) {
    // Try to find a slot before the first conflict
    final earliestConflict = conflicts.reduce((a, b) =>
        a.startTime.isBefore(b.startTime) ? a : b);
    
    if (event.startTime.isBefore(earliestConflict.startTime)) {
      final maxEndTime = earliestConflict.startTime;
      const minDuration = Duration(minutes: 30);
      
      if (maxEndTime.difference(event.startTime) >= minDuration) {
        return TimeSlot(event.startTime, maxEndTime);
      }
    }
    
    return null;
  }

  /// Find alternative slot for conflicting event
  TimeSlot? _findAlternativeSlot(
    CalendarEvent conflictingEvent,
    List<CalendarEvent> otherEvents,
  ) {
    final duration = conflictingEvent.duration;
    final searchStart = conflictingEvent.startTime.subtract(const Duration(hours: 2));
    final searchEnd = conflictingEvent.endTime.add(const Duration(hours: 2));
    
    DateTime currentTime = searchStart;
    while (currentTime.add(duration).isBefore(searchEnd)) {
      final proposedSlot = TimeSlot(currentTime, currentTime.add(duration));
      
      final hasConflict = otherEvents.any((event) =>
          proposedSlot.startTime.isBefore(event.endTime) &&
          proposedSlot.endTime.isAfter(event.startTime));
      
      if (!hasConflict) {
        return proposedSlot;
      }
      
      currentTime = currentTime.add(const Duration(minutes: 15));
    }
    
    return null;
  }

  /// Format time slot for display
  String _formatTimeSlot(DateTime start, DateTime end) {
    final startTime = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final endTime = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '$startTime - $endTime';
  }

  /// Get optimal scheduling suggestions for a task
  List<SchedulingSuggestion> getSchedulingSuggestions(
    TaskModel task,
    DateTime preferredDate,
    List<CalendarEvent> existingEvents, {
    Duration preferredDuration = const Duration(hours: 1),
    Duration workingHoursStart = const Duration(hours: 9),
    Duration workingHoursEnd = const Duration(hours: 17),
  }) {
    final suggestions = <SchedulingSuggestion>[];
    
    // Try preferred date first
    final preferredSlots = _findAvailableSlots(
      preferredDate,
      existingEvents,
      preferredDuration,
      workingHoursStart,
      workingHoursEnd,
    );
    
    for (final slot in preferredSlots.take(3)) {
      suggestions.add(SchedulingSuggestion(
        startTime: slot.startTime,
        endTime: slot.endTime,
        confidence: _calculateSlotConfidence(slot, task, existingEvents),
        reason: 'Available on preferred date',
      ));
    }
    
    // Try next few days if preferred date is full
    if (suggestions.length < 3) {
      for (int i = 1; i <= 7; i++) {
        final alternativeDate = preferredDate.add(Duration(days: i));
        final alternativeSlots = _findAvailableSlots(
          alternativeDate,
          existingEvents,
          preferredDuration,
          workingHoursStart,
          workingHoursEnd,
        );
        
        for (final slot in alternativeSlots.take(3 - suggestions.length)) {
          suggestions.add(SchedulingSuggestion(
            startTime: slot.startTime,
            endTime: slot.endTime,
            confidence: _calculateSlotConfidence(slot, task, existingEvents) * 0.8,
            reason: 'Available ${i == 1 ? 'tomorrow' : 'in $i days'}',
          ));
        }
        
        if (suggestions.length >= 3) break;
      }
    }
    
    return suggestions..sort((a, b) => b.confidence.compareTo(a.confidence));
  }

  /// Find available time slots for a given date
  List<TimeSlot> _findAvailableSlots(
    DateTime date,
    List<CalendarEvent> existingEvents,
    Duration duration,
    Duration workingHoursStart,
    Duration workingHoursEnd,
  ) {
    final slots = <TimeSlot>[];
    final dayStart = DateTime(date.year, date.month, date.day).add(workingHoursStart);
    final dayEnd = DateTime(date.year, date.month, date.day).add(workingHoursEnd);
    
    final dayEvents = existingEvents.where((event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return eventDate.isAtSameMomentAs(targetDate);
    }).toList()..sort((a, b) => a.startTime.compareTo(b.startTime));
    
    DateTime currentTime = dayStart;
    
    for (final event in dayEvents) {
      // Check if there's a slot before this event
      if (currentTime.add(duration).isBefore(event.startTime) ||
          currentTime.add(duration).isAtSameMomentAs(event.startTime)) {
        slots.add(TimeSlot(currentTime, currentTime.add(duration)));
      }
      
      currentTime = event.endTime.isAfter(currentTime) ? event.endTime : currentTime;
    }
    
    // Check for slot after last event
    if (currentTime.add(duration).isBefore(dayEnd) ||
        currentTime.add(duration).isAtSameMomentAs(dayEnd)) {
      slots.add(TimeSlot(currentTime, currentTime.add(duration)));
    }
    
    return slots;
  }

  /// Calculate confidence score for a time slot
  double _calculateSlotConfidence(
    TimeSlot slot,
    TaskModel task,
    List<CalendarEvent> existingEvents,
  ) {
    double confidence = 1.0;
    
    // Prefer morning slots for high priority tasks
    if (task.priority == TaskPriority.high || task.priority == TaskPriority.urgent) {
      if (slot.startTime.hour < 12) {
        confidence += 0.2;
      }
    }
    
    // Prefer afternoon slots for low priority tasks
    if (task.priority == TaskPriority.low) {
      if (slot.startTime.hour >= 14) {
        confidence += 0.1;
      }
    }
    
    // Penalize very early or very late slots
    if (slot.startTime.hour < 8 || slot.startTime.hour > 18) {
      confidence -= 0.3;
    }
    
    // Prefer slots with buffer time
    final hasBufferBefore = existingEvents.every((event) =>
        event.endTime.isBefore(slot.startTime.subtract(const Duration(minutes: 15))));
    final hasBufferAfter = existingEvents.every((event) =>
        event.startTime.isAfter(slot.endTime.add(const Duration(minutes: 15))));
    
    if (hasBufferBefore && hasBufferAfter) {
      confidence += 0.1;
    }
    
    return confidence.clamp(0.0, 1.0);
  }
}

/// Represents a group of conflicting events
class ConflictGroup {
  List<CalendarEvent> events;
  
  ConflictGroup({required this.events});
  
  DateTime get earliestStart => events.map((e) => e.startTime).reduce(
    (a, b) => a.isBefore(b) ? a : b,
  );
  
  DateTime get latestEnd => events.map((e) => e.endTime).reduce(
    (a, b) => a.isAfter(b) ? a : b,
  );
  
  Duration get totalDuration => latestEnd.difference(earliestStart);
}

/// Result of conflict checking
class ConflictCheckResult {
  final bool hasConflicts;
  final List<CalendarEvent> conflictingEvents;
  final ConflictSeverity severity;
  final List<ConflictResolution> suggestions;
  
  const ConflictCheckResult({
    required this.hasConflicts,
    required this.conflictingEvents,
    required this.severity,
    this.suggestions = const [],
  });
}

/// Severity levels for conflicts
enum ConflictSeverity {
  none,
  low,
  medium,
  high,
  critical,
}

/// Types of conflict resolution
enum ResolutionType {
  reschedule,
  shorten,
  moveConflicting,
  cancel,
}

/// Priority levels for resolution suggestions
enum ResolutionPriority {
  low,
  medium,
  high,
}

/// Conflict resolution suggestion
class ConflictResolution {
  final ResolutionType type;
  final String description;
  final DateTime? newStartTime;
  final DateTime? newEndTime;
  final String? conflictingEventId;
  final ResolutionPriority priority;
  
  const ConflictResolution({
    required this.type,
    required this.description,
    this.newStartTime,
    this.newEndTime,
    this.conflictingEventId,
    required this.priority,
  });
}

/// Time slot representation
class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  
  const TimeSlot(this.startTime, this.endTime);
  
  Duration get duration => endTime.difference(startTime);
  
  bool overlaps(TimeSlot other) {
    return startTime.isBefore(other.endTime) && endTime.isAfter(other.startTime);
  }
}

/// Scheduling suggestion for optimal task placement
class SchedulingSuggestion {
  final DateTime startTime;
  final DateTime endTime;
  final double confidence;
  final String reason;
  
  const SchedulingSuggestion({
    required this.startTime,
    required this.endTime,
    required this.confidence,
    required this.reason,
  });
  
  Duration get duration => endTime.difference(startTime);
}