import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/investment_model.dart';

class PortfolioHoldingsList extends StatelessWidget {
  final List<PortfolioHolding> holdings;
  final List<Investment> investments;

  const PortfolioHoldingsList({
    super.key,
    required this.holdings,
    required this.investments,
  });

  @override
  Widget build(BuildContext context) {
    if (holdings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Holdings Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start investing to see your holdings here',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: holdings.length,
      itemBuilder: (context, index) {
        final holding = holdings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: HoldingCard(
            holding: holding,
            onTap: () => context.push('/funds/${holding.fundId}'),
          ),
        );
      },
    );
  }
}

class HoldingCard extends StatelessWidget {
  final PortfolioHolding holding;
  final VoidCallback? onTap;

  const HoldingCard({
    super.key,
    required this.holding,
    this.onTap,
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
              // Header with fund name and allocation
              Row(
                children: [
                  Expanded(
                    child: Text(
                      holding.fundName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${holding.allocationPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Value and gain/loss
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Value',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        holding.formattedCurrentValue,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Gain/Loss',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            holding.isProfit ? Icons.trending_up : Icons.trending_down,
                            color: holding.isProfit ? Colors.green : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            holding.formattedGainLoss,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: holding.isProfit ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        holding.formattedGainLossPercentage,
                        style: TextStyle(
                          fontSize: 12,
                          color: holding.isProfit ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Units and NAV details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Units',
                        holding.units.toStringAsFixed(4),
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Avg. NAV',
                        '₦${holding.averageNAV.toStringAsFixed(2)}',
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Current NAV',
                        '₦${holding.currentNAV.toStringAsFixed(2)}',
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.push('/investment/order/${holding.fundId}');
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Buy More'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showRedeemDialog(context, holding);
                      },
                      icon: const Icon(Icons.remove, size: 16),
                      label: const Text('Redeem'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
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

  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showRedeemDialog(BuildContext context, PortfolioHolding holding) {
    showDialog(
      context: context,
      builder: (context) => RedeemDialog(holding: holding),
    );
  }
}

class RedeemDialog extends StatefulWidget {
  final PortfolioHolding holding;

  const RedeemDialog({
    super.key,
    required this.holding,
  });

  @override
  State<RedeemDialog> createState() => _RedeemDialogState();
}

class _RedeemDialogState extends State<RedeemDialog> {
  final _unitsController = TextEditingController();
  bool _redeemAll = false;

  @override
  void dispose() {
    _unitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxUnits = widget.holding.units;
    final unitsToRedeem = _redeemAll 
        ? maxUnits 
        : double.tryParse(_unitsController.text) ?? 0.0;
    final redeemValue = unitsToRedeem * widget.holding.currentNAV;

    return AlertDialog(
      title: const Text('Redeem Investment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fund: ${widget.holding.fundName}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text('Available Units: ${maxUnits.toStringAsFixed(4)}'),
          Text('Current NAV: ₦${widget.holding.currentNAV.toStringAsFixed(2)}'),
          
          const SizedBox(height: 16),
          
          // Redeem all checkbox
          CheckboxListTile(
            title: const Text('Redeem All Units'),
            value: _redeemAll,
            onChanged: (value) {
              setState(() {
                _redeemAll = value ?? false;
                if (_redeemAll) {
                  _unitsController.text = maxUnits.toStringAsFixed(4);
                } else {
                  _unitsController.clear();
                }
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          
          // Units input
          if (!_redeemAll)
            TextFormField(
              controller: _unitsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Units to Redeem',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {}); // Trigger rebuild for value calculation
              },
            ),
          
          const SizedBox(height: 16),
          
          // Redemption summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Redemption Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Units: ${unitsToRedeem.toStringAsFixed(4)}'),
                Text('Estimated Value: ₦${redeemValue.toStringAsFixed(2)}'),
                const SizedBox(height: 4),
                Text(
                  'Note: Final amount may vary based on NAV at redemption time',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: unitsToRedeem > 0 && unitsToRedeem <= maxUnits
              ? () {
                  Navigator.of(context).pop();
                  // TODO: Implement redemption logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Redemption request submitted'),
                    ),
                  );
                }
              : null,
          child: const Text('Redeem'),
        ),
      ],
    );
  }
}

class HoldingListTile extends StatelessWidget {
  final PortfolioHolding holding;
  final VoidCallback? onTap;

  const HoldingListTile({
    super.key,
    required this.holding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Text(
          holding.fundName.substring(0, 2).toUpperCase(),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      title: Text(
        holding.fundName,
        style: const TextStyle(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${holding.units.toStringAsFixed(4)} units',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            '${holding.allocationPercentage.toStringAsFixed(1)}% of portfolio',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            holding.formattedCurrentValue,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                holding.isProfit ? Icons.trending_up : Icons.trending_down,
                color: holding.isProfit ? Colors.green : Colors.red,
                size: 12,
              ),
              Text(
                holding.formattedGainLossPercentage,
                style: TextStyle(
                  color: holding.isProfit ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
