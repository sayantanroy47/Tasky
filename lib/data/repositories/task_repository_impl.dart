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
  Future<TaskModel?> updateTaskSafely(TaskModel task) async {
    return await _database.taskDao.updateTaskSafely(task);
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
    // Use database-level filtering for better performance
    return await _database.taskDao.getTasksWithFilter(filter);
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
    return await _database.taskDao.getTasksByIds(ids);
  }

  @override
  Future<List<TaskModel>> getTasksWithDependency(String dependencyId) async {
    return await _database.taskDao.getTasksWithDependency(dependencyId);
  }

  // Bulk Operations
  
  @override
  Future<void> deleteTasks(List<String> taskIds) async {
    await _database.taskDao.deleteTasks(taskIds);
  }
  
  @override
  Future<void> updateTasksStatus(List<String> taskIds, TaskStatus status) async {
    await _database.taskDao.updateTasksStatus(taskIds, status);
  }
  
  @override
  Future<void> updateTasksPriority(List<String> taskIds, TaskPriority priority) async {
    await _database.taskDao.updateTasksPriority(taskIds, priority);
  }
  
  @override
  Future<void> assignTasksToProject(List<String> taskIds, String? projectId) async {
    await _database.taskDao.assignTasksToProject(taskIds, projectId);
  }
}
