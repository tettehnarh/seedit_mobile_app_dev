import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../core/utils/validation_functions.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authStateProvider.notifier).resetPassword(
        _emailController.text.trim(),
      );
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset code sent to your email!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to reset password confirmation screen
        context.push('/auth/reset-password-confirm', extra: _emailController.text.trim());
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
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
                      Icons.lock_reset,
                      color: Theme.of(context).primaryColor,
                      size: 40,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title and description
                Text(
                  'Forgot Password?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'No worries! Enter your email address and we\'ll send you a code to reset your password.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // Email field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'Enter your email address',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: ValidationFunctions.validateEmail,
                  enabled: !isLoading,
                ),
                
                const SizedBox(height: 32),
                
                // Reset password button
                CustomButton(
                  text: 'Send Reset Code',
                  onPressed: isLoading ? null : _resetPassword,
                  isLoading: isLoading,
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
                            'What happens next?',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. We\'ll send a 6-digit code to your email\n'
                        '2. Enter the code on the next screen\n'
                        '3. Create a new password\n'
                        '4. Sign in with your new password',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Back to sign in
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Remember your password? '),
                    TextButton(
                      onPressed: isLoading ? null : () {
                        context.pop();
                      },
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
