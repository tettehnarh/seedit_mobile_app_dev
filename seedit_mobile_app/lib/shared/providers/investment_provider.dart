import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/investment_model.dart';
import '../models/wallet_model.dart';
import '../../core/services/investment_service.dart';
import '../../core/services/wallet_service.dart';
import 'auth_provider.dart';

// Service providers
final investmentServiceProvider = Provider<InvestmentService>((ref) => InvestmentService());
final walletServiceProvider = Provider<WalletService>((ref) => WalletService());

// User investments provider
final userInvestmentsProvider = FutureProvider<List<Investment>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return [];
  
  final investmentService = ref.read(investmentServiceProvider);
  return await investmentService.getUserInvestments(currentUser.id);
});

// User portfolio provider
final userPortfolioProvider = FutureProvider<Portfolio?>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return null;
  
  final investmentService = ref.read(investmentServiceProvider);
  return await investmentService.getUserPortfolio(currentUser.id);
});

// User wallet provider
final userWalletProvider = FutureProvider<Wallet?>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return null;
  
  final walletService = ref.read(walletServiceProvider);
  return await walletService.getUserWallet(currentUser.id);
});

// User investment orders provider
final userInvestmentOrdersProvider = FutureProvider<List<InvestmentOrder>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return [];
  
  final investmentService = ref.read(investmentServiceProvider);
  return await investmentService.getUserInvestmentOrders(currentUser.id);
});

// Wallet transactions provider
final walletTransactionsProvider = FutureProvider<List<WalletTransaction>>((ref) async {
  final wallet = ref.watch(userWalletProvider);
  return wallet.when(
    data: (walletData) async {
      if (walletData == null) return [];
      final walletService = ref.read(walletServiceProvider);
      return await walletService.getWalletTransactions(walletData.id);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// User payment methods provider
final userPaymentMethodsProvider = FutureProvider<List<PaymentMethod>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return [];
  
  final walletService = ref.read(walletServiceProvider);
  return await walletService.getUserPaymentMethods(currentUser.id);
});

// Investment order provider
final investmentOrderProvider = FutureProvider.family<InvestmentOrder?, String>((ref, orderId) async {
  final investmentService = ref.read(investmentServiceProvider);
  return await investmentService.getInvestmentOrder(orderId);
});

// Investment state provider
final investmentStateProvider = StateNotifierProvider<InvestmentNotifier, InvestmentState>((ref) {
  return InvestmentNotifier(
    ref.read(investmentServiceProvider),
    ref.read(walletServiceProvider),
  );
});

class InvestmentState {
  final bool isLoading;
  final String? error;
  final InvestmentOrder? currentOrder;
  final Investment? currentInvestment;

  InvestmentState({
    this.isLoading = false,
    this.error,
    this.currentOrder,
    this.currentInvestment,
  });

  InvestmentState copyWith({
    bool? isLoading,
    String? error,
    InvestmentOrder? currentOrder,
    Investment? currentInvestment,
  }) {
    return InvestmentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentOrder: currentOrder ?? this.currentOrder,
      currentInvestment: currentInvestment ?? this.currentInvestment,
    );
  }
}

class InvestmentNotifier extends StateNotifier<InvestmentState> {
  final InvestmentService _investmentService;
  final WalletService _walletService;

  InvestmentNotifier(this._investmentService, this._walletService) : super(InvestmentState());

  // Create investment order
  Future<InvestmentOrder?> createInvestmentOrder({
    required String userId,
    required String fundId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final order = await _investmentService.createInvestmentOrder(
        userId: userId,
        fundId: fundId,
        amount: amount,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      state = state.copyWith(
        isLoading: false,
        currentOrder: order,
      );

      return order;
    } catch (e) {
      debugPrint('Create investment order error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Process investment order
  Future<bool> processInvestmentOrder(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final order = await _investmentService.processInvestmentOrder(orderId);
      
      state = state.copyWith(
        isLoading: false,
        currentOrder: order,
      );

      return true;
    } catch (e) {
      debugPrint('Process investment order error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Complete investment order
  Future<Investment?> completeInvestmentOrder(String orderId, double navAtPurchase) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final investment = await _investmentService.completeInvestmentOrder(orderId, navAtPurchase);
      
      state = state.copyWith(
        isLoading: false,
        currentInvestment: investment,
      );

      return investment;
    } catch (e) {
      debugPrint('Complete investment order error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Cancel investment order
  Future<bool> cancelInvestmentOrder(String orderId, String reason) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final order = await _investmentService.cancelInvestmentOrder(orderId, reason);
      
      state = state.copyWith(
        isLoading: false,
        currentOrder: order,
      );

      return true;
    } catch (e) {
      debugPrint('Cancel investment order error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Redeem investment
  Future<InvestmentOrder?> redeemInvestment({
    required String investmentId,
    required double units,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final order = await _investmentService.redeemInvestment(
        investmentId: investmentId,
        units: units,
        notes: notes,
      );

      state = state.copyWith(
        isLoading: false,
        currentOrder: order,
      );

      return order;
    } catch (e) {
      debugPrint('Redeem investment error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Validate investment amount
  bool validateInvestmentAmount(double amount, double minInvestment, double maxInvestment) {
    return amount >= minInvestment && amount <= maxInvestment;
  }

  // Check wallet balance
  Future<bool> checkWalletBalance(String userId, double amount) async {
    try {
      final wallet = await _walletService.getUserWallet(userId);
      if (wallet == null) return false;
      
      return _walletService.hasSufficientBalance(wallet, amount);
    } catch (e) {
      debugPrint('Check wallet balance error: $e');
      return false;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear current order
  void clearCurrentOrder() {
    state = state.copyWith(currentOrder: null);
  }

  // Clear current investment
  void clearCurrentInvestment() {
    state = state.copyWith(currentInvestment: null);
  }
}

// Wallet state provider
final walletStateProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(ref.read(walletServiceProvider));
});

class WalletState {
  final bool isLoading;
  final String? error;
  final DepositRequest? currentDeposit;
  final WithdrawalRequest? currentWithdrawal;

  WalletState({
    this.isLoading = false,
    this.error,
    this.currentDeposit,
    this.currentWithdrawal,
  });

  WalletState copyWith({
    bool? isLoading,
    String? error,
    DepositRequest? currentDeposit,
    WithdrawalRequest? currentWithdrawal,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentDeposit: currentDeposit ?? this.currentDeposit,
      currentWithdrawal: currentWithdrawal ?? this.currentWithdrawal,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletService _walletService;

  WalletNotifier(this._walletService) : super(WalletState());

  // Create deposit request
  Future<DepositRequest?> createDepositRequest({
    required String userId,
    required String walletId,
    required double amount,
    required PaymentMethodType paymentMethod,
    String? paymentMethodId,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final deposit = await _walletService.createDepositRequest(
        userId: userId,
        walletId: walletId,
        amount: amount,
        paymentMethod: paymentMethod,
        paymentMethodId: paymentMethodId,
        notes: notes,
      );

      state = state.copyWith(
        isLoading: false,
        currentDeposit: deposit,
      );

      return deposit;
    } catch (e) {
      debugPrint('Create deposit request error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Create withdrawal request
  Future<WithdrawalRequest?> createWithdrawalRequest({
    required String userId,
    required String walletId,
    required double amount,
    required PaymentMethodType withdrawalMethod,
    String? paymentMethodId,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final withdrawal = await _walletService.createWithdrawalRequest(
        userId: userId,
        walletId: walletId,
        amount: amount,
        withdrawalMethod: withdrawalMethod,
        paymentMethodId: paymentMethodId,
        notes: notes,
      );

      state = state.copyWith(
        isLoading: false,
        currentWithdrawal: withdrawal,
      );

      return withdrawal;
    } catch (e) {
      debugPrint('Create withdrawal request error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
