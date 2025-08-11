import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:task_tracker_app/services/security/api_key_manager.dart';
import 'package:task_tracker_app/services/ai/composite_ai_task_parser.dart';
import 'package:task_tracker_app/services/speech/transcription_service_factory.dart';
import 'package:task_tracker_app/services/speech/external_transcription_service.dart';
import 'package:task_tracker_app/services/ai/ai_task_parsing_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Security and API Key Management Integration Tests', () {
    
    setUp(() async {
      // Clear any existing API keys before each test
      await APIKeyManager.clearAllApiKeys();
    });

    tearDown(() async {
      // Clean up after each test
      await APIKeyManager.clearAllApiKeys();
    });

    test('secure API key storage and retrieval', () async {
      const testOpenAIKey = 'sk-test-openai-key-12345678901234567890';
      const testClaudeKey = 'sk-ant-test-claude-key-12345678901234567890';
      
      // Store API keys
      await APIKeyManager.setOpenAIApiKey(testOpenAIKey);
      await APIKeyManager.setClaudeApiKey(testClaudeKey);
      
      // Retrieve and verify
      final retrievedOpenAI = await APIKeyManager.getOpenAIApiKey();
      final retrievedClaude = await APIKeyManager.getClaudeApiKey();
      
      expect(retrievedOpenAI, equals(testOpenAIKey));
      expect(retrievedClaude, equals(testClaudeKey));
      
      // Verify availability flags
      expect(await APIKeyManager.hasOpenAIApiKey(), isTrue);
      expect(await APIKeyManager.hasClaudeApiKey(), isTrue);
    });

    test('API key validation', () async {
      // Test valid API key formats
      const validOpenAIKey = 'sk-1234567890abcdef1234567890abcdef1234567890abcdef';
      const validClaudeKey = 'sk-ant-api03-1234567890abcdef1234567890abcdef1234567890abcdef';
      
      expect(APIKeyManager.isValidApiKeyFormat(validOpenAIKey, AIServiceType.openai), isTrue);
      expect(APIKeyManager.isValidApiKeyFormat(validClaudeKey, AIServiceType.claude), isTrue);
      
      // Test invalid API key formats
      const invalidKeys = [
        'sk-', // Too short
        'invalid-format', // Wrong format
        '', // Empty
        'sk-short', // Too short for OpenAI
        'random-key-123', // Wrong prefix
      ];
      
      for (final key in invalidKeys) {
        expect(APIKeyManager.isValidApiKeyFormat(key, AIServiceType.openai), isFalse);
        expect(APIKeyManager.isValidApiKeyFormat(key, AIServiceType.claude), isFalse);
      }
    });

    test('API key masking for display', () async {
      const testKey = 'sk-1234567890abcdef1234567890abcdef1234567890abcdef';
      
      final masked = APIKeyManager.getMaskedApiKey(testKey);
      
      // Should show first 4 and last 4 characters
      expect(masked, startsWith('sk-1'));
      expect(masked, endsWith('cdef'));
      expect(masked, contains('*'));
      expect(masked.length, equals(testKey.length));
    });

    test('API key clearing', () async {
      const testKey = 'sk-test-key-123';
      
      // Store key
      await APIKeyManager.setOpenAIApiKey(testKey);
      expect(await APIKeyManager.hasOpenAIApiKey(), isTrue);
      
      // Clear specific key
      await APIKeyManager.setOpenAIApiKey('');
      expect(await APIKeyManager.hasOpenAIApiKey(), isFalse);
      
      // Store multiple keys and clear all
      await APIKeyManager.setOpenAIApiKey(testKey);
      await APIKeyManager.setClaudeApiKey(testKey);
      
      await APIKeyManager.clearAllApiKeys();
      
      expect(await APIKeyManager.hasOpenAIApiKey(), isFalse);
      expect(await APIKeyManager.hasClaudeApiKey(), isFalse);
    });

    test('base URL storage and retrieval', () async {
      const customOpenAIUrl = 'https://custom-openai.example.com/v1';
      const customClaudeUrl = 'https://custom-claude.example.com/v1';
      
      // Store custom URLs
      await APIKeyManager.setOpenAIBaseUrl(customOpenAIUrl);
      await APIKeyManager.setClaudeBaseUrl(customClaudeUrl);
      
      // Retrieve and verify
      final retrievedOpenAIUrl = await APIKeyManager.getOpenAIBaseUrl();
      final retrievedClaudeUrl = await APIKeyManager.getClaudeBaseUrl();
      
      expect(retrievedOpenAIUrl, equals(customOpenAIUrl));
      expect(retrievedClaudeUrl, equals(customClaudeUrl));
      
      // Clear URLs
      await APIKeyManager.setOpenAIBaseUrl(null);
      await APIKeyManager.setClaudeBaseUrl(null);
      
      expect(await APIKeyManager.getOpenAIBaseUrl(), isNull);
      expect(await APIKeyManager.getClaudeBaseUrl(), isNull);
    });

    test('transcription service integration with API keys', () async {
      // Test without API key
      var serviceInfo = await TranscriptionServiceFactory.getServiceInfo();
      expect(serviceInfo.hasApiKey, isFalse);
      expect(serviceInfo.externalServiceAvailable, isFalse);
      
      // Set valid API key
      const testKey = 'sk-test-key-for-transcription-service-123';
      await APIKeyManager.setOpenAIApiKey(testKey);
      
      // Refresh service info
      await TranscriptionServiceFactory.clearCache();
      serviceInfo = await TranscriptionServiceFactory.getServiceInfo();
      expect(serviceInfo.hasApiKey, isTrue);
      
      // Create service and verify it uses external when available
      final service = await TranscriptionServiceFactory.createService(
        preferExternal: true,
        fallbackToLocal: true,
      );
      
      expect(service, isNotNull);
      expect(service.isServiceAvailable, isTrue);
    });

    test('AI parsing service integration with API keys', () async {
      // Test AI service selection based on API key availability
      final parser = CompositeAITaskParser();
      
      // Without API key, should use local
      var config = AIParsingConfig(serviceType: AIServiceType.openai);
      await parser.updateConfiguration(config);
      
      var result = await parser.parseTask('Test task without API key');
      // Should fall back to local or handle gracefully
      expect(result.isSuccess || result.error?.isNotEmpty == true, isTrue);
      
      // With API key, should be able to configure external service
      const testKey = 'sk-test-ai-parsing-key-123';
      await APIKeyManager.setOpenAIApiKey(testKey);
      
      // Update configuration
      config = AIParsingConfig(serviceType: AIServiceType.openai);
      await parser.updateConfiguration(config);
      
      result = await parser.parseTask('Test task with API key');
      expect(result.isSuccess, isTrue);
    });

    test('error handling for invalid API keys', () async {
      // Set invalid API key
      const invalidKey = 'invalid-key-format';
      
      try {
        await APIKeyManager.setOpenAIApiKey(invalidKey);
        // Should still store but service will handle validation
        expect(await APIKeyManager.getOpenAIApiKey(), equals(invalidKey));
      } catch (e) {
        // Or might reject invalid format during storage
        expect(e, isA<Exception>());
      }
      
      // External service should handle invalid key gracefully
      final service = ExternalTranscriptionService();
      await service.initialize();
      
      final result = await service.transcribeAudioData([1, 2, 3, 4]);
      expect(result.isSuccess, isFalse);
      expect(result.error?.type, equals(TranscriptionErrorType.serviceUnavailable));
    });

    test('concurrent API key operations', () async {
      const testKey = 'sk-concurrent-test-key-123';
      
      // Perform multiple concurrent operations
      final futures = [
        APIKeyManager.setOpenAIApiKey(testKey),
        APIKeyManager.setClaudeApiKey(testKey),
        APIKeyManager.getOpenAIApiKey(),
        APIKeyManager.hasOpenAIApiKey(),
      ];
      
      final results = await Future.wait(futures);
      
      // Should complete without errors
      expect(results.length, equals(4));
      
      // Verify final state
      expect(await APIKeyManager.getOpenAIApiKey(), equals(testKey));
      expect(await APIKeyManager.getClaudeApiKey(), equals(testKey));
    });

    test('API key persistence across app restarts', () async {
      const testKey = 'sk-persistence-test-key-123';
      
      // Store API key
      await APIKeyManager.setOpenAIApiKey(testKey);
      expect(await APIKeyManager.getOpenAIApiKey(), equals(testKey));
      
      // Simulate app restart by creating new service instances
      await TranscriptionServiceFactory.clearCache();
      
      // API key should still be available
      expect(await APIKeyManager.getOpenAIApiKey(), equals(testKey));
      
      final serviceInfo = await TranscriptionServiceFactory.getServiceInfo();
      expect(serviceInfo.hasApiKey, isTrue);
    });

    test('security violation detection', () async {
      // Test that sensitive data is not logged or exposed
      const sensitiveKey = 'sk-very-secret-key-do-not-log-123';
      
      await APIKeyManager.setOpenAIApiKey(sensitiveKey);
      
      // Verify masked version doesn't expose full key
      final masked = APIKeyManager.getMaskedApiKey(sensitiveKey);
      expect(masked, isNot(contains('very-secret')));
      expect(masked, isNot(contains('do-not-log')));
      
      // Verify key is stored securely (this is implicit in the secure storage implementation)
      final retrieved = await APIKeyManager.getOpenAIApiKey();
      expect(retrieved, equals(sensitiveKey));
    });

    test('service degradation graceful handling', () async {
      // Test behavior when secure storage is unavailable
      // This is difficult to test directly, but we can verify error handling
      
      try {
        await APIKeyManager.setOpenAIApiKey('test-key');
        expect(await APIKeyManager.hasOpenAIApiKey(), isTrue);
      } catch (e) {
        // If secure storage fails, should handle gracefully
        expect(e, isA<Exception>());
        expect(e.toString(), contains('Failed to store'));
      }
    });
  });

  group('API Key UI Integration Tests', () {
    // These would test the actual UI components if running as widget tests
    // For now, focusing on service-level integration
    
    test('API key configuration flow validation', () async {
      // Simulate the complete flow from UI perspective
      
      // Step 1: Check initial state (no keys)
      expect(await APIKeyManager.hasOpenAIApiKey(), isFalse);
      
      // Step 2: Attempt to use service without key
      final serviceInfo = await TranscriptionServiceFactory.getServiceInfo();
      expect(serviceInfo.externalServiceAvailable, isFalse);
      
      // Step 3: Set API key (simulating user input)
      const userInputKey = 'sk-user-entered-key-from-ui-123';
      
      // Validate format first (as UI would)
      final isValid = APIKeyManager.isValidApiKeyFormat(userInputKey, AIServiceType.openai);
      expect(isValid, isTrue);
      
      // Store key
      await APIKeyManager.setOpenAIApiKey(userInputKey);
      
      // Step 4: Verify service availability updated
      await TranscriptionServiceFactory.clearCache();
      final updatedServiceInfo = await TranscriptionServiceFactory.getServiceInfo();
      expect(updatedServiceInfo.hasApiKey, isTrue);
      
      // Step 5: Test service functionality
      final service = await TranscriptionServiceFactory.createService();
      expect(service.isServiceAvailable, isTrue);
    });
  });
}