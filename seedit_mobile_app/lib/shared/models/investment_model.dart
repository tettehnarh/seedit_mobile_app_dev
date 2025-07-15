import 'package:json_annotation/json_annotation.dart';

part 'investment_model.g.dart';

@JsonSerializable()
class Investment {
  final String id;
  final String userId;
  final String fundId;
  final String fundName;
  final double amount;
  final double units;
  final double navAtPurchase;
  final double currentNAV;
  final InvestmentStatus status;
  final InvestmentType type;
  final DateTime investmentDate;
  final DateTime? maturityDate;
  final String? groupId;
  final bool isAutoInvest;
  final double? targetAmount;
  final InvestmentFrequency? frequency;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Investment({
    required this.id,
    required this.userId,
    required this.fundId,
    required this.fundName,
    required this.amount,
    required this.units,
    required this.navAtPurchase,
    required this.currentNAV,
    required this.status,
    required this.type,
    required this.investmentDate,
    this.maturityDate,
    this.groupId,
    this.isAutoInvest = false,
    this.targetAmount,
    this.frequency,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory Investment.fromJson(Map<String, dynamic> json) => _$InvestmentFromJson(json);
  Map<String, dynamic> toJson() => _$InvestmentToJson(this);

  Investment copyWith({
    String? id,
    String? userId,
    String? fundId,
    String? fundName,
    double? amount,
    double? units,
    double? navAtPurchase,
    double? currentNAV,
    InvestmentStatus? status,
    InvestmentType? type,
    DateTime? investmentDate,
    DateTime? maturityDate,
    String? groupId,
    bool? isAutoInvest,
    double? targetAmount,
    InvestmentFrequency? frequency,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Investment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fundId: fundId ?? this.fundId,
      fundName: fundName ?? this.fundName,
      amount: amount ?? this.amount,
      units: units ?? this.units,
      navAtPurchase: navAtPurchase ?? this.navAtPurchase,
      currentNAV: currentNAV ?? this.currentNAV,
      status: status ?? this.status,
      type: type ?? this.type,
      investmentDate: investmentDate ?? this.investmentDate,
      maturityDate: maturityDate ?? this.maturityDate,
      groupId: groupId ?? this.groupId,
      isAutoInvest: isAutoInvest ?? this.isAutoInvest,
      targetAmount: targetAmount ?? this.targetAmount,
      frequency: frequency ?? this.frequency,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculated properties
  double get currentValue => units * currentNAV;
  double get gainLoss => currentValue - amount;
  double get gainLossPercentage => amount > 0 ? (gainLoss / amount) * 100 : 0.0;
  bool get isProfit => gainLoss > 0;
  
  String get formattedAmount => '₦${amount.toStringAsFixed(2)}';
  String get formattedCurrentValue => '₦${currentValue.toStringAsFixed(2)}';
  String get formattedGainLoss => '${isProfit ? '+' : ''}₦${gainLoss.toStringAsFixed(2)}';
  String get formattedGainLossPercentage => '${isProfit ? '+' : ''}${gainLossPercentage.toStringAsFixed(2)}%';
}

@JsonSerializable()
class InvestmentOrder {
  final String id;
  final String userId;
  final String fundId;
  final String fundName;
  final double amount;
  final double? units;
  final double? navAtOrder;
  final OrderType orderType;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final String? paymentReference;
  final String? walletId;
  final DateTime orderDate;
  final DateTime? executionDate;
  final DateTime? expiryDate;
  final String? notes;
  final List<OrderStatusHistory> statusHistory;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvestmentOrder({
    required this.id,
    required this.userId,
    required this.fundId,
    required this.fundName,
    required this.amount,
    this.units,
    this.navAtOrder,
    required this.orderType,
    required this.status,
    required this.paymentMethod,
    this.paymentReference,
    this.walletId,
    required this.orderDate,
    this.executionDate,
    this.expiryDate,
    this.notes,
    this.statusHistory = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvestmentOrder.fromJson(Map<String, dynamic> json) => _$InvestmentOrderFromJson(json);
  Map<String, dynamic> toJson() => _$InvestmentOrderToJson(this);

  InvestmentOrder copyWith({
    String? id,
    String? userId,
    String? fundId,
    String? fundName,
    double? amount,
    double? units,
    double? navAtOrder,
    OrderType? orderType,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    String? paymentReference,
    String? walletId,
    DateTime? orderDate,
    DateTime? executionDate,
    DateTime? expiryDate,
    String? notes,
    List<OrderStatusHistory>? statusHistory,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvestmentOrder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fundId: fundId ?? this.fundId,
      fundName: fundName ?? this.fundName,
      amount: amount ?? this.amount,
      units: units ?? this.units,
      navAtOrder: navAtOrder ?? this.navAtOrder,
      orderType: orderType ?? this.orderType,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      walletId: walletId ?? this.walletId,
      orderDate: orderDate ?? this.orderDate,
      executionDate: executionDate ?? this.executionDate,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
      statusHistory: statusHistory ?? this.statusHistory,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedAmount => '₦${amount.toStringAsFixed(2)}';
  bool get isPending => status == OrderStatus.pending || status == OrderStatus.processing;
  bool get isCompleted => status == OrderStatus.completed;
  bool get isFailed => status == OrderStatus.failed || status == OrderStatus.cancelled;
}

@JsonSerializable()
class OrderStatusHistory {
  final OrderStatus status;
  final DateTime timestamp;
  final String? notes;
  final String? updatedBy;

  OrderStatusHistory({
    required this.status,
    required this.timestamp,
    this.notes,
    this.updatedBy,
  });

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) => _$OrderStatusHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$OrderStatusHistoryToJson(this);
}

@JsonSerializable()
class Portfolio {
  final String id;
  final String userId;
  final double totalValue;
  final double totalInvested;
  final double totalGainLoss;
  final double totalGainLossPercentage;
  final List<PortfolioHolding> holdings;
  final List<AssetAllocation> assetAllocation;
  final PortfolioPerformance performance;
  final DateTime lastUpdated;

  Portfolio({
    required this.id,
    required this.userId,
    required this.totalValue,
    required this.totalInvested,
    required this.totalGainLoss,
    required this.totalGainLossPercentage,
    required this.holdings,
    required this.assetAllocation,
    required this.performance,
    required this.lastUpdated,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) => _$PortfolioFromJson(json);
  Map<String, dynamic> toJson() => _$PortfolioToJson(this);

  String get formattedTotalValue => '₦${totalValue.toStringAsFixed(2)}';
  String get formattedTotalInvested => '₦${totalInvested.toStringAsFixed(2)}';
  String get formattedTotalGainLoss => '${totalGainLoss >= 0 ? '+' : ''}₦${totalGainLoss.toStringAsFixed(2)}';
  String get formattedTotalGainLossPercentage => '${totalGainLoss >= 0 ? '+' : ''}${totalGainLossPercentage.toStringAsFixed(2)}%';
  bool get isProfit => totalGainLoss > 0;
}

@JsonSerializable()
class PortfolioHolding {
  final String fundId;
  final String fundName;
  final double units;
  final double averageNAV;
  final double currentNAV;
  final double totalInvested;
  final double currentValue;
  final double gainLoss;
  final double gainLossPercentage;
  final double allocationPercentage;
  final DateTime lastUpdated;

  PortfolioHolding({
    required this.fundId,
    required this.fundName,
    required this.units,
    required this.averageNAV,
    required this.currentNAV,
    required this.totalInvested,
    required this.currentValue,
    required this.gainLoss,
    required this.gainLossPercentage,
    required this.allocationPercentage,
    required this.lastUpdated,
  });

  factory PortfolioHolding.fromJson(Map<String, dynamic> json) => _$PortfolioHoldingFromJson(json);
  Map<String, dynamic> toJson() => _$PortfolioHoldingToJson(this);

  String get formattedCurrentValue => '₦${currentValue.toStringAsFixed(2)}';
  String get formattedTotalInvested => '₦${totalInvested.toStringAsFixed(2)}';
  String get formattedGainLoss => '${gainLoss >= 0 ? '+' : ''}₦${gainLoss.toStringAsFixed(2)}';
  String get formattedGainLossPercentage => '${gainLoss >= 0 ? '+' : ''}${gainLossPercentage.toStringAsFixed(2)}%';
  bool get isProfit => gainLoss > 0;
}

@JsonSerializable()
class PortfolioPerformance {
  final double dailyReturn;
  final double weeklyReturn;
  final double monthlyReturn;
  final double quarterlyReturn;
  final double yearlyReturn;
  final double totalReturn;
  final double volatility;
  final double sharpeRatio;
  final double maxDrawdown;
  final List<PerformanceDataPoint> historicalData;

  PortfolioPerformance({
    required this.dailyReturn,
    required this.weeklyReturn,
    required this.monthlyReturn,
    required this.quarterlyReturn,
    required this.yearlyReturn,
    required this.totalReturn,
    required this.volatility,
    required this.sharpeRatio,
    required this.maxDrawdown,
    required this.historicalData,
  });

  factory PortfolioPerformance.fromJson(Map<String, dynamic> json) => _$PortfolioPerformanceFromJson(json);
  Map<String, dynamic> toJson() => _$PortfolioPerformanceToJson(this);
}

@JsonSerializable()
class PerformanceDataPoint {
  final DateTime date;
  final double value;
  final double return_;
  final double cumulativeReturn;

  PerformanceDataPoint({
    required this.date,
    required this.value,
    required this.return_,
    required this.cumulativeReturn,
  });

  factory PerformanceDataPoint.fromJson(Map<String, dynamic> json) => _$PerformanceDataPointFromJson(json);
  Map<String, dynamic> toJson() => _$PerformanceDataPointToJson(this);
}

@JsonSerializable()
class AssetAllocation {
  final String assetClass;
  final double percentage;
  final double value;
  final String description;

  AssetAllocation({
    required this.assetClass,
    required this.percentage,
    required this.value,
    required this.description,
  });

  factory AssetAllocation.fromJson(Map<String, dynamic> json) => _$AssetAllocationFromJson(json);
  Map<String, dynamic> toJson() => _$AssetAllocationToJson(this);

  String get formattedValue => '₦${value.toStringAsFixed(2)}';
  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';
}

enum InvestmentStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('ACTIVE')
  active,
  @JsonValue('MATURED')
  matured,
  @JsonValue('REDEEMED')
  redeemed,
  @JsonValue('CANCELLED')
  cancelled,
}

enum InvestmentType {
  @JsonValue('LUMP_SUM')
  lumpSum,
  @JsonValue('RECURRING')
  recurring,
  @JsonValue('SIP')
  sip,
  @JsonValue('GROUP')
  group,
}

enum InvestmentFrequency {
  @JsonValue('DAILY')
  daily,
  @JsonValue('WEEKLY')
  weekly,
  @JsonValue('MONTHLY')
  monthly,
  @JsonValue('QUARTERLY')
  quarterly,
  @JsonValue('YEARLY')
  yearly,
}

enum OrderType {
  @JsonValue('BUY')
  buy,
  @JsonValue('SELL')
  sell,
  @JsonValue('SWITCH')
  switch_,
  @JsonValue('SIP')
  sip,
}

enum OrderStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('PROCESSING')
  processing,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('FAILED')
  failed,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('EXPIRED')
  expired,
}

enum PaymentMethod {
  @JsonValue('WALLET')
  wallet,
  @JsonValue('BANK_TRANSFER')
  bankTransfer,
  @JsonValue('CARD')
  card,
  @JsonValue('MOBILE_MONEY')
  mobileMoney,
  @JsonValue('DIRECT_DEBIT')
  directDebit,
}
