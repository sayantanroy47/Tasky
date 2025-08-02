import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/location/location_models.dart';
import '../providers/location_providers.dart';

class LocationPermissionWidget extends ConsumerWidget {
  final Widget child;
  final Widget? permissionDeniedWidget;

  const LocationPermissionWidget({
    super.key,
    required this.child,
    this.permissionDeniedWidget,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionAsync = ref.watch(locationPermissionProvider);

    return permissionAsync.when(
      data: (permission) {
        switch (permission) {
          case LocationPermissionStatus.granted:
          case LocationPermissionStatus.whileInUse:
          case LocationPermissionStatus.always:
            return child;
          case LocationPermissionStatus.denied:
          case LocationPermissionStatus.deniedForever:
          case LocationPermissionStatus.unableToDetermine:
            return permissionDeniedWidget ?? _buildPermissionDeniedWidget(context, ref);
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error checking location permission: $error'),
      ),
    );
  }

  Widget _buildPermissionDeniedWidget(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Location Permission Required',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This feature requires location access to work properly.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final locationService = ref.read(locationServiceProvider);
              await locationService.requestPermission();
              ref.invalidate(locationPermissionProvider);
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }
}

class CurrentLocationWidget extends ConsumerWidget {
  final Widget Function(LocationData location) builder;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const CurrentLocationWidget({
    super.key,
    required this.builder,
    this.loadingWidget,
    this.errorWidget,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(currentLocationProvider);

    return locationAsync.when(
      data: builder,
      loading: () => loadingWidget ?? const Center(child: CircularProgressIndicator()),
      error: (error, stack) => errorWidget ?? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(height: 8),
            Text('Error: $error'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.invalidate(currentLocationProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class LocationStreamWidget extends ConsumerWidget {
  final Widget Function(LocationData location) builder;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const LocationStreamWidget({
    super.key,
    required this.builder,
    this.loadingWidget,
    this.errorWidget,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationStream = ref.watch(locationStreamProvider);

    return locationStream.when(
      data: builder,
      loading: () => loadingWidget ?? const Center(child: CircularProgressIndicator()),
      error: (error, stack) => errorWidget ?? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(height: 8),
            Text('Error: $error'),
          ],
        ),
      ),
    );
  }
}

class GeofenceConfigWidget extends ConsumerStatefulWidget {
  final Function(GeofenceData geofence) onGeofenceCreated;
  final GeofenceData? initialGeofence;

  const GeofenceConfigWidget({
    super.key,
    required this.onGeofenceCreated,
    this.initialGeofence,
  });
  @override
  ConsumerState<GeofenceConfigWidget> createState() => _GeofenceConfigWidgetState();
}

class _GeofenceConfigWidgetState extends ConsumerState<GeofenceConfigWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _radiusController = TextEditingController();
  final _addressController = TextEditingController();
  
  GeofenceType _selectedType = GeofenceType.enter;
  LocationData? _selectedLocation;
  bool _isLoadingLocation = false;
  @override
  void initState() {
    super.initState();
    if (widget.initialGeofence != null) {
      _nameController.text = widget.initialGeofence!.name;
      _radiusController.text = widget.initialGeofence!.radius.toString();
      _selectedType = widget.initialGeofence!.type;
      _selectedLocation = LocationData(
        latitude: widget.initialGeofence!.latitude,
        longitude: widget.initialGeofence!.longitude,
        timestamp: DateTime.now(),
      );
    }
  }
  @override
  void dispose() {
    _nameController.dispose();
    _radiusController.dispose();
    _addressController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Geofence Configuration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Geofence Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address or Location',
                  border: const OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _searchAddress,
                      ),
                      IconButton(
                        icon: const Icon(Icons.my_location),
                        onPressed: _useCurrentLocation,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _radiusController,
                decoration: const InputDecoration(
                  labelText: 'Radius (meters)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a radius';
                  }
                  final radius = double.tryParse(value);
                  if (radius == null || radius <= 0) {
                    return 'Please enter a valid radius';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<GeofenceType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Trigger Type',
                  border: OutlineInputBorder(),
                ),
                items: GeofenceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getGeofenceTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_selectedLocation != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Location: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoadingLocation ? null : _createGeofence,
                    child: _isLoadingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Geofence'),
                  ),
                ],
              ),
            ],
          ),
        ),
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

  Future<void> _searchAddress() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCoordinatesFromAddress(address);
      
      if (location != null) {
        setState(() {
          _selectedLocation = location;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address not found')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching address: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCurrentLocation();
      
      setState(() {
        _selectedLocation = location;
      });

      // Try to get address for the location
      try {
        final address = await locationService.getAddressFromCoordinates(
          location.latitude,
          location.longitude,
        );
        if (address != null) {
          _addressController.text = address;
        }
      } catch (e) {
        // Address lookup failed, but location is still valid
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting current location: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _createGeofence() {
    if (!_formKey.currentState!.validate() || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a location')),
      );
      return;
    }

    final geofence = GeofenceData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      latitude: _selectedLocation!.latitude,
      longitude: _selectedLocation!.longitude,
      radius: double.parse(_radiusController.text),
      isActive: true,
      type: _selectedType,
      createdAt: DateTime.now(),
    );

    widget.onGeofenceCreated(geofence);
    Navigator.of(context).pop();
  }
}
