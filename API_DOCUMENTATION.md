# Tasky API Documentation

## 1. Task Repository

### Interface: `TaskRepository`
Location: `lib/domain/repositories/task_repository.dart`

```dart
abstract class TaskRepository {
  /// Creates a new task with detailed configuration
  /// 
  /// [task] The task model to be created
  /// Returns a unique task identifier
  Future<int> createTask(Task task);

  /// Retrieves tasks based on complex filtering criteria
  /// 
  /// [filter] Complex task filtering options
  /// [sortOrder] Optional sorting configuration
  /// Returns a stream of filtered tasks
  Stream<List<Task>> getTasks({
    TaskFilter? filter, 
    TaskSortOrder? sortOrder
  });

  /// Updates an existing task
  /// 
  /// [task] The updated task model
  /// Returns whether the update was successful
  Future<bool> updateTask(Task task);

  /// Deletes a task by its unique identifier
  /// 
  /// [taskId] Unique identifier of the task to delete
  Future<void> deleteTask(int taskId);
}
```

### Key Features
- Stream-based reactive task retrieval
- Complex filtering and sorting
- Type-safe task operations

## 2. Project Repository

### Interface: `ProjectRepository`
Location: `lib/domain/repositories/project_repository.dart`

```dart
abstract class ProjectRepository {
  /// Creates a new project with comprehensive details
  /// 
  /// [project] Project model to be created
  /// Returns the created project's unique identifier
  Future<int> createProject(Project project);

  /// Retrieves projects with optional filtering
  /// 
  /// [activeOnly] Filter for active projects
  /// [searchTerm] Optional search query
  Stream<List<Project>> getProjects({
    bool activeOnly = false, 
    String? searchTerm
  });

  /// Calculates comprehensive project analytics
  /// 
  /// [projectId] Unique project identifier
  /// Returns detailed project performance metrics
  Future<ProjectAnalytics> getProjectAnalytics(int projectId);
}
```

### Advanced Features
- Reactive project streams
- Built-in project analytics
- Comprehensive project management

## 3. AI Integration Repository

### Interface: `AITaskParsingRepository`
Location: `lib/domain/repositories/ai_task_repository.dart`

```dart
abstract class AITaskParsingRepository {
  /// Parses natural language into structured task
  /// 
  /// [text] Natural language task description
  /// [aiProvider] Optional AI service provider
  /// Returns a parsed and structured task model
  Future<Task> parseTaskFromNaturalLanguage(
    String text, {
    AIServiceType aiProvider = AIServiceType.openAI
  });

  /// Suggests task improvements or completions
  /// 
  /// [existingTask] Base task for AI enhancement
  /// Returns an enriched task suggestion
  Future<Task> suggestTaskEnhancements(Task existingTask);
}
```

### AI Service Capabilities
- Multi-provider AI task parsing
- Intelligent task suggestion
- Fallback mechanism for AI services

## 4. Offline Sync Repository

### Interface: `OfflineSyncRepository`
Location: `lib/domain/repositories/offline_sync_repository.dart`

```dart
abstract class OfflineSyncRepository {
  /// Synchronizes local changes with remote storage
  /// 
  /// [syncStrategy] Configurable sync approach
  /// Returns sync operation status and conflicts
  Future<SyncResult> synchronizeData({
    SyncStrategy syncStrategy = SyncStrategy.conservative
  });

  /// Resolves sync conflicts intelligently
  /// 
  /// [conflicts] List of detected sync conflicts
  /// Returns resolved data reconciliation
  Future<List<ResolvedEntity>> resolveConflicts(
    List<SyncConflict> conflicts
  );
}
```

### Sync Features
- Intelligent conflict resolution
- Configurable sync strategies
- Comprehensive sync tracking

## Performance and Error Handling

### Error Handling Strategy
- Typed exceptions for each repository
- Comprehensive error logging
- Graceful degradation with offline fallbacks

### Performance Considerations
- Asynchronous operations
- Efficient stream-based data retrieval
- Minimal overhead in repository methods

## Best Practices
- Immutable data structures
- Comprehensive error handling
- Type-safe operations
- Reactive programming paradigms