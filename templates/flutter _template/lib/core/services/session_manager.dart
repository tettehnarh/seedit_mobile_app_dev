import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/storage_utils.dart';
import '../utils/secure_storage_utils.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/providers/user_provider.dart';
import '../../features/investments/providers/investment_provider.dart';

/// Centralized session manager for coordinating user session cleanup
/// and ensuring complete data isolation between different user sessions
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  /// Complete session cleanup - clears all user data across the entire app
  static Future<void> clearCompleteSession() async {
    try {
      developer.log('==== COMPLETE SESSION CLEANUP START ====');
      developer.log('Starting comprehensive session cleanup...');

      // Perform parallel cleanup of all storage systems
      await Future.wait([
        StorageUtils.clearCompleteSession(),
        SecureStorageUtils.clearCompleteSession(),
      ]);

      developer.log('==== COMPLETE SESSION CLEANUP FINISHED ====');
      developer.log('All user data cleared successfully');
    } catch (e) {
      developer.log('==== SESSION CLEANUP ERROR ====');
      developer.log('Error during complete session cleanup: $e', error: e);

      // Fallback: nuclear cleanup
      try {
        await _fallbackCleanup();
        developer.log('Fallback cleanup completed');
      } catch (fallbackError) {
        developer.log(
          'Fallback cleanup failed: $fallbackError',
          error: fallbackError,
        );
        rethrow;
      }
    }
  }

  /// Pre-login cleanup to ensure clean state before new user login
  static Future<void> preLoginCleanup() async {
    try {
      developer.log('==== PRE-LOGIN CLEANUP START ====');
      developer.log('Preparing clean state for new user login...');

      // Perform comprehensive pre-login cleanup
      await Future.wait([
        StorageUtils.preLoginCleanup(),
        SecureStorageUtils.preLoginCleanup(),
      ]);

      developer.log('==== PRE-LOGIN CLEANUP FINISHED ====');
      developer.log('Clean state prepared for new user');
    } catch (e) {
      developer.log('==== PRE-LOGIN CLEANUP ERROR ====');
      developer.log('Error during pre-login cleanup: $e', error: e);

      // Continue with login even if cleanup fails
      developer.log('Continuing with login despite cleanup errors');
    }
  }

  /// Reset all providers to initial state
  static Future<void> resetAllProviders(Ref ref) async {
    try {
      developer.log('Resetting all providers to initial state...');

      // Reset auth provider
      try {
        final authNotifier = ref.read(authProvider.notifier);
        authNotifier.clearError();
        developer.log('Auth provider reset');
      } catch (e) {
        developer.log('Error resetting auth provider: $e', error: e);
      }

      // Reset user provider
      try {
        final userNotifier = ref.read(userProvider.notifier);
        userNotifier.resetForNewUser();
        developer.log('User provider reset');
      } catch (e) {
        developer.log('Error resetting user provider: $e', error: e);
      }

      // Reset investment provider
      try {
        final investmentNotifier = ref.read(investmentProvider.notifier);
        investmentNotifier.resetForNewUser();
        developer.log('Investment provider reset');
      } catch (e) {
        developer.log('Error resetting investment provider: $e', error: e);
      }

      developer.log('All providers reset successfully');
    } catch (e) {
      developer.log('Error resetting providers: $e', error: e);
    }
  }

  /// Logout with complete session cleanup and provider reset
  static Future<Map<String, dynamic>> logout(Ref ref) async {
    try {
      developer.log('==== LOGOUT WITH SESSION CLEANUP START ====');

      // Step 1: Clear complete session
      await clearCompleteSession();

      // Step 2: Reset all providers
      await resetAllProviders(ref);

      developer.log('==== LOGOUT WITH SESSION CLEANUP COMPLETE ====');

      return {
        'success': true,
        'message': 'Logged out successfully - complete session cleared',
      };
    } catch (e) {
      developer.log('==== LOGOUT ERROR ====');
      developer.log('Error during logout with session cleanup: $e', error: e);

      return {
        'success': false,
        'error':
            'Logout completed with errors. Please restart the app if issues persist.',
      };
    }
  }

  /// Login with pre-cleanup and fresh data initialization
  static Future<Map<String, dynamic>> login({
    required Ref ref,
    required String username,
    required String password,
    required Future<Map<String, dynamic>> Function(String, String)
    loginFunction,
  }) async {
    try {
      developer.log('==== LOGIN WITH SESSION MANAGEMENT START ====');
      developer.log('Starting login with session management for: $username');

      // Step 1: Pre-login cleanup
      await preLoginCleanup();

      // Step 2: Reset all providers before login
      await resetAllProviders(ref);

      // Step 3: Perform actual login
      final loginResult = await loginFunction(username, password);

      if (loginResult['success'] == true) {
        developer.log('Login successful - initializing fresh user session');

        // Step 4: Initialize fresh data for new user
        await _initializeFreshUserSession(ref);

        developer.log('==== LOGIN WITH SESSION MANAGEMENT COMPLETE ====');
      } else if (loginResult['requires_verification'] == true) {
        developer.log(
          'Login requires email verification: ${loginResult['email']}',
        );

        // Return the verification requirement without session initialization
        return {
          'success': false,
          'requires_verification': true,
          'email': loginResult['email'],
          'message': loginResult['message'],
          'error': loginResult['error'],
        };
      } else {
        developer.log('Login failed: ${loginResult['error']}');
      }

      return loginResult;
    } catch (e) {
      developer.log('==== LOGIN ERROR ====');
      developer.log('Error during login with session management: $e', error: e);

      return {
        'success': false,
        'error': 'Login failed due to session management error',
      };
    }
  }

  /// Initialize fresh user session after successful login
  static Future<void> _initializeFreshUserSession(Ref ref) async {
    try {
      developer.log('Initializing fresh user session...');

      // Initialize investment data for new user
      try {
        final investmentNotifier = ref.read(investmentProvider.notifier);
        await investmentNotifier.refreshInvestmentData();
        developer.log('Investment data initialized for new user');
      } catch (e) {
        developer.log('Error initializing investment data: $e', error: e);
      }

      // Refresh user profile data
      try {
        final userNotifier = ref.read(userProvider.notifier);
        await userNotifier.refreshUserData();
        developer.log('User profile data refreshed');
      } catch (e) {
        developer.log('Error refreshing user data: $e', error: e);
      }

      developer.log('Fresh user session initialized successfully');
    } catch (e) {
      developer.log('Error initializing fresh user session: $e', error: e);
    }
  }

  /// Fallback cleanup when normal cleanup fails
  static Future<void> _fallbackCleanup() async {
    try {
      developer.log('Performing fallback cleanup...');

      await Future.wait([
        StorageUtils.clearAll(),
        SecureStorageUtils.deleteAll(),
      ]);

      developer.log('Fallback cleanup completed');
    } catch (e) {
      developer.log('Fallback cleanup failed: $e', error: e);
      rethrow;
    }
  }

  /// Check if session is clean (no residual data)
  static Future<bool> isSessionClean() async {
    try {
      final hasUserEmail = await StorageUtils.getUserEmail() != null;
      final hasAccessToken = await StorageUtils.getAccessToken() != null;
      final hasSecureToken = await SecureStorageUtils.getAccessToken() != null;

      final isClean = !hasUserEmail && !hasAccessToken && !hasSecureToken;

      developer.log('Session clean check: $isClean');
      return isClean;
    } catch (e) {
      developer.log('Error checking session cleanliness: $e', error: e);
      return false;
    }
  }

  /// Verify session isolation between users
  static Future<Map<String, dynamic>> verifySessionIsolation({
    required String currentUserEmail,
  }) async {
    try {
      developer.log('Verifying session isolation for: $currentUserEmail');

      final storedEmail = await StorageUtils.getUserEmail();
      final isIsolated = storedEmail == currentUserEmail;

      if (!isIsolated) {
        developer.log('Session isolation violation detected!');
        developer.log('Expected: $currentUserEmail, Found: $storedEmail');

        return {
          'isolated': false,
          'error': 'Session data from previous user detected',
          'expected': currentUserEmail,
          'found': storedEmail,
        };
      }

      developer.log('Session isolation verified successfully');
      return {'isolated': true, 'message': 'Session properly isolated'};
    } catch (e) {
      developer.log('Error verifying session isolation: $e', error: e);
      return {'isolated': false, 'error': 'Failed to verify session isolation'};
    }
  }
}
