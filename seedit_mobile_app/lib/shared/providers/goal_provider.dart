import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/goal_model.dart';
import '../../core/services/goal_service.dart';
import 'auth_provider.dart';

// Service provider
final goalServiceProvider = Provider<GoalService>((ref) => GoalService());

// User goals provider
final userGoalsProvider = FutureProvider<List<FinancialGoal>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return [];
  
  final service = ref.read(goalServiceProvider);
  return await service.getUserGoals(currentUser.id);
});

// Goal by ID provider
final goalByIdProvider = FutureProvider.family<FinancialGoal?, String>((ref, goalId) async {
  final service = ref.read(goalServiceProvider);
  return await service.getGoalById(goalId);
});

// Goal allocations provider
final goalAllocationsProvider = FutureProvider.family<List<GoalAllocation>, String>((ref, goalId) async {
  final service = ref.read(goalServiceProvider);
  return await service.getGoalAllocations(goalId);
});

// Goal recommendations provider
final goalRecommendationsProvider = FutureProvider.family<List<GoalRecommendation>, String>((ref, goalId) async {
  final service = ref.read(goalServiceProvider);
  return await service.getGoalRecommendations(goalId);
});

// Goal progress provider
final goalProgressProvider = FutureProvider.family<GoalProgress, String>((ref, goalId) async {
  final service = ref.read(goalServiceProvider);
  return await service.getGoalProgress(goalId);
});

// Goal management state provider
final goalManagementProvider = StateNotifierProvider<GoalManagementNotifier, GoalManagementState>((ref) {
  return GoalManagementNotifier(ref.read(goalServiceProvider));
});

class GoalManagementState {
  final bool isLoading;
  final String? error;
  final FinancialGoal? currentGoal;
  final GoalAllocation? currentAllocation;
  final GoalProgress? currentProgress;
  final Map<String, dynamic>? goalRequirements;

  GoalManagementState({
    this.isLoading = false,
    this.error,
    this.currentGoal,
    this.currentAllocation,
    this.currentProgress,
    this.goalRequirements,
  });

  GoalManagementState copyWith({
    bool? isLoading,
    String? error,
    FinancialGoal? currentGoal,
    GoalAllocation? currentAllocation,
    GoalProgress? currentProgress,
    Map<String, dynamic>? goalRequirements,
  }) {
    return GoalManagementState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentGoal: currentGoal ?? this.currentGoal,
      currentAllocation: currentAllocation ?? this.currentAllocation,
      currentProgress: currentProgress ?? this.currentProgress,
      goalRequirements: goalRequirements ?? this.goalRequirements,
    );
  }
}

class GoalManagementNotifier extends StateNotifier<GoalManagementState> {
  final GoalService _service;

  GoalManagementNotifier(this._service) : super(GoalManagementState());

  // Create goal
  Future<FinancialGoal?> createGoal({
    required String userId,
    required String name,
    required String description,
    required GoalCategory category,
    required GoalPriority priority,
    required double targetAmount,
    required DateTime targetDate,
    DateTime? startDate,
    GoalStrategy strategy = GoalStrategy.moderate,
    List<GoalMilestone> milestones = const [],
    GoalSettings? settings,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final goal = await _service.createGoal(
        userId: userId,
        name: name,
        description: description,
        category: category,
        priority: priority,
        targetAmount: targetAmount,
        targetDate: targetDate,
        startDate: startDate,
        strategy: strategy,
        milestones: milestones,
        settings: settings,
      );

      state = state.copyWith(
        isLoading: false,
        currentGoal: goal,
      );

      return goal;
    } catch (e) {
      debugPrint('Create goal error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Update goal
  Future<FinancialGoal?> updateGoal({
    required String goalId,
    String? name,
    String? description,
    GoalCategory? category,
    GoalPriority? priority,
    double? targetAmount,
    DateTime? targetDate,
    GoalStrategy? strategy,
    GoalSettings? settings,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final goal = await _service.updateGoal(
        goalId: goalId,
        name: name,
        description: description,
        category: category,
        priority: priority,
        targetAmount: targetAmount,
        targetDate: targetDate,
        strategy: strategy,
        settings: settings,
      );

      state = state.copyWith(
        isLoading: false,
        currentGoal: goal,
      );

      return goal;
    } catch (e) {
      debugPrint('Update goal error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Update goal progress
  Future<bool> updateGoalProgress({
    required String goalId,
    required double amount,
    String? source,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final goal = await _service.updateGoalProgress(
        goalId: goalId,
        amount: amount,
        source: source,
      );

      state = state.copyWith(
        isLoading: false,
        currentGoal: goal,
      );

      return true;
    } catch (e) {
      debugPrint('Update goal progress error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Pause goal
  Future<bool> pauseGoal(String goalId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final goal = await _service.pauseGoal(goalId);
      
      state = state.copyWith(
        isLoading: false,
        currentGoal: goal,
      );

      return true;
    } catch (e) {
      debugPrint('Pause goal error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Resume goal
  Future<bool> resumeGoal(String goalId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final goal = await _service.resumeGoal(goalId);
      
      state = state.copyWith(
        isLoading: false,
        currentGoal: goal,
      );

      return true;
    } catch (e) {
      debugPrint('Resume goal error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Complete goal
  Future<bool> completeGoal(String goalId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final goal = await _service.completeGoal(goalId);
      
      state = state.copyWith(
        isLoading: false,
        currentGoal: goal,
      );

      return true;
    } catch (e) {
      debugPrint('Complete goal error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Update goal allocation
  Future<GoalAllocation?> updateGoalAllocation({
    required String goalId,
    required String fundId,
    required double allocationPercentage,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final allocation = await _service.updateGoalAllocation(
        goalId: goalId,
        fundId: fundId,
        allocationPercentage: allocationPercentage,
      );

      state = state.copyWith(
        isLoading: false,
        currentAllocation: allocation,
      );

      return allocation;
    } catch (e) {
      debugPrint('Update goal allocation error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Calculate goal requirements
  Future<void> calculateGoalRequirements({
    required double targetAmount,
    required DateTime targetDate,
    double currentAmount = 0.0,
    double expectedReturn = 12.0,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final requirements = await _service.calculateGoalRequirements(
        targetAmount: targetAmount,
        targetDate: targetDate,
        currentAmount: currentAmount,
        expectedReturn: expectedReturn,
      );

      state = state.copyWith(
        isLoading: false,
        goalRequirements: requirements,
      );
    } catch (e) {
      debugPrint('Calculate goal requirements error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear current goal
  void clearCurrentGoal() {
    state = state.copyWith(currentGoal: null);
  }

  // Clear current allocation
  void clearCurrentAllocation() {
    state = state.copyWith(currentAllocation: null);
  }

  // Clear current progress
  void clearCurrentProgress() {
    state = state.copyWith(currentProgress: null);
  }

  // Clear goal requirements
  void clearGoalRequirements() {
    state = state.copyWith(goalRequirements: null);
  }
}

// Goal calculator provider
final goalCalculatorProvider = StateNotifierProvider<GoalCalculatorNotifier, GoalCalculatorState>((ref) {
  return GoalCalculatorNotifier();
});

class GoalCalculatorState {
  final double targetAmount;
  final DateTime targetDate;
  final double currentAmount;
  final double expectedReturn;
  final double monthlyRequired;
  final double sipAmount;
  final double lumpSumRequired;
  final bool isFeasible;

  GoalCalculatorState({
    this.targetAmount = 1000000,
    DateTime? targetDate,
    this.currentAmount = 0,
    this.expectedReturn = 12.0,
    this.monthlyRequired = 0,
    this.sipAmount = 0,
    this.lumpSumRequired = 0,
    this.isFeasible = true,
  }) : targetDate = targetDate ?? DateTime.now().add(const Duration(days: 1825)); // 5 years

  GoalCalculatorState copyWith({
    double? targetAmount,
    DateTime? targetDate,
    double? currentAmount,
    double? expectedReturn,
    double? monthlyRequired,
    double? sipAmount,
    double? lumpSumRequired,
    bool? isFeasible,
  }) {
    return GoalCalculatorState(
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      currentAmount: currentAmount ?? this.currentAmount,
      expectedReturn: expectedReturn ?? this.expectedReturn,
      monthlyRequired: monthlyRequired ?? this.monthlyRequired,
      sipAmount: sipAmount ?? this.sipAmount,
      lumpSumRequired: lumpSumRequired ?? this.lumpSumRequired,
      isFeasible: isFeasible ?? this.isFeasible,
    );
  }
}

class GoalCalculatorNotifier extends StateNotifier<GoalCalculatorState> {
  GoalCalculatorNotifier() : super(GoalCalculatorState()) {
    _calculateRequirements();
  }

  void updateTargetAmount(double amount) {
    state = state.copyWith(targetAmount: amount);
    _calculateRequirements();
  }

  void updateTargetDate(DateTime date) {
    state = state.copyWith(targetDate: date);
    _calculateRequirements();
  }

  void updateCurrentAmount(double amount) {
    state = state.copyWith(currentAmount: amount);
    _calculateRequirements();
  }

  void updateExpectedReturn(double return_) {
    state = state.copyWith(expectedReturn: return_);
    _calculateRequirements();
  }

  void _calculateRequirements() {
    final remainingAmount = state.targetAmount - state.currentAmount;
    final monthsRemaining = state.targetDate.difference(DateTime.now()).inDays / 30;
    
    if (monthsRemaining <= 0) {
      state = state.copyWith(
        monthlyRequired: remainingAmount,
        sipAmount: remainingAmount,
        lumpSumRequired: remainingAmount,
        isFeasible: false,
      );
      return;
    }
    
    // Simple calculation (would use proper financial formulas)
    final monthlyRequired = remainingAmount / monthsRemaining;
    final sipAmount = monthlyRequired * 0.9; // Assuming SIP advantage
    final isFeasible = monthlyRequired <= state.targetAmount * 0.1; // 10% of target per month max
    
    state = state.copyWith(
      monthlyRequired: monthlyRequired,
      sipAmount: sipAmount,
      lumpSumRequired: remainingAmount,
      isFeasible: isFeasible,
    );
  }
}
