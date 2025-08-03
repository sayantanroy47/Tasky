import 'package:flutter/material.dart';

/// Application router
class AppRouter {
  static const String initialRoute = '/';
  static const String home = '/';
  static const String tasks = '/tasks';
  static const String settings = '/settings';
  static const String performance = '/performance';

  /// Current navigation index
  final int _currentIndex = 0;

  /// Get current navigation index
  int get currentIndex => _currentIndex;

  /// Navigate to index
  static void navigateToIndex(int index) {
    // This would need to be implemented with proper navigation logic
    // For now, just a placeholder
  }

  /// Navigate to route
  static void navigateToRoute(BuildContext context, String route, {Object? arguments}) {
    Navigator.pushNamed(context, route, arguments: arguments);
  }

  /// Calendar route getter
  static String get calendar => '/calendar';

  /// Analytics route getter
  static String get analytics => '/analytics';

  /// Task detail route getter
  static String get taskDetail => '/task-detail';

  /// Bottom navigation destinations
  static List<NavigationDestination> get bottomNavigationDestinations => [
    const NavigationDestination(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    const NavigationDestination(
      icon: Icon(Icons.task_alt),
      label: 'Tasks',
    ),
    const NavigationDestination(
      icon: Icon(Icons.settings),
      label: 'Settings',
    ),
    const NavigationDestination(
      icon: Icon(Icons.speed),
      label: 'Performance',
    ),
  ];

  /// Generate route
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case '/tasks':
        return MaterialPageRoute(
          builder: (_) => const TasksScreen(),
          settings: settings,
        );
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      case '/performance':
        return MaterialPageRoute(
          builder: (_) => const PerformanceScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
          settings: settings,
        );
    }
  }
}

/// Home screen placeholder
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Tracker'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Welcome to Task Tracker',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your voice-driven task management app',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.tasks);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Tasks screen placeholder
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.settings);
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Tasks will be displayed here'),
      ),
    );
  }
}

/// Settings screen placeholder
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.speed),
            title: const Text('Performance'),
            subtitle: const Text('View performance metrics'),
            onTap: () {
              Navigator.pushNamed(context, AppRouter.performance);
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: const Text('Change app appearance'),
            onTap: () {
              // Theme settings would go here
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy'),
            subtitle: const Text('Privacy and security settings'),
            onTap: () {
              // Privacy settings would go here
            },
          ),
        ],
      ),
    );
  }
}

/// Performance screen placeholder
class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance'),
      ),
      body: const Center(
        child: Text('Performance metrics will be displayed here'),
      ),
    );
  }
}

/// Not found screen
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'The requested page could not be found.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}