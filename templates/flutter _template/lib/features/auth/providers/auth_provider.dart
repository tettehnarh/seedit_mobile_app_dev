import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../../../core/utils/storage_utils.dart';
import '../../../core/events/auth_events.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/biometric_service.dart';
import '../services/user_storage_service.dart';
import '../../kyc/services/kyc_service.dart';

// Auth state model
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

// Auth provider with automatic logout detection
class AuthNotifier extends StateNotifier<AuthState> with AuthEventListener {
  final AuthService _authService;
  final UserService _userService;
  final KycService _kycService;
  final BiometricService _biometricService;

  AuthNotifier(
    this._authService,
    this._userService,
    this._kycService,
    this._biometricService,
  ) : super(const AuthState()) {
    _checkAuthStatus();
    // Start listening for authentication events
    startListeningToAuthEvents();
  }

  @override
  void dispose() {
    // Stop listening to auth events when provider is disposed
    stopListeningToAuthEvents();
    super.dispose();
  }

  @override
  void onAuthEvent(AuthEvent event) {
    developer.log('🎯 [AUTH_PROVIDER] Received auth event: $event');

    switch (event.type) {
      case AuthEventType.sessionInvalidated:
      case AuthEventType.tokenExpired:
      case AuthEventType.forceLogout:
        _handleAutomaticLogout(event);
        break;
      case AuthEventType.kycApprovalLogout:
        _handleKycApprovalLogout(event);
        break;
    }
  }

  /// Handle automatic logout for general session invalidation
  void _handleAutomaticLogout(AuthEvent event) async {
    developer.log(
      '🚪 [AUTH_PROVIDER] Handling automatic logout: ${event.reason}',
    );

    // Clear stored user information
    await UserStorageService.clearStoredUser();

    // Clear the authentication state
    state = const AuthState(
      isAuthenticated: false,
      isLoading: false,
      user: null,
      error: null,
    );

    developer.log('✅ [AUTH_PROVIDER] User automatically logged out');
  }

  /// Handle KYC approval logout with special messaging
  void _handleKycApprovalLogout(AuthEvent event) async {
    developer.log(
      '🎉 [AUTH_PROVIDER] Handling KYC approval logout: ${event.reason}',
    );

    // Clear stored user information
    await UserStorageService.clearStoredUser();

    // Clear the authentication state with a specific message
    state = const AuthState(
      isAuthenticated: false,
      isLoading: false,
      user: null,
      error:
          'KYC approved! Please log in again to access your updated account.',
    );

    developer.log('✅ [AUTH_PROVIDER] User logged out due to KYC approval');
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        // Try to get fresh user data from backend
        final userResult = await _userService.getUserProfile();

        if (userResult['success'] == true) {
          final user = UserModel.fromJson(userResult['data']);

          // Also refresh KYC status
          final kycResult = await _kycService.getKycStatus();
          if (kycResult['success'] == true) {
            final kycStatus = kycResult['data']['kyc_status'];
            final updatedUser = user.copyWith(kycStatus: kycStatus);
            state = state.copyWith(isAuthenticated: true, user: updatedUser);
          } else {
            state = state.copyWith(isAuthenticated: true, user: user);
          }
        } else {
          // Fallback to cached data
          final userEmail = await StorageUtils.getUserEmail();
          final userName = await StorageUtils.getString('user_name');
          final userId = await StorageUtils.getString('user_id');
          final kycStatus = await StorageUtils.getString('kyc_status');

          if (userEmail != null && userId != null) {
            final user = UserModel(
              id: userId,
              email: userEmail,
              username: userName ?? userEmail.split('@')[0],
              firstName: userName?.split(' ').first ?? '',
              lastName: userName?.split(' ').skip(1).join(' ') ?? '',
              kycStatus: kycStatus ?? 'pending',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            state = state.copyWith(isAuthenticated: true, user: user);
          }
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.login(
        username: email,
        password: password,
      );

      if (result['success'] == true) {
        final user = UserModel.fromJson(result['user']);

        // Check if user requires password change
        if (user.requiresPasswordChange) {
          state = state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            user: user,
          );

          return {
            'success': true,
            'requires_password_change': true,
            'user': user,
          };
        }

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: user,
        );

        // Store user information
        await UserStorageService.storeLastUser(
          email: user.email,
          userId: user.id.toString(),
          name: user.username,
        );

        return {'success': true, 'user': user};
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['error'] ?? 'Sign in failed',
        );
        return {'success': false, 'error': result['error'] ?? 'Sign in failed'};
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String username,
    required String phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.register({
        'email': email,
        'password': password,
        'username': username,
        'phone_number': phoneNumber,
      });

      if (result['success'] == true) {
        if (result['requires_verification'] == true) {
          // Registration successful, but email verification required
          state = state.copyWith(isLoading: false);
          return {
            'success': true,
            'requires_verification': true,
            'email': result['email'],
            'message': result['message'],
          };
        } else if (result['user'] != null) {
          // Immediate registration (fallback)
          final user = UserModel.fromJson(result['user']);
          state = state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            user: user,
          );
          return {'success': true, 'requires_verification': false};
        }
      }

      state = state.copyWith(
        isLoading: false,
        error: result['error'] ?? 'Sign up failed',
      );
      return {'success': false, 'error': result['error'] ?? 'Sign up failed'};
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Verify email with PIN
  Future<bool> verifyEmail({required String email, required String pin}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.verifyEmail(email: email, pin: pin);

      if (result['success'] == true && result['user'] != null) {
        final user = UserModel.fromJson(result['user']);

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: user,
        );

        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['error'] ?? 'Email verification failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Resend verification email
  Future<bool> resendVerificationEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.resendVerificationEmail(email);

      state = state.copyWith(isLoading: false);

      if (result['success'] == true) {
        return true;
      } else {
        state = state.copyWith(
          error: result['error'] ?? 'Failed to resend verification email',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.forgotPassword(email);

      state = state.copyWith(isLoading: false);

      if (result['success'] == true) {
        return true;
      } else {
        state = state.copyWith(
          error: result['error'] ?? 'Password reset failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Sign out user with complete session cleanup
  Future<void> signOut() async {
    try {
      developer.log('Starting sign out process...');

      // Perform logout with complete session cleanup
      final result = await _authService.logout();

      if (result['success'] == true) {
        // Clear biometric data
        await _biometricService.clearBiometricData();

        // Clear stored user information
        await UserStorageService.clearStoredUser();

        // Reset auth state to initial empty state
        state = const AuthState();

        // Additional cleanup - clear any cached provider data
        await _clearProviderCaches();

        developer.log('Sign out completed successfully');
      } else {
        state = state.copyWith(error: result['error'] ?? 'Logout failed');
      }
    } catch (e) {
      developer.log('Error during sign out: $e', error: e);

      // Force reset state even if logout fails
      state = const AuthState();

      // Try to clear caches anyway
      try {
        await _clearProviderCaches();
      } catch (cacheError) {
        developer.log(
          'Error clearing provider caches: $cacheError',
          error: cacheError,
        );
      }

      state = state.copyWith(error: 'Sign out completed with errors');
    }
  }

  /// Clear provider caches and reset states
  Future<void> _clearProviderCaches() async {
    try {
      developer.log('Clearing provider caches...');

      // Clear any additional cached data that might persist
      await Future.wait([
        StorageUtils.remove('auth_cache'),
        StorageUtils.remove('user_cache'),
        StorageUtils.remove('session_cache'),
      ]);

      developer.log('Provider caches cleared');
    } catch (e) {
      developer.log('Error clearing provider caches: $e', error: e);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh authentication status
  Future<void> refreshAuthStatus() async {
    await _checkAuthStatus();
  }

  /// Sign in with biometric authentication
  Future<Map<String, dynamic>> signInWithBiometric() async {
    try {
      developer.log('Attempting biometric sign in...');
      state = state.copyWith(isLoading: true, error: null);

      // Authenticate with biometrics and get stored token
      final authResult = await _biometricService.authenticateWithBiometric();

      if (!authResult.success || authResult.authToken == null) {
        state = state.copyWith(
          isLoading: false,
          error: authResult.errorMessage ?? 'Biometric authentication failed',
        );
        return {
          'success': false,
          'error': authResult.errorMessage ?? 'Biometric authentication failed',
        };
      }

      // Store the token and get user profile to validate
      await StorageUtils.setAccessToken(authResult.authToken!);

      // Get user profile to validate the token
      final result = await _authService.getUserProfile();

      if (result['success'] == true && result['user'] != null) {
        final user = UserModel.fromJson(result['user']);

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: user,
        );

        developer.log('Biometric sign in successful for user: ${user.email}');
        return {'success': true, 'user': user.toJson()};
      } else {
        // Token is invalid, disable biometric auth
        await _biometricService.disableBiometric();
        await StorageUtils.clearAuthData();
        state = state.copyWith(
          isLoading: false,
          error: 'Authentication token expired. Please sign in again.',
        );
        return {
          'success': false,
          'error': 'Authentication token expired. Please sign in again.',
        };
      }
    } catch (e) {
      developer.log('Error during biometric sign in: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        error: 'Biometric authentication failed',
      );
      return {'success': false, 'error': 'Biometric authentication failed'};
    }
  }

  /// Enable biometric authentication after successful login
  Future<bool> enableBiometric() async {
    try {
      developer.log('Enabling biometric authentication...');

      // Get current auth token
      final authToken = await StorageUtils.getAccessToken();
      if (authToken == null) {
        developer.log('No auth token found, cannot enable biometric');
        return false;
      }

      // Enable biometric with current token
      final result = await _biometricService.enableBiometric(authToken);

      if (result.success) {
        developer.log('Biometric authentication enabled successfully');
        return true;
      } else {
        developer.log('Failed to enable biometric: ${result.message}');
        return false;
      }
    } catch (e) {
      developer.log('Error enabling biometric authentication: $e', error: e);
      return false;
    }
  }

  /// Disable biometric authentication
  Future<bool> disableBiometric() async {
    try {
      developer.log('Disabling biometric authentication...');

      final result = await _biometricService.disableBiometric();

      if (result.success) {
        developer.log('Biometric authentication disabled successfully');
        return true;
      } else {
        developer.log('Failed to disable biometric: ${result.message}');
        return false;
      }
    } catch (e) {
      developer.log('Error disabling biometric authentication: $e', error: e);
      return false;
    }
  }

  /// Check if biometric authentication is available and enabled
  Future<bool> isBiometricEnabled() async {
    try {
      return await _biometricService.isBiometricEnabled();
    } catch (e) {
      developer.log('Error checking biometric status: $e', error: e);
      return false;
    }
  }

  /// Verify password reset OTP
  Future<bool> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      developer.log('Verifying password reset OTP for: $email');

      final result = await _authService.verifyPasswordResetOtp(
        email: email,
        otp: otp,
      );

      if (result['success'] == true) {
        developer.log('Password reset OTP verification successful');
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        final errorMessage = result['error'] ?? 'OTP verification failed';
        developer.log('Password reset OTP verification failed: $errorMessage');
        state = state.copyWith(isLoading: false, error: errorMessage);
        return false;
      }
    } catch (e) {
      developer.log('Password reset OTP verification error: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to verify OTP. Please try again.',
      );
      return false;
    }
  }

  /// Reset password with OTP
  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      developer.log('Resetting password for: $email');

      final result = await _authService.resetPasswordWithOtp(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );

      if (result['success'] == true) {
        developer.log('Password reset successful');

        // Clear authentication state for security
        await _clearProviderCaches();
        state = const AuthState(); // Reset to initial state

        return true;
      } else {
        final errorMessage = result['error'] ?? 'Password reset failed';
        developer.log('Password reset failed: $errorMessage');
        state = state.copyWith(isLoading: false, error: errorMessage);
        return false;
      }
    } catch (e) {
      developer.log('Password reset error: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to reset password. Please try again.',
      );
      return false;
    }
  }
}

// Provider instances
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final userServiceProvider = Provider<UserService>((ref) => UserService());
final kycServiceProvider = Provider<KycService>((ref) => KycService());
final biometricServiceProvider = Provider<BiometricService>(
  (ref) => BiometricService(),
);

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  final userService = ref.read(userServiceProvider);
  final kycService = ref.read(kycServiceProvider);
  final biometricService = ref.read(biometricServiceProvider);
  return AuthNotifier(authService, userService, kycService, biometricService);
});

// Convenience providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});
