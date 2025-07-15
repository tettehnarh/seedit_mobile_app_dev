import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/investment_models.dart';
import '../services/investment_service.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import 'fund_subscription_provider.dart';
import '../../transactions/providers/transaction_provider.dart';

import '../../../core/utils/storage_utils.dart';
import 'dart:developer' as developer;

/// State class for investment management
class InvestmentState {
  final PortfolioSummary? portfolio;
  final Map<String, dynamic>? portfolioOverview;
  final List<Fund> availableFunds;
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;

  const InvestmentState({
    this.portfolio,
    this.portfolioOverview,
    this.availableFunds = const [],
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
  });

  InvestmentState copyWith({
    PortfolioSummary? portfolio,
    Map<String, dynamic>? portfolioOverview,
    List<Fund>? availableFunds,
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    bool clearError = false,
    bool clearPortfolio = false,
    bool clearPortfolioOverview = false,
  }) {
    return InvestmentState(
      portfolio: clearPortfolio ? null : (portfolio ?? this.portfolio),
      portfolioOverview: clearPortfolioOverview
          ? null
          : (portfolioOverview ?? this.portfolioOverview),
      availableFunds: availableFunds ?? this.availableFunds,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Riverpod provider for managing investment state
class InvestmentNotifier extends StateNotifier<InvestmentState> {
  final InvestmentService _investmentService;
  final ApiClient _apiClient = ApiClient();

  InvestmentNotifier(this._investmentService) : super(const InvestmentState()) {
    _initializeInvestments();
  }

  /// Initialize investment data
  Future<void> _initializeInvestments() async {
    if (state.isInitialized) {
      developer.log('Investment data already initialized, skipping...');
      return;
    }

    try {
      developer.log('Starting investment data initialization...');
      state = state.copyWith(isLoading: true, clearError: true);

      // Load portfolio, portfolio overview, and available funds
      await Future.wait([
        _loadPortfolio(),
        _loadPortfolioOverview(),
        _loadAvailableFunds(),
      ]);

      state = state.copyWith(isLoading: false, isInitialized: true);

      developer.log(
        'Investment data initialized successfully. Available funds: ${state.availableFunds.length}',
      );
    } catch (e) {
      developer.log('Error initializing investments: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        errorMessage: 'Failed to load investment data',
      );
      developer.log(
        'Investment initialization completed with error. Available funds: ${state.availableFunds.length}',
      );
    }
  }

  /// Load user's portfolio summary
  Future<void> _loadPortfolio() async {
    try {
      final portfolio = await _investmentService.getPortfolioSummary();
      state = state.copyWith(portfolio: portfolio);
      developer.log(
        'Portfolio loaded: ${portfolio.totalInvestments} investments',
      );
    } catch (e) {
      if (e is UnauthorizedException) {
        // User not logged in or token expired
        developer.log('User not authenticated for portfolio');
        state = state.copyWith(clearPortfolio: true);
      } else {
        developer.log('Error loading portfolio: $e', error: e);
        // For demo purposes, create empty portfolio
        state = state.copyWith(portfolio: PortfolioSummary.empty());
      }
    }
  }

  /// Load portfolio overview for home screen from backend
  Future<void> _loadPortfolioOverview() async {
    try {
      developer.log('Loading portfolio overview');
      final portfolioOverview = await _investmentService.getPortfolioOverview();

      state = state.copyWith(portfolioOverview: portfolioOverview);
      developer.log('Portfolio overview loaded successfully');
    } catch (e) {
      developer.log('Error loading portfolio overview: $e', error: e);
      // Don't set error for portfolio overview as it's supplementary data
      // The main portfolio data is more important
    }
  }

  /// Load available funds for investment
  Future<void> _loadAvailableFunds() async {
    try {
      developer.log('Starting to load available funds...');
      final funds = await _investmentService.getAvailableFunds();
      state = state.copyWith(availableFunds: funds);
      developer.log(
        'Available funds loaded successfully: ${funds.length} funds',
      );

      // Log fund details for debugging
      for (final fund in funds) {
        developer.log(
          'Fund: ${fund.name} (${fund.id}) - Min: ${fund.minimumInvestment}, Price: ${fund.currentPrice}',
        );
      }
    } catch (e) {
      developer.log('Error loading available funds: $e', error: e);

      // Don't use mock data - let the UI handle empty state properly
      state = state.copyWith(
        availableFunds: [],
        errorMessage:
            'Failed to load available funds. Please check your connection and try again.',
      );

      developer.log('Available funds loading failed - empty state set');
    }
  }

  /// Refresh all investment data with retry mechanism
  Future<void> refreshInvestmentData({int retryCount = 0}) async {
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    try {
      // Log current state before refresh
      final currentState = state;
      developer.log('📊 [INVESTMENT_PROVIDER] Current state before refresh:');
      developer.log(
        '   - Portfolio: ${currentState.portfolio != null ? "exists" : "null"}',
      );
      developer.log(
        '   - Available funds count: ${currentState.availableFunds.length}',
      );
      developer.log('   - Is loading: ${currentState.isLoading}');
      developer.log('   - Is initialized: ${currentState.isInitialized}');
      developer.log('   - Error message: ${currentState.errorMessage}');

      state = state.copyWith(isLoading: true, clearError: true);
      developer.log('🚀 [INVESTMENT_PROVIDER] Set loading state to true');

      developer.log(
        '🔄 [INVESTMENT_PROVIDER] Starting concurrent data loading...',
      );
      await Future.wait([
        _loadPortfolio(),
        _loadPortfolioOverview(),
        _loadAvailableFunds(),
      ]);

      state = state.copyWith(isLoading: false);

      final endTimestamp = DateTime.now().toIso8601String();
      developer.log(
        '✅ [INVESTMENT_PROVIDER] Data refresh completed at $endTimestamp',
      );

      // Log final state after refresh
      final newState = state;
      developer.log('📊 [INVESTMENT_PROVIDER] Final state after refresh:');
      developer.log(
        '   - Portfolio: ${newState.portfolio != null ? "exists" : "null"}',
      );
      developer.log(
        '   - Available funds count: ${newState.availableFunds.length}',
      );
      developer.log('   - Is loading: ${newState.isLoading}');
      developer.log('   - Is initialized: ${newState.isInitialized}');
      developer.log('   - Error message: ${newState.errorMessage}');

      if (newState.portfolio != null) {
        developer.log('💰 [INVESTMENT_PROVIDER] Portfolio details:');
        developer.log(
          '   - Total investments: ${newState.portfolio!.totalInvestments}',
        );
        developer.log(
          '   - Total invested: ${newState.portfolio!.totalInvested}',
        );
      }

      developer.log(
        '✅ [INVESTMENT_PROVIDER] Investment data refreshed successfully',
      );
    } catch (e) {
      final errorTimestamp = DateTime.now().toIso8601String();
      developer.log(
        '❌ [INVESTMENT_PROVIDER] Error refreshing investment data at $errorTimestamp (attempt ${retryCount + 1}): $e',
        error: e,
      );

      if (retryCount < maxRetries) {
        developer.log(
          '🔄 [INVESTMENT_PROVIDER] Retrying investment data refresh in ${retryDelay.inSeconds} seconds...',
        );
        await Future.delayed(retryDelay);
        return refreshInvestmentData(retryCount: retryCount + 1);
      }

      final finalErrorMessage =
          'Failed to refresh investment data after $maxRetries attempts';
      state = state.copyWith(isLoading: false, errorMessage: finalErrorMessage);

      developer.log(
        '💥 [INVESTMENT_PROVIDER] Final error after all retries: $finalErrorMessage',
      );
    }
  }

  /// Force refresh portfolio data (useful after payments or manual updates)
  Future<void> forceRefreshPortfolio() async {
    try {
      developer.log('🔄 [INVESTMENT_PROVIDER] Force refreshing portfolio...');
      await _loadPortfolio();
      await _loadPortfolioOverview();

      if (state.portfolio != null) {
        developer.log(
          '💰 [INVESTMENT_PROVIDER] Portfolio force refreshed - Total invested: ${state.portfolio!.totalInvested}',
        );
      } else {
        developer.log(
          '⚠️ [INVESTMENT_PROVIDER] Portfolio is null after force refresh',
        );
      }
    } catch (e) {
      developer.log(
        '❌ [INVESTMENT_PROVIDER] Error force refreshing portfolio: $e',
      );
    }
  }

  /// Invest in a fund
  Future<bool> investInFund(String fundId, double amount) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final result = await _investmentService.createInvestment(
        fundId: fundId,
        amount: amount,
      );

      if (result['success'] == true) {
        // Refresh portfolio after successful investment
        await _loadPortfolio();
        state = state.copyWith(isLoading: false);
        developer.log(
          'Investment successful: \$${amount.toStringAsFixed(2)} in fund $fundId',
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['error'] ?? 'Investment failed',
        );
        return false;
      }
    } catch (e) {
      developer.log('Error investing in fund: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to process investment',
      );
      return false;
    }
  }

  /// Withdraw from investment
  Future<bool> withdrawFromInvestment(
    String investmentId,
    double amount,
  ) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final result = await _investmentService.withdrawFromInvestment(
        investmentId: investmentId,
        amount: amount,
      );

      if (result['success'] == true) {
        // Refresh portfolio after successful withdrawal
        await _loadPortfolio();
        state = state.copyWith(isLoading: false);
        developer.log(
          'Withdrawal successful: \$${amount.toStringAsFixed(2)} from investment $investmentId',
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['error'] ?? 'Withdrawal failed',
        );
        return false;
      }
    } catch (e) {
      developer.log('Error withdrawing from investment: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to process withdrawal',
      );
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear all data (for logout)
  void clearData() {
    state = const InvestmentState();
    developer.log('Investment data cleared');
  }

  /// Complete session cleanup - reset all investment data
  Future<void> clearCompleteSession() async {
    try {
      developer.log('Clearing complete investment session...');

      // Clear all cached investment data
      await StorageUtils.clearInvestmentData();

      // Reset state to initial empty state
      state = const InvestmentState();

      developer.log('Investment session cleared successfully');
    } catch (e) {
      developer.log('Error clearing investment session: $e', error: e);

      // Force reset state even if cleanup fails
      state = const InvestmentState();
    }
  }

  /// Reset state for new user session
  void resetForNewUser() {
    developer.log('Resetting investment provider for new user...');
    state = const InvestmentState();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }
}

/// Provider instances
final investmentServiceProvider = Provider<InvestmentService>(
  (ref) => InvestmentService(),
);

/// Provider for InvestmentNotifier
final investmentProvider =
    StateNotifierProvider<InvestmentNotifier, InvestmentState>((ref) {
      final investmentService = ref.read(investmentServiceProvider);
      return InvestmentNotifier(investmentService);
    });

/// Convenience providers for accessing specific parts of the investment state
final portfolioProvider = Provider<PortfolioSummary?>((ref) {
  return ref.watch(investmentProvider).portfolio;
});

final portfolioOverviewProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(investmentProvider).portfolioOverview;
});

final availableFundsProvider = Provider<List<Fund>>((ref) {
  return ref.watch(investmentProvider).availableFunds;
});

final investmentLoadingProvider = Provider<bool>((ref) {
  return ref.watch(investmentProvider).isLoading;
});

final investmentErrorProvider = Provider<String?>((ref) {
  return ref.watch(investmentProvider).errorMessage;
});

final totalInvestedProvider = Provider<double>((ref) {
  final portfolio = ref.watch(portfolioProvider);
  return portfolio?.totalInvested ?? 0.0;
});

final totalProfitLossProvider = Provider<double>((ref) {
  final portfolio = ref.watch(portfolioProvider);
  return portfolio?.totalProfitLoss ?? 0.0;
});

/// Provider for force refreshing portfolio data
final forceRefreshPortfolioProvider = Provider<Future<void> Function()>((ref) {
  return () => ref.read(investmentProvider.notifier).forceRefreshPortfolio();
});

/// Global refresh trigger for post-payment updates
/// This provider can be used to trigger a complete refresh of investment data
/// after successful payments or other critical operations
final globalInvestmentRefreshProvider = Provider<Future<void> Function()>((
  ref,
) {
  return () async {
    developer.log(
      '🔄 [GLOBAL_REFRESH] Triggering global investment refresh...',
    );

    // Execute all refreshes concurrently for better performance
    await Future.wait([
      // Force refresh investment data
      ref.read(investmentProvider.notifier).refreshInvestmentData(),

      // Refresh fund subscriptions to ensure latest subscription status
      ref.read(fundSubscriptionProvider.notifier).loadAllSubscriptions(),

      // Refresh recent transactions for home screen display
      ref.read(transactionProvider.notifier).loadRecentTransactions(),
    ]);

    developer.log('✅ [GLOBAL_REFRESH] Global investment refresh completed');
  };
});
