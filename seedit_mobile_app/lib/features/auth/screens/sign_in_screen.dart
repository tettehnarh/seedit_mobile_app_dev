import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../core/utils/validation_functions.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    final request = SignInRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    try {
      await ref.read(authStateProvider.notifier).signIn(request);
      if (mounted) {
        context.go('/home');
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // Logo and title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to your SeedIt account',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Email field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: ValidationFunctions.validateEmail,
                  enabled: !isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // Password field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
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
                
                // Remember me and forgot password
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: isLoading ? null : (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    const Text('Remember me'),
                    const Spacer(),
                    TextButton(
                      onPressed: isLoading ? null : () {
                        context.push('/auth/forgot-password');
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Sign in button
                CustomButton(
                  text: 'Sign In',
                  onPressed: isLoading ? null : _signIn,
                  isLoading: isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Biometric sign in (if available)
                OutlinedButton.icon(
                  onPressed: isLoading ? null : () {
                    // TODO: Implement biometric authentication
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Biometric authentication coming soon'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Sign in with Biometrics'),
                ),
                
                const Spacer(),
                
                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: isLoading ? null : () {
                        context.push('/auth/sign-up');
                      },
                      child: const Text('Sign Up'),
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
