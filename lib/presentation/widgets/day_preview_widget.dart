import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';
import '../../core/theme/typography_constants.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../providers/task_providers.dart';
import '../widgets/glassmorphism_container.dart';
import 'standardized_text.dart';

/// Day Preview Widget showing tasks for a specific day with hourly timeline
class DayPreviewWidget extends ConsumerWidget {
  final DateTime selectedDate;

  const DayPreviewWidget({
    super.key,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tasksAsync = ref.watch(tasksProvider);

    return GlassmorphismContainer(
      level: GlassLevel.content,
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildHeader(context, theme),
        const SizedBox(height: 12),
        tasksAsync.when(
          data: (tasks) => _buildDayView(context, theme, tasks),
          loading: () => const Center(
            child: Padding(
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
        )
      ]),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    final isToday = _isSameDay(selectedDate, DateTime.now());

    return Row(children: [
      PhosphorIcon(
        PhosphorIcons.calendar(),
        color: theme.colorScheme.primary,
        size: 20,
      ),
      const SizedBox(width: 8),
      Text(
        isToday ? 'Today' : _getDayName(selectedDate),
        style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      const Spacer(),
      Text(
        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
        style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      )
    ]);
  }

  Widget _buildDayView(BuildContext context, ThemeData theme, List<TaskModel> allTasks) {
    final dayTasks = _getTasksForDay(allTasks, selectedDate);

    if (dayTasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(children: [
            PhosphorIcon(
              PhosphorIcons.coffee(),
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'No tasks scheduled',
              style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Enjoy your free time!',
              style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          ]),
        ),
      );
    }

    return SizedBox(
      height: 400, // Fixed height for scrollable timeline
      child: _buildHourlyTimeline(context, theme, dayTasks),
    );
  }

  Widget _buildHourlyTimeline(BuildContext context, ThemeData theme, List<TaskModel> dayTasks) {
    return ListView.builder(
      itemCount: 24, // 24 hours
      itemBuilder: (context, index) {
        final hour = index;
        final hourTasks = _getTasksForHour(dayTasks, hour);

        return _buildHourSlot(context, theme, hour, hourTasks);
      },
    );
  }

  Widget _buildHourSlot(BuildContext context, ThemeData theme, int hour, List<TaskModel> hourTasks) {
    final hasCurrentTime = _isCurrentHour(hour);
    final timeString = _formatHour(hour);

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Time column
        SizedBox(
          width: 50,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text(
              timeString,
              style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                fontWeight: hasCurrentTime ? FontWeight.w500 : FontWeight.normal,
                color: hasCurrentTime ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                // Removed fontSize override - respects theme typography
              ),
            ),
          ),
        ),

        // Timeline line
        Container(
          width: 2,
          height: hourTasks.isEmpty ? 20 : null,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: hasCurrentTime ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusXSmall), // 2.0 - Fixed border radius hierarchy (was 1px)
          ),
          child: hourTasks.isNotEmpty ? _buildTimelineDot(theme, hasCurrentTime) : null,
        ),

        // Tasks column
        Expanded(
          child: hourTasks.isEmpty
              ? const SizedBox(height: 20) // Empty space
              : Column(
                  children: hourTasks.map((task) => _buildTaskItem(context, theme, task)).toList(),
                ),
        )
      ]),
    );
  }

  Widget _buildTimelineDot(ThemeData theme, bool isCurrent) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Transform.translate(
        offset: const Offset(-3, 0),
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isCurrent ? theme.colorScheme.primary : theme.colorScheme.secondary,
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.surface,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, ThemeData theme, TaskModel task) {
    final isCompleted = task.status == TaskStatus.completed;

    return GestureDetector(
      onTap: () => _showTaskDetails(context, task),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8, top: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCompleted
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : _getPriorityColor(task.priority, theme).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
          border: Border.all(
            color: isCompleted
                ? theme.colorScheme.outline.withValues(alpha: 0.3)
                : _getPriorityColor(task.priority, theme).withValues(alpha: 0.5),
          ),
        ),
        child: Row(children: [
          PhosphorIcon(
            isCompleted
                ? PhosphorIcons.checkCircle()
                : task.priority == TaskPriority.high
                    ? PhosphorIcons.warning()
                    : task.priority == TaskPriority.medium
                        ? PhosphorIcons.equals()
                        : PhosphorIcons.caretDown(),
            color: isCompleted ? theme.colorScheme.outline : _getPriorityColor(task.priority, theme),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                task.title,
                style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
                  fontWeight: FontWeight.w500,
                  color: isCompleted ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (task.dueDate != null)
                Text(
                  '${task.dueDate!.hour}:${task.dueDate!.minute.toString().padLeft(2, '0')}',
                  style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
            ]),
          ),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary.withValues(alpha: 0.2), // Fixed hardcoded color violation (was Colors.green)
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
              ),
              child: Text(
                'DONE',
                style: TextStyle(
                  fontSize: TypographyConstants.labelSmall, // Fixed accessibility violation - was 8px, now 11px
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.tertiary, // Fixed hardcoded color violation (was Colors.green.shade700)
                ),
              ),
            )
        ]),
      ),
    );
  }

  // Helper methods
  List<TaskModel> _getTasksForDay(List<TaskModel> allTasks, DateTime date) {
    return allTasks.where((task) {
      final taskDate = task.dueDate ?? task.createdAt;
      return _isSameDay(taskDate, date);
    }).toList()
      ..sort((a, b) {
        final aTime = (a.dueDate ?? a.createdAt);
        final bTime = (b.dueDate ?? b.createdAt);
        return aTime.compareTo(bTime);
      });
  }

  List<TaskModel> _getTasksForHour(List<TaskModel> dayTasks, int hour) {
    return dayTasks.where((task) {
      final taskTime = task.dueDate ?? task.createdAt;
      return taskTime.hour == hour;
    }).toList();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  bool _isCurrentHour(int hour) {
    final now = DateTime.now();
    return _isSameDay(selectedDate, now) && now.hour == hour;
  }

  String _getDayName(DateTime date) {
    const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return dayNames[date.weekday - 1];
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  Color _getPriorityColor(TaskPriority priority, ThemeData theme) {
    switch (priority) {
      case TaskPriority.high:
        return theme.colorScheme.error;
      case TaskPriority.medium:
        return theme.colorScheme.secondary;
      case TaskPriority.low:
        return theme.colorScheme.tertiary;
      default:
        return theme.colorScheme.primary;
    }
  }

  void _showTaskDetails(BuildContext context, TaskModel task) {
    final theme = Theme.of(context);
    final isCompleted = task.status == TaskStatus.completed;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [
          PhosphorIcon(
            isCompleted ? PhosphorIcons.checkCircle() : PhosphorIcons.checkSquare(),
            color: isCompleted ? theme.colorScheme.tertiary : theme.colorScheme.primary, // Fixed hardcoded color violation
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          )
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (task.description?.isNotEmpty == true) ...[
            Text(
              'Description:',
              style: StandardizedTextStyle.titleSmall.toTextStyle(context).copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              task.description!,
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(children: [
            Text(
              'Priority: ',
              style: StandardizedTextStyle.titleSmall.toTextStyle(context).copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getPriorityColor(task.priority, theme).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium), // 12.0 - Fixed border radius hierarchy
              ),
              child: Text(
                task.priority.name.toUpperCase(),
                style: TextStyle(
                  fontSize: TypographyConstants.labelMedium,
                  fontWeight: FontWeight.w500,
                  color: _getPriorityColor(task.priority, theme),
                ),
              ),
            )
          ]),
          if (task.dueDate != null) ...[
            const SizedBox(height: 8),
            Row(children: [
              PhosphorIcon(PhosphorIcons.clock(), size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                'Due: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year} at ${task.dueDate!.hour}:${task.dueDate!.minute.toString().padLeft(2, '0')}',
                style: StandardizedTextStyle.bodySmall.toTextStyle(context),
              )
            ]),
          ],
          if (isCompleted) ...[
            const SizedBox(height: 8),
            Row(children: [
              PhosphorIcon(PhosphorIcons.check(), size: 16, color: theme.colorScheme.tertiary), // Fixed hardcoded color violation
              const SizedBox(width: 4),
              Text(
                'Completed',
                style: TextStyle(
                  color: theme.colorScheme.tertiary, // Fixed hardcoded color violation (was Colors.green.shade700)
                  fontWeight: FontWeight.w500,
                  fontSize: TypographyConstants.labelMedium,
                ),
              )
            ]),
          ]
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
