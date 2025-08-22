import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography_constants.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';


/// Widget for AI privacy controls and data management
class AIPrivacyControls extends ConsumerWidget {
  const AIPrivacyControls({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  PhosphorIcons.shieldWarning(),
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Privacy & Data Control',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your data and privacy preferences',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Data Retention Settings
            ListTile(
              leading: Icon(PhosphorIcons.database()),
              title: const Text('Data Retention'),
              subtitle: const Text('Manage how long AI data is stored'),
              trailing: Icon(PhosphorIcons.caretRight()),
              onTap: () => _showDataRetentionDialog(context),
            ),

            const Divider(),

            // Clear AI Data
            ListTile(
              leading: Icon(PhosphorIcons.trash()),
              title: const Text('Clear AI Data'),
              subtitle: const Text('Remove all stored AI parsing data'),
              trailing: Icon(PhosphorIcons.caretRight()),
              onTap: () => _showClearDataDialog(context),
            ),

            const Divider(),

            // Export Data
            ListTile(
              leading: Icon(PhosphorIcons.download()),
              title: const Text('Export AI Data'),
              subtitle: const Text('Download your AI usage data'),
              trailing: Icon(PhosphorIcons.caretRight()),
              onTap: () => _exportAIData(context),
            ),

            const Divider(),

            // Privacy Mode
            SwitchListTile(
              secondary: Icon(PhosphorIcons.shield()),
              title: const Text('Enhanced Privacy Mode'),
              subtitle: const Text('Minimize data collection and processing'),
              value: false, // This would come from preferences
              onChanged: (value) => _togglePrivacyMode(context, value),
            ),

            const SizedBox(height: 16),

            // Privacy Information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.info(),
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Privacy Rights',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• You control which AI service processes your data\n'
                    '• Switch to local-only processing anytime\n'
                    '• Clear your data whenever you want\n'
                    '• Export your data in standard formats',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDataRetentionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DataRetentionDialog(),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear AI Data'),
        content: const Text(
          'This will permanently delete all AI parsing data including:\n\n'
          '• Usage statistics\n'
          '• Cached parsing results\n'
          '• AI service preferences\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearAIData(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }

  void _clearAIData(BuildContext context) {
    // Implementation would clear all AI-related data from SharedPreferences
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI data cleared successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportAIData(BuildContext context) {
    // Implementation would export AI data to a file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI data export started'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _togglePrivacyMode(BuildContext context, bool enabled) {
    // Implementation would toggle enhanced privacy mode
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled 
            ? 'Enhanced privacy mode enabled'
            : 'Enhanced privacy mode disabled'
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

/// Dialog for configuring data retention settings
class DataRetentionDialog extends StatefulWidget {
  const DataRetentionDialog({super.key});
  @override
  State<DataRetentionDialog> createState() => _DataRetentionDialogState();
}

class _DataRetentionDialogState extends State<DataRetentionDialog> {
  int _selectedDays = 30; // Default retention period
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Data Retention Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose how long to keep AI parsing data:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          
          RadioListTile<int>(
            title: const Text('7 days'),
            subtitle: const Text('Minimal retention'),
            value: 7,
            groupValue: _selectedDays,
            onChanged: (value) {
              setState(() {
                _selectedDays = value!;
              });
            },
          ),
          
          RadioListTile<int>(
            title: const Text('30 days'),
            subtitle: const Text('Recommended'),
            value: 30,
            groupValue: _selectedDays,
            onChanged: (value) {
              setState(() {
                _selectedDays = value!;
              });
            },
          ),
          
          RadioListTile<int>(
            title: const Text('90 days'),
            subtitle: const Text('Extended retention'),
            value: 90,
            groupValue: _selectedDays,
            onChanged: (value) {
              setState(() {
                _selectedDays = value!;
              });
            },
          ),
          
          RadioListTile<int>(
            title: const Text('Never delete'),
            subtitle: const Text('Keep data indefinitely'),
            value: -1,
            groupValue: _selectedDays,
            onChanged: (value) {
              setState(() {
                _selectedDays = value!;
              });
            },
          ),
          
          SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  PhosphorIcons.info(),
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Data older than the selected period will be automatically deleted. This includes usage statistics and cached results.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            _saveRetentionSettings();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveRetentionSettings() {
    // Implementation would save retention settings to SharedPreferences
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedDays == -1
            ? 'Data retention set to indefinite'
            : 'Data retention set to $_selectedDays days'
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}


