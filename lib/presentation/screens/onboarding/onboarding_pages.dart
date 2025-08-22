import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Onboarding page data model
class OnboardingPageData {
  final String title;
  final String description;
  final IconData icon;
  final List<String> highlights;
  final Color? accentColor;

  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    this.highlights = const [],
    this.accentColor,
  });
}

/// Onboarding pages content
class OnboardingPages {
  static final List<OnboardingPageData> pages = [
    OnboardingPageData(
      title: 'Welcome to Tasky',
      description: 'Your intelligent task management companion with beautiful glassmorphism design and powerful AI features.',
      icon: PhosphorIcons.rocket(),
      highlights: [
        'Beautiful glassmorphism interface',
        'AI-powered task creation',
        'Voice-to-text support',
        'Smart notifications',
      ],
      accentColor: Colors.blue,
    ),
    OnboardingPageData(
      title: 'Create Tasks Effortlessly',
      description: 'Create tasks using multiple methods - manual entry, voice commands, or AI-powered natural language processing.',
      icon: PhosphorIcons.plus(),
      highlights: [
        'Manual task creation with rich details',
        'Voice-to-text for quick entry',
        'AI understands natural language',
        'Smart date and priority detection',
      ],
      accentColor: Colors.green,
    ),
    OnboardingPageData(
      title: 'Stay Organized',
      description: 'Organize your tasks with priorities, due dates, categories, and dependencies to stay on top of everything.',
      icon: PhosphorIcons.package(),
      highlights: [
        'Priority levels and color coding',
        'Due dates and reminders',
        'Task dependencies and subtasks',
        'Project and category grouping',
      ],
      accentColor: Colors.orange,
    ),
    OnboardingPageData(
      title: 'Smart Notifications',
      description: 'Never miss important tasks with intelligent notifications that adapt to your schedule and preferences.',
      icon: PhosphorIcons.bell(),
      highlights: [
        'Location-based reminders',
        'Smart timing suggestions',
        'Customizable notification styles',
        'Do not disturb integration',
      ],
      accentColor: Colors.purple,
    ),
    OnboardingPageData(
      title: 'Powerful Analytics',
      description: 'Track your productivity with detailed analytics and insights to help you improve your task management.',
      icon: PhosphorIcons.chartBar(),
      highlights: [
        'Completion rate tracking',
        'Productivity trends',
        'Time estimation insights',
        'Goal achievement metrics',
      ],
      accentColor: Colors.teal,
    ),
    OnboardingPageData(
      title: 'Sync Everywhere',
      description: 'Your tasks sync seamlessly across all your devices with offline support and cloud backup.',
      icon: PhosphorIcons.arrowsClockwise(),
      highlights: [
        'Cross-device synchronization',
        'Offline mode support',
        'Automatic cloud backup',
        'Real-time collaboration',
      ],
      accentColor: Colors.indigo,
    ),
  ];

  /// Get page data by index
  static OnboardingPageData? getPage(int index) {
    if (index >= 0 && index < pages.length) {
      return pages[index];
    }
    return null;
  }

  /// Get total number of pages
  static int get pageCount => pages.length;

  /// Get page titles for navigation
  static List<String> get pageTitles => pages.map((page) => page.title).toList();
}

/// Onboarding completion tracking
class OnboardingProgress {
  final int currentPage;
  final bool isCompleted;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<String, bool> featuresSeen;

  const OnboardingProgress({
    this.currentPage = 0,
    this.isCompleted = false,
    this.startedAt,
    this.completedAt,
    this.featuresSeen = const {},
  });

  OnboardingProgress copyWith({
    int? currentPage,
    bool? isCompleted,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, bool>? featuresSeen,
  }) {
    return OnboardingProgress(
      currentPage: currentPage ?? this.currentPage,
      isCompleted: isCompleted ?? this.isCompleted,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      featuresSeen: featuresSeen ?? this.featuresSeen,
    );
  }

  /// Calculate completion percentage
  double get completionPercentage {
    if (isCompleted) return 1.0;
    return currentPage / OnboardingPages.pageCount;
  }

  /// Get duration of onboarding session
  Duration? get sessionDuration {
    if (startedAt == null) return null;
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt!);
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'isCompleted': isCompleted,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'featuresSeen': featuresSeen,
    };
  }

  factory OnboardingProgress.fromJson(Map<String, dynamic> json) {
    return OnboardingProgress(
      currentPage: json['currentPage'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt']) 
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      featuresSeen: Map<String, bool>.from(json['featuresSeen'] ?? {}),
    );
  }
}

/// Interactive onboarding tutorials for specific features
class FeatureTutorial {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<TutorialStep> steps;
  final Duration estimatedDuration;
  final List<String> prerequisites;

  const FeatureTutorial({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.steps,
    required this.estimatedDuration,
    this.prerequisites = const [],
  });
}

/// Individual tutorial step
class TutorialStep {
  final String title;
  final String description;
  final String? targetWidget;
  final IconData? icon;
  final String? illustration;
  final TutorialAction? action;

  const TutorialStep({
    required this.title,
    required this.description,
    this.targetWidget,
    this.icon,
    this.illustration,
    this.action,
  });
}

/// Tutorial action types
enum TutorialAction {
  tap,
  longPress,
  swipe,
  pinch,
  none,
}

/// Available feature tutorials
class FeatureTutorials {
  static final List<FeatureTutorial> tutorials = [
    FeatureTutorial(
      id: 'voice_creation',
      title: 'Voice Task Creation',
      description: 'Learn how to create tasks using voice commands',
      icon: PhosphorIcons.microphone(),
      estimatedDuration: Duration(minutes: 2),
      steps: [
        TutorialStep(
          title: 'Find the Voice Button',
          description: 'Look for the microphone icon in the task creation menu',
          targetWidget: 'voice_creation_button',
          icon: PhosphorIcons.microphone(),
          action: TutorialAction.tap,
        ),
        TutorialStep(
          title: 'Speak Your Task',
          description: 'Say something like "Create a task to call mom tomorrow at 3 PM"',
          icon: PhosphorIcons.microphone(),
          action: TutorialAction.none,
        ),
        TutorialStep(
          title: 'Review and Save',
          description: 'Check the AI-generated task details and make any adjustments',
          targetWidget: 'task_review_dialog',
          icon: PhosphorIcons.pencil(),
          action: TutorialAction.tap,
        ),
      ],
    ),
    FeatureTutorial(
      id: 'task_management',
      title: 'Task Management',
      description: 'Master the basics of managing your tasks',
      icon: PhosphorIcons.checkSquare(),
      estimatedDuration: Duration(minutes: 3),
      steps: [
        TutorialStep(
          title: 'Complete a Task',
          description: 'Tap the checkbox or swipe right to mark a task as complete',
          targetWidget: 'task_card',
          icon: PhosphorIcons.checkCircle(),
          action: TutorialAction.tap,
        ),
        TutorialStep(
          title: 'Edit Task Details',
          description: 'Long press on a task to see editing options',
          targetWidget: 'task_card',
          icon: PhosphorIcons.pencil(),
          action: TutorialAction.longPress,
        ),
        TutorialStep(
          title: 'Delete or Archive',
          description: 'Swipe left on a task to reveal deletion options',
          targetWidget: 'task_card',
          icon: PhosphorIcons.trash(),
          action: TutorialAction.swipe,
        ),
      ],
    ),
    FeatureTutorial(
      id: 'smart_features',
      title: 'Smart Features',
      description: 'Discover AI-powered productivity features',
      icon: PhosphorIcons.sparkle(),
      estimatedDuration: Duration(minutes: 4),
      steps: [
        TutorialStep(
          title: 'Smart Scheduling',
          description: 'Let AI suggest optimal times for your tasks',
          icon: PhosphorIcons.clock(),
          action: TutorialAction.none,
        ),
        TutorialStep(
          title: 'Natural Language',
          description: 'Create tasks using everyday language',
          icon: PhosphorIcons.chatCircle(),
          action: TutorialAction.none,
        ),
        TutorialStep(
          title: 'Productivity Insights',
          description: 'Get personalized tips to improve your productivity',
          targetWidget: 'analytics_page',
          icon: PhosphorIcons.chartLine(),
          action: TutorialAction.tap,
        ),
      ],
    ),
  ];

  static FeatureTutorial? getTutorial(String id) {
    try {
      return tutorials.firstWhere((tutorial) => tutorial.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<FeatureTutorial> getAvailableTutorials(List<String> completedTutorials) {
    return tutorials.where((tutorial) {
      // Check if prerequisites are met
      final prerequisitesMet = tutorial.prerequisites.every((prereq) => 
          completedTutorials.contains(prereq));
      
      // Check if tutorial is not already completed
      final notCompleted = !completedTutorials.contains(tutorial.id);
      
      return prerequisitesMet && notCompleted;
    }).toList();
  }
}

/// Onboarding configuration and settings
class OnboardingConfig {
  static const bool showOnFirstLaunch = true;
  static const bool allowSkipping = true;
  static const Duration autoAdvanceDelay = Duration(seconds: 10);
  static const bool trackAnalytics = true;
  static const bool showProgressIndicators = true;
  static const bool enableHapticFeedback = true;
  
  /// Feature introduction timing
  static const Map<String, int> featureIntroductionSchedule = {
    'voice_creation': 1, // Show after 1 task created
    'smart_notifications': 5, // Show after 5 tasks created
    'analytics': 20, // Show after 20 tasks created
    'advanced_features': 50, // Show after 50 tasks created
  };

  /// Tips and hints for contextual help
  static const Map<String, String> contextualHints = {
    'empty_task_list': 'Tap the + button to create your first task!',
    'task_completed': 'Great job! You can undo this by tapping the task again.',
    'first_voice_task': 'Try using voice input for even faster task creation.',
    'productivity_milestone': 'You\'re on a roll! Check out your analytics to see your progress.',
    'weekend_reminder': 'Don\'t forget to plan for the weekend!',
  };

  /// Achievement unlocks during onboarding
  static const Map<String, String> onboardingAchievements = {
    'onboarding_completed': 'Tutorial Master',
    'first_task_created': 'Getting Started',
    'voice_task_created': 'Voice Commander',
    'task_completed': 'Task Crusher',
    'smart_feature_used': 'AI Explorer',
  };
}


