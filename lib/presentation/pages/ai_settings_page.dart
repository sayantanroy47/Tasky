import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/glassmorphism_container.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/standardized_page_dialogs.dart';
import '../widgets/standardized_text.dart';
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
        appBar: const StandardizedAppBar(title: 'AI Settings',
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
                        const StandardizedText(
                          'AI Task Parsing',
                          style: StandardizedTextStyle.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const StandardizedText(
                      'Use AI to automatically extract task details from natural language',
                      style: StandardizedTextStyle.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const StandardizedText('Enable AI Parsing', style: StandardizedTextStyle.titleMedium),
                      subtitle: StandardizedText(
                        config.enabled
                            ? 'AI will help parse your tasks'
                            : 'Only local parsing will be used',
                        style: StandardizedTextStyle.bodyMedium,
                      ),
                      value: config.enabled,
                      onChanged: (value) {
                        configNotifier.setEnabled(value);
                      },
                    ),
                  ],
                ),
            ),

            const SizedBox(height: 16),

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
                        const StandardizedText(
                          'Auto-Apply Settings',
                          style: StandardizedTextStyle.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const StandardizedText(
                      'Choose which AI suggestions to apply automatically',
                      style: StandardizedTextStyle.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const StandardizedText('Auto-apply Tags', style: StandardizedTextStyle.titleMedium),
                      subtitle: const StandardizedText('Automatically add suggested tags to tasks', style: StandardizedTextStyle.bodyMedium),
                      value: config.autoApplyTags,
                      onChanged: config.enabled
                          ? (value) => configNotifier.setAutoApplyTags(value)
                          : null,
                    ),
                    SwitchListTile(
                      title: const StandardizedText('Auto-apply Priority', style: StandardizedTextStyle.titleMedium),
                      subtitle: const StandardizedText('Automatically set task priority from text', style: StandardizedTextStyle.bodyMedium),
                      value: config.autoApplyPriority,
                      onChanged: config.enabled
                          ? (value) => configNotifier.setAutoApplyPriority(value)
                          : null,
                    ),
                    SwitchListTile(
                      title: const StandardizedText('Auto-apply Due Date', style: StandardizedTextStyle.titleMedium),
                      subtitle: const StandardizedText('Automatically set due dates from text', style: StandardizedTextStyle.bodyMedium),
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
                        const StandardizedText(
                          'Display Settings',
                          style: StandardizedTextStyle.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const StandardizedText('Show Confidence Scores', style: StandardizedTextStyle.titleMedium),
                      subtitle: const StandardizedText('Display AI confidence levels for parsed tasks', style: StandardizedTextStyle.bodyMedium),
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
                        const StandardizedText(
                          'Help & Information',
                          style: StandardizedTextStyle.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: Icon(PhosphorIcons.info()),
                      title: const StandardizedText('How AI Parsing Works', style: StandardizedTextStyle.titleMedium),
                      subtitle: const StandardizedText('Learn about AI task parsing features', style: StandardizedTextStyle.bodyMedium),
                      trailing: Icon(PhosphorIcons.caretRight()),
                      onTap: () => _showHelpDialog(context),
                    ),
                    ListTile(
                      leading: Icon(PhosphorIcons.shieldWarning()),
                      title: const StandardizedText('Privacy Policy', style: StandardizedTextStyle.titleMedium),
                      subtitle: const StandardizedText('View our AI data handling policy', style: StandardizedTextStyle.bodyMedium),
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
    context.showInfoDialog(
      title: 'How AI Parsing Works',
      message: '''AI task parsing helps you create tasks faster by understanding natural language input.

Features:
• Extracts task titles and descriptions
• Identifies due dates from phrases like "tomorrow" or "next week"
• Recognizes priority levels from words like "urgent" or "low priority"
• Suggests tags based on content
• Parses locations for location-based reminders

Examples:
"Urgent: Buy groceries tomorrow at 3pm"
→ Creates high priority task due tomorrow at 3pm

"Call mom next week about vacation"
→ Creates task with family tag due next week''',
      icon: PhosphorIcons.brain(),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const StandardizedText('AI Privacy Policy', style: StandardizedTextStyle.titleLarge),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              StandardizedText(
                'Your Privacy Matters',
                style: StandardizedTextStyle.titleMedium,
              ),
              SizedBox(height: 16),
              StandardizedText('Local Processing:', style: StandardizedTextStyle.titleSmall),
              StandardizedText('• Local parsing keeps all data on your device', style: StandardizedTextStyle.bodyMedium),
              StandardizedText('• No internet connection required', style: StandardizedTextStyle.bodyMedium),
              StandardizedText('• Complete privacy and offline functionality', style: StandardizedTextStyle.bodyMedium),
              SizedBox(height: 16),
              StandardizedText('Cloud AI Services:', style: StandardizedTextStyle.titleSmall),
              StandardizedText('• Task text is sent to AI providers for processing', style: StandardizedTextStyle.bodyMedium),
              StandardizedText('• Data is not stored by AI providers after processing', style: StandardizedTextStyle.bodyMedium),
              StandardizedText('• Encrypted transmission for security', style: StandardizedTextStyle.bodyMedium),
              StandardizedText('• You can disable cloud AI anytime', style: StandardizedTextStyle.bodyMedium),
              SizedBox(height: 16),
              StandardizedText('Data Control:', style: StandardizedTextStyle.titleSmall),
              StandardizedText('• You choose which AI service to use', style: StandardizedTextStyle.bodyMedium),
              StandardizedText('• Switch to local-only processing anytime', style: StandardizedTextStyle.bodyMedium),
              StandardizedText('• Clear usage statistics and data', style: StandardizedTextStyle.bodyMedium),
              StandardizedText('• Full control over your information', style: StandardizedTextStyle.bodyMedium),
              SizedBox(height: 16),
              StandardizedText(
                'We recommend using local processing for sensitive tasks.',
                style: StandardizedTextStyle.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const StandardizedText('Understood', style: StandardizedTextStyle.buttonText),
          ),
        ],
      ),
    );
  }
}


