import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/phosphor_icons.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/theme/typography_constants.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/entities/timeline_milestone.dart';
import '../../domain/entities/timeline_settings.dart';
import '../widgets/glassmorphism_container.dart';
import '../widgets/standardized_error_states.dart';
import '../widgets/timeline/timeline_gantt_view.dart';
import '../providers/timeline_providers.dart';

/// Demo page showcasing the comprehensive Timeline/Gantt chart functionality
/// 
/// This page demonstrates:
/// - Multi-project timeline visualization
/// - Task scheduling and dependency management
/// - Milestone tracking and progress monitoring
/// - Interactive controls and settings
/// - Drag-and-drop rescheduling
/// - Critical path analysis
/// - Export capabilities
class TimelineDemoPage extends ConsumerStatefulWidget {
  const TimelineDemoPage({super.key});

  @override
  ConsumerState<TimelineDemoPage> createState() => _TimelineDemoPageState();
}

class _TimelineDemoPageState extends ConsumerState<TimelineDemoPage> {
  bool _showSampleData = true;

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    if (_showSampleData) {
      // Create sample data to demonstrate timeline functionality
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _createSampleTimelineData();
      });
    }
  }

  Future<void> _createSampleTimelineData() async {
    try {
      // This would normally be handled by the service layer
      // For demo purposes, we'll just trigger a data refresh
      await ref.read(timelineDataProvider.notifier).refreshData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load sample data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Timeline / Gantt Chart Demo',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: TypographyConstants.medium,
        ),
      ),
      actions: [
        // Sample data toggle
        IconButton(
          icon: Icon(
            _showSampleData 
                ? PhosphorIcons.database()
                : PhosphorIcons.eyeSlash(),
          ),
          tooltip: _showSampleData ? 'Hide sample data' : 'Show sample data',
          onPressed: () {
            setState(() {
              _showSampleData = !_showSampleData;
            });
            _loadSampleData();
          },
        ),
        
        // Timeline statistics
        IconButton(
          icon: Icon(PhosphorIcons.chartBar()),
          tooltip: 'Timeline statistics',
          onPressed: _showTimelineStatistics,
        ),
        
        // Export options
        PopupMenuButton<String>(
          icon: Icon(PhosphorIcons.export()),
          tooltip: 'Export timeline',
          onSelected: _handleExport,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'png',
              child: Row(
                children: [
                  Icon(PhosphorIcons.image(), size: 16),
                  const SizedBox(width: 8),
                  const Text('Export as PNG'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'pdf',
              child: Row(
                children: [
                  Icon(PhosphorIcons.filePdf(), size: 16),
                  const SizedBox(width: 8),
                  const Text('Export as PDF'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'csv',
              child: Row(
                children: [
                  Icon(PhosphorIcons.table(), size: 16),
                  const SizedBox(width: 8),
                  const Text('Export as CSV'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Demo introduction panel
        _buildIntroductionPanel(),
        
        // Main timeline view
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
            child: TimelineGanttView(
              showControls: true,
              onTaskSelected: _handleTaskSelected,
              onMilestoneSelected: _handleMilestoneSelected,
              onTaskRescheduled: _handleTaskRescheduled,
            ),
          ),
        ),
        
        // Status bar
        _buildStatusBar(),
      ],
    );
  }

  Widget _buildIntroductionPanel() {
    return GlassmorphismContainer(
      level: GlassLevel.whisper,
      padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      margin: const EdgeInsets.all(TypographyConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.chartLineUp(),
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Timeline/Gantt Chart Demo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: TypographyConstants.medium,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: TypographyConstants.spacingSmall),
          
          Text(
            'This comprehensive timeline view demonstrates advanced project management features:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: TypographyConstants.spacingSmall),
          
          Wrap(
            spacing: TypographyConstants.spacingLarge,
            runSpacing: TypographyConstants.spacingSmall,
            children: [
              _buildFeatureChip(
                icon: PhosphorIcons.calendarBlank(),
                label: 'Multi-zoom timeline',
                color: Colors.blue,
              ),
              _buildFeatureChip(
                icon: PhosphorIcons.arrowsOutCardinal(),
                label: 'Drag & drop scheduling',
                color: Colors.green,
              ),
              _buildFeatureChip(
                icon: PhosphorIcons.arrowRight(),
                label: 'Task dependencies',
                color: Colors.orange,
              ),
              _buildFeatureChip(
                icon: PhosphorIcons.flagBanner(),
                label: 'Project milestones',
                color: Colors.purple,
              ),
              _buildFeatureChip(
                icon: PhosphorIcons.path(),
                label: 'Critical path analysis',
                color: Colors.red,
              ),
              _buildFeatureChip(
                icon: PhosphorIcons.chartBar(),
                label: 'Progress tracking',
                color: Colors.teal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Chip(
      avatar: Icon(
        icon,
        size: 14,
        color: color,
      ),
      label: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color.withValues(alpha: 0.8),
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
    );
  }

  Widget _buildStatusBar() {
    return Consumer(
      builder: (context, ref, child) {
        final timelineStats = ref.watch(timelineStatsProvider);
        final timelineSettings = ref.watch(timelineSettingsProvider);
        
        return timelineStats.when(
          data: (stats) => _buildStatusBarContent(stats, timelineSettings),
          loading: () => StandardizedErrorStates.loading(
            style: LoadingStyle.linear,
            compact: true,
          ),
          error: (error, stack) => StandardizedErrorStates.error(
            message: 'Error loading statistics',
            severity: ErrorSeverity.moderate,
            compact: true,
          ),
        );
      },
    );
  }

  Widget _buildStatusBarContent(
    TimelineStats stats,
    TimelineSettings settings,
  ) {
    return GlassmorphismContainer(
      level: GlassLevel.whisper,
      padding: const EdgeInsets.symmetric(
        horizontal: TypographyConstants.paddingMedium,
        vertical: TypographyConstants.paddingSmall,
      ),
      child: Row(
        children: [
          _buildStatusItem(
            icon: PhosphorIcons.listChecks(),
            label: 'Tasks',
            value: '${stats.completedTasks}/${stats.totalTasks}',
            color: Theme.of(context).colorScheme.primary,
          ),
          _buildStatusDivider(),
          
          _buildStatusItem(
            icon: PhosphorIcons.folder(),
            label: 'Projects',
            value: '${stats.activeProjects}/${stats.totalProjects}',
            color: Theme.of(context).colorScheme.secondary,
          ),
          _buildStatusDivider(),
          
          _buildStatusItem(
            icon: PhosphorIcons.flagBanner(),
            label: 'Milestones',
            value: '${stats.completedMilestones}/${stats.totalMilestones}',
            color: Theme.of(context).colorScheme.tertiary,
          ),
          _buildStatusDivider(),
          
          _buildStatusItem(
            icon: PhosphorIcons.chartPie(),
            label: 'Progress',
            value: '${(stats.overallProgress * 100).toInt()}%',
            color: Colors.green,
          ),
          _buildStatusDivider(),
          
          _buildStatusItem(
            icon: PhosphorIcons.clockCountdown(),
            label: 'Overdue',
            value: '${stats.overdueTasks}',
            color: stats.overdueTasks > 0 ? Colors.red : Colors.grey,
          ),
          
          const Spacer(),
          
          // Zoom level indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PhosphorIconConstants.getIconByName(settings.zoomLevel.iconName),
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  settings.zoomLevel.displayName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: TypographyConstants.medium,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: TypographyConstants.spacingMedium),
      width: 1,
      height: 16,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Add milestone FAB
        FloatingActionButton.small(
          heroTag: 'add_milestone',
          onPressed: _showAddMilestoneDialog,
          tooltip: 'Add Milestone',
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
          child: Icon(PhosphorIcons.flagBanner()),
        ),
        
        const SizedBox(height: 8),
        
        // Add dependency FAB
        FloatingActionButton.small(
          heroTag: 'add_dependency',
          onPressed: _showAddDependencyDialog,
          tooltip: 'Add Dependency',
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          child: Icon(PhosphorIcons.arrowRight()),
        ),
        
        const SizedBox(height: 8),
        
        // Add task FAB
        FloatingActionButton(
          heroTag: 'add_task',
          onPressed: _showAddTaskDialog,
          tooltip: 'Add Task',
          child: Icon(PhosphorIcons.plus()),
        ),
      ],
    );
  }

  // Event handlers
  void _handleTaskSelected(TaskModel task) {
    ref.read(selectedTimelineTaskProvider.notifier).state = task;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              PhosphorIcons.checkSquare(),
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Selected task: ${task.title}'),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Edit',
          onPressed: () => _showEditTaskDialog(task),
        ),
      ),
    );
  }

  void _handleMilestoneSelected(TimelineMilestone milestone) {
    ref.read(selectedTimelineMilestoneProvider.notifier).state = milestone;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              PhosphorIcons.flagBanner(),
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Selected milestone: ${milestone.title}'),
            ),
          ],
        ),
        backgroundColor: Color(int.parse('0xFF${milestone.color.substring(1)}')),
        action: SnackBarAction(
          label: 'Edit',
          textColor: Colors.white,
          onPressed: () => _showEditMilestoneDialog(milestone),
        ),
      ),
    );
  }

  void _handleTaskRescheduled(
    TaskModel task,
    DateTime newStartDate,
    DateTime newEndDate,
  ) {
    // Handle task rescheduling
    ref.read(timelineDataProvider.notifier).rescheduleTask(
      task,
      newStartDate,
      newEndDate,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              PhosphorIcons.calendarCheck(),
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text('Rescheduled: ${task.title}'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showTimelineStatistics() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(PhosphorIcons.chartBar()),
            const SizedBox(width: 8),
            const Text('Timeline Statistics'),
          ],
        ),
        content: Consumer(
          builder: (context, ref, child) {
            final stats = ref.watch(timelineStatsProvider);
            return stats.when(
              data: (data) => _buildStatisticsContent(data),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsContent(TimelineStats stats) {
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatRow('Total Tasks', stats.totalTasks.toString()),
          _buildStatRow('Completed Tasks', stats.completedTasks.toString()),
          _buildStatRow('Overdue Tasks', stats.overdueTasks.toString()),
          _buildStatRow('Active Projects', stats.activeProjects.toString()),
          _buildStatRow('Total Milestones', stats.totalMilestones.toString()),
          _buildStatRow('Overall Progress', '${(stats.overallProgress * 100).toInt()}%'),
          _buildStatRow('Critical Tasks', stats.criticalTasks.length.toString()),
          _buildStatRow('Avg Task Duration', '${stats.averageTaskDuration.inDays} days'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: TypographyConstants.medium,
            ),
          ),
        ],
      ),
    );
  }

  void _handleExport(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export to ${format.toUpperCase()} - Feature coming soon!'),
      ),
    );
  }

  void _showAddTaskDialog() {
    // TODO: Implement add task dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Task dialog - Coming soon!')),
    );
  }

  void _showAddMilestoneDialog() {
    // TODO: Implement add milestone dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Milestone dialog - Coming soon!')),
    );
  }

  void _showAddDependencyDialog() {
    // TODO: Implement add dependency dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Dependency dialog - Coming soon!')),
    );
  }

  void _showEditTaskDialog(TaskModel task) {
    // TODO: Implement edit task dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit Task: ${task.title} - Coming soon!')),
    );
  }

  void _showEditMilestoneDialog(TimelineMilestone milestone) {
    // TODO: Implement edit milestone dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit Milestone: ${milestone.title} - Coming soon!')),
    );
  }
}