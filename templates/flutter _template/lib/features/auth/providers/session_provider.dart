import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/session_service.dart';

/// State class for session management
class SessionState {
  final bool isActive;
  final bool isLoading;
  final DateTime? expiresAt;
  final int timeUntilExpirySeconds;
  final bool shouldWarnTimeout;
  final int warningThresholdMinutes;
  final int sessionTimeoutMinutes;
  final String? deviceName;
  final String? deviceType;
  final String? errorMessage;
  final String? successMessage;
  final List<UserSessionInfo> activeSessions;

  const SessionState({
    this.isActive = false,
    this.isLoading = false,
    this.expiresAt,
    this.timeUntilExpirySeconds = 0,
    this.shouldWarnTimeout = false,
    this.warningThresholdMinutes = 2,
    this.sessionTimeoutMinutes = 15,
    this.deviceName,
    this.deviceType,
    this.errorMessage,
    this.successMessage,
    this.activeSessions = const [],
  });

  SessionState copyWith({
    bool? isActive,
    bool? isLoading,
    DateTime? expiresAt,
    int? timeUntilExpirySeconds,
    bool? shouldWarnTimeout,
    int? warningThresholdMinutes,
    int? sessionTimeoutMinutes,
    String? deviceName,
    String? deviceType,
    String? errorMessage,
    String? successMessage,
    List<UserSessionInfo>? activeSessions,
  }) {
    return SessionState(
      isActive: isActive ?? this.isActive,
      isLoading: isLoading ?? this.isLoading,
      expiresAt: expiresAt ?? this.expiresAt,
      timeUntilExpirySeconds:
          timeUntilExpirySeconds ?? this.timeUntilExpirySeconds,
      shouldWarnTimeout: shouldWarnTimeout ?? this.shouldWarnTimeout,
      warningThresholdMinutes:
          warningThresholdMinutes ?? this.warningThresholdMinutes,
      sessionTimeoutMinutes:
          sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      errorMessage: errorMessage,
      successMessage: successMessage,
      activeSessions: activeSessions ?? this.activeSessions,
    );
  }

  /// Clear messages
  SessionState clearMessages() {
    return copyWith(errorMessage: null, successMessage: null);
  }

  @override
  String toString() {
    return 'SessionState(isActive: $isActive, isLoading: $isLoading, expiresAt: $expiresAt, timeUntilExpirySeconds: $timeUntilExpirySeconds, shouldWarnTimeout: $shouldWarnTimeout)';
  }
}

/// Session information for a user session
class UserSessionInfo {
  final String sessionId;
  final String deviceName;
  final String deviceType;
  final String sessionType;
  final String ipAddress;
  final String? location;
  final DateTime createdAt;
  final DateTime lastActivity;
  final DateTime expiresAt;
  final bool isCurrentSession;
  final int timeUntilExpirySeconds;

  const UserSessionInfo({
    required this.sessionId,
    required this.deviceName,
    required this.deviceType,
    required this.sessionType,
    required this.ipAddress,
    this.location,
    required this.createdAt,
    required this.lastActivity,
    required this.expiresAt,
    required this.isCurrentSession,
    required this.timeUntilExpirySeconds,
  });

  factory UserSessionInfo.fromJson(Map<String, dynamic> json) {
    return UserSessionInfo(
      sessionId: json['session_id'],
      deviceName: json['device_name'],
      deviceType: json['device_type'],
      sessionType: json['session_type'],
      ipAddress: json['ip_address'],
      location: json['location'],
      createdAt: DateTime.parse(json['created_at']),
      lastActivity: DateTime.parse(json['last_activity']),
      expiresAt: DateTime.parse(json['expires_at']),
      isCurrentSession: json['is_current_session'],
      timeUntilExpirySeconds: json['time_until_expiry_seconds'],
    );
  }
}

/// Notifier for managing session state
class SessionNotifier extends StateNotifier<SessionState> {
  final SessionService _sessionService;
  Timer? _statusCheckTimer;
  Timer? _timeoutWarningTimer;

  SessionNotifier(this._sessionService) : super(const SessionState()) {
    // Delay initialization to avoid provider modification during build
    Future(() {
      _startPeriodicStatusCheck();
    });
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    _timeoutWarningTimer?.cancel();
    super.dispose();
  }

  /// Start periodic session status checking
  void _startPeriodicStatusCheck() {
    _statusCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      checkSessionStatus();
    });
  }

  /// Check current session status
  Future<void> checkSessionStatus() async {
    try {
      developer.log('Checking session status', name: 'SessionNotifier');

      final result = await _sessionService.getSessionStatus();

      if (result['success'] == true) {
        final data = result['data'];
        final expiresAt = DateTime.parse(data['expires_at']);
        final timeUntilExpiry = data['time_until_expiry_seconds'];
        final shouldWarn = data['should_warn_timeout'];

        state = state.copyWith(
          isActive: true,
          expiresAt: expiresAt,
          timeUntilExpirySeconds: timeUntilExpiry,
          shouldWarnTimeout: shouldWarn,
          warningThresholdMinutes: data['warning_threshold_minutes'],
          sessionTimeoutMinutes: data['session_timeout_minutes'],
          deviceName: data['device_name'],
          deviceType: data['device_type'],
        );

        // Handle timeout warning
        if (shouldWarn && _timeoutWarningTimer == null) {
          _showTimeoutWarning();
        }

        developer.log(
          'Session status updated: ${timeUntilExpiry}s remaining',
          name: 'SessionNotifier',
        );
      } else {
        state = state.copyWith(
          isActive: false,
          errorMessage: result['error'] ?? 'Failed to get session status',
        );
      }
    } catch (e) {
      developer.log(
        'Error checking session status: $e',
        name: 'SessionNotifier',
      );
      state = state.copyWith(errorMessage: 'Failed to check session status');
    }
  }

  /// Extend current session
  Future<bool> extendSession({int? minutes}) async {
    try {
      developer.log('Extending session', name: 'SessionNotifier');
      state = state.copyWith(isLoading: true);

      final result = await _sessionService.extendSession(minutes: minutes);

      if (result['success'] == true) {
        final data = result['data'];
        final newExpiry = DateTime.parse(data['new_expiry']);
        final timeUntilExpiry = data['time_until_expiry_seconds'];

        state = state.copyWith(
          isLoading: false,
          expiresAt: newExpiry,
          timeUntilExpirySeconds: timeUntilExpiry,
          shouldWarnTimeout: false,
          successMessage: 'Session extended successfully',
        );

        // Cancel timeout warning
        _timeoutWarningTimer?.cancel();
        _timeoutWarningTimer = null;

        developer.log('Session extended successfully', name: 'SessionNotifier');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['error'] ?? 'Failed to extend session',
        );
        return false;
      }
    } catch (e) {
      developer.log('Error extending session: $e', name: 'SessionNotifier');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to extend session',
      );
      return false;
    }
  }

  /// Get list of active sessions
  Future<void> loadActiveSessions() async {
    try {
      developer.log('Loading active sessions', name: 'SessionNotifier');
      state = state.copyWith(isLoading: true);

      final result = await _sessionService.listUserSessions();

      if (result['success'] == true) {
        final data = result['data'];
        final sessions = (data['sessions'] as List)
            .map((session) => UserSessionInfo.fromJson(session))
            .toList();

        state = state.copyWith(isLoading: false, activeSessions: sessions);

        developer.log(
          'Loaded ${sessions.length} active sessions',
          name: 'SessionNotifier',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['error'] ?? 'Failed to load sessions',
        );
      }
    } catch (e) {
      developer.log(
        'Error loading active sessions: $e',
        name: 'SessionNotifier',
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load active sessions',
      );
    }
  }

  /// Logout from a specific session
  Future<bool> logoutSession(String sessionId) async {
    try {
      developer.log('Logging out session: $sessionId', name: 'SessionNotifier');

      final result = await _sessionService.logoutSession(sessionId: sessionId);

      if (result['success'] == true) {
        // Reload active sessions
        await loadActiveSessions();

        state = state.copyWith(
          successMessage: 'Session logged out successfully',
        );

        return true;
      } else {
        state = state.copyWith(
          errorMessage: result['error'] ?? 'Failed to logout session',
        );
        return false;
      }
    } catch (e) {
      developer.log('Error logging out session: $e', name: 'SessionNotifier');
      state = state.copyWith(errorMessage: 'Failed to logout session');
      return false;
    }
  }

  /// Logout from all other sessions
  Future<bool> logoutAllOtherSessions() async {
    try {
      developer.log('Logging out all other sessions', name: 'SessionNotifier');

      final result = await _sessionService.logoutSession(logoutAll: true);

      if (result['success'] == true) {
        // Reload active sessions
        await loadActiveSessions();

        state = state.copyWith(
          successMessage: 'Logged out from all other sessions',
        );

        return true;
      } else {
        state = state.copyWith(
          errorMessage: result['error'] ?? 'Failed to logout other sessions',
        );
        return false;
      }
    } catch (e) {
      developer.log(
        'Error logging out other sessions: $e',
        name: 'SessionNotifier',
      );
      state = state.copyWith(errorMessage: 'Failed to logout other sessions');
      return false;
    }
  }

  /// Show timeout warning
  void _showTimeoutWarning() {
    _timeoutWarningTimer = Timer(
      Duration(seconds: state.timeUntilExpirySeconds),
      () {
        // Session has expired
        state = state.copyWith(
          isActive: false,
          errorMessage: 'Your session has expired. Please sign in again.',
        );
      },
    );
  }

  /// Clear messages
  void clearMessages() {
    state = state.clearMessages();
  }

  /// Reset session state (for logout)
  void resetSession() {
    _statusCheckTimer?.cancel();
    _timeoutWarningTimer?.cancel();
    state = const SessionState();
  }
}

/// Provider for session service
final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService();
});

/// Provider for session state management
final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((
  ref,
) {
  final sessionService = ref.read(sessionServiceProvider);
  return SessionNotifier(sessionService);
});
