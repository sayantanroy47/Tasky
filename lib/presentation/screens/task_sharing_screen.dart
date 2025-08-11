import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/standardized_app_bar.dart';
import '../../core/theme/typography_constants.dart';
import '../../services/collaboration_service.dart';
import 'collaboration_management_screen.dart';

class TaskSharingScreen extends ConsumerStatefulWidget {
  final String? taskId;
  final List<String>? taskIds;

  const TaskSharingScreen({
    super.key,
    this.taskId,
    this.taskIds,
  });
  @override
  ConsumerState<TaskSharingScreen> createState() => _TaskSharingScreenState();
}

class _TaskSharingScreenState extends ConsumerState<TaskSharingScreen> {
  final CollaborationService _collaborationService = CollaborationService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _shareCodeController = TextEditingController();
  
  List<SharedTaskList> _sharedLists = [];
  bool _isLoading = false;
  bool _isPublic = false;
  @override
  void initState() {
    super.initState();
    _loadSharedLists();
  }
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _shareCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadSharedLists() async {
    setState(() => _isLoading = true);
    try {
      // In a real implementation, get current user ID from auth service
      const currentUserId = 'current_user_id';
      final lists = _collaborationService.getSharedTaskListsForUser(currentUserId);
      setState(() {
        _sharedLists = lists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load shared lists: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StandardizedAppBar(
        title: 'Task Sharing & Collaboration',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.taskId != null || widget.taskIds != null) ...[
                    _buildCreateSharedListSection(),
                    const SizedBox(height: 24),
                  ],
                  _buildJoinSharedListSection(),
                  const SizedBox(height: 24),
                  _buildExistingSharedListsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildCreateSharedListSection() {
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
                  'Create Shared Task List',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'List Name',
                hintText: 'Enter a name for the shared list',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Public List'),
              subtitle: const Text('Allow others to join with a share code'),
              value: _isPublic,
              onChanged: (value) => setState(() => _isPublic = value),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createSharedList,
                icon: const Icon(Icons.create),
                label: const Text('Create Shared List'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinSharedListSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.group_add, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Join Shared List',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _shareCodeController,
              decoration: const InputDecoration(
                labelText: 'Share Code',
                hintText: 'Enter the 8-character share code',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 8,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _joinSharedList,
                icon: const Icon(Icons.login),
                label: const Text('Join Shared List'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingSharedListsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Your Shared Lists',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_sharedLists.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.folder_open, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No shared lists yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _sharedLists.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final sharedList = _sharedLists[index];
                  return _buildSharedListTile(sharedList);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharedListTile(SharedTaskList sharedList) {
    const currentUserId = 'current_user_id'; // In real implementation, get from auth
    final userPermission = sharedList.collaborators[currentUserId] ?? CollaborationPermission.view;
    final isOwner = sharedList.ownerId == currentUserId;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Icon(
          sharedList.isPublic ? Icons.public : Icons.group,
          color: Theme.of(context).primaryColor,
        ),
      ),
      title: Text(
        sharedList.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sharedList.description.isNotEmpty)
            Text(sharedList.description),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.people, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${sharedList.collaborators.length} collaborators',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(width: 12),
              Icon(Icons.task, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${sharedList.taskIds.length} tasks',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getPermissionColor(userPermission).withOpacity(0.1),
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            ),
            child: Text(
              isOwner ? 'Owner' : userPermission.name.toUpperCase(),
              style: TextStyle(
                color: _getPermissionColor(userPermission),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleSharedListAction(value, sharedList),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'view',
            child: ListTile(
              leading: Icon(Icons.visibility),
              title: Text('View Details'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (sharedList.isPublic)
            const PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Share Link'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          if (userPermission == CollaborationPermission.admin)
            const PopupMenuItem(
              value: 'manage',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Manage'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          const PopupMenuItem(
            value: 'export',
            child: ListTile(
              leading: Icon(Icons.download),
              title: Text('Export'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (!isOwner)
            const PopupMenuItem(
              value: 'leave',
              child: ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.red),
                title: Text('Leave', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
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

  Future<void> _createSharedList() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a name for the shared list');
      return;
    }

    try {
      setState(() => _isLoading = true);

      final taskIds = widget.taskIds ?? (widget.taskId != null ? [widget.taskId!] : <String>[]);
      
      final sharedList = await _collaborationService.createSharedTaskList(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        ownerId: 'current_user_id', // In real implementation, get from auth
        taskIds: taskIds,
        isPublic: _isPublic,
      );

      _nameController.clear();
      _descriptionController.clear();
      setState(() => _isPublic = false);

      await _loadSharedLists();
      _showSuccessSnackBar('Shared list "${sharedList.name}" created successfully!');

      if (sharedList.isPublic && sharedList.shareCode != null) {
        _showShareCodeDialog(sharedList);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to create shared list: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _joinSharedList() async {
    final shareCode = _shareCodeController.text.trim().toUpperCase();
    if (shareCode.isEmpty || shareCode.length != 8) {
      _showErrorSnackBar('Please enter a valid 8-character share code');
      return;
    }

    try {
      setState(() => _isLoading = true);

      final sharedList = await _collaborationService.joinSharedTaskList(
        shareCode: shareCode,
        userId: 'current_user_id', // In real implementation, get from auth
        userName: 'Current User', // In real implementation, get from auth
      );

      _shareCodeController.clear();
      await _loadSharedLists();
      _showSuccessSnackBar('Successfully joined "${sharedList.name}"!');
    } catch (e) {
      _showErrorSnackBar('Failed to join shared list: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleSharedListAction(String action, SharedTaskList sharedList) {
    switch (action) {
      case 'view':
        _showSharedListDetails(sharedList);
        break;
      case 'share':
        _shareList(sharedList);
        break;
      case 'manage':
        _manageSharedList(sharedList);
        break;
      case 'export':
        _exportSharedList(sharedList);
        break;
      case 'leave':
        _leaveSharedList(sharedList);
        break;
    }
  }

  void _showSharedListDetails(SharedTaskList sharedList) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(sharedList.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (sharedList.description.isNotEmpty) ...[
                Text(sharedList.description),
                const SizedBox(height: 16),
              ],
              Text('Tasks: ${sharedList.taskIds.length}'),
              Text('Collaborators: ${sharedList.collaborators.length}'),
              Text('Created: ${_formatDate(sharedList.createdAt)}'),
              Text('Updated: ${_formatDate(sharedList.updatedAt)}'),
              if (sharedList.isPublic && sharedList.shareCode != null) ...[
                const SizedBox(height: 16),
                Text('Share Code: ${sharedList.shareCode}'),
              ],
            ],
          ),
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

  void _shareList(SharedTaskList sharedList) {
    try {
      final shareLink = _collaborationService.generateShareableLink(sharedList.id);
      Clipboard.setData(ClipboardData(text: shareLink));
      _showSuccessSnackBar('Share link copied to clipboard!');
    } catch (e) {
      _showErrorSnackBar('Failed to generate share link: $e');
    }
  }

  void _manageSharedList(SharedTaskList sharedList) {
    // Navigate to collaboration management screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CollaborationManagementScreen(sharedList: sharedList),
      ),
    ).then((_) => _loadSharedLists());
  }

  void _exportSharedList(SharedTaskList sharedList) {
    try {
      final exportData = _collaborationService.exportSharedTaskList(sharedList.id);
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      // In a real implementation, save to file or share
      Clipboard.setData(ClipboardData(text: jsonString));
      _showSuccessSnackBar('Shared list data copied to clipboard!');
    } catch (e) {
      _showErrorSnackBar('Failed to export shared list: $e');
    }
  }

  void _leaveSharedList(SharedTaskList sharedList) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Shared List'),
        content: Text('Are you sure you want to leave "${sharedList.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await _collaborationService.removeCollaborator(
                  taskListId: sharedList.id,
                  userId: 'current_user_id',
                  requesterId: sharedList.ownerId,
                );
                await _loadSharedLists();
                _showSuccessSnackBar('Left "${sharedList.name}" successfully');
              } catch (e) {
                _showErrorSnackBar('Failed to leave shared list: $e');
              }
            },
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showShareCodeDialog(SharedTaskList sharedList) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Code Generated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your share code for "${sharedList.name}":'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              ),
              child: Text(
                sharedList.shareCode!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Share this code with others so they can join your list.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: sharedList.shareCode!));
              Navigator.of(context).pop();
              _showSuccessSnackBar('Share code copied to clipboard!');
            },
            child: const Text('Copy Code'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

