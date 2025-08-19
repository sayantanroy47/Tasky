import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/enhanced_ux_widgets.dart';
import '../widgets/standardized_app_bar.dart';
import '../../services/privacy_service.dart';
import 'dart:convert';
import '../widgets/glassmorphism_container.dart';
import '../../core/design_system/design_tokens.dart';
import '../../core/theme/typography_constants.dart';

/// Screen for managing privacy settings and data compliance
class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});
  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacySettings = ref.watch(privacySettingsProvider);
    final retentionSettings = ref.watch(dataRetentionSettingsProvider);
    
    return Scaffold(
      appBar: StandardizedAppBar(
        title: 'Privacy & Data',
        actions: [
          IconButton(
            onPressed: () => _showPrivacyInfo(context),
            icon: const Icon(Icons.info_outline),
            tooltip: 'Privacy information',
          ),
        ],
      ),
      body: privacySettings.when(
        data: (privacy) => retentionSettings.when(
          data: (retention) => _buildPrivacyContent(context, ref, privacy, retention),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildErrorWidget(context, ref, error),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorWidget(context, ref, error),
      ),
    );
  }

  Widget _buildPrivacyContent(
    BuildContext context,
    WidgetRef ref,
    PrivacySettings privacy,
    DataRetentionSettings retention,
  ) {
    return ResponsiveWidget(
      builder: (context, config) {
        return ListView(
          padding: config.padding,
          children: [
            // Privacy Principles Section
            _buildSectionHeader(context, 'Privacy Principles'),
            GlassmorphismContainer(
              level: GlassLevel.content,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.minimize),
                    title: const Text('Data Minimization'),
                    subtitle: const Text('Collect only necessary data for app functionality'),
                    value: privacy.dataMinimization,
                    onChanged: (value) => _updatePrivacySetting(
                      ref,
                      privacy.copyWith(dataMinimization: value),
                    ),
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.computer),
                    title: const Text('Local Processing Preferred'),
                    subtitle: const Text('Process data on device when possible'),
                    value: privacy.localProcessingPreferred,
                    onChanged: (value) => _updatePrivacySetting(
                      ref,
                      privacy.copyWith(localProcessingPreferred: value),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Data Collection Section
            _buildSectionHeader(context, 'Data Collection'),
            GlassmorphismContainer(
              level: GlassLevel.content,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.analytics),
                    title: const Text('Analytics'),
                    subtitle: const Text('Help improve the app with usage analytics'),
                    value: privacy.analyticsEnabled,
                    onChanged: (value) => _showConsentDialog(
                      context,
                      ref,
                      'Analytics Data Collection',
                      'Allow collection of anonymous usage data to help improve the app?',
                      DataProcessingPurpose.analytics,
                      () => _updatePrivacySetting(
                        ref,
                        privacy.copyWith(analyticsEnabled: value),
                      ),
                    ),
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.bug_report),
                    title: const Text('Crash Reporting'),
                    subtitle: const Text('Send crash reports to help fix issues'),
                    value: privacy.crashReportingEnabled,
                    onChanged: (value) => _updatePrivacySetting(
                      ref,
                      privacy.copyWith(crashReportingEnabled: value),
                    ),
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.location_on),
                    title: const Text('Location Tracking'),
                    subtitle: const Text('Use location for location-based reminders'),
                    value: privacy.locationTrackingEnabled,
                    onChanged: (value) => _showConsentDialog(
                      context,
                      ref,
                      'Location Data Collection',
                      'Allow access to your location for location-based features?',
                      DataProcessingPurpose.locationServices,
                      () => _updatePrivacySetting(
                        ref,
                        privacy.copyWith(locationTrackingEnabled: value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // AI and Voice Processing Section
            _buildSectionHeader(context, 'AI & Voice Processing'),
            GlassmorphismContainer(
              level: GlassLevel.content,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.psychology),
                    title: const Text('AI Processing'),
                    subtitle: const Text('Use AI services for smart task parsing'),
                    value: privacy.aiProcessingConsent,
                    onChanged: (value) => _showConsentDialog(
                      context,
                      ref,
                      'AI Processing Consent',
                      'Allow AI services to process your task data for smart features?',
                      DataProcessingPurpose.aiProcessing,
                      () => _updatePrivacySetting(
                        ref,
                        privacy.copyWith(aiProcessingConsent: value),
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.mic),
                    title: const Text('Voice Data Retention'),
                    subtitle: Text(_getVoiceRetentionDescription(privacy.voiceDataRetention)),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showVoiceRetentionDialog(context, ref, privacy),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Cloud and Sharing Section
            _buildSectionHeader(context, 'Cloud & Sharing'),
            GlassmorphismContainer(
              level: GlassLevel.content,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.cloud),
                    title: const Text('Cloud Sync'),
                    subtitle: const Text('Sync data across devices via cloud'),
                    value: privacy.cloudSyncEnabled,
                    onChanged: (value) => _showConsentDialog(
                      context,
                      ref,
                      'Cloud Sync Consent',
                      'Allow syncing your data to cloud storage?',
                      DataProcessingPurpose.cloudSync,
                      () => _updatePrivacySetting(
                        ref,
                        privacy.copyWith(cloudSyncEnabled: value),
                      ),
                    ),
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.share),
                    title: const Text('Share Usage Data'),
                    subtitle: const Text('Share anonymous usage patterns'),
                    value: privacy.shareUsageData,
                    onChanged: (value) => _updatePrivacySetting(
                      ref,
                      privacy.copyWith(shareUsageData: value),
                    ),
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.ads_click),
                    title: const Text('Personalized Ads'),
                    subtitle: const Text('Show personalized advertisements'),
                    value: privacy.personalizedAds,
                    onChanged: (value) => _updatePrivacySetting(
                      ref,
                      privacy.copyWith(personalizedAds: value),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Data Retention Section
            _buildSectionHeader(context, 'Data Retention'),
            GlassmorphismContainer(
              level: GlassLevel.content,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('Log Retention'),
                    subtitle: Text('Keep logs for ${retention.logRetentionDays} days'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showRetentionDialog(
                      context,
                      ref,
                      'Log Retention Period',
                      retention.logRetentionDays,
                      (days) => _updateRetentionSetting(
                        ref,
                        retention.copyWith(logRetentionDays: days),
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.task),
                    title: const Text('Task Retention'),
                    subtitle: Text(retention.taskRetentionDays > 0
                        ? 'Delete completed tasks after ${retention.taskRetentionDays} days'
                        : 'Keep completed tasks forever'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showRetentionDialog(
                      context,
                      ref,
                      'Task Retention Period',
                      retention.taskRetentionDays,
                      (days) => _updateRetentionSetting(
                        ref,
                        retention.copyWith(taskRetentionDays: days),
                      ),
                    ),
                  ),
                  const Divider(),
                  SwitchListTile(
                    secondary: const Icon(Icons.auto_delete),
                    title: const Text('Auto-delete Completed Tasks'),
                    subtitle: const Text('Automatically remove old completed tasks'),
                    value: retention.autoDeleteCompletedTasks,
                    onChanged: (value) => _updateRetentionSetting(
                      ref,
                      retention.copyWith(autoDeleteCompletedTasks: value),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Data Rights Section
            _buildSectionHeader(context, 'Your Data Rights'),
            GlassmorphismContainer(
              level: GlassLevel.content,
              borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.download),
                    title: const Text('Export My Data'),
                    subtitle: const Text('Download all your data in JSON format'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _exportUserData(context, ref),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.visibility),
                    title: const Text('View Data Processing Log'),
                    subtitle: const Text('See how your data has been processed'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showDataProcessingLog(context, ref),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.gavel),
                    title: const Text('Manage Consent'),
                    subtitle: const Text('Review and modify your consent choices'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showConsentManagement(context, ref),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.delete_forever,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      'Delete All My Data',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    subtitle: const Text('Permanently delete all your data'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showDeleteAllDataDialog(context, ref),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load privacy settings',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GlassmorphismContainer(
            level: GlassLevel.interactive,
            borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ref.read(privacySettingsProvider.notifier).refresh();
                  ref.read(dataRetentionSettingsProvider.notifier).refresh();
                },
                borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        Theme.of(context).colorScheme.primary.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(TypographyConstants.radiusStandard),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _updatePrivacySetting(WidgetRef ref, PrivacySettings settings) {
    ref.read(privacySettingsProvider.notifier).updateSettings(settings);
  }

  void _updateRetentionSetting(WidgetRef ref, DataRetentionSettings settings) {
    ref.read(dataRetentionSettingsProvider.notifier).updateSettings(settings);
  }

  void _showConsentDialog(
    BuildContext context,
    WidgetRef ref,
    String title,
    String description,
    DataProcessingPurpose purpose,
    VoidCallback onConsent,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Record consent
              final privacyService = ref.read(privacyServiceProvider);
              await privacyService.recordConsent(ConsentRecord(
                purpose: purpose,
                granted: true,
                timestamp: DateTime.now(),
                version: '1.0',
                ipAddress: await privacyService.getDeviceIP(),
                userAgent: await privacyService.getDeviceInfo(),
              ));
              
              onConsent();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }

  void _showVoiceRetentionDialog(
    BuildContext context,
    WidgetRef ref,
    PrivacySettings settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voice Data Retention'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: VoiceDataRetention.values.map((retention) {
            return RadioListTile<VoiceDataRetention>(
              title: Text(_getVoiceRetentionName(retention)),
              subtitle: Text(_getVoiceRetentionDescription(retention)),
              value: retention,
              groupValue: settings.voiceDataRetention,
              onChanged: (value) {
                if (value != null) {
                  _updatePrivacySetting(
                    ref,
                    settings.copyWith(voiceDataRetention: value),
                  );
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showRetentionDialog(
    BuildContext context,
    WidgetRef ref,
    String title,
    int currentDays,
    Function(int) onChanged,
  ) {
    final options = [0, 7, 30, 90, 180, 365];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((days) {
            return RadioListTile<int>(
              title: Text(days == 0 ? 'Never delete' : '$days days'),
              value: days,
              groupValue: currentDays,
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _exportUserData(BuildContext context, WidgetRef ref) async {
    try {
      final privacyService = ref.read(privacyServiceProvider);
      final userData = await privacyService.exportUserData();
      
      // In a real app, this would save to file or share
      final jsonString = const JsonEncoder.withIndent('  ').convert(userData);
      
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Data Export'),
            content: SingleChildScrollView(
              child: Text(
                'Your data has been exported. In a real app, this would be saved to a file.\n\nData size: ${jsonString.length} characters',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  void _showDataProcessingLog(BuildContext context, WidgetRef ref) async {
    final privacyService = ref.read(privacyServiceProvider);
    final logs = await privacyService.getDataProcessingLogs();
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Data Processing Log'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: logs.isEmpty
                ? const Center(child: Text('No processing logs found'))
                : ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return ListTile(
                        title: Text('${log.activity.name} - ${log.purpose.name}'),
                        subtitle: Text(
                          '${log.timestamp.toString().substring(0, 19)}\n'
                          'Data types: ${log.dataTypes.map((t) => t.name).join(', ')}',
                        ),
                        leading: Icon(
                          log.success ? Icons.check_circle : Icons.error,
                          color: log.success ? Colors.green : Colors.red,
                        ),
                        isThreeLine: true,
                      );
                    },
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
  }

  void _showConsentManagement(BuildContext context, WidgetRef ref) async {
    final privacyService = ref.read(privacyServiceProvider);
    final consents = await privacyService.getConsentRecords();
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Consent Management'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: consents.isEmpty
                ? const Center(child: Text('No consent records found'))
                : ListView.builder(
                    itemCount: consents.length,
                    itemBuilder: (context, index) {
                      final consent = consents[index];
                      return ListTile(
                        title: Text(consent.purpose.name),
                        subtitle: Text(
                          '${consent.granted ? 'Granted' : 'Denied'} on ${consent.timestamp.toString().substring(0, 19)}\n'
                          'Valid: ${consent.isValid ? 'Yes' : 'No'}',
                        ),
                        leading: Icon(
                          consent.granted ? Icons.check_circle : Icons.cancel,
                          color: consent.granted ? Colors.green : Colors.red,
                        ),
                        trailing: consent.granted
                            ? IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () async {
                                  await privacyService.withdrawConsent(consent.purpose);
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    _showConsentManagement(context, ref);
                                  }
                                },
                              )
                            : null,
                        isThreeLine: true,
                      );
                    },
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
  }

  void _showDeleteAllDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'This will permanently delete all your data including tasks, settings, and logs. This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final privacyService = ref.read(privacyServiceProvider);
              await privacyService.deleteAllUserData();
              
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Information'),
        content: const SingleChildScrollView(
          child: Text(
            'This app is designed with privacy-first principles:\n\n'
            '• Data Minimization: We only collect data necessary for app functionality\n'
            '• Local Processing: Data is processed on your device when possible\n'
            '• Transparent Consent: You control what data is collected and how it\'s used\n'
            '• Data Rights: You can export, view, or delete your data at any time\n'
            '• Secure Storage: All data is encrypted and stored securely\n'
            '• No Tracking: We don\'t track you across other apps or websites\n\n'
            'You have full control over your privacy settings and can change them at any time.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  String _getVoiceRetentionName(VoiceDataRetention retention) {
    switch (retention) {
      case VoiceDataRetention.none:
        return 'Delete Immediately';
      case VoiceDataRetention.session:
        return 'Session Only';
      case VoiceDataRetention.day:
        return '1 Day';
      case VoiceDataRetention.week:
        return '1 Week';
      case VoiceDataRetention.month:
        return '1 Month';
    }
  }

  String _getVoiceRetentionDescription(VoiceDataRetention retention) {
    switch (retention) {
      case VoiceDataRetention.none:
        return 'Voice data is deleted immediately after processing';
      case VoiceDataRetention.session:
        return 'Voice data is kept only during the current session';
      case VoiceDataRetention.day:
        return 'Voice data is kept for 1 day';
      case VoiceDataRetention.week:
        return 'Voice data is kept for 1 week';
      case VoiceDataRetention.month:
        return 'Voice data is kept for 1 month';
    }
  }
}