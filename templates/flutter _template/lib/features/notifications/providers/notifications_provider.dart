import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../models/notification_model.dart';
import '../services/notification_service.dart';

// Providers
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>((
      ref,
    ) {
      final notificationService = ref.watch(notificationServiceProvider);
      return NotificationsNotifier(notificationService);
    });

final notificationsLoadingProvider = StateProvider<bool>((ref) => false);

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((notification) => !notification.isRead).length;
});

// Categorized notification providers
final importantNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((notification) {
    try {
      return notification.category == NotificationCategory.important;
    } catch (e) {
      // Fallback for any notifications that might have null categories
      return true; // Default to important
    }
  }).toList();
});

final newsNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((notification) {
    try {
      return notification.category == NotificationCategory.news;
    } catch (e) {
      // Fallback for any notifications that might have null categories
      return false; // Don't include in news if category is problematic
    }
  }).toList();
});

// Unread count providers for each category
final unreadImportantCountProvider = Provider<int>((ref) {
  final importantNotifications = ref.watch(importantNotificationsProvider);
  return importantNotifications
      .where((notification) => !notification.isRead)
      .length;
});

final unreadNewsCountProvider = Provider<int>((ref) {
  final newsNotifications = ref.watch(newsNotificationsProvider);
  return newsNotifications.where((notification) => !notification.isRead).length;
});

// Notifications Notifier
class NotificationsNotifier extends StateNotifier<List<NotificationModel>> {
  final NotificationService _notificationService;

  NotificationsNotifier(this._notificationService) : super([]);

  Future<void> loadNotifications() async {
    try {
      final notifications = await _notificationService.getNotifications();
      state = notifications;
    } catch (e) {
      developer.log('Error loading notifications: $e', error: e);
      // Keep existing state on error to avoid clearing notifications
      rethrow;
    }
  }

  Future<void> loadImportantNotifications() async {
    try {
      final notifications = await _notificationService
          .getImportantNotifications();
      // Update state with important notifications, preserving existing news notifications
      final currentNews = state
          .where((n) => n.category == NotificationCategory.news)
          .toList();
      state = [...notifications, ...currentNews];
    } catch (e) {
      developer.log('Error loading important notifications: $e', error: e);
      // Keep existing state on error
      rethrow;
    }
  }

  Future<void> loadNewsNotifications() async {
    try {
      final notifications = await _notificationService.getNewsNotifications();
      // Update state with news notifications, preserving existing important notifications
      final currentImportant = state
          .where((n) => n.category == NotificationCategory.important)
          .toList();
      state = [...currentImportant, ...notifications];
    } catch (e) {
      developer.log('Error loading news notifications: $e', error: e);
      // Keep existing state on error
      rethrow;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      // Update local state
      state = state.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();
    } catch (e) {
      developer.log('Error marking notification as read: $e', error: e);
      // Still update local state for better UX, even if API call fails
      state = state.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();

      // Update local state
      state = state
          .map((notification) => notification.copyWith(isRead: true))
          .toList();
    } catch (e) {
      developer.log('Error marking all notifications as read: $e', error: e);
      // Still update local state for better UX, even if API call fails
      state = state
          .map((notification) => notification.copyWith(isRead: true))
          .toList();
    }
  }

  void addNotification(NotificationModel notification) {
    state = [notification, ...state];
  }

  void removeNotification(String notificationId) {
    state = state
        .where((notification) => notification.id != notificationId)
        .toList();
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      removeNotification(notificationId);
    } catch (e) {
      developer.log('Error deleting notification: $e', error: e);
      // Don't remove from local state if API call fails
      rethrow;
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      await _notificationService.clearAllNotifications();
      state = [];
    } catch (e) {
      developer.log('Error clearing all notifications: $e', error: e);
      // Don't clear local state if API call fails
      rethrow;
    }
  }

  // Handle KYC status change notifications
  void handleKycStatusChange(String newStatus, String userId) {
    final now = DateTime.now();

    switch (newStatus.toLowerCase()) {
      case 'approved':
        final notification = NotificationModel.kycApproved(
          id: 'kyc_approved_${userId}_${now.millisecondsSinceEpoch}',
          createdAt: now,
        );
        addNotification(notification);
        break;
      case 'rejected':
        final notification = NotificationModel.kycRejected(
          id: 'kyc_rejected_${userId}_${now.millisecondsSinceEpoch}',
          createdAt: now,
        );
        addNotification(notification);
        break;
    }
  }

  // Handle investment-related notifications
  void handleInvestmentNotification({
    required String title,
    required String message,
    required String userId,
    Map<String, dynamic>? data,
  }) {
    final now = DateTime.now();
    final notification = NotificationModel.investmentUpdate(
      id: 'investment_${userId}_${now.millisecondsSinceEpoch}',
      title: title,
      message: message,
      createdAt: now,
      additionalData: data,
    );
    addNotification(notification);
  }

  // Handle payment-related notifications
  void handlePaymentNotification({
    required String title,
    required String message,
    required String userId,
    Map<String, dynamic>? data,
  }) {
    final now = DateTime.now();
    final notification = NotificationModel.paymentUpdate(
      id: 'payment_${userId}_${now.millisecondsSinceEpoch}',
      title: title,
      message: message,
      createdAt: now,
      additionalData: data,
    );
    addNotification(notification);
  }

  // Handle system notifications
  void handleSystemNotification({
    required String title,
    required String message,
    required String userId,
    Map<String, dynamic>? data,
  }) {
    final now = DateTime.now();
    final notification = NotificationModel.systemNotification(
      id: 'system_${userId}_${now.millisecondsSinceEpoch}',
      title: title,
      message: message,
      createdAt: now,
      additionalData: data,
    );
    addNotification(notification);
  }
}

// Push notification handling provider
final pushNotificationProvider = Provider<PushNotificationHandler>((ref) {
  final notificationsNotifier = ref.read(notificationsProvider.notifier);
  return PushNotificationHandler(notificationsNotifier);
});

class PushNotificationHandler {
  final NotificationsNotifier _notificationsNotifier;

  PushNotificationHandler(this._notificationsNotifier);

  // Initialize push notifications
  Future<void> initialize() async {
    // TODO: Initialize Firebase Cloud Messaging or other push notification service
    // This would typically involve:
    // 1. Requesting notification permissions
    // 2. Getting FCM token
    // 3. Sending token to backend
    // 4. Setting up message handlers

    // Push notifications initialized
  }

  // Handle incoming push notifications
  void handlePushNotification(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final userId = data['user_id'] as String?;

    if (userId == null) return;

    switch (type) {
      case 'kyc_status_change':
        final newStatus = data['kyc_status'] as String?;
        if (newStatus != null) {
          _notificationsNotifier.handleKycStatusChange(newStatus, userId);
        }
        break;
      case 'investment_update':
        _notificationsNotifier.handleInvestmentNotification(
          title: data['title'] ?? 'Investment Update',
          message: data['message'] ?? 'You have a new investment update',
          userId: userId,
          data: data,
        );
        break;
      case 'payment_update':
        _notificationsNotifier.handlePaymentNotification(
          title: data['title'] ?? 'Payment Update',
          message: data['message'] ?? 'You have a new payment update',
          userId: userId,
          data: data,
        );
        break;
      default:
        _notificationsNotifier.handleSystemNotification(
          title: data['title'] ?? 'System Notification',
          message: data['message'] ?? 'You have a new notification',
          userId: userId,
          data: data,
        );
    }
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    // TODO: Implement permission request logic
    // This would typically use firebase_messaging or local_notifications
    return true;
  }

  // Get FCM token for backend registration
  Future<String?> getFCMToken() async {
    // TODO: Implement FCM token retrieval
    return null;
  }
}
