import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../core/utils/validation_functions.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  AccountType _accountType = AccountType.individual;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final request = SignUpRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      accountType: _accountType,
    );

    try {
      await ref.read(authStateProvider.notifier).signUp(request);
      if (mounted) {
        context.push('/auth/email-verification', extra: _emailController.text.trim());
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
        title: const Text('Create Account'),
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
                // Header
                Text(
                  'Join SeedIt',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your investment journey today',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Account type selection
                Text(
                  'Account Type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<AccountType>(
                        title: const Text('Individual'),
                        value: AccountType.individual,
                        groupValue: _accountType,
                        onChanged: isLoading ? null : (value) {
                          setState(() {
                            _accountType = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<AccountType>(
                        title: const Text('Corporate'),
                        value: AccountType.corporate,
                        groupValue: _accountType,
                        onChanged: isLoading ? null : (value) {
                          setState(() {
                            _accountType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Name fields
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _firstNameController,
                        label: 'First Name',
                        prefixIcon: Icons.person_outlined,
                        validator: ValidationFunctions.validateName,
                        enabled: !isLoading,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        prefixIcon: Icons.person_outlined,
                        validator: ValidationFunctions.validateName,
                        enabled: !isLoading,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
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
                
                // Phone field
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: ValidationFunctions.validatePhoneNumber,
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
                
                // Confirm password field
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
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
                
                const SizedBox(height: 24),
                
                // Terms and conditions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: isLoading ? null : (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: isLoading ? null : () {
                          setState(() {
                            _acceptTerms = !_acceptTerms;
                          });
                        },
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Sign up button
                CustomButton(
                  text: 'Create Account',
                  onPressed: isLoading ? null : _signUp,
                  isLoading: isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
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
