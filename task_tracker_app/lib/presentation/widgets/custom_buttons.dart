import 'package:flutter/material.dart';

/// Custom primary button with consistent styling
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = icon != null
        ? FilledButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon),
            label: Text(text),
          )
        : FilledButton(
            onPressed: isLoading ? null : onPressed,
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(text),
          );

    return isExpanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Custom secondary button with consistent styling
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = icon != null
        ? OutlinedButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon),
            label: Text(text),
          )
        : OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(text),
          );

    return isExpanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Custom text button with consistent styling
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  const CustomTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return icon != null
        ? TextButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon),
            label: Text(text),
          )
        : TextButton(
            onPressed: isLoading ? null : onPressed,
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(text),
          );
  }
}

/// Voice action button with special styling
class VoiceActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isListening;
  final bool isProcessing;
  final String? tooltip;

  const VoiceActionButton({
    super.key,
    this.onPressed,
    this.isListening = false,
    this.isProcessing = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget icon;
    Color? backgroundColor;
    Color? foregroundColor;
    
    if (isProcessing) {
      icon = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
      backgroundColor = theme.colorScheme.secondary;
      foregroundColor = theme.colorScheme.onSecondary;
    } else if (isListening) {
      icon = const Icon(Icons.mic);
      backgroundColor = AppColors.voiceRecording;
      foregroundColor = Colors.white;
    } else {
      icon = const Icon(Icons.mic_none);
      backgroundColor = theme.colorScheme.primaryContainer;
      foregroundColor = theme.colorScheme.onPrimaryContainer;
    }

    return FloatingActionButton(
      onPressed: (isProcessing || isListening) ? null : onPressed,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      tooltip: tooltip ?? (isListening ? 'Listening...' : 'Voice input'),
      child: icon,
    );
  }
}

/// Destructive button for dangerous actions
class DestructiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  const DestructiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = icon != null
        ? FilledButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon),
            label: Text(text),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
          )
        : FilledButton(
            onPressed: isLoading ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(text),
          );

    return isExpanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Import the AppColors for the VoiceActionButton
class AppColors {
  static const Color voiceRecording = Color(0xFFE91E63);
}