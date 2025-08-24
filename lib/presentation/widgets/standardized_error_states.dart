import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/design_system/design_tokens.dart';
import '../../core/theme/typography_constants.dart';
import 'glassmorphism_container.dart';
import 'standardized_text.dart';

/// Standardized error, loading, and empty state components
/// 
/// Eliminates Error State Pattern Inconsistency by providing:
/// - Consistent error message styling and hierarchy
/// - Standardized loading state indicators  
/// - Unified empty state presentations
/// - Proper accessibility and visual hierarchy
class StandardizedErrorStates {
  /// Standard error widget with consistent styling
  static Widget error({
    required String message,
    IconData? icon,
    VoidCallback? onRetry,
    String? retryLabel,
    ErrorSeverity severity = ErrorSeverity.moderate,
    bool compact = false,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        if (compact) {
          return _buildCompactError(theme, message, icon, severity);
        }
        
        return _buildFullError(theme, message, icon, onRetry, retryLabel, severity);
      },
    );
  }

  /// Standard loading widget with consistent styling
  static Widget loading({
    String? message,
    LoadingStyle style = LoadingStyle.circular,
    bool compact = false,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        switch (style) {
          case LoadingStyle.circular:
            return _buildCircularLoading(theme, message, compact);
          case LoadingStyle.linear:
            return _buildLinearLoading(theme, message, compact);
          case LoadingStyle.minimal:
            return _buildMinimalLoading(theme, message, compact);
        }
      },
    );
  }

  /// Standard empty state widget
  static Widget empty({
    required String message,
    String? subtitle,
    IconData? icon,
    VoidCallback? onAction,
    String? actionLabel,
    bool compact = false,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        if (compact) {
          return _buildCompactEmpty(theme, message, icon);
        }
        
        return _buildFullEmpty(theme, message, subtitle, icon, onAction, actionLabel);
      },
    );
  }

  /// AsyncValue handler with consistent error/loading states
  static Widget asyncBuilder<T>({
    required AsyncValue<T> asyncValue,
    required Widget Function(T data) dataBuilder,
    Widget? loadingWidget,
    Widget Function(Object error, StackTrace stack)? errorBuilder,
    String? loadingMessage,
    ErrorSeverity errorSeverity = ErrorSeverity.moderate,
    LoadingStyle loadingStyle = LoadingStyle.circular,
    bool compact = false,
  }) {
    return asyncValue.when(
      data: dataBuilder,
      loading: () => loadingWidget ?? loading(
        message: loadingMessage,
        style: loadingStyle,
        compact: compact,
      ),
      error: (error, stack) => errorBuilder?.call(error, stack) ?? 
        StandardizedErrorStates.error(
          message: 'Error: ${error.toString()}',
          severity: errorSeverity,
          compact: compact,
        ),
    );
  }

  // Private builders for different error styles
  static Widget _buildFullError(
    ThemeData theme,
    String message,
    IconData? icon,
    VoidCallback? onRetry,
    String? retryLabel,
    ErrorSeverity severity,
  ) {
    final errorColor = _getErrorColor(theme, severity);
    
    return GlassmorphismContainer(
      level: GlassLevel.content,
      glassTint: errorColor.withValues(alpha: 0.1),
      borderColor: errorColor.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? _getErrorIcon(severity),
            color: errorColor,
            size: 24,
          ),
          const SizedBox(height: SpacingTokens.sm),
          StandardizedText(
            message,
            style: StandardizedTextStyle.bodyMedium,
            color: errorColor,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: SpacingTokens.md),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(PhosphorIcons.arrowClockwise()),
              label: StandardizedText(
                retryLabel ?? 'Retry',
                style: StandardizedTextStyle.buttonText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildCompactError(
    ThemeData theme,
    String message,
    IconData? icon,
    ErrorSeverity severity,
  ) {
    final errorColor = _getErrorColor(theme, severity);
    
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.sm),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
        border: Border.all(
          color: errorColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? _getErrorIcon(severity),
            color: errorColor,
            size: 16,
          ),
          const SizedBox(width: SpacingTokens.xs),
          Flexible(
            child: StandardizedText(
              message,
              style: StandardizedTextStyle.bodySmall,
              color: errorColor,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCircularLoading(
    ThemeData theme,
    String? message,
    bool compact,
  ) {
    if (compact) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.colorScheme.primary,
          ),
        ),
      );
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: SpacingTokens.md),
              StandardizedText(
                message,
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

  static Widget _buildLinearLoading(
    ThemeData theme,
    String? message,
    bool compact,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinearProgressIndicator(
          minHeight: compact ? 2 : 4,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.colorScheme.primary,
          ),
        ),
        if (message != null && !compact) ...[
          const SizedBox(height: SpacingTokens.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
            child: StandardizedText(
              message,
              style: StandardizedTextStyle.bodySmall,
              color: theme.colorScheme.onSurfaceVariant,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  static Widget _buildMinimalLoading(
    ThemeData theme,
    String? message,
    bool compact,
  ) {
    return Padding(
      padding: EdgeInsets.all(compact ? SpacingTokens.sm : SpacingTokens.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: compact ? 16 : 20,
            height: compact ? 16 : 20,
            child: CircularProgressIndicator(
              strokeWidth: compact ? 2 : 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(width: SpacingTokens.sm),
            StandardizedText(
              message,
              style: compact ? StandardizedTextStyle.bodySmall : StandardizedTextStyle.bodyMedium,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildFullEmpty(
    ThemeData theme,
    String message,
    String? subtitle,
    IconData? icon,
    VoidCallback? onAction,
    String? actionLabel,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? PhosphorIcons.fileX(),
              color: theme.colorScheme.onSurfaceVariant,
              size: 48,
            ),
            const SizedBox(height: SpacingTokens.md),
            StandardizedText(
              message,
              style: StandardizedTextStyle.titleMedium,
              color: theme.colorScheme.onSurface,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: SpacingTokens.sm),
              StandardizedText(
                subtitle,
                style: StandardizedTextStyle.bodyMedium,
                color: theme.colorScheme.onSurfaceVariant,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: SpacingTokens.lg),
              ElevatedButton(
                onPressed: onAction,
                child: StandardizedText(
                  actionLabel,
                  style: StandardizedTextStyle.buttonText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget _buildCompactEmpty(
    ThemeData theme,
    String message,
    IconData? icon,
  ) {
    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? PhosphorIcons.fileX(),
            color: theme.colorScheme.onSurfaceVariant,
            size: 16,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Flexible(
            child: StandardizedText(
              message,
              style: StandardizedTextStyle.bodySmall,
              color: theme.colorScheme.onSurfaceVariant,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  static Color _getErrorColor(ThemeData theme, ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return theme.colorScheme.secondary;
      case ErrorSeverity.moderate:
        return theme.colorScheme.error;
      case ErrorSeverity.high:
        return theme.colorScheme.error;
      case ErrorSeverity.critical:
        return theme.colorScheme.error;
    }
  }

  static IconData _getErrorIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return PhosphorIcons.info();
      case ErrorSeverity.moderate:
        return PhosphorIcons.warning();
      case ErrorSeverity.high:
        return PhosphorIcons.warningOctagon();
      case ErrorSeverity.critical:
        return PhosphorIcons.xCircle();
    }
  }
}

/// Error severity levels for consistent error styling
enum ErrorSeverity {
  low,      // Info-level, secondary color
  moderate, // Standard error, error color  
  high,     // Important error, error color with emphasis
  critical, // Critical error, error color with strong emphasis
}

/// Loading style variants
enum LoadingStyle {
  circular, // Standard circular progress indicator
  linear,   // Linear progress bar
  minimal,  // Minimal inline loading indicator
}


/// Convenience widgets for common error state patterns
class StandardizedErrorStateVariants {
  /// Standard network error
  static Widget networkError({
    VoidCallback? onRetry,
    bool compact = false,
  }) {
    return StandardizedErrorStates.error(
      message: 'Network connection failed',
      icon: PhosphorIcons.wifiSlash(),
      onRetry: onRetry,
      retryLabel: 'Retry',
      severity: ErrorSeverity.moderate,
      compact: compact,
    );
  }

  /// Standard loading stats/data
  static Widget loadingData({
    String? message,
    bool compact = false,
  }) {
    return StandardizedErrorStates.loading(
      message: message ?? 'Loading...',
      style: LoadingStyle.minimal,
      compact: compact,
    );
  }

  /// Standard no data/empty list
  static Widget noData({
    String? message,
    VoidCallback? onRefresh,
    bool compact = false,
  }) {
    return StandardizedErrorStates.empty(
      message: message ?? 'No data available',
      subtitle: onRefresh != null ? 'Pull to refresh or tap to reload' : null,
      icon: PhosphorIcons.fileX(),
      onAction: onRefresh,
      actionLabel: onRefresh != null ? 'Refresh' : null,
      compact: compact,
    );
  }

  /// Standard permission error
  static Widget permissionError({
    required String message,
    VoidCallback? onOpenSettings,
    bool compact = false,
  }) {
    return StandardizedErrorStates.error(
      message: message,
      icon: PhosphorIcons.lock(),
      onRetry: onOpenSettings,
      retryLabel: 'Open Settings',
      severity: ErrorSeverity.high,
      compact: compact,
    );
  }
}