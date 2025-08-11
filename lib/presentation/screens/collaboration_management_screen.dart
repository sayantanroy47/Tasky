import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/standardized_app_bar.dart';
import '../../services/collaboration_service.dart';

class CollaborationManagementScreen extends ConsumerStatefulWidget {
  final SharedTaskList sharedList;

  const CollaborationManagementScreen({
    super.key,
    required this.sharedList,
  });
  @override
  ConsumerState<CollaborationManagementScreen> createState() => _CollaborationManagementScreenState();
}

class _CollaborationManagementScreenState extends ConsumerState<CollaborationManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CollaborationService _collaborationService = CollaborationService();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  
  List<CollaborationChange> _changeHistory = [];
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadChangeHistory();
  }
  @override
  void dispose() {
    _tabController.dispose();
    _userIdController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  Future<void> _loadChangeHistory() async {
    setState(() => _isLoading = true);
    try {
      final history = _collaborationService.getChangeHistory(widget.sharedList.id);
      setState(() {
        _changeHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load change history: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardizedAppBar(
        title: 'Manage ${widget.sharedList.name}',
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Collaborators'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
            Tab(icon: Icon(Icons.history), text: 'Activity'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCollaboratorsTab(),
          _buildSettingsTab(),
          _buildActivityTab(),
        ],
      ),
    );
  }

  Widget _buildCollaboratorsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddCollaboratorSection(),
          const SizedBox(height: 24),
          _buildCollaboratorsList(),
        ],
      ),
    );
  }

  Widget _buildAddCollaboratorSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_add, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Add Collaborator',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID or Email',
                hintText: 'Enter user identifier',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'Enter display name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addCollaborator(CollaborationPermission.view),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Add as Viewer'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addCollaborator(CollaborationPermission.edit),
                    icon: const Icon(Icons.edit),
                    label: const Text('Add as Editor'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollaboratorsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.group, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Current Collaborators',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.sharedList.collaborators.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final entry = widget.sharedList.collaborators.entries.elementAt(index);
                final userId = entry.key;
                final permission = entry.value;
                final isOwner = userId == widget.sharedList.ownerId;
                
                return _buildCollaboratorTile(userId, permission, isOwner);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollaboratorTile(String userId, CollaborationPermission permission, bool isOwner) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getPermissionColor(permission).withOpacity(0.1),
        child: Icon(
          isOwner ? Icons.star : Icons.person,
          color: _getPermissionColor(permission),
        ),
      ),
      title: Text(
        isOwner ? '$userId (Owner)' : userId,
        style: TextStyle(
          fontWeight: isOwner ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(permission.name.toUpperCase()),
      trailing: isOwner
          ? null
          : PopupMenuButton<String>(
              onSelected: (value) => _handleCollaboratorAction(value, userId, permission),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'change_to_view',
                  child: ListTile(
                    leading: Icon(Icons.visibility),
                    title: Text('Change to Viewer'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'change_to_edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Change to Editor'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'change_to_admin',
                  child: ListTile(
                    leading: Icon(Icons.admin_panel_settings),
                    title: Text('Change to Admin'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: ListTile(
                    leading: Icon(Icons.remove_circle, color: Colors.red),
                    title: Text('Remove', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildListSettingsSection(),
          const SizedBox(height: 24),
          _buildSharingSettingsSection(),
          const SizedBox(height: 24),
          _buildDangerZoneSection(),
        ],
      ),
    );
  }

  Widget _buildListSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'List Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('List Name'),
              subtitle: Text(widget.sharedList.name),
              trailing: const Icon(Icons.edit),
              onTap: () => _editListName(),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const Text('Description'),
              subtitle: Text(
                widget.sharedList.description.isEmpty 
                    ? 'No description' 
                    : widget.sharedList.description,
              ),
              trailing: const Icon(Icons.edit),
              onTap: () => _editListDescription(),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const Text('Tasks'),
              subtitle: Text('${widget.sharedList.taskIds.length} tasks in this list'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _manageListTasks(),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharingSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.share, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Sharing Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Public List'),
              subtitle: const Text('Allow others to join with a share code'),
              value: widget.sharedList.isPublic,
              onChanged: (value) => _togglePublicAccess(value),
              contentPadding: EdgeInsets.zero,
            ),
            if (widget.sharedList.isPublic && widget.sharedList.shareCode != null) ...[
              ListTile(
                title: const Text('Share Code'),
                subtitle: Text(widget.sharedList.shareCode!),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyShareCode(),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                title: const Text('Share Link'),
                subtitle: const Text('Generate shareable link'),
                trailing: const Icon(Icons.link),
                onTap: () => _generateShareLink(),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZoneSection() {
    return Card(
      color: Colors.red.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Danger Zone',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Delete Shared List'),
              subtitle: const Text('Permanently delete this shared list and remove all collaborators'),
              trailing: const Icon(Icons.delete_forever, color: Colors.red),
              onTap: () => _deleteSharedList(),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _changeHistory.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No activity yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: _changeHistory.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final change = _changeHistory[index];
                  return _buildActivityTile(change);
                },
              );
  }

  Widget _buildActivityTile(CollaborationChange change) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getChangeTypeColor(change.changeType).withOpacity(0.1),
        child: Icon(
          _getChangeTypeIcon(change.changeType),
          color: _getChangeTypeColor(change.changeType),
        ),
      ),
      title: Text(_getChangeDescription(change)),
      subtitle: Text(
        '${change.userName} • ${_formatDateTime(change.timestamp)}',
      ),
      onTap: () => _showChangeDetails(change),
    );
  }

  Color _getPermissionColor(CollaborationPermission permission) {
    switch (permission) {
      case CollaborationPermission.view:
        return Colors.blue;
      case CollaborationPermission.edit:
        return Colors.orange;
      case CollaborationPermission.admin:
        return Colors.red;
    }
  }

  Color _getChangeTypeColor(CollaborationChangeType changeType) {
    switch (changeType) {
      case CollaborationChangeType.taskCreated:
        return Colors.green;
      case CollaborationChangeType.taskUpdated:
        return Colors.blue;
      case CollaborationChangeType.taskCompleted:
        return Colors.purple;
      case CollaborationChangeType.taskDeleted:
        return Colors.red;
      case CollaborationChangeType.collaboratorAdded:
        return Colors.teal;
      case CollaborationChangeType.collaboratorRemoved:
        return Colors.orange;
      case CollaborationChangeType.permissionChanged:
        return Colors.amber;
    }
  }

  IconData _getChangeTypeIcon(CollaborationChangeType changeType) {
    switch (changeType) {
      case CollaborationChangeType.taskCreated:
        return Icons.add_task;
      case CollaborationChangeType.taskUpdated:
        return Icons.edit;
      case CollaborationChangeType.taskCompleted:
        return Icons.check_circle;
      case CollaborationChangeType.taskDeleted:
        return Icons.delete;
      case CollaborationChangeType.collaboratorAdded:
        return Icons.person_add;
      case CollaborationChangeType.collaboratorRemoved:
        return Icons.person_remove;
      case CollaborationChangeType.permissionChanged:
        return Icons.security;
    }
  }

  String _getChangeDescription(CollaborationChange change) {
    switch (change.changeType) {
      case CollaborationChangeType.taskCreated:
        return 'Created a task';
      case CollaborationChangeType.taskUpdated:
        return 'Updated a task';
      case CollaborationChangeType.taskCompleted:
        return 'Completed a task';
      case CollaborationChangeType.taskDeleted:
        return 'Deleted a task';
      case CollaborationChangeType.collaboratorAdded:
        return 'Added ${change.changeData['addedUserName']} as ${change.changeData['permission']}';
      case CollaborationChangeType.collaboratorRemoved:
        return 'Removed a collaborator';
      case CollaborationChangeType.permissionChanged:
        return 'Changed permissions to ${change.changeData['newPermission']}';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _addCollaborator(CollaborationPermission permission) async {
    final userId = _userIdController.text.trim();
    final userName = _userNameController.text.trim();

    if (userId.isEmpty || userName.isEmpty) {
      _showErrorSnackBar('Please enter both user ID and display name');
      return;
    }

    try {
      await _collaborationService.addCollaborator(
        taskListId: widget.sharedList.id,
        userId: userId,
        userName: userName,
        permission: permission,
        requesterId: 'current_user_id', // In real implementation, get from auth
      );

      _userIdController.clear();
      _userNameController.clear();
      
      // Refresh the screen
      if (mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackBar('Collaborator added successfully!');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to add collaborator: $e');
    }
  }

  void _handleCollaboratorAction(String action, String userId, CollaborationPermission currentPermission) {
    switch (action) {
      case 'change_to_view':
        _changeCollaboratorPermission(userId, CollaborationPermission.view);
        break;
      case 'change_to_edit':
        _changeCollaboratorPermission(userId, CollaborationPermission.edit);
        break;
      case 'change_to_admin':
        _changeCollaboratorPermission(userId, CollaborationPermission.admin);
        break;
      case 'remove':
        _removeCollaborator(userId);
        break;
    }
  }

  Future<void> _changeCollaboratorPermission(String userId, CollaborationPermission newPermission) async {
    try {
      await _collaborationService.updateCollaboratorPermission(
        taskListId: widget.sharedList.id,
        userId: userId,
        newPermission: newPermission,
        requesterId: 'current_user_id',
      );

      if (mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackBar('Permission updated successfully!');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update permission: $e');
    }
  }

  Future<void> _removeCollaborator(String userId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Collaborator'),
        content: const Text('Are you sure you want to remove this collaborator?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              navigator.pop();
              try {
                await _collaborationService.removeCollaborator(
                  taskListId: widget.sharedList.id,
                  userId: userId,
                  requesterId: 'current_user_id',
                );

                if (mounted) {
                  navigator.pop();
                  _showSuccessSnackBar('Collaborator removed successfully!');
                }
              } catch (e) {
                if (mounted) {
                  _showErrorSnackBar('Failed to remove collaborator: $e');
                }
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editListName() {
    // Show dialog to edit list name
    _showSuccessSnackBar('Edit list name functionality coming soon!');
  }

  void _editListDescription() {
    // Show dialog to edit list description
    _showSuccessSnackBar('Edit list description functionality coming soon!');
  }

  void _manageListTasks() {
    // Navigate to task management screen
    _showSuccessSnackBar('Task management functionality coming soon!');
  }

  void _togglePublicAccess(bool isPublic) {
    // Toggle public access
    _showSuccessSnackBar('Toggle public access functionality coming soon!');
  }

  void _copyShareCode() {
    if (widget.sharedList.shareCode != null) {
      Clipboard.setData(ClipboardData(text: widget.sharedList.shareCode!));
      _showSuccessSnackBar('Share code copied to clipboard!');
    }
  }

  void _generateShareLink() {
    try {
      final shareLink = _collaborationService.generateShareableLink(widget.sharedList.id);
      Clipboard.setData(ClipboardData(text: shareLink));
      _showSuccessSnackBar('Share link copied to clipboard!');
    } catch (e) {
      _showErrorSnackBar('Failed to generate share link: $e');
    }
  }

  void _deleteSharedList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shared List'),
        content: const Text(
          'Are you sure you want to delete this shared list? '
          'This action cannot be undone and will remove all collaborators.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              _showSuccessSnackBar('Delete shared list functionality coming soon!');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showChangeDetails(CollaborationChange change) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getChangeDescription(change)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('User: ${change.userName}'),
            Text('Time: ${change.timestamp}'),
            if (change.changeData.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Details:'),
              ...change.changeData.entries.map(
                (entry) => Text('${entry.key}: ${entry.value}'),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}