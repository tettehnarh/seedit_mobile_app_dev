import 'package:flutter/foundation.dart';
import '../../shared/models/investment_model.dart';
import '../../shared/models/fund_model.dart';
import '../../shared/models/wallet_model.dart';

class InvestmentService {
  // Create investment order
  Future<InvestmentOrder> createInvestmentOrder({
    required String userId,
    required String fundId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? notes,
  }) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 800));
      
      final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
      final order = InvestmentOrder(
        id: orderId,
        userId: userId,
        fundId: fundId,
        fundName: 'SeedIt Equity Growth Fund', // TODO: Get from fund service
        amount: amount,
        orderType: OrderType.buy,
        status: OrderStatus.pending,
        paymentMethod: _mapPaymentMethodType(paymentMethod),
        paymentReference: 'PAY_${DateTime.now().millisecondsSinceEpoch}',
        orderDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(hours: 24)),
        statusHistory: [
          OrderStatusHistory(
            status: OrderStatus.pending,
            timestamp: DateTime.now(),
            notes: 'Order created',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      return order;
    } catch (e) {
      debugPrint('Create investment order error: $e');
      throw Exception('Failed to create investment order');
    }
  }

  // Process investment order
  Future<InvestmentOrder> processInvestmentOrder(String orderId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Simulate processing
      final order = await getInvestmentOrder(orderId);
      if (order == null) throw Exception('Order not found');
      
      final updatedOrder = order.copyWith(
        status: OrderStatus.processing,
        statusHistory: [
          ...order.statusHistory,
          OrderStatusHistory(
            status: OrderStatus.processing,
            timestamp: DateTime.now(),
            notes: 'Payment processing',
          ),
        ],
        updatedAt: DateTime.now(),
      );
      
      return updatedOrder;
    } catch (e) {
      debugPrint('Process investment order error: $e');
      throw Exception('Failed to process investment order');
    }
  }

  // Complete investment order
  Future<Investment> completeInvestmentOrder(String orderId, double navAtPurchase) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final order = await getInvestmentOrder(orderId);
      if (order == null) throw Exception('Order not found');
      
      final units = order.amount / navAtPurchase;
      
      final investment = Investment(
        id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
        userId: order.userId,
        fundId: order.fundId,
        fundName: order.fundName,
        amount: order.amount,
        units: units,
        navAtPurchase: navAtPurchase,
        currentNAV: navAtPurchase,
        status: InvestmentStatus.active,
        type: InvestmentType.lumpSum,
        investmentDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      return investment;
    } catch (e) {
      debugPrint('Complete investment order error: $e');
      throw Exception('Failed to complete investment order');
    }
  }

  // Get investment order
  Future<InvestmentOrder?> getInvestmentOrder(String orderId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Return mock order for demo
      return _getMockOrder(orderId);
    } catch (e) {
      debugPrint('Get investment order error: $e');
      return null;
    }
  }

  // Get user investments
  Future<List<Investment>> getUserInvestments(String userId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      return _getMockInvestments(userId);
    } catch (e) {
      debugPrint('Get user investments error: $e');
      throw Exception('Failed to load investments');
    }
  }

  // Get user portfolio
  Future<Portfolio> getUserPortfolio(String userId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 600));
      
      final investments = await getUserInvestments(userId);
      return _calculatePortfolio(userId, investments);
    } catch (e) {
      debugPrint('Get user portfolio error: $e');
      throw Exception('Failed to load portfolio');
    }
  }

  // Get investment orders for user
  Future<List<InvestmentOrder>> getUserInvestmentOrders(String userId) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 400));
      
      return _getMockOrders(userId);
    } catch (e) {
      debugPrint('Get user investment orders error: $e');
      throw Exception('Failed to load investment orders');
    }
  }

  // Cancel investment order
  Future<InvestmentOrder> cancelInvestmentOrder(String orderId, String reason) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final order = await getInvestmentOrder(orderId);
      if (order == null) throw Exception('Order not found');
      
      final updatedOrder = order.copyWith(
        status: OrderStatus.cancelled,
        statusHistory: [
          ...order.statusHistory,
          OrderStatusHistory(
            status: OrderStatus.cancelled,
            timestamp: DateTime.now(),
            notes: reason,
          ),
        ],
        updatedAt: DateTime.now(),
      );
      
      return updatedOrder;
    } catch (e) {
      debugPrint('Cancel investment order error: $e');
      throw Exception('Failed to cancel investment order');
    }
  }

  // Redeem investment
  Future<InvestmentOrder> redeemInvestment({
    required String investmentId,
    required double units,
    String? notes,
  }) async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 800));
      
      final orderId = 'redeem_${DateTime.now().millisecondsSinceEpoch}';
      final order = InvestmentOrder(
        id: orderId,
        userId: 'user_123', // TODO: Get from context
        fundId: 'fund_001',
        fundName: 'SeedIt Equity Growth Fund',
        amount: units * 125.50, // TODO: Calculate with current NAV
        units: units,
        navAtOrder: 125.50,
        orderType: OrderType.sell,
        status: OrderStatus.pending,
        paymentMethod: PaymentMethod.wallet,
        orderDate: DateTime.now(),
        notes: notes,
        statusHistory: [
          OrderStatusHistory(
            status: OrderStatus.pending,
            timestamp: DateTime.now(),
            notes: 'Redemption request created',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      return order;
    } catch (e) {
      debugPrint('Redeem investment error: $e');
      throw Exception('Failed to create redemption request');
    }
  }

  // Calculate investment amount for given units
  double calculateInvestmentAmount(double units, double nav) {
    return units * nav;
  }

  // Calculate units for given amount
  double calculateUnits(double amount, double nav) {
    return amount / nav;
  }

  // Validate investment amount
  bool validateInvestmentAmount(double amount, InvestmentFund fund) {
    return amount >= fund.minimumInvestment && amount <= fund.maximumInvestment;
  }

  // Check if user can invest
  Future<bool> canUserInvest(String userId, double amount) async {
    try {
      // TODO: Check user KYC status, wallet balance, etc.
      return true;
    } catch (e) {
      debugPrint('Can user invest error: $e');
      return false;
    }
  }

  // Private helper methods
  PaymentMethod _mapPaymentMethodType(PaymentMethod method) {
    // TODO: Map from PaymentMethod object to enum
    return PaymentMethod.wallet;
  }

  InvestmentOrder _getMockOrder(String orderId) {
    return InvestmentOrder(
      id: orderId,
      userId: 'user_123',
      fundId: 'fund_001',
      fundName: 'SeedIt Equity Growth Fund',
      amount: 50000,
      orderType: OrderType.buy,
      status: OrderStatus.pending,
      paymentMethod: PaymentMethod.wallet,
      paymentReference: 'PAY_123456789',
      orderDate: DateTime.now().subtract(const Duration(minutes: 30)),
      expiryDate: DateTime.now().add(const Duration(hours: 23, minutes: 30)),
      statusHistory: [
        OrderStatusHistory(
          status: OrderStatus.pending,
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          notes: 'Order created',
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    );
  }

  List<InvestmentOrder> _getMockOrders(String userId) {
    return [
      InvestmentOrder(
        id: 'order_001',
        userId: userId,
        fundId: 'fund_001',
        fundName: 'SeedIt Equity Growth Fund',
        amount: 50000,
        orderType: OrderType.buy,
        status: OrderStatus.completed,
        paymentMethod: PaymentMethod.wallet,
        paymentReference: 'PAY_123456789',
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        executionDate: DateTime.now().subtract(const Duration(days: 2)),
        statusHistory: [
          OrderStatusHistory(
            status: OrderStatus.pending,
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            notes: 'Order created',
          ),
          OrderStatusHistory(
            status: OrderStatus.completed,
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            notes: 'Investment completed',
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      InvestmentOrder(
        id: 'order_002',
        userId: userId,
        fundId: 'fund_002',
        fundName: 'SeedIt Bond Income Fund',
        amount: 25000,
        orderType: OrderType.buy,
        status: OrderStatus.processing,
        paymentMethod: PaymentMethod.bankTransfer,
        paymentReference: 'PAY_987654321',
        orderDate: DateTime.now().subtract(const Duration(hours: 6)),
        statusHistory: [
          OrderStatusHistory(
            status: OrderStatus.pending,
            timestamp: DateTime.now().subtract(const Duration(hours: 6)),
            notes: 'Order created',
          ),
          OrderStatusHistory(
            status: OrderStatus.processing,
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
            notes: 'Payment processing',
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }

  List<Investment> _getMockInvestments(String userId) {
    return [
      Investment(
        id: 'inv_001',
        userId: userId,
        fundId: 'fund_001',
        fundName: 'SeedIt Equity Growth Fund',
        amount: 50000,
        units: 398.41,
        navAtPurchase: 125.50,
        currentNAV: 127.80,
        status: InvestmentStatus.active,
        type: InvestmentType.lumpSum,
        investmentDate: DateTime.now().subtract(const Duration(days: 30)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      Investment(
        id: 'inv_002',
        userId: userId,
        fundId: 'fund_002',
        fundName: 'SeedIt Bond Income Fund',
        amount: 25000,
        units: 230.95,
        navAtPurchase: 108.25,
        currentNAV: 109.15,
        status: InvestmentStatus.active,
        type: InvestmentType.lumpSum,
        investmentDate: DateTime.now().subtract(const Duration(days: 15)),
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  Portfolio _calculatePortfolio(String userId, List<Investment> investments) {
    double totalInvested = 0;
    double totalValue = 0;
    List<PortfolioHolding> holdings = [];

    for (final investment in investments) {
      totalInvested += investment.amount;
      totalValue += investment.currentValue;

      holdings.add(PortfolioHolding(
        fundId: investment.fundId,
        fundName: investment.fundName,
        units: investment.units,
        averageNAV: investment.navAtPurchase,
        currentNAV: investment.currentNAV,
        totalInvested: investment.amount,
        currentValue: investment.currentValue,
        gainLoss: investment.gainLoss,
        gainLossPercentage: investment.gainLossPercentage,
        allocationPercentage: totalValue > 0 ? (investment.currentValue / totalValue) * 100 : 0,
        lastUpdated: DateTime.now(),
      ));
    }

    final totalGainLoss = totalValue - totalInvested;
    final totalGainLossPercentage = totalInvested > 0 ? (totalGainLoss / totalInvested) * 100 : 0;

    return Portfolio(
      id: 'portfolio_$userId',
      userId: userId,
      totalValue: totalValue,
      totalInvested: totalInvested,
      totalGainLoss: totalGainLoss,
      totalGainLossPercentage: totalGainLossPercentage,
      holdings: holdings,
      assetAllocation: _calculateAssetAllocation(holdings, totalValue),
      performance: _calculatePortfolioPerformance(),
      lastUpdated: DateTime.now(),
    );
  }

  List<AssetAllocation> _calculateAssetAllocation(List<PortfolioHolding> holdings, double totalValue) {
    // TODO: Implement proper asset allocation calculation
    return [
      AssetAllocation(
        assetClass: 'Equity',
        percentage: 70.0,
        value: totalValue * 0.7,
        description: 'Equity investments',
      ),
      AssetAllocation(
        assetClass: 'Fixed Income',
        percentage: 30.0,
        value: totalValue * 0.3,
        description: 'Bond and fixed income',
      ),
    ];
  }

  PortfolioPerformance _calculatePortfolioPerformance() {
    // TODO: Implement proper performance calculation
    return PortfolioPerformance(
      dailyReturn: 0.5,
      weeklyReturn: 2.1,
      monthlyReturn: 8.3,
      quarterlyReturn: 12.5,
      yearlyReturn: 15.2,
      totalReturn: 18.7,
      volatility: 12.5,
      sharpeRatio: 1.2,
      maxDrawdown: -8.5,
      historicalData: [],
    );
  }
}
