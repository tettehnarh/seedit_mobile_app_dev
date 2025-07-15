import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/api_exceptions.dart';
import '../../../core/utils/storage_utils.dart';

class SettingsService {
  final ApiClient _apiClient = ApiClient();

  /// Change user password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      developer.log('🔐 [SETTINGS_SERVICE] Changing password...');

      await _apiClient.postWithAuth(ApiConstants.changePasswordEndpoint, {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      });

      developer.log('✅ [SETTINGS_SERVICE] Password changed successfully');
    } catch (e) {
      developer.log(
        '❌ [SETTINGS_SERVICE] Error changing password: $e',
        error: e,
      );

      if (e is ApiException) {
        throw e.message;
      }
      throw 'Failed to change password. Please try again.';
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? address,
    String? city,
    String? country,
    DateTime? dateOfBirth,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
  }) async {
    try {
      developer.log('👤 [SETTINGS_SERVICE] Updating profile...');

      final data = <String, dynamic>{};

      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;
      if (address != null) data['address'] = address;
      if (city != null) data['city'] = city;
      if (country != null) data['country'] = country;
      if (dateOfBirth != null) {
        data['date_of_birth'] = dateOfBirth.toIso8601String();
      }
      if (emailNotifications != null) {
        data['email_notifications'] = emailNotifications;
      }
      if (pushNotifications != null) {
        data['push_notifications'] = pushNotifications;
      }
      if (smsNotifications != null) {
        data['sms_notifications'] = smsNotifications;
      }

      final response = await _apiClient.putWithAuth(
        ApiConstants.updateProfileEndpoint,
        data,
      );

      developer.log('✅ [SETTINGS_SERVICE] Profile updated successfully');
      return response;
    } catch (e) {
      developer.log(
        '❌ [SETTINGS_SERVICE] Error updating profile: $e',
        error: e,
      );

      if (e is ApiException) {
        throw e.message;
      }
      throw 'Failed to update profile. Please try again.';
    }
  }

  /// Get notification preferences
  Future<Map<String, dynamic>> getNotificationPreferences() async {
    try {
      developer.log(
        '🔔 [SETTINGS_SERVICE] Getting notification preferences...',
      );

      final response = await _apiClient.get(
        ApiConstants.notificationPreferencesEndpoint,
      );

      developer.log('✅ [SETTINGS_SERVICE] Notification preferences retrieved');
      return response;
    } catch (e) {
      developer.log(
        '❌ [SETTINGS_SERVICE] Error getting notification preferences: $e',
        error: e,
      );

      if (e is ApiException) {
        throw e.message;
      }
      throw 'Failed to get notification preferences. Please try again.';
    }
  }

  /// Update notification preferences
  Future<Map<String, dynamic>> updateNotificationPreferences({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? marketingEmails,
    bool? securityAlerts,
    bool? transactionNotifications,
  }) async {
    try {
      developer.log(
        '🔔 [SETTINGS_SERVICE] Updating notification preferences...',
      );

      final data = <String, dynamic>{};

      if (emailNotifications != null) {
        data['email_notifications_enabled'] = emailNotifications;
      }
      if (pushNotifications != null) {
        data['push_notifications_enabled'] = pushNotifications;
      }
      if (smsNotifications != null) {
        data['sms_notifications_enabled'] = smsNotifications;
      }
      if (marketingEmails != null) {
        data['investment_notifications'] = marketingEmails;
      }
      if (securityAlerts != null) {
        data['system_notifications'] = securityAlerts;
      }
      if (transactionNotifications != null) {
        data['payment_notifications'] = transactionNotifications;
      }

      final response = await _apiClient.patchWithAuth(
        ApiConstants.notificationPreferencesEndpoint,
        data,
      );

      developer.log('✅ [SETTINGS_SERVICE] Notification preferences updated');
      return response;
    } catch (e) {
      developer.log(
        '❌ [SETTINGS_SERVICE] Error updating notification preferences: $e',
        error: e,
      );

      if (e is ApiException) {
        throw e.message;
      }
      throw 'Failed to update notification preferences. Please try again.';
    }
  }

  /// Create support ticket
  Future<Map<String, dynamic>> createSupportTicket({
    required String subject,
    required String message,
    String? category,
    String? priority,
  }) async {
    try {
      developer.log('🎫 [SETTINGS_SERVICE] Creating support ticket...');

      final response = await _apiClient
          .postWithAuth(ApiConstants.supportTicketsEndpoint, {
            'subject': subject,
            'message': message,
            'category': category ?? 'general',
            'priority': priority ?? 'medium',
          });

      developer.log('✅ [SETTINGS_SERVICE] Support ticket created successfully');
      return response;
    } catch (e) {
      developer.log(
        '❌ [SETTINGS_SERVICE] Error creating support ticket: $e',
        error: e,
      );

      if (e is ApiException) {
        throw e.message;
      }
      throw 'Failed to create support ticket. Please try again.';
    }
  }

  /// Get FAQ list
  Future<List<Map<String, dynamic>>> getFAQs() async {
    try {
      developer.log('❓ [SETTINGS_SERVICE] Getting FAQs...');

      final response = await _apiClient.get(ApiConstants.faqEndpoint);

      developer.log('✅ [SETTINGS_SERVICE] FAQs retrieved successfully');

      // Handle paginated response
      if (response is Map<String, dynamic> && response.containsKey('results')) {
        return List<Map<String, dynamic>>.from(response['results']);
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      developer.log('❌ [SETTINGS_SERVICE] Error getting FAQs: $e', error: e);

      if (e is ApiException) {
        throw e.message;
      }
      throw 'Failed to get FAQs. Please try again.';
    }
  }

  /// Get payment methods
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      developer.log('💳 [SETTINGS_SERVICE] Getting payment methods...');

      final response = await _apiClient.get(
        ApiConstants.paymentMethodsEndpoint,
      );

      developer.log(
        '✅ [SETTINGS_SERVICE] Payment methods retrieved successfully',
      );

      // Handle paginated response
      if (response is Map<String, dynamic> && response.containsKey('results')) {
        return List<Map<String, dynamic>>.from(response['results']);
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      developer.log(
        '❌ [SETTINGS_SERVICE] Error getting payment methods: $e',
        error: e,
      );

      if (e is ApiException) {
        throw e.message;
      }
      throw 'Failed to get payment methods. Please try again.';
    }
  }

  /// Upload profile picture
  Future<Map<String, dynamic>> uploadProfilePicture(File imageFile) async {
    try {
      developer.log('📸 [SETTINGS_SERVICE] Uploading profile picture...');

      // Get the access token
      final token = await StorageUtils.getAccessToken();
      if (token == null) {
        throw 'Authentication token not found';
      }

      // Create multipart request
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.updateProfileEndpoint}',
      );
      final request = http.MultipartRequest('PUT', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Token $token';

      // Add the image file
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'avatar',
        fileStream,
        fileLength,
        filename: 'profile_picture.jpg',
        contentType: MediaType('image', 'jpeg'),
      );

      request.files.add(multipartFile);

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      developer.log(
        '📸 [SETTINGS_SERVICE] Upload response status: ${response.statusCode}',
      );
      developer.log(
        '📸 [SETTINGS_SERVICE] Upload response body: ${response.body}',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        developer.log(
          '✅ [SETTINGS_SERVICE] Profile picture uploaded successfully',
        );
        return responseData;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['error'] ?? 'Failed to upload profile picture';
        developer.log('❌ [SETTINGS_SERVICE] Upload failed: $errorMessage');
        throw errorMessage;
      }
    } catch (e) {
      developer.log(
        '❌ [SETTINGS_SERVICE] Error uploading profile picture: $e',
        error: e,
      );

      if (e is ApiException) {
        throw e.message;
      }
      throw 'Failed to upload profile picture. Please try again.';
    }
  }
}
