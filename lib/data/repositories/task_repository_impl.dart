import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';
import '../../domain/repositories/task_repository.dart';
import '../../services/database/database.dart';

/// Concrete implementation of TaskRepository using local database
/// 
/// This implementation uses the Drift/SQLite database through the TaskDao
/// to provide all task-related operations.
class TaskRepositoryImpl implements TaskRepository {
  final AppDatabase _database;

  const TaskRepositoryImpl(this._database);
  @override
  Future<List<TaskModel>> getAllTasks() async {
    return await _database.taskDao.getAllTasks();
  }
  @override
  Future<TaskModel?> getTaskById(String id) async {
    return await _database.taskDao.getTaskById(id);
  }
  @override
  Future<void> createTask(TaskModel task) async {
    await _database.taskDao.createTask(task);
  }
  @override
  Future<void> updateTask(TaskModel task) async {
    await _database.taskDao.updateTask(task);
  }
  @override
  Future<void> deleteTask(String id) async {
    await _database.taskDao.deleteTask(id);
  }
  @override
  Future<List<TaskModel>> getTasksByStatus(TaskStatus status) async {
    return await _database.taskDao.getTasksByStatus(status);
  }
  @override
  Future<List<TaskModel>> getTasksByPriority(TaskPriority priority) async {
    return await _database.taskDao.getTasksByPriority(priority);
  }
  @override
  Future<List<TaskModel>> getTasksDueToday() async {
    return await _database.taskDao.getTasksDueToday();
  }
  @override
  Future<List<TaskModel>> getOverdueTasks() async {
    return await _database.taskDao.getOverdueTasks();
  }
  @override
  Future<List<TaskModel>> getTasksByDateRange(DateTime startDate, DateTime endDate) async {
    return await _database.taskDao.getTasksByDateRange(startDate, endDate);
  }
  @override
  Future<List<TaskModel>> getTasksByProject(String projectId) async {
    return await _database.taskDao.getTasksByProject(projectId);
  }
  @override
  Future<List<TaskModel>> searchTasks(String query) async {
    return await _database.taskDao.searchTasks(query);
  }


  @override
  Future<List<TaskModel>> getTasksWithFilter(TaskFilter filter) async {
    // Start with all tasks
    var tasks = await getAllTasks();

    // Apply filters
    if (filter.status != null) {
      tasks = tasks.where((task) => task.status == filter.status).toList();
    }

    if (filter.priority != null) {
      tasks = tasks.where((task) => task.priority == filter.priority).toList();
    }

    if (filter.tags != null && filter.tags!.isNotEmpty) {
      tasks = tasks.where((task) {
        return filter.tags!.any((tagId) => task.tags.contains(tagId));
      }).toList();
    }

    if (filter.projectId != null) {
      tasks = tasks.where((task) => task.projectId == filter.projectId).toList();
    }

    if (filter.dueDateFrom != null) {
      tasks = tasks.where((task) {
        return task.dueDate != null && task.dueDate!.isAfter(filter.dueDateFrom!);
      }).toList();
    }

    if (filter.dueDateTo != null) {
      tasks = tasks.where((task) {
        return task.dueDate != null && task.dueDate!.isBefore(filter.dueDateTo!);
      }).toList();
    }

    if (filter.isOverdue == true) {
      tasks = tasks.where((task) => task.isOverdue).toList();
    } else if (filter.isOverdue == false) {
      tasks = tasks.where((task) => !task.isOverdue).toList();
    }

    if (filter.isPinned != null) {
      tasks = tasks.where((task) => task.isPinned == filter.isPinned).toList();
    }

    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      tasks = tasks.where((task) {
        return task.title.toLowerCase().contains(query) ||
            (task.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply sorting
    tasks.sort((a, b) {
      int comparison = 0;
      
      switch (filter.sortBy) {
        case TaskSortBy.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case TaskSortBy.updatedAt:
          final aUpdated = a.updatedAt ?? a.createdAt;
          final bUpdated = b.updatedAt ?? b.createdAt;
          comparison = aUpdated.compareTo(bUpdated);
          break;
        case TaskSortBy.dueDate:
          if (a.dueDate == null && b.dueDate == null) {
            comparison = 0;
          } else if (a.dueDate == null) {
            comparison = 1;
          } else if (b.dueDate == null) {
            comparison = -1;
          } else {
            comparison = a.dueDate!.compareTo(b.dueDate!);
          }
          break;
        case TaskSortBy.priority:
          comparison = a.priority.sortValue.compareTo(b.priority.sortValue);
          break;
        case TaskSortBy.title:
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case TaskSortBy.status:
          comparison = a.status.index.compareTo(b.status.index);
          break;
      }

      return filter.sortAscending ? comparison : -comparison;
    });

    return tasks;
  }
  @override
  Stream<List<TaskModel>> watchAllTasks() {
    return _database.taskDao.watchAllTasks();
  }
  @override
  Stream<List<TaskModel>> watchTasksByStatus(TaskStatus status) {
    return _database.taskDao.watchTasksByStatus(status);
  }
  @override
  Stream<List<TaskModel>> watchTasksByProject(String projectId) {
    return watchAllTasks().map((tasks) {
      return tasks.where((task) => task.projectId == projectId).toList();
    });
  }

  @override
  Future<List<TaskModel>> getTasksByIds(List<String> ids) async {
    final tasks = await getAllTasks();
    return tasks.where((task) => ids.contains(task.id)).toList();
  }

  @override
  Future<List<TaskModel>> getTasksWithDependency(String dependencyId) async {
    final tasks = await getAllTasks();
    return tasks.where((task) => task.dependencies.contains(dependencyId)).toList();
  }
}
