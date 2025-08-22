import 'package:flutter/material.dart';
import '../../presentation/widgets/standardized_app_bar.dart';
import '../theme/typography_constants.dart';
import '../../presentation/pages/main_scaffold.dart';
import '../../presentation/pages/tasks_page.dart';
import '../../presentation/pages/settings_page.dart';
import '../../presentation/pages/calendar_page.dart';
import '../../presentation/pages/analytics_page.dart';
import '../../presentation/pages/projects_page.dart';
import '../../presentation/pages/task_detail_page.dart';
import '../../presentation/pages/voice_demo_page.dart';
import '../../presentation/pages/data_export_page.dart';
import '../../presentation/pages/help_page.dart';
import '../../presentation/pages/task_dependencies_page.dart';
import '../../presentation/screens/integration_settings_screen.dart';
import '../../presentation/screens/task_sharing_screen.dart';
import '../../presentation/screens/pin_setup_screen.dart';
import '../../presentation/screens/authentication_screen.dart';
import '../../presentation/widgets/theme_background_widget.dart';
import 'route_validator.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Application router
class AppRouter {
  static const String initialRoute = '/';
  static const String home = '/';
  static const String tasks = '/tasks';
  static const String settings = '/settings';

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
        route = calendar;
        break;
      case 2:
        route = analytics;
        break;
      case 3:
        route = settings;
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
  
  /// Add task route getter
  static String get addTask => '/add-task';
  
  /// Navigate to task detail
  static void navigateToTaskDetail(BuildContext context, String taskId) {
    Navigator.pushNamed(context, taskDetail, arguments: taskId);
  }

  /// Bottom navigation destinations
  static List<NavigationDestination> get bottomNavigationDestinations => [
    NavigationDestination(
      icon: Icon(PhosphorIcons.house()),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(PhosphorIcons.calendar()),
      label: 'Calendar',
    ),
    NavigationDestination(
      icon: Icon(PhosphorIcons.chartBar()),
      label: 'Analytics',
    ),
    NavigationDestination(
      icon: Icon(PhosphorIcons.gear()),
      label: 'Settings',
    ),
  ];

  /// Generate route
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const MainScaffold(),
          settings: settings,
        );
      case '/tasks':
        return MaterialPageRoute(
          builder: (_) => const ThemeBackgroundWidget(child: TasksPage()),
          settings: settings,
        );
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const ThemeBackgroundWidget(child: SettingsPage()),
          settings: settings,
        );
      case '/calendar':
        return MaterialPageRoute(
          builder: (_) => const ThemeBackgroundWidget(child: CalendarPage()),
          settings: settings,
        );
      case '/analytics':
        return MaterialPageRoute(
          builder: (_) => const ThemeBackgroundWidget(child: AnalyticsPage()),
          settings: settings,
        );
      case '/projects':
        return MaterialPageRoute(
          builder: (_) => const ThemeBackgroundWidget(child: ProjectsPage()),
          settings: settings,
        );
      case '/task-detail':
        try {
          final validationResult = RouteValidator.validateTaskId(settings.arguments);
          if (!validationResult.isValid) {
            return _createErrorRoute(validationResult.errorMessage!, settings);
          }
          
          final taskId = validationResult.validatedParams!['taskId'] as String;
          return MaterialPageRoute(
            builder: (_) => ThemeBackgroundWidget(
              child: TaskDetailPage(taskId: taskId),
            ),
            settings: settings,
          );
        } catch (e) {
          return _createErrorRoute('Invalid task detail parameters: $e', settings);
        }
      case '/voice-demo':
        return MaterialPageRoute(
          builder: (_) => const ThemeBackgroundWidget(child: VoiceDemoPage()),
          settings: settings,
        );
      case '/data-export':
        return MaterialPageRoute(
          builder: (_) => const ThemeBackgroundWidget(child: DataExportPage()),
          settings: settings,
        );
      case '/integration-settings':
        return MaterialPageRoute(
          builder: (_) => const ThemeBackgroundWidget(child: IntegrationSettingsScreen()),
          settings: settings,
        );
      case '/task-sharing':
        return MaterialPageRoute(
          builder: (_) => const ThemeBackgroundWidget(child: TaskSharingScreen()),
          settings: settings,
        );
      case '/help':
        return MaterialPageRoute(
          builder: (_) => const ThemeBackgroundWidget(child: HelpPage()),
          settings: settings,
        );
      case '/add-task':
        return MaterialPageRoute(
          builder: (_) => const ThemeBackgroundWidget(child: TasksPage()), // Will show add task form
          settings: settings,
        );
      case '/setup-pin':
        return MaterialPageRoute(
          builder: (_) => const PinSetupScreen(),
          settings: settings,
        );
      case '/change-pin':
        return MaterialPageRoute(
          builder: (_) => const PinSetupScreen(isChangingPin: true),
          settings: settings,
        );
      case '/auth':
        return MaterialPageRoute(
          builder: (_) => const AuthenticationScreen(),
          settings: settings,
        );
      case '/task-dependencies':
        return MaterialPageRoute(
          builder: (_) => const ThemeBackgroundWidget(child: TaskDependenciesPage()),
          settings: settings,
        );
      default:
        return _createNotFoundRoute(settings);
    }
  }

  /// Create error route with validation message
  static MaterialPageRoute _createErrorRoute(String errorMessage, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => ThemeBackgroundWidget(
        child: RouteErrorScreen(
          errorMessage: errorMessage,
          routeName: settings.name ?? 'Unknown',
        ),
      ),
      settings: settings,
    );
  }

  /// Create not found route
  static MaterialPageRoute _createNotFoundRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => ThemeBackgroundWidget(
        child: NotFoundScreen(
          requestedRoute: settings.name ?? 'Unknown',
        ),
      ),
      settings: settings,
    );
  }
}



/// Not found screen
class NotFoundScreen extends StatelessWidget {
  final String requestedRoute;
  
  const NotFoundScreen({
    super.key,
    this.requestedRoute = 'Unknown',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: StandardizedAppBar(title: 'Page Not Found',
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.warningCircle(),
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: TextStyle(
                  fontSize: TypographyConstants.textXL,
                  fontWeight: TypographyConstants.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'The requested page "$requestedRoute" could not be found.',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                ),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Route error screen for validation failures
class RouteErrorScreen extends StatelessWidget {
  final String errorMessage;
  final String routeName;
  
  const RouteErrorScreen({
    super.key,
    required this.errorMessage,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: StandardizedAppBar(title: 'Route Error',
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.warningCircle(),
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Invalid Route Parameters',
                style: TextStyle(
                  fontSize: TypographyConstants.textXL,
                  fontWeight: TypographyConstants.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Route: $routeName',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    ),
                    child: const Text('Go to Home'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

