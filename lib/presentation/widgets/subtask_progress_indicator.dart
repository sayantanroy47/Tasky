import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subtask_providers.dart';

/// Compact subtask progress indicator for task cards
class SubtaskProgressIndicator extends ConsumerWidget {
  final String taskId;
  final double size;
  final bool showCount;

  const SubtaskProgressIndicator({
    super.key,
    required this.taskId,
    this.size = 16,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtasksAsync = ref.watch(subtasksForTaskProvider(taskId));
    final theme = Theme.of(context);

    return subtasksAsync.when(
      data: (subtasks) {
        if (subtasks.isEmpty) return const SizedBox.shrink();

        final completed = subtasks.where((s) => s.isCompleted).length;
        final total = subtasks.length;
        final percentage = total > 0 ? completed / total : 0.0;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress circle
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: percentage,
                strokeWidth: 2,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage == 1.0 ? Colors.green : theme.colorScheme.primary,
                ),
              ),
            ),
            
            // Count text
            if (showCount) ...[
              const SizedBox(width: 4),
              Text(
                '$completed/$total',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        );
      },
      loading: () => SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Linear subtask progress indicator
class SubtaskLinearProgressIndicator extends ConsumerWidget {
  final String taskId;
  final double height;
  final bool showPercentage;

  const SubtaskLinearProgressIndicator({
    super.key,
    required this.taskId,
    this.height = 4,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completionPercentageAsync = ref.watch(subtaskCompletionPercentageProvider(taskId));
    final theme = Theme.of(context);

    return completionPercentageAsync.when(
      data: (percentage) {
        if (percentage == 0.0) return const SizedBox.shrink();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: percentage / 100.0,
              minHeight: height,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage == 100.0 ? Colors.green : theme.colorScheme.primary,
              ),
            ),
            if (showPercentage) ...[
              const SizedBox(height: 2),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        );
      },
      loading: () => LinearProgressIndicator(
        minHeight: height,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Badge showing subtask completion status
class SubtaskCompletionBadge extends ConsumerWidget {
  final String taskId;

  const SubtaskCompletionBadge({
    super.key,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtasksAsync = ref.watch(subtasksForTaskProvider(taskId));
    final theme = Theme.of(context);

    return subtasksAsync.when(
      data: (subtasks) {
        if (subtasks.isEmpty) return const SizedBox.shrink();

        final completed = subtasks.where((s) => s.isCompleted).length;
        final total = subtasks.length;
        final allCompleted = completed == total;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: allCompleted ? Colors.green : theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$completed/$total',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '...',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}