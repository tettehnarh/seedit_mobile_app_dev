import 'dart:developer' as developer;
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/storage_utils.dart';
import '../../../core/utils/secure_storage_utils.dart';

/// Service for handling authentication-related API calls
class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Pre-login cleanup to ensure clean state
  Future<void> _preLoginCleanup() async {
    try {
      developer.log('Performing pre-login cleanup...');

      await Future.wait([
        StorageUtils.preLoginCleanup(),
        SecureStorageUtils.preLoginCleanup(),
      ]);

      developer.log('Pre-login cleanup completed');
    } catch (e) {
      developer.log('Error during pre-login cleanup: $e', error: e);
      // Continue with login even if cleanup fails
    }
  }

  /// Login user
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      developer.log('==== LOGIN ATTEMPT START ====');
      developer.log('Attempting login for user: $username');

      // Perform pre-login cleanup to ensure clean state
      await _preLoginCleanup();

      // Normalize the username (email) by trimming whitespace
      final normalizedUsername = username.trim();
      if (normalizedUsername != username) {
        developer.log(
          'Username was trimmed from "$username" to "$normalizedUsername"',
        );
      }

      developer.log(
        'Making login request to ${ApiConstants.loginEndpoint} endpoint',
      );
      final response = await _apiClient.post(ApiConstants.loginEndpoint, {
        'username': normalizedUsername,
        'password': password,
      });

      developer.log('Login response received: $response');

      // Check if login is successful - Django returns token and user on success
      if (response['token'] != null && response['user'] != null) {
        developer.log('Login successful, saving tokens and user info');

        // Save Django token
        await StorageUtils.setAccessToken(response['token']);
        developer.log('Token saved: ${response['token']}');

        // Extract user info from Django response
        final user = response['user'];
        await StorageUtils.setUserEmail(normalizedUsername);
        await StorageUtils.setLoggedIn(true);

        // Set current user email in secure storage
        await SecureStorageUtils.write(
          'current_user_email',
          normalizedUsername,
        );
        developer.log('Current user email set: $normalizedUsername');

        // Store email verification status from Django user object
        final isEmailVerified = user['is_email_verified'] ?? false;
        await StorageUtils.setBool('email_verified', isEmailVerified);
        developer.log('Email verification status saved: $isEmailVerified');

        // Save user name from Django user object
        final firstName = user['first_name'] ?? '';
        final lastName = user['last_name'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        final username = user['username'] ?? '';

        // Priority: username from backend > full name > email prefix
        final displayName = username.isNotEmpty
            ? username
            : (fullName.isNotEmpty
                  ? fullName
                  : normalizedUsername.split('@')[0]);
        await StorageUtils.setString('user_name', displayName);
        developer.log(
          'Display name saved: $displayName (from ${username.isNotEmpty
              ? 'username'
              : fullName.isNotEmpty
              ? 'full name'
              : 'email prefix'})',
        );

        // Save user ID
        if (user['id'] != null) {
          await StorageUtils.setString('user_id', user['id'].toString());
          developer.log('User ID saved: ${user['id']}');
        }

        // Save KYC status
        if (user['kyc_status'] != null) {
          await StorageUtils.setString('kyc_status', user['kyc_status']);
          developer.log('KYC status saved: ${user['kyc_status']}');
        }

        // Check for forced password change requirement
        final requiresPasswordChange =
            user['requires_password_change'] ?? false;
        if (requiresPasswordChange) {
          developer.log('==== USER REQUIRES PASSWORD CHANGE ====');
          developer.log('User must change password before continuing');
        }

        // Return success response with password change flag
        return {
          'success': true,
          'token': response['token'],
          'user': user,
          'requires_password_change': requiresPasswordChange,
        };
      } else if (response['requires_verification'] == true) {
        // Handle unverified email case
        developer.log('==== LOGIN REQUIRES EMAIL VERIFICATION ====');
        developer.log('User email not verified: ${response['email']}');

        return {
          'success': false,
          'requires_verification': true,
          'email': response['email'],
          'message':
              response['message'] ?? 'Please verify your email to continue',
          'error': response['error'] ?? 'Email verification required',
        };
      } else {
        // Handle login failure - check for error message
        final errorMsg = response['error'] ?? 'Invalid credentials';
        developer.log('Login failed: $errorMsg');
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      developer.log('==== LOGIN ERROR START ====');
      developer.log('Login error: $e', error: e);

      // Special handling for authentication errors
      if (e is UnauthorizedException) {
        return {
          'success': false,
          'error': 'Invalid email or password. Please try again.',
        };
      } else if (e is BadRequestException) {
        return {
          'success': false,
          'error': 'Invalid request. Please check your input.',
        };
      }

      developer.log('==== LOGIN ERROR END ====');

      if (e is ApiException) {
        return {'success': false, 'error': e.message};
      }

      return {
        'success': false,
        'error': 'An error occurred. Please try again.',
      };
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await StorageUtils.isLoggedIn();
  }

  /// Check if the current user's email is verified
  Future<bool> isEmailVerified() async {
    try {
      // For now, assume email is verified for simplicity
      return await StorageUtils.getBool('email_verified', defaultValue: true);
    } catch (e) {
      developer.log('Error checking email verification status: $e', error: e);
      return true; // Default to true to prevent blocking
    }
  }

  /// Logout user and clear all stored data
  Future<Map<String, dynamic>> logout() async {
    try {
      developer.log('==== LOGOUT PROCESS START ====');
      developer.log('Starting complete logout process...');

      // Try to call backend logout endpoint
      try {
        await _apiClient.postWithAuth(ApiConstants.logoutEndpoint, {});
        developer.log('Backend logout successful');
      } catch (e) {
        developer.log(
          'Backend logout failed (continuing with local logout): $e',
        );
      }

      // Perform complete session cleanup
      await Future.wait([
        StorageUtils.clearCompleteSession(),
        SecureStorageUtils.clearCompleteSession(),
      ]);

      developer.log('==== LOGOUT PROCESS COMPLETE ====');
      developer.log('Complete session cleanup finished');

      return {
        'success': true,
        'message': 'Logged out successfully - all user data cleared',
      };
    } catch (e) {
      developer.log('==== LOGOUT ERROR ====');
      developer.log('Error during logout: $e', error: e);

      // Fallback: try nuclear cleanup
      try {
        await Future.wait([
          StorageUtils.clearAll(),
          SecureStorageUtils.deleteAll(),
        ]);
        developer.log('Fallback cleanup completed');

        return {
          'success': true,
          'message': 'Logged out successfully (fallback cleanup)',
        };
      } catch (fallbackError) {
        developer.log(
          'Fallback cleanup failed: $fallbackError',
          error: fallbackError,
        );

        return {
          'success': false,
          'error': 'Failed to logout completely. Please restart the app.',
        };
      }
    }
  }

  /// Get user profile information
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      developer.log('🔄 [AUTH_SERVICE] Fetching user profile from backend...');

      // Check if user is logged in
      final isUserLoggedIn = await isLoggedIn();
      if (!isUserLoggedIn) {
        throw const UnauthorizedException('User is not logged in');
      }

      // Call the backend API to get user profile
      final response = await _apiClient.get(ApiConstants.userProfileEndpoint);

      developer.log('✅ [AUTH_SERVICE] User profile fetched successfully');
      developer.log('📦 [AUTH_SERVICE] Profile data: $response');

      return {'success': true, 'data': response};
    } catch (e) {
      developer.log(
        '❌ [AUTH_SERVICE] Error fetching user profile: $e',
        error: e,
      );

      // Fallback to locally stored information if API fails
      try {
        final email = await StorageUtils.getUserEmail();
        final name = await StorageUtils.getString('user_name');
        final phone = await StorageUtils.getString('user_phone');
        final userId = await StorageUtils.getString('user_id');
        final kycStatus = await StorageUtils.getString('kyc_status');

        if (email != null && userId != null) {
          developer.log('🔄 [AUTH_SERVICE] Using cached user data as fallback');

          return {
            'success': true,
            'data': {
              'id': userId,
              'email': email,
              'username': name ?? email.split('@')[0],
              'first_name': name?.split(' ').first ?? '',
              'last_name': name?.split(' ').skip(1).join(' ') ?? '',
              'phone_number': phone,
              'kyc_status': kycStatus ?? 'not_started',
              'is_email_verified': true,
              'role': 'user',
              'cached': true,
            },
          };
        }
      } catch (fallbackError) {
        developer.log('❌ [AUTH_SERVICE] Fallback also failed: $fallbackError');
      }

      if (e is ApiException) {
        return {'success': false, 'error': e.message};
      }

      return {'success': false, 'error': 'Failed to get user profile'};
    }
  }

  /// Register new user (creates inactive account, sends verification email)
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      developer.log('🔄 [AUTH_SERVICE] === REGISTRATION DEBUG START ===');

      developer.log(
        '🔍 [AUTH_SERVICE] Attempting registration for user: ${userData['email']}',
      );

      // Log all registration data (excluding password)
      final logData = Map<String, dynamic>.from(userData);
      if (logData.containsKey('password')) {
        logData['password'] = '*' * (logData['password']?.length ?? 0);
      }
      developer.log('🔍 [AUTH_SERVICE] Registration data: $logData');

      // Validate required fields before sending
      final requiredFields = ['email', 'username', 'password'];
      final missingFields = <String>[];

      for (final field in requiredFields) {
        if (!userData.containsKey(field) ||
            userData[field] == null ||
            userData[field].toString().trim().isEmpty) {
          missingFields.add(field);
        }
      }

      if (missingFields.isNotEmpty) {
        final errorMsg = 'Missing required fields: ${missingFields.join(', ')}';
        developer.log('❌ [AUTH_SERVICE] Validation failed: $errorMsg');
        return {'success': false, 'error': errorMsg};
      }

      final response = await _apiClient.post('auth/register/', userData);

      if (response['message'] != null &&
          response['requires_verification'] == true) {
        final successResponse = {
          'success': true,
          'requires_verification': true,
          'email': response['email'],
          'user_id': response['user_id'],
          'message': response['message'],
        };

        return successResponse;
      } else if (response['token'] != null && response['user'] != null) {
        // Fallback for immediate registration (if verification is disabled)
        final immediateResponse = {
          'success': true,
          'token': response['token'],
          'user': response['user'],
        };

        return immediateResponse;
      } else {
        // Extract clean error message from backend response
        final rawErrorMsg = response['error'];
        final cleanErrorMsg =
            _extractCleanErrorMessage(rawErrorMsg) ?? 'Registration failed';

        final errorResponse = {'success': false, 'error': cleanErrorMsg};

        return errorResponse;
      }
    } catch (e) {
      String rawErrorMessage;
      String cleanErrorMessage;

      if (e is ApiException) {
        rawErrorMessage = e.message;
        cleanErrorMessage =
            _extractCleanErrorMessage(rawErrorMessage) ?? 'Registration failed';
      } else {
        rawErrorMessage = e.toString();
        cleanErrorMessage =
            'An error occurred during registration. Please try again.';
      }

      final exceptionResponse = {'success': false, 'error': cleanErrorMessage};
      developer.log(
        '❌ [AUTH_SERVICE] === REGISTRATION EXCEPTION DEBUG END ===',
      );

      return exceptionResponse;
    }
  }

  /// Verify email with PIN
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String pin,
  }) async {
    try {
      developer.log('==== EMAIL VERIFICATION START ====');
      developer.log('Verifying email: $email with PIN: $pin');

      final response = await _apiClient.post('auth/verify-email/', {
        'email': email,
        'pin': pin,
      });

      developer.log('Email verification response: $response');

      if (response['token'] != null && response['user'] != null) {
        developer.log('Email verification successful');

        // Store tokens
        await StorageUtils.setAccessToken(response['token']);
        await SecureStorageUtils.setAccessToken(response['token']);
        await StorageUtils.setUserEmail(response['user']['email']);
        await StorageUtils.setLoggedIn(true);

        // Store user data using same logic as login
        final user = response['user'];
        final firstName = user['first_name'] ?? '';
        final lastName = user['last_name'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        final username = user['username'] ?? '';

        // Priority: username from backend > full name > email prefix
        final displayName = username.isNotEmpty
            ? username
            : (fullName.isNotEmpty ? fullName : email.split('@')[0]);
        await StorageUtils.setString('user_name', displayName);

        // Store other user data
        if (user['id'] != null) {
          await StorageUtils.setString('user_id', user['id'].toString());
        }
        if (user['kyc_status'] != null) {
          await StorageUtils.setString('kyc_status', user['kyc_status']);
        }
        await StorageUtils.setBool('email_verified', true);

        return {
          'success': true,
          'token': response['token'],
          'user': response['user'],
          'message': response['message'] ?? 'Email verified successfully',
        };
      } else {
        final rawErrorMsg = response['error'];
        final cleanErrorMsg =
            _extractCleanErrorMessage(rawErrorMsg) ??
            'Email verification failed';
        developer.log('Email verification failed: $rawErrorMsg');
        developer.log('Clean error message: $cleanErrorMsg');
        return {'success': false, 'error': cleanErrorMsg};
      }
    } catch (e) {
      developer.log('Email verification error: $e', error: e);

      String cleanErrorMsg;
      if (e is ApiException) {
        cleanErrorMsg =
            _extractCleanErrorMessage(e.message) ?? 'Email verification failed';
      } else {
        cleanErrorMsg =
            'An error occurred during email verification. Please try again.';
      }

      return {'success': false, 'error': cleanErrorMsg};
    }
  }

  /// Resend verification email
  Future<Map<String, dynamic>> resendVerificationEmail(String email) async {
    try {
      developer.log('==== RESEND VERIFICATION START ====');
      developer.log('Resending verification email to: $email');

      final response = await _apiClient.post('auth/resend-verification/', {
        'email': email,
      });

      developer.log('Resend verification response: $response');

      if (response['message'] != null) {
        return {'success': true, 'message': response['message']};
      } else {
        final errorMsg =
            response['error'] ?? 'Failed to resend verification email';
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      developer.log('Resend verification error: $e', error: e);

      if (e is ApiException) {
        return {'success': false, 'error': e.message};
      }

      return {
        'success': false,
        'error': 'An error occurred. Please try again.',
      };
    }
  }

  /// Check username availability
  Future<Map<String, dynamic>> checkUsernameAvailability(
    String username,
  ) async {
    try {
      developer.log('Checking username availability: $username');

      final response = await _apiClient.post('auth/check-username/', {
        'username': username,
      });

      developer.log('Username check response: $response');
      return response;
    } catch (e) {
      developer.log('Username check error: $e', error: e);

      if (e is ApiException) {
        return {'available': false, 'error': e.message};
      }

      return {
        'available': false,
        'error': 'Failed to check username availability',
      };
    }
  }

  /// Send forgot password request
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      developer.log('Sending forgot password request for: $email');

      final response = await _apiClient.post('auth/forgot-password/', {
        'email': email,
      });

      developer.log('Forgot password response: $response');

      if (response['message'] != null) {
        return {'success': true, 'message': response['message']};
      } else {
        final errorMsg = response['error'] ?? 'Failed to send reset email';
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      developer.log('Forgot password error: $e', error: e);

      if (e is ApiException) {
        return {'success': false, 'error': e.message};
      }

      return {
        'success': false,
        'error': 'An error occurred. Please try again.',
      };
    }
  }

  /// Reset password with PIN
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String pin,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      developer.log('Resetting password for: $email');

      final response = await _apiClient.post('auth/reset-password/', {
        'email': email,
        'pin': pin,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      });

      developer.log('Reset password response: $response');

      if (response['message'] != null) {
        return {'success': true, 'message': response['message']};
      } else {
        final errorMsg = response['error'] ?? 'Failed to reset password';
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      developer.log('Reset password error: $e', error: e);

      if (e is ApiException) {
        return {'success': false, 'error': e.message};
      }

      return {
        'success': false,
        'error': 'An error occurred. Please try again.',
      };
    }
  }

  /// Extract clean error message from raw error response
  String? _extractCleanErrorMessage(dynamic rawError) {
    if (rawError == null) return null;

    final errorString = rawError.toString().trim();
    if (errorString.isEmpty) return null;

    // Remove common prefixes that add noise
    final prefixesToRemove = [
      'Registration failed: ',
      'Error: ',
      'Failed: ',
      'Exception: ',
      'API Error: ',
      'Server Error: ',
    ];

    String cleanError = errorString;
    for (final prefix in prefixesToRemove) {
      if (cleanError.startsWith(prefix)) {
        cleanError = cleanError.substring(prefix.length);
        break;
      }
    }

    // Remove common suffixes that add noise
    final suffixesToRemove = [
      '. Please try again.',
      '. Please try again',
      ' Please try again.',
      ' Please try again',
    ];

    for (final suffix in suffixesToRemove) {
      if (cleanError.endsWith(suffix)) {
        cleanError = cleanError.substring(0, cleanError.length - suffix.length);
        break;
      }
    }

    // Ensure the error message is properly capitalized and ends with a period
    if (cleanError.isNotEmpty) {
      cleanError = cleanError[0].toUpperCase() + cleanError.substring(1);
      if (!cleanError.endsWith('.') &&
          !cleanError.endsWith('!') &&
          !cleanError.endsWith('?')) {
        cleanError += '.';
      }
    }

    return cleanError.isNotEmpty ? cleanError : null;
  }

  /// Verify password reset OTP
  Future<Map<String, dynamic>> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      developer.log('==== PASSWORD RESET OTP VERIFICATION START ====');
      developer.log('Verifying OTP for email: $email');

      final response = await _apiClient.post(
        ApiConstants.verifyPasswordResetOtpEndpoint,
        {'email': email.trim(), 'otp': otp.trim()},
      );

      developer.log('OTP verification response: $response');

      if (response['success'] == true || response['message'] != null) {
        developer.log('OTP verification successful');
        return {
          'success': true,
          'message': response['message'] ?? 'OTP verified successfully',
        };
      } else {
        final errorMessage = response['error'] ?? 'Invalid or expired OTP';
        developer.log('OTP verification failed: $errorMessage');
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      developer.log('OTP verification error: $e', error: e);
      return {
        'success': false,
        'error':
            _extractCleanErrorMessage(e.toString()) ?? 'Failed to verify OTP',
      };
    }
  }

  /// Reset password with OTP (new flow)
  Future<Map<String, dynamic>> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      developer.log('==== PASSWORD RESET START ====');
      developer.log('Resetting password for email: $email');

      final response = await _apiClient.post(
        ApiConstants.resetPasswordEndpoint,
        {
          'email': email.trim(),
          'pin': otp.trim(), // Backend expects 'pin' field
          'new_password': newPassword,
        },
      );

      developer.log('Password reset response: $response');

      if (response['success'] == true || response['message'] != null) {
        developer.log('Password reset successful');

        // Clear all stored tokens and user data for security
        await _performSecurityLogout();

        return {
          'success': true,
          'message': response['message'] ?? 'Password reset successfully',
        };
      } else {
        final errorMessage = response['error'] ?? 'Failed to reset password';
        developer.log('Password reset failed: $errorMessage');
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      developer.log('Password reset error: $e', error: e);
      return {
        'success': false,
        'error':
            _extractCleanErrorMessage(e.toString()) ??
            'Failed to reset password',
      };
    }
  }

  /// Perform security logout after password reset
  Future<void> _performSecurityLogout() async {
    try {
      developer.log('Performing security logout after password reset...');

      // Clear all stored authentication data
      await Future.wait([
        StorageUtils.clearAll(),
        SecureStorageUtils.deleteAll(),
      ]);

      developer.log('Security logout completed');
    } catch (e) {
      developer.log('Error during security logout: $e', error: e);
      // Continue even if cleanup fails
    }
  }

  /// Get the API client instance
  ApiClient getApiClient() {
    return _apiClient;
  }

  /// Dispose resources
  void dispose() {
    _apiClient.dispose();
  }
}
