import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/session_service.dart';

// Security services providers
final biometricServiceProvider = Provider<BiometricService>((ref) => BiometricService());
final sessionServiceProvider = Provider<SessionService>((ref) => SessionService());

// Security state provider
final securityStateProvider = StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
  return SecurityNotifier(
    ref.read(biometricServiceProvider),
    ref.read(sessionServiceProvider),
  );
});

// Biometric capabilities provider
final biometricCapabilitiesProvider = FutureProvider<BiometricCapabilities>((ref) async {
  final biometricService = ref.read(biometricServiceProvider);
  return await biometricService.getBiometricCapabilities();
});

// Session info provider
final sessionInfoProvider = FutureProvider<SessionInfo>((ref) async {
  final sessionService = ref.read(sessionServiceProvider);
  return await sessionService.getSessionInfo();
});

// Biometric enabled provider
final biometricEnabledProvider = FutureProvider<bool>((ref) async {
  final biometricService = ref.read(biometricServiceProvider);
  return await biometricService.isBiometricEnabled();
});

// Auto-lock enabled provider
final autoLockEnabledProvider = FutureProvider<bool>((ref) async {
  final sessionService = ref.read(sessionServiceProvider);
  return await sessionService.isAutoLockEnabled();
});

// Session timeout provider
final sessionTimeoutProvider = FutureProvider<int>((ref) async {
  final sessionService = ref.read(sessionServiceProvider);
  return await sessionService.getSessionTimeout();
});

class SecurityState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticating;
  final bool isSessionActive;
  final SessionEvent? lastSessionEvent;

  SecurityState({
    this.isLoading = false,
    this.error,
    this.isAuthenticating = false,
    this.isSessionActive = false,
    this.lastSessionEvent,
  });

  SecurityState copyWith({
    bool? isLoading,
    String? error,
    bool? isAuthenticating,
    bool? isSessionActive,
    SessionEvent? lastSessionEvent,
  }) {
    return SecurityState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      isSessionActive: isSessionActive ?? this.isSessionActive,
      lastSessionEvent: lastSessionEvent ?? this.lastSessionEvent,
    );
  }
}

class SecurityNotifier extends StateNotifier<SecurityState> {
  final BiometricService _biometricService;
  final SessionService _sessionService;

  SecurityNotifier(this._biometricService, this._sessionService) : super(SecurityState()) {
    _initialize();
  }

  void _initialize() {
    // Listen to session events
    _sessionService.sessionEvents.listen((event) {
      state = state.copyWith(
        lastSessionEvent: event,
        isSessionActive: _sessionService.isSessionActive,
      );
    });
  }

  // Initialize security services
  Future<void> initializeSecurity() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _sessionService.initialize();
      state = state.copyWith(
        isLoading: false,
        isSessionActive: _sessionService.isSessionActive,
      );
    } catch (e) {
      debugPrint('Initialize security error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Enable biometric authentication
  Future<bool> enableBiometric() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _biometricService.enableBiometric();
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      debugPrint('Enable biometric error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Disable biometric authentication
  Future<void> disableBiometric() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _biometricService.disableBiometric();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      debugPrint('Disable biometric error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Authenticate with biometric
  Future<bool> authenticateWithBiometric({
    String? reason,
    bool fallbackToCredentials = true,
  }) async {
    state = state.copyWith(isAuthenticating: true, error: null);
    
    try {
      final success = await _biometricService.authenticateWithBiometric(
        reason: reason,
        fallbackToCredentials: fallbackToCredentials,
      );
      
      state = state.copyWith(isAuthenticating: false);
      return success;
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      state = state.copyWith(
        isAuthenticating: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Start session
  Future<void> startSession() async {
    try {
      await _sessionService.startSession();
      state = state.copyWith(isSessionActive: true);
    } catch (e) {
      debugPrint('Start session error: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  // End session
  Future<void> endSession() async {
    try {
      await _sessionService.endSession();
      state = state.copyWith(isSessionActive: false);
    } catch (e) {
      debugPrint('End session error: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  // Update activity
  Future<void> updateActivity() async {
    try {
      await _sessionService.updateActivity();
    } catch (e) {
      debugPrint('Update activity error: $e');
    }
  }

  // Set session timeout
  Future<void> setSessionTimeout(int minutes) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _sessionService.setSessionTimeout(minutes);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      debugPrint('Set session timeout error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Set auto-lock enabled
  Future<void> setAutoLockEnabled(bool enabled) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _sessionService.setAutoLockEnabled(enabled);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      debugPrint('Set auto-lock error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Set lock on background enabled
  Future<void> setLockOnBackgroundEnabled(bool enabled) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _sessionService.setLockOnBackgroundEnabled(enabled);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      debugPrint('Set lock on background error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Handle app lifecycle changes
  Future<void> onAppBackground() async {
    try {
      await _sessionService.onAppBackground();
    } catch (e) {
      debugPrint('App background error: $e');
    }
  }

  Future<void> onAppForeground() async {
    try {
      await _sessionService.onAppForeground();
      state = state.copyWith(isSessionActive: _sessionService.isSessionActive);
    } catch (e) {
      debugPrint('App foreground error: $e');
    }
  }

  // Check if biometric is available
  Future<bool> isBiometricAvailable() async {
    try {
      return await _biometricService.isBiometricAvailable();
    } catch (e) {
      debugPrint('Check biometric availability error: $e');
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _biometricService.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Get available biometrics error: $e');
      return [];
    }
  }

  // Get biometric type display name
  Future<String> getBiometricTypeDisplayName() async {
    try {
      return await _biometricService.getBiometricTypeDisplayName();
    } catch (e) {
      debugPrint('Get biometric type display name error: $e');
      return 'Biometric';
    }
  }

  // Check if session is expired
  Future<bool> isSessionExpired() async {
    try {
      return await _sessionService.isSessionExpired();
    } catch (e) {
      debugPrint('Check session expired error: $e');
      return true;
    }
  }

  // Get remaining session time
  Future<int> getRemainingSessionTime() async {
    try {
      return await _sessionService.getRemainingSessionTime();
    } catch (e) {
      debugPrint('Get remaining session time error: $e');
      return 0;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Refresh security settings
  Future<void> refreshSecuritySettings() async {
    // Trigger refresh of providers
    ref.invalidate(biometricCapabilitiesProvider);
    ref.invalidate(sessionInfoProvider);
    ref.invalidate(biometricEnabledProvider);
    ref.invalidate(autoLockEnabledProvider);
    ref.invalidate(sessionTimeoutProvider);
  }
}

// Security settings model
class SecuritySettings {
  final bool biometricEnabled;
  final bool autoLockEnabled;
  final bool lockOnBackgroundEnabled;
  final int sessionTimeoutMinutes;
  final BiometricCapabilities biometricCapabilities;

  SecuritySettings({
    required this.biometricEnabled,
    required this.autoLockEnabled,
    required this.lockOnBackgroundEnabled,
    required this.sessionTimeoutMinutes,
    required this.biometricCapabilities,
  });

  SecuritySettings copyWith({
    bool? biometricEnabled,
    bool? autoLockEnabled,
    bool? lockOnBackgroundEnabled,
    int? sessionTimeoutMinutes,
    BiometricCapabilities? biometricCapabilities,
  }) {
    return SecuritySettings(
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoLockEnabled: autoLockEnabled ?? this.autoLockEnabled,
      lockOnBackgroundEnabled: lockOnBackgroundEnabled ?? this.lockOnBackgroundEnabled,
      sessionTimeoutMinutes: sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      biometricCapabilities: biometricCapabilities ?? this.biometricCapabilities,
    );
  }
}
