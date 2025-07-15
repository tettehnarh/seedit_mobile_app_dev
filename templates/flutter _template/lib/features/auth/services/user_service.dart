import 'dart:developer' as developer;
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/storage_utils.dart';
import '../models/user_model.dart';

/// Service for handling user profile-related API calls
class UserService {
  final ApiClient _apiClient = ApiClient();

  /// Get user profile from backend
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      developer.log('Fetching user profile from backend');
      
      final response = await _apiClient.get(ApiConstants.userProfileEndpoint);
      
      // Cache user data locally
      if (response['email'] != null) {
        await StorageUtils.setUserEmail(response['email']);
      }
      
      if (response['username'] != null) {
        await StorageUtils.setString('user_name', response['username']);
      }
      
      if (response['id'] != null) {
        await StorageUtils.setString('user_id', response['id'].toString());
      }
      
      if (response['kyc_status'] != null) {
        await StorageUtils.setString('kyc_status', response['kyc_status']);
      }
      
      if (response['phone_number'] != null) {
        await StorageUtils.setString('user_phone', response['phone_number']);
      }
      
      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      developer.log('Error fetching user profile: $e', error: e);
      
      // Return cached data if API fails
      final cachedEmail = await StorageUtils.getUserEmail();
      if (cachedEmail != null) {
        final cachedData = {
          'email': cachedEmail,
          'username': await StorageUtils.getString('user_name') ?? cachedEmail.split('@')[0],
          'id': await StorageUtils.getString('user_id'),
          'kyc_status': await StorageUtils.getString('kyc_status') ?? 'pending',
          'phone_number': await StorageUtils.getString('user_phone'),
          'cached': true,
        };
        
        return {
          'success': true,
          'data': cachedData,
        };
      }
      
      if (e is ApiException) {
        return {
          'success': false,
          'error': e.message,
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to fetch user profile. Please try again.',
      };
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      developer.log('Updating user profile');
      
      final response = await _apiClient.putWithAuth(
        ApiConstants.updateProfileEndpoint,
        profileData,
      );
      
      // Update cached data
      if (response['email'] != null) {
        await StorageUtils.setUserEmail(response['email']);
      }
      
      if (response['username'] != null) {
        await StorageUtils.setString('user_name', response['username']);
      }
      
      if (response['phone_number'] != null) {
        await StorageUtils.setString('user_phone', response['phone_number']);
      }
      
      return {
        'success': true,
        'data': response,
        'message': 'Profile updated successfully',
      };
    } catch (e) {
      developer.log('Error updating user profile: $e', error: e);
      
      if (e is ApiException) {
        return {
          'success': false,
          'error': e.message,
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to update profile. Please try again.',
      };
    }
  }

  /// Change user password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      developer.log('Changing user password');
      
      final response = await _apiClient.postWithAuth(
        ApiConstants.changePasswordEndpoint,
        {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
      
      return {
        'success': true,
        'data': response,
        'message': 'Password changed successfully',
      };
    } catch (e) {
      developer.log('Error changing password: $e', error: e);
      
      if (e is ApiException) {
        return {
          'success': false,
          'error': e.message,
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to change password. Please try again.',
      };
    }
  }

  /// Get user model from cached or API data
  Future<UserModel?> getCurrentUser() async {
    try {
      final profileResult = await getUserProfile();
      
      if (profileResult['success'] == true) {
        final userData = profileResult['data'];
        return UserModel.fromJson(userData);
      }
      
      return null;
    } catch (e) {
      developer.log('Error getting current user: $e', error: e);
      return null;
    }
  }

  /// Refresh user data from backend
  Future<Map<String, dynamic>> refreshUserData() async {
    try {
      developer.log('Refreshing user data from backend');
      
      // Clear cached data first
      await StorageUtils.remove('user_name');
      await StorageUtils.remove('user_id');
      await StorageUtils.remove('kyc_status');
      await StorageUtils.remove('user_phone');
      
      // Fetch fresh data
      return await getUserProfile();
    } catch (e) {
      developer.log('Error refreshing user data: $e', error: e);
      
      if (e is ApiException) {
        return {
          'success': false,
          'error': e.message,
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to refresh user data. Please try again.',
      };
    }
  }

  /// Sync user data with backend (for offline support)
  Future<Map<String, dynamic>> syncUserData() async {
    try {
      developer.log('Syncing user data with backend');
      
      // Get cached data
      final cachedEmail = await StorageUtils.getUserEmail();
      final cachedName = await StorageUtils.getString('user_name');
      final cachedPhone = await StorageUtils.getString('user_phone');
      
      if (cachedEmail == null) {
        return {
          'success': false,
          'error': 'No cached user data found',
        };
      }
      
      // Try to sync with backend
      final profileResult = await getUserProfile();
      
      if (profileResult['success'] == true) {
        return {
          'success': true,
          'message': 'User data synced successfully',
          'data': profileResult['data'],
        };
      } else {
        // Return cached data if sync fails
        return {
          'success': true,
          'message': 'Using cached user data',
          'data': {
            'email': cachedEmail,
            'username': cachedName ?? cachedEmail.split('@')[0],
            'phone_number': cachedPhone,
            'cached': true,
          },
        };
      }
    } catch (e) {
      developer.log('Error syncing user data: $e', error: e);
      
      // Return cached data as fallback
      final cachedEmail = await StorageUtils.getUserEmail();
      if (cachedEmail != null) {
        return {
          'success': true,
          'message': 'Using cached user data (sync failed)',
          'data': {
            'email': cachedEmail,
            'username': await StorageUtils.getString('user_name') ?? cachedEmail.split('@')[0],
            'phone_number': await StorageUtils.getString('user_phone'),
            'cached': true,
          },
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to sync user data and no cached data available',
      };
    }
  }

  /// Check if user data is cached
  Future<bool> hasUserDataCached() async {
    final email = await StorageUtils.getUserEmail();
    return email != null;
  }

  /// Clear all user data
  Future<void> clearUserData() async {
    try {
      await StorageUtils.clearAuthData();
      developer.log('User data cleared successfully');
    } catch (e) {
      developer.log('Error clearing user data: $e', error: e);
    }
  }

  /// Dispose resources
  void dispose() {
    _apiClient.dispose();
  }
}
