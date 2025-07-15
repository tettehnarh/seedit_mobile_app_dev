import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/utils/app_theme.dart';
import 'core/navigation/navigation_service.dart';
import 'core/auth/global_auth_listener.dart';
import 'features/auth/screens/sign_in_screen.dart';
import 'features/auth/screens/sign_up_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/password_reset_otp_screen.dart';
import 'features/auth/screens/create_new_password_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/email_verification_screen.dart';
import 'features/auth/screens/forced_password_change_screen.dart';

import 'features/wallet/screens/wallet_add_screen.dart';
import 'features/wallet/screens/transaction_history_screen.dart';
import 'features/wallet/screens/top_up_screen.dart';
import 'features/wallet/screens/withdraw_screen.dart';
import 'features/wallet/screens/success_screen.dart';
import 'features/wallet/screens/paystack_webview_screen.dart';
import 'features/wallet/screens/my_seed_wallet_screen.dart';
import 'features/wallet/screens/wallet_top_up_screen.dart';
import 'features/wallet/screens/wallet_transactions_screen.dart';
import 'features/wallet/models/wallet_models.dart';
import 'shared/widgets/main_navigation_container.dart';
import 'shared/widgets/custom_bottom_navigation.dart';

import 'features/investments/screens/fund_details_screen.dart';
import 'features/investments/screens/investment_amount_screen.dart';
import 'features/investments/screens/payment_summary_screen.dart';
import 'features/investments/screens/wallet_selection_screen.dart';
import 'features/investments/screens/payment_options_screen.dart';
import 'features/investments/screens/funds_screen.dart';

import 'features/goals/screens/goals_screen.dart';

import 'features/kyc/screens/kyc_verification_screen.dart';
import 'features/kyc/screens/kyc_personal_info_screen.dart';
import 'features/kyc/screens/kyc_next_of_kin_screen.dart';
import 'features/kyc/screens/kyc_financial_info_screen.dart';

import 'features/kyc/screens/kyc_documents_screen.dart';
import 'features/groups/screens/group_detail_screen.dart';
import 'features/groups/screens/group_form_screen.dart';
import 'features/groups/screens/group_contribution_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/settings/screens/kyc_details_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/settings/screens/change_password_screen.dart';
import 'features/settings/screens/personal_info_screen.dart';
import 'features/settings/screens/notification_settings_screen.dart';
import 'features/settings/screens/help_center_screen.dart';
import 'features/settings/screens/contact_support_screen.dart';
import 'features/settings/screens/payment_methods_screen.dart';
import 'features/settings/screens/privacy_policy_screen.dart';
import 'features/settings/screens/terms_of_service_screen.dart';
import 'features/settings/screens/edit_profile_screen.dart';
import 'features/settings/screens/kyc_information_screen.dart';

void main() {
  runApp(const ProviderScope(child: SeeditMobileApp()));
}

class SeeditMobileApp extends StatelessWidget {
  const SeeditMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalAuthListenerWidget(
      child: MaterialApp(
        title: 'SeedIt Mobile App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        navigatorKey: NavigationService().navigatorKey,
        home: const SplashScreen(),
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/sign-in': (context) => const SignInScreen(),
          '/sign-up': (context) => const SignUpScreen(),
          '/email-verification': (context) => const EmailVerificationScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/password-reset-otp': (context) => const PasswordResetOtpScreen(),
          '/create-new-password': (context) => const CreateNewPasswordScreen(),
          '/forced-password-change': (context) =>
              const ForcedPasswordChangeScreen(),

          '/home': (context) =>
              const MainNavigationContainer(initialTab: BottomNavItem.home),
          '/wallet': (context) =>
              const MainNavigationContainer(initialTab: BottomNavItem.wallet),
          '/groups': (context) =>
              const MainNavigationContainer(initialTab: BottomNavItem.groups),
          '/investments': (context) => const MainNavigationContainer(
            initialTab: BottomNavItem.investments,
          ),
          '/goals': (context) => const GoalsScreen(),

          // Individual wallet screens (not part of main navigation)
          '/wallet/add': (context) => const WalletAddScreen(),
          '/wallet/top-up': (context) => const TopUpScreen(),
          '/wallet/withdraw': (context) => const WithdrawScreen(),
          '/wallet/my-seed': (context) => const MySeedWalletScreen(),
          '/wallet/top-up-new': (context) => const WalletTopUpScreen(),
          '/wallet/transactions': (context) => const WalletTransactionsScreen(),
          '/paystack-payment': (context) {
            final args =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;
            if (args != null) {
              return PaystackWebViewScreen(
                authorizationUrl: args['authorization_url'],
                reference: args['reference'],
                transactionId: args['transaction_id'] ?? '',
                onPaymentComplete: (result) {
                  // Navigate directly to transaction history to show the new transaction
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/transaction-history',
                    (route) => route.settings.name == '/home',
                    arguments: {
                      'showSuccessMessage': true,
                      'paymentData': {
                        'type': args['transaction_type'] ?? 'investment_top_up',
                        'amount': args['amount'],
                        'fund_name': args['fund_name'],
                        'reference': args['reference'],
                      },
                    },
                  );
                },
                onPaymentCancelled: () {
                  Navigator.pop(context);
                },
              );
            }
            return const PlaceholderScreen(title: 'Payment Error');
          },
          '/funds': (context) => const FundsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/kyc-details': (context) => const KycDetailsScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/transaction-history': (context) => const TransactionHistoryScreen(),
          '/kyc': (context) => const KycVerificationScreen(),
          '/kyc/personal-info': (context) => const KycPersonalInfoScreen(),
          '/kyc/next-of-kin': (context) => const KycNextOfKinScreen(),
          '/kyc/financial-info': (context) => const KycFinancialInfoScreen(),

          '/kyc/documents': (context) => const KycDocumentsScreen(),
          '/group-detail': (context) {
            final args =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;
            if (args != null && args['groupId'] != null) {
              return GroupDetailScreen(groupId: args['groupId']);
            }
            return const PlaceholderScreen(title: 'Group Detail');
          },
          '/group-form': (context) {
            final args =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;
            if (args != null && args['group'] != null) {
              return GroupFormScreen(group: args['group']);
            }
            return const GroupFormScreen(); // For creating new groups
          },
          '/group-contribution': (context) {
            final args =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;
            if (args != null && args['group'] != null) {
              return GroupContributionScreen(group: args['group']);
            }
            return const PlaceholderScreen(title: 'Group Contribution');
          },
          '/portfolio': (context) =>
              const PlaceholderScreen(title: 'Portfolio'),
          '/history': (context) => const PlaceholderScreen(title: 'History'),
          '/transfer': (context) => const PlaceholderScreen(title: 'Transfer'),

          // Settings screens
          '/change-password': (context) => const ChangePasswordScreen(),
          '/personal-info': (context) => const PersonalInfoScreen(),
          '/notification-settings': (context) =>
              const NotificationSettingsScreen(),
          '/help-center': (context) => const HelpCenterScreen(),
          '/contact-support': (context) => const ContactSupportScreen(),
          '/payment-methods': (context) => const PaymentMethodsScreen(),
          '/privacy-policy': (context) => const PrivacyPolicyScreen(),
          '/terms-of-service': (context) => const TermsOfServiceScreen(),
          '/edit-profile': (context) => const EditProfileScreen(),
          '/kyc-information': (context) => const KycInformationScreen(),
          '/add-funds/bank': (context) =>
              const PlaceholderScreen(title: 'Add Funds - Bank'),
          '/add-funds/card': (context) =>
              const PlaceholderScreen(title: 'Add Funds - Card'),
          '/withdraw/bank': (context) =>
              const PlaceholderScreen(title: 'Withdraw - Bank'),
          '/fund/details': (context) {
            final args =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;
            if (args != null && args['fund'] != null) {
              return FundDetailsScreen(fund: args['fund']);
            }
            return const PlaceholderScreen(title: 'Fund Details');
          },
          '/investment/amount': (context) {
            final args =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;
            if (args != null && args['fund'] != null) {
              return InvestmentAmountScreen(fund: args['fund']);
            }
            return const PlaceholderScreen(title: 'Investment Amount');
          },
          '/investment/wallet-selection': (context) {
            final args =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;
            if (args != null &&
                args['fund'] != null &&
                args['amount'] != null) {
              return WalletSelectionScreen(
                fund: args['fund'],
                amount: args['amount'],
              );
            }
            return const PlaceholderScreen(title: 'Wallet Selection');
          },
          '/investment/payment-options': (context) {
            final args =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;
            if (args != null &&
                args['fund'] != null &&
                args['amount'] != null) {
              return PaymentOptionsScreen(
                fund: args['fund'],
                amount: args['amount'],
                wallet: args['wallet'] is PaymentMethod ? args['wallet'] : null,
              );
            }
            return const PlaceholderScreen(title: 'Payment Options');
          },
          '/investment/payment-summary': (context) {
            final args =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;
            if (args != null &&
                args['fund'] != null &&
                args['amount'] != null &&
                args['paymentMethod'] != null) {
              return PaymentSummaryScreen(
                fund: args['fund'],
                amount: args['amount'],
                paymentMethod: args['paymentMethod'],
                wallet: args['wallet'] is PaymentMethod ? args['wallet'] : null,
              );
            }
            return const PlaceholderScreen(title: 'Payment Summary');
          },

          '/funds/all': (context) =>
              const PlaceholderScreen(title: 'All Funds'),

          '/portfolio/details': (context) =>
              const PlaceholderScreen(title: 'Portfolio Details'),

          '/success': (context) {
            final args =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;
            if (args != null) {
              return SuccessScreen(transactionData: args);
            }
            return const PlaceholderScreen(title: 'Success');
          },
        },
      ),
    );
  }
}

// Placeholder screens will be replaced with actual implementations

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text(
              '$title Screen',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coming Soon!',
              style: TextStyle(fontSize: 16, color: AppTheme.companyInfoColor),
            ),
          ],
        ),
      ),
    );
  }
}
