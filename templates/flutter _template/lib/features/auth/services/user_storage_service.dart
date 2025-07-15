import 'package:shared_preferences/shared_preferences.dart';

/// Service for storing and retrieving user information locally
class UserStorageService {
  static const String _lastUserEmailKey = 'last_user_email';
  static const String _lastUserIdKey = 'last_user_id';
  static const String _lastUserNameKey = 'last_user_name';

  /// Store the last logged-in user information
  static Future<void> storeLastUser({
    required String email,
    required String userId,
    String? name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUserEmailKey, email);
    await prefs.setString(_lastUserIdKey, userId);
    if (name != null) {
      await prefs.setString(_lastUserNameKey, name);
    }
  }

  /// Get the last logged-in user's email
  static Future<String?> getLastUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUserEmailKey);
  }

  /// Get the last logged-in user's ID
  static Future<String?> getLastUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUserIdKey);
  }

  /// Get the last logged-in user's name
  static Future<String?> getLastUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUserNameKey);
  }

  /// Check if there's a stored user
  static Future<bool> hasStoredUser() async {
    final email = await getLastUserEmail();
    return email != null && email.isNotEmpty;
  }

  /// Clear stored user information
  static Future<void> clearStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastUserEmailKey);
    await prefs.remove(_lastUserIdKey);
    await prefs.remove(_lastUserNameKey);
  }

  /// Get stored user information as a map
  static Future<Map<String, String?>> getStoredUserInfo() async {
    return {
      'email': await getLastUserEmail(),
      'userId': await getLastUserId(),
      'name': await getLastUserName(),
    };
  }
}
