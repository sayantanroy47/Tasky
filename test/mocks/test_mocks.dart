import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/domain/repositories/task_repository.dart';
import 'package:task_tracker_app/domain/repositories/project_repository.dart';
import 'package:task_tracker_app/services/notification/notification_service.dart';
import 'package:task_tracker_app/services/analytics/analytics_service.dart';
import 'package:task_tracker_app/services/performance_service.dart';

/// Mock annotations for performance test dependencies
@GenerateMocks([
  TaskRepository,
  ProjectRepository,
  NotificationService,
  AnalyticsService,
  PerformanceService,
])
void main() {}