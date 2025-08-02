import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

/// Service for managing data privacy and compliance
class PrivacyService {
  static const String _privacySettingsKey = 'privacy_settings';
  static const String _consentRecordsKey = 'consent_records';
  static const String _dataRetentionKey = 'data_retention';
  static const String _dataProcessingLogKey = 'data_processing_log';

  /// Get current privacy settings
  Future<PrivacySettings> getPrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_privacySettingsKey);
    
    if (settingsJson != null) {
      final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
      return PrivacySettings.fromJson(settingsMap);
    }
    
    return PrivacySettings.defaultSettings();
  }

  /// Save privacy settings
  Future<void> savePrivacySettings(PrivacySettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = json.encode(settings.toJson());
    await prefs.setString(_privacySettingsKey, settingsJson);
  }

  /// Record user consent for data processing
  Future<void> recordConsent(ConsentRecord consent) async {
    final prefs = await SharedPreferences.getInstance();
    final existingRecords = await getConsentRecords();
    
    // Remove any existing consent for the same purpose
    existingRecords.removeWhere((record) => record.purpose == consent.purpose);
    
    // Add new consent record
    existingRecords.add(consent);
    
    final recordsJson = json.encode(
      existingRecords.map((record) => record.toJson()).toList(),
    );
    await prefs.setString(_consentRecordsKey, recordsJson);
  }

  /// Get all consent records
  Future<List<ConsentRecord>> getConsentRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getString(_consentRecordsKey);
    
    if (recordsJson != null) {
      final recordsList = json.decode(recordsJson) as List<dynamic>;
      return recordsList
          .map((record) => ConsentRecord.fromJson(record as Map<String, dynamic>))
          .toList();
    }
    
    return [];
  }

  /// Check if user has consented to specific data processing
  Future<bool> hasConsent(DataProcessingPurpose purpose) async {
    final records = await getConsentRecords();
    final relevantRecord = records
        .where((record) => record.purpose == purpose)
        .where((record) => record.isValid)
        .firstOrNull;
    
    return relevantRecord?.granted ?? false;
  }

  /// Withdraw consent for specific purpose
  Future<void> withdrawConsent(DataProcessingPurpose purpose) async {
    final withdrawalRecord = ConsentRecord(
      purpose: purpose,
      granted: false,
      timestamp: DateTime.now(),
      version: '1.0',
      ipAddress: await getDeviceIP(),
      userAgent: await getDeviceInfo(),
    );
    
    await recordConsent(withdrawalRecord);
    await _cleanupDataForPurpose(purpose);
  }

  /// Get data retention settings
  Future<DataRetentionSettings> getDataRetentionSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_dataRetentionKey);
    
    if (settingsJson != null) {
      final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
      return DataRetentionSettings.fromJson(settingsMap);
    }
    
    return DataRetentionSettings.defaultSettings();
  }

  /// Save data retention settings
  Future<void> saveDataRetentionSettings(DataRetentionSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = json.encode(settings.toJson());
    await prefs.setString(_dataRetentionKey, settingsJson);
  }

  /// Log data processing activity
  Future<void> logDataProcessing(DataProcessingLog log) async {
    final prefs = await SharedPreferences.getInstance();
    final existingLogs = await getDataProcessingLogs();
    
    existingLogs.add(log);
    
    // Keep only last 1000 logs to prevent storage bloat
    if (existingLogs.length > 1000) {
      existingLogs.removeRange(0, existingLogs.length - 1000);
    }
    
    final logsJson = json.encode(
      existingLogs.map((log) => log.toJson()).toList(),
    );
    await prefs.setString(_dataProcessingLogKey, logsJson);
  }

  /// Get data processing logs
  Future<List<DataProcessingLog>> getDataProcessingLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getString(_dataProcessingLogKey);
    
    if (logsJson != null) {
      final logsList = json.decode(logsJson) as List<dynamic>;
      return logsList
          .map((log) => DataProcessingLog.fromJson(log as Map<String, dynamic>))
          .toList();
    }
    
    return [];
  }

  /// Export all user data
  Future<Map<String, dynamic>> exportUserData() async {
    final retentionSettings = await getDataRetentionSettings();
    final processingLogs = await getDataProcessingLogs();
    
    return {
      'export_timestamp': DateTime.now().toIso8601String(),
      'privacy_settings': settings.toJson(),
      'consent_records': consents.map((c) => c.toJson()).toList(),
      'data_retention_settings': retentionSettings.toJson(),
      'data_processing_logs': processingLogs.map((l) => l.toJson()).toList(),
      'data_categories': await _exportDataByCategory(),
    };
  }

  /// Delete all user data
  Future<void> deleteAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get all keys and remove user data
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (_isUserDataKey(key)) {
        await prefs.remove(key);
      }
    }
    
    // Log the deletion
    await logDataProcessing(DataProcessingLog(
      activity: DataProcessingActivity.deletion,
      purpose: DataProcessingPurpose.userRequest,
      dataTypes: [DataType.all],
      timestamp: DateTime.now(),
      success: true,
    ));
  }

  /// Check if data retention policies need enforcement
  Future<void> enforceDataRetention() async {
    final now = DateTime.now();
    
    // Clean up old processing logs
    if (settings.logRetentionDays > 0) {
      final logs = await getDataProcessingLogs();
      final cutoffDate = now.subtract(Duration(days: settings.logRetentionDays));
      final filteredLogs = logs.where((log) => log.timestamp.isAfter(cutoffDate)).toList();
      
      if (filteredLogs.length != logs.length) {
        final prefs = await SharedPreferences.getInstance();
        final logsJson = json.encode(filteredLogs.map((log) => log.toJson()).toList());
        await prefs.setString(_dataProcessingLogKey, logsJson);
      }
    }
    
    // Clean up old consent records
    if (settings.consentRetentionDays > 0) {
      final cutoffDate = now.subtract(Duration(days: settings.consentRetentionDays));
      final filteredConsents = consents.where((consent) => consent.timestamp.isAfter(cutoffDate)).toList();
      
      if (filteredConsents.length != consents.length) {
        final prefs = await SharedPreferences.getInstance();
        final consentsJson = json.encode(filteredConsents.map((consent) => consent.toJson()).toList());
        await prefs.setString(_consentRecordsKey, consentsJson);
      }
    }
  }

  /// Get privacy compliance status
  Future<PrivacyComplianceStatus> getComplianceStatus() async {
    final retentionSettings = await getDataRetentionSettings();
    
    final issues = <String>[];
    
    // Check for missing consents
    for (final purpose in DataProcessingPurpose.values) {
      if (purpose != DataProcessingPurpose.essential && !await hasConsent(purpose)) {
        issues.add('Missing consent for ${purpose.name}');
      }
    }
    
    // Check data retention compliance
    if (retentionSettings.logRetentionDays <= 0) {
      issues.add('Data retention period not configured');
    }
    
    // Check privacy settings
    if (!settings.dataMinimization) {
      issues.add('Data minimization not enabled');
    }
    
    return PrivacyComplianceStatus(
      isCompliant: issues.isEmpty,
      issues: issues,
      lastChecked: DateTime.now(),
    );
  }

  /// Initialize privacy-first defaults
  Future<void> initializePrivacyDefaults() async {
    final currentSettings = await getPrivacySettings();
    
    // Only set defaults if no settings exist
    if (currentSettings == PrivacySettings.defaultSettings()) {
      const privacyFirstSettings = PrivacySettings(
        dataMinimization: true,
        localProcessingPreferred: true,
        analyticsEnabled: false,
        crashReportingEnabled: false,
        locationTrackingEnabled: false,
        voiceDataRetention: VoiceDataRetention.none,
        aiProcessingConsent: false,
        cloudSyncEnabled: false,
        shareUsageData: false,
        personalizedAds: false,
      );
      
      await savePrivacySettings(privacyFirstSettings);
    }
  }

  // Helper methods
  Future<String> getDeviceIP() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (!address.isLoopback && address.type == InternetAddressType.IPv4) {
            return address.address;
          }
        }
      }
    } catch (e) {
      // Ignore errors, return placeholder
    }
    return 'unknown';
  }

  Future<String> getDeviceInfo() async {
    return 'Flutter App/${Platform.operatingSystem}';
  }

  Future<void> _cleanupDataForPurpose(DataProcessingPurpose purpose) async {
    // Implementation would depend on specific data types
    // This is a placeholder for purpose-specific cleanup
    await logDataProcessing(DataProcessingLog(
      activity: DataProcessingActivity.deletion,
      purpose: purpose,
      dataTypes: [DataType.all],
      timestamp: DateTime.now(),
      success: true,
    ));
  }

  Future<Map<String, dynamic>> _exportDataByCategory() async {
    // This would export actual user data by category
    // Placeholder implementation
    return {
      'tasks': [],
      'projects': [],
      'tags': [],
      'settings': {},
    };
  }

  bool _isUserDataKey(String key) {
    // Define which SharedPreferences keys contain user data
    const userDataKeys = [
      'tasks',
      'projects',
      'tags',
      'user_settings',
      _privacySettingsKey,
      _consentRecordsKey,
      _dataRetentionKey,
      _dataProcessingLogKey,
    ];
    
    return userDataKeys.any((userKey) => key.startsWith(userKey));
  }
}

/// Privacy settings data model
class PrivacySettings {
  final bool dataMinimization;
  final bool localProcessingPreferred;
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final bool locationTrackingEnabled;
  final VoiceDataRetention voiceDataRetention;
  final bool aiProcessingConsent;
  final bool cloudSyncEnabled;
  final bool shareUsageData;
  final bool personalizedAds;

  const PrivacySettings({
    required this.dataMinimization,
    required this.localProcessingPreferred,
    required this.analyticsEnabled,
    required this.crashReportingEnabled,
    required this.locationTrackingEnabled,
    required this.voiceDataRetention,
    required this.aiProcessingConsent,
    required this.cloudSyncEnabled,
    required this.shareUsageData,
    required this.personalizedAds,
  });

  factory PrivacySettings.defaultSettings() {
    return const PrivacySettings(
      dataMinimization: true,
      localProcessingPreferred: true,
      analyticsEnabled: false,
      crashReportingEnabled: false,
      locationTrackingEnabled: false,
      voiceDataRetention: VoiceDataRetention.none,
      aiProcessingConsent: false,
      cloudSyncEnabled: false,
      shareUsageData: false,
      personalizedAds: false,
    );
  }

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      dataMinimization: json['dataMinimization'] ?? true,
      localProcessingPreferred: json['localProcessingPreferred'] ?? true,
      analyticsEnabled: json['analyticsEnabled'] ?? false,
      crashReportingEnabled: json['crashReportingEnabled'] ?? false,
      locationTrackingEnabled: json['locationTrackingEnabled'] ?? false,
      voiceDataRetention: VoiceDataRetention.values.firstWhere(
        (e) => e.name == json['voiceDataRetention'],
        orElse: () => VoiceDataRetention.none,
      ),
      aiProcessingConsent: json['aiProcessingConsent'] ?? false,
      cloudSyncEnabled: json['cloudSyncEnabled'] ?? false,
      shareUsageData: json['shareUsageData'] ?? false,
      personalizedAds: json['personalizedAds'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dataMinimization': dataMinimization,
      'localProcessingPreferred': localProcessingPreferred,
      'analyticsEnabled': analyticsEnabled,
      'crashReportingEnabled': crashReportingEnabled,
      'locationTrackingEnabled': locationTrackingEnabled,
      'voiceDataRetention': voiceDataRetention.name,
      'aiProcessingConsent': aiProcessingConsent,
      'cloudSyncEnabled': cloudSyncEnabled,
      'shareUsageData': shareUsageData,
      'personalizedAds': personalizedAds,
    };
  }

  PrivacySettings copyWith({
    bool? dataMinimization,
    bool? localProcessingPreferred,
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    bool? locationTrackingEnabled,
    VoiceDataRetention? voiceDataRetention,
    bool? aiProcessingConsent,
    bool? cloudSyncEnabled,
    bool? shareUsageData,
    bool? personalizedAds,
  }) {
    return PrivacySettings(
      dataMinimization: dataMinimization ?? this.dataMinimization,
      localProcessingPreferred: localProcessingPreferred ?? this.localProcessingPreferred,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
      locationTrackingEnabled: locationTrackingEnabled ?? this.locationTrackingEnabled,
      voiceDataRetention: voiceDataRetention ?? this.voiceDataRetention,
      aiProcessingConsent: aiProcessingConsent ?? this.aiProcessingConsent,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      shareUsageData: shareUsageData ?? this.shareUsageData,
      personalizedAds: personalizedAds ?? this.personalizedAds,
    );
  }
}

/// Consent record data model
class ConsentRecord {
  final DataProcessingPurpose purpose;
  final bool granted;
  final DateTime timestamp;
  final String version;
  final String ipAddress;
  final String userAgent;

  const ConsentRecord({
    required this.purpose,
    required this.granted,
    required this.timestamp,
    required this.version,
    required this.ipAddress,
    required this.userAgent,
  });

  bool get isValid {
    // Consent is valid for 2 years
    final expiryDate = timestamp.add(const Duration(days: 730));
    return DateTime.now().isBefore(expiryDate);
  }

  factory ConsentRecord.fromJson(Map<String, dynamic> json) {
    return ConsentRecord(
      purpose: DataProcessingPurpose.values.firstWhere(
        (e) => e.name == json['purpose'],
        orElse: () => DataProcessingPurpose.essential,
      ),
      granted: json['granted'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
      version: json['version'] ?? '1.0',
      ipAddress: json['ipAddress'] ?? 'unknown',
      userAgent: json['userAgent'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purpose': purpose.name,
      'granted': granted,
      'timestamp': timestamp.toIso8601String(),
      'version': version,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
    };
  }
}

/// Data retention settings
class DataRetentionSettings {
  final int logRetentionDays;
  final int consentRetentionDays;
  final int taskRetentionDays;
  final bool autoDeleteCompletedTasks;
  final int voiceDataRetentionDays;

  const DataRetentionSettings({
    required this.logRetentionDays,
    required this.consentRetentionDays,
    required this.taskRetentionDays,
    required this.autoDeleteCompletedTasks,
    required this.voiceDataRetentionDays,
  });

  factory DataRetentionSettings.defaultSettings() {
    return const DataRetentionSettings(
      logRetentionDays: 90,
      consentRetentionDays: 730, // 2 years
      taskRetentionDays: 0, // Never delete by default
      autoDeleteCompletedTasks: false,
      voiceDataRetentionDays: 0, // Delete immediately
    );
  }

  factory DataRetentionSettings.fromJson(Map<String, dynamic> json) {
    return DataRetentionSettings(
      logRetentionDays: json['logRetentionDays'] ?? 90,
      consentRetentionDays: json['consentRetentionDays'] ?? 730,
      taskRetentionDays: json['taskRetentionDays'] ?? 0,
      autoDeleteCompletedTasks: json['autoDeleteCompletedTasks'] ?? false,
      voiceDataRetentionDays: json['voiceDataRetentionDays'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logRetentionDays': logRetentionDays,
      'consentRetentionDays': consentRetentionDays,
      'taskRetentionDays': taskRetentionDays,
      'autoDeleteCompletedTasks': autoDeleteCompletedTasks,
      'voiceDataRetentionDays': voiceDataRetentionDays,
    };
  }

  DataRetentionSettings copyWith({
    int? logRetentionDays,
    int? consentRetentionDays,
    int? taskRetentionDays,
    bool? autoDeleteCompletedTasks,
    int? voiceDataRetentionDays,
  }) {
    return DataRetentionSettings(
      logRetentionDays: logRetentionDays ?? this.logRetentionDays,
      consentRetentionDays: consentRetentionDays ?? this.consentRetentionDays,
      taskRetentionDays: taskRetentionDays ?? this.taskRetentionDays,
      autoDeleteCompletedTasks: autoDeleteCompletedTasks ?? this.autoDeleteCompletedTasks,
      voiceDataRetentionDays: voiceDataRetentionDays ?? this.voiceDataRetentionDays,
    );
  }
}

/// Data processing log entry
class DataProcessingLog {
  final DataProcessingActivity activity;
  final DataProcessingPurpose purpose;
  final List<DataType> dataTypes;
  final DateTime timestamp;
  final bool success;
  final String? errorMessage;

  const DataProcessingLog({
    required this.activity,
    required this.purpose,
    required this.dataTypes,
    required this.timestamp,
    required this.success,
    this.errorMessage,
  });

  factory DataProcessingLog.fromJson(Map<String, dynamic> json) {
    return DataProcessingLog(
      activity: DataProcessingActivity.values.firstWhere(
        (e) => e.name == json['activity'],
        orElse: () => DataProcessingActivity.access,
      ),
      purpose: DataProcessingPurpose.values.firstWhere(
        (e) => e.name == json['purpose'],
        orElse: () => DataProcessingPurpose.essential,
      ),
      dataTypes: (json['dataTypes'] as List<dynamic>)
          .map((type) => DataType.values.firstWhere(
                (e) => e.name == type,
                orElse: () => DataType.other,
              ))
          .toList(),
      timestamp: DateTime.parse(json['timestamp']),
      success: json['success'] ?? false,
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity': activity.name,
      'purpose': purpose.name,
      'dataTypes': dataTypes.map((type) => type.name).toList(),
      'timestamp': timestamp.toIso8601String(),
      'success': success,
      'errorMessage': errorMessage,
    };
  }
}

/// Privacy compliance status
class PrivacyComplianceStatus {
  final bool isCompliant;
  final List<String> issues;
  final DateTime lastChecked;

  const PrivacyComplianceStatus({
    required this.isCompliant,
    required this.issues,
    required this.lastChecked,
  });
}

/// Enumerations
enum VoiceDataRetention { none, session, day, week, month }

enum DataProcessingPurpose {
  essential,
  analytics,
  aiProcessing,
  cloudSync,
  locationServices,
  voiceProcessing,
  userRequest,
}

enum DataProcessingActivity {
  collection,
  processing,
  storage,
  transmission,
  access,
  modification,
  deletion,
}

enum DataType {
  tasks,
  projects,
  tags,
  settings,
  location,
  voice,
  analytics,
  logs,
  all,
  other,
}

/// Providers
final privacyServiceProvider = Provider<PrivacyService>((ref) {
  return const PrivacyService();
});

final privacySettingsProvider = StateNotifierProvider<PrivacySettingsNotifier, AsyncValue<PrivacySettings>>((ref) {
  return PrivacySettingsNotifier(ref.read(privacyServiceProvider));
});

final dataRetentionSettingsProvider = StateNotifierProvider<DataRetentionSettingsNotifier, AsyncValue<DataRetentionSettings>>((ref) {
  return DataRetentionSettingsNotifier(ref.read(privacyServiceProvider));
});

/// Privacy settings notifier
class PrivacySettingsNotifier extends StateNotifier<AsyncValue<PrivacySettings>> {
  final PrivacyService _privacyService;

  PrivacySettingsNotifier(this._privacyService) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateSettings(PrivacySettings settings) async {
    await _privacyService.savePrivacySettings(settings);
    state = AsyncValue.data(settings);
  }

  Future<void> refresh() async {
    await _loadSettings();
  }
}

/// Data retention settings notifier
class DataRetentionSettingsNotifier extends StateNotifier<AsyncValue<DataRetentionSettings>> {
  final PrivacyService _privacyService;

  DataRetentionSettingsNotifier(this._privacyService) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateSettings(DataRetentionSettings settings) async {
    await _privacyService.saveDataRetentionSettings(settings);
    state = AsyncValue.data(settings);
  }

  Future<void> refresh() async {
    await _loadSettings();
  }
}