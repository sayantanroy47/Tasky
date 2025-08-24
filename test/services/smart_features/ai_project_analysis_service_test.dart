import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/ai_suggestion.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/domain/repositories/task_repository.dart';
import 'package:task_tracker_app/domain/repositories/project_repository.dart';
import 'package:task_tracker_app/services/ai/composite_ai_task_parser.dart';
import 'package:task_tracker_app/services/smart_features/ai_project_analysis_service.dart';

@GenerateMocks([TaskRepository, ProjectRepository, CompositeAITaskParser])
import 'ai_project_analysis_service_test.mocks.dart';

void main() {
  group('AIProjectAnalysisService', () {
    late AIProjectAnalysisService service;
    late MockTaskRepository mockTaskRepository;
    late MockProjectRepository mockProjectRepository;
    late MockCompositeAITaskParser mockAiParser;

    setUp(() {
      mockTaskRepository = MockTaskRepository();
      mockProjectRepository = MockProjectRepository();
      mockAiParser = MockCompositeAITaskParser();
      
      service = AIProjectAnalysisService(
        taskRepository: mockTaskRepository,
        projectRepository: mockProjectRepository,
        aiParser: mockAiParser,
      );
    });

    group('analyzeProject', () {
      test('should analyze project and return AI suggestions', () async {
        // Arrange
        const projectId = 'test-project-id';
        final project = Project.create(name: 'Test Project');
        final tasks = [
          TaskModel.create(
            title: 'Task 1',
            projectId: projectId,
            priority: TaskPriority.high,
            dueDate: DateTime.now().add(const Duration(days: -1)), // Overdue
          ),
          TaskModel.create(
            title: 'Task 2',
            projectId: projectId,
            priority: TaskPriority.medium,
          ),
        ];

        when(mockProjectRepository.getProjectById(projectId))
            .thenAnswer((_) async => project.copyWith(id: projectId));
        when(mockTaskRepository.getTasksByProject(projectId))
            .thenAnswer((_) async => tasks);

        // Act
        final result = await service.analyzeProject(projectId);

        // Assert
        expect(result, isA<ProjectAISuggestions>());
        expect(result.projectId, equals(projectId));
        expect(result.suggestions, isNotEmpty);
        expect(result.overallConfidence, greaterThan(0));
        
        verify(mockProjectRepository.getProjectById(projectId)).called(1);
        verify(mockTaskRepository.getTasksByProject(projectId)).called(1);
      });

      test('should throw ArgumentError for non-existent project', () async {
        // Arrange
        const projectId = 'non-existent-project';
        when(mockProjectRepository.getProjectById(projectId))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => service.analyzeProject(projectId),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should generate task prioritization suggestions for overdue tasks', () async {
        // Arrange
        const projectId = 'test-project-id';
        final project = Project.create(name: 'Test Project');
        final tasks = [
          TaskModel.create(
            title: 'Overdue Task 1',
            projectId: projectId,
            priority: TaskPriority.low,
            dueDate: DateTime.now().subtract(const Duration(days: 2)),
          ),
          TaskModel.create(
            title: 'Overdue Task 2',
            projectId: projectId,
            priority: TaskPriority.medium,
            dueDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
          TaskModel.create(
            title: 'High Priority Task',
            projectId: projectId,
            priority: TaskPriority.high,
          ),
        ];

        when(mockProjectRepository.getProjectById(projectId))
            .thenAnswer((_) async => project.copyWith(id: projectId));
        when(mockTaskRepository.getTasksByProject(projectId))
            .thenAnswer((_) async => tasks);

        // Act
        final result = await service.analyzeProject(projectId);

        // Assert
        final prioritizationSuggestions = result.suggestions
            .where((s) => s.type == AISuggestionType.taskPrioritization)
            .toList();
        expect(prioritizationSuggestions, isNotEmpty);
        
        final overdueSuggestion = prioritizationSuggestions.firstWhere(
          (s) => s.title.contains('Overdue'),
          orElse: () => throw TestFailure('No overdue task suggestion found'),
        );
        expect(overdueSuggestion.priority, equals(SuggestionPriority.high));
        expect(overdueSuggestion.relatedTaskIds, hasLength(2)); // Two overdue tasks
      });

      test('should generate schedule optimization suggestions for heavy workload', () async {
        // Arrange
        const projectId = 'test-project-id';
        final project = Project.create(name: 'Test Project');
        final now = DateTime.now();
        final nextWeek = now.add(const Duration(days: 7));
        
        // Create 6 tasks due in the next 7 days (heavy workload)
        final tasks = List.generate(6, (index) => 
          TaskModel.create(
            title: 'Task ${index + 1}',
            projectId: projectId,
            dueDate: now.add(Duration(days: index + 1)),
          ),
        );

        when(mockProjectRepository.getProjectById(projectId))
            .thenAnswer((_) async => project.copyWith(id: projectId));
        when(mockTaskRepository.getTasksByProject(projectId))
            .thenAnswer((_) async => tasks);

        // Act
        final result = await service.analyzeProject(projectId);

        // Assert
        final scheduleSuggestions = result.suggestions
            .where((s) => s.type == AISuggestionType.scheduleOptimization)
            .toList();
        expect(scheduleSuggestions, isNotEmpty);
        
        final workloadSuggestion = scheduleSuggestions.firstWhere(
          (s) => s.title.contains('Heavy Workload'),
          orElse: () => throw TestFailure('No heavy workload suggestion found'),
        );
        expect(workloadSuggestion.priority, equals(SuggestionPriority.medium));
      });

      test('should generate bottleneck suggestions for too many in-progress tasks', () async {
        // Arrange
        const projectId = 'test-project-id';
        final project = Project.create(name: 'Test Project');
        final tasks = [
          ...List.generate(4, (index) => 
            TaskModel.create(
              title: 'In Progress Task ${index + 1}',
              projectId: projectId,
            ),
          ),
          TaskModel.create(
            title: 'Pending Task',
            projectId: projectId,
          ), // Only 1 pending task
        ];

        when(mockProjectRepository.getProjectById(projectId))
            .thenAnswer((_) async => project.copyWith(id: projectId));
        when(mockTaskRepository.getTasksByProject(projectId))
            .thenAnswer((_) async => tasks);

        // Act
        final result = await service.analyzeProject(projectId);

        // Assert
        final bottleneckSuggestions = result.suggestions
            .where((s) => s.type == AISuggestionType.bottleneckIdentification)
            .toList();
        expect(bottleneckSuggestions, isNotEmpty);
        
        final wipSuggestion = bottleneckSuggestions.firstWhere(
          (s) => s.title.contains('In Progress'),
          orElse: () => throw TestFailure('No WIP suggestion found'),
        );
        expect(wipSuggestion.priority, equals(SuggestionPriority.high));
        expect(wipSuggestion.recommendations, contains(predicate<String>(
          (rec) => rec.toLowerCase().contains('wip'),
        )));
      });

      test('should calculate overall confidence based on data quality', () async {
        // Arrange
        const projectId = 'test-project-id';
        final project = Project.create(name: 'Test Project');
        final tasks = [
          TaskModel.create(
            title: 'Well-defined Task',
            description: 'This task has a detailed description',
            projectId: projectId,
            estimatedDuration: 60,
            dueDate: DateTime.now().add(const Duration(days: 3)),
          ),
          TaskModel.create(
            title: 'Another Task',
            description: 'Another detailed task',
            projectId: projectId,
            estimatedDuration: 120,
            dueDate: DateTime.now().add(const Duration(days: 5)),
          ),
        ];

        when(mockProjectRepository.getProjectById(projectId))
            .thenAnswer((_) async => project.copyWith(id: projectId));
        when(mockTaskRepository.getTasksByProject(projectId))
            .thenAnswer((_) async => tasks);

        // Act
        final result = await service.analyzeProject(projectId);

        // Assert
        expect(result.overallConfidence, greaterThan(50.0));
        expect(result.overallConfidence, lessThanOrEqualTo(100.0));
      });

      test('should generate key insights based on project analysis', () async {
        // Arrange
        const projectId = 'test-project-id';
        final project = Project.create(name: 'Test Project');
        final tasks = [
          TaskModel.create(
            title: 'Completed Task 1',
            projectId: projectId,
          ),
          TaskModel.create(
            title: 'Completed Task 2',
            projectId: projectId,
          ),
          TaskModel.create(
            title: 'Pending Task',
            projectId: projectId,
            tags: const ['development'],
          ),
        ];

        when(mockProjectRepository.getProjectById(projectId))
            .thenAnswer((_) async => project.copyWith(id: projectId));
        when(mockTaskRepository.getTasksByProject(projectId))
            .thenAnswer((_) async => tasks);

        // Act
        final result = await service.analyzeProject(projectId);

        // Assert
        expect(result.keyInsights, isNotEmpty);
        expect(result.keyInsights.any((insight) => 
          insight.contains('completion rate') || 
          insight.contains('track')
        ), isTrue);
      });
    });

    group('edge cases', () {
      test('should handle empty project gracefully', () async {
        // Arrange
        const projectId = 'empty-project';
        final project = Project.create(name: 'Empty Project');
        final tasks = <TaskModel>[];

        when(mockProjectRepository.getProjectById(projectId))
            .thenAnswer((_) async => project.copyWith(id: projectId));
        when(mockTaskRepository.getTasksByProject(projectId))
            .thenAnswer((_) async => tasks);

        // Act
        final result = await service.analyzeProject(projectId);

        // Assert
        expect(result.suggestions, isEmpty);
        expect(result.overallConfidence, equals(0.0));
        expect(result.keyInsights, isEmpty);
      });

      test('should handle tasks without estimates gracefully', () async {
        // Arrange
        const projectId = 'no-estimates-project';
        final project = Project.create(name: 'No Estimates Project');
        final tasks = [
          TaskModel.create(
            title: 'Task without estimate 1',
            projectId: projectId,
          ),
          TaskModel.create(
            title: 'Task without estimate 2',
            projectId: projectId,
          ),
        ];

        when(mockProjectRepository.getProjectById(projectId))
            .thenAnswer((_) async => project.copyWith(id: projectId));
        when(mockTaskRepository.getTasksByProject(projectId))
            .thenAnswer((_) async => tasks);

        // Act
        final result = await service.analyzeProject(projectId);

        // Assert
        expect(result, isA<ProjectAISuggestions>());
        // Should not crash and should still provide some suggestions
        expect(result.suggestions.any((s) => 
          s.type == AISuggestionType.workflowImprovement
        ), isTrue);
      });

      test('should generate resource allocation suggestions for unrealistic deadlines', () async {
        // Arrange
        const projectId = 'tight-deadline-project';
        final project = Project.create(
          name: 'Tight Deadline Project',
          deadline: DateTime.now().add(const Duration(days: 1)), // Very tight deadline
        );
        final tasks = List.generate(10, (index) =>
          TaskModel.create(
            title: 'Task ${index + 1}',
            projectId: projectId,
            estimatedDuration: 120, // 2 hours each = 20 hours total
          ),
        );

        when(mockProjectRepository.getProjectById(projectId))
            .thenAnswer((_) async => project.copyWith(id: projectId));
        when(mockTaskRepository.getTasksByProject(projectId))
            .thenAnswer((_) async => tasks);

        // Act
        final result = await service.analyzeProject(projectId);

        // Assert
        final resourceSuggestions = result.suggestions
            .where((s) => s.type == AISuggestionType.resourceAllocation)
            .toList();
        expect(resourceSuggestions, isNotEmpty);
        
        final timelineSuggestion = resourceSuggestions.firstWhere(
          (s) => s.title.contains('Insufficient Time') || s.title.contains('Workload'),
          orElse: () => throw TestFailure('No timeline suggestion found'),
        );
        expect(timelineSuggestion.priority, equals(SuggestionPriority.urgent));
      });
    });
  });
}