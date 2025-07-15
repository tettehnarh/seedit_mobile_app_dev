import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricTypeKey = 'biometric_type';

  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.isDeviceSupported();
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      return isAvailable && canCheckBiometrics;
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  // Check if biometric is enabled for the app
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      debugPrint('Error checking biometric enabled status: $e');
      return false;
    }
  }

  // Enable biometric authentication
  Future<bool> enableBiometric() async {
    try {
      // First check if biometric is available
      if (!await isBiometricAvailable()) {
        throw Exception('Biometric authentication is not available on this device');
      }

      // Authenticate to enable biometric
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Enable biometric authentication for SeedIt',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_biometricEnabledKey, true);
        
        // Store the biometric type
        final availableBiometrics = await getAvailableBiometrics();
        if (availableBiometrics.isNotEmpty) {
          await prefs.setString(_biometricTypeKey, availableBiometrics.first.name);
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error enabling biometric: $e');
      throw Exception('Failed to enable biometric authentication');
    }
  }

  // Disable biometric authentication
  Future<void> disableBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, false);
      await prefs.remove(_biometricTypeKey);
    } catch (e) {
      debugPrint('Error disabling biometric: $e');
      throw Exception('Failed to disable biometric authentication');
    }
  }

  // Authenticate with biometric
  Future<bool> authenticateWithBiometric({
    String? reason,
    bool fallbackToCredentials = true,
  }) async {
    try {
      if (!await isBiometricEnabled()) {
        throw Exception('Biometric authentication is not enabled');
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason ?? 'Authenticate to access SeedIt',
        options: AuthenticationOptions(
          biometricOnly: !fallbackToCredentials,
          stickyAuth: true,
        ),
      );

      return didAuthenticate;
    } catch (e) {
      debugPrint('Error authenticating with biometric: $e');
      rethrow;
    }
  }

  // Get biometric type display name
  Future<String> getBiometricTypeDisplayName() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      
      if (availableBiometrics.isEmpty) {
        return 'Biometric';
      }

      // Prioritize Face ID over Touch ID
      if (availableBiometrics.contains(BiometricType.face)) {
        return 'Face ID';
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return 'Touch ID';
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        return 'Iris';
      } else if (availableBiometrics.contains(BiometricType.strong)) {
        return 'Biometric';
      } else if (availableBiometrics.contains(BiometricType.weak)) {
        return 'Screen Lock';
      }

      return 'Biometric';
    } catch (e) {
      debugPrint('Error getting biometric type display name: $e');
      return 'Biometric';
    }
  }

  // Get biometric icon
  Future<String> getBiometricIcon() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      
      if (availableBiometrics.isEmpty) {
        return 'fingerprint';
      }

      if (availableBiometrics.contains(BiometricType.face)) {
        return 'face';
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return 'fingerprint';
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        return 'visibility';
      }

      return 'fingerprint';
    } catch (e) {
      debugPrint('Error getting biometric icon: $e');
      return 'fingerprint';
    }
  }

  // Check if specific biometric type is available
  Future<bool> isBiometricTypeAvailable(BiometricType type) async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.contains(type);
    } catch (e) {
      debugPrint('Error checking biometric type availability: $e');
      return false;
    }
  }

  // Get biometric capabilities
  Future<BiometricCapabilities> getBiometricCapabilities() async {
    try {
      final isAvailable = await isBiometricAvailable();
      final availableBiometrics = await getAvailableBiometrics();
      final isEnabled = await isBiometricEnabled();
      final displayName = await getBiometricTypeDisplayName();
      final icon = await getBiometricIcon();

      return BiometricCapabilities(
        isAvailable: isAvailable,
        isEnabled: isEnabled,
        availableBiometrics: availableBiometrics,
        displayName: displayName,
        icon: icon,
        hasFaceId: availableBiometrics.contains(BiometricType.face),
        hasTouchId: availableBiometrics.contains(BiometricType.fingerprint),
        hasIris: availableBiometrics.contains(BiometricType.iris),
      );
    } catch (e) {
      debugPrint('Error getting biometric capabilities: $e');
      return BiometricCapabilities(
        isAvailable: false,
        isEnabled: false,
        availableBiometrics: [],
        displayName: 'Biometric',
        icon: 'fingerprint',
        hasFaceId: false,
        hasTouchId: false,
        hasIris: false,
      );
    }
  }

  // Stop authentication (cancel ongoing authentication)
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      debugPrint('Error stopping authentication: $e');
    }
  }
}

class BiometricCapabilities {
  final bool isAvailable;
  final bool isEnabled;
  final List<BiometricType> availableBiometrics;
  final String displayName;
  final String icon;
  final bool hasFaceId;
  final bool hasTouchId;
  final bool hasIris;

  BiometricCapabilities({
    required this.isAvailable,
    required this.isEnabled,
    required this.availableBiometrics,
    required this.displayName,
    required this.icon,
    required this.hasFaceId,
    required this.hasTouchId,
    required this.hasIris,
  });

  bool get hasAnyBiometric => availableBiometrics.isNotEmpty;
  
  bool get hasStrongBiometric => 
      hasFaceId || hasTouchId || hasIris || 
      availableBiometrics.contains(BiometricType.strong);

  String get primaryBiometricType {
    if (hasFaceId) return 'Face ID';
    if (hasTouchId) return 'Touch ID';
    if (hasIris) return 'Iris';
    return 'Biometric';
  }
}

enum BiometricAuthResult {
  success,
  failed,
  cancelled,
  notAvailable,
  notEnabled,
  error,
}

class BiometricAuthException implements Exception {
  final String message;
  final BiometricAuthResult result;

  BiometricAuthException(this.message, this.result);

  @override
  String toString() => 'BiometricAuthException: $message';
}
