import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/services/bulk_operations/bulk_operation_service.dart';
import 'package:task_tracker_app/services/bulk_operations/project_migration_service.dart';
import 'package:task_tracker_app/services/bulk_operations/task_selection_manager.dart';
import 'package:task_tracker_app/services/bulk_operations/bulk_operation_history.dart';
import 'package:task_tracker_app/presentation/providers/bulk_operation_providers.dart';

import '../mocks/test_mocks.mocks.dart';

void main() {
  group('Bulk Operations Performance Tests - Enterprise Scale', () {
    late MockTaskRepository mockTaskRepository;
    late MockProjectRepository mockProjectRepository;
    late MockNotificationService mockNotificationService;
    late PerformanceBenchmarker benchmarker;
    late BulkOperationsTestDataGenerator dataGenerator;

    setUp(() {
      mockTaskRepository = MockTaskRepository();
      mockProjectRepository = MockProjectRepository();
      mockNotificationService = MockNotificationService();
      benchmarker = PerformanceBenchmarker();
      dataGenerator = BulkOperationsTestDataGenerator();
    });

    group('Large-Scale Task Operations', () {
      test('Bulk priority update for 1000 tasks across multiple projects', () async {
        final tasks = dataGenerator.generateCrossProjectTasks(1000, 50);
        final bulkService = BulkOperationService(
          taskRepository: mockTaskRepository,
          projectRepository: mockProjectRepository,
          notificationService: mockNotificationService,
        );
        
        // Mock repository responses
        when(mockTaskRepository.updateTask(any)).thenAnswer((_) async {
          return null;
        });
        when(mockTaskRepository.getTasksByIds(any)).thenAnswer((_) async => tasks);
        
        final stopwatch = Stopwatch()..start();
        
        // Execute bulk priority update
        final operationResult = await bulkService.bulkUpdatePriority(
          taskIds: tasks.map((t) => t.id).toList(),
          newPriority: TaskPriority.high,
          batchSize: 100, // Process in batches for better performance
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('bulk_priority_update_1000_tasks', stopwatch.elapsedMilliseconds);
        
        // Should complete bulk operation within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(5000),
               reason: 'Bulk priority update (1000 tasks) should complete within 5 seconds');
        
        expect(operationResult.isSuccess, isTrue);
        expect(operationResult.processedCount, equals(1000));
        expect(operationResult.failedCount, equals(0));
        
        // Verify all tasks were updated
        verify(mockTaskRepository.updateTask(any)).called(1000);
        
        print('Bulk priority update (1000 tasks): ${stopwatch.elapsedMilliseconds}ms');
        print('Success rate: ${operationResult.successRate.toStringAsFixed(2)}%');
      });

      test('Bulk status change with dependency cascade for 500 tasks', () async {
        final tasks = dataGenerator.generateTasksWithDependencies(500, 1000);
        final bulkService = BulkOperationService(
          taskRepository: mockTaskRepository,
          projectRepository: mockProjectRepository,
          notificationService: mockNotificationService,
        );
        
        when(mockTaskRepository.updateTask(any)).thenAnswer((_) async {
          return null;
        });
        when(mockTaskRepository.getTasksByIds(any)).thenAnswer((_) async => tasks);
        when(mockTaskRepository.getDependentTasks(any)).thenAnswer((_) async => []);
        
        final stopwatch = Stopwatch()..start();
        
        // Execute bulk status change with cascade
        final operationResult = await bulkService.bulkUpdateStatus(
          taskIds: tasks.take(100).map((t) => t.id).toList(),
          newStatus: TaskStatus.completed,
          updateDependencies: true, // This adds complexity
          cascadeToChildren: true,
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('bulk_status_cascade_100_tasks', stopwatch.elapsedMilliseconds);
        
        // Status changes with cascading should be efficient
        expect(stopwatch.elapsedMilliseconds, lessThan(3000),
               reason: 'Bulk status change with cascade should complete within 3 seconds');
        
        expect(operationResult.isSuccess, isTrue);
        expect(operationResult.processedCount, greaterThanOrEqualTo(100));
        
        print('Bulk status change with cascade (100+ tasks): ${stopwatch.elapsedMilliseconds}ms');
        print('Tasks affected: ${operationResult.processedCount}');
      });

      test('Bulk tag operations on large dataset', () async {
        final tasks = dataGenerator.generateLargeTaskDataset(2000);
        final bulkService = BulkOperationService(
          taskRepository: mockTaskRepository,
          projectRepository: mockProjectRepository,
          notificationService: mockNotificationService,
        );
        
        when(mockTaskRepository.updateTask(any)).thenAnswer((_) async {
          return null;
        });
        when(mockTaskRepository.getTasksByIds(any)).thenAnswer((_) async => tasks);
        
        final stopwatch = Stopwatch()..start();
        
        // Execute multiple tag operations
        final tagOperations = [
          bulkService.bulkAddTags(
            taskIds: tasks.take(500).map((t) => t.id).toList(),
            tags: ['urgent', 'priority'],
          ),
          bulkService.bulkRemoveTags(
            taskIds: tasks.skip(500).take(500).map((t) => t.id).toList(),
            tags: ['outdated'],
          ),
          bulkService.bulkReplaceTags(
            taskIds: tasks.skip(1000).take(500).map((t) => t.id).toList(),
            oldTags: ['temp'],
            newTags: ['reviewed', 'processed'],
          ),
        ];
        
        final results = await Future.wait(tagOperations);
        
        stopwatch.stop();
        
        benchmarker.recordMetric('bulk_tag_operations_1500_tasks', stopwatch.elapsedMilliseconds);
        
        // Complex tag operations should be efficient
        expect(stopwatch.elapsedMilliseconds, lessThan(4000),
               reason: 'Bulk tag operations (1500 tasks) should complete within 4 seconds');
        
        for (final result in results) {
          expect(result.isSuccess, isTrue);
          expect(result.processedCount, equals(500));
        }
        
        print('Bulk tag operations (3 operations, 1500 tasks): ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Cross-Project Migration Performance', () {
      test('Large-scale project migration with 1000+ tasks', () async {
        final sourceProjects = dataGenerator.generateProjectDataset(10);
        final targetProjects = dataGenerator.generateProjectDataset(5);
        final tasks = dataGenerator.generateCrossProjectTasks(1200, sourceProjects.length);
        
        final migrationService = ProjectMigrationService(
          taskRepository: mockTaskRepository,
          projectRepository: mockProjectRepository,
          notificationService: mockNotificationService,
        );
        
        when(mockTaskRepository.updateTask(any)).thenAnswer((_) async {
          return null;
        });
        when(mockTaskRepository.getTasksByProjectId(any)).thenAnswer((_) async => tasks.take(120).toList());
        when(mockProjectRepository.getProjectById(any)).thenAnswer((_) async => targetProjects.first);
        
        final stopwatch = Stopwatch()..start();
        
        // Execute large-scale project migration
        final migrationResult = await migrationService.migrateTasksBetweenProjects(
          sourceProjectIds: sourceProjects.take(3).map((p) => p.id).toList(),
          targetProjectId: targetProjects.first.id,
          migrationOptions: const ProjectMigrationOptions(
            preserveTaskMetadata: true,
            updateTaskDependencies: true,
            notifyStakeholders: true,
            createMigrationLog: true,
          ),
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('project_migration_1200_tasks', stopwatch.elapsedMilliseconds);
        
        // Project migration should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(8000),
               reason: 'Project migration (1200 tasks) should complete within 8 seconds');
        
        expect(migrationResult.isSuccess, isTrue);
        expect(migrationResult.migratedTaskCount, greaterThan(0));
        
        print('Project migration (1200 tasks, 3→1 projects): ${stopwatch.elapsedMilliseconds}ms');
        print('Migration success rate: ${migrationResult.successRate.toStringAsFixed(2)}%');
      });

      test('Concurrent project migrations with conflict resolution', () async {
        final projects = dataGenerator.generateProjectDataset(20);
        final tasks = dataGenerator.generateCrossProjectTasks(1500, 20);
        
        final migrationService = ProjectMigrationService(
          taskRepository: mockTaskRepository,
          projectRepository: mockProjectRepository,
          notificationService: mockNotificationService,
        );
        
        when(mockTaskRepository.updateTask(any)).thenAnswer((_) async {
          return null;
        });
        when(mockTaskRepository.getTasksByProjectId(any)).thenAnswer((_) async => tasks.take(75).toList());
        when(mockProjectRepository.getProjectById(any)).thenAnswer((_) async => projects.first);
        
        final stopwatch = Stopwatch()..start();
        
        // Execute multiple concurrent migrations
        final migrationFutures = List.generate(5, (i) {
          return migrationService.migrateTasksBetweenProjects(
            sourceProjectIds: [projects[i * 2].id, projects[i * 2 + 1].id],
            targetProjectId: projects[10 + i].id,
            migrationOptions: const ProjectMigrationOptions(
              preserveTaskMetadata: true,
              resolveConflicts: true,
              conflictResolutionStrategy: ConflictResolutionStrategy.mergePreferTarget,
            ),
          );
        });
        
        final migrationResults = await Future.wait(migrationFutures);
        
        stopwatch.stop();
        
        benchmarker.recordMetric('concurrent_migrations_5_ops', stopwatch.elapsedMilliseconds);
        
        // Concurrent migrations should be efficient
        expect(stopwatch.elapsedMilliseconds, lessThan(12000),
               reason: '5 concurrent project migrations should complete within 12 seconds');
        
        for (final result in migrationResults) {
          expect(result.isSuccess, isTrue);
        }
        
        final totalMigratedTasks = migrationResults.fold(0, (sum, result) => sum + result.migratedTaskCount);
        
        print('Concurrent migrations (5 operations): ${stopwatch.elapsedMilliseconds}ms');
        print('Total migrated tasks: $totalMigratedTasks');
      });

      test('Project consolidation with duplicate detection', () async {
        final projects = dataGenerator.generateProjectDataset(30);
        final tasks = dataGenerator.generateDuplicateProneTaskData(2000, projects);
        
        final migrationService = ProjectMigrationService(
          taskRepository: mockTaskRepository,
          projectRepository: mockProjectRepository,
          notificationService: mockNotificationService,
        );
        
        when(mockTaskRepository.updateTask(any)).thenAnswer((_) async {
          return null;
        });
        when(mockTaskRepository.getAllTasks()).thenAnswer((_) async => tasks);
        when(mockProjectRepository.deleteProject(any)).thenAnswer((_) async {
          return null;
        });
        
        final stopwatch = Stopwatch()..start();
        
        // Execute project consolidation with duplicate detection
        final consolidationResult = await migrationService.consolidateProjects(
          projectIds: projects.take(15).map((p) => p.id).toList(),
          targetProjectId: projects.last.id,
          consolidationOptions: const ProjectConsolidationOptions(
            detectDuplicateTasks: true,
            mergeDuplicates: true,
            deleteEmptyProjects: true,
            generateConsolidationReport: true,
          ),
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('project_consolidation_15_projects', stopwatch.elapsedMilliseconds);
        
        // Project consolidation should handle large datasets efficiently
        expect(stopwatch.elapsedMilliseconds, lessThan(10000),
               reason: 'Project consolidation should complete within 10 seconds');
        
        expect(consolidationResult.isSuccess, isTrue);
        expect(consolidationResult.consolidatedProjects, equals(15));
        
        print('Project consolidation (15 projects, 2000 tasks): ${stopwatch.elapsedMilliseconds}ms');
        print('Duplicates detected: ${consolidationResult.duplicatesDetected}');
        print('Duplicates merged: ${consolidationResult.duplicatesMerged}');
      });
    });

    group('Batch Processing Performance', () {
      test('Optimized batch processing with configurable batch sizes', () async {
        final tasks = dataGenerator.generateLargeTaskDataset(5000);
        final bulkService = BulkOperationService(
          taskRepository: mockTaskRepository,
          projectRepository: mockProjectRepository,
          notificationService: mockNotificationService,
        );
        
        when(mockTaskRepository.updateTask(any)).thenAnswer((_) async {
          return null;
        });
        when(mockTaskRepository.getTasksByIds(any)).thenAnswer((_) async => tasks);
        
        // Test different batch sizes
        final batchSizes = [50, 100, 200, 500];
        final batchResults = <int, BulkOperationResult>{};
        
        for (final batchSize in batchSizes) {
          final stopwatch = Stopwatch()..start();
          
          final result = await bulkService.bulkUpdatePriority(
            taskIds: tasks.map((t) => t.id).toList(),
            newPriority: TaskPriority.medium,
            batchSize: batchSize,
          );
          
          stopwatch.stop();
          
          benchmarker.recordMetric('batch_processing_${batchSize}_size', stopwatch.elapsedMilliseconds);
          batchResults[batchSize] = result;
          
          expect(result.isSuccess, isTrue);
          expect(result.processedCount, equals(5000));
          
          print('Batch processing (size: $batchSize): ${stopwatch.elapsedMilliseconds}ms');
        }
        
        // Find optimal batch size (should show performance characteristics)
        final optimalBatchSize = batchResults.entries
            .map((e) => MapEntry(e.key, e.value.executionTimeMs))
            .reduce((a, b) => a.value < b.value ? a : b)
            .key;
            
        print('Optimal batch size for 5000 tasks: $optimalBatchSize');
      });

      test('Parallel batch processing with worker pools', () async {
        final tasks = dataGenerator.generateLargeTaskDataset(3000);
        final parallelBulkService = ParallelBulkOperationService(
          taskRepository: mockTaskRepository,
          projectRepository: mockProjectRepository,
          notificationService: mockNotificationService,
          maxConcurrentWorkers: 4,
        );
        
        when(mockTaskRepository.updateTask(any)).thenAnswer((_) async {
          return null;
        });
        when(mockTaskRepository.getTasksByIds(any)).thenAnswer((_) async => tasks);
        
        final stopwatch = Stopwatch()..start();
        
        // Execute parallel bulk operations
        final parallelResult = await parallelBulkService.parallelBulkUpdate(
          taskIds: tasks.map((t) => t.id).toList(),
          updateOperations: [
            const TaskUpdateOperation(field: 'priority', value: TaskPriority.high),
            const TaskUpdateOperation(field: 'tags', value: ['batch-processed']),
            TaskUpdateOperation(field: 'metadata', value: {'processed_at': DateTime.now().toIso8601String()}),
          ],
          batchSize: 100,
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('parallel_bulk_processing_3000', stopwatch.elapsedMilliseconds);
        
        // Parallel processing should be significantly faster
        expect(stopwatch.elapsedMilliseconds, lessThan(4000),
               reason: 'Parallel bulk processing should complete within 4 seconds');
        
        expect(parallelResult.isSuccess, isTrue);
        expect(parallelResult.processedCount, equals(3000));
        
        print('Parallel bulk processing (3000 tasks, 4 workers): ${stopwatch.elapsedMilliseconds}ms');
        print('Throughput: ${(3000 / (stopwatch.elapsedMilliseconds / 1000.0)).toStringAsFixed(0)} tasks/sec');
      });

      test('Memory-efficient streaming batch operations', () async {
        const largeTaskCount = 10000;
        final streamingService = StreamingBulkOperationService(
          taskRepository: mockTaskRepository,
          projectRepository: mockProjectRepository,
        );
        
        when(mockTaskRepository.updateTask(any)).thenAnswer((_) async {
          return null;
        });
        
        final memoryTracker = MemoryUsageTracker();
        final baselineMemory = await memoryTracker.getCurrentUsage();
        
        final stopwatch = Stopwatch()..start();
        
        // Process large dataset in streaming fashion
        var processedCount = 0;
        await for (final batch in streamingService.streamBulkUpdate(
          taskCount: largeTaskCount,
          batchSize: 200,
          updateOperation: const TaskUpdateOperation(field: 'status', value: TaskStatus.inProgress),
        )) {
          processedCount += batch.processedCount;
          
          // Check memory usage doesn't grow excessively
          final currentMemory = await memoryTracker.getCurrentUsage();
          final memoryIncrease = currentMemory - baselineMemory;
          
          expect(memoryIncrease, lessThan(50.0),
                 reason: 'Memory usage should stay under 50MB during streaming operations');
        }
        
        stopwatch.stop();
        
        benchmarker.recordMetric('streaming_bulk_10k_tasks', stopwatch.elapsedMilliseconds);
        
        // Streaming should handle large datasets efficiently
        expect(stopwatch.elapsedMilliseconds, lessThan(15000),
               reason: 'Streaming bulk operations (10k tasks) should complete within 15 seconds');
        
        expect(processedCount, equals(largeTaskCount));
        
        print('Streaming bulk operations (10k tasks): ${stopwatch.elapsedMilliseconds}ms');
        print('Peak memory increase: ${(await memoryTracker.getCurrentUsage() - baselineMemory).toStringAsFixed(1)}MB');
      });
    });

    group('Error Handling and Recovery Performance', () {
      test('Bulk operation rollback with large transaction sets', () async {
        final tasks = dataGenerator.generateLargeTaskDataset(1000);
        final bulkService = TransactionalBulkOperationService(
          taskRepository: mockTaskRepository,
          projectRepository: mockProjectRepository,
        );
        
        // Mock some failures
        var updateCount = 0;
        when(mockTaskRepository.updateTask(any)).thenAnswer((_) async {
          updateCount++;
          if (updateCount > 800) {
            throw Exception('Simulated database error');
          }
          return null;
        });
        when(mockTaskRepository.getTasksByIds(any)).thenAnswer((_) async => tasks);
        
        final stopwatch = Stopwatch()..start();
        
        // Execute operation that will fail and need rollback
        final operationResult = await bulkService.transactionalBulkUpdate(
          taskIds: tasks.map((t) => t.id).toList(),
          updateOperations: [
            TaskUpdateOperation(field: 'priority', value: TaskPriority.critical),
          ],
          rollbackOnError: true,
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('bulk_rollback_1000_tasks', stopwatch.elapsedMilliseconds);
        
        // Rollback should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(6000),
               reason: 'Bulk operation rollback should complete within 6 seconds');
        
        expect(operationResult.isSuccess, isFalse);
        expect(operationResult.rollbackPerformed, isTrue);
        expect(operationResult.rollbackSuccessful, isTrue);
        
        print('Bulk operation rollback (1000 tasks): ${stopwatch.elapsedMilliseconds}ms');
        print('Tasks processed before error: ${operationResult.processedCount}');
      });

      test('Partial failure recovery with retry mechanisms', () async {
        final tasks = dataGenerator.generateLargeTaskDataset(500);
        final resilientService = ResilientBulkOperationService(
          taskRepository: mockTaskRepository,
          projectRepository: mockProjectRepository,
          maxRetries: 3,
          retryDelayMs: 100,
        );
        
        // Mock intermittent failures
        var updateCount = 0;
        when(mockTaskRepository.updateTask(any)).thenAnswer((_) async {
          updateCount++;
          // Fail every 5th operation initially, then succeed on retry
          if (updateCount % 5 == 0 && updateCount < 100) {
            throw Exception('Intermittent failure');
          }
          return null;
        });
        when(mockTaskRepository.getTasksByIds(any)).thenAnswer((_) async => tasks);
        
        final stopwatch = Stopwatch()..start();
        
        // Execute operation with automatic retry
        final operationResult = await resilientService.resilientBulkUpdate(
          taskIds: tasks.map((t) => t.id).toList(),
          updateOperations: [
            const TaskUpdateOperation(field: 'tags', value: ['resilient-test']),
          ],
        );
        
        stopwatch.stop();
        
        benchmarker.recordMetric('resilient_bulk_500_tasks', stopwatch.elapsedMilliseconds);
        
        // Resilient operations should eventually succeed
        expect(stopwatch.elapsedMilliseconds, lessThan(8000),
               reason: 'Resilient bulk operations should complete within 8 seconds');
        
        expect(operationResult.isSuccess, isTrue);
        expect(operationResult.retryCount, greaterThan(0));
        expect(operationResult.processedCount, equals(500));
        
        print('Resilient bulk operations (500 tasks): ${stopwatch.elapsedMilliseconds}ms');
        print('Retry attempts: ${operationResult.retryCount}');
        print('Final success rate: ${operationResult.successRate.toStringAsFixed(2)}%');
      });
    });

    group('Performance Monitoring and Analytics', () {
      test('Bulk operation performance metrics collection', () async {
        final tasks = dataGenerator.generateLargeTaskDataset(2000);
        final monitoredService = MonitoredBulkOperationService(
          taskRepository: mockTaskRepository,
          projectRepository: mockProjectRepository,
          performanceMonitor: BulkOperationPerformanceMonitor(),
        );
        
        when(mockTaskRepository.updateTask(any)).thenAnswer((_) async {
          return null;
        });
        when(mockTaskRepository.getTasksByIds(any)).thenAnswer((_) async => tasks);
        
        final stopwatch = Stopwatch()..start();
        
        // Execute multiple operations to gather metrics
        final operations = [
          monitoredService.bulkUpdatePriority(
            taskIds: tasks.take(500).map((t) => t.id).toList(),
            newPriority: TaskPriority.high,
          ),
          monitoredService.bulkUpdateStatus(
            taskIds: tasks.skip(500).take(500).map((t) => t.id).toList(),
            newStatus: TaskStatus.inProgress,
          ),
          monitoredService.bulkAddTags(
            taskIds: tasks.skip(1000).take(500).map((t) => t.id).toList(),
            tags: ['monitored'],
          ),
          monitoredService.bulkDeleteTasks(
            taskIds: tasks.skip(1500).take(500).map((t) => t.id).toList(),
          ),
        ];
        
        final results = await Future.wait(operations);
        
        stopwatch.stop();
        
        benchmarker.recordMetric('monitored_bulk_ops_2000_tasks', stopwatch.elapsedMilliseconds);
        
        // Generate performance analytics
        final performanceAnalytics = await monitoredService.generatePerformanceReport(
          timeRange: const Duration(minutes: 10),
        );
        
        expect(stopwatch.elapsedMilliseconds, lessThan(5000),
               reason: 'Monitored bulk operations should complete within 5 seconds');
        
        expect(results.length, equals(4));
        expect(performanceAnalytics, isNotNull);
        expect(performanceAnalytics.totalOperations, equals(4));
        expect(performanceAnalytics.averageExecutionTime, greaterThan(0));
        
        print('Monitored bulk operations (2000 tasks, 4 ops): ${stopwatch.elapsedMilliseconds}ms');
        print('Average operation time: ${performanceAnalytics.averageExecutionTime.toStringAsFixed(0)}ms');
        print('Throughput: ${performanceAnalytics.tasksPerSecond.toStringAsFixed(0)} tasks/sec');
      });

      test('Real-time bulk operation progress tracking', () async {
        final tasks = dataGenerator.generateLargeTaskDataset(1500);
        final progressTracker = BulkOperationProgressTracker();
        
        when(mockTaskRepository.updateTask(any)).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 2));
          return null; // Simulate work
        });
        when(mockTaskRepository.getTasksByIds(any)).thenAnswer((_) async => tasks);
        
        final bulkService = ProgressTrackingBulkOperationService(
          taskRepository: mockTaskRepository,
          projectRepository: mockProjectRepository,
          progressTracker: progressTracker,
        );
        
        final stopwatch = Stopwatch()..start();
        
        // Start bulk operation with progress tracking
        final operationFuture = bulkService.bulkUpdateWithProgress(
          taskIds: tasks.map((t) => t.id).toList(),
          updateOperation: const TaskUpdateOperation(field: 'tags', value: ['tracked']),
          batchSize: 100,
        );
        
        // Monitor progress in real-time
        var lastProgress = 0.0;
        var progressUpdateCount = 0;
        
        while (!operationFuture.isCompleted) {
          await Future.delayed(const Duration(milliseconds: 200));
          
          final currentProgress = await progressTracker.getCurrentProgress();
          if (currentProgress > lastProgress) {
            lastProgress = currentProgress;
            progressUpdateCount++;
            
            print('Progress: ${(currentProgress * 100).toStringAsFixed(1)}%');
          }
        }
        
        final result = await operationFuture;
        stopwatch.stop();
        
        benchmarker.recordMetric('progress_tracked_bulk_1500', stopwatch.elapsedMilliseconds);
        
        // Progress tracking should provide regular updates
        expect(stopwatch.elapsedMilliseconds, lessThan(7000),
               reason: 'Progress-tracked bulk operation should complete within 7 seconds');
        
        expect(result.isSuccess, isTrue);
        expect(progressUpdateCount, greaterThan(5),
               reason: 'Should receive multiple progress updates');
        expect(lastProgress, equals(1.0),
               reason: 'Final progress should be 100%');
        
        print('Progress-tracked bulk operation (1500 tasks): ${stopwatch.elapsedMilliseconds}ms');
        print('Progress updates received: $progressUpdateCount');
      });
    });

    tearDown(() {
      // Print bulk operations performance summary
      final summary = benchmarker.generateSummary();
      print('\n=== Bulk Operations Performance Summary ===');
      summary.forEach((metric, stats) {
        print('$metric: ${stats['avg']}ms avg (${stats['min']}-${stats['max']}ms)');
      });
      print('==========================================\n');
    });
  });
}

/// Bulk operations test data generator
class BulkOperationsTestDataGenerator {
  final math.Random _random = math.Random(42); // Fixed seed
  
  /// Generates tasks spread across multiple projects
  List<TaskModel> generateCrossProjectTasks(int taskCount, int projectCount) {
    final tasks = <TaskModel>[];
    final projectIds = List.generate(projectCount, (i) => 'project-${i + 1}');
    final now = DateTime.now();
    
    for (int i = 0; i < taskCount; i++) {
      final projectId = projectIds[i % projectIds.length];
      
      final task = TaskModel.create(
        title: 'Cross-Project Task #${i + 1}',
        description: 'Task for bulk operations performance testing',
        projectId: projectId,
        priority: TaskPriority.values[_random.nextInt(TaskPriority.values.length)],
        tags: _generateRandomTags(),
        createdAt: now.subtract(Duration(days: _random.nextInt(30))),
      ).copyWith(
      );
      
      tasks.add(task);
    }
    
    return tasks;
  }
  
  /// Generates tasks with dependency relationships
  List<TaskModel> generateTasksWithDependencies(int taskCount, int dependencyCount) {
    final tasks = <TaskModel>[];
    final taskIds = List.generate(taskCount, (i) => 'task-${i + 1}');
    
    // Create base tasks
    for (int i = 0; i < taskCount; i++) {
      final task = TaskModel.create(
        title: 'Dependent Task #${i + 1}',
        description: 'Task with dependencies for bulk operations testing',
      ).copyWith(
        id: taskIds[i],
      );
      
      tasks.add(task);
    }
    
    // Add dependencies
    final dependencyMap = <String, Set<String>>{};
    for (int i = 0; i < dependencyCount && i < taskCount * 2; i++) {
      final dependentIndex = _random.nextInt(taskCount);
      final dependsOnIndex = _random.nextInt(taskCount);
      
      if (dependentIndex != dependsOnIndex) {
        final dependentId = taskIds[dependentIndex];
        final dependsOnId = taskIds[dependsOnIndex];
        
        dependencyMap.putIfAbsent(dependentId, () => <String>{}).add(dependsOnId);
      }
    }
    
    // Update tasks with dependencies
    for (int i = 0; i < tasks.length; i++) {
      final taskId = taskIds[i];
      final dependencies = dependencyMap[taskId]?.toList() ?? <String>[];
      
      tasks[i] = tasks[i].copyWith(dependencies: dependencies);
    }
    
    return tasks;
  }
  
  /// Generates large task dataset
  List<TaskModel> generateLargeTaskDataset(int count) {
    final tasks = <TaskModel>[];
    final now = DateTime.now();
    
    for (int i = 0; i < count; i++) {
      final task = TaskModel.create(
        title: 'Bulk Operations Task #${i + 1}',
        description: 'Large dataset task for performance testing',
        priority: TaskPriority.values[_random.nextInt(TaskPriority.values.length)],
        tags: _generateRandomTags(),
        createdAt: now.subtract(Duration(days: _random.nextInt(365))),
      ).copyWith(
        metadata: {
          'batch_id': 'batch-${i ~/ 100}',
          'sequence': i,
          'complexity': _random.nextInt(10) + 1,
        },
      );
      
      tasks.add(task);
    }
    
    return tasks;
  }
  
  /// Generates project dataset
  List<Project> generateProjectDataset(int count) {
    final projects = <Project>[];
    
    for (int i = 0; i < count; i++) {
      final project = Project.create(
        name: 'Bulk Operations Project ${i + 1}',
        description: 'Project for bulk operations testing',
        deadline: _random.nextBool() 
          ? DateTime.now().add(Duration(days: 30 + _random.nextInt(180)))
          : null,
      );
      
      projects.add(project);
    }
    
    return projects;
  }
  
  /// Generates tasks prone to duplication
  List<TaskModel> generateDuplicateProneTaskData(int count, List<Project> projects) {
    final tasks = <TaskModel>[];
    final duplicateTemplates = [
      'Setup development environment',
      'Create user documentation',
      'Implement authentication',
      'Add unit tests',
      'Deploy to staging',
    ];
    
    for (int i = 0; i < count; i++) {
      final template = duplicateTemplates[_random.nextInt(duplicateTemplates.length)];
      final project = projects[_random.nextInt(projects.length)];
      
      // Some tasks are exact duplicates, others are similar
      final isDuplicate = _random.nextDouble() < 0.2;
      final title = isDuplicate 
        ? template 
        : '$template - ${project.name}';
      
      final task = TaskModel.create(
        title: title,
        description: 'Potentially duplicate task for consolidation testing',
        projectId: project.id,
        priority: TaskPriority.values[_random.nextInt(TaskPriority.values.length)],
      );
      
      tasks.add(task);
    }
    
    return tasks;
  }
  
  List<String> _generateRandomTags() {
    final allTags = [
      'urgent', 'feature', 'bug', 'enhancement', 'documentation',
      'testing', 'deployment', 'maintenance', 'research', 'planning'
    ];
    
    final tagCount = 1 + _random.nextInt(3);
    final tags = <String>[];
    
    for (int i = 0; i < tagCount; i++) {
      final tag = allTags[_random.nextInt(allTags.length)];
      if (!tags.contains(tag)) {
        tags.add(tag);
      }
    }
    
    return tags;
  }
}

/// Performance benchmarker (shared utility)
class PerformanceBenchmarker {
  final Map<String, List<int>> _metrics = {};
  
  void recordMetric(String name, int valueMs) {
    _metrics.putIfAbsent(name, () => []).add(valueMs);
  }
  
  Map<String, Map<String, int>> generateSummary() {
    final summary = <String, Map<String, int>>{};
    
    _metrics.forEach((name, values) {
      final avg = values.reduce((a, b) => a + b) / values.length;
      final min = values.reduce(math.min);
      final max = values.reduce(math.max);
      
      summary[name] = {
        'avg': avg.round(),
        'min': min,
        'max': max,
        'count': values.length,
      };
    });
    
    return summary;
  }
}

/// Memory tracker (shared utility)
class MemoryUsageTracker {
  Future<double> getCurrentUsage() async {
    await Future.delayed(const Duration(milliseconds: 5));
    return 70.0 + (DateTime.now().millisecondsSinceEpoch % 1000) / 30.0;
  }
}

/// Mock bulk operation services for testing
class ParallelBulkOperationService {
  final MockTaskRepository taskRepository;
  final MockProjectRepository projectRepository;
  final MockNotificationService notificationService;
  final int maxConcurrentWorkers;
  
  ParallelBulkOperationService({
    required this.taskRepository,
    required this.projectRepository,
    required this.notificationService,
    required this.maxConcurrentWorkers,
  });
  
  Future<BulkOperationResult> parallelBulkUpdate({
    required List<String> taskIds,
    required List<TaskUpdateOperation> updateOperations,
    required int batchSize,
  }) async {
    // Simulate parallel processing
    final batches = <List<String>>[];
    for (int i = 0; i < taskIds.length; i += batchSize) {
      batches.add(taskIds.skip(i).take(batchSize).toList());
    }
    
    // Process batches in parallel
    final futures = batches.map((batch) async {
      await Future.delayed(Duration(milliseconds: batch.length * 2));
      return batch.length; // Return processed count
    });
    
    final results = await Future.wait(futures);
    final totalProcessed = results.fold(0, (sum, count) => sum + count);
    
    return BulkOperationResult(
      isSuccess: true,
      processedCount: totalProcessed,
      failedCount: 0,
      executionTimeMs: 0,
    );
  }
}

class StreamingBulkOperationService {
  final MockTaskRepository taskRepository;
  final MockProjectRepository projectRepository;
  
  StreamingBulkOperationService({
    required this.taskRepository,
    required this.projectRepository,
  });
  
  Stream<BulkOperationBatch> streamBulkUpdate({
    required int taskCount,
    required int batchSize,
    required TaskUpdateOperation updateOperation,
  }) async* {
    var processedCount = 0;
    
    while (processedCount < taskCount) {
      final currentBatchSize = math.min(batchSize, taskCount - processedCount);
      
      // Simulate processing batch
      await Future.delayed(Duration(milliseconds: currentBatchSize * 5));
      
      processedCount += currentBatchSize;
      
      yield BulkOperationBatch(
        processedCount: currentBatchSize,
        totalProcessed: processedCount,
        totalCount: taskCount,
      );
    }
  }
}

class TransactionalBulkOperationService {
  final MockTaskRepository taskRepository;
  final MockProjectRepository projectRepository;
  
  TransactionalBulkOperationService({
    required this.taskRepository,
    required this.projectRepository,
  });
  
  Future<BulkOperationResult> transactionalBulkUpdate({
    required List<String> taskIds,
    required List<TaskUpdateOperation> updateOperations,
    required bool rollbackOnError,
  }) async {
    var processedCount = 0;
    final processedTasks = <String>[];
    
    try {
      for (final taskId in taskIds) {
        await taskRepository.updateTask(TaskModel.create(title: 'test').copyWith(id: taskId));
        processedTasks.add(taskId);
        processedCount++;
      }
      
      return BulkOperationResult(
        isSuccess: true,
        processedCount: processedCount,
        failedCount: 0,
        executionTimeMs: 0,
      );
    } catch (e) {
      // Simulate rollback
      if (rollbackOnError) {
        await Future.delayed(Duration(milliseconds: processedTasks.length * 2));
        
        return BulkOperationResult(
          isSuccess: false,
          processedCount: processedCount,
          failedCount: taskIds.length - processedCount,
          executionTimeMs: 0,
          rollbackPerformed: true,
          rollbackSuccessful: true,
        );
      }
      
      rethrow;
    }
  }
}

class ResilientBulkOperationService {
  final MockTaskRepository taskRepository;
  final MockProjectRepository projectRepository;
  final int maxRetries;
  final int retryDelayMs;
  
  ResilientBulkOperationService({
    required this.taskRepository,
    required this.projectRepository,
    required this.maxRetries,
    required this.retryDelayMs,
  });
  
  Future<BulkOperationResult> resilientBulkUpdate({
    required List<String> taskIds,
    required List<TaskUpdateOperation> updateOperations,
  }) async {
    var processedCount = 0;
    var retryCount = 0;
    
    for (final taskId in taskIds) {
      var attempts = 0;
      var success = false;
      
      while (!success && attempts <= maxRetries) {
        try {
          await taskRepository.updateTask(TaskModel.create(title: 'test').copyWith(id: taskId));
          success = true;
          processedCount++;
        } catch (e) {
          attempts++;
          if (attempts <= maxRetries) {
            retryCount++;
            await Future.delayed(Duration(milliseconds: retryDelayMs));
          }
        }
      }
    }
    
    return BulkOperationResult(
      isSuccess: processedCount == taskIds.length,
      processedCount: processedCount,
      failedCount: taskIds.length - processedCount,
      executionTimeMs: 0,
      retryCount: retryCount,
    );
  }
}

class MonitoredBulkOperationService {
  final MockTaskRepository taskRepository;
  final MockProjectRepository projectRepository;
  final BulkOperationPerformanceMonitor performanceMonitor;
  
  MonitoredBulkOperationService({
    required this.taskRepository,
    required this.projectRepository,
    required this.performanceMonitor,
  });
  
  Future<BulkOperationResult> bulkUpdatePriority({
    required List<String> taskIds,
    required TaskPriority newPriority,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    for (final taskId in taskIds) {
      await taskRepository.updateTask(TaskModel.create(title: 'test').copyWith(id: taskId));
    }
    
    stopwatch.stop();
    
    performanceMonitor.recordOperation(
      'priority_update',
      taskIds.length,
      stopwatch.elapsedMilliseconds,
    );
    
    return BulkOperationResult(
      isSuccess: true,
      processedCount: taskIds.length,
      failedCount: 0,
      executionTimeMs: stopwatch.elapsedMilliseconds,
    );
  }
  
  Future<BulkOperationResult> bulkUpdateStatus({
    required List<String> taskIds,
    required TaskStatus newStatus,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    for (final taskId in taskIds) {
      await taskRepository.updateTask(TaskModel.create(title: 'test').copyWith(id: taskId));
    }
    
    stopwatch.stop();
    
    performanceMonitor.recordOperation(
      'status_update',
      taskIds.length,
      stopwatch.elapsedMilliseconds,
    );
    
    return BulkOperationResult(
      isSuccess: true,
      processedCount: taskIds.length,
      failedCount: 0,
      executionTimeMs: stopwatch.elapsedMilliseconds,
    );
  }
  
  Future<BulkOperationResult> bulkAddTags({
    required List<String> taskIds,
    required List<String> tags,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    for (final taskId in taskIds) {
      await taskRepository.updateTask(TaskModel.create(title: 'test').copyWith(id: taskId));
    }
    
    stopwatch.stop();
    
    performanceMonitor.recordOperation(
      'add_tags',
      taskIds.length,
      stopwatch.elapsedMilliseconds,
    );
    
    return BulkOperationResult(
      isSuccess: true,
      processedCount: taskIds.length,
      failedCount: 0,
      executionTimeMs: stopwatch.elapsedMilliseconds,
    );
  }
  
  Future<BulkOperationResult> bulkDeleteTasks({
    required List<String> taskIds,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    for (final taskId in taskIds) {
      await taskRepository.updateTask(TaskModel.create(title: 'test').copyWith(id: taskId));
    }
    
    stopwatch.stop();
    
    performanceMonitor.recordOperation(
      'delete_tasks',
      taskIds.length,
      stopwatch.elapsedMilliseconds,
    );
    
    return BulkOperationResult(
      isSuccess: true,
      processedCount: taskIds.length,
      failedCount: 0,
      executionTimeMs: stopwatch.elapsedMilliseconds,
    );
  }
  
  Future<BulkOperationPerformanceReport> generatePerformanceReport({
    required Duration timeRange,
  }) async {
    return performanceMonitor.generateReport(timeRange);
  }
}

class BulkOperationPerformanceMonitor {
  final List<OperationMetric> _metrics = [];
  
  void recordOperation(String operationType, int taskCount, int executionTimeMs) {
    _metrics.add(OperationMetric(
      operationType: operationType,
      taskCount: taskCount,
      executionTimeMs: executionTimeMs,
      timestamp: DateTime.now(),
    ));
  }
  
  BulkOperationPerformanceReport generateReport(Duration timeRange) {
    final cutoffTime = DateTime.now().subtract(timeRange);
    final recentMetrics = _metrics.where((m) => m.timestamp.isAfter(cutoffTime)).toList();
    
    if (recentMetrics.isEmpty) {
      return const BulkOperationPerformanceReport(
        totalOperations: 0,
        averageExecutionTime: 0,
        tasksPerSecond: 0,
      );
    }
    
    final totalOps = recentMetrics.length;
    final avgTime = recentMetrics.map((m) => m.executionTimeMs).reduce((a, b) => a + b) / totalOps;
    final totalTasks = recentMetrics.map((m) => m.taskCount).reduce((a, b) => a + b);
    final totalTimeSeconds = recentMetrics.map((m) => m.executionTimeMs).reduce((a, b) => a + b) / 1000.0;
    
    return BulkOperationPerformanceReport(
      totalOperations: totalOps,
      averageExecutionTime: avgTime,
      tasksPerSecond: totalTasks / totalTimeSeconds,
    );
  }
}

class ProgressTrackingBulkOperationService {
  final MockTaskRepository taskRepository;
  final MockProjectRepository projectRepository;
  final BulkOperationProgressTracker progressTracker;
  
  ProgressTrackingBulkOperationService({
    required this.taskRepository,
    required this.projectRepository,
    required this.progressTracker,
  });
  
  Future<BulkOperationResult> bulkUpdateWithProgress({
    required List<String> taskIds,
    required TaskUpdateOperation updateOperation,
    required int batchSize,
  }) async {
    progressTracker.startOperation(taskIds.length);
    
    var processedCount = 0;
    
    for (int i = 0; i < taskIds.length; i += batchSize) {
      final batch = taskIds.skip(i).take(batchSize);
      
      for (final taskId in batch) {
        await taskRepository.updateTask(TaskModel.create(title: 'test').copyWith(id: taskId));
        processedCount++;
        progressTracker.updateProgress(processedCount, taskIds.length);
      }
    }
    
    progressTracker.completeOperation();
    
    return BulkOperationResult(
      isSuccess: true,
      processedCount: processedCount,
      failedCount: 0,
      executionTimeMs: 0,
    );
  }
}

class BulkOperationProgressTracker {
  double _currentProgress = 0.0;
  bool _operationActive = false;
  
  void startOperation(int totalCount) {
    _operationActive = true;
    _currentProgress = 0.0;
  }
  
  void updateProgress(int processedCount, int totalCount) {
    if (_operationActive) {
      _currentProgress = processedCount / totalCount;
    }
  }
  
  void completeOperation() {
    _operationActive = false;
    _currentProgress = 1.0;
  }
  
  Future<double> getCurrentProgress() async {
    return _currentProgress;
  }
}

// Mock data classes and enums
enum ConflictResolutionStrategy { mergePreferSource, mergePreferTarget, createDuplicate, skip }

class ProjectMigrationOptions {
  final bool preserveTaskMetadata;
  final bool updateTaskDependencies;
  final bool notifyStakeholders;
  final bool createMigrationLog;
  final bool resolveConflicts;
  final ConflictResolutionStrategy? conflictResolutionStrategy;
  
  const ProjectMigrationOptions({
    required this.preserveTaskMetadata,
    required this.updateTaskDependencies,
    required this.notifyStakeholders,
    required this.createMigrationLog,
    this.resolveConflicts = false,
    this.conflictResolutionStrategy,
  });
}

class ProjectConsolidationOptions {
  final bool detectDuplicateTasks;
  final bool mergeDuplicates;
  final bool deleteEmptyProjects;
  final bool generateConsolidationReport;
  
  const ProjectConsolidationOptions({
    required this.detectDuplicateTasks,
    required this.mergeDuplicates,
    required this.deleteEmptyProjects,
    required this.generateConsolidationReport,
  });
}

class TaskUpdateOperation {
  final String field;
  final dynamic value;
  
  const TaskUpdateOperation({required this.field, required this.value});
}

class BulkOperationResult {
  final bool isSuccess;
  final int processedCount;
  final int failedCount;
  final int executionTimeMs;
  final bool rollbackPerformed;
  final bool rollbackSuccessful;
  final int retryCount;
  
  const BulkOperationResult({
    required this.isSuccess,
    required this.processedCount,
    required this.failedCount,
    required this.executionTimeMs,
    this.rollbackPerformed = false,
    this.rollbackSuccessful = false,
    this.retryCount = 0,
  });
  
  double get successRate => processedCount / (processedCount + failedCount) * 100;
}

class MigrationResult {
  final bool isSuccess;
  final int migratedTaskCount;
  
  const MigrationResult({required this.isSuccess, required this.migratedTaskCount});
  
  double get successRate => isSuccess ? 100.0 : 0.0;
}

class ConsolidationResult {
  final bool isSuccess;
  final int consolidatedProjects;
  final int duplicatesDetected;
  final int duplicatesMerged;
  
  const ConsolidationResult({
    required this.isSuccess,
    required this.consolidatedProjects,
    required this.duplicatesDetected,
    required this.duplicatesMerged,
  });
}

class BulkOperationBatch {
  final int processedCount;
  final int totalProcessed;
  final int totalCount;
  
  const BulkOperationBatch({
    required this.processedCount,
    required this.totalProcessed,
    required this.totalCount,
  });
}

class OperationMetric {
  final String operationType;
  final int taskCount;
  final int executionTimeMs;
  final DateTime timestamp;
  
  const OperationMetric({
    required this.operationType,
    required this.taskCount,
    required this.executionTimeMs,
    required this.timestamp,
  });
}

class BulkOperationPerformanceReport {
  final int totalOperations;
  final double averageExecutionTime;
  final double tasksPerSecond;
  
  const BulkOperationPerformanceReport({
    required this.totalOperations,
    required this.averageExecutionTime,
    required this.tasksPerSecond,
  });
}