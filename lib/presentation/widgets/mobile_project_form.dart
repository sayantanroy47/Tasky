import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';
import 'standardized_animations.dart';
import '../../domain/entities/project.dart';
import '../../services/ui/mobile_gesture_service.dart';
import '../providers/project_providers.dart';
import 'enhanced_ux_widgets.dart';
import 'glassmorphism_container.dart';
import 'standardized_text.dart';
import 'standardized_colors.dart';
import 'standardized_spacing.dart';
import 'standardized_form_widgets.dart';
import '../../core/validation/form_validators.dart';

/// Mobile-optimized project form with gesture support and enhanced UX
class MobileProjectForm extends ConsumerStatefulWidget {
  final Project? project; // null for creating new project
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;
  final bool isFullScreen;

  const MobileProjectForm({
    super.key,
    this.project,
    this.onSuccess,
    this.onCancel,
    this.isFullScreen = false,
  });

  @override
  ConsumerState<MobileProjectForm> createState() => _MobileProjectFormState();
}

class _MobileProjectFormState extends ConsumerState<MobileProjectForm>
    with TickerProviderStateMixin {
  late AnimationController _slideAnimationController;
  late AnimationController _colorAnimationController;
  late AnimationController _loadingAnimationController;
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  String _selectedColor = '#2196F3';
  DateTime? _selectedDeadline;
  bool _isLoading = false;
  final bool _showColorPicker = false;
  int _currentStep = 0;

  final List<ProjectFormStep> _formSteps = [
    const ProjectFormStep(
      title: 'Basic Info',
      subtitle: 'Name and description',
      icon: PhosphorIcons.info,
    ),
    const ProjectFormStep(
      title: 'Customization',
      subtitle: 'Color and settings',
      icon: PhosphorIcons.palette,
    ),
    const ProjectFormStep(
      title: 'Timeline',
      subtitle: 'Deadline and milestones',
      icon: PhosphorIcons.calendarBlank,
    ),
  ];

  // Enhanced color options with better mobile accessibility
  final List<ProjectColor> _colorOptions = [
    const ProjectColor(name: 'Ocean Blue', hex: '#2196F3', description: 'Professional and calm'),
    const ProjectColor(name: 'Forest Green', hex: '#4CAF50', description: 'Growth and nature'),
    const ProjectColor(name: 'Sunset Orange', hex: '#FF9800', description: 'Energy and creativity'),
    const ProjectColor(name: 'Cherry Red', hex: '#F44336', description: 'Urgent and important'),
    const ProjectColor(name: 'Royal Purple', hex: '#9C27B0', description: 'Luxury and innovation'),
    const ProjectColor(name: 'Slate Gray', hex: '#607D8B', description: 'Professional and stable'),
    const ProjectColor(name: 'Earth Brown', hex: '#795548', description: 'Grounded and reliable'),
    const ProjectColor(name: 'Magenta Pink', hex: '#E91E63', description: 'Creative and bold'),
    const ProjectColor(name: 'Turquoise', hex: '#00BCD4', description: 'Fresh and modern'),
    const ProjectColor(name: 'Lime Green', hex: '#8BC34A', description: 'Active and vibrant'),
  ];

  @override
  void initState() {
    super.initState();
    
    _slideAnimationController = AnimationController(
      duration: StandardizedAnimations.normal,
      vsync: this,
    );
    _colorAnimationController = AnimationController(
      duration: StandardizedAnimations.fast,
      vsync: this,
    );
    _loadingAnimationController = AnimationController(
      duration: StandardizedAnimations.slow,
      vsync: this,
    );

    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description ?? '';
      _selectedColor = widget.project!.color;
      _selectedDeadline = widget.project!.deadline;
    }

    // Start entrance animation
    _slideAnimationController.forward();
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _colorAnimationController.dispose();
    _loadingAnimationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mobileGestureService = ref.read(mobileGestureServiceProvider);
    final isEditing = widget.project != null;

    return Scaffold(
      backgroundColor: widget.isFullScreen ? null : context.colors.backgroundTransparent,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: mobileGestureService.createTabNavigationGestureDetector(
          currentIndex: _currentStep,
          totalTabs: _formSteps.length,
          onTabChanged: _navigateToStep,
          enableSwipeNavigation: true,
          semanticLabel: 'Project form steps',
          child: AnimatedBuilder(
            animation: _slideAnimationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - _slideAnimationController.value)),
                child: Opacity(
                  opacity: _slideAnimationController.value,
                  child: _buildFormContent(theme, mobileGestureService, isEditing),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(
    ThemeData theme,
    MobileGestureService gestureService,
    bool isEditing,
  ) {
    return Column(
      children: [
        // Header with progress and navigation
        _buildFormHeader(theme, gestureService),
        
        // Step indicator
        _buildStepIndicator(theme),
        
        // Form content
        Expanded(
          child: _buildFormBody(theme, gestureService),
        ),
        
        // Action buttons
        _buildActionButtons(theme, gestureService, isEditing),
      ],
    );
  }

  Widget _buildFormHeader(ThemeData theme, MobileGestureService gestureService) {
    final currentStep = _formSteps[_currentStep];
    
    return GlassmorphismContainer(
      level: GlassLevel.floating,
      margin: StandardizedSpacing.margin(SpacingSize.md),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.lg),
        child: Row(
          children: [
            // Back button
            gestureService.createProjectCardGestureDetector(
              projectId: 'form_back',
              onTap: _handleBack,
              semanticLabel: 'Go back',
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.withSemanticOpacity(
                    theme.colorScheme.surfaceContainerHighest,
                    SemanticOpacity.strong,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  PhosphorIcons.arrowLeft(),
                  color: theme.colorScheme.onSurface,
                  size: 20,
                ),
              ),
            ),
            
            StandardizedGaps.md,
            
            // Step info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StandardizedText(
                    currentStep.title,
                    style: StandardizedTextStyle.titleLarge,
                  ),
                  StandardizedGaps.vertical(SpacingSize.xs),
                  StandardizedText(
                    currentStep.subtitle,
                    style: StandardizedTextStyle.bodyMedium,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            
            // Step counter
            Container(
              padding: StandardizedSpacing.paddingSymmetric(
                horizontal: SpacingSize.sm,
                vertical: SpacingSize.xs,
              ),
              decoration: BoxDecoration(
                color: context.colors.withSemanticOpacity(
                  theme.colorScheme.primary,
                  SemanticOpacity.subtle,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: StandardizedText(
                '${_currentStep + 1}/${_formSteps.length}',
                style: StandardizedTextStyle.labelMedium,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(ThemeData theme) {
    return Container(
      height: 60,
      margin: StandardizedSpacing.marginSymmetric(horizontal: SpacingSize.md),
      child: Row(
        children: List.generate(_formSteps.length, (index) {
          final step = _formSteps[index];
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => _navigateToStep(index),
              child: AnimatedContainer(
                duration: StandardizedAnimations.fast,
                margin: StandardizedSpacing.marginSymmetric(horizontal: SpacingSize.xs),
                decoration: BoxDecoration(
                  color: isActive
                      ? context.colors.withSemanticOpacity(
                          theme.colorScheme.primary,
                          SemanticOpacity.subtle,
                        )
                      : isCompleted
                          ? context.colors.withSemanticOpacity(
                              theme.colorScheme.primary,
                              SemanticOpacity.subtle,
                            )
                          : context.colors.backgroundTransparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? theme.colorScheme.primary
                        : isCompleted
                            ? context.colors.withSemanticOpacity(
                                theme.colorScheme.primary,
                                SemanticOpacity.light,
                              )
                            : context.colors.withSemanticOpacity(
                                theme.colorScheme.outline,
                                SemanticOpacity.light,
                              ),
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Padding(
                  padding: StandardizedSpacing.padding(SpacingSize.sm),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isCompleted ? PhosphorIcons.checkCircle() : step.icon(),
                        size: 20,
                        color: isActive
                            ? theme.colorScheme.primary
                            : isCompleted
                                ? context.colors.withSemanticOpacity(
                                    theme.colorScheme.primary,
                                    SemanticOpacity.strong,
                                  )
                                : theme.colorScheme.onSurfaceVariant,
                      ),
                      StandardizedGaps.vertical(SpacingSize.xs),
                      StandardizedText(
                        step.title,
                        style: StandardizedTextStyle.bodySmall,
                        color: isActive
                            ? theme.colorScheme.primary
                            : isCompleted
                                ? context.colors.withSemanticOpacity(
                                    theme.colorScheme.primary,
                                    SemanticOpacity.strong,
                                  )
                                : theme.colorScheme.onSurfaceVariant,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFormBody(ThemeData theme, MobileGestureService gestureService) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      margin: StandardizedSpacing.margin(SpacingSize.md),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Form(
        key: _formKey,
        child: PageView.builder(
          onPageChanged: _onPageChanged,
          itemCount: _formSteps.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: StandardizedSpacing.padding(SpacingSize.lg),
              child: _buildStepContent(theme, gestureService, index),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepContent(ThemeData theme, MobileGestureService gestureService, int stepIndex) {
    switch (stepIndex) {
      case 0:
        return _buildBasicInfoStep(theme, gestureService);
      case 1:
        return _buildCustomizationStep(theme, gestureService);
      case 2:
        return _buildTimelineStep(theme, gestureService);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasicInfoStep(ThemeData theme, MobileGestureService gestureService) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project name field
          StandardizedFormField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            label: 'Project Name',
            hint: 'Enter project name',
            semanticLabel: 'Project name input field',
            prefixIcon: Icon(PhosphorIcons.folder()),
            isRequired: true,
            validator: FieldValidator.compose([
              FieldValidator.required('Please enter a project name'),
              FieldValidator.minLength(3, 'Name must be at least 3 characters'),
            ]),
            onChanged: (value) {
              setState(() {}); // Trigger rebuild for validation
            },
          ),
          
          StandardizedGaps.vertical(SpacingSize.phi2),
          
          // Project description field
          StandardizedFormField(
            controller: _descriptionController,
            focusNode: _descriptionFocusNode,
            label: 'Description (Optional)',
            hint: 'Describe your project goals and scope',
            semanticLabel: 'Project description input field',
            prefixIcon: Icon(PhosphorIcons.textAa()),
            isMultiline: true,
            maxLines: 3,
            onChanged: (value) {
              setState(() {}); // Trigger rebuild
            },
          ),
          
          StandardizedGaps.vertical(SpacingSize.lg),
          
          // Character count and tips
          if (_descriptionController.text.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  PhosphorIcons.info(),
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                StandardizedGaps.horizontal(SpacingSize.sm),
                StandardizedText(
                  '${_descriptionController.text.length} characters',
                  style: StandardizedTextStyle.bodySmall,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            StandardizedGaps.md,
          ],
          
          // Quick tips
          _buildQuickTips(theme, [
            'Choose a descriptive name that clearly identifies your project',
            'Add a brief description to help team members understand the project goals',
            'You can always edit these details later',
          ]),
        ],
      ),
    );
  }

  Widget _buildCustomizationStep(ThemeData theme, MobileGestureService gestureService) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color picker section
          Text(
            'Project Color',
            style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Choose a color to help identify your project',
            style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Color grid
          _buildColorGrid(theme, gestureService),
          
          const SizedBox(height: 24),
          
          // Preview section
          _buildProjectPreview(theme),
          
          const SizedBox(height: 24),
          
          // Quick tips
          _buildQuickTips(theme, [
            'Colors help visually organize projects in lists and calendars',
            'Choose colors that make sense for your project type',
            'You can change the color anytime from project settings',
          ]),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(ThemeData theme, MobileGestureService gestureService) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Deadline section
          Text(
            'Project Deadline',
            style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Set an optional deadline to track project progress',
            style: StandardizedTextStyle.bodyMedium.toTextStyle(context).copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Deadline picker
          GestureDetector(
            onTap: () => _showDatePicker(context),
            child: Container(
              padding: const EdgeInsets.all(SpacingTokens.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.calendarBlank(),
                    color: _selectedDeadline != null
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDeadline != null
                          ? _formatDate(_selectedDeadline!)
                          : 'Tap to set deadline',
                      style: StandardizedTextStyle.bodyLarge.toTextStyle(context).copyWith(
                        color: _selectedDeadline != null
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (_selectedDeadline != null)
                    GestureDetector(
                      onTap: () {
                        setState(() => _selectedDeadline = null);
                        HapticFeedback.lightImpact();
                      },
                      child: Icon(
                        PhosphorIcons.x(),
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          if (_selectedDeadline != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(SpacingTokens.sm + 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.clock(),
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getDeadlineDescription(_selectedDeadline!),
                    style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Quick tips
          _buildQuickTips(theme, [
            'Deadlines are optional but help with project planning',
            'You can set task-specific deadlines even without a project deadline',
            'Project deadline alerts can be configured in settings',
          ]),
        ],
      ),
    );
  }

  Widget _buildColorGrid(ThemeData theme, MobileGestureService gestureService) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _colorOptions.length,
      itemBuilder: (context, index) {
        final colorOption = _colorOptions[index];
        final isSelected = _selectedColor == colorOption.hex;
        
        return gestureService.createProjectCardGestureDetector(
          projectId: 'color_${colorOption.hex}',
          onTap: () => _selectColor(colorOption.hex),
          semanticLabel: '${colorOption.name} color option',
          child: AnimatedContainer(
            duration: StandardizedAnimations.fast,
            decoration: BoxDecoration(
              color: _parseColor(colorOption.hex),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.onSurface
                    : Colors.transparent,
                width: isSelected ? 3 : 0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _parseColor(colorOption.hex).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: isSelected
                ? Icon(
                    PhosphorIcons.check(),
                    color: Colors.white,
                    size: 24,
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildProjectPreview(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: StandardizedTextStyle.titleSmall.toTextStyle(context).copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _parseColor(_selectedColor).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            border: Border.all(
              color: _parseColor(_selectedColor).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 32,
                decoration: BoxDecoration(
                  color: _parseColor(_selectedColor),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text.isEmpty ? 'Project Name' : _nameController.text,
                      style: StandardizedTextStyle.titleMedium.toTextStyle(context).copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_descriptionController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _descriptionController.text,
                          style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickTips(ThemeData theme, List<String> tips) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.lightbulb(),
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Tips',
                style: StandardizedTextStyle.labelMedium.toTextStyle(context).copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        tip,
                        style: StandardizedTextStyle.bodySmall.toTextStyle(context).copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    ThemeData theme,
    MobileGestureService gestureService,
    bool isEditing,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back/Previous button
          if (_currentStep > 0)
            Expanded(
              child: EnhancedButton(
                onPressed: _previousStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.onSurface,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIcons.caretLeft(), size: 16),
                    const SizedBox(width: 8),
                    const Text('Previous'),
                  ],
                ),
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: 12),
          
          // Next/Save button
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: EnhancedButton(
              onPressed: _isLoading ? null : _handleNextOrSave,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_currentStep == _formSteps.length - 1
                            ? (isEditing ? 'Update Project' : 'Create Project')
                            : 'Next'),
                        const SizedBox(width: 8),
                        Icon(
                          _currentStep == _formSteps.length - 1
                              ? PhosphorIcons.check()
                              : PhosphorIcons.caretRight(),
                          size: 16,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Event handlers
  void _navigateToStep(int step) {
    if (step != _currentStep && step >= 0 && step < _formSteps.length) {
      setState(() => _currentStep = step);
      HapticFeedback.selectionClick();
    }
  }

  void _onPageChanged(int page) {
    if (page != _currentStep) {
      setState(() => _currentStep = page);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      HapticFeedback.lightImpact();
    }
  }

  void _nextStep() {
    if (_currentStep < _formSteps.length - 1) {
      setState(() => _currentStep++);
      HapticFeedback.lightImpact();
    }
  }

  void _handleNextOrSave() {
    if (_currentStep < _formSteps.length - 1) {
      // Validate current step before proceeding
      if (_validateCurrentStep()) {
        _nextStep();
      }
    } else {
      // Final step - save the project
      _saveProject();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Basic info
        if (_nameController.text.trim().isEmpty) {
          _showSnackBar('Please enter a project name', isError: true);
          return false;
        }
        return true;
      case 1: // Customization
        return true; // Color is always selected
      case 2: // Timeline
        return true; // Deadline is optional
      default:
        return true;
    }
  }

  void _selectColor(String color) {
    setState(() => _selectedColor = color);
    HapticFeedback.selectionClick();
  }

  void _handleBack() {
    if (_currentStep > 0) {
      _previousStep();
    } else {
      widget.onCancel?.call();
      if (widget.isFullScreen) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // ~10 years
    );
    
    if (date != null) {
      setState(() => _selectedDeadline = date);
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _saveProject() async {
    if (!_validateCurrentStep() || _isLoading) return;

    setState(() => _isLoading = true);
    _loadingAnimationController.forward();

    final navigator = widget.isFullScreen ? Navigator.of(context) : null;

    try {
      final projectData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        'color': _selectedColor,
        'deadline': _selectedDeadline,
      };

      if (widget.project != null) {
        // Update existing project
        await ref.read(projectsProvider.notifier).updateProject(
          widget.project!.id,
          projectData,
        );
        _showSnackBar('Project updated successfully!');
      } else {
        // Create new project
        await ref.read(projectsProvider.notifier).createProject(projectData);
        _showSnackBar('Project created successfully!');
      }

      await HapticFeedback.heavyImpact(); // Success feedback
      widget.onSuccess?.call();
      
      if (widget.isFullScreen && navigator != null) {
        navigator.pop();
      }
    } catch (e) {
      _showSnackBar('Error saving project: ${e.toString()}', isError: true);
      await HapticFeedback.vibrate(); // Error feedback
    } finally {
      setState(() => _isLoading = false);
      _loadingAnimationController.reset();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? PhosphorIcons.warningCircle() : PhosphorIcons.checkCircle(),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError 
            ? Theme.of(context).colorScheme.error 
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        ),
      ),
    );
  }

  // Helper methods
  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Theme.of(context).colorScheme.primary;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getDeadlineDescription(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;

    if (difference < 0) {
      return 'Past deadline';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else if (difference <= 7) {
      return 'Due in $difference days';
    } else if (difference <= 30) {
      return 'Due in ${(difference / 7).round()} weeks';
    } else if (difference <= 365) {
      return 'Due in ${(difference / 30).round()} months';
    } else {
      return 'Due in ${(difference / 365).round()} years';
    }
  }
}

/// Project form step configuration
class ProjectFormStep {
  final String title;
  final String subtitle;
  final IconData Function() icon;

  const ProjectFormStep({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

/// Project color option
class ProjectColor {
  final String name;
  final String hex;
  final String description;

  const ProjectColor({
    required this.name,
    required this.hex,
    required this.description,
  });
}