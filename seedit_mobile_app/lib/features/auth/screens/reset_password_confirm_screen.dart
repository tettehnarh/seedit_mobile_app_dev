import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../core/utils/validation_functions.dart';

class ResetPasswordConfirmScreen extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordConfirmScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<ResetPasswordConfirmScreen> createState() => _ResetPasswordConfirmScreenState();
}

class _ResetPasswordConfirmScreenState extends ConsumerState<ResetPasswordConfirmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _confirmResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authStateProvider.notifier).confirmPasswordReset(
        widget.email,
        _passwordController.text,
        _codeController.text.trim(),
      );
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successfully!'),
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
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
        child: SingleChildScrollView(
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
                  'Create New Password',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Enter the verification code sent to ${widget.email} and create a new password.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // Verification code field
                CustomTextField(
                  controller: _codeController,
                  label: 'Verification Code',
                  hintText: 'Enter 6-digit code',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.security,
                  validator: ValidationFunctions.validateConfirmationCode,
                  enabled: !isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // New password field
                CustomTextField(
                  controller: _passwordController,
                  label: 'New Password',
                  hintText: 'Enter your new password',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: ValidationFunctions.validatePassword,
                  enabled: !isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // Confirm password field
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password',
                  hintText: 'Confirm your new password',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: _validateConfirmPassword,
                  enabled: !isLoading,
                ),
                
                const SizedBox(height: 32),
                
                // Password requirements
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password Requirements:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• At least 8 characters long\n'
                        '• Contains uppercase and lowercase letters\n'
                        '• Contains at least one number\n'
                        '• Contains at least one special character',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Reset password button
                CustomButton(
                  text: 'Reset Password',
                  onPressed: isLoading ? null : _confirmResetPassword,
                  isLoading: isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Back to sign in
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Remember your password? '),
                    TextButton(
                      onPressed: isLoading ? null : () {
                        context.go('/auth/sign-in');
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
