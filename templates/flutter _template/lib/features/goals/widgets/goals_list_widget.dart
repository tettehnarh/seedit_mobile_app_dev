import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/goal_models.dart';
import '../providers/goals_provider.dart';
import '../screens/goal_detail_screen.dart';

class GoalsListWidget extends ConsumerWidget {
  final List<PersonalGoal> goals;

  const GoalsListWidget({super.key, required this.goals});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group goals by status
    final activeGoals = goals.where((goal) => goal.status == 'active').toList();
    final completedGoals = goals
        .where((goal) => goal.status == 'completed')
        .toList();
    final otherGoals = goals
        .where((goal) => goal.status != 'active' && goal.status != 'completed')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active Goals
        if (activeGoals.isNotEmpty) ...[
          _buildSectionHeader('Active Goals', activeGoals.length),
          const SizedBox(height: 12),
          ...activeGoals.map((goal) => GoalCard(goal: goal)),
          const SizedBox(height: 20),
        ],

        // Completed Goals
        if (completedGoals.isNotEmpty) ...[
          _buildSectionHeader('Completed Goals', completedGoals.length),
          const SizedBox(height: 12),
          ...completedGoals.map((goal) => GoalCard(goal: goal)),
          const SizedBox(height: 20),
        ],

        // Other Goals (Paused, Cancelled)
        if (otherGoals.isNotEmpty) ...[
          _buildSectionHeader('Other Goals', otherGoals.length),
          const SizedBox(height: 12),
          ...otherGoals.map((goal) => GoalCard(goal: goal)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

class GoalCard extends ConsumerWidget {
  final PersonalGoal goal;

  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fundInvestmentsAsync = ref.watch(fundInvestmentsWithRefreshProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToGoalDetail(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor().withOpacity(0.2),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: fundInvestmentsAsync.when(
              data: (investmentsData) => _buildGoalCardContent(investmentsData),
              loading: () => _buildGoalCardLoading(),
              error: (error, stack) => _buildGoalCardContent({}),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCardContent(Map<String, dynamic> investmentsData) {
    // Use backend-calculated values directly instead of recalculating
    final allocatedAmount = goal.currentAmount;
    final progressPercentage = goal.progressPercentage;
    final allocationPercentage = goal.allocationPercentage;
    final fundName = goal.linkedFundName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                goal.name,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                // Allocation badge (if fund is linked)
                if (fundName != null && allocationPercentage < 100) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${allocationPercentage.toInt()}%',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                _buildStatusChip(),
              ],
            ),
          ],
        ),

        if (goal.description != null && goal.description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            goal.description!,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        // Allocation description (if fund is linked)
        if (fundName != null) ...[
          const SizedBox(height: 8),
          Text(
            _getAllocationDescription(fundName, allocationPercentage),
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 11,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        const SizedBox(height: 16),

        // Progress Bar
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progressPercentage.toStringAsFixed(1)}% Complete',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  _formatTargetDate(),
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressPercentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
              minHeight: 6,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Amount Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.formatAmountWithCurrency(allocatedAmount),
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Target',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.formatAmountWithCurrency(goal.targetAmount),
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Investment Frequency and Required Amount
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_getFrequencyDisplayName()} Investment',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            Text(
              CurrencyFormatter.formatAmountWithCurrency(
                goal.requiredAmountPerFrequency,
              ),
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalCardLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                goal.name,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusChip(),
          ],
        ),

        const SizedBox(height: 16),

        // Loading indicator
        Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryColor,
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusDisplayName(),
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (goal.status) {
      case 'active':
        return AppTheme.primaryColor;
      case 'completed':
        return Colors.green;
      case 'paused':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName() {
    switch (goal.status) {
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'paused':
        return 'Paused';
      case 'cancelled':
        return 'Cancelled';
      default:
        return goal.status.toUpperCase();
    }
  }

  String _getFrequencyDisplayName() {
    switch (goal.investmentFrequency) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'quarterly':
        return 'Quarterly';
      default:
        return goal.investmentFrequency;
    }
  }

  String _formatTargetDate() {
    try {
      final date = DateTime.parse(goal.targetDate);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;

      if (difference < 0) {
        return 'Overdue';
      } else if (difference == 0) {
        return 'Due today';
      } else if (difference < 30) {
        return '$difference days left';
      } else if (difference < 365) {
        final months = (difference / 30).round();
        return '$months months left';
      } else {
        final years = (difference / 365).round();
        return '$years years left';
      }
    } catch (e) {
      return goal.targetDate;
    }
  }

  void _navigateToGoalDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GoalDetailScreen(goal: goal)),
    );
  }

  String _getAllocationDescription(
    String fundName,
    double allocationPercentage,
  ) {
    if (allocationPercentage >= 100) {
      return 'Based on all $fundName investments';
    } else {
      return 'Based on ${allocationPercentage.toInt()}% of $fundName investments';
    }
  }
}
