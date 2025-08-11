import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/ai_service_type.dart';

/// Secure API key management service using platform-specific secure storage
/// Uses Keychain on iOS and Keystore on Android
class APIKeyManager {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(),
  );

  // Storage keys
  static const String _openaiApiKeyKey = 'openai_api_key';
  static const String _claudeApiKeyKey = 'claude_api_key';
  static const String _openaiBaseUrlKey = 'openai_base_url';
  static const String _claudeBaseUrlKey = 'claude_base_url';

  /// Store OpenAI API key securely
  static Future<void> setOpenAIApiKey(String apiKey) async {
    try {
      if (apiKey.trim().isEmpty) {
        await _storage.delete(key: _openaiApiKeyKey);
      } else {
        await _storage.write(key: _openaiApiKeyKey, value: apiKey.trim());
      }
    } catch (e) {
      // Log error without exposing sensitive details
      if (kDebugMode) {
        print('Failed to store OpenAI API key securely');
      }
      throw Exception('Failed to store OpenAI API key securely');
    }
  }

  /// Store Claude API key securely
  static Future<void> setClaudeApiKey(String apiKey) async {
    try {
      if (apiKey.trim().isEmpty) {
        await _storage.delete(key: _claudeApiKeyKey);
      } else {
        await _storage.write(key: _claudeApiKeyKey, value: apiKey.trim());
      }
    } catch (e) {
      // Log error without exposing sensitive details
      if (kDebugMode) {
        print('Failed to store Claude API key securely');
      }
      throw Exception('Failed to store Claude API key securely');
    }
  }

  /// Retrieve OpenAI API key securely
  static Future<String?> getOpenAIApiKey() async {
    try {
      return await _storage.read(key: _openaiApiKeyKey);
    } catch (e) {
      // Log error without exposing sensitive details
      if (kDebugMode) {
        print('Failed to retrieve OpenAI API key');
      }
      return null;
    }
  }

  /// Retrieve Claude API key securely
  static Future<String?> getClaudeApiKey() async {
    try {
      return await _storage.read(key: _claudeApiKeyKey);
    } catch (e) {
      // Log error without exposing sensitive details
      if (kDebugMode) {
        print('Failed to retrieve Claude API key');
      }
      return null;
    }
  }

  /// Store OpenAI base URL
  static Future<void> setOpenAIBaseUrl(String? baseUrl) async {
    try {
      if (baseUrl == null || baseUrl.trim().isEmpty) {
        await _storage.delete(key: _openaiBaseUrlKey);
      } else {
        await _storage.write(key: _openaiBaseUrlKey, value: baseUrl.trim());
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to store OpenAI base URL');
      }
      throw Exception('Failed to store OpenAI base URL');
    }
  }

  /// Store Claude base URL
  static Future<void> setClaudeBaseUrl(String? baseUrl) async {
    try {
      if (baseUrl == null || baseUrl.trim().isEmpty) {
        await _storage.delete(key: _claudeBaseUrlKey);
      } else {
        await _storage.write(key: _claudeBaseUrlKey, value: baseUrl.trim());
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to store Claude base URL');
      }
      throw Exception('Failed to store Claude base URL');
    }
  }

  /// Retrieve OpenAI base URL
  static Future<String?> getOpenAIBaseUrl() async {
    try {
      return await _storage.read(key: _openaiBaseUrlKey);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to retrieve OpenAI base URL');
      }
      return null;
    }
  }

  /// Retrieve Claude base URL
  static Future<String?> getClaudeBaseUrl() async {
    try {
      return await _storage.read(key: _claudeBaseUrlKey);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to retrieve Claude base URL');
      }
      return null;
    }
  }

  /// Check if OpenAI API key is configured
  static Future<bool> hasOpenAIApiKey() async {
    final apiKey = await getOpenAIApiKey();
    return apiKey != null && apiKey.trim().isNotEmpty;
  }

  /// Check if Claude API key is configured
  static Future<bool> hasClaudeApiKey() async {
    final apiKey = await getClaudeApiKey();
    return apiKey != null && apiKey.trim().isNotEmpty;
  }

  /// Clear all stored API keys (for logout or reset)
  static Future<void> clearAllApiKeys() async {
    try {
      await Future.wait([
        _storage.delete(key: _openaiApiKeyKey),
        _storage.delete(key: _claudeApiKeyKey),
        _storage.delete(key: _openaiBaseUrlKey),
        _storage.delete(key: _claudeBaseUrlKey),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to clear API keys');
      }
      throw Exception('Failed to clear API keys');
    }
  }

  /// Validate API key format (basic validation)
  static bool isValidApiKeyFormat(String apiKey, AIServiceType serviceType) {
    if (apiKey.trim().isEmpty) return false;
    
    switch (serviceType) {
      case AIServiceType.openai:
        // OpenAI keys typically start with 'sk-' and are 51 characters long
        return apiKey.startsWith('sk-') && apiKey.length >= 20;
      case AIServiceType.claude:
        // Claude keys typically start with 'sk-ant-' or similar
        return apiKey.length >= 20 && apiKey.contains('-');
      default:
        return false;
    }
  }

  /// Get masked version of API key for display (shows only first/last few characters)
  static String getMaskedApiKey(String apiKey) {
    if (apiKey.length <= 8) {
      return '*' * apiKey.length;
    }
    
    final prefix = apiKey.substring(0, 4);
    final suffix = apiKey.substring(apiKey.length - 4);
    final middleLength = apiKey.length - 8;
    
    return '$prefix${'*' * middleLength}$suffix';
  }
}

// AIServiceType enum moved to domain/models/ai_service_type.dart