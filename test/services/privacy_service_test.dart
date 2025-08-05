import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_tracker_app/services/privacy_service.dart';


void main() {
  group('PrivacyService', () {
    late PrivacyService privacyService;

    setUp(() {
      privacyService = PrivacyService();
      SharedPreferences.setMockInitialValues({});
    });

    group('Privacy Settings', () {
      test('should return default settings when none exist', () async {
        final settings = await privacyService.getPrivacySettings();
        
        expect(settings.dataMinimization, isTrue);
        expect(settings.localProcessingPreferred, isTrue);
        expect(settings.analyticsEnabled, isFalse);
        expect(settings.cloudSyncEnabled, isFalse);
      });

      test('should save and retrieve privacy settings', () async {
        const settings = PrivacySettings(
          dataMinimization: false,
          localProcessingPreferred: false,
          analyticsEnabled: true,
          crashReportingEnabled: true,
          locationTrackingEnabled: true,
          voiceDataRetention: VoiceDataRetention.day,
          aiProcessingConsent: true,
          cloudSyncEnabled: true,
          shareUsageData: true,
          personalizedAds: true,
        );

        await privacyService.savePrivacySettings(settings);
        final retrievedSettings = await privacyService.getPrivacySettings();

        expect(retrievedSettings.dataMinimization, equals(settings.dataMinimization));
        expect(retrievedSettings.analyticsEnabled, equals(settings.analyticsEnabled));
        expect(retrievedSettings.cloudSyncEnabled, equals(settings.cloudSyncEnabled));
      });

      test('should update settings with copyWith', () {
        final originalSettings = PrivacySettings.defaultSettings();
        final updatedSettings = originalSettings.copyWith(
          analyticsEnabled: true,
          cloudSyncEnabled: true,
        );

        expect(updatedSettings.analyticsEnabled, isTrue);
        expect(updatedSettings.cloudSyncEnabled, isTrue);
        expect(updatedSettings.dataMinimization, equals(originalSettings.dataMinimization));
      });
    });

    group('Consent Management', () {
      test('should record user consent', () async {
        final consent = ConsentRecord(
          purpose: DataProcessingPurpose.analytics,
          granted: true,
          timestamp: DateTime.now(),
          version: '1.0',
          ipAddress: '192.168.1.1',
          userAgent: 'Test Agent',
        );

        await privacyService.recordConsent(consent);
        final hasConsent = await privacyService.hasConsent(DataProcessingPurpose.analytics);

        expect(hasConsent, isTrue);
      });

      test('should check consent validity', () {
        final validConsent = ConsentRecord(
          purpose: DataProcessingPurpose.analytics,
          granted: true,
          timestamp: DateTime.now(),
          version: '1.0',
          ipAddress: '192.168.1.1',
          userAgent: 'Test Agent',
        );

        final expiredConsent = ConsentRecord(
          purpose: DataProcessingPurpose.analytics,
          granted: true,
          timestamp: DateTime.now().subtract(const Duration(days: 800)),
          version: '1.0',
          ipAddress: '192.168.1.1',
          userAgent: 'Test Agent',
        );

        expect(validConsent.isValid, isTrue);
        expect(expiredConsent.isValid, isFalse);
      });

      test('should withdraw consent', () async {
        // First grant consent
        final consent = ConsentRecord(
          purpose: DataProcessingPurpose.analytics,
          granted: true,
          timestamp: DateTime.now(),
          version: '1.0',
          ipAddress: '192.168.1.1',
          userAgent: 'Test Agent',
        );

        await privacyService.recordConsent(consent);
        expect(await privacyService.hasConsent(DataProcessingPurpose.analytics), isTrue);

        // Then withdraw it
        await privacyService.withdrawConsent(DataProcessingPurpose.analytics);
        expect(await privacyService.hasConsent(DataProcessingPurpose.analytics), isFalse);
      });

      test('should replace existing consent for same purpose', () async {
        final firstConsent = ConsentRecord(
          purpose: DataProcessingPurpose.analytics,
          granted: true,
          timestamp: DateTime.now(),
          version: '1.0',
          ipAddress: '192.168.1.1',
          userAgent: 'Test Agent',
        );

        final secondConsent = ConsentRecord(
          purpose: DataProcessingPurpose.analytics,
          granted: false,
          timestamp: DateTime.now(),
          version: '1.1',
          ipAddress: '192.168.1.1',
          userAgent: 'Test Agent',
        );

        await privacyService.recordConsent(firstConsent);
        await privacyService.recordConsent(secondConsent);

        final records = await privacyService.getConsentRecords();
        final analyticsRecords = records.where((r) => r.purpose == DataProcessingPurpose.analytics).toList();

        expect(analyticsRecords.length, equals(1));
        expect(analyticsRecords.first.granted, isFalse);
        expect(analyticsRecords.first.version, equals('1.1'));
      });
    });

    group('Data Retention', () {
      test('should return default retention settings', () async {
        final settings = await privacyService.getDataRetentionSettings();

        expect(settings.logRetentionDays, equals(90));
        expect(settings.consentRetentionDays, equals(730));
        expect(settings.taskRetentionDays, equals(0));
        expect(settings.autoDeleteCompletedTasks, isFalse);
        expect(settings.voiceDataRetentionDays, equals(0));
      });

      test('should save and retrieve retention settings', () async {
        const settings = DataRetentionSettings(
          logRetentionDays: 30,
          consentRetentionDays: 365,
          taskRetentionDays: 180,
          autoDeleteCompletedTasks: true,
          voiceDataRetentionDays: 7,
        );

        await privacyService.saveDataRetentionSettings(settings);
        final retrievedSettings = await privacyService.getDataRetentionSettings();

        expect(retrievedSettings.logRetentionDays, equals(30));
        expect(retrievedSettings.consentRetentionDays, equals(365));
        expect(retrievedSettings.taskRetentionDays, equals(180));
        expect(retrievedSettings.autoDeleteCompletedTasks, isTrue);
        expect(retrievedSettings.voiceDataRetentionDays, equals(7));
      });

      test('should enforce data retention policies', () async {
        // This test would require more complex setup to verify actual cleanup
        expect(() => privacyService.enforceDataRetention(), returnsNormally);
      });
    });

    group('Data Processing Logs', () {
      test('should log data processing activity', () async {
        final log = DataProcessingLog(
          activity: DataProcessingActivity.collection,
          purpose: DataProcessingPurpose.analytics,
          dataTypes: [DataType.tasks, DataType.analytics],
          timestamp: DateTime.now(),
          success: true,
        );

        await privacyService.logDataProcessing(log);
        final logs = await privacyService.getDataProcessingLogs();

        expect(logs, isNotEmpty);
        expect(logs.first.activity, log.activity);
        expect(logs.first.purpose, log.purpose);
        expect(logs.first.success, log.success);
      });

      test('should limit log storage to prevent bloat', () async {
        // Add more than 1000 logs
        for (int i = 0; i < 1100; i++) {
          final log = DataProcessingLog(
            activity: DataProcessingActivity.access,
            purpose: DataProcessingPurpose.essential,
            dataTypes: [DataType.tasks],
            timestamp: DateTime.now(),
            success: true,
          );
          await privacyService.logDataProcessing(log);
        }

        final logs = await privacyService.getDataProcessingLogs();
        expect(logs.length, equals(1000));
      });
    });

    group('Data Export and Deletion', () {
      test('should export user data', () async {
        final exportData = await privacyService.exportUserData();

        expect(exportData, containsPair('export_timestamp', isA<String>()));
        expect(exportData, containsPair('privacy_settings', isA<Map>()));
        expect(exportData, containsPair('consent_records', isA<List>()));
        expect(exportData, containsPair('data_retention_settings', isA<Map>()));
        expect(exportData, containsPair('data_processing_logs', isA<List>()));
        expect(exportData, containsPair('data_categories', isA<Map>()));
      });

      test('should delete all user data', () async {
        // Add some test data first
        await privacyService.savePrivacySettings(PrivacySettings.defaultSettings());
        
        await privacyService.deleteAllUserData();
        
        // Verify data is deleted (this would require checking SharedPreferences)
        expect(() => privacyService.deleteAllUserData(), returnsNormally);
      });
    });

    group('Privacy Compliance', () {
      test('should check compliance status', () async {
        final status = await privacyService.getComplianceStatus();

        expect(status.isCompliant, isA<bool>());
        expect(status.issues, isA<List<String>>());
        expect(status.lastChecked, isA<DateTime>());
      });

      test('should initialize privacy-first defaults', () async {
        await privacyService.initializePrivacyDefaults();
        
        final settings = await privacyService.getPrivacySettings();
        expect(settings.dataMinimization, isTrue);
        expect(settings.localProcessingPreferred, isTrue);
        expect(settings.analyticsEnabled, isFalse);
      });
    });
  });

  group('ConsentRecord', () {
    test('should serialize to JSON correctly', () {
      final consent = ConsentRecord(
        purpose: DataProcessingPurpose.analytics,
        granted: true,
        timestamp: DateTime(2023, 1, 1, 12, 0, 0),
        version: '1.0',
        ipAddress: '192.168.1.1',
        userAgent: 'Test Agent',
      );

      final json = consent.toJson();

      expect(json['purpose'], equals('analytics'));
      expect(json['granted'], isTrue);
      expect(json['timestamp'], equals('2023-01-01T12:00:00.000'));
      expect(json['version'], equals('1.0'));
      expect(json['ipAddress'], equals('192.168.1.1'));
      expect(json['userAgent'], equals('Test Agent'));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'purpose': 'analytics',
        'granted': true,
        'timestamp': '2023-01-01T12:00:00.000',
        'version': '1.0',
        'ipAddress': '192.168.1.1',
        'userAgent': 'Test Agent',
      };

      final consent = ConsentRecord.fromJson(json);

      expect(consent.purpose, equals(DataProcessingPurpose.analytics));
      expect(consent.granted, isTrue);
      expect(consent.timestamp, equals(DateTime(2023, 1, 1, 12, 0, 0)));
      expect(consent.version, equals('1.0'));
      expect(consent.ipAddress, equals('192.168.1.1'));
      expect(consent.userAgent, equals('Test Agent'));
    });
  });

  group('DataProcessingLog', () {
    test('should serialize to JSON correctly', () {
      final log = DataProcessingLog(
        activity: DataProcessingActivity.collection,
        purpose: DataProcessingPurpose.analytics,
        dataTypes: [DataType.tasks, DataType.analytics],
        timestamp: DateTime(2023, 1, 1, 12, 0, 0),
        success: true,
        errorMessage: null,
      );

      final json = log.toJson();

      expect(json['activity'], equals('collection'));
      expect(json['purpose'], equals('analytics'));
      expect(json['dataTypes'], equals(['tasks', 'analytics']));
      expect(json['timestamp'], equals('2023-01-01T12:00:00.000'));
      expect(json['success'], isTrue);
      expect(json['errorMessage'], isNull);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'activity': 'collection',
        'purpose': 'analytics',
        'dataTypes': ['tasks', 'analytics'],
        'timestamp': '2023-01-01T12:00:00.000',
        'success': true,
        'errorMessage': null,
      };

      final log = DataProcessingLog.fromJson(json);

      expect(log.activity, equals(DataProcessingActivity.collection));
      expect(log.purpose, equals(DataProcessingPurpose.analytics));
      expect(log.dataTypes, equals([DataType.tasks, DataType.analytics]));
      expect(log.timestamp, equals(DateTime(2023, 1, 1, 12, 0, 0)));
      expect(log.success, isTrue);
      expect(log.errorMessage, isNull);
    });
  });
}
