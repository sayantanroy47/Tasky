import 'transcription_service.dart';
import 'transcription_service_impl.dart';
import 'external_transcription_service.dart' as ext_service;
import '../../services/security/api_key_manager.dart';

/// Factory for creating the appropriate transcription service
/// 
/// This factory determines which transcription service to use based on:
/// - API key availability
/// - Service preferences
/// - Platform capabilities
class TranscriptionServiceFactory {
  static TranscriptionService? _cachedService;

  /// Create the best available transcription service
  static Future<TranscriptionService> createService({
    bool preferExternal = true,
    bool fallbackToLocal = true,
  }) async {
    // Return cached service if available
    if (_cachedService != null) {
      return _cachedService!;
    }

    TranscriptionService service;

    if (preferExternal) {
      // Check if external API key is available
      final hasOpenAIKey = await APIKeyManager.hasOpenAIApiKey();
      
      if (hasOpenAIKey) {
        // Use external service
        service = ext_service.ExternalTranscriptionService();
        final initialized = await service.initialize();
        
        if (initialized) {
          // Test connection to ensure API key is valid
          if (service is ext_service.ExternalTranscriptionService) {
            final connectionOk = await service.testConnection();
            if (connectionOk) {
              _cachedService = service;
              return service;
            }
          }
        }
      }
      
      // If external service failed and fallback is enabled
      if (fallbackToLocal) {
        service = TranscriptionServiceImpl();
        final initialized = await service.initialize();
        
        if (initialized) {
          _cachedService = service;
          return service;
        }
      }
      
      // If no fallback, return external service anyway (will handle errors gracefully)
      service = ext_service.ExternalTranscriptionService();
      await service.initialize();
      _cachedService = service;
      return service;
    } else {
      // Prefer local service
      service = TranscriptionServiceImpl();
      final initialized = await service.initialize();
      
      if (initialized) {
        _cachedService = service;
        return service;
      }
      
      // Fallback to external if local fails
      if (fallbackToLocal) {
        service = ext_service.ExternalTranscriptionService();
        await service.initialize();
        _cachedService = service;
        return service;
      }
      
      // Return local service anyway (will handle errors gracefully)
      _cachedService = service;
      return service;
    }
  }

  /// Create external transcription service specifically
  static Future<ext_service.ExternalTranscriptionService> createExternalService() async {
    final service = ext_service.ExternalTranscriptionService();
    await service.initialize();
    return service;
  }

  /// Create local transcription service specifically
  static Future<TranscriptionServiceImpl> createLocalService() async {
    final service = TranscriptionServiceImpl();
    await service.initialize();
    return service;
  }

  /// Get service capabilities and status
  static Future<TranscriptionServiceInfo> getServiceInfo() async {
    final hasOpenAIKey = await APIKeyManager.hasOpenAIApiKey();
    
    // Test local service availability
    final localService = TranscriptionServiceImpl();
    final localAvailable = await localService.initialize();
    await localService.dispose();
    
    // Test external service if API key is available
    bool externalAvailable = false;
    if (hasOpenAIKey) {
      final externalService = ext_service.ExternalTranscriptionService();
      externalAvailable = await externalService.initialize();
      if (externalAvailable && externalService is ext_service.ExternalTranscriptionService) {
        externalAvailable = await externalService.testConnection();
      }
      await externalService.dispose();
    }

    return TranscriptionServiceInfo(
      hasApiKey: hasOpenAIKey,
      localServiceAvailable: localAvailable,
      externalServiceAvailable: externalAvailable,
      recommendedService: _getRecommendedServiceType(hasOpenAIKey, localAvailable, externalAvailable),
    );
  }

  /// Determine the recommended service type
  static TranscriptionServiceType _getRecommendedServiceType(
    bool hasApiKey,
    bool localAvailable,
    bool externalAvailable,
  ) {
    if (hasApiKey && externalAvailable) {
      return TranscriptionServiceType.external;
    } else if (localAvailable) {
      return TranscriptionServiceType.local;
    } else {
      return TranscriptionServiceType.none;
    }
  }

  /// Clear cached service (useful when API keys change)
  static Future<void> clearCache() async {
    if (_cachedService != null) {
      await _cachedService!.dispose();
      _cachedService = null;
    }
  }

  /// Refresh service (clear cache and recreate)
  static Future<TranscriptionService> refreshService({
    bool preferExternal = true,
    bool fallbackToLocal = true,
  }) async {
    await clearCache();
    return await createService(
      preferExternal: preferExternal,
      fallbackToLocal: fallbackToLocal,
    );
  }
}

/// Information about available transcription services
class TranscriptionServiceInfo {
  final bool hasApiKey;
  final bool localServiceAvailable;
  final bool externalServiceAvailable;
  final TranscriptionServiceType recommendedService;

  const TranscriptionServiceInfo({
    required this.hasApiKey,
    required this.localServiceAvailable,
    required this.externalServiceAvailable,
    required this.recommendedService,
  });

  bool get hasAnyServiceAvailable => localServiceAvailable || externalServiceAvailable;
  
  String get statusMessage {
    if (!hasAnyServiceAvailable) {
      return 'No transcription services available';
    } else if (hasApiKey && externalServiceAvailable) {
      return 'External API transcription available (high quality)';
    } else if (localServiceAvailable) {
      return 'Local device transcription available';
    } else {
      return 'Transcription services configured but not available';
    }
  }
}

/// Types of transcription services
enum TranscriptionServiceType {
  local,
  external,
  none;

  String get displayName {
    switch (this) {
      case TranscriptionServiceType.local:
        return 'Local Device';
      case TranscriptionServiceType.external:
        return 'External API';
      case TranscriptionServiceType.none:
        return 'Not Available';
    }
  }

  String get description {
    switch (this) {
      case TranscriptionServiceType.local:
        return 'Uses device speech recognition, works offline';
      case TranscriptionServiceType.external:
        return 'Uses external API for high-quality transcription';
      case TranscriptionServiceType.none:
        return 'No transcription service available';
    }
  }
}