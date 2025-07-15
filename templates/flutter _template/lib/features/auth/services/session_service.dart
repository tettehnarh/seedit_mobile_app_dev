import 'dart:developer' as developer;
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';

/// Service for handling session management API calls
class SessionService {
  final ApiClient _apiClient = ApiClient();

  /// Get current session status and timeout information
  Future<Map<String, dynamic>> getSessionStatus() async {
    try {
      developer.log('Getting session status', name: 'SessionService');

      final response = await _apiClient.get('session/status/');

      developer.log(
        'Session status response: ${response.toString()}',
        name: 'SessionService',
      );

      return {'success': true, 'data': response};
    } on ApiException catch (e) {
      developer.log(
        'API error getting session status: ${e.message}',
        name: 'SessionService',
      );

      // Handle specific session errors
      if (e.statusCode == 401) {
        return {
          'success': false,
          'error': 'Session expired. Please sign in again.',
          'requires_login': true,
        };
      }

      return {'success': false, 'error': e.message};
    } catch (e) {
      developer.log('Error getting session status: $e', name: 'SessionService');
      return {'success': false, 'error': 'Failed to get session status'};
    }
  }

  /// Extend current session timeout
  Future<Map<String, dynamic>> extendSession({int? minutes}) async {
    try {
      developer.log('Extending session', name: 'SessionService');

      final requestData = <String, dynamic>{};
      if (minutes != null) {
        requestData['minutes'] = minutes;
      }

      final response = await _apiClient.post('session/extend/', requestData);

      developer.log(
        'Session extension response: ${response.toString()}',
        name: 'SessionService',
      );

      return {'success': true, 'data': response};
    } on ApiException catch (e) {
      developer.log(
        'API error extending session: ${e.message}',
        name: 'SessionService',
      );

      // Handle specific session errors
      if (e.statusCode == 401) {
        return {
          'success': false,
          'error': 'Session expired. Please sign in again.',
          'requires_login': true,
        };
      }

      return {'success': false, 'error': e.message};
    } catch (e) {
      developer.log('Error extending session: $e', name: 'SessionService');
      return {'success': false, 'error': 'Failed to extend session'};
    }
  }

  /// List all active sessions for the current user
  Future<Map<String, dynamic>> listUserSessions() async {
    try {
      developer.log('Listing user sessions', name: 'SessionService');

      final response = await _apiClient.get('session/list/');

      developer.log(
        'User sessions response: ${response.toString()}',
        name: 'SessionService',
      );

      return {'success': true, 'data': response};
    } on ApiException catch (e) {
      developer.log(
        'API error listing user sessions: ${e.message}',
        name: 'SessionService',
      );

      // Handle specific session errors
      if (e.statusCode == 401) {
        return {
          'success': false,
          'error': 'Session expired. Please sign in again.',
          'requires_login': true,
        };
      }

      return {'success': false, 'error': e.message};
    } catch (e) {
      developer.log('Error listing user sessions: $e', name: 'SessionService');
      return {'success': false, 'error': 'Failed to list user sessions'};
    }
  }

  /// Logout from a specific session or all sessions
  Future<Map<String, dynamic>> logoutSession({
    String? sessionId,
    bool logoutAll = false,
  }) async {
    try {
      developer.log('Logging out session', name: 'SessionService');

      final requestData = <String, dynamic>{};

      if (logoutAll) {
        requestData['logout_all'] = true;
      } else if (sessionId != null) {
        requestData['session_id'] = sessionId;
      } else {
        return {
          'success': false,
          'error': 'Either session_id or logout_all must be provided',
        };
      }

      final response = await _apiClient.post('session/logout/', requestData);

      developer.log(
        'Session logout response: ${response.toString()}',
        name: 'SessionService',
      );

      return {'success': true, 'data': response};
    } on ApiException catch (e) {
      developer.log(
        'API error logging out session: ${e.message}',
        name: 'SessionService',
      );

      // Handle specific session errors
      if (e.statusCode == 401) {
        return {
          'success': false,
          'error': 'Session expired. Please sign in again.',
          'requires_login': true,
        };
      }

      return {'success': false, 'error': e.message};
    } catch (e) {
      developer.log('Error logging out session: $e', name: 'SessionService');
      return {'success': false, 'error': 'Failed to logout session'};
    }
  }

  /// Get or update session settings
  Future<Map<String, dynamic>> getSessionSettings() async {
    try {
      developer.log('Getting session settings', name: 'SessionService');

      final response = await _apiClient.get('session/settings/');

      developer.log(
        'Session settings response: ${response.toString()}',
        name: 'SessionService',
      );

      return {'success': true, 'data': response};
    } on ApiException catch (e) {
      developer.log(
        'API error getting session settings: ${e.message}',
        name: 'SessionService',
      );

      return {'success': false, 'error': e.message};
    } catch (e) {
      developer.log(
        'Error getting session settings: $e',
        name: 'SessionService',
      );
      return {'success': false, 'error': 'Failed to get session settings'};
    }
  }

  /// Update session settings
  Future<Map<String, dynamic>> updateSessionSettings({
    int? sessionTimeoutMinutes,
    int? warningBeforeTimeoutMinutes,
    int? maxConcurrentSessions,
    bool? allowMultipleDevices,
    bool? requireReauthOnIpChange,
    bool? autoLogoutOnSuspiciousActivity,
    bool? notifyOnNewDeviceLogin,
    bool? notifyOnSessionTimeout,
  }) async {
    try {
      developer.log('Updating session settings', name: 'SessionService');

      final requestData = <String, dynamic>{};

      if (sessionTimeoutMinutes != null) {
        requestData['session_timeout_minutes'] = sessionTimeoutMinutes;
      }
      if (warningBeforeTimeoutMinutes != null) {
        requestData['warning_before_timeout_minutes'] =
            warningBeforeTimeoutMinutes;
      }
      if (maxConcurrentSessions != null) {
        requestData['max_concurrent_sessions'] = maxConcurrentSessions;
      }
      if (allowMultipleDevices != null) {
        requestData['allow_multiple_devices'] = allowMultipleDevices;
      }
      if (requireReauthOnIpChange != null) {
        requestData['require_reauth_on_ip_change'] = requireReauthOnIpChange;
      }
      if (autoLogoutOnSuspiciousActivity != null) {
        requestData['auto_logout_on_suspicious_activity'] =
            autoLogoutOnSuspiciousActivity;
      }
      if (notifyOnNewDeviceLogin != null) {
        requestData['notify_on_new_device_login'] = notifyOnNewDeviceLogin;
      }
      if (notifyOnSessionTimeout != null) {
        requestData['notify_on_session_timeout'] = notifyOnSessionTimeout;
      }

      final response = await _apiClient.putWithAuth(
        'session/settings/',
        requestData,
      );

      developer.log(
        'Session settings update response: ${response.toString()}',
        name: 'SessionService',
      );

      return {'success': true, 'data': response};
    } on ApiException catch (e) {
      developer.log(
        'API error updating session settings: ${e.message}',
        name: 'SessionService',
      );

      return {'success': false, 'error': e.message};
    } catch (e) {
      developer.log(
        'Error updating session settings: $e',
        name: 'SessionService',
      );
      return {'success': false, 'error': 'Failed to update session settings'};
    }
  }

  /// Create session with device information
  Future<Map<String, dynamic>> createSessionWithDeviceInfo({
    required String email,
    required String password,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      developer.log(
        'Creating session with device info',
        name: 'SessionService',
      );

      final requestData = <String, dynamic>{
        'email': email,
        'password': password,
      };

      if (deviceInfo != null) {
        requestData['device_info'] = deviceInfo;
      }

      final response = await _apiClient.post('auth/login/', requestData);

      developer.log(
        'Session creation response: ${response.toString()}',
        name: 'SessionService',
      );

      return {'success': true, 'data': response};
    } on ApiException catch (e) {
      developer.log(
        'API error creating session: ${e.message}',
        name: 'SessionService',
      );

      return {'success': false, 'error': e.message};
    } catch (e) {
      developer.log('Error creating session: $e', name: 'SessionService');
      return {'success': false, 'error': 'Failed to create session'};
    }
  }
}
