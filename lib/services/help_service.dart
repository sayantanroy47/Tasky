import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../core/theme/typography_constants.dart';

/// Service for managing help and documentation
class HelpService {
  static final HelpService _instance = HelpService._internal();
  factory HelpService() => _instance;
  HelpService._internal();

  /// Help topics with content
  final Map<String, HelpTopic> _helpTopics = {
    'getting_started': const HelpTopic(
      id: 'getting_started',
      title: 'Getting Started',
      content: '''
# Welcome to Tasky! [EMOJI]

Tasky is your AI-powered task management companion that helps you stay organized and productive.

## Key Features:
- **Voice Input**: Create tasks by speaking naturally
- **AI Parsing**: Smart task extraction from voice and text
- **Themes**: Beautiful themes including Vegeta Blue, Matrix, and Dracula IDE
- **Offline-First**: Works without internet connection
- **Smart Notifications**: Get reminded at the right time

## Quick Start:
1. Tap the + button to create your first task
2. Choose between text, voice, or speech-to-text input
3. Organize tasks with projects, tags, and priorities
4. Track your progress in the Analytics tab

Get started by creating your first task!
      ''',
      category: 'basics',
      order: 1,
    ),
    
    'voice_input': const HelpTopic(
      id: 'voice_input',
      title: 'Voice Input & Speech-to-Text',
      content: '''
# Voice Input Features [MIC]

Tasky offers three powerful ways to create tasks with your voice:

## Voice Recording
- Records audio that you can play back later
- Perfect for detailed instructions or context
- Audio is stored securely on your device

## Speech-to-Text
- Converts your speech to text automatically
- Uses AI to extract task details like due dates and priorities
- Say things like "Remind me to buy milk tomorrow at 5 PM"

## AI Parsing Examples:
- "Call mom this evening" → Creates task with evening due time
- "High priority: finish project report by Friday" → Sets high priority and due date
- "Buy groceries at the store on Main Street" → Adds location context

## Tips:
- Speak clearly and at normal speed
- Include context like "tomorrow", "next week", "urgent"
- The AI will automatically detect priorities and dates
      ''',
      category: 'features',
      order: 2,
    ),

    'themes': const HelpTopic(
      id: 'themes',
      title: 'Themes & Personalization',
      content: '''
# Personalize Your Experience

Tasky offers beautiful, creative themes to match your style:

## Available Themes:

### Vegeta Blue
- Inspired by Dragon Ball Z's Prince Vegeta
- Deep royal blues with explosive energy effects
- Angular design with dramatic animations
- Perfect for power users who like bold aesthetics

### Matrix
- Cyberpunk theme inspired by The Matrix
- Neon green code on black backgrounds
- Terminal-style typography with digital effects
- Great for developers and tech enthusiasts

### Dracula IDE
- Popular developer color scheme
- Sophisticated dark purples with syntax highlighting colors
- Elegant design with smooth animations
- Ideal for coding and professional use

## Light/Dark Modes:
- Each theme has both light and dark variants
- Automatically syncs with your system settings
- Manual override available in Settings

## How to Change Themes:
1. Go to Settings
2. Browse the Theme Gallery
3. Tap any theme to apply instantly
4. Enjoy the smooth transition!
      ''',
      category: 'customization',
      order: 3,
    ),

    'ai_features': const HelpTopic(
      id: 'ai_features',
      title: 'AI-Powered Features',
      content: '''
# Intelligent Task Management

Tasky uses advanced AI to make task management effortless:

## Natural Language Processing:
- Create tasks using everyday language
- AI extracts due dates, priorities, and context automatically
- Works with voice input and text

## Smart Parsing Examples:
- "Dentist appointment next Tuesday at 2 PM" 
  → Creates task with specific date/time
- "Urgent: Submit tax documents before March 15th"
  → High priority task with deadline
- "Weekly team meeting every Monday at 9 AM"
  → Creates recurring task

## Local AI Processing:
- Most AI features work offline
- Your data stays private on your device
- Optional cloud AI for advanced features

## Task Intelligence:
- Automatic categorization suggestions
- Smart due date recommendations
- Project and tag suggestions based on content

## Privacy First:
- Local processing means your tasks stay private
- No data sent to external servers for basic AI features
- You control what gets shared (if anything)
      ''',
      category: 'features',
      order: 4,
    ),

    'organization': const HelpTopic(
      id: 'organization',
      title: 'Organization & Productivity',
      content: '''
# Stay Organized

Tasky offers powerful organization tools to keep you productive:

## Projects:
- Group related tasks together
- Track project progress
- Set project deadlines and goals

## Tags:
- Add multiple tags to tasks for easy filtering
- Create custom tag systems (work, personal, urgent, etc.)
- Quick filtering by tags in the main view

## Priorities:
- **Low**: Nice to have, flexible timing
- **Medium**: Standard tasks, normal priority
- **High**: Important tasks, should be done soon
- **Urgent**: Critical tasks, immediate attention needed

## Smart Filtering:
- Filter by status, priority, due date
- Search across all task content
- Save custom filter combinations

## Analytics:
- Track your productivity trends
- See completion rates and patterns
- Identify your most productive times

## Recurring Tasks:
- Set tasks to repeat daily, weekly, monthly
- Complex recurrence patterns supported
- Automatic task generation
      ''',
      category: 'productivity',
      order: 5,
    ),

    'notifications': const HelpTopic(
      id: 'notifications',
      title: 'Notifications & Reminders',
      content: '''
# Smart Notifications

Never miss important tasks with Tasky's intelligent notification system:

## Notification Types:
- **Due Soon**: Reminds you before tasks are due
- **Overdue**: Alerts for missed deadlines
- **Daily Summary**: Morning overview of today's tasks
- **Achievement**: Celebrates your productivity wins

## Smart Timing:
- Notifications adapt to your usage patterns
- Quiet hours respect your schedule
- Priority-based notification urgency

## Customization:
- Choose which notifications you want
- Set custom reminder times
- Adjust notification frequency

## Settings Location:
- Go to Settings → Notifications
- Toggle individual notification types
- Set quiet hours and preferences

## Battery Optimization:
- Efficient notification scheduling
- Respects device battery settings
- Works with Do Not Disturb modes
      ''',
      category: 'features',
      order: 6,
    ),

    'troubleshooting': const HelpTopic(
      id: 'troubleshooting',
      title: 'Troubleshooting',
      content: '''
# Common Issues & Solutions [EMOJI]

## Voice Input Not Working:
1. Check microphone permissions in device settings
2. Ensure good internet connection for speech-to-text
3. Try speaking more clearly or closer to device
4. Restart the app if issues persist

## Themes Not Loading:
1. Force close and reopen the app
2. Check device storage (themes need space for assets)
3. Try switching to a different theme first
4. Clear app cache if available

## Notifications Not Appearing:
1. Check notification permissions in device settings
2. Ensure battery optimization is disabled for Tasky
3. Verify notification settings within the app
4. Check Do Not Disturb settings

## Sync Issues:
1. Check internet connection
2. Verify account credentials if using cloud sync
3. Try manual sync from Settings
4. Local data is always preserved

## Performance Issues:
1. Restart the app
2. Clear app cache/data (will preserve tasks)
3. Ensure device has sufficient storage
4. Update to latest app version

## Data Recovery:
- Tasks are stored locally on your device
- Export your data regularly from Settings
- Contact support for help with data recovery

## Still Need Help?
- Check our FAQ in the app
- Report bugs through Settings → Send Feedback
- Visit our support website for updates
      ''',
      category: 'support',
      order: 7,
    ),

    'privacy_security': const HelpTopic(
      id: 'privacy_security',
      title: 'Privacy & Security',
      content: '''
# Your Privacy Matters [EMOJI]

Tasky is designed with privacy and security as core principles:

## Local-First Architecture:
- Tasks stored locally on your device
- No cloud dependency for core features
- You own your data completely

## Data Processing:
- Basic AI processing happens on-device
- Advanced features may use encrypted cloud processing
- You choose what gets processed where

## Optional Cloud Features:
- Sync across devices (encrypted)
- Advanced AI parsing (privacy-focused providers)
- Team collaboration (end-to-end encrypted)

## Permissions:
- **Microphone**: For voice input features
- **Notifications**: For task reminders
- **Storage**: To save your tasks locally
- **Location**: For location-based tasks (optional)

## Security Features:
- Local database encryption
- Secure API communication (HTTPS only)
- No tracking or analytics by default
- Open source components where possible

## Data Control:
- Export all your data anytime
- Delete account and data completely
- No vendor lock-in
- Transparent privacy policy

## Third-Party Services:
- OpenAI API: Only if you enable advanced AI features
- Supabase: Only if you enable cloud sync
- All connections are encrypted and optional
      ''',
      category: 'privacy',
      order: 8,
    ),
  };

  /// Get all help topics
  List<HelpTopic> getAllTopics() {
    final topics = _helpTopics.values.toList();
    topics.sort((a, b) => a.order.compareTo(b.order));
    return topics;
  }

  /// Get topics by category
  List<HelpTopic> getTopicsByCategory(String category) {
    final topics = _helpTopics.values
        .where((topic) => topic.category == category)
        .toList();
    topics.sort((a, b) => a.order.compareTo(b.order));
    return topics;
  }

  /// Get specific topic by ID
  HelpTopic? getTopic(String id) {
    return _helpTopics[id];
  }

  /// Get all categories
  List<String> getCategories() {
    final categories = _helpTopics.values
        .map((topic) => topic.category)
        .toSet()
        .toList();
    
    // Define category order
    const categoryOrder = [
      'basics',
      'features', 
      'productivity',
      'customization',
      'privacy',
      'support',
    ];
    
    categories.sort((a, b) {
      final aIndex = categoryOrder.indexOf(a);
      final bIndex = categoryOrder.indexOf(b);
      return aIndex.compareTo(bIndex);
    });
    
    return categories;
  }

  /// Search help topics
  List<HelpTopic> searchTopics(String query) {
    if (query.isEmpty) return getAllTopics();
    
    final lowercaseQuery = query.toLowerCase();
    return _helpTopics.values
        .where((topic) =>
            topic.title.toLowerCase().contains(lowercaseQuery) ||
            topic.content.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  /// Get category display name
  String getCategoryDisplayName(String category) {
    switch (category) {
      case 'basics':
        return 'Getting Started';
      case 'features':
        return 'Features';
      case 'productivity':
        return 'Organization';
      case 'customization':
        return 'Themes & Settings';
      case 'privacy':
        return 'Privacy & Security';
      case 'support':
        return 'Help & Support';
      default:
        return category.toUpperCase();
    }
  }

  /// Show help topic in bottom sheet
  void showHelpTopic(BuildContext context, String topicId) {
    final topic = getTopic(topicId);
    if (topic == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => HelpTopicSheet(topic: topic),
    );
  }

  /// Show help search
  void showHelpSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: HelpSearchDelegate(this),
    );
  }
}

/// Help topic data model
class HelpTopic {
  final String id;
  final String title;
  final String content;
  final String category;
  final int order;

  const HelpTopic({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.order,
  });
}

/// Help topic bottom sheet widget
class HelpTopicSheet extends StatelessWidget {
  final HelpTopic topic;

  const HelpTopicSheet({
    super.key,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(TypographyConstants.radiusStandard),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        topic.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(PhosphorIcons.x()),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    topic.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Help search delegate
class HelpSearchDelegate extends SearchDelegate<String> {
  final HelpService helpService;

  HelpSearchDelegate(this.helpService);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(PhosphorIcons.x()),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: Icon(PhosphorIcons.arrowLeft()),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = helpService.searchTopics(query);
    
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final topic = results[index];
        return ListTile(
          title: Text(topic.title),
          subtitle: Text(
            helpService.getCategoryDisplayName(topic.category),
            style: const TextStyle(fontSize: 12),
          ),
          onTap: () {
            close(context, topic.id);
            helpService.showHelpTopic(context, topic.id);
          },
        );
      },
    );
  }
}
