import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;

/// Utility class for handling secure storage (for sensitive data like tokens, PINs)
class SecureStorageUtils {
  // Create storage instance with options
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys for storing sensitive data
  static const String _pinHashKey = 'pin_hash';
  static const String _biometricTokenKey = 'biometric_token';
  static const String _encryptionKeyKey = 'encryption_key';
  static const String _accessTokenKey = 'secure_access_token';
  static const String _refreshTokenKey = 'secure_refresh_token';

  /// Store PIN hash securely
  static Future<void> setPinHash(String pinHash) async {
    try {
      await _storage.write(key: _pinHashKey, value: pinHash);
      developer.log('PIN hash stored securely');
    } catch (e) {
      developer.log('Error storing PIN hash: $e', error: e);
      rethrow;
    }
  }

  /// Get PIN hash
  static Future<String?> getPinHash() async {
    try {
      return await _storage.read(key: _pinHashKey);
    } catch (e) {
      developer.log('Error reading PIN hash: $e', error: e);
      return null;
    }
  }

  /// Store biometric token
  static Future<void> setBiometricToken(String token) async {
    try {
      await _storage.write(key: _biometricTokenKey, value: token);
      developer.log('Biometric token stored securely');
    } catch (e) {
      developer.log('Error storing biometric token: $e', error: e);
      rethrow;
    }
  }

  /// Get biometric token
  static Future<String?> getBiometricToken() async {
    try {
      return await _storage.read(key: _biometricTokenKey);
    } catch (e) {
      developer.log('Error reading biometric token: $e', error: e);
      return null;
    }
  }

  /// Store encryption key
  static Future<void> setEncryptionKey(String key) async {
    try {
      await _storage.write(key: _encryptionKeyKey, value: key);
      developer.log('Encryption key stored securely');
    } catch (e) {
      developer.log('Error storing encryption key: $e', error: e);
      rethrow;
    }
  }

  /// Get encryption key
  static Future<String?> getEncryptionKey() async {
    try {
      return await _storage.read(key: _encryptionKeyKey);
    } catch (e) {
      developer.log('Error reading encryption key: $e', error: e);
      return null;
    }
  }

  /// Store access token securely (alternative to shared preferences)
  static Future<void> setAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
      developer.log('Access token stored securely');
    } catch (e) {
      developer.log('Error storing access token: $e', error: e);
      rethrow;
    }
  }

  /// Get access token
  static Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      developer.log('Error reading access token: $e', error: e);
      return null;
    }
  }

  /// Store refresh token securely
  static Future<void> setRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
      developer.log('Refresh token stored securely');
    } catch (e) {
      developer.log('Error storing refresh token: $e', error: e);
      rethrow;
    }
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      developer.log('Error reading refresh token: $e', error: e);
      return null;
    }
  }

  /// Store generic secure value
  static Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      developer.log('Secure value stored for key: $key');
    } catch (e) {
      developer.log('Error storing secure value for key $key: $e', error: e);
      rethrow;
    }
  }

  /// Read generic secure value
  static Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      developer.log('Error reading secure value for key $key: $e', error: e);
      return null;
    }
  }

  /// Delete specific key
  static Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      developer.log('Secure value deleted for key: $key');
    } catch (e) {
      developer.log('Error deleting secure value for key $key: $e', error: e);
      rethrow;
    }
  }

  /// Delete all secure storage data
  static Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      developer.log('All secure storage data deleted');
    } catch (e) {
      developer.log('Error deleting all secure storage data: $e', error: e);
      rethrow;
    }
  }

  /// Check if key exists
  static Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      developer.log('Error checking if key exists: $e', error: e);
      return false;
    }
  }

  /// Get all keys
  static Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      developer.log('Error reading all secure storage data: $e', error: e);
      return {};
    }
  }

  /// Clear authentication related secure data
  static Future<void> clearAuthData() async {
    try {
      await delete(_accessTokenKey);
      await delete(_refreshTokenKey);
      await delete(_biometricTokenKey);
      developer.log('Authentication secure data cleared');
    } catch (e) {
      developer.log('Error clearing authentication secure data: $e', error: e);
      rethrow;
    }
  }

  /// Clear PIN related secure data
  static Future<void> clearPinData() async {
    try {
      await delete(_pinHashKey);
      developer.log('PIN secure data cleared');
    } catch (e) {
      developer.log('Error clearing PIN secure data: $e', error: e);
      rethrow;
    }
  }

  /// Complete secure session cleanup - clears all user-related secure data
  static Future<void> clearCompleteSession() async {
    try {
      developer.log('Starting complete secure session cleanup...');

      // Get all keys first to identify user-related data
      final allData = await readAll();
      final userRelatedKeys = allData.keys
          .where(
            (key) =>
                key.startsWith('user_') ||
                key.startsWith('session_') ||
                key.startsWith('auth_') ||
                key.contains('token') ||
                key.contains('credential') ||
                key.contains('password') ||
                key.contains('pin') ||
                key.contains('biometric') ||
                key.contains('secure_'),
          )
          .toList();

      // Clear all user-related secure data
      await Future.wait([
        clearAuthData(),
        clearPinData(),
        delete(_encryptionKeyKey),
        // Clear any additional user-related keys
        ...userRelatedKeys.map((key) => delete(key)),
      ]);

      developer.log(
        'Complete secure session cleanup finished - ${userRelatedKeys.length} keys cleared',
      );
    } catch (e) {
      developer.log(
        'Error during complete secure session cleanup: $e',
        error: e,
      );
      // If individual cleanup fails, try nuclear option
      try {
        await deleteAll();
        developer.log('Fallback: All secure storage cleared');
      } catch (fallbackError) {
        developer.log(
          'Error in fallback secure storage cleanup: $fallbackError',
          error: fallbackError,
        );
      }
    }
  }

  /// Pre-login secure cleanup - ensures clean secure state before new user login
  static Future<void> preLoginCleanup() async {
    try {
      developer.log('Starting pre-login secure cleanup...');

      // Perform complete secure session cleanup
      await clearCompleteSession();

      // Additional cleanup for login preparation
      await Future.wait([
        delete('login_credentials'),
        delete('remember_password'),
        delete('auto_login_token'),
        delete('temp_session'),
        delete('verification_code'),
      ]);

      developer.log('Pre-login secure cleanup completed');
    } catch (e) {
      developer.log('Error during pre-login secure cleanup: $e', error: e);
    }
  }
}
