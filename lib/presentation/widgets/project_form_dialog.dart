import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/project.dart';
import '../providers/project_providers.dart';
import '../../core/theme/typography_constants.dart';
import 'glassmorphism_container.dart';
import '../../core/design_system/design_tokens.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Dialog for creating and editing projects
/// 
/// Provides a form for entering project details including name,
/// description, color, and deadline.
class ProjectFormDialog extends ConsumerStatefulWidget {
  final Project? project; // null for creating new project
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
  
  String _selectedColor = '#2196F3'; // Default blue color
  DateTime? _selectedDeadline;
  bool _isLoading = false;
  
  // Predefined color options
  final List<String> _colorOptions = [
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#FF9800', // Orange
    '#F44336', // Red
    '#9C27B0', // Purple
    '#607D8B', // Blue Grey
    '#795548', // Brown
    '#E91E63', // Pink
    '#00BCD4', // Cyan
    '#8BC34A', // Light Green
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
    final isEditing = widget.project != null;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        padding: const EdgeInsets.all(24),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      isEditing ? PhosphorIcons.pencil() : PhosphorIcons.plus(),
                      color: _parseColor(_selectedColor),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isEditing ? 'Edit Project' : 'Create Project',
                        style: theme.textTheme.headlineSmall?.copyWith(
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
                
                const SizedBox(height: 24),
                
                // Project name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Project Name *',
                    hintText: 'Enter project name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                    ),
                    prefixIcon: Icon(PhosphorIcons.folder()),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Project name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Project name must be at least 2 characters';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                
                const SizedBox(height: 16),
                
                // Project description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter project description (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                    ),
                    prefixIcon: Icon(PhosphorIcons.fileText()),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                
                const SizedBox(height: 16),
                
                // Color selection
                Text(
                  'Project Color',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
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
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _parseColor(color),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: theme.colorScheme.onSurface,
                                  width: 3,
                                )
                              : Border.all(
                                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                                ),
                        ),
                        child: isSelected
                            ? Icon(
                                PhosphorIcons.check(),
                                color: _parseColor(color).computeLuminance() > 0.5
                                    ? Colors.black
                                    : Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Deadline selection
                InkWell(
                  onTap: _selectDeadline,
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
                          PhosphorIcons.calendar(),
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Deadline',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                _selectedDeadline == null
                                    ? 'No deadline set'
                                    : _formatDate(_selectedDeadline!),
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        if (_selectedDeadline != null)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDeadline = null;
                              });
                            },
                            icon: Icon(PhosphorIcons.x()),
                            tooltip: 'Remove deadline',
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _parseColor(_selectedColor),
                        foregroundColor: _parseColor(_selectedColor).computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEditing ? 'Update' : 'Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _selectDeadline() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)), // 2 years from now
    );
    
    if (selectedDate != null) {
      setState(() {
        _selectedDeadline = selectedDate;
      });
    }
  }
  
  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Store context references before async operations
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      
      if (widget.project != null) {
        // Update existing project
        final updatedProject = widget.project!.copyWith(
          name: name,
          description: description.isEmpty ? null : description,
          color: _selectedColor,
          deadline: _selectedDeadline,
          updatedAt: DateTime.now(),
        );
        
        await ref.read(projectsProvider.notifier).updateProject(updatedProject);
      } else {
        // Create new project
        await ref.read(projectsProvider.notifier).createProject(
          name: name,
          description: description.isEmpty ? null : description,
          color: _selectedColor,
          deadline: _selectedDeadline,
        );
      }
      
      if (context.mounted) {
        navigator.pop();
        widget.onSuccess?.call();
        
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              widget.project != null
                  ? 'Project updated successfully'
                  : 'Project created successfully',
            ),
            backgroundColor: _parseColor(_selectedColor),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

