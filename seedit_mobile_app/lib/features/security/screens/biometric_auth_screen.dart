import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/security_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class BiometricAuthScreen extends ConsumerStatefulWidget {
  final String? redirectPath;
  final String? reason;

  const BiometricAuthScreen({
    super.key,
    this.redirectPath,
    this.reason,
  });

  @override
  ConsumerState<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends ConsumerState<BiometricAuthScreen> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricAndAuthenticate();
    });
  }

  Future<void> _checkBiometricAndAuthenticate() async {
    final securityNotifier = ref.read(securityStateProvider.notifier);
    
    // Check if biometric is available and enabled
    final isAvailable = await securityNotifier.isBiometricAvailable();
    final capabilities = await ref.read(biometricCapabilitiesProvider.future);
    
    if (isAvailable && capabilities.isEnabled) {
      await _authenticateWithBiometric();
    }
  }

  Future<void> _authenticateWithBiometric() async {
    if (_isAuthenticating) return;
    
    setState(() {
      _isAuthenticating = true;
    });

    try {
      final securityNotifier = ref.read(securityStateProvider.notifier);
      final success = await securityNotifier.authenticateWithBiometric(
        reason: widget.reason ?? 'Authenticate to access SeedIt',
        fallbackToCredentials: true,
      );

      if (success && mounted) {
        // Authentication successful
        await securityNotifier.startSession();
        
        if (widget.redirectPath != null) {
          context.go(widget.redirectPath!);
        } else {
          context.go('/home');
        }
      } else if (mounted) {
        // Authentication failed
        _showAuthenticationFailedDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  void _showAuthenticationFailedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Failed'),
        content: const Text(
          'Biometric authentication failed. Please try again or use your password.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _authenticateWithBiometric();
            },
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/auth/sign-in');
            },
            child: const Text('Use Password'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/auth/sign-in');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final biometricCapabilities = ref.watch(biometricCapabilitiesProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or app icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.security,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                'Secure Access',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              biometricCapabilities.when(
                data: (capabilities) => Column(
                  children: [
                    if (capabilities.isAvailable && capabilities.isEnabled) ...[
                      Text(
                        'Use ${capabilities.displayName} to access your account',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Biometric icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _isAuthenticating 
                              ? Colors.orange.withOpacity(0.1)
                              : Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isAuthenticating 
                                ? Colors.orange
                                : Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                        child: _isAuthenticating
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : Icon(
                                _getBiometricIcon(capabilities),
                                size: 40,
                                color: Theme.of(context).primaryColor,
                              ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      if (_isAuthenticating) ...[
                        Text(
                          'Authenticating...',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else ...[
                        CustomButton(
                          text: 'Authenticate with ${capabilities.displayName}',
                          onPressed: _authenticateWithBiometric,
                          icon: _getBiometricIcon(capabilities),
                        ),
                      ],
                    ] else ...[
                      Text(
                        'Biometric authentication is not available or enabled',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      CustomButton(
                        text: 'Use Password Instead',
                        onPressed: () {
                          context.go('/auth/sign-in');
                        },
                        isOutlined: true,
                      ),
                    ],
                  ],
                ),
                loading: () => const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading biometric settings...'),
                  ],
                ),
                error: (error, stack) => Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading biometric settings',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Use Password Instead',
                      onPressed: () {
                        context.go('/auth/sign-in');
                      },
                      isOutlined: true,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Alternative options
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      context.go('/auth/sign-in');
                    },
                    child: const Text('Use Password'),
                  ),
                  const Text(' • '),
                  TextButton(
                    onPressed: () {
                      context.go('/security');
                    },
                    child: const Text('Security Settings'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getBiometricIcon(capabilities) {
    if (capabilities.hasFaceId) {
      return Icons.face;
    } else if (capabilities.hasTouchId) {
      return Icons.fingerprint;
    } else if (capabilities.hasIris) {
      return Icons.visibility;
    }
    return Icons.security;
  }
}

class BiometricPromptDialog extends StatefulWidget {
  final String reason;
  final VoidCallback onSuccess;
  final VoidCallback onFailure;
  final VoidCallback? onCancel;

  const BiometricPromptDialog({
    super.key,
    required this.reason,
    required this.onSuccess,
    required this.onFailure,
    this.onCancel,
  });

  @override
  State<BiometricPromptDialog> createState() => _BiometricPromptDialogState();
}

class _BiometricPromptDialogState extends State<BiometricPromptDialog> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
    });

    // Simulate biometric authentication
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isAuthenticating = false;
      });
      
      // For demo purposes, randomly succeed or fail
      if (DateTime.now().millisecond % 2 == 0) {
        widget.onSuccess();
      } else {
        widget.onFailure();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Biometric Authentication'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isAuthenticating) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Authenticating...'),
          ] else ...[
            const Icon(
              Icons.fingerprint,
              size: 48,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(widget.reason),
          ],
        ],
      ),
      actions: [
        if (!_isAuthenticating && widget.onCancel != null)
          TextButton(
            onPressed: widget.onCancel,
            child: const Text('Cancel'),
          ),
      ],
    );
  }
}
