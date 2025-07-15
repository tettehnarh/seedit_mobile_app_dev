import 'package:flutter/material.dart';

class PortfolioActionsBar extends StatelessWidget {
  final VoidCallback? onInvestMore;
  final VoidCallback? onWithdraw;
  final VoidCallback? onRebalance;
  final VoidCallback? onAnalytics;

  const PortfolioActionsBar({
    super.key,
    this.onInvestMore,
    this.onWithdraw,
    this.onRebalance,
    this.onAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Invest More',
                Icons.add_circle_outline,
                Colors.green,
                onInvestMore,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                context,
                'Withdraw',
                Icons.remove_circle_outline,
                Colors.orange,
                onWithdraw,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                context,
                'Rebalance',
                Icons.balance,
                Colors.blue,
                onRebalance,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                context,
                'Analytics',
                Icons.analytics,
                Colors.purple,
                onAnalytics,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback? onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class PortfolioQuickActions extends StatelessWidget {
  final VoidCallback? onInvestMore;
  final VoidCallback? onWithdraw;
  final VoidCallback? onRebalance;
  final VoidCallback? onSwitchFunds;

  const PortfolioQuickActions({
    super.key,
    this.onInvestMore,
    this.onWithdraw,
    this.onRebalance,
    this.onSwitchFunds,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildQuickActionCard(
              'Invest More',
              'Add funds to existing investments',
              Icons.add_circle,
              Colors.green,
              onInvestMore,
            ),
            _buildQuickActionCard(
              'Withdraw',
              'Redeem from your investments',
              Icons.remove_circle,
              Colors.orange,
              onWithdraw,
            ),
            _buildQuickActionCard(
              'Rebalance',
              'Optimize your portfolio allocation',
              Icons.balance,
              Colors.blue,
              onRebalance,
            ),
            _buildQuickActionCard(
              'Switch Funds',
              'Move between different funds',
              Icons.swap_horiz,
              Colors.purple,
              onSwitchFunds,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback? onPressed,
  ) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PortfolioActionButtons extends StatelessWidget {
  final VoidCallback? onInvestMore;
  final VoidCallback? onWithdraw;
  final VoidCallback? onRebalance;

  const PortfolioActionButtons({
    super.key,
    this.onInvestMore,
    this.onWithdraw,
    this.onRebalance,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onInvestMore,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Invest More'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onWithdraw,
            icon: const Icon(Icons.remove, size: 18),
            label: const Text('Withdraw'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        IconButton(
          onPressed: onRebalance,
          icon: const Icon(Icons.balance),
          style: IconButton.styleFrom(
            backgroundColor: Colors.blue.withOpacity(0.1),
            foregroundColor: Colors.blue,
          ),
          tooltip: 'Rebalance Portfolio',
        ),
      ],
    );
  }
}

class PortfolioFloatingActions extends StatelessWidget {
  final VoidCallback? onInvestMore;
  final VoidCallback? onQuickAction;

  const PortfolioFloatingActions({
    super.key,
    this.onInvestMore,
    this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: onQuickAction,
          heroTag: 'quick_action',
          backgroundColor: Colors.blue,
          child: const Icon(Icons.more_horiz),
        ),
        
        const SizedBox(height: 16),
        
        FloatingActionButton.extended(
          onPressed: onInvestMore,
          heroTag: 'invest_more',
          backgroundColor: Colors.green,
          icon: const Icon(Icons.add),
          label: const Text('Invest'),
        ),
      ],
    );
  }
}

class PortfolioActionSheet extends StatelessWidget {
  final VoidCallback? onInvestMore;
  final VoidCallback? onWithdraw;
  final VoidCallback? onRebalance;
  final VoidCallback? onSwitchFunds;
  final VoidCallback? onAnalytics;
  final VoidCallback? onSettings;

  const PortfolioActionSheet({
    super.key,
    this.onInvestMore,
    this.onWithdraw,
    this.onRebalance,
    this.onSwitchFunds,
    this.onAnalytics,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const Text(
            'Portfolio Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          _buildActionItem(
            'Invest More',
            'Add funds to your portfolio',
            Icons.add_circle,
            Colors.green,
            onInvestMore,
          ),
          
          _buildActionItem(
            'Withdraw Funds',
            'Redeem from your investments',
            Icons.remove_circle,
            Colors.orange,
            onWithdraw,
          ),
          
          _buildActionItem(
            'Rebalance Portfolio',
            'Optimize your asset allocation',
            Icons.balance,
            Colors.blue,
            onRebalance,
          ),
          
          _buildActionItem(
            'Switch Funds',
            'Move between different funds',
            Icons.swap_horiz,
            Colors.purple,
            onSwitchFunds,
          ),
          
          _buildActionItem(
            'Portfolio Analytics',
            'View detailed performance analysis',
            Icons.analytics,
            Colors.teal,
            onAnalytics,
          ),
          
          _buildActionItem(
            'Portfolio Settings',
            'Manage your portfolio preferences',
            Icons.settings,
            Colors.grey,
            onSettings,
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback? onPressed,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        onPressed?.call();
      },
    );
  }
}
