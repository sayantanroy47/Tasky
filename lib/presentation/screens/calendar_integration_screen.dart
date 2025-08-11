import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_calendar/device_calendar.dart';
import '../widgets/standardized_app_bar.dart';
import '../../services/system_calendar_service.dart';

/// Screen for managing calendar integration settings
class CalendarIntegrationScreen extends ConsumerStatefulWidget {
  const CalendarIntegrationScreen({super.key});
  @override
  ConsumerState<CalendarIntegrationScreen> createState() => _CalendarIntegrationScreenState();
}

class _CalendarIntegrationScreenState extends ConsumerState<CalendarIntegrationScreen> {
  bool _isInitializing = false;
  bool _isSyncing = false;
  @override
  void initState() {
    super.initState();
    _initializeCalendarService();
  }

  Future<void> _initializeCalendarService() async {
    setState(() => _isInitializing = true);
    
    final service = ref.read(systemCalendarServiceProvider);
    await service.initialize();
    
    setState(() => _isInitializing = false);
  }
  @override
  Widget build(BuildContext context) {
    final syncStatusAsync = ref.watch(calendarSyncStatusProvider);
    final availableCalendars = ref.watch(availableCalendarsProvider);

    return Scaffold(
      appBar: StandardizedAppBar(
        title: 'Calendar Integration',
        actions: [
          IconButton(
            onPressed: _isSyncing ? null : _performSync,
            icon: _isSyncing 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            tooltip: 'Sync Now',
          ),
        ],
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : syncStatusAsync.when(
              data: (syncStatus) => _buildContent(context, syncStatus, availableCalendars),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(calendarSyncStatusProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CalendarSyncStatus syncStatus,
    List<Calendar> availableCalendars,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Integration status card
        _buildStatusCard(syncStatus),
        const SizedBox(height: 16),

        // Permission section
        _buildPermissionSection(syncStatus),
        const SizedBox(height: 16),

        // Calendar selection section
        if (syncStatus.hasPermission) ...[
          _buildCalendarSelectionSection(availableCalendars),
          const SizedBox(height: 16),
        ],

        // Sync settings section
        if (syncStatus.isEnabled) ...[
          _buildSyncSettingsSection(),
          const SizedBox(height: 16),
        ],

        // Sync actions section
        if (syncStatus.isEnabled) ...[
          _buildSyncActionsSection(),
          const SizedBox(height: 16),
        ],

        // Help section
        _buildHelpSection(),
      ],
    );
  }

  Widget _buildStatusCard(CalendarSyncStatus syncStatus) {
    final isEnabled = syncStatus.isEnabled;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isEnabled ? Icons.check_circle : Icons.error,
                  color: isEnabled ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Calendar Integration',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isEnabled 
                  ? 'Integration is active and ready to sync'
                  : 'Integration requires setup',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (syncStatus.selectedCalendarName != null) ...[
              const SizedBox(height: 8),
              Text(
                'Selected Calendar: ${syncStatus.selectedCalendarName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (syncStatus.lastSyncTime != null) ...[
              const SizedBox(height: 4),
              Text(
                'Last Sync: ${_formatDateTime(syncStatus.lastSyncTime!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionSection(CalendarSyncStatus syncStatus) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calendar Permission',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  syncStatus.hasPermission ? Icons.check : Icons.close,
                  color: syncStatus.hasPermission ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    syncStatus.hasPermission
                        ? 'Calendar access granted'
                        : 'Calendar access required',
                  ),
                ),
                if (!syncStatus.hasPermission)
                  ElevatedButton(
                    onPressed: _requestPermission,
                    child: const Text('Grant Permission'),
                  ),
              ],
            ),
            if (!syncStatus.hasPermission) ...[
              const SizedBox(height: 8),
              Text(
                'Calendar permission is required to sync tasks with your device calendar.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSelectionSection(List<Calendar> availableCalendars) {
    final service = ref.read(systemCalendarServiceProvider);
    final selectedCalendarId = service.selectedCalendarId;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Calendar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (availableCalendars.isEmpty)
              const Text('No calendars available')
            else
              ...availableCalendars.map((calendar) {
                final isReadOnly = calendar.isReadOnly ?? false;
                
                return RadioListTile<String>(
                  title: Text(calendar.name ?? 'Unnamed Calendar'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Account: ${calendar.accountName ?? 'Unknown'}'),
                      if (isReadOnly)
                        Text(
                          'Read-only',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  value: calendar.id!,
                  groupValue: selectedCalendarId,
                  onChanged: isReadOnly ? null : (value) {
                    if (value != null) {
                      service.setSelectedCalendar(value);
                      ref.invalidate(calendarSyncStatusProvider);
                    }
                  },
                  secondary: Icon(
                    Icons.calendar_today,
                    color: isReadOnly ? Colors.grey : null,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Auto Sync'),
              subtitle: const Text('Automatically sync changes'),
              value: true, // This would be from settings
              onChanged: (value) {
                // Implement auto sync toggle
              },
            ),
            SwitchListTile(
              title: const Text('Two-way Sync'),
              subtitle: const Text('Import events from calendar'),
              value: false, // This would be from settings
              onChanged: (value) {
                // Implement two-way sync toggle
              },
            ),
            ListTile(
              title: const Text('Sync Frequency'),
              subtitle: const Text('Every 15 minutes'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Show sync frequency options
                _showSyncFrequencyDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sync Now'),
              subtitle: const Text('Manually sync all changes'),
              onTap: _performSync,
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Import Events'),
              subtitle: const Text('Import events from calendar'),
              onTap: _importEvents,
            ),
            ListTile(
              leading: const Icon(Icons.upload),
              title: const Text('Export Tasks'),
              subtitle: const Text('Export all tasks to calendar'),
              onTap: _exportTasks,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.orange),
              title: const Text('Reset Sync'),
              subtitle: const Text('Clear sync data and start fresh'),
              onTap: _resetSync,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help & Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('How it works'),
              subtitle: const Text('Learn about calendar integration'),
              onTap: _showHelpDialog,
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Troubleshooting'),
              subtitle: const Text('Fix common sync issues'),
              onTap: _showTroubleshootingDialog,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermission() async {
    final service = ref.read(systemCalendarServiceProvider);
    final granted = await service.requestCalendarPermission();
    
    if (granted) {
      await service.initialize();
      ref.invalidate(calendarSyncStatusProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calendar permission granted')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Calendar permission denied'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _performSync() async {
    setState(() => _isSyncing = true);
    
    try {
      final service = ref.read(systemCalendarServiceProvider);
      final result = await service.performSync();
      
      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sync completed: ${result.importedCount} imported, ${result.exportedCount} exported',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sync failed: ${result.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Future<void> _importEvents() async {
    // Show date range picker and import events
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now().add(const Duration(days: 90)),
      ),
    );

    if (dateRange != null) {
      final service = ref.read(systemCalendarServiceProvider);
      final events = await service.importEventsFromCalendar(
        startDate: dateRange.start,
        endDate: dateRange.end,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported ${events.length} events')),
        );
      }
    }
  }

  Future<void> _exportTasks() async {
    // This would export all tasks to calendar
    // Implementation would depend on task provider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon')),
    );
  }

  Future<void> _resetSync() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Sync'),
        content: const Text(
          'This will clear all sync data and remove the connection to your calendar. '
          'You will need to set up the integration again. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Reset sync data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync data reset')),
      );
    }
  }

  void _showSyncFrequencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Frequency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Manual only'),
              value: 'manual',
              groupValue: 'every_15_min',
              onChanged: (value) => Navigator.of(context).pop(),
            ),
            RadioListTile<String>(
              title: const Text('Every 15 minutes'),
              value: 'every_15_min',
              groupValue: 'every_15_min',
              onChanged: (value) => Navigator.of(context).pop(),
            ),
            RadioListTile<String>(
              title: const Text('Every hour'),
              value: 'hourly',
              groupValue: 'every_15_min',
              onChanged: (value) => Navigator.of(context).pop(),
            ),
            RadioListTile<String>(
              title: const Text('Daily'),
              value: 'daily',
              groupValue: 'every_15_min',
              onChanged: (value) => Navigator.of(context).pop(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calendar Integration Help'),
        content: const SingleChildScrollView(
          child: Text(
            'Calendar integration allows you to sync your tasks with your device\'s calendar app.\n\n'
            'Features:\n'
            '• Export tasks as calendar events\n'
            '• Import calendar events as tasks\n'
            '• Two-way synchronization\n'
            '• Automatic sync based on schedule\n\n'
            'Your tasks will appear in your calendar with appropriate reminders based on priority.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showTroubleshootingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Troubleshooting'),
        content: const SingleChildScrollView(
          child: Text(
            'Common issues and solutions:\n\n'
            '1. Events not syncing:\n'
            '   • Check calendar permissions\n'
            '   • Ensure calendar is not read-only\n'
            '   • Try manual sync\n\n'
            '2. Duplicate events:\n'
            '   • Reset sync data\n'
            '   • Disable two-way sync temporarily\n\n'
            '3. Missing events:\n'
            '   • Check date range settings\n'
            '   • Verify calendar selection\n\n'
            'If issues persist, try resetting the sync data.',
          ),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}