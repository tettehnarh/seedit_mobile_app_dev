import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/user_model.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Sign up with email and password
  Future<AuthResponse> signUp(SignUpRequest request) async {
    try {
      final result = await Amplify.Auth.signUp(
        username: request.email,
        password: request.password,
        options: SignUpOptions(
          userAttributes: {
            AuthUserAttributeKey.email: request.email,
            AuthUserAttributeKey.givenName: request.firstName,
            AuthUserAttributeKey.familyName: request.lastName,
            AuthUserAttributeKey.phoneNumber: request.phoneNumber,
            const CognitoUserAttributeKey.custom('account_type'): 
                request.accountType.name,
          },
        ),
      );

      if (result.isSignUpComplete) {
        // Auto sign in after successful registration
        return await signIn(SignInRequest(
          email: request.email,
          password: request.password,
        ));
      } else {
        throw Exception('Sign up not complete. Please verify your email.');
      }
    } on AuthException catch (e) {
      debugPrint('Sign up error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected sign up error: $e');
      throw Exception('Failed to create account. Please try again.');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn(SignInRequest request) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: request.email,
        password: request.password,
      );

      if (result.isSignedIn) {
        final user = await getCurrentUser();
        final session = await Amplify.Auth.fetchAuthSession();
        
        if (session is CognitoAuthSession) {
          final authResponse = AuthResponse(
            user: user,
            accessToken: session.userPoolTokensResult.value.accessToken.raw,
            refreshToken: session.userPoolTokensResult.value.refreshToken!.raw,
            expiresAt: session.userPoolTokensResult.value.accessToken.expiresAt,
          );

          await _saveAuthData(authResponse);
          return authResponse;
        }
      }

      throw Exception('Sign in failed');
    } on AuthException catch (e) {
      debugPrint('Sign in error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected sign in error: $e');
      throw Exception('Failed to sign in. Please try again.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
      await _clearAuthData();
    } on AuthException catch (e) {
      debugPrint('Sign out error: ${e.message}');
      throw Exception('Failed to sign out. Please try again.');
    }
  }

  // Get current authenticated user
  Future<User> getCurrentUser() async {
    try {
      final authUser = await Amplify.Auth.getCurrentUser();
      final attributes = await Amplify.Auth.fetchUserAttributes();

      final attributeMap = {
        for (var attr in attributes) attr.userAttributeKey.key: attr.value
      };

      return User(
        id: authUser.userId,
        email: attributeMap['email'] ?? '',
        firstName: attributeMap['given_name'] ?? '',
        lastName: attributeMap['family_name'] ?? '',
        phoneNumber: attributeMap['phone_number'],
        kycStatus: _parseKycStatus(attributeMap['custom:kyc_status']),
        accountType: _parseAccountType(attributeMap['custom:account_type']),
        riskProfile: _parseRiskProfile(attributeMap['custom:risk_profile']),
        isEmailVerified: attributeMap['email_verified'] == 'true',
        isPhoneVerified: attributeMap['phone_number_verified'] == 'true',
        isMfaEnabled: false, // TODO: Get from user preferences
        createdAt: DateTime.now(), // TODO: Get from backend
        updatedAt: DateTime.now(), // TODO: Get from backend
      );
    } on AuthException catch (e) {
      debugPrint('Get current user error: ${e.message}');
      throw Exception('Failed to get user information.');
    }
  }

  // Check if user is signed in
  Future<bool> isSignedIn() async {
    try {
      final result = await Amplify.Auth.fetchAuthSession();
      return result.isSignedIn;
    } catch (e) {
      debugPrint('Check sign in status error: $e');
      return false;
    }
  }

  // Confirm sign up with verification code
  Future<void> confirmSignUp(String email, String confirmationCode) async {
    try {
      await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: confirmationCode,
      );
    } on AuthException catch (e) {
      debugPrint('Confirm sign up error: ${e.message}');
      throw _handleAuthException(e);
    }
  }

  // Resend confirmation code
  Future<void> resendSignUpCode(String email) async {
    try {
      await Amplify.Auth.resendSignUpCode(username: email);
    } on AuthException catch (e) {
      debugPrint('Resend code error: ${e.message}');
      throw _handleAuthException(e);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await Amplify.Auth.resetPassword(username: email);
    } on AuthException catch (e) {
      debugPrint('Reset password error: ${e.message}');
      throw _handleAuthException(e);
    }
  }

  // Confirm password reset
  Future<void> confirmResetPassword(
    String email,
    String newPassword,
    String confirmationCode,
  ) async {
    try {
      await Amplify.Auth.confirmResetPassword(
        username: email,
        newPassword: newPassword,
        confirmationCode: confirmationCode,
      );
    } on AuthException catch (e) {
      debugPrint('Confirm reset password error: ${e.message}');
      throw _handleAuthException(e);
    }
  }

  // Update password
  Future<void> updatePassword(String oldPassword, String newPassword) async {
    try {
      await Amplify.Auth.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } on AuthException catch (e) {
      debugPrint('Update password error: ${e.message}');
      throw _handleAuthException(e);
    }
  }

  // Private helper methods
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, authResponse.user.toJson().toString());
    await prefs.setString(_tokenKey, authResponse.accessToken);
    await prefs.setString(_refreshTokenKey, authResponse.refreshToken);
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  Exception _handleAuthException(AuthException e) {
    switch (e.runtimeType) {
      case UserNotConfirmedException:
        return Exception('Please verify your email address before signing in.');
      case NotAuthorizedException:
        return Exception('Invalid email or password.');
      case UserNotFoundException:
        return Exception('No account found with this email address.');
      case InvalidPasswordException:
        return Exception('Password does not meet requirements.');
      case UsernameExistsException:
        return Exception('An account with this email already exists.');
      case CodeMismatchException:
        return Exception('Invalid verification code.');
      case ExpiredCodeException:
        return Exception('Verification code has expired.');
      case LimitExceededException:
        return Exception('Too many attempts. Please try again later.');
      default:
        return Exception(e.message);
    }
  }

  KycStatus _parseKycStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'APPROVED':
        return KycStatus.approved;
      case 'REJECTED':
        return KycStatus.rejected;
      case 'UNDER_REVIEW':
        return KycStatus.underReview;
      default:
        return KycStatus.pending;
    }
  }

  AccountType _parseAccountType(String? type) {
    switch (type?.toUpperCase()) {
      case 'CORPORATE':
        return AccountType.corporate;
      default:
        return AccountType.individual;
    }
  }

  RiskProfile? _parseRiskProfile(String? profile) {
    switch (profile?.toUpperCase()) {
      case 'CONSERVATIVE':
        return RiskProfile.conservative;
      case 'MODERATE':
        return RiskProfile.moderate;
      case 'AGGRESSIVE':
        return RiskProfile.aggressive;
      default:
        return null;
    }
  }
}
