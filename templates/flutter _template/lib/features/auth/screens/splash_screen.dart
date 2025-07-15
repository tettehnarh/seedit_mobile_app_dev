import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../../../core/utils/storage_utils.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation - exact match with reference
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start animation
    _animationController.forward();

    // Initialize splash and handle navigation
    _initializeSplash();
  }

  /// Initialize splash screen and determine navigation - exact match with reference
  Future<void> _initializeSplash() async {
    try {
      // Wait for the splash duration - exact match with reference (3 seconds)
      await Future.delayed(const Duration(seconds: 3));

      // Check if context is still mounted
      if (!mounted) return;

      // Check onboarding completion status - exact match with reference
      final onboardingCompleted = await StorageUtils.isOnboardingCompleted();

      if (!onboardingCompleted) {
        // Navigate to onboarding screen
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
        return;
      }

      // Initialize authentication - adapted for Riverpod
      if (!mounted) return;
      final authState = ref.read(authProvider);

      if (!mounted) return;

      if (!authState.isAuthenticated) {
        // Navigate to sign in screen
        Navigator.pushReplacementNamed(context, '/sign-in');
        return;
      }

      // User is authenticated, navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Fallback navigation to onboarding
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_buildLogoSection()],
                ),
              ),
              _buildFooterSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget for the logo and app name - exact match with reference
  Widget _buildLogoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo image with company info overlaid at the bottom
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Logo image
            FadeTransition(
              opacity: _fadeAnimation,
              child: Image.asset(
                'assets/images/seedit_logo.png',
                width: 400,
                height: 400,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if logo is not found
                  return Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppTheme.primaryColor,
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      size: 100,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            // Company info positioned at the bottom of the logo
            Positioned(
              bottom: 30, // Adjust this value to move text up or down
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'a product of the\nInvestiture Fund Managers',
                  style: AppTheme.bodyTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Loading indicator
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            strokeWidth: 3,
          ),
        ),
      ],
    );
  }

  /// Footer section with regulatory text - exact match with reference
  Widget _buildFooterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Container(
            width: 300,
            margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                'regulated by\nThe Securities & Exchange Commission, Ghana',
                maxLines: 2,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
                style: AppTheme.smallTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
