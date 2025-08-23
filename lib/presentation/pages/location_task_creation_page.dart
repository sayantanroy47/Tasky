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

/// Location validation utilities
class LocationValidator {
  // Earth coordinate bounds
  static const double _minLatitude = -90.0;
  static const double _maxLatitude = 90.0;
  static const double _minLongitude = -180.0;
  static const double _maxLongitude = 180.0;
  
  // Geofence radius bounds (in meters)
  static const double _minRadius = 1.0;
  static const double _maxRadius = 10000.0; // 10km
  
  /// Validate latitude coordinate
  static bool isValidLatitude(double latitude) {
    return latitude >= _minLatitude && 
           latitude <= _maxLatitude && 
           !latitude.isNaN && 
           latitude.isFinite;
  }
  
  /// Validate longitude coordinate  
  static bool isValidLongitude(double longitude) {
    return longitude >= _minLongitude && 
           longitude <= _maxLongitude && 
           !longitude.isNaN && 
           longitude.isFinite;
  }
  
  /// Validate location coordinates
  static bool isValidLocation(LocationData location) {
    return isValidLatitude(location.latitude) && 
           isValidLongitude(location.longitude);
  }
  
  /// Validate geofence radius
  static bool isValidRadius(double radius) {
    return radius >= _minRadius && 
           radius <= _maxRadius && 
           !radius.isNaN && 
           radius.isFinite;
  }
  
  /// Sanitize user address input
  static String sanitizeAddressInput(String input) {
    return input.trim()
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .replaceAll(RegExp(r'[^\w\s,.-]'), ''); // Remove special chars except common address chars
  }
  
  /// Check if string looks like coordinates
  static bool looksLikeCoordinates(String input) {
    final coordPattern = RegExp(r'^-?\d+\.?\d*\s*,\s*-?\d+\.?\d*$');
    return coordPattern.hasMatch(input.trim());
  }
  
  /// Get validation error message for coordinates
  static String? getLocationValidationError(LocationData? location) {
    if (location == null) return 'Location is required';
    
    if (!isValidLatitude(location.latitude)) {
      return 'Invalid latitude: must be between -90 and 90 degrees';
    }
    
    if (!isValidLongitude(location.longitude)) {
      return 'Invalid longitude: must be between -180 and 180 degrees';
    }
    
    return null;
  }
  
  /// Get validation error message for radius
  static String? getRadiusValidationError(double radius) {
    if (!isValidRadius(radius)) {
      return 'Invalid radius: must be between 1m and 10km';
    }
    
    return null;
  }
}

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
  DateTime? _dueDate = DateTime.now();
  TimeOfDay? _dueTime;
  
  // Location properties
  GeofenceType _triggerType = GeofenceType.enter;
  double _geofenceRadius = 100.0;
  LocationData? _selectedLocation;
  List<String> _suggestedLocations = [];
  
  // State
  bool _isCreatingTask = false;
  bool _isSearchingLocation = false;
  bool _isLoadingAddress = false;
  String? _selectedLocationAddress;
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
    _preloadPermissions();
    _fadeController.forward();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _debounceTimer?.cancel();
    _debounceTimer = null;
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
      _loadLocationAddress(_selectedLocation!);
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
  
  void _preloadPermissions() async {
    // Preload location permissions to avoid delays later
    try {
      ref.read(locationPermissionProvider);
    } catch (e) {
      // Ignore errors - user will see them when they try to use location
      debugPrint('Failed to preload location permissions: $e');
    }
  }

  Future<void> _loadLocationAddress(LocationData location) async {
    if (mounted) {
      setState(() => _isLoadingAddress = true);
    }
    
    try {
      final locationService = ref.read(locationServiceProvider);
      final address = await locationService.getAddressFromCoordinates(
        location.latitude, 
        location.longitude,
      );
      
      if (mounted) {
        setState(() {
          _selectedLocationAddress = address;
          _locationSearchController.text = address ?? _formatLocationDisplay(location);
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      // Fallback to coordinates if geocoding fails
      if (mounted) {
        setState(() {
          _selectedLocationAddress = null;
          _locationSearchController.text = _formatLocationDisplay(location);
          _isLoadingAddress = false;
        });
        
        // Show subtle feedback about geocoding failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not load address name, using coordinates'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ThemeBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Main content - full screen
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
                      const SizedBox(height: 20),
                      
                      // Task Details Section
                      _buildTaskDetailsSection(context, theme),
                      
                      const SizedBox(height: 20),
                      
                      // Location Setup Section
                      _buildLocationSection(context, theme),
                      
                      const SizedBox(height: 20),
                      
                      // Location Trigger Configuration Section
                      _buildTriggerConfigSection(context, theme),
                      
                      const SizedBox(height: 20),
                      
                      // Quick Locations Section
                      _buildQuickLocationsSection(context, theme),
                      
                      const SizedBox(height: 32),
                      
                      // Create Button
                      _buildCreateButton(context, theme),
                      
                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
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
                    ),
                  ],
                ),
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
            _selectedLocation != null ? Positioned(
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
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => setState(() {
                        _selectedLocation = null;
                        _selectedLocationAddress = null;
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
              ) : const SizedBox.shrink(),
          ],
        ),
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
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.mapPin(),
                size: 24,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Location Task Details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: TypographyConstants.medium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
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
          
          const SizedBox(height: 16),
          
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
          ),
        ],
      ),
    );
  }
  
  Widget _buildLocationSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.mapPin(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Location Setup',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: TypographyConstants.medium,
                ),
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
              prefixIcon: _isSearchingLocation 
                  ? const Padding(
                      padding: EdgeInsets.all(14.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Icon(PhosphorIcons.magnifyingGlass()),
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
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: _requestLocationPermission,
                              child: const Text('Enable Location'),
                            ),
                          ],
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
            const SizedBox(height: 12),
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Location',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: TypographyConstants.medium,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getBestLocationDisplay(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: TypographyConstants.medium,
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
      ),
    );
  }
  
  Widget _buildTriggerConfigSection(BuildContext context, ThemeData theme) {
    return GlassmorphismContainer(
      level: GlassLevel.content,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.bell(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Location Trigger',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: TypographyConstants.medium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Trigger type and priority row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<GeofenceType>(
                  initialValue: _triggerType,
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
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<TaskPriority>(
                  initialValue: _priority,
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
                        children: [
                          Icon(_getPriorityIcon(priority), size: 16),
                          const SizedBox(width: 8),
                          Text(priority.name.toUpperCase()),
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
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Due date row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
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
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _dueDate == null ? null : () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _dueTime ?? const TimeOfDay(hour: 23, minute: 59),
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
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Geofence radius
          Text(
            'Detection Radius: ${_geofenceRadius.toInt()}m',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: TypographyConstants.medium,
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _geofenceRadius,
              min: 1, // LocationValidator._minRadius
              max: 10000, // LocationValidator._maxRadius
              divisions: 50,
              label: '${_geofenceRadius.toInt()}m',
              onChanged: (value) {
                // Validate the new radius value
                if (LocationValidator.isValidRadius(value)) {
                  setState(() {
                    _geofenceRadius = value;
                  });
                }
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
          ),
        ],
      ),
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
        children: [
          Row(
            children: [
              Icon(
                PhosphorIcons.mapPin(),
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Locations',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: TypographyConstants.medium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
          ),
        ],
      ),
    );
  }
  
  Widget _buildCreateButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: (_isCreatingTask || _isLoadingAddress) ? null : _createLocationTask,
        icon: (_isCreatingTask || _isLoadingAddress)
            ? const SizedBox(width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(PhosphorIcons.mapPin()),
        label: Text(_isCreatingTask 
            ? 'Creating...'
            : _isLoadingAddress
                ? 'Loading address...'
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
    
    if (query.trim().isEmpty) {
      setState(() {
        _selectedLocation = null;
        _selectedLocationAddress = null;
        _isSearchingLocation = false;
      });
      return;
    }
    
    // Show loading state immediately for better UX
    setState(() => _isSearchingLocation = true);
    
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      // Sanitize user input before processing
      final sanitizedQuery = LocationValidator.sanitizeAddressInput(query);
      if (sanitizedQuery.isEmpty) {
        if (mounted) setState(() => _isSearchingLocation = false);
        return;
      }
      
      try {
        final locationService = ref.read(locationServiceProvider);
        final location = await locationService.getCoordinatesFromAddress(sanitizedQuery);
        
        // Validate coordinates are within Earth bounds
        final validationError = LocationValidator.getLocationValidationError(location);
        if (validationError != null) {
          if (mounted) {
            setState(() => _isSearchingLocation = false);
            _showError('Invalid location: $validationError');
          }
          return;
        }
        
        if (mounted) {
          setState(() {
            _selectedLocation = location;
            _isSearchingLocation = false;
            _selectedLocationAddress = sanitizedQuery;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSearchingLocation = false;
            _selectedLocation = null;
            _selectedLocationAddress = null;
          });
          
          // Enhanced geocoding error feedback
          final errorString = e.toString().toLowerCase();
          if (errorString.contains('geocoding') || errorString.contains('not found')) {
            _showEnhancedGeocodingError(sanitizedQuery);
          } else {
            _showLocationError('find address', e);
          }
        }
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
    try {
      // Check permissions first (now cached)
      final permissionAsync = ref.read(locationPermissionProvider);
      final permissionStatus = await permissionAsync.when(
        data: (status) => Future.value(status),
        loading: () => ref.read(locationServiceProvider).checkPermission(),
        error: (_, __) => ref.read(locationServiceProvider).checkPermission(),
      );
      
      if (permissionStatus != LocationPermissionStatus.granted) {
        _requestLocationPermission();
        return;
      }

      // Show loading state with reduced duration since it should be faster now
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Getting your location...'),
            ],
          ),
          duration: Duration(milliseconds: 1500),
        ),
      );

      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCurrentLocation();
      
      // Validate coordinates are within Earth bounds  
      final validationError = LocationValidator.getLocationValidationError(location);
      if (validationError != null) {
        _showError('Invalid current location coordinates: $validationError');
        return;
      }
      
      if (mounted) {
        setState(() {
          _selectedLocation = location;
        });
        
        // Load the address for better display (await to prevent race condition)
        await _loadLocationAddress(location);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Current location selected'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (error) {
      _showLocationError('get current location', error);
    }
  }

  // Select suggested location
  void _selectSuggestedLocation(String locationName) async {
    setState(() {
      _locationSearchController.text = locationName;
    });
    
    try {
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCoordinatesFromAddress(locationName);
      
      if (location != null) {
        // Validate coordinates are within Earth bounds
        final validationError = LocationValidator.getLocationValidationError(location);
        if (validationError != null) {
          _showError('Invalid location coordinates for "$locationName": $validationError');
          return;
        }
        
        if (mounted) {
          setState(() {
            _selectedLocation = location;
            _selectedLocationAddress = LocationValidator.sanitizeAddressInput(locationName);
          });
        }
      } else {
        _showError('Could not find coordinates for "$locationName"');
      }
    } catch (e) {
      // Enhanced error handling for suggested locations
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('geocoding') || errorString.contains('not found')) {
        _showError('Could not find location for "$locationName". Try using "Use Current Location" or enter a specific address.');
      } else {
        _showLocationError('find suggested location', e);
      }
    }
  }

  // Request location permission with user-friendly explanation
  void _requestLocationPermission() async {
    // Show explanation dialog first
    final shouldProceed = await _showLocationPermissionDialog();
    if (!shouldProceed) return;
    
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
          case LocationPermissionStatus.serviceDisabled:
            message = 'Location service is disabled';
            color = Colors.red;
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
      _showLocationError('request location permission', e);
    }
  }

  // Show location permission explanation dialog
  Future<bool> _showLocationPermissionDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(PhosphorIcons.mapPin(), color: Colors.blue, size: 24),
            const SizedBox(width: 8),
            const Text('Location Permission'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To create location-based tasks with geofencing alerts, this app needs access to your device\'s location.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What this enables:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(PhosphorIcons.bellRinging(), size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Get notified when you arrive/leave places')),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(PhosphorIcons.target(), size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Set custom geofence radius for tasks')),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(PhosphorIcons.shieldCheck(), size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Location data stays on your device')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: Icon(PhosphorIcons.check(), size: 18),
            label: const Text('Enable Location'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Create location task
  void _createLocationTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      _showError('Please select a location for this task');
      return;
    }
    
    // Validate geofence radius
    final radiusError = LocationValidator.getRadiusValidationError(_geofenceRadius);
    if (radiusError != null) {
      _showError(radiusError);
      return;
    }

    setState(() => _isCreatingTask = true);

    try {
      // Create location trigger template (taskId will be set after task creation)
      final triggerTemplate = LocationTrigger(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        taskId: '', // Will be updated after task creation
        geofence: GeofenceData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _getBestGeofenceName(),
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

      // Create task with location trigger (sanitize all text inputs)
      final sanitizedTitle = _titleController.text.trim().replaceAll(RegExp(r'\s+'), ' ');
      final sanitizedDescription = _descriptionController.text.trim().replaceAll(RegExp(r'\s+'), ' ');
      
      final task = TaskModel.create(
        title: sanitizedTitle,
        description: sanitizedDescription.isEmpty ? null : sanitizedDescription,
        dueDate: finalDueDate,
        priority: _priority,
        locationTrigger: jsonEncode(triggerTemplate.toJson()),
        metadata: {
          'has_location_trigger': true,
          'trigger_type': _triggerType.name,
          'geofence_radius': _geofenceRadius,
          'location_display': _getBestLocationDisplay(),
          'created_from': 'location_task_creation',
        },
      );

      TaskModel createdTask;
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
        final result = await ref.read(taskOperationsProvider).updateTask(updatedTask);
        if (!result.isSuccess || result.task == null) {
          throw Exception(result.error ?? 'Failed to update task');
        }
        createdTask = result.task!;
      } else {
        // Create new task
        final result = await ref.read(taskOperationsProvider).createTask(task);
        if (!result.isSuccess || result.task == null) {
          throw Exception(result.error ?? 'Failed to create task');
        }
        createdTask = result.task!;
      }

      // Ensure we have a valid task ID before creating the location trigger
      if (createdTask.id.isEmpty) {
        throw Exception('Failed to create task: Invalid task ID');
      }

      // Create the final location trigger with the correct task ID
      final finalTrigger = triggerTemplate.copyWith(taskId: createdTask.id);
      
      // Add location trigger to geofencing system
      try {
        await ref.read(locationTriggersProvider.notifier).addLocationTrigger(finalTrigger);
      } catch (e) {
        // If trigger creation fails, we should clean up the task (only for new tasks)
        if (widget.taskToEdit == null) {
          try {
            await ref.read(taskOperationsProvider).deleteTask(createdTask);
          } catch (deleteError) {
            debugPrint('Failed to cleanup task after trigger failure: $deleteError');
          }
        }
        throw Exception('Failed to create location trigger: $e');
      }

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
  
  /// Get the best available location display for metadata/storage
  String _getBestLocationDisplay() {
    if (_selectedLocationAddress != null && _selectedLocationAddress!.isNotEmpty) {
      return _selectedLocationAddress!;
    }
    if (_selectedLocation != null) {
      return _formatLocationDisplay(_selectedLocation!);
    }
    return 'Unknown Location';
  }
  
  /// Get the best available name for geofence (prioritizes human-readable names)
  String _getBestGeofenceName() {
    // Priority 1: Use human-readable address if available
    if (_selectedLocationAddress != null && _selectedLocationAddress!.isNotEmpty) {
      return _selectedLocationAddress!;
    }
    
    // Priority 2: Use search query if it's not coordinates and not empty
    final searchText = _locationSearchController.text.trim();
    if (searchText.isNotEmpty && !LocationValidator.looksLikeCoordinates(searchText)) {
      return searchText;
    }
    
    // Priority 3: Use task title as context
    final taskTitle = _titleController.text.trim();
    if (taskTitle.isNotEmpty) {
      return '$taskTitle Location';
    }
    
    // Fallback: Generic name
    return 'Task Location';
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
  
  void _showLocationError(String operation, dynamic error) {
    final String errorString = error.toString().toLowerCase();
    final String userMessage;
    
    if (errorString.contains('timeout') || errorString.contains('timed out')) {
      userMessage = 'Location request timed out. Please check your GPS signal and try again.';
    } else if (errorString.contains('permission') || errorString.contains('denied')) {
      userMessage = 'Location permission denied. Please enable location access in settings.';
    } else if (errorString.contains('disabled') || errorString.contains('service')) {
      userMessage = 'Location services are disabled. Please enable GPS in your device settings.';
    } else if (errorString.contains('network') || errorString.contains('internet')) {
      userMessage = 'No internet connection. Address lookup requires internet access.';
    } else if (errorString.contains('geocoding') || errorString.contains('address not found')) {
      userMessage = 'Address not found. Please try a different address or use coordinates.';
    } else {
      userMessage = 'Failed to $operation. Please check your location settings and try again.';
    }
    
    _showError(userMessage);
  }
  
  void _showEnhancedGeocodingError(String searchQuery) {
    final suggestions = <String>[];
    
    // Add specific suggestions based on the search query
    if (searchQuery.length < 3) {
      suggestions.add('• Try entering a more complete address');
    }
    if (!searchQuery.contains(',') && !searchQuery.contains('street') && !searchQuery.contains('road')) {
      suggestions.add('• Include street name or city (e.g., "123 Main St, Springfield")');
    }
    if (!RegExp(r'\d').hasMatch(searchQuery)) {
      suggestions.add('• Try including a street number or postal code');
    }
    
    final suggestionsText = suggestions.isEmpty 
        ? '' 
        : '\n\nSuggestions:\n${suggestions.join('\n')}';
    
    final message = 'Address "$searchQuery" could not be found.$suggestionsText\n\nYou can also:\n• Use your current location\n• Try a different address\n• Use coordinates (lat, lng)';
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(PhosphorIcons.mapPin(), color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              const Text('Address Not Found'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}


