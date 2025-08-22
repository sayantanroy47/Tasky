import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/lazy_service_manager.dart';
import '../../services/audio/lazy_audio_playback_service.dart';
import '../../services/audio/audio_file_manager.dart';
import '../../services/widget_service.dart';
import '../../services/background/simple_background_service.dart';

/// Lazy service manager provider
final lazyServiceManagerProvider = Provider<LazyServiceManager>((ref) {
  return LazyServiceManager();
});

/// Lazy audio playback service provider
final lazyAudioPlaybackServiceProvider = FutureProvider<LazyAudioPlaybackService>((ref) async {
  final serviceManager = ref.watch(lazyServiceManagerProvider);
  return await serviceManager.getService<LazyAudioPlaybackService>(ServiceIds.audioPlayback);
});

/// Audio file manager provider (lazy)
final audioFileManagerProvider = FutureProvider<AudioFileManager>((ref) async {
  final serviceManager = ref.watch(lazyServiceManagerProvider);
  return await serviceManager.getService<AudioFileManager>(ServiceIds.audioFileManager);
});

/// Widget service provider (lazy)
final widgetServiceProvider = FutureProvider<WidgetService>((ref) async {
  final serviceManager = ref.watch(lazyServiceManagerProvider);
  return await serviceManager.getService<WidgetService>(ServiceIds.widgetService);
});

/// Background service provider (lazy)
final backgroundServiceProvider = FutureProvider<SimpleBackgroundService>((ref) async {
  final serviceManager = ref.watch(lazyServiceManagerProvider);
  return await serviceManager.getService<SimpleBackgroundService>(ServiceIds.backgroundService);
});

/// Service status provider for monitoring initialization
final serviceStatusProvider = Provider<Map<String, bool>>((ref) {
  final serviceManager = ref.watch(lazyServiceManagerProvider);
  return serviceManager.getInitializationStatus();
});

/// Helper provider to preload services that are likely needed soon
final servicePreloaderProvider = Provider.family<Future<void>, List<String>>((ref, serviceIds) async {
  final serviceManager = ref.watch(lazyServiceManagerProvider);
  return serviceManager.preloadServices(serviceIds);
});

/// Provider for checking if critical services are ready
final criticalServicesReadyProvider = Provider<bool>((ref) {
  final serviceManager = ref.watch(lazyServiceManagerProvider);
  final status = serviceManager.getInitializationStatus();
  
  // Check if all critical services are initialized
  final criticalServiceIds = [ServiceIds.performance, ServiceIds.shareIntent];
  return criticalServiceIds.every((id) => status[id] == true);
});

/// Provider for checking if high-priority services are ready
final highPriorityServicesReadyProvider = Provider<bool>((ref) {
  final serviceManager = ref.watch(lazyServiceManagerProvider);
  final status = serviceManager.getInitializationStatus();
  
  // Check if high-priority services are initialized
  final highPriorityServiceIds = [ServiceIds.widgetService, ServiceIds.audioFileManager];
  return highPriorityServiceIds.every((id) => status[id] == true);
});

/// Provider for warm up audio service when likely to be needed
final audioServiceWarmerProvider = Provider<Future<void>>((ref) async {
  final lazyAudio = LazyAudioPlaybackService.instance;
  await lazyAudio.warmup();
});