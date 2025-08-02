import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';

/// Service for managing app security and authentication
class SecurityService {
  static const String _appLockEnabledKey = 'app_lock_enabled';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _pinHashKey = 'pin_hash';
  static const String _saltKey = 'salt';
  static const String _lockTimeoutKey = 'lock_timeout';
  static const String _maxAttemptsKey = 'max_attempts';
  static const String _failedAttemptsKey = 'failed_attempts';
  static const String _lastFailedAttemptKey = 'last_failed_attempt';
  static const String _lockoutUntilKey = 'lockout_until';

  final LocalAuthentication _localAuth = const LocalAuthentication();

  /// Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticateWithBiometrics({
    String reason = 'Please authenticate to access the app',
  }) async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedFallbackTitle: 'Use PIN instead',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Biometric authentication required',
            cancelButton: 'No thanks',
          ),
          IOSAuthMessages(
            cancelButton: 'No thanks',
          ),
        ],
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      return isAuthenticated;
    } catch (e) {
      return false;
    }
  }

  /// Set up PIN authentication
  Future<bool> setupPin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salt = _generateSalt();
      final hashedPin = _hashPin(pin, salt);
      
      await prefs.setString(_pinHashKey, hashedPin);
      await prefs.setString(_saltKey, salt);
      await prefs.setBool(_appLockEnabledKey, true);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedHash = prefs.getString(_pinHashKey);
      final salt = prefs.getString(_saltKey);
      
      if (storedHash == null || salt == null) {
        return false;
      }
      
      final hashedPin = _hashPin(pin, salt);
      final isValid = hashedPin == storedHash;
      
      if (isValid) {
        await _resetFailedAttempts();
      } else {
        await _recordFailedAttempt();
      }
      
      return isValid;
    } catch (e) {
      return false;
    }
  }

  /// Check if app lock is enabled
  Future<bool> isAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_appLockEnabledKey) ?? false;
  }

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  /// Disable app lock
  Future<void> disableAppLock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_appLockEnabledKey, false);
    await prefs.setBool(_biometricEnabledKey, false);
    await prefs.remove(_pinHashKey);
    await prefs.remove(_saltKey);
    await _resetFailedAttempts();
  }

  /// Get lock timeout duration
  Future<Duration> getLockTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    final minutes = prefs.getInt(_lockTimeoutKey) ?? 5;
    return Duration(minutes: minutes);
  }

  /// Set lock timeout duration
  Future<void> setLockTimeout(Duration timeout) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lockTimeoutKey, timeout.inMinutes);
  }

  /// Check if app is currently locked out due to failed attempts
  Future<bool> isLockedOut() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutUntil = prefs.getInt(_lockoutUntilKey);
    
    if (lockoutUntil == null) return false;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= lockoutUntil) {
      await _resetFailedAttempts();
      return false;
    }
    
    return true;
  }

  /// Get remaining lockout time
  Future<Duration?> getRemainingLockoutTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutUntil = prefs.getInt(_lockoutUntilKey);
    
    if (lockoutUntil == null) return null;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= lockoutUntil) {
      await _resetFailedAttempts();
      return null;
    }
    
    return Duration(milliseconds: lockoutUntil - now);
  }

  /// Get number of failed attempts
  Future<int> getFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_failedAttemptsKey) ?? 0;
  }

  /// Get maximum allowed attempts
  Future<int> getMaxAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_maxAttemptsKey) ?? 5;
  }

  /// Set maximum allowed attempts
  Future<void> setMaxAttempts(int maxAttempts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_maxAttemptsKey, maxAttempts);
  }

  /// Generate a random salt for PIN hashing
  String _generateSalt() {
    final bytes = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      bytes[i] = DateTime.now().millisecondsSinceEpoch % 256;
    }
    return base64.encode(bytes);
  }

  /// Hash PIN with salt
  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode(pin + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Record a failed authentication attempt
  Future<void> _recordFailedAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    final currentAttempts = prefs.getInt(_failedAttemptsKey) ?? 0;
    final maxAttempts = await getMaxAttempts();
    
    final newAttempts = currentAttempts + 1;
    await prefs.setInt(_failedAttemptsKey, newAttempts);
    await prefs.setInt(_lastFailedAttemptKey, DateTime.now().millisecondsSinceEpoch);
    
    // If max attempts reached, set lockout
    if (newAttempts >= maxAttempts) {
      final lockoutDuration = _calculateLockoutDuration(newAttempts);
      final lockoutUntil = DateTime.now().add(lockoutDuration).millisecondsSinceEpoch;
      await prefs.setInt(_lockoutUntilKey, lockoutUntil);
    }
  }

  /// Reset failed attempts counter
  Future<void> _resetFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_failedAttemptsKey);
    await prefs.remove(_lastFailedAttemptKey);
    await prefs.remove(_lockoutUntilKey);
  }

  /// Calculate lockout duration based on failed attempts
  Duration _calculateLockoutDuration(int failedAttempts) {
    // Exponential backoff: 1 min, 5 min, 15 min, 30 min, 1 hour, etc.
    switch (failedAttempts) {
      case 5:
        return const Duration(minutes: 1);
      case 6:
        return const Duration(minutes: 5);
      case 7:
        return const Duration(minutes: 15);
      case 8:
        return const Duration(minutes: 30);
      default:
        return const Duration(hours: 1);
    }
  }

  /// Check if PIN has been set
  Future<bool> isPinSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinHashKey) != null;
  }

  /// Change existing PIN
  Future<bool> changePin(String oldPin, String newPin) async {
    final isOldPinValid = await verifyPin(oldPin);
    if (!isOldPinValid) {
      return false;
    }
    
    return await setupPin(newPin);
  }

  /// Get security settings
  Future<SecuritySettings> getSecuritySettings() async {
    return SecuritySettings(
      appLockEnabled: await isAppLockEnabled(),
      biometricEnabled: await isBiometricEnabled(),
      lockTimeout: await getLockTimeout(),
      maxAttempts: await getMaxAttempts(),
      isPinSet: await isPinSet(),
      biometricAvailable: await isBiometricAvailable(),
      availableBiometrics: await getAvailableBiometrics(),
    );
  }
}

/// Security settings data model
class SecuritySettings {
  final bool appLockEnabled;
  final bool biometricEnabled;
  final Duration lockTimeout;
  final int maxAttempts;
  final bool isPinSet;
  final bool biometricAvailable;
  final List<BiometricType> availableBiometrics;

  const SecuritySettings({
    required this.appLockEnabled,
    required this.biometricEnabled,
    required this.lockTimeout,
    required this.maxAttempts,
    required this.isPinSet,
    required this.biometricAvailable,
    required this.availableBiometrics,
  });

  SecuritySettings copyWith({
    bool? appLockEnabled,
    bool? biometricEnabled,
    Duration? lockTimeout,
    int? maxAttempts,
    bool? isPinSet,
    bool? biometricAvailable,
    List<BiometricType>? availableBiometrics,
  }) {
    return SecuritySettings(
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      lockTimeout: lockTimeout ?? this.lockTimeout,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      isPinSet: isPinSet ?? this.isPinSet,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      availableBiometrics: availableBiometrics ?? this.availableBiometrics,
    );
  }
}

/// Authentication state
enum AuthenticationState {
  authenticated,
  unauthenticated,
  lockedOut,
  biometricRequired,
  pinRequired,
}

/// Providers for security service
final securityServiceProvider = Provider<SecurityService>((ref) {
  return const SecurityService();
});

final securitySettingsProvider = StateNotifierProvider<SecuritySettingsNotifier, AsyncValue<SecuritySettings>>((ref) {
  return SecuritySettingsNotifier(ref.read(securityServiceProvider));
});

final authenticationStateProvider = StateNotifierProvider<AuthenticationStateNotifier, AuthenticationState>((ref) {
  return AuthenticationStateNotifier(ref.read(securityServiceProvider));
});

/// Security settings notifier
class SecuritySettingsNotifier extends StateNotifier<AsyncValue<SecuritySettings>> {
  final SecurityService _securityService;

  SecuritySettingsNotifier(this._securityService) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _securityService.getSecuritySettings();
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadSettings();
  }

  Future<bool> setupPin(String pin) async {
    final success = await _securityService.setupPin(pin);
    if (success) {
      await _loadSettings();
    }
    return success;
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    final success = await _securityService.changePin(oldPin, newPin);
    if (success) {
      await _loadSettings();
    }
    return success;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _securityService.setBiometricEnabled(enabled);
    await _loadSettings();
  }

  Future<void> setLockTimeout(Duration timeout) async {
    await _securityService.setLockTimeout(timeout);
    await _loadSettings();
  }

  Future<void> setMaxAttempts(int maxAttempts) async {
    await _securityService.setMaxAttempts(maxAttempts);
    await _loadSettings();
  }

  Future<void> disableAppLock() async {
    await _securityService.disableAppLock();
    await _loadSettings();
  }
}

/// Authentication state notifier
class AuthenticationStateNotifier extends StateNotifier<AuthenticationState> {
  final SecurityService _securityService;

  AuthenticationStateNotifier(this._securityService) : super(AuthenticationState.unauthenticated) {
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    final isAppLockEnabled = await _securityService.isAppLockEnabled();
    if (!isAppLockEnabled) {
      state = AuthenticationState.authenticated;
      return;
    }

    final isLockedOut = await _securityService.isLockedOut();
    if (isLockedOut) {
      state = AuthenticationState.lockedOut;
      return;
    }

    final isBiometricEnabled = await _securityService.isBiometricEnabled();
    final isBiometricAvailable = await _securityService.isBiometricAvailable();
    
    if (isBiometricEnabled && isBiometricAvailable) {
      state = AuthenticationState.biometricRequired;
    } else {
      state = AuthenticationState.pinRequired;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    final success = await _securityService.authenticateWithBiometrics();
    if (success) {
      state = AuthenticationState.authenticated;
    }
    return success;
  }

  Future<bool> authenticateWithPin(String pin) async {
    final isLockedOut = await _securityService.isLockedOut();
    if (isLockedOut) {
      state = AuthenticationState.lockedOut;
      return false;
    }

    final success = await _securityService.verifyPin(pin);
    if (success) {
      state = AuthenticationState.authenticated;
    } else {
      final newLockoutState = await _securityService.isLockedOut();
      if (newLockoutState) {
        state = AuthenticationState.lockedOut;
      }
    }
    return success;
  }

  void logout() {
    state = AuthenticationState.unauthenticated;
    _checkInitialState();
  }

  Future<void> refresh() async {
    await _checkInitialState();
  }

  void switchToPinAuthentication() {
    state = AuthenticationState.pinRequired;
  }

  void switchToBiometricAuthentication() {
    state = AuthenticationState.biometricRequired;
  }
}