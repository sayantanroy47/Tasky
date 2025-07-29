import 'package:flutter/material.dart';
import 'custom_buttons.dart';

/// Confirmation dialog for destructive actions
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        SecondaryButton(
          text: cancelText,
          onPressed: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
        ),
        const SizedBox(width: 8),
        isDestructive
            ? DestructiveButton(
                text: confirmText,
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm?.call();
                },
              )
            : PrimaryButton(
                text: confirmText,
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm?.call();
                },
              ),
      ],
    );
  }

  /// Show confirmation dialog
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }
}

/// Loading dialog with progress indicator
class LoadingDialog extends StatelessWidget {
  final String title;
  final String? message;
  final bool canCancel;
  final VoidCallback? onCancel;

  const LoadingDialog({
    super.key,
    required this.title,
    this.message,
    this.canCancel = false,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: canCancel
          ? [
              SecondaryButton(
                text: 'Cancel',
                onPressed: () {
                  Navigator.of(context).pop();
                  onCancel?.call();
                },
              ),
            ]
          : null,
    );
  }

  /// Show loading dialog
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    String? message,
    bool canCancel = false,
    VoidCallback? onCancel,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: canCancel,
      builder: (context) => LoadingDialog(
        title: title,
        message: message,
        canCancel: canCancel,
        onCancel: onCancel,
      ),
    );
  }
}

/// Info dialog with single action
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
    return AlertDialog(
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon),
            const SizedBox(width: 12),
          ],
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(content),
      actions: [
        PrimaryButton(
          text: buttonText,
          onPressed: () {
            Navigator.of(context).pop();
            onPressed?.call();
          },
        ),
      ],
    );
  }

  /// Show info dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String content,
    String buttonText = 'OK',
    VoidCallback? onPressed,
    IconData? icon,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => InfoDialog(
        title: title,
        content: content,
        buttonText: buttonText,
        onPressed: onPressed,
        icon: icon,
      ),
    );
  }
}

/// Text input dialog
class TextInputDialog extends StatefulWidget {
  final String title;
  final String? hint;
  final String? initialValue;
  final String confirmText;
  final String cancelText;
  final ValueChanged<String>? onConfirm;
  final VoidCallback? onCancel;
  final String? Function(String?)? validator;
  final int maxLines;

  const TextInputDialog({
    super.key,
    required this.title,
    this.hint,
    this.initialValue,
    this.confirmText = 'OK',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.validator,
    this.maxLines = 1,
  });

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (_formKey.currentState?.validate() ?? true) {
      Navigator.of(context).pop();
      widget.onConfirm?.call(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hint,
          ),
          maxLines: widget.maxLines,
          validator: widget.validator,
          autofocus: true,
          onFieldSubmitted: (_) => _onConfirm(),
        ),
      ),
      actions: [
        SecondaryButton(
          text: widget.cancelText,
          onPressed: () {
            Navigator.of(context).pop();
            widget.onCancel?.call();
          },
        ),
        const SizedBox(width: 8),
        PrimaryButton(
          text: widget.confirmText,
          onPressed: _onConfirm,
        ),
      ],
    );
  }

  /// Show text input dialog
  static Future<String?> show(
    BuildContext context, {
    required String title,
    String? hint,
    String? initialValue,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => TextInputDialog(
        title: title,
        hint: hint,
        initialValue: initialValue,
        confirmText: confirmText,
        cancelText: cancelText,
        validator: validator,
        maxLines: maxLines,
        onConfirm: (value) => Navigator.of(context).pop(value),
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// Choice dialog with multiple options
class ChoiceDialog<T> extends StatelessWidget {
  final String title;
  final List<ChoiceDialogOption<T>> options;
  final ValueChanged<T>? onSelected;
  final VoidCallback? onCancel;
  final String cancelText;

  const ChoiceDialog({
    super.key,
    required this.title,
    required this.options,
    this.onSelected,
    this.onCancel,
    this.cancelText = 'Cancel',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) => ListTile(
          leading: option.icon != null ? Icon(option.icon) : null,
          title: Text(option.title),
          subtitle: option.subtitle != null ? Text(option.subtitle!) : null,
          onTap: () {
            Navigator.of(context).pop();
            onSelected?.call(option.value);
          },
        )).toList(),
      ),
      actions: [
        SecondaryButton(
          text: cancelText,
          onPressed: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
        ),
      ],
    );
  }

  /// Show choice dialog
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required List<ChoiceDialogOption<T>> options,
    String cancelText = 'Cancel',
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => ChoiceDialog<T>(
        title: title,
        options: options,
        cancelText: cancelText,
        onSelected: (value) => Navigator.of(context).pop(value),
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// Choice dialog option
class ChoiceDialogOption<T> {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final T value;

  const ChoiceDialogOption({
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
  });
}

/// Bottom sheet dialog
class CustomBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final bool isScrollControlled;
  final bool isDismissible;

  const CustomBottomSheet({
    super.key,
    this.title,
    required this.child,
    this.isScrollControlled = false,
    this.isDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
          
          // Content
          Flexible(child: child),
        ],
      ),
    );
  }

  /// Show bottom sheet
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    required Widget child,
    bool isScrollControlled = false,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      builder: (context) => CustomBottomSheet(
        title: title,
        isScrollControlled: isScrollControlled,
        isDismissible: isDismissible,
        child: child,
      ),
    );
  }
}