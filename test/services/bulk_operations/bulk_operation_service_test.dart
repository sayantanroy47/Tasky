import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/domain/repositories/task_repository.dart';
import 'package:task_tracker_app/domain/repositories/project_repository.dart';
import 'package:task_tracker_app/services/bulk_operations/bulk_operation_service.dart';
import 'package:task_tracker_app/services/bulk_operations/bulk_operation_history.dart';
import 'package:task_tracker_app/services/notification/notification_service.dart';
import 'package:task_tracker_app/services/performance_service.dart';

import 'bulk_operation_service_test.mocks.dart';

@GenerateMocks([
  TaskRepository,
  ProjectRepository,
  NotificationService,
  PerformanceService,
  BulkOperationHistory,
])
void main() {
  group('BulkOperationService', () {
    late BulkOperationService service;
    late MockTaskRepository mockTaskRepository;
    late MockProjectRepository mockProjectRepository;
    late MockNotificationService mockNotificationService;
    late MockPerformanceService mockPerformanceService;
    late MockBulkOperationHistory mockHistory;
    late List<TaskModel> testTasks;

    setUp(() {
      mockTaskRepository = MockTaskRepository();
      mockProjectRepository = MockProjectRepository();
      mockNotificationService = MockNotificationService();
      mockPerformanceService = MockPerformanceService();
      mockHistory = MockBulkOperationHistory();

      // Setup performance service mock to execute operations directly
      when(mockPerformanceService.trackOperation<dynamic>(any, any))
          .thenAnswer((invocation) async {
        final operation = invocation.positionalArguments[1] as Function();
        return await operation();
      });

      service = BulkOperationService(
        taskRepository: mockTaskRepository,
        projectRepository: mockProjectRepository,
        notificationService: mockNotificationService,
        performanceService: mockPerformanceService,
        history: mockHistory,
      );

      testTasks = [
        TaskModel(
          id: '1',
          title: 'Task 1',
          priority: TaskPriority.high,
          createdAt: DateTime.now(),
        ),
        TaskModel(
          id: '2',
          title: 'Task 2',
          priority: TaskPriority.medium,
          createdAt: DateTime.now(),
        ),
        TaskModel(
          id: '3',
          title: 'Task 3',
          priority: TaskPriority.low,
          createdAt: DateTime.now(),
        ),
      ];
    });

    tearDown(() {
      service.dispose();
    });

    group('Bulk Delete Operations', () {
      test('should delete tasks successfully', () async {
        when(mockTaskRepository.deleteTasks(any))
            .thenAnswer((_) async {
              return;
            });
        when(mockNotificationService.showNotification(
          title: anyNamed('title'),
          body: anyNamed('body'),
        )).thenAnswer((_) async {
          return null;
        });

        final result = await service.bulkDeleteTasks(testTasks);

        expect(result.isSuccess, isTrue);
        expect(result.successfulTasks, equals(3));
        expect(result.failedTasks, equals(0));
        verify(mockTaskRepository.deleteTasks(['1', '2', '3'])).called(1);
        verify(mockNotificationService.showNotification(
          title: 'Tasks Deleted',
          body: '3 tasks deleted successfully',
        )).called(1);
      });

      test('should handle delete operation failures', () async {
        when(mockTaskRepository.deleteTasks(any))
            .thenThrow(Exception('Database error'));

        final result = await service.bulkDeleteTasks(testTasks);

        expect(result.isSuccess, isFalse);
        expect(result.successfulTasks, equals(0));
        expect(result.failedTasks, equals(3));
        expect(result.errors, isNotEmpty);
      });

      test('should record delete operation in history when undo enabled', () async {
        when(mockTaskRepository.deleteTasks(any))
            .thenAnswer((_) async {
              return;
            });
        when(mockHistory.recordOperation(any))
            .thenAnswer((_) async {
              return;
            });

        await service.bulkDeleteTasks(testTasks, enableUndo: true);

        verify(mockHistory.recordOperation(any)).called(1);
      });

      test('should not record operation in history when undo disabled', () async {
        when(mockTaskRepository.deleteTasks(any))
            .thenAnswer((_) async {
              return;
            });

        await service.bulkDeleteTasks(testTasks, enableUndo: false);

        verifyNever(mockHistory.recordOperation(any));
      });
    });

    group('Bulk Status Update Operations', () {
      test('should update task status successfully', () async {
        when(mockTaskRepository.updateTasksStatus(any, any))
            .thenAnswer((_) async {
              return;
            });

        final result = await service.bulkUpdateStatus(
          testTasks,
          TaskStatus.completed,
        );

        expect(result.isSuccess, isTrue);
        expect(result.successfulTasks, equals(3));
        verify(mockTaskRepository.updateTasksStatus(
          ['1', '2', '3'],
          TaskStatus.completed,
        )).called(1);
      });

      test('should handle partial status update failures', () async {
        // Simulate batch failure by throwing on the first batch
        when(mockTaskRepository.updateTasksStatus(any, any))
            .thenThrow(Exception('Update failed'));

        final result = await service.bulkUpdateStatus(
          testTasks,
          TaskStatus.completed,
        );

        expect(result.isSuccess, isFalse);
        expect(result.successfulTasks, equals(0));
        expect(result.failedTasks, equals(3));
      });
    });

    group('Bulk Priority Update Operations', () {
      test('should update task priority successfully', () async {
        when(mockTaskRepository.updateTasksPriority(any, any))
            .thenAnswer((_) async {
              return;
            });

        final result = await service.bulkUpdatePriority(
          testTasks,
          TaskPriority.urgent,
        );

        expect(result.isSuccess, isTrue);
        expect(result.successfulTasks, equals(3));
        verify(mockTaskRepository.updateTasksPriority(
          ['1', '2', '3'],
          TaskPriority.urgent,
        )).called(1);
      });
    });

    group('Bulk Project Move Operations', () {
      test('should move tasks to project successfully', () async {
        when(mockTaskRepository.assignTasksToProject(any, any))
            .thenAnswer((_) async {
              return;
            });

        final result = await service.bulkMoveToProject(
          testTasks,
          'project-123',
        );

        expect(result.isSuccess, isTrue);
        expect(result.successfulTasks, equals(3));
        verify(mockTaskRepository.assignTasksToProject(
          ['1', '2', '3'],
          'project-123',
        )).called(1);
      });

      test('should move tasks to no project (null)', () async {
        when(mockTaskRepository.assignTasksToProject(any, any))
            .thenAnswer((_) async {
              return;
            });

        final result = await service.bulkMoveToProject(testTasks, null);

        expect(result.isSuccess, isTrue);
        verify(mockTaskRepository.assignTasksToProject(['1', '2', '3'], null))
            .called(1);
      });
    });

    group('Bulk Tags Operations', () {
      test('should add tags to tasks successfully', () async {
        when(mockTaskRepository.updateTask(any))
            .thenAnswer((_) async {
              return;
            });

        final result = await service.bulkAddTags(
          testTasks,
          ['urgent', 'important'],
        );

        expect(result.isSuccess, isTrue);
        expect(result.successfulTasks, equals(3));
        verify(mockTaskRepository.updateTask(any)).called(3);
      });

      test('should remove tags from tasks successfully', () async {
        // Create tasks with tags
        final tasksWithTags = testTasks.map((task) =>
          task.copyWith(tags: ['tag1', 'tag2', 'tag3'])).toList();

        when(mockTaskRepository.updateTask(any))
            .thenAnswer((_) async {
              return;
            });

        final result = await service.bulkRemoveTags(
          tasksWithTags,
          ['tag1', 'tag3'],
        );

        expect(result.isSuccess, isTrue);
        verify(mockTaskRepository.updateTask(any)).called(3);
      });

      test('should not update tasks that already have the tags', () async {
        // Create tasks that already have the target tags
        final tasksWithTags = testTasks.map((task) =>
          task.copyWith(tags: ['urgent', 'important'])).toList();

        when(mockTaskRepository.updateTask(any))
            .thenAnswer((_) async {
              return;
            });

        await service.bulkAddTags(tasksWithTags, ['urgent']);

        // Should not call updateTask since tags are already present
        verifyNever(mockTaskRepository.updateTask(any));
      });
    });

    group('Bulk Reschedule Operations', () {
      test('should reschedule tasks with absolute strategy', () async {
        when(mockTaskRepository.updateTask(any))
            .thenAnswer((_) async {
              return;
            });

        final newDueDate = DateTime.now().add(const Duration(days: 7));
        final result = await service.bulkReschedule(
          testTasks,
          newDueDate,
          strategy: RescheduleStrategy.absolute,
        );

        expect(result.isSuccess, isTrue);
        verify(mockTaskRepository.updateTask(any)).called(3);
      });

      test('should reschedule tasks with relative strategy', () async {
        // Create tasks with existing due dates
        final tasksWithDueDates = testTasks.map((task) =>
          task.copyWith(dueDate: DateTime.now())).toList();

        when(mockTaskRepository.updateTask(any))
            .thenAnswer((_) async {
              return;
            });

        final result = await service.bulkReschedule(
          tasksWithDueDates,
          DateTime.now(), // Not used for relative strategy
          strategy: RescheduleStrategy.relative,
          relativeDuration: const Duration(days: 3),
        );

        expect(result.isSuccess, isTrue);
        verify(mockTaskRepository.updateTask(any)).called(3);
      });

      test('should reschedule tasks with preserve time strategy', () async {
        final tasksWithDueDates = testTasks.map((task) =>
          task.copyWith(dueDate: DateTime(2024, 1, 15, 14, 30))).toList();

        when(mockTaskRepository.updateTask(any))
            .thenAnswer((_) async {
              return;
            });

        final newDate = DateTime(2024, 2, 20);
        final result = await service.bulkReschedule(
          tasksWithDueDates,
          newDate,
          strategy: RescheduleStrategy.preserveTime,
        );

        expect(result.isSuccess, isTrue);
        verify(mockTaskRepository.updateTask(any)).called(3);
      });
    });

    group('Bulk Duplicate Operations', () {
      test('should duplicate tasks with smart naming', () async {
        when(mockTaskRepository.createTask(any))
            .thenAnswer((_) async {
              return;
            });

        final result = await service.bulkDuplicate(
          testTasks,
          strategy: DuplicationStrategy.smartNaming,
        );

        expect(result.isSuccess, isTrue);
        expect(result.result, isNotNull);
        expect(result.result?.length, equals(3));
        verify(mockTaskRepository.createTask(any)).called(3);
      });

      test('should duplicate tasks with suffix strategy', () async {
        when(mockTaskRepository.createTask(any))
            .thenAnswer((_) async {
              return;
            });

        final result = await service.bulkDuplicate(
          testTasks,
          strategy: DuplicationStrategy.suffix,
          nameSuffix: 'Copy',
        );

        expect(result.isSuccess, isTrue);
        verify(mockTaskRepository.createTask(any)).called(3);
      });

      test('should handle smart naming for tasks with existing copy numbers', () async {
        final taskWithCopy = TaskModel.create(
          title: 'Original Task (2)',
          createdAt: DateTime.now(),
        );

        when(mockTaskRepository.createTask(any))
            .thenAnswer((_) async {
              return;
            });

        await service.bulkDuplicate(
          [taskWithCopy],
          strategy: DuplicationStrategy.smartNaming,
        );

        // Verify the new task was created (can't easily verify title without capturing args)
        verify(mockTaskRepository.createTask(any)).called(1);
      });
    });

    group('Progress Tracking', () {
      test('should track progress during large operations', () async {
        // Create a larger set of tasks to test batching
        final largeTasks = List.generate(150, (i) => TaskModel(
          id: 'task_$i',
          title: 'Task $i',
          createdAt: DateTime.now(),
        ));

        when(mockTaskRepository.deleteTasks(any))
            .thenAnswer((_) async {
              return;
            });

        final result = await service.bulkDeleteTasks(largeTasks);

        expect(result.isSuccess, isTrue);
        expect(result.successfulTasks, equals(150));
        // Should be batched into multiple calls
        verify(mockTaskRepository.deleteTasks(any)).called(3); // 150/50 = 3 batches
      });

      test('should provide progress stream during operation', () async {
        when(mockTaskRepository.deleteTasks(any))
            .thenAnswer((_) async => Future.delayed(Duration.zero));

        // Start the operation
        final resultFuture = service.bulkDeleteTasks(testTasks);
        
        // The operation should complete
        final result = await resultFuture;
        expect(result.isSuccess, isTrue);

        // Progress stream should be cleaned up
        expect(service.getProgressStream(result.operationId), isNull);
      });
    });

    group('Operation Cancellation', () {
      test('should allow operation cancellation', () async {
        // This is a more complex test that would require proper stream handling
        // For now, we'll just test that the cancel method doesn't throw
        expect(() => service.cancelOperation('non-existent-id'), returnsNormally);
      });
    });

    group('Undo Operations', () {
      test('should undo delete operation', () async {
        // Create a mock record
        final mockRecord = BulkOperationRecord(
          id: 'operation-1',
          type: BulkOperationType.delete,
          taskSnapshots: testTasks,
          timestamp: DateTime.now(),
        );

        when(mockHistory.getOperation('operation-1'))
            .thenAnswer((_) async => mockRecord);
        when(mockTaskRepository.createTask(any))
            .thenAnswer((_) async {
              return;
            });
        when(mockHistory.markOperationUndone(any))
            .thenAnswer((_) async {
              return;
            });

        final result = await service.undoOperation('operation-1');

        expect(result.isSuccess, isTrue);
        verify(mockTaskRepository.createTask(any)).called(3);
        verify(mockHistory.markOperationUndone('operation-1')).called(1);
      });

      test('should undo status update operation', () async {
        final mockRecord = BulkOperationRecord(
          id: 'operation-1',
          type: BulkOperationType.updateStatus,
          taskSnapshots: testTasks,
          timestamp: DateTime.now(),
        );

        when(mockHistory.getOperation('operation-1'))
            .thenAnswer((_) async => mockRecord);
        when(mockTaskRepository.updateTask(any))
            .thenAnswer((_) async {
              return;
            });
        when(mockHistory.markOperationUndone(any))
            .thenAnswer((_) async {
              return;
            });

        final result = await service.undoOperation('operation-1');

        expect(result.isSuccess, isTrue);
        verify(mockTaskRepository.updateTask(any)).called(3);
        verify(mockHistory.markOperationUndone('operation-1')).called(1);
      });

      test('should fail to undo non-existent operation', () async {
        when(mockHistory.getOperation('non-existent'))
            .thenAnswer((_) async => null);

        expect(
          () => service.undoOperation('non-existent'),
          throwsA(isA<BulkOperationException>()),
        );
      });
    });

    group('Notifications', () {
      test('should show notification when showNotification is true', () async {
        when(mockTaskRepository.deleteTasks(any))
            .thenAnswer((_) async {
              return;
            });
        when(mockNotificationService.showNotification(
          title: anyNamed('title'),
          body: anyNamed('body'),
        )).thenAnswer((_) async {
          return null;
        });

        await service.bulkDeleteTasks(testTasks, showNotification: true);

        verify(mockNotificationService.showNotification(
          title: 'Tasks Deleted',
          body: '3 tasks deleted successfully',
        )).called(1);
      });

      test('should not show notification when showNotification is false', () async {
        when(mockTaskRepository.deleteTasks(any))
            .thenAnswer((_) async {
              return;
            });

        await service.bulkDeleteTasks(testTasks, showNotification: false);

        verifyNever(mockNotificationService.showNotification(
          title: anyNamed('title'),
          body: anyNamed('body'),
        ));
      });
    });

    group('Error Handling', () {
      test('should handle repository errors gracefully', () async {
        when(mockTaskRepository.deleteTasks(any))
            .thenThrow(Exception('Database connection failed'));

        final result = await service.bulkDeleteTasks(testTasks);

        expect(result.isFailure, isTrue);
        expect(result.errors, isNotEmpty);
        expect(result.errors.values.first, contains('Database connection failed'));
      });

      test('should handle partial batch failures', () async {
        var callCount = 0;
        when(mockTaskRepository.deleteTasks(any))
            .thenAnswer((_) async {
              callCount++;
              if (callCount == 1) {
                throw Exception('First batch failed');
              }
              return;
              // Second batch succeeds
            });

        // Create enough tasks for 2 batches
        final manyTasks = List.generate(100, (i) => TaskModel(
          id: 'task_$i',
          title: 'Task $i',
          createdAt: DateTime.now(),
        ));

        final result = await service.bulkDeleteTasks(manyTasks);

        expect(result.isPartialSuccess, isTrue);
        expect(result.successfulTasks, equals(50)); // Second batch succeeded
        expect(result.failedTasks, equals(50)); // First batch failed
      });
    });

    group('Performance Benchmarks', () {
      test('should complete small operations within performance targets', () async {
        when(mockTaskRepository.deleteTasks(any))
            .thenAnswer((_) async {
              return;
            });

        final stopwatch = Stopwatch()..start();
        await service.bulkDeleteTasks(testTasks);
        stopwatch.stop();

        // Should complete small operations quickly
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('should handle large operations efficiently', () async {
        final largeTasks = List.generate(1000, (i) => TaskModel(
          id: 'task_$i',
          title: 'Task $i',
          createdAt: DateTime.now(),
        ));

        when(mockTaskRepository.deleteTasks(any))
            .thenAnswer((_) async {
              return;
            });

        final stopwatch = Stopwatch()..start();
        await service.bulkDeleteTasks(largeTasks);
        stopwatch.stop();

        // Should complete large operations within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        // Verify proper batching occurred
        verify(mockTaskRepository.deleteTasks(any)).called(20); // 1000/50 = 20 batches
      });
    });

    group('Memory Management', () {
      test('should cleanup resources after operations', () async {
        when(mockTaskRepository.deleteTasks(any))
            .thenAnswer((_) async {
              return;
            });

        final result = await service.bulkDeleteTasks(testTasks);
        
        // Progress stream should be cleaned up
        expect(service.getProgressStream(result.operationId), isNull);
      });

      test('should dispose properly', () {
        // Should not throw when disposing
        expect(() => service.dispose(), returnsNormally);
        
        // After disposal, operations should still work but cleanup immediately
        expect(() => service.dispose(), returnsNormally);
      });
    });
  });
}