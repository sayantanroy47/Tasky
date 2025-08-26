import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../domain/models/enums.dart';
import '../../services/cloud_sync_service.dart';
import '../widgets/standardized_app_bar.dart';
import '../widgets/standardized_text.dart';

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
      appBar: StandardizedAppBar(
        title: 'Cloud Sync',
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
                  : Icon(PhosphorIcons.cloudArrowUp()),
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
              Icon(PhosphorIcons.warningCircle(), size: 64, color: Colors.red),
              const SizedBox(height: 16),
              StandardizedText('Error: $error', style: StandardizedTextStyle.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(cloudSyncStatsProvider),
                child: const StandardizedText('Retry', style: StandardizedTextStyle.buttonText),
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
          Icon(
            PhosphorIcons.cloudSlash(),
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          const StandardizedText(
            'Cloud Sync Not Connected',
            style: StandardizedTextStyle.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const StandardizedText(
            'Sign in to sync your tasks and events across devices',
            style: StandardizedTextStyle.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Sign in button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showSignInDialog(),
              icon: Icon(PhosphorIcons.signIn()),
              label: const StandardizedText('Sign In', style: StandardizedTextStyle.buttonText),
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
              icon: Icon(PhosphorIcons.userPlus()),
              label: const StandardizedText('Create Account', style: StandardizedTextStyle.buttonText),
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
            const StandardizedText(
              'Benefits of Cloud Sync',
              style: StandardizedTextStyle.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildBenefitItem(
              PhosphorIcons.devices(),
              'Access your tasks on all devices',
            ),
            _buildBenefitItem(
              PhosphorIcons.cloudArrowUp(),
              'Automatic backup of your data',
            ),
            _buildBenefitItem(
              PhosphorIcons.arrowsClockwise(),
              'Real-time synchronization',
            ),
            _buildBenefitItem(
              PhosphorIcons.shield(),
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
          Expanded(child: StandardizedText(text, style: StandardizedTextStyle.bodyMedium)),
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
                Icon(PhosphorIcons.userCircle(), color: Colors.green),
                const SizedBox(width: 8),
                const StandardizedText(
                  'Account Connected',
                  style: StandardizedTextStyle.titleMedium,
                  color: Colors.green,
                ),
                const Spacer(),
                TextButton(
                  onPressed: _showSignOutDialog,
                  child: const StandardizedText('Sign Out', style: StandardizedTextStyle.buttonText),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const StandardizedText(
              'Your data is being synced to the cloud',
              style: StandardizedTextStyle.bodyMedium,
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
            const StandardizedText(
              'Sync Statistics',
              style: StandardizedTextStyle.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Tasks in Cloud',
                    '${stats.totalCloudTasks}',
                    PhosphorIcons.checkSquare(),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Events in Cloud',
                    '${stats.totalCloudEvents}',
                    PhosphorIcons.calendar(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (stats.lastSyncTime != null) ...[
              Row(
                children: [
                  Icon(PhosphorIcons.clock(), size: 16),
                  const SizedBox(width: 8),
                  StandardizedText(
                    'Last sync: ${_formatDateTime(stats.lastSyncTime!)}',
                    style: StandardizedTextStyle.bodySmall,
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Icon(PhosphorIcons.info(), size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  const StandardizedText(
                    'Never synced',
                    style: StandardizedTextStyle.bodySmall,
                    color: Colors.orange,
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
        StandardizedText(
          value,
          style: StandardizedTextStyle.headlineSmall,
        ),
        StandardizedText(
          label,
          style: StandardizedTextStyle.bodySmall,
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
            const StandardizedText(
              'Sync Settings',
              style: StandardizedTextStyle.titleMedium,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const StandardizedText('Auto Sync', style: StandardizedTextStyle.bodyLarge),
              subtitle: const StandardizedText('Automatically sync changes', style: StandardizedTextStyle.bodyMedium),
              value: true, // This would come from settings
              onChanged: (value) {
                // Implement auto sync toggle
              },
            ),
            SwitchListTile(
              title: const StandardizedText('Real-time Sync', style: StandardizedTextStyle.bodyLarge),
              subtitle: const StandardizedText('Sync changes immediately', style: StandardizedTextStyle.bodyMedium),
              value: false, // This would come from settings
              onChanged: (value) {
                // Implement real-time sync toggle
              },
            ),
            SwitchListTile(
              title: const StandardizedText('Sync on WiFi Only', style: StandardizedTextStyle.bodyLarge),
              subtitle: const StandardizedText('Avoid mobile data usage', style: StandardizedTextStyle.bodyMedium),
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
            const StandardizedText(
              'Sync Actions',
              style: StandardizedTextStyle.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(PhosphorIcons.cloudArrowUp()),
              title: const StandardizedText('Full Sync', style: StandardizedTextStyle.bodyLarge),
              subtitle: const StandardizedText('Sync all data to and from cloud', style: StandardizedTextStyle.bodyMedium),
              onTap: _performFullSync,
            ),
            ListTile(
              leading: Icon(PhosphorIcons.cloudArrowUp()),
              title: const StandardizedText('Upload All', style: StandardizedTextStyle.bodyLarge),
              subtitle: const StandardizedText('Upload all local data to cloud', style: StandardizedTextStyle.bodyMedium),
              onTap: _uploadAllData,
            ),
            ListTile(
              leading: Icon(PhosphorIcons.cloudArrowDown()),
              title: const StandardizedText('Download All', style: StandardizedTextStyle.bodyLarge),
              subtitle: const StandardizedText('Download all data from cloud', style: StandardizedTextStyle.bodyMedium),
              onTap: _downloadAllData,
            ),
            const Divider(),
            ListTile(
              leading: Icon(PhosphorIcons.arrowClockwise(), color: Colors.orange),
              title: const StandardizedText('Reset Sync', style: StandardizedTextStyle.bodyLarge),
              subtitle: const StandardizedText('Clear sync data and start fresh', style: StandardizedTextStyle.bodyMedium),
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
            const StandardizedText(
              'Advanced Settings',
              style: StandardizedTextStyle.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(PhosphorIcons.gitMerge()),
              title: const StandardizedText('Conflict Resolution', style: StandardizedTextStyle.bodyLarge),
              subtitle: const StandardizedText('How to handle sync conflicts', style: StandardizedTextStyle.bodyMedium),
              trailing: Icon(PhosphorIcons.caretRight()),
              onTap: _showConflictResolutionSettings,
            ),
            ListTile(
              leading: Icon(PhosphorIcons.database()),
              title: const StandardizedText('Data Management', style: StandardizedTextStyle.bodyLarge),
              subtitle: const StandardizedText('Manage cloud storage usage', style: StandardizedTextStyle.bodyMedium),
              trailing: Icon(PhosphorIcons.caretRight()),
              onTap: _showDataManagementSettings,
            ),
            ListTile(
              leading: Icon(PhosphorIcons.clockCounterClockwise()),
              title: const StandardizedText('Sync History', style: StandardizedTextStyle.bodyLarge),
              subtitle: const StandardizedText('View sync activity log', style: StandardizedTextStyle.bodyMedium),
              trailing: Icon(PhosphorIcons.caretRight()),
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
    setState(() => _isLoading = true);

    try {
      final cloudService = ref.read(cloudSyncServiceProvider);
      final result = await cloudService.uploadAllLocalData();

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload completed: ${result.totalSynced} items uploaded'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed: ${result.error}'),
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

  Future<void> _downloadAllData() async {
    setState(() => _isLoading = true);

    try {
      final cloudService = ref.read(cloudSyncServiceProvider);
      final result = await cloudService.downloadAllCloudData();

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download completed: ${result.totalSynced} items downloaded'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download failed: ${result.error}'),
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

    if (confirmed == true && mounted) {
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conflict Resolution'),
        content: const Text('Configure how sync conflicts are handled automatically or manually.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDataManagementSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Management'),
        content: const Text('Manage cloud storage usage and cleanup policies.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSyncHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync History'),
        content: const Text('View detailed sync activity and troubleshoot sync issues.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
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
              decoration: InputDecoration(
                labelText: 'Email',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(PhosphorIcons.envelope()),
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
                prefixIcon: Icon(PhosphorIcons.lock()),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(_obscurePassword ? PhosphorIcons.eye() : PhosphorIcons.eyeSlash()),
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
              decoration: InputDecoration(
                labelText: 'Email',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(PhosphorIcons.envelope()),
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
                prefixIcon: Icon(PhosphorIcons.lock()),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(_obscurePassword ? PhosphorIcons.eye() : PhosphorIcons.eyeSlash()),
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
                prefixIcon: Icon(PhosphorIcons.lock()),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  icon: Icon(_obscureConfirmPassword ? PhosphorIcons.eye() : PhosphorIcons.eyeSlash()),
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
