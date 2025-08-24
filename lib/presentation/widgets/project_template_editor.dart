import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/phosphor_icons.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/theme/typography_constants.dart';
import '../../domain/entities/project_template.dart';
import '../../domain/entities/task_template.dart';
import '../../domain/entities/task_enums.dart';
import 'glassmorphism_container.dart';

/// Comprehensive project template editor
/// 
/// Allows users to create and edit custom project templates with
/// variables, wizard steps, and task templates.
class ProjectTemplateEditor extends StatefulWidget {
  final ProjectTemplate? initialTemplate;
  final Function(ProjectTemplate template) onTemplateCreated;
  final VoidCallback? onCancel;
  final List<TaskTemplate>? availableTaskTemplates;

  const ProjectTemplateEditor({
    super.key,
    this.initialTemplate,
    required this.onTemplateCreated,
    this.onCancel,
    this.availableTaskTemplates,
  });

  @override
  State<ProjectTemplateEditor> createState() => _ProjectTemplateEditorState();
}

class _ProjectTemplateEditorState extends State<ProjectTemplateEditor>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Basic info
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _projectNameTemplateController = TextEditingController();
  final _projectDescriptionTemplateController = TextEditingController();
  
  ProjectTemplateType _selectedType = ProjectTemplateType.simple;
  int _difficultyLevel = 1;
  int? _estimatedHours;
  String _defaultColor = '#2196F3';
  List<String> _industryTags = [];
  List<String> _tags = [];

  // Variables
  List<TemplateVariable> _variables = [];
  
  // Wizard steps
  List<TemplateWizardStep> _wizardSteps = [];
  
  // Tasks and dependencies
  List<TaskTemplate> _selectedTaskTemplates = [];
  Map<String, List<String>> _taskDependencies = {};
  
  // Milestones
  List<ProjectMilestone> _milestones = [];

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 5, vsync: this);
    
    if (widget.initialTemplate != null) {
      _populateFromTemplate(widget.initialTemplate!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _shortDescriptionController.dispose();
    _projectNameTemplateController.dispose();
    _projectDescriptionTemplateController.dispose();
    super.dispose();
  }

  void _populateFromTemplate(ProjectTemplate template) {
    _nameController.text = template.name;
    _descriptionController.text = template.description ?? '';
    _shortDescriptionController.text = template.shortDescription ?? '';
    _projectNameTemplateController.text = template.projectNameTemplate;
    _projectDescriptionTemplateController.text = template.projectDescriptionTemplate ?? '';
    
    _selectedType = template.type;
    _difficultyLevel = template.difficultyLevel;
    _estimatedHours = template.estimatedHours;
    _defaultColor = template.defaultColor;
    _industryTags = List.from(template.industryTags);
    _tags = List.from(template.tags);
    
    _variables = List.from(template.variables);
    _wizardSteps = List.from(template.wizardSteps);
    _selectedTaskTemplates = List.from(template.taskTemplates);
    _taskDependencies = Map.from(template.taskDependencies);
    _milestones = List.from(template.milestones);
  }

  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final template = widget.initialTemplate?.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        shortDescription: _shortDescriptionController.text.trim().isEmpty
            ? null
            : _shortDescriptionController.text.trim(),
        type: _selectedType,
        difficultyLevel: _difficultyLevel,
        estimatedHours: _estimatedHours,
        projectNameTemplate: _projectNameTemplateController.text.trim(),
        projectDescriptionTemplate: _projectDescriptionTemplateController.text.trim().isEmpty
            ? null
            : _projectDescriptionTemplateController.text.trim(),
        defaultColor: _defaultColor,
        industryTags: _industryTags,
        tags: _tags,
        variables: _variables,
        wizardSteps: _wizardSteps,
        taskTemplates: _selectedTaskTemplates,
        taskDependencies: _taskDependencies,
        milestones: _milestones,
        updatedAt: DateTime.now(),
      ) ?? ProjectTemplate.create(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        shortDescription: _shortDescriptionController.text.trim().isEmpty
            ? null
            : _shortDescriptionController.text.trim(),
        type: _selectedType,
        difficultyLevel: _difficultyLevel,
        estimatedHours: _estimatedHours,
        projectNameTemplate: _projectNameTemplateController.text.trim(),
        projectDescriptionTemplate: _projectDescriptionTemplateController.text.trim().isEmpty
            ? null
            : _projectDescriptionTemplateController.text.trim(),
        defaultColor: _defaultColor,
        industryTags: _industryTags,
        tags: _tags,
        variables: _variables,
        wizardSteps: _wizardSteps,
        taskTemplates: _selectedTaskTemplates,
        taskDependencies: _taskDependencies,
        milestones: _milestones,
      );

      widget.onTemplateCreated(template);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving template: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Dialog.fullscreen(
      backgroundColor: theme.colorScheme.surface,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(theme),
        body: Column(
          children: [
            _buildTabBar(theme),
            Expanded(
              child: Form(
                key: _formKey,
                child: _buildTabContent(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(PhosphorIcons.x()),
        onPressed: widget.onCancel,
      ),
      title: Text(
        widget.initialTemplate != null 
            ? 'Edit Template' 
            : 'Create Template',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : widget.onCancel,
          child: const Text('Cancel'),
        ),
        const SizedBox(width: TypographyConstants.paddingSmall),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _saveTemplate,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(PhosphorIcons.check()),
          label: Text(widget.initialTemplate != null ? 'Update' : 'Create'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(width: TypographyConstants.paddingMedium),
      ],
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: TypographyConstants.paddingMedium),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        indicatorColor: theme.colorScheme.primary,
        tabs: [
          Tab(
            icon: Icon(PhosphorIcons.info()),
            text: 'Basic Info',
          ),
          Tab(
            icon: Icon(PhosphorIcons.textbox()),
            text: 'Variables',
          ),
          Tab(
            icon: Icon(PhosphorIcons.magicWand()),
            text: 'Wizard Steps',
          ),
          Tab(
            icon: Icon(PhosphorIcons.listChecks()),
            text: 'Tasks',
          ),
          Tab(
            icon: Icon(PhosphorIcons.flag()),
            text: 'Milestones',
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(ThemeData theme) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildBasicInfoTab(theme),
        _buildVariablesTab(theme),
        _buildWizardStepsTab(theme),
        _buildTasksTab(theme),
        _buildMilestonesTab(theme),
      ],
    );
  }

  Widget _buildBasicInfoTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TypographyConstants.paddingLarge),
      child: GlassmorphismContainer(
        level: GlassLevel.content,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
        padding: const EdgeInsets.all(TypographyConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Template Information',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: TypographyConstants.paddingLarge),
            
            // Template name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Template Name *',
                hintText: 'Enter a descriptive name for your template',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Template name is required';
                }
                return null;
              },
            ),
            
            const SizedBox(height: TypographyConstants.paddingMedium),
            
            // Short description
            TextFormField(
              controller: _shortDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Short Description',
                hintText: 'Brief description for template cards',
              ),
              maxLines: 2,
            ),
            
            const SizedBox(height: TypographyConstants.paddingMedium),
            
            // Full description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Detailed description of what this template creates',
              ),
              maxLines: 4,
            ),
            
            const SizedBox(height: TypographyConstants.paddingLarge),
            
            // Template configuration
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ProjectTemplateType>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Template Type',
                    ),
                    items: ProjectTemplateType.values.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
                  ),
                ),
                
                const SizedBox(width: TypographyConstants.paddingMedium),
                
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _difficultyLevel,
                    decoration: const InputDecoration(
                      labelText: 'Difficulty Level',
                    ),
                    items: List.generate(5, (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Row(
                        children: [
                          Text('${index + 1}'),
                          const SizedBox(width: TypographyConstants.paddingSmall),
                          Row(
                            children: List.generate(5, (starIndex) => Icon(
                              PhosphorIcons.star(
                                starIndex <= index
                                    ? PhosphorIconsStyle.fill
                                    : PhosphorIconsStyle.regular,
                              ),
                              size: 12,
                              color: starIndex <= index
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            )),
                          ),
                        ],
                      ),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _difficultyLevel = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: TypographyConstants.paddingMedium),
            
            // Estimated hours
            TextFormField(
              initialValue: _estimatedHours?.toString() ?? '',
              decoration: const InputDecoration(
                labelText: 'Estimated Hours',
                hintText: 'Estimated time to complete project',
                suffixText: 'hours',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _estimatedHours = int.tryParse(value);
              },
            ),
            
            const SizedBox(height: TypographyConstants.paddingLarge),
            
            Text(
              'Project Configuration',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: TypographyConstants.paddingMedium),
            
            // Project name template
            TextFormField(
              controller: _projectNameTemplateController,
              decoration: const InputDecoration(
                labelText: 'Project Name Template *',
                hintText: 'Use {{variable_name}} for substitution',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Project name template is required';
                }
                return null;
              },
            ),
            
            const SizedBox(height: TypographyConstants.paddingMedium),
            
            // Project description template
            TextFormField(
              controller: _projectDescriptionTemplateController,
              decoration: const InputDecoration(
                labelText: 'Project Description Template',
                hintText: 'Use {{variable_name}} for substitution',
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: TypographyConstants.paddingMedium),
            
            // Color picker
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _defaultColor,
                    decoration: const InputDecoration(
                      labelText: 'Default Color',
                      hintText: '#2196F3',
                    ),
                    onChanged: (value) {
                      if (RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(value)) {
                        setState(() {
                          _defaultColor = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: TypographyConstants.paddingMedium),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(int.parse(_defaultColor.substring(1), radix: 16) + 0xFF000000),
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: TypographyConstants.paddingLarge),
            
            // Tags section
            _buildTagsSection(theme, 'Industry Tags', _industryTags, (tags) {
              setState(() {
                _industryTags = tags;
              });
            }),
            
            const SizedBox(height: TypographyConstants.paddingMedium),
            
            _buildTagsSection(theme, 'Tags', _tags, (tags) {
              setState(() {
                _tags = tags;
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(
    ThemeData theme,
    String title,
    List<String> tags,
    Function(List<String>) onTagsChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: TypographyConstants.paddingSmall),
        Wrap(
          spacing: TypographyConstants.paddingSmall,
          runSpacing: TypographyConstants.paddingSmall,
          children: [
            ...tags.map((tag) => Chip(
              label: Text(tag),
              deleteIcon: Icon(PhosphorIcons.x(), size: 16),
              onDeleted: () {
                final newTags = List<String>.from(tags)..remove(tag);
                onTagsChanged(newTags);
              },
            )),
            ActionChip(
              avatar: Icon(PhosphorIcons.plus(), size: 16),
              label: const Text('Add Tag'),
              onPressed: () => _showAddTagDialog(theme, onTagsChanged),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVariablesTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TypographyConstants.paddingLarge),
      child: GlassmorphismContainer(
        level: GlassLevel.content,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
        padding: const EdgeInsets.all(TypographyConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Template Variables',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _addVariable(),
                  icon: Icon(PhosphorIcons.plus()),
                  label: const Text('Add Variable'),
                ),
              ],
            ),
            const SizedBox(height: TypographyConstants.paddingMedium),
            
            if (_variables.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      PhosphorIcons.textbox(),
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: TypographyConstants.paddingMedium),
                    Text(
                      'No variables added yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(_variables.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: TypographyConstants.paddingMedium),
                  child: _buildVariableCard(theme, index),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildVariableCard(ThemeData theme, int index) {
    final variable = _variables[index];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    variable.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Chip(
                  label: Text(variable.type.name.toUpperCase()),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 12,
                  ),
                ),
                IconButton(
                  icon: Icon(PhosphorIcons.pencil()),
                  onPressed: () => _editVariable(index),
                ),
                IconButton(
                  icon: Icon(PhosphorIcons.trash()),
                  onPressed: () => _removeVariable(index),
                ),
              ],
            ),
            Text(
              'Key: {{${variable.key}}}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (variable.description != null) ...[
              const SizedBox(height: TypographyConstants.paddingSmall),
              Text(
                variable.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (variable.isRequired)
              Padding(
                padding: const EdgeInsets.only(top: TypographyConstants.paddingSmall),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.asteriskSimple(),
                      size: 12,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Required',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWizardStepsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TypographyConstants.paddingLarge),
      child: GlassmorphismContainer(
        level: GlassLevel.content,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
        padding: const EdgeInsets.all(TypographyConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Wizard Steps',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_selectedType == ProjectTemplateType.wizard)
                  ElevatedButton.icon(
                    onPressed: () => _addWizardStep(),
                    icon: Icon(PhosphorIcons.plus()),
                    label: const Text('Add Step'),
                  ),
              ],
            ),
            const SizedBox(height: TypographyConstants.paddingMedium),
            
            if (_selectedType != ProjectTemplateType.wizard)
              Container(
                padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.info(),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: TypographyConstants.paddingMedium),
                    Expanded(
                      child: Text(
                        'Wizard steps are only available for Wizard type templates',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (_wizardSteps.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      PhosphorIcons.magicWand(),
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: TypographyConstants.paddingMedium),
                    Text(
                      'No wizard steps added yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _wizardSteps.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) newIndex--;
                    final step = _wizardSteps.removeAt(oldIndex);
                    _wizardSteps.insert(newIndex, step);
                    
                    // Update order values
                    for (int i = 0; i < _wizardSteps.length; i++) {
                      _wizardSteps[i] = TemplateWizardStep(
                        id: _wizardSteps[i].id,
                        title: _wizardSteps[i].title,
                        description: _wizardSteps[i].description,
                        variableKeys: _wizardSteps[i].variableKeys,
                        showCondition: _wizardSteps[i].showCondition,
                        order: i,
                        isOptional: _wizardSteps[i].isOptional,
                        iconName: _wizardSteps[i].iconName,
                      );
                    }
                  });
                },
                itemBuilder: (context, index) {
                  return _buildWizardStepCard(theme, index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWizardStepCard(ThemeData theme, int index) {
    final step = _wizardSteps[index];
    
    return Card(
      key: Key(step.id),
      child: Padding(
        padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIcons.dotsSixVertical()),
                const SizedBox(width: TypographyConstants.paddingSmall),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${step.order + 1}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: TypographyConstants.paddingMedium),
                Expanded(
                  child: Text(
                    step.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(PhosphorIcons.pencil()),
                  onPressed: () => _editWizardStep(index),
                ),
                IconButton(
                  icon: Icon(PhosphorIcons.trash()),
                  onPressed: () => _removeWizardStep(index),
                ),
              ],
            ),
            if (step.description != null) ...[
              const SizedBox(height: TypographyConstants.paddingSmall),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Text(
                  step.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            if (step.variableKeys.isNotEmpty) ...[
              const SizedBox(height: TypographyConstants.paddingSmall),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Wrap(
                  spacing: TypographyConstants.paddingSmall,
                  children: step.variableKeys.map((key) => Chip(
                    label: Text(key),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    labelStyle: theme.textTheme.labelSmall,
                  )).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTasksTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TypographyConstants.paddingLarge),
      child: GlassmorphismContainer(
        level: GlassLevel.content,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
        padding: const EdgeInsets.all(TypographyConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Task Templates',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _addTaskTemplate(),
                  icon: Icon(PhosphorIcons.plus()),
                  label: const Text('Add Tasks'),
                ),
              ],
            ),
            const SizedBox(height: TypographyConstants.paddingMedium),
            
            if (_selectedTaskTemplates.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      PhosphorIcons.listChecks(),
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: TypographyConstants.paddingMedium),
                    Text(
                      'No task templates added yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(_selectedTaskTemplates.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: TypographyConstants.paddingMedium),
                  child: _buildTaskTemplateCard(theme, index),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTemplateCard(ThemeData theme, int index) {
    final taskTemplate = _selectedTaskTemplates[index];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    taskTemplate.titleTemplate,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Chip(
                  label: Text(taskTemplate.priority.name.toUpperCase()),
                  backgroundColor: _getPriorityColor(theme, taskTemplate.priority),
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontSize: 12,
                  ),
                ),
                IconButton(
                  icon: Icon(PhosphorIcons.trash()),
                  onPressed: () => _removeTaskTemplate(index),
                ),
              ],
            ),
            if (taskTemplate.descriptionTemplate != null) ...[
              const SizedBox(height: TypographyConstants.paddingSmall),
              Text(
                taskTemplate.descriptionTemplate!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (taskTemplate.estimatedDuration != null) ...[
              const SizedBox(height: TypographyConstants.paddingSmall),
              Row(
                children: [
                  Icon(
                    PhosphorIcons.clock(),
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${taskTemplate.estimatedDuration} minutes',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonesTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TypographyConstants.paddingLarge),
      child: GlassmorphismContainer(
        level: GlassLevel.content,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusMedium),
        padding: const EdgeInsets.all(TypographyConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Project Milestones',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _addMilestone(),
                  icon: Icon(PhosphorIcons.plus()),
                  label: const Text('Add Milestone'),
                ),
              ],
            ),
            const SizedBox(height: TypographyConstants.paddingMedium),
            
            if (_milestones.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      PhosphorIcons.flag(),
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: TypographyConstants.paddingMedium),
                    Text(
                      'No milestones added yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(_milestones.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: TypographyConstants.paddingMedium),
                  child: _buildMilestoneCard(theme, index),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneCard(ThemeData theme, int index) {
    final milestone = _milestones[index];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (milestone.iconName != null)
                  Icon(
                    PhosphorIconConstants.getIconByName(milestone.iconName!),
                    color: theme.colorScheme.primary,
                  )
                else
                  Icon(
                    PhosphorIcons.flag(),
                    color: theme.colorScheme.primary,
                  ),
                const SizedBox(width: TypographyConstants.paddingMedium),
                Expanded(
                  child: Text(
                    milestone.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Chip(
                  label: Text('Day ${milestone.dayOffset}'),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  labelStyle: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontSize: 12,
                  ),
                ),
                IconButton(
                  icon: Icon(PhosphorIcons.pencil()),
                  onPressed: () => _editMilestone(index),
                ),
                IconButton(
                  icon: Icon(PhosphorIcons.trash()),
                  onPressed: () => _removeMilestone(index),
                ),
              ],
            ),
            if (milestone.description != null) ...[
              const SizedBox(height: TypographyConstants.paddingSmall),
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Text(
                  milestone.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper methods
  Color _getPriorityColor(ThemeData theme, TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return theme.colorScheme.tertiary.withValues(alpha: 0.1);
      case TaskPriority.medium:
        return theme.colorScheme.primary.withValues(alpha: 0.1);
      case TaskPriority.high:
        return theme.colorScheme.secondary.withValues(alpha: 0.1);
      case TaskPriority.urgent:
        return theme.colorScheme.error.withValues(alpha: 0.1);
    }
  }

  // Action methods - simplified implementations
  void _addVariable() {
    // Show variable creation dialog
    // For brevity, this would show a complex form dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Variable creation dialog would open here')),
    );
  }

  void _editVariable(int index) {
    // Show variable editing dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Variable editing dialog would open here')),
    );
  }

  void _removeVariable(int index) {
    setState(() {
      _variables.removeAt(index);
    });
  }

  void _addWizardStep() {
    setState(() {
      _wizardSteps.add(TemplateWizardStep(
        id: const Uuid().v4(),
        title: 'New Step',
        order: _wizardSteps.length,
        variableKeys: const [],
      ));
    });
  }

  void _editWizardStep(int index) {
    // Show wizard step editing dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wizard step editing dialog would open here')),
    );
  }

  void _removeWizardStep(int index) {
    setState(() {
      _wizardSteps.removeAt(index);
      
      // Update order values
      for (int i = 0; i < _wizardSteps.length; i++) {
        _wizardSteps[i] = TemplateWizardStep(
          id: _wizardSteps[i].id,
          title: _wizardSteps[i].title,
          description: _wizardSteps[i].description,
          variableKeys: _wizardSteps[i].variableKeys,
          showCondition: _wizardSteps[i].showCondition,
          order: i,
          isOptional: _wizardSteps[i].isOptional,
          iconName: _wizardSteps[i].iconName,
        );
      }
    });
  }

  void _addTaskTemplate() {
    // Show task template selection dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task template selection dialog would open here')),
    );
  }

  void _removeTaskTemplate(int index) {
    setState(() {
      _selectedTaskTemplates.removeAt(index);
    });
  }

  void _addMilestone() {
    setState(() {
      _milestones.add(ProjectMilestone(
        id: const Uuid().v4(),
        name: 'New Milestone',
        dayOffset: 7,
      ));
    });
  }

  void _editMilestone(int index) {
    // Show milestone editing dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Milestone editing dialog would open here')),
    );
  }

  void _removeMilestone(int index) {
    setState(() {
      _milestones.removeAt(index);
    });
  }

  void _showAddTagDialog(ThemeData theme, Function(List<String>) onTagsChanged) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tag name',
            hintText: 'Enter tag name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final tag = controller.text.trim();
              if (tag.isNotEmpty) {
                final currentTags = _tags.contains(tag) ? _tags : [..._tags, tag];
                onTagsChanged(currentTags);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}