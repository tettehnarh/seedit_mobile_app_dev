import '../models/goal_models.dart';
import 'dart:developer' as developer;

/// Utility class for calculating goal progress based on allocation percentage
class ProgressCalculator {
  /// Calculate allocation-based progress for a goal
  static AllocationBasedProgress calculateProgress({
    required PersonalGoal goal,
    required Map<String, dynamic> fundInvestmentsData,
  }) {
    developer.log(
      '🎯 [PROGRESS_CALCULATOR] Calculating progress for goal: ${goal.name}',
    );

    // If no fund is linked, use the current amount from the goal
    if (goal.linkedFund == null || goal.linkedFund!.isEmpty) {
      developer.log(
        '🎯 [PROGRESS_CALCULATOR] No linked fund, using current amount: ${goal.currentAmount}',
      );
      
      return AllocationBasedProgress(
        allocatedAmount: goal.currentAmount,
        totalFundInvestment: 0.0,
        allocationPercentage: goal.allocationPercentage,
        progressPercentage: _calculateProgressPercentage(
          goal.currentAmount,
          goal.targetAmount,
        ),
        remainingAmount: _calculateRemainingAmount(
          goal.currentAmount,
          goal.targetAmount,
        ),
        isCompleted: goal.currentAmount >= goal.targetAmount,
        fundName: null,
      );
    }

    // Get fund investment data
    final fundInvestments = fundInvestmentsData['fund_investments'] as Map<String, dynamic>? ?? {};
    final fundData = fundInvestments[goal.linkedFund] as Map<String, dynamic>?;
    
    final totalFundInvestment = fundData?['total_invested'] as double? ?? 0.0;
    final fundName = fundData?['fund_name'] as String?;
    
    // Calculate allocated amount based on allocation percentage
    final allocatedAmount = totalFundInvestment * (goal.allocationPercentage / 100.0);
    
    final progressPercentage = _calculateProgressPercentage(
      allocatedAmount,
      goal.targetAmount,
    );
    
    final remainingAmount = _calculateRemainingAmount(
      allocatedAmount,
      goal.targetAmount,
    );

    developer.log(
      '🎯 [PROGRESS_CALCULATOR] Results: '
      'Total fund investment: GHS $totalFundInvestment, '
      'Allocation: ${goal.allocationPercentage}%, '
      'Allocated amount: GHS $allocatedAmount, '
      'Progress: ${progressPercentage.toStringAsFixed(1)}%',
    );

    return AllocationBasedProgress(
      allocatedAmount: allocatedAmount,
      totalFundInvestment: totalFundInvestment,
      allocationPercentage: goal.allocationPercentage,
      progressPercentage: progressPercentage,
      remainingAmount: remainingAmount,
      isCompleted: allocatedAmount >= goal.targetAmount,
      fundName: fundName,
    );
  }

  /// Calculate progress percentage
  static double _calculateProgressPercentage(double currentAmount, double targetAmount) {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount * 100).clamp(0.0, 100.0);
  }

  /// Calculate remaining amount
  static double _calculateRemainingAmount(double currentAmount, double targetAmount) {
    return (targetAmount - currentAmount).clamp(0.0, double.infinity);
  }

  /// Get progress status text
  static String getProgressStatusText(AllocationBasedProgress progress) {
    if (progress.isCompleted) {
      return 'Goal achieved! 🎉';
    } else if (progress.progressPercentage >= 75) {
      return 'Almost there!';
    } else if (progress.progressPercentage >= 50) {
      return 'Halfway there!';
    } else if (progress.progressPercentage >= 25) {
      return 'Making progress';
    } else {
      return 'Just getting started';
    }
  }

  /// Get allocation description text
  static String getAllocationDescription(AllocationBasedProgress progress) {
    if (progress.fundName == null) {
      return 'Manual contributions';
    }
    
    if (progress.allocationPercentage >= 100) {
      return 'Based on all ${progress.fundName} investments';
    } else {
      return 'Based on ${progress.allocationPercentage.toInt()}% of ${progress.fundName} investments';
    }
  }
}

/// Data class for allocation-based progress calculation results
class AllocationBasedProgress {
  final double allocatedAmount;
  final double totalFundInvestment;
  final double allocationPercentage;
  final double progressPercentage;
  final double remainingAmount;
  final bool isCompleted;
  final String? fundName;

  const AllocationBasedProgress({
    required this.allocatedAmount,
    required this.totalFundInvestment,
    required this.allocationPercentage,
    required this.progressPercentage,
    required this.remainingAmount,
    required this.isCompleted,
    this.fundName,
  });

  @override
  String toString() {
    return 'AllocationBasedProgress('
        'allocatedAmount: $allocatedAmount, '
        'totalFundInvestment: $totalFundInvestment, '
        'allocationPercentage: $allocationPercentage, '
        'progressPercentage: $progressPercentage, '
        'remainingAmount: $remainingAmount, '
        'isCompleted: $isCompleted, '
        'fundName: $fundName)';
  }
}
