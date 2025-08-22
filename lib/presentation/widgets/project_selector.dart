import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography_constants.dart';

import '../../domain/entities/project.dart';
import '../providers/project_providers.dart';
import 'glassmorphism_container.dart';
import '../../core/design_system/design_tokens.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Widget for selecting a project from a list
/// 
/// Provides a dropdown or bottom sheet for selecting a project,
/// with options to create a new project or clear selection.
class ProjectSelector extends ConsumerWidget {
  final String? selectedProjectId;
  final Function(Project?) onProjectSelected;
  final bool allowNone;
  final String? hintText;
  final bool showCreateOption;
  
  const ProjectSelector({
    super.key,
    this.selectedProjectId,
    required this.onProjectSelected,
    this.allowNone = true,
    this.hintText,
    this.showCreateOption = true,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final projectsAsync = ref.watch(projectsProvider);
    
    return projectsAsync.when(
      data: (projects) {
        // Filter to only active projects
        final activeProjects = projects.where((p) => !p.isArchived).toList();
        
        final selectedProject = selectedProjectId != null
            ? activeProjects.firstWhere(
                (p) => p.id == selectedProjectId,
                orElse: () => Project(
                  id: '',
                  name: 'Unknown Project',
                  color: '#2196F3',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              )
            : null;
        
        return InkWell(
          onTap: () => _showProjectSelectionBottomSheet(context, ref, activeProjects),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.folder(),
                  color: selectedProject != null
                      ? _parseColor(selectedProject.color)
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Project',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        selectedProject?.name ?? hintText ?? 'Select a project',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: selectedProject != null
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  PhosphorIcons.caretDown(),
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading projects...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      error: (error, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.error.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        ),
        child: Row(
          children: [
            Icon(
              PhosphorIcons.warningCircle(),
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Error loading projects',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showProjectSelectionBottomSheet(BuildContext context, WidgetRef ref, List<Project> projects) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GlassmorphismContainer(
        level: GlassLevel.floating,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(PhosphorIcons.folder()),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Select Project',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(PhosphorIcons.x()),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // None option
            if (allowNone)
              ListTile(
                leading: Icon(PhosphorIcons.x()),
                title: const Text('No Project'),
                subtitle: const Text('Don\'t assign to any project'),
                onTap: () {
                  onProjectSelected(null);
                  Navigator.of(context).pop();
                },
                selected: selectedProjectId == null,
              ),
            
            // Project list
            if (projects.isEmpty)
              Padding(padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(PhosphorIcons.folder(), size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No Projects Available',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const Text(
                      'Create a project first to assign tasks',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ...projects.map((project) => ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _parseColor(project.color),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(project.name),
                subtitle: project.description != null && project.description!.isNotEmpty
                    ? Text(
                        project.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: project.id == selectedProjectId
                    ? Icon(
                        PhosphorIcons.check(),
                        color: _parseColor(project.color),
                      )
                    : null,
                onTap: () {
                  onProjectSelected(project);
                  Navigator.of(context).pop();
                },
                selected: project.id == selectedProjectId,
              )),
            
            // Create new project option
            if (showCreateOption) ...[
              const Divider(),
              ListTile(
                leading: Icon(PhosphorIcons.plus()),
                title: const Text('Create New Project'),
                subtitle: const Text('Create a new project for this task'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showCreateProjectDialog(context, ref);
                },
              ),
            ],
            
            // Bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
  
  void _showCreateProjectDialog(BuildContext context, WidgetRef ref) {
    // This would show the ProjectFormDialog
    // For now, show a simple snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Project creation coming soon'),
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

/// Compact version of project selector for forms
class CompactProjectSelector extends ConsumerWidget {
  final String? selectedProjectId;
  final Function(Project?) onProjectSelected;
  final bool allowNone;
  
  const CompactProjectSelector({
    super.key,
    this.selectedProjectId,
    required this.onProjectSelected,
    this.allowNone = true,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final projectsAsync = ref.watch(projectsProvider);
    
    return projectsAsync.when(
      data: (projects) {
        final activeProjects = projects.where((p) => !p.isArchived).toList();
        
        return DropdownButtonFormField<String?>(
          initialValue: selectedProjectId,
          decoration: InputDecoration(
            labelText: 'Project',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            ),
            prefixIcon: Icon(PhosphorIcons.folder()),
          ),
          items: [
            if (allowNone)
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('No Project'),
              ),
            ...activeProjects.map((project) => DropdownMenuItem<String?>(
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
          onChanged: (value) {
            if (value == null) {
              onProjectSelected(null);
            } else {
              final project = activeProjects.firstWhere((p) => p.id == value);
              onProjectSelected(project);
            }
          },
        );
      },
      loading: () => TextFormField(
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Project',
          hintText: 'Loading projects...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          ),
          prefixIcon: const SizedBox(width: 24,
            height: 24,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      error: (error, _) => TextFormField(
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Project',
          hintText: 'Error loading projects',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
          ),
          prefixIcon: Icon(
            PhosphorIcons.warningCircle(),
            color: theme.colorScheme.error,
          ),
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


