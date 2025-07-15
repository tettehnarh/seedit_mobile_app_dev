import 'package:flutter/material.dart';
import '../../../core/utils/app_theme.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

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
          // First Row
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.add_circle_outline,
                  label: 'Invest',
                  color: AppTheme.primaryColor,
                  onTap: () {
                    Navigator.pushNamed(context, '/investments');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Wallet',
                  color: AppTheme.secondaryColor,
                  onTap: () {
                    Navigator.pushNamed(context, '/wallet');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.trending_up,
                  label: 'Portfolio',
                  color: AppTheme.accentColor,
                  onTap: () {
                    Navigator.pushNamed(context, '/portfolio');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Second Row
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.flag_outlined,
                  label: 'Goals',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pushNamed(context, '/goals');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.history,
                  label: 'History',
                  color: AppTheme.companyInfoColor,
                  onTap: () {
                    Navigator.pushNamed(context, '/history');
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Empty space to balance the row
              const Expanded(child: SizedBox()),
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
}
