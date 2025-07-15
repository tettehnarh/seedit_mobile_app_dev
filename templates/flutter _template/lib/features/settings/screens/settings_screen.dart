import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart' as user_prov;
import '../../auth/providers/biometric_provider.dart';

import '../services/settings_service.dart';
import 'dart:developer' as developer;

// Import standardized dialogs
import '../../../shared/widgets/dialogs/dialogs.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoading = false;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    _loadNotificationPreferences();
    _loadBiometricStatus();
  }

  /// Initialize and refresh user data to ensure KYC status is current
  Future<void> _initializeUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      developer.log(
        '🔄 [SETTINGS] Refreshing user data for current KYC status...',
      );

      // Force refresh KYC status to ensure we have the most current status
      // This fixes the issue where KYC-verified users appear as not verified on initial load
      await ref.read(user_prov.userProvider.notifier).forceRefreshKycStatus();

      // Then refresh user data to get the latest profile information
      await ref.read(user_prov.userProvider.notifier).refreshUserData();

      developer.log(
        '✅ [SETTINGS] User data and KYC status refreshed successfully',
      );
    } catch (e) {
      developer.log('❌ [SETTINGS] Error refreshing user data: $e', error: e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Load notification preferences from backend
  Future<void> _loadNotificationPreferences() async {
    try {
      final settingsService = SettingsService();
      final preferences = await settingsService.getNotificationPreferences();

      if (mounted) {
        setState(() {
          _emailNotifications =
              preferences['email_notifications_enabled'] ?? true;
          _smsNotifications = preferences['sms_notifications_enabled'] ?? false;
        });
      }
    } catch (e) {
      developer.log(
        '❌ [SETTINGS] Error loading notification preferences: $e',
        error: e,
      );
    }
  }

  /// Update email notification preference
  Future<void> _updateEmailNotifications(bool value) async {
    setState(() {
      _emailNotifications = value;
    });

    try {
      final settingsService = SettingsService();
      await settingsService.updateNotificationPreferences(
        emailNotifications: value,
      );

      developer.log('✅ [SETTINGS] Updated email notifications to $value');
    } catch (e) {
      developer.log(
        '❌ [SETTINGS] Error updating email notifications: $e',
        error: e,
      );

      // Revert the UI state on error
      if (mounted) {
        setState(() {
          _emailNotifications = !value;
        });
      }
    }
  }

  /// Update SMS notification preference
  Future<void> _updateSmsNotifications(bool value) async {
    setState(() {
      _smsNotifications = value;
    });

    try {
      final settingsService = SettingsService();
      await settingsService.updateNotificationPreferences(
        smsNotifications: value,
      );

      developer.log('✅ [SETTINGS] Updated SMS notifications to $value');
    } catch (e) {
      developer.log(
        '❌ [SETTINGS] Error updating SMS notifications: $e',
        error: e,
      );

      // Revert the UI state on error
      if (mounted) {
        setState(() {
          _smsNotifications = !value;
        });
      }
    }
  }

  /// Load biometric authentication status
  Future<void> _loadBiometricStatus() async {
    try {
      final biometricNotifier = ref.read(biometricProvider.notifier);
      await biometricNotifier.checkBiometricStatus();

      final biometricState = ref.read(biometricProvider);

      if (mounted) {
        setState(() {
          _biometricAvailable = biometricState.isAvailable;
          _biometricEnabled = biometricState.isEnabled;
        });
      }
    } catch (e) {
      developer.log(
        '❌ [SETTINGS] Error loading biometric status: $e',
        error: e,
      );
    }
  }

  /// Update biometric authentication preference
  Future<void> _updateBiometricAuthentication(bool value) async {
    try {
      final authNotifier = ref.read(authProvider.notifier);
      final biometricNotifier = ref.read(biometricProvider.notifier);

      if (value) {
        // Enable biometric authentication
        final success = await authNotifier.enableBiometric();
        if (success) {
          setState(() {
            _biometricEnabled = true;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Biometric authentication enabled successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to enable biometric authentication'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Disable biometric authentication
        final success = await authNotifier.disableBiometric();
        if (success) {
          setState(() {
            _biometricEnabled = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Biometric authentication disabled'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to disable biometric authentication'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }

      // Refresh biometric status
      await biometricNotifier.checkBiometricStatus();
    } catch (e) {
      developer.log(
        '❌ [SETTINGS] Error updating biometric authentication: $e',
        error: e,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating biometric authentication'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(user_prov.currentUserProvider);
    final userState = ref.watch(user_prov.userProvider);
    final isKycApproved = user?.isKycCompleted ?? false;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Settings',
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
            // Check if we can pop, otherwise navigate to home
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
      ),
      body: _isLoading || userState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : RefreshIndicator(
              onRefresh: _initializeUserData,
              color: AppTheme.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile section
                    _buildProfileSection(context, user, isKycApproved),
                    const SizedBox(height: 24),

                    // Security section
                    _buildSectionTitle('Security'),
                    const SizedBox(height: 12),
                    _buildSettingCard(
                      context,
                      title: 'Change Password',
                      subtitle: 'Update your password',
                      icon: Icons.lock,
                      onTap: () {
                        Navigator.pushNamed(context, '/change-password');
                      },
                    ),
                    const SizedBox(height: 24),

                    // KYC Information section (only show if KYC has been submitted)
                    if (user != null && _shouldShowKycSection(user)) ...[
                      _buildSectionTitle('Verification'),
                      const SizedBox(height: 12),
                      _buildSettingCard(
                        context,
                        title: 'KYC Information',
                        subtitle: 'View your verification details',
                        icon: Icons.verified_user,
                        onTap: () {
                          Navigator.pushNamed(context, '/kyc-information');
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Support section
                    _buildSectionTitle('Support'),
                    const SizedBox(height: 12),
                    _buildSettingCard(
                      context,
                      title: 'Help Center',
                      subtitle: 'Get help and support',
                      icon: Icons.help,
                      onTap: () {
                        Navigator.pushNamed(context, '/help-center');
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildSettingCard(
                      context,
                      title: 'Contact Support',
                      subtitle: 'Reach out to our team',
                      icon: Icons.support_agent,
                      onTap: () {
                        Navigator.pushNamed(context, '/contact-support');
                      },
                    ),
                    const SizedBox(height: 24),

                    // App section
                    _buildSectionTitle('App'),
                    const SizedBox(height: 12),
                    // Email Notifications Toggle
                    _buildNotificationToggle(
                      title: 'Email Notifications',
                      subtitle: 'Receive notifications via email',
                      icon: Icons.email,
                      value: _emailNotifications,
                      onChanged: _updateEmailNotifications,
                    ),
                    const SizedBox(height: 8),
                    // SMS Notifications Toggle
                    _buildNotificationToggle(
                      title: 'SMS Notifications',
                      subtitle: 'Receive notifications via SMS',
                      icon: Icons.sms,
                      value: _smsNotifications,
                      onChanged: _updateSmsNotifications,
                    ),
                    const SizedBox(height: 8),
                    // Biometric Authentication Toggle (only show if available)
                    if (_biometricAvailable) ...[
                      _buildNotificationToggle(
                        title: 'Biometric Authentication',
                        subtitle: 'Use fingerprint or face ID to sign in',
                        icon: Icons.fingerprint,
                        value: _biometricEnabled,
                        onChanged: _updateBiometricAuthentication,
                      ),
                      const SizedBox(height: 8),
                    ],

                    _buildSettingCard(
                      context,
                      title: 'Privacy Policy',
                      subtitle: 'Read our privacy policy',
                      icon: Icons.privacy_tip,
                      onTap: () {
                        Navigator.pushNamed(context, '/privacy-policy');
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildSettingCard(
                      context,
                      title: 'Terms of Service',
                      subtitle: 'Read our terms of service',
                      icon: Icons.description,
                      onTap: () {
                        Navigator.pushNamed(context, '/terms-of-service');
                      },
                    ),
                    const SizedBox(height: 32),

                    // Sign out button
                    CustomButton(
                      text: 'SIGN OUT',
                      onPressed: () => _showSignOutDialog(context, ref),
                      backgroundColor: Colors.red,
                    ),
                    const SizedBox(height: 16),

                    // App version
                    Center(
                      child: Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileSection(BuildContext context, user, bool isKycApproved) {
    // Determine display name and status based on KYC status
    String displayName;
    String statusText;
    Color statusColor;

    if (user == null) {
      displayName = 'Seedit Investor';
      statusText = 'Loading...';
      statusColor = Colors.grey;
    } else {
      switch (user.kycStatus.toLowerCase()) {
        case 'approved':
          // Use KYC-verified name as authoritative source
          displayName = user.authoritativeFullName.isNotEmpty
              ? user.authoritativeFullName
              : 'Verified User';
          statusText = 'KYC Verified';
          statusColor = Colors.green;
          break;
        case 'pending_review':
          // Show submitted name (read-only)
          displayName = user.authoritativeFullName.isNotEmpty
              ? user.authoritativeFullName
              : 'Pending Review';
          statusText = 'KYC Under Review';
          statusColor = Colors.orange;
          break;
        case 'rejected':
          // Show previously submitted name (read-only)
          displayName = user.authoritativeFullName.isNotEmpty
              ? user.authoritativeFullName
              : 'KYC Rejected';
          statusText = 'KYC Rejected - Contact Support';
          statusColor = Colors.red;
          break;
        case 'in_progress':
          displayName = user.authoritativeFullName.isNotEmpty
              ? user.authoritativeFullName
              : 'Seedit Investor';
          statusText = 'Complete KYC Process';
          statusColor = Colors.blue;
          break;
        default: // not_started
          displayName = 'Seedit Investor';
          statusText = 'Complete KYC to Verify Identity';
          statusColor = Colors.grey;
          break;
      }
    }

    // Get initials for avatar
    String avatarInitials;
    if (user != null && user.authoritativeFirstName.isNotEmpty) {
      avatarInitials = user.authoritativeFirstName[0].toUpperCase();
    } else {
      avatarInitials = 'S'; // For "Seedit"
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              avatarInitials,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'user@example.com',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.companyInfoColor,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 8),
                // KYC Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Profile editing removed - all profile information is now read-only
          Icon(Icons.lock, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  /// Check if KYC section should be shown
  bool _shouldShowKycSection(user) {
    if (user?.kycPersonalInfo == null) return false;

    // Show KYC section for submitted, pending, approved, or rejected applications
    final kycStatus = user.kycStatus.toLowerCase();
    return ['approved', 'pending_review', 'rejected'].contains(kycStatus);
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

  Widget _buildSettingCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
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
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
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
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.companyInfoColor,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
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
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
          activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.3),
          inactiveThumbColor: Colors.grey[400],
          inactiveTrackColor: Colors.grey[300],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
      isDestructive: true,
      icon: Icons.logout,
      details: 'You will need to sign in again to access your account.',
    );

    if (confirmed && context.mounted) {
      // Show loading dialog while signing out
      LoadingDialogManager.show(
        context: context,
        title: 'Signing Out',
        message: 'Please wait...',
        icon: Icons.logout,
      );

      try {
        await ref.read(authProvider.notifier).signOut();

        // Dismiss loading dialog
        LoadingDialogManager.dismiss();

        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/sign-in',
            (route) => false,
          );
        }
      } catch (error) {
        // Dismiss loading dialog
        LoadingDialogManager.dismiss();

        if (context.mounted) {
          // Show error dialog
          await MessageDialog.showError(
            context: context,
            title: 'Sign Out Failed',
            message: 'Unable to sign out. Please try again.',
            details: 'Check your internet connection and try again.',
          );
        }
      }
    }
  }
}
