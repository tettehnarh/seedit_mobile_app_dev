import 'package:flutter/material.dart';
import '../../../core/utils/app_theme.dart';

// Import standardized dialogs
import '../../../shared/widgets/dialogs/dialogs.dart';

class WalletActionsCard extends StatelessWidget {
  const WalletActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            'Quick Actions',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.add_circle_outline,
                  label: 'Add Funds',
                  color: Colors.green,
                  onTap: () {
                    _showAddFundsDialog(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.remove_circle_outline,
                  label: 'Withdraw',
                  color: Colors.orange,
                  onTap: () {
                    _showWithdrawDialog(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.swap_horiz,
                  label: 'Transfer',
                  color: AppTheme.primaryColor,
                  onTap: () {
                    Navigator.pushNamed(context, '/transfer');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.receipt_long,
                  label: 'History',
                  color: AppTheme.companyInfoColor,
                  onTap: () {
                    Navigator.pushNamed(context, '/transaction-history');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFundsDialog(BuildContext context) {
    final fundingOptions = [
      SelectionOption<String>(
        value: 'bank',
        title: 'Bank Transfer',
        subtitle: 'Transfer from your bank account',
        icon: Icons.account_balance,
      ),
      SelectionOption<String>(
        value: 'card',
        title: 'Credit/Debit Card',
        subtitle: 'Pay with your card',
        icon: Icons.credit_card,
      ),
    ];

    SelectionDialog.show<String>(
      context: context,
      title: 'Add Funds',
      subtitle: 'Choose how you would like to add funds to your wallet:',
      options: fundingOptions,
      icon: Icons.add_circle,
    ).then((selectedMethod) {
      if (selectedMethod != null && context.mounted) {
        Navigator.pushNamed(context, '/add-funds/$selectedMethod');
      }
    });
  }

  void _showWithdrawDialog(BuildContext context) {
    final withdrawOptions = [
      SelectionOption<String>(
        value: 'bank',
        title: 'Bank Account',
        subtitle: 'Withdraw to your bank account',
        icon: Icons.account_balance,
      ),
    ];

    SelectionDialog.show<String>(
      context: context,
      title: 'Withdraw Funds',
      subtitle: 'Choose where you would like to withdraw funds:',
      options: withdrawOptions,
      icon: Icons.account_balance_wallet,
    ).then((selectedMethod) {
      if (selectedMethod != null && context.mounted) {
        Navigator.pushNamed(context, '/withdraw/$selectedMethod');
      }
    });
  }
}
