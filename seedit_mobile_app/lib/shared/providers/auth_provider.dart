import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../../core/services/auth_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.user;
});

// Auth loading provider
final authLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isLoading;
});

// Auth error provider
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.error;
});

// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isAuthenticated;
});

class AuthState {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _checkAuthStatus();
  }

  // Check initial authentication status
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final isSignedIn = await _authService.isSignedIn();
      if (isSignedIn) {
        final user = await _authService.getCurrentUser();
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('Auth status check error: $e');
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Sign up
  Future<void> signUp(SignUpRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final authResponse = await _authService.signUp(request);
      state = state.copyWith(
        user: authResponse.user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Sign up error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Sign in
  Future<void> signIn(SignInRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final authResponse = await _authService.signIn(request);
      state = state.copyWith(
        user: authResponse.user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Sign in error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.signOut();
      state = AuthState(); // Reset to initial state
    } catch (e) {
      debugPrint('Sign out error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Confirm sign up
  Future<void> confirmSignUp(String email, String confirmationCode) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.confirmSignUp(email, confirmationCode);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      debugPrint('Confirm sign up error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Resend confirmation code
  Future<void> resendConfirmationCode(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.resendSignUpCode(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      debugPrint('Resend code error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.resetPassword(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      debugPrint('Reset password error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Confirm password reset
  Future<void> confirmPasswordReset(
    String email,
    String newPassword,
    String confirmationCode,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.confirmResetPassword(email, newPassword, confirmationCode);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      debugPrint('Confirm password reset error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Update password
  Future<void> updatePassword(String oldPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.updatePassword(oldPassword, newPassword);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      debugPrint('Update password error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (!state.isAuthenticated) return;
    
    try {
      final user = await _authService.getCurrentUser();
      state = state.copyWith(user: user);
    } catch (e) {
      debugPrint('Refresh user error: $e');
      // Don't update error state for refresh failures
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
