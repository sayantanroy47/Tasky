import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/simple_theme_toggle.dart';
import '../widgets/glassmorphism_container.dart';
import 'themes_page.dart';
import 'help_page.dart';
import 'import_export_page.dart';
import 'tasks_page.dart';
import 'projects_page.dart';
import 'ai_settings_page.dart' as ai_settings;
import 'data_export_page.dart';
import 'location_settings_page.dart';
import 'nearby_tasks_page.dart';
import 'notification_settings_page.dart';
import 'notification_history_page.dart';
import 'voice_demo_page.dart';
import '../../core/theme/typography_constants.dart';
import '../../core/routing/app_router.dart';

/// Settings page for app configuration and preferences
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true, // Show phone status bar
      appBar: const StandardizedAppBar(
        title: 'Settings',
        forceBackButton: false, // Settings is main tab - no back button
        actions: [
          ThemeToggleButton(),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(
            top: kToolbarHeight + 8, // App bar height + spacing
            left: 16,
            right: 16,
            bottom: 16,
          ),
        children: [
          // Navigation section
          GlassmorphismContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Navigation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                ListTile(
                  leading: const Icon(Icons.task_alt),
                  title: const Text('Tasks'),
                  subtitle: const Text('View and manage all tasks'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TasksPage(),
                      ),
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                
                ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: const Text('Projects'),
                  subtitle: const Text('Organize tasks by projects'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProjectsPage(),
                      ),
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
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
          
          // AI & Voice section
          GlassmorphismContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI & Voice',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                ListTile(
                  leading: const Icon(Icons.smart_toy),
                  title: const Text('AI Settings'),
                  subtitle: const Text('Configure AI task parsing and features'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ai_settings.AISettingsPage(),
                      ),
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                
                ListTile(
                  leading: const Icon(Icons.record_voice_over),
                  title: const Text('Voice Demo'),
                  subtitle: const Text('Test voice recognition features'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const VoiceDemoPage(),
                      ),
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Location section
          GlassmorphismContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Location Settings'),
                  subtitle: const Text('Configure location-based features'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LocationSettingsPage(),
                      ),
                    );
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                
                ListTile(
                  leading: const Icon(Icons.near_me),
                  title: const Text('Nearby Tasks'),
                  subtitle: const Text('View tasks near your location'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NearbyTasksPage(),
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
                    leading: const Icon(Icons.today_outlined),
                    title: const Text('Today\'s Tasks'),
                    subtitle: const Text('View tasks due today'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TasksPage(),
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.schedule_outlined),
                    title: const Text('Upcoming Tasks'),
                    subtitle: const Text('View future scheduled tasks'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      AppRouter.navigateToRoute(context, AppRouter.calendar);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notification Settings'),
                    subtitle: const Text('Configure task reminders and alerts'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationSettingsPage(),
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Notification History'),
                    subtitle: const Text('View past notifications'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationHistoryPage(),
                        ),
                      );
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.sync),
                    title: const Text('Auto Sync'),
                    subtitle: const Text('Sync tasks across devices'),
                    trailing: Switch(
                      value: false,
                      onChanged: (value) {
                        // Handle sync settings toggle
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(value 
                              ? 'Auto sync enabled' 
                              : 'Auto sync disabled'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
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
                
                ListTile(
                  leading: const Icon(Icons.file_download),
                  title: const Text('Data Export'),
                  subtitle: const Text('Export analytics and task data'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DataExportPage(),
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
      ),
    );
  }
}