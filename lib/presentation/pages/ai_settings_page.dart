import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/glassmorphism_container.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/theme_background_widget.dart';
import '../../core/theme/typography_constants.dart';
import '../../services/ai/ai_task_parsing_service.dart';
import '../widgets/ai_service_selector.dart';
import '../widgets/ai_privacy_controls.dart';
import '../widgets/ai_usage_statistics.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Settings page for AI task parsing configuration and privacy controls
class AISettingsPage extends ConsumerStatefulWidget {
  const AISettingsPage({super.key});
  @override
  ConsumerState<AISettingsPage> createState() => _AISettingsPageState();
}

class _AISettingsPageState extends ConsumerState<AISettingsPage> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watch(aiParsingConfigProvider);
    final configNotifier = ref.read(aiParsingConfigProvider.notifier);

    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: StandardizedAppBar(title: 'AI Settings',
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: kToolbarHeight + 8,
            left: 16.0,
            right: 16.0,
            bottom: 16.0,
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Parsing Toggle
            GlassmorphismContainer(
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.brain(),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI Task Parsing',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use AI to automatically extract task details from natural language',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Enable AI Parsing'),
                      subtitle: Text(
                        config.enabled
                            ? 'AI will help parse your tasks'
                            : 'Only local parsing will be used',
                      ),
                      value: config.enabled,
                      onChanged: (value) {
                        configNotifier.setEnabled(value);
                      },
                    ),
                  ],
                ),
            ),

            SizedBox(height: 16),

            // AI Service Selection
            if (config.enabled) ...[
              const AIServiceSelector(),
              const SizedBox(height: 16),
            ],

            // Auto-Apply Settings
            GlassmorphismContainer(
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.sparkle(),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Auto-Apply Settings',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose which AI suggestions to apply automatically',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Auto-apply Tags'),
                      subtitle: const Text('Automatically add suggested tags to tasks'),
                      value: config.autoApplyTags,
                      onChanged: config.enabled
                          ? (value) => configNotifier.setAutoApplyTags(value)
                          : null,
                    ),
                    SwitchListTile(
                      title: const Text('Auto-apply Priority'),
                      subtitle: const Text('Automatically set task priority from text'),
                      value: config.autoApplyPriority,
                      onChanged: config.enabled
                          ? (value) => configNotifier.setAutoApplyPriority(value)
                          : null,
                    ),
                    SwitchListTile(
                      title: const Text('Auto-apply Due Date'),
                      subtitle: const Text('Automatically set due dates from text'),
                      value: config.autoApplyDueDate,
                      onChanged: config.enabled
                          ? (value) => configNotifier.setAutoApplyDueDate(value)
                          : null,
                    ),
                  ],
                ),
            ),

            const SizedBox(height: 16),

            // Display Settings
            GlassmorphismContainer(
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.eye(),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Display Settings',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Show Confidence Scores'),
                      subtitle: const Text('Display AI confidence levels for parsed tasks'),
                      value: config.showConfidence,
                      onChanged: config.enabled
                          ? (value) => configNotifier.setShowConfidence(value)
                          : null,
                    ),
                  ],
                ),
            ),

            const SizedBox(height: 16),

            // Privacy Controls
            const AIPrivacyControls(),

            const SizedBox(height: 16),

            // Usage Statistics
            if (config.enabled) ...[
              const AIUsageStatistics(),
              const SizedBox(height: 16),
            ],

            // Help and Information
            GlassmorphismContainer(
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.question(),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Help & Information',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: Icon(PhosphorIcons.info()),
                      title: const Text('How AI Parsing Works'),
                      subtitle: const Text('Learn about AI task parsing features'),
                      trailing: Icon(PhosphorIcons.caretRight()),
                      onTap: () => _showHelpDialog(context),
                    ),
                    ListTile(
                      leading: Icon(PhosphorIcons.shieldWarning()),
                      title: const Text('Privacy Policy'),
                      subtitle: const Text('View our AI data handling policy'),
                      trailing: Icon(PhosphorIcons.caretRight()),
                      onTap: () => _showPrivacyDialog(context),
                    ),
                  ],
                ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How AI Parsing Works'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'AI task parsing helps you create tasks faster by understanding natural language input.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Features:'),
              SizedBox(height: 8),
              Text('• Extracts task titles and descriptions'),
              Text('• Identifies due dates from phrases like "tomorrow" or "next week"'),
              Text('• Determines priority from words like "urgent" or "important"'),
              Text('• Suggests relevant tags based on content'),
              Text('• Breaks down complex tasks into subtasks'),
              SizedBox(height: 16),
              Text(
                'Example:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '"Urgent: Submit quarterly report by Friday. Need to gather data, write summary, and review with team."',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 8),
              Text('This would create a high-priority task with:'),
              Text('• Title: "Submit quarterly report"'),
              Text('• Due date: Next Friday'),
              Text('• Priority: High'),
              Text('• Tags: work, report, deadline'),
              Text('• Subtasks: gather data, write summary, review with team'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Privacy Policy'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your Privacy Matters',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Local Processing:'),
              Text('• Local parsing keeps all data on your device'),
              Text('• No internet connection required'),
              Text('• Complete privacy and offline functionality'),
              SizedBox(height: 16),
              Text('Cloud AI Services:'),
              Text('• Task text is sent to AI providers for processing'),
              Text('• Data is not stored by AI providers after processing'),
              Text('• Encrypted transmission for security'),
              Text('• You can disable cloud AI anytime'),
              SizedBox(height: 16),
              Text('Data Control:'),
              Text('• You choose which AI service to use'),
              Text('• Switch to local-only processing anytime'),
              Text('• Clear usage statistics and data'),
              Text('• Full control over your information'),
              SizedBox(height: 16),
              Text(
                'We recommend using local processing for sensitive tasks.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}


