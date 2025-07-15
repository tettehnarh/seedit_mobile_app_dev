import 'package:flutter/material.dart';
import '../../../shared/models/goal_model.dart';

class GoalCard extends StatelessWidget {
  final FinancialGoal goal;
  final VoidCallback? onTap;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onComplete;
  final bool isCompact;

  const GoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.onPause,
    this.onResume,
    this.onComplete,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with goal name and badges
              Row(
                children: [
                  Expanded(
                    child: Text(
                      goal.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: isCompact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildPriorityBadge(),
                  const SizedBox(width: 8),
                  _buildStatusBadge(),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Goal description
              Text(
                goal.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: isCompact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Progress bar
              _buildProgressBar(),
              
              const SizedBox(height: 12),
              
              // Goal metrics
              Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      'Target',
                      goal.formattedTargetAmount,
                      Icons.flag,
                    ),
                  ),
                  Expanded(
                    child: _buildMetric(
                      'Current',
                      goal.formattedCurrentAmount,
                      Icons.trending_up,
                    ),
                  ),
                  Expanded(
                    child: _buildMetric(
                      'Days Left',
                      '${goal.daysRemaining}',
                      Icons.schedule,
                    ),
                  ),
                ],
              ),
              
              if (!isCompact) ...[
                const SizedBox(height: 12),
                
                // Category and target date
                Row(
                  children: [
                    Icon(
                      _getCategoryIcon(goal.category),
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _getCategoryText(goal.category),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(goal.targetDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Monthly requirement
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: goal.isOnTrack ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        goal.isOnTrack ? Icons.check_circle : Icons.warning,
                        size: 16,
                        color: goal.isOnTrack ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          goal.isOnTrack 
                              ? 'On track to achieve goal'
                              : 'Need ${goal.formattedMonthlyRequired}/month',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: goal.isOnTrack ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Action buttons
                Row(
                  children: [
                    if (goal.status == GoalStatus.active && onPause != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onPause,
                          icon: const Icon(Icons.pause, size: 16),
                          label: const Text('Pause'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    
                    if (goal.status == GoalStatus.paused && onResume != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onResume,
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text('Resume'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    
                    if (goal.isCompleted && goal.status != GoalStatus.completed && onComplete != null) ...[
                      if (onPause != null || onResume != null) const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onComplete,
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Complete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge() {
    Color color;
    String label;
    
    switch (goal.priority) {
      case GoalPriority.low:
        color = Colors.grey;
        label = 'Low';
        break;
      case GoalPriority.medium:
        color = Colors.blue;
        label = 'Medium';
        break;
      case GoalPriority.high:
        color = Colors.orange;
        label = 'High';
        break;
      case GoalPriority.critical:
        color = Colors.red;
        label = 'Critical';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;
    
    switch (goal.status) {
      case GoalStatus.active:
        color = Colors.green;
        label = 'Active';
        break;
      case GoalStatus.paused:
        color = Colors.orange;
        label = 'Paused';
        break;
      case GoalStatus.completed:
        color = Colors.blue;
        label = 'Completed';
        break;
      case GoalStatus.cancelled:
        color = Colors.red;
        label = 'Cancelled';
        break;
      case GoalStatus.overdue:
        color = Colors.red;
        label = 'Overdue';
        break;
      case GoalStatus.draft:
        color = Colors.grey;
        label = 'Draft';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${goal.progressPercentage.toStringAsFixed(1)}% achieved',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              goal.formattedRemainingAmount + ' remaining',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: goal.progressPercentage / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            goal.isCompleted ? Colors.green : Theme.of(context).primaryColor,
          ),
        ),
      ],
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
              size: 14,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class GoalListTile extends StatelessWidget {
  final FinancialGoal goal;
  final VoidCallback? onTap;

  const GoalListTile({
    super.key,
    required this.goal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(goal.status).withOpacity(0.1),
        child: Icon(
          _getCategoryIcon(goal.category),
          color: _getStatusColor(goal.status),
          size: 20,
        ),
      ),
      title: Text(
        goal.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            goal.description,
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${goal.progressPercentage.toStringAsFixed(0)}% • ${goal.daysRemaining} days left',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            goal.formattedCurrentAmount,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            'of ${goal.formattedTargetAmount}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(GoalStatus status) {
    switch (status) {
      case GoalStatus.active:
        return Colors.green;
      case GoalStatus.paused:
        return Colors.orange;
      case GoalStatus.completed:
        return Colors.blue;
      case GoalStatus.cancelled:
        return Colors.red;
      case GoalStatus.overdue:
        return Colors.red;
      case GoalStatus.draft:
        return Colors.grey;
    }
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
}
