import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../investments/models/investment_models.dart';
import '../../investments/services/investment_service.dart';
import '../../../core/api/api_exception.dart';
import 'dart:developer' as developer;

/// State class for transaction management
class TransactionState {
  final List<TransactionModel> recentTransactions;
  final List<TransactionModel> allTransactions;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool hasMoreData;
  final int currentPage;

  const TransactionState({
    this.recentTransactions = const [],
    this.allTransactions = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.hasMoreData = true,
    this.currentPage = 1,
  });

  TransactionState copyWith({
    List<TransactionModel>? recentTransactions,
    List<TransactionModel>? allTransactions,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool? hasMoreData,
    int? currentPage,
    bool clearError = false,
  }) {
    return TransactionState(
      recentTransactions: recentTransactions ?? this.recentTransactions,
      allTransactions: allTransactions ?? this.allTransactions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Riverpod provider for managing transaction state
class TransactionNotifier extends StateNotifier<TransactionState> {
  final InvestmentService _investmentService;

  TransactionNotifier(this._investmentService)
    : super(const TransactionState());

  /// Load recent transactions (for home screen preview)
  Future<void> loadRecentTransactions() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      // Fetch only first 2 transactions for home screen preview
      final result = await _investmentService.getTransactionHistory(
        page: 1,
        pageSize: 2,
      );

      final transactions = result['transactions'] as List<TransactionModel>;

      state = state.copyWith(
        recentTransactions: transactions,
        isLoading: false,
      );

      developer.log(
        'Recent transactions loaded: ${transactions.length} transactions',
      );
    } catch (e) {
      developer.log('Error loading recent transactions: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Load all transactions with pagination
  Future<void> loadAllTransactions({bool refresh = false}) async {
    if (state.isLoading || state.isLoadingMore) return;

    try {
      if (refresh) {
        state = state.copyWith(
          isLoading: true,
          currentPage: 1,
          hasMoreData: true,
          clearError: true,
        );
      } else {
        if (!state.hasMoreData) return;
        state = state.copyWith(isLoadingMore: true, clearError: true);
      }

      final result = await _investmentService.getTransactionHistory(
        page: refresh ? 1 : state.currentPage,
        pageSize: 20,
      );

      final transactions = result['transactions'] as List<TransactionModel>;
      final hasNext = result['hasNext'] as bool? ?? false;

      if (refresh) {
        state = state.copyWith(
          allTransactions: transactions,
          isLoading: false,
          currentPage: 2,
          hasMoreData: hasNext,
        );
      } else {
        final updatedTransactions = [...state.allTransactions, ...transactions];
        state = state.copyWith(
          allTransactions: updatedTransactions,
          isLoadingMore: false,
          currentPage: state.currentPage + 1,
          hasMoreData: hasNext,
        );
      }

      developer.log(
        'All transactions loaded: ${state.allTransactions.length} total transactions',
      );
    } catch (e) {
      developer.log('Error loading all transactions: $e', error: e);
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  /// Search transactions
  Future<List<TransactionModel>> searchTransactions(String query) async {
    try {
      developer.log('Searching transactions with query: $query');
      return await _investmentService.searchTransactions(query);
    } catch (e) {
      developer.log('Error searching transactions: $e', error: e);
      rethrow;
    }
  }

  /// Get transaction by ID
  Future<TransactionModel?> getTransactionById(String transactionId) async {
    try {
      developer.log('Fetching transaction details for ID: $transactionId');
      return await _investmentService.getTransactionById(transactionId);
    } catch (e) {
      developer.log('Error fetching transaction details: $e', error: e);
      rethrow;
    }
  }

  /// Refresh transaction data
  Future<void> refreshTransactions() async {
    await Future.wait([
      loadRecentTransactions(),
      loadAllTransactions(refresh: true),
    ]);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear all data (for logout)
  void clearData() {
    state = const TransactionState();
    developer.log('Transaction data cleared');
  }

  /// Get error message from exception
  String _getErrorMessage(dynamic error) {
    if (error is UnauthorizedException) {
      return 'Please sign in to view transactions';
    } else if (error is ServerException) {
      return 'Server error. Please try again later.';
    } else if (error is NetworkException) {
      return 'Network error. Please check your connection.';
    } else {
      return 'Failed to load transactions. Please try again.';
    }
  }
}

/// Provider instances
final investmentServiceProvider = Provider<InvestmentService>(
  (ref) => InvestmentService(),
);

/// Provider for TransactionNotifier
final transactionProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
      final investmentService = ref.read(investmentServiceProvider);
      return TransactionNotifier(investmentService);
    });

/// Convenience providers for accessing specific parts of the transaction state
final recentTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  return ref.watch(transactionProvider).recentTransactions;
});

final allTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  return ref.watch(transactionProvider).allTransactions;
});

final transactionLoadingProvider = Provider<bool>((ref) {
  return ref.watch(transactionProvider).isLoading;
});

final transactionErrorProvider = Provider<String?>((ref) {
  return ref.watch(transactionProvider).errorMessage;
});

final hasMoreTransactionsProvider = Provider<bool>((ref) {
  return ref.watch(transactionProvider).hasMoreData;
});
