import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/project.dart';
import '../providers/project_providers.dart';

/// Widget for selecting a project from a dropdown
/// 
/// Displays active projects in a dropdown menu with color indicators
/// and allows clearing the selection.
class ProjectSelector extends ConsumerWidget {
  final String? selectedProjectId;
  final ValueChanged<String?> onProjectChanged;
  final String? label;
  final String? hint;

  const ProjectSelector({
    super.key,
    required this.selectedProjectId,
    required this.onProjectChanged,
    this.label = 'Project',
    this.hint = 'Select a project (optional)',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeProjectsAsync = ref.watch(activeProjectsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!,
            style: theme.textTheme.titleSmall,
          ),
        if (label != null) const SizedBox(height: 8),
        
        activeProjectsAsync.when(
          data: (projects) {

            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: selectedProjectId,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      hint ?? 'Select a project',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  isExpanded: true,
                  items: [
                    // Clear selection option
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.clear,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'No project',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Divider
                    const DropdownMenuItem<String?>(
                      enabled: false,
                      value: '__divider__',
                      child: Divider(height: 1),
                    ),
                    
                    // Project options
                    ...projects.map((project) => DropdownMenuItem<String?>(
                      value: project.id,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            // Project color indicator
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _parseColor(project.color),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            
                            // Project name
                            Expanded(
                              child: Text(
                                project.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            // Task count
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${project.taskCount}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                  ],
                  onChanged: (value) {
                    if (value != '__divider__') {
                      onProjectChanged(value);
                    }
                  },
                ),
              ),
            );
          },
          loading: () => Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (error, _) => Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.error),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Error loading projects',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Selected project info
        if (selectedProjectId != null)
          activeProjectsAsync.when(
            data: (projects) {
              final project = projects.firstWhere(
                (p) => p.id == selectedProjectId,
                orElse: () => Project.create(name: 'Unknown Project'),
              );
              
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _parseColor(project.color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _parseColor(project.color).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _parseColor(project.color),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          project.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: _parseColor(project.color).withValues(alpha: 0.1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (project.hasDeadline)
                        Text(
                          'Due ${_formatDate(project.deadline!)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: _parseColor(project.color).withValues(alpha: 0.1),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
      ],
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'today';
    } else if (difference == 1) {
      return 'tomorrow';
    } else if (difference > 0 && difference <= 7) {
      return 'in $difference days';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}

/// Compact version of project selector for use in smaller spaces
class CompactProjectSelector extends ConsumerWidget {
  final String? selectedProjectId;
  final ValueChanged<String?> onProjectChanged;

  const CompactProjectSelector({
    super.key,
    required this.selectedProjectId,
    required this.onProjectChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeProjectsAsync = ref.watch(activeProjectsProvider);

    return activeProjectsAsync.when(
      data: (projects) {
        final selectedProject = selectedProjectId != null
            ? projects.firstWhere(
                (p) => p.id == selectedProjectId,
                orElse: () => Project.create(name: 'Unknown'),
              )
            : null;

        return PopupMenuButton<String?>(
          initialValue: selectedProjectId,
          onSelected: onProjectChanged,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: selectedProject != null
                  ? _parseColor(selectedProject.color).withValues(alpha: 0.1)
                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: selectedProject != null
                  ? Border.all(
                      color: _parseColor(selectedProject.color).withValues(alpha: 0.1),
                    )
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedProject != null) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _parseColor(selectedProject.color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    selectedProject.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: _parseColor(selectedProject.color),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.folder_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Project',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 16,
                  color: selectedProject != null
                      ? _parseColor(selectedProject.color)
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          itemBuilder: (context) => [
            // Clear selection
            PopupMenuItem<String?>(
              value: null,
              child: Row(
                children: [
                  Icon(
                    Icons.clear,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'No project',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            // Divider
            const PopupMenuDivider(),
            
            // Projects
            ...projects.map((project) => PopupMenuItem<String?>(
              value: project.id,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _parseColor(project.color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      project.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
          ],
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 12,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: 4),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}