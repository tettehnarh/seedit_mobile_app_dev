import 'package:json_annotation/json_annotation.dart';

part 'fund_model.g.dart';

@JsonSerializable()
class InvestmentFund {
  final String id;
  final String name;
  final String description;
  final String shortDescription;
  final FundType type;
  final FundCategory category;
  final RiskLevel riskLevel;
  final String currency;
  final double minimumInvestment;
  final double maximumInvestment;
  final double currentNAV;
  final double previousNAV;
  final double totalAssets;
  final int totalInvestors;
  final double managementFee;
  final double performanceFee;
  final String fundManager;
  final String fundManagerId;
  final DateTime inceptionDate;
  final DateTime? maturityDate;
  final bool isActive;
  final bool isPublic;
  final List<String> tags;
  final FundPerformance performance;
  final List<AssetAllocation> assetAllocation;
  final List<String> documents;
  final String? imageUrl;
  final String? prospectusUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvestmentFund({
    required this.id,
    required this.name,
    required this.description,
    required this.shortDescription,
    required this.type,
    required this.category,
    required this.riskLevel,
    required this.currency,
    required this.minimumInvestment,
    required this.maximumInvestment,
    required this.currentNAV,
    required this.previousNAV,
    required this.totalAssets,
    required this.totalInvestors,
    required this.managementFee,
    required this.performanceFee,
    required this.fundManager,
    required this.fundManagerId,
    required this.inceptionDate,
    this.maturityDate,
    required this.isActive,
    required this.isPublic,
    required this.tags,
    required this.performance,
    required this.assetAllocation,
    required this.documents,
    this.imageUrl,
    this.prospectusUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvestmentFund.fromJson(Map<String, dynamic> json) => _$InvestmentFundFromJson(json);
  Map<String, dynamic> toJson() => _$InvestmentFundToJson(this);

  InvestmentFund copyWith({
    String? id,
    String? name,
    String? description,
    String? shortDescription,
    FundType? type,
    FundCategory? category,
    RiskLevel? riskLevel,
    String? currency,
    double? minimumInvestment,
    double? maximumInvestment,
    double? currentNAV,
    double? previousNAV,
    double? totalAssets,
    int? totalInvestors,
    double? managementFee,
    double? performanceFee,
    String? fundManager,
    String? fundManagerId,
    DateTime? inceptionDate,
    DateTime? maturityDate,
    bool? isActive,
    bool? isPublic,
    List<String>? tags,
    FundPerformance? performance,
    List<AssetAllocation>? assetAllocation,
    List<String>? documents,
    String? imageUrl,
    String? prospectusUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvestmentFund(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      type: type ?? this.type,
      category: category ?? this.category,
      riskLevel: riskLevel ?? this.riskLevel,
      currency: currency ?? this.currency,
      minimumInvestment: minimumInvestment ?? this.minimumInvestment,
      maximumInvestment: maximumInvestment ?? this.maximumInvestment,
      currentNAV: currentNAV ?? this.currentNAV,
      previousNAV: previousNAV ?? this.previousNAV,
      totalAssets: totalAssets ?? this.totalAssets,
      totalInvestors: totalInvestors ?? this.totalInvestors,
      managementFee: managementFee ?? this.managementFee,
      performanceFee: performanceFee ?? this.performanceFee,
      fundManager: fundManager ?? this.fundManager,
      fundManagerId: fundManagerId ?? this.fundManagerId,
      inceptionDate: inceptionDate ?? this.inceptionDate,
      maturityDate: maturityDate ?? this.maturityDate,
      isActive: isActive ?? this.isActive,
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? this.tags,
      performance: performance ?? this.performance,
      assetAllocation: assetAllocation ?? this.assetAllocation,
      documents: documents ?? this.documents,
      imageUrl: imageUrl ?? this.imageUrl,
      prospectusUrl: prospectusUrl ?? this.prospectusUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculated properties
  double get dailyReturn {
    if (previousNAV == 0) return 0.0;
    return ((currentNAV - previousNAV) / previousNAV) * 100;
  }

  double get totalReturnSinceInception {
    return performance.totalReturn;
  }

  double get annualizedReturn {
    return performance.annualizedReturn;
  }

  String get riskLevelText {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.moderate:
        return 'Moderate Risk';
      case RiskLevel.high:
        return 'High Risk';
      case RiskLevel.veryHigh:
        return 'Very High Risk';
    }
  }

  String get categoryText {
    switch (category) {
      case FundCategory.equity:
        return 'Equity Fund';
      case FundCategory.bond:
        return 'Bond Fund';
      case FundCategory.mixed:
        return 'Mixed Fund';
      case FundCategory.moneyMarket:
        return 'Money Market';
      case FundCategory.realEstate:
        return 'Real Estate';
      case FundCategory.commodity:
        return 'Commodity';
      case FundCategory.alternative:
        return 'Alternative';
    }
  }

  bool get isAvailableForInvestment {
    return isActive && isPublic;
  }

  String get formattedTotalAssets {
    if (totalAssets >= 1000000000) {
      return '₦${(totalAssets / 1000000000).toStringAsFixed(1)}B';
    } else if (totalAssets >= 1000000) {
      return '₦${(totalAssets / 1000000).toStringAsFixed(1)}M';
    } else if (totalAssets >= 1000) {
      return '₦${(totalAssets / 1000).toStringAsFixed(1)}K';
    }
    return '₦${totalAssets.toStringAsFixed(0)}';
  }
}

@JsonSerializable()
class FundPerformance {
  final double totalReturn;
  final double annualizedReturn;
  final double volatility;
  final double sharpeRatio;
  final double maxDrawdown;
  final double ytdReturn;
  final double oneMonthReturn;
  final double threeMonthReturn;
  final double sixMonthReturn;
  final double oneYearReturn;
  final double threeYearReturn;
  final double fiveYearReturn;
  final List<PerformanceDataPoint> historicalData;

  FundPerformance({
    required this.totalReturn,
    required this.annualizedReturn,
    required this.volatility,
    required this.sharpeRatio,
    required this.maxDrawdown,
    required this.ytdReturn,
    required this.oneMonthReturn,
    required this.threeMonthReturn,
    required this.sixMonthReturn,
    required this.oneYearReturn,
    required this.threeYearReturn,
    required this.fiveYearReturn,
    required this.historicalData,
  });

  factory FundPerformance.fromJson(Map<String, dynamic> json) => _$FundPerformanceFromJson(json);
  Map<String, dynamic> toJson() => _$FundPerformanceToJson(this);
}

@JsonSerializable()
class PerformanceDataPoint {
  final DateTime date;
  final double nav;
  final double return_;
  final double cumulativeReturn;

  PerformanceDataPoint({
    required this.date,
    required this.nav,
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
  final String description;

  AssetAllocation({
    required this.assetClass,
    required this.percentage,
    required this.description,
  });

  factory AssetAllocation.fromJson(Map<String, dynamic> json) => _$AssetAllocationFromJson(json);
  Map<String, dynamic> toJson() => _$AssetAllocationToJson(this);
}

@JsonSerializable()
class FundManager {
  final String id;
  final String name;
  final String bio;
  final String experience;
  final String education;
  final List<String> certifications;
  final String? imageUrl;
  final List<String> managedFunds;
  final double totalAssetsUnderManagement;

  FundManager({
    required this.id,
    required this.name,
    required this.bio,
    required this.experience,
    required this.education,
    required this.certifications,
    this.imageUrl,
    required this.managedFunds,
    required this.totalAssetsUnderManagement,
  });

  factory FundManager.fromJson(Map<String, dynamic> json) => _$FundManagerFromJson(json);
  Map<String, dynamic> toJson() => _$FundManagerToJson(this);
}

enum FundType {
  @JsonValue('OPEN_ENDED')
  openEnded,
  @JsonValue('CLOSED_ENDED')
  closedEnded,
  @JsonValue('ETF')
  etf,
  @JsonValue('MUTUAL_FUND')
  mutualFund,
}

enum FundCategory {
  @JsonValue('EQUITY')
  equity,
  @JsonValue('BOND')
  bond,
  @JsonValue('MIXED')
  mixed,
  @JsonValue('MONEY_MARKET')
  moneyMarket,
  @JsonValue('REAL_ESTATE')
  realEstate,
  @JsonValue('COMMODITY')
  commodity,
  @JsonValue('ALTERNATIVE')
  alternative,
}

enum RiskLevel {
  @JsonValue('LOW')
  low,
  @JsonValue('MODERATE')
  moderate,
  @JsonValue('HIGH')
  high,
  @JsonValue('VERY_HIGH')
  veryHigh,
}
