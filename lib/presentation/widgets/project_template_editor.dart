import 'package:flutter/material.dart';
import '../../domain/entities/project_template.dart' as domain;

/// Editor widget for creating and editing project templates
class ProjectTemplateEditor extends StatefulWidget {
  final domain.ProjectTemplate? template;
  final Function(domain.ProjectTemplate)? onTemplateCreated;

  const ProjectTemplateEditor({
    super.key,
    this.template,
    this.onTemplateCreated,
  });

  @override
  State<ProjectTemplateEditor> createState() => _ProjectTemplateEditorState();
}

class _ProjectTemplateEditorState extends State<ProjectTemplateEditor> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _projectNameTemplateController = TextEditingController();
  
  domain.ProjectTemplateType _selectedType = domain.ProjectTemplateType.simple;
  int _difficultyLevel = 1;
  String _selectedColor = '#2196F3';

  @override
  void initState() {
    super.initState();
    if (widget.template != null) {
      _loadTemplate(widget.template!);
    }
  }

  void _loadTemplate(domain.ProjectTemplate template) {
    _nameController.text = template.name;
    _descriptionController.text = template.description ?? '';
    _projectNameTemplateController.text = template.projectNameTemplate;
    _selectedType = template.type;
    _difficultyLevel = template.difficultyLevel;
    _selectedColor = template.defaultColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _projectNameTemplateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template == null ? 'Create Template' : 'Edit Template'),
        actions: [
          TextButton(
            onPressed: _saveTemplate,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfo(),
              const SizedBox(height: 24),
              _buildTemplateSettings(),
              const SizedBox(height: 24),
              _buildTaskTemplates(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Template Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a template name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _projectNameTemplateController,
              decoration: const InputDecoration(
                labelText: 'Project Name Template',
                border: OutlineInputBorder(),
                helperText: 'Use {{variable}} for dynamic values',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a project name template';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Template Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<domain.ProjectTemplateType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Template Type',
                border: OutlineInputBorder(),
              ),
              items: domain.ProjectTemplateType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getTypeDisplayName(type)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: 16),
            Text('Difficulty Level: $_difficultyLevel'),
            Slider(
              value: _difficultyLevel.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: _difficultyLevel.toString(),
              onChanged: (value) => setState(() => _difficultyLevel = value.round()),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Color: '),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _showColorPicker,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse(_selectedColor.substring(1), radix: 16) + 0xFF000000),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTemplates() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Task Templates',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton.icon(
                  onPressed: _addTaskTemplate,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Task'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Task templates will be listed here'),
          ],
        ),
      ),
    );
  }

  String _getTypeDisplayName(domain.ProjectTemplateType type) {
    switch (type) {
      case domain.ProjectTemplateType.simple:
        return 'Simple';
      case domain.ProjectTemplateType.wizard:
        return 'Wizard';
      case domain.ProjectTemplateType.advanced:
        return 'Advanced';
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: Wrap(
          children: [
            '#2196F3', '#F44336', '#4CAF50', '#FF9800',
            '#9C27B0', '#00BCD4', '#E91E63', '#3F51B5',
          ].map((color) => GestureDetector(
            onTap: () {
              setState(() => _selectedColor = color);
              Navigator.of(context).pop();
            },
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Color(int.parse(color.substring(1), radix: 16) + 0xFF000000),
                shape: BoxShape.circle,
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _addTaskTemplate() {
    // TODO: Implement task template addition
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task template addition not implemented yet')),
    );
  }

  void _saveTemplate() {
    if (_formKey.currentState?.validate() ?? false) {
      final template = domain.ProjectTemplate.create(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        type: _selectedType,
        projectNameTemplate: _projectNameTemplateController.text.trim(),
        difficultyLevel: _difficultyLevel,
        defaultColor: _selectedColor,
      );
      
      widget.onTemplateCreated?.call(template);
      Navigator.of(context).pop();
    }
  }
}