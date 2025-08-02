import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task_model.dart';

/// Task repository interface
abstract class TaskRepository {
  Future<List<TaskModel>> getAllTasks();
  Future<TaskModel?> getTaskById(String id);
  Future<void> createTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Stream<List<TaskModel>> watchTasks();
  Future<List<TaskModel>> searchTasks(String query);
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
}

/// Task repository provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return InMemoryTaskRepository();
});