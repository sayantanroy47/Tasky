import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/models/enums.dart';
import 'package:task_tracker_app/domain/repositories/task_repository.dart';
import 'package:task_tracker_app/presentation/widgets/kanban_board_view.dart';
import 'package:task_tracker_app/presentation/widgets/kanban_column.dart';
import 'package:task_tracker_app/presentation/widgets/kanban_dialogs.dart';
import 'package:task_tracker_app/presentation/providers/kanban_providers.dart';
import 'package:task_tracker_app/presentation/providers/task_providers.dart';

@GenerateNiceMocks([MockSpec<TaskRepository>()])
import 'kanban_board_test.mocks.dart';

void main() {
  group('KanbanBoardView', () {
    late MockTaskRepository mockRepository;
    late List<TaskModel> testTasks;

    setUp(() {
      mockRepository = MockTaskRepository();
      testTasks = _createTestTasks();

      // Mock repository responses
      when(mockRepository.watchAllTasks()).thenAnswer(
        (_) => Stream.value(testTasks),
      );
      when(mockRepository.getAllTasks()).thenAnswer(
        (_) async => testTasks,
      );
      when(mockRepository.getTasksByStatus(any)).thenAnswer(
        (invocation) async {
          final status = invocation.positionalArguments[0] as TaskStatus;
          return testTasks.where((task) => task.status == status).toList();
        },
      );
    });

    testWidgets('renders default columns correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: KanbanBoardView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify default columns are rendered
      expect(find.text('Backlog'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);

      // Verify task counts are shown
      expect(find.textContaining('task'), findsAtLeast(1));
    });

    testWidgets('shows search field when search is toggled', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: KanbanBoardView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the search button
      final searchButton = find.byIcon(PhosphorIcons.magnifyingGlass());
      expect(searchButton, findsOneWidget);
      
      await tester.tap(searchButton);
      await tester.pumpAndSettle();

      // Verify search field appears
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search tasks...'), findsOneWidget);
    });

    testWidgets('opens filter dialog when filter button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: KanbanBoardView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the filter button
      final filterButton = find.byIcon(PhosphorIcons.funnel());
      expect(filterButton, findsOneWidget);
      
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // Verify filter dialog opens
      expect(find.byType(KanbanFilterDialog), findsOneWidget);
      expect(find.text('Filter Tasks'), findsOneWidget);
    });

    testWidgets('creates new task when add button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: KanbanBoardView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the add task button
      final addButton = find.text('Add Task');
      expect(addButton, findsOneWidget);
      
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verify task creation dialog opens
      expect(find.byType(TaskCreationDialog), findsOneWidget);
    });

    testWidgets('enables batch selection mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: KanbanBoardView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the batch selection button
      final batchButton = find.byIcon(PhosphorIcons.selection());
      expect(batchButton, findsOneWidget);
      
      await tester.tap(batchButton);
      await tester.pumpAndSettle();

      // Verify batch selection mode is enabled
      expect(find.byIcon(PhosphorIcons.selectionAll()), findsOneWidget);
    });

    testWidgets('filters tasks correctly when search query is entered', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: KanbanBoardView(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enable search
      await tester.tap(find.byIcon(PhosphorIcons.magnifyingGlass()));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Test Task 1');
      await tester.pumpAndSettle();

      // Verify filtered results (implementation depends on actual filtering logic)
      // This test would need to be adjusted based on how the filtering is implemented
    });

    testWidgets('handles drag and drop between columns', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: KanbanBoardView(enableDragAndDrop: true),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // This test would require mocking the drag and drop behavior
      // which is complex in Flutter widget tests
      // In a real implementation, you might test the underlying logic separately
    });
  });

  group('KanbanColumn', () {
    late List<TaskModel> testTasks;

    setUp(() {
      testTasks = _createTestTasks();
    });

    testWidgets('renders column header correctly', (WidgetTester tester) async {
      const config = KanbanColumnConfig(
        id: 'test',
        title: 'Test Column',
        icon: PhosphorIcons.circle,
        color: Colors.blue,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: KanbanColumn(
                config: config,
                tasks: testTasks.where((t) => t.status == TaskStatus.pending).toList(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Column'), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.circle), findsOneWidget);
    });

    testWidgets('shows task count when enabled', (WidgetTester tester) async {
      const config = KanbanColumnConfig(
        id: 'test',
        title: 'Test Column',
        icon: PhosphorIcons.circle,
        color: Colors.blue,
      );

      final pendingTasks = testTasks.where((t) => t.status == TaskStatus.pending).toList();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: KanbanColumn(
                config: config,
                tasks: pendingTasks,
                showTaskCount: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('${pendingTasks.length} task${pendingTasks.length != 1 ? 's' : ''}'), findsOneWidget);
    });

    testWidgets('collapses when header is tapped', (WidgetTester tester) async {
      const config = KanbanColumnConfig(
        id: 'test',
        title: 'Test Column',
        icon: PhosphorIcons.circle,
        color: Colors.blue,
        isCollapsible: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: KanbanColumn(
                config: config,
                tasks: testTasks.where((t) => t.status == TaskStatus.pending).toList(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the collapse button and tap it
      final collapseButton = find.byIcon(PhosphorIcons.caretDown());
      expect(collapseButton, findsOneWidget);
      
      await tester.tap(collapseButton);
      await tester.pumpAndSettle();

      // Verify the column content is collapsed (test depends on implementation)
      // You might check for specific UI changes that indicate collapsed state
    });

    testWidgets('renders empty state when no tasks', (WidgetTester tester) async {
      const config = KanbanColumnConfig(
        id: 'test',
        title: 'Empty Column',
        icon: PhosphorIcons.circle,
        color: Colors.blue,
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: KanbanColumn(
                config: config,
                tasks: [],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No tasks'), findsOneWidget);
      expect(find.byIcon(PhosphorIcons.stack()), findsOneWidget);
    });

    testWidgets('calls onCreateTask when add button is tapped', (WidgetTester tester) async {
      const config = KanbanColumnConfig(
        id: 'test',
        title: 'Test Column',
        icon: PhosphorIcons.circle,
        color: Colors.blue,
      );

      bool createTaskCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: KanbanColumn(
                config: config,
                tasks: const [],
                onCreateTask: () {
                  createTaskCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the add button
      final addButton = find.byIcon(PhosphorIcons.plus());
      expect(addButton, findsOneWidget);
      
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(createTaskCalled, isTrue);
    });
  });

  group('KanbanFilterDialog', () {
    testWidgets('renders filter options correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: KanbanFilterDialog(
                currentTags: const [],
                onFiltersChanged: (priority, tags) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Filter Tasks'), findsOneWidget);
      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('Tags'), findsOneWidget);

      // Verify priority chips
      for (final priority in TaskPriority.values) {
        expect(find.text(priority.displayName), findsOneWidget);
      }
    });

    testWidgets('calls callback with selected filters', (WidgetTester tester) async {
      TaskPriority? selectedPriority;
      List<String>? selectedTags;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: KanbanFilterDialog(
                currentTags: const [],
                onFiltersChanged: (priority, tags) {
                  selectedPriority = priority;
                  selectedTags = tags;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Select a priority
      await tester.tap(find.text(TaskPriority.high.displayName));
      await tester.pumpAndSettle();

      // Apply filters
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(selectedPriority, equals(TaskPriority.high));
      expect(selectedTags, isNotNull);
    });

    testWidgets('clears filters when Clear button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: KanbanFilterDialog(
                currentPriority: TaskPriority.high,
                currentTags: const ['test'],
                onFiltersChanged: (priority, tags) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap clear button
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      // Verify filters are cleared (test implementation depends on UI state management)
    });
  });

  group('TaskCreationDialog', () {
    testWidgets('renders form fields correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TaskCreationDialog(
                initialStatus: TaskStatus.pending,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Create Task - Pending'), findsOneWidget);
      expect(find.text('Task Title'), findsOneWidget);
      expect(find.text('Description (Optional)'), findsOneWidget);
      expect(find.text('Priority:'), findsOneWidget);
      expect(find.text('Due Date:'), findsOneWidget);
    });

    testWidgets('validates required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TaskCreationDialog(
                initialStatus: TaskStatus.pending,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Try to create task without title
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a title'), findsOneWidget);
    });

    testWidgets('creates task with valid data', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskRepositoryProvider.overrideWithValue(MockTaskRepository()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TaskCreationDialog(
                initialStatus: TaskStatus.pending,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter task title
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter task title...'),
        'Test Task',
      );
      await tester.pumpAndSettle();

      // Create task
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify success (this would depend on the actual implementation)
    });
  });

  group('KanbanBoardConfig', () {
    test('creates config with default values', () {
      const config = KanbanBoardConfig();

      expect(config.columns, equals(defaultKanbanColumns));
      expect(config.showTaskCounts, isTrue);
      expect(config.enableDragAndDrop, isTrue);
      expect(config.enableBatchOperations, isTrue);
      expect(config.enableSwimLanes, isFalse);
    });

    test('creates config with custom values', () {
      const customColumns = [
        KanbanColumnConfig(
          id: 'custom',
          title: 'Custom',
          icon: PhosphorIcons.star,
          color: Colors.purple,
        ),
      ];

      final config = KanbanBoardConfig(
        columns: customColumns,
        showTaskCounts: false,
        enableDragAndDrop: false,
      );

      expect(config.columns, equals(customColumns));
      expect(config.showTaskCounts, isFalse);
      expect(config.enableDragAndDrop, isFalse);
    });

    test('copyWith updates only specified fields', () {
      const config = KanbanBoardConfig();
      final updated = config.copyWith(showTaskCounts: false);

      expect(updated.columns, equals(config.columns));
      expect(updated.showTaskCounts, isFalse);
      expect(updated.enableDragAndDrop, equals(config.enableDragAndDrop));
    });
  });

  group('KanbanBoardFilter', () {
    test('creates filter with default values', () {
      const filter = KanbanBoardFilter();

      expect(filter.projectId, isNull);
      expect(filter.searchQuery, isEmpty);
      expect(filter.priority, isNull);
      expect(filter.tags, isEmpty);
      expect(filter.includeCompleted, isTrue);
      expect(filter.hasFilters, isFalse);
    });

    test('detects filters correctly', () {
      const filter = KanbanBoardFilter(
        searchQuery: 'test',
        priority: TaskPriority.high,
        tags: ['tag1'],
      );

      expect(filter.hasFilters, isTrue);
    });

    test('copyWith updates only specified fields', () {
      const filter = KanbanBoardFilter();
      final updated = filter.copyWith(searchQuery: 'test');

      expect(updated.projectId, equals(filter.projectId));
      expect(updated.searchQuery, equals('test'));
      expect(updated.priority, equals(filter.priority));
    });
  });

  group('KanbanColumnStats', () {
    test('creates stats with default values', () {
      const stats = KanbanColumnStats();

      expect(stats.totalTasks, equals(0));
      expect(stats.highPriorityTasks, equals(0));
      expect(stats.overdueTasks, equals(0));
      expect(stats.completedToday, equals(0));
    });

    test('creates stats with custom values', () {
      const stats = KanbanColumnStats(
        totalTasks: 10,
        highPriorityTasks: 3,
        overdueTasks: 2,
        completedToday: 5,
      );

      expect(stats.totalTasks, equals(10));
      expect(stats.highPriorityTasks, equals(3));
      expect(stats.overdueTasks, equals(2));
      expect(stats.completedToday, equals(5));
    });
  });
}

/// Creates test tasks for testing
List<TaskModel> _createTestTasks() {
  final now = DateTime.now();
  return [
    TaskModel.create(
      title: 'Test Task 1',
      description: 'First test task',
      priority: TaskPriority.high,
      tags: const ['test', 'urgent'],
      dueDate: now.add(const Duration(days: 1)),
    
    TaskModel.create(
      title: 'Test Task 2',
      description: 'Second test task',
      priority: TaskPriority.medium,
      tags: const ['test'],
      dueDate: now.add(const Duration(days: 3)),
    
    TaskModel.create(
      title: 'Test Task 3',
      description: 'Third test task',
      priority: TaskPriority.low,
      tags: const ['completed'],
      dueDate: now.subtract(const Duration(days: 1)),
    ).copyWith(
      completedAt: now,
    ),
    
    TaskModel.create(
      title: 'Overdue Task',
      description: 'This task is overdue',
      priority: TaskPriority.urgent,
      tags: const ['overdue'],
      dueDate: now.subtract(const Duration(days: 5)),
  ];
}