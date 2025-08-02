import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/performance_service.dart';

/// Performance monitoring dashboard for debugging and optimization
class PerformanceDashboardScreen extends ConsumerWidget {
  const PerformanceDashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performanceStatsAsync = ref.watch(performanceStatsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(performanceStatsProvider),
          ),
        ],
      ),
      body: performanceStatsAsync.when(
        data: (stats) => _buildDashboard(context, stats),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading performance data: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(performanceStatsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDashboard(BuildContext context, PerformanceStats stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(context, stats),
          const SizedBox(height: 16),
          _buildOperationsList(context, stats),
          const SizedBox(height: 16),
          _buildMemoryInfo(context),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard(BuildContext context, PerformanceStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Summary',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'Total Metrics',
                    stats.totalMetrics.toString(),
                    Icons.analytics,
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    'Operations',
                    stats.operationStats.length.toString(),
                    Icons.functions,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Generated: ${_formatDateTime(stats.generatedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetricTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildOperationsList(BuildContext context, PerformanceStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Operation Performance',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            if (stats.operationStats.isEmpty)
              const Text('No performance data available')
            else
              ...stats.operationStats.values.map((opStats) => 
                _buildOperationTile(opStats)
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOperationTile(OperationStats opStats) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  opStats.operation,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPerformanceColor(opStats.averageDuration),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${opStats.count}x',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Avg', '${opStats.averageDuration.inMilliseconds}ms'),
              ),
              Expanded(
                child: _buildStatItem('Min', '${opStats.minDuration.inMilliseconds}ms'),
              ),
              Expanded(
                child: _buildStatItem('Max', '${opStats.maxDuration.inMilliseconds}ms'),
              ),
              Expanded(
                child: _buildStatItem('P95', '${opStats.p95Duration.inMilliseconds}ms'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMemoryInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Memory Management',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.memory),
              title: const Text('Automatic Cleanup'),
              subtitle: const Text('Memory cleanup runs every 10 minutes'),
              trailing: ElevatedButton(
                onPressed: () {
                  MemoryManager.performCleanup();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Memory cleanup performed')),
                  );
                },
                child: const Text('Clean Now'),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cached),
              title: const Text('Image Cache'),
              subtitle: const Text('Automatically cleared when memory is low'),
              trailing: ElevatedButton(
                onPressed: () {
                  PaintingBinding.instance.imageCache.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image cache cleared')),
                  );
                },
                child: const Text('Clear Cache'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getPerformanceColor(Duration duration) {
    final ms = duration.inMilliseconds;
    if (ms < 50) return Colors.green;
    if (ms < 100) return Colors.orange;
    return Colors.red;
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
  }
}