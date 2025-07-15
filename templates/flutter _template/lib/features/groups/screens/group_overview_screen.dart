import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_theme.dart';
import '../models/group_models.dart';

class GroupOverviewScreen extends ConsumerWidget {
  final InvestmentGroup group;

  const GroupOverviewScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Group Overview',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('Description', group.description, Icons.description),
            const SizedBox(height: 16),
            _buildInfoCard('Investment Goal', group.investmentGoal, Icons.flag),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Fund Details',
              '${group.designatedFund.name}\nType: ${group.designatedFund.categoryName}\nMinimum Investment: GHS ${_formatAmount(group.designatedFund.minimumInvestment)}',
              Icons.account_balance,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Timeline',
              'Start: ${_formatDate(group.startDate)}\nEnd: ${_formatDate(group.endDate)}',
              Icons.schedule,
            ),
            if (group.minimumContribution != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                'Contribution Details',
                'Minimum: GHS ${_formatAmount(group.minimumContribution!)}\nFrequency: ${group.contributionFrequency}',
                Icons.payment,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.companyInfoColor,
              fontFamily: 'Montserrat',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
