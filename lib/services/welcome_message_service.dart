import 'dart:math';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
      greeting: 'Good Morning, Achiever!',
      subtitle: 'Time to turn dreams into done',
      timeOfDay: TimeOfDay.morning,
      icon: PhosphorIcons.sparkle(),
    ),
    WelcomeMessage(
      greeting: 'Rise and Grind!',
      subtitle: 'Every task is a step toward greatness',
      timeOfDay: TimeOfDay.morning,
    ),
    WelcomeMessage(
      greeting: 'Morning, Taskmaster!',
      subtitle: 'Ready to conquer your day?',
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
      icon: PhosphorIcons.rocket(),
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
      icon: PhosphorIcons.sun(),
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
      icon: PhosphorIcons.moon(),
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
    
    // Motivational (any time)
    WelcomeMessage(
      greeting: 'Progress Pioneer',
      subtitle: 'Every small step counts',
      timeOfDay: TimeOfDay.any,
    ),
    WelcomeMessage(
      greeting: 'Task Champion',
      subtitle: 'You\'ve got this!',
      timeOfDay: TimeOfDay.any,
      icon: PhosphorIcons.barbell(),
    ),
    WelcomeMessage(
      greeting: 'Productivity Legend',
      subtitle: 'Making things happen, one task at a time',
      timeOfDay: TimeOfDay.any,
    ),
    WelcomeMessage(
      greeting: 'Goal Getter',
      subtitle: 'Turning plans into progress',
      timeOfDay: TimeOfDay.any,
    ),
    WelcomeMessage(
      greeting: 'Success Architect',
      subtitle: 'Building your best life, daily',
      timeOfDay: TimeOfDay.any,
    ),
    WelcomeMessage(
      greeting: 'Achievement Unlocked',
      subtitle: 'Ready for the next level?',
      timeOfDay: TimeOfDay.any,
    ),
    WelcomeMessage(
      greeting: 'Focus Commander',
      subtitle: 'Directing energy toward excellence',
      timeOfDay: TimeOfDay.any,
    ),
    WelcomeMessage(
      greeting: 'Momentum Master',
      subtitle: 'Keeping the productivity rolling',
      timeOfDay: TimeOfDay.any,
    ),
    WelcomeMessage(
      greeting: 'Efficiency Expert',
      subtitle: 'Smart work meets hard work',
      timeOfDay: TimeOfDay.any,
    ),
    WelcomeMessage(
      greeting: 'Time Wizard',
      subtitle: 'Making every moment count',
      timeOfDay: TimeOfDay.any,
    ),
    WelcomeMessage(
      greeting: 'Dream Builder',
      subtitle: 'One task closer to your goals',
      timeOfDay: TimeOfDay.any,
    ),
    WelcomeMessage(
      greeting: 'Victory Awaits',
      subtitle: 'Your dedicated effort will pay off',
      timeOfDay: TimeOfDay.any,
    ),
  ];

  /// Get a dynamic welcome message based on time of day and context
  WelcomeMessage getWelcomeMessage({
    int? pendingTaskCount,
    int? completedToday,
    bool isFirstTimeUser = false,
  }) {
    final now = DateTime.now();
    final timeOfDay = _getTimeOfDay(now);
    
    // Filter messages by time of day
    final relevantMessages = _welcomeMessages.where((message) =>
      message.timeOfDay == timeOfDay || message.timeOfDay == TimeOfDay.any
    ).toList();
    
    // Special cases for first-time users or specific contexts
    if (isFirstTimeUser) {
      return WelcomeMessage(
        greeting: 'Welcome to Tasky! 🎉',
        subtitle: 'Let\'s build amazing habits together',
        timeOfDay: TimeOfDay.any,
      );
    }
    
    // Return random message from relevant ones
    return relevantMessages[_random.nextInt(relevantMessages.length)];
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
        ? 'All done for today! 🎉 You completed $completedToday ${completedToday == 1 ? 'task' : 'tasks'}.'
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
  final IconData? icon;
  
  WelcomeMessage({
    required this.greeting,
    required this.subtitle,
    required this.timeOfDay,
    this.icon,
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


