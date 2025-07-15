import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../../../shared/widgets/dialogs/dialogs.dart';
import '../services/settings_service.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _isLoading = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;
  bool _marketingEmails = false;
  bool _securityAlerts = true;
  bool _transactionNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    try {
      final settingsService = SettingsService();
      final preferences = await settingsService.getNotificationPreferences();

      setState(() {
        _emailNotifications =
            preferences['email_notifications_enabled'] ?? true;
        _pushNotifications = preferences['push_notifications_enabled'] ?? true;
        _smsNotifications = preferences['sms_notifications_enabled'] ?? false;
        _marketingEmails = preferences['investment_notifications'] ?? false;
        _securityAlerts = preferences['system_notifications'] ?? true;
        _transactionNotifications =
            preferences['payment_notifications'] ?? true;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        await MessageDialog.showError(
          context: context,
          title: 'Loading Failed',
          message: 'Failed to load notification preferences.',
          details: error.toString(),
        );
      }
    }
  }

  Future<void> _updatePreferences() async {
    try {
      final settingsService = SettingsService();
      await settingsService.updateNotificationPreferences(
        emailNotifications: _emailNotifications,
        pushNotifications: _pushNotifications,
        smsNotifications: _smsNotifications,
        marketingEmails: _marketingEmails,
        securityAlerts: _securityAlerts,
        transactionNotifications: _transactionNotifications,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification preferences updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        await MessageDialog.showError(
          context: context,
          title: 'Update Failed',
          message: 'Failed to update notification preferences.',
          details: error.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Notification Settings',
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // General Notifications Section
                  _buildSectionTitle('General Notifications'),
                  const SizedBox(height: 12),
                  _buildNotificationCard(
                    title: 'Email Notifications',
                    subtitle: 'Receive notifications via email',
                    value: _emailNotifications,
                    onChanged: (value) {
                      setState(() {
                        _emailNotifications = value;
                      });
                      _updatePreferences();
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildNotificationCard(
                    title: 'Push Notifications',
                    subtitle: 'Receive push notifications on your device',
                    value: _pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        _pushNotifications = value;
                      });
                      _updatePreferences();
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildNotificationCard(
                    title: 'SMS Notifications',
                    subtitle: 'Receive notifications via SMS',
                    value: _smsNotifications,
                    onChanged: (value) {
                      setState(() {
                        _smsNotifications = value;
                      });
                      _updatePreferences();
                    },
                  ),
                  const SizedBox(height: 24),

                  // Specific Notifications Section
                  _buildSectionTitle('Specific Notifications'),
                  const SizedBox(height: 12),
                  _buildNotificationCard(
                    title: 'System Notifications',
                    subtitle: 'Important system and account updates',
                    value: _securityAlerts,
                    onChanged: (value) {
                      setState(() {
                        _securityAlerts = value;
                      });
                      _updatePreferences();
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildNotificationCard(
                    title: 'Payment Notifications',
                    subtitle: 'Updates about payments and transactions',
                    value: _transactionNotifications,
                    onChanged: (value) {
                      setState(() {
                        _transactionNotifications = value;
                      });
                      _updatePreferences();
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildNotificationCard(
                    title: 'Investment Notifications',
                    subtitle: 'Updates about your investments and portfolio',
                    value: _marketingEmails,
                    onChanged: (value) {
                      setState(() {
                        _marketingEmails = value;
                      });
                      _updatePreferences();
                    },
                  ),
                  const SizedBox(height: 24),

                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Security alerts cannot be disabled for your account safety.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
        fontFamily: 'Montserrat',
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
            fontFamily: 'Montserrat',
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.companyInfoColor,
            fontFamily: 'Montserrat',
          ),
        ),
        value: value,
        onChanged: title == 'Security Alerts'
            ? null
            : onChanged, // Disable security alerts toggle
        activeColor: AppTheme.primaryColor,
      ),
    );
  }
}
