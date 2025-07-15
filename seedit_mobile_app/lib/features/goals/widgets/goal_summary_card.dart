import 'package:flutter/material.dart';
import '../../../shared/models/goal_model.dart';

class GoalSummaryCard extends StatelessWidget {
  final List<FinancialGoal> goals;

  const GoalSummaryCard({
    super.key,
    required this.goals,
  });

  @override
  Widget build(BuildContext context) {
    final totalTarget = goals.fold<double>(0, (sum, goal) => sum + goal.targetAmount);
    final totalCurrent = goals.fold<double>(0, (sum, goal) => sum + goal.currentAmount);
    final overallProgress = totalTarget > 0 ? (totalCurrent / totalTarget) * 100 : 0.0;
    final activeGoals = goals.where((goal) => goal.status == GoalStatus.active).length;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Financial Goals',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.flag,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Total current amount
            Text(
              '₦${totalCurrent.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              'Total Saved • ${overallProgress.toStringAsFixed(1)}% of target',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Goal metrics
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    'Active Goals',
                    '$activeGoals of ${goals.length}',
                    Icons.flag_outlined,
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    'Target Amount',
                    '₦${totalTarget.toStringAsFixed(0)}',
                    Icons.trending_up,
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    'Remaining',
                    '₦${(totalTarget - totalCurrent).toStringAsFixed(0)}',
                    Icons.schedule,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class GoalQuickStats extends StatelessWidget {
  final List<FinancialGoal> goals;

  const GoalQuickStats({
    super.key,
    required this.goals,
  });

  @override
  Widget build(BuildContext context) {
    final activeGoals = goals.where((goal) => goal.status == GoalStatus.active).toList();
    final completedGoals = goals.where((goal) => goal.status == GoalStatus.completed).toList();
    final onTrackGoals = goals.where((goal) => goal.isOnTrack).toList();
    final overdueGoals = goals.where((goal) => goal.isOverdue).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Active',
                    '${activeGoals.length}',
                    Colors.green,
                    Icons.flag,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Completed',
                    '${completedGoals.length}',
                    Colors.blue,
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'On Track',
                    '${onTrackGoals.length}',
                    Colors.orange,
                    Icons.trending_up,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Overdue',
                    '${overdueGoals.length}',
                    Colors.red,
                    Icons.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class GoalCategoryBreakdown extends StatelessWidget {
  final List<FinancialGoal> goals;

  const GoalCategoryBreakdown({
    super.key,
    required this.goals,
  });

  @override
  Widget build(BuildContext context) {
    final categoryData = <GoalCategory, Map<String, dynamic>>{};
    
    for (final goal in goals) {
      if (!categoryData.containsKey(goal.category)) {
        categoryData[goal.category] = {
          'count': 0,
          'totalTarget': 0.0,
          'totalCurrent': 0.0,
        };
      }
      
      categoryData[goal.category]!['count']++;
      categoryData[goal.category]!['totalTarget'] += goal.targetAmount;
      categoryData[goal.category]!['totalCurrent'] += goal.currentAmount;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Goals by Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            ...categoryData.entries.map((entry) {
              final category = entry.key;
              final data = entry.value;
              final progress = data['totalTarget'] > 0 
                  ? (data['totalCurrent'] / data['totalTarget']) * 100 
                  : 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCategoryItem(
                  category,
                  data['count'],
                  progress,
                  data['totalCurrent'],
                  data['totalTarget'],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    GoalCategory category,
    int count,
    double progress,
    double current,
    double target,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 20,
              color: _getCategoryColor(category),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getCategoryText(category),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$count goal${count > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        LinearProgressIndicator(
          value: progress / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(_getCategoryColor(category)),
        ),
        
        const SizedBox(height: 4),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${progress.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '₦${current.toStringAsFixed(0)} of ₦${target.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getCategoryIcon(GoalCategory category) {
    switch (category) {
      case GoalCategory.retirement:
        return Icons.elderly;
      case GoalCategory.education:
        return Icons.school;
      case GoalCategory.homePurchase:
        return Icons.home;
      case GoalCategory.emergencyFund:
        return Icons.security;
      case GoalCategory.vacation:
        return Icons.flight;
      case GoalCategory.wedding:
        return Icons.favorite;
      case GoalCategory.business:
        return Icons.business;
      case GoalCategory.vehicle:
        return Icons.directions_car;
      case GoalCategory.healthcare:
        return Icons.local_hospital;
      case GoalCategory.other:
        return Icons.more_horiz;
    }
  }

  String _getCategoryText(GoalCategory category) {
    switch (category) {
      case GoalCategory.retirement:
        return 'Retirement';
      case GoalCategory.education:
        return 'Education';
      case GoalCategory.homePurchase:
        return 'Home Purchase';
      case GoalCategory.emergencyFund:
        return 'Emergency Fund';
      case GoalCategory.vacation:
        return 'Vacation';
      case GoalCategory.wedding:
        return 'Wedding';
      case GoalCategory.business:
        return 'Business';
      case GoalCategory.vehicle:
        return 'Vehicle';
      case GoalCategory.healthcare:
        return 'Healthcare';
      case GoalCategory.other:
        return 'Other';
    }
  }

  Color _getCategoryColor(GoalCategory category) {
    switch (category) {
      case GoalCategory.retirement:
        return Colors.purple;
      case GoalCategory.education:
        return Colors.blue;
      case GoalCategory.homePurchase:
        return Colors.green;
      case GoalCategory.emergencyFund:
        return Colors.red;
      case GoalCategory.vacation:
        return Colors.orange;
      case GoalCategory.wedding:
        return Colors.pink;
      case GoalCategory.business:
        return Colors.indigo;
      case GoalCategory.vehicle:
        return Colors.teal;
      case GoalCategory.healthcare:
        return Colors.cyan;
      case GoalCategory.other:
        return Colors.grey;
    }
  }
}
