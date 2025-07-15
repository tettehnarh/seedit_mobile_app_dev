import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/app_theme.dart';
import '../../features/auth/providers/user_provider.dart';

// Import standardized dialogs
import 'dialogs/dialogs.dart';

enum BottomNavItem { home, wallet, groups, investments, settings }

// Provider for managing current navigation tab
final currentNavTabProvider = StateProvider<BottomNavItem>(
  (ref) => BottomNavItem.home,
);

/// Persistent bottom navigation widget that can be used across all main screens
/// Optimized for performance with selective rebuilding and fade transitions
class PersistentBottomNavigation extends ConsumerWidget {
  final BottomNavItem currentTab;
  final Function(BottomNavItem)? onTabChanged;

  const PersistentBottomNavigation({
    super.key,
    required this.currentTab,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active tab indicator at the top edge - now inside SafeArea
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildTopIndicator(),
            ),

            // Navigation items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _OptimizedNavItem(
                      item: BottomNavItem.home,
                      currentTab: currentTab,
                      label: 'Home',
                      svgPath: 'assets/images/img_home.svg',
                      fallbackIcon: Icons.home,
                      onTabChanged: onTabChanged,
                    ),
                  ),
                  Expanded(
                    child: _OptimizedNavItem(
                      item: BottomNavItem.wallet,
                      currentTab: currentTab,
                      label: 'Wallet',
                      svgPath: 'assets/images/img_wallet.svg',
                      fallbackIcon: Icons.account_balance_wallet,
                      requiresKyc: true,
                      onTabChanged: onTabChanged,
                    ),
                  ),
                  Expanded(
                    child: _OptimizedNavItem(
                      item: BottomNavItem.groups,
                      currentTab: currentTab,
                      label: 'Groups',
                      svgPath: 'assets/images/img_group.svg',
                      fallbackIcon: Icons.group,
                      requiresKyc: true,
                      onTabChanged: onTabChanged,
                    ),
                  ),
                  Expanded(
                    child: _OptimizedNavItem(
                      item: BottomNavItem.investments,
                      currentTab: currentTab,
                      label: 'My Investments',
                      svgPath: 'assets/images/img_dashboard.svg',
                      fallbackIcon: Icons.dashboard,
                      requiresKyc: true,
                      onTabChanged: onTabChanged,
                    ),
                  ),
                  Expanded(
                    child: _OptimizedNavItem(
                      item: BottomNavItem.settings,
                      currentTab: currentTab,
                      label: 'Settings',
                      svgPath: 'assets/images/img_settings_small.svg',
                      fallbackIcon: Icons.settings,
                      onTabChanged: onTabChanged,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the active tab indicator positioned at the top edge
  /// Ensures perfect alignment with the center of each tab's icon by accounting for padding
  /// Now positioned within SafeArea for consistent device-specific safe area handling
  Widget _buildTopIndicator() {
    return SizedBox(
      height: 3,
      child: Row(
        children: [
          // Home tab indicator - matches icon positioning with padding offset
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ), // Match nav item padding exactly
              child: Center(
                child: currentTab == BottomNavItem.home
                    ? Container(
                        width: 20,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          // Wallet tab indicator - matches icon positioning with padding offset
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ), // Match nav item padding
              child: Center(
                child: currentTab == BottomNavItem.wallet
                    ? Container(
                        width: 20,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          // Groups tab indicator - matches icon positioning with padding offset
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ), // Match nav item padding
              child: Center(
                child: currentTab == BottomNavItem.groups
                    ? Container(
                        width: 20,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          // Investments tab indicator - matches icon positioning with padding offset
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ), // Match nav item padding
              child: Center(
                child: currentTab == BottomNavItem.investments
                    ? Container(
                        width: 20,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          // Settings tab indicator - matches icon positioning with padding offset
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ), // Match nav item padding
              child: Center(
                child: currentTab == BottomNavItem.settings
                    ? Container(
                        width: 20,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Optimized navigation item widget with selective rebuilding
class _OptimizedNavItem extends ConsumerWidget {
  final BottomNavItem item;
  final BottomNavItem currentTab;
  final String label;
  final String? svgPath;
  final IconData fallbackIcon;
  final bool requiresKyc;
  final Function(BottomNavItem)? onTabChanged;

  const _OptimizedNavItem({
    required this.item,
    required this.currentTab,
    required this.label,
    this.svgPath,
    required this.fallbackIcon,
    this.requiresKyc = false,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch KYC status if this item requires it
    final isKycCompleted = requiresKyc
        ? ref.watch(
            currentUserProvider.select((user) => user?.isKycCompleted ?? false),
          )
        : true;

    final isSelected = currentTab == item;
    final isEnabled = !requiresKyc || isKycCompleted;

    // Dynamic icon colors based on state
    final Color color;
    if (isSelected) {
      color = AppTheme.primaryColor; // Active tab - primary color
    } else if (isEnabled) {
      color = Colors.grey[600]!; // Inactive but enabled - gray color
    } else {
      color = Colors.grey[400]!; // Disabled - muted color
    }

    return GestureDetector(
      onTap: () =>
          _handleNavigation(context, ref, item, requiresKyc, isKycCompleted),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon (no more local indicator since it's now at the top edge)
            SizedBox(
              width: 22,
              height: 22,
              child: svgPath != null
                  ? SvgPicture.asset(
                      svgPath!,
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      width: 22,
                      height: 22,
                    )
                  : Icon(fallbackIcon, size: 22, color: color),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(
    BuildContext context,
    WidgetRef ref,
    BottomNavItem item,
    bool requiresKyc,
    bool isKycCompleted,
  ) {
    // Don't navigate if already on the same tab
    if (currentTab == item) return;

    // Check KYC requirements
    if (requiresKyc && !isKycCompleted) {
      _showAccessRestrictedDialog(context, item);
      return;
    }

    // Update the current tab in provider for instant visual feedback
    ref.read(currentNavTabProvider.notifier).state = item;

    // Use callback for navigation if provided, otherwise fall back to direct navigation
    if (onTabChanged != null) {
      onTabChanged!(item);
    } else {
      // Fallback to direct navigation for backward compatibility
      switch (item) {
        case BottomNavItem.home:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case BottomNavItem.wallet:
          Navigator.pushReplacementNamed(context, '/wallet');
          break;
        case BottomNavItem.groups:
          Navigator.pushReplacementNamed(context, '/groups');
          break;
        case BottomNavItem.investments:
          Navigator.pushReplacementNamed(context, '/investments');
          break;
        case BottomNavItem.settings:
          Navigator.pushReplacementNamed(context, '/settings');
          break;
      }
    }
  }

  void _showAccessRestrictedDialog(BuildContext context, BottomNavItem item) {
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

class CustomBottomNavigation extends StatelessWidget {
  final BottomNavItem currentIndex;
  final Function(BottomNavItem) onTap;
  final bool isKycCompleted;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isKycCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildNavItem(
                  BottomNavItem.home,
                  'Home',
                  'assets/images/img_home.svg',
                  Icons.home,
                ),
              ),

              Expanded(
                child: _buildNavItem(
                  BottomNavItem.wallet,
                  'Wallet',
                  'assets/images/img_wallet.svg',
                  Icons.account_balance_wallet,
                  requiresKyc: true,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  BottomNavItem.groups,
                  'Groups',
                  'assets/images/img_group.svg',
                  Icons.group,
                  requiresKyc: true,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  BottomNavItem.investments,
                  'My Investments',
                  'assets/images/img_dashboard.svg',
                  Icons.dashboard,
                  requiresKyc: true,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  BottomNavItem.settings,
                  'Settings',
                  'assets/images/img_settings_small.svg',
                  Icons.settings,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BottomNavItem item,
    String label,
    String? svgPath,
    IconData fallbackIcon, {
    bool requiresKyc = false,
  }) {
    final isSelected = currentIndex == item;
    final isEnabled = !requiresKyc || isKycCompleted;
    final color = isSelected
        ? AppTheme.primaryColor
        : (isEnabled ? Colors.grey[600]! : Colors.grey[400]!);

    return GestureDetector(
      onTap: () {
        if (requiresKyc && !isKycCompleted) {
          // Show KYC required message
          return;
        }
        onTap(item);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: svgPath != null
                  ? SvgPicture.asset(
                      svgPath,
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      width: 22,
                      height: 22,
                    )
                  : Icon(fallbackIcon, size: 22, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

mixin BottomNavigationMixin<T extends StatefulWidget> on State<T> {
  BottomNavItem get currentNavItem;
  bool get isKycCompleted;

  Widget buildBottomNavigation() {
    return CustomBottomNavigation(
      currentIndex: currentNavItem,
      isKycCompleted: isKycCompleted,
      onTap: (item) => _handleNavigation(item),
    );
  }

  void _handleNavigation(BottomNavItem item) {
    if (item == currentNavItem) return;

    switch (item) {
      case BottomNavItem.home:
        Navigator.pushReplacementNamed(context, '/home');
        break;

      case BottomNavItem.wallet:
        if (isKycCompleted) {
          Navigator.pushNamed(context, '/wallet');
        } else {
          _showAccessRestrictedDialog(
            'Wallet',
            'Complete your KYC verification to access wallet features.',
          );
        }
        break;
      case BottomNavItem.groups:
        if (isKycCompleted) {
          Navigator.pushNamed(context, '/groups');
        } else {
          _showAccessRestrictedDialog(
            'Investment Groups',
            'Complete your KYC verification to join investment groups.',
          );
        }
        break;
      case BottomNavItem.investments:
        if (isKycCompleted) {
          Navigator.pushNamed(context, '/investments');
        } else {
          _showAccessRestrictedDialog(
            'My Investments',
            'Complete your KYC verification to access your investment portfolio.',
          );
        }
        break;
      case BottomNavItem.settings:
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  void _showAccessRestrictedDialog(String featureName, String message) {
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
}

// Extension to get route name from BottomNavItem
extension BottomNavItemExtension on BottomNavItem {
  String get routeName {
    switch (this) {
      case BottomNavItem.home:
        return '/home';
      case BottomNavItem.wallet:
        return '/wallet';
      case BottomNavItem.groups:
        return '/groups';
      case BottomNavItem.investments:
        return '/investments';
      case BottomNavItem.settings:
        return '/settings';
    }
  }

  String get label {
    switch (this) {
      case BottomNavItem.home:
        return 'Home';
      case BottomNavItem.wallet:
        return 'Wallet';
      case BottomNavItem.groups:
        return 'Groups';
      case BottomNavItem.investments:
        return 'My Investments';
      case BottomNavItem.settings:
        return 'Settings';
    }
  }

  IconData get icon {
    switch (this) {
      case BottomNavItem.home:
        return Icons.home;
      case BottomNavItem.wallet:
        return Icons.account_balance_wallet;
      case BottomNavItem.groups:
        return Icons.group;
      case BottomNavItem.investments:
        return Icons.dashboard;
      case BottomNavItem.settings:
        return Icons.settings;
    }
  }

  bool get requiresKyc {
    switch (this) {
      case BottomNavItem.home:
      case BottomNavItem.settings:
        return false;
      case BottomNavItem.wallet:
      case BottomNavItem.groups:
      case BottomNavItem.investments:
        return true;
    }
  }
}
