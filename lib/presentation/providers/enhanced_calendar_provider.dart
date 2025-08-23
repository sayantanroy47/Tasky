import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/calendar_event_extensions.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../services/calendar_service.dart';
import '../../core/providers/core_providers.dart';

/// Enhanced calendar view mode
enum CalendarViewMode { month, week, day }

/// Enhanced calendar state that integrates tasks and events
class EnhancedCalendarState {
  final DateTime selectedDate;
  final DateTime focusedDate;
  final CalendarViewMode viewMode;
  final List<CalendarEvent> events;
  final List<TaskModel> tasksForSelectedDate;
  final List<TaskModel> allTasks;
  final CalendarView calendarFormat;
  final bool isLoading;
  final bool isViewChanging;
  final String? errorMessage;
  final DateTime lastUpdated;

  EnhancedCalendarState({
    required this.selectedDate,
    required this.focusedDate,
    this.viewMode = CalendarViewMode.month,
    this.events = const [],
    this.tasksForSelectedDate = const [],
    this.allTasks = const [],
    this.calendarFormat = CalendarView.month,
    this.isLoading = false,
    this.isViewChanging = false,
    this.errorMessage,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  EnhancedCalendarState copyWith({
    DateTime? selectedDate,
    DateTime? focusedDate,
    CalendarViewMode? viewMode,
    List<CalendarEvent>? events,
    List<TaskModel>? tasksForSelectedDate,
    List<TaskModel>? allTasks,
    CalendarView? calendarFormat,
    bool? isLoading,
    bool? isViewChanging,
    String? errorMessage,
    bool clearError = false,
    bool updateTimestamp = true,
  }) {
    return EnhancedCalendarState(
      selectedDate: selectedDate ?? this.selectedDate,
      focusedDate: focusedDate ?? this.focusedDate,
      viewMode: viewMode ?? this.viewMode,
      events: events ?? this.events,
      tasksForSelectedDate: tasksForSelectedDate ?? this.tasksForSelectedDate,
      allTasks: allTasks ?? this.allTasks,
      calendarFormat: calendarFormat ?? this.calendarFormat,
      isLoading: isLoading ?? this.isLoading,
      isViewChanging: isViewChanging ?? this.isViewChanging,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastUpdated: updateTimestamp ? DateTime.now() : lastUpdated,
    );
  }
  
  /// Check if state has been recently updated to prevent unnecessary rebuilds
  bool get wasRecentlyUpdated {
    return DateTime.now().difference(lastUpdated).inMilliseconds < 100;
  }
  
  /// Check if calendar is in a stable state (not loading or changing views)
  bool get isStable {
    return !isLoading && !isViewChanging && errorMessage == null;
  }
}

/// Enhanced calendar notifier that integrates tasks and calendar events
class EnhancedCalendarNotifier extends StateNotifier<EnhancedCalendarState> {
  final CalendarService _calendarService;
  final Ref _ref;
  
  /// Check if notifier is still active (simple check)
  bool get _isActive => true; // Simplified for now

  EnhancedCalendarNotifier(this._calendarService, this._ref) 
    : super(EnhancedCalendarState(
        selectedDate: DateTime.now(),
        focusedDate: DateTime.now(),
        lastUpdated: DateTime.now(),
      )) {
    _initialize();
  }

  /// Initialize the calendar service and load data
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _loadAllData();
      state = state.copyWith(isLoading: false, errorMessage: null);
    } catch (error) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: error.toString(),
      );
    }
  }

  /// Load all tasks and events
  Future<void> _loadAllData() async {
    final taskRepository = _ref.read(taskRepositoryProvider);
    final allTasks = await taskRepository.getAllTasks();
    final events = _calendarService.getAllEvents();
    final tasksForDate = _getTasksForDate(allTasks, state.selectedDate);

    state = state.copyWith(
      allTasks: allTasks,
      events: events,
      tasksForSelectedDate: tasksForDate,
    );
  }

  /// Get tasks for a specific date
  List<TaskModel> _getTasksForDate(List<TaskModel> tasks, DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return tasks.where((task) {
      if (task.dueDate == null) return false;
      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      return taskDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  /// Select a date and load tasks for that date with validation
  void selectDate(DateTime date) {
    // Prevent redundant updates if same date is selected
    if (state.selectedDate.day == date.day && 
        state.selectedDate.month == date.month && 
        state.selectedDate.year == date.year) {
      return;
    }
    
    final tasksForDate = _getTasksForDate(state.allTasks, date);
    
    state = state.copyWith(
      selectedDate: date,
      tasksForSelectedDate: tasksForDate,
    );
  }

  /// Change focused date (for navigation) with debouncing
  DateTime? _lastFocusedUpdate;
  void changeFocusedDate(DateTime date) {
    // Debounce rapid updates to prevent performance issues and duplicate keys
    final now = DateTime.now();
    if (_lastFocusedUpdate != null && 
        now.difference(_lastFocusedUpdate!).inMilliseconds < 50) {
      return;
    }
    
    // Safety check to prevent duplicate updates
    if (state.focusedDate.day != date.day || 
        state.focusedDate.month != date.month || 
        state.focusedDate.year != date.year) {
      _lastFocusedUpdate = now;
      state = state.copyWith(focusedDate: date);
    }
  }

  /// Change view mode with proper synchronization and error prevention
  void changeViewMode(CalendarViewMode mode) {
    // Prevent unnecessary state updates if mode is already selected
    if (state.viewMode == mode) return;
    
    // Prevent rapid view changes if one is already in progress
    if (state.isViewChanging) return;
    
    try {
      // Set view changing state to prevent conflicts
      state = state.copyWith(
        isViewChanging: true,
        clearError: true,
      );
      
      // Map CalendarViewMode to CalendarView for consistency
      CalendarView format;
      switch (mode) {
        case CalendarViewMode.month:
          format = CalendarView.month;
          break;
        case CalendarViewMode.week:
          format = CalendarView.week;
          break;
        case CalendarViewMode.day:
          format = CalendarView.day;
          break;
      }
      
      // Update both viewMode and calendarFormat atomically after brief delay
      Future.microtask(() {
        if (_isActive) {
          state = state.copyWith(
            viewMode: mode,
            calendarFormat: format,
            isLoading: false,
            isViewChanging: false,
            clearError: true,
          );
        }
      });
    } catch (e) {
      state = state.copyWith(
        isViewChanging: false,
        errorMessage: 'Failed to change view: $e',
      );
    }
  }

  /// Go to today
  void goToToday() {
    final today = DateTime.now();
    final todayTasks = _getTasksForDate(state.allTasks, today);
    
    state = state.copyWith(
      selectedDate: today,
      focusedDate: today,
      tasksForSelectedDate: todayTasks,
    );
  }

  /// Create task for specific date
  Future<bool> createTaskForDate(TaskModel task) async {
    try {
      final taskRepository = _ref.read(taskRepositoryProvider);
      await taskRepository.updateTask(task); // Use updateTask for inserts too
      
      // Create corresponding calendar event if task has a due date
      if (task.dueDate != null) {
        final event = CalendarEventTaskExtension.fromTask(task);
        await _calendarService.addEvent(event);
      }
      
      await _loadAllData();
      return true;
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
      return false;
    }
  }

  /// Update task and sync to calendar
  Future<bool> updateTask(TaskModel task) async {
    try {
      final taskRepository = _ref.read(taskRepositoryProvider);
      await taskRepository.updateTask(task);
      
      // Update corresponding calendar event if task has a due date
      if (task.dueDate != null) {
        final event = CalendarEventTaskExtension.fromTask(task);
        await _calendarService.updateEvent(event);
      }
      
      await _loadAllData();
      return true;
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
      return false;
    }
  }

  /// Complete task and update calendar
  Future<bool> completeTask(String taskId) async {
    try {
      final taskRepository = _ref.read(taskRepositoryProvider);
      final task = await taskRepository.getTaskById(taskId);
      
      if (task != null) {
        final completedTask = task.markCompleted();
        await taskRepository.updateTask(completedTask);
        
        // Update calendar event to reflect completion
        if (completedTask.dueDate != null) {
          final event = CalendarEventTaskExtension.fromTask(completedTask);
          await _calendarService.updateEvent(event);
        }
        
        await _loadAllData();
        return true;
      }
      return false;
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
      return false;
    }
  }

  /// Add event to calendar
  Future<bool> addEvent(CalendarEvent event) async {
    try {
      await _calendarService.addEvent(event);
      await _loadAllData();
      return true;
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
      return false;
    }
  }

  /// Get tasks with due dates for calendar markers
  Map<DateTime, List<TaskModel>> getTasksByDate() {
    final Map<DateTime, List<TaskModel>> tasksByDate = {};
    
    for (final task in state.allTasks) {
      if (task.dueDate != null) {
        final date = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        
        if (tasksByDate[date] == null) {
          tasksByDate[date] = [];
        }
        tasksByDate[date]!.add(task);
      }
    }
    
    return tasksByDate;
  }

  /// Get events for calendar markers
  Map<DateTime, List<CalendarEvent>> getEventsByDate() {
    final Map<DateTime, List<CalendarEvent>> eventsByDate = {};
    
    for (final event in state.events) {
      final date = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      
      if (eventsByDate[date] == null) {
        eventsByDate[date] = [];
      }
      eventsByDate[date]!.add(event);
    }
    
    return eventsByDate;
  }

  /// Force refresh all data
  Future<void> refresh() async {
    await _loadAllData();
  }

}

/// Enhanced calendar provider
final enhancedCalendarProvider = StateNotifierProvider<EnhancedCalendarNotifier, EnhancedCalendarState>((ref) {
  final calendarService = ref.read(calendarServiceProvider);
  return EnhancedCalendarNotifier(calendarService, ref);
});

/// Selected date tasks provider
final selectedDateTasksProvider = Provider<List<TaskModel>>((ref) {
  final calendarState = ref.watch(enhancedCalendarProvider);
  return calendarState.tasksForSelectedDate;
});

/// Today's tasks provider
final todaysTasksProvider = Provider<List<TaskModel>>((ref) {
  final calendarState = ref.watch(enhancedCalendarProvider);
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  
  return calendarState.allTasks.where((task) {
    if (task.dueDate == null) return false;
    final taskDate = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
    );
    return taskDate.isAtSameMomentAs(todayDate);
  }).toList();
});

/// Upcoming tasks provider (next 7 days)
final upcomingTasksProvider = Provider<List<TaskModel>>((ref) {
  final calendarState = ref.watch(enhancedCalendarProvider);
  final now = DateTime.now();
  final nextWeek = now.add(const Duration(days: 7));
  
  return calendarState.allTasks.where((task) {
    if (task.dueDate == null) return false;
    return task.dueDate!.isAfter(now) && task.dueDate!.isBefore(nextWeek);
  }).toList();
});

/// Overdue tasks provider
final overdueTasksProvider = Provider<List<TaskModel>>((ref) {
  final calendarState = ref.watch(enhancedCalendarProvider);
  final now = DateTime.now();
  
  return calendarState.allTasks.where((task) {
    if (task.dueDate == null) return false;
    return task.dueDate!.isBefore(now) && task.status != TaskStatus.completed;
  }).toList();
});

/// Calendar statistics provider
final calendarStatsProvider = Provider<CalendarStats>((ref) {
  final todaysTasks = ref.watch(todaysTasksProvider);
  final upcomingTasks = ref.watch(upcomingTasksProvider);
  final overdueTasks = ref.watch(overdueTasksProvider);
  final calendarState = ref.watch(enhancedCalendarProvider);
  
  return CalendarStats(
    totalTasks: calendarState.allTasks.length,
    todaysTasks: todaysTasks.length,
    upcomingTasks: upcomingTasks.length,
    overdueTasks: overdueTasks.length,
    completedTasks: calendarState.allTasks.where((t) => t.status == TaskStatus.completed).length,
    totalEvents: calendarState.events.length,
  );
});

/// Calendar statistics data class
class CalendarStats {
  final int totalTasks;
  final int todaysTasks;
  final int upcomingTasks;
  final int overdueTasks;
  final int completedTasks;
  final int totalEvents;

  const CalendarStats({
    required this.totalTasks,
    required this.todaysTasks,
    required this.upcomingTasks,
    required this.overdueTasks,
    required this.completedTasks,
    required this.totalEvents,
  });
}