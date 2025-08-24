import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/tag.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/domain/repositories/project_repository.dart';
import 'package:task_tracker_app/domain/repositories/tag_repository.dart';
import 'package:task_tracker_app/domain/repositories/task_repository.dart';
import 'package:task_tracker_app/services/data_export/data_export_models.dart';
import 'package:task_tracker_app/services/data_export/enhanced_export_service.dart';

import 'enhanced_export_service_test.mocks.dart';

@GenerateMocks([TaskRepository, ProjectRepository, TagRepository])
void main() {
  late EnhancedExportService exportService;
  late MockTaskRepository mockTaskRepository;
  late MockProjectRepository mockProjectRepository;
  late MockTagRepository mockTagRepository;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    mockProjectRepository = MockProjectRepository();
    mockTagRepository = MockTagRepository();
    
    exportService = EnhancedExportService(
      taskRepository: mockTaskRepository,
      projectRepository: mockProjectRepository,
      tagRepository: mockTagRepository,
    );
  });

  tearDown(() {
    exportService.dispose();
  });

  group('EnhancedExportService', () {
    group('Task Export', () {
      test('should export tasks to CSV format successfully', () async {
        // Arrange
        final tasks = [
          TaskModel(
            id: '1',
            title: 'Test Task 1',
            description: 'Description 1',
            priority: TaskPriority.high,
            createdAt: DateTime(2024, 1, 1),
            tags: const ['test', 'important'],
            isPinned: false,
          ),
          TaskModel(
            id: '2',
            title: 'Test Task 2',
            description: 'Description 2',
            priority: TaskPriority.medium,
            createdAt: DateTime(2024, 1, 2),
            completedAt: DateTime(2024, 1, 3),
            tags: const ['test'],
            isPinned: true,
          ),
        ];

        // Act
        final result = await exportService.exportTasks(
          tasks,
          format: ExportFormat.csv,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.filePath, isNotNull);
        expect(result.message, contains('Successfully exported'));
        expect(result.fileSize, greaterThan(0));
        expect(result.exportedAt, isNotNull);
      });

      test('should export tasks to JSON format successfully', () async {
        // Arrange
        final tasks = [
          TaskModel(
            id: '1',
            title: 'JSON Test Task',
            description: 'JSON Description',
            priority: TaskPriority.urgent,
            createdAt: DateTime(2024, 1, 1),
            dueDate: DateTime(2024, 1, 5),
            tags: const ['json', 'test'],
            isPinned: false,
          ),
        ];

        // Act
        final result = await exportService.exportTasks(
          tasks,
          format: ExportFormat.json,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.filePath, contains('.json'));
        expect(result.fileSize, greaterThan(0));
      });

      test('should export tasks to Excel format using ExcelExportService', () async {
        // Arrange
        final tasks = [
          TaskModel(
            id: '1',
            title: 'Excel Test Task',
            description: 'Excel Description',
            priority: TaskPriority.low,
            createdAt: DateTime(2024, 1, 1),
            tags: const ['excel', 'test'],
            isPinned: false,
          ),
        ];

        // Act
        final result = await exportService.exportTasks(
          tasks,
          format: ExportFormat.excel,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.filePath, contains('.xlsx'));
      });

      test('should export tasks to Kanban board format', () async {
        // Arrange
        final tasks = [
          TaskModel(
            id: '1',
            title: 'Pending Task',
            priority: TaskPriority.medium,
            createdAt: DateTime(2024, 1, 1),
            tags: const ['kanban'],
            isPinned: false,
          ),
          TaskModel(
            id: '2',
            title: 'In Progress Task',
            priority: TaskPriority.high,
            createdAt: DateTime(2024, 1, 2),
            tags: const ['kanban'],
            isPinned: false,
          ),
          TaskModel(
            id: '3',
            title: 'Completed Task',
            priority: TaskPriority.low,
            createdAt: DateTime(2024, 1, 3),
            completedAt: DateTime(2024, 1, 4),
            tags: const ['kanban'],
            isPinned: false,
          ),
        ];

        // Act
        final result = await exportService.exportTasks(
          tasks,
          format: ExportFormat.kanbanBoard,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.filePath, contains('kanban.json'));
        expect(result.metadata, containsPair('totalTasks', 3));
      });

      test('should export tasks as template package', () async {
        // Arrange
        final tasks = [
          TaskModel(
            id: '1',
            title: 'Template Task',
            description: 'Template Description',
            priority: TaskPriority.medium,
            createdAt: DateTime(2024, 1, 1),
            tags: const ['template'],
            isPinned: false,
            estimatedDuration: 120,
          ),
        ];

        // Act
        final result = await exportService.exportTasks(
          tasks,
          format: ExportFormat.templatePackage,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.filePath, contains('.taskytpl'));
      });

      test('should handle empty task list', () async {
        // Arrange
        final tasks = <TaskModel>[];

        // Act
        final result = await exportService.exportTasks(
          tasks,
          format: ExportFormat.csv,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.message, contains('Successfully exported 0 tasks'));
      });
    });

    group('Project Export', () {
      test('should export projects to CSV format successfully', () async {
        // Arrange
        final projects = [
          Project(
            id: '1',
            name: 'Test Project 1',
            description: 'Project Description 1',
            color: '#FF0000',
            createdAt: DateTime(2024, 1, 1),
            taskIds: const ['task1', 'task2'],
          ),
          Project(
            id: '2',
            name: 'Test Project 2',
            description: 'Project Description 2',
            color: '#00FF00',
            createdAt: DateTime(2024, 1, 2),
            taskIds: const ['task3'],
            isArchived: true,
          ),
        ];

        when(mockTaskRepository.getTaskById('task1')).thenAnswer((_) async => TaskModel(
          id: 'task1',
          title: 'Task 1',
          priority: TaskPriority.medium,
          createdAt: DateTime(2024, 1, 1),
          tags: const [],
          isPinned: false,
        ));

        when(mockTaskRepository.getTaskById('task2')).thenAnswer((_) async => TaskModel(
          id: 'task2',
          title: 'Task 2',
          priority: TaskPriority.high,
          createdAt: DateTime(2024, 1, 2),
          tags: const [],
          isPinned: false,
        ));

        when(mockTaskRepository.getTaskById('task3')).thenAnswer((_) async => TaskModel(
          id: 'task3',
          title: 'Task 3',
          priority: TaskPriority.low,
          createdAt: DateTime(2024, 1, 3),
          tags: const [],
          isPinned: false,
        ));

        // Act
        final result = await exportService.exportProjects(
          projects,
          format: ExportFormat.csv,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.filePath, contains('.csv'));
        expect(result.fileSize, greaterThan(0));
      });

      test('should export projects to Excel format', () async {
        // Arrange
        final projects = [
          Project(
            id: '1',
            name: 'Excel Project',
            description: 'Excel Project Description',
            color: '#0000FF',
            createdAt: DateTime(2024, 1, 1),
            taskIds: const [],
          ),
        ];

        // Act
        final result = await exportService.exportProjects(
          projects,
          format: ExportFormat.excel,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.filePath, contains('.xlsx'));
      });

      test('should export projects to Microsoft Project XML format', () async {
        // Arrange
        final projects = [
          Project(
            id: '1',
            name: 'MS Project Test',
            description: 'Microsoft Project Export Test',
            color: '#FF00FF',
            createdAt: DateTime(2024, 1, 1),
            taskIds: const ['task1'],
          ),
        ];

        when(mockTaskRepository.getTaskById('task1')).thenAnswer((_) async => TaskModel(
          id: 'task1',
          title: 'MS Project Task',
          priority: TaskPriority.medium,
          createdAt: DateTime(2024, 1, 1),
          dueDate: DateTime(2024, 1, 7),
          tags: const [],
          isPinned: false,
        ));

        // Act
        final result = await exportService.exportProjects(
          projects,
          format: ExportFormat.microsoftProjectXML,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.filePath, contains('.xml'));
      });
    });

    group('Full Backup', () {
      test('should create full backup successfully', () async {
        // Arrange
        final tasks = [
          TaskModel(
            id: '1',
            title: 'Backup Task',
            priority: TaskPriority.medium,
            createdAt: DateTime(2024, 1, 1),
            tags: const [],
            isPinned: false,
          ),
        ];

        final projects = [
          Project(
            id: '1',
            name: 'Backup Project',
            description: 'Project for backup',
            color: '#FFFF00',
            createdAt: DateTime(2024, 1, 1),
            taskIds: const ['1'],
          ),
        ];

        final tags = [
          Tag(
            id: '1',
            name: 'backup',
            color: '#CCCCCC',
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => tasks);
        when(mockProjectRepository.getAllProjects()).thenAnswer((_) async => projects);
        when(mockTagRepository.getAllTags()).thenAnswer((_) async => tags);

        // Act
        final result = await exportService.exportFullBackup();

        // Assert
        expect(result.success, isTrue);
        expect(result.filePath, contains('full_backup_'));
        expect(result.filePath, contains('.json'));
        expect(result.message, contains('Enhanced full backup created successfully'));
        expect(result.metadata, containsPair('taskCount', 1));
        expect(result.metadata, containsPair('projectCount', 1));
        expect(result.metadata, containsPair('tagCount', 1));
      });
    });

    group('Cloud Integration', () {
      test('should handle cloud upload error gracefully', () async {
        // Arrange
        final tasks = [
          TaskModel(
            id: '1',
            title: 'Cloud Task',
            priority: TaskPriority.medium,
            createdAt: DateTime(2024, 1, 1),
            tags: const [],
            isPinned: false,
          ),
        ];

        // Act
        final result = await exportService.exportAndUploadToCloud(
          format: ExportFormat.json,
          cloudProvider: 'invalid_provider',
          accessToken: 'fake_token',
          taskIds: ['1'],
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.message, contains('Unsupported cloud provider'));
      });
    });

    group('External Platform Import', () {
      test('should handle unsupported import source', () async {
        // Act
        final result = await exportService.importFromExternalPlatform(
          source: ImportSource.csv, // Using CSV as unsupported for this method
          credentials: {},
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.message, contains('Unsupported import source'));
      });

      test('should validate required credentials for Trello import', () async {
        // Act
        final result = await exportService.importFromExternalPlatform(
          source: ImportSource.trello,
          credentials: {}, // Missing required credentials
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.errors, isNotEmpty);
      });
    });

    group('File Format Support', () {
      test('should support all defined export formats', () async {
        // Act
        final supportedFormats = await exportService.getSupportedFormats();

        // Assert
        expect(supportedFormats, contains(ExportFormat.csv));
        expect(supportedFormats, contains(ExportFormat.json));
        expect(supportedFormats, contains(ExportFormat.excel));
        expect(supportedFormats, contains(ExportFormat.pdf));
        expect(supportedFormats, contains(ExportFormat.microsoftProjectXML));
        expect(supportedFormats, contains(ExportFormat.ganttChart));
        expect(supportedFormats, contains(ExportFormat.executiveReport));
        expect(supportedFormats, contains(ExportFormat.kanbanBoard));
        expect(supportedFormats, contains(ExportFormat.templatePackage));
      });

      test('should generate correct file extensions', () async {
        // Arrange
        final tasks = [
          TaskModel(
            id: '1',
            title: 'Extension Test',
            priority: TaskPriority.medium,
            createdAt: DateTime(2024, 1, 1),
            tags: const [],
            isPinned: false,
          ),
        ];

        // Test multiple formats
        final formats = [
          (ExportFormat.csv, '.csv'),
          (ExportFormat.json, '.json'),
          (ExportFormat.excel, '.xlsx'),
          (ExportFormat.kanbanBoard, 'kanban.json'),
          (ExportFormat.templatePackage, '.taskytpl'),
        ];

        for (final (format, expectedExtension) in formats) {
          // Act
          final result = await exportService.exportTasks(tasks, format: format);

          // Assert
          expect(result.success, isTrue);
          expect(result.filePath, contains(expectedExtension));
        }
      });
    });

    group('Error Handling', () {
      test('should handle export errors gracefully', () async {
        // Arrange - Create a scenario that would cause an error
        final tasks = <TaskModel>[];

        // Act - Try to export with invalid format option that might cause issues
        final result = await exportService.exportTasks(
          tasks,
          format: ExportFormat.csv,
          options: const ExportOptions(
            selectedFields: ['invalid_field'], // Invalid field that doesn't exist
          ),
        );

        // Assert - Should still succeed for empty list with basic CSV export
        expect(result.success, isTrue);
      });

      test('should handle repository errors during full backup', () async {
        // Arrange
        when(mockTaskRepository.getAllTasks()).thenThrow(Exception('Database error'));

        // Act
        final result = await exportService.exportFullBackup();

        // Assert
        expect(result.success, isFalse);
        expect(result.message, contains('Enhanced backup failed'));
      });
    });

    group('Utility Methods', () {
      test('should create export directory if it does not exist', () async {
        // Act
        final exportDir = await exportService.getExportDirectory();

        // Assert
        expect(exportDir, isNotNull);
        expect(exportDir, contains('enhanced_exports'));
      });

      test('should validate storage permissions', () async {
        // Act
        final hasPermission = await exportService.hasStoragePermission();
        final canRequest = await exportService.requestStoragePermission();

        // Assert - These should not throw exceptions
        expect(hasPermission, isA<bool>());
        expect(canRequest, isA<bool>());
      });

      test('should clean up old exports', () async {
        // Act & Assert - Should not throw exception
        await expectLater(
          exportService.cleanupOldExports(maxAgeInDays: 1),
          completes,
        );
      });

      test('should share files successfully', () async {
        // Arrange - Create a temporary file for sharing
        final tasks = [
          TaskModel(
            id: '1',
            title: 'Share Test',
            priority: TaskPriority.medium,
            createdAt: DateTime(2024, 1, 1),
            tags: const [],
            isPinned: false,
          ),
        ];

        final exportResult = await exportService.exportTasks(tasks, format: ExportFormat.json);

        // Act
        final shareResult = await exportService.shareFile(
          exportResult.filePath!,
          subject: 'Test Export',
        );

        // Assert - In test environment, this will likely return false due to no share intent handler
        expect(shareResult, isA<bool>());
      });

      test('should pick import files with correct extensions', () async {
        // Act
        final pickedFile = await exportService.pickImportFile(
          allowedExtensions: ['json', 'csv'],
        );

        // Assert - In test environment, this will return null
        expect(pickedFile, isNull);
      });
    });
  });

  group('Performance Tests', () {
    test('should handle large number of tasks efficiently', () async {
      // Arrange - Create a large number of tasks
      final tasks = List.generate(1000, (index) => TaskModel(
        id: 'task_$index',
        title: 'Task $index',
        description: 'Description for task $index',
        status: index % 2 == 0 ? TaskStatus.completed : TaskStatus.pending,
        priority: TaskPriority.values[index % TaskPriority.values.length],
        createdAt: DateTime(2024, 1, 1).add(Duration(days: index)),
        tags: ['tag_${index % 5}'],
        isPinned: index % 10 == 0,
      ));

      // Act
      final stopwatch = Stopwatch()..start();
      final result = await exportService.exportTasks(tasks, format: ExportFormat.csv);
      stopwatch.stop();

      // Assert
      expect(result.success, isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(5000), 
        reason: 'Export of 1000 tasks should complete within 5 seconds');
      expect(result.fileSize, greaterThan(50000), 
        reason: 'File should be reasonably large for 1000 tasks');
    });

    test('should handle large number of projects efficiently', () async {
      // Arrange - Create a large number of projects
      final projects = List.generate(100, (index) => Project(
        id: 'project_$index',
        name: 'Project $index',
        description: 'Description for project $index',
        color: '#${(index * 1000).toRadixString(16).padLeft(6, '0')}',
        createdAt: DateTime(2024, 1, 1).add(Duration(days: index)),
        taskIds: List.generate(10, (taskIndex) => 'task_${index}_$taskIndex'),
        isArchived: index % 20 == 0,
      ));

      // Mock task retrieval for each project
      for (final project in projects) {
        for (final taskId in project.taskIds) {
          when(mockTaskRepository.getTaskById(taskId)).thenAnswer((_) async => TaskModel(
            id: taskId,
            title: 'Task $taskId',
            priority: TaskPriority.medium,
            createdAt: DateTime.now(),
            tags: const [],
            isPinned: false,
          ));
        }
      }

      // Act
      final stopwatch = Stopwatch()..start();
      final result = await exportService.exportProjects(projects, format: ExportFormat.csv);
      stopwatch.stop();

      // Assert
      expect(result.success, isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(3000), 
        reason: 'Export of 100 projects should complete within 3 seconds');
    });
  });
}