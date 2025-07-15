import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet_models.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import 'dart:developer' as developer;

/// State class for wallet management
class WalletState {
  final WalletSummary? walletSummary;
  final List<Transaction> transactions;
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;

  const WalletState({
    this.walletSummary,
    this.transactions = const [],
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
  });

  WalletState copyWith({
    WalletSummary? walletSummary,
    List<Transaction>? transactions,
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    bool clearError = false,
    bool clearWallet = false,
  }) {
    return WalletState(
      walletSummary: clearWallet ? null : (walletSummary ?? this.walletSummary),
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Riverpod provider for managing wallet state
class WalletNotifier extends StateNotifier<WalletState> {
  final ApiClient _apiClient = ApiClient();

  WalletNotifier() : super(const WalletState()) {
    _initializeWallet();
  }

  /// Initialize wallet data
  Future<void> _initializeWallet() async {
    developer.log('🚀 [WALLET_DEBUG] Starting wallet initialization...');
    if (state.isInitialized) {
      developer.log(
        '⚠️ [WALLET_DEBUG] Wallet already initialized, skipping...',
      );
      return;
    }

    try {
      developer.log('🔄 [WALLET_DEBUG] Setting loading state...');
      state = state.copyWith(isLoading: true, clearError: true);

      // Load wallet summary and transaction history
      developer.log(
        '🔄 [WALLET_DEBUG] Loading wallet summary and transaction history...',
      );
      await Future.wait([_loadWalletSummary(), _loadTransactionHistory()]);

      state = state.copyWith(isLoading: false, isInitialized: true);

      developer.log('✅ [WALLET_DEBUG] Wallet data initialized successfully');
    } catch (e) {
      developer.log('❌ [WALLET_DEBUG] Error initializing wallet: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        errorMessage: 'Failed to load wallet data',
      );
    }
  }

  /// Load wallet summary
  Future<void> _loadWalletSummary() async {
    try {
      developer.log('🔄 [WALLET_DEBUG] Starting wallet summary load...');
      developer.log(
        '🔍 [WALLET_DEBUG] API Client base URL: ${_apiClient.baseUrl}',
      );
      developer.log(
        '🔍 [WALLET_DEBUG] Making request to: /payments/wallet/summary/',
      );

      final response = await _apiClient.get('/payments/wallet/summary/');

      developer.log('🔍 [WALLET_DEBUG] API Response: $response');

      if (response != null) {
        developer.log(
          '🔍 [WALLET_DEBUG] Raw balance data: ${response['balance']}',
        );
        final walletSummary = WalletSummary.fromJson(response);
        state = state.copyWith(walletSummary: walletSummary);
        developer.log('✅ [WALLET_DEBUG] Wallet summary loaded successfully:');
        developer.log(
          '💰 [WALLET_DEBUG] Available Balance: \$${walletSummary.balance.availableBalance}',
        );
        developer.log(
          '💰 [WALLET_DEBUG] Total Balance: \$${walletSummary.balance.totalBalance}',
        );
        developer.log(
          '💰 [WALLET_DEBUG] Invested Amount: \$${walletSummary.balance.investedAmount}',
        );
        developer.log(
          '💰 [WALLET_DEBUG] Pending Amount: \$${walletSummary.balance.pendingAmount}',
        );
        developer.log(
          '📅 [WALLET_DEBUG] Last Updated: ${walletSummary.balance.lastUpdated}',
        );

        // Additional verification print
        print(
          '🎯 [WALLET_VERIFICATION] Parsed wallet balance: ${walletSummary.balance.totalBalance}',
        );
        print(
          '🎯 [WALLET_VERIFICATION] Available balance: ${walletSummary.balance.availableBalance}',
        );
        print(
          '🎯 [WALLET_VERIFICATION] Raw response balance: ${response['balance']}',
        );
      } else {
        developer.log('⚠️ [WALLET_DEBUG] API returned null response');
      }
    } catch (e) {
      if (e is UnauthorizedException) {
        developer.log('🔒 [WALLET_DEBUG] User not authenticated for wallet');
        state = state.copyWith(clearWallet: true);
      } else {
        developer.log(
          '❌ [WALLET_DEBUG] Error loading wallet summary: $e',
          error: e,
        );
        developer.log('🔄 [WALLET_DEBUG] Falling back to sample wallet data');
        // For demo purposes, create sample wallet
        state = state.copyWith(walletSummary: _createSampleWallet());
      }
    }
  }

  /// Load transaction history
  Future<void> _loadTransactionHistory() async {
    try {
      final response = await _apiClient.get('/payments/wallet/transactions/');

      if (response != null && response['transactions'] != null) {
        final List<dynamic> transactionsData = response['transactions'];
        final transactions = transactionsData
            .map((item) => Transaction.fromJson(item as Map<String, dynamic>))
            .toList();
        state = state.copyWith(transactions: transactions);
        developer.log(
          'Transaction history loaded: ${transactions.length} transactions',
        );
      } else {
        // For demo purposes, create sample transactions
        state = state.copyWith(transactions: _createSampleTransactions());
      }
    } catch (e) {
      developer.log('Error loading transaction history: $e', error: e);
      // For demo purposes, create sample transactions
      state = state.copyWith(transactions: _createSampleTransactions());
    }
  }

  /// Create sample wallet for demo
  WalletSummary _createSampleWallet() {
    final balance = WalletBalance(
      availableBalance: 2500.00,
      totalBalance: 5000.00,
      investedAmount: 2500.00,
      pendingAmount: 0.00,
      lastUpdated: DateTime.now(),
    );

    final paymentMethods = [
      PaymentMethod(
        id: '1',
        type: 'bank_account',
        name: 'Primary Bank Account',
        displayName: 'Bank Account ****1234',
        isDefault: true,
      ),
      PaymentMethod(
        id: '2',
        type: 'card',
        name: 'Credit Card',
        displayName: 'Visa ****5678',
        isDefault: false,
      ),
    ];

    return WalletSummary(
      balance: balance,
      recentTransactions: _createSampleTransactions().take(3).toList(),
      paymentMethods: paymentMethods,
      lastUpdated: DateTime.now(),
    );
  }

  /// Create sample transactions for demo
  List<Transaction> _createSampleTransactions() {
    return [
      Transaction(
        id: '1',
        type: 'deposit',
        amount: 1000.00,
        description: 'Bank transfer deposit',
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: 'completed',
        referenceId: 'DEP001',
      ),
      Transaction(
        id: '2',
        type: 'investment',
        amount: 500.00,
        description: 'Investment in Growth Fund',
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: 'completed',
        referenceId: 'INV001',
      ),
      Transaction(
        id: '3',
        type: 'dividend',
        amount: 25.50,
        description: 'Dividend payment from Conservative Fund',
        date: DateTime.now().subtract(const Duration(days: 5)),
        status: 'completed',
        referenceId: 'DIV001',
      ),
      Transaction(
        id: '4',
        type: 'withdrawal',
        amount: 200.00,
        description: 'Withdrawal to bank account',
        date: DateTime.now().subtract(const Duration(days: 7)),
        status: 'completed',
        referenceId: 'WTH001',
      ),
      Transaction(
        id: '5',
        type: 'investment',
        amount: 750.00,
        description: 'Investment in Aggressive Growth Fund',
        date: DateTime.now().subtract(const Duration(days: 10)),
        status: 'completed',
        referenceId: 'INV002',
      ),
    ];
  }

  /// Refresh wallet data
  Future<void> refreshWalletData() async {
    try {
      developer.log('🔄 [WALLET_DEBUG] Starting wallet data refresh...');
      state = state.copyWith(isLoading: true, clearError: true);

      await Future.wait([_loadWalletSummary(), _loadTransactionHistory()]);

      state = state.copyWith(isLoading: false);
      developer.log('✅ [WALLET_DEBUG] Wallet data refreshed successfully');

      // Log current state after refresh
      final currentBalance = state.walletSummary?.balance;
      if (currentBalance != null) {
        developer.log(
          '💰 [WALLET_DEBUG] Current balance after refresh: \$${currentBalance.totalBalance}',
        );
      }
    } catch (e) {
      developer.log(
        '❌ [WALLET_DEBUG] Error refreshing wallet data: $e',
        error: e,
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to refresh wallet data',
      );
    }
  }

  /// Add funds to wallet
  Future<bool> addFunds(double amount, String paymentMethodId) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final response = await _apiClient.postWithAuth('wallet/deposit/', {
        'amount': amount,
        'payment_method_id': paymentMethodId,
      });

      if (response['success'] == true) {
        // Refresh wallet after successful deposit
        await _loadWalletSummary();
        await _loadTransactionHistory();
        state = state.copyWith(isLoading: false);
        developer.log(
          'Funds added successfully: \$${amount.toStringAsFixed(2)}',
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response['error'] ?? 'Failed to add funds',
        );
        return false;
      }
    } catch (e) {
      developer.log('Error adding funds: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to add funds',
      );
      return false;
    }
  }

  /// Initialize Paystack wallet top-up
  Future<Map<String, dynamic>?> initializeWalletTopUp(double amount) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final response = await _apiClient.postWithAuth(
        '/payments/paystack/wallet/top-up/',
        {'amount': amount},
      );

      state = state.copyWith(isLoading: false);

      if (response != null) {
        developer.log('Wallet top-up initialized successfully');
        return response;
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to initialize wallet top-up',
        );
        return null;
      }
    } catch (e) {
      developer.log('Error initializing wallet top-up: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize wallet top-up',
      );
      return null;
    }
  }

  /// Verify Paystack wallet top-up payment
  Future<bool> verifyWalletTopUp(String reference) async {
    try {
      developer.log(
        '🔄 [WALLET_DEBUG] Starting wallet top-up verification for reference: $reference',
      );
      state = state.copyWith(isLoading: true, clearError: true);

      final response = await _apiClient.postWithAuth(
        '/payments/paystack/verify/',
        {'reference': reference},
      );

      developer.log('🔍 [WALLET_DEBUG] Verification response: $response');

      if (response != null && response['status'] == true) {
        developer.log(
          '✅ [WALLET_DEBUG] Payment verification successful, refreshing wallet data...',
        );

        // Refresh wallet after successful top-up
        await _loadWalletSummary();
        await _loadTransactionHistory();

        state = state.copyWith(isLoading: false);
        developer.log(
          '✅ [WALLET_DEBUG] Wallet top-up verified and data refreshed successfully',
        );
        return true;
      } else {
        developer.log(
          '❌ [WALLET_DEBUG] Payment verification failed: ${response?['message']}',
        );
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              response?['message'] ?? 'Failed to verify wallet top-up',
        );
        return false;
      }
    } catch (e) {
      developer.log(
        '❌ [WALLET_DEBUG] Error verifying wallet top-up: $e',
        error: e,
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to verify wallet top-up',
      );
      return false;
    }
  }

  /// Withdraw funds from wallet
  Future<bool> withdrawFunds(double amount, String paymentMethodId) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final response = await _apiClient.postWithAuth('wallet/withdraw/', {
        'amount': amount,
        'payment_method_id': paymentMethodId,
      });

      if (response['success'] == true) {
        // Refresh wallet after successful withdrawal
        await _loadWalletSummary();
        await _loadTransactionHistory();
        state = state.copyWith(isLoading: false);
        developer.log(
          'Funds withdrawn successfully: \$${amount.toStringAsFixed(2)}',
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response['error'] ?? 'Failed to withdraw funds',
        );
        return false;
      }
    } catch (e) {
      developer.log('Error withdrawing funds: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to withdraw funds',
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
    state = const WalletState();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }
}

/// Provider for WalletNotifier
final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((
  ref,
) {
  return WalletNotifier();
});

/// Convenience providers for accessing specific parts of the wallet state
final walletSummaryProvider = Provider<WalletSummary?>((ref) {
  return ref.watch(walletProvider).walletSummary;
});

final walletBalanceProvider = Provider<WalletBalance?>((ref) {
  final summary = ref.watch(walletSummaryProvider);
  return summary?.balance;
});

final walletTransactionsProvider = Provider<List<Transaction>>((ref) {
  return ref.watch(walletProvider).transactions;
});

final walletLoadingProvider = Provider<bool>((ref) {
  return ref.watch(walletProvider).isLoading;
});

final walletErrorProvider = Provider<String?>((ref) {
  return ref.watch(walletProvider).errorMessage;
});

final availableBalanceProvider = Provider<double>((ref) {
  final balance = ref.watch(walletBalanceProvider);
  return balance?.availableBalance ?? 0.0;
});
