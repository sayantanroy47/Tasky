import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/theme_selector.dart';
import '../widgets/app_scaffold.dart';

/// Settings page for app configuration and preferences
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Settings',
      actions: [
        const ThemeToggleButton(),
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () {
            // TODO: Show help
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Help functionality coming soon!')),
            );
          },
          tooltip: 'Help',
        ),
      ],
      body: const SettingsPageBody(),
    );
  }
}

/// Settings page body content
class SettingsPageBody extends ConsumerWidget {
  const SettingsPageBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme settings
          const ThemeSelector(),
          
          const SizedBox(height: 16),
          
          // Voice settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voice Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    title: const Text('Voice Input'),
                    subtitle: const Text('Enable voice-based task creation'),
                    value: true,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Voice input ${value ? 'enabled' : 'disabled'}',
                          ),
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  SwitchListTile(
                    title: const Text('Local Processing'),
                    subtitle: const Text('Process voice locally for privacy'),
                    value: false,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Local processing ${value ? 'enabled' : 'disabled'}',
                          ),
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  ListTile(
                    title: const Text('Voice Language'),
                    subtitle: const Text('English (US)'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Language selection coming soon!'),
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.mic),
                    title: const Text('Voice Demo'),
                    subtitle: const Text('Test voice recognition functionality'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.of(context).pushNamed('/voice-demo');
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Notification settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    title: const Text('Task Reminders'),
                    subtitle: const Text('Get notified about upcoming tasks'),
                    value: true,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Task reminders ${value ? 'enabled' : 'disabled'}',
                          ),
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  SwitchListTile(
                    title: const Text('Daily Summary'),
                    subtitle: const Text('Morning summary of today\'s tasks'),
                    value: true,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Daily summary ${value ? 'enabled' : 'disabled'}',
                          ),
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  ListTile(
                    title: const Text('Quiet Hours'),
                    subtitle: const Text('10:00 PM - 8:00 AM'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Quiet hours settings coming soon!'),
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Privacy settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy & Security',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    title: const Text('App Lock'),
                    subtitle: const Text('Require authentication to open app'),
                    value: false,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'App lock ${value ? 'enabled' : 'disabled'}',
                          ),
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  SwitchListTile(
                    title: const Text('AI Processing'),
                    subtitle: const Text('Use AI for smart task parsing'),
                    value: true,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'AI processing ${value ? 'enabled' : 'disabled'}',
                          ),
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  SwitchListTile(
                    title: const Text('Cloud Sync'),
                    subtitle: const Text('Sync data across devices'),
                    value: false,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Cloud sync ${value ? 'enabled' : 'disabled'}',
                          ),
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Data management
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Management',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  ListTile(
                    leading: const Icon(Icons.file_download),
                    title: const Text('Export Data'),
                    subtitle: const Text('Download your tasks and settings'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Export functionality coming soon!'),
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.file_upload),
                    title: const Text('Import Data'),
                    subtitle: const Text('Import tasks from backup'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Import functionality coming soon!'),
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  ListTile(
                    leading: Icon(Icons.delete_forever, color: Colors.red),
                    title: Text(
                      'Clear All Data',
                      style: TextStyle(color: Colors.red),
                    ),
                    subtitle: const Text('Permanently delete all tasks'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showClearDataDialog(context);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // About section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('App Version'),
                    subtitle: const Text('1.0.0+1'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Privacy policy coming soon!'),
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.gavel),
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Terms of service coming soon!'),
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.feedback),
                    title: const Text('Send Feedback'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Feedback functionality coming soon!'),
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your tasks, settings, and data. '
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Clear data functionality coming soon!'),
                ),
              );
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
}