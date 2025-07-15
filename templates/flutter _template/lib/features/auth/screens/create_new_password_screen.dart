import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

// Import standardized dialogs
import '../../../shared/widgets/dialogs/dialogs.dart';

class CreateNewPasswordScreen extends ConsumerStatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  ConsumerState<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState
    extends ConsumerState<CreateNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'create_new_password_form');
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _email;
  String? _otp;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isCreating = false;

  // Password strength tracking
  int _passwordStrength = 0;
  List<String> _passwordRequirements = [];

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get email and OTP passed from OTP verification screen
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _email = args['email'] as String?;
      _otp = args['otp'] as String?;
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    int strength = 0;
    List<String> requirements = [];

    // Check length
    if (password.length >= 8) {
      strength++;
    } else {
      requirements.add('At least 8 characters');
    }

    // Check for uppercase letter
    if (password.contains(RegExp(r'[A-Z]'))) {
      strength++;
    } else {
      requirements.add('One uppercase letter');
    }

    // Check for lowercase letter
    if (password.contains(RegExp(r'[a-z]'))) {
      strength++;
    } else {
      requirements.add('One lowercase letter');
    }

    // Check for number
    if (password.contains(RegExp(r'[0-9]'))) {
      strength++;
    } else {
      requirements.add('One number');
    }

    // Check for special character
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      strength++;
    } else {
      requirements.add('One special character');
    }

    setState(() {
      _passwordStrength = strength;
      _passwordRequirements = requirements;
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
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

  Color _getStrengthColor() {
    switch (_passwordStrength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow[700]!;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStrengthText() {
    switch (_passwordStrength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      case 5:
        return 'Very Strong';
      default:
        return '';
    }
  }

  Future<void> _createNewPassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (_email == null || _otp == null) return;

    setState(() {
      _isCreating = true;
    });

    try {
      // Show loading dialog
      LoadingDialogManager.show(
        context: context,
        title: 'Creating New Password',
        message: 'Please wait while we update your password...',
        icon: Icons.lock_reset,
      );

      final success = await ref
          .read(authProvider.notifier)
          .resetPassword(
            email: _email!,
            otp: _otp!,
            newPassword: _passwordController.text,
          );

      // Dismiss loading dialog
      LoadingDialogManager.dismiss();

      if (mounted) {
        if (success) {
          // Show success dialog
          await MessageDialog.showSuccess(
            context: context,
            title: 'Password Updated Successfully',
            message:
                'Your password has been updated. You will now be logged out for security.',
          );

          // Perform logout and navigate to login
          await ref.read(authProvider.notifier).signOut();

          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/sign-in',
              (route) => false,
            );
          }
        } else {
          final error = ref.read(authErrorProvider);
          await MessageDialog.showError(
            context: context,
            title: 'Password Update Failed',
            message: error ?? 'Unable to update your password.',
            details:
                'Please try again or contact support if the problem persists.',
          );
        }
      }
    } catch (e) {
      // Dismiss loading dialog
      LoadingDialogManager.dismiss();

      if (mounted) {
        await MessageDialog.showError(
          context: context,
          title: 'Update Error',
          message: 'Unable to update your password.',
          details: 'Please check your internet connection and try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
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
          'Create New Password',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                const Center(
                  child: Text(
                    'Create New Password',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                      fontFamily: 'Montserrat',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                // Subtitle
                Center(
                  child: Text(
                    'Your new password must be different from your previous password',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontFamily: 'Montserrat',
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 40),

                // New Password field
                CustomTextField(
                  controller: _passwordController,
                  label: 'New Password',
                  hint: 'Enter your new password',
                  obscureText: !_isPasswordVisible,
                  validator: _validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Password strength indicator
                if (_passwordController.text.isNotEmpty) ...[
                  Row(
                    children: [
                      Text(
                        'Password Strength: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Text(
                        _getStrengthText(),
                        style: TextStyle(
                          fontSize: 14,
                          color: _getStrengthColor(),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _passwordStrength / 5,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getStrengthColor(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Confirm Password field
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password',
                  hint: 'Re-enter your new password',
                  obscureText: !_isConfirmPasswordVisible,
                  validator: _validateConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Password requirements
                if (_passwordRequirements.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password Requirements:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...(_passwordRequirements.map(
                          (requirement) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  requirement,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Create Password button
                CustomButton(
                  text: 'Update Password',
                  onPressed:
                      _passwordStrength >= 3 &&
                          _passwordController.text ==
                              _confirmPasswordController.text &&
                          !_isCreating
                      ? _createNewPassword
                      : null,
                  isLoading: _isCreating,
                ),

                const SizedBox(height: 24),

                // Security note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.security, size: 20, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'For your security, you will be automatically logged out after updating your password.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
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
      ),
    );
  }
}
