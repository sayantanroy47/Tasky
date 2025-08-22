import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/location_providers.dart';
import '../widgets/glassmorphism_container.dart';
import '../../core/theme/typography_constants.dart';
import '../widgets/location_widgets.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/theme_background_widget.dart';
import '../../services/location/location_models.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LocationSettingsPage extends ConsumerWidget {
  const LocationSettingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationSettings = ref.watch(locationSettingsProvider);
    final locationPermission = ref.watch(locationPermissionProvider);
    final locationServiceEnabled = ref.watch(locationServiceEnabledProvider);

    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: const StandardizedAppBar(
          title: 'Location Settings',
        ),
        body: ListView(
          padding: const EdgeInsets.only(
            top: kToolbarHeight + 8,
            left: 16.0,
            right: 16.0,
            bottom: 16.0,
          ),
        children: [
          // Location Service Status
          GlassmorphismContainer(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location Service Status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  locationServiceEnabled.when(
                    data: (enabled) => _buildStatusRow(
                      'Location Services',
                      enabled,
                      enabled ? 'Enabled' : 'Disabled',
                      enabled ? Colors.green : Colors.red,
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  ),
                  const SizedBox(height: 8),
                  locationPermission.when(
                    data: (permission) => _buildStatusRow(
                      'Location Permission',
                      _isPermissionGranted(permission),
                      _getPermissionStatusText(permission),
                      _isPermissionGranted(permission) ? Colors.green : Colors.red,
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  ),
                ],
              ),
          ),
          const SizedBox(height: 16),

          // Location Features
          GlassmorphismContainer(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location Features',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enable Location Features'),
                    subtitle: const Text('Allow app to use location for task reminders'),
                    value: locationSettings.locationEnabled,
                    onChanged: (value) {
                      ref.read(locationSettingsProvider.notifier).updateLocationEnabled(value);
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Enable Geofencing'),
                    subtitle: const Text('Get notified when entering/leaving locations'),
                    value: locationSettings.geofencingEnabled,
                    onChanged: locationSettings.locationEnabled
                        ? (value) {
                            ref.read(locationSettingsProvider.notifier).updateGeofencingEnabled(value);
                          }
                        : null,
                  ),
                ],
              ),
          ),
          const SizedBox(height: 16),

          // Location Accuracy
          GlassmorphismContainer(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location Accuracy',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<LocationAccuracy>(
                    initialValue: locationSettings.locationAccuracy,
                    decoration: const InputDecoration(
                      labelText: 'Accuracy Level',
                      border: OutlineInputBorder(),
                    ),
                    items: LocationAccuracy.values.map((accuracy) {
                      return DropdownMenuItem(
                        value: accuracy,
                        child: Text(_getAccuracyLabel(accuracy)),
                      );
                    }).toList(),
                    onChanged: locationSettings.locationEnabled
                        ? (value) {
                            if (value != null) {
                              ref.read(locationSettingsProvider.notifier).updateLocationAccuracy(value);
                            }
                          }
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getAccuracyDescription(locationSettings.locationAccuracy),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
          ),
          const SizedBox(height: 16),

          // Current Location
          if (locationSettings.locationEnabled)
            GlassmorphismContainer(
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Location',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    LocationPermissionWidget(
                      child: CurrentLocationWidget(
                        builder: (location) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Latitude: ${location.latitude.toStringAsFixed(6)}'),
                            Text('Longitude: ${location.longitude.toStringAsFixed(6)}'),
                            if (location.accuracy != null)
                              Text('Accuracy: ${location.accuracy!.toStringAsFixed(1)}m'),
                            Text('Updated: ${_formatDateTime(location.timestamp)}'),
                            if (location.address != null)
                              Text('Address: ${location.address}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ),
          const SizedBox(height: 16),

          // Location Triggers
          GlassmorphismContainer(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Location Triggers',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton.icon(
                        onPressed: locationSettings.locationEnabled && locationSettings.geofencingEnabled
                            ? () => _showCreateGeofenceDialog(context, ref)
                            : null,
                        icon: Icon(PhosphorIcons.plus()),
                        label: const Text('Add Trigger'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, child) {
                      final triggers = ref.watch(locationTriggersProvider);
                      
                      if (triggers.isEmpty) {
                        return const Center(
                          child: Text('No location triggers configured'),
                        );
                      }

                      return Column(
                        children: triggers.map((trigger) => _buildTriggerTile(context, ref, trigger)).toList(),
                      );
                    },
                  ),
                ],
              ),
          ),
          const SizedBox(height: 16),

          // Actions
          GlassmorphismContainer(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final locationService = ref.read(locationServiceProvider);
                      await locationService.requestPermission();
                      ref.invalidate(locationPermissionProvider);
                    },
                    icon: Icon(PhosphorIcons.mapPin()),
                    label: const Text('Request Location Permission'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.invalidate(currentLocationProvider);
                      ref.invalidate(locationServiceEnabledProvider);
                    },
                    icon: Icon(PhosphorIcons.arrowClockwise()),
                    label: const Text('Refresh Location Status'),
                  ),
                ],
              ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildStatusRow(String label, bool isGood, String status, Color color) {
    return Row(
      children: [
        Icon(
          isGood ? PhosphorIcons.checkCircle() : PhosphorIcons.warningCircle(),
          color: color,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(label),
        const Spacer(),
        Text(
          status,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  bool _isPermissionGranted(LocationPermissionStatus permission) {
    return permission == LocationPermissionStatus.granted ||
           permission == LocationPermissionStatus.whileInUse ||
           permission == LocationPermissionStatus.always;
  }

  String _getPermissionStatusText(LocationPermissionStatus permission) {
    switch (permission) {
      case LocationPermissionStatus.granted:
      case LocationPermissionStatus.always:
        return 'Granted';
      case LocationPermissionStatus.whileInUse:
        return 'While in Use';
      case LocationPermissionStatus.denied:
        return 'Denied';
      case LocationPermissionStatus.deniedForever:
        return 'Permanently Denied';
      case LocationPermissionStatus.unableToDetermine:
        return 'Unknown';
      case LocationPermissionStatus.serviceDisabled:
        return 'Service Disabled';
    }
  }

  String _getAccuracyLabel(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.low:
        return 'Low (Battery Saving)';
      case LocationAccuracy.medium:
        return 'Medium (Balanced)';
      case LocationAccuracy.high:
        return 'High (GPS)';
      case LocationAccuracy.best:
        return 'Best (High Accuracy)';
    }
  }

  String _getAccuracyDescription(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.low:
        return 'Uses network location only. Lower battery usage but less accurate.';
      case LocationAccuracy.medium:
        return 'Balanced accuracy and battery usage.';
      case LocationAccuracy.high:
        return 'Uses GPS for high accuracy. Higher battery usage.';
      case LocationAccuracy.best:
        return 'Best possible accuracy. Highest battery usage.';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildTriggerTile(BuildContext context, WidgetRef ref, LocationTrigger trigger) {
    return ListTile(
      leading: Icon(
        trigger.isEnabled ? PhosphorIcons.mapPin() : PhosphorIcons.mapPin(),
        color: trigger.isEnabled ? Colors.green : Colors.grey,
      ),
      title: Text(trigger.geofence.name),
      subtitle: Text(
        '${trigger.geofence.radius.toInt()}m radius • ${_getGeofenceTypeLabel(trigger.geofence.type)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: trigger.isEnabled,
            onChanged: (value) {
              ref.read(locationTriggersProvider.notifier).toggleLocationTrigger(trigger.id);
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  // Show edit dialog for location trigger
                  _showEditLocationDialog(context, ref, trigger);
                  break;
                case 'delete':
                  ref.read(locationTriggersProvider.notifier).removeLocationTrigger(trigger.id);
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  String _getGeofenceTypeLabel(GeofenceType type) {
    switch (type) {
      case GeofenceType.enter:
        return 'On Enter';
      case GeofenceType.exit:
        return 'On Exit';
      case GeofenceType.both:
        return 'On Enter & Exit';
    }
  }

  void _showEditLocationDialog(BuildContext context, WidgetRef ref, LocationTrigger trigger) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: GeofenceConfigWidget(
            initialGeofence: trigger.geofence,
            onGeofenceCreated: (geofence) {
              final updatedTrigger = trigger.copyWith(geofence: geofence);
              ref.read(locationTriggersProvider.notifier).updateLocationTrigger(updatedTrigger);
            },
          ),
        ),
      ),
    );
  }

  void _showCreateGeofenceDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: GeofenceConfigWidget(
            onGeofenceCreated: (geofence) {
              final trigger = LocationTrigger(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                taskId: '', // This would be set when associating with a task
                geofence: geofence,
                isEnabled: true,
                createdAt: DateTime.now(),
              );
              ref.read(locationTriggersProvider.notifier).addLocationTrigger(trigger);
            },
          ),
        ),
      ),
    );
  }
}


