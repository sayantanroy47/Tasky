import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/task_repository.dart';
import '../../services/notification/notification_manager.dart';
import '../../services/notification/notification_models.dart';
import '../../services/notification/notification_service.dart';
import '../../services/notification/local_notification_service.dart';
import 'task_providers.dart';

/// Provider for the notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return LocalNotificationService();
});

/// Provider for the notification manager
final notificationManagerProvider = Provider<NotificationManager>((ref) {
  final taskRepository = ref.read(taskRepositoryProvider);
  final notificationService = ref.read(notificationServiceProvider);
  
  return NotificationManager(
    notificationService: notificationService,
    taskRepository: taskRepository,
  );
});

/// Provider for notification settings
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, AsyncValue<NotificationSettings>>((ref) {
  final notificationManager = ref.read(notificationManagerProvider);
  return NotificationSettingsNotifier(notificationManager);
});

/// Provider for scheduled notifications
final scheduledNotificationsProvider = StateNotifierProvider<ScheduledNotificationsNotifier, AsyncValue<List<ScheduledNotification>>>((ref) {
  final notificationManager = ref.read(notificationManagerProvider);
  return ScheduledNotificationsNotifier(notificationManager);
});

/// Provider for notification permissions status
final notificationPermissionsProvider = StateNotifierProvider<NotificationPermissionsNotifier, AsyncValue<bool>>((ref) {
  final notificationManager = ref.read(notificationManagerProvider);
  return NotificationPermissionsNotifier(notificationManager);
});

/// State notifier for notification settings
class NotificationSettingsNotifier extends StateNotifier<AsyncValue<NotificationSettings>> {
  final NotificationManager _notificationManager;

  NotificationSettingsNotifier(this._notificationManager) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _notificationManager.getSettings();
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateSettings(NotificationSettings settings) async {
    state = const AsyncValue.loading();
    
    try {
      await _notificationManager.updateSettings(settings);
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      await updateSettings(currentSettings.copyWith(enabled: enabled));
    }
  }

  Future<void> toggleDailySummary(bool enabled) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      await updateSettings(currentSettings.copyWith(dailySummary: enabled));
    }
  }

  Future<void> updateDailySummaryTime(NotificationTime time) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      await updateSettings(currentSettings.copyWith(dailySummaryTime: time));
    }
  }

  Future<void> updateDefaultReminder(Duration reminder) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      await updateSettings(currentSettings.copyWith(defaultReminder: reminder));
    }
  }

  Future<void> toggleOverdueNotifications(bool enabled) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      await updateSettings(currentSettings.copyWith(overdueNotifications: enabled));
    }
  }

  Future<void> setQuietHours(NotificationTime? start, NotificationTime? end) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      await updateSettings(currentSettings.copyWith(
        quietHoursStart: start,
        quietHoursEnd: end,
      ));
    }
  }

  Future<void> toggleVibration(bool enabled) async {
    final currentSettings = state.value;
    if (currentSettings != null) {
      await updateSettings(currentSettings.copyWith(vibrate: enabled));
    }
  }
}

/// State notifier for scheduled notifications
class ScheduledNotificationsNotifier extends StateNotifier<AsyncValue<List<ScheduledNotification>>> {
  final NotificationManager _notificationManager;

  ScheduledNotificationsNotifier(this._notificationManager) : super(const AsyncValue.loading()) {
    _loadScheduledNotifications();
  }

  Future<void> _loadScheduledNotifications() async {
    try {
      final notifications = await _notificationManager.getScheduledNotifications();
      state = AsyncValue.data(notifications);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadScheduledNotifications();
  }

  Future<void> cancelNotification(int notificationId) async {
    try {
      await _notificationManager.removeTaskNotifications(notificationId.toString());
      await _loadScheduledNotifications();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// State notifier for notification permissions
class NotificationPermissionsNotifier extends StateNotifier<AsyncValue<bool>> {
  final NotificationManager _notificationManager;

  NotificationPermissionsNotifier(this._notificationManager) : super(const AsyncValue.loading()) {
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      final hasPermissions = await _notificationManager.hasPermissions;
      state = AsyncValue.data(hasPermissions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> requestPermissions() async {
    try {
      final granted = await _notificationManager.requestPermissions();
      state = AsyncValue.data(granted);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _checkPermissions();
  }
}

/// Provider for notification initialization status
final notificationInitializationProvider = FutureProvider<bool>((ref) async {
  final notificationManager = ref.read(notificationManagerProvider);
  return await notificationManager.initialize();
});

/// Provider for showing test notification
final testNotificationProvider = Provider<Future<void> Function()>((ref) {
  final notificationManager = ref.read(notificationManagerProvider);
  return () => notificationManager.showTestNotification();
});
