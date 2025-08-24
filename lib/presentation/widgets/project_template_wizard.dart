import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/phosphor_icons.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/theme/typography_constants.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_template.dart';
import 'glassmorphism_container.dart';

/// Comprehensive project template wizard for guided project creation
/// 
/// This widget provides a step-by-step wizard interface for creating projects
/// from templates with variable substitution and conditional logic.
class ProjectTemplateWizard extends StatefulWidget {
  final ProjectTemplate template;
  final Function(Project project) onProjectCreated;
  final VoidCallback? onCancel;
  final bool showPreview;

  const ProjectTemplateWizard({
    super.key,
    required this.template,
    required this.onProjectCreated,
    this.onCancel,
    this.showPreview = true,
  });

  @override
  State<ProjectTemplateWizard> createState() => _ProjectTemplateWizardState();
}

class _ProjectTemplateWizardState extends State<ProjectTemplateWizard>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  int _currentStepIndex = 0;
  final Map<String, dynamic> _variableValues = {};
  final Map<String, String> _validationErrors = {};
  bool _isLoading = false;

  // Cache for dynamic variables and steps
  List<TemplateWizardStep> _visibleSteps = [];
  List<TemplateVariable> _currentStepVariables = [];

  @override
  void initState() {
    super.initState();
    
    _pageController = PageController();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _initializeWizard();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _initializeWizard() {
    // Initialize with template's default values
    for (final variable in widget.template.variables) {
      if (variable.defaultValue != null) {
        _variableValues[variable.key] = variable.defaultValue;
      }
    }

    _updateVisibleSteps();
    _updateProgress();
  }

  void _updateVisibleSteps() {
    _visibleSteps = widget.template.wizardSteps.where((step) {
      return _shouldShowStep(step);
    }).toList();

    if (_visibleSteps.isNotEmpty && _currentStepIndex < _visibleSteps.length) {
      _currentStepVariables = widget.template.getVariablesForStep(
        _visibleSteps[_currentStepIndex].id,
      );
    }
  }

  bool _shouldShowStep(TemplateWizardStep step) {
    if (step.showCondition == null) return true;
    
    // Simple condition evaluation - in production this would be more robust
    final condition = step.showCondition!;
    for (final entry in _variableValues.entries) {
      final placeholder = '{{${entry.key}}}';
      if (condition.contains(placeholder)) {
        final conditionWithValue = condition.replaceAll(
          placeholder, 
          entry.value.toString(),
        );
        return conditionWithValue.contains('true') || 
               !conditionWithValue.contains('false');
      }
    }
    
    return true;
  }

  void _updateProgress() {
    final progress = _visibleSteps.isNotEmpty 
        ? (_currentStepIndex + 1) / _visibleSteps.length 
        : 0.0;
    _progressController.animateTo(progress);
  }

  bool _validateCurrentStep() {
    _validationErrors.clear();
    bool isValid = true;

    for (final variable in _currentStepVariables) {
      final value = _variableValues[variable.key];

      // Check required fields
      if (variable.isRequired && (value == null || value.toString().isEmpty)) {
        _validationErrors[variable.key] = '${variable.displayName} is required';
        isValid = false;
        continue;
      }

      // Skip validation if value is null/empty and not required
      if (value == null || value.toString().isEmpty) continue;

      // Type-specific validation
      if (!_validateVariableValue(variable, value)) {
        _validationErrors[variable.key] = variable.validationError ?? 
            'Invalid value for ${variable.displayName}';
        isValid = false;
      }
    }

    return isValid;
  }

  bool _validateVariableValue(TemplateVariable variable, dynamic value) {
    switch (variable.type) {
      case TemplateVariableType.text:
        if (value is! String) return false;
        if (variable.validationPattern != null) {
          return RegExp(variable.validationPattern!).hasMatch(value);
        }
        return true;

      case TemplateVariableType.number:
        if (value is! num) return false;
        if (variable.minValue != null && value < variable.minValue) return false;
        if (variable.maxValue != null && value > variable.maxValue) return false;
        return true;

      case TemplateVariableType.date:
        if (value is! DateTime) return false;
        if (variable.minValue != null && 
            value.isBefore(variable.minValue as DateTime)) {
          return false;
        }
        if (variable.maxValue != null && 
            value.isAfter(variable.maxValue as DateTime)) {
          return false;
        }
        return true;

      case TemplateVariableType.choice:
        if (value is! String) return false;
        return variable.options.contains(value);

      case TemplateVariableType.multiChoice:
        if (value is! List) return false;
        return (value).every((item) => variable.options.contains(item));

      case TemplateVariableType.boolean:
        return value is bool;
    }
  }

  void _nextStep() {
    if (!_validateCurrentStep()) {
      setState(() {}); // Trigger rebuild to show validation errors
      return;
    }

    if (_currentStepIndex < _visibleSteps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _updateVisibleSteps();
        _updateProgress();
      });
      
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _createProject();
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
        _updateVisibleSteps();
        _updateProgress();
      });
      
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _createProject() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create project from template with variable substitution
      final projectName = widget.template.replaceVariables(
        widget.template.projectNameTemplate,
        _variableValues,
      );
      
      final projectDescription = widget.template.projectDescriptionTemplate != null
          ? widget.template.replaceVariables(
              widget.template.projectDescriptionTemplate!,
              _variableValues,
            )
          : null;

      // Calculate deadline if offset is provided
      DateTime? deadline;
      if (widget.template.deadlineOffsetDays != null) {
        deadline = DateTime.now().add(
          Duration(days: widget.template.deadlineOffsetDays!),
        );
      }

      final project = Project.create(
        name: projectName,
        description: projectDescription,
        color: widget.template.defaultColor,
        categoryId: widget.template.projectCategoryId,
        deadline: deadline,
      );

      widget.onProjectCreated(project);
    } catch (e) {
      // Show error dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating project: $e'),
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
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.9,
          maxWidth: 700,
        ),
        child: GlassmorphismContainer(
          level: GlassLevel.floating,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
          padding: const EdgeInsets.all(TypographyConstants.paddingLarge),
          child: Column(
            children: [
              _buildHeader(theme),
              const SizedBox(height: TypographyConstants.paddingMedium),
              _buildProgressIndicator(theme),
              const SizedBox(height: TypographyConstants.paddingLarge),
              Expanded(
                child: _buildContent(theme),
              ),
              const SizedBox(height: TypographyConstants.paddingLarge),
              _buildActionButtons(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(TypographyConstants.paddingSmall),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
          ),
          child: Icon(
            PhosphorIconConstants.getIconByName('magic-wand'),
            color: theme.colorScheme.primary,
            size: TypographyConstants.headlineSmall,
          ),
        ),
        const SizedBox(width: TypographyConstants.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create from Template',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                widget.template.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: widget.onCancel,
          icon: Icon(PhosphorIcons.x()),
          style: IconButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    if (_visibleSteps.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // Step counter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${_currentStepIndex + 1} of ${_visibleSteps.length}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${((_currentStepIndex + 1) / _visibleSteps.length * 100).round()}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: TypographyConstants.paddingSmall),
        
        // Progress bar
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(2),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_visibleSteps.isEmpty) {
      return _buildSimpleForm(theme);
    }

    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(), // Controlled navigation only
      itemCount: _visibleSteps.length,
      itemBuilder: (context, index) {
        final step = _visibleSteps[index];
        final stepVariables = widget.template.getVariablesForStep(step.id);
        
        return SingleChildScrollView(
          child: _buildStepContent(theme, step, stepVariables),
        );
      },
    );
  }

  Widget _buildStepContent(
    ThemeData theme,
    TemplateWizardStep step,
    List<TemplateVariable> variables,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step header
        Row(
          children: [
            if (step.iconName != null) ...[
              Icon(
                PhosphorIconConstants.getIconByName(step.iconName!),
                color: theme.colorScheme.primary,
                size: TypographyConstants.headlineMedium,
              ),
              const SizedBox(width: TypographyConstants.paddingMedium),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (step.description != null)
                    Text(
                      step.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: TypographyConstants.paddingLarge),
        
        // Step variables
        ...variables.map((variable) => Padding(
          padding: const EdgeInsets.only(bottom: TypographyConstants.paddingMedium),
          child: _buildVariableInput(theme, variable),
        )),
      ],
    );
  }

  Widget _buildSimpleForm(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Configuration',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: TypographyConstants.paddingLarge),
          
          ...widget.template.variables.map((variable) => Padding(
            padding: const EdgeInsets.only(bottom: TypographyConstants.paddingMedium),
            child: _buildVariableInput(theme, variable),
          )),
        ],
      ),
    );
  }

  Widget _buildVariableInput(ThemeData theme, TemplateVariable variable) {
    final hasError = _validationErrors.containsKey(variable.key);
    final errorText = _validationErrors[variable.key];

    switch (variable.type) {
      case TemplateVariableType.text:
        return TextFormField(
          initialValue: _variableValues[variable.key]?.toString() ?? '',
          decoration: InputDecoration(
            labelText: variable.displayName,
            hintText: variable.description,
            errorText: hasError ? errorText : null,
            suffixIcon: variable.isRequired 
                ? const Icon(Icons.star, size: 12, color: Colors.red)
                : null,
          ),
          onChanged: (value) {
            setState(() {
              _variableValues[variable.key] = value;
              _validationErrors.remove(variable.key);
            });
          },
        );

      case TemplateVariableType.number:
        return TextFormField(
          initialValue: _variableValues[variable.key]?.toString() ?? '',
          decoration: InputDecoration(
            labelText: variable.displayName,
            hintText: variable.description,
            errorText: hasError ? errorText : null,
            suffixIcon: variable.isRequired 
                ? const Icon(Icons.star, size: 12, color: Colors.red)
                : null,
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              final numValue = num.tryParse(value);
              _variableValues[variable.key] = numValue;
              _validationErrors.remove(variable.key);
            });
          },
        );

      case TemplateVariableType.choice:
        return DropdownButtonFormField<String>(
          initialValue: _variableValues[variable.key],
          decoration: InputDecoration(
            labelText: variable.displayName,
            hintText: variable.description,
            errorText: hasError ? errorText : null,
          ),
          items: variable.options.map((option) => DropdownMenuItem(
            value: option,
            child: Text(option),
          )).toList(),
          onChanged: (value) {
            setState(() {
              _variableValues[variable.key] = value;
              _validationErrors.remove(variable.key);
              _updateVisibleSteps(); // Update steps when conditional variables change
            });
          },
        );

      case TemplateVariableType.boolean:
        return CheckboxListTile(
          title: Text(variable.displayName),
          subtitle: variable.description != null 
              ? Text(variable.description!) 
              : null,
          value: _variableValues[variable.key] ?? false,
          onChanged: (value) {
            setState(() {
              _variableValues[variable.key] = value ?? false;
              _validationErrors.remove(variable.key);
              _updateVisibleSteps();
            });
          },
        );

      case TemplateVariableType.date:
        return InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _variableValues[variable.key] ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
            );
            
            if (date != null) {
              setState(() {
                _variableValues[variable.key] = date;
                _validationErrors.remove(variable.key);
              });
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: variable.displayName,
              hintText: variable.description,
              errorText: hasError ? errorText : null,
              suffixIcon: Icon(PhosphorIcons.calendar()),
            ),
            child: Text(
              _variableValues[variable.key] != null
                  ? _formatDate(_variableValues[variable.key])
                  : 'Select date',
            ),
          ),
        );

      case TemplateVariableType.multiChoice:
        // For now, implement as a simple text field
        // In a full implementation, this would be a multi-select widget
        return TextFormField(
          initialValue: _variableValues[variable.key]?.toString() ?? '',
          decoration: InputDecoration(
            labelText: variable.displayName,
            hintText: '${variable.description} (comma-separated)',
            errorText: hasError ? errorText : null,
          ),
          onChanged: (value) {
            setState(() {
              _variableValues[variable.key] = value.split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
              _validationErrors.remove(variable.key);
            });
          },
        );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildActionButtons(ThemeData theme) {
    final isFirstStep = _currentStepIndex == 0;
    final isLastStep = _visibleSteps.isEmpty || _currentStepIndex == _visibleSteps.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous button
        if (!isFirstStep)
          TextButton.icon(
            onPressed: _isLoading ? null : _previousStep,
            icon: Icon(PhosphorIcons.caretLeft()),
            label: const Text('Previous'),
          )
        else
          const SizedBox.shrink(),

        // Cancel button
        TextButton(
          onPressed: _isLoading ? null : widget.onCancel,
          child: const Text('Cancel'),
        ),

        // Next/Create button
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _nextStep,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(isLastStep 
                  ? PhosphorIcons.check() 
                  : PhosphorIcons.caretRight()),
          label: Text(isLastStep ? 'Create Project' : 'Next'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }
}