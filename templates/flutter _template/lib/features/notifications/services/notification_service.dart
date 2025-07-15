import '../models/notification_model.dart';
import '../../../core/api/api_client.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  // Get all notifications for the current user
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.get('notifications/');

      if (response is List) {
        return response
            .map((json) => _safeParseNotification(json))
            .where((notification) => notification != null)
            .cast<NotificationModel>()
            .toList();
      } else if (response is Map && response.containsKey('results')) {
        final List<dynamic> data = response['results'];
        return data
            .map((json) => _safeParseNotification(json))
            .where((notification) => notification != null)
            .cast<NotificationModel>()
            .toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      // Don't return mock data - let the UI handle empty state properly
      return [];
    }
  }

  // Safe parsing method to handle notifications without categories
  NotificationModel? _safeParseNotification(Map<String, dynamic> json) {
    try {
      return NotificationModel.fromJson(json);
    } catch (e) {
      // Try to create a basic notification with default category
      try {
        return NotificationModel(
          id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: json['title'] ?? 'Notification',
          message: json['message'] ?? 'You have a new notification',
          type: json['type'] ?? 'system',
          category: NotificationCategory.important, // Default category
          isRead: json['is_read'] ?? false,
          createdAt: json['created_at'] != null
              ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
              : DateTime.now(),
          data: json['data'],
        );
      } catch (e2) {
        return null; // Skip this notification if it can't be parsed
      }
    }
  }

  // Get important notifications only
  Future<List<NotificationModel>> getImportantNotifications() async {
    try {
      final response = await _apiClient.get(
        'notifications/?category=important',
      );

      if (response is List) {
        return response
            .map((json) => _safeParseNotification(json))
            .where((notification) => notification != null)
            .cast<NotificationModel>()
            .toList();
      } else if (response is Map && response.containsKey('results')) {
        final List<dynamic> data = response['results'];
        return data
            .map((json) => _safeParseNotification(json))
            .where((notification) => notification != null)
            .cast<NotificationModel>()
            .toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      // Don't return mock data - let the UI handle empty state properly
      return [];
    }
  }

  // Get news notifications only
  Future<List<NotificationModel>> getNewsNotifications() async {
    try {
      final response = await _apiClient.get('notifications/?category=news');

      if (response is List) {
        return response
            .map((json) => _safeParseNotification(json))
            .where((notification) => notification != null)
            .cast<NotificationModel>()
            .toList();
      } else if (response is Map && response.containsKey('results')) {
        final List<dynamic> data = response['results'];
        return data
            .map((json) => _safeParseNotification(json))
            .where((notification) => notification != null)
            .cast<NotificationModel>()
            .toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      // Don't return mock data - let the UI handle empty state properly
      return [];
    }
  }

  // Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.patchWithAuth('notifications/$notificationId/', {
        'is_read': true,
      });
    } catch (e) {
      // For now, we'll just log the error and continue
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.postWithAuth('notifications/mark-all-read/', {});
    } catch (e) {
      // For now, we'll just log the error and continue
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiClient.deleteWithAuth('notifications/$notificationId/');
    } catch (e) {
      // For now, we'll just log the error and continue
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      await _apiClient.deleteWithAuth('notifications/clear-all/');
    } catch (e) {
      // For now, we'll just log the error and continue
    }
  }

  // Send FCM token to backend for push notifications
  Future<void> registerFCMToken(String token) async {
    try {
      await _apiClient.postWithAuth('notifications/register-token/', {
        'fcm_token': token,
        'platform': 'android', // or 'ios' based on platform
      });
    } catch (e) {
      // Error registering FCM token
    }
  }

  // Unregister FCM token
  Future<void> unregisterFCMToken(String token) async {
    try {
      await _apiClient.postWithAuth('notifications/unregister-token/', {
        'fcm_token': token,
      });
    } catch (e) {
      // Error unregistering FCM token
    }
  }

  // Get notification preferences
  Future<Map<String, bool>> getNotificationPreferences() async {
    try {
      final response = await _apiClient.get('notifications/preferences/');

      if (response is Map<String, dynamic>) {
        return response.map((key, value) => MapEntry(key, value as bool));
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      // Return default preferences if API fails
      return {
        'kyc_updates': true,
        'investment_updates': true,
        'payment_updates': true,
        'system_updates': true,
        'marketing': false,
      };
    }
  }

  // Update notification preferences
  Future<void> updateNotificationPreferences(
    Map<String, bool> preferences,
  ) async {
    try {
      await _apiClient.patchWithAuth('notifications/preferences/', preferences);
    } catch (e) {
      // Error updating notification preferences
    }
  }

  // Create a test notification (for development)
  Future<void> createTestNotification({
    required String type,
    required String title,
    required String message,
  }) async {
    try {
      await _apiClient.postWithAuth('notifications/test/', {
        'type': type,
        'title': title,
        'message': message,
      });
    } catch (e) {
      // Error creating test notification
    }
  }

  // Simulate KYC approval notification (for testing)
  NotificationModel createKycApprovalNotification() {
    return NotificationModel.kycApproved(
      id: 'test_kyc_approved_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
  }

  // Simulate KYC rejection notification (for testing)
  NotificationModel createKycRejectionNotification({String? reason}) {
    return NotificationModel.kycRejected(
      id: 'test_kyc_rejected_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      reason: reason,
    );
  }

  // Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get('notifications/unread-count/');

      if (response is Map<String, dynamic>) {
        return response['count'] ?? 0;
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      // Return 0 if API fails
      return 0;
    }
  }
}
