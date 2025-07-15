import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/verification_code_input.dart';
import '../providers/auth_provider.dart';

// Import standardized dialogs
import '../../../shared/widgets/dialogs/dialogs.dart';

class PasswordResetOtpScreen extends ConsumerStatefulWidget {
  const PasswordResetOtpScreen({super.key});

  @override
  ConsumerState<PasswordResetOtpScreen> createState() => _PasswordResetOtpScreenState();
}

class _PasswordResetOtpScreenState extends ConsumerState<PasswordResetOtpScreen> {
  String? _email;
  String _verificationCode = '';
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get email passed from forgot password screen
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _email = args['email'] as String?;
    }
  }

  Future<void> _verifyOtp() async {
    if (_verificationCode.length != 6 || _email == null) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      // Show loading dialog
      LoadingDialogManager.show(
        context: context,
        title: 'Verifying Code',
        message: 'Please wait while we verify your reset code...',
        icon: Icons.verified_user,
      );

      final success = await ref
          .read(authProvider.notifier)
          .verifyPasswordResetOtp(email: _email!, otp: _verificationCode);

      // Dismiss loading dialog
      LoadingDialogManager.dismiss();

      if (mounted) {
        if (success) {
          // Navigate to new password creation screen
          Navigator.pushReplacementNamed(
            context,
            '/create-new-password',
            arguments: {
              'email': _email,
              'otp': _verificationCode,
            },
          );
        } else {
          final error = ref.read(authErrorProvider);
          await MessageDialog.showError(
            context: context,
            title: 'Verification Failed',
            message: error ?? 'Invalid or expired verification code.',
            details: 'Please check your code and try again, or request a new code.',
          );
        }
      }
    } catch (e) {
      // Dismiss loading dialog
      LoadingDialogManager.dismiss();
      
      if (mounted) {
        await MessageDialog.showError(
          context: context,
          title: 'Verification Error',
          message: 'Unable to verify the code.',
          details: 'Please check your internet connection and try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    if (_email == null || _isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      // Show loading dialog
      LoadingDialogManager.show(
        context: context,
        title: 'Sending New Code',
        message: 'Please wait while we send a new verification code...',
        icon: Icons.email,
      );

      final success = await ref
          .read(authProvider.notifier)
          .forgotPassword(_email!);

      // Dismiss loading dialog
      LoadingDialogManager.dismiss();

      if (mounted) {
        if (success) {
          await MessageDialog.showSuccess(
            context: context,
            title: 'Code Sent',
            message: 'A new verification code has been sent to your email.',
          );
        } else {
          final error = ref.read(authErrorProvider);
          await MessageDialog.showError(
            context: context,
            title: 'Failed to Send Code',
            message: error ?? 'Unable to send verification code.',
            details: 'Please try again later.',
          );
        }
      }
    } catch (e) {
      // Dismiss loading dialog
      LoadingDialogManager.dismiss();
      
      if (mounted) {
        await MessageDialog.showError(
          context: context,
          title: 'Send Error',
          message: 'Unable to send verification code.',
          details: 'Please check your internet connection and try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Verify Reset Code',
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Header icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.lock_reset,
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Enter Verification Code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'We\'ve sent a 6-digit verification code to\n${_email ?? 'your email'}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: 'Montserrat',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // OTP Input
              VerificationCodeInput(
                length: 6,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                  fontFamily: 'Montserrat',
                ),
                borderColor: Colors.grey[300]!,
                focusedBorderColor: AppTheme.primaryColor,
                onCompleted: (code) {
                  setState(() {
                    _verificationCode = code;
                  });
                },
                onChanged: (code) {
                  setState(() {
                    _verificationCode = code;
                  });
                },
              ),
              
              const SizedBox(height: 32),
              
              // Verify button
              CustomButton(
                text: 'Verify Code',
                onPressed: _verificationCode.length == 6 && !_isVerifying
                    ? _verifyOtp
                    : null,
                isLoading: _isVerifying,
              ),
              
              const SizedBox(height: 24),
              
              // Resend code section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Didn\'t receive the code? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  GestureDetector(
                    onTap: _isResending ? null : _resendCode,
                    child: Text(
                      _isResending ? 'Sending...' : 'Resend',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isResending ? Colors.grey[400] : AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Help text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The verification code will expire in 15 minutes. Please check your spam folder if you don\'t see the email.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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
      ),
    );
  }
}
