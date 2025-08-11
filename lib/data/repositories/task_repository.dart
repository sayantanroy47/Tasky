import '../../domain/entities/task_model.dart';
import '../../domain/models/enums.dart';

/// Task repository interface
abstract class TaskRepository {
  Future<List<TaskModel>> getAllTasks();
  Future<TaskModel?> getTaskById(String id);
  Future<void> createTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Stream<List<TaskModel>> watchTasks();
  Future<List<TaskModel>> searchTasks(String query);
  Future<List<TaskModel>> getTasksByIds(List<String> ids);
  Future<List<TaskModel>> getTasksWithDependency(String taskId);
  Future<List<TaskModel>> getTasksByProject(String projectId);
  Future<List<TaskModel>> getTasksByStatus(TaskStatus status);
  Future<List<TaskModel>> getTasksByPriority(TaskPriority priority);
  Future<List<TaskModel>> getTasksDueToday();
  Future<List<TaskModel>> getOverdueTasks();
  Future<List<TaskModel>> getTasksByDateRange(DateTime startDate, DateTime endDate);
  Future<List<TaskModel>> getTasksWithFilter(TaskFilter filter);
  Stream<List<TaskModel>> watchAllTasks();
  Stream<List<TaskModel>> watchTasksByStatus(TaskStatus status);
  Stream<List<TaskModel>> watchTasksByProject(String projectId);
}

/// Simple in-memory task repository implementation
class InMemoryTaskRepository implements TaskRepository {
  final List<TaskModel> _tasks = [];
  @override
  Future<List<TaskModel>> getAllTasks() async {
    return List.from(_tasks);
  }
  @override
  Future<TaskModel?> getTaskById(String id) async {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }
  @override
  Future<void> createTask(TaskModel task) async {
    _tasks.add(task);
  }
  @override
  Future<void> updateTask(TaskModel task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }
  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
  }
  @override
  Stream<List<TaskModel>> watchTasks() async* {
    yield List.from(_tasks);
  }
  @override
  Future<List<TaskModel>> searchTasks(String query) async {
    return _tasks.where((task) => 
      task.title.toLowerCase().contains(query.toLowerCase()) ||
      (task.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  @override
  Future<List<TaskModel>> getTasksByIds(List<String> ids) async {
    return _tasks.where((task) => ids.contains(task.id)).toList();
  }

  @override
  Future<List<TaskModel>> getTasksWithDependency(String taskId) async {
    return _tasks.where((task) => task.dependencies.contains(taskId)).toList();
  }

  @override
  Future<List<TaskModel>> getTasksByProject(String projectId) async {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }

  @override
  Future<List<TaskModel>> getTasksByStatus(TaskStatus status) async {
    return _tasks.where((task) => task.status == status).toList();
  }

  @override
  Future<List<TaskModel>> getTasksByPriority(TaskPriority priority) async {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  @override
  Future<List<TaskModel>> getTasksDueToday() async {
    return _tasks.where((task) => task.isDueToday).toList();
  }

  @override
  Future<List<TaskModel>> getOverdueTasks() async {
    return _tasks.where((task) => task.isOverdue).toList();
  }

  @override
  Future<List<TaskModel>> getTasksByDateRange(DateTime startDate, DateTime endDate) async {
    return _tasks.where((task) => 
      task.dueDate != null && 
      task.dueDate!.isAfter(startDate) && 
      task.dueDate!.isBefore(endDate)
    ).toList();
  }

  @override
  Future<List<TaskModel>> getTasksWithFilter(TaskFilter filter) async {
    var filteredTasks = List<TaskModel>.from(_tasks);
    
    if (filter.status != null) {
      filteredTasks = filteredTasks.where((task) => task.status == filter.status).toList();
    }
    
    if (filter.priority != null) {
      filteredTasks = filteredTasks.where((task) => task.priority == filter.priority).toList();
    }
    
    if (filter.projectId != null) {
      filteredTasks = filteredTasks.where((task) => task.projectId == filter.projectId).toList();
    }
    
    return filteredTasks;
  }

  @override
  Stream<List<TaskModel>> watchAllTasks() async* {
    yield List.from(_tasks);
  }

  @override
  Stream<List<TaskModel>> watchTasksByStatus(TaskStatus status) async* {
    yield _tasks.where((task) => task.status == status).toList();
  }

  @override
  Stream<List<TaskModel>> watchTasksByProject(String projectId) async* {
    yield _tasks.where((task) => task.projectId == projectId).toList();
  }
}

