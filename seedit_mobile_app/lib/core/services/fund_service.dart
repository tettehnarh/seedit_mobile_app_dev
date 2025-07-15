import 'package:flutter/foundation.dart';
import '../../shared/models/fund_model.dart';

class FundService {
  // Get all available funds
  Future<List<InvestmentFund>> getAllFunds() async {
    try {
      // TODO: Replace with actual API call when backend is ready
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      return _getMockFunds();
    } catch (e) {
      debugPrint('Get all funds error: $e');
      throw Exception('Failed to load funds');
    }
  }

  // Get funds by category
  Future<List<InvestmentFund>> getFundsByCategory(FundCategory category) async {
    try {
      final allFunds = await getAllFunds();
      return allFunds.where((fund) => fund.category == category).toList();
    } catch (e) {
      debugPrint('Get funds by category error: $e');
      throw Exception('Failed to load funds by category');
    }
  }

  // Get funds by risk level
  Future<List<InvestmentFund>> getFundsByRiskLevel(RiskLevel riskLevel) async {
    try {
      final allFunds = await getAllFunds();
      return allFunds.where((fund) => fund.riskLevel == riskLevel).toList();
    } catch (e) {
      debugPrint('Get funds by risk level error: $e');
      throw Exception('Failed to load funds by risk level');
    }
  }

  // Search funds
  Future<List<InvestmentFund>> searchFunds(String query) async {
    try {
      final allFunds = await getAllFunds();
      final lowercaseQuery = query.toLowerCase();
      
      return allFunds.where((fund) {
        return fund.name.toLowerCase().contains(lowercaseQuery) ||
               fund.description.toLowerCase().contains(lowercaseQuery) ||
               fund.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
               fund.fundManager.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      debugPrint('Search funds error: $e');
      throw Exception('Failed to search funds');
    }
  }

  // Get fund by ID
  Future<InvestmentFund?> getFundById(String fundId) async {
    try {
      final allFunds = await getAllFunds();
      return allFunds.where((fund) => fund.id == fundId).firstOrNull;
    } catch (e) {
      debugPrint('Get fund by ID error: $e');
      throw Exception('Failed to load fund details');
    }
  }

  // Get trending funds
  Future<List<InvestmentFund>> getTrendingFunds() async {
    try {
      final allFunds = await getAllFunds();
      // Sort by performance and return top performers
      allFunds.sort((a, b) => b.performance.oneMonthReturn.compareTo(a.performance.oneMonthReturn));
      return allFunds.take(5).toList();
    } catch (e) {
      debugPrint('Get trending funds error: $e');
      throw Exception('Failed to load trending funds');
    }
  }

  // Get recommended funds for user
  Future<List<InvestmentFund>> getRecommendedFunds(String userId) async {
    try {
      // TODO: Implement personalized recommendations based on user profile
      final allFunds = await getAllFunds();
      return allFunds.where((fund) => fund.riskLevel == RiskLevel.moderate).take(3).toList();
    } catch (e) {
      debugPrint('Get recommended funds error: $e');
      throw Exception('Failed to load recommended funds');
    }
  }

  // Get fund performance history
  Future<List<PerformanceDataPoint>> getFundPerformanceHistory(
    String fundId,
    Duration period,
  ) async {
    try {
      final fund = await getFundById(fundId);
      if (fund == null) throw Exception('Fund not found');
      
      // Filter performance data based on period
      final cutoffDate = DateTime.now().subtract(period);
      return fund.performance.historicalData
          .where((point) => point.date.isAfter(cutoffDate))
          .toList();
    } catch (e) {
      debugPrint('Get fund performance history error: $e');
      throw Exception('Failed to load fund performance history');
    }
  }

  // Get fund manager details
  Future<FundManager?> getFundManager(String managerId) async {
    try {
      // TODO: Replace with actual API call
      return _getMockFundManager(managerId);
    } catch (e) {
      debugPrint('Get fund manager error: $e');
      throw Exception('Failed to load fund manager details');
    }
  }

  // Filter funds
  Future<List<InvestmentFund>> filterFunds({
    List<FundCategory>? categories,
    List<RiskLevel>? riskLevels,
    double? minInvestment,
    double? maxInvestment,
    double? minReturn,
    List<String>? tags,
  }) async {
    try {
      var funds = await getAllFunds();

      if (categories != null && categories.isNotEmpty) {
        funds = funds.where((fund) => categories.contains(fund.category)).toList();
      }

      if (riskLevels != null && riskLevels.isNotEmpty) {
        funds = funds.where((fund) => riskLevels.contains(fund.riskLevel)).toList();
      }

      if (minInvestment != null) {
        funds = funds.where((fund) => fund.minimumInvestment >= minInvestment).toList();
      }

      if (maxInvestment != null) {
        funds = funds.where((fund) => fund.minimumInvestment <= maxInvestment).toList();
      }

      if (minReturn != null) {
        funds = funds.where((fund) => fund.performance.annualizedReturn >= minReturn).toList();
      }

      if (tags != null && tags.isNotEmpty) {
        funds = funds.where((fund) => 
          fund.tags.any((tag) => tags.contains(tag))
        ).toList();
      }

      return funds;
    } catch (e) {
      debugPrint('Filter funds error: $e');
      throw Exception('Failed to filter funds');
    }
  }

  // Mock data methods (replace with actual API calls)
  List<InvestmentFund> _getMockFunds() {
    return [
      InvestmentFund(
        id: 'fund_001',
        name: 'SeedIt Equity Growth Fund',
        description: 'A diversified equity fund focused on growth stocks with strong fundamentals and long-term potential.',
        shortDescription: 'Growth-focused equity fund for long-term wealth creation',
        type: FundType.openEnded,
        category: FundCategory.equity,
        riskLevel: RiskLevel.high,
        currency: 'NGN',
        minimumInvestment: 10000,
        maximumInvestment: 10000000,
        currentNAV: 125.50,
        previousNAV: 123.75,
        totalAssets: 2500000000,
        totalInvestors: 1250,
        managementFee: 1.5,
        performanceFee: 20.0,
        fundManager: 'Adebayo Ogundimu',
        fundManagerId: 'manager_001',
        inceptionDate: DateTime(2020, 1, 15),
        isActive: true,
        isPublic: true,
        tags: ['growth', 'equity', 'long-term', 'diversified'],
        performance: FundPerformance(
          totalReturn: 25.5,
          annualizedReturn: 12.8,
          volatility: 18.5,
          sharpeRatio: 0.69,
          maxDrawdown: -15.2,
          ytdReturn: 8.5,
          oneMonthReturn: 2.1,
          threeMonthReturn: 5.8,
          sixMonthReturn: 7.2,
          oneYearReturn: 12.8,
          threeYearReturn: 11.5,
          fiveYearReturn: 0.0,
          historicalData: _generateMockPerformanceData(),
        ),
        assetAllocation: [
          AssetAllocation(assetClass: 'Nigerian Equities', percentage: 70.0, description: 'Large and mid-cap Nigerian stocks'),
          AssetAllocation(assetClass: 'International Equities', percentage: 20.0, description: 'Developed market equities'),
          AssetAllocation(assetClass: 'Cash & Equivalents', percentage: 10.0, description: 'Money market instruments'),
        ],
        documents: ['prospectus.pdf', 'annual_report.pdf'],
        imageUrl: 'https://example.com/fund_images/equity_growth.jpg',
        prospectusUrl: 'https://example.com/documents/equity_growth_prospectus.pdf',
        createdAt: DateTime(2020, 1, 15),
        updatedAt: DateTime.now(),
      ),
      InvestmentFund(
        id: 'fund_002',
        name: 'SeedIt Bond Income Fund',
        description: 'A conservative bond fund that provides steady income through government and corporate bonds.',
        shortDescription: 'Stable income through diversified bond investments',
        type: FundType.openEnded,
        category: FundCategory.bond,
        riskLevel: RiskLevel.low,
        currency: 'NGN',
        minimumInvestment: 5000,
        maximumInvestment: 5000000,
        currentNAV: 108.25,
        previousNAV: 108.10,
        totalAssets: 1800000000,
        totalInvestors: 2100,
        managementFee: 1.0,
        performanceFee: 0.0,
        fundManager: 'Funmi Adebisi',
        fundManagerId: 'manager_002',
        inceptionDate: DateTime(2019, 6, 1),
        isActive: true,
        isPublic: true,
        tags: ['bonds', 'income', 'conservative', 'stable'],
        performance: FundPerformance(
          totalReturn: 8.25,
          annualizedReturn: 6.5,
          volatility: 4.2,
          sharpeRatio: 1.55,
          maxDrawdown: -2.8,
          ytdReturn: 4.2,
          oneMonthReturn: 0.5,
          threeMonthReturn: 1.8,
          sixMonthReturn: 3.1,
          oneYearReturn: 6.5,
          threeYearReturn: 6.8,
          fiveYearReturn: 0.0,
          historicalData: _generateMockPerformanceData(startNav: 100.0, volatility: 0.02),
        ),
        assetAllocation: [
          AssetAllocation(assetClass: 'Government Bonds', percentage: 60.0, description: 'Nigerian government securities'),
          AssetAllocation(assetClass: 'Corporate Bonds', percentage: 30.0, description: 'High-grade corporate bonds'),
          AssetAllocation(assetClass: 'Treasury Bills', percentage: 10.0, description: 'Short-term government securities'),
        ],
        documents: ['prospectus.pdf', 'annual_report.pdf'],
        imageUrl: 'https://example.com/fund_images/bond_income.jpg',
        prospectusUrl: 'https://example.com/documents/bond_income_prospectus.pdf',
        createdAt: DateTime(2019, 6, 1),
        updatedAt: DateTime.now(),
      ),
      InvestmentFund(
        id: 'fund_003',
        name: 'SeedIt Balanced Fund',
        description: 'A balanced fund that combines equity and fixed income investments for moderate growth and income.',
        shortDescription: 'Balanced approach combining growth and income',
        type: FundType.openEnded,
        category: FundCategory.mixed,
        riskLevel: RiskLevel.moderate,
        currency: 'NGN',
        minimumInvestment: 7500,
        maximumInvestment: 7500000,
        currentNAV: 115.80,
        previousNAV: 115.20,
        totalAssets: 3200000000,
        totalInvestors: 1800,
        managementFee: 1.25,
        performanceFee: 15.0,
        fundManager: 'Chidi Okwu',
        fundManagerId: 'manager_003',
        inceptionDate: DateTime(2018, 3, 20),
        isActive: true,
        isPublic: true,
        tags: ['balanced', 'mixed', 'moderate', 'diversified'],
        performance: FundPerformance(
          totalReturn: 15.8,
          annualizedReturn: 9.2,
          volatility: 12.1,
          sharpeRatio: 0.76,
          maxDrawdown: -8.5,
          ytdReturn: 6.1,
          oneMonthReturn: 1.2,
          threeMonthReturn: 3.5,
          sixMonthReturn: 5.2,
          oneYearReturn: 9.2,
          threeYearReturn: 8.8,
          fiveYearReturn: 0.0,
          historicalData: _generateMockPerformanceData(startNav: 100.0, volatility: 0.08),
        ),
        assetAllocation: [
          AssetAllocation(assetClass: 'Equities', percentage: 50.0, description: 'Diversified equity investments'),
          AssetAllocation(assetClass: 'Bonds', percentage: 40.0, description: 'Government and corporate bonds'),
          AssetAllocation(assetClass: 'Cash & Equivalents', percentage: 10.0, description: 'Money market instruments'),
        ],
        documents: ['prospectus.pdf', 'annual_report.pdf'],
        imageUrl: 'https://example.com/fund_images/balanced.jpg',
        prospectusUrl: 'https://example.com/documents/balanced_prospectus.pdf',
        createdAt: DateTime(2018, 3, 20),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  FundManager _getMockFundManager(String managerId) {
    switch (managerId) {
      case 'manager_001':
        return FundManager(
          id: 'manager_001',
          name: 'Adebayo Ogundimu',
          bio: 'Experienced fund manager with over 15 years in equity markets and portfolio management.',
          experience: '15+ years in investment management',
          education: 'MBA Finance, University of Lagos; CFA Charter',
          certifications: ['CFA', 'FRM', 'CAIA'],
          imageUrl: 'https://example.com/managers/adebayo.jpg',
          managedFunds: ['fund_001'],
          totalAssetsUnderManagement: 2500000000,
        );
      case 'manager_002':
        return FundManager(
          id: 'manager_002',
          name: 'Funmi Adebisi',
          bio: 'Fixed income specialist with deep expertise in bond markets and credit analysis.',
          experience: '12+ years in fixed income',
          education: 'MSc Economics, University of Ibadan; CFA Charter',
          certifications: ['CFA', 'FRM'],
          imageUrl: 'https://example.com/managers/funmi.jpg',
          managedFunds: ['fund_002'],
          totalAssetsUnderManagement: 1800000000,
        );
      default:
        return FundManager(
          id: 'manager_003',
          name: 'Chidi Okwu',
          bio: 'Multi-asset portfolio manager with expertise in balanced investment strategies.',
          experience: '10+ years in portfolio management',
          education: 'BSc Accounting, University of Nigeria; CFA Charter',
          certifications: ['CFA', 'CAIA'],
          imageUrl: 'https://example.com/managers/chidi.jpg',
          managedFunds: ['fund_003'],
          totalAssetsUnderManagement: 3200000000,
        );
    }
  }

  List<PerformanceDataPoint> _generateMockPerformanceData({
    double startNav = 100.0,
    double volatility = 0.12,
  }) {
    final List<PerformanceDataPoint> data = [];
    final now = DateTime.now();
    double currentNav = startNav;
    double cumulativeReturn = 0.0;

    for (int i = 365; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      
      // Simulate daily returns with some randomness
      final dailyReturn = (volatility / 16) * (DateTime.now().millisecond % 100 - 50) / 50;
      currentNav *= (1 + dailyReturn);
      cumulativeReturn = ((currentNav - startNav) / startNav) * 100;

      data.add(PerformanceDataPoint(
        date: date,
        nav: currentNav,
        return_: dailyReturn * 100,
        cumulativeReturn: cumulativeReturn,
      ));
    }

    return data;
  }
}
