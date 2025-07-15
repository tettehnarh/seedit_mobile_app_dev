import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:developer' as developer;

/// Utility class for handling shared preferences storage
class StorageUtils {
  // Keys for storing data
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _kycStatusKey = 'kyc_status';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  /// Get SharedPreferences instance
  static Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  /// Store access token
  static Future<void> setAccessToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_accessTokenKey, token);
    developer.log('Access token stored');
  }

  /// Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await _prefs;
    final token = prefs.getString(_accessTokenKey);
    developer.log(
      '🔑 [AUTH_DEBUG] Retrieved access token: ${token != null ? "Token exists (${token.length} chars)" : "No token found"}',
    );
    return token;
  }

  /// Store refresh token
  static Future<void> setRefreshToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_refreshTokenKey, token);
    developer.log('Refresh token stored');
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await _prefs;
    return prefs.getString(_refreshTokenKey);
  }

  /// Store user ID
  static Future<void> setUserId(String userId) async {
    final prefs = await _prefs;
    await prefs.setString(_userIdKey, userId);
    developer.log('User ID stored: $userId');
  }

  /// Get user ID
  static Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(_userIdKey);
  }

  /// Store user email
  static Future<void> setUserEmail(String email) async {
    final prefs = await _prefs;
    await prefs.setString(_userEmailKey, email);
    developer.log('User email stored: $email');
  }

  /// Get user email
  static Future<String?> getUserEmail() async {
    final prefs = await _prefs;
    return prefs.getString(_userEmailKey);
  }

  /// Store user name
  static Future<void> setUserName(String name) async {
    final prefs = await _prefs;
    await prefs.setString(_userNameKey, name);
    developer.log('User name stored: $name');
  }

  /// Get user name
  static Future<String?> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString(_userNameKey);
  }

  /// Store user phone
  static Future<void> setUserPhone(String phone) async {
    final prefs = await _prefs;
    await prefs.setString(_userPhoneKey, phone);
    developer.log('User phone stored: $phone');
  }

  /// Get user phone
  static Future<String?> getUserPhone() async {
    final prefs = await _prefs;
    return prefs.getString(_userPhoneKey);
  }

  /// Save user name (alias for setUserName)
  static Future<void> saveUserName(String name) async {
    await setUserName(name);
  }

  /// Save user email (alias for setUserEmail)
  static Future<void> saveUserEmail(String email) async {
    await setUserEmail(email);
  }

  /// Save user phone (alias for setUserPhone)
  static Future<void> saveUserPhone(String phone) async {
    await setUserPhone(phone);
  }

  /// Set login status
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await _prefs;
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
    developer.log('Login status set: $isLoggedIn');
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Store KYC status
  static Future<void> setKycStatus(String status) async {
    final prefs = await _prefs;
    await prefs.setString(_kycStatusKey, status);
    developer.log('KYC status stored: $status');
  }

  /// Get KYC status
  static Future<String?> getKycStatus() async {
    final prefs = await _prefs;
    return prefs.getString(_kycStatusKey);
  }

  /// Set onboarding completed status
  static Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await _prefs;
    await prefs.setBool(_onboardingCompletedKey, completed);
    developer.log('Onboarding completed status set: $completed');
  }

  /// Check if onboarding is completed
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await _prefs;
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Set biometric authentication enabled status
  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_biometricEnabledKey, enabled);
    developer.log('Biometric enabled status set: $enabled');
  }

  /// Check if biometric authentication is enabled
  static Future<bool> isBiometricEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Set notifications enabled status
  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_notificationsEnabledKey, enabled);
    developer.log('Notifications enabled status set: $enabled');
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_notificationsEnabledKey) ?? true; // Default to true
  }

  /// Clear all stored data
  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
    developer.log('All stored data cleared');
  }

  /// Clear authentication data only
  static Future<void> clearAuthData() async {
    try {
      final prefs = await _prefs;
      await Future.wait([
        prefs.remove(_accessTokenKey),
        prefs.remove(_refreshTokenKey),
        prefs.remove(_userIdKey),
        prefs.remove(_userEmailKey),
        prefs.remove(_isLoggedInKey),
        prefs.remove(_kycStatusKey),
        // Clear additional auth-related data
        remove('login_timestamp'),
        remove('last_login_email'),
        remove('session_id'),
        remove('auth_expiry'),
      ]);
      developer.log('Authentication data cleared');
    } catch (e) {
      developer.log('Error clearing auth data: $e', error: e);
    }
  }

  /// Clear all user profile data
  static Future<void> clearUserData() async {
    try {
      await Future.wait([
        remove('user_name'),
        remove('user_id'),
        remove('user_phone'),
        remove('user_email'),
        remove('email_verified'),
        remove('profile_picture'),
        remove('user_preferences'),
        remove('user_settings'),
        remove('display_name'),
        remove('first_name'),
        remove('last_name'),
      ]);
      developer.log('User profile data cleared');
    } catch (e) {
      developer.log('Error clearing user data: $e', error: e);
    }
  }

  /// Clear all investment-related data
  static Future<void> clearInvestmentData() async {
    try {
      await Future.wait([
        remove('portfolio_cache'),
        remove('available_funds_cache'),
        remove('transaction_history_cache'),
        remove('investment_performance_cache'),
        remove('last_portfolio_update'),
        remove('cached_investments'),
        remove('portfolio_summary'),
        remove('fund_details_cache'),
        remove('investment_goals'),
        remove('watchlist'),
      ]);
      developer.log('Investment data cleared');
    } catch (e) {
      developer.log('Error clearing investment data: $e', error: e);
    }
  }

  /// Clear all KYC-related data
  static Future<void> clearKycData() async {
    try {
      await Future.wait([
        remove('kyc_status'),
        remove('kyc_application_data'),
        remove('kyc_documents'),
        remove('kyc_last_update'),
        remove('kyc_submission_date'),
        remove('kyc_personal_info'),
        remove('kyc_next_of_kin'),
        remove('kyc_professional_info'),
        remove('kyc_id_info'),
        remove('kyc_verification_status'),
      ]);
      developer.log('KYC data cleared');
    } catch (e) {
      developer.log('Error clearing KYC data: $e', error: e);
    }
  }

  /// Store generic string value
  static Future<void> setString(String key, String value) async {
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }

  /// Get generic string value
  static Future<String?> getString(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  /// Store generic boolean value
  static Future<void> setBool(String key, bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(key, value);
  }

  /// Get generic boolean value
  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final prefs = await _prefs;
    return prefs.getBool(key) ?? defaultValue;
  }

  /// Store generic integer value
  static Future<void> setInt(String key, int value) async {
    final prefs = await _prefs;
    await prefs.setInt(key, value);
  }

  /// Get generic integer value
  static Future<int> getInt(String key, {int defaultValue = 0}) async {
    final prefs = await _prefs;
    return prefs.getInt(key) ?? defaultValue;
  }

  /// Store generic double value
  static Future<void> setDouble(String key, double value) async {
    final prefs = await _prefs;
    await prefs.setDouble(key, value);
  }

  /// Get generic double value
  static Future<double> getDouble(
    String key, {
    double defaultValue = 0.0,
  }) async {
    final prefs = await _prefs;
    return prefs.getDouble(key) ?? defaultValue;
  }

  /// Remove specific key
  static Future<void> remove(String key) async {
    final prefs = await _prefs;
    await prefs.remove(key);
  }

  /// Check if key exists
  static Future<bool> containsKey(String key) async {
    final prefs = await _prefs;
    return prefs.containsKey(key);
  }

  /// Complete session cleanup - clears all user-related data
  static Future<void> clearCompleteSession() async {
    try {
      developer.log('Starting complete session cleanup...');

      // Clear all specific data categories
      await Future.wait([
        clearAuthData(),
        clearUserData(),
        clearInvestmentData(),
        clearKycData(),
      ]);

      // Clear any remaining cached data with common prefixes
      final prefs = await _prefs;
      final keys = prefs.getKeys().toList();
      final userDataKeys = keys
          .where(
            (key) =>
                key.startsWith('user_') ||
                key.startsWith('portfolio_') ||
                key.startsWith('investment_') ||
                key.startsWith('kyc_') ||
                key.startsWith('cache_') ||
                key.startsWith('temp_') ||
                key.contains('_cache') ||
                key.contains('_temp') ||
                key.endsWith('_data'),
          )
          .toList();

      for (final key in userDataKeys) {
        await prefs.remove(key);
      }

      developer.log(
        'Complete session cleanup finished - ${userDataKeys.length} additional keys cleared',
      );
    } catch (e) {
      developer.log('Error during complete session cleanup: $e', error: e);
    }
  }

  /// Pre-login cleanup - ensures clean state before new user login
  static Future<void> preLoginCleanup() async {
    try {
      developer.log('Starting pre-login cleanup...');

      // Perform complete session cleanup
      await clearCompleteSession();

      // Additional cleanup for login preparation
      await Future.wait([
        remove('login_attempt_count'),
        remove('last_failed_login'),
        remove('password_reset_token'),
        remove('remember_me'),
        remove('auto_login'),
      ]);

      developer.log('Pre-login cleanup completed');
    } catch (e) {
      developer.log('Error during pre-login cleanup: $e', error: e);
    }
  }

  /// JSON Helper Methods for Caching

  /// Convert Map to JSON string
  static String toJson(Map<String, dynamic> data) {
    try {
      return json.encode(data);
    } catch (e) {
      developer.log('Error encoding JSON: $e');
      return '{}';
    }
  }

  /// Parse JSON string to Map
  static Map<String, dynamic> parseJson(String jsonString) {
    try {
      final decoded = json.decode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        developer.log('JSON is not a Map<String, dynamic>: $decoded');
        return {};
      }
    } catch (e) {
      developer.log('Error parsing JSON: $e');
      return {};
    }
  }

  /// Store JSON object
  static Future<void> setJson(String key, Map<String, dynamic> data) async {
    try {
      final jsonString = toJson(data);
      await setString(key, jsonString);
    } catch (e) {
      developer.log('Error storing JSON for key $key: $e');
    }
  }

  /// Get JSON object
  static Future<Map<String, dynamic>?> getJson(String key) async {
    try {
      final jsonString = await getString(key);
      if (jsonString != null) {
        return parseJson(jsonString);
      }
      return null;
    } catch (e) {
      developer.log('Error retrieving JSON for key $key: $e');
      return null;
    }
  }
}
