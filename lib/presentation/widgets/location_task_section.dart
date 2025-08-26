import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/theme/typography_constants.dart';
import '../../services/location/location_models.dart';
import '../providers/location_providers.dart';
import 'glassmorphism_container.dart';
import '../../core/design_system/design_tokens.dart';
import 'standardized_text.dart';

/// Reusable location section widget for task creation forms
class LocationTaskSection extends ConsumerStatefulWidget {
  final LocationData? initialLocation;
  final Function(LocationData? location)? onLocationChanged;
  final bool isRequired;
  final double defaultRadius;
  
  const LocationTaskSection({
    super.key,
    this.initialLocation,
    this.onLocationChanged,
    this.isRequired = false,
    this.defaultRadius = 300.0, // 300 meters as requested
  });

  @override
  ConsumerState<LocationTaskSection> createState() => _LocationTaskSectionState();
}

class _LocationTaskSectionState extends ConsumerState<LocationTaskSection> {
  final _addressController = TextEditingController();
  LocationData? _selectedLocation;
  bool _isLoadingLocation = false;
  bool _isLocationEnabled = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    if (_selectedLocation != null) {
      _isLocationEnabled = true;
      // Try to get address for initial location
      _getAddressForLocation(_selectedLocation!);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getAddressForLocation(LocationData location) async {
    try {
      final locationService = ref.read(locationServiceProvider);
      final address = await locationService.getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (address != null && mounted) {
        _addressController.text = address;
      }
    } catch (e) {
      // Address lookup failed, continue without address
      debugPrint('Failed to get address for location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StandardizedTextVariants.sectionHeader('Location Reminder'),
                    if (!widget.isRequired)
                      StandardizedText(
                        '(Optional)',
                        style: StandardizedTextStyle.taskMeta,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                  ],
                ),
              ),
              Switch(
                value: _isLocationEnabled,
                onChanged: (value) {
                  setState(() {
                    _isLocationEnabled = value;
                    debugPrint('🗺️ Location section ${value ? 'enabled' : 'disabled'}');
                    if (!value) {
                      _selectedLocation = null;
                      _addressController.clear();
                      widget.onLocationChanged?.call(null);
                    }
                  });
                },
              ),
            ],
          ),
          if (_isLocationEnabled) ...[
            const SizedBox(height: 16),
            StandardizedText(
              'Get notified when you arrive at this location (${widget.defaultRadius.toInt()}m radius)',
              style: StandardizedTextStyle.bodySmall,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            
            // Address input field
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address or Location',
                hintText: 'Enter address or search for a place',
                border: const OutlineInputBorder(),
                suffixIcon: _isLoadingLocation
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : PopupMenuButton<String>(
                        icon: Icon(PhosphorIcons.mapPin()),
                        tooltip: 'Location options',
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'search',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(PhosphorIcons.magnifyingGlass(), size: 16),
                                const SizedBox(width: 8),
                                const Text('Search address'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'current',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(PhosphorIcons.crosshair(), size: 16),
                                const SizedBox(width: 8),
                                const Text('Current location'),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'search') {
                            _searchAddress();
                          } else if (value == 'current') {
                            _useCurrentLocation();
                          }
                        },
                      ),
              ),
              validator: widget.isRequired
                  ? (value) {
                      if (_selectedLocation == null) {
                        return 'Please select a location';
                      }
                      return null;
                    }
                  : null,
            ),
            
            const SizedBox(height: 12),
            
            // Location confirmation
            if (_selectedLocation != null) ...[
              Container(
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
                          StandardizedText(
                            'Location confirmed',
                            style: StandardizedTextStyle.labelMedium,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 2),
                          StandardizedText(
                            '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                            style: StandardizedTextStyle.bodySmall,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        PhosphorIcons.x(),
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedLocation = null;
                          _addressController.clear();
                          widget.onLocationChanged?.call(null);
                        });
                      },
                      tooltip: 'Remove location',
                    ),
                  ],
                ),
              ),
            ],
            
            // Permission check
            Consumer(
              builder: (context, ref, child) {
                final permissionAsync = ref.watch(locationPermissionProvider);
                return permissionAsync.when(
                  data: (permission) {
                    if (permission == LocationPermissionStatus.denied ||
                        permission == LocationPermissionStatus.deniedForever) {
                      return Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              PhosphorIcons.warningCircle(),
                              color: theme.colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  StandardizedText(
                                    'Location permission required',
                                    style: StandardizedTextStyle.labelMedium,
                                    color: theme.colorScheme.error,
                                  ),
                                  const SizedBox(height: 2),
                                  StandardizedText(
                                    'Grant location access to receive location-based notifications',
                                    style: StandardizedTextStyle.bodySmall,
                                    color: theme.colorScheme.onErrorContainer,
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final locationService = ref.read(locationServiceProvider);
                                await locationService.requestPermission();
                                ref.invalidate(locationPermissionProvider);
                              },
                              child: StandardizedText(
                                'Grant',
                                style: StandardizedTextStyle.labelMedium,
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (error, stack) => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _searchAddress() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      _showSnackBar('Please enter an address to search');
      return;
    }

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
        widget.onLocationChanged?.call(location);
        _showSnackBar('Location found and confirmed');
      } else {
        _showSnackBar('Address not found. Please try a different search.');
      }
    } catch (e) {
      _showSnackBar('Error searching address: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
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
      widget.onLocationChanged?.call(location);
      debugPrint('🗺️ Location selected: ${location.latitude}, ${location.longitude}');

      // Try to get address for the location
      await _getAddressForLocation(location);
      
      _showSnackBar('Current location confirmed');
    } catch (e) {
      _showSnackBar('Error getting current location: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: StandardizedText(
            message,
            style: StandardizedTextStyle.bodyMedium,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}