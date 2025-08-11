import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/standardized_app_bar.dart';
import '../../services/integration_service.dart';
import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';

class IntegrationSettingsScreen extends ConsumerStatefulWidget {
  const IntegrationSettingsScreen({super.key});
  @override
  ConsumerState<IntegrationSettingsScreen> createState() => _IntegrationSettingsScreenState();
}

class _IntegrationSettingsScreenState extends ConsumerState<IntegrationSettingsScreen> {
  List<String> _installedMessagingApps = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
  }

  Future<void> _loadInstalledApps() async {
    try {
      final integrationService = ref.read(integrationServiceProvider);
      final apps = await integrationService.getInstalledMessagingApps();
      setState(() {
        _installedMessagingApps = apps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StandardizedAppBar(
        title: 'External App Integration',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Share Intent Settings'),
                  _buildShareIntentCard(),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Messaging Apps'),
                  _buildMessagingAppsSection(),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Quick Actions'),
                  _buildQuickActionsSection(),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Widgets'),
                  _buildWidgetsSection(),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Test Integration'),
                  _buildTestSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildShareIntentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.share, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Share Intent Handling',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'This app can receive shared text from other apps and automatically create tasks. '
              'Share any text content to this app to create a new task.',
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text('Share intent handling enabled'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagingAppsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.message, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Messaging App Integration',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Share tasks directly to your favorite messaging apps:',
            ),
            const SizedBox(height: 16),
            ..._buildMessagingAppsList(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMessagingAppsList() {
    final appInfo = {
      'com.whatsapp': {'name': 'WhatsApp', 'icon': Icons.chat},
      'com.facebook.orca': {'name': 'Facebook Messenger', 'icon': Icons.messenger},
      'com.telegram.messenger': {'name': 'Telegram', 'icon': Icons.telegram},
      'com.discord': {'name': 'Discord', 'icon': Icons.discord},
      'com.slack': {'name': 'Slack', 'icon': Icons.work},
      'com.microsoft.teams': {'name': 'Microsoft Teams', 'icon': Icons.groups},
    };

    return appInfo.entries.map((entry) {
      final packageName = entry.key;
      final info = entry.value;
      final isInstalled = _installedMessagingApps.contains(packageName);

      return ListTile(
        leading: Icon(
          info['icon'] as IconData,
          color: isInstalled ? Colors.green : Colors.grey,
        ),
        title: Text(info['name'] as String),
        subtitle: Text(isInstalled ? 'Installed' : 'Not installed'),
        trailing: isInstalled
            ? ElevatedButton(
                onPressed: () => _testShareToApp(packageName),
                child: const Text('Test'),
              )
            : null,
      );
    }).toList();
  }

  Widget _buildQuickActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Quick ways to create tasks from outside the app:',
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.settings),
              title: Text('Quick Settings Tile'),
              subtitle: Text('Add quick task tile to notification panel'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
            const ListTile(
              leading: Icon(Icons.shortcut),
              title: Text('App Shortcuts'),
              subtitle: Text('Long press app icon for quick actions'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
            const ListTile(
              leading: Icon(Icons.voice_chat),
              title: Text('Voice Shortcuts'),
              subtitle: Text('Create tasks using voice commands'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetsSection() {
    final integrationService = ref.read(integrationServiceProvider);
    final widgetTypes = integrationService.getAvailableWidgetTypes();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.widgets, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Home Screen Widgets',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Add widgets to your home screen for quick access:',
            ),
            const SizedBox(height: 16),
            ...widgetTypes.map((widget) => ListTile(
              leading: const Icon(Icons.widgets_outlined),
              title: Text(widget['name'] as String),
              subtitle: Text(widget['description'] as String),
              trailing: TextButton(
                onPressed: () => _configureWidget(widget['type'] as String),
                child: const Text('Configure'),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bug_report, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Test Integration',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Test the integration features:',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _testShareIntent,
                  icon: const Icon(Icons.share),
                  label: const Text('Test Share'),
                ),
                ElevatedButton.icon(
                  onPressed: _testQuickTask,
                  icon: const Icon(Icons.add_task),
                  label: const Text('Test Quick Task'),
                ),
                ElevatedButton.icon(
                  onPressed: _testWidgetUpdate,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Update Widgets'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testShareToApp(String packageName) async {
    try {
      final integrationService = ref.read(integrationServiceProvider);
      
      // Create a test task
      final testTask = TaskModel(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Test Task from Task Tracker',
        description: 'This is a test task shared from the Task Tracker app.',
        createdAt: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        tags: const ['test', 'shared'],
        subTasks: const [],
        projectId: null,
        dependencies: const [],
        metadata: const {'source': 'test'},
      );

      final success = await integrationService.shareTask(testTask, targetApp: packageName);
      
      if (success) {
        _showSnackBar('Test task shared successfully!', Colors.green);
      } else {
        _showSnackBar('Failed to share test task', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error sharing test task: $e', Colors.red);
    }
  }

  Future<void> _testShareIntent() async {
    try {
      final integrationService = ref.read(integrationServiceProvider);
      
      // Simulate shared content
      const testContent = 'Buy groceries tomorrow at 3 PM - high priority task with shopping tag';
      
      final task = await integrationService.handleSharedContent(
        testContent,
        sourceApp: 'test_app',
      );
      
      if (task != null) {
        _showSnackBar('Test share intent processed successfully!', Colors.green);
      } else {
        _showSnackBar('Failed to process test share intent', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error testing share intent: $e', Colors.red);
    }
  }

  Future<void> _testQuickTask() async {
    try {
      final integrationService = ref.read(integrationServiceProvider);
      
      final task = await integrationService.handleShortcutAction(
        'CREATE_QUICK_TASK',
        {'title': 'Test Quick Task', 'description': 'Created from integration test'},
      );
      
      if (task != null) {
        _showSnackBar('Test quick task created successfully!', Colors.green);
      } else {
        _showSnackBar('Failed to create test quick task', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error testing quick task: $e', Colors.red);
    }
  }

  Future<void> _testWidgetUpdate() async {
    try {
      final integrationService = ref.read(integrationServiceProvider);
      await integrationService.updateWidgets();
      _showSnackBar('Widgets updated successfully!', Colors.green);
    } catch (e) {
      _showSnackBar('Error updating widgets: $e', Colors.red);
    }
  }

  Future<void> _configureWidget(String widgetType) async {
    // Show widget configuration dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configure $widgetType Widget'),
        content: const Text(
          'Widget configuration is not yet implemented. '
          'This would allow users to customize widget appearance and behavior.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}