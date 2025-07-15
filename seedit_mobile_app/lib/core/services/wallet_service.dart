import 'package:flutter/foundation.dart';
import '../../shared/models/wallet_model.dart';

class WalletService {
  // Get user wallet
  Future<Wallet?> getUserWallet(String userId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 400));
      
      return _getMockWallet(userId);
    } catch (e) {
      debugPrint('Get user wallet error: $e');
      return null;
    }
  }

  // Get wallet balance
  Future<double> getWalletBalance(String walletId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 200));
      
      final wallet = await getUserWallet('user_123'); // TODO: Get user ID from context
      return wallet?.balance ?? 0.0;
    } catch (e) {
      debugPrint('Get wallet balance error: $e');
      return 0.0;
    }
  }

  // Create deposit request
  Future<DepositRequest> createDepositRequest({
    required String userId,
    required String walletId,
    required double amount,
    required PaymentMethodType paymentMethod,
    String? paymentMethodId,
    String? notes,
  }) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 600));
      
      final depositId = 'dep_${DateTime.now().millisecondsSinceEpoch}';
      final deposit = DepositRequest(
        id: depositId,
        userId: userId,
        walletId: walletId,
        amount: amount,
        currency: 'NGN',
        paymentMethod: paymentMethod,
        paymentMethodId: paymentMethodId,
        status: DepositStatus.pending,
        paymentReference: 'PAY_${DateTime.now().millisecondsSinceEpoch}',
        notes: notes,
        requestDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      return deposit;
    } catch (e) {
      debugPrint('Create deposit request error: $e');
      throw Exception('Failed to create deposit request');
    }
  }

  // Create withdrawal request
  Future<WithdrawalRequest> createWithdrawalRequest({
    required String userId,
    required String walletId,
    required double amount,
    required PaymentMethodType withdrawalMethod,
    String? paymentMethodId,
    String? notes,
  }) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 600));
      
      final withdrawalId = 'with_${DateTime.now().millisecondsSinceEpoch}';
      final withdrawal = WithdrawalRequest(
        id: withdrawalId,
        userId: userId,
        walletId: walletId,
        amount: amount,
        currency: 'NGN',
        withdrawalMethod: withdrawalMethod,
        paymentMethodId: paymentMethodId,
        status: WithdrawalStatus.pending,
        reference: 'WITH_${DateTime.now().millisecondsSinceEpoch}',
        notes: notes,
        requestDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      return withdrawal;
    } catch (e) {
      debugPrint('Create withdrawal request error: $e');
      throw Exception('Failed to create withdrawal request');
    }
  }

  // Get wallet transactions
  Future<List<WalletTransaction>> getWalletTransactions(
    String walletId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      return _getMockTransactions(walletId);
    } catch (e) {
      debugPrint('Get wallet transactions error: $e');
      throw Exception('Failed to load wallet transactions');
    }
  }

  // Get user payment methods
  Future<List<PaymentMethod>> getUserPaymentMethods(String userId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 400));
      
      return _getMockPaymentMethods(userId);
    } catch (e) {
      debugPrint('Get user payment methods error: $e');
      throw Exception('Failed to load payment methods');
    }
  }

  // Add payment method
  Future<PaymentMethod> addPaymentMethod({
    required String userId,
    required PaymentMethodType type,
    required String name,
    String? last4Digits,
    String? bankName,
    String? accountNumber,
    String? cardBrand,
    String? expiryMonth,
    String? expiryYear,
    bool isDefault = false,
  }) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 800));
      
      final paymentMethodId = 'pm_${DateTime.now().millisecondsSinceEpoch}';
      final paymentMethod = PaymentMethod(
        id: paymentMethodId,
        userId: userId,
        type: type,
        name: name,
        last4Digits: last4Digits,
        bankName: bankName,
        accountNumber: accountNumber,
        cardBrand: cardBrand,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        isDefault: isDefault,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      return paymentMethod;
    } catch (e) {
      debugPrint('Add payment method error: $e');
      throw Exception('Failed to add payment method');
    }
  }

  // Remove payment method
  Future<void> removePaymentMethod(String paymentMethodId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      debugPrint('Remove payment method error: $e');
      throw Exception('Failed to remove payment method');
    }
  }

  // Set default payment method
  Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      debugPrint('Set default payment method error: $e');
      throw Exception('Failed to set default payment method');
    }
  }

  // Check if wallet has sufficient balance
  bool hasSufficientBalance(Wallet wallet, double amount) {
    return wallet.availableBalance >= amount;
  }

  // Reserve funds for investment
  Future<void> reserveFunds(String walletId, double amount) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      debugPrint('Reserve funds error: $e');
      throw Exception('Failed to reserve funds');
    }
  }

  // Release reserved funds
  Future<void> releaseReservedFunds(String walletId, double amount) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      debugPrint('Release reserved funds error: $e');
      throw Exception('Failed to release reserved funds');
    }
  }

  // Process wallet transaction
  Future<WalletTransaction> processWalletTransaction({
    required String walletId,
    required String userId,
    required TransactionType type,
    required TransactionCategory category,
    required double amount,
    required String description,
    String? reference,
    String? externalReference,
  }) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final transactionId = 'txn_${DateTime.now().millisecondsSinceEpoch}';
      final wallet = await getUserWallet(userId);
      final balanceBefore = wallet?.balance ?? 0.0;
      final balanceAfter = type == TransactionType.credit 
          ? balanceBefore + amount 
          : balanceBefore - amount;
      
      final transaction = WalletTransaction(
        id: transactionId,
        walletId: walletId,
        userId: userId,
        type: type,
        category: category,
        amount: amount,
        balanceBefore: balanceBefore,
        balanceAfter: balanceAfter,
        currency: 'NGN',
        status: TransactionStatus.completed,
        description: description,
        reference: reference,
        externalReference: externalReference,
        transactionDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      return transaction;
    } catch (e) {
      debugPrint('Process wallet transaction error: $e');
      throw Exception('Failed to process wallet transaction');
    }
  }

  // Mock data methods
  Wallet _getMockWallet(String userId) {
    return Wallet(
      id: 'wallet_$userId',
      userId: userId,
      currency: 'NGN',
      balance: 150000.00,
      availableBalance: 145000.00,
      pendingBalance: 5000.00,
      reservedBalance: 0.00,
      status: WalletStatus.active,
      type: WalletType.primary,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now(),
    );
  }

  List<WalletTransaction> _getMockTransactions(String walletId) {
    return [
      WalletTransaction(
        id: 'txn_001',
        walletId: walletId,
        userId: 'user_123',
        type: TransactionType.credit,
        category: TransactionCategory.deposit,
        amount: 100000.00,
        balanceBefore: 50000.00,
        balanceAfter: 150000.00,
        currency: 'NGN',
        status: TransactionStatus.completed,
        description: 'Bank transfer deposit',
        reference: 'DEP_123456789',
        transactionDate: DateTime.now().subtract(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      WalletTransaction(
        id: 'txn_002',
        walletId: walletId,
        userId: 'user_123',
        type: TransactionType.debit,
        category: TransactionCategory.investment,
        amount: 50000.00,
        balanceBefore: 150000.00,
        balanceAfter: 100000.00,
        currency: 'NGN',
        status: TransactionStatus.completed,
        description: 'Investment in SeedIt Equity Growth Fund',
        reference: 'INV_987654321',
        transactionDate: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      WalletTransaction(
        id: 'txn_003',
        walletId: walletId,
        userId: 'user_123',
        type: TransactionType.debit,
        category: TransactionCategory.investment,
        amount: 25000.00,
        balanceBefore: 100000.00,
        balanceAfter: 75000.00,
        currency: 'NGN',
        status: TransactionStatus.completed,
        description: 'Investment in SeedIt Bond Income Fund',
        reference: 'INV_456789123',
        transactionDate: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  List<PaymentMethod> _getMockPaymentMethods(String userId) {
    return [
      PaymentMethod(
        id: 'pm_001',
        userId: userId,
        type: PaymentMethodType.card,
        name: 'Primary Card',
        last4Digits: '1234',
        cardBrand: 'Visa',
        expiryMonth: '12',
        expiryYear: '2027',
        isDefault: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      PaymentMethod(
        id: 'pm_002',
        userId: userId,
        type: PaymentMethodType.bankAccount,
        name: 'GTBank Account',
        last4Digits: '5678',
        bankName: 'Guaranty Trust Bank',
        accountNumber: '0123456789',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }
}
