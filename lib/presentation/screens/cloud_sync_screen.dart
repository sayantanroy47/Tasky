import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/cloud_sync_service.dart';

/// Screen for managing cloud synchronization settings
class CloudSyncScreen extends ConsumerStatefulWidget {
  const CloudSyncScreen({super.key});
  @override
  ConsumerState<CloudSyncScreen> createState() => _CloudSyncScreenState();
}

class _CloudSyncScreenState extends ConsumerState<CloudSyncScreen> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(authStatusProvider);
    final syncStatsAsync = ref.watch(cloudSyncStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Sync'),
        actions: [
          if (isAuthenticated)
            IconButton(
              onPressed: _isLoading ? null : _performFullSync,
              icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_sync),
              tooltip: 'Sync Now',
            ),
        ],
      ),
      body: syncStatsAsync.when(
        data: (stats) => _buildContent(context, stats),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(cloudSyncStatsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, CloudSyncStats stats) {
    if (!stats.isAuthenticated) {
      return _buildAuthenticationSection();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Account status card
        _buildAccountStatusCard(stats),
        const SizedBox(height: 16),

        // Sync statistics card
        _buildSyncStatsCard(stats),
        const SizedBox(height: 16),

        // Sync settings card
        _buildSyncSettingsCard(),
        const SizedBox(height: 16),

        // Sync actions card
        _buildSyncActionsCard(),
        const SizedBox(height: 16),

        // Advanced settings card
        _buildAdvancedSettingsCard(),
      ],
    );
  }

  Widget _buildAuthenticationSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          Text(
            'Cloud Sync Not Connected',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Sign in to sync your tasks and events across devices',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Sign in button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showSignInDialog(),
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Sign up button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showSignUpDialog(),
              icon: const Icon(Icons.person_add),
              label: const Text('Create Account'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Benefits section
          _buildBenefitsSection(),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Benefits of Cloud Sync',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildBenefitItem(
              Icons.devices,
              'Access your tasks on all devices',
            ),
            _buildBenefitItem(
              Icons.backup,
              'Automatic backup of your data',
            ),
            _buildBenefitItem(
              Icons.sync,
              'Real-time synchronization',
            ),
            _buildBenefitItem(
              Icons.security,
              'Secure cloud storage',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildAccountStatusCard(CloudSyncStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Account Connected',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _showSignOutDialog,
                  child: const Text('Sign Out'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Your data is being synced to the cloud',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatsCard(CloudSyncStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Statistics',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Tasks in Cloud',
                    '${stats.totalCloudTasks}',
                    Icons.task,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Events in Cloud',
                    '${stats.totalCloudEvents}',
                    Icons.event,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (stats.lastSyncTime != null) ...[
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Last sync: ${_formatDateTime(stats.lastSyncTime!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  const Icon(Icons.info, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Never synced',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSyncSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            SwitchListTile(
              title: const Text('Auto Sync'),
              subtitle: const Text('Automatically sync changes'),
              value: true, // This would come from settings
              onChanged: (value) {
                // Implement auto sync toggle
              },
            ),
            
            SwitchListTile(
              title: const Text('Real-time Sync'),
              subtitle: const Text('Sync changes immediately'),
              value: false, // This would come from settings
              onChanged: (value) {
                // Implement real-time sync toggle
              },
            ),
            
            SwitchListTile(
              title: const Text('Sync on WiFi Only'),
              subtitle: const Text('Avoid mobile data usage'),
              value: true, // This would come from settings
              onChanged: (value) {
                // Implement WiFi-only sync toggle
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            ListTile(
              leading: const Icon(Icons.cloud_sync),
              title: const Text('Full Sync'),
              subtitle: const Text('Sync all data to and from cloud'),
              onTap: _performFullSync,
            ),
            
            ListTile(
              leading: const Icon(Icons.cloud_upload),
              title: const Text('Upload All'),
              subtitle: const Text('Upload all local data to cloud'),
              onTap: _uploadAllData,
            ),
            
            ListTile(
              leading: const Icon(Icons.cloud_download),
              title: const Text('Download All'),
              subtitle: const Text('Download all data from cloud'),
              onTap: _downloadAllData,
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.orange),
              title: const Text('Reset Sync'),
              subtitle: const Text('Clear sync data and start fresh'),
              onTap: _resetSync,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            ListTile(
              leading: const Icon(Icons.merge_type),
              title: const Text('Conflict Resolution'),
              subtitle: const Text('How to handle sync conflicts'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showConflictResolutionSettings,
            ),
            
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('Data Management'),
              subtitle: const Text('Manage cloud storage usage'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showDataManagementSettings,
            ),
            
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Sync History'),
              subtitle: const Text('View sync activity log'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showSyncHistory,
            ),
          ],
        ),
      ),
    );
  }

  void _showSignInDialog() {
    showDialog(
      context: context,
      builder: (context) => const SignInDialog(),
    );
  }

  void _showSignUpDialog() {
    showDialog(
      context: context,
      builder: (context) => const SignUpDialog(),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out? Your local data will remain, '
          'but you won\'t be able to sync until you sign in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    final cloudService = ref.read(cloudSyncServiceProvider);
    await cloudService.signOut();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out successfully')),
      );
    }
  }

  Future<void> _performFullSync() async {
    setState(() => _isLoading = true);
    
    try {
      final cloudService = ref.read(cloudSyncServiceProvider);
      final result = await cloudService.performFullSync();
      
      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Full sync completed: ${result.totalSynced} items synced'),
              backgroundColor: Colors.green,
            ),
          );
          
          if (result.conflicts.isNotEmpty) {
            _showConflictsDialog(result.conflicts);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sync failed: ${result.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _uploadAllData() async {
    // Implementation for uploading all local data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upload all data functionality coming soon')),
    );
  }

  Future<void> _downloadAllData() async {
    // Implementation for downloading all cloud data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download all data functionality coming soon')),
    );
  }

  Future<void> _resetSync() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Sync'),
        content: const Text(
          'This will clear all sync data and remove the connection to cloud storage. '
          'Your local data will remain intact. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Reset sync data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync data reset')),
      );
    }
  }

  void _showConflictsDialog(List<SyncConflict> conflicts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sync Conflicts (${conflicts.length})'),
        content: const Text(
          'Some items had conflicts during sync. Please review and resolve them in the conflict resolution screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to conflict resolution screen
            },
            child: const Text('Resolve Now'),
          ),
        ],
      ),
    );
  }

  void _showConflictResolutionSettings() {
    // Show conflict resolution settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conflict resolution settings coming soon')),
    );
  }

  void _showDataManagementSettings() {
    // Show data management settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data management settings coming soon')),
    );
  }

  void _showSyncHistory() {
    // Show sync history
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sync history coming soon')),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Sign in dialog
class SignInDialog extends ConsumerStatefulWidget {
  const SignInDialog({super.key});
  @override
  ConsumerState<SignInDialog> createState() => _SignInDialogState();
}

class _SignInDialogState extends ConsumerState<SignInDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sign In'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _signIn,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Sign In'),
        ),
      ],
    );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cloudService = ref.read(cloudSyncServiceProvider);
      final result = await cloudService.authenticateUser(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (result.success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Signed in successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Sign in failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Sign up dialog
class SignUpDialog extends ConsumerStatefulWidget {
  const SignUpDialog({super.key});
  @override
  ConsumerState<SignUpDialog> createState() => _SignUpDialogState();
}

class _SignUpDialogState extends ConsumerState<SignUpDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Account'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              obscureText: _obscureConfirmPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _signUp,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Account'),
        ),
      ],
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cloudService = ref.read(cloudSyncServiceProvider);
      final result = await cloudService.signUpUser(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (result.success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Account created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Account creation failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}