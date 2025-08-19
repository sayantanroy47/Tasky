import 'package:flutter/material.dart';
import 'dart:async';
import '../accessibility/accessibility_constants.dart';

/// Comprehensive error handling system with glassmorphism UI
class AppErrorHandler {
  static AppErrorHandler? _instance;
  static AppErrorHandler get instance => _instance ??= AppErrorHandler._internal();
  
  AppErrorHandler._internal();

  final List<AppError> _errorHistory = [];
  final StreamController<AppError> _errorStream = StreamController<AppError>.broadcast();
  
  /// Stream of errors for global error handling
  Stream<AppError> get errorStream => _errorStream.stream;
  
  /// Error history for debugging
  List<AppError> get errorHistory => List.unmodifiable(_errorHistory);

  /// Handle error with context for UI feedback
  void handleError(
    dynamic error, {
    StackTrace? stackTrace,
    BuildContext? context,
    String? userMessage,
    ErrorSeverity severity = ErrorSeverity.warning,
    ErrorCategory category = ErrorCategory.general,
    bool showToUser = true,
    Map<String, dynamic>? metadata,
  }) {
    final appError = _createAppError(
      error,
      stackTrace: stackTrace,
      userMessage: userMessage,
      severity: severity,
      category: category,
      metadata: metadata,
    );

    // Add to history
    _addToHistory(appError);
    
    // Broadcast to listeners
    _errorStream.add(appError);

    // Show to user if requested
    if (showToUser && context != null && context.mounted) {
      _showErrorToUser(context, appError);
    }

    // Log error (in production, this would go to crash reporting)
    _logError(appError);
  }

  /// Handle async operation with automatic error handling
  Future<T?> handleAsyncOperation<T>(
    Future<T> Function() operation, {
    BuildContext? context,
    String? operationName,
    String? userMessage,
    bool showLoadingIndicator = false,
    bool showSuccessMessage = false,
    String? successMessage,
    T? fallbackValue,
  }) async {
    try {
      // Show loading if requested
      if (showLoadingIndicator && context != null) {
        // This would show a loading indicator
      }

      final result = await operation();

      // Show success message if requested
      if (showSuccessMessage && context != null && context.mounted && successMessage != null) {
        _showSuccessMessage(context, successMessage);
      }

      return result;
    } catch (error, stackTrace) {
      handleError(
        error,
        stackTrace: stackTrace,
        context: context?.mounted == true ? context : null,
        userMessage: userMessage ?? 'Operation failed',
        category: ErrorCategory.operation,
        severity: ErrorSeverity.error,
      );
      return fallbackValue;
    }
  }

  /// Create standardized AppError from various error types
  AppError _createAppError(
    dynamic error, {
    StackTrace? stackTrace,
    String? userMessage,
    ErrorSeverity severity = ErrorSeverity.warning,
    ErrorCategory category = ErrorCategory.general,
    Map<String, dynamic>? metadata,
  }) {
    String message = userMessage ?? 'An unexpected error occurred';
    String? technicalDetails;
    ErrorType type = ErrorType.unknown;

    if (error is AppError) {
      return error;
    } else if (error is Exception) {
      technicalDetails = error.toString();
      type = _categorizeException(error);
      message = userMessage ?? _getUserMessageForException(error);
    } else if (error is Error) {
      technicalDetails = error.toString();
      type = ErrorType.systemError;
      message = userMessage ?? 'A system error occurred';
    } else if (error is String) {
      message = userMessage ?? error;
      technicalDetails = error;
      type = ErrorType.validation;
    } else {
      technicalDetails = error.toString();
    }

    return AppError(
      message: message,
      technicalDetails: technicalDetails,
      stackTrace: stackTrace,
      severity: severity,
      category: category,
      type: type,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );
  }

  /// Categorize exception types
  ErrorType _categorizeException(Exception exception) {
    final errorString = exception.toString().toLowerCase();
    
    if (errorString.contains('network') || errorString.contains('connection')) {
      return ErrorType.network;
    } else if (errorString.contains('timeout')) {
      return ErrorType.timeout;
    } else if (errorString.contains('permission') || errorString.contains('access')) {
      return ErrorType.permission;
    } else if (errorString.contains('validation') || errorString.contains('invalid')) {
      return ErrorType.validation;
    } else if (errorString.contains('not found') || errorString.contains('404')) {
      return ErrorType.notFound;
    }
    
    return ErrorType.unknown;
  }

  /// Get user-friendly message for common exceptions
  String _getUserMessageForException(Exception exception) {
    final errorString = exception.toString().toLowerCase();
    
    // Network and connectivity errors
    if (errorString.contains('network') || errorString.contains('connection') || 
        errorString.contains('socket') || errorString.contains('dns')) {
      return 'Unable to connect to the internet. Please check your connection and try again.';
    } 
    
    // Timeout errors
    else if (errorString.contains('timeout') || errorString.contains('deadline exceeded')) {
      return 'The request is taking longer than expected. Please check your connection and try again.';
    } 
    
    // Permission errors
    else if (errorString.contains('permission') || errorString.contains('unauthorized') || 
             errorString.contains('forbidden') || errorString.contains('access denied')) {
      return 'You don\'t have permission to perform this action. Please check your access rights.';
    } 
    
    // Not found errors
    else if (errorString.contains('not found') || errorString.contains('404')) {
      return 'The item you\'re looking for couldn\'t be found. It may have been moved or deleted.';
    }
    
    // Database errors
    else if (errorString.contains('database') || errorString.contains('sql') || 
             errorString.contains('constraint') || errorString.contains('unique')) {
      return 'There was a problem saving your data. Please try again.';
    }
    
    // File system errors
    else if (errorString.contains('file') || errorString.contains('directory') || 
             errorString.contains('storage') || errorString.contains('disk')) {
      return 'There was a problem accessing files. Please check your device storage.';
    }
    
    // API/Server errors
    else if (errorString.contains('server') || errorString.contains('api') || 
             errorString.contains('service') || errorString.contains('500')) {
      return 'Our servers are experiencing issues. Please try again in a few minutes.';
    }
    
    // Authentication errors
    else if (errorString.contains('auth') || errorString.contains('login') || 
             errorString.contains('token') || errorString.contains('expired')) {
      return 'Your session has expired. Please log in again to continue.';
    }
    
    // Validation errors
    else if (errorString.contains('validation') || errorString.contains('invalid') || 
             errorString.contains('format') || errorString.contains('required')) {
      return 'Please check your input and make sure all required fields are filled correctly.';
    }
    
    // Rate limiting
    else if (errorString.contains('rate') || errorString.contains('limit') || 
             errorString.contains('quota') || errorString.contains('429')) {
      return 'You\'ve made too many requests. Please wait a moment and try again.';
    }
    
    // Memory/resource errors  
    else if (errorString.contains('memory') || errorString.contains('resource') || 
             errorString.contains('out of')) {
      return 'Your device is running low on resources. Please close some apps and try again.';
    }
    
    // Default friendly message
    return 'Something unexpected happened. Please try again, and if the problem continues, restart the app.';
  }

  /// Show error to user with appropriate UI
  void _showErrorToUser(BuildContext context, AppError error) {
    switch (error.severity) {
      case ErrorSeverity.info:
        _showInfoSnackBar(context, error);
        break;
      case ErrorSeverity.warning:
        _showWarningSnackBar(context, error);
        break;
      case ErrorSeverity.error:
        _showErrorDialog(context, error);
        break;
      case ErrorSeverity.critical:
        _showCriticalErrorDialog(context, error);
        break;
    }
  }

  /// Show info snackbar
  void _showInfoSnackBar(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
    AccessibilityUtils.announceToScreenReader(context, 'Info: ${error.message}');
  }

  /// Show warning snackbar
  void _showWarningSnackBar(BuildContext context, AppError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(error.message)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: error.type == ErrorType.network
            ? SnackBarAction(
                label: 'Retry',
                onPressed: () => _handleRetry(context, error),
                textColor: Colors.white,
              )
            : null,
      ),
    );
    AccessibilityUtils.announceToScreenReader(context, 'Warning: ${error.message}');
  }

  /// Show error dialog
  void _showErrorDialog(BuildContext context, AppError error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(error.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    AccessibilityUtils.announceToScreenReader(context, 'Error: ${error.message}');
  }

  /// Show critical error dialog
  void _showCriticalErrorDialog(BuildContext context, AppError error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Critical Error'),
        content: Text(error.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    AccessibilityUtils.announceToScreenReader(context, 'Critical error: ${error.message}');
  }

  /// Show success message
  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
    AccessibilityUtils.announceToScreenReader(context, 'Success: $message');
  }

  /// Handle retry for recoverable errors
  void _handleRetry(BuildContext context, AppError error) {
    // Implementation would depend on the specific error and retry mechanism
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Retrying...'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Add error to history
  void _addToHistory(AppError error) {
    _errorHistory.add(error);
    
    // Keep history size manageable
    if (_errorHistory.length > 100) {
      _errorHistory.removeAt(0);
    }
  }

  /// Log error (placeholder for crash reporting integration)
  void _logError(AppError error) {
    debugPrint('AppError: ${error.message}');
    if (error.technicalDetails != null) {
      debugPrint('Details: ${error.technicalDetails}');
    }
    if (error.stackTrace != null) {
      debugPrint('Stack trace: ${error.stackTrace}');
    }
    
    // In production, this would send to crash reporting service
    // like Firebase Crashlytics, Sentry, etc.
  }

  /// Clear error history
  void clearHistory() {
    _errorHistory.clear();
  }

  /// Dispose resources
  void dispose() {
    _errorStream.close();
  }
}

/// Standardized error model
class AppError {
  final String message;
  final String? technicalDetails;
  final StackTrace? stackTrace;
  final ErrorSeverity severity;
  final ErrorCategory category;
  final ErrorType type;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const AppError({
    required this.message,
    this.technicalDetails,
    this.stackTrace,
    this.severity = ErrorSeverity.warning,
    this.category = ErrorCategory.general,
    this.type = ErrorType.unknown,
    required this.timestamp,
    this.metadata = const {},
  });

  AppError copyWith({
    String? message,
    String? technicalDetails,
    StackTrace? stackTrace,
    ErrorSeverity? severity,
    ErrorCategory? category,
    ErrorType? type,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return AppError(
      message: message ?? this.message,
      technicalDetails: technicalDetails ?? this.technicalDetails,
      stackTrace: stackTrace ?? this.stackTrace,
      severity: severity ?? this.severity,
      category: category ?? this.category,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'AppError(message: $message, severity: $severity, type: $type, timestamp: $timestamp)';
  }
}

/// Error severity levels
enum ErrorSeverity {
  info,
  warning,
  error,
  critical,
}

/// Error categories for organization
enum ErrorCategory {
  general,
  network,
  storage,
  authentication,
  authorization,
  validation,
  operation,
  ui,
  performance,
}

/// Specific error types for targeted handling
enum ErrorType {
  unknown,
  network,
  timeout,
  permission,
  validation,
  notFound,
  systemError,
  userError,
}