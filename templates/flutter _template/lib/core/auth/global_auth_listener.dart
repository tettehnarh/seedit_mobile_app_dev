import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../events/auth_events.dart';
import '../navigation/navigation_service.dart';

/// Global authentication listener that handles navigation and UI updates
/// when authentication events occur (like session invalidation)
class GlobalAuthListener with AuthEventListener {
  static final GlobalAuthListener _instance = GlobalAuthListener._internal();
  factory GlobalAuthListener() => _instance;
  GlobalAuthListener._internal();

  // TEMPORARY DEBUG FLAG: Set to false to disable automatic logout handling
  static const bool enableAuthEventHandling = false;

  bool _isInitialized = false;

  /// Initialize the global auth listener
  void initialize() {
    if (_isInitialized) {
      developer.log('⚠️ [GLOBAL_AUTH_LISTENER] Already initialized');
      return;
    }

    developer.log(
      '🚀 [GLOBAL_AUTH_LISTENER] Initializing global auth listener',
    );
    startListeningToAuthEvents();
    _isInitialized = true;
  }

  /// Dispose the global auth listener
  void dispose() {
    if (!_isInitialized) return;

    developer.log('🛑 [GLOBAL_AUTH_LISTENER] Disposing global auth listener');
    stopListeningToAuthEvents();
    _isInitialized = false;
  }

  @override
  void onAuthEvent(AuthEvent event) {
    developer.log('🎯 [GLOBAL_AUTH_LISTENER] Received auth event: $event');

    if (!enableAuthEventHandling) {
      developer.log('⚠️ [DEBUG] Auth event handling DISABLED for debugging');
      return;
    }

    switch (event.type) {
      case AuthEventType.sessionInvalidated:
        _handleSessionInvalidated(event);
        break;
      case AuthEventType.tokenExpired:
        _handleTokenExpired(event);
        break;
      case AuthEventType.forceLogout:
        _handleForceLogout(event);
        break;
      case AuthEventType.kycApprovalLogout:
        _handleKycApprovalLogout(event);
        break;
    }
  }

  /// Handle session invalidation
  void _handleSessionInvalidated(AuthEvent event) {
    developer.log('🔑 [GLOBAL_AUTH_LISTENER] Handling session invalidation');

    // Navigate to login with appropriate message
    NavigationService().navigateToLogin(
      message: 'Your session has expired. Please log in again.',
    );

    // Show notification
    NavigationService().showError('Session expired. Please log in again.');
  }

  /// Handle token expiration
  void _handleTokenExpired(AuthEvent event) {
    developer.log('⏰ [GLOBAL_AUTH_LISTENER] Handling token expiration');

    // Navigate to login with appropriate message
    NavigationService().navigateToLogin(
      message: 'Your login has expired. Please log in again.',
    );

    // Show notification
    NavigationService().showError('Login expired. Please log in again.');
  }

  /// Handle force logout
  void _handleForceLogout(AuthEvent event) {
    developer.log('🚪 [GLOBAL_AUTH_LISTENER] Handling force logout');

    // Navigate to login with appropriate message
    NavigationService().navigateToLogin(
      message: event.reason ?? 'You have been logged out.',
    );

    // Show notification
    NavigationService().showInfo(event.reason ?? 'You have been logged out.');
  }

  /// Handle KYC approval logout with special messaging
  void _handleKycApprovalLogout(AuthEvent event) {
    developer.log('🎉 [GLOBAL_AUTH_LISTENER] Handling KYC approval logout');

    // Navigate to login with congratulatory message
    NavigationService().navigateToLogin(
      message:
          'Congratulations! Your KYC has been approved. Please log in again to access your updated account.',
    );

    // Show success notification
    NavigationService().showSuccess(
      'KYC Approved! Please log in again to continue.',
    );
  }
}

/// Widget that initializes the global auth listener
class GlobalAuthListenerWidget extends StatefulWidget {
  final Widget child;

  const GlobalAuthListenerWidget({Key? key, required this.child})
    : super(key: key);

  @override
  State<GlobalAuthListenerWidget> createState() =>
      _GlobalAuthListenerWidgetState();
}

class _GlobalAuthListenerWidgetState extends State<GlobalAuthListenerWidget> {
  @override
  void initState() {
    super.initState();
    // Initialize the global auth listener when the widget is created
    GlobalAuthListener().initialize();
  }

  @override
  void dispose() {
    // Dispose the global auth listener when the widget is disposed
    GlobalAuthListener().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
