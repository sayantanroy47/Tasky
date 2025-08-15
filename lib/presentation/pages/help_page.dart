import 'package:flutter/material.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/theme_background_widget.dart';
import '../widgets/glassmorphism_container.dart';
import '../../core/theme/typography_constants.dart';
import '../../services/help_service.dart';

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
              icon: const Icon(Icons.search),
              onPressed: () {
                _helpService.showHelpSearch(context);
              },
              tooltip: 'Search Help',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(
            top: kToolbarHeight + 8,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          child: Column(
        children: [
            // Welcome Card
            Container(
              margin: const EdgeInsets.only(bottom: 16.0),
            child: GlassmorphismContainer(
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to Tasky Help',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Find answers to common questions and learn how to get the most out of Tasky.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _helpService.showHelpTopic(context, 'getting_started');
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Quick Start'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              _showFeedbackDialog(context);
                            },
                            icon: const Icon(Icons.feedback),
                            label: const Text('Feedback'),
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
      padding: const EdgeInsets.all(16.0),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return GlassmorphismContainer(
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: Text(
              topic.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              _getTopicPreview(topic.content),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
      if (trimmed.isNotEmpty && 
          !trimmed.startsWith('#') && 
          !trimmed.startsWith('## ') && 
          !trimmed.startsWith('- ')) {
        return trimmed;
      }
    }
    return 'Learn more about this topic';
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('We\'d love to hear from you!'),
            SizedBox(height: 16),
            Text('You can send feedback through:'),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.email, size: 16),
                SizedBox(width: 8),
                Text('Settings → Send Feedback'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.bug_report, size: 16),
                SizedBox(width: 8),
                Text('Report bugs or suggest features'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
            child: const Text('Go to Settings'),
          ),
        ],
      ),
    );
  }
}