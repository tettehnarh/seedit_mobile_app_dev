import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/utils/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';

import '../../../shared/widgets/custom_button.dart';

import '../../auth/providers/user_provider.dart';
import '../../auth/models/user_model.dart';
import '../../investments/providers/investment_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../goals/providers/goals_provider.dart' as goals_providers;
import '../../goals/widgets/goal_reminder_bottom_sheet.dart';

import 'dart:developer' as developer;

/// Utility function to format monetary values
String formatCurrency(double? value, {String currency = 'GHS'}) {
  return CurrencyFormatter.formatAmountWithCurrencyOrHyphen(
    value,
    currency: currency,
  );
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isReminderSheetShowing = false;

  @override
  void initState() {
    super.initState();
    // Automatically refresh user data (including KYC status) when home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshDataOnLoad();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning to home screen (e.g., after investment)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshInvestmentDataIfNeeded();
    });
  }

  /// Refresh investment data when returning to home screen
  Future<void> _refreshInvestmentDataIfNeeded() async {
    try {
      developer.log('🏠 [HOME] Refreshing investment data on screen return...');

      // Use the global refresh provider to ensure complete data refresh
      await ref.read(globalInvestmentRefreshProvider)();

      // Also refresh recent transactions for home screen display
      await ref.read(transactionProvider.notifier).loadRecentTransactions();

      developer.log(
        '✅ [HOME] Investment data refreshed successfully on return',
      );
    } catch (e) {
      developer.log('❌ [HOME] Error refreshing investment data on return: $e');
    }
  }

  /// Refresh data when home screen loads to ensure current status
  Future<void> _refreshDataOnLoad() async {
    try {
      developer.log('🏠 [HOME] Starting data refresh on load...');

      // Refresh user data to ensure KYC status is current
      // This is critical for displaying the correct KYC status card
      developer.log('🏠 [HOME] Refreshing user data for current KYC status...');
      await ref.read(userProvider.notifier).refreshUserData();

      // Only refresh investment data and transactions for home screen content
      developer.log('🏠 [HOME] Refreshing investment data...');
      await ref.read(investmentProvider.notifier).refreshInvestmentData();

      // Check if funds were loaded
      final fundsCount = ref.read(availableFundsProvider).length;
      developer.log(
        '🏠 [HOME] After refresh, available funds count: $fundsCount',
      );

      // Load recent transactions for home screen preview
      developer.log('🏠 [HOME] Loading recent transactions...');
      await ref.read(transactionProvider.notifier).loadRecentTransactions();

      // Load goal reminders for modal display
      developer.log('🏠 [HOME] Loading goal reminders...');
      await ref
          .read(goals_providers.goalRemindersProvider.notifier)
          .loadReminders();

      developer.log('✅ [HOME] Data refresh completed successfully');

      // Show reminder bottom sheet if reminders are available
      _checkAndShowReminders();
    } catch (e) {
      // Silently handle errors during background refresh
      developer.log('❌ [HOME] Error refreshing data on home screen load: $e');
    }
  }

  /// Check for goal reminders and show bottom sheet if available
  void _checkAndShowReminders() {
    // Use a post-frame callback to ensure the widget is built before showing modal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final remindersState = ref.read(goals_providers.goalRemindersProvider);
      final activeReminders = remindersState.activeReminders;

      if (activeReminders.isNotEmpty && mounted && !_isReminderSheetShowing) {
        developer.log(
          '🔔 [HOME] Showing reminder bottom sheet for ${activeReminders.length} reminders',
        );

        _isReminderSheetShowing = true;

        // Show the bottom sheet modal
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) =>
              GoalReminderBottomSheet(reminders: activeReminders),
        ).then((_) {
          // Reset flag when bottom sheet is dismissed
          _isReminderSheetShowing = false;
        });
      } else {
        developer.log(
          '🔔 [HOME] No active reminders to show or sheet already showing',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _getWelcomeDisplayName(user),
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
              // Notification badge
              Consumer(
                builder: (context, ref, child) {
                  final unreadCount = ref.watch(
                    unreadNotificationsCountProvider,
                  );
                  if (unreadCount > 0) {
                    return Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),

          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          developer.log('🔄 [HOME] Pull-to-refresh triggered');

          // CRITICAL FIX: Refresh user data first to ensure KYC status is current
          // This prevents the KYC status from reverting to incorrect values
          developer.log(
            '🔄 [HOME] Refreshing user data for KYC status sync...',
          );
          await ref.read(userProvider.notifier).refreshUserData();

          // Then refresh other data in parallel
          developer.log('🔄 [HOME] Refreshing other data...');
          await Future.wait([
            ref.read(investmentProvider.notifier).refreshInvestmentData(),
            ref.read(transactionProvider.notifier).loadRecentTransactions(),
            ref
                .read(goals_providers.goalRemindersProvider.notifier)
                .loadReminders(),
          ]);

          developer.log('✅ [HOME] Pull-to-refresh completed');

          // Check for reminders after refresh
          _checkAndShowReminders();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KYC Status Card (show for all non-approved statuses)
              if (user != null && _shouldShowKycStatusCard(user))
                _buildKycStatusCard(context, user),
              const SizedBox(height: 20),

              // Investment content - show based on KYC status
              if (user?.isKycCompleted == true) ...[
                // Available Investment Funds Card (KYC approved users)
                _buildAvailableFundsCard(),
                const SizedBox(height: 20),
                // Portfolio Summary Card (KYC approved users)
                _buildPortfolioSummaryCard(),
                const SizedBox(height: 20),
                // Portfolio Overview Card (KYC approved users)
                _buildPortfolioOverviewCard(),
                const SizedBox(height: 20),
                // Recent Transactions Card (KYC approved users)
                _buildRecentTransactionsCard(),
                const SizedBox(height: 20),
              ] else ...[
                // Restricted access cards for non-KYC approved users
                _buildRestrictedPortfolioCard(),
                const SizedBox(height: 20),
                _buildRestrictedTransactionsCard(),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 100), // Space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableFundsCard() {
    final availableFunds = ref.watch(availableFundsProvider);
    final isLoading = ref.watch(investmentLoadingProvider);
    final errorMessage = ref.watch(investmentErrorProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Text(
              'Available Funds',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            )
          else if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Failed to load funds. Tap to retry.',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref
                            .read(investmentProvider.notifier)
                            .refreshInvestmentData();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (availableFunds.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No investment funds available at the moment.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Show all available funds in a horizontal scrollable list
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: availableFunds.length,
                itemBuilder: (context, index) {
                  final fund = availableFunds[index];
                  return _buildFundCard(fund);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFundCard(fund) {
    return GestureDetector(
      onTap: () {
        // Navigate to fund details screen
        Navigator.pushNamed(
          context,
          '/fund/details',
          arguments: {'fund': fund},
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: BoxBorder.all(
            color: Colors.black.withValues(alpha: 0.05),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey.withValues(alpha: 0.2),
          //     blurRadius: 5,
          //     spreadRadius: 1,
          //     offset: const Offset(0, 2),
          //     blurStyle: BlurStyle.inner,
          //   ),
          // ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fund icon at the top
            SvgPicture.asset(
              'assets/images/fund_icon.svg',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 8),

            // Fund details below the icon
            Text(
              fund.name,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              "Min: ${formatCurrency(fund.minimumInvestment)}",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            // Performance and risk info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: _getRiskColor(fund.riskLevel).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    fund.riskLevel.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: _getRiskColor(fund.riskLevel),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  CurrencyFormatter.formatPercentage(fund.returnRate),
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'high':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _buildPortfolioSummaryCard() {
    final portfolioOverview = ref.watch(portfolioOverviewProvider);
    final isLoading = ref.watch(investmentLoadingProvider);

    // Extract data from portfolio overview or fallback to portfolio summary
    final portfolioSummary = portfolioOverview?['portfolio_summary'];
    final currentValue = portfolioSummary != null
        ? double.tryParse(
                portfolioSummary['current_value']?.toString() ?? '0',
              ) ??
              0.0
        : ref.watch(portfolioProvider)?.currentValue ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Balance Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOTAL BALANCE',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isLoading
                    ? 'Loading...'
                    : CurrencyFormatter.formatAmountWithCurrency(currentValue),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Action Buttons Section
          Row(
            children: [
              // Top Up Button
              Expanded(
                child: CustomButton(
                  text: 'Top Up',
                  backgroundColor: Colors.white,
                  textColor: AppTheme.primaryColor,
                  height: 48,
                  borderRadius: 12,
                  onPressed: () {
                    // Navigate to investment top up screen
                    Navigator.pushNamed(context, '/wallet/top-up');
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Withdraw Button
              Expanded(
                child: CustomButton(
                  text: 'Withdraw',
                  isOutlined: true,
                  backgroundColor: Colors.transparent,
                  textColor: Colors.white,
                  height: 48,
                  borderRadius: 12,
                  onPressed: () {
                    // Navigate to withdrawal screen
                    Navigator.pushNamed(context, '/wallet/withdraw');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioOverviewCard() {
    final portfolioOverview = ref.watch(portfolioOverviewProvider);
    final isLoading = ref.watch(investmentLoadingProvider);

    // Extract data from portfolio overview or fallback to portfolio summary
    final portfolioSummary = portfolioOverview?['portfolio_summary'];
    final totalInvested = portfolioSummary != null
        ? double.tryParse(
                portfolioSummary['total_invested']?.toString() ?? '0',
              ) ??
              0.0
        : ref.watch(portfolioProvider)?.totalInvested ?? 0.0;

    final totalGains = portfolioSummary != null
        ? double.tryParse(portfolioSummary['total_gains']?.toString() ?? '0') ??
              0.0
        : ref.watch(portfolioProvider)?.totalProfitLoss ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Left column - Total Contribution
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Contribution',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLoading ? 'Loading...' : formatCurrency(totalInvested),
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          // Vertical divider
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            width: 1,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(0.5),
            ),
          ),
          // Right column - Gains
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gains',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLoading
                      ? 'Loading...'
                      : totalGains != 0
                      ? '${totalGains >= 0 ? '+' : ''}${formatCurrency(totalGains.abs())}'
                      : '-',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: totalGains >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsCard() {
    final recentTransactions = ref.watch(recentTransactionsProvider);
    final isLoading = ref.watch(transactionLoadingProvider);
    final errorMessage = ref.watch(transactionErrorProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontFamily: 'Montserrat',
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to transaction history
                  Navigator.pushNamed(context, '/transaction-history');
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryColor,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          else if (errorMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Failed to load transactions. Tap to retry.',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref
                          .read(transactionProvider.notifier)
                          .loadRecentTransactions();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (recentTransactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No recent transactions found.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            // Show only the first 2 transactions
            ...recentTransactions
                .take(2)
                .map((transaction) => _buildTransactionItem(transaction)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(transaction) {
    final statusColor = _getTransactionStatusColor(transaction.status);
    final icon = _getTransactionIcon(transaction.transactionType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTransactionTypeDisplay(transaction.transactionType),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                    fontFamily: 'Montserrat',
                  ),
                ),
                Text(
                  transaction.fundName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Montserrat',
                  ),
                ),
                Text(
                  _formatTransactionDate(transaction.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatCurrency(transaction.amount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontFamily: 'Montserrat',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getTransactionStatusDisplay(transaction.status),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTransactionStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'investment':
      case 'top_up':
        return Icons.trending_up;
      case 'withdrawal':
        return Icons.trending_down;
      case 'dividend':
        return Icons.account_balance_wallet;
      default:
        return Icons.swap_horiz;
    }
  }

  String _getTransactionTypeDisplay(String type) {
    switch (type.toLowerCase()) {
      case 'investment':
        return 'Investment Purchase';
      case 'top_up':
        return 'Investment Top-up';
      case 'withdrawal':
        return 'Withdrawal';
      case 'dividend':
        return 'Dividend Payment';
      default:
        return type.toUpperCase();
    }
  }

  String _getTransactionStatusDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Determine if KYC status card should be shown
  bool _shouldShowKycStatusCard(UserModel user) {
    final status = user.kycStatus.toLowerCase();

    // Show KYC card for all statuses except approved
    // This includes: not_started, in_progress, pending_review, under_review, rejected
    return status != 'approved';
  }

  Widget _buildRestrictedPortfolioCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[300]!,
            Colors.grey[400]!,
            Colors.grey[500]!,
            Colors.grey[600]!,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "PORTFOLIO ACCESS\nRESTRICTED",
                      maxLines: 3,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Complete KYC verification to view your portfolio',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestrictedTransactionsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.lock_outline, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'KYC Required',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.visibility_off_outlined,
                  color: Colors.grey[400],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Transaction History Unavailable',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete your KYC verification to view transaction history',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycStatusCard(BuildContext context, UserModel user) {
    // Determine card content based on KYC status
    String statusText;
    String mainText;
    String descriptionText;
    List<Color> gradientColors;
    bool isInteractive = true;
    String? estimatedTime;
    String? nextStepsInfo;

    switch (user.kycStatus.toLowerCase()) {
      case 'not_started':
        statusText = "LET'S GET TO KNOW YOU!";
        mainText = "VERIFY ACCOUNT";
        descriptionText = "Complete KYC to access all features";
        gradientColors = [AppTheme.primaryColor, const Color(0xFFBAD339)];
        break;
      case 'in_progress':
        statusText = "KYC IN PROGRESS";
        mainText = "CONTINUE VERIFICATION";
        descriptionText = "Complete remaining KYC sections";
        gradientColors = [const Color(0xFFFF9800), const Color(0xFFFFC107)];
        break;
      case 'pending_review':
        statusText = "KYC UNDER REVIEW";
        mainText = "REVIEW IN PROGRESS";
        descriptionText = "Your KYC is being reviewed by our team";
        gradientColors = [
          const Color(0xFF9E9E9E),
          const Color(0xFFBDBDBD),
        ]; // Gray colors for inactive state
        isInteractive = false; // Disable interaction
        estimatedTime = "1-3 business days";
        nextStepsInfo = "We'll notify you once the review is complete";
        break;
      case 'approved':
        statusText = "KYC APPROVED";
        mainText = "VERIFICATION COMPLETE";
        descriptionText = "Your account is fully verified";
        gradientColors = [const Color(0xFF4CAF50), const Color(0xFF8BC34A)];
        isInteractive = false; // No need to navigate when approved
        break;
      case 'rejected':
        statusText = "KYC REJECTED";
        mainText = "RESUBMIT DOCUMENTS";
        descriptionText = "Please update and resubmit your KYC";
        gradientColors = [const Color(0xFFF44336), const Color(0xFFFF5722)];
        nextStepsInfo = "Review feedback and resubmit required documents";
        break;
      default:
        statusText = "KYC PENDING";
        mainText = "VERIFY ACCOUNT";
        descriptionText = "Complete KYC to access all features";
        gradientColors = [AppTheme.primaryColor, const Color(0xFFBAD339)];
    }

    return GestureDetector(
      onTap: isInteractive
          ? () {
              // Navigate to KYC verification screen only if interactive
              Navigator.pushNamed(context, '/kyc');
            }
          : null, // Disable tap when not interactive
      child: Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(1.61, 2.55),
              end: const Alignment(-0.16, -0.3),
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(20),
            // Add opacity for inactive state
            boxShadow: isInteractive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SvgPicture.asset(
                        'assets/images/img_user_white_a700.svg',
                        width: 23,
                        height: 23,
                      ),
                      const SizedBox(height: 7),
                      SizedBox(
                        width: 180,
                        child: Text(
                          mainText,
                          maxLines: 3,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.visible,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        descriptionText,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isInteractive
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      // Additional information for specific statuses
                      if (estimatedTime != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Est. time: $estimatedTime',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (nextStepsInfo != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                nextStepsInfo,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 120, // Set a fixed height for the container
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/img_shield_tick.svg',
                          width: 100,
                          height: 100,
                          colorFilter: isInteractive
                              ? null
                              : ColorFilter.mode(
                                  Colors.white.withValues(alpha: 0.6),
                                  BlendMode.modulate,
                                ),
                        ),
                        // Show pending review indicator
                        if (!isInteractive &&
                            user.kycStatus.toLowerCase() == 'pending_review')
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.hourglass_empty,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get the appropriate display name for the welcome message
  /// Uses KYC-verified name for approved users, fallback for others
  String _getWelcomeDisplayName(UserModel? user) {
    if (user == null) {
      return 'Seedit Investor';
    }

    // Check if user has completed KYC verification
    if (user.kycStatus == 'approved') {
      // Use authoritative name from KYC data for verified users
      final authoritativeName = user.authoritativeFirstName;
      if (authoritativeName.isNotEmpty) {
        return authoritativeName;
      }

      // Fallback to full authoritative name if first name is empty
      final fullAuthoritativeName = user.authoritativeFullName;
      if (fullAuthoritativeName.isNotEmpty) {
        return fullAuthoritativeName;
      }
    }

    // For non-KYC verified users, use static fallback text
    return 'Seedit Investor';
  }
}
