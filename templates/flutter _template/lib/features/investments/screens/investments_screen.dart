import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:developer' as developer;
import '../../../core/utils/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';

import '../providers/investment_provider.dart';
import '../providers/fund_subscription_provider.dart';
import '../widgets/goal_overview_card.dart';

import '../../groups/providers/groups_provider.dart';
import '../../groups/models/group_models.dart';
import '../../auth/providers/user_provider.dart';
import '../../goals/providers/goals_provider.dart' as goals;

class InvestmentsScreen extends ConsumerStatefulWidget {
  const InvestmentsScreen({super.key});

  @override
  ConsumerState<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends ConsumerState<InvestmentsScreen> {
  @override
  void initState() {
    super.initState();
    // Load investment data immediately when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInvestmentData();

      // Load groups data for the groups card
      ref.read(groupsProvider.notifier).loadMyGroups();

      // Load goals data for the goals overview card
      ref.read(goals.goalsProvider.notifier).loadGoals();
      ref.read(goals.goalsDashboardProvider.notifier).loadDashboard();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Refresh data when returning to screen (e.g., after making investments)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshInvestmentDataIfNeeded();
    });
  }

  /// Load investment data and user data (including KYC status) on screen initialization
  Future<void> _loadInvestmentData() async {
    try {
      // Force load both portfolio and subscription data concurrently
      // Use refreshInvestmentData to ensure fresh data from backend
      final investmentNotifier = ref.read(investmentProvider.notifier);
      final subscriptionNotifier = ref.read(fundSubscriptionProvider.notifier);
      final userNotifier = ref.read(userProvider.notifier);

      final userDataFuture = userNotifier.refreshUserData();
      final investmentFuture = investmentNotifier.refreshInvestmentData();
      final subscriptionFuture = subscriptionNotifier.loadAllSubscriptions();

      final futures = [userDataFuture, investmentFuture, subscriptionFuture];

      await Future.wait(
        futures,
        eagerError: false,
      ); // Don't fail fast, let both complete

      // Log state after loading
      final newSubscriptions = ref.read(fundSubscriptionProvider).subscriptions;
      final newPortfolio = ref.read(portfolioProvider);
      final newIsLoading = ref.read(investmentLoadingProvider);
      final newSubscriptionLoading = ref.read(fundSubscriptionLoadingProvider);

      developer.log('📊 [INVESTMENTS_SCREEN] State after loading:');
      developer.log('   - Subscriptions count: ${newSubscriptions.length}');
      developer.log(
        '   - Portfolio: ${newPortfolio != null ? "exists" : "null"}',
      );
      developer.log('   - Investment loading: $newIsLoading');
      developer.log('   - Subscription loading: $newSubscriptionLoading');

      if (newSubscriptions.isNotEmpty) {
        developer.log('📋 [INVESTMENTS_SCREEN] New subscriptions:');
        newSubscriptions.forEach((fundId, subscription) {
          developer.log(
            '   - Fund: ${subscription.fundName} (${subscription.fundId}) - Subscribed: ${subscription.isSubscribed}',
          );
        });
      }

      developer.log(
        '✅ [INVESTMENTS_SCREEN] Investment data loaded successfully',
      );
    } catch (e, stackTrace) {
      final errorTimestamp = DateTime.now().toIso8601String();
      developer.log(
        '❌ [INVESTMENTS_SCREEN] Error loading investment data at $errorTimestamp: $e',
        error: e,
        stackTrace: stackTrace,
      );

      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to load investment data. Pull to refresh to try again.',
              style: TextStyle(fontFamily: 'Montserrat'),
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _loadInvestmentData(),
            ),
          ),
        );
      }
    }
  }

  /// Refresh investment data when returning to screen
  Future<void> _refreshInvestmentDataIfNeeded() async {
    final startTimestamp = DateTime.now().toIso8601String();
    developer.log(
      '🔄 [INVESTMENTS_SCREEN] _refreshInvestmentDataIfNeeded() started at $startTimestamp',
    );

    try {
      // Always refresh subscription data to ensure we have the latest status
      // This is important when returning from fund details or after investments
      final isLoading = ref.read(fundSubscriptionLoadingProvider);
      final currentSubscriptions = ref
          .read(fundSubscriptionProvider)
          .subscriptions;

      developer.log('📊 [INVESTMENTS_SCREEN] Refresh check state:');
      developer.log('   - Is loading: $isLoading');
      developer.log(
        '   - Current subscriptions count: ${currentSubscriptions.length}',
      );

      // Only refresh if not currently loading
      if (!isLoading) {
        developer.log(
          '🔄 [INVESTMENTS_SCREEN] Refreshing subscription and goals data on screen return...',
        );

        // Refresh subscription data
        await ref
            .read(fundSubscriptionProvider.notifier)
            .loadAllSubscriptions();

        // Refresh goals data to show newly created goals
        ref.read(goals.goalsProvider.notifier).loadGoals();
        ref.read(goals.goalsDashboardProvider.notifier).loadDashboard();

        final newSubscriptions = ref
            .read(fundSubscriptionProvider)
            .subscriptions;
        developer.log(
          '✅ [INVESTMENTS_SCREEN] Subscription and goals data refreshed on screen return',
        );
        developer.log(
          '   - New subscriptions count: ${newSubscriptions.length}',
        );
      } else {
        developer.log(
          '⏸️ [INVESTMENTS_SCREEN] Skipping refresh - already loading',
        );
      }
    } catch (e) {
      final errorTimestamp = DateTime.now().toIso8601String();
      developer.log(
        '❌ [INVESTMENTS_SCREEN] Error refreshing subscription data at $errorTimestamp: $e',
        error: e,
      );
      // Error handling is done in the providers
    }
  }

  @override
  Widget build(BuildContext context) {
    final buildTimestamp = DateTime.now().toIso8601String();
    developer.log('🎨 [INVESTMENTS_SCREEN] build() called at $buildTimestamp');

    final portfolio = ref.watch(portfolioProvider);
    final subscriptions = ref.watch(fundSubscriptionProvider).subscriptions;
    final isLoading = ref.watch(investmentLoadingProvider);
    final subscriptionLoading = ref.watch(fundSubscriptionLoadingProvider);
    final investmentError = ref.watch(investmentErrorProvider);
    final subscriptionError = ref.watch(fundSubscriptionErrorProvider);

    // Log current UI state
    developer.log('🎨 [INVESTMENTS_SCREEN] UI State:');
    developer.log('   - Portfolio: ${portfolio != null ? "exists" : "null"}');
    developer.log('   - Subscriptions count: ${subscriptions.length}');
    developer.log('   - Investment loading: $isLoading');
    developer.log('   - Subscription loading: $subscriptionLoading');
    developer.log('   - Investment error: $investmentError');
    developer.log('   - Subscription error: $subscriptionError');

    if (subscriptions.isNotEmpty) {
      developer.log('🎨 [INVESTMENTS_SCREEN] Available subscriptions for UI:');
      subscriptions.forEach((fundId, subscription) {
        developer.log(
          '   - ${subscription.fundName} (${subscription.fundId}): subscribed=${subscription.isSubscribed}',
        );
      });

      final subscribedFunds = subscriptions.values
          .where((s) => s.isSubscribed)
          .toList();
      developer.log(
        '🎨 [INVESTMENTS_SCREEN] Subscribed funds for display: ${subscribedFunds.length}',
      );
    }

    // Determine if this is initial loading (no data and loading)
    final isInitialLoading =
        (isLoading || subscriptionLoading) &&
        subscriptions.isEmpty &&
        portfolio == null;

    // Check for errors
    final hasError = investmentError != null || subscriptionError != null;

    developer.log('🎨 [INVESTMENTS_SCREEN] UI Decision:');
    developer.log('   - Is initial loading: $isInitialLoading');
    developer.log('   - Has error: $hasError');
    developer.log(
      '   - Will show: ${isInitialLoading
          ? "loading state"
          : hasError && subscriptions.isEmpty && portfolio == null
          ? "error state"
          : "content"}',
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading:
            false, // Remove back button for main navigation screen
        centerTitle: true,
        title: const Text(
          'My Investments',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
      body: isInitialLoading
          ? _buildInitialLoadingState()
          : hasError && subscriptions.isEmpty && portfolio == null
          ? _buildErrorState(investmentError ?? subscriptionError!)
          : RefreshIndicator(
              onRefresh: () async {
                // Refresh user data (including KYC status), investment data, and goals
                await Future.wait([
                  ref.read(userProvider.notifier).refreshUserData(),
                  ref.read(investmentProvider.notifier).refreshInvestmentData(),
                  ref
                      .read(fundSubscriptionProvider.notifier)
                      .loadAllSubscriptions(),
                ]);

                // Also refresh goals data
                ref.read(goals.goalsProvider.notifier).loadGoals();
                ref.read(goals.goalsDashboardProvider.notifier).loadDashboard();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // My Subscribed Funds Card
                    _buildSubscribedFundsCard(
                      context,
                      subscriptions,
                      isLoading || subscriptionLoading,
                    ),
                    const SizedBox(height: 20),

                    // My Groups Card
                    _buildGroupsCard(context),
                    const SizedBox(height: 20),

                    // Personal Goals Overview Card
                    const GoalOverviewCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSubscribedFundsCard(
    BuildContext context,
    Map<String, FundSubscription> subscriptions,
    bool isLoading,
  ) {
    if (isLoading) {
      return _buildSubscribedFundsSkeletonLoader();
    }

    final subscribedFunds = subscriptions.values
        .where((subscription) => subscription.isSubscribed)
        .toList();

    if (subscribedFunds.isEmpty) {
      return _buildEmptyInvestments(context);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
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
                'My Subscribed Funds',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                '${subscribedFunds.length} fund${subscribedFunds.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...subscribedFunds.map(
            (subscription) => _buildSubscribedFundItem(context, subscription),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyInvestments(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.dashboard,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No investments yet',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Start your investment journey by exploring available funds and making your first investment.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/funds');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Explore Funds',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribedFundItem(
    BuildContext context,
    FundSubscription subscription,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          // Get the fund from available funds using the subscription's fundId
          final availableFunds = ref.read(availableFundsProvider);

          try {
            final fund = availableFunds.firstWhere(
              (f) => f.id == subscription.fundId,
            );

            Navigator.pushNamed(
              context,
              '/fund/details',
              arguments: {'fund': fund},
            );
          } catch (e) {
            // Fund not found in available funds, show error
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fund details not available. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.fundName,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Invested: ${CurrencyFormatter.formatAmountWithCurrency(subscription.totalInvested)}',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
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
                'My Groups',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/groups');
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGroupsContent(context),
        ],
      ),
    );
  }

  Widget _buildGroupsContent(BuildContext context) {
    final groupsState = ref.watch(groupsProvider);

    if (groupsState.isLoading) {
      return _buildGroupsSkeletonLoader();
    }

    if (groupsState.error != null) {
      return _buildGroupsErrorState();
    }

    // Show all groups where user is a member (regardless of contributions)
    final userGroups = groupsState.myGroups;

    if (userGroups.isEmpty) {
      return _buildEmptyGroupsState(context);
    }

    return Column(
      children: [
        ...userGroups
            .take(3)
            .map((group) => _buildGroupContributionItem(group)),
        if (userGroups.length > 3) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/groups'),
            child: Text(
              'View ${userGroups.length - 3} more groups',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGroupsSkeletonLoader() {
    return Column(
      children: List.generate(
        2,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupsErrorState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Failed to load groups',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => ref.read(groupsProvider.notifier).loadAllGroupsData(),
            child: const Text(
              'Tap to retry',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                color: AppTheme.primaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGroupsState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(Icons.group_outlined, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No groups joined yet',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join investment groups to collaborate with others',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/groups');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Explore Groups',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupContributionItem(InvestmentGroup group) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/group-detail',
          arguments: {'groupId': group.id},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.group,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    group.userContributions > 0
                        ? 'Your contribution: ${CurrencyFormatter.formatAmount(group.userContributions)}'
                        : 'Role: ${(group.userMembership?.role ?? 'member').toUpperCase()}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  /// Build error state with retry option
  Widget _buildErrorState(String errorMessage) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(Icons.error_outline, color: Colors.red, size: 40),
          ),
          const SizedBox(height: 24),
          const Text(
            'Failed to Load Data',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              // Clear errors and retry loading
              ref.read(investmentProvider.notifier).clearError();
              ref.read(fundSubscriptionProvider.notifier).clearError();
              await _loadInvestmentData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text(
              'Retry',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build initial loading state for the entire screen
  Widget _buildInitialLoadingState() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Loading Your Investments',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please wait while we fetch your portfolio data...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build skeleton loader for subscribed funds section
  Widget _buildSubscribedFundsSkeletonLoader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 150,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 60,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Fund items skeleton
            ...List.generate(2, (index) => _buildFundItemSkeleton()),
          ],
        ),
      ),
    );
  }

  /// Build skeleton for individual fund item
  Widget _buildFundItemSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Icon skeleton
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),

          // Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),

          // Status and arrow skeleton
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 50,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
