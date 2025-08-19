import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/accessibility/accessibility_constants.dart';
import '../../core/theme/typography_constants.dart';
import 'glassmorphism_container.dart';
import 'accessible_button.dart';

/// Standardized state management for consistent UI across the app
class StandardizedStateWidgets {
  /// Create loading state with consistent design
  static Widget loading({
    String? message,
    bool showProgress = false,
    double? progress,
    bool fullScreen = false,
    Color? backgroundColor,
  }) {
    return StandardizedLoadingWidget(
      message: message,
      showProgress: showProgress,
      progress: progress,
      fullScreen: fullScreen,
      backgroundColor: backgroundColor,
    );
  }

  /// Create error state with consistent design and actions
  static Widget error({
    required String message,
    String? title,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    IconData? icon,
    bool fullScreen = false,
  }) {
    return StandardizedErrorWidget(
      message: message,
      title: title,
      onRetry: onRetry,
      onDismiss: onDismiss,
      icon: icon,
      fullScreen: fullScreen,
    );
  }

  /// Create empty state with consistent design
  static Widget empty({
    required String message,
    String? title,
    IconData? icon,
    VoidCallback? onAction,
    String? actionText,
    bool fullScreen = false,
  }) {
    return StandardizedEmptyWidget(
      message: message,
      title: title,
      icon: icon,
      onAction: onAction,
      actionText: actionText,
      fullScreen: fullScreen,
    );
  }

  /// Create success state with consistent design
  static Widget success({
    required String message,
    String? title,
    VoidCallback? onContinue,
    IconData? icon,
    Duration? autoHideDuration,
  }) {
    return StandardizedSuccessWidget(
      message: message,
      title: title,
      onContinue: onContinue,
      icon: icon,
      autoHideDuration: autoHideDuration,
    );
  }

  /// Wrap any widget with loading overlay
  static Widget withLoadingOverlay({
    required Widget child,
    required bool isLoading,
    String? loadingMessage,
    double? progress,
  }) {
    return LoadingOverlayWrapper(
      isLoading: isLoading,
      loadingMessage: loadingMessage,
      progress: progress,
      child: child,
    );
  }

  /// Create state-aware list builder
  static Widget stateAwareListBuilder<T>({
    required List<T> items,
    required Widget Function(BuildContext, T) itemBuilder,
    required bool isLoading,
    String? loadingMessage,
    String? error,
    VoidCallback? onRetry,
    String? emptyMessage,
    String? emptyTitle,
    VoidCallback? onEmptyAction,
    String? emptyActionText,
    Widget Function(BuildContext, List<T>)? headerBuilder,
    Widget Function(BuildContext, List<T>)? footerBuilder,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
  }) {
    return StateAwareListBuilder<T>(
      items: items,
      itemBuilder: itemBuilder,
      isLoading: isLoading,
      loadingMessage: loadingMessage,
      error: error,
      onRetry: onRetry,
      emptyMessage: emptyMessage,
      emptyTitle: emptyTitle,
      onEmptyAction: onEmptyAction,
      emptyActionText: emptyActionText,
      headerBuilder: headerBuilder,
      footerBuilder: footerBuilder,
      padding: padding,
      physics: physics,
    );
  }
}

/// Standardized loading widget
class StandardizedLoadingWidget extends ConsumerWidget {
  final String? message;
  final bool showProgress;
  final double? progress;
  final bool fullScreen;
  final Color? backgroundColor;

  const StandardizedLoadingWidget({
    super.key,
    this.message,
    this.showProgress = false,
    this.progress,
    this.fullScreen = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final shouldReduceMotion = AccessibilityUtils.shouldReduceMotion(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);
    
    final content = Center(
      child: GlassmorphismContainer(
        level: GlassLevel.floating,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loading indicator
            if (showProgress && progress != null)
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  color: theme.colorScheme.primary,
                ),
              )
            else
              SizedBox(
                width: 48,
                height: 48,
                child: shouldReduceMotion
                    ? Icon(
                        Icons.hourglass_empty,
                        size: 48,
                        color: theme.colorScheme.primary,
                      )
                    : CircularProgressIndicator(
                        strokeWidth: 4,
                        color: theme.colorScheme.primary,
                      ),
              ),

            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: TextStyle(
                  fontSize: isLargeText 
                      ? TypographyConstants.textBase 
                      : TypographyConstants.textSM,
                  fontWeight: TypographyConstants.medium,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (showProgress && progress != null) ...[
              const SizedBox(height: 8),
              Text(
                '${(progress! * 100).round()}%',
                style: TextStyle(
                  fontSize: TypographyConstants.textXS,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (fullScreen) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: backgroundColor ?? Colors.black.withOpacity(0.3),
        child: Semantics(
          label: message != null 
              ? 'Loading: $message'
              : 'Loading',
          liveRegion: true,
          child: content,
        ),
      );
    }

    return Semantics(
      label: message != null 
          ? 'Loading: $message'
          : 'Loading',
      liveRegion: true,
      child: content,
    );
  }
}

/// Standardized error widget
class StandardizedErrorWidget extends ConsumerWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final IconData? icon;
  final bool fullScreen;

  const StandardizedErrorWidget({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.onDismiss,
    this.icon,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);
    
    final content = Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassmorphismContainer(
          level: GlassLevel.content,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error icon
              Icon(
                icon ?? Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),

              const SizedBox(height: 16),

              // Title
              if (title != null)
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: isLargeText 
                        ? TypographyConstants.textXL 
                        : TypographyConstants.textLG,
                    fontWeight: TypographyConstants.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

              if (title != null) const SizedBox(height: 8),

              // Error message
              Text(
                message,
                style: TextStyle(
                  fontSize: isLargeText 
                      ? TypographyConstants.textBase 
                      : TypographyConstants.textSM,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Action buttons
              if (onRetry != null || onDismiss != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (onDismiss != null) ...[
                      AccessibleButton(
                        label: 'Dismiss',
                        onPressed: onDismiss,
                        child: Text(
                          'Dismiss',
                          style: TextStyle(
                            fontSize: isLargeText 
                                ? TypographyConstants.textBase 
                                : TypographyConstants.textSM,
                          ),
                        ),
                      ),
                      if (onRetry != null) const SizedBox(width: 16),
                    ],
                    if (onRetry != null)
                      AccessibleButton(
                        label: 'Retry',
                        onPressed: onRetry,
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: isLargeText 
                                ? TypographyConstants.textBase 
                                : TypographyConstants.textSM,
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

    if (fullScreen) {
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Semantics(
          label: title != null 
              ? '$title: $message'
              : 'Error: $message',
          liveRegion: true,
          child: content,
        ),
      );
    }

    return Semantics(
      label: title != null 
          ? '$title: $message'
          : 'Error: $message',
      liveRegion: true,
      child: content,
    );
  }
}

/// Standardized empty state widget
class StandardizedEmptyWidget extends ConsumerWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;
  final bool fullScreen;

  const StandardizedEmptyWidget({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.onAction,
    this.actionText,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);
    
    final content = Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassmorphismContainer(
          level: GlassLevel.content,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Empty state icon
              Icon(
                icon ?? Icons.inbox_outlined,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),

              const SizedBox(height: 16),

              // Title
              if (title != null)
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: isLargeText 
                        ? TypographyConstants.textXL 
                        : TypographyConstants.textLG,
                    fontWeight: TypographyConstants.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

              if (title != null) const SizedBox(height: 8),

              // Empty message
              Text(
                message,
                style: TextStyle(
                  fontSize: isLargeText 
                      ? TypographyConstants.textBase 
                      : TypographyConstants.textSM,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              if (onAction != null) ...[
                const SizedBox(height: 24),
                AccessibleButton(
                  label: actionText ?? 'Get Started',
                  onPressed: onAction,
                  child: Text(
                    actionText ?? 'Get Started',
                    style: TextStyle(
                      fontSize: isLargeText 
                          ? TypographyConstants.textBase 
                          : TypographyConstants.textSM,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (fullScreen) {
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Semantics(
          label: title != null 
              ? '$title: $message'
              : message,
          child: content,
        ),
      );
    }

    return Semantics(
      label: title != null 
          ? '$title: $message'
          : message,
      child: content,
    );
  }
}

/// Standardized success widget
class StandardizedSuccessWidget extends ConsumerStatefulWidget {
  final String message;
  final String? title;
  final VoidCallback? onContinue;
  final IconData? icon;
  final Duration? autoHideDuration;

  const StandardizedSuccessWidget({
    super.key,
    required this.message,
    this.title,
    this.onContinue,
    this.icon,
    this.autoHideDuration,
  });

  @override
  ConsumerState<StandardizedSuccessWidget> createState() => _StandardizedSuccessWidgetState();
}

class _StandardizedSuccessWidgetState extends ConsumerState<StandardizedSuccessWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.autoHideDuration != null) {
      Future.delayed(widget.autoHideDuration!, () {
        if (mounted) {
          widget.onContinue?.call();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeText = AccessibilityUtils.isLargeTextEnabled(context);
    
    return Semantics(
      label: widget.title != null 
          ? '${widget.title}: ${widget.message}'
          : 'Success: ${widget.message}',
      liveRegion: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassmorphismContainer(
            level: GlassLevel.content,
            borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Icon(
                  widget.icon ?? Icons.check_circle_outline,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),

                const SizedBox(height: 16),

                // Title
                if (widget.title != null)
                  Text(
                    widget.title!,
                    style: TextStyle(
                      fontSize: isLargeText 
                          ? TypographyConstants.textXL 
                          : TypographyConstants.textLG,
                      fontWeight: TypographyConstants.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                if (widget.title != null) const SizedBox(height: 8),

                // Success message
                Text(
                  widget.message,
                  style: TextStyle(
                    fontSize: isLargeText 
                        ? TypographyConstants.textBase 
                        : TypographyConstants.textSM,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (widget.onContinue != null && widget.autoHideDuration == null) ...[
                  const SizedBox(height: 24),
                  AccessibleButton(
                    label: 'Continue',
                    onPressed: widget.onContinue,
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: isLargeText 
                            ? TypographyConstants.textBase 
                            : TypographyConstants.textSM,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Loading overlay wrapper
class LoadingOverlayWrapper extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final double? progress;

  const LoadingOverlayWrapper({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: StandardizedLoadingWidget(
              message: loadingMessage,
              progress: progress,
              showProgress: progress != null,
              fullScreen: true,
              backgroundColor: Colors.black.withOpacity(0.3),
            ),
          ),
      ],
    );
  }
}

/// State-aware list builder
class StateAwareListBuilder<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final bool isLoading;
  final String? loadingMessage;
  final String? error;
  final VoidCallback? onRetry;
  final String? emptyMessage;
  final String? emptyTitle;
  final VoidCallback? onEmptyAction;
  final String? emptyActionText;
  final Widget Function(BuildContext, List<T>)? headerBuilder;
  final Widget Function(BuildContext, List<T>)? footerBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const StateAwareListBuilder({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.isLoading,
    this.loadingMessage,
    this.error,
    this.onRetry,
    this.emptyMessage,
    this.emptyTitle,
    this.onEmptyAction,
    this.emptyActionText,
    this.headerBuilder,
    this.footerBuilder,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    // Show error state
    if (error != null) {
      return StandardizedStateWidgets.error(
        message: error!,
        onRetry: onRetry,
        fullScreen: true,
      );
    }

    // Show loading state
    if (isLoading && items.isEmpty) {
      return StandardizedStateWidgets.loading(
        message: loadingMessage,
        fullScreen: true,
      );
    }

    // Show empty state
    if (items.isEmpty && !isLoading) {
      return StandardizedStateWidgets.empty(
        message: emptyMessage ?? 'No items found',
        title: emptyTitle,
        onAction: onEmptyAction,
        actionText: emptyActionText,
        fullScreen: true,
      );
    }

    // Show list with data
    return ListView.builder(
      padding: padding,
      physics: physics,
      itemCount: items.length + 
          (headerBuilder != null ? 1 : 0) + 
          (footerBuilder != null ? 1 : 0),
      itemBuilder: (context, index) {
        // Header
        if (headerBuilder != null && index == 0) {
          return headerBuilder!(context, items);
        }

        // Footer
        final footerIndex = items.length + (headerBuilder != null ? 1 : 0);
        if (footerBuilder != null && index == footerIndex) {
          return footerBuilder!(context, items);
        }

        // Regular item
        final itemIndex = index - (headerBuilder != null ? 1 : 0);
        return itemBuilder(context, items[itemIndex]);
      },
    );
  }
}