import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/background/background_task_service.dart';
import '../../core/providers/core_providers.dart';
import 'recurring_task_providers.dart';

/// Provider for BackgroundTaskService with proper dependency injection
final backgroundTaskServiceProvider = Provider<BackgroundTaskService>((ref) {
  final service = BackgroundTaskService.instance;
  final recurringTaskService = ref.read(recurringTaskServiceProvider);
  final taskRepository = ref.read(taskRepositoryProvider);
  
  // Inject dependencies
  service.setDependencies(
    recurringTaskService: recurringTaskService,
    taskRepository: taskRepository,
  );
  
  return service;
});

/// Provider for background service initialization status
final backgroundServiceInitializedProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(backgroundTaskServiceProvider);
  return await service.initialize();
});

/// Provider for background service status
final backgroundServiceStatusProvider = Provider<Map<String, dynamic>>((ref) {
  final service = ref.read(backgroundTaskServiceProvider);
  return service.getServiceStatus();
});

/// Provider to start background processing
final backgroundProcessingProvider = FutureProvider<void>((ref) async {
  final service = ref.read(backgroundTaskServiceProvider);
  final isInitialized = await ref.read(backgroundServiceInitializedProvider.future);
  
  if (isInitialized && service.isServiceEnabled) {
    await service.startBackgroundProcessing();
  }
});

/// State notifier for managing background service state
class BackgroundServiceNotifier extends StateNotifier<BackgroundServiceState> {
  final BackgroundTaskService _service;
  final Ref _ref;

  BackgroundServiceNotifier(this._service, this._ref) 
      : super(const BackgroundServiceState.loading()) {
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      final initialized = await _service.initialize();
      if (initialized) {
        state = BackgroundServiceState.ready(_service.getServiceStatus());
        if (_service.isServiceEnabled) {
          await _service.startBackgroundProcessing();
          state = BackgroundServiceState.running(_service.getServiceStatus());
        }
      } else {
        state = const BackgroundServiceState.error('Failed to initialize background service');
      }
    } catch (e) {
      state = BackgroundServiceState.error('Initialization error: $e');
    }
  }

  Future<void> toggleService(bool enabled) async {
    try {
      await _service.setServiceEnabled(enabled);
      final status = _service.getServiceStatus();
      
      if (enabled) {
        state = BackgroundServiceState.running(status);
      } else {
        state = BackgroundServiceState.ready(status);
      }
    } catch (e) {
      state = BackgroundServiceState.error('Toggle error: $e');
    }
  }

  Future<void> forceProcessRecurringTasks() async {
    try {
      final recurringService = _ref.read(recurringTaskServiceProvider);
      await recurringService.processCompletedRecurringTasks();
      
      // Update state to reflect that processing was done
      final status = _service.getServiceStatus();
      status['last_manual_processing'] = DateTime.now().toIso8601String();
      
      state = state.maybeWhen(
        running: (_) => BackgroundServiceState.running(status),
        ready: (_) => BackgroundServiceState.ready(status),
        orElse: () => state,
) ?? state;
    } catch (e) {
      state = BackgroundServiceState.error('Manual processing error: $e');
    }
  }

  Future<void> refreshStatus() async {
    try {
      final status = _service.getServiceStatus();
      
      if (_service.isServiceEnabled) {
        state = BackgroundServiceState.running(status);
      } else {
        state = BackgroundServiceState.ready(status);
      }
    } catch (e) {
      state = BackgroundServiceState.error('Status refresh error: $e');
    }
  }
}

/// Provider for BackgroundServiceNotifier
final backgroundServiceNotifierProvider = 
    StateNotifierProvider<BackgroundServiceNotifier, BackgroundServiceState>((ref) {
  final service = ref.read(backgroundTaskServiceProvider);
  return BackgroundServiceNotifier(service, ref);
});

/// Background service state
sealed class BackgroundServiceState {
  const BackgroundServiceState();

  const factory BackgroundServiceState.loading() = _LoadingState;
  const factory BackgroundServiceState.ready(Map<String, dynamic> status) = _ReadyState;
  const factory BackgroundServiceState.running(Map<String, dynamic> status) = _RunningState;
  const factory BackgroundServiceState.error(String message) = _ErrorState;

  T when<T>({
    required T Function() loading,
    required T Function(Map<String, dynamic> status) ready,
    required T Function(Map<String, dynamic> status) running,
    required T Function(String message) error,
  }) {
    return switch (this) {
      _LoadingState() => loading(),
      _ReadyState(:final status) => ready(status),
      _RunningState(:final status) => running(status),
      _ErrorState(:final message) => error(message),
    };
  }

  T? maybeWhen<T>({
    T Function()? loading,
    T Function(Map<String, dynamic> status)? ready,
    T Function(Map<String, dynamic> status)? running,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    return switch (this) {
      _LoadingState() => loading?.call() ?? orElse(),
      _ReadyState(:final status) => ready?.call(status) ?? orElse(),
      _RunningState(:final status) => running?.call(status) ?? orElse(),
      _ErrorState(:final message) => error?.call(message) ?? orElse(),
    };
  }
}

class _LoadingState extends BackgroundServiceState {
  const _LoadingState();
}

class _ReadyState extends BackgroundServiceState {
  final Map<String, dynamic> status;
  const _ReadyState(this.status);
}

class _RunningState extends BackgroundServiceState {
  final Map<String, dynamic> status;
  const _RunningState(this.status);
}

class _ErrorState extends BackgroundServiceState {
  final String message;
  const _ErrorState(this.message);
}