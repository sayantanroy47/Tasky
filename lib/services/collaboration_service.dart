import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';

/// Enum for collaboration permissions
enum CollaborationPermission {
  view,
  edit,
  admin,
}

/// Model for shared task list
class SharedTaskList {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final List<String> taskIds;
  final Map<String, CollaborationPermission> collaborators;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;
  final String? shareCode;

  const SharedTaskList({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.taskIds,
    required this.collaborators,
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = false,
    this.shareCode,
  });

  SharedTaskList copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    List<String>? taskIds,
    Map<String, CollaborationPermission>? collaborators,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
    String? shareCode,
  }) {
    return SharedTaskList(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      taskIds: taskIds ?? this.taskIds,
      collaborators: collaborators ?? this.collaborators,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      shareCode: shareCode ?? this.shareCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'taskIds': taskIds,
      'collaborators': collaborators.map((k, v) => MapEntry(k, v.name)),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPublic': isPublic,
      'shareCode': shareCode,
    };
  }

  factory SharedTaskList.fromJson(Map<String, dynamic> json) {
    return SharedTaskList(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ownerId: json['ownerId'],
      taskIds: List<String>.from(json['taskIds']),
      collaborators: (json['collaborators'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, CollaborationPermission.values.firstWhere(
          (p) => p.name == v,
          orElse: () => CollaborationPermission.view,
        )),
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isPublic: json['isPublic'] ?? false,
      shareCode: json['shareCode'],
    );
  }
}

/// Model for collaboration change tracking
class CollaborationChange {
  final String id;
  final String taskListId;
  final String taskId;
  final String userId;
  final String userName;
  final CollaborationChangeType changeType;
  final Map<String, dynamic> changeData;
  final DateTime timestamp;

  const CollaborationChange({
    required this.id,
    required this.taskListId,
    required this.taskId,
    required this.userId,
    required this.userName,
    required this.changeType,
    required this.changeData,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskListId': taskListId,
      'taskId': taskId,
      'userId': userId,
      'userName': userName,
      'changeType': changeType.name,
      'changeData': changeData,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CollaborationChange.fromJson(Map<String, dynamic> json) {
    return CollaborationChange(
      id: json['id'],
      taskListId: json['taskListId'],
      taskId: json['taskId'],
      userId: json['userId'],
      userName: json['userName'],
      changeType: CollaborationChangeType.values.firstWhere(
        (t) => t.name == json['changeType'],
        orElse: () => CollaborationChangeType.taskUpdated,
      ),
      changeData: json['changeData'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// Enum for collaboration change types
enum CollaborationChangeType {
  taskCreated,
  taskUpdated,
  taskCompleted,
  taskDeleted,
  collaboratorAdded,
  collaboratorRemoved,
  permissionChanged,
}

/// Service for handling task collaboration and sharing
class CollaborationService {
  static final CollaborationService _instance = CollaborationService._internal();
  factory CollaborationService() => _instance;
  CollaborationService._internal();

  final Map<String, SharedTaskList> _sharedTaskLists = {};
  final Map<String, List<CollaborationChange>> _changeHistory = {};
  final StreamController<CollaborationChange> _changeStreamController = 
      StreamController<CollaborationChange>.broadcast();

  /// Stream of collaboration changes
  Stream<CollaborationChange> get changeStream => _changeStreamController.stream;

  /// Create a shared task list
  Future<SharedTaskList> createSharedTaskList({
    required String name,
    required String description,
    required String ownerId,
    required List<String> taskIds,
    bool isPublic = false,
  }) async {
    try {
      final id = _generateId();
      final shareCode = isPublic ? _generateShareCode() : null;
      
      final sharedList = SharedTaskList(
        id: id,
        name: name,
        description: description,
        ownerId: ownerId,
        taskIds: taskIds,
        collaborators: {ownerId: CollaborationPermission.admin},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPublic: isPublic,
        shareCode: shareCode,
      );

      _sharedTaskLists[id] = sharedList;
      _changeHistory[id] = [];

      debugPrint('Created shared task list: $name');
      return sharedList;
    } catch (e) {
      debugPrint('Error creating shared task list: $e');
      rethrow;
    }
  }

  /// Get shared task list by ID
  SharedTaskList? getSharedTaskList(String id) {
    return _sharedTaskLists[id];
  }

  /// Get shared task list by share code
  SharedTaskList? getSharedTaskListByCode(String shareCode) {
    return _sharedTaskLists.values.firstWhere(
      (list) => list.shareCode == shareCode,
      orElse: () => throw Exception('Shared task list not found'),
    );
  }

  /// Get all shared task lists for a user
  List<SharedTaskList> getSharedTaskListsForUser(String userId) {
    return _sharedTaskLists.values
        .where((list) => list.collaborators.containsKey(userId))
        .toList();
  }

  /// Add collaborator to shared task list
  Future<void> addCollaborator({
    required String taskListId,
    required String userId,
    required String userName,
    required CollaborationPermission permission,
    required String requesterId,
  }) async {
    try {
      final sharedList = _sharedTaskLists[taskListId];
      if (sharedList == null) {
        throw Exception('Shared task list not found');
      }

      // Check if requester has admin permission
      if (!_hasPermission(sharedList, requesterId, CollaborationPermission.admin)) {
        throw Exception('Insufficient permissions to add collaborators');
      }

      final updatedCollaborators = Map<String, CollaborationPermission>.from(sharedList.collaborators);
      updatedCollaborators[userId] = permission;

      final updatedList = sharedList.copyWith(
        collaborators: updatedCollaborators,
        updatedAt: DateTime.now(),
      );

      _sharedTaskLists[taskListId] = updatedList;

      // Track change
      await _trackChange(
        taskListId: taskListId,
        taskId: '',
        userId: requesterId,
        userName: 'User', // In real implementation, get from user service
        changeType: CollaborationChangeType.collaboratorAdded,
        changeData: {
          'addedUserId': userId,
          'addedUserName': userName,
          'permission': permission.name,
        },
      );

      debugPrint('Added collaborator $userName to task list ${sharedList.name}');
    } catch (e) {
      debugPrint('Error adding collaborator: $e');
      rethrow;
    }
  }

  /// Remove collaborator from shared task list
  Future<void> removeCollaborator({
    required String taskListId,
    required String userId,
    required String requesterId,
  }) async {
    try {
      final sharedList = _sharedTaskLists[taskListId];
      if (sharedList == null) {
        throw Exception('Shared task list not found');
      }

      // Check if requester has admin permission
      if (!_hasPermission(sharedList, requesterId, CollaborationPermission.admin)) {
        throw Exception('Insufficient permissions to remove collaborators');
      }

      // Cannot remove the owner
      if (userId == sharedList.ownerId) {
        throw Exception('Cannot remove the owner from the shared list');
      }

      final updatedCollaborators = Map<String, CollaborationPermission>.from(sharedList.collaborators);
      updatedCollaborators.remove(userId);

      final updatedList = sharedList.copyWith(
        collaborators: updatedCollaborators,
        updatedAt: DateTime.now(),
      );

      _sharedTaskLists[taskListId] = updatedList;

      // Track change
      await _trackChange(
        taskListId: taskListId,
        taskId: '',
        userId: requesterId,
        userName: 'User',
        changeType: CollaborationChangeType.collaboratorRemoved,
        changeData: {
          'removedUserId': userId,
        },
      );

      debugPrint('Removed collaborator from task list ${sharedList.name}');
    } catch (e) {
      debugPrint('Error removing collaborator: $e');
      rethrow;
    }
  }

  /// Update collaborator permission
  Future<void> updateCollaboratorPermission({
    required String taskListId,
    required String userId,
    required CollaborationPermission newPermission,
    required String requesterId,
  }) async {
    try {
      final sharedList = _sharedTaskLists[taskListId];
      if (sharedList == null) {
        throw Exception('Shared task list not found');
      }

      // Check if requester has admin permission
      if (!_hasPermission(sharedList, requesterId, CollaborationPermission.admin)) {
        throw Exception('Insufficient permissions to change permissions');
      }

      final updatedCollaborators = Map<String, CollaborationPermission>.from(sharedList.collaborators);
      updatedCollaborators[userId] = newPermission;

      final updatedList = sharedList.copyWith(
        collaborators: updatedCollaborators,
        updatedAt: DateTime.now(),
      );

      _sharedTaskLists[taskListId] = updatedList;

      // Track change
      await _trackChange(
        taskListId: taskListId,
        taskId: '',
        userId: requesterId,
        userName: 'User',
        changeType: CollaborationChangeType.permissionChanged,
        changeData: {
          'targetUserId': userId,
          'newPermission': newPermission.name,
        },
      );

      debugPrint('Updated permission for user $userId in task list ${sharedList.name}');
    } catch (e) {
      debugPrint('Error updating collaborator permission: $e');
      rethrow;
    }
  }

  /// Add task to shared list
  Future<void> addTaskToSharedList({
    required String taskListId,
    required String taskId,
    required String userId,
  }) async {
    try {
      final sharedList = _sharedTaskLists[taskListId];
      if (sharedList == null) {
        throw Exception('Shared task list not found');
      }

      // Check if user has edit permission
      if (!_hasPermission(sharedList, userId, CollaborationPermission.edit)) {
        throw Exception('Insufficient permissions to add tasks');
      }

      final updatedTaskIds = List<String>.from(sharedList.taskIds);
      if (!updatedTaskIds.contains(taskId)) {
        updatedTaskIds.add(taskId);
      }

      final updatedList = sharedList.copyWith(
        taskIds: updatedTaskIds,
        updatedAt: DateTime.now(),
      );

      _sharedTaskLists[taskListId] = updatedList;

      // Track change
      await _trackChange(
        taskListId: taskListId,
        taskId: taskId,
        userId: userId,
        userName: 'User',
        changeType: CollaborationChangeType.taskCreated,
        changeData: {'action': 'added_to_shared_list'},
      );

      debugPrint('Added task $taskId to shared list ${sharedList.name}');
    } catch (e) {
      debugPrint('Error adding task to shared list: $e');
      rethrow;
    }
  }

  /// Remove task from shared list
  Future<void> removeTaskFromSharedList({
    required String taskListId,
    required String taskId,
    required String userId,
  }) async {
    try {
      final sharedList = _sharedTaskLists[taskListId];
      if (sharedList == null) {
        throw Exception('Shared task list not found');
      }

      // Check if user has edit permission
      if (!_hasPermission(sharedList, userId, CollaborationPermission.edit)) {
        throw Exception('Insufficient permissions to remove tasks');
      }

      final updatedTaskIds = List<String>.from(sharedList.taskIds);
      updatedTaskIds.remove(taskId);

      final updatedList = sharedList.copyWith(
        taskIds: updatedTaskIds,
        updatedAt: DateTime.now(),
      );

      _sharedTaskLists[taskListId] = updatedList;

      // Track change
      await _trackChange(
        taskListId: taskListId,
        taskId: taskId,
        userId: userId,
        userName: 'User',
        changeType: CollaborationChangeType.taskDeleted,
        changeData: {'action': 'removed_from_shared_list'},
      );

      debugPrint('Removed task $taskId from shared list ${sharedList.name}');
    } catch (e) {
      debugPrint('Error removing task from shared list: $e');
      rethrow;
    }
  }

  /// Track task changes in shared lists
  Future<void> trackTaskChange({
    required String taskId,
    required String userId,
    required CollaborationChangeType changeType,
    Map<String, dynamic>? changeData,
  }) async {
    try {
      // Find all shared lists containing this task
      final affectedLists = _sharedTaskLists.values
          .where((list) => list.taskIds.contains(taskId))
          .toList();

      for (final list in affectedLists) {
        // Check if user has permission to modify tasks in this list
        if (_hasPermission(list, userId, CollaborationPermission.edit)) {
          await _trackChange(
            taskListId: list.id,
            taskId: taskId,
            userId: userId,
            userName: 'User',
            changeType: changeType,
            changeData: changeData ?? {},
          );
        }
      }
    } catch (e) {
      debugPrint('Error tracking task change: $e');
    }
  }

  /// Get change history for a shared task list
  List<CollaborationChange> getChangeHistory(String taskListId) {
    return _changeHistory[taskListId] ?? [];
  }

  /// Generate shareable link for task list
  String generateShareableLink(String taskListId) {
    final sharedList = _sharedTaskLists[taskListId];
    if (sharedList == null) {
      throw Exception('Shared task list not found');
    }

    if (!sharedList.isPublic || sharedList.shareCode == null) {
      throw Exception('Task list is not publicly shareable');
    }

    // In a real implementation, this would be a proper URL
    return 'https://tasktracker.app/shared/${sharedList.shareCode}';
  }

  /// Join shared task list via share code
  Future<SharedTaskList> joinSharedTaskList({
    required String shareCode,
    required String userId,
    required String userName,
  }) async {
    try {
      final sharedList = getSharedTaskListByCode(shareCode);
      
      // Add user as viewer by default
      await addCollaborator(
        taskListId: sharedList.id,
        userId: userId,
        userName: userName,
        permission: CollaborationPermission.view,
        requesterId: sharedList.ownerId, // Auto-approve for public lists
      );

      return getSharedTaskList(sharedList.id)!;
    } catch (e) {
      debugPrint('Error joining shared task list: $e');
      rethrow;
    }
  }

  /// Export shared task list
  Map<String, dynamic> exportSharedTaskList(String taskListId) {
    final sharedList = _sharedTaskLists[taskListId];
    if (sharedList == null) {
      throw Exception('Shared task list not found');
    }

    final changeHistory = getChangeHistory(taskListId);

    return {
      'sharedTaskList': sharedList.toJson(),
      'changeHistory': changeHistory.map((change) => change.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Import shared task list
  Future<SharedTaskList> importSharedTaskList(Map<String, dynamic> data) async {
    try {
      final sharedListData = data['sharedTaskList'] as Map<String, dynamic>;
      final sharedList = SharedTaskList.fromJson(sharedListData);
      
      _sharedTaskLists[sharedList.id] = sharedList;
      
      if (data['changeHistory'] != null) {
        final changes = (data['changeHistory'] as List)
            .map((changeData) => CollaborationChange.fromJson(changeData))
            .toList();
        _changeHistory[sharedList.id] = changes;
      }

      debugPrint('Imported shared task list: ${sharedList.name}');
      return sharedList;
    } catch (e) {
      debugPrint('Error importing shared task list: $e');
      rethrow;
    }
  }

  /// Check if user has specific permission
  bool _hasPermission(SharedTaskList sharedList, String userId, CollaborationPermission requiredPermission) {
    final userPermission = sharedList.collaborators[userId];
    if (userPermission == null) return false;

    switch (requiredPermission) {
      case CollaborationPermission.view:
        return true; // All collaborators can view
      case CollaborationPermission.edit:
        return userPermission == CollaborationPermission.edit || 
               userPermission == CollaborationPermission.admin;
      case CollaborationPermission.admin:
        return userPermission == CollaborationPermission.admin;
    }
  }

  /// Track a collaboration change
  Future<void> _trackChange({
    required String taskListId,
    required String taskId,
    required String userId,
    required String userName,
    required CollaborationChangeType changeType,
    required Map<String, dynamic> changeData,
  }) async {
    final change = CollaborationChange(
      id: _generateId(),
      taskListId: taskListId,
      taskId: taskId,
      userId: userId,
      userName: userName,
      changeType: changeType,
      changeData: changeData,
      timestamp: DateTime.now(),
    );

    _changeHistory[taskListId] ??= [];
    _changeHistory[taskListId]!.add(change);

    // Emit change to stream
    _changeStreamController.add(change);
  }

  /// Generate unique ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Generate share code
  String _generateShareCode() {
    final bytes = utf8.encode('${DateTime.now().millisecondsSinceEpoch}');
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 8).toUpperCase();
  }

  /// Dispose resources
  void dispose() {
    _changeStreamController.close();
  }
}