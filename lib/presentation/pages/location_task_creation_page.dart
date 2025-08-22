import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../services/location/location_models.dart';
import '../providers/location_providers.dart';
import '../providers/task_provider.dart' show taskOperationsProvider;
import '../widgets/glassmorphism_container.dart';
import '../widgets/theme_background_widget.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/theme/material3/motion_system.dart';

/// Ultra-modern full-screen location-based task creation page
class LocationTaskCreationPage extends ConsumerStatefulWidget {
  final TaskModel? taskToEdit;
  final LocationData? preselectedLocation;

  const LocationTaskCreationPage({
    super.key,
    this.taskToEdit,
    this.preselectedLocation,
  });

  @override
  ConsumerState<LocationTaskCreationPage> createState() => _LocationTaskCreationPageState();
}

class _LocationTaskCreationPageState extends ConsumerState<LocationTaskCreationPage>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationSearchController = TextEditingController();
  
  // Task properties
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  
  // Location properties
  GeofenceType _triggerType = GeofenceType.enter;
  double _geofenceRadius = 100.0;
  LocationData? _selectedLocation;
  List<String> _suggestedLocations = [];
  
  // State
  bool _isCreatingTask = false;
  Timer? _debounceTimer;
  
  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: ExpressiveMotionSystem.durationMedium2,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _initializeData();
    _loadLocationSuggestions();
    _fadeController.forward();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _debounceTimer?.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationSearchController.dispose();
    super.dispose();
  }
  
  void _initializeData() {
    // Pre-populate if editing
    if (widget.taskToEdit != null) {
      final task = widget.taskToEdit!;
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _priority = task.priority;
      _dueDate = task.dueDate;
      if (_dueDate != null) {
        _dueTime = TimeOfDay.fromDateTime(_dueDate!);
      }
    }
    
    // Use preselected location if provided
    if (widget.preselectedLocation != null) {
      _selectedLocation = widget.preselectedLocation;
      _locationSearchController.text = _formatLocationDisplay(_selectedLocation!);
    }
  }
  
  void _loadLocationSuggestions() {
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
    
    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [// Main content - full screen
            SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 60, // Account for status bar + floating button
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      
                      // Task Details Section
                      _buildTaskDetailsSection(context, theme),
                      
                      SizedBox(height: 20),
                      
                      // Location Setup Section
                      _buildLocationSection(context, theme),
                      
                      SizedBox(height: 20),
                      
                      // Location Trigger Configuration Section
                      _buildTriggerConfigSection(context, theme),
                      
                      SizedBox(height: 20),
                      
                      // Quick Locations Section
                      _buildQuickLocationsSection(context, theme),
                      
                      SizedBox(height: 32),
                      
                      // Create Button
                      _buildCreateButton(context, theme),
                      
                      SizedBox(height: 100), // Bottom padding]),
                ),
              ),
            ),
            
            // Floating navigation buttons
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface.withValues(alpha: 0.9),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )]),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      PhosphorIcons.arrowLeft(),
                      color: theme.colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            
            // Floating clear location button (only show if has location)
            if (_selectedLocation != null)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )]),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => setState(() {
                        _selectedLocation = null;
                        _locationSearchController.clear();
                      }),
                      child: Icon(
                        PhosphorIcons.mapPin(),
                        color: theme.colorScheme.onErrorContainer,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              )]),
      ),
    );
  }
  
  Widget _buildTaskDetailsSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Row(
            children: [
              Icon(
                PhosphorIcons.mapPin(),
                size: 24,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Location Task Details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )]),
          SizedBox(height: 16),
          
          // Title field
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Task Title',
              hintText: 'Enter a clear, actionable task title...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Task title is required';
              }
              return null;
            },
            onChanged: (_) => _updateLocationSuggestions(),
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
          ),
          
          SizedBox(height: 16),
          
          // Description field
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Add additional details, notes, or context...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              ),
            ),
            maxLines: 3,
            onChanged: (_) => _updateLocationSuggestions(),
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.sentences,
          )]),
    );
  }
  
  Widget _buildLocationSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Row(
            children: [
              Icon(
                PhosphorIcons.mapPin(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Location Setup',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )]),
          SizedBox(height: 12),
          
          // Location search field
          TextFormField(
            controller: _locationSearchController,
            decoration: InputDecoration(
              labelText: 'Search Location',
              hintText: 'Enter address, place name, or coordinates...',
              prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
              suffixIcon: IconButton(
                onPressed: _useCurrentLocation,
                icon: Icon(PhosphorIcons.crosshair()),
                tooltip: 'Use current location',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
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
          
          // Location permission warning
          Consumer(
            builder: (context, ref, child) {
              final locationPermission = ref.watch(locationPermissionProvider);
              return locationPermission.when(
                data: (status) {
                  if (status != LocationPermissionStatus.granted) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [Icon(PhosphorIcons.warning(), color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Location permission required for location-based reminders',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            TextButton(
                              onPressed: _requestLocationPermission,
                              child: const Text("")]),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
          
          // Selected location display
          if (_selectedLocation != null) ...[
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
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
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Location',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          _formatLocationDisplay(_selectedLocation!),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        )]),
                  )]),
            ),
          ]]),
    );
  }
  
  Widget _buildTriggerConfigSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Row(
            children: [
              Icon(
                PhosphorIcons.bell(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Location Trigger',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )]),
          SizedBox(height: 16),
          
          // Trigger type and priority row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<GeofenceType>(
                  value: _triggerType,
                  decoration: InputDecoration(
                    labelText: 'Trigger Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                    ),
                  ),
                  items: GeofenceType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(_getTriggerTypeIcon(type), size: 16),
                          SizedBox(width: 8),
                          Text(_getTriggerTypeDisplay(type))]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _triggerType = value ?? GeofenceType.enter;
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<TaskPriority>(
                  value: _priority,
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                    ),
                  ),
                  items: TaskPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Row(
                        children: [Icon(_getPriorityIcon(priority), size: 16),
                          SizedBox(width: 8),
                          Text(priority.name.toUpperCase())]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _priority = value ?? TaskPriority.medium;
                    });
                  },
                ),
              )]),
          
          SizedBox(height: 16),
          
          // Due date row
          Row(
            children: [Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now().add(Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _dueDate = date);
                    }
                  },
                  icon: Icon(PhosphorIcons.calendar()),
                  label: Text(_dueDate != null 
                      ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                      : 'Set Date'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _dueDate == null ? null : () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _dueTime ?? TimeOfDay(hour: 23, minute: 59),
                    );
                    if (time != null) {
                      setState(() => _dueTime = time);
                    }
                  },
                  icon: Icon(PhosphorIcons.clock()),
                  label: Text(_dueTime != null 
                      ? _dueTime!.format(context)
                      : 'Set Time'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (_dueDate != null)
                IconButton(
                  onPressed: () => setState(() {
                    _dueDate = null;
                    _dueTime = null;
                  }),
                  icon: Icon(PhosphorIcons.x()),
                  tooltip: 'Clear due date',
                )]),
          
          SizedBox(height: 16),
          
          // Geofence radius
          Text(
            'Detection Radius: ${_geofenceRadius.toInt()}m',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
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
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _getRadiusDescription(_geofenceRadius),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          )]),
    );
  }
  
  Widget _buildQuickLocationsSection(BuildContext context, ThemeData theme) {
    if (_suggestedLocations.isEmpty) return const SizedBox.shrink();
    
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Row(
            children: [
              Icon(
                PhosphorIcons.mapPin(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Quick Locations',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )]),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestedLocations.take(8).map((location) {
                return ActionChip(
                  label: Text(location),
                  onPressed: () => _selectSuggestedLocation(location),
                  avatar: Icon(PhosphorIcons.mapPin(), size: 16),
                  backgroundColor: theme.colorScheme.surfaceContainerLow,
                  side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                );
              }).toList(),
            ),
          )]),
    );
  }
  
  Widget _buildCreateButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isCreatingTask ? null : _createLocationTask,
        icon: _isCreatingTask 
            ? SizedBox(width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(PhosphorIcons.mapPin()),
        label: Text(_isCreatingTask 
            ? 'Creating...' 
            : widget.taskToEdit != null 
                ? 'Update Location Task'
                : 'Create Location Task'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
          ),
        ),
      ),
    );
  }

  // Location search with debouncing
  void _onLocationSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 800), () async {
      if (query.trim().isEmpty) {
        setState(() => _selectedLocation = null);
        return;
      }
      
      try {
        final locationService = ref.read(locationServiceProvider);
        final location = await locationService.getCoordinatesFromAddress(query);
        
        if (location != null && mounted) {
          setState(() => _selectedLocation = location);
        }
      } catch (e) {
        debugPrint('Geocoding error: $e');
      }
    });
  }

  // Update location suggestions based on task content
  void _updateLocationSuggestions() {
    final title = _titleController.text.toLowerCase();
    final description = _descriptionController.text.toLowerCase();
    final content = '$title $description';
    
    final smartSuggestions = <String>[];
    
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
      _suggestedLocations = <String>{...smartSuggestions, ..._suggestedLocations}.toList();
    });
  }

  // Use current location
  void _useCurrentLocation() async {
    final currentLocation = ref.read(currentLocationProvider);
    currentLocation.when(
      data: (location) {
        setState(() {
          _selectedLocation = location;
          _locationSearchController.text = _formatLocationDisplay(location);
        });
      },
      loading: () {},
      error: (error, _) {
        _showError('Failed to get current location: $error');
      },
    );
  }

  // Select suggested location
  void _selectSuggestedLocation(String locationName) async {
    setState(() {
      _locationSearchController.text = locationName;
    });
    
    try {
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCoordinatesFromAddress(locationName);
      
      if (location != null && mounted) {
        setState(() => _selectedLocation = location);
      } else {
        _showError('Could not find coordinates for "$locationName"');
      }
    } catch (e) {
      _showError('Failed to find location: $e');
    }
  }

  // Request location permission
  void _requestLocationPermission() async {
    try {
      final locationService = ref.read(locationServiceProvider);
      final status = await locationService.requestPermission();
      
      if (mounted) {
        String message;
        Color color;
        
        switch (status) {
          case LocationPermissionStatus.granted:
          case LocationPermissionStatus.whileInUse:
          case LocationPermissionStatus.always:
            message = 'Location permission granted!';
            color = Colors.green;
            ref.invalidate(locationPermissionProvider);
            break;
          case LocationPermissionStatus.denied:
            message = 'Location permission denied';
            color = Colors.orange;
            break;
          case LocationPermissionStatus.deniedForever:
            message = 'Location permission permanently denied';
            color = Colors.red;
            break;
          case LocationPermissionStatus.unableToDetermine:
            message = 'Unable to determine location permission status';
            color = Colors.orange;
            break;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to request location permission: $e');
    }
  }

  // Create location task
  void _createLocationTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      _showError('Please select a location for this task');
      return;
    }

    setState(() => _isCreatingTask = true);

    try {
      // Create location trigger
      final trigger = LocationTrigger(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        taskId: '',
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

      // Combine date and time if both are set
      DateTime? finalDueDate;
      if (_dueDate != null) {
        if (_dueTime != null) {
          finalDueDate = DateTime(
            _dueDate!.year,
            _dueDate!.month,
            _dueDate!.day,
            _dueTime!.hour,
            _dueTime!.minute,
          );
        } else {
          finalDueDate = _dueDate;
        }
      }

      // Create task with location trigger
      final task = TaskModel.create(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
        dueDate: finalDueDate,
        priority: _priority,
        locationTrigger: jsonEncode(trigger.toJson()),
        metadata: {
          'has_location_trigger': true,
          'trigger_type': _triggerType.name,
          'geofence_radius': _geofenceRadius,
          'location_display': _formatLocationDisplay(_selectedLocation!),
          'created_from': 'location_task_creation',
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
        setState(() => _isCreatingTask = false);
      }
    }
  }

  // Helper methods
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
        return PhosphorIcons.arrowsLeftRight();
    }
  }

  String _getTriggerTypeDisplay(GeofenceType type) {
    switch (type) {
      case GeofenceType.enter:
        return 'When arriving';
      case GeofenceType.exit:
        return 'When leaving';
      case GeofenceType.both:
        return 'Arriving or leaving';
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