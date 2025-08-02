import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/collaboration_service.dart';


/// Provider for CollaborationService
final collaborationServiceProvider = Provider<CollaborationService>((ref) {
  return CollaborationService();
});

/// Provider for shared task lists for current user
final sharedTaskListsProvider = FutureProvider<List<SharedTaskList>>((ref) async {
  final collaborationService = ref.read(collaborationServiceProvider);
  
  // In a real implementation, get current user ID from auth service
  const currentUserId = 'current_user_id';
  
  return collaborationService.getSharedTaskListsForUser(currentUserId);
});

/// Provider for a specific shared task list
final sharedTaskListProvider = Provider.family<SharedTaskList?, String>((ref, taskListId) {
  final collaborationService = ref.read(collaborationServiceProvider);
  return collaborationService.getSharedTaskList(taskListId);
});

/// Provider for collaboration changes stream
final collaborationChangesProvider = StreamProvider<CollaborationChange>((ref) {
  final collaborationService = ref.read(collaborationServiceProvider);
  return collaborationService.changeStream;
});

/// Provider for change history of a specific task list
final changeHistoryProvider = Provider.family<List<CollaborationChange>, String>((ref, taskListId) {
  final collaborationService = ref.read(collaborationServiceProvider);
  return collaborationService.getChangeHistory(taskListId);
});

/// State notifier for managing collaboration state
class CollaborationNotifier extends StateNotifier<AsyncValue<List<SharedTaskList>>> {
  final CollaborationService _collaborationService;
  final String _currentUserId;

  CollaborationNotifier(this._collaborationService, this._currentUserId) 
      : super(const AsyncValue.loading()) {
    _loadSharedLists();
  }

  Future<void> _loadSharedLists() async {
    try {
      final lists = _collaborationService.getSharedTaskListsForUser(_currentUserId);
      state = AsyncValue.data(lists);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createSharedList({
    required String name,
    required String description,
    required List<String> taskIds,
    bool isPublic = false,
  }) async {
    try {
      await _collaborationService.createSharedTaskList(
        name: name,
        description: description,
        ownerId: _currentUserId,
        taskIds: taskIds,
        isPublic: isPublic,
      );
      await _loadSharedLists();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> joinSharedList({
    required String shareCode,
    required String userName,
  }) async {
    try {
      await _collaborationService.joinSharedTaskList(
        shareCode: shareCode,
        userId: _currentUserId,
        userName: userName,
      );
      await _loadSharedLists();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addCollaborator({
    required String taskListId,
    required String userId,
    required String userName,
    required CollaborationPermission permission,
  }) async {
    try {
      await _collaborationService.addCollaborator(
        taskListId: taskListId,
        userId: userId,
        userName: userName,
        permission: permission,
        requesterId: _currentUserId,
      );
      await _loadSharedLists();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeCollaborator({
    required String taskListId,
    required String userId,
  }) async {
    try {
      await _collaborationService.removeCollaborator(
        taskListId: taskListId,
        userId: userId,
        requesterId: _currentUserId,
      );
      await _loadSharedLists();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateCollaboratorPermission({
    required String taskListId,
    required String userId,
    required CollaborationPermission newPermission,
  }) async {
    try {
      await _collaborationService.updateCollaboratorPermission(
        taskListId: taskListId,
        userId: userId,
        newPermission: newPermission,
        requesterId: _currentUserId,
      );
      await _loadSharedLists();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addTaskToSharedList({
    required String taskListId,
    required String taskId,
  }) async {
    try {
      await _collaborationService.addTaskToSharedList(
        taskListId: taskListId,
        taskId: taskId,
        userId: _currentUserId,
      );
      await _loadSharedLists();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeTaskFromSharedList({
    required String taskListId,
    required String taskId,
  }) async {
    try {
      await _collaborationService.removeTaskFromSharedList(
        taskListId: taskListId,
        taskId: taskId,
        userId: _currentUserId,
      );
      await _loadSharedLists();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void refresh() {
    _loadSharedLists();
  }
}

/// Provider for collaboration state notifier
final collaborationNotifierProvider = StateNotifierProvider<CollaborationNotifier, AsyncValue<List<SharedTaskList>>>((ref) {
  final collaborationService = ref.read(collaborationServiceProvider);
  
  // In a real implementation, get current user ID from auth service
  const currentUserId = 'current_user_id';
  
  return CollaborationNotifier(collaborationService, currentUserId);
});