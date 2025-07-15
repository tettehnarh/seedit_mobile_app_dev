import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../../../core/utils/validation_functions.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../providers/sign_in_provider.dart';
import '../providers/biometric_provider.dart';
import '../providers/auth_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _handleSignIn(
    SignInNotifier signInNotifier,
    BuildContext context,
  ) async {
    if (_formKey.currentState!.validate()) {
      await signInNotifier.signInWithoutValidation(context);
    }
  }

  Future<void> _handleBiometricSignIn(BuildContext context) async {
    try {
      final authNotifier = ref.read(authProvider.notifier);
      final result = await authNotifier.signInWithBiometric();

      if (result['success'] == true) {
        // Navigate to home screen
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['error'] ?? 'Biometric authentication failed',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final signInState = ref.watch(signInProvider);
    final signInNotifier = ref.read(signInProvider.notifier);

    // Check for automatic logout message from navigation arguments
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final autoLogoutMessage = arguments?['message'] as String?;
    final isAutoLogout = arguments?['autoLogout'] as bool? ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  const SizedBox(height: 32),

                  // Welcome back text
                  const Text(
                    "WELCOME\nBACK!",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Subtitle
                  Text(
                    "Sign in to continue to your account",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: AppTheme.companyInfoColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Show automatic logout message if present
                  if (autoLogoutMessage != null &&
                      autoLogoutMessage.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color:
                            isAutoLogout &&
                                autoLogoutMessage.toLowerCase().contains('kyc')
                            ? Colors.green.shade50
                            : Colors.blue.shade50,
                        border: Border.all(
                          color:
                              isAutoLogout &&
                                  autoLogoutMessage.toLowerCase().contains(
                                    'kyc',
                                  )
                              ? Colors.green.shade300
                              : Colors.blue.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isAutoLogout &&
                                    autoLogoutMessage.toLowerCase().contains(
                                      'kyc',
                                    )
                                ? Icons.check_circle
                                : Icons.info,
                            color:
                                isAutoLogout &&
                                    autoLogoutMessage.toLowerCase().contains(
                                      'kyc',
                                    )
                                ? Colors.green.shade600
                                : Colors.blue.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              autoLogoutMessage,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color:
                                    isAutoLogout &&
                                        autoLogoutMessage
                                            .toLowerCase()
                                            .contains('kyc')
                                    ? Colors.green.shade800
                                    : Colors.blue.shade800,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Email field
                  CustomTextField(
                    controller: signInNotifier.emailController,
                    label: 'Email Address',
                    hint: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    validator: ValidationFunctions.validateEmail,
                    onChanged: (value) => signInNotifier.setEmail(value),
                  ),
                  const SizedBox(height: 20),

                  // Password field
                  CustomTextField(
                    controller: signInNotifier.passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    obscureText: signInState.obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        signInState.obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.companyInfoColor,
                        size: 20,
                      ),
                      onPressed: signInNotifier.togglePasswordVisibility,
                    ),
                    validator: ValidationFunctions.validatePassword,
                    onChanged: (value) => signInNotifier.setPassword(value),
                  ),
                  const SizedBox(height: 12),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () =>
                          signInNotifier.navigateToForgotPassword(context),
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Error message
                  if (signInState.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              signInState.errorMessage!,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (signInState.errorMessage != null)
                    const SizedBox(height: 16),

                  // Sign in button
                  CustomButton(
                    text: 'SIGN IN',
                    onPressed: signInState.isLoading
                        ? null
                        : () => _handleSignIn(signInNotifier, context),
                    isLoading: signInState.isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Biometric authentication button
                  Consumer(
                    builder: (context, ref, child) {
                      final biometricState = ref.watch(biometricProvider);

                      if (biometricState.isAvailable &&
                          biometricState.isEnabled) {
                        final biometricNotifier = ref.read(
                          biometricProvider.notifier,
                        );
                        final biometricTypeName = biometricNotifier
                            .getBiometricTypeName();

                        return Column(
                          children: [
                            // OR divider
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Biometric button
                            OutlinedButton.icon(
                              onPressed: signInState.isLoading
                                  ? null
                                  : () => _handleBiometricSignIn(context),
                              icon: const Icon(
                                Icons.fingerprint,
                                size: 24,
                                color: AppTheme.primaryColor,
                              ),
                              label: Text(
                                'Sign in with $biometricTypeName',
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                side: const BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),

                  // Sign up link
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.companyInfoColor,
                          fontFamily: 'Montserrat',
                        ),
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () =>
                                  signInNotifier.navigateToSignUp(context),
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
