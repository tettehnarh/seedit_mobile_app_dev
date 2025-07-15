import 'dart:async';
import 'dart:developer' as developer;

/// Authentication event types
enum AuthEventType {
  sessionInvalidated,
  tokenExpired,
  forceLogout,
  kycApprovalLogout,
}

/// Authentication event data
class AuthEvent {
  final AuthEventType type;
  final String? reason;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  AuthEvent({
    required this.type,
    this.reason,
    this.data,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'AuthEvent(type: $type, reason: $reason, timestamp: $timestamp)';
  }
}

/// Global authentication event bus for handling session invalidation
class AuthEventBus {
  static final AuthEventBus _instance = AuthEventBus._internal();
  factory AuthEventBus() => _instance;
  AuthEventBus._internal();

  final StreamController<AuthEvent> _controller = StreamController<AuthEvent>.broadcast();

  /// Stream of authentication events
  Stream<AuthEvent> get events => _controller.stream;

  /// Fire an authentication event
  void fire(AuthEvent event) {
    developer.log('🔥 [AUTH_EVENT_BUS] Firing event: $event');
    _controller.add(event);
  }

  /// Fire a session invalidation event
  void fireSessionInvalidated({String? reason, Map<String, dynamic>? data}) {
    fire(AuthEvent(
      type: AuthEventType.sessionInvalidated,
      reason: reason ?? 'Session invalidated by server',
      data: data,
    ));
  }

  /// Fire a token expiration event
  void fireTokenExpired({String? reason, Map<String, dynamic>? data}) {
    fire(AuthEvent(
      type: AuthEventType.tokenExpired,
      reason: reason ?? 'Authentication token expired',
      data: data,
    ));
  }

  /// Fire a force logout event
  void fireForceLogout({String? reason, Map<String, dynamic>? data}) {
    fire(AuthEvent(
      type: AuthEventType.forceLogout,
      reason: reason ?? 'Forced logout required',
      data: data,
    ));
  }

  /// Fire a KYC approval logout event
  void fireKycApprovalLogout({String? reason, Map<String, dynamic>? data}) {
    fire(AuthEvent(
      type: AuthEventType.kycApprovalLogout,
      reason: reason ?? 'KYC approved - re-authentication required',
      data: data,
    ));
  }

  /// Dispose the event bus
  void dispose() {
    _controller.close();
  }
}

/// Mixin for listening to authentication events
mixin AuthEventListener {
  StreamSubscription<AuthEvent>? _authEventSubscription;

  /// Start listening to authentication events
  void startListeningToAuthEvents() {
    _authEventSubscription = AuthEventBus().events.listen(
      (event) {
        developer.log('📡 [AUTH_EVENT_LISTENER] Received event: $event');
        onAuthEvent(event);
      },
      onError: (error) {
        developer.log('❌ [AUTH_EVENT_LISTENER] Error: $error', error: error);
      },
    );
  }

  /// Stop listening to authentication events
  void stopListeningToAuthEvents() {
    _authEventSubscription?.cancel();
    _authEventSubscription = null;
  }

  /// Handle authentication events (override in implementing classes)
  void onAuthEvent(AuthEvent event);
}

/// Authentication failure detector
class AuthFailureDetector {
  static final AuthFailureDetector _instance = AuthFailureDetector._internal();
  factory AuthFailureDetector() => _instance;
  AuthFailureDetector._internal();

  /// Detect and handle authentication failure from HTTP response
  void handleHttpAuthFailure({
    required int statusCode,
    required Map<String, dynamic>? responseData,
    required String endpoint,
  }) {
    if (statusCode == 401) {
      developer.log('🚨 [AUTH_FAILURE_DETECTOR] 401 Unauthorized detected on $endpoint');
      
      // Check if this is a session invalidation due to KYC approval
      final errorCode = responseData?['error_code'];
      final detail = responseData?['detail'] ?? 'Unauthorized';
      
      if (errorCode == 'INVALID_TOKEN' || detail.toLowerCase().contains('invalid token')) {
        developer.log('🔍 [AUTH_FAILURE_DETECTOR] Token invalidation detected');
        
        // Check if this might be due to KYC approval
        if (detail.toLowerCase().contains('kyc') || 
            detail.toLowerCase().contains('approval') ||
            detail.toLowerCase().contains('re-authentication')) {
          AuthEventBus().fireKycApprovalLogout(
            reason: detail,
            data: {
              'endpoint': endpoint,
              'statusCode': statusCode,
              'errorCode': errorCode,
            },
          );
        } else {
          AuthEventBus().fireSessionInvalidated(
            reason: detail,
            data: {
              'endpoint': endpoint,
              'statusCode': statusCode,
              'errorCode': errorCode,
            },
          );
        }
      } else {
        AuthEventBus().fireTokenExpired(
          reason: detail,
          data: {
            'endpoint': endpoint,
            'statusCode': statusCode,
            'errorCode': errorCode,
          },
        );
      }
    }
  }

  /// Detect authentication failure from API exceptions
  void handleApiException(dynamic exception, String endpoint) {
    developer.log('🚨 [AUTH_FAILURE_DETECTOR] API exception on $endpoint: $exception');
    
    if (exception.toString().toLowerCase().contains('unauthorized') ||
        exception.toString().toLowerCase().contains('401')) {
      AuthEventBus().fireSessionInvalidated(
        reason: 'API authentication failure: $exception',
        data: {
          'endpoint': endpoint,
          'exception': exception.toString(),
        },
      );
    }
  }
}
