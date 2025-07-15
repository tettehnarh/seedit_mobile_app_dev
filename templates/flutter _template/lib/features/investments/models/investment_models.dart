class Fund {
  final String id;
  final String name;
  final String description;
  final double minimumInvestment;
  final double currentPrice;
  final double returnRate;
  final String riskLevel;
  final String category;
  final bool isActive;
  final DateTime? createdAt;
  final double totalAssets;
  final double managementFee;
  final DateTime inceptionDate;

  const Fund({
    required this.id,
    required this.name,
    required this.description,
    required this.minimumInvestment,
    required this.currentPrice,
    required this.returnRate,
    required this.riskLevel,
    required this.category,
    this.isActive = true,
    this.createdAt,
    required this.totalAssets,
    required this.managementFee,
    required this.inceptionDate,
  });

  Fund copyWith({
    String? id,
    String? name,
    String? description,
    double? minimumInvestment,
    double? currentPrice,
    double? returnRate,
    String? riskLevel,
    String? category,
    bool? isActive,
    DateTime? createdAt,
    double? totalAssets,
    double? managementFee,
    DateTime? inceptionDate,
  }) {
    return Fund(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      minimumInvestment: minimumInvestment ?? this.minimumInvestment,
      currentPrice: currentPrice ?? this.currentPrice,
      returnRate: returnRate ?? this.returnRate,
      riskLevel: riskLevel ?? this.riskLevel,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      totalAssets: totalAssets ?? this.totalAssets,
      managementFee: managementFee ?? this.managementFee,
      inceptionDate: inceptionDate ?? this.inceptionDate,
    );
  }

  /// Calculate estimated return based on risk level and management fee
  static double _calculateEstimatedReturn(
    dynamic riskLevel,
    dynamic managementFee,
  ) {
    final risk = riskLevel?.toString().toLowerCase() ?? 'medium';
    final fee = double.tryParse(managementFee?.toString() ?? '0') ?? 0.0;

    // Base returns by risk level
    double baseReturn = switch (risk) {
      'low' => 4.0,
      'medium' => 8.0,
      'high' => 12.0,
      _ => 8.0,
    };

    // Adjust for management fee (higher fee might indicate better management)
    if (fee > 2.0) baseReturn += 1.0;
    if (fee > 1.5) baseReturn += 0.5;

    return baseReturn;
  }

  factory Fund.fromJson(Map<String, dynamic> json) {
    return Fund(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      minimumInvestment:
          double.tryParse(json['minimum_investment']?.toString() ?? '0') ?? 0.0,
      currentPrice:
          double.tryParse(
            json['current_nav']?.toString() ??
                json['current_price']?.toString() ??
                '0',
          ) ??
          0.0,
      returnRate:
          double.tryParse(json['return_rate']?.toString() ?? '') ??
          _calculateEstimatedReturn(json['risk_level'], json['management_fee']),
      riskLevel: json['risk_level'] ?? 'medium',
      category: json['category'] ?? 'general',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      totalAssets:
          double.tryParse(
            json['total_aum']?.toString() ??
                json['total_assets']?.toString() ??
                '1000000',
          ) ??
          1000000.0,
      managementFee:
          double.tryParse(json['management_fee']?.toString() ?? '1.5') ?? 1.5,
      inceptionDate: json['inception_date'] != null
          ? DateTime.tryParse(json['inception_date']) ??
                DateTime.now().subtract(const Duration(days: 365))
          : DateTime.now().subtract(const Duration(days: 365)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'minimum_investment': minimumInvestment,
      'current_price': currentPrice,
      'return_rate': returnRate,
      'risk_level': riskLevel,
      'category': category,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'total_assets': totalAssets,
      'management_fee': managementFee,
      'inception_date': inceptionDate.toIso8601String(),
    };
  }
}

class FundInvestment {
  final String id;
  final Fund fund;
  final double amountInvested;
  final double currentValue;
  final double units;
  final DateTime investmentDate;
  final String status;
  final double? profitLoss;

  const FundInvestment({
    required this.id,
    required this.fund,
    required this.amountInvested,
    required this.currentValue,
    required this.units,
    required this.investmentDate,
    required this.status,
    this.profitLoss,
  });

  double get profitLossAmount => profitLoss ?? (currentValue - amountInvested);

  double get profitLossPercentage =>
      amountInvested > 0 ? (profitLossAmount / amountInvested) * 100 : 0;

  bool get isProfitable => profitLossAmount > 0;

  FundInvestment copyWith({
    String? id,
    Fund? fund,
    double? amountInvested,
    double? currentValue,
    double? units,
    DateTime? investmentDate,
    String? status,
    double? profitLoss,
  }) {
    return FundInvestment(
      id: id ?? this.id,
      fund: fund ?? this.fund,
      amountInvested: amountInvested ?? this.amountInvested,
      currentValue: currentValue ?? this.currentValue,
      units: units ?? this.units,
      investmentDate: investmentDate ?? this.investmentDate,
      status: status ?? this.status,
      profitLoss: profitLoss ?? this.profitLoss,
    );
  }

  factory FundInvestment.fromJson(Map<String, dynamic> json) {
    // Handle both fund breakdown format and regular investment format
    Fund fund;
    if (json['fund'] != null) {
      // Regular investment format
      fund = Fund.fromJson(json['fund']);
    } else {
      // Fund breakdown format from portfolio summary
      fund = Fund(
        id: '', // Not provided in breakdown
        name: json['fund_name'] ?? '',
        description: '',
        minimumInvestment: 0,
        currentPrice: 0,
        returnRate: 0,
        riskLevel: '',
        category: '',
        totalAssets: 0,
        managementFee: 0,
        inceptionDate: DateTime.now(),
        isActive: true,
      );
    }

    return FundInvestment(
      id: json['id']?.toString() ?? '',
      fund: fund,
      amountInvested:
          double.tryParse(
            json['invested_amount']?.toString() ??
                json['amount_invested']?.toString() ??
                '0',
          ) ??
          0.0,
      currentValue:
          double.tryParse(json['current_value']?.toString() ?? '0') ?? 0.0,
      units: double.tryParse(json['units']?.toString() ?? '0') ?? 0.0,
      investmentDate:
          DateTime.tryParse(json['investment_date'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'active',
      profitLoss: double.tryParse(
        json['return_amount']?.toString() ??
            json['profit_loss']?.toString() ??
            '0',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fund': fund.toJson(),
      'amount_invested': amountInvested,
      'current_value': currentValue,
      'units': units,
      'investment_date': investmentDate.toIso8601String(),
      'status': status,
      'profit_loss': profitLoss,
    };
  }
}

class PortfolioSummary {
  final double totalInvested;
  final double currentValue;
  final double totalProfitLoss;
  final double totalProfitLossPercentage;
  final List<FundInvestment> investments;
  final DateTime lastUpdated;

  const PortfolioSummary({
    required this.totalInvested,
    required this.currentValue,
    required this.totalProfitLoss,
    required this.totalProfitLossPercentage,
    required this.investments,
    required this.lastUpdated,
  });

  bool get isProfitable => totalProfitLoss > 0;

  int get totalInvestments => investments.length;

  PortfolioSummary copyWith({
    double? totalInvested,
    double? currentValue,
    double? totalProfitLoss,
    double? totalProfitLossPercentage,
    List<FundInvestment>? investments,
    DateTime? lastUpdated,
  }) {
    return PortfolioSummary(
      totalInvested: totalInvested ?? this.totalInvested,
      currentValue: currentValue ?? this.currentValue,
      totalProfitLoss: totalProfitLoss ?? this.totalProfitLoss,
      totalProfitLossPercentage:
          totalProfitLossPercentage ?? this.totalProfitLossPercentage,
      investments: investments ?? this.investments,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory PortfolioSummary.fromJson(Map<String, dynamic> json) {
    // Handle nested portfolio data structure from API
    final portfolioData = json['portfolio'] as Map<String, dynamic>? ?? json;
    final fundBreakdown = json['fund_breakdown'] as List<dynamic>? ?? [];

    final investmentsList = fundBreakdown
        .map((item) => FundInvestment.fromJson(item as Map<String, dynamic>))
        .toList();

    return PortfolioSummary(
      totalInvested:
          double.tryParse(portfolioData['total_invested']?.toString() ?? '0') ??
          0.0,
      currentValue:
          double.tryParse(portfolioData['current_value']?.toString() ?? '0') ??
          0.0,
      totalProfitLoss:
          double.tryParse(portfolioData['total_returns']?.toString() ?? '0') ??
          0.0,
      totalProfitLossPercentage: (portfolioData['return_percentage'] ?? 0)
          .toDouble(),
      investments: investmentsList,
      lastUpdated:
          DateTime.now(), // API doesn't provide last_updated, use current time
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_invested': totalInvested,
      'current_value': currentValue,
      'total_profit_loss': totalProfitLoss,
      'total_profit_loss_percentage': totalProfitLossPercentage,
      'investments': investments.map((inv) => inv.toJson()).toList(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  factory PortfolioSummary.empty() {
    return PortfolioSummary(
      totalInvested: 0,
      currentValue: 0,
      totalProfitLoss: 0,
      totalProfitLossPercentage: 0,
      investments: [],
      lastUpdated: DateTime.now(),
    );
  }
}

class TransactionModel {
  final String id;
  final String
  transactionType; // 'investment', 'withdrawal', 'top_up', 'dividend', 'fee'
  final String fundId;
  final String fundName;
  final String fundCode;
  final double amount;
  final double? units;
  final double? navAtExecution;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? executedAt;
  final String
  status; // 'pending', 'pending_payment', 'approved', 'rejected', 'completed', 'expired', 'cancelled'
  final String? processedBy;
  final String? rejectionReason;
  final String? notes;
  final String? description;

  const TransactionModel({
    required this.id,
    required this.transactionType,
    required this.fundId,
    required this.fundName,
    required this.fundCode,
    required this.amount,
    this.units,
    this.navAtExecution,
    required this.createdAt,
    required this.updatedAt,
    this.executedAt,
    required this.status,
    this.processedBy,
    this.rejectionReason,
    this.notes,
    this.description,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      transactionType: json['transaction_type'] ?? 'investment',
      fundId: json['fund_id']?.toString() ?? '',
      fundName: json['fund_name'] ?? 'Unknown Fund',
      fundCode: json['fund_code'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      units: json['units'] != null
          ? double.tryParse(json['units'].toString())
          : null,
      navAtExecution: json['nav_at_execution'] != null
          ? double.tryParse(json['nav_at_execution'].toString())
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      executedAt: json['executed_at'] != null
          ? DateTime.tryParse(json['executed_at'])
          : null,
      status: json['status'] ?? 'pending',
      processedBy: json['processed_by'],
      rejectionReason: json['rejection_reason'],
      notes: json['notes'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_type': transactionType,
      'fund_id': fundId,
      'fund_name': fundName,
      'fund_code': fundCode,
      'amount': amount,
      'units': units,
      'nav_at_execution': navAtExecution,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'executed_at': executedAt?.toIso8601String(),
      'status': status,
      'processed_by': processedBy,
      'rejection_reason': rejectionReason,
      'notes': notes,
      'description': description,
    };
  }

  // Helper getters for UI display
  String get displayType {
    switch (transactionType) {
      case 'investment':
        return 'Investment';
      case 'top_up':
        return 'Top Up';
      case 'withdrawal':
        return 'Withdrawal';
      case 'dividend':
        return 'Dividend';
      case 'fee':
        return 'Fee';
      default:
        return transactionType.toUpperCase();
    }
  }

  String get displayStatus {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'pending_payment':
        return 'Pending Payment';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      case 'expired':
        return 'Expired';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending' || status == 'pending_payment';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';

  // For reporting purposes
  bool get canReport => isCompleted || isRejected;
}
