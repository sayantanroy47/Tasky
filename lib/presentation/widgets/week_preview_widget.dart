import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../providers/task_providers.dart';
import '../widgets/glassmorphism_container.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/theme/typography_constants.dart';
import 'standardized_text.dart';

/// Preferences for week preview display
class WeekPreviewPreferences {
  final bool showTaskCount;
  final bool showPriorityDistribution;
  final bool showCompactView;
  final bool highlightToday;
  final bool showUpcomingDeadlines;
  
  const WeekPreviewPreferences({
    this.showTaskCount = true,
    this.showPriorityDistribution = true,
    this.showCompactView = false,
    this.highlightToday = true,
    this.showUpcomingDeadlines = true,
  });
}

/// Provider for week preview preferences
final weekPreviewPreferencesProvider = StateProvider<WeekPreviewPreferences>((ref) {
  return const WeekPreviewPreferences();
});

/// Week Preview Widget showing upcoming tasks for the week
class WeekPreviewWidget extends ConsumerWidget {
  final WeekPreviewPreferences? customPreferences;
  
  const WeekPreviewWidget({
    super.key,
    this.customPreferences,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final defaultPreferences = ref.watch(weekPreviewPreferencesProvider);
    final preferences = customPreferences ?? defaultPreferences;
    final tasksAsync = ref.watch(tasksProvider);
    
    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader(context, theme, preferences),
          const SizedBox(height: 12),
          tasksAsync.when(
            data: (tasks) => _buildWeekView(context, theme, tasks, preferences),
            loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, _) => Center(
              child: Text(
                'Error loading tasks',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          )]),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, WeekPreviewPreferences preferences) {
    return Row(
      children: [PhosphorIcon(
          PhosphorIcons.calendar(),
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'Week Preview',
          style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        if (!preferences.showCompactView)
          Consumer(
            builder: (context, ref, child) {
              return IconButton(
                icon: PhosphorIcon(PhosphorIcons.gear(), size: 16),
                onPressed: () => _showPreferencesDialog(context, ref),
                tooltip: 'Customize week preview',
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              );
            },
          )]);
  }

  Widget _buildWeekView(BuildContext context, ThemeData theme, List<TaskModel> allTasks, WeekPreviewPreferences preferences) {
    final today = DateTime.now();
    final startOfWeek = _getStartOfWeek(today);
    final weekData = _organizeTasksByWeek(allTasks, startOfWeek);
    
    if (preferences.showCompactView) {
      return _buildCompactWeekView(context, theme, weekData, preferences);
    } else {
      return _buildDetailedWeekView(context, theme, weekData, preferences);
    }
  }

  Widget _buildCompactWeekView(BuildContext context, ThemeData theme, Map<DateTime, List<TaskModel>> weekData, WeekPreviewPreferences preferences) {
    final today = DateTime.now();
    
    return SizedBox(
      height: 80,
      child: Row(
        children: List.generate(7, (index) {
          final date = _getStartOfWeek(today).add(Duration(days: index));
          final dayKey = DateTime(date.year, date.month, date.day);
          final dayTasks = weekData[dayKey] ?? [];
          final isToday = _isSameDay(date, today);
          
          return Expanded(
            child: GestureDetector(
              onTap: () => _showDayTasks(context, date, dayTasks),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isToday && preferences.highlightToday 
                      ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday && preferences.highlightToday
                      ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3))
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text(
                      _getDayName(date).substring(0, 1),
                      style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                        fontWeight: isToday ? FontWeight.w500 : FontWeight.w500,
                        color: isToday ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                        fontWeight: isToday ? FontWeight.w500 : FontWeight.normal,
                        color: isToday ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (preferences.showTaskCount)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: _getTaskCountColor(dayTasks.length, theme),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${dayTasks.length}',
                          style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                            color: Colors.white,
                            fontSize: TypographyConstants.labelSmall,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )]),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDetailedWeekView(BuildContext context, ThemeData theme, Map<DateTime, List<TaskModel>> weekData, WeekPreviewPreferences preferences) {
    final today = DateTime.now();
    
    return Column(
      children: List.generate(7, (index) {
        final date = _getStartOfWeek(today).add(Duration(days: index));
        final dayKey = DateTime(date.year, date.month, date.day);
        final dayTasks = weekData[dayKey] ?? [];
        final isToday = _isSameDay(date, today);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isToday && preferences.highlightToday 
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            border: isToday && preferences.highlightToday
                ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3))
                : null,
          ),
          child: Row(
            children: [// Day column
              SizedBox(
                width: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDayName(date),
                      style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                        fontWeight: isToday ? FontWeight.w500 : FontWeight.w500,
                        color: isToday ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${date.day}',
                      style: StandardizedTextStyle.headlineSmall.toTextStyle(context).copyWith(
                        fontWeight: FontWeight.w500,
                        color: isToday ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      ),
                    )]),
              ),
              const SizedBox(width: 12),
              
              // Task summary
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (preferences.showTaskCount)
                      Row(
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.checkSquare(),
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${dayTasks.length} ${dayTasks.length == 1 ? 'task' : 'tasks'}',
                            style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          )]),
                    
                    if (preferences.showPriorityDistribution && dayTasks.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: _buildPriorityDistribution(theme, dayTasks),
                      ),
                    
                    if (preferences.showUpcomingDeadlines && dayTasks.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: _buildUpcomingDeadlines(theme, dayTasks),
                      )]),
              ),
              
              // Quick action
              IconButton(
                icon: PhosphorIcon(PhosphorIcons.caretRight(), size: 16),
                onPressed: () => _showDayTasks(context, date, dayTasks),
                tooltip: 'View day tasks',
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              )]),
        );
      }),
    );
  }

  Widget _buildPriorityDistribution(ThemeData theme, List<TaskModel> tasks) {
    final priorityCounts = <TaskPriority, int>{};
    for (final task in tasks) {
      priorityCounts[task.priority] = (priorityCounts[task.priority] ?? 0) + 1;
    }
    
    return Row(
      children: [if (priorityCounts[TaskPriority.high] != null)
          _buildPriorityChip('H', priorityCounts[TaskPriority.high]!, theme.colorScheme.error),
        if (priorityCounts[TaskPriority.medium] != null)
          _buildPriorityChip('M', priorityCounts[TaskPriority.medium]!, theme.colorScheme.secondary),
        if (priorityCounts[TaskPriority.low] != null)
          _buildPriorityChip('L', priorityCounts[TaskPriority.low]!, theme.colorScheme.tertiary)]);
  }

  Widget _buildPriorityChip(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          '$label:$count',
          style: TextStyle(
            fontSize: TypographyConstants.labelSmall,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingDeadlines(ThemeData theme, List<TaskModel> tasks) {
    final overdueTasks = tasks.where((task) => 
        task.dueDate != null && 
        task.dueDate!.isBefore(DateTime.now()) &&
        task.status != TaskStatus.completed
    ).length;
    
    if (overdueTasks > 0) {
      return Row(
        children: [PhosphorIcon(
            PhosphorIcons.warning(),
            size: 12,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 4),
          Text(
            '$overdueTasks overdue',
            style: TextStyle(
              fontSize: TypographyConstants.labelSmall,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.error,
            ),
          )]);
    }
    
    return const SizedBox.shrink();
  }

  // Helper methods
  DateTime _getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysFromMonday));
  }

  String _getDayName(DateTime date) {
    const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return dayNames[date.weekday - 1];
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  Color _getTaskCountColor(int count, ThemeData theme) {
    if (count == 0) return theme.colorScheme.outline;
    if (count <= 2) return theme.colorScheme.tertiary;
    if (count <= 5) return theme.colorScheme.secondary;
    return theme.colorScheme.primary;
  }

  Map<DateTime, List<TaskModel>> _organizeTasksByWeek(List<TaskModel> tasks, DateTime startOfWeek) {
    final weekData = <DateTime, List<TaskModel>>{};
    
    // Initialize all days of the week
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dayKey = DateTime(day.year, day.month, day.day);
      weekData[dayKey] = [];
    }
    
    // Group ALL tasks by their due date or created date (including completed)
    for (final task in tasks) {
      final taskDate = task.dueDate ?? task.createdAt;
      final taskDay = DateTime(taskDate.year, taskDate.month, taskDate.day);
      
      // Only include tasks within this week
      if (taskDay.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
          taskDay.isBefore(startOfWeek.add(const Duration(days: 7)))) {
        weekData[taskDay]?.add(task);
      }
    }
    
    return weekData;
  }

  void _showDayTasks(BuildContext context, DateTime date, List<TaskModel> tasks) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_getDayName(date)}, ${date.day}'),
        content: tasks.isEmpty 
            ? const Text('No tasks for this day')
            : SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: tasks.map((task) {
                    final isCompleted = task.status == TaskStatus.completed;
                    final theme = Theme.of(context);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                            : theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: isCompleted 
                            ? Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3))
                            : Border.all(color: _getPriorityColor(task.priority, theme).withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [PhosphorIcon(
                            isCompleted ? PhosphorIcons.checkCircle() : 
                            task.priority == TaskPriority.high ? PhosphorIcons.warning() :
                            task.priority == TaskPriority.medium ? PhosphorIcons.equals() :
                            PhosphorIcons.caretDown(),
                            color: isCompleted 
                                ? theme.colorScheme.outline
                                : _getPriorityColor(task.priority, theme),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: isCompleted 
                                        ? theme.colorScheme.onSurfaceVariant
                                        : theme.colorScheme.onSurface,
                                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                if (task.description?.isNotEmpty == true)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      task.description!,
                                      style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                                        color: isCompleted 
                                            ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
                                            : theme.colorScheme.onSurfaceVariant,
                                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                if (task.dueDate != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Due: ${task.dueDate!.day}/${task.dueDate!.month} ${task.dueDate!.hour}:${task.dueDate!.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontSize: TypographyConstants.labelSmall,
                                        color: theme.colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )]),
                          ),
                          if (isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'DONE',
                                style: TextStyle(
                                  fontSize: TypographyConstants.labelSmall,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            )]),
                    );
                  }).toList(),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority, ThemeData theme) {
    // Use the updated enum colors which now have stellar gold fallback for high priority
    return priority.color;
  }

  void _showPreferencesDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _WeekPreviewPreferencesDialog(ref: ref),
    );
  }
}

class _WeekPreviewPreferencesDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;
  
  const _WeekPreviewPreferencesDialog({required this.ref});

  @override
  ConsumerState<_WeekPreviewPreferencesDialog> createState() => _WeekPreviewPreferencesDialogState();
}

class _WeekPreviewPreferencesDialogState extends ConsumerState<_WeekPreviewPreferencesDialog> {
  late WeekPreviewPreferences preferences;
  
  @override
  void initState() {
    super.initState();
    preferences = ref.read(weekPreviewPreferencesProvider);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Week Preview Preferences'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [SwitchListTile(
            title: const Text('Show Task Count'),
            value: preferences.showTaskCount,
            onChanged: (value) => setState(() {
              preferences = WeekPreviewPreferences(
                showTaskCount: value,
                showPriorityDistribution: preferences.showPriorityDistribution,
                showCompactView: preferences.showCompactView,
                highlightToday: preferences.highlightToday,
                showUpcomingDeadlines: preferences.showUpcomingDeadlines,
              );
            }),
          ),
          SwitchListTile(
            title: const Text('Show Priority Distribution'),
            value: preferences.showPriorityDistribution,
            onChanged: (value) => setState(() {
              preferences = WeekPreviewPreferences(
                showTaskCount: preferences.showTaskCount,
                showPriorityDistribution: value,
                showCompactView: preferences.showCompactView,
                highlightToday: preferences.highlightToday,
                showUpcomingDeadlines: preferences.showUpcomingDeadlines,
              );
            }),
          ),
          SwitchListTile(
            title: const Text('Compact View'),
            value: preferences.showCompactView,
            onChanged: (value) => setState(() {
              preferences = WeekPreviewPreferences(
                showTaskCount: preferences.showTaskCount,
                showPriorityDistribution: preferences.showPriorityDistribution,
                showCompactView: value,
                highlightToday: preferences.highlightToday,
                showUpcomingDeadlines: preferences.showUpcomingDeadlines,
              );
            }),
          ),
          SwitchListTile(
            title: const Text('Highlight Today'),
            value: preferences.highlightToday,
            onChanged: (value) => setState(() {
              preferences = WeekPreviewPreferences(
                showTaskCount: preferences.showTaskCount,
                showPriorityDistribution: preferences.showPriorityDistribution,
                showCompactView: preferences.showCompactView,
                highlightToday: value,
                showUpcomingDeadlines: preferences.showUpcomingDeadlines,
              );
            }),
          ),
          SwitchListTile(
            title: const Text('Show Upcoming Deadlines'),
            value: preferences.showUpcomingDeadlines,
            onChanged: (value) => setState(() {
              preferences = WeekPreviewPreferences(
                showTaskCount: preferences.showTaskCount,
                showPriorityDistribution: preferences.showPriorityDistribution,
                showCompactView: preferences.showCompactView,
                highlightToday: preferences.highlightToday,
                showUpcomingDeadlines: value,
              );
            }),
          )]),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(weekPreviewPreferencesProvider.notifier).state = preferences;
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

