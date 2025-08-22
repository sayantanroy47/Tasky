import 'dart:async';
import 'package:flutter/foundation.dart';

/// Manages lazy initialization of services to improve startup performance
class LazyServiceManager {
  static final LazyServiceManager _instance = LazyServiceManager._internal();
  factory LazyServiceManager() => _instance;
  LazyServiceManager._internal();

  final Map<String, ServiceInitializer> _services = {};
  final Map<String, Completer<void>> _initializationCompleters = {};
  final Map<String, bool> _initialized = {};
  final Map<String, dynamic> _serviceInstances = {};

  /// Register a service for lazy initialization
  void registerService<T>({
    required String serviceId,
    required ServicePriority priority,
    required Future<T> Function() initializer,
    bool runInBackground = false,
  }) {
    _services[serviceId] = ServiceInitializer<T>(
      serviceId: serviceId,
      priority: priority,
      initializer: initializer,
      runInBackground: runInBackground,
    );
    _initialized[serviceId] = false;
  }

  /// Get a service instance, initializing if needed
  Future<T> getService<T>(String serviceId) async {
    if (_serviceInstances.containsKey(serviceId)) {
      return _serviceInstances[serviceId] as T;
    }

    if (!_initializationCompleters.containsKey(serviceId)) {
      _initializationCompleters[serviceId] = Completer<void>();
      _initializeService(serviceId);
    }

    await _initializationCompleters[serviceId]!.future;
    return _serviceInstances[serviceId] as T;
  }

  /// Check if a service is initialized
  bool isServiceInitialized(String serviceId) => _initialized[serviceId] ?? false;

  /// Initialize critical services immediately
  Future<void> initializeCriticalServices() async {
    final criticalServices = _services.entries
        .where((entry) => entry.value.priority == ServicePriority.critical)
        .toList();

    await Future.wait(
      criticalServices.map((service) => _initializeService(service.key)),
    );
  }

  /// Initialize non-critical services in background
  Future<void> initializeBackgroundServices() async {
    final backgroundServices = _services.entries
        .where((entry) => entry.value.priority != ServicePriority.critical)
        .toList();

    // Initialize high priority services first, then medium, then low
    for (final priority in [ServicePriority.high, ServicePriority.medium, ServicePriority.low]) {
      final priorityServices = backgroundServices
          .where((service) => service.value.priority == priority)
          .toList();

      if (priorityServices.isNotEmpty) {
        await Future.wait(
          priorityServices.map((service) => _initializeService(service.key)),
        );
        
        // Add small delay between priority levels to not overwhelm the main thread
        if (priority != ServicePriority.low) {
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }
    }
  }

  /// Initialize a specific service
  Future<void> _initializeService(String serviceId) async {
    if (_initialized[serviceId] == true) return;

    final service = _services[serviceId];
    if (service == null) return;

    try {
      if (kDebugMode) {
        print('LazyServiceManager: Initializing ${service.serviceId}...');
      }

      final stopwatch = Stopwatch()..start();
      
      dynamic serviceInstance;
      if (service.runInBackground && !kIsWeb) {
        // Run in isolate for heavy services (not on web)
        serviceInstance = await _initializeInIsolate(service);
      } else {
        serviceInstance = await service.initializer();
      }

      _serviceInstances[serviceId] = serviceInstance;
      _initialized[serviceId] = true;

      if (kDebugMode) {
        print('LazyServiceManager: ${service.serviceId} initialized in ${stopwatch.elapsedMilliseconds}ms');
      }

      if (_initializationCompleters.containsKey(serviceId)) {
        _initializationCompleters[serviceId]!.complete();
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('LazyServiceManager: Failed to initialize ${service.serviceId}: $error');
      }

      if (_initializationCompleters.containsKey(serviceId)) {
        _initializationCompleters[serviceId]!.completeError(error, stackTrace);
      }
    }
  }

  /// Initialize service in isolate for heavy operations
  Future<dynamic> _initializeInIsolate(ServiceInitializer service) async {
    // For now, just run on main thread
    // TODO: Implement proper isolate initialization for specific heavy services
    return await service.initializer();
  }

  /// Preload services that are likely to be needed soon
  Future<void> preloadServices(List<String> serviceIds) async {
    final futures = serviceIds
        .where((id) => !isServiceInitialized(id))
        .map((id) => _initializeService(id));

    await Future.wait(futures);
  }

  /// Get initialization status of all services
  Map<String, bool> getInitializationStatus() {
    return Map<String, bool>.from(_initialized);
  }
}

/// Service priority levels for initialization order
enum ServicePriority {
  critical,  // Must be initialized before app starts
  high,      // Should be initialized early but not blocking
  medium,    // Nice to have early
  low,       // Can be initialized later
}

/// Service initializer container
class ServiceInitializer<T> {
  final String serviceId;
  final ServicePriority priority;
  final Future<T> Function() initializer;
  final bool runInBackground;

  ServiceInitializer({
    required this.serviceId,
    required this.priority,
    required this.initializer,
    this.runInBackground = false,
  });
}

/// Service IDs for easy reference
class ServiceIds {
  static const String audioPlayback = 'audio_playback';
  static const String audioFileManager = 'audio_file_manager';
  static const String backgroundService = 'background_service';
  static const String shareIntent = 'share_intent';
  static const String widgetService = 'widget_service';
  static const String database = 'database';
  static const String privacy = 'privacy';
  static const String errorRecovery = 'error_recovery';
  static const String performance = 'performance';
  static const String themeService = 'theme_service';
  static const String locationService = 'location_service';
  static const String geofencingManager = 'geofencing_manager';
}