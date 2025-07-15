import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../core/utils/validation_functions.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  Timer? _timer;
  int _resendCountdown = 0;
  bool _canResend = true;

  @override
  void dispose() {
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyEmail() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authStateProvider.notifier).confirmSignUp(
        widget.email,
        _codeController.text.trim(),
      );
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to sign in screen
        context.go('/auth/sign-in');
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

  Future<void> _resendCode() async {
    if (!_canResend) return;

    try {
      await ref.read(authStateProvider.notifier).resendConfirmationCode(widget.email);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code sent!'),
            backgroundColor: Colors.green,
          ),
        );
        
        _startResendCountdown();
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

  void _startResendCountdown() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCountdown--;
      });

      if (_resendCountdown <= 0) {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isLoading ? null : () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                
                // Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.email_outlined,
                      color: Theme.of(context).primaryColor,
                      size: 40,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title and description
                Text(
                  'Check Your Email',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'We\'ve sent a verification code to:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  widget.email,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Verification code input
                CustomTextField(
                  controller: _codeController,
                  label: 'Verification Code',
                  hintText: 'Enter 6-digit code',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.security,
                  validator: ValidationFunctions.validateConfirmationCode,
                  enabled: !isLoading,
                  textCapitalization: TextCapitalization.characters,
                ),
                
                const SizedBox(height: 32),
                
                // Verify button
                CustomButton(
                  text: 'Verify Email',
                  onPressed: isLoading ? null : _verifyEmail,
                  isLoading: isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Resend code section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (_canResend)
                      TextButton(
                        onPressed: isLoading ? null : _resendCode,
                        child: const Text('Resend'),
                      )
                    else
                      Text(
                        'Resend in ${_resendCountdown}s',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Help text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tips:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Check your spam/junk folder\n'
                        '• Make sure you entered the correct email\n'
                        '• The code expires in 15 minutes',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Change email option
                TextButton(
                  onPressed: isLoading ? null : () {
                    context.pop();
                  },
                  child: const Text('Use a different email address'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
