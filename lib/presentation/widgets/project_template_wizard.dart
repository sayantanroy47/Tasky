import 'package:flutter/material.dart';
import '../../domain/entities/project_template.dart' as domain;

/// Wizard widget for creating projects from templates
class ProjectTemplateWizard extends StatefulWidget {
  final domain.ProjectTemplate template;
  final Function(Map<String, dynamic>)? onProjectCreated;

  const ProjectTemplateWizard({
    super.key,
    required this.template,
    this.onProjectCreated,
  });

  @override
  State<ProjectTemplateWizard> createState() => _ProjectTemplateWizardState();
}

class _ProjectTemplateWizardState extends State<ProjectTemplateWizard> {
  int _currentStep = 0;
  final Map<String, dynamic> _values = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create ${widget.template.name}'),
      ),
      body: widget.template.isWizard
          ? _buildWizardView()
          : _buildSimpleView(),
    );
  }

  Widget _buildWizardView() {
    if (widget.template.wizardSteps.isEmpty) {
      return const Center(child: Text('No wizard steps configured'));
    }

    final currentStepData = widget.template.wizardSteps[_currentStep];
    final variables = widget.template.getVariablesForStep(currentStepData.id);

    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentStep + 1) / widget.template.wizardSteps.length,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentStepData.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (currentStepData.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    currentStepData.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: variables.length,
                    itemBuilder: (context, index) {
                      return _buildVariableInput(variables[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildSimpleView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configure ${widget.template.name}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: widget.template.variables.length,
              itemBuilder: (context, index) {
                return _buildVariableInput(widget.template.variables[index]);
              },
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildVariableInput(domain.TemplateVariable variable) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            variable.displayName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (variable.description != null) ...[
            const SizedBox(height: 4),
            Text(
              variable.description!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 8),
          _buildInputWidget(variable),
        ],
      ),
    );
  }

  Widget _buildInputWidget(domain.TemplateVariable variable) {
    switch (variable.type) {
      case domain.TemplateVariableType.text:
        return TextFormField(
          initialValue: _values[variable.key]?.toString() ?? variable.defaultValue?.toString(),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Enter ${variable.displayName.toLowerCase()}',
          ),
          onChanged: (value) => _values[variable.key] = value,
        );
      case domain.TemplateVariableType.choice:
        return DropdownButtonFormField<String>(
          initialValue: _values[variable.key]?.toString() ?? variable.defaultValue?.toString(),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: variable.options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) => setState(() => _values[variable.key] = value),
        );
      case domain.TemplateVariableType.boolean:
        return CheckboxListTile(
          title: Text(variable.displayName),
          value: _values[variable.key] as bool? ?? variable.defaultValue as bool? ?? false,
          onChanged: (value) => setState(() => _values[variable.key] = value),
        );
      default:
        return TextFormField(
          initialValue: _values[variable.key]?.toString() ?? variable.defaultValue?.toString(),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _values[variable.key] = value,
        );
    }
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0 || !widget.template.isWizard)
            TextButton(
              onPressed: _canGoBack() ? _goBack : null,
              child: const Text('Back'),
            )
          else
            const SizedBox(),
          ElevatedButton(
            onPressed: _canProceed() ? _proceed : null,
            child: Text(_isLastStep() ? 'Create Project' : 'Next'),
          ),
        ],
      ),
    );
  }

  bool _canGoBack() {
    return _currentStep > 0;
  }

  bool _canProceed() {
    // Check if required variables are filled
    if (widget.template.isWizard) {
      final currentStepData = widget.template.wizardSteps[_currentStep];
      final variables = widget.template.getVariablesForStep(currentStepData.id);
      
      for (final variable in variables) {
        if (variable.isRequired && (_values[variable.key] == null || _values[variable.key].toString().isEmpty)) {
          return false;
        }
      }
    } else {
      for (final variable in widget.template.variables) {
        if (variable.isRequired && (_values[variable.key] == null || _values[variable.key].toString().isEmpty)) {
          return false;
        }
      }
    }
    
    return true;
  }

  bool _isLastStep() {
    return !widget.template.isWizard || _currentStep >= widget.template.wizardSteps.length - 1;
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _proceed() {
    if (_isLastStep()) {
      _createProject();
    } else {
      setState(() => _currentStep++);
    }
  }

  void _createProject() {
    widget.onProjectCreated?.call(_values);
    Navigator.of(context).pop();
  }
}