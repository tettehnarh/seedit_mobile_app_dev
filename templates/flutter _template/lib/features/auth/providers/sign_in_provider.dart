import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sign_in_model.dart';
import '../services/auth_service.dart';
import '../../../core/utils/connectivity_utils.dart';

import '../../../core/services/session_manager.dart';
import 'user_provider.dart';
import 'dart:developer' as developer;

/// State class for sign-in functionality
class SignInState {
  final SignInModel signInModel;
  final bool isLoading;
  final String? errorMessage;
  final bool obscurePassword;

  const SignInState({
    required this.signInModel,
    this.isLoading = false,
    this.errorMessage,
    this.obscurePassword = true,
  });

  SignInState copyWith({
    SignInModel? signInModel,
    bool? isLoading,
    String? errorMessage,
    bool? obscurePassword,
    bool clearError = false,
  }) {
    return SignInState(
      signInModel: signInModel ?? this.signInModel,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}

/// Riverpod provider for managing sign-in screen state
class SignInNotifier extends StateNotifier<SignInState> {
  final AuthService _authService = AuthService();
  final Ref _ref;

  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignInNotifier(this._ref) : super(SignInState(signInModel: SignInModel()));

  /// Update email
  void setEmail(String email) {
    state = state.copyWith(
      signInModel: state.signInModel.copyWith(email: email),
      clearError: true,
    );
  }

  /// Update password
  void setPassword(String password) {
    state = state.copyWith(
      signInModel: state.signInModel.copyWith(password: password),
      clearError: true,
    );
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  /// Set loading state
  void _setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// Set error message
  void _setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }

  /// Clear error message
  void _clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }

  /// Sign in user
  Future<void> signIn(BuildContext context) async {
    try {
      // Clear any previous errors
      _clearError();

      // Update model with current controller values
      state = state.copyWith(
        signInModel: state.signInModel.copyWith(
          email: emailController.text.trim(),
          password: passwordController.text,
        ),
      );

      // Note: Form validation is now handled externally

      // Check internet connectivity
      final hasConnection = await ConnectivityUtils.checkInternetConnection(
        context,
      );
      if (!hasConnection) {
        _setError(
          'No internet connection. Please check your network settings.',
        );
        return;
      }

      _setLoading(true);

      developer.log('==== SIGN IN WITH SESSION MANAGEMENT START ====');
      developer.log('Attempting sign in for: ${state.signInModel.email}');

      // Use session manager for login with complete session management
      final response = await SessionManager.login(
        ref: _ref,
        username: state.signInModel.email,
        password: state.signInModel.password,
        loginFunction: (username, password) =>
            _authService.login(username: username, password: password),
      );

      developer.log('Sign in response: $response');

      if (response['success'] == true) {
        developer.log('Sign in successful');

        // Check if user requires password change
        if (response['requires_password_change'] == true) {
          developer.log('==== SIGN IN REQUIRES PASSWORD CHANGE ====');
          developer.log('User must change password before continuing');

          // Update user provider with login data
          _ref
              .read(userProvider.notifier)
              .updateUserAfterLogin(response['user']);

          // Clear form
          _clearForm();

          // Navigate to forced password change screen
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/forced-password-change');
          }
          return;
        }

        // Update user provider with login data
        _ref.read(userProvider.notifier).updateUserAfterLogin(response['user']);

        // Clear form
        _clearForm();

        // Navigate to home screen
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else if (response['requires_verification'] == true) {
        // Handle unverified email case
        developer.log('==== SIGN IN REQUIRES EMAIL VERIFICATION ====');
        developer.log('User email not verified: ${response['email']}');

        // Clear form
        _clearForm();

        // Navigate to email verification screen
        if (context.mounted) {
          Navigator.pushNamed(
            context,
            '/email-verification',
            arguments: {
              'email': response['email'],
              'message': response['message'],
            },
          );
        }
      } else {
        // Handle sign in failure
        final errorMsg =
            response['error'] ?? 'Sign in failed. Please try again.';
        _setError(errorMsg);
        developer.log('Sign in failed: $errorMsg');
      }
    } catch (e) {
      developer.log('Sign in error: $e', error: e);
      _setError('An error occurred. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in user without form validation (for external validation)
  Future<void> signInWithoutValidation(BuildContext context) async {
    try {
      // Clear any previous errors
      _clearError();

      // Update model with current controller values
      state = state.copyWith(
        signInModel: state.signInModel.copyWith(
          email: emailController.text.trim(),
          password: passwordController.text,
        ),
      );

      // Check internet connectivity
      final hasConnection = await ConnectivityUtils.checkInternetConnection(
        context,
      );
      if (!hasConnection) {
        _setError(
          'No internet connection. Please check your network settings.',
        );
        return;
      }

      _setLoading(true);

      developer.log('==== SIGN IN WITH SESSION MANAGEMENT START ====');
      developer.log('Attempting sign in for: ${state.signInModel.email}');

      // Use session manager for login with complete session management
      final response = await SessionManager.login(
        ref: _ref,
        username: state.signInModel.email,
        password: state.signInModel.password,
        loginFunction: (username, password) =>
            _authService.login(username: username, password: password),
      );

      developer.log('Sign in response: $response');

      if (response['success'] == true) {
        developer.log('Sign in successful');

        // Check if user requires password change
        if (response['requires_password_change'] == true) {
          developer.log('==== SIGN IN REQUIRES PASSWORD CHANGE ====');
          developer.log('User must change password before continuing');

          // Update user provider with login data
          _ref
              .read(userProvider.notifier)
              .updateUserAfterLogin(response['user']);

          // Clear form
          _clearForm();

          // Navigate to forced password change screen
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/forced-password-change');
          }
          return;
        }

        // Update user provider with login data
        _ref.read(userProvider.notifier).updateUserAfterLogin(response['user']);

        // Clear form
        _clearForm();

        // Navigate to home screen
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else if (response['requires_verification'] == true) {
        // Handle unverified email case
        developer.log('==== SIGN IN REQUIRES EMAIL VERIFICATION ====');
        developer.log('User email not verified: ${response['email']}');

        // Clear form
        _clearForm();

        // Navigate to email verification screen
        if (context.mounted) {
          Navigator.pushNamed(
            context,
            '/email-verification',
            arguments: {
              'email': response['email'],
              'message': response['message'],
            },
          );
        }
      } else {
        // Handle sign in failure
        final errorMsg =
            response['error'] ?? 'Sign in failed. Please try again.';
        _setError(errorMsg);
        developer.log('Sign in failed: $errorMsg');
      }
    } catch (e) {
      developer.log('Sign in error: $e', error: e);
      _setError('An error occurred. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  /// Navigate to forgot password
  void navigateToForgotPassword(BuildContext context) {
    Navigator.pushNamed(context, '/forgot-password');
  }

  /// Navigate to sign up
  void navigateToSignUp(BuildContext context) {
    Navigator.pushNamed(context, '/sign-up');
  }

  /// Clear form
  void _clearForm() {
    emailController.clear();
    passwordController.clear();
    state = SignInState(signInModel: SignInModel());
  }

  /// Dispose resources
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _authService.dispose();
    super.dispose();
  }
}

/// Provider for SignInNotifier
final signInProvider =
    StateNotifierProvider.autoDispose<SignInNotifier, SignInState>((ref) {
      return SignInNotifier(ref);
    });

/// Convenience providers for accessing specific parts of the state
final signInModelProvider = Provider.autoDispose<SignInModel>((ref) {
  return ref.watch(signInProvider).signInModel;
});

final signInLoadingProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(signInProvider).isLoading;
});

final signInErrorProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(signInProvider).errorMessage;
});

final signInObscurePasswordProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(signInProvider).obscurePassword;
});
