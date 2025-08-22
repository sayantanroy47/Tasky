import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../services/task/task_dependency_service.dart';
import '../providers/task_dependency_providers.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Widget that shows dependency status for a task
class TaskDependencyStatus extends ConsumerWidget {
  final TaskModel task;
  final bool showDetails;
  final VoidCallback? onTap;

  const TaskDependencyStatus({
    super.key,
    required this.task,
    this.showDetails = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (task.dependencies.isEmpty) {
      return const SizedBox.shrink();
    }

    final validationAsync = ref.watch(taskDependencyValidationProvider(task));

    return validationAsync.when(
      data: (validation) => _buildDependencyStatus(context, validation),
      loading: () => _buildLoadingStatus(context),
      error: (_, __) => _buildErrorStatus(context),
    );
  }

  Widget _buildDependencyStatus(BuildContext context, DependencyValidationResult validation) {
    final isBlocked = !validation.isValid;
    final color = isBlocked ? Colors.orange : Colors.green;
    final icon = isBlocked ? PhosphorIcons.prohibit() : PhosphorIcons.checkCircle();
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              isBlocked 
                  ? '${validation.incompleteDependencies.length}/${task.dependencies.length} pending'
                  : 'Ready',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showDetails && validation.incompleteDependencies.isNotEmpty) ...[
              const SizedBox(width: 4),
              Icon(
                PhosphorIcons.info(),
                size: 12,
                color: color,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Checking...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIcons.warningCircle(),
            size: 14,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 4),
          Text(
            'Error',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget that shows a detailed dependency tooltip
class TaskDependencyTooltip extends ConsumerWidget {
  final TaskModel task;
  final Widget child;

  const TaskDependencyTooltip({
    super.key,
    required this.task,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (task.dependencies.isEmpty) {
      return child;
    }

    final validationAsync = ref.watch(taskDependencyValidationProvider(task));

    return validationAsync.when(
      data: (validation) => Tooltip(
        message: _buildTooltipMessage(validation),
        preferBelow: false,
        child: child,
      ),
      loading: () => child,
      error: (_, __) => child,
    );
  }

  String _buildTooltipMessage(DependencyValidationResult validation) {
    if (validation.isValid) {
      return 'All dependencies completed. Task is ready to start.';
    }
    
    final incompleteTasks = validation.incompleteDependencies
        .map((task) => '• ${task.title}')
        .join('\n');
    
    return 'Blocked by ${validation.incompleteDependencies.length} incomplete dependencies:\n$incompleteTasks';
  }
}

/// Compact dependency indicator for task cards
class TaskDependencyIndicator extends ConsumerWidget {
  final TaskModel task;
  final double size;

  const TaskDependencyIndicator({
    super.key,
    required this.task,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (task.dependencies.isEmpty) {
      return const SizedBox.shrink();
    }

    final validationAsync = ref.watch(taskDependencyValidationProvider(task));

    return validationAsync.when(
      data: (validation) {
        final isBlocked = !validation.isValid;
        return TaskDependencyTooltip(
          task: task,
          child: Icon(
            isBlocked ? PhosphorIcons.link() : PhosphorIcons.link(),
            size: size,
            color: isBlocked 
                ? Colors.orange 
                : Colors.green,
          ),
        );
      },
      loading: () => Icon(
        PhosphorIcons.link(),
        size: size,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
      error: (_, __) => Icon(
        PhosphorIcons.link(),
        size: size,
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

