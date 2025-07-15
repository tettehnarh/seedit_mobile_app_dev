import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/fund_model.dart';
import '../../core/services/fund_service.dart';
import 'auth_provider.dart';

// Fund service provider
final fundServiceProvider = Provider<FundService>((ref) => FundService());

// All funds provider
final allFundsProvider = FutureProvider<List<InvestmentFund>>((ref) async {
  final fundService = ref.read(fundServiceProvider);
  return await fundService.getAllFunds();
});

// Trending funds provider
final trendingFundsProvider = FutureProvider<List<InvestmentFund>>((ref) async {
  final fundService = ref.read(fundServiceProvider);
  return await fundService.getTrendingFunds();
});

// Recommended funds provider
final recommendedFundsProvider = FutureProvider<List<InvestmentFund>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return [];
  
  final fundService = ref.read(fundServiceProvider);
  return await fundService.getRecommendedFunds(currentUser.id);
});

// Fund by ID provider
final fundByIdProvider = FutureProvider.family<InvestmentFund?, String>((ref, fundId) async {
  final fundService = ref.read(fundServiceProvider);
  return await fundService.getFundById(fundId);
});

// Funds by category provider
final fundsByCategoryProvider = FutureProvider.family<List<InvestmentFund>, FundCategory>((ref, category) async {
  final fundService = ref.read(fundServiceProvider);
  return await fundService.getFundsByCategory(category);
});

// Funds by risk level provider
final fundsByRiskLevelProvider = FutureProvider.family<List<InvestmentFund>, RiskLevel>((ref, riskLevel) async {
  final fundService = ref.read(fundServiceProvider);
  return await fundService.getFundsByRiskLevel(riskLevel);
});

// Fund search provider
final fundSearchProvider = StateNotifierProvider<FundSearchNotifier, FundSearchState>((ref) {
  return FundSearchNotifier(ref.read(fundServiceProvider));
});

// Fund filter provider
final fundFilterProvider = StateNotifierProvider<FundFilterNotifier, FundFilterState>((ref) {
  return FundFilterNotifier(ref.read(fundServiceProvider));
});

// Fund performance provider
final fundPerformanceProvider = FutureProvider.family<List<PerformanceDataPoint>, FundPerformanceParams>((ref, params) async {
  final fundService = ref.read(fundServiceProvider);
  return await fundService.getFundPerformanceHistory(params.fundId, params.period);
});

// Fund manager provider
final fundManagerProvider = FutureProvider.family<FundManager?, String>((ref, managerId) async {
  final fundService = ref.read(fundServiceProvider);
  return await fundService.getFundManager(managerId);
});

class FundSearchState {
  final String query;
  final List<InvestmentFund> results;
  final bool isLoading;
  final String? error;

  FundSearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  FundSearchState copyWith({
    String? query,
    List<InvestmentFund>? results,
    bool? isLoading,
    String? error,
  }) {
    return FundSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FundSearchNotifier extends StateNotifier<FundSearchState> {
  final FundService _fundService;

  FundSearchNotifier(this._fundService) : super(FundSearchState());

  Future<void> searchFunds(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(query: '', results: [], error: null);
      return;
    }

    state = state.copyWith(query: query, isLoading: true, error: null);

    try {
      final results = await _fundService.searchFunds(query);
      state = state.copyWith(
        results: results,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Search funds error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearSearch() {
    state = FundSearchState();
  }
}

class FundFilterState {
  final List<FundCategory> selectedCategories;
  final List<RiskLevel> selectedRiskLevels;
  final double? minInvestment;
  final double? maxInvestment;
  final double? minReturn;
  final List<String> selectedTags;
  final List<InvestmentFund> filteredFunds;
  final bool isLoading;
  final String? error;

  FundFilterState({
    this.selectedCategories = const [],
    this.selectedRiskLevels = const [],
    this.minInvestment,
    this.maxInvestment,
    this.minReturn,
    this.selectedTags = const [],
    this.filteredFunds = const [],
    this.isLoading = false,
    this.error,
  });

  FundFilterState copyWith({
    List<FundCategory>? selectedCategories,
    List<RiskLevel>? selectedRiskLevels,
    double? minInvestment,
    double? maxInvestment,
    double? minReturn,
    List<String>? selectedTags,
    List<InvestmentFund>? filteredFunds,
    bool? isLoading,
    String? error,
  }) {
    return FundFilterState(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedRiskLevels: selectedRiskLevels ?? this.selectedRiskLevels,
      minInvestment: minInvestment ?? this.minInvestment,
      maxInvestment: maxInvestment ?? this.maxInvestment,
      minReturn: minReturn ?? this.minReturn,
      selectedTags: selectedTags ?? this.selectedTags,
      filteredFunds: filteredFunds ?? this.filteredFunds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasActiveFilters {
    return selectedCategories.isNotEmpty ||
           selectedRiskLevels.isNotEmpty ||
           minInvestment != null ||
           maxInvestment != null ||
           minReturn != null ||
           selectedTags.isNotEmpty;
  }
}

class FundFilterNotifier extends StateNotifier<FundFilterState> {
  final FundService _fundService;

  FundFilterNotifier(this._fundService) : super(FundFilterState());

  Future<void> applyFilters() async {
    if (!state.hasActiveFilters) {
      state = state.copyWith(filteredFunds: [], error: null);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final filteredFunds = await _fundService.filterFunds(
        categories: state.selectedCategories.isNotEmpty ? state.selectedCategories : null,
        riskLevels: state.selectedRiskLevels.isNotEmpty ? state.selectedRiskLevels : null,
        minInvestment: state.minInvestment,
        maxInvestment: state.maxInvestment,
        minReturn: state.minReturn,
        tags: state.selectedTags.isNotEmpty ? state.selectedTags : null,
      );

      state = state.copyWith(
        filteredFunds: filteredFunds,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Apply filters error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void updateCategories(List<FundCategory> categories) {
    state = state.copyWith(selectedCategories: categories);
    applyFilters();
  }

  void updateRiskLevels(List<RiskLevel> riskLevels) {
    state = state.copyWith(selectedRiskLevels: riskLevels);
    applyFilters();
  }

  void updateInvestmentRange(double? min, double? max) {
    state = state.copyWith(minInvestment: min, maxInvestment: max);
    applyFilters();
  }

  void updateMinReturn(double? minReturn) {
    state = state.copyWith(minReturn: minReturn);
    applyFilters();
  }

  void updateTags(List<String> tags) {
    state = state.copyWith(selectedTags: tags);
    applyFilters();
  }

  void clearFilters() {
    state = FundFilterState();
  }

  void toggleCategory(FundCategory category) {
    final categories = List<FundCategory>.from(state.selectedCategories);
    if (categories.contains(category)) {
      categories.remove(category);
    } else {
      categories.add(category);
    }
    updateCategories(categories);
  }

  void toggleRiskLevel(RiskLevel riskLevel) {
    final riskLevels = List<RiskLevel>.from(state.selectedRiskLevels);
    if (riskLevels.contains(riskLevel)) {
      riskLevels.remove(riskLevel);
    } else {
      riskLevels.add(riskLevel);
    }
    updateRiskLevels(riskLevels);
  }

  void toggleTag(String tag) {
    final tags = List<String>.from(state.selectedTags);
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    updateTags(tags);
  }
}

// Helper classes
class FundPerformanceParams {
  final String fundId;
  final Duration period;

  FundPerformanceParams({
    required this.fundId,
    required this.period,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FundPerformanceParams &&
          runtimeType == other.runtimeType &&
          fundId == other.fundId &&
          period == other.period;

  @override
  int get hashCode => fundId.hashCode ^ period.hashCode;
}

// Convenience providers for common fund categories
final equityFundsProvider = FutureProvider<List<InvestmentFund>>((ref) async {
  return ref.watch(fundsByCategoryProvider(FundCategory.equity).future);
});

final bondFundsProvider = FutureProvider<List<InvestmentFund>>((ref) async {
  return ref.watch(fundsByCategoryProvider(FundCategory.bond).future);
});

final mixedFundsProvider = FutureProvider<List<InvestmentFund>>((ref) async {
  return ref.watch(fundsByCategoryProvider(FundCategory.mixed).future);
});

// Convenience providers for risk levels
final lowRiskFundsProvider = FutureProvider<List<InvestmentFund>>((ref) async {
  return ref.watch(fundsByRiskLevelProvider(RiskLevel.low).future);
});

final moderateRiskFundsProvider = FutureProvider<List<InvestmentFund>>((ref) async {
  return ref.watch(fundsByRiskLevelProvider(RiskLevel.moderate).future);
});

final highRiskFundsProvider = FutureProvider<List<InvestmentFund>>((ref) async {
  return ref.watch(fundsByRiskLevelProvider(RiskLevel.high).future);
});
