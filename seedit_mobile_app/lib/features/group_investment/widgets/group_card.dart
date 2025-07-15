import 'package:flutter/material.dart';
import '../../../shared/models/group_investment_model.dart';

class GroupCard extends StatelessWidget {
  final InvestmentGroup group;
  final VoidCallback? onTap;
  final bool showMemberBadge;
  final bool isCompact;

  const GroupCard({
    super.key,
    required this.group,
    this.onTap,
    this.showMemberBadge = false,
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
              // Header with group name and badges
              Row(
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: isCompact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showMemberBadge) _buildMemberBadge(),
                  _buildGroupTypeBadge(),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Group description
              Text(
                group.description,
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
              
              // Group metrics
              Row(
                children: [
                  Expanded(
                    child: _buildMetric(
                      'Target',
                      group.formattedTargetAmount,
                      Icons.flag,
                    ),
                  ),
                  Expanded(
                    child: _buildMetric(
                      'Raised',
                      group.formattedCurrentAmount,
                      Icons.trending_up,
                    ),
                  ),
                  Expanded(
                    child: _buildMetric(
                      'Members',
                      '${group.currentMembers}/${group.maxMembers}',
                      Icons.group,
                    ),
                  ),
                ],
              ),
              
              if (!isCompact) ...[
                const SizedBox(height: 12),
                
                // Fund and creator info
                Row(
                  children: [
                    Icon(
                      Icons.account_balance,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        group.fundName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'by ${group.creatorName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Tags
                if (group.tags.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: group.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 12,
            color: Colors.blue[700],
          ),
          const SizedBox(width: 4),
          Text(
            'Member',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTypeBadge() {
    Color color;
    String label;
    
    switch (group.type) {
      case GroupType.investmentClub:
        color = Colors.purple;
        label = 'Club';
        break;
      case GroupType.savingsGroup:
        color = Colors.green;
        label = 'Savings';
        break;
      case GroupType.goalBased:
        color = Colors.orange;
        label = 'Goal';
        break;
      case GroupType.challenge:
        color = Colors.red;
        label = 'Challenge';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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
              '${group.progressPercentage.toStringAsFixed(1)}% funded',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              group.formattedRemainingAmount + ' remaining',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: group.progressPercentage / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            group.isTargetReached ? Colors.green : Theme.of(context).primaryColor,
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
}

class GroupListTile extends StatelessWidget {
  final InvestmentGroup group;
  final VoidCallback? onTap;

  const GroupListTile({
    super.key,
    required this.group,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: _getGroupTypeColor(group.type).withOpacity(0.1),
        child: Icon(
          _getGroupTypeIcon(group.type),
          color: _getGroupTypeColor(group.type),
          size: 20,
        ),
      ),
      title: Text(
        group.name,
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
            group.description,
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${group.currentMembers}/${group.maxMembers} members • ${group.progressPercentage.toStringAsFixed(0)}% funded',
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
            group.formattedCurrentAmount,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            'of ${group.formattedTargetAmount}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getGroupTypeColor(GroupType type) {
    switch (type) {
      case GroupType.investmentClub:
        return Colors.purple;
      case GroupType.savingsGroup:
        return Colors.green;
      case GroupType.goalBased:
        return Colors.orange;
      case GroupType.challenge:
        return Colors.red;
    }
  }

  IconData _getGroupTypeIcon(GroupType type) {
    switch (type) {
      case GroupType.investmentClub:
        return Icons.groups;
      case GroupType.savingsGroup:
        return Icons.savings;
      case GroupType.goalBased:
        return Icons.flag;
      case GroupType.challenge:
        return Icons.emoji_events;
    }
  }
}

class GroupSummaryCard extends StatelessWidget {
  final InvestmentGroup group;
  final VoidCallback? onTap;

  const GroupSummaryCard({
    super.key,
    required this.group,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getGroupTypeColor(group.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getGroupTypeIcon(group.type),
                  color: _getGroupTypeColor(group.type),
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${group.currentMembers} members',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${group.progressPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: group.isTargetReached ? Colors.green : Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    group.formattedCurrentAmount,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getGroupTypeColor(GroupType type) {
    switch (type) {
      case GroupType.investmentClub:
        return Colors.purple;
      case GroupType.savingsGroup:
        return Colors.green;
      case GroupType.goalBased:
        return Colors.orange;
      case GroupType.challenge:
        return Colors.red;
    }
  }

  IconData _getGroupTypeIcon(GroupType type) {
    switch (type) {
      case GroupType.investmentClub:
        return Icons.groups;
      case GroupType.savingsGroup:
        return Icons.savings;
      case GroupType.goalBased:
        return Icons.flag;
      case GroupType.challenge:
        return Icons.emoji_events;
    }
  }
}
