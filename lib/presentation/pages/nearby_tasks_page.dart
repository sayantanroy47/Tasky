import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/theme_background_widget.dart';
import '../widgets/location_task_widgets.dart';
import '../widgets/location_widgets.dart';
import '../widgets/glassmorphism_container.dart';
import '../../core/theme/typography_constants.dart';
import '../providers/location_providers.dart';
import '../../services/location/location_task_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NearbyTasksPage extends ConsumerStatefulWidget {
  const NearbyTasksPage({super.key});
  @override
  ConsumerState<NearbyTasksPage> createState() => _NearbyTasksPageState();
}

class _NearbyTasksPageState extends ConsumerState<NearbyTasksPage> {
  double _radiusInMeters = 1000;
  bool _showOnlyActiveTriggers = false;
  @override
  Widget build(BuildContext context) {
    final locationSettings = ref.watch(locationSettingsProvider);

    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: StandardizedAppBar(
          title: 'Nearby Tasks',
          actions: [
            IconButton(
              icon: Icon(PhosphorIcons.sliders()),
              onPressed: _showFilterDialog,
            ),
            IconButton(
              icon: Icon(PhosphorIcons.arrowClockwise()),
              onPressed: () {
                setState(() {
                  // Trigger rebuild to refresh data
                });
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight + 8),
          child: locationSettings.locationEnabled
            ? Column(
              children: [
                // Location status and settings
                _buildLocationStatusCard(),
                
                // Filter chips
                _buildFilterChips(),
                
                // Nearby tasks list
                Expanded(
                  child: NearbyTasksList(
                    radiusInMeters: _radiusInMeters,
                    onTaskTap: _handleTaskTap,
                    onLocationToggle: _handleLocationToggle,
                  ),
                ),
              ],
            )
          : _buildLocationDisabledView(),
        ),
      ),
    );
  }

  Widget _buildLocationStatusCard() {
    return GlassmorphismContainer(
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIcons.mapPin(), color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Location Services Active',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Showing tasks within ${_formatDistance(_radiusInMeters)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            CurrentLocationWidget(
              builder: (location) => Text(
                'Current: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
              loadingWidget: const Text('Getting location...'),
              errorWidget: const Text('Location unavailable'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          FilterChip(
            label: Text('${_formatDistance(_radiusInMeters)} radius'),
            selected: true,
            onSelected: (_) => _showRadiusDialog(),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Active triggers only'),
            selected: _showOnlyActiveTriggers,
            onSelected: (selected) {
              setState(() {
                _showOnlyActiveTriggers = selected;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDisabledView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.mapPin(),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Location Services Disabled',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enable location services in settings to see nearby tasks and create location-based reminders.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/location-settings');
              },
              icon: Icon(PhosphorIcons.gear()),
              label: const Text('Open Location Settings'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTaskTap(TaskLocationInfo taskLocationInfo) {
    Navigator.of(context).pushNamed(
      '/task-detail',
      arguments: taskLocationInfo.task.id,
    );
  }

  void _handleLocationToggle(TaskLocationInfo taskLocationInfo) {
    // Toggle location trigger for the task
    final newEnabled = !taskLocationInfo.trigger.isEnabled;
    
    // Update the trigger (this would typically use a service)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newEnabled
              ? 'Location reminder enabled for ${taskLocationInfo.task.title}'
              : 'Location reminder disabled for ${taskLocationInfo.task.title}',
        ),
      ),
    );

    // Refresh the list
    setState(() {});
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Search Radius'),
              subtitle: Text(_formatDistance(_radiusInMeters)),
              trailing: Icon(PhosphorIcons.pencil()),
              onTap: () {
                Navigator.of(context).pop();
                _showRadiusDialog();
              },
            ),
            SwitchListTile(
              title: const Text('Active Triggers Only'),
              subtitle: const Text('Show only tasks with enabled location triggers'),
              value: _showOnlyActiveTriggers,
              onChanged: (value) {
                setState(() {
                  _showOnlyActiveTriggers = value;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRadiusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Radius'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current radius: ${_formatDistance(_radiusInMeters)}'),
            const SizedBox(height: 16),
            Slider(
              value: _radiusInMeters,
              min: 100,
              max: 10000,
              divisions: 99,
              label: _formatDistance(_radiusInMeters),
              onChanged: (value) {
                setState(() {
                  _radiusInMeters = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }


  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toInt()}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }
}


