import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/task_model.dart';
import '../../services/calendar_service.dart';

/// Calendar view mode
enum CalendarViewMode { month, week, day }

/// Calendar state
class CalendarState {
  final DateTime selectedDate;
  final DateTime focusedDate;
  final CalendarViewMode viewMode;
  final List<CalendarEvent> events;
  final List<CalendarEvent> selectedDateEvents;
  final CalendarFormat calendarFormat;

  const CalendarState({
    required this.selectedDate,
    required this.focusedDate,
    this.viewMode = CalendarViewMode.month,
    this.events = const [],
    this.selectedDateEvents = const [],
    this.calendarFormat = CalendarFormat.month,
  });

  CalendarState copyWith({
    DateTime? selectedDate,
    DateTime? focusedDate,
    CalendarViewMode? viewMode,
    List<CalendarEvent>? events,
    List<CalendarEvent>? selectedDateEvents,
    CalendarFormat? calendarFormat,
  }) {
    return CalendarState(
      selectedDate: selectedDate ?? this.selectedDate,
      focusedDate: focusedDate ?? this.focusedDate,
      viewMode: viewMode ?? this.viewMode,
      events: events ?? this.events,
      selectedDateEvents: selectedDateEvents ?? this.selectedDateEvents,
      calendarFormat: calendarFormat ?? this.calendarFormat,
    );
  }
}

/// Calendar state notifier
class CalendarNotifier extends StateNotifier<CalendarState> {
  final CalendarService _calendarService;

  CalendarNotifier(this._calendarService) : super(CalendarState(
    selectedDate: DateTime.now(),
    focusedDate: DateTime.now(),
  )) {
    _loadEvents();
  }

  /// Load all events
  void _loadEvents() {
    final events = _calendarService.getAllEvents();
    final selectedDateEvents = _calendarService.getEventsForDate(state.selectedDate);
    
    state = state.copyWith(
      events: events,
      selectedDateEvents: selectedDateEvents,
    );
  }

  /// Select a date
  void selectDate(DateTime date) {
    final selectedDateEvents = _calendarService.getEventsForDate(date);
    
    state = state.copyWith(
      selectedDate: date,
      selectedDateEvents: selectedDateEvents,
    );
  }

  /// Change focused date (for navigation)
  void changeFocusedDate(DateTime date) {
    state = state.copyWith(focusedDate: date);
  }

  /// Change view mode
  void changeViewMode(CalendarViewMode mode) {
    CalendarFormat format;
    switch (mode) {
      case CalendarViewMode.month:
        format = CalendarFormat.month;
        break;
      case CalendarViewMode.week:
        format = CalendarFormat.week;
        break;
      case CalendarViewMode.day:
        format = CalendarFormat.week; // Use week format for day view
        break;
    }
    
    state = state.copyWith(
      viewMode: mode,
      calendarFormat: format,
    );
  }

  /// Go to today
  void goToToday() {
    final today = DateTime.now();
    final todayEvents = _calendarService.getEventsForDate(today);
    
    state = state.copyWith(
      selectedDate: today,
      focusedDate: today,
      selectedDateEvents: todayEvents,
    );
  }

  /// Add event
  Future<void> addEvent(CalendarEvent event) async {
    await _calendarService.addEvent(event);
    _loadEvents();
  }

  /// Update event
  Future<void> updateEvent(CalendarEvent event) async {
    await _calendarService.updateEvent(event);
    _loadEvents();
  }

  /// Delete event
  Future<void> deleteEvent(String eventId) async {
    await _calendarService.deleteEvent(eventId);
    _loadEvents();
  }

  /// Reschedule event
  Future<bool> rescheduleEvent(String eventId, DateTime newStartTime, DateTime newEndTime) async {
    final success = await _calendarService.rescheduleEvent(eventId, newStartTime, newEndTime);
    if (success) {
      _loadEvents();
    }
    return success;
  }

  /// Get events for a specific date
  List<CalendarEvent> getEventsForDate(DateTime date) {
    return _calendarService.getEventsForDate(date);
  }

  /// Get suggested time slots for scheduling
  List<TimeSlot> getSuggestedTimeSlots(DateTime date, {Duration? duration}) {
    return _calendarService.getSuggestedTimeSlots(
      // This would need a task parameter in real implementation
      // For now, we'll create a dummy task
      TaskModel.create(title: 'Dummy Task'),
      date,
      duration: duration ?? const Duration(hours: 1),
    );
  }
}

/// Calendar provider
final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  final calendarService = ref.read(calendarServiceProvider);
  return CalendarNotifier(calendarService);
});

/// Selected date events provider
final selectedDateEventsProvider = Provider<List<CalendarEvent>>((ref) {
  final calendarState = ref.watch(calendarProvider);
  return calendarState.selectedDateEvents;
});

/// Today's events provider
final todaysEventsProvider = Provider<List<CalendarEvent>>((ref) {
  final calendarService = ref.read(calendarServiceProvider);
  return calendarService.getTodaysEvents();
});

/// Upcoming events provider
final upcomingEventsProvider = Provider<List<CalendarEvent>>((ref) {
  final calendarService = ref.read(calendarServiceProvider);
  return calendarService.getUpcomingEvents();
});

/// Events grouped by date provider
final eventsGroupedByDateProvider = Provider<Map<DateTime, List<CalendarEvent>>>((ref) {
  final calendarService = ref.read(calendarServiceProvider);
  return calendarService.getEventsGroupedByDate();
});