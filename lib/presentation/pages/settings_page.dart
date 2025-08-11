import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/simple_theme_toggle.dart';
import '../widgets/glassmorphism_container.dart';
import 'themes_page.dart';
import 'help_page.dart';
import 'import_export_page.dart';
import '../../core/theme/typography_constants.dart';

/// Settings page for app configuration and preferences
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const StandardizedAppBar(
        title: 'Settings',
        actions: [
          ThemeToggleButton(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance section
          GlassmorphismContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text('Themes'),
                  subtitle: const Text('Customize app appearance'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ThemesPage(),
                      ),
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tasks section
          GlassmorphismContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(
                    'Tasks',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notifications'),
                    subtitle: const Text('Task reminders and alerts'),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        // TODO: Implement notification settings
                      },
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.sync),
                    title: const Text('Auto Sync'),
                    subtitle: const Text('Sync tasks across devices'),
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {
                        // TODO: Implement sync settings
                      },
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Data section
          GlassmorphismContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                ListTile(
                  leading: const Icon(Icons.import_export),
                  title: const Text('Import & Export'),
                  subtitle: const Text('Backup and restore your tasks'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ImportExportPage(),
                      ),
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // About section
          GlassmorphismContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  subtitle: const Text('Get help using the app'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HelpPage(),
                      ),
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  subtitle: const Text('Version 1.0.0'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Tasky',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2024 Tasky App',
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}