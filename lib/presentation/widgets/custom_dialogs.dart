import 'package:flutter/material.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/theme/material3/motion_system.dart';
import '../../core/design_system/design_tokens.dart';
import 'glassmorphism_container.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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

class _ConfirmationDialogState extends State<ConfirmationDialog>
    with TickerProviderStateMixin {
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
      insetPadding: const EdgeInsets.all(24),
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
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 16),
                _buildContent(theme),
                const SizedBox(height: 24),
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
            padding: const EdgeInsets.all(8),
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
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: Text(
            widget.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Text(
      widget.content,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: GlassmorphismContainer(
            level: GlassLevel.interactive,
            borderRadius: BorderRadius.circular(8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onCancel?.call();
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Center(
                    child: Text(
                      widget.cancelText,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GlassmorphismContainer(
            level: GlassLevel.interactive,
            borderRadius: BorderRadius.circular(8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onConfirm?.call();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      widget.confirmText,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
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
      insetPadding: const EdgeInsets.all(24),
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        width: size.width * 0.85,
        borderRadius: BorderRadius.circular(TypographyConstants.dialogRadius),
        glassTint: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              GlassmorphismContainer(
                level: GlassLevel.content,
                width: 56,
                height: 56,
                borderRadius: BorderRadius.circular(28),
                glassTint: theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Center(
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GlassmorphismContainer(
              level: GlassLevel.interactive,
              borderRadius: BorderRadius.circular(8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    onPressed?.call();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.8),
                          theme.colorScheme.primary.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        buttonText,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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
      insetPadding: const EdgeInsets.all(24),
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        width: size.width * 0.85,
        borderRadius: BorderRadius.circular(TypographyConstants.dialogRadius),
        glassTint: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              if (widget.content != null) ...[
                Text(
                  widget.content!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
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
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlassmorphismContainer(
                      level: GlassLevel.interactive,
                      borderRadius: BorderRadius.circular(8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            widget.onCancel?.call();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Center(
                              child: Text(
                                widget.cancelText,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GlassmorphismContainer(
                      level: GlassLevel.interactive,
                      borderRadius: BorderRadius.circular(8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.of(context).pop();
                              widget.onConfirm?.call(_controller.text);
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary.withValues(alpha: 0.8),
                                  theme.colorScheme.primary.withValues(alpha: 0.6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                widget.confirmText,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
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
      insetPadding: const EdgeInsets.all(24),
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        width: size.width * 0.85,
        borderRadius: BorderRadius.circular(TypographyConstants.dialogRadius),
        glassTint: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
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
                      margin: const EdgeInsets.only(bottom: 8),
                      borderRadius: BorderRadius.circular(8),
                      glassTint: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : null,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            onSelected?.call(option);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected 
                                      ? PhosphorIcons.checkCircle()
                                      : PhosphorIcons.circle(),
                                  color: isSelected 
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    getDisplayText(option),
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: isSelected 
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
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
            const SizedBox(height: 16),
            GlassmorphismContainer(
              level: GlassLevel.interactive,
              borderRadius: BorderRadius.circular(8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
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
      insetPadding: const EdgeInsets.all(24),
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        width: size.width * 0.7,
        borderRadius: BorderRadius.circular(TypographyConstants.dialogRadius),
        glassTint: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GlassmorphismContainer(
              level: GlassLevel.content,
              width: 64,
              height: 64,
              borderRadius: BorderRadius.circular(32),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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

