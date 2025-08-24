import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/constants/phosphor_icons.dart';
import '../../../core/theme/typography_constants.dart';
import '../../../core/design_system/design_tokens.dart';
import '../../../domain/entities/timeline_settings.dart';
import '../glassmorphism_container.dart';

/// Timeline control panel with zoom, filters, and view options
/// 
/// Features:
/// - Zoom level controls (hours, days, weeks, months)
/// - View toggles (dependencies, milestones, critical path)
/// - Date range selector
/// - Project filter dropdown
/// - Export and settings options
/// - Responsive layout for different screen sizes
class TimelineControls extends StatefulWidget {
  /// Current timeline settings
  final TimelineSettings settings;
  
  /// Callback when settings are changed
  final void Function(TimelineSettings settings) onSettingsChanged;
  
  /// Callback when zoom level changes
  final void Function(TimelineZoom zoom) onZoomChanged;
  
  /// Callback when date range changes
  final void Function(DateTime start, DateTime end) onDateRangeChanged;
  
  /// Whether to show advanced controls
  final bool showAdvancedControls;

  const TimelineControls({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    required this.onZoomChanged,
    required this.onDateRangeChanged,
    this.showAdvancedControls = true,
  });

  @override
  State<TimelineControls> createState() => _TimelineControlsState();
}

class _TimelineControlsState extends State<TimelineControls> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    return GlassmorphismContainer(
      level: GlassLevel.interactive,
      padding: const EdgeInsets.all(TypographyConstants.paddingMedium),
      borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
      child: Column(
        children: [
          // Main controls row
          _buildMainControlsRow(),
          
          // Advanced controls (collapsible)
          if (widget.showAdvancedControls) ...[
            const SizedBox(height: TypographyConstants.spacingSmall),
            _buildExpandButton(),
            
            if (_isExpanded) ...[
              const SizedBox(height: TypographyConstants.spacingMedium),
              _buildAdvancedControls(),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildMainControlsRow() {
    return Row(
      children: [
        // Zoom controls
        _buildZoomControls(),
        
        const SizedBox(width: TypographyConstants.spacingLarge),
        
        // View toggles
        _buildViewToggles(),
        
        const Spacer(),
        
        // Action buttons
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildZoomControls() {
    return Row(
      children: [
        Text(
          'Zoom:',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: TypographyConstants.medium,
          ),
        ),
        const SizedBox(width: TypographyConstants.spacingSmall),
        
        // Zoom level buttons
        ...TimelineZoom.values.map((zoom) {
          final isSelected = widget.settings.zoomLevel == zoom;
          
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: _buildZoomButton(zoom, isSelected),
          );
        }),
      ],
    );
  }

  Widget _buildZoomButton(TimelineZoom zoom, bool isSelected) {
    return GestureDetector(
      onTap: () => widget.onZoomChanged(zoom),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: TypographyConstants.paddingSmall,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIconConstants.getIconByName(zoom.iconName),
              size: 14,
              color: isSelected 
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 4),
            Text(
              zoom.displayName,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected 
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: TypographyConstants.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggles() {
    return Row(
      children: [
        Text(
          'Show:',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: TypographyConstants.medium,
          ),
        ),
        const SizedBox(width: TypographyConstants.spacingSmall),
        
        _buildToggleButton(
          label: 'Dependencies',
          icon: PhosphorIcons.arrowRight(),
          isEnabled: widget.settings.showDependencies,
          onToggled: (value) => _updateSetting((s) => s.copyWith(showDependencies: value)),
        ),
        
        _buildToggleButton(
          label: 'Milestones',
          icon: PhosphorIcons.flagBanner(),
          isEnabled: widget.settings.showMilestones,
          onToggled: (value) => _updateSetting((s) => s.copyWith(showMilestones: value)),
        ),
        
        _buildToggleButton(
          label: 'Progress',
          icon: PhosphorIcons.chartBar(),
          isEnabled: widget.settings.showProgress,
          onToggled: (value) => _updateSetting((s) => s.copyWith(showProgress: value)),
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isEnabled,
    required void Function(bool) onToggled,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: TypographyConstants.spacingSmall),
      child: GestureDetector(
        onTap: () => onToggled(!isEnabled),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: TypographyConstants.paddingSmall,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: isEnabled 
                ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
            border: Border.all(
              color: isEnabled 
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isEnabled 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isEnabled 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: TypographyConstants.medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Today button
        _buildActionButton(
          label: 'Today',
          icon: PhosphorIcons.calendar(),
          onPressed: _goToToday,
          tooltip: 'Jump to today',
        ),
        
        const SizedBox(width: TypographyConstants.spacingSmall),
        
        // Fit timeline button
        _buildActionButton(
          label: 'Fit',
          icon: PhosphorIcons.arrowsOutSimple(),
          onPressed: _fitTimeline,
          tooltip: 'Fit all tasks in view',
        ),
        
        const SizedBox(width: TypographyConstants.spacingSmall),
        
        // Export button
        _buildActionButton(
          label: 'Export',
          icon: PhosphorIcons.export(),
          onPressed: _showExportOptions,
          tooltip: 'Export timeline',
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TypographyConstants.paddingSmall,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusSmall),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: TypographyConstants.medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandButton() {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isExpanded ? PhosphorIcons.caretUp() : PhosphorIcons.caretDown(),
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            _isExpanded ? 'Hide Advanced' : 'Show Advanced',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedControls() {
    return Column(
      children: [
        // First row - Display options
        Row(
          children: [
            Expanded(
              child: _buildAdvancedSection(
                title: 'Display Options',
                children: [
                  _buildAdvancedToggle(
                    label: 'Show Weekends',
                    value: widget.settings.showWeekends,
                    onChanged: (value) => _updateSetting((s) => s.copyWith(showWeekends: value)),
                  ),
                  _buildAdvancedToggle(
                    label: 'Critical Path',
                    value: widget.settings.showCriticalPath,
                    onChanged: (value) => _updateSetting((s) => s.copyWith(showCriticalPath: value)),
                  ),
                  _buildAdvancedToggle(
                    label: 'Resource Allocation',
                    value: widget.settings.showResourceAllocation,
                    onChanged: (value) => _updateSetting((s) => s.copyWith(showResourceAllocation: value)),
                  ),
                  _buildAdvancedToggle(
                    label: 'Highlight Overdue',
                    value: widget.settings.highlightOverdue,
                    onChanged: (value) => _updateSetting((s) => s.copyWith(highlightOverdue: value)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: TypographyConstants.spacingLarge),
            
            Expanded(
              child: _buildAdvancedSection(
                title: 'Interaction',
                children: [
                  _buildAdvancedToggle(
                    label: 'Drag & Drop',
                    value: widget.settings.enableDragAndDrop,
                    onChanged: (value) => _updateSetting((s) => s.copyWith(enableDragAndDrop: value)),
                  ),
                  _buildAdvancedToggle(
                    label: 'Auto Schedule',
                    value: widget.settings.autoSchedule,
                    onChanged: (value) => _updateSetting((s) => s.copyWith(autoSchedule: value)),
                  ),
                  _buildAdvancedToggle(
                    label: 'Hover Details',
                    value: widget.settings.showTaskDetailsOnHover,
                    onChanged: (value) => _updateSetting((s) => s.copyWith(showTaskDetailsOnHover: value)),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: TypographyConstants.spacingMedium),
        
        // Second row - Time settings
        Row(
          children: [
            Expanded(
              child: _buildAdvancedSection(
                title: 'Working Hours',
                children: [
                  Row(
                    children: [
                      Text(
                        'Start: ${widget.settings.workingHoursStart}:00',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Slider(
                          value: widget.settings.workingHoursStart.toDouble(),
                          min: 0,
                          max: 23,
                          divisions: 23,
                          onChanged: (value) => _updateSetting((s) => s.copyWith(workingHoursStart: value.round())),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'End: ${widget.settings.workingHoursEnd}:00',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Slider(
                          value: widget.settings.workingHoursEnd.toDouble(),
                          min: 1,
                          max: 24,
                          divisions: 23,
                          onChanged: (value) => _updateSetting((s) => s.copyWith(workingHoursEnd: value.round())),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: TypographyConstants.spacingLarge),
            
            Expanded(
              child: _buildAdvancedSection(
                title: 'Color Theme',
                children: [
                  DropdownButton<TimelineColorTheme>(
                    value: widget.settings.colorTheme,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    items: TimelineColorTheme.values.map((theme) {
                      return DropdownMenuItem(
                        value: theme,
                        child: Text(
                          theme.displayName,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _updateSetting((s) => s.copyWith(colorTheme: value));
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdvancedSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: TypographyConstants.medium,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: TypographyConstants.spacingSmall),
        ...children,
      ],
    );
  }

  Widget _buildAdvancedToggle({
    required String label,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  void _updateSetting(TimelineSettings Function(TimelineSettings) updater) {
    final newSettings = updater(widget.settings);
    widget.onSettingsChanged(newSettings);
  }

  void _goToToday() {
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 7));
    final end = today.add(const Duration(days: 30));
    widget.onDateRangeChanged(start, end);
  }

  void _fitTimeline() {
    // TODO: Calculate optimal date range based on all tasks
    final start = DateTime.now().subtract(const Duration(days: 30));
    final end = DateTime.now().add(const Duration(days: 90));
    widget.onDateRangeChanged(start, end);
  }

  void _showExportOptions() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TypographyConstants.radiusStandard),
        ),
      ),
      builder: (context) => _buildExportBottomSheet(),
    );
  }

  Widget _buildExportBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(TypographyConstants.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Export Timeline',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: TypographyConstants.medium,
            ),
          ),
          const SizedBox(height: TypographyConstants.spacingLarge),
          
          ListTile(
            leading: Icon(PhosphorIcons.image()),
            title: const Text('Export as Image'),
            subtitle: const Text('PNG, JPEG formats'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement image export
            },
          ),
          
          ListTile(
            leading: Icon(PhosphorIcons.filePdf()),
            title: const Text('Export as PDF'),
            subtitle: const Text('Vector format, scalable'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement PDF export
            },
          ),
          
          ListTile(
            leading: Icon(PhosphorIcons.table()),
            title: const Text('Export Data'),
            subtitle: const Text('CSV, Excel formats'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement data export
            },
          ),
          
          const SizedBox(height: TypographyConstants.spacingMedium),
          
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
}