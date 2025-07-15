import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'config/amplify_config.dart' as config;
import 'shared/providers/auth_provider.dart';
import 'features/auth/screens/sign_in_screen.dart';
import 'features/auth/screens/sign_up_screen.dart';
import 'features/auth/screens/email_verification_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/reset_password_confirm_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/edit_profile_screen.dart';
import 'features/kyc/screens/kyc_verification_screen.dart';
import 'features/security/screens/security_settings_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/funds/screens/fund_discovery_screen.dart';
import 'features/investment/screens/investment_order_screen.dart';
import 'features/portfolio/screens/portfolio_dashboard_screen.dart';
import 'features/group_investment/screens/group_discovery_screen.dart';
import 'features/sip/screens/sip_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await config.AmplifyConfig.configureAmplify();
  } catch (e) {
    debugPrint('Failed to configure Amplify: $e');
  }

  runApp(const ProviderScope(child: SeedItApp()));
}

class SeedItApp extends ConsumerWidget {
  const SeedItApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'SeedIt',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/auth/sign-in',
  routes: [
    // Auth routes
    GoRoute(
      path: '/auth/sign-in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/auth/sign-up',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/auth/email-verification',
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return EmailVerificationScreen(email: email);
      },
    ),
    GoRoute(
      path: '/auth/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/auth/reset-password-confirm',
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return ResetPasswordConfirmScreen(email: email);
      },
    ),

    // Main app routes
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

    // Profile routes
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfileScreen(),
    ),

    // KYC routes
    GoRoute(
      path: '/kyc',
      builder: (context, state) => const KycVerificationScreen(),
    ),

    // Security routes
    GoRoute(
      path: '/security',
      builder: (context, state) => const SecuritySettingsScreen(),
    ),

    // Onboarding routes
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Fund routes
    GoRoute(
      path: '/funds',
      builder: (context, state) => const FundDiscoveryScreen(),
    ),

    // Investment routes
    GoRoute(
      path: '/investment/order/:fundId',
      builder: (context, state) {
        final fundId = state.pathParameters['fundId']!;
        return InvestmentOrderScreen(fundId: fundId);
      },
    ),

    // Portfolio routes
    GoRoute(
      path: '/portfolio',
      builder: (context, state) => const PortfolioDashboardScreen(),
    ),

    // Group investment routes
    GoRoute(
      path: '/groups',
      builder: (context, state) => const GroupDiscoveryScreen(),
    ),

    // SIP routes
    GoRoute(
      path: '/sip',
      builder: (context, state) => const SIPDashboardScreen(),
    ),
  ],
);

// Placeholder home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SeedIt Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              context.push('/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement sign out
              context.go('/auth/sign-in');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to SeedIt!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your investment journey starts here.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/portfolio');
                      },
                      icon: const Icon(Icons.pie_chart),
                      label: const Text('My Portfolio'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/funds');
                      },
                      icon: const Icon(Icons.explore),
                      label: const Text('Discover Funds'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/groups');
                      },
                      icon: const Icon(Icons.group),
                      label: const Text('Groups'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/sip');
                      },
                      icon: const Icon(Icons.schedule),
                      label: const Text('SIP & Auto'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
