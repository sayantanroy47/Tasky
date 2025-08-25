import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../services/collaboration_service.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/standardized_spacing.dart';
import '../widgets/standardized_text.dart';

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
          tabs: [
            Tab(icon: Icon(PhosphorIcons.users()), text: 'Collaborators'),
            Tab(icon: Icon(PhosphorIcons.gear()), text: 'Settings'),
            Tab(icon: Icon(PhosphorIcons.clockCounterClockwise()), text: 'Activity'),
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
      padding: StandardizedSpacing.padding(SpacingSize.md),
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
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIcons.userPlus(), color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const StandardizedText(
                  'Add Collaborator',
                  style: StandardizedTextStyle.titleMedium,
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
                    icon: Icon(PhosphorIcons.eye()),
                    label: const StandardizedText('Add as Viewer', style: StandardizedTextStyle.buttonText),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addCollaborator(CollaborationPermission.edit),
                    icon: Icon(PhosphorIcons.pencil()),
                    label: const StandardizedText('Add as Editor', style: StandardizedTextStyle.buttonText),
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
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIcons.users(), color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const StandardizedText(
                  'Current Collaborators',
                  style: StandardizedTextStyle.titleMedium,
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
        backgroundColor: _getPermissionColor(permission).withValues(alpha: 0.1),
        child: Icon(
          isOwner ? PhosphorIcons.star() : PhosphorIcons.user(),
          color: _getPermissionColor(permission),
        ),
      ),
      title: StandardizedText(
        isOwner ? '$userId (Owner)' : userId,
        style: isOwner ? StandardizedTextStyle.titleSmall : StandardizedTextStyle.bodyMedium,
      ),
      subtitle: StandardizedText(permission.name.toUpperCase(), style: StandardizedTextStyle.bodySmall),
      trailing: isOwner
          ? null
          : PopupMenuButton<String>(
              onSelected: (value) => _handleCollaboratorAction(value, userId, permission),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'change_to_view',
                  child: ListTile(
                    leading: Icon(PhosphorIcons.eye()),
                    title: const StandardizedText('Change to Viewer', style: StandardizedTextStyle.bodyMedium),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'change_to_edit',
                  child: ListTile(
                    leading: Icon(PhosphorIcons.pencil()),
                    title: const StandardizedText('Change to Editor', style: StandardizedTextStyle.bodyMedium),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'change_to_admin',
                  child: ListTile(
                    leading: Icon(PhosphorIcons.shieldCheck()),
                    title: const StandardizedText('Change to Admin', style: StandardizedTextStyle.bodyMedium),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'remove',
                  child: ListTile(
                    leading: Icon(PhosphorIcons.minusCircle(), color: Colors.red),
                    title: const StandardizedText('Remove', style: StandardizedTextStyle.bodyMedium, color: Colors.red),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: StandardizedSpacing.padding(SpacingSize.md),
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
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIcons.gear(), color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const StandardizedText(
                  'List Settings',
                  style: StandardizedTextStyle.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const StandardizedText('List Name', style: StandardizedTextStyle.bodyMedium),
              subtitle: StandardizedText(widget.sharedList.name, style: StandardizedTextStyle.bodySmall),
              trailing: Icon(PhosphorIcons.pencil()),
              onTap: () => _editListName(),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const StandardizedText('Description', style: StandardizedTextStyle.bodyMedium),
              subtitle: StandardizedText(
                widget.sharedList.description.isEmpty ? 'No description' : widget.sharedList.description,
                style: StandardizedTextStyle.bodySmall,
              ),
              trailing: Icon(PhosphorIcons.pencil()),
              onTap: () => _editListDescription(),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const StandardizedText('Tasks', style: StandardizedTextStyle.bodyMedium),
              subtitle: StandardizedText('${widget.sharedList.taskIds.length} tasks in this list', style: StandardizedTextStyle.bodySmall),
              trailing: Icon(PhosphorIcons.caretRight()),
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
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIcons.share(), color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const StandardizedText(
                  'Sharing Settings',
                  style: StandardizedTextStyle.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const StandardizedText('Public List', style: StandardizedTextStyle.bodyMedium),
              subtitle: const StandardizedText('Allow others to join with a share code', style: StandardizedTextStyle.bodySmall),
              value: widget.sharedList.isPublic,
              onChanged: (value) => _togglePublicAccess(value),
              contentPadding: EdgeInsets.zero,
            ),
            if (widget.sharedList.isPublic && widget.sharedList.shareCode != null) ...[
              ListTile(
                title: const StandardizedText('Share Code', style: StandardizedTextStyle.bodyMedium),
                subtitle: StandardizedText(widget.sharedList.shareCode!, style: StandardizedTextStyle.bodySmall),
                trailing: IconButton(
                  icon: Icon(PhosphorIcons.copy()),
                  onPressed: () => _copyShareCode(),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                title: const StandardizedText('Share Link', style: StandardizedTextStyle.bodyMedium),
                subtitle: const StandardizedText('Generate shareable link', style: StandardizedTextStyle.bodySmall),
                trailing: Icon(PhosphorIcons.link()),
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
      color: Colors.red.withValues(alpha: 0.05),
      child: Padding(
        padding: StandardizedSpacing.padding(SpacingSize.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIcons.warning(), color: Colors.red),
                const SizedBox(width: 8),
                const StandardizedText(
                  'Danger Zone',
                  style: StandardizedTextStyle.titleMedium,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const StandardizedText('Delete Shared List', style: StandardizedTextStyle.bodyMedium),
              subtitle: const StandardizedText('Permanently delete this shared list and remove all collaborators', style: StandardizedTextStyle.bodySmall),
              trailing: Icon(PhosphorIcons.trash(), color: Colors.red),
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
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIcons.clockCounterClockwise(), size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const StandardizedText(
                      'No activity yet',
                      style: StandardizedTextStyle.titleMedium,
                      color: Colors.grey,
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: StandardizedSpacing.padding(SpacingSize.md),
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
        backgroundColor: _getChangeTypeColor(change.changeType).withValues(alpha: 0.1),
        child: Icon(
          _getChangeTypeIcon(change.changeType),
          color: _getChangeTypeColor(change.changeType),
        ),
      ),
      title: StandardizedText(_getChangeDescription(change), style: StandardizedTextStyle.bodyMedium),
      subtitle: StandardizedText(
        '${change.userName} • ${_formatDateTime(change.timestamp)}',
        style: StandardizedTextStyle.bodySmall,
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
        return PhosphorIcons.plus();
      case CollaborationChangeType.taskUpdated:
        return PhosphorIcons.pencil();
      case CollaborationChangeType.taskCompleted:
        return PhosphorIcons.checkCircle();
      case CollaborationChangeType.taskDeleted:
        return PhosphorIcons.trash();
      case CollaborationChangeType.collaboratorAdded:
        return PhosphorIcons.userPlus();
      case CollaborationChangeType.collaboratorRemoved:
        return PhosphorIcons.userMinus();
      case CollaborationChangeType.permissionChanged:
        return PhosphorIcons.shield();
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
        title: const StandardizedText('Remove Collaborator', style: StandardizedTextStyle.titleMedium),
        content: const StandardizedText('Are you sure you want to remove this collaborator?', style: StandardizedTextStyle.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const StandardizedText('Cancel', style: StandardizedTextStyle.buttonText),
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
            child: const StandardizedText('Remove', style: StandardizedTextStyle.buttonText, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _editListName() {
    showDialog(
      context: context,
      builder: (context) => _EditListNameDialog(
        currentName: widget.sharedList.name,
        onSave: (newName) async {
          try {
            final currentList = _collaborationService.getSharedTaskList(widget.sharedList.id);
            if (currentList != null) {
              currentList.copyWith(name: newName, updatedAt: DateTime.now());
              // In a real implementation, this would update the storage
              debugPrint('List name updated to: $newName');
            }
            if (mounted) {
              Navigator.of(context).pop();
              _showSuccessSnackBar('List name updated successfully!');
            }
          } catch (e) {
            _showErrorSnackBar('Failed to update list name: $e');
          }
        },
      ),
    );
  }

  void _editListDescription() {
    showDialog(
      context: context,
      builder: (context) => _EditListDescriptionDialog(
        currentDescription: widget.sharedList.description,
        onSave: (newDescription) async {
          try {
            final currentList = _collaborationService.getSharedTaskList(widget.sharedList.id);
            if (currentList != null) {
              currentList.copyWith(description: newDescription, updatedAt: DateTime.now());
              // In a real implementation, this would update the storage
              debugPrint('List description updated to: $newDescription');
            }
            if (mounted) {
              Navigator.of(context).pop();
              _showSuccessSnackBar('List description updated successfully!');
            }
          } catch (e) {
            _showErrorSnackBar('Failed to update list description: $e');
          }
        },
      ),
    );
  }

  void _manageListTasks() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _SharedTaskListTasksScreen(
          sharedList: widget.sharedList,
          collaborationService: _collaborationService,
        ),
      ),
    );
  }

  void _togglePublicAccess(bool isPublic) async {
    try {
      final currentList = _collaborationService.getSharedTaskList(widget.sharedList.id);
      if (currentList != null) {
        currentList.copyWith(isPublic: isPublic, updatedAt: DateTime.now());
        // In a real implementation, this would update the storage
        debugPrint('List visibility updated: ${isPublic ? "public" : "private"}');
      }
      if (mounted) {
        _showSuccessSnackBar(
          isPublic ? 'List is now public' : 'List is now private',
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update list visibility: $e');
    }
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
        title: const StandardizedText('Delete Shared List', style: StandardizedTextStyle.titleMedium),
        content: const StandardizedText(
          'Are you sure you want to delete this shared list? '
          'This action cannot be undone and will remove all collaborators.',
          style: StandardizedTextStyle.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const StandardizedText('Cancel', style: StandardizedTextStyle.buttonText),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              navigator.pop();
              try {
                // In a real implementation, this would delete from storage
                debugPrint('Shared list ${widget.sharedList.id} deleted');
                navigator.pop();
                if (mounted) {
                  _showSuccessSnackBar('Shared list deleted successfully!');
                }
              } catch (e) {
                if (mounted) {
                  _showErrorSnackBar('Failed to delete shared list: $e');
                }
              }
            },
            child: const StandardizedText('Delete', style: StandardizedTextStyle.buttonText, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showChangeDetails(CollaborationChange change) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: StandardizedText(_getChangeDescription(change), style: StandardizedTextStyle.bodyMedium),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            StandardizedText('User: ${change.userName}', style: StandardizedTextStyle.bodyMedium),
            StandardizedText('Time: ${change.timestamp}', style: StandardizedTextStyle.bodyMedium),
            if (change.changeData.isNotEmpty) ...[
              const SizedBox(height: 8),
              const StandardizedText('Details:', style: StandardizedTextStyle.titleSmall),
              ...change.changeData.entries.map(
                (entry) => StandardizedText('${entry.key}: ${entry.value}', style: StandardizedTextStyle.bodySmall),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const StandardizedText('Close', style: StandardizedTextStyle.buttonText),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: StandardizedText(message, style: StandardizedTextStyle.bodyMedium),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: StandardizedText(message, style: StandardizedTextStyle.bodyMedium),
        backgroundColor: Colors.red,
      ),
    );
  }
}

/// Dialog for editing list name
class _EditListNameDialog extends StatefulWidget {
  final String currentName;
  final Function(String) onSave;

  const _EditListNameDialog({
    required this.currentName,
    required this.onSave,
  });

  @override
  State<_EditListNameDialog> createState() => _EditListNameDialogState();
}

class _EditListNameDialogState extends State<_EditListNameDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const StandardizedText('Edit List Name', style: StandardizedTextStyle.titleMedium),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'List Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a list name';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const StandardizedText('Cancel', style: StandardizedTextStyle.buttonText),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(_controller.text.trim());
            }
          },
          child: const StandardizedText('Save', style: StandardizedTextStyle.buttonText),
        ),
      ],
    );
  }
}

/// Dialog for editing list description
class _EditListDescriptionDialog extends StatefulWidget {
  final String currentDescription;
  final Function(String) onSave;

  const _EditListDescriptionDialog({
    required this.currentDescription,
    required this.onSave,
  });

  @override
  State<_EditListDescriptionDialog> createState() => _EditListDescriptionDialogState();
}

class _EditListDescriptionDialogState extends State<_EditListDescriptionDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentDescription);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const StandardizedText('Edit List Description', style: StandardizedTextStyle.titleMedium),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Description',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const StandardizedText('Cancel', style: StandardizedTextStyle.buttonText),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_controller.text.trim());
          },
          child: const StandardizedText('Save', style: StandardizedTextStyle.buttonText),
        ),
      ],
    );
  }
}

/// Screen for managing tasks in a shared list
class _SharedTaskListTasksScreen extends StatelessWidget {
  final SharedTaskList sharedList;
  final CollaborationService collaborationService;

  const _SharedTaskListTasksScreen({
    required this.sharedList,
    required this.collaborationService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StandardizedText('Tasks in ${sharedList.name}', style: StandardizedTextStyle.titleLarge),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sharedList.taskIds.length,
        itemBuilder: (context, index) {
          final taskId = sharedList.taskIds[index];
          return Card(
            child: ListTile(
              title: StandardizedText('Task $taskId', style: StandardizedTextStyle.bodyMedium),
              subtitle: const StandardizedText('Task details would be loaded from task service', style: StandardizedTextStyle.bodySmall),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'remove') {
                    _removeTaskFromList(context, taskId);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'remove',
                    child: ListTile(
                      leading: Icon(PhosphorIcons.minusCircle(), color: Colors.red),
                      title: const StandardizedText('Remove from list', style: StandardizedTextStyle.bodyMedium),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _removeTaskFromList(BuildContext context, String taskId) async {
    try {
      await collaborationService.removeTaskFromSharedList(
        taskListId: sharedList.id,
        taskId: taskId,
        userId: 'current_user_id',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: StandardizedText('Task removed from shared list', style: StandardizedTextStyle.bodyMedium),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: StandardizedText('Failed to remove task: $e', style: StandardizedTextStyle.bodyMedium),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
