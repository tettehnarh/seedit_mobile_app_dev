import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';

import '../providers/goals_provider.dart';
import '../models/goal_models.dart';
import '../utils/progress_calculator.dart';

import 'create_goal_screen.dart';
import 'dart:developer' as developer;

class GoalDetailScreen extends ConsumerStatefulWidget {
  final PersonalGoal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // Get the latest goal data from the provider
    final goalsState = ref.watch(goalsProvider);
    final currentGoal = goalsState.goals.firstWhere(
      (g) => g.id == widget.goal.id,
      orElse: () => widget.goal,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          currentGoal.name,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, currentGoal),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Edit Goal'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Goal', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal Overview Card
            _buildGoalOverviewCard(currentGoal),

            const SizedBox(height: 20),

            // Progress Details Card
            _buildProgressDetailsCard(currentGoal),

            const SizedBox(height: 20),

            // Investment Planning Card
            _buildInvestmentPlanningCard(currentGoal),
          ],
        ),
      ),
    );
  }

  void _refreshData() {
    developer.log('🔄 [GOAL_DETAIL] Refreshing goal data and fund investments');

    // Trigger refresh of fund investments data
    ref.read(refreshFundInvestmentsProvider.notifier).state++;

    // Also refresh goals data to get updated goal information
    ref.read(refreshGoalsProvider.notifier).state++;

    // Show a brief feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing data...'),
        duration: Duration(seconds: 1),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildGoalOverviewCard(PersonalGoal goal) {
    final fundInvestmentsAsync = ref.watch(fundInvestmentsWithRefreshProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getStatusColor(goal.status),
            _getStatusColor(goal.status).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: fundInvestmentsAsync.when(
        data: (investmentsData) =>
            _buildGoalOverviewContent(goal, investmentsData),
        loading: () => _buildGoalOverviewLoading(goal),
        error: (error, stack) => _buildGoalOverviewContent(goal, {}),
      ),
    );
  }

  Widget _buildGoalOverviewContent(
    PersonalGoal goal,
    Map<String, dynamic> investmentsData,
  ) {
    final progress = ProgressCalculator.calculateProgress(
      goal: goal,
      fundInvestmentsData: investmentsData,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                goal.name,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatusDisplayName(goal.status),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        if (goal.description != null && goal.description!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            goal.description!,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],

        // Allocation info
        if (progress.fundName != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              ProgressCalculator.getAllocationDescription(progress),
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Progress Circle and Amount
        Row(
          children: [
            // Progress Circle
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                children: [
                  // Background circle
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  // Progress circle
                  CircularProgressIndicator(
                    value: progress.progressPercentage / 100,
                    strokeWidth: 6,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                  // Percentage text
                  Center(
                    child: Text(
                      '${progress.progressPercentage.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 20),

            // Amount Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Amount',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatAmountWithCurrency(
                      progress.allocatedAmount,
                    ),
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Target: ${CurrencyFormatter.formatAmountWithCurrency(goal.targetAmount)}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalOverviewLoading(PersonalGoal goal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                goal.name,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatusDisplayName(goal.status),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Loading indicator
        Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                'Loading progress...',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressDetailsCard(PersonalGoal goal) {
    final fundInvestmentsAsync = ref.watch(fundInvestmentsWithRefreshProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        data: (investmentsData) =>
            _buildProgressDetailsContent(goal, investmentsData),
        loading: () => _buildProgressDetailsLoading(),
        error: (error, stack) => _buildProgressDetailsContent(goal, {}),
      ),
    );
  }

  Widget _buildProgressDetailsContent(
    PersonalGoal goal,
    Map<String, dynamic> investmentsData,
  ) {
    final progress = ProgressCalculator.calculateProgress(
      goal: goal,
      fundInvestmentsData: investmentsData,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress Details',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),

        const SizedBox(height: 16),

        // Progress Stats
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Remaining',
                CurrencyFormatter.formatAmountWithCurrency(
                  progress.remainingAmount,
                ),
                Icons.trending_up,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'Target Date',
                _formatTargetDate(goal.targetDate),
                Icons.calendar_today,
              ),
            ),
          ],
        ),

        // Show allocation details if fund is linked
        if (progress.fundName != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Fund Investment',
                  CurrencyFormatter.formatAmountWithCurrency(
                    progress.totalFundInvestment,
                  ),
                  Icons.account_balance,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Allocation',
                  '${progress.allocationPercentage.toInt()}%',
                  Icons.pie_chart,
                ),
              ),
            ],
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
                  '${progress.progressPercentage.toStringAsFixed(1)}% Complete',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  '${CurrencyFormatter.formatAmountWithCurrency(progress.allocatedAmount)} / ${CurrencyFormatter.formatAmountWithCurrency(goal.targetAmount)}',
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
              value: progress.progressPercentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(goal.status),
              ),
              minHeight: 8,
            ),

            // Progress status text
            const SizedBox(height: 8),
            Text(
              ProgressCalculator.getProgressStatusText(progress),
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: progress.isCompleted
                    ? Colors.green.shade600
                    : AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressDetailsLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress Details',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentPlanningCard(PersonalGoal goal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Investment Planning',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '${_getFrequencyDisplayName(goal.investmentFrequency)} Investment',
                  CurrencyFormatter.formatAmountWithCurrency(
                    goal.requiredAmountPerFrequency,
                  ),
                  Icons.schedule,
                ),
              ),
              if (goal.linkedFundName != null)
                Expanded(
                  child: _buildStatItem(
                    'Linked Fund',
                    goal.linkedFundName!,
                    Icons.account_balance,
                  ),
                ),
            ],
          ),

          if (goal.reminderEnabled) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reminders enabled for ${_getFrequencyDisplayName(goal.investmentFrequency).toLowerCase()} investments',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'completed':
        return 'Completed';
      case 'paused':
        return 'Paused';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }

  String _getFrequencyDisplayName(String frequency) {
    switch (frequency) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'quarterly':
        return 'Quarterly';
      default:
        return frequency;
    }
  }

  String _formatTargetDate(String targetDate) {
    try {
      final date = DateTime.parse(targetDate);
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
      return targetDate;
    }
  }

  void _handleMenuAction(String action, PersonalGoal goal) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateGoalScreen(goalToEdit: goal),
          ),
        ).then((_) {
          // Refresh data when returning from edit screen
          developer.log(
            '🔄 [GOAL_DETAIL] Returned from edit screen, refreshing data',
          );
          _refreshData();
        });
        break;
      case 'delete':
        _showDeleteConfirmation(goal);
        break;
    }
  }

  void _showDeleteConfirmation(PersonalGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text(
          'Are you sure you want to delete "${goal.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Store the navigator and scaffold messenger before async operation
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              navigator.pop(); // Close dialog first

              final success = await ref
                  .read(goalsProvider.notifier)
                  .deleteGoal(goal.id);

              if (!mounted) return; // Check if widget is still mounted

              if (success) {
                navigator.pop(); // Go back to previous screen
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Goal deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete goal'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
