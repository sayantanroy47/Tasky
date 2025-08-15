import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'calendar_event.g.dart';

/// Represents a calendar event that can be associated with a task
@JsonSerializable()
class CalendarEvent extends Equatable {
  /// Unique identifier for the event
  final String id;
  
  /// Associated task ID (optional)
  final String? taskId;
  
  /// Event title
  final String title;
  
  /// Event description
  final String? description;
  
  /// Start date and time
  final DateTime startTime;
  
  /// End date and time
  final DateTime endTime;
  
  /// Whether this is an all-day event
  final bool isAllDay;
  
  /// Event color (hex string)
  final String color;
  
  /// Whether this event is recurring
  final bool isRecurring;
  
  /// Location of the event
  final String? location;
  
  /// Event attendees
  final List<String> attendees;
  
  /// Reminder times in minutes before event
  final List<int> reminders;
  
  /// Additional metadata
  final Map<String, dynamic> metadata;

  const CalendarEvent({
    required this.id,
    this.taskId,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    this.color = '#2196F3',
    this.isRecurring = false,
    this.location,
    this.attendees = const [],
    this.reminders = const [],
    this.metadata = const {},
  });

  /// Creates a new calendar event with generated ID
  factory CalendarEvent.create({
    String? taskId,
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
    bool isAllDay = false,
    String color = '#2196F3',
    bool isRecurring = false,
    String? location,
    List<String> attendees = const [],
    List<int> reminders = const [],
    Map<String, dynamic> metadata = const {},
  }) {
    return CalendarEvent(
      id: const Uuid().v4(),
      taskId: taskId,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      color: color,
      isRecurring: isRecurring,
      location: location,
      attendees: attendees,
      reminders: reminders,
      metadata: metadata,
    );
  }

  /// Creates a CalendarEvent from JSON
  factory CalendarEvent.fromJson(Map<String, dynamic> json) => 
      _$CalendarEventFromJson(json);

  /// Converts this CalendarEvent to JSON
  Map<String, dynamic> toJson() => _$CalendarEventToJson(this);

  /// Creates a copy with updated fields
  CalendarEvent copyWith({
    String? id,
    String? taskId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    String? color,
    bool? isRecurring,
    String? location,
    List<String>? attendees,
    List<int>? reminders,
    Map<String, dynamic>? metadata,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      color: color ?? this.color,
      isRecurring: isRecurring ?? this.isRecurring,
      location: location ?? this.location,
      attendees: attendees ?? this.attendees,
      reminders: reminders ?? this.reminders,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Duration of the event
  Duration get duration => endTime.difference(startTime);

  /// Whether the event is currently happening
  bool get isHappening {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Whether the event is in the past
  bool get isPast => DateTime.now().isAfter(endTime);

  /// Whether the event is in the future
  bool get isFuture => DateTime.now().isBefore(startTime);

  /// Whether the event conflicts with another event
  bool conflictsWith(CalendarEvent other) {
    return startTime.isBefore(other.endTime) && endTime.isAfter(other.startTime);
  }  @override
  List<Object?> get props => [
        id,
        taskId,
        title,
        description,
        startTime,
        endTime,
        isAllDay,
        color,
        isRecurring,
        location,
        attendees,
        reminders,
        metadata,
      ];
}