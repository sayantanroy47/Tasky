import 'package:flutter/material.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/tasks_page.dart';
import '../../presentation/pages/settings_page.dart';
import '../../presentation/pages/calendar_page.dart';
import '../../presentation/pages/analytics_page.dart';
import '../../presentation/pages/projects_page.dart';
import '../../presentation/pages/task_detail_page.dart';
import '../../presentation/pages/voice_demo_page.dart';
import '../../presentation/pages/data_export_page.dart';
import '../../presentation/screens/performance_dashboard_screen.dart';
import '../../presentation/screens/integration_settings_screen.dart';
import '../../presentation/screens/task_sharing_screen.dart';

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
    // This method should be called with a BuildContext
    // For now, we'll handle navigation through the navigation provider
  }

  /// Navigate to index with context
  static void navigateToIndexWithContext(BuildContext context, int index) {
    String route;
    switch (index) {
      case 0:
        route = home;
        break;
      case 1:
        route = tasks;
        break;
      case 2:
        route = settings;
        break;
      case 3:
        route = performance;
        break;
      default:
        route = home;
    }
    
    Navigator.pushNamedAndRemoveUntil(
      context,
      route,
      (route) => false,
    );
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
          builder: (_) => const HomePage(),
          settings: settings,
        );
      case '/tasks':
        return MaterialPageRoute(
          builder: (_) => const TasksPage(),
          settings: settings,
        );
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
          settings: settings,
        );
      case '/performance':
        return MaterialPageRoute(
          builder: (_) => const PerformanceDashboardScreen(),
          settings: settings,
        );
      case '/calendar':
        return MaterialPageRoute(
          builder: (_) => const CalendarPage(),
          settings: settings,
        );
      case '/analytics':
        return MaterialPageRoute(
          builder: (_) => const AnalyticsPage(),
          settings: settings,
        );
      case '/projects':
        return MaterialPageRoute(
          builder: (_) => const ProjectsPage(),
          settings: settings,
        );
      case '/task-detail':
        return MaterialPageRoute(
          builder: (_) => TaskDetailPage(
            taskId: settings.arguments as String? ?? '',
          ),
          settings: settings,
        );
      case '/voice-demo':
        return MaterialPageRoute(
          builder: (_) => const VoiceDemoPage(),
          settings: settings,
        );
      case '/data-export':
        return MaterialPageRoute(
          builder: (_) => const DataExportPage(),
          settings: settings,
        );
      case '/integration-settings':
        return MaterialPageRoute(
          builder: (_) => const IntegrationSettingsScreen(),
          settings: settings,
        );
      case '/task-sharing':
        return MaterialPageRoute(
          builder: (_) => const TaskSharingScreen(),
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