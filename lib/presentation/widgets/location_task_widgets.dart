import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography_constants.dart';
import '../../services/location/location_models.dart';
import '../../services/location/location_task_service.dart';
import '../../domain/models/enums.dart';
import 'location_widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LocationTaskCard extends ConsumerWidget {
  final TaskLocationInfo taskLocationInfo;
  final VoidCallback? onTap;
  final VoidCallback? onLocationTriggerToggle;

  const LocationTaskCard({
    super.key,
    required this.taskLocationInfo,
    this.onTap,
    this.onLocationTriggerToggle,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = taskLocationInfo.task;
    final trigger = taskLocationInfo.trigger;
    final distance = taskLocationInfo.distance;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  Icon(
                    trigger.isEnabled ? PhosphorIcons.mapPin() : PhosphorIcons.mapPin(),
                    color: trigger.isEnabled ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                ],
              ),
              
              if (task.description?.isNotEmpty == true) ...[
                SizedBox(height: 8),
                Text(
                  task.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Location info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(PhosphorIcons.mapPin(), size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            trigger.geofence.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Distance: ${_formatDistance(distance)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Radius: ${trigger.geofence.radius.toInt()}m',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Trigger: ${_getGeofenceTypeLabel(trigger.geofence.type)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Priority and due date
                  Row(
                    children: [
                      _buildPriorityChip(task.priority),
                      if (task.dueDate != null) ...[
                        const SizedBox(width: 8),
                        _buildDueDateChip(task.dueDate!),
                      ],
                    ],
                  ),
                  
                  // Toggle location trigger
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Location',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Switch(
                        value: trigger.isEnabled,
                        onChanged: (_) => onLocationTriggerToggle?.call(),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    Color color;
    String label;
    
    switch (priority) {
      case TaskPriority.low:
        color = Colors.green;
        label = 'Low';
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        label = 'Medium';
        break;
      case TaskPriority.high:
        color = Colors.red;
        label = 'High';
        break;
      case TaskPriority.urgent:
        color = Colors.red.shade800;
        label = 'Urgent';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: TextStyle(color: color, fontSize: 12),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildDueDateChip(DateTime dueDate) {
    final now = DateTime.now();
    final isOverdue = dueDate.isBefore(now);
    final color = isOverdue ? Colors.red : Colors.blue;

    return Chip(
      label: Text(
        _formatDate(dueDate),
        style: TextStyle(color: color, fontSize: 12),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toInt()}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}';
    }
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
}

class NearbyTasksList extends ConsumerWidget {
  final double radiusInMeters;
  final Function(TaskLocationInfo)? onTaskTap;
  final Function(TaskLocationInfo)? onLocationToggle;

  const NearbyTasksList({
    super.key,
    this.radiusInMeters = 1000,
    this.onTaskTap,
    this.onLocationToggle,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LocationPermissionWidget(
      child: CurrentLocationWidget(
        builder: (location) {
          return FutureBuilder<List<TaskLocationInfo>>(
            future: _getNearbyTasks(location),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIcons.warningCircle(), color: Colors.red),
                      const SizedBox(height: 8),
                      Text('Error: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              final nearbyTasks = snapshot.data ?? [];

              if (nearbyTasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.crosshair(),
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks found nearby',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tasks within ${_formatDistance(radiusInMeters)} will appear here',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: nearbyTasks.length,
                itemBuilder: (context, index) {
                  final taskLocationInfo = nearbyTasks[index];
                  return LocationTaskCard(
                    taskLocationInfo: taskLocationInfo,
                    onTap: () => onTaskTap?.call(taskLocationInfo),
                    onLocationTriggerToggle: () => onLocationToggle?.call(taskLocationInfo),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<TaskLocationInfo>> _getNearbyTasks(LocationData location) async {
    // This would typically use a location task service
    // For now, return empty list as placeholder
    return [];
  }

  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toInt()}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }
}

class LocationStatisticsWidget extends ConsumerWidget {
  const LocationStatisticsWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<LocationStatistics>(
      future: _getLocationStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error loading statistics: ${snapshot.error}'),
            ),
          );
        }

        final stats = snapshot.data;
        if (stats == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No location statistics available'),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Statistics',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 16),
                _buildStatRow(
                  'Total Location Triggers',
                  stats.totalLocationTriggers.toString(),
                  PhosphorIcons.mapPin(),
                ),
                _buildStatRow(
                  'Active Triggers',
                  stats.activeLocationTriggers.toString(),
                  PhosphorIcons.bell(),
                ),
                _buildStatRow(
                  'Location Tasks',
                  stats.totalLocationTasks.toString(),
                  PhosphorIcons.checkSquare(),
                ),
                _buildStatRow(
                  'Completed Tasks',
                  stats.completedLocationTasks.toString(),
                  PhosphorIcons.checkCircle(),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: stats.completionRate,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    stats.completionRate > 0.7 ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completion Rate: ${(stats.completionRate * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<LocationStatistics> _getLocationStatistics() async {
    // This would typically use a location task service
    // For now, return mock data
    return const LocationStatistics(
      totalLocationTriggers: 0,
      activeLocationTriggers: 0,
      totalLocationTasks: 0,
      completedLocationTasks: 0,
    );
  }
}


