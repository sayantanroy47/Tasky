import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/project.dart';
import '../providers/project_providers.dart';

/// Dialog for creating or editing projects
/// 
/// Provides a form interface for project creation and editing
/// with validation and color selection.
class ProjectFormDialog extends ConsumerStatefulWidget {
  final Project? project; // null for create, non-null for edit
  final VoidCallback? onSuccess;

  const ProjectFormDialog({
    super.key,
    this.project,
    this.onSuccess,
  });

  @override
  ConsumerState<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends ConsumerState<ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _selectedDeadline;
  String _selectedColor = '#2196F3';
  
  final List<String> _colorOptions = [
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#FF9800', // Orange
    '#F44336', // Red
    '#9C27B0', // Purple
    '#00BCD4', // Cyan
    '#FFEB3B', // Yellow
    '#795548', // Brown
    '#607D8B', // Blue Grey
    '#E91E63', // Pink
  ];

  @override
  void initState() {
    super.initState();
    
    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description ?? '';
      _selectedColor = widget.project!.color;
      _selectedDeadline = widget.project!.deadline;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formState = ref.watch(projectFormProvider);
    
    return AlertDialog(
      title: Text(widget.project == null ? 'Create Project' : 'Edit Project'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  hintText: 'Enter project name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Project name is required';
                  }
                  return null;
                },
                onChanged: (value) {
                  ref.read(projectFormProvider.notifier).updateName(value);
                },
              ),
              
              const SizedBox(height: 16),
              
              // Project description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Enter project description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  ref.read(projectFormProvider.notifier).updateDescription(value);
                },
              ),
              
              const SizedBox(height: 16),
              
              // Color selection
              Text(
                'Project Color',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colorOptions.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                      ref.read(projectFormProvider.notifier).updateColor(color);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _parseColor(color),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: theme.colorScheme.primary,
                                width: 3,
                              )
                            : Border.all(
                                color: theme.colorScheme.outline,
                                width: 1,
                              ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: _getContrastColor(_parseColor(color)),
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // Deadline selection
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDeadline == null
                          ? 'No deadline set'
                          : 'Deadline: ${_formatDate(_selectedDeadline!)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _selectDeadline,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_selectedDeadline == null ? 'Set Deadline' : 'Change'),
                  ),
                  if (_selectedDeadline != null)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDeadline = null;
                        });
                        ref.read(projectFormProvider.notifier).updateDeadline(null);
                      },
                      icon: const Icon(Icons.clear),
                      tooltip: 'Remove deadline',
                    ),
                ],
              ),
              
              // Error message
              if (formState.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    formState.error!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: formState.isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: formState.isLoading ? null : _saveProject,
          child: formState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.project == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }

  Future<void> _selectDeadline() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDeadline = selectedDate;
      });
      ref.read(projectFormProvider.notifier).updateDeadline(selectedDate);
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ref.read(projectFormProvider.notifier).setLoading(true);

    try {
      if (widget.project == null) {
        // Create new project
        await ref.read(projectsProvider.notifier).createProject(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          color: _selectedColor,
          deadline: _selectedDeadline,
        );
      } else {
        // Update existing project
        final updatedProject = widget.project!.update(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          color: _selectedColor,
          deadline: _selectedDeadline,
        );
        
        await ref.read(projectsProvider.notifier).updateProject(updatedProject);
      }

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSuccess?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.project == null 
                  ? 'Project created successfully' 
                  : 'Project updated successfully',
            ),
          ),
        );
      }
    } catch (error) {
      ref.read(projectFormProvider.notifier).setError(error.toString());
    }
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  Color _getContrastColor(Color color) {
    // Calculate luminance to determine if we should use black or white text
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}