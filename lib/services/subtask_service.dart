import '../domain/entities/subtask.dart';
import '../domain/repositories/subtask_repository.dart';

/// Service for managing subtask operations and business logic
class SubtaskService {
  final SubtaskRepository _repository;

  SubtaskService({required SubtaskRepository repository}) : _repository = repository;

  /// Get all subtasks for a specific task
  Future<List<SubTask>> getSubtasksForTask(String taskId) async {
    return await _repository.getSubtasksForTask(taskId);
  }

  /// Add a new subtask to a task
  Future<void> addSubtask(String taskId, String title, {int? sortOrder}) async {
    // If no sort order specified, put it at the end
    final finalSortOrder = sortOrder ?? await _getNextSortOrder(taskId);
    
    final subtask = SubTask.create(
      taskId: taskId,
      title: title.trim(),
      sortOrder: finalSortOrder,
    );

    await _repository.addSubtask(subtask);
  }

  /// Update subtask title
  Future<void> updateSubtaskTitle(String subtaskId, String newTitle) async {
    final subtask = await _repository.getSubtaskById(subtaskId);
    if (subtask != null) {
      final updatedSubtask = subtask.copyWith(title: newTitle.trim());
      await _repository.updateSubtask(updatedSubtask);
    } else {
      throw Exception('Subtask not found');
    }
  }

  /// Toggle subtask completion status
  Future<void> toggleSubtaskCompletion(String subtaskId) async {
    final subtask = await _repository.getSubtaskById(subtaskId);
    if (subtask != null) {
      final updatedSubtask = subtask.isCompleted 
          ? subtask.markIncomplete() 
          : subtask.markCompleted();
      await _repository.updateSubtask(updatedSubtask);
    } else {
      throw Exception('Subtask not found');
    }
  }

  /// Mark subtask as completed
  Future<void> completeSubtask(String subtaskId) async {
    final subtask = await _repository.getSubtaskById(subtaskId);
    if (subtask != null) {
      if (!subtask.isCompleted) {
        await _repository.updateSubtask(subtask.markCompleted());
      }
    } else {
      throw Exception('Subtask not found');
    }
  }

  /// Mark subtask as incomplete
  Future<void> uncompleteSubtask(String subtaskId) async {
    final subtask = await _repository.getSubtaskById(subtaskId);
    if (subtask != null) {
      if (subtask.isCompleted) {
        await _repository.updateSubtask(subtask.markIncomplete());
      }
    } else {
      throw Exception('Subtask not found');
    }
  }

  /// Delete a subtask
  Future<void> deleteSubtask(String subtaskId) async {
    await _repository.deleteSubtask(subtaskId);
  }

  /// Delete all subtasks for a task
  Future<void> deleteAllSubtasksForTask(String taskId) async {
    await _repository.deleteSubtasksForTask(taskId);
  }

  /// Reorder subtasks within a task
  Future<void> reorderSubtasks(String taskId, List<String> subtaskIds) async {
    await _repository.reorderSubtasks(taskId, subtaskIds);
  }

  /// Move subtask up in the list
  Future<void> moveSubtaskUp(String subtaskId) async {
    final subtask = await _repository.getSubtaskById(subtaskId);
    if (subtask == null) {
      throw Exception('Subtask not found');
    }

    final siblings = await _repository.getSubtasksForTask(subtask.taskId);
    final currentIndex = siblings.indexWhere((s) => s.id == subtaskId);
    
    if (currentIndex > 0) {
      // Swap with the previous subtask
      final reorderedIds = siblings.map((s) => s.id).toList();
      final temp = reorderedIds[currentIndex];
      reorderedIds[currentIndex] = reorderedIds[currentIndex - 1];
      reorderedIds[currentIndex - 1] = temp;
      
      await _repository.reorderSubtasks(subtask.taskId, reorderedIds);
    }
  }

  /// Move subtask down in the list
  Future<void> moveSubtaskDown(String subtaskId) async {
    final subtask = await _repository.getSubtaskById(subtaskId);
    if (subtask == null) {
      throw Exception('Subtask not found');
    }

    final siblings = await _repository.getSubtasksForTask(subtask.taskId);
    final currentIndex = siblings.indexWhere((s) => s.id == subtaskId);
    
    if (currentIndex < siblings.length - 1) {
      // Swap with the next subtask
      final reorderedIds = siblings.map((s) => s.id).toList();
      final temp = reorderedIds[currentIndex];
      reorderedIds[currentIndex] = reorderedIds[currentIndex + 1];
      reorderedIds[currentIndex + 1] = temp;
      
      await _repository.reorderSubtasks(subtask.taskId, reorderedIds);
    }
  }

  /// Get subtask statistics for a task
  Future<SubtaskStats> getSubtaskStats(String taskId) async {
    final totalCount = await _repository.getSubtaskCount(taskId);
    final completedCount = await _repository.getCompletedSubtaskCount(taskId);
    final percentage = await _repository.getSubtaskCompletionPercentage(taskId);

    return SubtaskStats(
      totalCount: totalCount,
      completedCount: completedCount,
      remainingCount: totalCount - completedCount,
      completionPercentage: percentage,
    );
  }

  /// Mark all subtasks as completed for a task
  Future<void> completeAllSubtasks(String taskId) async {
    await _repository.markAllSubtasksCompleted(taskId);
  }

  /// Mark all subtasks as incomplete for a task
  Future<void> uncompleteAllSubtasks(String taskId) async {
    await _repository.markAllSubtasksIncomplete(taskId);
  }

  /// Duplicate subtasks from one task to another
  Future<void> duplicateSubtasks(String sourceTaskId, String targetTaskId) async {
    final sourceSubtasks = await _repository.getSubtasksForTask(sourceTaskId);
    
    for (int i = 0; i < sourceSubtasks.length; i++) {
      final sourceSubtask = sourceSubtasks[i];
      final duplicatedSubtask = SubTask.create(
        taskId: targetTaskId,
        title: sourceSubtask.title,
        sortOrder: i,
      );
      
      await _repository.addSubtask(duplicatedSubtask);
    }
  }

  /// Validate subtask data
  bool validateSubtask(SubTask subtask) {
    return subtask.isValid();
  }

  /// Get the next sort order for a new subtask
  Future<int> _getNextSortOrder(String taskId) async {
    final existingSubtasks = await _repository.getSubtasksForTask(taskId);
    if (existingSubtasks.isEmpty) {
      return 0;
    }
    
    return existingSubtasks.map((s) => s.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
  }

  /// Search subtasks by title within a task
  Future<List<SubTask>> searchSubtasks(String taskId, String query) async {
    if (query.trim().isEmpty) {
      return await _repository.getSubtasksForTask(taskId);
    }

    final allSubtasks = await _repository.getSubtasksForTask(taskId);
    final searchQuery = query.toLowerCase().trim();
    
    return allSubtasks.where((subtask) =>
        subtask.title.toLowerCase().contains(searchQuery)
    ).toList();
  }
}

/// Statistics for subtasks of a task
class SubtaskStats {
  final int totalCount;
  final int completedCount;
  final int remainingCount;
  final double completionPercentage;

  const SubtaskStats({
    required this.totalCount,
    required this.completedCount,
    required this.remainingCount,
    required this.completionPercentage,
  });

  /// Whether all subtasks are completed
  bool get allCompleted => totalCount > 0 && completedCount == totalCount;

  /// Whether no subtasks are completed
  bool get noneCompleted => completedCount == 0;

  /// Whether there are any subtasks
  bool get hasSubtasks => totalCount > 0;

  @override
  String toString() {
    return 'SubtaskStats(total: $totalCount, completed: $completedCount, '
           'remaining: $remainingCount, percentage: ${completionPercentage.toStringAsFixed(1)}%)';
  }
}