import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Standard error state management for consistent error handling across providers
class ErrorState {
  final String message;
  final String? code;
  final DateTime timestamp;
  final String? stackTrace;
  final ErrorSeverity severity;
  final Map<String, dynamic>? context;

  const ErrorState({
    required this.message,
    this.code,
    required this.timestamp,
    this.stackTrace,
    this.severity = ErrorSeverity.error,
    this.context,
  });

  ErrorState.fromException(
    Exception exception, {
    String? code,
    ErrorSeverity severity = ErrorSeverity.error,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) : this(
    message: exception.toString(),
    code: code,
    timestamp: DateTime.now(),
    stackTrace: stackTrace?.toString(),
    severity: severity,
    context: context,
  );

  ErrorState.fromError(
    Object error, {
    String? code,
    ErrorSeverity severity = ErrorSeverity.error,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) : this(
    message: error.toString(),
    code: code,
    timestamp: DateTime.now(),
    stackTrace: stackTrace?.toString(),
    severity: severity,
    context: context,
  );

  ErrorState copyWith({
    String? message,
    String? code,
    DateTime? timestamp,
    String? stackTrace,
    ErrorSeverity? severity,
    Map<String, dynamic>? context,
  }) {
    return ErrorState(
      message: message ?? this.message,
      code: code ?? this.code,
      timestamp: timestamp ?? this.timestamp,
      stackTrace: stackTrace ?? this.stackTrace,
      severity: severity ?? this.severity,
      context: context ?? this.context,
    );
  }

  bool get isRecoverable => severity != ErrorSeverity.critical;
  bool get requiresUserAction => severity == ErrorSeverity.warning || severity == ErrorSeverity.error;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is ErrorState &&
    runtimeType == other.runtimeType &&
    message == other.message &&
    code == other.code &&
    severity == other.severity;

  @override
  int get hashCode => message.hashCode ^ code.hashCode ^ severity.hashCode;

  @override
  String toString() {
    return 'ErrorState{message: $message, code: $code, severity: $severity}';
  }
}

/// Error severity levels
enum ErrorSeverity {
  info,     // Informational, no action required
  warning,  // Warning, may require user attention
  error,    // Error, requires user action
  critical, // Critical error, app functionality compromised
}

/// Global error state manager
class ErrorStateManager extends StateNotifier<List<ErrorState>> {
  ErrorStateManager() : super([]);

  /// Add an error to the global error state
  void addError(ErrorState error) {
    state = [...state, error];
    
    // Auto-clear info messages after 5 seconds
    if (error.severity == ErrorSeverity.info) {
      Future.delayed(const Duration(seconds: 5), () {
        removeError(error);
      });
    }
  }

  /// Add error from exception
  void addException(
    Exception exception, {
    String? code,
    ErrorSeverity severity = ErrorSeverity.error,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) {
    addError(ErrorState.fromException(
      exception,
      code: code,
      severity: severity,
      context: context,
      stackTrace: stackTrace,
    ));
  }

  /// Add error from any error object
  void addGenericError(
    Object error, {
    String? code,
    ErrorSeverity severity = ErrorSeverity.error,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) {
    addError(ErrorState.fromError(
      error,
      code: code,
      severity: severity,
      context: context,
      stackTrace: stackTrace,
    ));
  }

  /// Remove a specific error
  void removeError(ErrorState error) {
    state = state.where((e) => e != error).toList();
  }

  /// Clear all errors
  void clearAllErrors() {
    state = [];
  }

  /// Clear errors by severity
  void clearErrorsBySeverity(ErrorSeverity severity) {
    state = state.where((error) => error.severity != severity).toList();
  }

  /// Clear errors by code
  void clearErrorsByCode(String code) {
    state = state.where((error) => error.code != code).toList();
  }

  /// Get errors by severity
  List<ErrorState> getErrorsBySeverity(ErrorSeverity severity) {
    return state.where((error) => error.severity == severity).toList();
  }

  /// Check if there are any critical errors
  bool get hasCriticalErrors {
    return state.any((error) => error.severity == ErrorSeverity.critical);
  }

  /// Check if there are any errors that require user action
  bool get hasActionableErrors {
    return state.any((error) => error.requiresUserAction);
  }

  /// Get the most recent error
  ErrorState? get latestError {
    if (state.isEmpty) return null;
    return state.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
  }
}

/// Provider for global error state management
final errorStateManagerProvider = StateNotifierProvider<ErrorStateManager, List<ErrorState>>((ref) {
  return ErrorStateManager();
});

/// Helper extension for providers to easily report errors
extension ProviderErrorExtension on Ref {
  /// Report an error to the global error state
  void reportError(
    Object error, {
    String? code,
    ErrorSeverity severity = ErrorSeverity.error,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) {
    read(errorStateManagerProvider.notifier).addGenericError(
      error,
      code: code,
      severity: severity,
      context: context,
      stackTrace: stackTrace,
    );
  }

  /// Report an exception to the global error state
  void reportException(
    Exception exception, {
    String? code,
    ErrorSeverity severity = ErrorSeverity.error,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) {
    read(errorStateManagerProvider.notifier).addException(
      exception,
      code: code,
      severity: severity,
      context: context,
      stackTrace: stackTrace,
    );
  }
}

/// Computed providers for specific error states
final criticalErrorsProvider = Provider<List<ErrorState>>((ref) {
  final errors = ref.watch(errorStateManagerProvider);
  return errors.where((error) => error.severity == ErrorSeverity.critical).toList();
});

final actionableErrorsProvider = Provider<List<ErrorState>>((ref) {
  final errors = ref.watch(errorStateManagerProvider);
  return errors.where((error) => error.requiresUserAction).toList();
});

final latestErrorProvider = Provider<ErrorState?>((ref) {
  final errors = ref.watch(errorStateManagerProvider);
  if (errors.isEmpty) return null;
  return errors.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b);
});