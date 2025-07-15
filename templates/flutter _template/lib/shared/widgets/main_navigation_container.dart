import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/wallet/screens/my_seed_wallet_screen.dart';
import '../../features/groups/screens/groups_screen.dart';
import '../../features/investments/screens/investments_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/auth/providers/user_provider.dart';
import 'custom_bottom_navigation.dart';

// Import standardized dialogs
import 'dialogs/dialogs.dart';

/// Wrapper for HomeScreen without bottom navigation
class _HomeScreenWrapper extends ConsumerWidget {
  const _HomeScreenWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create a custom version that extracts only the body content
    return const HomeScreen();
  }
}

/// Wrapper for WalletScreen without bottom navigation
class _WalletScreenWrapper extends ConsumerWidget {
  const _WalletScreenWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create a custom version that extracts only the body content
    return const MySeedWalletScreen();
  }
}

/// Wrapper for GroupsScreen without bottom navigation
class _GroupsScreenWrapper extends ConsumerWidget {
  const _GroupsScreenWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create a custom version that extracts only the body content
    return const GroupsScreen();
  }
}

/// Wrapper for InvestmentsScreen without bottom navigation
class _InvestmentsScreenWrapper extends ConsumerWidget {
  const _InvestmentsScreenWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create a custom version that extracts only the body content
    return const InvestmentsScreen();
  }
}

/// Wrapper for SettingsScreen without bottom navigation
class _SettingsScreenWrapper extends ConsumerWidget {
  const _SettingsScreenWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create a custom version that extracts only the body content
    return const SettingsScreen();
  }
}

/// Main navigation container that provides smooth fade transitions between tabs
/// without full screen rebuilds. Uses IndexedStack to maintain widget states.
class MainNavigationContainer extends ConsumerStatefulWidget {
  final BottomNavItem initialTab;

  const MainNavigationContainer({
    super.key,
    this.initialTab = BottomNavItem.home,
  });

  @override
  ConsumerState<MainNavigationContainer> createState() =>
      _MainNavigationContainerState();
}

class _MainNavigationContainerState
    extends ConsumerState<MainNavigationContainer>
    with TickerProviderStateMixin {
  late BottomNavItem _currentTab;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // List of main screens
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;

    // Initialize fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Initialize screens using wrapper classes that don't include bottom navigation
    _screens = [
      const _HomeScreenWrapper(),
      const _WalletScreenWrapper(),
      const _GroupsScreenWrapper(),
      const _InvestmentsScreenWrapper(),
      const _SettingsScreenWrapper(),
    ];

    // Start with fade in
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _handleTabChange(BottomNavItem newTab) {
    if (_currentTab == newTab) return;

    setState(() {
      _currentTab = newTab;
    });

    // Update the provider
    ref.read(currentNavTabProvider.notifier).state = newTab;

    // Trigger fade animation
    _fadeController.reset();
    _fadeController.forward();
  }

  int _getTabIndex(BottomNavItem tab) {
    switch (tab) {
      case BottomNavItem.home:
        return 0;
      case BottomNavItem.wallet:
        return 1;
      case BottomNavItem.groups:
        return 2;
      case BottomNavItem.investments:
        return 3;
      case BottomNavItem.settings:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isKycCompleted = user?.isKycCompleted ?? false;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
          index: _getTabIndex(_currentTab),
          children: _screens,
        ),
      ),
      bottomNavigationBar: PersistentBottomNavigation(
        currentTab: _currentTab,
        onTabChanged: (tab) {
          // Check KYC requirements before allowing navigation
          if (tab.requiresKyc && !isKycCompleted) {
            _showAccessRestrictedDialog(tab);
            return;
          }
          _handleTabChange(tab);
        },
      ),
    );
  }

  void _showAccessRestrictedDialog(BottomNavItem item) {
    final featureName = _getFeatureName(item);
    final message = _getAccessRestrictedMessage(item);

    BaseDialog.show(
      context: context,
      dialog: BaseDialog(
        title: 'Access Restricted',
        titleIcon: Icons.lock_outline,
        titleColor: Colors.orange,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Only KYC-approved users can access $featureName.',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          DialogButton(
            text: 'Cancel',
            type: DialogButtonType.text,
            onPressed: () => Navigator.pop(context),
          ),
          DialogButton(
            text: 'Complete KYC',
            type: DialogButtonType.primary,
            icon: Icons.verified_user,
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/kyc');
            },
          ),
        ],
      ),
    );
  }

  String _getFeatureName(BottomNavItem item) {
    switch (item) {
      case BottomNavItem.wallet:
        return 'Wallet';
      case BottomNavItem.groups:
        return 'Groups';
      case BottomNavItem.investments:
        return 'My Investments';
      default:
        return 'this feature';
    }
  }

  String _getAccessRestrictedMessage(BottomNavItem item) {
    switch (item) {
      case BottomNavItem.wallet:
        return 'Complete your KYC verification to access wallet features.';
      case BottomNavItem.groups:
        return 'Complete your KYC verification to join investment groups.';
      case BottomNavItem.investments:
        return 'Complete your KYC verification to access your investment portfolio.';
      default:
        return 'Complete your KYC verification to access this feature.';
    }
  }
}
