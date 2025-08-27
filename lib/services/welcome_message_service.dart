import 'dart:math';

/// Service for generating dynamic welcome messages and productivity insights
class WelcomeMessageService {
  static final WelcomeMessageService _instance = WelcomeMessageService._internal();
  factory WelcomeMessageService() => _instance;
  WelcomeMessageService._internal();

  static final Random _random = Random();

  /// Collection of dynamic welcome messages
  static final List<WelcomeMessage> _welcomeMessages = [
    // Morning motivations
    WelcomeMessage(
      greeting: 'Good Morning!',
      subtitle: 'Ready to start your day?',
      timeOfDay: TimeOfDay.morning,
    ),
    WelcomeMessage(
      greeting: 'Good Morning!',
      subtitle: 'Let\'s get things done',
      timeOfDay: TimeOfDay.morning,
    ),
    WelcomeMessage(
      greeting: 'Good Morning!',
      subtitle: 'What will you accomplish today?',
      timeOfDay: TimeOfDay.morning,
    ),
    WelcomeMessage(
      greeting: 'Fresh Start, Fresh Goals',
      subtitle: 'What will you accomplish today?',
      timeOfDay: TimeOfDay.morning,
    ),
    WelcomeMessage(
      greeting: 'Dawn of Productivity',
      subtitle: 'Your future self will thank you',
      timeOfDay: TimeOfDay.morning,
    ),

    // Afternoon energy
    WelcomeMessage(
      greeting: 'Afternoon Focus Mode',
      subtitle: 'Momentum is building!',
      timeOfDay: TimeOfDay.afternoon,
    ),
    WelcomeMessage(
      greeting: 'Midday Warrior',
      subtitle: 'Half the day, double the determination',
      timeOfDay: TimeOfDay.afternoon,
    ),
    WelcomeMessage(
      greeting: 'Power Through!',
      subtitle: 'You\'re doing amazing things',
      timeOfDay: TimeOfDay.afternoon,
    ),
    WelcomeMessage(
      greeting: 'Afternoon Excellence',
      subtitle: 'Keep the productivity flowing',
      timeOfDay: TimeOfDay.afternoon,
    ),
    WelcomeMessage(
      greeting: 'Sunlit Success',
      subtitle: 'Making progress, one task at a time',
      timeOfDay: TimeOfDay.afternoon,
    ),

    // Evening wind-down
    WelcomeMessage(
      greeting: 'Evening Reflection',
      subtitle: 'Planning tomorrow\'s victories',
      timeOfDay: TimeOfDay.evening,
    ),
    WelcomeMessage(
      greeting: 'Sunset Planning',
      subtitle: 'End strong, start stronger tomorrow',
      timeOfDay: TimeOfDay.evening,
    ),
    WelcomeMessage(
      greeting: 'Twilight Organizer',
      subtitle: 'Wrapping up today\'s achievements',
      timeOfDay: TimeOfDay.evening,
    ),
    WelcomeMessage(
      greeting: 'Evening Vision',
      subtitle: 'Tomorrow\'s tasks, tonight\'s clarity',
      timeOfDay: TimeOfDay.evening,
    ),
    WelcomeMessage(
      greeting: 'Dusk Productivity',
      subtitle: 'Finishing strong and planning ahead',
      timeOfDay: TimeOfDay.evening,
    ),

    // Late night/general
    WelcomeMessage(
      greeting: 'Night Owl Mode',
      subtitle: 'Quiet hours, focused mind',
      timeOfDay: TimeOfDay.night,
    ),
    WelcomeMessage(
      greeting: 'Midnight Planner',
      subtitle: 'When inspiration strikes, capture it',
      timeOfDay: TimeOfDay.night,
    ),
    WelcomeMessage(
      greeting: 'Late Night Genius',
      subtitle: 'Great ideas don\'t follow schedules',
      timeOfDay: TimeOfDay.night,
    ),

    // General (any time)
    WelcomeMessage(
      greeting: 'Hello!',
      subtitle: 'Ready to tackle your tasks?',
      timeOfDay: TimeOfDay.any,
    ),
    WelcomeMessage(
      greeting: 'Welcome back',
      subtitle: 'What would you like to work on?',
      timeOfDay: TimeOfDay.any,
    ),
    WelcomeMessage(
      greeting: 'Let\'s get started',
      subtitle: 'Time to be productive',
      timeOfDay: TimeOfDay.any,
    ),
    WelcomeMessage(
      greeting: 'Ready to focus?',
      subtitle: 'Your tasks are waiting',
      timeOfDay: TimeOfDay.any,
    ),
  ];

  /// Get a dynamic welcome message based on time of day and context
  WelcomeMessage getWelcomeMessage({
    String? firstName,
    int? pendingTaskCount,
    int? completedToday,
    bool isFirstTimeUser = false,
  }) {
    final now = DateTime.now();
    final timeOfDay = _getTimeOfDay(now);
    final displayName = firstName ?? 'there';

    // Special cases for first-time users
    if (isFirstTimeUser) {
      return WelcomeMessage(
        greeting: firstName != null ? 'Welcome to Tasky, $firstName! [EMOJI]' : 'Welcome to Tasky! [EMOJI]',
        subtitle: 'Let\'s build amazing habits together',
        timeOfDay: TimeOfDay.any,
      );
    }

    // Use static welcome messages based on time of day
    return _getWelcomeMessageForTimeOfDay(timeOfDay, displayName);
  }

  /// Get welcome message from static list based on time of day
  WelcomeMessage _getWelcomeMessageForTimeOfDay(TimeOfDay timeOfDay, String displayName) {
    // Filter messages by time of day
    final filteredMessages = _welcomeMessages
        .where((message) => message.timeOfDay == timeOfDay || message.timeOfDay == TimeOfDay.any)
        .toList();

    // If no messages found for specific time, fall back to 'any' time messages
    if (filteredMessages.isEmpty) {
      final anyTimeMessages = _welcomeMessages.where((message) => message.timeOfDay == TimeOfDay.any).toList();
      final baseMessage = anyTimeMessages.isNotEmpty
          ? anyTimeMessages[_random.nextInt(anyTimeMessages.length)]
          : _welcomeMessages[_random.nextInt(_welcomeMessages.length)];
      return _personalizeMessage(baseMessage, displayName);
    }

    // Return random personalized message from filtered list
    final baseMessage = filteredMessages[_random.nextInt(filteredMessages.length)];
    return _personalizeMessage(baseMessage, displayName);
  }

  /// Personalize a welcome message with the user's name
  WelcomeMessage _personalizeMessage(WelcomeMessage baseMessage, String displayName) {
    // Create simple, single personalized greeting based on time of day
    String personalizedGreeting;
    switch (baseMessage.timeOfDay) {
      case TimeOfDay.morning:
        personalizedGreeting = 'Good morning, $displayName';
        break;
      case TimeOfDay.afternoon:
        personalizedGreeting = 'Good afternoon, $displayName';
        break;
      case TimeOfDay.evening:
        personalizedGreeting = 'Good evening, $displayName';
        break;
      case TimeOfDay.night:
        personalizedGreeting = 'Hello, $displayName';
        break;
      case TimeOfDay.any:
        personalizedGreeting = 'Hello, $displayName';
        break;
    }

    return WelcomeMessage(
      greeting: personalizedGreeting,
      subtitle: baseMessage.subtitle,
      timeOfDay: baseMessage.timeOfDay,
    );
  }

  /// Get smart task summary based on current task state
  String getTaskSummary({
    required int pendingTasks,
    required int completedToday,
    required int totalTasks,
  }) {
    if (totalTasks == 0) {
      return 'No tasks yet. Start by adding your first task!';
    }

    if (pendingTasks == 0) {
      return completedToday > 0
          ? 'All done for today! [EMOJI] You completed $completedToday ${completedToday == 1 ? 'task' : 'tasks'}.'
          : 'All caught up! Time to plan tomorrow.';
    }

    if (completedToday > 0) {
      return 'Great progress! $completedToday done, $pendingTasks to go.';
    }

    if (pendingTasks == 1) {
      return 'One task awaiting your attention.';
    }

    if (pendingTasks <= 3) {
      return '$pendingTasks tasks ready for action.';
    }

    if (pendingTasks <= 7) {
      return '$pendingTasks tasks on your plate. You\'ve got this!';
    }

    return '$pendingTasks tasks queued. Break them into smaller chunks?';
  }

  /// Get contextual productivity insight
  String getProductivityInsight({
    required int completedToday,
    required int completedYesterday,
    required List<String> topPriorities,
  }) {
    if (completedToday > completedYesterday && completedToday > 0) {
      return 'You\'re on fire! ${completedToday - completedYesterday} more than yesterday.';
    }

    if (completedToday == completedYesterday && completedToday > 0) {
      return 'Consistent performance! Same pace as yesterday.';
    }

    if (topPriorities.isNotEmpty) {
      return 'Focus area: ${topPriorities.first}';
    }

    if (completedToday > 5) {
      return 'Productivity champion! $completedToday tasks completed.';
    }

    if (completedToday > 0) {
      return 'Steady progress with $completedToday completions.';
    }

    return 'Fresh start! Ready to tackle new challenges.';
  }

  /// Determine time of day category
  TimeOfDay _getTimeOfDay(DateTime dateTime) {
    final hour = dateTime.hour;

    if (hour >= 5 && hour < 12) {
      return TimeOfDay.morning;
    } else if (hour >= 12 && hour < 17) {
      return TimeOfDay.afternoon;
    } else if (hour >= 17 && hour < 22) {
      return TimeOfDay.evening;
    } else {
      return TimeOfDay.night;
    }
  }
}

/// Welcome message data model
class WelcomeMessage {
  final String greeting;
  final String subtitle;
  final TimeOfDay timeOfDay;

  WelcomeMessage({
    required this.greeting,
    required this.subtitle,
    required this.timeOfDay,
  });
}

/// Time of day categories for contextual messages
enum TimeOfDay {
  morning,
  afternoon,
  evening,
  night,
  any, // Can be used at any time
}
