import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';
import '../../core/theme/material3/motion_system.dart';
import '../../core/theme/typography_constants.dart';
import 'glassmorphism_container.dart';
import 'standardized_text.dart';
import 'standardized_spacing.dart';

/// A reusable confirmation dialog widget with M3 glassmorphism design
class ConfirmationDialog extends StatefulWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
    this.onConfirm,
    this.onCancel,
    this.icon,
  });

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium3,
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium2,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: ExpressiveMotionSystem.emphasizedDecelerate,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: ExpressiveMotionSystem.emphasizedDecelerate,
    ));

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: StandardizedSpacing.padding(SpacingSize.lg),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GlassmorphismContainer(
            level: GlassLevel.floating,
            width: size.width * 0.85,
            borderRadius: BorderRadius.circular(TypographyConstants.dialogRadius),
            glassTint: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            padding: StandardizedSpacing.padding(SpacingSize.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(theme),
                StandardizedGaps.vertical(SpacingSize.md),
                _buildContent(theme),
                StandardizedGaps.vertical(SpacingSize.lg),
                _buildActions(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        if (widget.icon != null) ...[
          Container(
            padding: StandardizedSpacing.padding(SpacingSize.xs),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.isDestructive ? theme.colorScheme.error : theme.colorScheme.primary,
                  widget.isDestructive ? theme.colorScheme.error.withValues(alpha: 0.8) : theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
            ),
            child: Icon(
              widget.icon,
              color: theme.colorScheme.onPrimary, // Fixed hardcoded color violation (was Colors.white)
              size: 24,
            ),
          ),
          StandardizedGaps.horizontal(SpacingSize.md),
        ],
        Expanded(
          child: StandardizedText(
            widget.title,
            style: StandardizedTextStyle.titleLarge,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    return StandardizedText(
      widget.content,
      style: StandardizedTextStyle.bodyLarge,
      color: theme.colorScheme.onSurfaceVariant,
      lineHeight: 1.5,
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: GlassmorphismContainer(
            level: GlassLevel.interactive,
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onCancel?.call();
                },
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                child: Padding(
                  padding: StandardizedSpacing.paddingSymmetric(horizontal: SpacingSize.lg, vertical: SpacingSize.sm),
                  child: Center(
                    child: StandardizedText(
                      widget.cancelText,
                      style: StandardizedTextStyle.labelLarge,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        StandardizedGaps.horizontal(SpacingSize.md),
        Expanded(
          child: GlassmorphismContainer(
            level: GlassLevel.interactive,
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onConfirm?.call();
                },
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                child: Container(
                  padding: StandardizedSpacing.paddingSymmetric(horizontal: SpacingSize.lg, vertical: SpacingSize.sm),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.isDestructive
                          ? [
                              theme.colorScheme.error.withValues(alpha: 0.8),
                              theme.colorScheme.error.withValues(alpha: 0.6),
                            ]
                          : [
                              theme.colorScheme.primary.withValues(alpha: 0.8),
                              theme.colorScheme.primary.withValues(alpha: 0.6),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                  ),
                  child: Center(
                    child: StandardizedText(
                      widget.confirmText,
                      style: StandardizedTextStyle.labelLarge,
                      color: theme.colorScheme.onPrimary, // Fixed hardcoded color violation (was Colors.white)
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A dialog for displaying information with an OK button
class InfoDialog extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText;
  final VoidCallback? onPressed;
  final IconData? icon;

  const InfoDialog({
    super.key,
    required this.title,
    required this.content,
    this.buttonText = 'OK',
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: StandardizedSpacing.padding(SpacingSize.lg),
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        width: size.width * 0.85,
        borderRadius: BorderRadius.circular(TypographyConstants.dialogRadius),
        glassTint: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        padding: StandardizedSpacing.padding(SpacingSize.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              GlassmorphismContainer(
                level: GlassLevel.content,
                width: 56,
                height: 56,
                borderRadius: BorderRadius.circular(TypographyConstants.radiusXXLarge), // 24.0 - Fixed border radius hierarchy (was 28px)
                glassTint: theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Center(
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
              ),
              StandardizedGaps.vertical(SpacingSize.md),
            ],
            StandardizedText(
              title,
              style: StandardizedTextStyle.titleLarge,
              color: theme.colorScheme.onSurface,
              textAlign: TextAlign.center,
            ),
            StandardizedGaps.vertical(SpacingSize.md),
            StandardizedText(
              content,
              style: StandardizedTextStyle.bodyLarge,
              color: theme.colorScheme.onSurfaceVariant,
              lineHeight: 1.5,
              textAlign: TextAlign.center,
            ),
            StandardizedGaps.vertical(SpacingSize.lg),
            GlassmorphismContainer(
              level: GlassLevel.interactive,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    onPressed?.call();
                  },
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                  child: Container(
                    width: double.infinity,
                    padding: StandardizedSpacing.paddingSymmetric(horizontal: SpacingSize.lg, vertical: SpacingSize.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.8),
                          theme.colorScheme.primary.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                    ),
                    child: Center(
                      child: StandardizedText(
                        buttonText,
                        style: StandardizedTextStyle.labelLarge,
                        color: theme.colorScheme.onPrimary, // Fixed hardcoded color violation (was Colors.white)
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A dialog for text input
class TextInputDialog extends StatefulWidget {
  final String title;
  final String? content;
  final String? hintText;
  final String? initialValue;
  final String confirmText;
  final String cancelText;
  final Function(String)? onConfirm;
  final VoidCallback? onCancel;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType keyboardType;

  const TextInputDialog({
    super.key,
    required this.title,
    this.content,
    this.hintText,
    this.initialValue,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.validator,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: StandardizedSpacing.padding(SpacingSize.lg),
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        width: size.width * 0.85,
        borderRadius: BorderRadius.circular(TypographyConstants.dialogRadius),
        glassTint: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        padding: StandardizedSpacing.padding(SpacingSize.lg),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StandardizedText(
                widget.title,
                style: StandardizedTextStyle.titleLarge,
                  color: theme.colorScheme.onSurface,
              ),
              StandardizedGaps.vertical(SpacingSize.md),
              if (widget.content != null) ...[
                StandardizedText(
                  widget.content!,
                  style: StandardizedTextStyle.bodyMedium,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                StandardizedGaps.vertical(SpacingSize.md),
              ],
              GlassmorphismContainer(
                level: GlassLevel.interactive,
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                child: TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  validator: widget.validator,
                  maxLines: widget.maxLines,
                  keyboardType: widget.keyboardType,
                  autofocus: true,
                ),
              ),
              StandardizedGaps.vertical(SpacingSize.lg),
              Row(
                children: [
                  Expanded(
                    child: GlassmorphismContainer(
                      level: GlassLevel.interactive,
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            widget.onCancel?.call();
                          },
                          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                          child: Padding(
                            padding: StandardizedSpacing.paddingSymmetric(horizontal: SpacingSize.lg, vertical: SpacingSize.sm),
                            child: Center(
                              child: StandardizedText(
                                widget.cancelText,
                                style: StandardizedTextStyle.labelLarge,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  StandardizedGaps.horizontal(SpacingSize.md),
                  Expanded(
                    child: GlassmorphismContainer(
                      level: GlassLevel.interactive,
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.of(context).pop();
                              widget.onConfirm?.call(_controller.text);
                            }
                          },
                          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                          child: Container(
                            padding: StandardizedSpacing.paddingSymmetric(horizontal: SpacingSize.lg, vertical: SpacingSize.sm),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary.withValues(alpha: 0.8),
                                  theme.colorScheme.primary.withValues(alpha: 0.6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                            ),
                            child: Center(
                              child: StandardizedText(
                                widget.confirmText,
                                style: StandardizedTextStyle.labelLarge,
                                color: theme.colorScheme.onPrimary, // Fixed hardcoded color violation (was Colors.white)
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A dialog for selecting from a list of options
class SelectionDialog<T> extends StatelessWidget {
  final String title;
  final List<T> options;
  final String Function(T) getDisplayText;
  final Function(T)? onSelected;
  final T? selectedValue;
  final bool allowMultipleSelection;

  const SelectionDialog({
    super.key,
    required this.title,
    required this.options,
    required this.getDisplayText,
    this.onSelected,
    this.selectedValue,
    this.allowMultipleSelection = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: StandardizedSpacing.padding(SpacingSize.lg),
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        width: size.width * 0.85,
        borderRadius: BorderRadius.circular(TypographyConstants.dialogRadius),
        glassTint: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        padding: StandardizedSpacing.padding(SpacingSize.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StandardizedText(
              title,
              style: StandardizedTextStyle.titleLarge,
              color: theme.colorScheme.onSurface,
            ),
            StandardizedGaps.vertical(SpacingSize.md),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: size.height * 0.4,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: options.map((option) {
                    final isSelected = selectedValue == option;
                    return GlassmorphismContainer(
                      level: isSelected ? GlassLevel.interactive : GlassLevel.content,
                      margin: StandardizedSpacing.marginOnly(bottom: SpacingSize.xs),
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                      glassTint: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : null,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            onSelected?.call(option);
                          },
                          borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                          child: Padding(
                            padding: StandardizedSpacing.padding(SpacingSize.md),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? PhosphorIcons.checkCircle() : PhosphorIcons.circle(),
                                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                                ),
                                StandardizedGaps.horizontal(SpacingSize.md),
                                Expanded(
                                  child: StandardizedText(
                                    getDisplayText(option),
                                    style: StandardizedTextStyle.bodyLarge,
                                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            StandardizedGaps.vertical(SpacingSize.md),
            GlassmorphismContainer(
              level: GlassLevel.interactive,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard), // 8.0 - Fixed border radius hierarchy
                  child: Padding(
                    padding: StandardizedSpacing.paddingSymmetric(horizontal: SpacingSize.lg, vertical: SpacingSize.sm),
                    child: Center(
                      child: StandardizedText(
                        'Cancel',
                        style: StandardizedTextStyle.labelLarge,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A dialog for displaying a loading state
class LoadingDialog extends StatelessWidget {
  final String title;
  final String? message;

  const LoadingDialog({
    super.key,
    required this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: StandardizedSpacing.padding(SpacingSize.lg),
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        width: size.width * 0.7,
        borderRadius: BorderRadius.circular(TypographyConstants.dialogRadius),
        glassTint: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        padding: StandardizedSpacing.padding(SpacingSize.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StandardizedText(
              title,
              style: StandardizedTextStyle.titleLarge,
              color: theme.colorScheme.onSurface,
              textAlign: TextAlign.center,
            ),
            StandardizedGaps.vertical(SpacingSize.lg),
            GlassmorphismContainer(
              level: GlassLevel.content,
              width: 64,
              height: 64,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusXXLarge), // 24.0 - Fixed border radius hierarchy (was 32px)
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            if (message != null) ...[
              StandardizedGaps.vertical(SpacingSize.md),
              StandardizedText(
                message!,
                style: StandardizedTextStyle.bodyMedium,
                color: theme.colorScheme.onSurfaceVariant,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Utility functions for showing dialogs
class DialogUtils {
  /// Show a confirmation dialog
  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        icon: icon,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );

    return result ?? false;
  }

  /// Show an info dialog
  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = 'OK',
    IconData? icon,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => InfoDialog(
        title: title,
        content: content,
        buttonText: buttonText,
        icon: icon,
      ),
    );
  }

  /// Show a text input dialog
  static Future<String?> showTextInput(
    BuildContext context, {
    required String title,
    String? content,
    String? hintText,
    String? initialValue,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => TextInputDialog(
        title: title,
        content: content,
        hintText: hintText,
        initialValue: initialValue,
        confirmText: confirmText,
        cancelText: cancelText,
        validator: validator,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onConfirm: (value) => Navigator.of(context).pop(value),
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show a selection dialog
  static Future<T?> showSelection<T>(
    BuildContext context, {
    required String title,
    required List<T> options,
    required String Function(T) getDisplayText,
    T? selectedValue,
  }) async {
    return await showDialog<T>(
      context: context,
      builder: (context) => SelectionDialog<T>(
        title: title,
        options: options,
        getDisplayText: getDisplayText,
        selectedValue: selectedValue,
        onSelected: (value) => Navigator.of(context).pop(value),
      ),
    );
  }

  /// Show a loading dialog
  static void showLoading(
    BuildContext context, {
    required String title,
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(
        title: title,
        message: message,
      ),
    );
  }

  /// Hide the currently shown dialog
  static void hideDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}
