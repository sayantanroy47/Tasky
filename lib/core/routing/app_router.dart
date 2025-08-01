import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/tasks_page.dart';
import '../../presentation/pages/task_detail_page.dart';
import '../../presentation/pages/projects_page.dart';
import '../../presentation/pages/project_detail_page.dart';
import '../../presentation/pages/calendar_page.dart';
import '../../presentation/pages/analytics_page.dart';
import '../../presentation/pages/settings_page.dart';
import '../../presentation/pages/not_found_page.dart';
import '../../presentation/pages/voice_demo_page.dart';
import '../../presentation/pages/location_settings_page.dart';
import '../../presentation/pages/data_export_page.dart';

/// App router configuration
class AppRouter {
  // Private constructor to prevent instantiation
  AppRouter._();

  /// Route names
  static const String home = '/home';
  static const String tasks = '/tasks';
  static const String taskDetail = '/task-detail';
  static const String projects = '/projects';
  static const String projectDetail = '/project-detail';
  static const String calendar = '/calendar';
  static const String analytics = '/analytics';
  static const String settings = '/settings';
  static const String voiceDemo = '/voice-demo';
  static const String locationSettings = '/location-settings';
  static const String dataExport = '/data-export';

  /// Initial route
  static const String initialRoute = home;

  /// Generate routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return _createRoute(const HomePage(), settings);
      case '/tasks':
        return _createRoute(const TasksPage(), settings);
      case '/task-detail':
        final taskId = settings.arguments as String?;
        if (taskId != null) {
          return _createRoute(TaskDetailPage(taskId: taskId), settings);
        }
        return _createRoute(const NotFoundPage(), settings);
      case '/projects':
        return _createRoute(const ProjectsPage(), settings);
      case '/project-detail':
        final projectId = settings.arguments as String?;
        if (projectId != null) {
          return _createRoute(ProjectDetailPage(projectId: projectId), settings);
        }
        return _createRoute(const NotFoundPage(), settings);
      case '/calendar':
        return _createRoute(const CalendarPage(), settings);
      case '/analytics':
        return _createRoute(const AnalyticsPage(), settings);
      case '/settings':
        return _createRoute(const SettingsPage(), settings);
      case '/voice-demo':
        return _createRoute(const VoiceDemoPage(), settings);
      case '/location-settings':
        return _createRoute(const LocationSettingsPage(), settings);
      case '/data-export':
        return _createRoute(const DataExportPage(), settings);
      default:
        return _createRoute(const NotFoundPage(), settings);
    }
  }

  /// Create route with consistent transition
  static Route<dynamic> _createRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide transition from right to left
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Navigate to route with provider update
  static void navigateToRoute(
    BuildContext context,
    String routeName,
    WidgetRef ref,
  ) {
    // Update navigation provider
    ref.read(navigationProvider.notifier).navigateToRoute(routeName);
    
    // Navigate using Navigator
    Navigator.of(context).pushReplacementNamed(routeName);
  }

  /// Navigate to destination with provider update
  static void navigateToDestination(
    BuildContext context,
    AppNavigationDestination destination,
    WidgetRef ref,
  ) {
    // Update navigation provider
    ref.read(navigationProvider.notifier).navigateToDestination(destination);
    
    // Navigate using Navigator
    Navigator.of(context).pushReplacementNamed(destination.route);
  }

  /// Navigate to index with provider update
  static void navigateToIndex(
    BuildContext context,
    int index,
    WidgetRef ref,
  ) {
    final destination = AppNavigationDestination.fromIndex(index);
    navigateToDestination(context, destination, ref);
  }

  /// Get all navigation destinations for bottom navigation
  static List<AppNavigationDestination> get bottomNavigationDestinations => [
    AppNavigationDestination.home,
    AppNavigationDestination.tasks,
    AppNavigationDestination.projects,
    AppNavigationDestination.calendar,
    AppNavigationDestination.analytics,
  ];

  /// Check if route exists
  static bool isValidRoute(String route) {
    return AppNavigationDestination.values
        .any((destination) => destination.route == route);
  }
}
