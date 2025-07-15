import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for handling biometric authentication
///
/// Provides functionality for:
/// - Checking biometric availability
/// - Enabling/disabling biometric authentication
/// - Authenticating with biometrics
/// - Managing biometric preferences
class BiometricService {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricTokenKey = 'biometric_auth_token';

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Check if biometric authentication is available on the device
  Future<BiometricAvailability> checkBiometricAvailability() async {
    try {
      developer.log(
        'Checking biometric availability',
        name: 'BiometricService',
      );

      // Check if device supports biometrics
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        developer.log(
          'Device does not support biometrics',
          name: 'BiometricService',
        );
        return BiometricAvailability.notAvailable;
      }

      // Check if biometrics are enrolled
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        developer.log(
          'Device does not support biometrics',
          name: 'BiometricService',
        );
        return BiometricAvailability.notSupported;
      }

      // Get available biometric types
      final List<BiometricType> availableBiometrics = await _localAuth
          .getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        developer.log(
          'No biometrics enrolled on device',
          name: 'BiometricService',
        );
        return BiometricAvailability.notEnrolled;
      }

      developer.log(
        'Biometrics available: $availableBiometrics',
        name: 'BiometricService',
      );
      return BiometricAvailability.available;
    } catch (e) {
      developer.log(
        'Error checking biometric availability: $e',
        name: 'BiometricService',
      );
      return BiometricAvailability.error;
    }
  }

  /// Get available biometric types on the device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      developer.log(
        'Error getting available biometrics: $e',
        name: 'BiometricService',
      );
      return [];
    }
  }

  /// Check if biometric authentication is enabled by user
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(_biometricEnabledKey) ?? false;

      // Also check if we have a stored biometric token
      final hasToken =
          await _secureStorage.read(key: _biometricTokenKey) != null;

      return isEnabled && hasToken;
    } catch (e) {
      developer.log(
        'Error checking biometric enabled status: $e',
        name: 'BiometricService',
      );
      return false;
    }
  }

  /// Enable biometric authentication
  /// This should be called after successful password authentication
  Future<BiometricResult> enableBiometric(String authToken) async {
    try {
      developer.log(
        'Enabling biometric authentication',
        name: 'BiometricService',
      );

      // First check if biometrics are available
      final availability = await checkBiometricAvailability();
      if (availability != BiometricAvailability.available) {
        return BiometricResult.error(
          'Biometric authentication is not available',
        );
      }

      // Authenticate with biometrics to confirm setup
      final bool authenticated = await _authenticateWithBiometrics(
        reason: 'Enable biometric authentication for quick sign-in',
        isSetup: true,
      );

      if (!authenticated) {
        return BiometricResult.error('Biometric authentication failed');
      }

      // Store the auth token securely
      await _secureStorage.write(key: _biometricTokenKey, value: authToken);

      // Enable biometric preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, true);

      developer.log(
        'Biometric authentication enabled successfully',
        name: 'BiometricService',
      );
      return BiometricResult.success('Biometric authentication enabled');
    } catch (e) {
      developer.log(
        'Error enabling biometric authentication: $e',
        name: 'BiometricService',
      );
      return BiometricResult.error('Failed to enable biometric authentication');
    }
  }

  /// Disable biometric authentication
  Future<BiometricResult> disableBiometric() async {
    try {
      developer.log(
        'Disabling biometric authentication',
        name: 'BiometricService',
      );

      // Remove stored token
      await _secureStorage.delete(key: _biometricTokenKey);

      // Disable biometric preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, false);

      developer.log(
        'Biometric authentication disabled successfully',
        name: 'BiometricService',
      );
      return BiometricResult.success('Biometric authentication disabled');
    } catch (e) {
      developer.log(
        'Error disabling biometric authentication: $e',
        name: 'BiometricService',
      );
      return BiometricResult.error(
        'Failed to disable biometric authentication',
      );
    }
  }

  /// Authenticate using biometrics
  Future<BiometricAuthResult> authenticateWithBiometric() async {
    try {
      developer.log(
        'Attempting biometric authentication',
        name: 'BiometricService',
      );

      // Check if biometric is enabled
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        return BiometricAuthResult.notEnabled();
      }

      // Authenticate with biometrics
      final bool authenticated = await _authenticateWithBiometrics(
        reason: 'Use your biometric to sign in to SEEDIT',
      );

      if (!authenticated) {
        return BiometricAuthResult.failed('Biometric authentication failed');
      }

      // Get stored auth token
      final authToken = await _secureStorage.read(key: _biometricTokenKey);
      if (authToken == null) {
        // Token not found, disable biometric and return error
        await disableBiometric();
        return BiometricAuthResult.failed('Authentication token not found');
      }

      developer.log(
        'Biometric authentication successful',
        name: 'BiometricService',
      );
      return BiometricAuthResult.success(authToken);
    } catch (e) {
      developer.log(
        'Error during biometric authentication: $e',
        name: 'BiometricService',
      );
      return BiometricAuthResult.failed('Biometric authentication error');
    }
  }

  /// Internal method to handle biometric authentication
  Future<bool> _authenticateWithBiometrics({
    required String reason,
    bool isSetup = false,
  }) async {
    try {
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // Allow fallback to device credentials
          stickyAuth: true,
        ),
      );

      return authenticated;
    } on PlatformException catch (e) {
      developer.log(
        'Platform exception during biometric auth: ${e.code} - ${e.message}',
        name: 'BiometricService',
      );

      // Handle specific error codes
      switch (e.code) {
        case auth_error.notAvailable:
        case auth_error.notEnrolled:
          return false;
        case auth_error.lockedOut:
        case auth_error.permanentlyLockedOut:
          return false;
        default:
          return false;
      }
    } catch (e) {
      developer.log(
        'Error during biometric authentication: $e',
        name: 'BiometricService',
      );
      return false;
    }
  }

  /// Clear all biometric data (for logout)
  Future<void> clearBiometricData() async {
    try {
      await _secureStorage.delete(key: _biometricTokenKey);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_biometricEnabledKey);
      developer.log('Biometric data cleared', name: 'BiometricService');
    } catch (e) {
      developer.log(
        'Error clearing biometric data: $e',
        name: 'BiometricService',
      );
    }
  }

  /// Get user-friendly biometric type name
  String getBiometricTypeName(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (types.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (types.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (types.contains(BiometricType.strong) ||
        types.contains(BiometricType.weak)) {
      return 'Biometric';
    }
    return 'Biometric';
  }
}

/// Enum for biometric availability status
enum BiometricAvailability {
  available,
  notAvailable,
  notSupported,
  notEnrolled,
  error,
}

/// Result class for biometric operations
class BiometricResult {
  final bool success;
  final String message;

  BiometricResult._(this.success, this.message);

  factory BiometricResult.success(String message) =>
      BiometricResult._(true, message);
  factory BiometricResult.error(String message) =>
      BiometricResult._(false, message);
}

/// Result class for biometric authentication
class BiometricAuthResult {
  final bool success;
  final String? authToken;
  final String? errorMessage;

  BiometricAuthResult._(this.success, this.authToken, this.errorMessage);

  factory BiometricAuthResult.success(String authToken) =>
      BiometricAuthResult._(true, authToken, null);
  factory BiometricAuthResult.failed(String errorMessage) =>
      BiometricAuthResult._(false, null, errorMessage);
  factory BiometricAuthResult.notEnabled() => BiometricAuthResult._(
    false,
    null,
    'Biometric authentication is not enabled',
  );
}
