import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography_constants.dart';


/// Widget displaying AI usage statistics and insights
class AIUsageStatistics extends ConsumerWidget {
  const AIUsageStatistics({super.key});  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real implementation, this would watch a provider that fetches usage stats
    final mockStats = _getMockUsageStats();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Usage Statistics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showDetailedStats(context),
                  child: const Text('View Details'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Your AI parsing usage over the last 30 days',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Statistics Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _StatCard(
                  title: 'Tasks Parsed',
                  value: mockStats['totalParsed'].toString(),
                  icon: Icons.task_alt,
                  color: Colors.blue,
                ),
                _StatCard(
                  title: 'Success Rate',
                  value: '${mockStats['successRate']}%',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                _StatCard(
                  title: 'Tags Suggested',
                  value: mockStats['tagsSuggested'].toString(),
                  icon: Icons.label,
                  color: Colors.orange,
                ),
                _StatCard(
                  title: 'Time Saved',
                  value: '${mockStats['timeSaved']}min',
                  icon: Icons.timer,
                  color: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Current Service Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Service: ${mockStats['currentService']}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Last used: ${mockStats['lastUsed']}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                    ),
                    child: Text(
                      'Active',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportStats(context),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Export'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _resetStats(context),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getMockUsageStats() {
    return {
      'totalParsed': 127,
      'successRate': 94,
      'tagsSuggested': 342,
      'timeSaved': 45,
      'currentService': 'Local Parser',
      'lastUsed': '2 hours ago',
    };
  }

  void _showDetailedStats(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DetailedStatsDialog(),
    );
  }

  void _exportStats(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Statistics exported successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _resetStats(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Statistics'),
        content: const Text(
          'This will permanently reset all usage statistics. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Statistics reset successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

/// Individual statistic card widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog showing detailed usage statistics
class DetailedStatsDialog extends StatelessWidget {
  const DetailedStatsDialog({super.key});  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Detailed Statistics'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatSection(
              context,
              'Parsing Performance',
              [
                const _StatRow('Total tasks parsed', '127'),
                const _StatRow('Successful parses', '119'),
                const _StatRow('Failed parses', '8'),
                const _StatRow('Average confidence', '87%'),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatSection(
              context,
              'Feature Usage',
              [
                const _StatRow('Tags suggested', '342'),
                const _StatRow('Due dates extracted', '89'),
                const _StatRow('Priorities detected', '76'),
                const _StatRow('Subtasks created', '203'),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatSection(
              context,
              'Time Analysis',
              [
                const _StatRow('Total time saved', '45 minutes'),
                const _StatRow('Average per task', '21 seconds'),
                const _StatRow('Most active day', 'Tuesday'),
                const _StatRow('Peak usage hour', '2-3 PM'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildStatSection(BuildContext context, String title, List<_StatRow> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...stats.map((stat) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(stat.label),
              Text(
                stat.value,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

/// Data class for statistic rows
class _StatRow {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);
}
