import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../services/location/location_models.dart';
import '../providers/location_providers.dart';
import '../providers/task_provider.dart' show taskOperationsProvider;
import 'glassmorphism_container.dart';
import '../../core/theme/typography_constants.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Enhanced dialog for creating location-based tasks with smart suggestions
class EnhancedLocationTaskDialog extends ConsumerStatefulWidget {
  final TaskModel? taskToEdit;
  final LocationData? preselectedLocation;

  const EnhancedLocationTaskDialog({
    super.key,
    this.taskToEdit,
    this.preselectedLocation,
  });

  @override
  ConsumerState<EnhancedLocationTaskDialog> createState() => _EnhancedLocationTaskDialogState();
}

class _EnhancedLocationTaskDialogState extends ConsumerState<EnhancedLocationTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationSearchController = TextEditingController();
  
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  GeofenceType _triggerType = GeofenceType.enter;
  double _geofenceRadius = 100.0;
  LocationData? _selectedLocation;
  bool _isCreatingTask = false;
  List<String> _suggestedLocations = [];

  @override
  void initState() {
    super.initState();
    
    // Pre-populate if editing
    if (widget.taskToEdit != null) {
      final task = widget.taskToEdit!;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _priority = task.priority;
      _dueDate = task.dueDate;
    }
    
    // Use preselected location if provided
    if (widget.preselectedLocation != null) {
      _selectedLocation = widget.preselectedLocation;
      _locationSearchController.text = _formatLocationDisplay(_selectedLocation!);
    }
    
    _loadLocationSuggestions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationSearchController.dispose();
    super.dispose();
  }

  /// Load smart location suggestions based on user history and task content
  void _loadLocationSuggestions() {
    // Common location suggestions
    _suggestedLocations = [
      'Home',
      'Work',
      'Gym',
      'Grocery Store',
      'School',
      'Doctor\'s Office',
      'Airport',
      'Mall',
      'Restaurant',
      'Coffee Shop',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locationPermission = ref.watch(locationPermissionProvider);
    final currentLocation = ref.watch(currentLocationProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: GlassmorphismContainer(
          borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(PhosphorIcons.mapPin(), color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.taskToEdit != null 
                            ? 'Edit Location Task' 
                            : 'Create Location-Based Task',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(PhosphorIcons.x()),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Task Details Section
                          _buildTaskDetailsSection(theme),
                          
                          const SizedBox(height: 24),
                          
                          // Location Section
                          _buildLocationSection(theme, locationPermission, currentLocation),
                          
                          const SizedBox(height: 24),
                          
                          // Trigger Configuration Section
                          _buildTriggerConfigSection(theme),
                          
                          const SizedBox(height: 24),
                          
                          // Location Suggestions
                          _buildLocationSuggestions(theme),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  _buildActionButtons(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build task details section
  Widget _buildTaskDetailsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        
        // Title field
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Task Title',
            hintText: 'Enter a descriptive title...',
            prefixIcon: Icon(PhosphorIcons.checkSquare()),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Task title is required';
            }
            return null;
          },
          onChanged: (_) => _updateLocationSuggestions(),
        ),
        
        SizedBox(height: 12),
        
        // Description field
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description (Optional)',
            hintText: 'Add more details...',
            prefixIcon: Icon(PhosphorIcons.fileText()),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
            ),
          ),
          maxLines: 3,
          onChanged: (_) => _updateLocationSuggestions(),
        ),
        
        const SizedBox(height: 12),
        
        // Priority and due date row
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<TaskPriority>(
                value: _priority,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  prefixIcon: Icon(PhosphorIcons.flag()),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                  ),
                ),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Row(
                      children: [
                        Icon(_getPriorityIcon(priority), size: 16),
                        const SizedBox(width: 8),
                        Text(priority.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _priority = value ?? TaskPriority.medium;
                  });
                },
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => _selectDueDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Due Date (Optional)',
                    prefixIcon: Icon(PhosphorIcons.calendar()),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                    ),
                  ),
                  child: Text(
                    _dueDate != null 
                      ? _formatDate(_dueDate!)
                      : 'No due date',
                    style: TextStyle(
                      color: _dueDate != null 
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build location section
  Widget _buildLocationSection(
    ThemeData theme,
    AsyncValue<LocationPermissionStatus> locationPermission,
    AsyncValue<LocationData> currentLocation,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Location Setup',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacer(),
            if (_selectedLocation != null)
              TextButton.icon(
                onPressed: () => setState(() => _selectedLocation = null),
                icon: Icon(PhosphorIcons.x(), size: 16),
                label: const Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Location search field
        TextFormField(
          controller: _locationSearchController,
          decoration: InputDecoration(
            labelText: 'Search Location',
            hintText: 'Enter address, place name, or coordinates...',
            prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoadingLocation())
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                IconButton(
                  onPressed: _useCurrentLocation,
                  icon: Icon(PhosphorIcons.crosshair()),
                  tooltip: 'Use current location',
                ),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
            ),
          ),
          validator: (value) {
            if (_selectedLocation == null && (value == null || value.trim().isEmpty)) {
              return 'Please select a location for this task';
            }
            return null;
          },
          onChanged: _onLocationSearchChanged,
        ),
        
        // Location permission status
        locationPermission.when(
          data: (status) {
            if (status != LocationPermissionStatus.granted) {
              return Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(PhosphorIcons.warning(), color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Location permission required for location-based reminders',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _requestLocationPermission,
                      child: const Text('Grant'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        
        // Selected location display
        if (_selectedLocation != null) ...[
          SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.mapPin(),
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Location',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatLocationDisplay(_selectedLocation!),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Build trigger configuration section
  Widget _buildTriggerConfigSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location Trigger',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        
        // Trigger type selection
        DropdownButtonFormField<GeofenceType>(
          value: _triggerType,
          decoration: InputDecoration(
            labelText: 'Trigger Type',
            prefixIcon: Icon(PhosphorIcons.bell()),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
            ),
          ),
          items: GeofenceType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Row(
                children: [
                  Icon(_getTriggerTypeIcon(type), size: 16),
                  const SizedBox(width: 8),
                  Text(_getTriggerTypeDisplay(type)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _triggerType = value ?? GeofenceType.enter;
            });
          },
        ),
        
        const SizedBox(height: 12),
        
        // Geofence radius slider
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detection Radius: ${_geofenceRadius.toInt()}m',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Slider(
              value: _geofenceRadius,
              min: 50,
              max: 1000,
              divisions: 19,
              label: '${_geofenceRadius.toInt()}m',
              onChanged: (value) {
                setState(() {
                  _geofenceRadius = value;
                });
              },
            ),
            Text(
              _getRadiusDescription(_geofenceRadius),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build location suggestions
  Widget _buildLocationSuggestions(ThemeData theme) {
    if (_suggestedLocations.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Locations',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestedLocations.take(6).map((location) {
            return ActionChip(
              label: Text(location),
              onPressed: () => _selectSuggestedLocation(location),
              avatar: Icon(PhosphorIcons.mapPin(), size: 16),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build action buttons
  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: _isCreatingTask ? null : _createLocationTask,
            child: _isCreatingTask
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.taskToEdit != null ? 'Update Task' : 'Create Task'),
          ),
        ),
      ],
    );
  }

  /// Handle location search changes
  void _onLocationSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _selectedLocation = null;
      });
      return;
    }
    
    // Debounce the search to avoid too many API calls
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_locationSearchController.text != query) return; // User typed more
    
    try {
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCoordinatesFromAddress(query);
      
      if (location != null && mounted) {
        setState(() {
          _selectedLocation = location;
        });
      }
    } catch (e) {
      // Silently handle geocoding errors to avoid spamming the user
      debugPrint('Geocoding error: $e');
    }
  }

  /// Update location suggestions based on task content
  void _updateLocationSuggestions() {
    final title = _titleController.text.toLowerCase();
    final description = _descriptionController.text.toLowerCase();
    final content = '$title $description';
    
    final smartSuggestions = <String>[];
    
    // Add context-based suggestions
    if (content.contains('grocery') || content.contains('shop') || content.contains('buy')) {
      smartSuggestions.addAll(['Grocery Store', 'Mall', 'Pharmacy']);
    }
    if (content.contains('doctor') || content.contains('medical') || content.contains('appointment')) {
      smartSuggestions.addAll(['Hospital', 'Doctor\'s Office', 'Pharmacy']);
    }
    if (content.contains('gym') || content.contains('workout') || content.contains('exercise')) {
      smartSuggestions.addAll(['Gym', 'Park', 'Sports Center']);
    }
    if (content.contains('meeting') || content.contains('work') || content.contains('office')) {
      smartSuggestions.addAll(['Work', 'Office', 'Conference Room']);
    }
    
    setState(() {
      _suggestedLocations = <String>{...smartSuggestions, ..._suggestedLocations}
          .toList();
    });
  }

  /// Use current location
  void _useCurrentLocation() async {
    final currentLocation = ref.read(currentLocationProvider);
    currentLocation.when(
      data: (location) {
        setState(() {
          _selectedLocation = location;
          _locationSearchController.text = _formatLocationDisplay(location);
        });
      },
      loading: () {
        // Show loading indicator
      },
      error: (error, _) {
        _showError('Failed to get current location: $error');
      },
    );
  }

  /// Select suggested location
  void _selectSuggestedLocation(String locationName) async {
    setState(() {
      _locationSearchController.text = locationName;
    });
    
    try {
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCoordinatesFromAddress(locationName);
      
      if (location != null && mounted) {
        setState(() {
          _selectedLocation = location;
        });
      } else {
        // Fallback to a default location if geocoding fails
        _showError('Could not find coordinates for "$locationName". Please enter a more specific address.');
      }
    } catch (e) {
      _showError('Failed to find location: $e');
    }
  }

  /// Request location permission
  void _requestLocationPermission() async {
    try {
      final locationService = ref.read(locationServiceProvider);
      final status = await locationService.requestPermission();
      
      if (mounted) {
        switch (status) {
          case LocationPermissionStatus.granted:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission granted!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Refresh the permission provider
            ref.invalidate(locationPermissionProvider);
            break;
          case LocationPermissionStatus.denied:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied. Some features may not work.'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
            break;
          case LocationPermissionStatus.deniedForever:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission permanently denied. Please enable in app settings.'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
            break;
          case LocationPermissionStatus.whileInUse:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission granted while app is in use.'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Refresh the permission provider
            ref.invalidate(locationPermissionProvider);
            break;
          case LocationPermissionStatus.always:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission granted for all times.'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Refresh the permission provider
            ref.invalidate(locationPermissionProvider);
            break;
          case LocationPermissionStatus.unableToDetermine:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unable to determine location permission status.'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
            break;
        }
      }
    } catch (e) {
      _showError('Failed to request location permission: $e');
    }
  }

  /// Create location task
  void _createLocationTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      _showError('Please select a location for this task');
      return;
    }

    setState(() {
      _isCreatingTask = true;
    });

    try {
      // Create location trigger
      final trigger = LocationTrigger(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        taskId: '', // Will be set after task creation
        geofence: GeofenceData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _locationSearchController.text.isNotEmpty 
            ? _locationSearchController.text 
            : 'Task Location',
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          radius: _geofenceRadius,
          isActive: true,
          type: _triggerType,
          createdAt: DateTime.now(),
        ),
        isEnabled: true,
        createdAt: DateTime.now(),
      );

      // Create task with location trigger
      final task = TaskModel.create(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
        dueDate: _dueDate,
        priority: _priority,
        locationTrigger: jsonEncode(trigger.toJson()), // Store trigger data as JSON string
        metadata: {
          'has_location_trigger': true,
          'trigger_type': _triggerType.name,
          'geofence_radius': _geofenceRadius,
          'location_display': _formatLocationDisplay(_selectedLocation!),
        },
      );

      if (widget.taskToEdit != null) {
        // Update existing task
        final updatedTask = widget.taskToEdit!.copyWith(
          title: task.title,
          description: task.description,
          dueDate: task.dueDate,
          priority: task.priority,
          locationTrigger: task.locationTrigger,
          metadata: {...widget.taskToEdit!.metadata, ...task.metadata},
        );
        await ref.read(taskOperationsProvider).updateTask(updatedTask);
      } else {
        // Create new task
        await ref.read(taskOperationsProvider).createTask(task);
      }

      // Add location trigger
      await ref.read(locationTriggersProvider.notifier).addLocationTrigger(
        trigger.copyWith(taskId: task.id),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.taskToEdit != null 
                ? 'Location task updated successfully'
                : 'Location task created successfully',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to create location task: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingTask = false;
        });
      }
    }
  }

  /// Select due date
  void _selectDueDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null && mounted) {
      if (!context.mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
      );
      
      if (time != null) {
        setState(() {
          _dueDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  /// Helper methods
  bool _isLoadingLocation() {
    final currentLocation = ref.watch(currentLocationProvider);
    return currentLocation.isLoading;
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return PhosphorIcons.warning();
      case TaskPriority.high:
        return PhosphorIcons.caretUp();
      case TaskPriority.medium:
        return PhosphorIcons.dotsSixVertical();
      case TaskPriority.low:
        return PhosphorIcons.caretDown();
    }
  }

  IconData _getTriggerTypeIcon(GeofenceType type) {
    switch (type) {
      case GeofenceType.enter:
        return PhosphorIcons.signIn();
      case GeofenceType.exit:
        return PhosphorIcons.signOut();
      case GeofenceType.both:
        return PhosphorIcons.arrowsClockwise();
    }
  }

  String _getTriggerTypeDisplay(GeofenceType type) {
    switch (type) {
      case GeofenceType.enter:
        return 'When arriving at location';
      case GeofenceType.exit:
        return 'When leaving location';
      case GeofenceType.both:
        return 'When arriving or leaving';
    }
  }

  String _getRadiusDescription(double radius) {
    if (radius <= 100) {
      return 'Very precise - inside buildings';
    } else if (radius <= 200) {
      return 'Precise - small area';
    } else if (radius <= 500) {
      return 'Moderate - neighborhood area';
    } else {
      return 'Wide - large area coverage';
    }
  }

  String _formatLocationDisplay(LocationData location) {
    return '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// Extension methods for location trigger
extension LocationTriggerExtension on LocationTrigger {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'geofence': {
        'id': geofence.id,
        'latitude': geofence.latitude,
        'longitude': geofence.longitude,
        'radius': geofence.radius,
        'type': geofence.type.name,
      },
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  LocationTrigger copyWith({
    String? id,
    String? taskId,
    GeofenceData? geofence,
    bool? isEnabled,
    DateTime? createdAt,
  }) {
    return LocationTrigger(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      geofence: geofence ?? this.geofence,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

