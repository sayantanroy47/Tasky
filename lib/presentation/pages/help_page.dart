import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/typography_constants.dart';
import '../../services/help_service.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/standardized_spacing.dart';
import '../widgets/standardized_text.dart';
import '../widgets/theme_background_widget.dart';

/// Help and documentation page
class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final HelpService _helpService = HelpService();

  @override
  void initState() {
    super.initState();
    final categories = _helpService.getCategories();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _helpService.getCategories();

    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: StandardizedAppBar(
          title: 'Help & Support',
          actions: [
            IconButton(
              icon: Icon(PhosphorIcons.magnifyingGlass()),
              onPressed: () {
                _helpService.showHelpSearch(context);
              },
              tooltip: 'Search Help',
            ),
          ],
        ),
        body: Padding(
          padding: StandardizedSpacing.paddingOnly(
            top: SpacingSize.lg,
            left: SpacingSize.md,
            right: SpacingSize.md,
            bottom: SpacingSize.md,
          ),
          child: Column(
            children: [
              // Welcome Card
              Container(
                margin: StandardizedSpacing.marginOnly(bottom: SpacingSize.md),
                child: GlassmorphismContainer(
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  padding: StandardizedSpacing.padding(SpacingSize.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.question(),
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          StandardizedGaps.hMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const StandardizedText(
                                  'Welcome to Tasky Help',
                                  style: StandardizedTextStyle.titleLarge,
                                ),
                                StandardizedGaps.xs,
                                const StandardizedText(
                                  'Find answers to common questions and learn how to get the most out of Tasky.',
                                  style: StandardizedTextStyle.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      StandardizedGaps.md,
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _helpService.showHelpTopic(context, 'getting_started');
                              },
                              icon: Icon(PhosphorIcons.play()),
                              label: const StandardizedText('Quick Start', style: StandardizedTextStyle.buttonText),
                            ),
                          ),
                          StandardizedGaps.hMd,
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                _showFeedbackDialog(context);
                              },
                              icon: Icon(PhosphorIcons.chatCircle()),
                              label: const StandardizedText('Feedback', style: StandardizedTextStyle.buttonText),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Category Tabs
              if (categories.isNotEmpty) ...[
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: categories.map((category) {
                    return Tab(text: _helpService.getCategoryDisplayName(category));
                  }).toList(),
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: categories.map((category) {
                      return _buildCategoryContent(category);
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryContent(String category) {
    final topics = _helpService.getTopicsByCategory(category);

    return ListView.builder(
      padding: StandardizedSpacing.padding(SpacingSize.md),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return GlassmorphismContainer(
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          margin: StandardizedSpacing.marginOnly(bottom: SpacingSize.md),
          child: ListTile(
            contentPadding: StandardizedSpacing.padding(SpacingSize.md),
            title: StandardizedText(
              topic.title,
              style: StandardizedTextStyle.titleMedium,
            ),
            subtitle: StandardizedText(
              _getTopicPreview(topic.content),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: StandardizedTextStyle.bodySmall,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            trailing: Icon(PhosphorIcons.caretRight(), size: 16),
            onTap: () {
              _helpService.showHelpTopic(context, topic.id);
            },
          ),
        );
      },
    );
  }

  String _getTopicPreview(String content) {
    // Extract first meaningful line after title
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty && !trimmed.startsWith('#') && !trimmed.startsWith('## ') && !trimmed.startsWith('- ')) {
        return trimmed;
      }
    }
    return 'Learn more about this topic';
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const StandardizedText('Send Feedback', style: StandardizedTextStyle.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StandardizedText('We\'d love to hear from you!', style: StandardizedTextStyle.bodyMedium),
            StandardizedGaps.md,
            const StandardizedText('You can send feedback through:', style: StandardizedTextStyle.bodyMedium),
            StandardizedGaps.md,
            Row(
              children: [
                Icon(PhosphorIcons.envelope(), size: 16),
                StandardizedGaps.hSm,
                const StandardizedText('Settings → Send Feedback', style: StandardizedTextStyle.bodyMedium),
              ],
            ),
            StandardizedGaps.sm,
            Row(
              children: [
                Icon(PhosphorIcons.bug(), size: 16),
                StandardizedGaps.hSm,
                const StandardizedText('Report bugs or suggest features', style: StandardizedTextStyle.bodyMedium),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const StandardizedText('Close', style: StandardizedTextStyle.buttonText),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
            child: const StandardizedText('Go to Settings', style: StandardizedTextStyle.buttonText),
          ),
        ],
      ),
    );
  }
}
