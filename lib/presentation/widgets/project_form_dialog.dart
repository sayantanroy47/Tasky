import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';
import '../../core/theme/material3/motion_system.dart';
import '../../core/theme/typography_constants.dart';
import '../../domain/entities/project.dart';
import '../providers/project_providers.dart';
import 'glassmorphism_container.dart';
import 'standardized_app_bar.dart';
import 'standardized_text.dart';
import 'theme_background_widget.dart';

/// Full-screen page for creating and editing projects
/// 
/// Provides a modern, consistent form for entering project details including name,
/// description, color, and deadline following the app's design system.
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

class _ProjectFormDialogState extends ConsumerState<ProjectFormDialog> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Project properties
  String _selectedColor = '#2196F3'; // Default blue color
  DateTime? _selectedDeadline;
  bool _isLoading = false;
  
  bool get isEditing => widget.project != null;
  
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

    // Initialize animations
    _fadeController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium2,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Pre-populate if editing
    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description ?? '';
      _selectedColor = widget.project!.color;
      _selectedDeadline = widget.project!.deadline;
    }

    _fadeController.forward();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: StandardizedAppBar(
          title: isEditing ? 'Edit Project' : 'Create Project',
          actions: [
            SizedBox(
              width: 100,
              child: TextButton(
                onPressed: _isLoading ? null : _saveProject,
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditing ? 'Update' : 'Create'),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Project Name Section
                    _buildNameSection(context, theme),

                    const SizedBox(height: 20),

                    // Description Section
                    _buildDescriptionSection(context, theme),

                    const SizedBox(height: 20),

                    // Color Selection Section
                    _buildColorSection(context, theme),

                    const SizedBox(height: 20),

                    // Deadline Section
                    _buildDeadlineSection(context, theme),

                    const SizedBox(height: 32),

                    // Action Button
                    _buildActionButton(context, theme),

                    const SizedBox(height: 100), // Bottom padding
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.folder(),
                size: 24,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              StandardizedTextVariants.sectionHeader('Project Name'),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter a clear, descriptive project name...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              ),
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
            textInputAction: TextInputAction.next,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.fileText(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              StandardizedTextVariants.sectionHeader('Description'),
              const SizedBox(width: 8),
              StandardizedText(
                '(Optional)',
                style: StandardizedTextStyle.taskMeta,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Add project details, goals, or context...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              ),
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.newline,
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.palette(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              StandardizedTextVariants.sectionHeader('Project Color'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: (MediaQuery.of(context).size.width / 60).floor().clamp(4, 8),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _colorOptions.length,
              itemBuilder: (context, index) {
                final color = _colorOptions[index];
                final isSelected = color == _selectedColor;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _selectedColor = color),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
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
                                width: 1,
                              ),
                      ),
                      child: isSelected
                          ? Icon(
                              PhosphorIcons.check(),
                              color: _parseColor(color).computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.calendar(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              StandardizedTextVariants.sectionHeader('Deadline'),
              const SizedBox(width: 8),
              StandardizedText(
                '(Optional)',
                style: StandardizedTextStyle.taskMeta,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectDeadline,
                  icon: Icon(PhosphorIcons.calendar()),
                  label: Text(
                    _selectedDeadline == null
                        ? 'Select Deadline'
                        : _formatDate(_selectedDeadline!),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (_selectedDeadline != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => setState(() => _selectedDeadline = null),
                  icon: Icon(PhosphorIcons.x()),
                  tooltip: 'Remove deadline',
                ),
              ],
            ],
          ),
          if (_selectedDeadline != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _parseColor(_selectedColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: StandardizedText(
                'Deadline: ${_formatDate(_selectedDeadline!)}',
                style: StandardizedTextStyle.labelMedium,
                color: _parseColor(_selectedColor),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveProject,
        icon: _isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(isEditing ? PhosphorIcons.floppyDisk() : PhosphorIcons.plus()),
        label: Text(_isLoading 
            ? (isEditing ? 'Updating...' : 'Creating...') 
            : (isEditing ? 'Update Project' : 'Create Project')),
        style: ElevatedButton.styleFrom(
          backgroundColor: _parseColor(_selectedColor),
          foregroundColor: _parseColor(_selectedColor).computeLuminance() > 0.5
              ? Colors.black
              : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
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

