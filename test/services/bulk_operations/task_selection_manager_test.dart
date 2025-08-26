import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/services/bulk_operations/task_selection_manager.dart';

void main() {
  group('TaskSelectionManager', () {
    late TaskSelectionManager selectionManager;
    late List<TaskModel> testTasks;

    setUp(() {
      selectionManager = TaskSelectionManager();
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

    group('Task Selection', () {
      test('should start with empty selection', () {
        expect(selectionManager.state.hasSelection, isFalse);
        expect(selectionManager.state.selectionCount, equals(0));
        expect(selectionManager.state.isMultiSelectMode, isFalse);
      });

      test('should toggle task selection', () {
        selectionManager.toggleTask(testTasks[0]);
        
        expect(selectionManager.state.hasSelection, isTrue);
        expect(selectionManager.state.selectionCount, equals(1));
        expect(selectionManager.state.isSelected(testTasks[0].id), isTrue);
        expect(selectionManager.state.isSelected(testTasks[1].id), isFalse);
      });

      test('should deselect task when toggled again', () {
        selectionManager.toggleTask(testTasks[0]);
        expect(selectionManager.state.isSelected(testTasks[0].id), isTrue);
        
        selectionManager.toggleTask(testTasks[0]);
        expect(selectionManager.state.isSelected(testTasks[0].id), isFalse);
        expect(selectionManager.state.hasSelection, isFalse);
      });

      test('should select multiple tasks', () {
        selectionManager.toggleTask(testTasks[0]);
        selectionManager.toggleTask(testTasks[1]);
        
        expect(selectionManager.state.selectionCount, equals(2));
        expect(selectionManager.state.isSelected(testTasks[0].id), isTrue);
        expect(selectionManager.state.isSelected(testTasks[1].id), isTrue);
      });

      test('should select all tasks', () {
        selectionManager.selectAll(testTasks);
        
        expect(selectionManager.state.selectionCount, equals(3));
        for (final task in testTasks) {
          expect(selectionManager.state.isSelected(task.id), isTrue);
        }
      });

      test('should deselect all tasks', () {
        selectionManager.selectAll(testTasks);
        expect(selectionManager.state.hasSelection, isTrue);
        
        selectionManager.deselectAll();
        expect(selectionManager.state.hasSelection, isFalse);
        expect(selectionManager.state.selectionCount, equals(0));
      });
    });

    group('Multi-Select Mode', () {
      test('should enable multi-select mode', () {
        selectionManager.enableMultiSelect();
        expect(selectionManager.state.isMultiSelectMode, isTrue);
      });

      test('should disable multi-select mode', () {
        selectionManager.enableMultiSelect();
        selectionManager.disableMultiSelect();
        expect(selectionManager.state.isMultiSelectMode, isFalse);
      });

      test('should clear selection when disabling multi-select mode', () {
        selectionManager.toggleTask(testTasks[0]);
        selectionManager.enableMultiSelect();
        selectionManager.disableMultiSelect();
        
        expect(selectionManager.state.hasSelection, isFalse);
      });

      test('should preserve selection when disabling multi-select with clearSelection=false', () {
        selectionManager.toggleTask(testTasks[0]);
        selectionManager.enableMultiSelect();
        selectionManager.disableMultiSelect(clearSelection: false);
        
        expect(selectionManager.state.isSelected(testTasks[0].id), isTrue);
        expect(selectionManager.state.isMultiSelectMode, isFalse);
      });
    });

    group('Selection by Criteria', () {
      test('should select tasks by status', () {
        selectionManager.selectByStatus(testTasks, TaskStatus.pending);
        
        expect(selectionManager.state.selectionCount, equals(1));
        expect(selectionManager.state.isSelected(testTasks[0].id), isTrue);
      });

      test('should select tasks by priority', () {
        selectionManager.selectByPriority(testTasks, TaskPriority.high);
        
        expect(selectionManager.state.selectionCount, equals(1));
        expect(selectionManager.state.isSelected(testTasks[0].id), isTrue);
      });

      test('should select tasks by project', () {
        final projectTasks = [
          testTasks[0].copyWith(projectId: 'project1'),
          testTasks[1].copyWith(projectId: 'project1'),
          testTasks[2].copyWith(projectId: 'project2'),
        ];
        
        selectionManager.selectByProject(projectTasks, 'project1');
        
        expect(selectionManager.state.selectionCount, equals(2));
        expect(selectionManager.state.isSelected(projectTasks[0].id), isTrue);
        expect(selectionManager.state.isSelected(projectTasks[1].id), isTrue);
        expect(selectionManager.state.isSelected(projectTasks[2].id), isFalse);
      });
    });

    group('Range Selection', () {
      test('should select range of tasks', () {
        selectionManager.selectRange(testTasks, testTasks[0], testTasks[2]);
        
        expect(selectionManager.state.selectionCount, equals(3));
        for (final task in testTasks) {
          expect(selectionManager.state.isSelected(task.id), isTrue);
        }
      });

      test('should select range in reverse order', () {
        selectionManager.selectRange(testTasks, testTasks[2], testTasks[0]);
        
        expect(selectionManager.state.selectionCount, equals(3));
        for (final task in testTasks) {
          expect(selectionManager.state.isSelected(task.id), isTrue);
        }
      });

      test('should handle invalid range selection', () {
        final nonExistentTask = TaskModel(
          id: 'nonexistent',
          title: 'Non-existent',
          createdAt: DateTime.now(),
        );
        
        selectionManager.selectRange(testTasks, testTasks[0], nonExistentTask);
        expect(selectionManager.state.hasSelection, isFalse);
      });
    });

    group('Selection Inversion', () {
      test('should invert empty selection', () {
        selectionManager.invertSelection(testTasks);
        
        expect(selectionManager.state.selectionCount, equals(3));
        for (final task in testTasks) {
          expect(selectionManager.state.isSelected(task.id), isTrue);
        }
      });

      test('should invert partial selection', () {
        selectionManager.toggleTask(testTasks[0]);
        selectionManager.invertSelection(testTasks);
        
        expect(selectionManager.state.selectionCount, equals(2));
        expect(selectionManager.state.isSelected(testTasks[0].id), isFalse);
        expect(selectionManager.state.isSelected(testTasks[1].id), isTrue);
        expect(selectionManager.state.isSelected(testTasks[2].id), isTrue);
      });

      test('should invert full selection', () {
        selectionManager.selectAll(testTasks);
        selectionManager.invertSelection(testTasks);
        
        expect(selectionManager.state.hasSelection, isFalse);
      });
    });

    group('Selection Cleanup', () {
      test('should cleanup deleted tasks from selection', () {
        selectionManager.selectAll(testTasks);
        expect(selectionManager.state.selectionCount, equals(3));
        
        // Simulate removing one task
        final remainingTasks = [testTasks[0], testTasks[2]];
        selectionManager.cleanupDeletedTasks(remainingTasks);
        
        expect(selectionManager.state.selectionCount, equals(2));
        expect(selectionManager.state.isSelected(testTasks[0].id), isTrue);
        expect(selectionManager.state.isSelected(testTasks[1].id), isFalse);
        expect(selectionManager.state.isSelected(testTasks[2].id), isTrue);
      });

      test('should not modify selection if no tasks removed', () {
        selectionManager.selectAll(testTasks);
        final initialCount = selectionManager.state.selectionCount;
        
        selectionManager.cleanupDeletedTasks(testTasks);
        
        expect(selectionManager.state.selectionCount, equals(initialCount));
      });
    });

    group('Task Data Updates', () {
      test('should update task data in selection', () {
        selectionManager.toggleTask(testTasks[0]);
        
        final updatedTask = testTasks[0].copyWith(title: 'Updated Title');
        selectionManager.updateTaskData(updatedTask);
        
        final selectedTasks = selectionManager.state.selectedTasksList;
        expect(selectedTasks.first.title, equals('Updated Title'));
      });

      test('should not affect selection if task not selected', () {
        selectionManager.toggleTask(testTasks[0]);
        
        final updatedTask = testTasks[1].copyWith(title: 'Updated Title');
        selectionManager.updateTaskData(updatedTask);
        
        expect(selectionManager.state.selectionCount, equals(1));
        expect(selectionManager.state.isSelected(testTasks[0].id), isTrue);
      });
    });

    group('Context Management', () {
      test('should set selection context', () {
        selectionManager.setContext(SelectionContext.kanbanBoard, metadata: {'boardId': 'board1'});
        
        expect(selectionManager.state.currentContext, equals(SelectionContext.kanbanBoard));
        expect(selectionManager.state.contextMetadata['boardId'], equals('board1'));
      });

      test('should set context without metadata', () {
        selectionManager.setContext(SelectionContext.home);
        
        expect(selectionManager.state.currentContext, equals(SelectionContext.home));
        expect(selectionManager.state.contextMetadata, isEmpty);
      });
    });

    group('Statistics', () {
      test('should calculate selection statistics', () {
        // Create tasks with different properties for statistics
        final diverseTasks = [
          testTasks[0], // high priority, pending
          testTasks[1], // medium priority, inProgress
          testTasks[2], // low priority, completed
          TaskModel(
            id: '4',
            title: 'Overdue Task',
            priority: TaskPriority.urgent,
            dueDate: DateTime.now().subtract(const Duration(days: 1)),
            createdAt: DateTime.now(),
          ),
          TaskModel(
            id: '5',
            title: 'Due Today Task',
            priority: TaskPriority.medium,
            dueDate: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        ];
        
        selectionManager.selectAll(diverseTasks);
        final statistics = selectionManager.getStatistics();
        
        expect(statistics.totalSelected, equals(5));
        expect(statistics.overdueCount, equals(1));
        expect(statistics.dueTodayCount, equals(1));
        expect(statistics.completedCount, equals(1));
        expect(statistics.statusBreakdown[TaskStatus.pending], equals(3));
        expect(statistics.statusBreakdown[TaskStatus.inProgress], equals(1));
        expect(statistics.statusBreakdown[TaskStatus.completed], equals(1));
        expect(statistics.priorityBreakdown[TaskPriority.high], equals(1));
        expect(statistics.priorityBreakdown[TaskPriority.medium], equals(2));
        expect(statistics.priorityBreakdown[TaskPriority.low], equals(1));
        expect(statistics.priorityBreakdown[TaskPriority.urgent], equals(1));
      });

      test('should generate suggested actions based on statistics', () {
        // Select overdue tasks
        final overdueTasks = [
          TaskModel(
            id: '1',
            title: 'Overdue Task 1',
            priority: TaskPriority.high,
            dueDate: DateTime.now().subtract(const Duration(days: 1)),
            createdAt: DateTime.now(),
          ),
          TaskModel(
            id: '2',
            title: 'Overdue Task 2',
            priority: TaskPriority.medium,
            dueDate: DateTime.now().subtract(const Duration(days: 2)),
            createdAt: DateTime.now(),
          ),
        ];
        
        selectionManager.selectAll(overdueTasks);
        final statistics = selectionManager.getStatistics();
        
        expect(statistics.suggestedActions, isNotEmpty);
        
        // Should suggest rescheduling overdue tasks
        final rescheduleAction = statistics.suggestedActions
            .firstWhere((action) => action.type == BulkActionType.reschedule);
        expect(rescheduleAction.priority, equals(BulkActionPriority.high));
      });
    });

    group('State Properties', () {
      test('should provide correct state properties', () {
        expect(selectionManager.state.hasSelection, isFalse);
        expect(selectionManager.state.selectionCount, equals(0));
        expect(selectionManager.state.selectedTasksList, isEmpty);
        expect(selectionManager.state.selectedTaskIds, isEmpty);
        
        selectionManager.toggleTask(testTasks[0]);
        
        expect(selectionManager.state.hasSelection, isTrue);
        expect(selectionManager.state.selectionCount, equals(1));
        expect(selectionManager.state.selectedTasksList.length, equals(1));
        expect(selectionManager.state.selectedTaskIds.length, equals(1));
        expect(selectionManager.state.selectedTaskIds.first, equals(testTasks[0].id));
      });

      test('should group tasks by status', () {
        selectionManager.selectAll(testTasks);
        final tasksByStatus = selectionManager.state.tasksByStatus;
        
        expect(tasksByStatus[TaskStatus.pending]?.length, equals(1));
        expect(tasksByStatus[TaskStatus.inProgress]?.length, equals(1));
        expect(tasksByStatus[TaskStatus.completed]?.length, equals(1));
      });

      test('should group tasks by priority', () {
        selectionManager.selectAll(testTasks);
        final tasksByPriority = selectionManager.state.tasksByPriority;
        
        expect(tasksByPriority[TaskPriority.high]?.length, equals(1));
        expect(tasksByPriority[TaskPriority.medium]?.length, equals(1));
        expect(tasksByPriority[TaskPriority.low]?.length, equals(1));
      });

      test('should group tasks by project', () {
        final projectTasks = [
          testTasks[0].copyWith(projectId: 'project1'),
          testTasks[1].copyWith(projectId: 'project1'),
          testTasks[2].copyWith(projectId: null), // No project
        ];
        
        selectionManager.selectAll(projectTasks);
        final tasksByProject = selectionManager.state.tasksByProject;
        
        expect(tasksByProject['project1']?.length, equals(2));
        expect(tasksByProject['none']?.length, equals(1));
      });
    });

    group('Edge Cases', () {
      test('should handle empty task list gracefully', () {
        selectionManager.selectAll([]);
        expect(selectionManager.state.hasSelection, isFalse);
        
        selectionManager.invertSelection([]);
        expect(selectionManager.state.hasSelection, isFalse);
        
        selectionManager.cleanupDeletedTasks([]);
        expect(selectionManager.state.hasSelection, isFalse);
      });

      test('should handle duplicate task selection attempts', () {
        selectionManager.toggleTask(testTasks[0]);
        expect(selectionManager.state.selectionCount, equals(1));
        
        // Try to select the same task in selectAll
        selectionManager.selectAll([testTasks[0]]);
        expect(selectionManager.state.selectionCount, equals(1));
      });

      test('should handle selection of non-existent tasks gracefully', () {
        final nonExistentTask = TaskModel(
          id: 'nonexistent',
          title: 'Non-existent',
          createdAt: DateTime.now(),
        );
        
        expect(() => selectionManager.toggleTask(nonExistentTask), returnsNormally);
        expect(selectionManager.state.hasSelection, isTrue);
        expect(selectionManager.state.isSelected('nonexistent'), isTrue);
      });
    });

    group('Performance', () {
      test('should handle large selection efficiently', () {
        // Create a large list of tasks
        final largeTasks = List.generate(1000, (i) => TaskModel(
          id: 'task_$i',
          title: 'Task $i',
          createdAt: DateTime.now(),
        ));
        
        final stopwatch = Stopwatch()..start();
        selectionManager.selectAll(largeTasks);
        stopwatch.stop();
        
        expect(selectionManager.state.selectionCount, equals(1000));
        // Should complete within reasonable time (adjust as needed)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('should handle frequent selection changes efficiently', () {
        final stopwatch = Stopwatch()..start();
        
        // Perform many selection operations
        for (int i = 0; i < 100; i++) {
          selectionManager.toggleTask(testTasks[i % testTasks.length]);
        }
        
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });
    });
  });
}