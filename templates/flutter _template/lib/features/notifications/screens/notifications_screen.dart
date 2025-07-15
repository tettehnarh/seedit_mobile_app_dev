import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../../../shared/widgets/custom_bottom_navigation.dart';
import '../models/notification_model.dart';
import '../providers/notifications_provider.dart';
import '../../auth/providers/user_provider.dart';

// Import standardized dialogs
import '../../../shared/widgets/dialogs/dialogs.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with BottomNavigationMixin, TickerProviderStateMixin {
  late TabController _tabController;

  @override
  BottomNavItem get currentNavItem => BottomNavItem.home;

  @override
  bool get isKycCompleted =>
      ref.watch(currentUserProvider)?.isKycCompleted ?? false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load notifications when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).loadNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(notificationsLoadingProvider);
    final importantNotifications = ref.watch(importantNotificationsProvider);
    final newsNotifications = ref.watch(newsNotificationsProvider);
    final unreadImportantCount = ref.watch(unreadImportantCountProvider);
    final unreadNewsCount = ref.watch(unreadNewsCountProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.mark_email_read,
              color: AppTheme.primaryColor,
            ),
            onPressed: () => _showMarkAllAsReadDialog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey[600],
          labelStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Important'),
                  if (unreadImportantCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        unreadImportantCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('News'),
                  if (unreadNewsCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        unreadNewsCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationTab(
            notifications: importantNotifications,
            isLoading: isLoading,
            emptyTitle: 'No Important Notifications',
            emptyMessage:
                'You\'ll see important notifications like KYC updates, investment alerts, and payment confirmations here.',
            emptyIcon: Icons.priority_high,
            onRefresh: () async {
              await ref
                  .read(notificationsProvider.notifier)
                  .loadImportantNotifications();
            },
          ),
          _buildNotificationTab(
            notifications: newsNotifications,
            isLoading: isLoading,
            emptyTitle: 'No News Updates',
            emptyMessage:
                'Stay tuned for market updates, investment tips, and financial education content.',
            emptyIcon: Icons.article,
            onRefresh: () async {
              await ref
                  .read(notificationsProvider.notifier)
                  .loadNewsNotifications();
            },
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigation(),
    );
  }

  Widget _buildNotificationTab({
    required List<NotificationModel> notifications,
    required bool isLoading,
    required String emptyTitle,
    required String emptyMessage,
    required IconData emptyIcon,
    required Future<void> Function() onRefresh,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            )
          : notifications.isEmpty
          ? _buildEmptyState(
              title: emptyTitle,
              message: emptyMessage,
              icon: emptyIcon,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String message,
    required IconData icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                fontFamily: 'Montserrat',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontFamily: 'Montserrat',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? Colors.grey[200]! : Colors.blue[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getNotificationColor(
              notification.type,
            ).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: _getNotificationColor(notification.type),
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
            color: AppTheme.primaryColor,
            fontFamily: 'Montserrat',
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDateTime(notification.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontFamily: 'Montserrat',
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
        onTap: () => _markAsRead(notification),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'kyc_approved':
        return Icons.verified_user;
      case 'kyc_rejected':
        return Icons.error_outline;
      case 'investment':
        return Icons.trending_up;
      case 'payment':
        return Icons.payment;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'kyc_approved':
        return Colors.green;
      case 'kyc_rejected':
        return Colors.red;
      case 'investment':
        return Colors.blue;
      case 'payment':
        return Colors.orange;
      case 'system':
        return Colors.purple;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  void _markAsRead(NotificationModel notification) {
    if (!notification.isRead) {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    }
  }

  void _showMarkAllAsReadDialog() async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Mark All as Read',
      message: 'Are you sure you want to mark all notifications as read?',
      confirmText: 'Mark All Read',
      cancelText: 'Cancel',
    );

    if (confirmed && mounted) {
      await _markAllAsRead();
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      // Show loading dialog
      LoadingDialogManager.show(
        context: context,
        title: 'Updating Notifications',
        message: 'Marking all notifications as read...',
        icon: Icons.mark_email_read,
      );

      await ref.read(notificationsProvider.notifier).markAllAsRead();

      // Dismiss loading dialog
      LoadingDialogManager.dismiss();

      if (mounted) {
        await MessageDialog.showSuccess(
          context: context,
          title: 'All Notifications Marked as Read',
          message: 'All your notifications have been marked as read.',
        );
      }
    } catch (error) {
      // Dismiss loading dialog
      LoadingDialogManager.dismiss();

      if (mounted) {
        await MessageDialog.showError(
          context: context,
          title: 'Update Failed',
          message: 'Unable to mark notifications as read.',
          details: 'Please check your internet connection and try again.',
        );
      }
    }
  }
}
