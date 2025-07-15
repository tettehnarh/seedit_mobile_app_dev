import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/security_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/biometric_settings_card.dart';
import '../widgets/session_settings_card.dart';
import '../widgets/security_info_card.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends ConsumerState<SecuritySettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSecurity();
    });
  }

  void _initializeSecurity() {
    ref.read(securityStateProvider.notifier).initializeSecurity();
  }

  @override
  Widget build(BuildContext context) {
    final securityState = ref.watch(securityStateProvider);
    final biometricCapabilities = ref.watch(biometricCapabilitiesProvider);
    final sessionInfo = ref.watch(sessionInfoProvider);
    final biometricEnabled = ref.watch(biometricEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showSecurityInfoDialog();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(securityStateProvider.notifier).refreshSecuritySettings();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.security,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Security & Privacy',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your account security settings and privacy preferences',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Error handling
              if (securityState.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade600,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          securityState.error!,
                          style: TextStyle(
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          ref.read(securityStateProvider.notifier).clearError();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Loading indicator
              if (securityState.isLoading) ...[
                const Center(
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(height: 24),
              ],
              
              // Biometric settings
              biometricCapabilities.when(
                data: (capabilities) => BiometricSettingsCard(
                  capabilities: capabilities,
                  isEnabled: biometricEnabled.value ?? false,
                  onToggle: (enabled) async {
                    if (enabled) {
                      final success = await ref.read(securityStateProvider.notifier).enableBiometric();
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${capabilities.displayName} enabled successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        ref.invalidate(biometricEnabledProvider);
                      }
                    } else {
                      try {
                        await ref.read(securityStateProvider.notifier).disableBiometric();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${capabilities.displayName} disabled'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          ref.invalidate(biometricEnabledProvider);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Error loading biometric settings: $error'),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Session settings
              sessionInfo.when(
                data: (info) => SessionSettingsCard(
                  sessionInfo: info,
                  onTimeoutChanged: (minutes) async {
                    try {
                      await ref.read(securityStateProvider.notifier).setSessionTimeout(minutes);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Session timeout updated to $minutes minutes'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        ref.invalidate(sessionInfoProvider);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  onAutoLockChanged: (enabled) async {
                    try {
                      await ref.read(securityStateProvider.notifier).setAutoLockEnabled(enabled);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Auto-lock ${enabled ? 'enabled' : 'disabled'}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        ref.invalidate(sessionInfoProvider);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  onLockOnBackgroundChanged: (enabled) async {
                    try {
                      await ref.read(securityStateProvider.notifier).setLockOnBackgroundEnabled(enabled);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lock on background ${enabled ? 'enabled' : 'disabled'}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        ref.invalidate(sessionInfoProvider);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Error loading session settings: $error'),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Security info card
              const SecurityInfoCard(),
              
              const SizedBox(height: 24),
              
              // Additional security actions
              _buildSecurityActions(),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            CustomButton(
              text: 'Change Password',
              onPressed: () {
                context.push('/security/change-password');
              },
              isOutlined: true,
              icon: Icons.lock_outline,
            ),
            
            const SizedBox(height: 12),
            
            CustomButton(
              text: 'Two-Factor Authentication',
              onPressed: () {
                context.push('/security/two-factor');
              },
              isOutlined: true,
              icon: Icons.verified_user,
            ),
            
            const SizedBox(height: 12),
            
            CustomButton(
              text: 'Active Sessions',
              onPressed: () {
                context.push('/security/active-sessions');
              },
              isOutlined: true,
              icon: Icons.devices,
            ),
            
            const SizedBox(height: 12),
            
            CustomButton(
              text: 'Security Log',
              onPressed: () {
                context.push('/security/security-log');
              },
              isOutlined: true,
              icon: Icons.history,
            ),
          ],
        ),
      ),
    );
  }

  void _showSecurityInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Information'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your security is our priority. Here\'s what we do to protect your account:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              Text('• End-to-end encryption for all data'),
              SizedBox(height: 8),
              Text('• Biometric authentication support'),
              SizedBox(height: 8),
              Text('• Automatic session timeout'),
              SizedBox(height: 8),
              Text('• Real-time security monitoring'),
              SizedBox(height: 8),
              Text('• Regular security audits'),
              SizedBox(height: 16),
              Text(
                'Always keep your security settings up to date and never share your login credentials.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
