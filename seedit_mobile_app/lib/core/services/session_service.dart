import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _lastActivityKey = 'last_activity';
  static const String _sessionTimeoutKey = 'session_timeout';
  static const String _autoLockEnabledKey = 'auto_lock_enabled';
  static const String _lockOnBackgroundKey = 'lock_on_background';
  static const String _sessionIdKey = 'session_id';
  
  // Default session timeout in minutes
  static const int _defaultSessionTimeout = 15;
  
  Timer? _sessionTimer;
  Timer? _warningTimer;
  final StreamController<SessionEvent> _sessionEventController = StreamController<SessionEvent>.broadcast();
  
  bool _isSessionActive = false;
  DateTime? _lastActivity;
  
  // Stream for session events
  Stream<SessionEvent> get sessionEvents => _sessionEventController.stream;
  
  // Check if session is active
  bool get isSessionActive => _isSessionActive;
  
  // Get last activity time
  DateTime? get lastActivity => _lastActivity;

  // Initialize session service
  Future<void> initialize() async {
    try {
      await _loadSessionSettings();
      await _checkExistingSession();
    } catch (e) {
      debugPrint('Error initializing session service: $e');
    }
  }

  // Start a new session
  Future<void> startSession() async {
    try {
      _isSessionActive = true;
      _lastActivity = DateTime.now();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastActivityKey, _lastActivity!.millisecondsSinceEpoch);
      await prefs.setString(_sessionIdKey, _generateSessionId());
      
      _startSessionTimer();
      _sessionEventController.add(SessionEvent.sessionStarted);
      
      debugPrint('Session started');
    } catch (e) {
      debugPrint('Error starting session: $e');
    }
  }

  // End current session
  Future<void> endSession() async {
    try {
      _isSessionActive = false;
      _lastActivity = null;
      
      _sessionTimer?.cancel();
      _warningTimer?.cancel();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastActivityKey);
      await prefs.remove(_sessionIdKey);
      
      _sessionEventController.add(SessionEvent.sessionEnded);
      
      debugPrint('Session ended');
    } catch (e) {
      debugPrint('Error ending session: $e');
    }
  }

  // Update activity timestamp
  Future<void> updateActivity() async {
    if (!_isSessionActive) return;
    
    try {
      _lastActivity = DateTime.now();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastActivityKey, _lastActivity!.millisecondsSinceEpoch);
      
      // Reset session timer
      _startSessionTimer();
      
      debugPrint('Activity updated');
    } catch (e) {
      debugPrint('Error updating activity: $e');
    }
  }

  // Check if session has expired
  Future<bool> isSessionExpired() async {
    try {
      if (!_isSessionActive || _lastActivity == null) {
        return true;
      }
      
      final sessionTimeout = await getSessionTimeout();
      final now = DateTime.now();
      final timeSinceLastActivity = now.difference(_lastActivity!);
      
      return timeSinceLastActivity.inMinutes >= sessionTimeout;
    } catch (e) {
      debugPrint('Error checking session expiry: $e');
      return true;
    }
  }

  // Get session timeout in minutes
  Future<int> getSessionTimeout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_sessionTimeoutKey) ?? _defaultSessionTimeout;
    } catch (e) {
      debugPrint('Error getting session timeout: $e');
      return _defaultSessionTimeout;
    }
  }

  // Set session timeout in minutes
  Future<void> setSessionTimeout(int minutes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_sessionTimeoutKey, minutes);
      
      // Restart timer with new timeout
      if (_isSessionActive) {
        _startSessionTimer();
      }
      
      debugPrint('Session timeout set to $minutes minutes');
    } catch (e) {
      debugPrint('Error setting session timeout: $e');
    }
  }

  // Check if auto-lock is enabled
  Future<bool> isAutoLockEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_autoLockEnabledKey) ?? true;
    } catch (e) {
      debugPrint('Error checking auto-lock status: $e');
      return true;
    }
  }

  // Enable/disable auto-lock
  Future<void> setAutoLockEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoLockEnabledKey, enabled);
      
      if (enabled && _isSessionActive) {
        _startSessionTimer();
      } else {
        _sessionTimer?.cancel();
        _warningTimer?.cancel();
      }
      
      debugPrint('Auto-lock ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('Error setting auto-lock: $e');
    }
  }

  // Check if lock on background is enabled
  Future<bool> isLockOnBackgroundEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_lockOnBackgroundKey) ?? false;
    } catch (e) {
      debugPrint('Error checking lock on background status: $e');
      return false;
    }
  }

  // Enable/disable lock on background
  Future<void> setLockOnBackgroundEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_lockOnBackgroundKey, enabled);
      
      debugPrint('Lock on background ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('Error setting lock on background: $e');
    }
  }

  // Handle app going to background
  Future<void> onAppBackground() async {
    try {
      final lockOnBackground = await isLockOnBackgroundEnabled();
      if (lockOnBackground && _isSessionActive) {
        await endSession();
        _sessionEventController.add(SessionEvent.sessionLocked);
      }
    } catch (e) {
      debugPrint('Error handling app background: $e');
    }
  }

  // Handle app coming to foreground
  Future<void> onAppForeground() async {
    try {
      if (await isSessionExpired()) {
        await endSession();
        _sessionEventController.add(SessionEvent.sessionExpired);
      }
    } catch (e) {
      debugPrint('Error handling app foreground: $e');
    }
  }

  // Get remaining session time in minutes
  Future<int> getRemainingSessionTime() async {
    try {
      if (!_isSessionActive || _lastActivity == null) {
        return 0;
      }
      
      final sessionTimeout = await getSessionTimeout();
      final now = DateTime.now();
      final timeSinceLastActivity = now.difference(_lastActivity!);
      final remainingTime = sessionTimeout - timeSinceLastActivity.inMinutes;
      
      return remainingTime > 0 ? remainingTime : 0;
    } catch (e) {
      debugPrint('Error getting remaining session time: $e');
      return 0;
    }
  }

  // Get session info
  Future<SessionInfo> getSessionInfo() async {
    try {
      final isActive = _isSessionActive;
      final lastActivity = _lastActivity;
      final timeout = await getSessionTimeout();
      final autoLockEnabled = await isAutoLockEnabled();
      final lockOnBackground = await isLockOnBackgroundEnabled();
      final remainingTime = await getRemainingSessionTime();
      final isExpired = await isSessionExpired();
      
      return SessionInfo(
        isActive: isActive,
        lastActivity: lastActivity,
        timeoutMinutes: timeout,
        autoLockEnabled: autoLockEnabled,
        lockOnBackgroundEnabled: lockOnBackground,
        remainingTimeMinutes: remainingTime,
        isExpired: isExpired,
      );
    } catch (e) {
      debugPrint('Error getting session info: $e');
      return SessionInfo(
        isActive: false,
        lastActivity: null,
        timeoutMinutes: _defaultSessionTimeout,
        autoLockEnabled: true,
        lockOnBackgroundEnabled: false,
        remainingTimeMinutes: 0,
        isExpired: true,
      );
    }
  }

  // Private methods
  Future<void> _loadSessionSettings() async {
    // Settings are loaded on-demand, no need to preload
  }

  Future<void> _checkExistingSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActivityTimestamp = prefs.getInt(_lastActivityKey);
      
      if (lastActivityTimestamp != null) {
        _lastActivity = DateTime.fromMillisecondsSinceEpoch(lastActivityTimestamp);
        
        if (!await isSessionExpired()) {
          _isSessionActive = true;
          _startSessionTimer();
          _sessionEventController.add(SessionEvent.sessionRestored);
        } else {
          await endSession();
          _sessionEventController.add(SessionEvent.sessionExpired);
        }
      }
    } catch (e) {
      debugPrint('Error checking existing session: $e');
    }
  }

  void _startSessionTimer() async {
    _sessionTimer?.cancel();
    _warningTimer?.cancel();
    
    final autoLockEnabled = await isAutoLockEnabled();
    if (!autoLockEnabled) return;
    
    final sessionTimeout = await getSessionTimeout();
    final warningTime = sessionTimeout - 2; // Show warning 2 minutes before timeout
    
    // Set warning timer
    if (warningTime > 0) {
      _warningTimer = Timer(Duration(minutes: warningTime), () {
        _sessionEventController.add(SessionEvent.sessionWarning);
      });
    }
    
    // Set session timeout timer
    _sessionTimer = Timer(Duration(minutes: sessionTimeout), () async {
      await endSession();
      _sessionEventController.add(SessionEvent.sessionExpired);
    });
  }

  String _generateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Dispose resources
  void dispose() {
    _sessionTimer?.cancel();
    _warningTimer?.cancel();
    _sessionEventController.close();
  }
}

class SessionInfo {
  final bool isActive;
  final DateTime? lastActivity;
  final int timeoutMinutes;
  final bool autoLockEnabled;
  final bool lockOnBackgroundEnabled;
  final int remainingTimeMinutes;
  final bool isExpired;

  SessionInfo({
    required this.isActive,
    required this.lastActivity,
    required this.timeoutMinutes,
    required this.autoLockEnabled,
    required this.lockOnBackgroundEnabled,
    required this.remainingTimeMinutes,
    required this.isExpired,
  });

  String get statusText {
    if (!isActive) return 'Inactive';
    if (isExpired) return 'Expired';
    if (remainingTimeMinutes <= 2) return 'Expiring Soon';
    return 'Active';
  }

  String get remainingTimeText {
    if (remainingTimeMinutes <= 0) return 'Expired';
    if (remainingTimeMinutes == 1) return '1 minute remaining';
    return '$remainingTimeMinutes minutes remaining';
  }
}

enum SessionEvent {
  sessionStarted,
  sessionEnded,
  sessionExpired,
  sessionWarning,
  sessionLocked,
  sessionRestored,
}
